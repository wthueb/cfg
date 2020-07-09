#!/bin/bash

vim +PluginInstall +qall

ln -s $HOME/.vim/bundle/vimpager/vimpager $HOME/.local/bin/
ln -s $HOME/.vim/bundle/vimpager/vimcat $HOME/.local/bin/

if [[ $# == 0 ]]; then
    echo 'run with an argument to fully install youcompleteme'
else
    if [[ $(which cmake) == '' ]]; then
        echo 'cmake not installed'
        exit
    fi

    if [[ $(which npm) == '' ]]; then
        echo 'npm not installed'
        exit
    fi

    cd ~/.vim/bundle/YouCompleteMe/

    python3 install.py --clang-completer --ts-completer --java-completer
fi
