local util = require 'oldwomanjosiah.util'
local toggleterm = require 'toggleterm'

local M = {
	sizes = {
		vert = function(cols) return cols * 0.4 end,
		hori = function(_) return 30 end
	},
	default_direction = "vertical"
}

function M.setup(opts)
	M.default_direction = opts.default_direction or M.default_direction

	toggleterm.setup {
		size = function(term)
			if term.direction == "horizontal" then
				return M.sizes.hori(vim.o.lines)
			elseif term.direction == "vertical" then
				return M.sizes.vert(vim.o.columns)
			end
		end,
		open_mapping = [[<C-t>]],
		hide_numbers = true,
		close_on_exit = true,
		direction = M.default_direction 
	}

	require 'notify'
end

return M
