local wezterm = require("wezterm")

local config = {
    color_scheme = "nord",

    font = wezterm.font "SauceCodePro Nerd Font",
    font_size = 15.0,

    disable_default_key_bindings = true,

    audible_bell = "Disabled",

    window_padding = {
        top = 1,
        bottom = 1,
        left = 1,
        right = 1,
    },

    launch_menu = {},

    skip_close_confirmation_for_processes_named = {},

    use_fancy_tab_bar = false,
    tab_bar_at_bottom = true,
    tab_max_width = 18,
    hide_tab_bar_if_only_one_tab = true,

    colors = {
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
        }
    }
}

local platform_keys = {}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    config.default_prog = { "pwsh.exe" }

    table.insert(config.launch_menu, {
        label = "PowerShell",
        args = { "pwsh.exe" },
    })

    config.hide_tab_bar_if_only_one_tab = false

    config.leader = { mods = "CTRL", key = "a", timeout_milliseconds = 5000 }

    platform_keys = {
        { key = "a",   mods = "LEADER|CTRL",  action = wezterm.action.SendString("\x01") },
        { key = "c",   mods = "LEADER",       action = wezterm.action.SpawnTab("CurrentPaneDomain") },
        { key = "1",   mods = "LEADER",       action = wezterm.action.ActivateTab(0) },
        { key = "2",   mods = "LEADER",       action = wezterm.action.ActivateTab(1) },
        { key = "3",   mods = "LEADER",       action = wezterm.action.ActivateTab(2) },
        { key = "4",   mods = "LEADER",       action = wezterm.action.ActivateTab(3) },
        { key = "5",   mods = "LEADER",       action = wezterm.action.ActivateTab(4) },
        { key = "6",   mods = "LEADER",       action = wezterm.action.ActivateTab(5) },
        { key = "7",   mods = "LEADER",       action = wezterm.action.ActivateTab(6) },
        { key = "8",   mods = "LEADER",       action = wezterm.action.ActivateTab(7) },
        { key = "9",   mods = "LEADER",       action = wezterm.action.ActivateTab(8) },
        { key = "a",   mods = "LEADER",       action = wezterm.action.ActivateLastTab },
        { key = "&",   mods = "LEADER|SHIFT", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
        { key = "Tab", mods = "CTRL",         action = wezterm.action.ActivateTabRelative(1) },
        { key = "Tab", mods = "CTRL|SHIFT",   action = wezterm.action.ActivateTabRelative(-1) },
        {
            mods = "CTRL|SHIFT",
            key = "t",
            action = wezterm.action.SpawnTab("CurrentPaneDomain")
        },
        {
            mods = "CTRL|SHIFT",
            key = "w",
            action = wezterm.action.CloseCurrentTab({ confirm = false }),
        },
        {
            mods = "CTRL|SHIFT",
            key = "c",
            action = wezterm.action.CopyTo("Clipboard"),
        },
        {
            mods = "CTRL|SHIFT",
            key = "v",
            action = wezterm.action.PasteFrom("Clipboard"),
        },
        {
            mods = "CTRL|SHIFT",
            key = "k",
            action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
        },
    }
elseif wezterm.target_triple == "aarch64-apple-darwin" then
    platform_keys = {
        {
            mods = "CMD",
            key = "t",
            action = wezterm.action.SpawnTab("CurrentPaneDomain")
        },
        {
            mods = "CMD",
            key = "w",
            action = wezterm.action.CloseCurrentTab({ confirm = false }),
        },
        {
            mods = "CMD",
            key = "q",
            action = wezterm.action.QuitApplication,
        },
        {
            mods = "CMD",
            key = "c",
            action = wezterm.action.CopyTo("Clipboard"),
        },
        {
            mods = "CMD",
            key = "v",
            action = wezterm.action.PasteFrom("Clipboard"),
        },
        {
            mods = "CMD",
            key = "k",
            action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
        },
    }
end

for _, key_config in pairs(platform_keys) do
    if (config.keys == nil) then
        config.keys = {}
    end

    table.insert(config.keys, key_config)
end

local function basename(s)
    local base = string.gsub(s, '(.*[/\\])(.*)', '%2')
    local idx = base:find(".exe")

    if idx == nil then
        return base
    end

    return base:sub(0, idx - 1)
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local process_name = basename(tab.active_pane.foreground_process_name)
    local title = " " .. tab.tab_index + 1 .. " > " .. process_name

    if (tab.is_active) then
        title = title .. " * "
    else
        title = title .. " - "
    end

    return title
end)

wezterm.on("update-right-status", function(window, pane)
    window:set_right_status(wezterm.format({
        { Foreground = { Color = "#2e3440" } },
        { Background = { Color = "#81a1c1" } },
        { Attribute = { Intensity = "Bold" } },
        { Text = " " .. wezterm.hostname() .. " " },
    }))
end)

return config
