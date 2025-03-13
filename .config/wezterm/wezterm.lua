local wezterm = require("wezterm")

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

local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

resurrect.state_manager.periodic_save({
    interval_seconds = 10,
    save_workspaces = true,
    save_windows = true,
    save_tabs = true,
})

wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)

local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

---@param s string
function string.basename(s)
    local base = string.gsub(s, "(.*[/\\])(.*)", "%2")
    local idx = base:find(".exe")

    if idx == nil then
        return base
    end

    return base:sub(0, idx - 1)
end

---@generic T : table
---@param t T
---@return T
function table.shallow_copy(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end

workspace_switcher.get_choices = function()
    ---@alias Choice {label: string, id: string}
    ---@type Choice[]
    local choices = workspace_switcher.choices.get_workspace_elements({})

    -- put ~ workspace at the top

    ---@type Choice
    local default = nil
    for i, choice in ipairs(choices) do
        if choice.id == "~" then
            default = choice
            table.remove(choices, i)
            break
        end
    end
    if default then
        table.insert(choices, 1, default)
    end

    local workspaces = table.shallow_copy(choices)

    ---@param potential Choice
    local function check_exists(potential)
        local exists = false
        for _, choice in ipairs(choices) do
            if choice.id == potential.id then
                exists = true
                break
            end
        end
        for _, choice in ipairs(workspaces) do
            if choice.id == potential.label then
                exists = true
                break
            end
        end

        return exists
    end

    ---@param path string
    local function add_dirs(path)
        ---@type boolean, string, string
        local _, stdout, _ = wezterm.run_child_process({
            "fd",
            "-t",
            "d",
            "-Ha",
            ".",
            path,
            "--max-depth=1",
        })

        for line in stdout:gmatch("[^\n]*\n?") do
            ---@type string
            line = line:match("^%s*(.-)%s*$") -- trim whitepsace

            local label = line:gsub(wezterm.home_dir, "~")

            local potential = { label = label, id = line }

            local exists = check_exists(potential)

            if not exists then
                table.insert(choices, potential)
            end
        end
    end

    ---@param path string
    local function add_git_dirs(path)
        ---@type boolean, string, string
        local _, stdout, _ = wezterm.run_child_process({
            "fd",
            "-t",
            "d",
            "-Ha",
            "--min-depth",
            "1",
            "--max-depth",
            "5",
            "\\.git$",
            path,
            "-x",
            "dirname",
        })

        for line in stdout:gmatch("[^\n]*\n?") do
            ---@type string
            line = line:match("^%s*(.-)%s*$") -- trim whitepsace

            local dir = string.basename(line)

            local potential = { label = dir, id = line }

            local exists = check_exists(potential)

            if not exists then
                table.insert(choices, potential)
            end
        end
    end

    local file = io.open(wezterm.config_dir .. "/dirs.txt", "r")

    if file then
        for line in file:lines() do
            line = line
            local method, path = line:match("^(%w+) (.-)$")
            if method == nil or path == nil then
                local label = line:gsub(wezterm.home_dir, "~")
                table.insert(choices, { label = label, id = line })
            elseif method == "git" then
                add_git_dirs(path)
            elseif method == "dir" then
                add_dirs(path)
            end
        end
        file:close()
    end

    return choices
end

wezterm.on("smart_workspace_switcher.workspace_switcher.chosen", function(window, workspace)
    local gui_win = window:gui_window()
    local base_path = string.gsub(workspace, "(.*[/\\])(.*)", "%2")
    gui_win:set_right_status(wezterm.format({
        { Foreground = { Color = "#2e3440" } },
        { Background = { Color = "#81a1c1" } },
        { Text = base_path .. "  " },
    }))
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, workspace)
    local gui_win = window:gui_window()
    local base_path = string.gsub(workspace, "(.*[/\\])(.*)", "%2")
    gui_win:set_right_status(wezterm.format({
        { Foreground = { Color = "#2e3440" } },
        { Background = { Color = "#81a1c1" } },
        { Text = base_path .. "  " },
    }))
end)

if wezterm.target_triple == "aarch64-apple-darwin" then
    config.default_prog = { "bash", "-l", "-c", "nu" }

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

local has_custom, custom = pcall(require, "custom")
if has_custom then
    custom.apply_to_config(config)
end

return config
