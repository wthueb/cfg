#!/usr/bin/env nu

def rm-with-parents [path: string] {
    mut path = $path | path expand

    rm -v $path

    mut parent = $path | path parse | get parent

    while not ($parent | is-empty) and (ls $parent | is-empty) {
        rm -v $parent
        $parent = $parent | path parse | get parent
    }
}

def main [] {
    const dotfiles = path self | path dirname | path join 'dotfiles'

    let existing = (
        fd --type symlink --hidden . $nu.home-dir -E 'AppData'
        | lines
        | each --flatten { ls -l ($in | path expand --no-symlink) }
        | select name target
        | rename source target
        | where (try { $it.target | path relative-to $dotfiles } catch { null }) != null
    )

    let files = (
        fd --type file --hidden . $dotfiles
        | lines
        | each { path expand }
        | where ($it | path basename) not-in ['.gitignore' '.gitkeep']
        | wrap target
        | insert source {|f| $nu.home-dir | path join ($f.target | path relative-to $dotfiles) }
    )

    let to_remove = $existing | where $it not-in $files
    let to_create = $files | where $it not-in $existing

    for remove in $to_remove {
        rm-with-parents $remove.source
    }

    let removed_dirs = $to_remove | each { $in.source | path dirname } | uniq

    for dir in $removed_dirs {
        if (ls $dir | is-empty) {
            rm -v $dir
        }
    }

    for create in $to_create {
        let parent = $create.source | path dirname

        if ($parent | path type) != 'dir' {
            rm -vf $parent
            mkdir -v $parent
        }

        ln -sv $create.target $create.source
    }
}
