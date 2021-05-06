set nocompatible
let mapleader=" "

" {{{ Plugins
call plug#begin('~/.config/nvim/bundles')
Plug 'morhetz/gruvbox'

" Fuzzy Finding (Replacing Nerdtree)
" Plug 'airblade/vim-rooter'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'preservim/nerdtree' |
 \ Plug 'Xuyuanp/nerdtree-git-plugin' |
 \ Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" Language Client for RLS
Plug 'autozimu/LanguageClient-neovim', {
		\ 'branch': 'next',
		\ 'do': 'bash install.sh',
		\ }

" Tags Pane
Plug 'liuchengxu/vista.vim'

" AutoCompletion
Plug 'neoclide/coc.nvim', { 'branch': 'release' }

" Language Support
Plug 'cespare/vim-toml'
Plug 'stephpy/vim-yaml'
Plug 'dag/vim-fish'
Plug 'rust-lang/rust.vim'
" Plug 'plasticboy/vim-markdown'
Plug 'ron-rs/ron.vim'
Plug 'lervag/vimtex'

" Plug 'harenome/vim-mipssyntax' " CS315 Mips Syntax

" GUI
Plug 'itchyny/lightline.vim'
Plug 'oldwomanjosiah/lightline-gruvbox.vim'
Plug 'mengelbrecht/lightline-bufferline'

Plug 'ryanoasis/vim-devicons'
call plug#end()

" }}}

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

" Fzf Shortcuts
nnoremap <Leader>b :Buffers<Cr>
nnoremap <C-p> :GFiles<Cr>
nnoremap <Leader>o :Files<Cr>
nnoremap <Leader>f :Rg<Cr>

" Nerdtree
nnoremap <Leader>nt :NERDTreeToggle<Cr>
nnoremap <Leader>nn :NERDTreeFocus<Cr>

" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

" Start nerdtree if vim started without a file
autocmd VimEnter * NERDTree | wincmd p

" NERDTreeGit
let g:NERDTreeGitStatusUseNerdFonts = 1
let g:NERDTreeGitStatusShowIgnored = 1

" Tex reflow paragraph
nnoremap <Leader>rf :norm gqip<Cr>
vnoremap <Leader>rf gq<Cr>

" coc options
nnoremap <Silent> <Leader>f :call CocAction('format')<Cr>
nnoremap <Leader>s :CocList outline<Cr>

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

nmap <leader>rn <Plug>(coc-rename)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
"
" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)

" 'Smart' nevigation
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-.> to trigger completion.
inoremap <silent><expr> <c-.> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

nnoremap <Leader><Leader> <C-^> " Map space-spcae to go to most recent buffer

" Unhighlight searches
nnoremap <Leader>h :nohlsearch<Cr>
vnoremap <Leader>h :nohlsearch<Cr>

" Lightline Options
let g:lightline#bufferline#unicode_symbols=1
let g:lightline_gruvbox_color='both'
set showtabline=2
if !has('gui_running')
  set t_Co=256
endif

let g:lightline = {
		\   'colorscheme': 'gruvbox',
		\   'active': {
		\     'left': [ [ 'mode', 'paste' ],
		\				[ 'cocstatus' ],
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

" Coc
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
" autocmd CursorHold * silent call CocActionAsync('highlight')
" Show type annotation
nnoremap <Leader>t :call CocAction('doHover')<Cr>
nnoremap <Leader>T :call CocAction('doHover')<Cr>

nnoremap <silent> <Leader>a :CocAction<Cr>

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Apply AutoFix to problem on the current line.
nmap <leader>i  <Plug>(coc-fix-current)

" Coc code regions
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

set noshowmode

" Vista Options
let g:vista_default_executive = 'coc'
let g:vista#renderer#enable_icon = 1
let g:vista_fzf_preview = ['right:50%']
let g:vista_echo_cursor_strategy = 'scroll'

nnoremap <silent> <Leader>vf :Vista finder<Cr>
nnoremap <silent> <Leader>vv :Vista!!<Cr>

" Start fzf if opened without file specified
" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | call fzf#vim#files(".", 0) | endif

" Rust specific options
autocmd BufNewFile,BufRead *.rs setlocal colorcolumn=100

" Vimtex filetype options
let g:tex_flavor = 'latex'
autocmd BufNewFile,BufRead *.tex setlocal textwidth=80 spell spelllang=en_us

" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1

" Use auocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
" Completion
" Better display for messages
set cmdheight=2
" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" Foldmethod
set foldmethod=marker

" Set Colorscheme
colorscheme gruvbox
