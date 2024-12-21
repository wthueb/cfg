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

$env.CARAPACE_MATCH = 1

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
        | get id
        | first
    )

    $id
}

$env.config.show_banner = false

$env.config.explore = {
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

$env.config.history = {
    max_size: 100_000
    sync_on_enter: true
    file_format: "sqlite"
    isolation: false
}

$env.config.completions = {
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

$env.config.filesize = {
    metric: true # true => KB, MB, GB (ISO standard), false => KiB, MiB, GiB (Windows standard)
    format: "auto" # b, kb, kib, mb, mib, gb, gib, tb, tib, pb, pib, eb, eib, auto
}

$env.config.cursor_shape = {
    emacs: line # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (line is the default)
    vi_insert: block # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (block is the default)
    vi_normal: underscore # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (underscore is the default)
}

$env.config.color_config = $nord_theme
$env.config.buffer_editor = "nvim" # command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.EDITOR and $env.VISUAL
$env.config.edit_mode = 'vi'
$env.config.shell_integration = { # see osc_entries!: https://github.com/wez/wezterm/blob/main/termwiz/src/escape/osc.rs
    # osc2 abbreviates the path if in the home_dir, sets the tab/window title, shows the running command in the tab/window title
    osc2: true
    # osc7 is a way to communicate the path to the terminal, this is helpful for spawning new tabs in the same directory
    osc7: true
    # osc8 is also implemented as the deprecated setting ls.show_clickable_links, it shows clickable links in ls output if your terminal supports it. show_clickable_links is deprecated in favor of osc8
    osc8: true
    # osc9_9 is from ConEmu and is starting to get wider support. It's similar to osc7 in that it communicates the path to the terminal
    osc9_9: false
    # osc133 is several escapes invented by Final Term which include the supported ones below.
    # 133;A - Mark prompt start
    # 133;B - Mark prompt end
    # 133;C - Mark pre-execution
    # 133;D;exit - Mark execution finished with exit code
    # This is used to enable terminals to know where the prompt is, the command is, where the command finishes, and where the output of the command is
    osc133: true
    # osc633 is closely related to osc133 but only exists in visual studio code (vscode) and supports their shell integration features
    # 633;A - Mark prompt start
    # 633;B - Mark prompt end
    # 633;C - Mark pre-execution
    # 633;D;exit - Mark execution finished with exit code
    # 633;E - NOT IMPLEMENTED - Explicitly set the command line with an optional nonce
    # 633;P;Cwd=<path> - Mark the current working directory and communicate it to the terminal
    # and also helps with the run recent menu in vscode
    osc633: false
    # reset_application_mode is escape \x1b[?1l and was added to help ssh work better
    reset_application_mode: true
}
$env.config.render_right_prompt_on_last_line = false # true or false to enable or disable right prompt to be rendered on last line of the prompt.
$env.config.hooks = {
    pre_prompt: [{ null }] # run before the prompt is shown
    pre_execution: [{ null }] # run before the repl input is run
    env_change: {
        PWD: [{|before, after| null }] # run if the PWD environment is different since the last repl input
    }
    display_output: "if (term size).columns >= 100 { table -e } else { table }" # run to display the output of a pipeline
    command_not_found: { null } # return an error message when a command is not found
}

$env.config.menus = [
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

$env.config.keybindings = [
    {
        name: fzf_history
        modifier: control
        keycode: char_r
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: ExecuteHostCommand,
            cmd: "commandline edit --replace (
                      history |
                      where exit_status == 0 |
                      sort-by -r start_timestamp |
                      get command |
                      uniq |
                      str join (char -i 0) |
                      fzf --scheme=history --read0 --layout=reverse --height=40% -q (commandline) |
                      decode utf-8 |
                      str trim
                  )"
        }
    }
    {
        name: fzf_file
        modifier: control
        keycode: char_t
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: ExecuteHostCommand,
            cmd: "commandline edit --insert (
                      fzf --layout=reverse --height=40% |
                      decode utf-8 |
                      str trim
                  )"
        }
    }
    {
        name: fzf_gist_id
        modifier: control
        keycode: char_g
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: ExecuteHostCommand,
            cmd: "commandline edit --insert (gh gist search)"
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
        keycode: char_n
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

def "vim upgrade" [] {
    nvim --headless "+Lazy! sync" +qa
    nvim --headless "+TSUpdateSync" +qa
    nvim --headless "+MasonToolsUpdateSync" +qa
}

def confirm [prompt?: string] {
    if ($prompt == null) {
        print -n 'confirm? [y/n]: '
    } else {
        print -n $'($prompt) [y/n]: '
    }

    let input = (input -s --numchar 1)
    print $input

    return ($input == 'y')
}

source ~/.cache/starship.nu
source ($nu.default-config-dir | path join 'config.custom.nu')
