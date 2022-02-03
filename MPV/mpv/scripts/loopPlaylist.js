var loops = {
    0: 'Playlist: None',
    1: 'Playlist: Loop File',
    2: 'Playlist: Loop Playlist',
    3: 'Playlist: Shuffle',
}

var loop = 0;

function RandomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
}

function loopPlaylist() {
    loop = (loop+1) % Object.keys(loops).length;
    mp.commandv("show-text", loops[loop]);
}

function on_change(name, value) {
    if ((mp.get_property_native('time-remaining') >= 0.5) || !value) return;
    var playlist = mp.get_property_native('playlist');
    if ((playlist === undefined) || (playlist.length <= 0)) return;

    for (var i = 0; i < playlist.length; i++) {
        if (playlist[i] && playlist[i].current) {
            var currentIndex = i;
        }
    }

    switch (loop) {
        case 1:
            mp.set_property_native("time-pos", 0);
            mp.set_property("pause", "no");
            break;
        case 2:
            if (currentIndex >= playlist.length-1) {
                mp.command('playlist-play-index 0');
            } else {
                mp.command('playlist-next');
            }

            mp.set_property_native("time-pos", 0);
            mp.set_property("pause", "no");
            break;
        case 3:
            if (playlist.length > 1) {
                var index = RandomInt(playlist.length);
                while (index == currentIndex) index = RandomInt(playlist.length);
                mp.command('playlist-play-index ' + index);
            }
            mp.set_property_native("time-pos", 0);
            mp.set_property("pause", "no");
            break;
    }
}

mp.observe_property("pause", "bool", on_change);
mp.add_key_binding(null, 'loopPlaylist', loopPlaylist);
