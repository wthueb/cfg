confirm()
{
    read -r -p "${1:-are you sure?} [y/n]: " response

    local response=${response,,} # to lower

    if [[ $response =~ ^(yes|y)$ ]]; then
        return 0
    fi

    return 1
}

mkcd()
{
    mkdir -p -- $@ && cd -P -- $@
}

mkcdp()
{
    mkcdir $1 && python -m venv env
}

alias virtualenv='python -m venv env'

pclean()
{
    confirm

    if [[ $? != 0 ]]; then
        return 1
    fi

    local count=$(find . -name '__pycache__' | wc -l | sed 's/ *//')

    if [[ $count > 0 ]]; then
        find . -name '__pycache__' -print0 | xargs -0 rm -r
    fi

    echo "deleted $count __pycache__ folders"

    count=$(find . -name '*.pyc' | wc -l | sed 's/ *//')

    find . -name '*.pyc' -delete

    echo "deleted $count *.pyc files"
}

retab()
{
    if [[ $# != 2 ]]; then
        echo "usage: retab FILE_NAME MAX_DEPTH (0 for MAX_DEPTH if unlimited)"

        return
    fi

    confirm

    if [[ $? != 0 ]]; then
        return 1
    fi

    if [[ $2 > 0 ]]; then
        find . -name "$1" -maxdepth $2 ! -type d -exec bash -c 'expand -t 4 "$0" > /tmp/e && mv /tmp/e "$0"' {} \;
    elif [[ $2 == 0 ]]; then
        find . -name "$1" ! -type d -exec bash -c 'expand -t 4 "$0" > /tmp/e && mv /tmp/e "$0"' {} \;
    else
        echo "usage: retab FILE_NAME MAX_DEPTH (0 for MAX_DEPTH if unlimited)"
    fi
}

_deactivate()
{
    conda deactivate

    unalias deactivate
}

activate()
{
    if [[ $* ]]; then
        conda activate $@

        alias deactivate=_deactivate
    else
        source env/bin/activate
    fi
}

path()
{
    if [[ $full_dir ]]; then
        unset full_dir
    else
        full_dir=1
    fi
}

alias ls='ls --color=auto --group-directories-first'
alias l='ls'
alias la='ls -a'
alias ll='ls -lh'
alias lla='ls -lah'
alias lal='lla'

alias cl='clear'

alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

refresh()
{
    echo "pulling https://github.com/wthueb/cfg"

    config pl

    echo "source ~/.bashrc"

    source ~/.bashrc
}

alias ..='cd ..'
alias cd..='cd ..'

alias mv='mv -v'
alias rm='rm -v'
alias cp='cp -v'

alias vi='vim'
alias vim-upgrade='vim +PluginInstall +PluginUpdate +PluginClean +q +q'

alias grep='grep -PI --color=auto'
alias grepr='grep -PIR --exclude-dir=env --color=auto'

alias p='python'
alias pi='python -i'
