alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

alias ls='LC_COLLATE=C ls --color=auto --group-directories-first'
alias l='ls'
alias la='ls -a'
alias ll='ls -lh'
alias lla='ls -lha'
alias lal='lla'

alias cl='clear'

alias ..='cd ..'
alias cd..='cd ..'

alias mv='mv -v'
alias rm='rm -v'
alias cp='cp -v'

alias vi='vim'
alias vim-upgrade='vim +PluginInstall +PluginUpdate +PluginClean +q +q'

alias grep='grep -PI --color=auto'
alias grepr='grep -R --exclude-dir=env --exclude-dir=.git'

alias sed='sed -E'

alias p='python'
alias pi='p -i'

alias ffmpeg='ffmpeg -hide_banner'
alias ffplay='ffplay -hide_banner'

alias gdb='gdb -q'

function confirm()
{
    read -r -p "${1:-are you sure?} [y/n]: " response

    local response=${response,,} # to lower

    [[ $response =~ ^(yes|y)$ ]]
}

function mkcd()
{
    mkdir -p -- $@ && cd -P -- $@
}

function mkcdp()
{
    mkcd $1 && venv
}

function pclean()
{
    if ! confirm; then
        return 1
    fi

    local count=$(find . -name '__pycache__' 2>/dev/null | wc -l | sed 's/ *//')

    echo "found $count __pycache__ folders"

    if [[ $count > 0 ]]; then
        find . -name '__pycache__' -print0 2>/dev/null | xargs -0 rm -r

        echo "deleted $count __pycache__ folders"
    fi

    count=$(find . -name '*.pyc' 2>/dev/null | wc -l | sed 's/ *//')

    echo "found $count *.pyc files"

    if [[ $count > 0 ]]; then
        find . -name '*.pyc' -delete 2>/dev/null

        echo "deleted $count *.pyc files"
    fi
}

function retab()
{
    if [[ $# != 1 ]]; then
        echo 'usage: retab FILE'

        return 1
    fi

    if ! file $1 | grep text &>/dev/null; then
        return 1
    fi

    local perms=$(stat --format='%a' $1)

    expand -t 4 "$1" > /tmp/e && 'mv' /tmp/e "$1"

    chmod $perms $1

    return 0
}

export -f retab

function retabr()
{
    if [[ $# != 2 ]]; then
        echo 'usage: retabr DIRECTORY MAX_DEPTH (-1 for MAX_DEPTH if unlimited)'

        return 1
    fi

    if ! confirm; then
        return 1
    fi

    if [[ $2 > -1 ]]; then
        find $1 -maxdepth $2 -type f 2>/dev/null | grep -v .git/ | grep -v .vim/ | xargs -n1 -I{} bash -c 'retab "{}" && echo "{} has been retabbed"'
    elif [[ $2 == -1 ]]; then
        find $1 -type f 2>/dev/null | grep -v .git/ | grep -v .vim/ | xargs -n1 -I{} bash -c 'retab "{}" && echo "{} has been retabbed"'
    else
        echo 'usage: retabr DIRECTORY MAX_DEPTH (-1 for MAX_DEPTH if unlimited)'

        return 1
    fi

    return 0
}

function venv()
{
    if [[ $1 ]]; then
        python -m venv $1
    else
        python -m venv env
    fi

    activate
}

function activate()
{
    if [[ $1 ]]; then
        source $1/bin/activate
    else
        source env/bin/activate
    fi
}

function upgrade-requirements()
{
    if [[ $VIRTUAL_ENV ]]; then
        cat requirements.txt | 'grep' -PIo '.*(?===)' | xargs -t pip install --upgrade --

        pip freeze > requirements.txt
    else
        echo 'must be inside of a virtualenv'

        return 1
    fi
}

function path()
{
    if [[ ! -f ~/.bash_options ]]; then
        echo 'full_dir=' > ~/.bash_options
    fi

    if [[ $full_dir ]]; then
        unset full_dir

        sed -i 's/full_dir=.*/full_dir=/' ~/.bash_options
    else
        full_dir=1

        sed -i 's/full_dir=.*/full_dir=1/' ~/.bash_options
    fi
}

function growl()
{
    echo -e $'\e]9;'${*}'\007'
}
