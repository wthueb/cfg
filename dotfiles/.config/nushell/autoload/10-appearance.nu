source ../themes/catppuccin_mocha.nu

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

$env.config.ls.use_ls_colors = true

$env.config.filesize.unit = "metric"
