# dotfiles

Managed with [chezmoi](https://chezmoi.io).

## Setup

```bash
chezmoi init --apply github.com/wkngo/dotfiles
```

## Usage

```bash
chezmoi update           # pull latest and apply
chezmoi edit ~/.gitconfig  # edit a file and apply
chezmoi apply            # apply pending changes
```

## What's included

| Config | Platforms |
|--------|-----------|
| nvim | all |
| tmux | all |
| gitconfig | all |
| GlazeWM | Windows only |
