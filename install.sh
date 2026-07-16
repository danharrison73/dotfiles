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
symlink "$DOTFILES_DIR/zsh/.zshenv"               "$HOME/.zshenv"
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
# print advice. (~/.cargo/bin reaches PATH via the cargo env line in .zshenv, so
# that the non-interactive shell nvim spawns the LSP from can see it too.)
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

# --- roslyn (C# LSP) --------------------------------------------------------
# nvim/init.lua enables lspconfig's roslyn_ls but points cmd at a launcher we
# drop here, because getting this server running takes two things the box lacks:
#
#   1. The server binary. Microsoft doesn't ship it with the SDK, mason has no
#      package, and the community dotnet-tool repackage is broken -- so pull it
#      straight from Microsoft's vs-impl NuGet feed (the source VS Code and mason
#      use), into ~/.local/share/roslyn-ls/.
#   2. A new-enough runtime. A modern (stdio-speaking) server needs >= .NET 9,
#      but the system may only have an older one -- and it usually lives in a
#      root-owned dir we shouldn't touch. So if neither the system nor a previous
#      run provides >= .NET 9, drop a private SDK in ~/.dotnet (no sudo), and
#      write a `run` launcher that scopes it (DOTNET_ROOT) to this server alone.
#
# The feed's builds are framework-dependent, so fetch the newest one whose target
# the chosen runtime can actually run: walk versions newest-first, take the first
# whose required .NET major is <= the runtime's. Idempotent: skips once the
# launcher yields a server that runs. Remove ~/.local/share/roslyn-ls to refetch.
ROSLYN_DIR="$HOME/.local/share/roslyn-ls"
ROSLYN_BIN="$ROSLYN_DIR/Microsoft.CodeAnalysis.LanguageServer"
ROSLYN_RUN="$ROSLYN_DIR/run"
DOTNET_PRIV="$HOME/.dotnet"
dotnet_major() { "$1" --list-runtimes 2>/dev/null | awk '/Microsoft.NETCore.App/ {split($2,a,"."); if(a[1]+0>m)m=a[1]+0} END{print m+0}'; }
if ! have dotnet; then
  warn "missing: dotnet (no .NET SDK — C# files will have no LSP)"
  echo "  install the .NET SDK from https://dotnet.microsoft.com/download, then re-run this script"
elif "$ROSLYN_RUN" --version >/dev/null 2>&1; then
  echo "  roslyn_ls: present ($("$ROSLYN_RUN" --version 2>/dev/null | cut -d+ -f1))"
elif ! { have curl && have jq && have unzip; }; then
  warn "roslyn_ls: need curl, jq and unzip to fetch the server; install those and re-run"
