logger.i('loading hyper')

local hyper_apps_map = {
    { 'c', 'Google Chrome' },
    { 'e', 'Finder' },
    { 't', 'iTerm' },
    { 'm', 'Messages' },
    { 's', 'Spotify' },
}

for i, mapping in ipairs(hyper_apps_map) do
    local key, app = table.unpack(mapping)

    hs.hotkey.bind(hyper_key, key, function()
        hs.application.open(app)
    end)
end
