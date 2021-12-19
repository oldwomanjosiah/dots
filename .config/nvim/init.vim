set nocompatible
let mapleader=" "

" {{{ Plugins
call plug#begin('~/.config/nvim/bundles')
" Plug 'morhetz/gruvbox'
Plug 'sainnhe/edge'
Plug 'dracula/vim', { 'as': 'dracula' }

" Fuzzy Finding (Replacing Nerdtree)
" Plug 'airblade/vim-rooter'
" Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
" Plug 'junegunn/fzf.vim'

Plug 'preservim/nerdtree' |
 \ Plug 'Xuyuanp/nerdtree-git-plugin' |
 \ Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" AutoCompletion
" Plug 'neoclide/coc.nvim', { 'branch': 'release' }

" Language Support
Plug 'cespare/vim-toml'
Plug 'stephpy/vim-yaml'
Plug 'udalov/kotlin-vim'
Plug 'dag/vim-fish'
Plug 'rust-lang/rust.vim'
Plug 'ron-rs/ron.vim'
Plug 'lervag/vimtex'
Plug 'tpope/vim-markdown'
Plug 'oldwomanjosiah/sasylf.vim'
Plug 'dingdean/wgsl.vim'
Plug 'elkowar/yuck.vim'

" Package Deps
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'

" Telescope
Plug 'nvim-telescope/telescope.nvim'

" Git
Plug 'lewis6991/gitsigns.nvim'

" Built-in LSP
Plug 'neovim/nvim-lspconfig'
Plug 'ray-x/lsp_signature.nvim'
Plug 'simrat39/rust-tools.nvim'
Plug 'tjdevries/nlua.nvim'

" Tree-Sitter
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }

" Snippets
Plug 'L3MON4D3/LuaSnip'

" Projects
Plug 'ahmedkhalf/project.nvim'

" Debugging
Plug 'mfussenegger/nvim-dap'

" Completion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'f3fora/cmp-spell'
Plug 'onsails/lspkind-nvim'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'saecki/crates.nvim'

" Plug 'dkarter/bullets.vim'
" This is currently removed because it broke code blocks

" GUI
Plug 'itchyny/lightline.vim'
" Plug 'oldwomanjosiah/lightline-gruvbox.vim'
Plug 'mengelbrecht/lightline-bufferline'

Plug 'ryanoasis/vim-devicons'

Plug 'akinsho/toggleterm.nvim'
Plug 'tpope/vim-surround'
Plug 'ggandor/lightspeed.nvim'
call plug#end()

" }}}

" Set Colorscheme
let g:edge_diagnostic_virtual_text = 'colored'
let g:edge_style = 'default'
let g:edge_transparent_background = 0
colorscheme edge


" Main Section
set tabstop=4
set softtabstop=4
set shiftwidth=4
" set noexpandtab
set nu
set rnu
set signcolumn=yes " For empty gitgutter
set scrolloff=3

set cursorline
set colorcolumn=81
set list
set listchars=tab:·\ ,trail:•
set lazyredraw
set shortmess+=c " For coc
set hidden " Allow switching through unwritten buffers

" Remap beginning and end of line to home row
map H ^
map L $

" Center Search Results
nnoremap <silent> n nzz
nnoremap <silent> N Nzz

" Allow Mouse Scrolling in terminals
set mouse=a

" File Finding
set path+=**
set wildmenu
set wildmode=list:longest

" Splits Remaps
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-H> <C-W><C-H>
nnoremap <C-L> <C-W><C-L>

" Terminal mode remaps
tnoremap <C-J> <C-\><C-N><C-W><C-J>
tnoremap <C-K> <C-\><C-N><C-W><C-K>
tnoremap <C-H> <C-\><C-N><C-W><C-H>
tnoremap <C-L> <C-\><C-N><C-W><C-L>
tnoremap <Esc> <C-\><C-N>

" Clear Arrow Keys
nnoremap <Up> <NoP>
nnoremap <Down> <NoP>
nnoremap <Left> <NoP>
nnoremap <Right> <NoP>

" Common mistypes
nnoremap :W :w
nnoremap :Q :q

