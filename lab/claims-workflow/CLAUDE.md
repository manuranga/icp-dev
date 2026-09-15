# Lab: claims-workflow

ICP + one durable-workflow BI app + Temporal + OpenSearch + Fluent Bit. The smallest setup that
exercises the console's workflow features: instance views, the human-task/approval queue, and the
workflow section of the Observability tab.

The app is `artifacts/bi/claims-workflow`, built against the **local** module and bridge, so
`make workflow` and `make bridge` must both run before this lab starts.

## Components

| Component | Port | Notes |
|-----------|------|-------|
| ICP (console + API) | 9446 | `https://localhost:9446` — admin/admin |
| ICP (runtime listener) | 9445 | Heartbeats from the app land here |
| ICP (auth) | 9447 | |
| claims-workflow | 8290 | `POST /claims`, `POST /claims/{workflowId}/bill`, `GET /claims` |
| Temporal | 7233 · 8233 | `temporalio/temporal:1.8.3` dev server in Docker, in-memory; UI on 8233 |
| OpenSearch | 9200 | Plain HTTP, no auth (Homebrew default) |
| Fluent Bit | 2020 | HTTP monitoring endpoint only |

Temporal is the one container; everything else is a host process. Its persistence is in-memory,
so a restart empties the console's instance list — which is what a lab wants.

## What the workflow covers

`claimApproval` is shaped to light up every view, not to model insurance:

| Console feature | What produces it |
|---|---|
| Activities on the flow rail | `recordState`, `validateClaim`, `executePayment` |
| Human task, role `MANAGER` | `reviewClaim`, and `reviewClaimWithBill` on the bill branch |
| Human task, role `ACCOUNTANT` | `approvePayment` |
| Branch with a taken/untaken arm | `if decision.outcome == "REQUEST_BILL"` |
| Event wait | `wait events.billUploaded`, resumed by `POST /claims/{id}/bill` |
| Review activity (`ON_FAILURE`) | submit a **negative amount**: `validateClaim` fails under a `retryPolicy`, and the review lands in Human Tasks |
| Workflow metrics | runs, activity attempts, task decisions, control operations |

Everything a human decides is decided **in the console** — the app deliberately has no task UI.

Two things this lab cannot show, both needing an artifact it does not have: a `PRE_RUN` approval
gate, which the module raises only for a durable agent's tool calls, and SSO with tasks gated on
groups from an IdP — here one seeded admin holds both task roles.
[wf-demo-claims-approval](https://github.com/hasithaa/wf-demo-claims-approval) covers both.

## Lifecycle

```
make start claims-workflow
make stop  claims-workflow
make reset claims-workflow
```

## Driving it

Start runs from the console (**Workflow Executions → Start New Workflow**) or over HTTP:

```sh
curl -s localhost:8290/claims -H 'Content-Type: application/json' \
     -d '{"amount": 2400, "submittedBy": "alice", "description": "Hotel flooded"}'
# → {"claimId": "CLM-...", "workflowId": "...", "status": "SUBMITTED"}

curl -s localhost:8290/claims/<workflowId>/bill -H 'Content-Type: application/json' \
     -d '{"url": "https://bills.example/1"}'     # resumes a run parked on the event
```

The event inlet has to be an HTTP call: events travel through the owning integration, never
through the ICP, so the console cannot deliver one.

## Logs

- `lab/claims-workflow/logs/{icp,bi,fluent-bit,opensearch}.log`
- `docker logs icplab-temporal`

## Observability path

Fluent Bit tails three files into OpenSearch. Three indices, three templates, re-put on every
`up.sh` because a leftover blocks the put:

| Index | Source |
|---|---|
| `ballerina-application-logs-*` | `bi/logs/app.log` |
| `ballerina-metrics-logs-*` | `bi/logs/metrics.log` — `ballerinax/metrics.logs` samples (`logger="metrics"`) |
| `ballerina-workflow-metrics-*` | both of the workflow module's sinks, below |

The module splits its own telemetry in two, which is the fiddly part of this lab:

- **Task decisions** go through `ballerina/log`, so they land in `bi/logs/app.log` next to the
  application lines. Fluent Bit re-tags them out before the application-log output claims them.
- **Run and activity samples** are printed by the module's Java layer to **stdout**, captured as
  `logs/bi.log`. Fluent Bit tails that too, keeping only `logger="workflow-metrics"` lines.

Those Java-side lines carry **no `icp_runtimeId`**, and the console's metrics query filters on one,
so every run and activity sample would be silently dropped. `up.sh` therefore starts Fluent Bit
*last* — after the runtime registers — and writes `fluent-bit/runtime-id.conf`, a `record_modifier`
filter that stamps the current id. This is a workaround for a runtime gap, not a lab quirk: any
deployment reading these samples needs the same back-fill.

OpenSearch is shared host-wide. If ingestion stops with `cluster_block_exception ... flood-stage
watermark`, the **host disk** is over 95% full, not OpenSearch — free space rather than raising the
watermark. (`colima ssh -- sudo fstrim -a` reclaims a pruned Docker VM's unused blocks.)

## Seeded identity

`config/seed.sql` inserts org secret `dev-workflow-lab` for the `dev` environment, so the app
connects without a trip through the UI. On the first heartbeat ICP auto-creates project
`workflow-project` and component `claims-workflow`. Skip the seed to rehearse real onboarding.
