def logfmt-error [message: string] {
    error make {msg: $"invalid logfmt: ($message)"}
}

def logfmt-is-record [value: any] {
    ($value | describe) =~ '^record'
}

def logfmt-flatten [value: record, prefix: string = ""] {
    mut fields = []

    for field in ($value | transpose key value) {
        if ($field.key | is-empty) or ($field.key =~ '[\s=\\".]') {
            logfmt-error $"field name cannot be represented: ($field.key | to json --raw)"
        }

        let key = if ($prefix | is-empty) {
            $field.key
        } else {
            $"($prefix).($field.key)"
        }

        if (logfmt-is-record $field.value) and ($field.value | is-not-empty) {
            $fields = $fields | append (logfmt-flatten $field.value $key)
        } else {
            $fields = $fields | append ({key: $key, value: $field.value})
        }
    }

    $fields
}

def logfmt-looks-typed [value: string] {
    [
        ($value in ["true" "false" "null"])
        ($value =~ '^-?(0|[1-9][0-9]*)$')
        ($value =~ '^-?(0|[1-9][0-9]*)(\.[0-9]+([eE][+-]?[0-9]+)?|[eE][+-]?[0-9]+)$')
        ($value =~ '^[\[{]')
    ] | any {$in}
}

def logfmt-encode-value [value: any] {
    let kind = $value | describe

    if $kind == "string" {
        if ($value | is-empty) or ($value =~ '[\s=\\"]') or (logfmt-looks-typed $value) {
            $value | to json --raw
        } else {
            $value
        }
    } else if $kind == "bool" or $kind == "int" {
        $value | into string
    } else if $kind == "float" {
        $value | to json --raw
    } else if $kind == "nothing" {
        "null"
    } else if ($kind =~ '^list') or ($kind =~ '^table') or (logfmt-is-record $value) {
        $value | to json --raw
    } else {
        ($value | into string) | to json --raw
    }
}

def logfmt-encode-record [value: record] {
    logfmt-flatten $value
    | each {|field| $"($field.key)=(logfmt-encode-value $field.value)" }
    | str join " "
}

def logfmt-decode-bare [value: string] {
    if $value == "true" {
        true
    } else if $value == "false" {
        false
    } else if $value == "null" {
        null
    } else if ($value =~ '^-?(0|[1-9][0-9]*)$') {
        $value | into int
    } else if ($value =~ '^-?(0|[1-9][0-9]*)(\.[0-9]+([eE][+-]?[0-9]+)?|[eE][+-]?[0-9]+)$') {
        $value | into float
    } else if ($value =~ '^\[.*\]$') or ($value =~ '^\{.*\}$') {
        try {
            $value | from json --strict
        } catch {
            $value
        }
    } else {
        $value
    }
}

def logfmt-parse-line [line: string] {
    let chars = $line | split chars
    let count = $chars | length
    mut index = 0
    mut fields = []

    while $index < $count {
        while $index < $count and (($chars | get $index) =~ '\s') {
            $index = $index + 1
        }
        if $index >= $count {
            break
        }

        let key_start = $index
        while $index < $count and (($chars | get $index) != "=") and not (($chars | get $index) =~ '\s') {
            $index = $index + 1
        }
        if $index == $key_start or $index >= $count or (($chars | get $index) != "=") {
            logfmt-error $"expected key=value near character ($key_start + 1)"
        }

        let key = $chars | slice $key_start..<$index | str join
        let path = $key | split row "."
        if ($path | any {|part| $part | is-empty }) {
            logfmt-error $"invalid dotted field name: ($key)"
        }
        $index = $index + 1

        let quoted = $index < $count and (($chars | get $index) == '"')
        let value = if $quoted {
            let value_start = $index
            $index = $index + 1
            mut escaped = false
            mut closed = false

            while $index < $count {
                let char = $chars | get $index
                if $escaped {
                    $escaped = false
                } else if $char == "\\" {
                    $escaped = true
                } else if $char == '"' {
                    $closed = true
                    $index = $index + 1
                    break
                }
                $index = $index + 1
            }

            if not $closed {
                logfmt-error $"unterminated quoted value for ($key)"
            }
            if $index < $count and not (($chars | get $index) =~ '\s') {
                logfmt-error $"expected whitespace after quoted value for ($key)"
            }

            let encoded = $chars | slice $value_start..<$index | str join
            try {
                $encoded | from json --strict
            } catch {|error|
                logfmt-error $"invalid quoted value for ($key): ($error.msg)"
            }
        } else {
            let value_start = $index
            while $index < $count and not (($chars | get $index) =~ '\s') {
                $index = $index + 1
            }
            let encoded = $chars | slice $value_start..<$index | str join
            logfmt-decode-bare $encoded
        }

        $fields = $fields | append ({path: $path, value: $value})
    }

    $fields | reduce --fold {} {|field, record|
        try {
            $record | upsert ($field.path | into cell-path) $field.value
        } catch {
            logfmt-error $"conflicting field path: ($field.path | str join '.')"
        }
    }
}

# Convert structured data into logfmt text, flattening nested records with dotted field names.
export def "to logfmt" []: any -> string {
    let input = $in
    let kind = $input | describe

    if (logfmt-is-record $input) {
        logfmt-encode-record $input
    } else if ($kind =~ '^list') or ($kind =~ '^table') {
        $input
        | each {|row|
            if not (logfmt-is-record $row) {
                logfmt-error "table rows must be records"
            }
            logfmt-encode-record $row
        }
        | str join (char nl)
    } else {
        logfmt-error $"expected a record or table, found ($kind)"
    }
}

# Stream logfmt lines as records, expanding dotted field names into nested records.
export def "from logfmt" []: [
    string -> list<record>
    list<string> -> list<record>
] {
    $in
    | each --flatten {|input| $input | lines }
    | where {|line| $line | str trim | is-not-empty }
    | each {|line| logfmt-parse-line $line }
}
