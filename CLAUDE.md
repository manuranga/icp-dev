# ICP

ICP is management console for WSO2 integration runtimes MI, BI (monitors/on runtimes).

## MI and BI

- MI (Micro Integrator): A Product, Java. Contains many artifacts. Mgt API with JWT auth.
- BI: VSCode fork called Ballerina Integrator. But in this context, BI is an app (artifact) written _in_ BI, embedding icp-runtime-bridge.

|                | BI                           | MI          |
| -------------- | ---------------------------- | ----------- |
| Heartbeat(10s) | `icp-runtime-bridge`         | builtin     |
| Control Signal | piggybacked on the heartbeat | Mgt API     |
| Config         | deployment.toml, log4j       | Config.toml |
| Artifact Lang  | Ballerina language (-> .jar) | XML         |
| Deployment     | Compiled                     | Interpreted |

# Structure

- . : a repo with submodules for icp, mi, bridge
- ./icp
- ./mi
- ./bi/icp-runtime-bridge
- ./bi/app
- ./env : env for testing, each self-contained, feel free to make more
- ./env/proxied : docker compose with icp + bi + mi + PostgreSQL + OpenSearch + wire dump tools
- ./env/bare : icp icp + bi + mi running bare, PostgreSQL + OpenSearch on docker
- ./downloads/ballerina-\* : used to build icp and bi
- Makefile : `make icp`, `make start bare`
