-- Pull in the wezterm API
local wezterm = require("wezterm")
local hue = math.random(0, 360)
local config = wezterm.config_builder()

config.debug_key_events = true
config.window_background_gradient = {
	colors = {
		string.format("#2A2B33", hue, math.random(25, 40)),
		string.format("#002366", hue, math.random(70, 100)),
	},
	blend = "Oklab",
	orientation = {
		Radial = {
			cx = 0.8,
			cy = 0.8,
			radius = 1.2,
		},
	},
}
config.launch_menu = {
	{
		args = { "top" },
	},
	{
		args = { "tmux" },
		label = "TMUX",
	},
	{
		-- Optional label to show in the launcher. If omitted, a label
		-- is derived from the `args`
		label = "ZSH",
		-- The argument array to spawn.  If omitted the default program
		-- will be used as described in the documentation above
		args = { "zsh" },

		-- You can specify an alternative current working directory;
		-- if you don't specify one then a default based on the OSC 7
		-- escape sequence will be used (see the Shell Integration
		-- docs), falling back to the home directory.
		-- cwd = "/some/path"

		-- You can override environment variables just for this command
		-- by setting this here.  It has the same semantics as the main
		-- set_environment_variables configuration option described above
		-- set_environment_variables = { FOO = "bar" },
	},
}

config.keys = {
	-- CMD-y starts `top` in a new window
	--{
	--    key = 'y',
	-- mods = 'ALT',
	--  action = wezterm.action.SpawnCommandInNewWindow {
	--  args = { 'glances' },
	--},
	--},
}
-- For example, changing the color scheme:
config.color_scheme = "tokyonight-storm"
config.window_background_opacity = 0.7
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true

config.font = wezterm.font("Fira Code Retina")
config.font_size = 14

-- config.default_prog = { "tmux",
--
-- "attach",
-- "||",
-- "tmux",
-- "new-session"
-- }

-- and finally, return the configuration to wezterm
return config
