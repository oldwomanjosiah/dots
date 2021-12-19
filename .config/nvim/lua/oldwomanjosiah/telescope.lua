local utils = require 'oldwomanjosiah.util'
local telescope = require 'telescope'

local M = {}

M.theme = [[require 'telescope.themes'.get_ivy {}]]
M.base = [[:lua require 'telescope.builtin']]

local function tele(builtin)
	return M.base .. '.' .. builtin .. '(' .. M.theme .. ')<CR>'
end

function M.setup(opts)
	utils.nmap('<Leader>ff', tele('find_files'))
	utils.command('HelpPage', tele('help_tags'))
	utils.command('Recents', tele('oldfiles'))

	telescope.setup {}
end

return M
