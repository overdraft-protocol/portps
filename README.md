# portps

Find or kill processes listening on TCP ports. Supports exact ports and glob patterns.

```bash
portps 9100          # exact port
portps 91*           # all ports starting with 91
portps 9???          # four-digit ports starting with 9
portps -k 9100       # kill listener on port 9100
```

## Requirements

- macOS or Linux
- [zsh](https://www.zsh.org/) (default on modern macOS)
- `lsof` and `ps` (preinstalled on macOS)

## Install

### curl (from a git checkout or release)

```bash
git clone <your-repo-url> portps
cd portps
./install.sh --zsh
```

`--zsh` adds a `noglob` alias so patterns like `portps 91*` work without quoting.

### npm

```bash
npm install -g portps
```

Then add the zsh alias manually (or run `./install.sh --zsh`):

```zsh
alias portps='noglob command portps'
```

### Manual

```bash
cp bin/portps ~/.local/bin/
chmod +x ~/.local/bin/portps
```

## Uninstall

```bash
./install.sh --uninstall
# or
npm uninstall -g portps
```

## Pattern syntax

Uses zsh glob rules:

| Pattern | Matches |
|---------|---------|
| `9100` | port 9100 exactly |
| `91*` | ports starting with `91` |
| `9???` | port + exactly 3 more characters |
| `90[01]*` | ports starting with `900` or `901` |

Quote patterns in bash or use the zsh `noglob` alias to avoid the shell expanding `*` as filenames.

## License

MIT
