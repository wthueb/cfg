if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    augroup PlugInstall
        autocmd! VimEnter * PlugInstall
    augroup END
endif

call plug#begin('~/.vim/bundle')

" colorscheme
Plug 'dracula/vim', { 'as': 'dracula' }

" autocompletion
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
" {{{
let g:coc_global_extensions = [
    \ 'coc-clangd',
    \ 'coc-css',
    \ 'coc-html',
    \ 'coc-json',
    \ 'coc-pyright',
    \ 'coc-sh',
    \ 'coc-tsserver',
    \ 'coc-vimlsp',
    \ 'coc-vimtex',
    \ 'coc-yaml',
    \]

" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <Tab>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<Tab>" :
    \ coc#refresh()

" formatting
nmap <leader>= <Plug>(coc-format)
vmap <leader>= <Plug>(coc-format-selected)

" rename
nmap <leader><C-r> <Plug>(coc-rename)

" show documentaiton
function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    else
        call CocActionAsync('doHover')
    endif
endfunction
nnoremap <silent> K :call <SID>show_documentation()<CR>
" }}}

" stauts bar
Plug 'vim-airline/vim-airline'

" fuzzy file finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
"" {{{
nnoremap <C-p> :FZF<CR>
"" }}}

" file browser
Plug 'scrooloose/nerdtree'
" {{{
abbrev nt NERDTree

" toggle using ,n
nnoremap <silent> <leader>n :NERDTreeToggle<CR>

" open to current file using ,v
nnoremap <silent> <leader>v :NERDTreeFind<CR>

" close when opening file
let NERDTreeQuitOnOpen = 1

" when you delete a file delete its buffer
let NERDTreeAutoDeleteBuffer = 1

" disable press ? for help
let NERDTreeMinimalUI = 1

" open when no command line arguments or stdin is passed
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" }}}

" better commenting
Plug 'preservim/nerdcommenter'
" {{{
" space after delimiter
let g:NERDSpaceDelims = 1

" compact multi-line comments
let g:NERDCompactSexyComs = 1

let g:NERDCommentEmptyLines = 0

" trim trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

let g:NERDCreateDefaultMappings = 0

nmap <silent> ,cc <Plug>NERDCommenterToggle
vmap <silent> ,cc <Plug>NERDCommenterToggle

nmap <silent> ,cs <Plug>NERDCommenterSexy
vmap <silent> ,cs <Plug>NERDCommenterSexy
" }}}

" show registers when using " or @
Plug 'junegunn/vim-peekaboo'

if has('signs')
    " show marks
    Plug 'kshenoy/vim-signature'
endif

" change quotes/parens
Plug 'tpope/vim-surround'

" git diff as line numbers
Plug 'airblade/vim-gitgutter'

" repeat plugin maps with . too
Plug 'tpope/vim-repeat'

" markdown preview in browser
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
" {{{
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 1
let g:mkdp_refresh_slow = 1
let g:mkdp_command_for_global = 0
let g:mkdp_open_to_the_world = 0

autocmd FileType markdown nnoremap <buffer> <leader>r :MarkdownPreview<CR>
" }}}

" {{{ filetype stuff
" better python syntax
Plug 'vim-python/python-syntax', { 'for': 'python' }
" {{{
let g:python_highlight_all = 1
" }}}

" aligning text; required for vim-markdown
Plug 'godlygeek/tabular', { 'for': 'markdown' }
" markdown syntax
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }

" json syntax
Plug 'elzr/vim-json', { 'for': 'json' }
" {{{
" don't hide quotes
let g:vim_json_syntax_conceal = 0
" }}}

" typescript syntax
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }

" TeX
Plug 'lervag/vimtex', { 'for': 'tex' }
"{{{
let g:tex_flavor = 'latex'

"}}}

" snippets
Plug 'sirver/ultisnips'
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
"}}}

call plug#end()
