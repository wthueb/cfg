[[ -f ~/.bash_options ]] && source ~/.bash_options

# don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

export HISTSIZE=
export HISTFILESIZE=100000

export CLICOLOR=1
export LSCOLORS=GxBxHxDxFxhxhxhxhxcxcx
export LS_COLORS="di=1;36:ln=1;31:so=1;37:pi=1;33:ex=1;35:bd=37:cd=37:su=37:sg=37:tw=32:ow=32"

# less syntax highlighting with source-highlight
export LESS=" -R "

# colored gcc warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

export CC='gcc'
export CXX='g++'

export EDITOR=ex
export VISUAL=vim

_prompt_command() {
    PS1=""

    local remove="\[\e[0m\]"
    local bold="\[\e[1m\]"

    local green="\[\e[32m\]"
    local magenta="\[\e[35m\]"
    local cyan="\[\e[36m\]"

    if [[ "$VIRTUAL_ENV" ]]; then
        PS1+="($(basename $VIRTUAL_ENV)) "
    fi

    if [[ $CONDA_PROMPT_MODIFIER ]]; then
        PS1+="$CONDA_PROMPT_MODIFIER"
    fi

    PS1+="${green}${bold}\u@\h${remove}:"
    
    if [[ $full_dir ]]; then
        PS1+="${cyan}${bold}\w${remove}"
    else
        if [[ $PWD == $HOME ]]; then
            PS1+="${cyan}${bold}~${remove}"
        else
            PS1+="${cyan}${bold}$(basename "$PWD")${remove}"
        fi
    fi

    git rev-parse --git-dir &>/dev/null

    if [[ $? == 0 ]]; then
        local branch=$(git branch 2>/dev/null | 'grep' '^*' | colrm 1 2)

        PS1+="@${bold}${magenta}$branch"

        if [[ $branch ]]; then
            if [ "$(git diff-index HEAD)" ] || [ "$(git ls-files --others --exclude-standard)" ]; then
                PS1+="+"
            fi
        else
            PS1+="+"
        fi

        PS1+="${remove}"
    fi

    PS1+="\$ "
}

PROMPT_COMMAND=_prompt_command

[[ -f ~/.bashrc ]] && source ~/.bashrc

[[ -f ~/.customprofile ]] && source ~/.customprofile
