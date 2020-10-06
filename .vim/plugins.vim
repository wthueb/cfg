if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    augroup PlugInstall
        autocmd! VimEnter * PlugInstall
    augroup END
endif

call plug#begin('~/.vim/bundle')

Plug 'dracula/vim', { 'as': 'dracula' } " dracula colorscheme

Plug 'elzr/vim-json' " json syntax
" {{{
" don't hide quotes
let g:vim_json_syntax_conceal = 0
" }}}

Plug 'godlygeek/tabular' " aligning text; required for vim-markdown

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " fuzzy file finder
"" {{{
nnoremap <C-p> :FZF<CR>
"" }}}

Plug 'leafgarland/typescript-vim' " typescript syntax

Plug 'plasticboy/vim-markdown' " markdown syntax

Plug 'preservim/nerdcommenter' " better commenting

Plug 'scrooloose/nerdtree' " file browser
" {{{
abbrev nt NERDTree

" toggle using ,n
nnoremap <silent> <leader>n :NERDTreeToggle<CR>

" open to current file using ,v
nnoremap <silent> <leader>v :NERDTreeFind<CR>

" close when opening file
let NERDTreeQuitOnOpen = 1
"
" when you delete a file delete its buffer
let NERDTreeAutoDeleteBuffer = 1

" disable press ? for help
let NERDTreeMinimalUI = 1

" open when no command line arguments or stdin is passed
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" }}}

Plug 'tpope/vim-surround' " change quotes and stuff

Plug 'vim-python/python-syntax' " better python syntax
"" {{{
let g:python_highlight_all = 1
"" }}}

call plug#end()
