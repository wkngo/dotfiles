#!/bin/bash
set -e

OS="$(uname)"
IS_WSL=false
grep -qi microsoft /proc/version 2>/dev/null && IS_WSL=true

IS_ARCH=false
[[ "$OS" == "Linux" ]] && [[ -f /etc/arch-release ]] && IS_ARCH=true

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
    neovim \
    zsh \
    tmux

  brew install --cask ghostty

# ── Linux (Arch) ───────────────────────────────────────────────────────────────
elif [[ "$IS_ARCH" == "true" ]]; then
  sudo pacman -S --noconfirm --needed \
    base-devel \
    curl \
    git \
    unzip \
    tar \
    ripgrep \
    fd \
    go \
    clang \
    python-pipx \
    zoxide \
    fzf \
    git-delta \
    eza \
    bat \
    direnv \
    neovim \
    zsh \
    tmux

  if [ "$IS_WSL" = false ]; then
    sudo pacman -S --noconfirm --needed \
      brightnessctl \
      swaylock \
      playerctl \
      wl-clipboard

    # ghostty is in the AUR
    if ! command -v ghostty &>/dev/null; then
      if command -v paru &>/dev/null; then
        paru -S --noconfirm ghostty
      elif command -v yay &>/dev/null; then
        yay -S --noconfirm ghostty
      else
        echo "WARNING: No AUR helper found. Install ghostty manually: paru -S ghostty"
      fi
    fi
  fi

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
    git-delta \
    eza \
    bat \
    direnv \
    zsh \
    tmux

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

# Set zsh as the default shell
if [ "$SHELL" != "$(command -v zsh)" ]; then
  chsh -s "$(command -v zsh)" "$USER"
fi

# fzf: Arch and macOS install via package manager above; apt version is too old for --zsh
if ! command -v fzf &>/dev/null || ! fzf --zsh &>/dev/null 2>&1; then
  if [[ "$OS" == "Darwin" ]]; then
    brew install fzf
  elif [[ "$IS_ARCH" == "true" ]]; then
    sudo pacman -S --noconfirm --needed fzf
  else
    FZF_VERSION=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | tr -d 'v')
    curl -fLo /tmp/fzf.tar.gz "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz"
    tar -xzf /tmp/fzf.tar.gz -C ~/.local/bin
    rm /tmp/fzf.tar.gz
  fi
fi

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

# ── Bootstrap Neovim ───────────────────────────────────────────────────────────
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
nvim --headless "+TSUpdateSync" +qa 2>/dev/null || true
