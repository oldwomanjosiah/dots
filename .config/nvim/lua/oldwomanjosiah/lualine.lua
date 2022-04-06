local M = {}

function M.setup(self, opts)
	local diagnostics = { 'diagnostics', colored = false }

	require 'lualine'.setup {
		options = {
			icons_enabled = true,
			theme = 'edge',
		},
		sections = {
			lualine_a = { 'mode' },
			lualine_b = { 'filename', diagnostics },

			lualine_c = {},

			lualine_v = {},
			lualine_w = {},

			lualine_x = { 'diff', 'branch'},
			lualine_y = { 'filetype' },
			lualine_z = { 'location' },
		},
		inactive_sections = {
			lualine_a = { 'filename' },
			lualine_b = { diagnostics },

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
