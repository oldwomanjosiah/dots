local treesitter = require 'nvim-treesitter'
local ts_configs = require 'nvim-treesitter.configs'

local M = {}

function M.setup(cfg)
	ts_configs.setup {
		highlight = {
			enable = true,
		}
	}
end

return M
