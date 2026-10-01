def cmd-exists [cmd: string] {
    not (which $cmd | is-empty)
}

def "gh gist search" [] {
    let gists = (
        gh gist list
        | lines
        | parse --regex '(?P<id>\S+)\s*(?P<description>.*?)\s*(?P<files>\d+) files?\s*(?P<visibility>\w*)\s*(?P<updated>.*)'
        | into datetime updated
    )

    let input = (
        $gists
        | each {|row| echo $"($row.id): ($row.description)"}
        | to text --no-newline
    )

    let selection = $input | fzf

    if ($selection | is-empty) {
        return
    }

    let id = (
        $selection
        | parse '{id}: {description}'
        | get id.0
    )

    $id
}

def --wrapped mkcd [dir: path, ...rest] {
    mkdir ...$rest $dir ; cd $dir
}

def "vim upgrade" [] {
    nvim --headless "+Lazy! sync" +qa
    nvim --headless "+Lazy! clean" +qa
    nvim --headless "+MasonToolsUpdateSync" +qa
}

def confirm [prompt?: string] {
    print -n $'($prompt | default 'confirm?') [y/n]: '

    let input = (input -s --numchar 1)
    print $input

    return ($input == 'y')
}

def --wrapped pwatch [duration: duration, command: oneof<closure, string>, ...args] {
    loop {
        # clear first so if the command writes to stdout it's preserved
        clear --keep-scrollback

        let output = if ($command | describe) == "closure" {
            do $command
        } else {
            run-external $command ...$args
        }

        print $output
        sleep $duration
    }
}

def pkill [...args] {
    let processes = ps

    let selected = $processes | each {|p| $"($p.name) \(($p.pid)\)" } | to text | fzf

    if (confirm $"are you sure you want to kill ($selected)?") {
        let pid = $selected | parse --regex '.*\((\d+)\)' | get capture0.0 | into int

        kill ...$args $pid
    }
}

def atq [] {
    ^atq -o %s
    | lines
    | parse --regex '^(?<job>\d+)\s+(?<date>\d+)\s+(?<queue>\S+)\s+(?<user>\w+)'
    | update date {into datetime --format %s}
    | sort-by date
    | insert command {^at -c $in.job | lines | last}
}

# calculate the duration remaining until a given time of day
def until [
    time: string  # time of day in HH:MM or HH:MM:SS format
    --seconds (-s)  # output whole seconds instead of a duration
]: [nothing -> oneof<duration, int>] {
    let parts = $time | split row ':'

    if ($parts | length) not-in [2 3] {
        error make {
            msg: 'time must be in HH:MM or HH:MM:SS format'
        }
    }

    let hour = $parts.0 | into int
    let minute = $parts.1 | into int
    let second = if ($parts | length) == 3 {
        $parts.2 | into int
    } else {
        0
    }

    if $hour not-in 0..23 {
        error make { msg: 'hour must be between 0 and 23' }
    }

    if $minute not-in 0..59 {
        error make { msg: 'minute must be between 0 and 59' }
    }

    if $second not-in 0..59 {
        error make { msg: 'second must be between 0 and 59' }
    }

    let target = (
        ($hour * 1hr)
        + ($minute * 1min)
        + ($second * 1sec)
    )

    let now = date now

    let current = (
        (($now | format date '%H' | into int) * 1hr)
        + (($now | format date '%M' | into int) * 1min)
        + (($now | format date '%S' | into int) * 1sec)
    )

    let difference = $target - $current

    let remaining = if $difference <= 0sec {
        $difference + 1day
    } else {
        $difference
    }

    if $seconds {
        $remaining / 1sec | into int
    } else {
        $remaining
    }
}

use ../modules/alloy.nu *
use ../modules/docker.nu *
use ../modules/logfmt.nu *
use (if $nu.os-info.name in [macos linux] { '../modules/processes.nu' } else { null }) *
