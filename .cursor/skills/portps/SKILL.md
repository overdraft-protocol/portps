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
# or from this repo: ./install.sh --shell
```

Confirm:

```bash
command -v portps && portps 2>&1 | head -2
```

## Commands

Always quote glob patterns so the shell does not expand them:

```bash
portps 9100
portps '91*'
portps '9???'
portps -k 9100
portps -k '91*'
```

(`%` / `_` work unquoted as synonyms for `*` / `?`.)

## When not to use

- Do not kill processes unless the user asked to free/kill the port
- TCP listen only (not UDP)
- Prefer quoting patterns in agent-run commands
