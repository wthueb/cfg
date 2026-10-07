source (if ('~/.config/nushell/nix/config.nu' | path exists) { '~/.config/nushell/nix/config.nu' } else { null })

use std "path add"
use std/dirs shells-aliases *

$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

$env.config.completions = {
    case_sensitive: false
    quick: true # auto accept if it's the only option
    partial: true
    algorithm: "prefix" # "prefix" or "fuzzy"
    external: { max_results: 100 }
    use_ls_colors: true
}

$env.config.render_right_prompt_on_last_line = false # true or false to enable or disable right prompt to be rendered on last line of the prompt.

$env.config.hooks = {
    pre_execution: [{ null }] # run before the repl input is run
    env_change: {
        PWD: [{|before, after| null }] # run if the PWD environment is different since the last repl input
    }
    display_output: "if (term size).columns >= 100 { table -e } else { table }" # run to display the output of a pipeline
    command_not_found: { null } # return an error message when a command is not found
}

$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

#$env.PAGER = "nvim -R"
$env.MANPAGER = "nvim +Man!"

$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""

if $nu.os-info.family == "windows" {
   let autoload_path = ($nu.data-dir | path join 'vendor/autoload')
   mkdir $autoload_path

   def --env regen-if-stale [bin: string, out: path, gen: closure] {
       let src = (which $bin | get -o 0.path)
       if $src == null { return }
       if (not ($out | path exists)) or ((ls -l $out | get 0.modified) < (ls -l $src | get 0.modified)) {
           do $gen | save --force $out
       }
   }

   regen-if-stale starship ($autoload_path | path join 'starship.nu') { starship init nu }
   regen-if-stale carapace ($autoload_path | path join 'carapace.nu') { carapace _carapace nushell }
}

if not (which carapace | is-empty) {
    $env.CARAPACE_MATCH = "1"
}

path add ~/.local/bin

const nix_installed = (
    ("/nix/var/nix/profiles/default/bin/nix" | path exists)
    or ("/run/current-system/sw/bin/nix" | path exists)
    or ("~/.nix-profile/bin/nix" | path expand | path exists))

use (if $nix_installed { "./modules/nix.nu" } else { null }) *

def "config update" [] {
    git -C ~/.cfg fetch

    let head = git -C ~/.cfg rev-parse HEAD

    if $head == (git -C ~/.cfg rev-parse @{u}) {
        print "configuration is already up to date"
        return
    }

    git -C ~/.cfg pull --rebase --autostash

    if $nu.os-info.family == "windows" or (not $nix_installed) {
        let diff = (
            git -C ~/.cfg diff $"($head)..HEAD" --name-only
            | lines
            | where { str starts-with "dotfiles" }
        )

        if ($diff | is-empty) {
            print "no changes to dotfiles"
            return
        }

        ~/.cfg/install.nu
    } else if (cmd-exists darwin-rebuild) or (cmd-exists nixos-rebuild) or (cmd-exists home-manager) {
        nix rebuild
    } else {
        print "don't know how to apply new configuration"
    }
}
