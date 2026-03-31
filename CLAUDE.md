# ICP

ICP is management console for WSO2 integration runtimes MI, BI (monitors/on runtimes).

## MI and BI

**MI** — A Product, Java. Contains many artifacts. Mgt API with JWT auth.
**BI** — VSCode fork. But in this context, an app (artifact) written _in_ Ballerina Integrator, embedding icp-runtime-bridge.

|                | BI                           | MI          |
| -------------- | ---------------------------- | ----------- |
| Heartbeat(10s) | `icp-runtime-bridge`         | builtin     |
| Control Signal | piggybacked on the heartbeat | Mgt API     |
| Config         | deployment.toml, log4j       | Config.toml |
| Artifact Lang  | Ballerina language           | XML         |
| Deployment     | Compiled                     | Interpreted |

# Structure

- ./icp
- ./mi
- ./bi/icp-runtime-bridge
- ./bi/app
- ./envs : envs for testing, feel free to make more
- ./envs/compose-wire : docker with icp + 2 bi + mi (proxy) + mi (api) + PostgreSQL + wire dump tools
- ./envs/native - icp + bi + mi running bare, OpenSearch on docker
- ./downloads/ballerina-\* : used to build icp and bi/app
- Makefile : `make` to build and update envs/compose-debug
