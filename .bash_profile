[[ -f ~/.bash_options ]] && source ~/.bash_options

# don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

export HISTSIZE=
export HISTFILESIZE=100000

export CLICOLOR=1
export LSCOLORS=GxBxHxDxFxhxhxhxhxcxcx
export LS_COLORS='di=1;38;5;117:ln=1;31:so=1;37:pi=1;33:ex=1;35:bd=37:cd=37:su=37:sg=37:tw=32:ow=32'

# less syntax highlighting with source-highlight
export LESS=' -R '

# colored gcc warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

export CC='gcc'
export CXX='g++'

export EDITOR=ex
export VISUAL=vim

export PATH="$HOME/.local/bin:$PATH"

[[ -f ~/.bashrc ]] && source ~/.bashrc

[[ -f ~/.customprofile ]] && source ~/.customprofile

refresh &> /dev/null

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
