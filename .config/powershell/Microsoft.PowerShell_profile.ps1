function .. { cd .. }
Set-Alias l ls
function l { ls $args }
function ll { ls -l $args }

Set-Alias vim nvim

Import-Module PSReadLine
Set-PSReadLineOption -EditMode vi
Set-PSReadLineKeyHandler -Key Tab -Function Complete

Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
