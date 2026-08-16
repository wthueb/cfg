def alloy-config-blocks [config: string] {
    mut blocks = []
    mut buffer = ""
    mut depth = 0
    mut quote = ""
    mut escaped = false
    mut line_comment = false
    mut block_comment = false
    mut block_kind = ""
    mut block_name = ""
    let chars = $config | split chars

    for item in ($chars | enumerate) {
        let char = $item.item
        let next = $chars | get -o ($item.index + 1) | default ""
        $buffer = $buffer + $char

        if $line_comment {
            if $char == "\n" {
                $line_comment = false
            }
            continue
        }

        if $block_comment {
            if $char == "*" and $next == "/" {
                $block_comment = false
            }
            continue
        }

        if $quote == '"' {
            if $escaped {
                $escaped = false
            } else if $char == "\\" {
                $escaped = true
            } else if $char == '"' {
                $quote = ""
            }
            continue
        }

        if $quote == "`" {
            if $char == "`" {
                $quote = ""
            }
            continue
        }

        if $char == "/" and $next == "/" {
            $line_comment = true
            continue
        }

        if $char == "/" and $next == "*" {
            $block_comment = true
            continue
        }

        if $char == '"' or $char == "`" {
            $quote = $char
            continue
        }

        if $char == "{" {
            if $depth == 0 {
                let header = (
                    $buffer
                    | str substring --grapheme-clusters 0..-2
                    | parse --regex '(?s)(?<kind>[A-Za-z_][A-Za-z0-9_.]*)\s*(?:"(?<name>[^"]*)")?\s*$'
                    | first
                )
                $block_kind = $header.kind
                $block_name = $header.name? | default ""
            }
            $depth = $depth + 1
        } else if $char == "}" {
            $depth = $depth - 1
            if $depth == 0 {
                $blocks = $blocks | append {
                    kind: $block_kind
                    name: $block_name
                    text: $buffer
                }
                $buffer = ""
                $block_kind = ""
                $block_name = ""
            }
        }
    }

    if ($buffer | str trim | is-not-empty) {
        $blocks = $blocks | append {kind: "", name: "", text: $buffer}
    }

    $blocks
}

def alloy-forward-receivers [block: string] {
    $block
    | parse --regex '(?s)forward_to\s*=\s*\[(?<receivers>[^\]]*)\]'
    | get -o receivers.0
    | default ""
    | split row ","
    | str trim
    | where { is-not-empty }
}

def alloy-block-parts [block: string] {
    $block
    | parse --regex '(?s)^(?<header>.*?\{)(?<body>.*)(?<footer>\}\s*)$'
    | first
}

def alloy-log-sources [blocks: list<any>] {
    mut sources = []
    for block in $blocks {
        if ($block.kind | str starts-with "loki.source.") {
            $sources = $sources | append {
                kind: $block.kind
                name: $block.name
                scope: ""
                text: $block.text
            }
        } else if $block.kind == "declare" {
            let parts = alloy-block-parts $block.text
            for nested in (alloy-config-blocks $parts.body) {
                if ($nested.kind | str starts-with "loki.source.") {
                    $sources = $sources | append {
                        kind: $nested.kind
                        name: $nested.name
                        scope: $block.name
                        text: $nested.text
                    }
                }
            }
        }
    }
    $sources
}

def alloy-source-description [source: record] {
    if ($source.scope | is-empty) {
        $source.name + " (" + $source.kind + ")"
    } else {
        $source.name + " (" + $source.kind + " in declare " + $source.scope + ")"
    }
}

def alloy-test-source [source: record, path_literal: string] {
    let receivers = alloy-forward-receivers $source.text
    if ($receivers | is-empty) {
        error make $"($source.kind).($source.name) has no forward_to receivers"
    }
    let receiver_list = $receivers | str join ", "
    $'
loki.source.file "alloy_test_input" {
    targets = [{ __path__ = ($path_literal) }]
    forward_to = [($receiver_list)]
    tail_from_end = false
}
'
}

def alloy-test-declaration [block: record, source: record, path_literal: string] {
    let parts = alloy-block-parts $block.text
    mut body = []
    for nested in (alloy-config-blocks $parts.body) {
        let is_source = $nested.kind | str starts-with "loki.source."
        let is_input_dependency = ($nested.kind | str starts-with "discovery.") or $nested.kind == "local.file_match"
        if $is_source {
            if $source.scope == $block.name and $nested.kind == $source.kind and $nested.name == $source.name {
                $body = $body | append (alloy-test-source $source $path_literal)
            }
        } else if not $is_input_dependency {
            $body = $body | append $nested.text
        }
    }
    $"($parts.header)($body | str join '')($parts.footer)"
}

