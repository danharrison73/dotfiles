#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR..."

symlink() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    echo "  updating symlink: $dest"
    ln -sf "$src" "$dest"
  elif [ -f "$dest" ]; then
    echo "  backing up existing file: $dest -> $dest.bak"
    mv "$dest" "$dest.bak"
    ln -sf "$src" "$dest"
  else
    echo "  linking: $dest"
    ln -sf "$src" "$dest"
  fi
}

# Bash
symlink "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"

# Neovim
symlink "$DOTFILES_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua"

# Tmux
symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# WezTerm (Windows path via WSL)
WEZTERM_SRC="$DOTFILES_DIR/wezterm/.wezterm.lua"
WINDOWS_HOME="/mnt/c/Users/$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')"

cp "$WEZTERM_SRC" "$WINDOWS_HOME/.wezterm.lua"

echo ""
echo "Done. Reload your shell with: source ~/.bashrc"
