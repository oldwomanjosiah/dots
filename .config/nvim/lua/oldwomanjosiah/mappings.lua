local util = require 'oldwomanjosiah.util'

local M = {}

function M.setup()
	util.nmap('<Leader>w', ':Bdelete<CR>')
end

return M
