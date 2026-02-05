#!/usr/bin/env nu

let extra_links = {
    "~/AppData/Roaming/nushell": "~/.config/nushell",
    "~/AppData/Local/nvim": "~/.config/nvim",
    "~/Documents/Powershell": "~/.config/powershell",
};

def "path is-relative-to" [base: path] {
    try {
        $in | path relative-to $base
        true
    } catch {
        false
    }
}

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

    let extra_links = (
        $extra_links
        | transpose source target
        | update source { path expand --no-symlink }
        | update target { path expand --no-symlink }
    )

    let existing = (
        fd --type symlink --hidden . $nu.home-dir
        | lines
        | each { path expand --no-symlink }
        | where not ($extra_links.source | any {|e| $it | path is-relative-to $e })
        | wrap source
        | insert target { get source | path expand }
        | where ($it.target | path is-relative-to $dotfiles)
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

    for link in $extra_links {
        let parent = $link.source | path dirname

        if ($parent | path type) != 'dir' {
            rm -vf $parent
            mkdir -v $parent
        }

        if ($link.source | path exists) {
            if ($link.source | path expand) == $link.target {
                continue
            }
            rm -rv $link.source
        }

        ln -sv $link.target $link.source
    }
}
