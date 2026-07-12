local sbar = require("sketchybar")

sbar.add("event", "window_focus")
sbar.add("event", "title_change")

local title = sbar.add("item", "title", {
    position = "left",
    icon = { drawing = false },
    associated_display = "active",
})

title:subscribe({ "window_focus", "front_app_switched", "space_change", "title_change" }, function()
    sbar.exec("yabai -m query --windows --window", function(window)
        local full_title
        if window.title == "" or window.title == nil then
            full_title = window.app
        else
            full_title = window.app .. " - " .. window.title
        end

        if #full_title > 75 then
            full_title = string.sub(full_title, 1, 75)
        end

        title:set({ label = { string = full_title } })
    end)
end)
