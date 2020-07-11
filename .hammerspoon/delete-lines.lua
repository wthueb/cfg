logger.i('loading delete-lines')

-- C-u to delete to beginning of line
local wf = hs.window.filter.new(false):setFilters({iTerm2 = true, Terminal = true})

disable_hk_for_wf(wf, hs.hotkey.bind({'ctrl'}, 'u', function()
    key_press({'cmd'}, 'delete')
end))

-- C-; to delete to end of line
hs.hotkey.bind({'ctrl'}, ';', function()
    if in_terminal() then
        hk = hs.fnutils.find(hs.hotkey.getHotkeys(), function(hk)
            return hk.idx == '⌃K'
        end)

        if hk then
            hk:disable()
        end

        key_press({'ctrl'}, 'k')

        hs.timer.new(.2, function()
            if hk then
                hk:enable()
            end
        end):start()
    else
        key_press({'cmd', 'shift'}, 'right')
        key_press({}, 'forwarddelete')
    end
end)
