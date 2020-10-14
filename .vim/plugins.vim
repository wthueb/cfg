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
    \ 'coc-python',
    \ 'coc-sh',
    \ 'coc-tsserver',
    \ 'coc-vimlsp',
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
nmap <leader>r <Plug>(coc-refactor)

" show documentaiton
nnoremap <silent> <leader>h :call CocActionAsync('doHover')<CR>
" }}}

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
let g:NERDSpaceDelims = 0

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

if has('terminal')
    " slime from emacs, required for vim-ipython-cell
    Plug 'jpalardy/vim-slime', { 'for': 'python' }
    " {{{
    let g:slime_target = 'vimterminal'
    let g:slime_python_ipython = 1
    let g:slime_vimterminal_cmd = 'ipython --matplotlib'
    let g:slime_vimterminal_config = {'term_finish': 'close'}
    " }}}

    " ipython inside vim
    Plug 'hanschen/vim-ipython-cell', { 'for': 'python' }
    " {{{
    " run cell
    nnoremap <leader>pr :IPythonCellExecuteCell<CR>
    " run entire script
    nnoremap <leader>pR :IPythonCellRun<CR>

    let g:ipython_cell_delimit_cells_by = 'marks'
    " }}}
endif

" {{{ syntax stuff
" better python syntax
Plug 'vim-python/python-syntax', { 'for': 'python' }
"" {{{
if (&ft == 'python')
    let g:python_highlight_all = 1
endif
"" }}}

" aligning text; required for vim-markdown
Plug 'godlygeek/tabular', { 'for': 'markdown' }
" markdown syntax
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }

" json syntax
Plug 'elzr/vim-json', { 'for': 'json' }
" {{{
if (&ft == 'json')
    " don't hide quotes
    let g:vim_json_syntax_conceal = 0
endif
" }}}

" typescript syntax
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
"}}}

call plug#end()
