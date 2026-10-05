local sbar = require("sketchybar")

sbar.add("event", "window_focus")
sbar.add("event", "title_change")

local title = sbar.add("item", "title", {
    position = "left",
    icon = { drawing = false },
    associated_display = "active",
})

local title_popup = sbar.add("item", "title.info", {
    position = "popup.title",
    icon = { drawing = false },
    label = {
        padding_left = 8,
        padding_right = 8,
    },
})

title:subscribe("mouse.entered", function()
    title:set({ popup = { drawing = true } })
end)

title:subscribe("mouse.exited", function()
    title:set({ popup = { drawing = false } })
end)

title:subscribe({ "window_focus", "front_app_switched", "space_change", "title_change" }, function()
    sbar.exec("yabai -m query --windows --window", function(window)
        local full_title
        if window.title == "" or window.title == nil then
            full_title = window.app
        else
            full_title = window.app .. " - " .. window.title
        end

        title_popup:set({ label = { string = full_title } })
        title:set({ label = { string = string.sub(full_title, 1, 75) } })
    end)
end)
