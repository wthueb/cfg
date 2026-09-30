$env.config.show_banner = false

$env.config.history = {
    max_size: 100_000
    sync_on_enter: true
    file_format: "sqlite"
    isolation: false
}

$env.config.cursor_shape = {
    emacs: line # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (line is the default)
    vi_insert: block # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (block is the default)
    vi_normal: underscore # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (underscore is the default)
}

$env.config.buffer_editor = "nvim" # command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.EDITOR and $env.VISUAL
$env.config.edit_mode = 'vi'
$env.config.shell_integration = { # see osc_entries!: https://github.com/wezterm/wezterm/blob/main/wezterm-escape-parser/src/osc.rs
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
    osc633: true
    # reset_application_mode is escape \x1b[?1l and was added to help ssh work better
    reset_application_mode: true
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
                      history
                      | where exit_status == 0
                      | sort-by -r start_timestamp
                      | get command
                      | uniq
                      | str join (char -i 0)
                      | fzf --scheme=history --read0 --layout=reverse --height=40% -q (commandline)
                      | decode utf-8
                      | str trim
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
                      fd --hidden --follow --print0 .
                      | fzf --scheme=path --read0 --layout=reverse --height=40%
                      | decode utf-8
                      | str trim
                      | if ' ' in $in { $'`($in)`' } else { $in }
                  )"
        }
    }
    {
        name: fzf_cd
        modifier: alt
        keycode: char_c
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: ExecuteHostCommand,
            cmd: "cd (
                      fd --type d --hidden --follow --print0 .
                      | fzf --scheme=path --read0 --layout=reverse --height=40%
                      | decode utf-8
                      | str trim
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
]
