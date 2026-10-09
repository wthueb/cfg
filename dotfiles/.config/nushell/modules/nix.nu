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

def nixpkgs-api [endpoint: string, --fields: record = {}] {
    let arguments = $fields | items {|key, value| ['-f' $'($key)=($value)']} | flatten
    let response = (^gh api --method GET $endpoint ...$arguments | complete)
    if $response.exit_code != 0 {
        error make {msg: $'GitHub request failed for ($endpoint): ($response.stderr | str trim)'}
    }
    $response.stdout | from json
}

# Find an exact package version in a required nixpkgs channel's history.
# Requires authenticated gh and Nix with flakes enabled. Indexed commits locate
# package files; channel-specific file history handles cherry-picked updates.
# Searches are bounded and do not guarantee a match for every historical version.
export def "nix revision" [
    channel: string # Release channel, e.g. nixos-26.05 or nixpkgs-unstable
    package: string # Nixpkgs attribute, e.g. linux_6_18 or neovim-unwrapped
    version: string # Exact version to find
    --system (-s): string = 'x86_64-linux' # System used for evaluation
    --limit (-l): int = 20 # Search hits, history entries per file, and evaluations (1–100)
    --search-name: string # Commit-message package name if different from the attribute
] {
    for command in [gh nix] {
        if (which $command | is-empty) {
            error make {msg: $'Required command not found: ($command)'}
        }
    }

    if $limit < 1 or $limit > 100 {
        error make {msg: '--limit must be between 1 and 100'}
    }

    let branch = nixpkgs-api $'repos/NixOS/nixpkgs/branches/($channel | url encode)'
    let head = $branch.commit.sha
    let name = $search_name | default $package
    let query = $'repo:NixOS/nixpkgs "($name)" "($version)"'
    let results = nixpkgs-api search/commits --fields {
        q: $query
        sort: 'committer-date'
        order: 'desc'
        per_page: $limit
    }
    if ($results.items | is-empty) {
        error make {msg: $'No indexed commits matched ($name) and ($version); this does not prove the version never existed in ($channel).'}
    }

    let search_hits = $results.items
        | insert target {|commit|
            $commit.commit.message | lines | first | str ends-with $'-> ($version)'
        }
        | sort-by --reverse target

    mut searched_paths = []
    mut channel_commits = []
    for hit in $search_hits {
        let details = nixpkgs-api $'repos/NixOS/nixpkgs/commits/($hit.sha)'
        let paths = $details.files
            | each {|file| [$file.filename $file.previous_filename?]}
            | flatten
            | where {|path| $path != null}
            | uniq

        for path in $paths {
            if $path in $searched_paths {
                continue
            }
            $searched_paths = $searched_paths | append $path
            print --stderr $'Searching ($channel) history: ($path)'
            let history = nixpkgs-api repos/NixOS/nixpkgs/commits --fields {
                sha: $head
                path: $path
                per_page: $limit
            }
            let matching = $history | where {|commit|
                ($commit.commit.message | str contains $name) and ($commit.commit.message | str contains $version)
            }
            $channel_commits = $channel_commits | append $matching
        }
        if ($channel_commits | is-not-empty) {
            break
        }
    }

    let candidates = $channel_commits
        | uniq-by sha
        | insert target {|commit|
            $commit.commit.message | lines | first | str ends-with $'-> ($version)'
        }
        | sort-by --reverse target
        | first $limit

    for commit in $candidates {
        let flake = $'github:NixOS/nixpkgs/($commit.sha)'
        let attribute = $'($flake)#legacyPackages.($system).($package).version'
        print --stderr $'Checking ($commit.sha): ($commit.commit.message | lines | first)'
        let evaluated = (^nix eval --raw --no-write-lock-file $attribute | complete)

        if $evaluated.exit_code != 0 {
            print --stderr $'Evaluation failed: ($evaluated.stderr | str trim)'
            continue
        }

        let actual = $evaluated.stdout | str trim
        if $actual == $version {
            return {
                channel: $channel
                package: $package
                version: $actual
                revision: $commit.sha
                flake: $flake
                url: $commit.html_url
            }
        }
        print --stderr $'Skipping: evaluated version is ($actual)'
    }

    error make {msg: $'No verified match in ($channel) among ($candidates | length) candidates. Try a larger --limit or a different --search-name; the search is not exhaustive.'}
}

export def "nix upgrade" [flake_path?: path] {
    let path = $flake_path | default ('~/.cfg' | path expand)

    nix flake update --flake $path
    nix rebuild $path
}
