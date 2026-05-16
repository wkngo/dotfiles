#!/bin/bash
set -e

# System packages
sudo apt install -y \
  build-essential \
  curl \
  git \
  unzip \
  tar \
  ripgrep \
  fd-find \
  golang-go \
  clang \
  clang-format \
  pipx \
  ghostty \
  zoxide \
  fzf

# Neovim (unstable PPA for latest stable release)
if ! command -v nvim &>/dev/null; then
  sudo add-apt-repository -y ppa:neovim-ppa/unstable
  sudo apt update
  sudo apt install -y neovim
fi

# nvm + Node.js (needed for many LSPs: pyright, vtsls, cssls, html, tailwindcss, prettierd)
if [ ! -f "$HOME/.nvm/nvm.sh" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts

# Rust (needed for rust_analyzer and building some tools)
if ! command -v rustup &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

# Starship prompt
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir ~/.local/bin -y
fi

# Python CLI tools via pipx (black, isort for conform.nvim)
pipx ensurepath
pipx install black
pipx install isort

# Niri (scrollable-tiling Wayland compositor) — not in apt, build from source
if ! command -v niri &>/dev/null; then
  sudo apt install -y \
    gcc libudev-dev libgbm-dev libxkbcommon-dev libegl1-mesa-dev \
    libwayland-dev libinput-dev libdbus-1-dev libsystemd-dev libseat-dev \
    libpipewire-0.3-dev libpango1.0-dev libdisplay-info-dev
  source "$HOME/.cargo/env"
  git clone https://github.com/niri-wm/niri /tmp/niri-build
  (cd /tmp/niri-build && cargo build --release)
  sudo install -m755 /tmp/niri-build/target/release/niri /usr/local/bin/niri
  rm -rf /tmp/niri-build
fi

# DankMaterialShell
if ! command -v dms &>/dev/null; then
  git clone https://github.com/AvengeMedia/DankMaterialShell.git /tmp/dms-build
  (cd /tmp/dms-build && sudo make install)
  rm -rf /tmp/dms-build
fi

# JetBrains Mono Nerd Font
if ! fc-list | grep -qi "JetBrainsMono Nerd"; then
  mkdir -p ~/.local/share/fonts
  curl -fLo /tmp/JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMonoNerd
  fc-cache -fv
  rm /tmp/JetBrainsMono.zip
fi

# Tmux plugins
if [ ! -d "$HOME/.config/tmux/plugins/catppuccin/tmux" ]; then
  git clone https://github.com/catppuccin/tmux.git "$HOME/.config/tmux/plugins/catppuccin/tmux"
fi

# Bootstrap Neovim plugins headlessly:
# 1. Install all lazy.nvim plugins (this also triggers mason-tool-installer on VimEnter)
# 2. Install treesitter parsers
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
nvim --headless "+TSUpdateSync" +qa 2>/dev/null || true
