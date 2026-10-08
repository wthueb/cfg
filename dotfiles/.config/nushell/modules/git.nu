# List branches as a table with commit, upstream, and worktree details.
export def b [
    --all (-a) # Include remote-tracking branches
    --remotes (-r) # List only remote-tracking branches
] {
    let flags = if $all { [--all] } else if $remotes { [--remotes] } else { [] }
    let result = (^git --no-pager branch --no-color --format='%(HEAD)%00%(refname:short)%00%(objectname:short)%00%(upstream:short)%00%(upstream:track)%00%(subject)%00%(worktreepath)' ...$flags | complete)

    if $result.exit_code != 0 {
        error make {msg: ($result.stderr | str trim)}
    }

    $result.stdout
    | lines
    | split column (char nul) current branch commit upstream tracking subject worktree
    | update current {|row| $row.current == '*'}
    | insert gone {|row| $row.tracking == '[gone]'}
    | sort-by -r current # put current at top
}

export def restash [entry?: string] {
    let base_dir = ^git rev-parse --show-toplevel
    ^git -C $base_dir stash show -p ($entry | default 'stash@{0}') | ^git -C $base_dir apply --reverse
}

export def skip [] {
    ^git status -s
    | lines
    | str substring 3..
    | each {|f| ^git update-index --skip-worktree $f ; $f}
}

export def show-skipped [] {
    ^git ls-files -v (^git rev-parse --show-toplevel)
    | lines
    | where $it =~ '^S'
    | str substring 2..
}

export def unskip [branch?: string] {
    let files = show-skipped

    ^git update-index --no-skip-worktree ...$files
}
