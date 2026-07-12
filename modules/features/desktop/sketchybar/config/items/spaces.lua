local sbar = require("sketchybar")
local colors = require("colors")

sbar.add("item", "space.left_spacer", {
    position = "left",
    icon = { drawing = false },
    label = { drawing = false },
    background = {
        padding_left = 5,
        padding_right = 0,
    },
})

for i = 1, 9 do
    local space = sbar.add("space", "space." .. i, {
        position = "left",
        associated_space = i,
        icon = {
            string = tostring(i),
            highlight_color = colors.primary,
            padding_left = 0,
            padding_right = 0,
        },
        label = { drawing = false },
        background = { drawing = false },
    })

    space:subscribe("mouse.clicked", function(env)
        if env.BUTTON == "right" then
            sbar.exec("yabai -m space --destroy " .. env.SID)
            sbar.trigger("windows_on_spaces")
            sbar.trigger("space_change")
        else
            sbar.exec("yabai -m space --focus " .. env.SID .. " 2>/dev/null")
        end
    end)

    space:subscribe("space_change", function(env)
        local selected = env.SELECTED == "true"
        space:set({ icon = { highlight = selected } })
    end)
end

sbar.add("item", "space.right_spacer", {
    position = "left",
    icon = { drawing = false },
    label = { drawing = false },
    background = {
        padding_left = 0,
        padding_right = 5,
    },
})

sbar.add("bracket", "spaces_bracket", { "/space\\..*/" }, {
    background = { color = colors.modal_bg },
})
