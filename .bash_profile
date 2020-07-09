[[ -f ~/.bash_options ]] && source ~/.bash_options

export CLICOLOR=1
export LSCOLORS=GxBxHxDxFxhxhxhxhxcxcx
export LS_COLORS='di=1;38;5;117:ln=1;31:so=1;37:pi=1;33:ex=1;35:bd=37:cd=37:su=37:sg=37:tw=32:ow=32'

# less syntax highlighting with source-highlight
export LESS=' -R '

# colored gcc warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

export LC_ALL='en_US.UTF-8'
export LANG='en_US.UTF-8'

# sort uppercase before lowercase with ls command
export LC_COLLATE='C'

export EDITOR=vim
export VISUAL=vim

export PAGER=vimpager

PATH="$HOME/.local/bin:$PATH"

[[ -f ~/.bashrc ]] && source ~/.bashrc

[[ -f ~/.customprofile ]] && source ~/.customprofile

config pull &> /dev/null

if [[ -f ~/.iterm2/it2check ]]; then
    PATH="/usr/bin:/bin:/usr/sbin:/sbin" ~/.iterm2/it2check

    [[ $? ]] && [[ -f ~/.iterm2_shell_integration.bash ]] && source ~/.iterm2_shell_integration.bash
fi
