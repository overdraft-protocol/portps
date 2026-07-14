---
name: portps
description: >-
  Find or kill processes listening on TCP ports using the portps CLI.
  Use when a port is in use, something is already listening, the user asks
  what is on a port, needs to free a port, or wants to kill a listener by
  port number or glob pattern (e.g. 3000, 91%, 9___).
---

# portps

Use the `portps` CLI to inspect or kill TCP listeners. Prefer it over ad-hoc
`lsof` / `kill` pipelines when matching by port.

## Install if missing

```bash
npm install -g @overdraft-protocol/portps
# or: brew tap/trust/install overdraft-protocol/portps
# or from this repo: ./install.sh
```

Confirm:

```bash
command -v portps && portps --help
```

## Commands

Prefer **shell-safe** patterns so the shell never expands them (`%`→`*`, `_`→`?`):

```bash
portps 9100              # exact port
portps 91%               # ports starting with 91
portps 9___              # four-character ports starting with 9
portps -k 9100           # kill listener on 9100
portps -k 91%            # kill all matching listeners
```

Classic globs also work if quoted: `portps '91*'`, `portps '9???'`.

Optional once for unquoted classic globs on zsh: `portps --setup-shell`.

Flags: `-k` / `--kill`.

## Behavior

- Exact port + single match → `ps` details for that PID
- Glob or multiple matches → table: PORT PID PPID USER COMMAND
- No match → non-zero exit and a message on stderr

Requires macOS/Linux with `lsof` and `ps`. Works with bash or zsh.

## When not to use

- Do not kill processes unless the user asked to free/kill the port
- Do not use for UDP-only sockets (TCP listen only)
- In agent commands prefer `91%` / quoted `'91*'` — never bare `91*`
