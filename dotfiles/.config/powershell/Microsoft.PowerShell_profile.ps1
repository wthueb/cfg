function .. { set-location .. }

function l { get-childitem $args }
function ll { get-childitem -l $args }

Set-Alias -Name cat -Value bat -Option AllScope
Set-Alias p python
Set-Alias vim nvim
Set-Alias vi nvim

Import-Module PSReadLine
Set-PSReadLineOption -EditMode vi
Set-PSReadLineOption -HistorySearchCursorMovesToEnd:$true
Set-PSReadLineKeyHandler -Key Tab -Function Complete

if (Get-Module -ListAvailable -Name gsudoModule) {
  Import-Module gsudoModule
} elseif ($IsWindows) {
  Write-Host "warning: gsudoModule not found, install it :)" -ForegroundColor Yellow
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (&starship init powershell)
} else {
  Write-Host "warning: starship not found, install it :)" -ForegroundColor Yellow
}

if (Get-Command carapace -ErrorAction SilentlyContinue) {
  Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }
  Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
  carapace _carapace | Out-String | Invoke-Expression
} else {
  Write-Host "warning: carapace not found, install it :)" -ForegroundColor Yellow
}

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path $ChocolateyProfile) {
  Import-Module "$ChocolateyProfile"
}

$Custom = (Join-Path $PSScriptRoot "custom.ps1")
if (Test-Path $Custom) {
    . $Custom
}
