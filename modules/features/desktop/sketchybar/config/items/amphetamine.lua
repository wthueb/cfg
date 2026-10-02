local sbar = require("sketchybar")
local icons = require("icons")
local colors = require("colors")

sbar.add("event", "amphetamine_change")

local amphetamine = sbar.add("item", "amphetamine", {
    position = "right",
    drawing = false,
    updates = true,
    update_freq = 10,
    icon = {
        string = icons.amphetamine,
        color = colors.primary,
        padding_right = 0,
    },
    label = { drawing = false },
})

local function update_amphetamine()
    sbar.exec(
        [[/usr/bin/osascript -e 'if application "Amphetamine" is running then' -e 'with timeout of 5 seconds' -e 'tell application "Amphetamine" to return session is active' -e 'end timeout' -e 'else' -e 'return false' -e 'end if' 2>/dev/null]],
        function(output)
            amphetamine:set({ drawing = output:match("^%s*true%s*$") ~= nil })
        end
    )
end

amphetamine:subscribe({ "routine", "system_woke", "amphetamine_change" }, update_amphetamine)

update_amphetamine()
