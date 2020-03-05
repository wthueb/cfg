# if not running interactively, don't do anything :)
[[ $- != *i* ]] && return

# append to the history file, don't overwrite it
shopt -s histappend

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

function _prompt_command()
{
    PS1=""

    local remove='\[\e[0m\]'
    local bold='\[\e[1m\]'

    local green='\[\e[38;5;119m\]'
    local magenta='\[\e[38;5;205m\]'
    local cyan='\[\e[38;5;117m\]'

    if [[ $VIRTUAL_ENV ]]; then
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
            PS1+="${cyan}${bold}`basename "$PWD"`${remove}"
        fi
    fi

    git rev-parse --git-dir &>/dev/null

    if [[ $? == 0 ]]; then
        local branch="$(git branch 2>/dev/null | 'grep' '^*' | colrm 1 2)"

        PS1+="@${bold}${magenta}$branch"

        if [[ $branch ]]; then
            if [ "$(git diff-index HEAD)" ] || [ "$(git ls-files --others --exclude-standard)" ]; then
                PS1+='+'
            fi
        else
            PS1+='+'
        fi

        PS1+="${remove}"
    fi

    if [[ $newline_prompt ]]; then
        PS1+='\n'
    fi

    PS1+='$ '
}

PROMPT_COMMAND=_prompt_command

[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases

[[ -f ~/.customrc ]] && source ~/.customrc
