#!/usr/bin/env bash
set -e

# Ensure ~/.config exists
mkdir -p ~/.config

# Backup existing nvim config if it exists and isn't already a symlink
if [ -d ~/.config/nvim ] && [ ! -L ~/.config/nvim ]; then
  mv ~/.config/nvim ~/.config/nvim.backup.$(date +%s)
fi

# Create symlink
ln -sfn "$PWD/.config/nvim" ~/.config/nvim
ln -sfn "$PWD/.config/zellij" ~/.config/zellij
