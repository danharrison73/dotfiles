# dotfiles

My personal configuration for a WSL2 (Ubuntu) + WezTerm setup on Windows.

## What's inside

| Config | Path | Symlinked to | Notes |
| --- | --- | --- | --- |
| **zsh** | `zsh/.zshrc`, `zsh/.zshenv` | `~/.zshrc`, `~/.zshenv` | Login shell. History, prompt, completion, conda, nvm, fzf. `.zshenv` holds what non-interactive shells need on PATH too (the rust and .NET toolchains). |
| **bash** | `bash/.bashrc` | `~/.bashrc` | Kept as a fallback shell. |
| **git** | `git/.gitconfig`, `git/.gitignore_global` | `~/.gitconfig`, `~/.gitignore_global` | Identity, aliases, and a global ignore list. |
| **nvim** | `nvim/init.lua`, `nvim/lazy-lock.json` | `~/.config/nvim/` | lazy.nvim plugin manager (version-pinned), harpoon + telescope + neo-tree, LSP (mason) + autocompletion (nvim-cmp), debugging (nvim-dap + dap-ui). |
| **tmux** | `tmux/.tmux.conf` | `~/.tmux.conf` | `C-Space` prefix, vim-style panes, Tokyo Night status bar. |
| **wezterm** | `wezterm/.wezterm.lua` | Windows `~/.wezterm.lua` (stub) | Terminal emulator. Launches WSL into a tmux session. |
| **claude** | `claude/settings.json`, `claude/CLAUDE.md`, `claude/keybindings.json`, `claude/statusline-command.sh` | `~/.claude/` | Claude Code global settings, house style, keybindings, and custom status line. |

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
- **telescope** — `<leader>ff` files, `<leader>fg` grep, `<leader>fb` buffers, `<leader>fh` help, `<leader>fe` file browser.
  - [telescope-ui-select](https://github.com/nvim-telescope/telescope-ui-select.nvim) routes `vim.ui.select()` through telescope, so *every* menu nvim raises is a fuzzy-filterable dropdown instead of a numbered `inputlist` in the command area — LSP code actions (`<leader>ca`), the Makefile target pickers (`<leader>mm`, `<leader>dM`), and anything added later, since they all go through the same hook.
- **neo-tree** — [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim), the sidebar tree. `<leader>e` toggles it and *reveals* the current file, expanding the directories above it, so it always answers "where am I". Complements telescope rather than replacing it: telescope finds a file you can name, neo-tree shows you the shape of a directory you can't. Inside it, `<Space>` expands/collapses, `<CR>` opens, `a`/`d`/`r` add/delete/rename, `C`/`z` collapse this node / everything, and `?` lists the full keymap. Gitignored files are hidden, dotfiles are not; `H` toggles both. `motions.lua` carries the complete set.
- **LSP** — [mason.nvim](https://github.com/williamboman/mason.nvim) installs language servers, wired to `nvim-lspconfig` via `mason-lspconfig`. `lua_ls` is auto-installed; add more via `ensure_installed` or `:Mason`. Requires nvim 0.11+ (uses the `vim.lsp.config`/`vim.lsp.enable` API).
  - Keymaps (buffer-local, on attach): `gd` definition and `gr` references (routed through telescope for preview + fuzzy filter), `K` hover, `<leader>rn` rename, `<leader>ca` code action, `[d`/`]d` prev/next diagnostic (floats the message on jump).
- **Autocompletion** — [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) with LSP, buffer, and path sources, plus LuaSnip for snippets. `<Tab>`/`<S-Tab>` cycle items and jump snippets, `<CR>` confirms, `<C-Space>` triggers completion, `<C-f>`/`<C-b>` scroll docs.
- **Debugging (DAP)** — [nvim-dap](https://github.com/mfussenegger/nvim-dap) speaks the same wire protocol VS Code's debugger does, against the same `debugpy` adapter, so breakpoints, stepping and inspection behave identically. What VS Code adds on top is the UI, which [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) supplies (scopes, stacks, breakpoints, watches, repl); `nvim-dap-virtual-text` prints values inline beside the code as you step. Adapters are installed by [mason-nvim-dap](https://github.com/jay-babu/mason-nvim-dap.nvim) the way mason installs servers, and the python configurations come from [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python).
  - **Running without debugging** — `<leader>mm` is the same Makefile picker without `DEBUG=1` and without attaching: the target just runs in a terminal split. That's the common case, and it avoids paying tracing overhead for a run you aren't stepping through. (`:term <cmd>` and `:!<cmd>` cover anything that isn't a make target.)
  - **Two ways in.** `<F5>` picks a configuration — in a project with a `.vscode/launch.json`, that file's configurations are in the list automatically, so VS Code's Run-and-Debug dropdown and this picker are the same list. `<leader>dM` picks a **Makefile target** instead, runs it with `DEBUG=1` in a terminal split and attaches, so the parameters live in the Makefile rather than in a second copy of the arguments. It needs the target to honour `DEBUG=1` by running behind `python -m debugpy --listen $(PORT) --wait-for-client`; the port is read out of the Makefile.
  - **Breakpoints** — `<leader>db` toggle, `<leader>dB` conditional (a python expression evaluated in the frame), `<leader>dp` logpoint (prints, never stops; `{}` interpolates), `<leader>dx` clear all.
  - **Stepping** — `<F10>`/`<F11>`/`<S-F11>` over/into/out, VS Code's own keys (`<F12>` is an unshifted step-out fallback, for terminals that don't send `<S-F11>`). `<leader>dc` continue, `<leader>dC` run to cursor, `<leader>dl` re-run the last configuration, `<leader>dm` debug the test the cursor is inside.
  - **Inspecting** — `<leader>de` evaluate the word under the cursor, or the *selection* in visual mode; `<leader>dr` a real repl in the stopped frame; `<leader>du` toggle the panes.
  - **Ending** — `<leader>dt` terminates, which for debugpy is a hard kill rather than a `Ctrl-C` (no `KeyboardInterrupt`, no `finally` blocks — interrupt the terminal split instead if the run should wind down cleanly). `<leader>dq` (or `:DebugCleanup`) also closes the panes, the repl and the `<leader>dM` split; breakpoints survive it.
  - **`launch.json` caveat** — nvim's JSON parser is stricter than VS Code's. Trailing commas, and `//` comments sharing a line with code, make the whole file unparseable and nvim-dap falls back silently to the generic configurations. Keep comments on their own line.
  - **Which python runs your code** — `$VIRTUAL_ENV`, else `$CONDA_PREFIX`, else the first `venv`/`.venv`/`env`/`.env` directory under the cwd or an attached LSP's root. `debugpy` does *not* need installing into that venv: the adapter injects its own copy onto the debuggee's `sys.path`, which is how the VS Code extension gets away with bundling one debugpy for every project.
- **Auto-reload on external edits** — a buffer changed by something else (claude in another tmux pane, a `git checkout`, a formatter) reloads on focus, buffer entry, or 250ms idle, with a notification so it never changes silently under the cursor. `autoread` alone is not enough: it only re-reads when something prompts nvim to look, and `:checktime` is that prompt. Two non-obvious parts — tmux needs `focus-events on` or `FocusGained` never fires under it at all, and `:checktime` must be `vim.schedule`d because calling it straight from an autocmd callback is silently ignored under textlock.
- Leader is `<Space>`; `jk` escapes insert mode; `M-u`/`M-d` alias `C-u`/`C-d` so the same keys half-page-scroll nvim, tmux copy mode and the Claude TUI; 2-space indentation, no swapfile.
- **Hybrid line numbers** (`number` + `relativenumber`) — the cursor line shows its absolute number, every other line shows its distance. That gutter is what makes counted jumps (`7j`, `d2j`) aimable: read the number, type it.
- **`tutorial.rs`** — the practice range. A tier-ordered walkthrough for becoming a power user, drilled against real Rust code sitting in the file. Each section explains the idea, then gives `TRY IT` exercises with concrete targets ("cursor anywhere in `timeout_ms`, press `ciw`, type `deadline_ms`"). Open it, work top to bottom, wreck the code, and reset with `:e!` — that's a repeatable 10-minute daily loop.
  - Order is deliberate — grammar before plugins: motions → **text objects** → `.` → counts → insert → registers → visual/blockwise → macros → `:s`/`:g` → marks → telescope → harpoon → LSP → cmp. Tiers 1-4 are where the speed actually lives; plugins add capability but don't compound the way `ciw` does.
  - It also explains *how to think* in vim (vim is a language, not a set of shortcuts) and how the rest of these dotfiles feed the editing loop.
  - The LSP section needs `rust-analyzer` (`:Mason`, press `i` on it); `lua_ls` is the only server auto-installed.
- `motions.lua` is the companion cheat-sheet for getting around a file.

### tmux (`tmux/.tmux.conf`)
- Prefix rebound to `C-Space`; mouse on; windows/panes start at 1 and renumber; 10,000 lines of scrollback per pane.
- `focus-events on` — off by default, and its absence is why nvim's `autoread` looks broken under tmux: `FocusGained` never arrives, so a buffer edited in another pane stays stale. See the nvim auto-reload note above.
- Split with `|` / `-`, resize with `prefix H/J/K/L`, reload with `prefix r`.
- **Pane hopping, zoom-preserving** — `M-h/j/k/l` (or `M-<arrow>`) moves between panes with no prefix at all, and `M-1`…`M-5` jumps straight to a pane by number *and zooms it*. `M-z` toggles zoom. Every move uses `select-pane -Z`, which "keeps the window zoomed if it was zoomed" — so once you're full screen you stay full screen while moving around, instead of dropping back to the split layout and having to zoom again. `prefix h/j/k/l` still works and is zoom-preserving too.
  - `bind -n` takes those keys from whatever runs inside the pane. Checked against this setup: zsh is in vi mode, where the only Alt bindings are `M-,` `M-/` `M-c` `M-~`, so none of these collide; nvim uses `<C-w>` for its own splits and is unaffected.
- **Windows for anything long-lived** — `M-H`/`M-L` move between windows, `prefix ;` is last-window. Programs drawing into the terminal's *normal* buffer (a shell) don't re-anchor their output when the pane changes size, so zooming or splitting leaves them mispositioned and you end up scrolling to find the content. Full-screen programs on the *alternate* buffer (nvim, less, htop, claude) repaint instead, but still have to re-render everything on each resize. A window is always the full terminal size, so switching windows resizes nothing — put claude and long-running jobs in their own window and the problem disappears; keep panes for short-lived shells you want side by side.
- **Scrolling without the mouse** — `M-u` drops into copy mode already scrolled up a page and `M-d` pages back down (both repeat while Alt is held; `Shift+PageUp` does the same for a docked full keyboard, but on a laptop PageUp is `Fn+Up` and not worth the stretch). Inside copy mode `C-u`/`C-d` still give half pages, and it's vim inside: `k`/`j`, `C-u`/`C-d`, `C-b`/`C-f`, `g`/`G` for the ends of the history, `/` to search with `n`/`N`, `q` to leave. `prefix [` is the long way in. Only shells have scrollback worth this, so the bindings are guarded on `#{alternate_on}`: a program on the *alternate* screen (claude, nvim, less) keeps its own history and writes nothing to tmux's, so copy mode there would show only the stale shell output from before it started — a few dozen lines that stop dead and look like a broken scroll limit. In those panes the key is forwarded to the program and scrolling is the program's own job. `mode-keys` is set to `vi` explicitly rather than left to tmux's inference from `$EDITOR`.
  - Selection inside copy mode keeps tmux's defaults, which differ from vim: `Space` starts a selection (`v` is block-select), `Enter` copies and exits.
- Tokyo Night status bar; true colour; 10ms escape-time to avoid WezTerm garbage.

### wezterm (`wezterm/.wezterm.lua`)
- JetBrains Mono, rose-pine-moon, acrylic-blurred transparent window.
- Bottom tab bar, blinking bar cursor, 10k scrollback.
- **Dictating into a terminal (Wispr Flow)** — use `Shift+Alt+X` (copy last transcript) then `Ctrl+Shift+V`. Flow's automatic insert does not work here, and neither does its one-key `Shift+Alt+Z`. Measured, rather than guessed:
  - Flow puts the transcript on the clipboard and **restores the previous contents 455ms later** (clipboard polled at 60ms: set at `18:31:58.171`, reverted at `18:31:58.626`). Anything that reads the clipboard slower than that gets stale text — which is what Claude Code does, since inside WSL it reads through WSLg's clipboard bridge.
  - Capturing the tty with `cat -v` during a dictation caught **zero bytes**, while manual typing in the same capture came through fine. So Flow's insert reaches the terminal in no form at all — no characters, no `^V`, no `Shift+Insert`. It inserts through a Windows text-control API, and a GPU-rendered terminal is not an edit control.
  - `Shift+Alt+X` sidesteps both: the clipboard is set permanently, and `Ctrl+Shift+V` is WezTerm's own paste, executed in the Windows process that owns the clipboard. Claude never sees the keystroke, so `chat:imagePaste` (bound to `ctrl+v`) can't swallow it either.
  - Do **not** rebind `Ctrl+V` to paste in WezTerm to make Flow's auto-paste work — it would swallow `<C-v>`, nvim's blockwise visual mode.
  - Claude Code's own `/voice` avoids all of this: it records inside WSL via SoX/PulseAudio, with no Windows text injection in the path.
- `use_ime = true` — **required for dictation** (Wispr Flow) and text expanders to reach the terminal. They inject text as synthesised character input, not keystrokes: measured, Flow's output arrives in Windows Terminal as plain literal characters and in WezTerm, without this, as nothing at all. WezTerm reads the keyboard through the raw-input path where posted character messages never appear; the IME path is the other way in.
- `Ctrl+V` pastes. WezTerm binds `Ctrl+Shift+V` and leaves unshifted `Ctrl+V` to pass through to the program — where Claude Code takes it as `chat:imagePaste` and hunts the clipboard for an *image*, so a text paste silently does nothing. Cost: nvim no longer sees `<C-v>`; press `<C-q>` for blockwise visual, which vim treats identically.
- **Restart WezTerm after editing this file** — don't trust hot-reload. `use_ime` only applies at window creation, and the stub's reload watch sits on a `\\wsl.localhost` path, where Windows change notifications are unreliable. Several apparent "this fix doesn't work" results were really a config that had never loaded.
- `Shift+PageUp`/`Shift+PageDown` are forwarded rather than scrolling WezTerm's own scrollback — with tmux running that buffer holds stale repainted frames, not session output, so the keys belong to tmux's copy mode.
- Boots straight into WSL + a tmux session named `main`.
- WezTerm runs on Windows and can't follow WSL symlinks, so `install.sh` writes a
  tiny Windows-side stub that live-loads this file over the `\\wsl.localhost` path
  (edits hot-reload; no re-copy needed).

### claude (`claude/`)
Global [Claude Code](https://claude.com/claude-code) config:
- `settings.json` — model, notification/stop sound hooks (Windows), enabled plugins, and the status line command.
- `CLAUDE.md` — global instructions, loaded into every session in every directory. Currently: maths notation, routed by destination — Unicode glyphs (∫, Σ, x̄) in terminal replies since LaTeX source is unreadable there, and real LaTeX (`$…$`) in `.md`/`.tex`/`.ipynb` files, which get read through a renderer.
- `keybindings.json` — laptop-friendly scrolling. `settings.json` sets `"tui": "fullscreen"`, where the conversation is a scrollable view whose only default scroll keys are `pageup`/`pagedown` — which a laptop reaches through `Fn`. These add vim keys on Alt: `M-u`/`M-d` half page, `M-b`/`M-f` full page, `M-g`/`M-G` top/bottom (the file itself spells them `alt+u`, `alt+shift+g` and so on — Claude's own syntax, not tmux's `M-` shorthand). Alt was chosen because Claude's own bindings use `alt+p/o/t/w/v` and tmux's use `M-h/j/k/l`, `M-z`, `M-1`–`M-5`, `M-H/M-L` — no overlap — and because tmux forwards `M-u`/`M-d` into alternate-screen panes rather than swallowing them.
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
