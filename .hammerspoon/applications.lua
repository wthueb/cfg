logger.i('loading applications')

local finder = hs.window.filter.new(false):allowApp('Finder')

enable_hk_for_wf(finder, hs.hotkey.new({}, 'delete', function()
    hs.application.get('Finder'):selectMenuItem({'File', 'Move to Trash'})
end))

local firefox = hs.window.filter.new(false):allowApp('Firefox')

enable_hk_for_wf(firefox, hs.hotkey.new({'cmd', 'shift'}, 'n', function()
    hs.application.get('Firefox'):selectMenuItem({'File', 'New Private Window'})
end))
