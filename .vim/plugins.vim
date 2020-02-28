set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'dracula/vim', {'name': 'dracula'} " dracula colorscheme
Plugin 'itchyny/lightline.vim' " status bar
Plugin 'nvie/vim-flake8' " flake8!
Plugin 'othree/eregex.vim' " regex everything
Plugin 'scrooloose/nerdtree' " file browser in a tab
Plugin 'tpope/vim-eunuch' " unix helper
Plugin 'tpope/vim-surround' " change quotes and stuff
Plugin 'Valloric/YouCompleteMe' " auto completion and syntax checking
Plugin 'vim-scripts/a.vim' " switch to header file

call vundle#end()
