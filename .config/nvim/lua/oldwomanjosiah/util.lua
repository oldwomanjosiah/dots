local M = {}

-- Create a callable command
function M.command(name, effect)
	vim.cmd('command! ' .. name .. ' ' .. effect)
end

M.default_mapping_opts = {
	noremap = true,
	silent = true,
}

-- Set a normal mode mapping for the editor
function M.nmap(keys, mapping, opts) 
	vim.api.nvim_set_keymap(
		'n',
		keys,
		mapping,
		opts or M.default_mapping_opts
	)
end

-- Set a normal mode mapping for a specific buffer only
function M.nmap_buf(bufnr, keys, mapping, opts) 
	vim.api.nvim_buf_set_keymap(
		bufnr,
		'n',
		keys,
		mapping,
		opts or M.default_mapping_opts
	)
end

return M
