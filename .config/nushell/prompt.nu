def left_prompt [] {
    let user = $nu.home-path | path basename
    let hostname = (sys).host.hostname
    let dir = $env.PWD | str replace $nu.home-path "~"

    # TODO: colors, git status, VIRTUAL_ENV

    mut prompt = $"(ansi green)($user)(ansi reset)@(ansi blue)($hostname)(ansi reset):(ansi cyan)($dir)"

    let current_branch = (git branch --show-current | complete).stdout | str trim

    if $current_branch != "" {
        $prompt += $"(ansi reset)@(ansi yellow)($current_branch)"

        if (git status -s) != "" {
            $prompt += "+"
        }
    }

    $prompt
}

def right_prompt [] {
    let time = date now | format date %I:%M:%S

    $"(ansi black_bold)($time)"
}

$env.PROMPT_COMMAND = { left_prompt }
$env.PROMPT_COMMAND_RIGHT = { right_prompt }
$env.PROMPT_INDICATOR = $"(ansi reset)\$ "
$env.PROMPT_INDICATOR_VI_NORMAL = $"(ansi reset)> "
$env.PROMPT_INDICATOR_VI_INSERT = $"(ansi reset)\$ "
$env.PROMPT_MULTILINE_INDICATOR = $"(ansi reset)::: "
