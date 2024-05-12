let nord_theme = {
    separator: "#e5e9f0"
    leading_trailing_space_bg: { attr: "n" }
    header: { fg: "#a3be8c" attr: "b" }
    empty: "#81a1c1"
    bool: {|| if $in { "#88c0d0" } else { "light_gray" } }
    int: "#e5e9f0"
    filesize: {|e|
        if $e == 0b {
            "#e5e9f0"
        } else if $e < 1mb {
            "#88c0d0"
        } else {{ fg: "#81a1c1" }}
    }
    duration: "#e5e9f0"
    date: {|| (date now) - $in |
        if $in < 1hr {
            { fg: "#bf616a" attr: "b" }
        } else if $in < 6hr {
            "#bf616a"
        } else if $in < 1day {
            "#ebcb8b"
        } else if $in < 3day {
            "#a3be8c"
        } else if $in < 1wk {
            { fg: "#a3be8c" attr: "b" }
        } else if $in < 6wk {
            "#88c0d0"
        } else if $in < 52wk {
            "#81a1c1"
        } else { "dark_gray" }
    }
    range: "#e5e9f0"
    float: "#e5e9f0"
    string: "#e5e9f0"
    nothing: "#e5e9f0"
    binary: "#e5e9f0"
    cellpath: "#e5e9f0"
    row_index: { fg: "#a3be8c" attr: "b" }
    record: "#e5e9f0"
    list: "#e5e9f0"
    block: "#e5e9f0"
    hints: "dark_gray"
    search_result: { fg: "#bf616a" bg: "#e5e9f0" }

    shape_and: { fg: "#b48ead" attr: "b" }
    shape_binary: { fg: "#b48ead" attr: "b" }
    shape_block: { fg: "#81a1c1" attr: "b" }
    shape_bool: "#88c0d0"
    shape_custom: "#a3be8c"
    shape_datetime: { fg: "#88c0d0" attr: "b" }
    shape_directory: "#88c0d0"
    shape_external: "#88c0d0"
    shape_externalarg: { fg: "#a3be8c" attr: "b" }
    shape_filepath: "#88c0d0"
    shape_flag: { fg: "#81a1c1" attr: "b" }
    shape_float: { fg: "#b48ead" attr: "b" }
    shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: "b" }
    shape_globpattern: { fg: "#88c0d0" attr: "b" }
    shape_int: { fg: "#b48ead" attr: "b" }
    shape_internalcall: { fg: "#88c0d0" attr: "b" }
    shape_list: { fg: "#88c0d0" attr: "b" }
    shape_literal: "#81a1c1"
    shape_match_pattern: "#a3be8c"
    shape_matching_brackets: { attr: "u" }
    shape_nothing: "#88c0d0"
    shape_operator: "#ebcb8b"
    shape_or: { fg: "#b48ead" attr: "b" }
    shape_pipe: { fg: "#b48ead" attr: "b" }
    shape_range: { fg: "#ebcb8b" attr: "b" }
    shape_record: { fg: "#88c0d0" attr: "b" }
    shape_redirection: { fg: "#b48ead" attr: "b" }
    shape_signature: { fg: "#a3be8c" attr: "b" }
    shape_string: "#a3be8c"
    shape_string_interpolation: { fg: "#88c0d0" attr: "b" }
    shape_table: { fg: "#81a1c1" attr: "b" }
    shape_variable: "#b48ead"

    background: "#2e3440"
    foreground: "#e5e9f0"
    cursor: "#e5e9f0"
}

let carapace_completer = {|spans|
  # if the current command is an alias, get it's expansion
  let expanded_alias = (scope aliases | where name == $spans.0 | get -i 0 | get -i expansion)

  # overwrite
  let spans = (if $expanded_alias != null  {
    # put the first word of the expanded alias first in the span
    $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
  } else {
    $spans
  })

  carapace $spans.0 nushell ...$spans
  | from json
}

