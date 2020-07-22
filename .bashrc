# if not running interactively, don't do anything :)
[[ $- != *i* ]] && return

# append to the history file (helps when running multiple bash instances
shopt -s histappend

# don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

HISTSIZE=
HISTFILESIZE=100000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS
shopt -s checkwinsize

# include dotfiles in globs
shopt -s dotglob

[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion
  fi
fi

REMOVE='\e[0m'

BRIGHTRED='\e[1;31m'
BRIGHTGREEN='\e[1;32m'
YELLOW='\e[0;33m'
BRIGHTYELLOW='\e[1;33m'
BRIGHTCYAN='\e[1;36m'

function _prompt_command()
{
    local status=$?

    PS1=""

    if [[ $VIRTUAL_ENV ]]; then
        PS1+="(`basename $VIRTUAL_ENV`) "
    fi

    if [[ $CONDA_PROMPT_MODIFIER ]]; then
        PS1+="$CONDA_PROMPT_MODIFIER"
    fi

    PS1+="$BRIGHTGREEN\u@\h$REMOVE:"
    
    if [[ $full_dir ]]; then
        PS1+="$BRIGHTCYAN\w$REMOVE"
    else
        if [[ $PWD == $HOME ]]; then
            PS1+="$BRIGHTCYAN~$REMOVE"
        else
            PS1+="$BRIGHTCYAN`basename "$PWD"`$REMOVE"
        fi
    fi

    git rev-parse --git-dir &>/dev/null

    if [[ $? == 0 ]]; then
        local branch="$(git rev-parse --abbrev-ref HEAD)"

        PS1+="@$YELLOW$branch"

        if [[ $branch ]]; then
            if [[ $(git diff-index HEAD) ]] || \
               [[ $(git ls-files --others --exclude-standard) ]]; then
                PS1+='+'
            fi
        else
            PS1+='+' # there is no branch, waiting on first commit
        fi

        PS1+="$REMOVE"
    fi

    if [[ $status != 0 ]]; then
        PS1+=" $BRIGHTRED$status$REMOVE"
    fi

    if [[ $newline_prompt ]]; then
        PS1+='\n'
    fi

    PS1+='$ '
}

PROMPT_COMMAND=_prompt_command

[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases

[[ -f ~/.customrc ]] && source ~/.customrc

[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash
