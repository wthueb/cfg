export def "nix diff" [] {
    if (which nix | is-empty) {
        error make {msg: 'nix is not installed'}
        return 1
    }

    let generations = if ('/run/current-system' | path exists) {
        ls /nix/var/nix/profiles/system-*-link
        | get name
        | sort-by {$in | parse --regex 'system-(\d+)-link' | get capture0.0 | into int}
        | last 2
    } else {
        home-manager generations
        | lines
        | first 2
        | parse --regex '-> (\S*)' | get capture0
        | reverse
    }

    nix run nixpkgs#nvd diff ...$generations
}

export def "nix rebuild" [flake_path?: path] {
    let path = $flake_path | default ('~/.cfg' | path expand)

    if (which darwin-rebuild | is-not-empty) {
        sudo darwin-rebuild switch --flake $path
    } else if (which nixos-rebuild | is-not-empty) {
        sudo nixos-rebuild switch --flake $path
    } else if (which home-manager | is-not-empty) {
        home-manager switch --flake $path
    } else {
        error make {msg: 'no rebuild command found, not in nix environment?'}
        return 1
    }
    nix diff
}

export def "nix upgrade" [flake_path?: path] {
    let path = $flake_path | default ('~/.cfg' | path expand)

    nix flake update --flake $path
    nix rebuild $path
}
