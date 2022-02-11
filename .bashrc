# if not running interactively, don't do anything :)
[[ $- != *i* ]] && return

# append to the history file (helps when running multiple bash instances
shopt -s histappend

# don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

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

REMOVE="\[\e[0m\]"

BRIGHTRED="\[\e[1;31m\]"
BRIGHTGREEN="\[\e[1;32m\]"
YELLOW="\[\e[0;33m\]"
BRIGHTYELLOW="\[\e[1;33m\]"
BLUE="\[\e[0;34m\]"
BRIGHTBLUE="\[\e[1;34m\]"
BRIGHTCYAN="\[\e[1;36m\]"

function update_title()
{
    echo -ne "\e]0;${BASH_COMMAND} - ${PWD##*/} - ${USER}@${HOSTNAME}\a"
}

trap update_title DEBUG

function _prompt_command()
{
    local status=$?

    PS1=""

    if [[ ${VIRTUAL_ENV} ]]; then
        PS1+="($(basename ${VIRTUAL_ENV})) "
    fi

    if [[ ${CONDA_PROMPT_MODIFIER} ]]; then
        PS1+="${CONDA_PROMPT_MODIFIER}"
    fi

    PS1+="${BRIGHTGREEN}\u${REMOVE}@${BRIGHTBLUE}\h${REMOVE}:"

    if [[ ${full_dir} ]]; then
        PS1+="${BRIGHTCYAN}\w${REMOVE}"
    else
        if [[ ${PWD} == ${HOME} ]]; then
            PS1+="${BRIGHTCYAN}~${REMOVE}"
        else
            PS1+="${BRIGHTCYAN}$(basename "${PWD}")${REMOVE}"
        fi
    fi

    git rev-parse --git-dir &>/dev/null

    if [[ $? == 0 ]]; then
        local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"

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

    echo -ne "\e]0;${PWD##*/} - ${USER}@${HOSTNAME}\a"
}

PROMPT_COMMAND=_prompt_command

if command -v pyenv &> /dev/null; then
    eval "$(pyenv init -)"
fi

[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases

[[ -f ~/.customrc ]] && source ~/.customrc

if command -v fd &> /dev/null; then
    # Use fd (https://github.com/sharkdp/fd) instead of the default find
    # command for listing path candidates.
    # - The first argument to the function ($1) is the base path to start traversal
    # - See the source code (completion.{bash,zsh}) for the details.
    _fzf_compgen_path() {
        fd --hidden --follow --exclude ".git" . "$1"
    }

    # Use fd to generate the list for directory completion
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

[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash

export NVM_DIR=~/.nvm
[[ -f $NVM_DIR/nvm.sh ]] && source $NVM_DIR/nvm.sh
[[ -f $NVM_DIR/bash_completion ]] && source $NVM_DIR/bash_completion

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
