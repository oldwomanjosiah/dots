local util = require 'oldwomanjosiah.util'
local toggleterm = require 'toggleterm'

local M = {}

function M.setup(opts)
	toggleterm.setup {
		size = function(term)
			if term.direction == "horizontal" then
				return 30
			elseif term.direction == "vertical" then
				return vim.o.columns * 0.4
			end
		end,
		open_mapping = [[<C-t>]],
		hide_numbers = true,
		close_on_exit = true,
	}
end

return M
