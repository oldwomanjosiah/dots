local lspconfig = require 'lspconfig'
local gitsigns = require 'gitsigns'
local crates = require 'crates'
local rust_tools = require 'rust-tools'
local nvim_lua = require 'nlua.lsp.nvim'
local lsp_signature = require 'lsp_signature'
local rust_tools_dap = require 'rust-tools.dap'

local utils = require 'oldwomanjosiah.util'

local M = {
	codelldb_path_d = '/usr/bin/rust-lldb',
	liblldb_path_d = '',
}

M.servers = {
	{ name = "texlab", settings = {} },
	{ name = "vimls" },
	{ name = "clangd" },
}

M.on_attach = function(client, bufnr)
	local lspcmd = utils.cmd.lsp
	local diag = utils.cmd.diag
	local telescope = utils.cmd.telescope

	-- Jump Commands
	utils.nmap_buf(bufnr, 'gD', lspcmd('declaration'))
	utils.nmap_buf(bufnr, 'gd', telescope('lsp_definitions'))
	utils.nmap_buf(bufnr, 'gi', telescope('lsp_implementations'))
	utils.nmap_buf(bufnr, 'gr', telescope('lsp_references'))
	utils.nmap_buf(bufnr, 'cs', telescope('lsp_workspace_symbols'))

	-- Diagnostic Commands
	utils.nmap_buf(bufnr, '<Leader>d', lspcmd('hover'))
	utils.nmap_buf(bufnr, '<Leader>t', lspcmd('hover')) -- Old 'type' informati 
	utils.nmap_buf(bufnr, '<Leader>e', diag('open_float'))
	utils.nmap_buf(bufnr, ']d', diag('goto_next'))
	utils.nmap_buf(bufnr, '[d', diag('goto_prev'))

	-- Refactoring Commands
	utils.nmap_buf(bufnr, '<Leader>rn', lspcmd('rename'))
	utils.nmap_buf(bufnr, '<Leader>ca', lspcmd('code_action'))
	utils.nmap_buf(bufnr, '<Leader>cl', lspcmd('code_lens'))
	utils.nmap_buf(bufnr, '<Leader>rf', lspcmd('formatting'))

	utils.nmap_buf(bufnr, '<Leader>fd', telescope('lsp_document_symbols'))
	utils.nmap_buf(bufnr, '<Leader>fw', telescope('lsp_workspace_symbols'))

	vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]

	lsp_signature.on_attach()
end

-- Setup lsp, allows for overriding capabilities in opts
function M.setup(opts)

	M.capabilities = vim.lsp.protocol.make_client_capabilities()

	local folding = {
		textDocument = {
			foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true
			}
		}
	}

	M.capabilities = vim.tbl_deep_extend('force', M.capabilities, opts.capabilities or {}, folding)

	for _, server in ipairs(M.servers) do
		lspconfig[server.name].setup {
			on_attach = M.on_attach,
			capabilities = M.capabilities,
			settings = server.settings or opts.default_settings or {},
		}
	end

	nvim_lua.setup(
		lspconfig,
		{
			on_attach = M.on_attach,
			capabilities = M.capabilities,
		}
	)

	rust_tools.setup {
		tools = {
			right_align = true,
			executor = {
				execute_command = function(command, args, cwd)
					local term = require 'toggleterm.terminal'
					local toggleterm = require 'oldwomanjosiah.toggleterm'

					local rust_command = require 'rust-tools.utils.utils'.make_command_from_args(command, args)

					print(vim.inspect(rust_command))

					local terminal, new = term.get_or_create_term(1, cwd, toggleterm.default_direction)

					if new or not terminal:is_open() then
						local size = require 'oldwomanjosiah.toggleterm'.sizes.hori(vim.o.lines)

						terminal:open(size, toggleterm.default_direction, new)
					end

					terminal:send(rust_command, true)
				end,
			}
		},
		server = {
			on_attach = M.on_attach,
			capabilities = M.capabilities,
			settings = {
				expand_macro = true,
				run_build_scripts = true,
				load_out_dirs_from_check = true,
				proc_macro = {
					ignored = {
						['async-trait'] = { 'async_trait' },
						['tonic'] = { 'async_trait' }
					}
				}
			},
		},
		--[[
		dap = {
			adapter = rust_tools_dap.get_codelldb_adapter(
				opts.codelldb_path or M.codelldb_path_d,
				opts.liblldb_path or M.liblldb_path_d
			)
		},
		]]--
		dap = {
			adapter = {
				type = 'executable',
				command = 'lldb-vscode',
				name = 'rt_lldb'
			}
		},
		debuggables = { use_telescope = true, },
		inlay_hints = { max_len_align = true, },
		runnables = { use_telescope = true, },
	}

	crates.setup()

	gitsigns.setup {
		current_line_blame = true,
	}

	if opts.after then opts.after() end
end

return M
