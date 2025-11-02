local wezterm = require("wezterm")
require("helpers")

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

config.default_workspace = "~"

config.front_end = "WebGpu" -- wez/wezterm#5990

config.color_scheme = "nord"

config.font = wezterm.font("SauceCodePro Nerd Font")
config.font_size = 15.0

config.hyperlink_rules = wezterm.default_hyperlink_rules()

table.insert(config.hyperlink_rules, {
    regex = [[\b([\w\d][-\w\d]+)/([-\w\d\.]+)#(\d+)\b]],
    format = "https://www.github.com/$1/$2/issues/$3",
})

table.insert(config.hyperlink_rules, {
    regex = [[\b([\w\d][-\w\d]+)/([-\w\d\.]+)\b]],
    format = "https://www.github.com/$1/$2",
})

config.audible_bell = "Disabled"

config.window_padding = {
    top = 1,
    bottom = 1,
    left = 1,
    right = 1,
}

config.unix_domains = {
    {
        name = "unix",
    },
}

config.default_gui_startup_args = { "connect", "unix" }

config.mux_env_remove = {
    "SSH_AUTH_SOCK",
    --"SSH_CLIENT",
    --"SSH_CONNECTION",
}

config.launch_menu = {}

config.skip_close_confirmation_for_processes_named = {}

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 18
config.hide_tab_bar_if_only_one_tab = false

config.colors = {
    tab_bar = {
        background = "#2e3440",

        active_tab = {
            bg_color = "#81a1c1",
            fg_color = "#2e3440",

            intensity = "Bold",
            underline = "None",
            italic = false,
            strikethrough = false,
        },

        inactive_tab = {
            bg_color = "#4e5668",
            fg_color = "#d8dee9",

            intensity = "Bold",
            underline = "None",
            italic = false,
            strikethrough = false,
        },
    },
}

config.disable_default_key_bindings = true
config.leader = { mods = "CTRL", key = "a", timeout_milliseconds = 5000 }
config.keys = require("keys").keys

if wezterm.target_triple == "aarch64-apple-darwin" then
    --config.default_prog = { "bash", "-l", "-c", "nu" }

    config.window_decorations = "RESIZE"
    config.window_padding = {
        top = 10,
        bottom = 10,
        left = 10,
        right = 10,
    }
elseif wezterm.target_triple == "x86_64-pc-windows-msvc" then
    config.default_prog = { "nu.exe" }

    config.wsl_domains = {
        {
            name = "WSL:NixOS",
            distribution = "NixOS",
            default_cwd = "/home/wil",
        },
    }

    table.insert(config.launch_menu, {
        label = "nu",
        args = { "nu.exe" },
    })

    table.insert(config.launch_menu, {
        label = "PowerShell",
        args = { "pwsh.exe" },
    })

    wezterm.on("gui-startup", function(cmd)
        ---@diagnostic disable-next-line: unused-local
        local tab, pane, window = wezterm.mux.spawn_window(cmd or {})

        window:gui_window():maximize()
    end)
end

---@diagnostic disable-next-line: unused-local
wezterm.on("format-tab-title", function(tab, tabs, panes, c, hover, max_width)
    local process_name = string.basename(tab.active_pane.foreground_process_name)
    local title = " " .. tab.tab_index + 1 .. " > " .. process_name

    if tab.is_active then
        title = title .. " * "
    else
        title = title .. " - "
    end

    return title
end)

-----@diagnostic disable-next-line: unused-local
--wezterm.on("update-right-status", function(window, pane)
--    window:set_right_status(wezterm.format({
--        { Foreground = { Color = "#2e3440" } },
--        { Background = { Color = "#81a1c1" } },
--        { Attribute = { Intensity = "Bold" } },
--        { Text = " " .. wezterm.hostname() .. " " },
--    }))
--end)

require("session")

local has_custom, custom = pcall(require, "custom")
if has_custom then
    custom.apply_to_config(config)
end

return config
