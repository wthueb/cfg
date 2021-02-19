function notify_playing()
    local album = hs.spotify.getCurrentAlbum()
    local artist = hs.spotify.getCurrentArtist()
    local track = hs.spotify.getCurrentTrack()

    local message = 'now playing'

    if not hs.spotify.isPlaying() then
        message = message .. ' (paused)'
    end

    message = message .. ': \n' .. artist .. ' - ' .. track

    hs.notify.new({title='spotify', informativeText=message}):send()
end

hs.hotkey.bind(hyper_key, 'b', function()
    if (hs.spotify.isPlaying()) then
        hs.spotify.pause()
    else
        hs.spotify.play()
    end

    hs.timer.doAfter(.5, notify_playing)
end):enable()

hs.hotkey.bind(hyper_key, 'v', function()
    hs.spotify.previous()
    hs.timer.doAfter(.5, notify_playing)
end):enable()

hs.hotkey.bind(hyper_key, 'n', function()
    hs.spotify.next()
    hs.timer.doAfter(.5, notify_playing)
end):enable()
