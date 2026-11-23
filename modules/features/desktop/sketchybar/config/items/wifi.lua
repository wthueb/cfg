local sbar = require("sketchybar")
local icons = require("icons")

local wifi = sbar.add("item", "wifi", {
    position = "right",
    icon = { string = icons.wifi_disconnected },
    label = { width = 0 },
    update_freq = 10,
})

local wifi_popup = sbar.add("item", "wifi.info", {
    position = "popup.wifi",
})

local function update_wifi()
    sbar.exec("networksetup -listallhardwareports | awk '/Wi-Fi/ { getline; print $2 }'", function(adapter)
        adapter = string.gsub(adapter, "%s+", "")

        if adapter == "" then
            wifi:set({ icon = { string = icons.wifi_disconnected } })
            wifi_popup:set({ label = { string = "No Wi-Fi" } })
            return
        end

        sbar.exec("ipconfig getsummary " .. adapter, function(summary)
            local ssid = summary:match("\n%s*SSID : ([^\n]*)") or ""
            ssid = ssid:match("^%s*(.-)%s*$")
            if ssid == "<redacted>" then
                ssid = ""
            end

            local connected = summary:match("LinkStatusActive%s*:%s*TRUE") ~= nil
            local hotspot = summary:match("IsExpensive%s*:%s*TRUE") ~= nil

            sbar.exec("ipconfig getifaddr " .. adapter, function(ip)
                ip = string.gsub(ip, "%s+", "")

                local icon, info
                if not connected then
                    info = "No Wi-Fi"
                    icon = icons.wifi_disconnected
                else
                    info = ssid ~= "" and ssid or "Wi-Fi"
                    icon = hotspot and icons.wifi_hotspot or icons.wifi_connected
                    if hotspot then
                        info = ssid ~= "" and "Personal Hotspot: " .. ssid or "Personal Hotspot"
                    end
                    if ip ~= "" then
                        info = info .. " (" .. ip .. ")"
                    end
                end

                wifi:set({ icon = { string = icon } })
                wifi_popup:set({ label = { string = info } })
            end)
        end)
    end)
end

wifi:subscribe({ "routine", "wifi_change", "system_woke" }, function(env)
    update_wifi()
    if env.SENDER == "system_woke" then
        sbar.delay(5, update_wifi)
    end
end)

update_wifi()

wifi:subscribe("mouse.entered", function()
    wifi:set({ popup = { drawing = true } })
end)

wifi:subscribe("mouse.exited", function()
    wifi:set({ popup = { drawing = false } })
end)
