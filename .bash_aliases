alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

alias ..='cd ..'
alias cd..='cd ..'

alias mv='mv -v'
alias cp='cp -v'
alias rm='rm -v'

alias ls='ls --color=auto --group-directories-first'

alias l='ls'
alias la='ls -a'
alias ll='ls -lh'
alias lla='ls -lha'
alias lal='ls -lha'

alias cl='clear'

alias vi='vim'

alias grep='grep -PI --color=auto'
alias grepr='grep -PIr --exclude-dir=env --exclude-dir=.git --color=auto'

alias p='python'
alias pi='p -i'

alias ffmpeg='ffmpeg -hide_banner'
alias ffplay='ffplay -hide_banner'

alias gdb='gdb -q'

if command -v bat &> /dev/null; then
    alias cat='bat'
fi

# $OS is set in .bashrc
case $OS in
    wsl)
        alias copy='clip.exe'
        alias paste='powershell.exe Get-Clipboard'
        ;;
    mac)
        alias copy='pbcopy'
        alias paste='pbpaste'
        ;;
    linux)
        alias copy='xclip -selection clipboard'
        alias paste='xclip -selection clipboard -o'
        ;;
    *)
        ;;
esac


function activate()
{
    if [[ $1 ]]; then
        source $1/bin/activate
    else
        source env/bin/activate
    fi
}

function calc()
{
    awk "BEGIN { print $* }"
}

function confirm()
{
    read -r -p "${1:-are you sure?} [y/n]: " response

    local response=${response,,} # to lower

    [[ $response =~ ^(yes|y)$ ]]
}

function growl()
{
    # for iterm
    echo -e $'\e]9;'${*}'\007'
}

function mkcd()
{
    mkdir -p -- $@ && cd -P -- $@
}

function newline-prompt()
{
    if [[ ! -f ~/.bash_options ]]; then
        echo 'full_dir=' > ~/.bash_options
        echo 'newline_prompt=' >> ~/.bash_options
    fi

    if [[ $newline_prompt ]]; then
        unset newline_prompt

        sed -i 's/newline_prompt=.*/newline_prompt=/' ~/.bash_options
    else
        newline_prompt=1

        sed -i 's/newline_prompt=.*/newline_prompt=1/' ~/.bash_options
    fi
}

function path()
{
    if [[ ! -f ~/.bash_options ]]; then
        echo 'full_dir=' > ~/.bash_options
        echo 'newline_prompt=' >> ~/.bash_options
    fi

    if [[ $full_dir ]]; then
        unset full_dir

        sed -i 's/full_dir=.*/full_dir=/' ~/.bash_options
    else
        full_dir=1

        sed -i 's/full_dir=.*/full_dir=1/' ~/.bash_options
    fi
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

function venv()
{
    if [[ $1 ]]; then
        python -m venv $1
    else
        python -m venv env
    fi

    activate $@
}

function vim-upgrade()
{
    # TODO: print vim-plug logs to stdout?

    echo '> vim +PlugUpgrade +qa!'
    vim +PlugUpgrade +qa!

    echo '> vim +PlugInstall +qa!'
    vim +PlugInstall +qa!

    echo '> vim +PlugUpdate +qa!'
    vim +PlugUpdate +qa!

    echo '> vim +PluginClean! +qa!'
    vim +PlugClean! +qa!
}
