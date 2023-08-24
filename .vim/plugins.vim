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

" status bar
Plug 'vim-airline/vim-airline'
let g:airline_theme = 'nord'

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

" hlsearch/incsearch for substitute
Plug 'osyo-manga/vim-over'

Plug 'sheerun/vim-polyglot'
let g:python_highlight_all = 1

call plug#end()
