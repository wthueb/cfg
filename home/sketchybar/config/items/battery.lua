local sbar = require("sketchybar")
local icons = require("icons")
local colors = require("colors")

local battery = sbar.add("item", "battery", {
    position = "right",
    update_freq = 30,
    icon = {
        padding_right = 3,
        y_offset = -1,
    },
})

local battery_popup = sbar.add("item", "battery.info", {
    position = "popup.battery",
})

local function update_battery()
    sbar.exec("pmset -g batt", function(output)
        local percentage = tonumber(string.match(output, "(%d+)%%"))

        if not percentage then
            return
        end

        local color = colors.icon
        local icon = icons.battery_0

        if percentage >= 80 then
            icon = icons.battery_100
        elseif percentage >= 60 then
            icon = icons.battery_75
        elseif percentage >= 40 then
            icon = icons.battery_50
        elseif percentage >= 20 then
            icon = icons.battery_25
        end

        if percentage <= 20 then
            color = colors.danger
        elseif percentage <= 30 then
            color = colors.warn
        end

        if string.match(output, "AC Power") then
            icon = icons.battery_charging
        end

        battery:set({
            icon = {
                string = icon,
                color = color,
            },
            label = { string = percentage .. "%" },
        })

        local remaining_time = string.match(output, "(%S+) remaining")
        if remaining_time then
            battery_popup:set({ label = { string = remaining_time .. ":00 remaining" } })
        end
    end)
end

battery:subscribe({ "routine", "power_source_change", "system_woke" }, update_battery)

battery:subscribe("mouse.entered", function()
    battery:set({ popup = { drawing = true } })
end)

battery:subscribe("mouse.exited", function()
    battery:set({ popup = { drawing = false } })
end)
