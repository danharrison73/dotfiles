# Sourced by EVERY zsh -- interactive, non-interactive, and scripts alike.
# .zshrc is only read by interactive shells, so anything that a non-interactive
# tool needs on PATH has to live here instead.
#
# Rust lands here for exactly that reason: tools that shell out non-interactively
# (Claude Code's bash tool, and the nvim LSP client that spawns rust-analyzer)
# got a .zshrc-less PATH and so couldn't see cargo or rust-analyzer at all, even
# though both were installed. The sourced script is idempotent -- it no-ops if
# ~/.cargo/bin is already on PATH -- so nested shells don't stack duplicates.
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# .NET lives in ~/.dotnet (a no-sudo SDK install), and it's put ahead of the
# system dotnet so `dotnet` resolves to the newer one there rather than the older
# apt-managed /usr/lib/dotnet. DOTNET_ROOT pairs with the PATH entry so that
# framework-dependent apphosts find the runtime, per Microsoft's manual-install
# guidance. Guarded so nested shells don't stack duplicate PATH entries.
if [ -d "$HOME/.dotnet" ]; then
  export DOTNET_ROOT="$HOME/.dotnet"
  case ":$PATH:" in
    *":$HOME/.dotnet:"*) ;;
    *) export PATH="$HOME/.dotnet:$PATH" ;;
  esac
fi
