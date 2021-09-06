logger.i('loading wifi')

local last_ssid = hs.wifi.currentNetwork()
local new_ssid  = nil

hs.wifi.watcher.new(function()
    new_ssid = hs.wifi.currentNetwork()

    if new_ssid == nil then
        hs.notify.new({title="wifi disconnected", informativeText="left network: " .. last_ssid}):send()
    elseif last_ssid == nil then
        hs.notify.new({title="wifi connected", informativeText="joined network: " .. new_ssid}):send()
    else
        hs.notify.new({title="wifi network changed", informativeText="left: " .. last_ssid .. "\njoined: " .. self.newSSID}):send()
    end

    last_ssid = new_ssid
end):start()
