local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Window
config.window_decorations = "TITLE|RESIZE"
config.window_background_opacity = 1
-- config.window_padding = { left = 12, right = 12, top = 12, bottom = 12 }

-- Tab bar
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

config.default_prog = { 'wsl.exe', '~' }

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

return config