$env.config = {
    show_banner: false

    ls: {
        use_ls_colors: true
        clickable_links: true
    }

    rm: {
        always_trash: false
    }

    table: {
        mode: rounded # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
        index_mode: always # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column
        show_empty: true # show 'empty list' and 'empty record' placeholders for command output
        padding: { left: 1, right: 1 } # a left right padding of each column in a table
        trim: {
            methodology: wrapping # wrapping or truncating
            wrapping_try_keep_words: true # A strategy used by the 'wrapping' methodology
            truncating_suffix: "..." # A suffix used by the 'truncating' methodology
        }
        header_on_separator: false # show header text on separator/border line
        # abbreviated_row_count: 10 # limit data rows from top and bottom after reaching a set point
    }

    error_style: "fancy"

    # datetime_format determines what a datetime rendered in the shell would look like.
    # Behavior without this configuration point will be to "humanize" the datetime display,
    # showing something like "a day ago."
    datetime_format: {
        # normal: '%a, %d %b %Y %H:%M:%S %z'    # shows up in displays of variables or other datetime's outside of tables
        # table: '%m/%d/%y %I:%M:%S%p'          # generally shows up in tabular outputs such as ls. commenting this out will change it to the default human readable datetime format
    }

    explore: {
        status_bar_background: { fg: "#1D1F21", bg: "#C4C9C6" },
        command_bar_text: { fg: "#C4C9C6" },
        highlight: { fg: "black", bg: "yellow" },
        status: {
            error: { fg: "white", bg: "red" },
            warn: {}
            info: {}
        },
        table: {
            split_line: { fg: "#404040" },
            selected_cell: { bg: light_blue },
            selected_row: {},
            selected_column: {},
        },
    }

    history: {
        max_size: 100_000
        sync_on_enter: true
        file_format: "sqlite"
        isolation: false
    }

    completions: {
        case_sensitive: false
        quick: true # auto accept if it's the only option
        partial: true
        algorithm: "prefix" # "prefix" or "fuzzy"
        external: {
            enable: true
            max_results: 100
            completer: $carapace_completer
        }
        use_ls_colors: true
    }

    filesize: {
        metric: true # true => KB, MB, GB (ISO standard), false => KiB, MiB, GiB (Windows standard)
        format: "auto" # b, kb, kib, mb, mib, gb, gib, tb, tib, pb, pib, eb, eib, auto
    }

    cursor_shape: {
        emacs: line # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (line is the default)
        vi_insert: block # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (block is the default)
        vi_normal: underscore # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (underscore is the default)
    }

    color_config: $nord_theme
    use_grid_icons: true
    footer_mode: 25 # always, never, number_of_rows, auto
    float_precision: 2 # the precision for displaying floats in tables
    buffer_editor: "nvim" # command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.EDITOR and $env.VISUAL
    use_ansi_coloring: true
    bracketed_paste: true # enable bracketed paste, currently useless on windows
    edit_mode: vi
    shell_integration: false # enables terminal shell integration. Off by default, as some terminals have issues with this.
    render_right_prompt_on_last_line: false # true or false to enable or disable right prompt to be rendered on last line of the prompt.
    use_kitty_protocol: false # enables keyboard enhancement protocol implemented by kitty console, only if your terminal support this.
    highlight_resolved_externals: false # true enables highlighting of external commands in the repl resolved by which.
    recursion_limit: 50 # the maximum number of times nushell allows recursion before stopping it

    plugins: {}

    plugin_gc: {
        default: {
            enabled: true
            stop_after: 10sec
        }
        plugins: {}
    }

    hooks: {
        pre_prompt: [{ null }] # run before the prompt is shown
        pre_execution: [{ null }] # run before the repl input is run
        env_change: {
            PWD: [{|before, after| null }] # run if the PWD environment is different since the last repl input
        }
        display_output: "if (term size).columns >= 100 { table -e } else { table }" # run to display the output of a pipeline
        command_not_found: { null } # return an error message when a command is not found
    }

    menus: [
        {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: columnar
                columns: 4
                col_width: 20     # Optional value. If missing all the screen width is used to calculate column width
                col_padding: 2
            }
            style: {
                text: green
                selected_text: { attr: r }
                description_text: yellow
                match_text: { attr: u }
                selected_match_text: { attr: ur }
            }
        }
        {
            name: help_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: description
                columns: 4
                col_width: 20     # Optional value. If missing all the screen width is used to calculate column width
                col_padding: 2
                selection_rows: 4
                description_rows: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
    ]

    keybindings: [
        {
            name: fzf_history
            modifier: control
            keycode: char_r
            mode: [emacs, vi_normal, vi_insert]
            event: {
                send: ExecuteHostCommand,
                cmd: "commandline (
                         history |
                         where exit_status == 0 |
                         get command |
                         uniq |
                         reverse |
                         str join (char -i 0) |
                         fzf --scheme=history --read0 --layout=reverse --height=40% -q (commandline) |
                         decode utf-8 |
                         str trim
                     )"
            }
        }
        {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                    { edit: complete }
                ]
            }
        }
        {
            name: completion_previous_menu
            modifier: shift
            keycode: backtab
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menuprevious }
        }
        {
            name: tmux-sessionizer
            modifier: control
            keycode: char_f
            mode: [emacs vi_normal vi_insert]
            event: {
                send: ExecuteHostCommand,
                cmd: "tmux-sessionizer"
            }
        }
        {
            name: cancel_command
            modifier: control
            keycode: char_c
            mode: [emacs, vi_normal, vi_insert]
            event: { send: ctrlc }
        }
        {
            name: quit_shell
            modifier: control
            keycode: char_d
            mode: [emacs, vi_normal, vi_insert]
            event: { send: ctrld }
        }
        {
            name: open_command_editor
            modifier: control
            keycode: char_o
            mode: [emacs, vi_normal, vi_insert]
            event: { send: openeditor }
        }
        {
            name: move_up
            modifier: none
            keycode: up
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menuup }
                    { send: up }
                ]
            }
        }
        {
            name: move_down
            modifier: none
            keycode: down
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menudown }
                    { send: down }
                ]
            }
        }
        {
            name: move_left
            modifier: none
            keycode: left
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menuleft }
                    { send: left }
                ]
            }
        }
        {
            name: move_right_or_take_history_hint
            modifier: none
            keycode: right
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: historyhintcomplete }
                    { send: menuright }
                    { send: right }
                ]
            }
        }
        {
            name: move_one_word_left
            modifier: control
            keycode: left
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: movewordleft }
        }
        {
            name: move_one_word_right_or_take_history_hint
            modifier: control
            keycode: right
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: historyhintwordcomplete }
                    { edit: movewordright }
                ]
            }
        }
        {
            name: move_to_line_start
            modifier: none
            keycode: home
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: movetolinestart }
        }
        {
            name: move_to_line_start
            modifier: control
            keycode: char_a
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: movetolinestart }
        }
        {
            name: move_to_line_end_or_take_history_hint
            modifier: none
            keycode: end
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: historyhintcomplete }
                    { edit: movetolineend }
                ]
            }
        }
        {
            name: move_to_line_end_or_take_history_hint
            modifier: control
            keycode: char_e
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: historyhintcomplete }
                    { edit: movetolineend }
                ]
            }
        }
        {
            name: move_up
            modifier: control
            keycode: char_p
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menuup }
                    { send: up }
                ]
            }
        }
        {
            name: move_down
            modifier: control
            keycode: char_t
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menudown }
                    { send: down }
                ]
            }
        }
        {
            name: delete_one_character_backward
            modifier: none
            keycode: backspace
            mode: [emacs, vi_insert]
            event: { edit: backspace }
        }
        {
            name: delete_one_word_backward
            modifier: control
            keycode: backspace
            mode: [emacs, vi_insert]
            event: { edit: backspaceword }
        }
        {
            name: delete_one_character_forward
            modifier: none
            keycode: delete
            mode: [emacs, vi_insert]
            event: { edit: delete }
        }
        {
            name: delete_one_character_backward
            modifier: control
            keycode: char_h
            mode: [emacs, vi_insert]
            event: { edit: backspace }
        }
        {
            name: delete_one_word_backward
            modifier: control
            keycode: char_w
            mode: [emacs, vi_insert]
            event: { edit: backspaceword }
        }
    ]
}

