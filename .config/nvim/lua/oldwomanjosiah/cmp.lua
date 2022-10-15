local cmp = require 'cmp'
local cmp_lsp = require 'cmp_nvim_lsp'

local utils = require 'oldwomanjosiah.util'

local M = {}

M.sources = {
	{ name = 'nvim_lsp' },
	{ name = 'crates' },
	{ name = 'path' },
	{ name = 'buffer', keyword_length = 5 },
	{ name = 'spell', keyword_length = 5, max_item_count = 3 },
}

-- Setup cmp config, returns table containing cmp extended capabilities
function M.setup(opts)
	cmp.setup({
		mapping = {
			['<C-Space>'] = cmp.mapping.complete(),
			['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
			['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
			['<CR>'] = cmp.mapping.confirm({
				-- select = true,
				behavior = cmp.SelectBehavior.Replace
			}),
		},
		sources = cmp.config.sources(M.sources),
		formatting = {
			format = require 'lspkind'.cmp_format {
				with_text = true,
				menu = {
					buffer = '[b]',
					path = '[p]',
					spell = '[s]',
					nvim_lsp = '[lsp]',
				},
			},
		},
		snippet = {
			expand = function(args)
				require 'luasnip'.lsp_expand(args.body)
			end
		},
		experimental = { native_menu = false, ghost_text = true },
	})

	--[[ local capabilities = cmp_lsp.update_capabilities(
		vim.lsp.protocol.make_client_capabilities()
	) ]]
	local capabilities = cmp_lsp.default_capabilities()

	return { capabilities = capabilities }
end

return M