def alloy-test-config [config: string, log_path: path, source_name?: string] {
    let blocks = alloy-config-blocks $config
    let sources = alloy-log-sources $blocks
    let available = (
        $sources
        | each {|source| alloy-source-description $source }
        | str join ", "
    )
    let source = if $source_name == null {
        if ($sources | length) == 1 {
            $sources | first
        } else if ($sources | is-empty) {
            error make "the Alloy config has no loki.source components"
        } else {
            let selected = $sources | input list --display {|item| alloy-source-description $item } "Select a loki.source"
            if $selected == null {
                error make "no loki.source selected"
            }
            $selected
        }
    } else {
        let matches = $sources | where name == $source_name
        if ($matches | is-empty) {
            error make $"loki.source ($source_name) was not found; available sources: ($available)"
        } else if ($matches | length) > 1 {
            error make $"loki.source name ($source_name) is ambiguous: ($available)"
        } else {
            $matches | first
        }
    }
    let path_literal = $log_path | into string | to json
    mut write_names = []
    mut kept = []
    mut source_block = ""

    for block in $blocks {
        let is_source = $block.kind | str starts-with "loki.source."
        let is_input_dependency = ($block.kind | str starts-with "discovery.") or $block.kind == "local.file_match"

        if $is_source {
            if ($source.scope | is-empty) and $block.kind == $source.kind and $block.name == $source.name {
                $source_block = alloy-test-source $source $path_literal
            }
        } else if $is_input_dependency {
            continue
        } else if $block.kind == "loki.write" {
            if ($block.name | is-not-empty) {
                $write_names = $write_names | append $block.name | uniq
            }
        } else if $block.kind == "declare" {
            $kept = $kept | append (alloy-test-declaration $block $source $path_literal)
        } else {
            $kept = $kept | append $block.text
        }
    }

    if ($write_names | is-empty) {
        error make "the Alloy config has no loki.write sink to capture"
    }

    mut body = $kept | str join ""
    for name in $write_names {
        $body = $body | str replace --all --regex $"\\bloki\\.write\\.($name)\\b" $"loki.echo.($name)"
    }

    let echoes = $write_names | each {|name| $'loki.echo "($name)" {}' } | str join "\n"

    $"($source_block)\n($body | str trim)\n\n($echoes)\n"
}

def alloy-label-record [labels: string] {
    $labels
    | parse --regex '(?<name>[A-Za-z_][A-Za-z0-9_]*)=(?<value>"(?:[^"\\]|\\.)*")'
    | where name != "filename"
    | reduce --fold {} {|label, record|
        $record | upsert $label.name ($label.value | from json)
    }
}

def alloy-echo-entry [line: string] {
    let parsed = (
        $line
        | parse --regex 'entry=(?<entry>"(?:[^"\\]|\\.)*").* labels=(?<labels>"(?:[^"\\]|\\.)*")'
        | first
    )
    let labels = $parsed.labels | from json
    {
        entry: ($parsed.entry | from json)
        labels: (alloy-label-record $labels)
    }
}

def alloy-test-finalize [summary: record, work_dir: path, keep: bool] {
    if $summary.entries == 0 {
        let detail = if ($summary.errors | is-empty) { "" } else { $"\n($summary.errors | str join '\n')" }
        let kept = if $keep { $"\ntemporary files: ($work_dir)" } else { "" }
        error make $"Alloy did not emit any transformed log entries($detail)($kept)"
    }
}

