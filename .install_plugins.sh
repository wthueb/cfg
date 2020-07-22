#!/bin/bash

curl -fLso ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

read -r -p "do you want to install youcompleteme completers? [y/n]: " response

[[ ${response,,} =~ ^(yes|y)$ ]] && export YCM_ENABLE=1

if [[ $YCM_ENABLE ]]; then
    if [[ $(which cmake) == '' ]]; then
        echo 'cmake not installed'
        exit
    fi

    if [[ $(which npm) == '' ]]; then
        echo 'npm not installed'
        exit
    fi
fi

vim +PlugInstall +qall

ln -s $HOME/.vim/bundle/vimpager/vimpager $HOME/.local/bin/ 2>/dev/null
ln -s $HOME/.vim/bundle/vimpager/vimcat $HOME/.local/bin/ 2>/dev/null

[[ $YCM_ENABLE ]] && echo "add 'export YCM_ENABLE=1' to your .customprofile"

exit 0
