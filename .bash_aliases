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

alias jc='echo compiling java files...;javac -d . *.java'

alias activate='source env/bin/activate'

alias sqlite=sqlite3

alias ls='ls --color=auto --group-directories-first'
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias lla='ls -la'
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
alias pip='pip3'

alias refresh='echo "source ~/.bashrc" && source ~/.bashrc'
