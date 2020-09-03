logger.i('loading hyper')

local hyper_apps_map = {
    { 'e', 'Finder' },
    { 'f', 'Firefox' },
    { 't', 'iTerm' },
    { 'm', 'Messages' },
    { 'n', 'Notable' },
    { 's', 'Spotify' },
}

for i, mapping in ipairs(hyper_apps_map) do
    local key, app = table.unpack(mapping)

    hs.hotkey.bind(hyper_key, key, function()
        hs.application.open(app)
    end)
end
