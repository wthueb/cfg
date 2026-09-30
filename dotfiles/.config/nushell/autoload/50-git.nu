def "git restash" [entry?: string] {
    let base_dir = git rev-parse --show-toplevel
    enter $base_dir
    git stash show -p ($entry | default 'stash@{0}') | git apply --reverse
    dexit
}

def "git skip" [] {
    git status -s
    | lines
    | str substring 3..
    | each {|f| git update-index --skip-worktree $f ; $f}
}

def "git show-skipped" [] {
    git ls-files -v (git rev-parse --show-toplevel)
    | lines
    | where $it =~ '^S'
    | str substring 2..
}

def "git unskip" [branch?: string] {
    let files = git show-skipped

    git update-index --no-skip-worktree ...$files
}

