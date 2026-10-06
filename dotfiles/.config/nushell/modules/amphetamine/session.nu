const APP = "Amphetamine"

export def run-applescript [command: string]: [nothing -> string] {
    let script = $'with timeout of 10 seconds
        tell application "($APP)" to ($command)
    end timeout'
    let result = ^osascript -e $script | complete

    if $result.exit_code != 0 {
        error make {
            msg: ($result.stderr | str trim)
            help: $'AppleScript: ($script)'
        }
    }

    $result.stdout | str trim
}

export def refresh-sketchybar []: [nothing -> nothing] {
    if (which sketchybar | is-not-empty) {
        try {
            ^sketchybar --trigger amphetamine_change | complete | ignore
        } catch { }
    }
}

def process-identity [pid: int] {
    let result = with-env {LC_ALL: C} { ^/bin/ps -p ($pid | into string) -o lstart= | complete }
    if $result.exit_code == 1 {
        return null
    }
    if $result.exit_code != 0 {
        error make {msg: "Could not check Amphetamine lease owner" help: $result.stderr}
    }
    let identity = $result.stdout | str trim
    if ($identity | is-empty) { null } else { $identity }
}

def save-state [path: path, state: record] {
    let temporary = $'($path).(random uuid).tmp'
    try {
        $state | to json | save --raw $temporary
        let permission = ^/bin/chmod 600 $temporary | complete
        if $permission.exit_code != 0 {
            error make {msg: "Could not secure Amphetamine state" help: $permission.stderr}
        }
        mv --force $temporary $path
    } catch {|err|
        rm --force $temporary
        error make $err
    }
}

def valid-state [state: any]: nothing -> bool {
    try {
        let header = ($state.version | describe) == int and $state.version == 1 and ($state.phase in [starting active restoring])
        let snapshot = $state.snapshot
        let settings = ([
            $snapshot.display_sleep_allowed
            $snapshot.closed_display_mode_enabled
            $snapshot.screen_saver_allowed
        ] | all {|value| ($value | describe) == bool })
        let kind = ($snapshot.kind in [none indefinite timed unsupported]) and ($snapshot.remaining | describe) == int
        let expiration = if $snapshot.kind == timed {
            ($snapshot.until | into datetime | describe) == datetime
        } else {
            $snapshot.until == null
        }
        let leases = $state.leases | all {|lease|
            (($lease.token | describe) == string and ($lease.token | is-not-empty) and
                ($lease.pid | describe) == int and $lease.pid > 0 and
                ($lease.started | describe) == string and ($lease.started | is-not-empty))
        }
        let tokens = $state.leases | get token
        ($header and $settings and $kind and $expiration and $leases and
            (($tokens | uniq | length) == ($tokens | length)) and
            ((($state.leases | describe) starts-with "list") or (($state.leases | describe) starts-with "table")) and
            ($state.phase == active or ($state.leases | is-empty)))
    } catch {
        false
    }
}

def load-state [path: path] {
    if not ($path | path exists) {
        return null
    }
    let state = try { open --raw $path | from json } catch { null }
    if not (valid-state $state) {
        error make {
            msg: "Invalid or unsupported Amphetamine state"
            help: $'Inspect ($path); do not remove it while closures are running. It may contain the original session snapshot.'
        }
    }
    $state
}

def snapshot-session []: nothing -> record {
    let active = run-applescript "session is active" | into bool
    let remaining = run-applescript "session time remaining" | into int
    let measured_at = date now
    let kind = if not $active or $remaining == -3 {
        "none"
    } else if $remaining > 0 {
        "timed"
    } else if $remaining == 0 {
        "indefinite"
    } else {
        "unsupported"
    }

    {
        kind: $kind
        remaining: $remaining
        until: (if $kind == timed { ($measured_at + ($remaining * 1sec)) | into string } else { null })
        display_sleep_allowed: (run-applescript "display sleep allowed" | into bool)
        closed_display_mode_enabled: (run-applescript "closed display mode enabled" | into bool)
        screen_saver_allowed: (run-applescript "screen saver allowed" | into bool)
    }
}

def start-session [minutes: int, snapshot: record] {
    let interval = if $minutes == 0 { "0" } else { "minutes" }
    run-applescript $'start new session with options {duration:($minutes), interval:($interval), displaySleepAllowed:($snapshot.display_sleep_allowed)}' | ignore
    refresh-sketchybar
    run-applescript (if $snapshot.closed_display_mode_enabled { "enable closed display mode" } else { "disable closed display mode" }) | ignore
    run-applescript (if $snapshot.screen_saver_allowed { "allow screen saver" } else { "prevent screen saver" }) | ignore
}

def finalize-session [path: path, state: record] {
    let restoring = $state | update phase restoring | update leases []
    save-state $path $restoring
    let snapshot = $restoring.snapshot
    let remaining = if $snapshot.kind == timed {
        ($snapshot.until | into datetime) - (date now)
    } else {
        0sec
    }

    if $snapshot.kind == indefinite {
        start-session 0 $snapshot
    } else if $snapshot.kind == timed and $remaining > 0sec {
        let ns = $remaining | into int
        let minutes = ($ns + 59_999_999_999) // 60_000_000_000
        start-session $minutes $snapshot
    } else {
        run-applescript "end session" | ignore
        refresh-sketchybar
    }
    rm $path
}

# Internal entry point; callers must hold the shared lock for this entire operation.
def main [operation: string, directory: path, token: string, owner_pid: int] {
    if $operation not-in [acquire release] {
        error make {msg: "Unknown Amphetamine lease operation"}
    }
    let path = $directory | path join state.json
    let loaded = load-state $path
    let state = if $loaded == null {
        null
    } else {
        let live = $loaded.leases | where {|lease| (process-identity $lease.pid) == $lease.started }
        let pruned = $loaded | update leases $live
        if $pruned.phase != active or ($live | is-empty) {
            finalize-session $path $pruned
            null
        } else {
            save-state $path $pruned
            $pruned
        }
    }

    if $operation == release {
        if $state != null {
            let remaining = $state.leases | where token != $token
            let released = $state | update leases $remaining
            if ($remaining | is-empty) {
                finalize-session $path $released
            } else {
                save-state $path $released
            }
        }
        {token: $token} | to json --raw
        return
    }

    let started = process-identity $owner_pid
    if $started == null {
        error make {msg: "Amphetamine closure owner no longer exists"}
    }
    let lease = {token: $token pid: $owner_pid started: $started}
    if $state != null {
        if ($state.leases | any {|existing| $existing.token == $token }) {
            error make {msg: "Duplicate Amphetamine lease token"}
        }
        save-state $path ($state | update leases {|current| $current.leases | append $lease })
    } else {
        let snapshot = snapshot-session
        let starting = {version: 1 phase: starting snapshot: $snapshot leases: []}
        save-state $path $starting
        if $snapshot.kind == unsupported {
            print --stderr "Warning: the existing Amphetamine session cannot be restored; it will not be restored after all closures finish."
        }
        try {
            start-session 0 $snapshot
            save-state $path ($starting | update phase active | update leases [$lease])
        } catch {|err|
            try {
                finalize-session $path $starting
            } catch {|cleanup|
                print --stderr $'Amphetamine rollback failed: ($cleanup.msg). Recovery will be retried on the next call.'
            }
            error make $err
        }
    }
    {token: $token} | to json --raw
}
