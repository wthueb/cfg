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
        env/bin/python $@
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

#alias p='env/bin/python'
#alias pi='env/bin/python -i'

alias jc='echo compiling java files...;javac -d . *.java'

alias activate='source env/bin/activate'

alias sqlite=sqlite3

alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias lla='ls -la'
alias lal='lla'

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

alias ..="cd .."
alias cd..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias mv='mv -v'
alias rm='rm -v'
alias cp='cp -v'

alias vi=vim
