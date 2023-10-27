Set-Alias cl clear

function .. { set-location .. }

Set-Alias l ls
function l { get-childitem $args }
function ll { get-childitem -l $args }

Set-Alias -Name cat -Value bat -Option AllScope
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

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

if (test-path $env:USERPROFILE\.config\powershell\custom.ps1) {
    . $env:USERPROFILE\.config\powershell\custom.ps1
}
