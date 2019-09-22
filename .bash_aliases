mkcdir()
{
    mkdir -p -- $@ && cd -P -- $@
}

mkcdirp()
{
    mkcdir $1 && python -m venv env
}

alias virtualenv='python -m venv env'

clean()
{
    local count=$(find . -name '__pycache__' | wc -l | sed 's/ *//')

    find . -name '__pycache__' -delete

    echo "deleted $count __pycache__ folders"

    count=$(find . -name '*.pyc' | wc -l | sed 's/ *//')

    find . -name '*.pyc' -delete

    echo "deleted $count *.pyc files"
}

jc()
{
    if [ $# -eq 0 ]; then
        echo "compiling all .java files..."
        javac -d . -cp .:/usr/local/share/java/* *.java
    else
        javac -d . -cp .:/usr/local/share/java/* $@
    fi
}

jr()
{
    if [ $# -lt 1 ]; then
        echo "pass a java file to run"

        return 1
    fi

    if [[ $1 =~ .*\.class ]]; then
        java $(sed 's/\.class.*//g' <<< $1) ${@:2}
    else
        java $@
    fi
}

retab()
{
    if [ $# -ne 2 ]; then
        echo "usage: retab FILE_NAME MAX_DEPTH (0 for MAX_DEPTH if unlimited)"

        return
    fi

    if [ $2 -gt 0 ]; then
        find . -name "$1" -maxdepth $2 ! -type d -exec bash -c 'expand -t 4 "$0" > /tmp/e && mv /tmp/e "$0"' {} \;
    elif [ $2 -eq 0 ]; then
        find . -name "$1" ! -type d -exec bash -c 'expand -t 4 "$0" > /tmp/e && mv /tmp/e "$0"' {} \;
    else
        echo "usage: retab FILE_NAME MAX_DEPTH (0 for MAX_DEPTH if unlimited)"
    fi
}

__deactivate()
{
    conda deactivate

    unalias deactivate
}

activate()
{
    if [ -n "$*" ]; then
        conda activate $@

        alias deactivate=__deactivate
    else
        source env/bin/activate
    fi
}

alias junit='java -jar /usr/local/share/java/junit-platform-console-standalone-1.5.0-M1.jar -cp . --disable-banner --include-classname ".*" --scan-class-path --fail-if-no-tests'

alias sqlite=sqlite3

alias ls='ls --color=auto --group-directories-first'
alias l='ls'
alias la='ls -a'
alias ll='ls -lh'
alias lla='ls -lah'
alias lal='lla'

alias cl='clear'

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

refresh()
{
    echo "pulling https://github.com/wthueb/cfg"

    config pl

    echo "source ~/.bashrc"

    source ~/.bashrc
}

alias ..='cd ..'
alias cd..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias mv='mv -v'
alias rm='rm -v'
alias cp='cp -v'

alias vi='vim'
alias vim-upgrade='vim +PluginInstall +PluginUpdate +PluginClean +q +q'

alias grep='grep -PI --color=auto'
alias grepr='grep -PIR --exclude-dir=env --color=auto'

alias python='python3'
alias pip='pip3'

alias p='python'
alias pi='p -i'

alias notify='tput bel'

confirm()
{
    read -r -p "${1:-are you sure?} [y/n]: " response

    response=${response,,} # to lower

    if [[ "$response" =~ ^(yes|y)$ ]]; then
        return 0
    fi

    return 1
}
