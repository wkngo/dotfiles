local wezterm = require 'wezterm'

local config = {}
config.color_scheme = 'Catppuccin Mocha'

config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Regular" })
config.font_size = 12

local act = wezterm.action
config.keys = {
	{ key = 'V', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
	{ key = 'V', mods = 'CTRL', action = act.PasteFrom 'PrimarySelection' }
}

config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true

config.window_close_confirmation = "NeverPrompt"

config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_duration_ms = 0,
  fade_out_duration_ms = 0,
}

return config
