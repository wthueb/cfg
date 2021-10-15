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

if [[ -f ~/.iterm2/it2check ]] && ~/.iterm2/it2check 2> /dev/null; then
    alias cl='echo -n -e "\e[2J\e[3J\e[1;1H"'
else
    alias cl='clear'
fi

alias log='journalctl --output=cat -u'
alias logf='journalctl --output=cat -fu'

alias vi='vim'

alias grep='grep -PI --color=auto'
alias grepr='grep -PIr --exclude-dir=env --exclude-dir=.git --color=auto'

alias pcre='pcre2grep --color'

alias trim="sed -E 's/^\s*//;s/\s*$//'"

alias p='python'
alias pi='p -i'

alias ffmpeg='ffmpeg -hide_banner'
alias ffplay='ffplay -hide_banner'

alias gdb='gdb -q'

if command -v fdfind &> /dev/null; then
    alias fd='fdfind'
fi

if command -v batcat &> /dev/null; then
    alias bat='batcat'
fi

if command -v bat &> /dev/null; then
    alias cat='bat'
fi

# $OS is set in .bashrc
case $OS in
    wsl)
        alias paste='powershell.exe Get-Clipboard'
        ;;
    mac)
        alias paste='pbpaste'
        ;;
    linux)
        alias paste='xclip -selection clipboard -o'
        ;;
    *)
        ;;
esac

function copy()
{
    local in=$(cat);

    # if we are using iterm
    if [[ -f ~/.iterm2/it2check ]] && ~/.iterm2/it2check 2> /dev/null; then
        echo "$in" | ~/.iterm2/it2copy
    else
        case $OS in
            wsl)
                echo "$in" | clip.exe
                ;;
            mac)
                echo "$in" | pbcopy
                ;;
            linux)
                echo "$in" | xclip -selection clipboard
                ;;
            *)
                echo error: cannot detect operating system
                ;;
        esac
    fi
}

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

    echo '> vim +CocUpdateSync +qa!'
    vim +CocUpdateSync +qa!
}
