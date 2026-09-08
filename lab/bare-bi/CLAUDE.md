# Lab: bare-bi

ICP + one BI app + OpenSearch + Fluent Bit. No MI.
The BI app is `artifacts/bi/hello-world`, built against the **local** bridge, so
`make bridge` must run before this lab starts.

## Components

| Component | Port | Notes |
|-----------|------|-------|
| ICP (console + API) | 9446 | `https://localhost:9446` — admin/admin |
| ICP (runtime listener) | 9445 | Heartbeats from BI land here |
| ICP (auth) | 9447 | |
| BI app | 9090 | `GET http://localhost:9090/greeting` → `Hello, World!` |
| OpenSearch | 9200 | Plain HTTP, no auth (Homebrew default) |
| Fluent Bit | 2020 | HTTP monitoring endpoint only |

OpenSearch and Fluent Bit come from Homebrew (`brew install opensearch fluent-bit`),
not from `dist/`. OpenSearch is **shared host-wide**, so other labs and older
sessions see the same indices and templates.

## Observability path

`bi/logs/app.log` + `bi/logs/metrics.log` → Fluent Bit (tail) → OpenSearch
indices `ballerina-application-logs-*` / `ballerina-metrics-logs-*` → ICP console.

`up.sh` deletes then re-puts both index templates, because a leftover template
from an earlier session blocks the put.

## Seeded identity

`config/seed.sql` inserts org secret `dev-very-bare-bi` for the `dev` environment,
so the app connects without a trip through the UI. On the first heartbeat ICP
auto-creates project `sample-project` and component `sample-integration` (type BI).
For a realistic test, skip the seed and copy the secret from the UI instead.

## Lifecycle

```
make start bare-bi
make stop  bare-bi
make reset bare-bi
```

## Logs

- `lab/bare-bi/logs/icp.log`
- `lab/bare-bi/logs/bi.log`
- `lab/bare-bi/logs/fluent-bit.log`
- `lab/bare-bi/logs/opensearch.log`

`bi.log` carries recurring `error collecting metric logs ... logger.v is null`
lines. Heartbeats and metric ingestion still work; ignore them unless the metrics
pipeline itself is under test.
