local sbar = require("sketchybar")

local colors = require("colors")

-- disable native volume popup
sbar.exec("launchctl unload -F /System/Library/LaunchAgents/com.apple.OSDUIHelper.plist")

sbar.bar({
    height = 32,
    color = colors.bg,
    border_width = 0,
    shadow = false,
    position = "top",
    sticky = true,
    padding_left = 10,
    padding_right = 10,
    y_offset = 0,
    margin = 0,
    topmost = "window",
})

sbar.default({
    updates = "when_shown",
    icon = {
        font = "SauceCodePro Nerd Font:Bold:14.0",
        color = colors.icon,
        padding_left = 0,
        padding_right = 0,
    },
    label = {
        font = "SauceCodePro Nerd Font:Semibold:13.0",
        color = colors.text,
        padding_left = 0,
        padding_right = 0,
    },
    background = {
        height = 26,
        padding_left = 5,
        padding_right = 5,
        corner_radius = 8,
        border_width = 2,
    },
    popup = {
        background = {
            border_width = 1,
            corner_radius = 3,
            border_color = colors.modal_border,
            color = colors.modal_bg,
            shadow = { drawing = true },
        },
        blur_radius = 20,
    },
})

require("items.spaces")
require("items.title")
require("items.calendar")
require("items.battery")
require("items.wifi")
require("items.volume")
