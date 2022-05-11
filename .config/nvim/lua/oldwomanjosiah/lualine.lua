local util = require 'oldwomanjosiah.util'

local M = {}

local function wordCount()
	if vim.opt.filetype._value == 'markdown' then
		return tostring(vim.fn.wordcount().words)
	else
		return ''
	end
end

local function mdsetup()
end

function M.setup(self, opts)
	local diagnostics = {
		'diagnostics',
		colored = false,
		sections = { 'error', 'warn' }
	}

	require 'lualine'.setup {
		options = {
			icons_enabled = true,
			theme = 'edge',
		},
		sections = {
			lualine_a = { 'mode' },
			lualine_b = { 'filename', diagnostics },

			lualine_c = { wordCount },

			lualine_v = {},
			lualine_w = {},

			lualine_x = { 'diff', 'branch'},
			lualine_y = { 'filetype' },
			lualine_z = { 'location' },
		},
		inactive_sections = {
			lualine_a = { 'filename' },
			lualine_b = { diagnostics, wordCount },

			lualine_c = {},

			lualine_v = {},
			lualine_w = {},

			lualine_x = { 'diff' },
			lualine_y = { 'filetype' },
			lualine_z = { 'location' },
		},
		extensions = { 'nvim-tree', 'toggleterm' }
	}
end

return M
