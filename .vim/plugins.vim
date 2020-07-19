set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'ctrlpvim/ctrlp.vim' " fuzzy file finder/opener
Plugin 'dracula/vim', {'name': 'dracula'} " dracula colorscheme
Plugin 'godlygeek/tabular' " aligning text, required for vim-markdown
Plugin 'leafgarland/typescript-vim' " typescript syntax files
Plugin 'nvie/vim-flake8' " flake8!
Plugin 'plasticboy/vim-markdown' " markdown!
Plugin 'preservim/nerdcommenter' " comment stuff
Plugin 'rkitover/vimpager' " pager
Plugin 'scrooloose/nerdtree' " file browser in a tab
Plugin 'tpope/vim-eunuch' " unix helper
Plugin 'tpope/vim-fugitive' " git
Plugin 'tpope/vim-surround' " change quotes and stuff
Plugin 'Valloric/YouCompleteMe' " auto completion and syntax checking
Plugin 'vim-scripts/a.vim' " switch to header file

call vundle#end()
