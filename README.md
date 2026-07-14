# portps

Find or kill processes listening on TCP ports. Supports exact ports and glob patterns.

```bash
portps 9100           # exact port
portps 91%            # ports starting with 91  (shell-safe)
portps 9___           # four-character ports starting with 9
portps -k 9100        # kill listener on port 9100
portps -k 91%         # kill all matching listeners
```

Works with **bash** or **zsh** (bash 3.2+ / macOS system bash is fine). Prefer **shell-safe** patterns (`%` = any run of characters, `_` = one character) so nothing in your shell expands them. Classic `*` / `?` / `[…]` still work if quoted, or after `portps --setup-shell` on zsh.

## Requirements

- macOS or Linux
- bash (for the script; your interactive shell can be bash or zsh)
- `lsof` and `ps`

## Install

### npm (recommended)

```bash
npm install -g @overdraft-protocol/portps
```

Optional (only if you want unquoted classic `*` globs on zsh):

```bash
portps --setup-shell
source ~/.zshrc   # or ~/.bashrc
```

### Homebrew

```bash
brew tap overdraft-protocol/portps
brew trust overdraft-protocol/portps   # required once for third-party taps
brew install portps
```

Optional after install: `portps --setup-shell`.

That uses the [`overdraft-protocol/homebrew-portps`](https://github.com/overdraft-protocol/homebrew-portps) tap. Publishing a GitHub Release here (tag `vX.Y.Z`) runs a workflow that updates the formula checksum and pushes it to the tap.

Local smoke test from this repo:

```bash
./scripts/brew-local-install.sh
```

Manual formula refresh (without pushing the tap):

```bash
./scripts/update-formula-sha.sh 1.1.1
```

### From source

```bash
git clone https://github.com/overdraft-protocol/portps.git
cd portps
./install.sh                 # binary only; tip printed for patterns
./install.sh --shell         # also runs portps --setup-shell
```

- `--shell` — `portps --setup-shell`
- `--zsh` / `--bash` — setup for that shell only
- `PREFIX=/usr/local ./install.sh` — custom install prefix

### Manual

```bash
cp bin/portps ~/.local/bin/
chmod +x ~/.local/bin/portps
# optional: portps --setup-shell
```

## Uninstall

```bash
npm uninstall -g @overdraft-protocol/portps
# or
./install.sh --uninstall
# or
brew uninstall portps
```

`portps --remove-shell` (also used by `install.sh --uninstall`) removes shell integration markers from `~/.zshrc` / `~/.bashrc`.

## Pattern syntax

### Shell-safe (recommended)

These do **not** need quoting and are not expanded by bash/zsh:

| Pattern | Matches |
|---------|---------|
| `9100` | port 9100 exactly |
| `91%` | ports starting with `91` |
| `9___` | port + exactly 3 more characters |
| `90%` | ports starting with `90` |

`%` → any sequence (like `*`), `_` → one character (like `?`).

### Classic globs

| Pattern | Matches |
|---------|---------|
| `91*` | same as `91%` |
| `9???` | same as `9___` |
| `90[01]*` | ports starting with `900` or `901` |

Quote classic globs (`portps '91*'`), or on zsh run `portps --setup-shell` so unquoted `*` works via a `noglob` alias.

## Claude Code / Cursor

This repo ships an agent skill so coding agents know when and how to run `portps`.

### Claude Code

```text
/plugin marketplace add overdraft-protocol/portps
/plugin install portps@overdraft-portps
```

Or test locally: `claude --plugin-dir /path/to/portps`

Skill path: `skills/portps/SKILL.md`

### Cursor

Project skill: `.cursor/skills/portps/SKILL.md`. Copy into `~/.cursor/skills/portps/` for global use.

## Distribution

Checklist for maintainers:

1. **One-shot release** (npm publish + tag + `gh release create`; Homebrew sync follows):

   ```bash
   # current package.json version already committed:
   npm run release

   # or bump then release:
   npm run release:patch    # or release:minor / release:major
   ./scripts/release.sh 1.2.0
   ./scripts/release.sh --dry-run patch   # preview
   ```

2. **One-time — write deploy key for the tap** (see setup steps below)
3. **Claude Code** — `/plugin marketplace add overdraft-protocol/portps` then `/plugin install portps@overdraft-portps`
4. **Topics** on the GitHub repo: `cli`, `bash`, `devtools`, `ports`, `lsof`

### Homebrew tap deploy key (one-time)

1. Create the public repo [`overdraft-protocol/homebrew-portps`](https://github.com/overdraft-protocol/homebrew-portps) if it does not exist yet.
2. Generate a dedicated key pair (do not reuse your personal SSH key):

   ```bash
   ssh-keygen -t ed25519 -C "portps-homebrew-tap-deploy" -f ./portps-tap-deploy -N ""
   ```

3. On **homebrew-portps** → Settings → Deploy keys → Add deploy key:
   - Title: `portps release sync`
   - Key: contents of `portps-tap-deploy.pub`
   - Enable **Allow write access**

4. On **portps** → Settings → Secrets and variables → Actions → New repository secret:
   - Name: `HOMEBREW_TAP_SSH_KEY`
   - Value: contents of `portps-tap-deploy` (the **private** key, including `BEGIN`/`END` lines)

5. Delete the local key files after storing them:

   ```bash
   rm -f ./portps-tap-deploy ./portps-tap-deploy.pub
   ```

6. Smoke-test: Actions → Sync Homebrew tap → Run workflow with version `1.1.1` (after a matching `v1.1.1` tag/release exists).

## License

MIT
