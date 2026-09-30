alias .. = cd ..
alias cd.. = cd ..

alias l = ls
alias ll = ls -l
alias la = ls -a
alias lla = ls -la

alias vim = nvim
alias vi = nvim

alias mail = neomutt

alias ffmpeg = ffmpeg -hide_banner
alias ffprobe = ffprobe -hide_banner
alias ffplay = ffplay -hide_banner

alias icat = wezterm imgcat

alias cat = bat --paging=auto

alias fd = fd --hidden
alias rg = rg --hidden --smart-case

alias claude = claude --mcp-config ~/.agents/mcp.json

match $nu.os-info.name {
    macos => {
        alias copy = pbcopy
        alias paste = pbpaste
    },
    windows => {
        alias copy = clip.exe
        alias paste = powershell.exe Get-Clipboard
    },
}
