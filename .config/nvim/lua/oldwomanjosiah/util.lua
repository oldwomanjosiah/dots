local async = require 'plenary.async'
local notify = require 'notify'.async

local M = {
	levels = {
		info = "info",
		warn = "warn",
		error = "error"
	}
}


M.default_mapping_opts = {
	noremap = true,
	silent = true,
}

--- Set a mapping in all modes for the editor
function M.map(keys, mapping, opts) 
	vim.api.nvim_set_keymap(
		'',
		keys,
		mapping,
		opts or M.default_mapping_opts
	)
end

--- Set a normal mode mapping for the editor
function M.nmap(keys, mapping, opts) 
	vim.api.nvim_set_keymap(
		'n',
		keys,
		mapping,
		opts or M.default_mapping_opts
	)
end

--- Set a normal mode mapping for the editor
function M.vmap(keys, mapping, opts) 
	vim.api.nvim_set_keymap(
		'v',
		keys,
		mapping,
		opts or M.default_mapping_opts
	)
end

--- Set a normal mode mapping for the editor
function M.tmap(keys, mapping, opts) 
	vim.api.nvim_set_keymap(
		't',
		keys,
		mapping,
		opts or M.default_mapping_opts
	)
end

--- Set a normal mode mapping for a specific buffer only
function M.nmap_buf(bufnr, keys, mapping, opts) 
	vim.api.nvim_buf_set_keymap(
		bufnr,
		'n',
		keys,
		mapping,
		opts or M.default_mapping_opts
	)
end

---Send Notification to user
---@param text string[] | string: Message Contents
---@param level string?: Notification Level
---@param onClose function?: On Close Callback
function M.notify(text, level, onClose)
	local mLevel = level or M.levels.info
	local mOnClose = onClose or function() end
	async.run(function()
		notify(text, mLevel).close()
		mOnClose()
	end)
end

local cmd = {}

--- Create a user defined Vim Command (Ex Mode)
function cmd.usr(name, effect)
	vim.cmd('command! ' .. name .. ' ' .. effect)
end

--- Create a LSP Command for nmaps
--- @param name string: The name of the command to be run
function cmd.lsp(name)
	return ('<cmd>lua vim.lsp.buf.' .. name .. '()<CR>')
end

--- Create a diagnostic command
function cmd.diag(name)
	return ('<cmd>lua vim.diagnostic.' .. name .. '()<CR>')
end

--- Create a telescope invokation
--- @param for_map boolean: defaults to true, if true wrap the output for use in a mapping
function cmd.telescope(name, for_map)
	-- return ('<cmd>Telescope ' .. name .. '<CR>')
	local inner = [[lua require 'oldwomanjosiah.telescope'.open(']] .. name .. [[')]]

	if for_map == nil or for_map then
		return '<cmd>' .. inner .. '<CR>'
	else
		return inner
	end
end

--- Creating and defining Ex Mode Commands
M.cmd = cmd

return M
