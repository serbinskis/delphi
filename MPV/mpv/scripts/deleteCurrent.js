function hexEncode(s) {
    var result = "";

    for (var i = 0; i < s.length; i++) {
        result += ("000"+s.charCodeAt(i).toString(16)).slice(-4);
    }

    return result
}

function deleteCurrent() {
    var playlist = mp.get_property_native('playlist');
    if ((playlist === undefined) || (playlist.length <= 0)) return;

    for (var i = 0; i < playlist.length; i++) {
        if (playlist[i] && playlist[i].current) {
            var currentItem = playlist[i];
            var currentIndex = i;
        }
    }
    
    if (playlist.length == 1) {
        mp.command('run helper.exe -recycle ' + hexEncode(currentItem.filename));
        mp.command('playlist-play-index none');
        return;
    } else if (playlist.length-1 == currentIndex) {
        mp.command('playlist-prev');
        mp.command('playlist_remove ' + currentIndex);
        mp.set_property("pause", "no");
        mp.command('run helper.exe -recycle ' + hexEncode(currentItem.filename));
    } else {
        mp.command('playlist-next');
        mp.command('playlist_remove ' + currentIndex);
        mp.set_property("pause", "no");
        mp.command('run helper.exe -recycle ' + hexEncode(currentItem.filename));
    }
}

mp.add_key_binding(null, 'deleteCurrent', deleteCurrent);
