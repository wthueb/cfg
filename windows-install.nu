#!/usr/bin/env nu

def main [] {
    const dotfiles = path self | path dirname | path join 'dotfiles'

    let existing = (
        fd --type symlink --hidden . $nu.home-dir
        | lines
        | each { path expand --no-symlink }
        | wrap source
        | insert target { $in.source | path expand }
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
        rm -v $remove.source
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