# Run log entries through an isolated copy of an Alloy log pipeline.
export def "alloy test" [
    config: path # Alloy configuration file or directory
    log_file?: path # Log file; omit when piping raw log text into the command
    source?: string # loki.source component name; omit to auto-select or choose interactively
    --wait: duration = 15sec # Maximum time to let Alloy process the entries
    --keep # Keep temporary input, config, and storage files for debugging
]: any -> table {
    let pipeline_input = $in
    let config_path = $config | path expand
    let config_type = $config_path | path type
    let config_text = if $config_type == "file" {
        open --raw $config_path
    } else if $config_type == "dir" {
        let files = (
            ls $config_path
            | where type == file and name =~ '\.alloy$'
            | sort-by name
            | get name
        )
        if ($files | is-empty) {
            error make $"configuration directory has no .alloy files: ($config_path)"
        }
        $files | each {|file| open --raw $file } | str join "\n"
    } else {
        error make $"configuration path is not a file or directory: ($config_path)"
    }

    let has_pipeline_input = ($pipeline_input | describe) != "nothing"
    if $log_file != null and $has_pipeline_input {
        error make "pass either a log file or pipeline input, not both"
    }

    let log_text = if $log_file != null {
        open --raw ($log_file | path expand)
    } else if $has_pipeline_input {
        match ($pipeline_input | describe) {
            "string" => $pipeline_input
            "binary" => ($pipeline_input | decode utf-8)
            _ => { error make "pipeline input must be raw text or binary data" }
        }
    } else {
        error make "pass a log file or pipe log entries into alloy test"
    }

    if ($log_text | is-empty) {
        error make "the log input is empty"
    }

    let work_dir = mktemp --directory --tmpdir alloy-test.XXXXXXXX
    let input_path = $work_dir | path join "input.log"
    let test_config_path = $work_dir | path join "test.alloy"
    let storage_path = $work_dir | path join "data"
    let normalized_logs = if ($log_text | str ends-with "\n") { $log_text } else { $log_text + "\n" }
    try {
        $normalized_logs | save --force $input_path
        alloy-test-config $config_text $input_path $source | save --force $test_config_path
    } catch {|error|
        if not $keep {
            rm --recursive $work_dir
        }
        error make $error
    }

    let alloy_runner = if (which alloy | is-not-empty) {
        [((which alloy | first).path)]
    } else if (which nix | is-not-empty) {
        [((which nix | first).path) "run" "nixpkgs#grafana-alloy" "--"]
    } else {
        rm --recursive $work_dir
        error make "neither alloy nor nix is available"
    }

    let timeout_runner = if (which timeout | is-not-empty) {
        {program: ((which timeout | first).path), args: []}
    } else if (which nix | is-not-empty) {
        {program: ((which nix | first).path), args: ["run" "nixpkgs#coreutils" "--" "timeout"]}
    } else {
        rm --recursive $work_dir
        error make "neither timeout nor nix is available"
    }
    let timeout = (($wait / 1sec | into string) + "s")
    let alloy_args = (
        $alloy_runner
        | append [
            "run"
            "--disable-reporting"
            $"--storage.path=($storage_path)"
            "--server.http.listen-addr=127.0.0.1:0"
            "--cluster.advertise-address=127.0.0.1:12345"
            ($test_config_path | into string)
        ]
        | flatten
    )
    if $keep {
        print --stderr $"temporary files: ($work_dir)"
    }
    let parent_job = job id
    let runner_job = job spawn --description "alloy test" {
        let runner_id = job id
        let consumer_stopped = "Alloy test consumer stopped receiving results"
        let consumer_is_active = try {
            do {
                run-external $timeout_runner.program ...$timeout_runner.args $timeout ...$alloy_args
            } out+err>| lines
            | chunks 256
            | each {|batch|
                {kind: "batch", lines: $batch} | job send --tag $runner_id $parent_job
                let acknowledgement = try { job recv --tag $runner_id --timeout $wait }
                if $acknowledgement != "next" {
                    error make $consumer_stopped
                }
            }
            | ignore
            true
        } catch {|error| $error.msg != $consumer_stopped }
        if not $keep and ($work_dir | path exists) {
            rm --recursive $work_dir
        }
        if $consumer_is_active {
            {kind: "end"} | job send --tag $runner_id $parent_job
        }
    }

    generate {|state|
        if ($state.batch | is-empty) {
            if $state.needs_ack {
                "next" | job send --tag $runner_job $runner_job
            }
            let message = job recv --tag $runner_job
            if $message.kind == "end" {
                alloy-test-finalize {
                    entries: $state.entries
                    errors: $state.errors
                } $work_dir $keep
                {}
            } else {
                {
                    next: ($state | merge {
                        batch: $message.lines
                        index: 0
                        needs_ack: true
                    })
                }
            }
        } else {
            let line = $state.batch | get $state.index
            let next_index = $state.index + 1
            let next_state = $state | merge {
                batch: (if $next_index == ($state.batch | length) { [] } else { $state.batch })
                index: $next_index
                entries: ($state.entries + if ($line =~ 'component_id=loki\.echo\.' and $line =~ ' entry=') { 1 } else { 0 })
                errors: (if ($line =~ '(^Error:|level=error)') and ($state.errors | length) < 10 {
                    $state.errors | append $line
                } else {
                    $state.errors
                })
            }
            if $line =~ 'component_id=loki\.echo\.' and $line =~ ' entry=' {
                {out: (alloy-echo-entry $line), next: $next_state}
            } else {
                {next: $next_state}
            }
        }
    } {
        batch: []
        index: 0
        needs_ack: false
        entries: 0
        errors: []
    }
}
