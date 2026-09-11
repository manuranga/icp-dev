# How to Create a Lab

1. Create `lab/<name>/config/` with these scripts:

| Script | Required | Purpose |
|--------|----------|---------|
| `create.sh` | yes | Set up the lab from dist artifacts |
| `up.sh` | yes | Start all components |
| `stop.sh` | yes | Stop all components |
| `down.sh` | no | Extra cleanup before lifecycle wipes non-config files |
| `is-up.sh` | no | Exit 0 only if **every** process `up.sh` starts is alive |

2. Scripts run with these exported variables:

- `ROOT` — repo root
- `LAB_DIR` — `lab/<name>`
- `DIST_DIR` — `dist/`
- `CONFIG_DIR` — `lab/<name>/config`

3. Source `make/helpers.sh` in your scripts for these:

- `logged_run <name> <cmd...>` — run in background, write pid + log; skips an already-live process, so `make start` repairs a half-dead lab
- `require_ports <port...>` — abort, naming the owning pid and its worktree, if a port is taken
- `wait_http <label> <url>` — poll until the url answers, else fail
- `wait_for_runtimes <count> [icp-url]` — poll ICP until `count` runtimes report RUNNING; proves heartbeats flow, not just that ports opened
- `pid_alive <name>` — true if component is running
- `pid_stop <name>` — kill children + parent, remove pid file
- `copy_bi_artifact <name> <local-bridge|remote-bridge[:version]> <dest>` — build and copy a BI artifact
- `copy_mi_artifact <filename.xml> <dest-dir>` — copy an MI artifact XML

4. Put any patch files or docker-compose configs in `config/`. This directory survives `reset`.

5. Use it:

```
make start <name>   # ensure running: creates if needed, restarts dead components
make stop <name>
make reset <name>   # fresh: stop, wipe everything but config/ and *.md, create, up
```

`up.sh` should end with readiness (`wait_http`) and, where a runtime is expected,
`wait_for_runtimes` — a lab that returns before it works costs more than it saves.

## Artifacts

Some labs need specific artifact. Create those as needed in `artifacts/bi/` or `artifacts/mi/`. Otherwise link to existing.
