#!/bin/bash

vim +PluginInstall +qall

if [ $# -eq 0 ]; then
    echo 'run with an argument to fully install youcompleteme'
else
    cd $HOME/.vim/bundle/YouCompleteMe/
    python3 install.py --clang-completer
fi
