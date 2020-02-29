#!/bin/bash

vim +PluginInstall +qall

if [[ $# == 0 ]]; then
    echo 'run with an argument to fully install youcompleteme'
else
    if [[ $(which cmake) == '' ]]; then
        echo 'cmake not installed'
        return
    fi

    if [[ $(which npm) == '' ]]; then
        echo 'npm not installed'
        return
    fi

    cd ~/.vim/bundle/YouCompleteMe/

    python3 install.py --clang-completer --ts-completer --java-completer
fi