def cmd-exists [cmd: string] {
    not (which $cmd | is-empty)
}

alias config = git --git-dir ~/.cfg --work-tree ~

alias .. = cd ..
alias cd.. = cd ..

alias l = ls
alias ll = ls -l
alias la = ls -a
alias lla = ls -la

alias vim = nvim
alias vi = vim

alias p = python

alias ffmpeg = ffmpeg -hide_banner
alias ffplay = ffplay -hide_banner

if (cmd-exists fdfind) {
    alias fd = fdfind
}

if (cmd-exists batcat) {
    alias bat = batcat
}

#if (cmd-exists bat) {
#    alias cat = bat --paging=auto
#}

match $nu.os-info.name {
    macos => {
        alias copy = pbcopy
        alias paste = pbpaste
    },
    windows => {
        alias copy = clip.exe
        alias paste = powershell.exe Get-Clipboard
    },
}

def mkcd [dir: string] {
    mkdir $dir ; cd $dir
}

def activate [dir?: string] {
    # TODO: do something with $env.VIRTUAL_ENV_PROMPT
    if not ($dir | is-empty) {
        sh -i -c $'source ($dir)/bin/activate ; nu -e "alias deactivate = exit"'                                                                        05/10/2024 03:41:54 AM
    } else {
        sh -i -c 'source env/bin/activate ; nu -e "alias deactivate = exit"'                                                                        05/10/2024 03:41:54 AM
    }
}

def venv [dir?: string] {
    if not ($dir | is-empty) {
        python -m venv --upgrade-deps $dir
    } else {
        python -m venv --upgrade-deps env
    }

    activate $dir
}

def vim-upgrade [] {
    nvim --headless "+Lazy! sync" +qa
}

source ($nu.default-config-dir | path join 'config.custom.nu')
