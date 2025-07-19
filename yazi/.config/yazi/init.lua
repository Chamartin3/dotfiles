-- ~/.config/yazi/init.lua

require("duckdb"):setup({
	-- mode = "standard" / "summarized", -- Default: "summarized"
	-- cache_size = 1000, -- Default: 500
	-- row_id = true / false / "dynamic", -- Default: false
	-- minmax_column_width = int, -- Default: 21
	-- column_fit_factor = float, -- Default: 10.0
})

require("git"):setup()

-- Initialize git theme (use 'th' which is the correct global variable for themes)
th = th or {}
th.git = th.git or {}

-- Set git status signs with icons
-- th.git.modified_sign = "" -- Modified icon
-- th.git.deleted_sign = "" -- Deleted icon
-- th.git.added_sign = "" -- Added icon
-- th.git.untracked_sign = "" -- Untracked icon (question mark circle)
-- th.git.updated_sign = "" -- Updated icon
-- th.git.ignored_sign = "" -- Ignored icon
--
-- -- Set git status colors
-- th.git.modified = ui.Style():fg("blue"):bold()
-- th.git.deleted = ui.Style():fg("red"):bold()
-- th.git.untracked = ui.Style():fg("yellow"):bold() -- Made bold for better visibility
-- th.git.added = ui.Style():fg("green"):bold()
-- th.git.updated = ui.Style():fg("cyan"):bold()
-- th.git.ignored = ui.Style():fg("darkgray")
--
-- Setup git plugin
