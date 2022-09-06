vim.g.mapleader = ' '
vim.g.home = os.getenv('HOME')
vim.g.config_dir = vim.g.home .. '/.config/nvim/'
vim.opt.termguicolors = true


require 'neovide'.init {
	cursor = {
		animation_length = 0.03
	},
	particle = {
		mode = require 'neovide'.particle.pixie_dust
	}
}


require 'packer'.startup(function(use)
	use 'wbthomason/packer.nvim'
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
	use 'nvim-lualine/lualine.nvim'
	use {
		'akinsho/bufferline.nvim',
		tag = 'v1.*',
	}
	use 'rcarriga/nvim-notify'
	use 'moll/vim-bbye'
	use 'hood/popui.nvim'
	use 'RishabhRD/popfix'

	use 'kyazdani42/nvim-web-devicons'
	use 'kyazdani42/nvim-tree.lua'

	use 'ryanoasis/vim-devicons'

	use {
		'akinsho/toggleterm.nvim',
		tag = 'v1.*',
	}
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
	use 'qnighy/lalrpop.vim'
	use 'tpope/vim-markdown'
	use 'NoahTheDuke/vim-just'
	use 'IndianBoy42/tree-sitter-just'
	use {
		'kevinhwang91/nvim-ufo',
		requires = 'kevinhwang91/promise-async'
	}
end)

package.loaded['oldwomanjosiah.util'] = nil
local util = require 'oldwomanjosiah.util'

local colorscheme = require 'oldwomanjosiah.util.colorscheme':setup {
	edge = {
		name = 'edge',
		before = (function()
			vim.g.edge_diagnostic_virtual_text = 'colored'
			vim.g.edge_style = 'neon'
			vim.g.edge_transparent_background = 0
		end)
	}
}

-- local iters = util.rerequire 'oldwomanjosiah.util.iters'
-- 
-- local new = iters
-- 	.iter_from { 'one', 'two', 'three' }
-- 	:map(
-- 		function (it)
-- 			return 'prefixed: ' .. it
-- 		end
-- 	)
-- 	:map(
-- 		function(it)
-- 			return it .. ', World!'
-- 		end
-- 	)
-- 	:collect()
-- 
-- print(vim.inspect(new))

local font = {
	fira = {
		name = 'Fira Code',
		default_size = 'h9',
	},
	comic = {
		name = 'Comic Code Ligatures',
		default_size = 'h9',
	},
	set = (function(to)
		local name = to.name or to[0]
		local default_size = to.default_size or to[1]

		if not name then util.notify '`to` Must contain a font name' return end
		if not default_size then util.notify '`to must contain a default size`' return end

		if type(name) ~= 'string' then util.notify 'font name must be a string' end

		if type(default_size) == 'string' then
			-- TODO(josiah) add checking
			vim.opt.guifont = name .. ':' .. default_size
		elseif type(default_size) == 'number' then
			vim.opt.guifont = name .. ':h' .. default_size
		else
			util.notify 'font size must be either a string ("h10") or number'
		end
	end)
}

colorscheme.set(colorscheme.named.edge)
font.set(font.comic)

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

vim.wo.foldcolumn = '1'
vim.wo.foldlevel = 99 -- feel free to decrease the value
vim.wo.foldenable = true

-- Common mappings
vim.opt.mouse = 'a'

util.map('H', '^') -- Go to beginning and end of line
util.map('L', '$')

util.nmap('n', 'nzz') -- Center after goto next search
util.nmap('N', 'Nzz')

util.nmap('U', '<C-r>') -- Better Redo

-- Common mistypes for exiting
util.cmd.usr('W', ':w')
util.cmd.usr('Wa', ':wa')
util.cmd.usr('Wq', ':wq')
util.cmd.usr('Q', ':q')
util.cmd.usr('Qa', ':qa')

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
util.tmap('<C-T>', ':ToggleTerm<Cr>')

local fextopts = {
	['tex'] = {
		textwidth = 80,
		spell = true,
		spelllang = 'en_us'
	},
	['md'] = {
		textwidth = 80,
		spell = true,
		spelllang = 'en_us',
		linebreak = true,
		softtabstop = 2,
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true
	}
}

local function setup_filetypes(opts)
	-- Build a single opt from a key + value
	local function makeopt(opt, value)
		local valty = type(value)

		if valty == 'boolean' then
			if value then
				return opt
			else
				return ('no' .. opt)
			end
		elseif valty == 'string' or valty == 'number' then
			return (opt .. '=' .. value)
		else
			error('cannot have opt of type ' .. valty .. ' for ' .. opt)
		end
	end

	local lines = {}
	for ft, ftopts in pairs(opts or {}) do
		local ftstr = '*.' .. ft
		local o = {}

		for k,v in pairs(ftopts or {}) do
			table.insert(o, makeopt(k, v))
		end

		table.insert(lines, 'au BufNewFile,BufRead ' .. ftstr .. ' setlocal ' .. util.jointostr(o))
	end

	vim.cmd('augroup setup_filetypes clear\n' .. util.jointostr(lines, '\n') .. '\naugroup end')
end

setup_filetypes(fextopts)

vim.cmd [[
hi def link LspDiagnosticsDefaultError Error
hi def link LspDiagnosticsDefaultWarning Debug
hi def link LspDiagnosticsDefaultInformation Todo
hi def link LspDiagnosticsDefaultHint Todo

" For UFO
hi default link UfoFoldedEllipsis Comment
]]

vim.ui.select = require 'popui.ui-overrider'
vim.ui.input = require 'popui.input-overrider'

require 'fidget'.setup {}

local cmp_out = require 'oldwomanjosiah.cmp'.setup {}

require 'oldwomanjosiah.lsp'.setup {
	capabilities = cmp_out.capabilities,
	after = function()
		require 'ufo'.setup {}
		vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
		vim.o.foldcolumn = '1'
	end
}

require 'oldwomanjosiah.telescope':setup {}
require 'oldwomanjosiah.toggleterm'.setup {}
require 'oldwomanjosiah.project'.setup {}
require 'oldwomanjosiah.nvim_dap'.setup {}
require 'oldwomanjosiah.treesitter'.setup {}

require 'bufferline'.setup {
	options = {
		right_mouse_command = '',
		middle_mouse_command = 'Bdelete %d',
		close_command = 'Bdelete %d',
		diagnostics = 'nvim_lsp'
	}
}

vim.notify = require 'notify'

require 'oldwomanjosiah.nvim-tree':setup {}

require 'oldwomanjosiah.mappings'.setup()
require 'oldwomanjosiah.lualine':setup {}

require 'tree-sitter-just'.setup {}
