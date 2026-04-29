# ICP

ICP is management console for WSO2 integration runtimes MI, BI (monitors/on runtimes).
UI has three levels: organizations → projects → components.
Same feature (eg: view runtime) may exist in each levels.
Roles can be assigned to user groups in per level basis.
components → environment → runtime. Environment occurs here in hierarchy, but managed at org level.

## MI and BI

- MI (Micro Integrator): A Product, Java. Contains many artifacts. Mgt API with JWT auth.
- BI: VSCode fork called Ballerina Integrator. But in this context, BI is an app (artifact) written _in_ BI, embedding the bridge.

|                | BI                           | MI          |
| -------------- | ---------------------------- | ----------- |
| Heartbeat(10s) | `icp-runtime-bridge`         | builtin     |
| Control Signal | piggybacked on the heartbeat | Mgt API     |
| Config         | deployment.toml, log4j       | Config.toml |
| Artifact Lang  | Ballerina language (-> .jar) | XML         |
| Deployment     | Compiled                     | Interpreted |

# Structure

- . : a repo with submodules for icp, mi, bridge (git submodule update --remote often, it's safe to revert any local changes)
- ./icp
- ./mi
- ./bridge : icp-runtime-bridge submodule
- ./artifacts/bi/ : BI artifacts (Ballerina projects). Each subdirectory is one artifact.
- ./artifacts/mi/ : MI artifacts (individual XML files).
- ./lab : local test setups, each self-contained, feel free to make more. Always leave the lab in a better state that you found.
- ./lab/bare-bi : ICP + BI + OpenSearch + Fluent Bit
- ./lab/bare-mi : ICP + MI
- ./lab/db-opsh-docker : ICP + MI + BI  and docker compose with PostgreSQL + OpenSearch
- ./lab/proxied : docker compose with icp + bi + mi + PostgreSQL + OpenSearch + wire dump tools
- ./downloads/ballerina-\* : used to build icp and bridge
- Makefile : `make icp`, `make bridge`, `make start bare-bi`, **MUST** use make commands when relevant.


# QA Testing
Test like a real customer using the browser UI. See TESTING.md
