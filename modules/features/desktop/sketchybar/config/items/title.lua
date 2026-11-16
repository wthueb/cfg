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

local function update_title()
    sbar.exec("yabai -m query --windows --window", function(window, exit_code)
        if exit_code ~= 0 or type(window) ~= "table" or type(window.app) ~= "string" then
            return
        end

        local full_title
        if window.title == "" or window.title == nil then
            full_title = window.app
        else
            full_title = window.app .. " - " .. window.title
        end

        title_popup:set({ label = { string = full_title } })
        title:set({ label = { string = string.sub(full_title, 1, 75) } })
    end)
end

title:subscribe({ "window_focus", "front_app_switched", "space_change", "title_change" }, update_title)

update_title()
