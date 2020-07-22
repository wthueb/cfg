#!/usr/bin/env bash

curl -fLso ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

setting="export YCM_ENABLE="

if [[ $YCM_ENABLE == "" ]]; then
    read -r -p "do you want to install youcompleteme completers? [y/n]: " response

    if [[ -f ~/.customprofile ]]; then
        echo >> ~/.customprofile
    fi

    if [[ ${response,,} =~ ^(yes|y)$ ]]; then
        setting="${setting}1"

        export YCM_ENABLE=1
    else
        setting="${setting}0"
    fi

    setting=$setting

    echo $setting >> ~/.customprofile
fi

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

if [[ ${setting: -1} != "=" ]]; then
    echo "added '$setting' to your ~/.customprofile"
    echo "you should probably source it"
fi

exit 0
