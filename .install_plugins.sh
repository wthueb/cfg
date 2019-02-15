#!/bin/bash

vim +PluginInstall +qall

cd $HOME/.vim/bundle/YouCompleteMe/

python3 install.py --clang-completer
