set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" kiteco/vim-plugin is installed with kite engine

Plugin 'ctrlpvim/ctrlp.vim' " fuzzy file finder/opener
Plugin 'dracula/vim', {'name': 'dracula'} " dracula colorscheme
Plugin 'elzr/vim-json' " json syntax
Plugin 'godlygeek/tabular' " aligning text; required for vim-markdown
Plugin 'leafgarland/typescript-vim' " typescript syntax
Plugin 'nvie/vim-flake8' " flake8!
Plugin 'plasticboy/vim-markdown' " markdown syntax
Plugin 'preservim/nerdcommenter' " better commenting
Plugin 'rkitover/vimpager' " pager
Plugin 'scrooloose/nerdtree' " file browser
Plugin 'tpope/vim-fugitive' " git
Plugin 'tpope/vim-surround' " change quotes and stuff
Plugin 'Valloric/YouCompleteMe' " auto completion and syntax checking
Plugin 'vim-python/python-syntax' " better python syntax

call vundle#end()
