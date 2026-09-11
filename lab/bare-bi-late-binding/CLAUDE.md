# Lab: bare-bi-late-binding

ICP + two BI apps, with **no seeded secret**. You copy the secret from the UI, the
way a customer does. Contrast with `bare-bi`, which seeds the secret in H2 and so
skips the whole onboarding path.

## Components

| Component | Port | Notes |
|-----------|------|-------|
| ICP (console + API) | 9446 | `https://localhost:9446` — admin/admin |
| ICP (runtime listener) | 9445 | Heartbeats land here |
| BI app 1 (`bi/`) | 9090 | Connected via `config/connect-bi.sh` |
| BI app 2 (`bi2/`) | 9090 | Same jar; connect by hand with a project-level secret |

Both apps are `artifacts/bi/hello-world` built against the **local** bridge, so
`make bridge` must run first. They share port 9090 — run one at a time, or edit
`bi2/Config.toml` before starting it.

## Lifecycle

```
make start bare-bi-late-binding     # starts ICP only
```

Then, in the UI, create the secret and copy the generated `Config.toml` snippet:

```
lab/bare-bi-late-binding/config/connect-bi.sh < snippet.toml
```

`connect-bi.sh` fills the placeholders (`sample-project`, `sample-integration`,
serverUrl 9445), starts BI, and waits until the runtime heartbeats into ICP.

```
make stop  bare-bi-late-binding
make reset bare-bi-late-binding
```

## Logs

- `lab/bare-bi-late-binding/logs/icp.log`
- `lab/bare-bi-late-binding/logs/bi.log`
