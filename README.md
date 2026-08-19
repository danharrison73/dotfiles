# dotfiles

My personal configuration for a WSL2 (Ubuntu) + WezTerm setup on Windows.

## What's inside

| Config | Path | Symlinked to | Notes |
| --- | --- | --- | --- |
| **zsh** | `zsh/.zshrc`, `zsh/.zshenv` | `~/.zshrc`, `~/.zshenv` | Login shell. History, prompt, completion, conda, nvm, fzf. `.zshenv` holds what non-interactive shells need on PATH too (the rust and .NET toolchains). |
| **bash** | `bash/.bashrc` | `~/.bashrc` | Kept as a fallback shell. |
| **git** | `git/.gitconfig`, `git/.gitignore_global` | `~/.gitconfig`, `~/.gitignore_global` | Identity, aliases, and a global ignore list. |
| **nvim** | `nvim/init.lua`, `nvim/lazy-lock.json` | `~/.config/nvim/` | lazy.nvim plugin manager (version-pinned), harpoon + telescope, LSP (mason) + autocompletion (nvim-cmp), debugging (nvim-dap + dap-ui). |
| **tmux** | `tmux/.tmux.conf` | `~/.tmux.conf` | `C-Space` prefix, vim-style panes, Tokyo Night status bar. |
| **wezterm** | `wezterm/.wezterm.lua` | Windows `~/.wezterm.lua` (stub) | Terminal emulator. Launches WSL into a tmux session. |
| **claude** | `claude/settings.json`, `claude/CLAUDE.md`, `claude/statusline-command.sh` | `~/.claude/` | Claude Code global settings, house style, and custom status line. |

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
- **Debugging (DAP)** — [nvim-dap](https://github.com/mfussenegger/nvim-dap) speaks the same wire protocol VS Code's debugger does, against the same `debugpy` adapter, so breakpoints, stepping and inspection behave identically. What VS Code adds on top is the UI, which [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) supplies (scopes, stacks, breakpoints, watches, repl); `nvim-dap-virtual-text` prints values inline beside the code as you step. Adapters are installed by [mason-nvim-dap](https://github.com/jay-babu/mason-nvim-dap.nvim) the way mason installs servers, and the python configurations come from [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python).
  - **Running without debugging** — `<leader>mm` is the same Makefile picker without `DEBUG=1` and without attaching: the target just runs in a terminal split. That's the common case, and it avoids paying tracing overhead for a run you aren't stepping through. (`:term <cmd>` and `:!<cmd>` cover anything that isn't a make target.)
  - **Two ways in.** `<F5>` picks a configuration — in a project with a `.vscode/launch.json`, that file's configurations are in the list automatically, so VS Code's Run-and-Debug dropdown and this picker are the same list. `<leader>dM` picks a **Makefile target** instead, runs it with `DEBUG=1` in a terminal split and attaches, so the parameters live in the Makefile rather than in a second copy of the arguments. It needs the target to honour `DEBUG=1` by running behind `python -m debugpy --listen $(PORT) --wait-for-client`; the port is read out of the Makefile.
  - **Breakpoints** — `<leader>db` toggle, `<leader>dB` conditional (a python expression evaluated in the frame), `<leader>dp` logpoint (prints, never stops; `{}` interpolates), `<leader>dx` clear all.
  - **Stepping** — `<F10>`/`<F11>`/`<S-F11>` over/into/out, VS Code's own keys. `<leader>dc` continue, `<leader>dC` run to cursor, `<leader>dl` re-run the last configuration, `<leader>dm` debug the test the cursor is inside.
  - **Inspecting** — `<leader>de` evaluate the word under the cursor, or the *selection* in visual mode; `<leader>dr` a real repl in the stopped frame; `<leader>du` toggle the panes.
  - **Ending** — `<leader>dt` terminates, which for debugpy is a hard kill rather than a `Ctrl-C` (no `KeyboardInterrupt`, no `finally` blocks — interrupt the terminal split instead if the run should wind down cleanly). `<leader>dq` (or `:DebugCleanup`) also closes the panes, the repl and the `<leader>dM` split; breakpoints survive it.
  - **`launch.json` caveat** — nvim's JSON parser is stricter than VS Code's. Trailing commas, and `//` comments sharing a line with code, make the whole file unparseable and nvim-dap falls back silently to the generic configurations. Keep comments on their own line.
  - **Which python runs your code** — `$VIRTUAL_ENV`, else `$CONDA_PREFIX`, else the first `venv`/`.venv`/`env`/`.env` directory under the cwd or an attached LSP's root. `debugpy` does *not* need installing into that venv: the adapter injects its own copy onto the debuggee's `sys.path`, which is how the VS Code extension gets away with bundling one debugpy for every project.
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
- `CLAUDE.md` — global instructions, loaded into every session in every directory. Currently: maths notation, routed by destination — Unicode glyphs (∫, Σ, x̄) in terminal replies since LaTeX source is unreadable there, and real LaTeX (`$…$`) in `.md`/`.tex`/`.ipynb` files, which get read through a renderer.
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
