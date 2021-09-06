-- use control + h/j/k/l for left/down/up/right
logger.i('loading arrows')

local remap = function(from_mods, from_key, mods, key)
    local fn = function() key_press(mods, key) end
    hs.hotkey.bind(from_mods, from_key, fn, nil, fn)
end

-- TODO: fix this monstrosity

remap({'ctrl'}, 'h', {}, 'left')
remap({'ctrl'}, 'j', {}, 'down')
remap({'ctrl'}, 'k', {}, 'up')
remap({'ctrl'}, 'l', {}, 'right')

remap({'ctrl', 'shift'}, 'h', {'shift'}, 'left')
remap({'ctrl', 'shift'}, 'j', {'shift'}, 'down')
remap({'ctrl', 'shift'}, 'k', {'shift'}, 'up')
remap({'ctrl', 'shift'}, 'l', {'shift'}, 'right')

remap({'ctrl', 'cmd'}, 'h', {'cmd'}, 'left')
remap({'ctrl', 'cmd'}, 'j', {'cmd'}, 'down')
remap({'ctrl', 'cmd'}, 'k', {'cmd'}, 'up')
remap({'ctrl', 'cmd'}, 'l', {'cmd'}, 'right')

remap({'ctrl', 'alt'}, 'h', {'alt'}, 'left')
remap({'ctrl', 'alt'}, 'j', {'alt'}, 'down')
remap({'ctrl', 'alt'}, 'k', {'alt'}, 'up')
remap({'ctrl', 'alt'}, 'l', {'alt'}, 'right')

remap({'ctrl', 'shift', 'cmd'}, 'h', {'shift', 'cmd'}, 'left')
remap({'ctrl', 'shift', 'cmd'}, 'j', {'shift', 'cmd'}, 'down')
remap({'ctrl', 'shift', 'cmd'}, 'k', {'shift', 'cmd'}, 'up')
remap({'ctrl', 'shift', 'cmd'}, 'l', {'shift', 'cmd'}, 'right')

remap({'ctrl', 'shift', 'alt'}, 'h', {'shift', 'alt'}, 'left')
remap({'ctrl', 'shift', 'alt'}, 'j', {'shift', 'alt'}, 'down')
remap({'ctrl', 'shift', 'alt'}, 'k', {'shift', 'alt'}, 'up')
remap({'ctrl', 'shift', 'alt'}, 'l', {'shift', 'alt'}, 'right')

remap({'ctrl', 'cmd', 'alt'}, 'h', {'cmd', 'alt'}, 'left')
remap({'ctrl', 'cmd', 'alt'}, 'j', {'cmd', 'alt'}, 'down')
remap({'ctrl', 'cmd', 'alt'}, 'k', {'cmd', 'alt'}, 'up')
remap({'ctrl', 'cmd', 'alt'}, 'l', {'cmd', 'alt'}, 'right')

remap({'ctrl', 'cmd', 'alt', 'shift'}, 'h', {'cmd', 'alt', 'shift'}, 'left')
remap({'ctrl', 'cmd', 'alt', 'shift'}, 'j', {'cmd', 'alt', 'shift'}, 'down')
remap({'ctrl', 'cmd', 'alt', 'shift'}, 'k', {'cmd', 'alt', 'shift'}, 'up')
remap({'ctrl', 'cmd', 'alt', 'shift'}, 'l', {'cmd', 'alt', 'shift'}, 'right')
