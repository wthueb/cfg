Set-Alias cl clear

function .. { set-location .. }

Set-Alias l ls
function l { get-childitem $args }
function ll { get-childitem -l $args }

Set-Alias -Name cat -Value bat -Option AllScope
Set-Alias p python
Set-Alias vim nvim

function config { git --git-dir=$HOME\.cfg --work-tree=$HOME $args }

function worktree {
    # hahahahahaha powershell sucks all of this sucks i hate this
    $branches = git branch --all --format='%(refname:short)' | foreach-object { $_ -replace "^origin/" } | select-object -unique

    $selectedBranch = $branches | fzf --height 40% --layout=reverse --prompt="branch> "

    if (-not $selectedBranch) {
        write-host "no branch selected"
        return
    }

    foreach ($tree in git worktree list) {
        $result = [regex]::matches($tree, "(?<dir>.+?)\s+(?<hash>\w+)\s+\[(?<branch>.+)\]")

        if ($selectedBranch -eq $result.groups[3].value) {
            set-location -path $result.groups[1].value
            return
        }
    }

    $dir = read-host "enter the directory name"
    if ((-not $dir) -or ($dir -contains "/") -or ($dir -contains "\\")) {
        write-host "invalid directory name"
        return
    }

    $baseDir = git rev-parse --git-dir | resolve-path

    while ((split-path -leaf $baseDir) -ne ".git") {
        $baseDir = split-path $baseDir -parent
    }

    $baseDir = split-path $baseDir -parent | split-path -parent

    $dir = join-path -path $baseDir -childpath $dir

    if (test-path -path $dir) {
        write-host "directory already exists, cding into it"
        set-location -path $dir
        return
    }

    git worktree add $dir $selectedBranch

    set-location -path $dir
}

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
