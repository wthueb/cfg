logger.i('loading arrows')

local arrows_map = {
    -- use control + h/j/k/l for left/down/up/right
    {
        from = {{'ctrl'}, 'h'},
        to   = {{}, 'left'}
    },
    {
        from = {{'ctrl'}, 'j'},
        to   = {{}, 'down'}
    },
    {
        from = {{'ctrl'}, 'k'},
        to   = {{}, 'up'}
    },
    {
        from = {{'ctrl'}, 'l'},
        to   = {{}, 'right'}
    },
}

local not_iterm = hs.window.filter.new(true):rejectApp('iTerm2')

for i, mapping in ipairs(arrows_map) do
    local from_mods, from_key = table.unpack(mapping.from)
    local to_mods, to_key = table.unpack(mapping.to)

    local function fn()
        key_press(to_mods, to_key)
    end

    enable_hk_for_wf(not_iterm, hs.hotkey.new(from_mods, from_key, fn, nil, fn))
end
