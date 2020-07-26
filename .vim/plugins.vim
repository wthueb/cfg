call plug#begin('~/.vim/bundle')

Plug 'dracula/vim', { 'as': 'dracula' } " dracula colorscheme

Plug 'elzr/vim-json' " json syntax
" {{{
let g:vim_json_syntax_conceal = 0 " show quotes
" }}}

Plug 'godlygeek/tabular' " aligning text; required for vim-markdown

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " fuzzy file finder
" {{{
nnoremap <C-p> :FZF<CR>
" }}}

Plug 'leafgarland/typescript-vim' " typescript syntax

Plug 'neoclide/coc.nvim', { 'branch': 'release' } " autocompletion and stuff
" {{{
" tab & shift-tab to cycle through completion options
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" ctrl-space to trigger completion
inoremap <silent><expr> <c-@> coc#refresh()

" <cr> to confirm completion
inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" move quickly between errors
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" navigate through errors quickly
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" show documentation with K
function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    else
        call CocAction('doHover')
    endif
endfunction
nnoremap <silent> K :call <SID>show_documentation()<CR>

" highlight symbol and references with cursor hovered
autocmd CursorHold * silent call CocActionAsync('highlight')

" rename symbol
nmap <leader>rn <Plug>(coc-rename)

" format selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
" }}}

Plug 'nvie/vim-flake8' " flake8!

Plug 'plasticboy/vim-markdown' " markdown syntax

Plug 'preservim/nerdcommenter' " better commenting

Plug 'rkitover/vimpager' " pager

Plug 'scrooloose/nerdtree' " file browser
" {{{
command NT NERDTree
" }}}

Plug 'tpope/vim-fugitive' " git

Plug 'tpope/vim-surround' " change quotes and stuff

Plug 'vim-python/python-syntax' " better python syntax
" {{{
let g:python_highlight_all = 1
" }}}

call plug#end()
