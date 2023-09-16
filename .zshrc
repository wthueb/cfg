export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

plugins+=(zsh-vi-mode)
ZVM_INIT_MODE=sourcing
ZVM_VI_INSERT_ESCAPE_BINDKEY=kj
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

source $ZSH/oh-my-zsh.sh

# default robbyrussel with user@hostname
PROMPT="%(!.%{%F{yellow}%}.)$USER@%{$fg[magenta]%}%M %(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ ) %{$fg[cyan]%}%c%{$reset_color%}"
PROMPT+=' $(git_prompt_info)'

[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

if command -v ng &> /dev/null; then
    source <(ng completion script)
fi

if command -v fzf &> /dev/null; then
    if command -v fd &> /dev/null; then
        _fzf_compgen_path() {
            fd --hidden --follow --exclude ".git" . "$1"
        }

        _fzf_compgen_dir() {
            fd --type d --hidden --follow --exclude ".git" . "$1"
        }
    fi

    _fzf_comprun() {
        local command=$1
        shift

        case "$command" in
            cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
            export|unset) fzf "$@" --preview "eval 'echo \$'{}" ;;
            ssh)          fzf "$@" --preview 'dig +short {}' ;;
            *)            fzf "$@" ;;
        esac
    }
fi

if command -v tmux-sessionizer &>/dev/null; then
    bindkey -s ^f "tmux-sessionizer\n"
fi

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

if command -v nvim &> /dev/null; then
    alias vi='nvim'
    alias vim='nvim'
else
    alias vi='vim'
fi

alias grep='grep -PI --color=auto'

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
    alias cat='bat --paging=auto'
fi

mkcd()
{
    mkdir -p -- $@ && cd -P -- $@
}

activate()
{
    if [[ $1 ]]; then
        source $1/bin/activate
    else
        source env/bin/activate
    fi
}

venv()
{
    if [[ $1 ]]; then
        python -m venv --upgrade-deps $1
    else
        python -m venv --upgrade-deps env
    fi

    activate $@
}

vim-upgrade()
{
    nvim --headless "+Lazy! sync" +qa
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

[[ -f ~/.customrc ]] && source ~/.customrc
