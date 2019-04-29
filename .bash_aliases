mkcdir()
{
    mkdir -p -- $@ && cd -P -- $@
}

mkcdirp()
{
    mkcdir $1 && virtualenv env
}

p()
{
    if [ -d 'env' ]; then
        env/bin/python3 $@
    else
        python3 $@
    fi
}

pi()
{
    if [ -d 'env' ]; then
        env/bin/python -i $@
    else
        python3 -i $@
    fi
}

alias dp="DEBUG=1 p"

cl()
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

alias junit='java -jar /usr/local/share/java/junit-platform-console-standalone-1.5.0-M1.jar -cp . --disable-banner --include-classname ".*" --scan-class-path --fail-if-no-tests'

alias activate='source env/bin/activate'

alias sqlite=sqlite3

alias ls='ls --color=auto --group-directories-first'
alias l='ls'
alias la='ls -a'
alias ll='ls -lh'
alias lla='ls -lah'
alias lal='lla'

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

alias ..='cd ..'
alias cd..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias mv='mv -v'
alias rm='rm -v'
alias cp='cp -v'

alias vi='vim'

alias grep='grep -In'
alias grepr='grep -RIn --exclude-dir=env'

alias python='python3'
alias python2="'python'"
alias pip='pip3'

alias refresh='echo "source ~/.bashrc" && source ~/.bashrc'

alias notify='tput bel'
