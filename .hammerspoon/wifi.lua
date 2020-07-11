logger.i('loading wifi')

local lastSSID = hs.wifi.currentNetwork()
local newSSID  = nil

wifi_watcher = hs.wifi.watcher.new(function()
    newSSID = hs.wifi.currentNetwork()

    if newSSID == nil then
		hs.notify.new({title="wifi disconnected", informativeText="left network: " .. lastSSID}):send()
	elseif lastSSID == nil then
		hs.notify.new({title="wifi connected", informativeText="joined network: " .. newSSID}):send()
	else
		hs.notify.new({title="wifi network changed", informativeText="left: " .. lastSSID .. "\njoined: " .. self.newSSID}):send()
	end

    lastSSID = newSSID
end):start()
