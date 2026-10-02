const APP = "Amphetamine"
const SDEF = "/Applications/Amphetamine.app/Contents/Resources/Amphetamine.sdef"

def run-applescript [command: string]: [nothing -> string] {
    let script = $'tell application "($APP)" to ($command)'
    let result = ^osascript -e $script | complete

    if $result.exit_code != 0 {
        error make {
            msg: ($result.stderr | str trim)
            help: $'AppleScript: ($script)'
        }
    }

    $result.stdout | str trim
}

def refresh-sketchybar []: [nothing -> nothing] {
    if (which sketchybar | is-not-empty) {
        try {
            ^sketchybar --trigger amphetamine_change | complete | ignore
        } catch { }
    }
}

def duration-to-minutes [value: duration]: [nothing -> int] {
    let ns = $value | into int
    let minute_ns = 60_000_000_000

    if $ns <= 0 {
        error make { msg: "duration must be greater than zero" }
    }

    let minutes = ($ns // $minute_ns) + (if ($ns mod $minute_ns) >= ($minute_ns // 2) { 1 } else { 0 })

    [$minutes 1] | math max
}

def display-sleep-allowed []: [nothing -> bool] {
    run-applescript "display sleep allowed" | into bool
}

# List Amphetamine commands.
export def amphetamine [] {
    help amphetamine
}

# Show a structured summary of Amphetamine's current state.
# Duration is the remaining countdown, not the session's original duration.
# Duration and until are null when no timed countdown is available.
export def "amphetamine status" []: [nothing -> record] {
    let is_active = run-applescript "session is active" | into bool
    let remaining = run-applescript "session time remaining" | into int
    let duration = if $is_active and $remaining > 0 { $remaining * 1sec } else { null }
    let until = if $duration == null { null } else { (date now) + $duration }
    let display_sleep = display-sleep-allowed
    let closed_display = run-applescript "closed display mode enabled" | into bool

    {
        active: $is_active
        duration: $duration
        until: $until
        display_sleep_allowed: $display_sleep
        closed_display_mode_enabled: $closed_display
    }
}

# Start an Amphetamine session.
#
# With no duration, the session is indefinite.
# Durations are rounded to the nearest minute, with ties rounded up and
# a minimum of one minute.
# Returns whether the session is active, its calculated end time, and its
# rounded duration. End time and duration are null for indefinite sessions.
# `--closed-display` explicitly enables Closed-Display Mode after starting
# the session. If omitted, the module does not change the existing
# Closed-Display Mode setting.
export def "amphetamine start" [
    duration?: duration
    --allow-display-sleep
    --prevent-display-sleep
    --closed-display
]: [nothing -> record] {
    if $allow_display_sleep and $prevent_display_sleep {
        error make {
            msg: "--allow-display-sleep and --prevent-display-sleep are mutually exclusive"
        }
    }

    let display_option = if $allow_display_sleep {
        "displaySleepAllowed:true"
    } else if $prevent_display_sleep {
        "displaySleepAllowed:false"
    } else {
        null
    }

    let minutes = if $duration == null { null } else { duration-to-minutes $duration }
    let rounded_duration = if $minutes == null { null } else { $minutes * 1min }

    let command = if $minutes == null {
        if $display_option == null {
            "start new session"
        } else {
            $'start new session with options {duration:0, interval:0, ($display_option)}'
        }
    } else {
        let options = if $display_option == null {
            let display_sleep = display-sleep-allowed
            $'duration:($minutes), interval:minutes, displaySleepAllowed:($display_sleep)'
        } else {
            $'duration:($minutes), interval:minutes, ($display_option)'
        }

        $'start new session with options {($options)}'
    }

    let started_at = date now
    let _ = run-applescript $command
    refresh-sketchybar

    if $closed_display {
        let _ = run-applescript "enable closed display mode"
    }

    amphetamine status
}

# End the current Amphetamine session.
export def "amphetamine stop" []: [nothing -> record] {
    let _ = run-applescript "end session"
    refresh-sketchybar

    amphetamine status
}
