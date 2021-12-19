local lsp = require 'oldwomanjosiah.lsp'
local telescope = require 'oldwomanjosiah.telescope'
local toggleterm = require 'oldwomanjosiah.toggleterm'
local cmp = require 'oldwomanjosiah.cmp'
local project = require 'oldwomanjosiah.project'
local nvim_dap = require 'oldwomanjosiah.nvim_dap'
local treesitter = require 'oldwomanjosiah.treesitter'

local M = {}

-- Setup my configurations
function M.setup(opts)
	local cmp_out = cmp.setup {}
	lsp.setup {
		capabilities = cmp_out.capabilities
	}
	telescope.setup {}
	toggleterm.setup {}
	project.setup {}
	nvim_dap.setup {}
	treesitter.setup {}
end

return M
