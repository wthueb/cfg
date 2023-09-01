Set-Alias cl clear

function .. { cd .. }

Set-Alias l ls
function l { ls $args }
function ll { ls -l $args }

Set-Alias cat bat
Set-Alias p python
Set-Alias vim nvim

function config { git --git-dir=$HOME\.cfg --work-tree=$HOME $args }

Import-Module PSReadLine
Set-PSReadLineOption -EditMode vi
Set-PSReadLineOption -HistorySearchCursorMovesToEnd:$true
Set-PSReadLineKeyHandler -Key Tab -Function Complete

Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

Import-Module posh-git
