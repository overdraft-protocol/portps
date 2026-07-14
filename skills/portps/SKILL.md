---
name: portps
description: >-
  Find or kill processes listening on TCP ports using the portps CLI.
  Use when a port is in use, something is already listening, the user asks
  what is on a port, needs to free a port, or wants to kill a listener by
  port number or glob pattern (e.g. 3000, 91*, 9???).
---

# portps

Use the `portps` CLI to inspect or kill TCP listeners. Prefer it over ad-hoc
`lsof` / `kill` pipelines when matching by port.

## Install if missing

```bash
npm install -g @overdraft-protocol/portps
# or: brew install --HEAD overdraft-protocol/tap/portps   # once tap exists
# or from this repo: ./install.sh --shell
```

Confirm:

```bash
command -v portps && portps 2>&1 | head -2
```

## Commands

Quote glob patterns so the shell does not expand them (agents should always quote):

```bash
portps 9100              # exact port
portps '91*'             # ports starting with 91
portps '9???'            # four-character ports starting with 9
portps '90[01]*'         # 900… / 901…
portps -k 9100           # kill listener on 9100
portps -k '91*'          # kill all matching listeners
```

Flags: `-k` / `--kill`. Shell-safe synonyms `%`→`*` and `_`→`?` also work unquoted (`portps 91%`).

## Behavior

- Exact port + single match → `ps` details for that PID
- Glob or multiple matches → table: PORT PID PPID USER COMMAND
- No match → non-zero exit and a message on stderr

Requires macOS/Linux with `lsof` and `ps`. Works with bash or zsh.

## When not to use

- Do not kill processes unless the user asked to free/kill the port
- Do not use for UDP-only sockets (TCP listen only)
- Prefer quoting patterns in agent-run commands (`portps '300*'`) even if the
  user has a zsh `noglob` alias
