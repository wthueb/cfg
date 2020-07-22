call plug#begin('~/.vim/bundle')

" kiteco/vim-plugin is installed with kite engine

Plug 'dracula/vim', { 'as': 'dracula' } " dracula colorscheme
Plug 'elzr/vim-json' " json syntax
Plug 'godlygeek/tabular' " aligning text; required for vim-markdown
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " fuzzy file finder
Plug 'leafgarland/typescript-vim' " typescript syntax
Plug 'nvie/vim-flake8' " flake8!
Plug 'plasticboy/vim-markdown' " markdown syntax
Plug 'preservim/nerdcommenter' " better commenting
Plug 'rkitover/vimpager' " pager
Plug 'scrooloose/nerdtree' " file browser
Plug 'tpope/vim-fugitive' " git
Plug 'tpope/vim-surround' " change quotes and stuff
Plug 'Valloric/YouCompleteMe', { 'do': 'python3 install.py --clang-completer --ts-completer --java-completer' } " auto completion and syntax checking
Plug 'vim-python/python-syntax' " better python syntax

call plug#end()
