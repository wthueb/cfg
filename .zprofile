[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/code/scripts/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[[ -f $NVM_DIR/nvm.sh ]] && source $NVM_DIR/nvm.sh
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"

export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND='fd -H'

# nord theme https://www.nordtheme.com/docs/colors-and-palettes
# fg+ and bg+ are for current line
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS"
    --color=fg:#d8dee9,bg:#2e3440,hl:#b48ead
    --color=fg+:#d8dee9,bg+:#434c5e,hl+:#b48ead
    --color=info:#8fbcbb,prompt:#81a1c1,pointer:#88c0d0
    --color=marker:#bf616a,spinner:#ebcb8b,header:#a3be8c"
export FZF_CTRL_R_OPTS="--scheme=history"

export BAT_THEME='Nord'

# colored gcc warnings and errors
export GCC_COLORS="error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01"

export LANG="en_US.UTF-8"

# sort uppercase before lowercase with ls command
#export LC_COLLATE='C'

export PAGER="less -RF"

PYENV_ROOT="$HOME/.pyenv"
if [[ -d $PYENV_ROOT ]]; then
    # if pyenv folder exists but command isn't available, it's installed locally
    command -v pyenv &> /dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

if command -v rustup &> /dev/null; then
    rustup completions zsh > ~/.oh-my-zsh/completions/_rustup
    rustup completions zsh cargo > ~/.oh-my-zsh/completions/_cargo
fi

if command -v nvim &> /dev/null; then
    export EDITOR=nvim
    export VISUAL=nvim
else
    export EDITOR=vim
    export VISUAL=vim
fi

export PATH

[[ -f ~/.customprofile ]] && source ~/.customprofile
