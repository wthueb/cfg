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

source (if ('~/.config/nushell/env.custom.nu' | path exists) { '~/.config/nushell/env.custom.nu' } else { null })
