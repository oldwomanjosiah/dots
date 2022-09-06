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

local fn = {}
--- Map the contents of a table using f
function map(tbl, f)
	local out = {}

	for key, value in pairs(tbl or {}) do
		out[key] = f(value)
	end

	return out
end

fn.map = map

local rtp = {}

--- Get the current runtimepath as a comma separated string
function rtp.current_str()
	return vim.opt.rtp._value
end

--- Get the current runtimepath as a table of globbed paths
function rtp.current()
	return vim.split(rtp.current_str(), ',')
end

--- Find files matching a relative path with globbing in
--- the runtimepath
---
--- @see vim.fn.globpath
function rtp.find(globbed)
	return vim.split(vim.fn.globpath(rtp.current_str(), globbed), '\n')
end

function M.rerequire(module)
	package.loaded[module] = nil
	return require(module)
end

--- Turn a list like table into a string
function M.jointostr(tbl, separator)
	local function skip(itf, t, s)
		local iterator, _, k = itf(t)

		for _ = 1,s do
			k = iterator(t, k)
		end

		return iterator, tbl, k
	end

	local sep = separator or ' '
	local str = ''

	for _,v in ipairs(tbl) do
		str = str .. v
		break
	end

	for _,v in skip(ipairs, tbl, 1) do
		str = str .. sep .. v
	end

	return str
end

--- Creating and defining Ex Mode Commands
M.cmd = cmd
M.rtp = rtp
M.fn = fn

return M
