# dotfiles

My personal configuration for a WSL2 (Ubuntu) + WezTerm setup on Windows.

## What's inside

| Config | Path | Symlinked to | Notes |
| --- | --- | --- | --- |
| **zsh** | `zsh/.zshrc` | `~/.zshrc` | Login shell. History, prompt, completion, conda, nvm, fzf. |
| **bash** | `bash/.bashrc` | `~/.bashrc` | Kept as a fallback shell. |
| **nvim** | `nvim/init.lua` | `~/.config/nvim/init.lua` | lazy.nvim plugin manager, harpoon + telescope. |
| **tmux** | `tmux/.tmux.conf` | `~/.tmux.conf` | `C-Space` prefix, vim-style panes, Tokyo Night status bar. |
| **wezterm** | `wezterm/.wezterm.lua` | Windows `~/.wezterm.lua` (stub) | Terminal emulator. Launches WSL into a tmux session. |

## Configs

### zsh (`zsh/.zshrc`)
The primary interactive shell. Ported from the old `.bashrc`:
- History with dedup + shared history across shells.
- Coloured `user@host:cwd` prompt and xterm title.
- `compinit` completion (with `bashcompinit` so nvm's completion loads).
- `ls`/`grep` colour aliases plus `ll`/`la`/`l`.
- conda (via the `shell.zsh` hook), ssh-agent bootstrap, nvm, and fzf.
- Extra aliases can be dropped in `~/.zsh_aliases`.

### nvim (`nvim/init.lua`)
- **lazy.nvim** self-bootstraps on first launch.
- **harpoon** — `<leader>a` add, `<leader>h` menu, `<leader>1..4` jump.
- **telescope** — `<leader>ff` files, `<leader>fg` grep, `<leader>fb` buffers, `<leader>fh` help.
- Leader is `<Space>`; `jk` escapes insert mode; 2-space indentation, line numbers, no swapfile.

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

## Tools I use
- [tmux](https://github.com/tmux/tmux)
- [wezterm](https://wezfurlong.org/wezterm/)
- [neovim](https://neovim.io/)
- zsh
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fzf](https://github.com/junegunn/fzf)
- [fd](https://github.com/sharkdp/fd)

### On the wishlist
- [starship](https://starship.rs/) prompt

## Install

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` symlinks each config into place, backing up any existing file to
`*.bak` first. Then reload with `exec zsh` (or `source ~/.zshrc`).
