call plug#begin('~/.vim/bundle')

" kiteco/vim-plugin is installed with kite engine

Plug 'dracula/vim', { 'as': 'dracula' } " dracula colorscheme
Plug 'elzr/vim-json' " json syntax
Plug 'godlygeek/tabular' " aligning text; required for vim-markdown
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin --completion --key-bindings --no-update-rc' } " fuzzy file finder
Plug 'leafgarland/typescript-vim' " typescript syntax
Plug 'neoclide/coc.nvim', { 'branch': 'release' } " autocompletion and stuff
Plug 'nvie/vim-flake8' " flake8!
Plug 'plasticboy/vim-markdown' " markdown syntax
Plug 'preservim/nerdcommenter' " better commenting
Plug 'rkitover/vimpager' " pager
Plug 'scrooloose/nerdtree' " file browser
Plug 'tpope/vim-fugitive' " git
Plug 'tpope/vim-surround' " change quotes and stuff
Plug 'vim-python/python-syntax' " better python syntax

call plug#end()
