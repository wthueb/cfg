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

-- use control + h/l for left/right a word
-- have to do this outside of arrows_map due to iterm

local function left_word()
    if in_terminal() then
        key_press({}, 'escape')
        key_press({}, 'b')
    else
        key_press({'alt'}, 'left')
    end
end

local function right_word()
    if in_terminal() then
        key_press({}, 'escape')
        key_press({}, 'f')
    else
        key_press({'alt'}, 'right')
    end
end

hs.hotkey.bind({'alt'}, 'h', left_word, nil, left_word)
hs.hotkey.bind({'alt'}, 'l', right_word, nil, right_word)

for i, mapping in ipairs(arrows_map) do
    local from_mods, from_key = table.unpack(mapping.from)
    local to_mods, to_key = table.unpack(mapping.to)

    local function fn()
        key_press(to_mods, to_key)
    end

    hs.hotkey.bind(from_mods, from_key, fn, nil, fn)
end
