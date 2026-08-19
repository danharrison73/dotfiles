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

-- Scrollback
config.scrollback_lines = 10000

-- Shift+PageUp/PageDown are WezTerm defaults for scrolling ITS scrollback, which
-- is the wrong buffer: tmux repaints the whole screen every frame, so WezTerm's
-- history is a stack of stale frames, not the session's output. Forward the keys
-- instead and let tmux's copy mode handle them (see tmux/.tmux.conf).
config.keys = {
  { key = 'PageUp',   mods = 'SHIFT', action = wezterm.action.SendKey { key = 'PageUp',   mods = 'SHIFT' } },
  { key = 'PageDown', mods = 'SHIFT', action = wezterm.action.SendKey { key = 'PageDown', mods = 'SHIFT' } },
}

return config
