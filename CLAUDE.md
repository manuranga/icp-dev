# ICP

ICP is management console for WSO2 integration runtimes MI, BI (monitors/on runtimes).
UI has three levels: organizations → projects → components.
Same feature (eg: view runtime) may exist in each levels.
Roles can be assigned to user groups in per level basis.
components → environment → runtime. Environment occurs here in hierarchy, but managed at org level.

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

- . : a repo with submodules for icp, mi, bridge (update as needed, it's safe to revert any local changes)
- ./icp
- ./mi
- ./bi/icp-runtime-bridge
- ./bi/app
- ./lab : local test setups, each self-contained, feel free to make more. Always leave the lab in a better state that you found.
- ./lab/proxied : docker compose with icp + bi + mi + PostgreSQL + OpenSearch + wire dump tools
- ./lab/bare : icp + bi + mi + PostgreSQL + OpenSearch running bare
- ./downloads/ballerina-\* : used to build icp and bi
- Makefile : `make icp`, `make start bare`, **MUST** use make commands when relevant.

# QA Testing
See TESTING.md
