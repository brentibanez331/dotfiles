local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

local is_windows = os.getenv("OS") and os.getenv("OS"):lower():find("windows")
local is_mac = wezterm.target_triple:lower():find("darwin") ~= nil

config.color_scheme = "rose-pine-moon"
config.colors = {
  selection_bg = "#56526e",
}

config.max_fps = 120
config.font = wezterm.font_with_fallback({
	"Hack Nerd Font",
	"Symbols Nerd Font Mono",
})

config.inactive_pane_hsb = {
  saturation = 1.0,
  brightness = 0.5,
}

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

if is_windows then
  config.win32_system_backdrop = "Acrylic"
  config.window_background_opacity = 0.7
  config.window_frame = { font_size = 10.0 }
end

if is_mac then
  config.window_background_opacity = 0.8
  config.macos_window_background_blur = 50
  config.font_size = 12.0
  config.window_frame = { font_size = 13.0 }
end

if is_windows then
  config.default_domain = "WSL:Ubuntu-24.04"
end

config.window_padding = { left = 16, right = 16, top = 32, bottom = 32 }

local maximize_window = wezterm.action_callback(function(window, _pane)
  window:maximize()
end)

local restore_window = wezterm.action_callback(function(window, _pane)
  window:restore()
end)

-- The fancy tab bar looks like native tabs; set to false for a slimmer retro bar.
config.use_fancy_tab_bar = true
-- Hide the tab bar entirely when you only have one tab (less clutter).
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE" -- no title bar, but still resizable

--------------------------------------------------------------------------------
-- BEHAVIOR
--------------------------------------------------------------------------------

config.scrollback_lines = 10000
config.audible_bell = "Disabled"
-- Cursor style: BlinkingBar | SteadyBar | BlinkingBlock | SteadyBlock
config.default_cursor_style = "BlinkingBar"

--------------------------------------------------------------------------------
-- KEY BINDINGS
--------------------------------------------------------------------------------
-- WezTerm has a rich multiplexer built in (splits/panes/tabs) so you often don't
-- even need tmux. `mods` is a string like "CMD", "CMD|SHIFT", "CTRL|ALT".
-- On macOS, CMD is the natural "leader". Below is a small, memorable set.

config.keys = {
	-- Splits: CMD+d = vertical split (side by side), CMD+SHIFT+d = horizontal.
	{ key = "d", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Move focus between panes with CMD + arrow keys.
	{ key = "LeftArrow", mods = "CMD", action = act.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "CMD", action = act.ActivatePaneDirection("Right") },
	{ key = "UpArrow", mods = "CMD", action = act.ActivatePaneDirection("Up") },
	{ key = "DownArrow", mods = "CMD", action = act.ActivatePaneDirection("Down") },

	-- Close the current pane (asks for confirmation).
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = true }) },

	-- Resize the focused pane. Hold CMD+CTRL and use arrows.
	{ key = "LeftArrow", mods = "CMD|CTRL", action = act.AdjustPaneSize({ "Left", 3 }) },
	{ key = "RightArrow", mods = "CMD|CTRL", action = act.AdjustPaneSize({ "Right", 3 }) },
	{ key = "UpArrow", mods = "CMD|CTRL", action = act.AdjustPaneSize({ "Up", 3 }) },
	{ key = "DownArrow", mods = "CMD|CTRL", action = act.AdjustPaneSize({ "Down", 3 }) },

	-- Toggle a pane to fullscreen-within-the-tab (zoom), like tmux <prefix> z.
	{ key = "z", mods = "CMD", action = act.TogglePaneZoomState },

        { key = "Enter", mods = "CMD", action = maximize_window },
        { key = "Enter", mods = "CMD|SHIFT", action = restore_window }
}

-- 3. ALWAYS return the config table. WezTerm ignores the file otherwise.
return config
