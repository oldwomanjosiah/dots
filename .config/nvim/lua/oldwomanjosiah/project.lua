local project = require 'project_nvim'
local util = require 'oldwomanjosiah.util'
local telescope = require 'telescope'

local M = {}

function M.setup(opts)
	project.setup {
		exclude_dirs = {
			"~/.cargo/"
		}
	}
	util.cmd.usr('Project', ':Telescope projects')
	telescope.load_extension('projects')
end

return M
