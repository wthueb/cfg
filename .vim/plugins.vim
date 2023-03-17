if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    augroup PlugInstall
        autocmd! VimEnter * PlugInstall
    augroup END
endif

call plug#begin('~/.vim/bundle')

" colorscheme
Plug 'arcticicestudio/nord-vim', { 'branch': 'main' }

" autocompletion
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
" {{{
let g:coc_node_path = trim(system('which node'))

let g:coc_global_extensions = [
    \ 'coc-clangd',
    \ 'coc-css',
    \ 'coc-html',
    \ 'coc-json',
    \ 'coc-prettier',
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

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
inoremap <silent><expr> <TAB>
        \ coc#pum#visible() ? coc#pum#confirm() :
        \ <SID>check_back_space() ? "\<tab>" :
        \ coc#refresh()

" formatting
nmap <leader>f <Plug>(coc-format)
vmap <leader>f <Plug>(coc-format-selected)

nmap <leader>s <Plug>(coc-rename)

nmap <leader>ac <Plug>(coc-codeaction)
nmap <leader>qf <Plug>(coc-fix-current)

nmap <silent> gq <Plug>(coc-diagnostic-prev)
nmap <silent> ge <Plug>(coc-diagnostic-next)

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" go to errors
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" apply code action
nmap <leader>a <Plug>(coc-codeaction-selected)

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

" status bar
Plug 'vim-airline/vim-airline'
" {{{
let g:airline_theme = 'nord'
" }}}

" fuzzy file finder
Plug 'junegunn/fzf'
" {{{
nmap <C-p> :FZF<CR>
" }}}

" better commenting
Plug 'preservim/nerdcommenter'
" {{{
" don't indent
let g:NERDDefaultAlign = 'none'

" space after delimiter
let g:NERDSpaceDelims = 1

" compact multi-line comments
let g:NERDCompactSexyComs = 0

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

" hlsearch/incsearch for substitute
Plug 'osyo-manga/vim-over'

" pcre regex
Plug 'othree/eregex.vim'
" {{{
let g:eregex_default_enable = 0
nnoremap <leader>/ :call eregex#toggle()<CR>
" }}}

Plug 'sheerun/vim-polyglot'
" {{{
let g:python_highlight_all = 1
" }}}

" }}}

call plug#end()
