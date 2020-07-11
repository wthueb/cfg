logger.i('loading superduper')

local sd_map = {
    -- tab stuff
    { {{}, 'u'}, {{'cmd'},          '1'} },
    { {{}, 'i'}, {{'cmd', 'shift'}, '['} },
    { {{}, 'o'}, {{'cmd', 'shift'}, ']'} },
    { {{}, 'p'}, {{'cmd'},          '9'} }
}

sd_hook = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
    -- if this is our own key press we don't want to process it
    if event:getProperty(EVENTPROPERTY_EVENTSOURCEUSERDATA) == USER_DATA then
        return false
    end

    if hs.fs.attributes('/tmp/superduper') == nil then
        return false
    end

    local mods = hs.eventtap.checkKeyboardModifiers()
    local key = hs.keycodes.map[event:getKeyCode()]

    for _, mapping in ipairs(sd_map) do
        local from_map, to_map = table.unpack(mapping)

        local from_mods, from_key = table.unpack(from_map)
        local to_mods, to_key = table.unpack(to_map)

        if key == from_key then
            local proper_mods = true 

            for _, mod in ipairs(from_mods) do
                if set[mod] == nil then
                    proper_mods = false
                end
            end

            if proper_mods then
                key_press(to_mods, to_key)

                return true
            end
        end
    end

    return false
end):start()
