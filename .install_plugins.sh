#!/bin/bash

vim +PluginInstall +qall

if [[ $# == 0 ]]; then
    echo 'run with an argument to fully install youcompleteme'
else
    cd ~/.vim/bundle/YouCompleteMe/

    python3 install.py --clang-completer --ts-completer --java-completer
fi
