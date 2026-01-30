local sbar = require("sketchybar")
local icons = require("icons")

local wifi = sbar.add("item", "wifi", {
    position = "right",
    icon = { string = icons.wifi_disconnected },
    label = { width = 0 },
    update_freq = 60,
})

local wifi_popup = sbar.add("item", "wifi.info", {
    position = "popup.wifi",
})

local function update_wifi()
    sbar.exec("networksetup -listallhardwareports | awk '/Wi-Fi/ { getline; print $2 }'", function(adapter)
        adapter = string.gsub(adapter, "%s+", "")

        sbar.exec("ipconfig getsummary " .. adapter .. " | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(ssid)
            ssid = string.gsub(ssid, "%s+", "")

            sbar.exec("ipconfig getifaddr " .. adapter, function(ip)
                ip = string.gsub(ip, "%s+", "")

                local icon, info
                if ip == "" then
                    info = "No Wi-Fi"
                    icon = icons.wifi_disconnected
                else
                    info = ssid .. " (" .. ip .. ")"
                    icon = icons.wifi_connected
                end

                wifi:set({ icon = { string = icon } })
                wifi_popup:set({ label = { string = info } })
            end)
        end)
    end)
end

wifi:subscribe({ "routine", "wifi_change" }, update_wifi)

wifi:subscribe("mouse.entered", function()
    wifi:set({ popup = { drawing = true } })
end)

wifi:subscribe("mouse.exited", function()
    wifi:set({ popup = { drawing = false } })
end)
