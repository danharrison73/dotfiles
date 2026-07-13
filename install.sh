#!/usr/bin/env bash
#
# Portable installer for these dotfiles.
#   - symlinks each config into place (backing up any existing real file to *.bak)
#   - checks for the tools the configs rely on
#   - sets zsh as the default shell
#   - on WSL, writes the Windows-side WezTerm stub
#
# Safe to re-run; it just refreshes the symlinks.

set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

symlink() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    echo "  updating symlink: $dest"
  elif [ -e "$dest" ]; then
    echo "  backing up existing file: $dest -> $dest.bak"
    mv "$dest" "$dest.bak"
  else
    echo "  linking: $dest"
  fi
  ln -sf "$src" "$dest"
}

# --- detect platform --------------------------------------------------------
IS_WSL=0
grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null && IS_WSL=1

info "Installing dotfiles from $DOTFILES_DIR"

# --- symlinks ---------------------------------------------------------------
symlink "$DOTFILES_DIR/bash/.bashrc"              "$HOME/.bashrc"
symlink "$DOTFILES_DIR/zsh/.zshrc"                "$HOME/.zshrc"
symlink "$DOTFILES_DIR/git/.gitconfig"            "$HOME/.gitconfig"
symlink "$DOTFILES_DIR/git/.gitignore_global"     "$HOME/.gitignore_global"
symlink "$DOTFILES_DIR/nvim/init.lua"             "$HOME/.config/nvim/init.lua"
symlink "$DOTFILES_DIR/nvim/lazy-lock.json"       "$HOME/.config/nvim/lazy-lock.json"
symlink "$DOTFILES_DIR/tmux/.tmux.conf"           "$HOME/.tmux.conf"
symlink "$DOTFILES_DIR/claude/settings.json"      "$HOME/.claude/settings.json"
symlink "$DOTFILES_DIR/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"

# --- dependency check -------------------------------------------------------
info "Checking for tools the configs rely on"
missing=()
have git    || missing+=(git)
have zsh    || missing+=(zsh)
have tmux   || missing+=(tmux)
have nvim   || missing+=(neovim)
have fzf    || missing+=(fzf)
have rg     || missing+=(ripgrep)
have jq     || missing+=(jq)
{ have fd || have fdfind; } || missing+=(fd)

if [ ${#missing[@]} -eq 0 ]; then
  echo "  all present"
else
  warn "missing: ${missing[*]}"
  if   have apt;    then echo "  install with: sudo apt install ${missing[*]}   (note: on apt, 'fd' is 'fd-find')"
  elif have brew;   then echo "  install with: brew install ${missing[*]}"
  elif have pacman; then echo "  install with: sudo pacman -S ${missing[*]}"
  elif have dnf;    then echo "  install with: sudo dnf install ${missing[*]}"
  else                   echo "  install these with your package manager"
  fi
fi

# zoxide is checked separately: apt ships a years-old 0.4.x, so prefer the
# upstream installer, which drops a current build in ~/.local/bin.
if ! have zoxide; then
  warn "missing: zoxide"
  if have brew; then
    echo "  install with: brew install zoxide"
  else
    echo "  install with: curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh"
    echo "  (needs ~/.local/bin on your PATH)"
  fi
fi

# --- rust-analyzer ----------------------------------------------------------
# nvim/init.lua enables rust_analyzer with lspconfig's default cmd, i.e. a bare
# `rust-analyzer` looked up on PATH -- deliberately NOT a mason-installed copy,
# so the analyser and the rustc it analyses are always the same version.
#
# That makes it a rustup *component*, not a package: ~/.cargo/bin/rust-analyzer
# already exists as a rustup proxy on any box with rustup, but until the
# component is added the proxy just errors with "Unknown binary". Adding it is
# idempotent, needs no sudo, and is a no-op once present -- so do it rather than
# print advice. (~/.cargo/bin reaches PATH via the cargo env line in .zshrc.)
if have rustup; then
  if rustup component list --installed 2>/dev/null | grep -q '^rust-analyzer'; then
    echo "  rust-analyzer: present"
  else
    info "Adding the rust-analyzer component (nvim's rust LSP)"
    if rustup component add rust-analyzer; then
      echo "  done"
    else
      warn "rustup component add rust-analyzer failed; rust files will have no LSP"
    fi
  fi
else
  warn "missing: rustup (no rust toolchain — rust files will have no LSP)"
  echo "  install with: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
  echo "  then re-run this script to add the rust-analyzer component"
fi

# --- default shell ----------------------------------------------------------
if have zsh; then
  login_shell="$(getent passwd "$USER" 2>/dev/null | cut -d: -f7)"
  [ -n "$login_shell" ] || login_shell="${SHELL:-}"
  if [ "$(basename "$login_shell")" != "zsh" ]; then
    info "Setting zsh as your default shell (may ask for your password)"
    if chsh -s "$(command -v zsh)"; then
      echo "  done — takes effect on next login"
    else
      warn "chsh failed; set it manually: chsh -s $(command -v zsh)"
    fi
  fi
fi

# --- WezTerm (WSL / Windows only) -------------------------------------------
# WezTerm runs on the Windows side and can't follow WSL symlinks, so we drop a
# tiny stub in the Windows home that live-loads the real config over the
# \\wsl.localhost UNC path (edits hot-reload; no re-copy needed).
if [ "$IS_WSL" -eq 1 ]; then
  win_user="$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')"
  WINDOWS_HOME="/mnt/c/Users/$win_user"
  if [ -n "$win_user" ] && [ -d "$WINDOWS_HOME" ]; then
    WSL_CONFIG="\\\\wsl.localhost\\${WSL_DISTRO_NAME}\\home\\${USER}\\dotfiles\\wezterm\\.wezterm.lua"
    info "Writing WezTerm stub to $WINDOWS_HOME/.wezterm.lua"
    cat > "$WINDOWS_HOME/.wezterm.lua" <<EOF
-- Auto-generated by dotfiles/install.sh — do NOT edit here.
-- Loads the real config live from the WSL dotfiles repo and watches it for changes,
-- so edits in ~/dotfiles/wezterm/.wezterm.lua hot-reload automatically.
local wezterm = require 'wezterm'
local wsl_config = [[${WSL_CONFIG}]]
wezterm.add_to_config_reload_watch_list(wsl_config)
return dofile(wsl_config)
EOF
  else
    warn "couldn't locate the Windows home; skipping the WezTerm stub"
  fi
else
  info "Not on WSL — skipping the Windows WezTerm stub"
  echo "  if you use WezTerm here, symlink wezterm/.wezterm.lua to your OS's config path"
fi

echo
info "Done. Start zsh now with: exec zsh"
