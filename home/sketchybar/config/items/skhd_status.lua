local sbar = require("sketchybar")

-- label gets updated via skhd configuration (calling sketchybar --set skhd_status label="...")
sbar.add("item", "skhd_status", {
    position = "e", -- right of notch
    icon = { drawing = false },
    padding_left = 0,
})
