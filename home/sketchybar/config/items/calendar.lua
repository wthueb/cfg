local sbar = require("sketchybar")

local calendar = sbar.add("item", "calendar", {
    position = "right",
    icon = { drawing = false },
    update_freq = 10,
    background = { padding_right = 0 },
})

local function update_calendar()
    local date_string = os.date("%a %b %d %I:%M %p")
    calendar:set({ label = { string = date_string } })
end

calendar:subscribe({ "routine", "system_woke" }, update_calendar)

update_calendar()
