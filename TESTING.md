# QA Testing ICP

Typically use proxied lab or its variant for debugging or issue discovery. Otherwise, select/create correct lab. Read lab/<selected>/CLAUDE.md
When asked to test, do not rely on build time testing. **MUST** up a lab and test. Prefer UI tests over API (curl) testing.

## UI Testing

Use playwright-cli (npm @playwright/cli), Must use headed mode unless asked.

- browser: open --headed [url], attach [name], close, goto <url>, resize <w> <h>
- nav: go-back, go-forward, reload
- interact: click/dblclick/hover <target>, type/fill <target> <text>, drag <from> <to>, select <target> <val>, check/uncheck <target>, upload <file>
- keys: press/keydown/keyup <key>
- mouse: mousemove <x> <y>, mousedown/mouseup [btn], mousewheel <dx> <dy>
- inspect: snapshot [el], eval <func> [el], console [level], network
- dialog: dialog-accept [prompt], dialog-dismiss
- capture: screenshot [target], pdf, video-start/stop, video-chapter <title>, tracing-start/stop
- tabs: tab-list, tab-new [url], tab-close [idx], tab-select <idx>
- state: state-load/save <file>, delete-data
- cookies: cookie-list, cookie-get/set/delete <name>, cookie-clear
- storage: {local,session}storage-{list,get,set,delete,clear}
- network: route <pattern>, route-list, unroute [pattern], network-state-set <online|offline>
- debug: run-code [code], show, pause-at <loc>, resume, step-over
- sessions: list, close-all, kill-all
- setup: install, install-browser [browser]
- flags: --raw, --help [cmd], --version
