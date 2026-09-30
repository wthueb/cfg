source (if ('~/.config/nushell/nix/env.nu' | path exists) { '~/.config/nushell/nix/env.nu' } else { null })

use std "path add"
path add ~/.local/bin

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

source (if ('~/.config/nushell/env.custom.nu' | path exists) { '~/.config/nushell/env.custom.nu' } else { null })