" Better redo
nnoremap U <C-r>

" Change split behavior to match tmux
set splitright
set splitbelow

" Undo over time
set undodir=~/.config/nvim/.nvimdid
set undofile

" Nerdtree
nnoremap <Leader>nt :NERDTreeToggle<Cr>
nnoremap <Leader>nn :NERDTreeFocus<Cr>

" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

" Start nerdtree with vim
autocmd VimEnter * NERDTree | wincmd p

" NERDTreeGit
let g:NERDTreeGitStatusUseNerdFonts = 1
let g:NERDTreeGitStatusShowIgnored = 1
let g:NERDTreeChDirMode = 2

" Tex reflow paragraph
nnoremap <Leader>rf :norm gqip<Cr>
vnoremap <Leader>rf gq<Cr>

nnoremap <Leader><Leader> <C-^> " Map space-spcae to go to most recent buffer
set noshowmode

" Unhighlight searches
nnoremap <Leader>h :nohlsearch<Cr>
vnoremap <Leader>h :nohlsearch<Cr>

" Lightline Options
let g:lightline#bufferline#unicode_symbols=1
" let g:lightline_gruvbox_color='both'
set showtabline=2
if !has('gui_running')
  set t_Co=256
endif

set termguicolors

"				[ 'cocstatus' ], removed from lightline config

let g:lightline = {
		\   'colorscheme': 'edge',
		\   'active': {
		\     'left': [ [ 'mode', 'paste' ],
		\               [ 'readonly', 'filename', 'modified' ] ],
		\     'right':[ [ 'gitstatus' ],
		\				[ 'percent' ],
		\				[ 'filetype', 'encoding', 'lineinfo' ] ]
		\   },
		\   'tabline': {
		\     'left': [ [ 'buffers' ] ],
		\     'right': [ [ 'tabs' ] ]
		\   },
		\   'component_function': {
		\     'filename': 'LightlineFilename',
		\     'cocstatus': 'coc#status',
		\     'gitstatus': 'LightlineGitStatus',
		\   },
		\   'component_expand': {
		\     'buffers': 'lightline#bufferline#buffers'
		\   },
		\   'component_type': {
		\     'buffers': 'tabsel'
		\   },
		\ }

function! LightlineFilename()
  return expand('%:t') !=# '' ? WebDevIconsGetFileTypeSymbol() . ' ' . @% : '[No Name]'
endfunction
function! LightlineGitStatus() abort
	let status = get(g:, 'coc_git_status', '')
	return winwidth(0) > 100 ? status : ''
endfunction

" Rust specific options
autocmd BufNewFile,BufRead *.rs setlocal colorcolumn=100

" Vimtex and markdown filetype options
let g:tex_flavor = 'latex'
autocmd BufNewFile,BufRead *.tex,*.md setlocal textwidth=80 spell spelllang=en_us
autocmd BufNewFile,BufRead *.md setlocal linebreak ts=2 sw=2 expandtab
autocmd BufNewFile,BufRead *.c,*.h setlocal ts=2 sw=2 expandtab

" Sasylf Special
autocmd BufNewFile,BufRead *.slf nnoremap <silent> <C-Space>
			\ :cexpr system('sasylf ' . expand('%:p')) <bar> :copen<CR>

let g:markdown_fenced_languages = ['html', 'python', 'kotlin', 'rust', 'bash=sh']

map <Leader>shl :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Use auocmd to force lightline update.
" autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
" Completion
" Better display for messages
set cmdheight=2
" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" Foldmethod
set foldmethod=marker

" ToggleTerm
lua << EOF
require 'oldwomanjosiah'.setup {}
EOF

hi def link LspDiagnosticsDefaultError Error
hi def link LspDiagnosticsDefaultWarning Debug
hi def link LspDiagnosticsDefaultInformation Todo
hi def link LspDiagnosticsDefaultHint Todo

let g:toggleterm_terminal_mapping = '<C-t>'

" let g:neovide_cursor_animation_length=0.01
" set guifont=CodeNewRoman\ Nerd\ Font\ Mono:8
