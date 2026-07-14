# portps

Find or kill processes listening on TCP ports. Supports exact ports and glob patterns.

```bash
portps 9100           # exact port
portps 91*            # all ports starting with 91
portps 9???           # four-character ports starting with 9
portps -k 9100        # kill listener on port 9100
portps -k 91*         # kill all listeners on matching ports
```

Works with **bash** or **zsh** (bash 3.2+ / macOS system bash is fine). On zsh, install adds a `noglob` alias so patterns like `91*` work unquoted. In bash (or without the alias), quote them: `portps '91*'`.

## Requirements

- macOS or Linux
- bash (for the script; your interactive shell can be bash or zsh)
- `lsof` and `ps`

## Install

### npm (recommended)

```bash
npm install -g @overdraft-protocol/portps
```

Global install runs a postinstall hook that adds shell integration for your current `$SHELL` (zsh `noglob` alias, or a bash tip in `~/.bashrc`). Then reload:

```bash
source ~/.zshrc   # or: source ~/.bashrc
```

### Homebrew

```bash
brew tap overdraft-protocol/portps
brew trust overdraft-protocol/portps   # required once for third-party taps
brew install portps
```

That uses the [`overdraft-protocol/homebrew-portps`](https://github.com/overdraft-protocol/homebrew-portps) tap. Publishing a GitHub Release here (tag `vX.Y.Z`) runs a workflow that updates the formula checksum and pushes it to the tap.

Local smoke test from this repo:

```bash
./scripts/brew-local-install.sh
```

Manual formula refresh (without pushing the tap):

```bash
./scripts/update-formula-sha.sh 1.1.0
```
### From source

```bash
git clone https://github.com/overdraft-protocol/portps.git
cd portps
./install.sh --shell
source ~/.zshrc   # or ~/.bashrc
```

- `--shell` — auto-detect bash/zsh and add integration  
- `--zsh` — zsh `noglob` alias only  
- `--bash` — bash quote tip only  
- `PREFIX=/usr/local ./install.sh` — custom install prefix  

### Manual

```bash
cp bin/portps ~/.local/bin/
chmod +x ~/.local/bin/portps
```

## Uninstall

```bash
npm uninstall -g @overdraft-protocol/portps
# or
./install.sh --uninstall
# or
brew uninstall portps
```

`install.sh --uninstall` removes the binary and shell integration markers from `~/.zshrc` / `~/.bashrc`.

## Pattern syntax

| Pattern | Matches |
|---------|---------|
| `9100` | port 9100 exactly |
| `91*` | ports starting with `91` |
| `9???` | port + exactly 3 more characters |
| `90[01]*` | ports starting with `900` or `901` |

**zsh:** with the install alias, `portps 91*` works unquoted.

**bash:** quote patterns (`portps '91*'`). Alternately, `%` / `_` are shell-safe synonyms for `*` / `?` (`portps 91%`).

## Claude Code / Cursor

This repo ships an agent skill so coding agents know when and how to run `portps`.

### Claude Code

Add this repo as a marketplace and install the plugin:

```text
/plugin marketplace add overdraft-protocol/portps
/plugin install portps@overdraft-portps
```

Or test locally:

```bash
claude --plugin-dir /path/to/portps
```

Skill path: `skills/portps/SKILL.md`

### Cursor

Project skill: `.cursor/skills/portps/SKILL.md` (available when this repo is open). Copy that folder into `~/.cursor/skills/portps/` for global use.

## Distribution

Checklist for maintainers:

1. **Bump version** in `package.json`, commit, push
2. **npm** — `npm publish --access=public`
3. **GitHub release** — tag `v<version>` (e.g. `gh release create v1.1.0`). The [Sync Homebrew tap](.github/workflows/sync-homebrew-tap.yml) workflow updates [`homebrew-portps`](https://github.com/overdraft-protocol/homebrew-portps) automatically
4. **One-time — write deploy key for the tap** (see setup steps below)
5. **Claude Code** — `/plugin marketplace add overdraft-protocol/portps` then `/plugin install portps@overdraft-portps`
6. **Topics** on the GitHub repo: `cli`, `bash`, `devtools`, `ports`, `lsof`

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

6. Smoke-test: Actions → Sync Homebrew tap → Run workflow with version `1.1.0` (after a matching `v1.1.0` tag/release exists).


## License

MIT
