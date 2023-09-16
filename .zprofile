[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/code/scripts/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[[ -f $NVM_DIR/nvm.sh ]] && source $NVM_DIR/nvm.sh
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"

export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND='fd -H'

# nord theme https://github.com/ianchesal/nord-fzf
export FZF_DEFAULT_OPTS='--color=fg:#e5e9f0,bg:#2e3440,hl:#81a1c1 --color=fg+:#e5e9f0,bg+:#2e3440,hl+:#81a1c1 --color=info:#eacb8a,prompt:#bf6069,pointer:#b48dac --color=marker:#a3be8b,spinner:#b48dac,header:#a3be8b'
export FZF_CTRL_R_OPTS='--scheme=history'

export BAT_THEME='Nord'

# colored gcc warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

export LANG='en_US.UTF-8'

# sort uppercase before lowercase with ls command
#export LC_COLLATE='C'

export PAGER='less -RF'

PYENV_ROOT="$HOME/.pyenv"
if [[ -d $PYENV_ROOT ]]; then
    PATH="$PYENV_ROOT/bin:$PATH"
    eval $(pyenv init --path)
fi

if command -v rustup > /dev/null; then
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
