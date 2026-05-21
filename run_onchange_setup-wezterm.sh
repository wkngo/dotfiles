#!/bin/bash
# Deploy WezTerm config to the Windows filesystem — only applicable when running WSL on Windows.
# On native Linux, chezmoi manages ~/.config/wezterm/wezterm.lua directly.
# Edit the heredoc below to update the config — chezmoi will re-run this
# script automatically on the next `chezmoi apply` when the content changes.

# Only applicable under WSL
grep -qi microsoft /proc/version 2>/dev/null || exit 0

WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n')
WIN_HOME="/mnt/c/Users/${WIN_USER}"
DEST="${WIN_HOME}/.wezterm.lua"

cat > /tmp/wezterm.lua << 'WEZTERM'
local wezterm = require 'wezterm'

local config = {}
config.default_domain = 'WSL:Ubuntu-24.04'

-- config.color_scheme = 'Tokyo Night'
-- config.color_scheme = 'Tokyo Night Day'
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
WEZTERM

if [ -d "$WIN_HOME" ]; then
  cp /tmp/wezterm.lua "$DEST"
  echo "WezTerm config deployed to $DEST"
else
  echo "---"
  echo "MANUAL STEP REQUIRED: Could not find Windows home at $WIN_HOME"
  echo "Copy .wezterm.lua manually to: C:\\Users\\<you>\\.wezterm.lua"
  echo "Source is at: $(chezmoi source-path)/run_onchange_setup-wezterm.sh (the heredoc)"
  echo "---"
fi

rm /tmp/wezterm.lua
