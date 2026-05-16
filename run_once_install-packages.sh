#!/bin/bash
set -e

OS="$(uname)"
IS_WSL=false
grep -qi microsoft /proc/version 2>/dev/null && IS_WSL=true

# ── macOS ──────────────────────────────────────────────────────────────────────
if [[ "$OS" == "Darwin" ]]; then
  if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  brew install \
    git \
    ripgrep \
    fd \
    go \
    clang-format \
    pipx \
    zoxide \
    fzf \
    git-delta \
    eza \
    bat \
    direnv \
    neovim

  brew install --cask ghostty

# ── Linux (apt) ────────────────────────────────────────────────────────────────
elif [[ "$OS" == "Linux" ]]; then
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
    zoxide \
    fzf \
    git-delta \
    eza \
    bat \
    direnv

  if [ "$IS_WSL" = false ]; then
    sudo apt install -y \
      ghostty \
      brightnessctl \
      swaylock \
      playerctl \
      wl-clipboard
  fi

  # bat installs as batcat on Ubuntu — symlink to bat
  if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    mkdir -p ~/.local/bin
    ln -sf "$(which batcat)" ~/.local/bin/bat
  fi

  # Neovim (unstable PPA for latest stable release)
  if ! command -v nvim &>/dev/null; then
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt update
    sudo apt install -y neovim
  fi
fi

# ── Cross-platform ─────────────────────────────────────────────────────────────

# nvm + Node.js (needed for many LSPs)
if [ ! -f "$HOME/.nvm/nvm.sh" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts

# Rust
if ! command -v rustup &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

# Starship prompt
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir ~/.local/bin -y
fi

# Python CLI tools via pipx
pipx ensurepath
pipx install black
pipx install isort

# JetBrains Mono Nerd Font
if [[ "$OS" == "Darwin" ]]; then
  FONT_DIR=~/Library/Fonts
  font_installed() { ls "$FONT_DIR"/JetBrainsMono* &>/dev/null; }
else
  FONT_DIR=~/.local/share/fonts/JetBrainsMonoNerd
  font_installed() { fc-list | grep -qi "JetBrainsMono Nerd"; }
fi

if ! font_installed; then
  mkdir -p "$FONT_DIR"
  curl -fLo /tmp/JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR"
  [[ "$OS" == "Linux" ]] && fc-cache -fv
  rm /tmp/JetBrainsMono.zip
fi

# Tmux plugins
if [ ! -d "$HOME/.config/tmux/plugins/catppuccin/tmux" ]; then
  git clone https://github.com/catppuccin/tmux.git "$HOME/.config/tmux/plugins/catppuccin/tmux"
fi

# ── Linux native-only ──────────────────────────────────────────────────────────
if [[ "$OS" == "Linux" ]] && [ "$IS_WSL" = false ]; then
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

  sudo usermod -aG video "$USER"

  if ! command -v dms &>/dev/null; then
    git clone https://github.com/AvengeMedia/DankMaterialShell.git /tmp/dms-build
    (cd /tmp/dms-build && sudo make install)
    rm -rf /tmp/dms-build
  fi
fi

# ── Bootstrap Neovim ───────────────────────────────────────────────────────────
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
nvim --headless "+TSUpdateSync" +qa 2>/dev/null || true
