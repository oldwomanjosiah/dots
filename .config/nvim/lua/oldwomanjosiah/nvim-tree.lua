local util = require 'oldwomanjosiah.util'
local nvim_tree = require 'nvim-tree'

local M = {}

local function setup_maps()
	util.nmap('<Leader>nt', ':NvimTreeToggle<CR>')
	util.nmap('<Leader>nn', ':NvimTreeFocus<CR>')
end

--- Setup nvim-tree.lua
function M.setup(self, opts)

	nvim_tree.setup {
		open_on_setup = false,
		update_cwd = true,
		auto_close = false,
		diagnostics = {
			enable = true,
			show_on_dirs = true,
		},
		view = {
			auto_resize = true,
		}
	}

	setup_maps()
end

return M
