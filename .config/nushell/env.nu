use std "path add"

source ($nu.default-config-dir | path join 'env.custom.nu')

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

mkdir ~/.cache
starship init nu | save -f ~/.cache/starship.nu
$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""

#source ($nu.default-config-dir | path join 'prompt.nu')
