set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'dracula/vim', {'name': 'dracula'} " dracula colorscheme
Plugin 'godlygeek/tabular' " aligning text
Plugin 'leafgarland/typescript-vim' " typescript syntax files
Plugin 'nvie/vim-flake8' " flake8!
Plugin 'plasticboy/vim-markdown' " markdown!
Plugin 'preservim/nerdcommenter' " comment stuff
Plugin 'othree/eregex.vim' " regex everything
Plugin 'rkitover/vimpager' " pager
Plugin 'scrooloose/nerdtree' " file browser in a tab
Plugin 'tpope/vim-eunuch' " unix helper
Plugin 'tpope/vim-fugitive' " git
Plugin 'tpope/vim-surround' " change quotes and stuff
Plugin 'Valloric/YouCompleteMe' " auto completion and syntax checking
Plugin 'vim-scripts/a.vim' " switch to header file

call vundle#end()
