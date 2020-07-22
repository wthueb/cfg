#!/bin/bash

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if [[ $(which cmake) == '' ]]; then
    echo 'cmake not installed'
    exit
fi

if [[ $(which npm) == '' ]]; then
    echo 'npm not installed'
    exit
fi

vim +PlugInstall +qall

ln -s $HOME/.vim/bundle/vimpager/vimpager $HOME/.local/bin/
ln -s $HOME/.vim/bundle/vimpager/vimcat $HOME/.local/bin/
