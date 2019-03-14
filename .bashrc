case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

HISTSIZE=
HISTFILESIZE=100000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS
shopt -s checkwinsize

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
export LS_COLORS="di=36:ln=1;31:so=37:pi=1;33:ex=35:bd=37:cd=37:su=37:sg=37:tw=32:ow=32"

PROMPT_COMMAND=__prompt_command

__prompt_command() {
    PS1=""

    local remove="\[\e[0m\]"
    local bold="\[\e[1m\]"

    local green="\[\e[32m\]"
    local magenta="\[\e[35m\]"
    local cyan="\[\e[36m\]"

    if test -n "$VIRTUAL_ENV"; then
        PS1+="($(basename $VIRTUAL_ENV)) "
    fi

    PS1+="${green}${bold}\u@\h${remove}:${cyan}${bold}\w${remove}"

    if [ "$(git rev-parse --git-dir 2>/dev/null)" ]; then
        PS1+=":${magenta}$(git branch 2>/dev/null | 'grep' '^*' | colrm 1 2)"

        if [ "$(git diff-index HEAD)" ]; then
            PS1+="+"
        fi

        PS1+="${remove}"
    fi

    PS1+="\$ "
}

# enable color support of ls
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored gcc warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

if [ -f ~/.customrc ]; then
    source ~/.customrc
fi

export EDITOR=ex
export VISUAL=vim

PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
  fi
fi
