# Lab: bare-mi-with-artifacts

ICP + MI only. No OpenSearch, Fluentbit, or BI.
MI is pre-loaded with one of each artifact type that ICP can display.

## Components

| Component | Port | Notes |
|-----------|------|-------|
| ICP (console + API) | 9446 | `https://localhost:9446` — admin/admin |
| ICP (runtime listener) | 9445 | Heartbeats from MI land here |
| MI (HTTP) | 8290 | |
| MI (HTTPS) | 8253 | |
| MI (management API) | 9164 | |
| MI (inbound HTTP) | 8095 | SampleInboundEndpoint |

## Pre-loaded Artifacts

| Type | Name |
|------|------|
| RestApi | HealthCheckAPI |
| ProxyService | SampleProxyService |
| Sequence | SampleSequence |
| Endpoint | SampleEndpoint |
| InboundEndpoint | SampleInboundEndpoint |
| Task | SampleTask |
| LocalEntry | SampleLocalEntry |
| MessageStore | SampleMessageStore |
| MessageProcessor | SampleMessageProcessor |
| Template | SampleTemplate |

## Lifecycle

```
make start bare-mi-with-artifacts
make stop  bare-mi-with-artifacts
make reset bare-mi-with-artifacts
```

Both ICP and MI auto-start. MI secret is pre-seeded.

## Logs

- `lab/bare-mi-with-artifacts/logs/icp.log`
- `lab/bare-mi-with-artifacts/logs/mi.log`
