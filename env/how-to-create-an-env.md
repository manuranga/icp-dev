# How to Create an Environment

1. Create `env/<name>/config/` with these scripts:

| Script | Required | Purpose |
|--------|----------|---------|
| `create.sh` | yes | Set up the env from dist artifacts |
| `up.sh` | yes | Start all components |
| `stop.sh` | yes | Stop all components |
| `down.sh` | no | Extra cleanup before lifecycle wipes non-config files |
| `is-up.sh` | no | Exit 0 if any component is running |

2. Scripts run with these exported variables:

- `ROOT` — repo root
- `ENV_DIR` — `env/<name>`
- `DIST_DIR` — `dist/`
- `CONFIG_DIR` — `env/<name>/config`

3. Source `make/helpers.sh` in your scripts for these:

- `logged_run <name> <cmd...>` — run in background, write pid + log
- `pid_alive <name>` — true if component is running
- `pid_stop <name>` — kill children + parent, remove pid file

4. Put any patch files or docker-compose configs in `config/`. This directory survives `reset`.

5. Use it:

```
make start <name>
make stop <name>
make reset <name>
```
