PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"
PATH="/usr/local/opt/sqlite/bin:$PATH"

export PATH

if [ -f ~/.bashrc ]; then
	source ~/.bashrc
fi
