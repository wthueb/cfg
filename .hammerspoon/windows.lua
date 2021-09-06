logger.i('loading windows')

local window_map = {
    modifiers  = {'ctrl'},
    trigger    = 's',
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
        { {}, 'b', 'code' },
    }
}

hs.window.animationDuration = 0

local win_func = {}

-- +-----------------+
-- |                 |
-- |      HERE       |
-- |                 |
-- +-----------------+
win_func.fullscreen = function(win)
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
win_func.center = function(win)
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
win_func.left = function(win)
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
win_func.right = function(win)
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
win_func.up = function(win)
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
win_func.down = function(win)
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
win_func.up_left = function(win)
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
win_func.down_left = function(win)
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
win_func.down_right = function(win)
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
win_func.up_right = function(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()

    f.x = max.x + (max.w / 2)
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h / 2

    win:setFrame(f)
end

-- +-----------------+
-- |     |           |
-- |     |    HERE   |
-- |     |           |
-- +-----------------+
win_func.code = function(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + (max.w / 5 * 2)
    f.y = max.y
    f.w = max.w / 5 * 3
    f.h = max.h

    win:setFrame(f)
end

local win_layout_mode = hs.hotkey.modal.new(window_map.modifiers, window_map.trigger)

win_layout_mode.entered = function()
    win_layout_mode.status_message:show()
end

win_layout_mode.exited = function()
    win_layout_mode.status_message:hide()
end

win_layout_mode:bind(window_map.modifiers, window_map.trigger, function()
    win_layout_mode:exit()
end)

win_layout_mode:bind({}, 'escape', function()
    win_layout_mode:exit()
end)

local msg = get_mods_str(window_map.modifiers)

msg = 'window layout mode (' .. msg .. (string.len(msg) > 0 and '+' or '') .. window_map.trigger .. ')'

win_layout_mode.status_message = require('status-message').new(msg)

for _, mapping in ipairs(window_map.mappings) do
    local modifiers, key, win_fn = table.unpack(mapping)

    win_layout_mode:bind(modifiers, key, function()
        win_layout_mode:exit()

        local fw = hs.window.focusedWindow()

        win_func[win_fn](fw)
    end)
end
