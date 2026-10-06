use session.nu [run-applescript refresh-sketchybar]

const SESSION_HELPER = path self session.nu

def session-lease [operation: string, token: string] {
    let directory = $env.AMPHETAMINE_STATE_DIR? | default ($env.HOME | path join Library Caches amphetamine-cli) | path expand
    mkdir $directory
    let permission = ^/bin/chmod 700 $directory | complete
    if $permission.exit_code != 0 {
        error make {msg: "Could not secure Amphetamine state directory" help: $permission.stderr}
    }
    let lock = $directory | path join session.lock
    let result = ^/usr/bin/lockf -k -t 30 $lock $nu.current-exe --no-config-file $SESSION_HELPER $operation $directory $token $nu.pid | complete
    if ($result.stderr | is-not-empty) {
        print --stderr --no-newline $result.stderr
    }
    if $result.exit_code != 0 {
        error make {
            msg: $'Amphetamine session ($operation) failed'
            help: ($result.stderr | str trim)
        }
    }
    $result.stdout | from json | ignore
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

# List Amphetamine commands, or keep the system awake while a closure runs.
# Concurrent and nested closures share an indefinite session across shells.
# Collect the closure's output and restore the original session after the last
# closure finishes, unless it expired or cannot be restored (a warning is printed).
# Timed restoration rounds remaining time up to minutes. Dead-process leases
# recover on subsequent calls; interrupted calls in a live shell may retain leases.
# Manual session changes during closures are not coordinated. AMPHETAMINE_STATE_DIR
# optionally overrides the shared state directory, including for isolated tests.
export def amphetamine [closure?: closure] {
    if $closure == null {
        return (help amphetamine)
    }

    let token = random uuid
    session-lease acquire $token

    let result = try {
        {value: (do --capture-errors $closure | collect) error: null}
    } catch {|err|
        {value: null error: $err}
    }

    let cleanup = try {
        session-lease release $token
        null
    } catch {|err| $err }

    if $result.error != null {
        if $cleanup != null {
            print --stderr $'Amphetamine cleanup failed: ($cleanup.msg). Recovery will be retried on the next call.'
        }
        error make $result.error
    }
    if $cleanup != null {
        error make $cleanup
    }
    $result.value
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
    run-applescript $command | ignore
    refresh-sketchybar

    if $closed_display {
        run-applescript "enable closed display mode" | ignore
    }

    amphetamine status
}

# End the current Amphetamine session.
export def "amphetamine stop" []: [nothing -> record] {
    run-applescript "end session" | ignore
    refresh-sketchybar

    amphetamine status
}
