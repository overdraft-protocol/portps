# portps

Find or kill processes listening on TCP ports. Supports exact ports and glob patterns.

```bash
portps 9100          # exact port
portps 91*           # all ports starting with 91
portps 9???          # four-digit ports starting with 9
portps -k 9100       # kill listener on port 9100
portps -k 91*        # kill all listeners on ports starting with 91
```

## Requirements

- macOS or Linux
- [zsh](https://www.zsh.org/) (default on modern macOS)
- `lsof` and `ps` (preinstalled on macOS)

## Install

### npm (recommended)

```bash
npm install -g @overdraft-protocol/portps
source ~/.zshrc
```

Global install runs a postinstall hook that adds a `noglob` alias to `~/.zshrc` so patterns like `portps 91*` work without quoting. Reload your shell with `source ~/.zshrc` (or open a new terminal) after install.

### From source

```bash
git clone https://github.com/overdraft-protocol/portps.git
cd portps
./install.sh --zsh
source ~/.zshrc
```

`--zsh` installs `portps` to `~/.local/bin` and adds the same `noglob` alias to `~/.zshrc`.

Other options:

```bash
./install.sh              # install binary only (no zsh alias)
PREFIX=/usr/local ./install.sh --zsh
```

### Manual

```bash
cp bin/portps ~/.local/bin/
chmod +x ~/.local/bin/portps
```

For glob patterns, add this to `~/.zshrc` and run `source ~/.zshrc`:

```zsh
alias portps='noglob command portps'
```

## Uninstall

```bash
npm uninstall -g @overdraft-protocol/portps
# or, if installed from source:
./install.sh --uninstall
```

`install.sh --uninstall` removes the binary from `~/.local/bin` and the zsh alias from `~/.zshrc`. After `npm uninstall`, remove the `# portps shell integration` block from `~/.zshrc` manually if you no longer need it.

## Pattern syntax

Uses zsh glob rules:

| Pattern | Matches |
|---------|---------|
| `9100` | port 9100 exactly |
| `91*` | ports starting with `91` |
| `9???` | port + exactly 3 more characters |
| `90[01]*` | ports starting with `900` or `901` |

With the `noglob` alias (added automatically by npm global install or `install.sh --zsh`), unquoted patterns work as shown above. Without it, quote patterns (`portps '91*'`) or escape glob characters (`portps 91\*`).

## License

MIT
