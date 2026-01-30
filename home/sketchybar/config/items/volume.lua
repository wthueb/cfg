local sbar = require("sketchybar")
local icons = require("icons")
local colors = require("colors")

local volume_slider = sbar.add("slider", "volume", 0, {
    position = "right",
    updates = true,
    padding_left = 0,
    padding_right = 5,
    label = { drawing = false },
    icon = { drawing = false },
    slider = {
        highlight_color = colors.primary,
        background = {
            height = 5,
            corner_radius = 3,
            color = colors.modal_bg,
        },
        knob = { drawing = false },
    },
})

local volume_icon = sbar.add("item", "volume_icon", {
    position = "right",
    icon = { font = "SauceCodePro Nerd Font:Regular:18.0" },
    label = { drawing = false },
})

local volume_timer = nil

local function get_volume_icon(volume)
    if volume >= 67 then
        return icons.volume_100
    elseif volume >= 34 then
        return icons.volume_66
    elseif volume >= 1 then
        return icons.volume_33
    else
        return icons.volume_0
    end
end

volume_slider:subscribe("volume_change", function(env)
    local volume = tonumber(env.INFO)
    local icon = get_volume_icon(volume)

    volume_icon:set({ icon = { string = icon } })
    volume_slider:set({ slider = { percentage = volume } })

    sbar.animate("tanh", 30, function()
        volume_slider:set({ slider = { width = 100 } })
    end)

    if volume_timer then
        volume_timer:cancel()
    end

    volume_timer = sbar.delay(2, function()
        local final_percentage = tonumber(volume_slider:query().slider.percentage)
        if final_percentage == volume then
            sbar.animate("tanh", 30, function()
                volume_slider:set({ slider = { width = 0 } })
            end)
        end
    end)
end)

volume_slider:subscribe("mouse.clicked", function(env)
    local percentage = env.PERCENTAGE
    sbar.exec("osascript -e 'set volume output volume " .. percentage .. "'")
end)

volume_icon:subscribe("mouse.clicked", function()
    sbar.animate("tanh", 30, function()
        volume_slider:set({ slider = { width = 100 } })
    end)
end)
