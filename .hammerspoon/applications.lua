logger.i('loading applications')

local finder = hs.window.filter.new('Finder')

enable_hk_for_wf(finder, hs.hotkey.new({}, 'delete', function()
    hs.application.get('Finder'):selectMenuItem({'File', 'Move to Trash'})
end))
