# dotfiles

Managed with [chezmoi](https://chezmoi.io).

## Setup

```bash
chezmoi init --apply github.com/wkngo/dotfiles
```

## Usage

```bash
chezmoi update                  # pull latest and apply
chezmoi apply                   # apply pending changes
chezmoi edit ~/.gitconfig       # edit a managed file
chezmoi add ~/.config/foo       # start managing a new file
chezmoi diff                    # preview changes before applying
```