else
  # pick the runtime the server will run under: system if it's already >= 9,
  # else a private ~/.dotnet SDK (installed here if it isn't there yet).
  sys_major="$(dotnet_major dotnet)"
  priv_major=0; [ -x "$DOTNET_PRIV/dotnet" ] && priv_major="$(dotnet_major "$DOTNET_PRIV/dotnet")"
  if [ "${sys_major:-0}" -ge 9 ]; then
    run_root=""; run_major="$sys_major"          # system runtime is new enough
  else
    if [ "${priv_major:-0}" -lt 9 ]; then
      info "Installing a private .NET SDK to ~/.dotnet (system .NET $sys_major is too old for a modern C# server)"
      # LTS currently resolves to .NET 10, which lets us run the newest server.
      curl -sSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel LTS --install-dir "$DOTNET_PRIV" >/dev/null \
        && priv_major="$(dotnet_major "$DOTNET_PRIV/dotnet")"
    fi
    run_root="$DOTNET_PRIV"; run_major="$priv_major"
  fi
  if [ "${run_major:-0}" -lt 9 ]; then
    warn "roslyn_ls: no .NET >= 9 available and the private SDK install failed; C# files will have no LSP"
  else
    info "Fetching the Roslyn C# language server (runs on .NET $run_major${run_root:+, private})"
    # rid for this OS/arch, e.g. linux-x64, osx-arm64
    case "$(uname -s)" in Darwin) r_os=osx ;; *) r_os=linux ;; esac
    case "$(uname -m)" in x86_64|amd64) r_arch=x64 ;; aarch64|arm64) r_arch=arm64 ;; *) r_arch=x64 ;; esac
    pkg="microsoft.codeanalysis.languageserver.${r_os}-${r_arch}"
    # resolve the feed's flat-container base URL from its service index
    flat="$(curl -s 'https://pkgs.dev.azure.com/azure-public/vside/_packaging/vs-impl/nuget/v3/index.json' \
      | jq -r '.resources[] | select(."@type"=="PackageBaseAddress/3.0.0") | ."@id"' | sed 's:/*$::')"
    tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' RETURN 2>/dev/null || true
    picked=""; picked_major=""
    if [ -n "$flat" ]; then
      # One candidate per base version -- its newest build -- base versions newest
      # first. Version strings are BASE-FEATURE.BUILD.REV, e.g. 4.14.0-1.25076.11;
      # the BUILD field is date-encoded (25076 = 2025, day 076), so it orders
      # builds within a base. Emit "BUILD<tab>BASE<tab>FULL", sort by BASE (version
      # order, desc) then BUILD (numeric, desc), keep the first row of each BASE.
      versions="$(curl -s "$flat/$pkg/index.json" \
        | jq -r '.versions[]' \
        | awk -F- '{ n=split($2,a,"."); print a[2]"\t"$1"\t"$0 }' \
        | sort -k2,2Vr -k1,1nr \
        | awk -F'\t' '!seen[$2]++ {print $3}')"
      # Take the first (newest) whose target framework the runtime can run. That
      # target lives in the tiny .nuspec (e.g. net9.0), so probe that rather than
      # the ~50MB nupkg -- one small request per candidate. A single base can
      # carry both net8 and net9 builds, so this is a per-build check.
      while IFS= read -r v; do
        [ -n "$v" ] || continue
        fw_major="$(curl -s "$flat/$pkg/$v/$pkg.nuspec" | grep -oE 'targetFramework="net[0-9]+' | head -1 | grep -oE '[0-9]+$')"
        [ -n "$fw_major" ] || continue
        if [ "$fw_major" -le "$run_major" ] 2>/dev/null; then picked="$v"; picked_major="$fw_major"; break; fi
      done <<< "$versions"
    fi
    if [ -n "$picked" ] && curl -sL "$flat/$pkg/$picked/$pkg.$picked.nupkg" -o "$tmp/c.nupkg"; then
      rm -rf "$tmp/x" "$ROSLYN_DIR"; mkdir -p "$tmp/x" "$ROSLYN_DIR"
      unzip -q "$tmp/c.nupkg" -d "$tmp/x"
      cp -r "$tmp/x/content/LanguageServer/${r_os}-${r_arch}/." "$ROSLYN_DIR/"
      chmod +x "$ROSLYN_BIN"
      # launcher: nvim's cmd. Scopes the chosen runtime to the server (if private)
      # so the system dotnet is untouched, then execs it with nvim's args.
      {
        echo '#!/usr/bin/env bash'
        echo '# Auto-generated by dotfiles/install.sh -- launches the Roslyn C# server.'
        if [ -n "$run_root" ]; then
          echo "export DOTNET_ROOT=\"$run_root\""
          echo "case \":\$PATH:\" in *\":$run_root:\"*) ;; *) export PATH=\"$run_root:\$PATH\" ;; esac"
        fi
        echo "exec \"$ROSLYN_BIN\" \"\$@\""
      } > "$ROSLYN_RUN"
      chmod +x "$ROSLYN_RUN"
      if "$ROSLYN_RUN" --version >/dev/null 2>&1; then
        echo "  installed roslyn_ls $picked (targets .NET $picked_major, on runtime major $run_major)"
      else
        warn "roslyn_ls installed but won't launch; C# files will have no LSP"
      fi
    elif [ -n "$picked" ]; then
      warn "roslyn_ls: download of $picked failed; C# files will have no LSP"
    else
      warn "roslyn_ls: found no server build targeting .NET <= $run_major; C# files will have no LSP"
    fi
  fi
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
