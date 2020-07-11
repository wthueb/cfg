logger.i('loading fn')

local function fn_catcher(event)
    -- if this is our own key press we don't want to process it
    if event:getProperty(EVENTPROPERTY_EVENTSOURCEUSERDATA) == USER_DATA then
        return false
    end

    if event:getFlags()['fn'] then
        if event:getCharacters() == 'h' then
            if in_terminal() then
                key_press({'ctrl'}, 'w')
            else
                key_press({'alt'}, 'delete')
            end

            return true
        elseif event:getCharacters() == 'l' then
            if in_terminal() then
                key_press({}, 'escape')
                key_press({}, 'd')
            else
                key_press({'alt'}, 'forwarddelete')
            end
            
            return true
        end
    end

    return false
end

fn_hook = hs.eventtap.new({hs.eventtap.event.types.keyDown}, fn_catcher):start()
