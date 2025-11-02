local M = {}

---@diagnostic disable-next-line: assign-type-mismatch
local wezterm = require("wezterm") ---@type Wezterm
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

local mod = "CTRL|SHIFT"

if wezterm.target_triple == "aarch64-apple-darwin" then
    mod = "CMD"
end

M.keys = {
    { key = "a", mods = "LEADER|CTRL", action = wezterm.action.SendString("\x01") },
    { key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    { key = "1", mods = "LEADER", action = wezterm.action.ActivateTab(0) },
    { key = "2", mods = "LEADER", action = wezterm.action.ActivateTab(1) },
    { key = "3", mods = "LEADER", action = wezterm.action.ActivateTab(2) },
    { key = "4", mods = "LEADER", action = wezterm.action.ActivateTab(3) },
    { key = "5", mods = "LEADER", action = wezterm.action.ActivateTab(4) },
    { key = "6", mods = "LEADER", action = wezterm.action.ActivateTab(5) },
    { key = "7", mods = "LEADER", action = wezterm.action.ActivateTab(6) },
    { key = "8", mods = "LEADER", action = wezterm.action.ActivateTab(7) },
    { key = "9", mods = "LEADER", action = wezterm.action.ActivateTab(8) },
    { key = "a", mods = "LEADER", action = wezterm.action.ActivateLastTab },
    { key = "r", mods = "LEADER", action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|DOMAINS" }) },
    { key = "Tab", mods = "CTRL", action = wezterm.action.ActivateTabRelative(1) },
    { key = "Tab", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
    {
        mods = mod,
        key = "q",
        action = wezterm.action.QuitApplication,
    },
    {
        mods = mod,
        key = "t",
        action = wezterm.action.SpawnTab("CurrentPaneDomain"),
    },
    {
        mods = mod,
        key = "w",
        action = wezterm.action.CloseCurrentTab({ confirm = false }),
    },
    {
        mods = mod,
        key = "n",
        action = wezterm.action.SpawnWindow,
    },
    {
        mods = mod,
        key = "c",
        action = wezterm.action.CopyTo("Clipboard"),
    },
    {
        mods = mod,
        key = "v",
        action = wezterm.action.PasteFrom("Clipboard"),
    },
    {
        mods = mod,
        key = "k",
        action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
    },
    {
        mods = mod,
        key = "n",
        action = wezterm.action.ShowLauncher,
    },
    {
        mods = mod,
        key = "-",
        action = wezterm.action.DecreaseFontSize,
    },
    {
        mods = mod,
        key = "=",
        action = wezterm.action.IncreaseFontSize,
    },
    {
        mods = mod,
        key = "l",
        action = wezterm.action.ShowDebugOverlay,
    },
    {
        mods = "CTRL",
        key = "f",
        action = workspace_switcher.switch_workspace(),
    },
}

return M
