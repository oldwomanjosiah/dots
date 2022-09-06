local utils = require 'oldwomanjosiah.util'
local telescope = require 'telescope'
local builtins = require 'telescope.builtin'
local themes = require 'telescope.themes'
local extensions = require 'telescope'.extensions

local M = {}

local function get_builtin(action)
	return builtins[action]
end

local function get_extension(ext)
	return extensions[ext]
end

function M.open(action, sub_action)
	if sub_action == nil then
		local ok, ext = pcall(get_builtin, action)
		if not ok then
			-- try calling extension
			local ok, ext = pcall(get_extension, action)

			if not ok then
				utils.notify('Could not find telescope builtin or extension with name ' .. action, 'error')
				return
			end

			if sub_action == nil then
				ext(M.theme)
			else
				local ext = ext[sub_action]

				if ext == nil then
					utils.notify('Could not find action ' .. sub_action .. ' in extension ' .. action, 'error')
					return
				end

				ext(M.theme)
			end
		else
			ext(M.theme)
		end
	end
end

local tele = utils.cmd.telescope

function M.setup(self, opts)
	utils.nmap('<Leader>ff', tele('find_files'))
	utils.cmd.usr('HelpPage', tele('help_tags', false))
	utils.cmd.usr('Recents', tele('oldfiles', false))

	self.theme = (opts or {}).theme or (themes.get_dropdown {})

	telescope.setup {}

end

return M
