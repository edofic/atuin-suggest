# atuin-suggest

Fish-style autosuggestions for Zsh, powered by [Atuin](https://atuin.sh).

A lightweight alternative to [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) that uses Atuin's shell history search instead of native zsh history.

## Features

- Suggests commands as you type based on your Atuin history
- Suggestions appear as gray text after your cursor
- Accept full suggestion or word-by-word
- Minimal footprint (~200 lines of zsh)

## Requirements

- Zsh 5.0+
- [Atuin](https://atuin.sh) installed and configured

## Installation

### Manual

```zsh
git clone https://github.com/edofic/atuin-suggest.git
echo "source /path/to/atuin-suggest/atuin-suggest.zsh" >> ~/.zshrc
```

### Oh My Zsh

```zsh
git clone https://github.com/edofic/atuin-suggest.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/atuin-suggest
```

Add `atuin-suggest` to your plugins array in `~/.zshrc`:

```zsh
plugins=(... atuin-suggest)
```

### Zinit

```zsh
zinit light edofic/atuin-suggest
```

### Antigen

```zsh
antigen bundle edofic/atuin-suggest
```

## Keybindings

| Key | Action |
|-----|--------|
| `→` (Right Arrow) | Accept next word |
| `End` | Accept full suggestion |
| `Ctrl+E` | Accept full suggestion |

## Configuration

```zsh
# Suggestion highlight style (default: gray)
ATUIN_SUGGEST_HIGHLIGHT_STYLE="fg=8"

# Atuin search mode: prefix, fuzzy, or full-text (default: prefix)
ATUIN_SUGGEST_SEARCH_MODE="prefix"
```

Set these variables before sourcing the plugin.

## How It Works

The plugin hooks into Zsh's line editor (ZLE) and queries Atuin on every keystroke:

```
atuin search --cmd-only --limit 1 --search-mode prefix "<your input>"
```

Suggestions are displayed using Zsh's `POSTDISPLAY` variable and styled via `region_highlight`.

## Why Atuin?

- **Sync across machines**: Your history follows you everywhere
- **Better search**: Atuin's search is fast and supports multiple modes
- **Context-aware**: Filter by directory, exit code, time, and more
- **Encryption**: Your history is encrypted end-to-end

## Comparison with zsh-autosuggestions

| Feature | atuin-suggest | zsh-autosuggestions |
|---------|---------------|---------------------|
| History source | Atuin | Native zsh history |
| Cross-machine sync | Yes (via Atuin) | No |
| Lines of code | ~200 | ~700 |
| Async support | No | Yes |
| Completion strategy | No | Yes |

## License

MIT
