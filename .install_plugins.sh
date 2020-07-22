#!/usr/bin/env bash

# install vim-plug
curl -fLso ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall

ln -s $HOME/.vim/bundle/vimpager/vimpager $HOME/.local/bin/ 2>/dev/null
ln -s $HOME/.vim/bundle/vimpager/vimcat $HOME/.local/bin/ 2>/dev/null

if [[ $(which npm) == '' ]]; then
    echo 'npm not installed'
    echo 'needed for coc completion'
    exit 1
fi

cd ~/.config/coc/extensions/

npm install

exit 0
