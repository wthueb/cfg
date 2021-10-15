[[ -f ~/.bash_options ]] && source ~/.bash_options

export CLICOLOR=1
export LSCOLORS=GxBxHxDxFxhxhxhxhxcxcx
export LS_COLORS='di=1;36:ln=1;31:so=1;37:pi=1;33:ex=1;35:bd=37:cd=37:su=37:sg=37:tw=32:ow=32'

export FZF_DEFAULT_OPTS='--color=dark,fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f
    --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7'

export BAT_THEME='Nord'

# colored gcc warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

export LANG='en_US.UTF-8'

# sort uppercase before lowercase with ls command
export LC_COLLATE='C'

export EDITOR=vim
export VISUAL=vim

export PAGER='less -RF'

if [[ -f /opt/homebrew/bin/brew ]]; then
    eval $(/opt/homebrew/bin/brew shellenv)

    PATH="$(brew --prefix)/bin:$(brew --prefix)/sbin:$PATH"
fi

PATH="$HOME/.local/bin:$PATH"

PYENV_ROOT="$HOME/.pyenv"

if [[ -d $PYENV_ROOT ]]; then
    PATH="$PYENV_ROOT/bin:$PATH"
    eval $(pyenv init --path)
fi

export PATH

[[ -f ~/.customprofile ]] && source ~/.customprofile

[[ -f ~/.bashrc ]] && source ~/.bashrc

if [[ -f ~/.iterm2/it2check ]]; then
    PATH="/usr/bin:/bin:/usr/sbin:/sbin" ~/.iterm2/it2check

    [[ $? ]] && [[ -f ~/.iterm2_shell_integration.bash ]] && source ~/.iterm2_shell_integration.bash
fi

[[ -f ~/.local/google-cloud-sdk/path.bash.inc ]] && source ~/.local/google-cloud-sdk/path.bash.inc
[[ -f ~/.local/google-cloud-sdk/completion.bash.inc ]] && source ~/.local/google-cloud-sdk/completion.bash.inc

# this is stupid but it's to set the last status to 0
true
