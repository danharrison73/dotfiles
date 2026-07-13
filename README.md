# dotfiles

My personal configuration for a WSL2 (Ubuntu) + WezTerm setup on Windows.

## What's inside

| Config | Path | Symlinked to | Notes |
| --- | --- | --- | --- |
| **zsh** | `zsh/.zshrc` | `~/.zshrc` | Login shell. History, prompt, completion, conda, nvm, fzf. |
| **bash** | `bash/.bashrc` | `~/.bashrc` | Kept as a fallback shell. |
| **git** | `git/.gitconfig`, `git/.gitignore_global` | `~/.gitconfig`, `~/.gitignore_global` | Identity, aliases, and a global ignore list. |
| **nvim** | `nvim/init.lua`, `nvim/lazy-lock.json` | `~/.config/nvim/` | lazy.nvim plugin manager (version-pinned), harpoon + telescope, LSP (mason) + autocompletion (nvim-cmp). |
| **tmux** | `tmux/.tmux.conf` | `~/.tmux.conf` | `C-Space` prefix, vim-style panes, Tokyo Night status bar. |
| **wezterm** | `wezterm/.wezterm.lua` | Windows `~/.wezterm.lua` (stub) | Terminal emulator. Launches WSL into a tmux session. |
| **claude** | `claude/settings.json`, `claude/statusline-command.sh` | `~/.claude/` | Claude Code global settings + custom status line. |

## Configs

### zsh (`zsh/.zshrc`)
The primary interactive shell. Ported from the old `.bashrc`:
- History with dedup + shared history across shells.
- Coloured `user@host:cwd` prompt and xterm title.
- `compinit` completion (with `bashcompinit` so nvm's completion loads).
- `ls`/`grep` colour aliases plus `ll`/`la`/`l`.
- conda (via the `shell.zsh` hook), ssh-agent bootstrap, nvm, and fzf.
- [zoxide](https://github.com/ajeetdsouza/zoxide) as a smarter `cd`: `z foo` jumps to the most-used directory matching `foo`, `zi` picks one interactively through fzf. The init is guarded on the binary being present, so the shell still starts cleanly without it.
- Extra aliases can be dropped in `~/.zsh_aliases`.

### git (`git/`)
- `.gitconfig` — identity, `main` as the default branch, `vim` editor, and aliases (`st`, `co`, `br`, `ci`, `lg`, `last`, `unstage`).
- `.gitignore_global` — OS/editor junk ignored across every repo (wired up via `core.excludesfile`).

### nvim (`nvim/`)
- **lazy.nvim** self-bootstraps on first launch; `lazy-lock.json` pins plugin versions so every machine installs the same commits.
- **harpoon** — `<leader>a` add, `<leader>h` menu, `<leader>1..4` jump.
- **telescope** — `<leader>ff` files, `<leader>fg` grep, `<leader>fb` buffers, `<leader>fh` help.
- **LSP** — [mason.nvim](https://github.com/williamboman/mason.nvim) installs language servers, wired to `nvim-lspconfig` via `mason-lspconfig`. `lua_ls` is auto-installed; add more via `ensure_installed` or `:Mason`. Requires nvim 0.11+ (uses the `vim.lsp.config`/`vim.lsp.enable` API).
  - Keymaps (buffer-local, on attach): `gd` definition and `gr` references (routed through telescope for preview + fuzzy filter), `K` hover, `<leader>rn` rename, `<leader>ca` code action, `[d`/`]d` prev/next diagnostic (floats the message on jump).
- **Autocompletion** — [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) with LSP, buffer, and path sources, plus LuaSnip for snippets. `<Tab>`/`<S-Tab>` cycle items and jump snippets, `<CR>` confirms, `<C-Space>` triggers completion, `<C-f>`/`<C-b>` scroll docs.
- Leader is `<Space>`; `jk` escapes insert mode; 2-space indentation, no swapfile.
- **Hybrid line numbers** (`number` + `relativenumber`) — the cursor line shows its absolute number, every other line shows its distance. That gutter is what makes counted jumps (`7j`, `d2j`) aimable: read the number, type it.
- **`tutorial.rs`** — the practice range. A tier-ordered walkthrough for becoming a power user, drilled against real Rust code sitting in the file. Each section explains the idea, then gives `TRY IT` exercises with concrete targets ("cursor anywhere in `timeout_ms`, press `ciw`, type `deadline_ms`"). Open it, work top to bottom, wreck the code, and reset with `:e!` — that's a repeatable 10-minute daily loop.
  - Order is deliberate — grammar before plugins: motions → **text objects** → `.` → counts → insert → registers → visual/blockwise → macros → `:s`/`:g` → marks → telescope → harpoon → LSP → cmp. Tiers 1-4 are where the speed actually lives; plugins add capability but don't compound the way `ciw` does.
  - It also explains *how to think* in vim (vim is a language, not a set of shortcuts) and how the rest of these dotfiles feed the editing loop.
  - The LSP section needs `rust-analyzer` (`:Mason`, press `i` on it); `lua_ls` is the only server auto-installed.
- `motions.lua` is the companion cheat-sheet for getting around a file.

### tmux (`tmux/.tmux.conf`)
- Prefix rebound to `C-Space`; mouse on; windows/panes start at 1 and renumber.
- Split with `|` / `-`, navigate/resize panes with `h/j/k/l`, reload with `prefix r`.
- Tokyo Night status bar; true colour; 10ms escape-time to avoid WezTerm garbage.

### wezterm (`wezterm/.wezterm.lua`)
- JetBrains Mono, rose-pine-moon, acrylic-blurred transparent window.
- Bottom tab bar, blinking bar cursor, 10k scrollback.
- Boots straight into WSL + a tmux session named `main`.
- WezTerm runs on Windows and can't follow WSL symlinks, so `install.sh` writes a
  tiny Windows-side stub that live-loads this file over the `\\wsl.localhost` path
  (edits hot-reload; no re-copy needed).

### claude (`claude/`)
Global [Claude Code](https://claude.com/claude-code) config:
- `settings.json` — model, notification/stop sound hooks (Windows), enabled plugins, and the status line command.
- `statusline-command.sh` — custom status line showing model, effort, context %, cost, rate limits, and git state (needs `jq`).

## Tools I use
- [tmux](https://github.com/tmux/tmux)
- [wezterm](https://wezfurlong.org/wezterm/)
- [neovim](https://neovim.io/)
- zsh
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fzf](https://github.com/junegunn/fzf)
- [fd](https://github.com/sharkdp/fd)
- [zoxide](https://github.com/ajeetdsouza/zoxide) (smarter `cd`; install via the upstream script, not apt — apt ships a very old 0.4.x)
- [jq](https://jqlang.github.io/jq/) (used by the Claude status line)

### On the wishlist
- [starship](https://starship.rs/) prompt

## Install

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` is safe to re-run. It:
- symlinks each config into place, backing up any existing real file to `*.bak`;
- checks for the required tools and prints an install command for your package manager if any are missing;
- sets zsh as your default shell (`chsh`);
- on WSL, writes the Windows-side WezTerm stub — and skips that step everywhere else.

Then reload with `exec zsh` (or `source ~/.zshrc`).
