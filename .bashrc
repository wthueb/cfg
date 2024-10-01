# if not running interactively, don't do anything :)
[[ $- != *i* ]] && return

# append to the history file (helps when running multiple bash instances
shopt -s histappend

# don't put duplicate lines or lines starting with space in the history
#HISTCONTROL=ignoreboth

HISTSIZE=
HISTFILESIZE=100000000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS
shopt -s checkwinsize

# include dotfiles in globs
shopt -s dotglob

if [[ $(uname -r) == *microsoft* ]]; then
    OS='wsl'
elif [[ $(uname) == Darwin ]]; then
    OS='mac'
elif [[ $(uname) == Linux ]]; then
    OS='linux'
fi

REMOVE='\[\033[0m\]'

BRIGHTRED='\[\033[1;31m\]'
BRIGHTGREEN='\[\033[1;32m\]'
YELLOW='\[\033[0;33m\]'
#BRIGHTYELLOW='\[\033[1;33m\]'
#BLUE='\[\033[0;34m\]'
BRIGHTBLUE='\[\033[1;34m\]'
BRIGHTCYAN='\[\033[1;36m\]'

function _prompt_command()
{
    local status=$?

    PS1=""

    if [[ ${VIRTUAL_ENV} ]]; then
        PS1+="($(basename "$VIRTUAL_ENV")) "
    fi

    if [[ ${CONDA_PROMPT_MODIFIER} ]]; then
        PS1+="${CONDA_PROMPT_MODIFIER}"
    fi

    PS1+="${BRIGHTGREEN}\u${REMOVE}@${BRIGHTBLUE}\h${REMOVE}:"

    if [[ ${full_dir} ]]; then
        PS1+="${BRIGHTCYAN}\w${REMOVE}"
    else
        PS1+="${BRIGHTCYAN}\W${REMOVE}"
    fi

    if git rev-parse --git-dir &>/dev/null; then
        local branch
        branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"

        PS1+="@${YELLOW}${branch}"

        if [[ ${branch} ]]; then
            if [[ $(git diff-index HEAD 2>/dev/null) ]] || [[ $(git ls-files --others --exclude-standard) ]]; then
                PS1+='+'
            fi
        else
            PS1+='+' # there is no branch, waiting on first commit
        fi

        PS1+="${REMOVE}"
    fi

    if [[ ${status} != 0 ]]; then
        PS1+=" ${BRIGHTRED}${status}${REMOVE}"
    fi

    if [[ ${newline_prompt} ]]; then
        PS1+="\n"
    fi

    PS1+='$ '

    echo -ne "\033]0;${PWD##*/} - ${USER}@${HOSTNAME}\a"
}

PROMPT_COMMAND=_prompt_command

if command -v pyenv &> /dev/null; then
    eval "$(pyenv init -)"
fi

# shellcheck source=.bash_aliases
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases

# shellcheck source=.customrc
[[ -f ~/.customrc ]] && source ~/.customrc

if command -v fd &> /dev/null; then
    _fzf_compgen_path() {
        fd --hidden --follow --exclude ".git" . "$1"
    }

    _fzf_compgen_dir() {
        fd --type d --hidden --follow --exclude ".git" . "$1"
    }
fi

# (EXPERIMENTAL) Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
    local command=$1
    shift

    case "$command" in
        cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
        export|unset) fzf "$@" --preview "eval 'echo \$'{}" ;;
        ssh)          fzf "$@" --preview 'dig +short {}' ;;
        *)            fzf "$@" ;;
    esac
}

# shellcheck source=.fzf.bash
[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash

if command -v tmux-sessionizer &>/dev/null; then
    bind -x '"\C-f": tmux-sessionizer'
fi

export NVM_DIR=~/.nvm
[[ -f $NVM_DIR/nvm.sh ]] && source $NVM_DIR/nvm.sh
[[ -f $NVM_DIR/bash_completion ]] && source $NVM_DIR/bash_completion

if command -v ng &> /dev/null; then
    source <(ng completion script)
fi

if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

bind -f ~/.inputrc
