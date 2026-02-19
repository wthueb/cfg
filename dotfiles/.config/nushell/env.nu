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

$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
]

$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

#$env.PAGER = "nvim -R"
$env.MANPAGER = "nvim +Man!"

$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""

if $nu.os-info.family == "windows" {
    let autoload_path = ($nu.data-dir | path join 'vendor/autoload')
    mkdir $autoload_path

    starship init nu | save --force ($autoload_path | path join 'starship.nu')
    carapace _carapace nushell | save --force ($autoload_path | path join 'carapace.nu')
}

if not (which carapace | is-empty) {
    $env.CARAPACE_MATCH = "1"
}

source (if ('~/.config/nushell/env.custom.nu' | path exists) { '~/.config/nushell/env.custom.nu' } else { null })
