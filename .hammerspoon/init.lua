hs.logger.defaultLogLevel = 'info'
hs.logger.setGlobalLogLevel('info')

logger = hs.logger.new('wi1binds')

logger.i('initializing')

hyper_key = {'ctrl', 'alt', 'cmd', 'shift'}

-- hyper-` to reload config
hs.hotkey.bind(hyper_key, '`', function()
    hs.reload()
end)

EVENTPROPERTY_EVENTSOURCEUSERDATA = 42
USER_DATA = 42069

key_press = function(modifiers, key)
    --hs.eventtap.keyStroke(modifiers, key)
    --
    hs.eventtap.event.newKeyEvent(modifiers, key, true):setProperty(EVENTPROPERTY_EVENTSOURCEUSERDATA, 42069):post()

    hs.timer.delayed.new(.005, function()
        hs.eventtap.event.newKeyEvent(modifiers, key, false):setProperty(EVENTPROPERTY_EVENTSOURCEUSERDATA, 42069):post()
    end):start()
end

in_terminal = function()
    app = hs.application.frontmostApplication():name()

    return app == 'iTerm2' or app == 'Terminal'
end

enable_hk_for_wf = function(wf, hk)
    wf:subscribe(hs.window.filter.windowFocused, function()
        hk:enable()
    end)

    wf:subscribe(hs.window.filter.windowUnfocused, function()
        hk:disable()
    end)
end

disable_hk_for_wf = function(wf, hk)
    wf:subscribe(hs.window.filter.windowFocused, function()
        hk:disable()
    end)

    wf:subscribe(hs.window.filter.windowUnfocused, function()
        hk:enable()
    end)
end

local help_msg = hs.execute('cat $HOME/.hammerspoon/keybinds.txt', true)

local message = require('status-message').new(help_msg, 9)
local showing_help = false

hs.hotkey.bind(hyper_key, 'h', function()
    logger.i('here')
    if showing_help then
        message:hide()
        showing_help = false
    else
        message:show()
        showing_help = true
    end
end):enable()

require('applications')
require('arrows')
require('delete-lines')
require('fn')
require('hyper')
require('superduper')
require('wifi')
require('windows')

hs.notify.new({title='hammerspoon', informativeText='initialized'}):send()
