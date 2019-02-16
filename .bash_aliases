alias ssh-laptop='echo "sshing into wil@laptop.wi1.xyz";ssh wil@laptop.wi1.xyz'
alias ssh-site='echo "sshing into wilhueb@wi1.xyz";ssh wilhueb@wi1.xyz'
alias ssh-ts='echo "sshing into wilhueb@ts.wi1.xyz";ssh wilhueb@ts.wi1.xyz'
alias ssh-remote='echo "sshing into whuebne1@harvey.cc.binghamton.edu";ssh whuebne1@harvey.cc.binghamton.edu'
alias ssh-funding='echo "sshing into ubuntu@63.32.64.21";ssh ubuntu@63.32.64.21'

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

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

alias ..="cd .."
alias cd..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias mv='mv -v'
alias rm='rm -v'
alias cp='cp -v'
