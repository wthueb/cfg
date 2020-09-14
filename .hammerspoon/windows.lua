logger.i('loading windows')

local window_map = {
      modifiers  = {'ctrl'},
      trigger    = 's',
      show_help  = false,
      mappings   = {
          { {}, 'f', 'fullscreen' },
          { {}, 'c', 'center' },
          { {}, 'h', 'left' },
          { {}, 'j', 'down' },
          { {}, 'k', 'up' },
          { {}, 'l', 'right' },
          { {}, 'i', 'up_left' },
          { {}, 'o', 'up_right' },
          { {}, ',', 'down_left' },
          { {}, '.', 'down_right' },
      }
}

hs.window.animationDuration = 0

-- +-----------------+
-- |                 |
-- |      HERE       |
-- |                 |
-- +-----------------+
function hs.window.fullscreen(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
  
    f.x = max.x
    f.y = max.y
    f.w = max.w
    f.h = max.h
  
    win:setFrame(f)
end

-- +-----------------+
-- |   |        |    |
-- |   |  HERE  |    |
-- |   |        |    |
-- +-----------------+
function hs.window.center(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
  
    f.x = max.x + max.w / 2 - f.w / 2
    f.y = max.y + max.h / 2 - f.h / 2
    f.w = f.w
    f.h = f.h
  
    win:setFrame(f)
end

-- +-----------------+
-- |        |        |
-- |  HERE  |        |
-- |        |        |
-- +-----------------+
function hs.window.left(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
  
    f.x = max.x
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h
  
    win:setFrame(f)
end

-- +-----------------+
-- |        |        |
-- |        |  HERE  |
-- |        |        |
-- +-----------------+
function hs.window.right(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
  
    f.x = max.x + (max.w / 2)
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h

    win:setFrame(f)
end

-- +-----------------+
-- |      HERE       |
-- +-----------------+
-- |                 |
-- +-----------------+
function hs.window.up(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x
    f.y = max.y
    f.w = max.w
    f.h = max.h / 2

    win:setFrame(f)
end

-- +-----------------+
-- |                 |
-- +-----------------+
-- |      HERE       |
-- +-----------------+
function hs.window.down(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x
    f.y = max.y + (max.h / 2)
    f.w = max.w
    f.h = max.h / 2

    win:setFrame(f)
end

-- +-----------------+
-- |  HERE  |        |
-- +--------+        |
-- |                 |
-- +-----------------+
function hs.window.up_left(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()

    f.x = max.x
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h / 2

    win:setFrame(f)
end

-- +-----------------+
-- |                 |
-- +--------+        |
-- |  HERE  |        |
-- +-----------------+
function hs.window.down_left(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()

    f.x = max.x
    f.y = max.y + (max.h / 2)
    f.w = max.w / 2
    f.h = max.h / 2

    win:setFrame(f)
end

-- +-----------------+
-- |                 |
-- |        +--------|
-- |        |  HERE  |
-- +-----------------+
function hs.window.down_right(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()

    f.x = max.x + (max.w / 2)
    f.y = max.y + (max.h / 2)
    f.w = max.w / 2
    f.h = max.h / 2

    win:setFrame(f)
end

-- +-----------------+
-- |        |  HERE  |
-- |        +--------|
-- |                 |
-- +-----------------+
function hs.window.up_right(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()

    f.x = max.x + (max.w / 2)
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h / 2

    win:setFrame(f)
end

win_layout_mode = hs.hotkey.modal.new({}, 'F16')

win_layout_mode.entered = function()
    win_layout_mode.status_message:show()
end

win_layout_mode.exited = function()
    win_layout_mode.status_message:hide()
end

function win_layout_mode.bind_and_exit(mode, modifiers, key, fn)
    mode:bind(modifiers, key, function()
        mode:exit()
        fn()
    end)
end

local modifiers = window_map.modifiers
local trigger = window_map.trigger
local show_help = window_map.show_help
local mappings = window_map.mappings

function get_mods_str(modifiers)
    local modMap = { shift = '⇧', ctrl = '⌃', alt = '⌥', cmd = '⌘' }
    local retVal = ''

    for i, v in ipairs(modifiers) do
        retVal = retVal .. modMap[v]
    end

    return retVal
end

local msg = get_mods_str(modifiers)

msg = 'window layout mode (' .. msg .. (string.len(msg) > 0 and '+' or '') .. trigger .. ')'

for i, mapping in ipairs(mappings) do
    local modifiers, trigger, win_fn = table.unpack(mapping)
    local hk_str = get_mods_str(modifiers)
  
    if show_help == true then
        if string.len(hk_str) > 0 then
          msg = msg .. (string.format('\n%10s+%s => %s', hk_str, trigger, win_fn))
        else
          msg = msg .. (string.format('\n%11s => %s', trigger, win_fn))
        end
    end
  
    win_layout_mode:bind_and_exit(modifiers, trigger, function()
        local fw = hs.window.focusedWindow()

        fw[win_fn](fw)
    end)
end

local message = require('status-message')

win_layout_mode.status_message = message.new(msg)

-- use modifiers+trigger to toggle window layout mode
hs.hotkey.bind(modifiers, trigger, function()
    win_layout_mode:enter()
end)

win_layout_mode:bind(modifiers, trigger, function()
    win_layout_mode:exit()
end)
