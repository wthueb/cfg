def left_prompt [] {
    let user = $nu.home-path | path basename
    let hostname = (sys).host.hostname
    let dir = $env.PWD | path basename

    # TODO: colors, git status, VIRTUAL_ENV

    $"($user)@($hostname):($dir)"
}

def right_prompt [] {
    let time = date now | format date %I:%M:%S

    $"($time)"
}

$env.PROMPT_COMMAND = { left_prompt }
$env.PROMPT_COMMAND_RIGHT = { right_prompt }
$env.PROMPT_INDICATOR = "$ "
$env.PROMPT_INDICATOR_VI_NORMAL = "> "
$env.PROMPT_INDICATOR_VI_INSERT = "$ "
