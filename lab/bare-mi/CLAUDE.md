# Lab: bare-mi

ICP + MI only. No OpenSearch, Fluentbit, or BI.
MI is pre-loaded with sample artifacts from `artifacts/mi/`.

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
make start bare-mi
make stop  bare-mi
make reset bare-mi
```

Both ICP and MI auto-start. MI secret is pre-seeded.

## Logs

- `lab/bare-mi/logs/icp.log`
- `lab/bare-mi/logs/mi.log`
