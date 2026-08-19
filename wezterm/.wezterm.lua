local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Window
config.window_decorations = "TITLE|RESIZE"
config.win32_system_backdrop = 'Acrylic'  -- blurs whatever is behind the window (Windows)
config.window_background_opacity = 0.7     -- keep < ~0.85 or the tint hides the acrylic blur
-- config.window_padding = { left = 12, right = 12, top = 12, bottom = 12 }

-- Tab bar
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

-- Startup: open WSL and attach to (or create) a tmux session named "main"
config.default_prog = { 'wsl.exe', '--', 'bash', '-lic', 'tmux new-session -A -s main' }

-- Font
config.font = wezterm.font('JetBrains Mono', { weight = 'Regular' })
config.font_size = 11.0
config.line_height = 1.2

-- Colour scheme
config.color_scheme = 'rose-pine-moon'

-- Cursor
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500

-- IME on. Not for input methods as such -- it changes which Windows text path
-- WezTerm accepts. Dictation tools and text expanders (Wispr Flow) inject text
-- as synthesised character input rather than keystrokes; measured, Flow's output
-- arrives in Windows Terminal as plain literal characters and in WezTerm as
-- nothing at all. WezTerm reads the keyboard through the raw-input path, where
-- posted WM_CHAR messages never appear; the IME path is the other way in.
-- This is the setting that fixed it. Note it takes effect at window creation:
-- WezTerm hot-reloads most config, but not this, and the reload watch on the
-- \\wsl.localhost path is unreliable anyway (Windows change notifications do not
-- travel over that redirector) -- so RESTART WezTerm after editing this file,
-- rather than trusting a reload that may never have happened.
config.use_ime = true

-- Scrollback
config.scrollback_lines = 10000

-- Shift+PageUp/PageDown are WezTerm defaults for scrolling ITS scrollback, which
-- is the wrong buffer: tmux repaints the whole screen every frame, so WezTerm's
-- history is a stack of stale frames, not the session's output. Forward the keys
-- instead and let tmux's copy mode handle them (see tmux/.tmux.conf).
config.keys = {
  { key = 'PageUp',   mods = 'SHIFT', action = wezterm.action.SendKey { key = 'PageUp',   mods = 'SHIFT' } },
  { key = 'PageDown', mods = 'SHIFT', action = wezterm.action.SendKey { key = 'PageDown', mods = 'SHIFT' } },

  -- Ctrl+V pastes. WezTerm binds Ctrl+SHIFT+V by default and leaves plain
  -- unshifted Ctrl+V to pass through to the program -- where Claude Code takes
  -- it as chat:imagePaste and searches the clipboard for an IMAGE, so an
  -- ordinary text paste silently does nothing. Windows Terminal binds Ctrl+V to
  -- paste, which is why pasting behaves normally there and not here.
  -- COST: nvim no longer receives <C-v>. Press <C-q> for blockwise visual --
  -- vim aliases the two, so it is the same command, not a lesser one.
  { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
}

return config
