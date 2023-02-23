var loops = {
    0: 'Playlist: None',
    1: 'Playlist: Loop File',
    2: 'Playlist: Loop Playlist',
    3: 'Playlist: Shuffle',
}

var loop = 0;

function randomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
}

function doPlaylist() {
    var playlist = mp.get_property_native('playlist');
    if ((playlist === undefined) || (playlist.length <= 0)) return;

    for (var i = 0; i < playlist.length; i++) {
        if (playlist[i] && playlist[i].current) {
            var currentIndex = i;
            break;
        }
    }

    switch (loop) {
        case -1:
            if (currentIndex == 0) {
                mp.command('playlist-play-index ' + (playlist.length-1));
            } else {
                mp.command('playlist-prev');
            }
            break;
        case 1:
            break;
        case 2:
            if (currentIndex >= playlist.length-1) {
                mp.command('playlist-play-index 0');
            } else {
                mp.command('playlist-next');
            }
            break;
        case 3:
            if (playlist.length > 1) {
                var index = randomInt(playlist.length);
                while (index == currentIndex) index = randomInt(playlist.length);
                mp.command('playlist-play-index ' + index);
            }
            break;
    }

    mp.set_property_native("time-pos", 0);
    mp.set_property("pause", "no");
}



mp.observe_property("pause", "bool", function(name, value) {
    if ((mp.get_property_native('time-remaining') >= 0.5) || !value) return;
    doPlaylist();
});

mp.add_key_binding(null, 'playNext', function() {
    var arg0 = (loop == 0);
    if (arg0) { loop = 2; }
    doPlaylist();
    if (arg0) { loop = 0; }
});

mp.add_key_binding(null, 'playPrev', function() {
    if ((loop == 0) || (loop == 2)) {
        var saved_loop = loop;
        loop = -1;
        doPlaylist();
        loop = saved_loop;
    } else {
        doPlaylist();
    }
});

mp.add_key_binding(null, 'loopPlaylist', function() {
    loop = (loop+1) % Object.keys(loops).length;
    mp.commandv("show-text", loops[loop]);
});
