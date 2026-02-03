Set-Alias cl clear

function .. { set-location .. }

Set-Alias l ls
function l { get-childitem $args }
function ll { get-childitem -l $args }

Set-Alias -Name cat -Value bat -Option AllScope
Set-Alias p python
Set-Alias vim nvim

Import-Module PSReadLine
Set-PSReadLineOption -EditMode vi
Set-PSReadLineOption -HistorySearchCursorMovesToEnd:$true
Set-PSReadLineKeyHandler -Key Tab -Function Complete

Import-Module gsudoModule

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Invoke-Expression (&starship init powershell)

if (test-path $env:USERPROFILE\.config\powershell\custom.ps1) {
    . $env:USERPROFILE\.config\powershell\custom.ps1
}
