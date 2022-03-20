-- TODO(josiah) remove
package.loaded['oldwomanjosiah.util'] = nil

-- Do work that needs to be picked up by plugins
vim.g.mapleader = ' '

vim.opt.encoding = 'utf-8'
vim.opt.termguicolors = true
vim.g.home = os.getenv('HOME')
vim.g.config_dir = vim.g.home .. '/.config/nvim/'

require 'packer'.startup(function(use)
	use 'sainnhe/edge'

	use 'nvim-lua/popup.nvim'
	use 'nvim-lua/plenary.nvim'
	use 'nvim-telescope/telescope.nvim'
	use 'lewis6991/gitsigns.nvim'
	use 'neovim/nvim-lspconfig'
	use 'ray-x/lsp_signature.nvim'
	use 'j-hui/fidget.nvim'
	use 'simrat39/rust-tools.nvim'
	use 'tjdevries/nlua.nvim'
	use 'nvim-treesitter/nvim-treesitter'
	use 'L3MON4D3/LuaSnip'

	use 'ahmedkhalf/project.nvim'

	use 'mfussenegger/nvim-dap'

	-- Completion
	use 'hrsh7th/nvim-cmp'
	use 'hrsh7th/cmp-nvim-lsp'
	use 'hrsh7th/cmp-buffer'
	use 'hrsh7th/cmp-path'
	use 'f3fora/cmp-spell'
	use 'onsails/lspkind-nvim'
	use 'saadparwaiz1/cmp_luasnip'
	use 'saecki/crates.nvim'

	-- GUI
	use 'itchyny/lightline.vim'
	use 'akinsho/bufferline.nvim'
	use 'rcarriga/nvim-notify'
	use 'moll/vim-bbye'

	use 'kyazdani42/nvim-web-devicons'
	use 'kyazdani42/nvim-tree.lua'

	use 'ryanoasis/vim-devicons'

	use 'akinsho/toggleterm.nvim'
	use 'tpope/vim-surround'

	use { 'cespare/vim-toml', }
	use 'stephpy/vim-yaml'
	use 'udalov/kotlin-vim'
	use 'dag/vim-fish'
	use 'ron-rs/ron.vim'
	use 'lervag/vimtex'
	use 'oldwomanjosiah/sasylf.vim'
	use 'dingdean/wgsl.vim'
	use 'elkowar/yuck.vim'
	use 'tpope/vim-markdown'
	use 'NoahTheDuke/vim-just'
	use 'IndianBoy42/tree-sitter-just'
end)

local util = require 'oldwomanjosiah.util'

local colorscheme = {
	edge = {
		name = 'edge',
		before = (function()
			vim.g.edge_diagnostic_virtual_text = 'colored'
			vim.g.edge_style = 'default'
			vim.g.edge_transparent_background = 0
		end)
	},
	set = (function(to)
		local name = to.name or to[0]
		local before = to.before or to[1]

		if name == nil then
			util.notify 'The name field is required for colorcheme.set'
			return
		end

		if before ~= nil then before() end

		vim.cmd('colorscheme ' .. name)
	end)
}

colorscheme.set(colorscheme.edge)



--[[ Edge Colorscheme
vim.opt.edge_diagnostic_virtual_text = 'colored'
vim.opt.edge_style = 'colored'
vim.opt.edge_transparent_background = 'colored'
--]]

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes:1'
vim.opt.scrolloff = 5

vim.opt.textwidth = 80
vim.opt.cursorline = true
vim.opt.colorcolumn = { '+1' }
vim.opt.list = true
vim.opt.listchars = [[tab:· ,trail:•]]
vim.opt.lazyredraw = true
vim.opt.updatetime = 300
-- vim.opt.shortmess = vim.g.shortmess .. 'c'
vim.opt.hidden = true

vim.opt.path = (vim.g.path or '') .. '**'
vim.opt.wildmenu = true
vim.opt.wildmode = 'list:longest'

vim.opt.undodir = vim.g.config_dir .. 'nvimdid'
vim.opt.undofile = true

-- Common mappings
vim.opt.mouse = 'a'

util.map('H', '^') -- Go to beginning and end of line
util.map('L', '$')

util.nmap('n', 'nzz') -- Center after goto next search
util.nmap('N', 'Nzz')

util.nmap('U', '<C-r>') -- Better Redo

-- Navigation Mappings
util.nmap('<C-H>', '<C-W><C-H>')
util.nmap('<C-J>', '<C-W><C-J>')
util.nmap('<C-K>', '<C-W><C-K>')
util.nmap('<C-L>', '<C-W><C-L>')

vim.opt.splitright = true
vim.opt.splitbelow = true

util.nmap('<Leader><Leader>', '<C-^>')

util.nmap('<Leader>h', ':nohlsearch<Cr>')
util.vmap('<Leader>h', ':nohlsearch<Cr>')

-- Terminal mode
util.tmap('<C-H>', '<C-\\><C-N><C-W><C-H>')
util.tmap('<C-J>', '<C-\\><C-N><C-W><C-J>')
util.tmap('<C-K>', '<C-\\><C-N><C-W><C-K>')
util.tmap('<C-L>', '<C-\\><C-N><C-W><C-L>')
util.tmap('<Esc>', '<C-\\><C-N>')

vim.cmd [[
augroup buffer_types clear
	au BufNewFile,BufRead *.tex,*.md setlocal textwidth=80 spell spelllang=en_us
	au BufNewFile,BufRead *.md setlocal linebreak ts=2 sw=2 expandtab
augroup END
]]

vim.cmd [[
hi def link LspDiagnosticsDefaultError Error
hi def link LspDiagnosticsDefaultWarning Debug
hi def link LspDiagnosticsDefaultInformation Todo
hi def link LspDiagnosticsDefaultHint Todo
]]

require 'fidget'.setup {}

local cmp_out = require 'oldwomanjosiah.cmp'.setup {}

require 'oldwomanjosiah.lsp'.setup {
	capabilities = cmp_out.capabilities
}
require 'oldwomanjosiah.telescope':setup {}
require 'oldwomanjosiah.toggleterm'.setup {}
require 'oldwomanjosiah.project'.setup {}
require 'oldwomanjosiah.nvim_dap'.setup {}
require 'oldwomanjosiah.treesitter'.setup {}

require 'oldwomanjosiah.bufferline'.setup {
	options = {
		right_mouse_command = '',
		middle_mouse_command = 'Bdelete %d',
		close_command = 'Bdelete %d',
		diagnostics = 'nvim_lsp'
	}
}

vim.notify = require 'notify'

require 'oldwomanjosiah.nvim_tree':setup {}

require 'oldwomanjosiah.mappings'.setup()

require 'tree-sitter-just'.setup {}
