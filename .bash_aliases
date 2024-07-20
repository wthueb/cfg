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

alias log='journalctl --output=cat -u'
alias logf='journalctl --output=cat -fu'

alias vi='vim'

if command -v nvim &> /dev/null; then
    alias vi='nvim'
    alias vim='nvim'
fi

alias grep='grep -PI --color=auto'
alias grepr='grep -PIr --exclude-dir=env --exclude-dir=.git --color=auto'

alias pcre='pcre2grep --color'

alias trim="sed -E 's/^\s*//;s/\s*$//'"

alias p='python'
alias pi='p -i'

alias ffmpeg='ffmpeg -hide_banner'
alias ffplay='ffplay -hide_banner'

alias gdb='gdb -q'

alias ggf='ggf --fg-empty=5'

if command -v fdfind &> /dev/null; then
    alias fd='fdfind'
fi

if command -v batcat &> /dev/null; then
    alias bat='batcat'
fi

if command -v bat &> /dev/null; then
    alias cat='bat --paging=auto'
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

copy()
{
    read "$in"

    # if we are using iterm
    if [[ -f ~/.iterm2/it2check ]] && ~/.iterm2/it2check 2> /dev/null; then
        echo -n "$in" | ~/.iterm2/it2copy
    else
        case $OS in
            wsl)
                echo -n "$in" | clip.exe
                ;;
            mac)
                echo -n "$in" | pbcopy
                ;;
            linux)
                echo -n "$in" | xclip -selection clipboard
                ;;
            *)
                echo error: cannot detect operating system
                ;;
        esac
    fi
}

calc()
{
    awk "BEGIN { print $* }"
}

confirm()
{
    read -r -p "${1:-are you sure?} [y/n]: " response

    local response=${response,,} # to lower

    [[ $response =~ ^(yes|y)$ ]]
}

mkcd()
{
    mkdir -p -- "$@" && cd -P -- "$@" || return
}

newline-prompt()
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

path()
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

activate()
{
    if [[ $1 ]]; then
        source "$1/bin/activate"
    else
        source env/bin/activate
    fi
}

venv()
{
    if [[ $1 ]]; then
        python -m venv --upgrade-deps "$1"
    else
        python -m venv --upgrade-deps env
    fi

    activate "$@"
}

vim-upgrade()
{
    nvim --headless "+Lazy! sync" +qa
    nvim --headless "+TSUpdateSync" +qa
    nvim --headless "+MasonToolsUpdateSync" +qa
}

addToPath() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH=$PATH:$1
    fi
}

addToPathFront() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH=$1:$PATH
    fi
}
