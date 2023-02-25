var loops = {
    0: 'Playlist: None',
    1: 'Playlist: Loop File',
    2: 'Playlist: Loop Playlist',
    3: 'Playlist: Shuffle',
    4: 'Playlist: Shuffle (Non repeating)',
}

var loop = 0;
var prev_list_limit = 1000;
var current_saved = '';
var loading_next = false;
var loading_prev = false;
var prev_list = [];
var next_list = [];
var shuffle = [];

function randomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
}

function getCurrentIndex() {
    var playlist = mp.get_property_native('playlist');
    if ((playlist === undefined) || (playlist.length <= 0)) return -1;

    for (var i = 0; i < playlist.length; i++) {
        if (playlist[i] && playlist[i].current) {
            return i;
        }
    }

    return -1;
}

function getIndexByFilename(filename) {
    var playlist = mp.get_property_native('playlist');
    if ((playlist === undefined) || (playlist.length <= 0)) return -1;

    for (var i = 0; i < playlist.length; i++) {
        if (playlist[i] && (playlist[i].filename == filename)) {
            return i;
        }
    }

    return -1;
}

function getShuffled() {
    var playlist = mp.get_property_native('playlist');
    var currentIndex = getCurrentIndex();
    var shuffled = [];

    //Loop trought playlist and compare if media was already played
    //before, aka, is in shuffle list, then it should be excluded
    for (var i = 0; i < playlist.length; i++) {
        if (!playlist[i]) { continue; }
        var found = false;

        for (var j = 0; j < shuffle.length; j++) {
            if (playlist[i].filename != shuffle[j].filename) { continue; }
            found = true;
            break;
        }

        //If media was not found played before add it to available shuffled list
        if (!found) { shuffled.push({ index: i, filename: playlist[i].filename }); }
    }

    //If we ran out of non repeating media
    //then reset list, aka, shuffle list
    //and run this shit again
    if (shuffled.length <= 0) {
        shuffle = [];
        return getShuffled();
    }

    //Select random media from shuffled list
    //Selected media cannot be current media
    var shuffledIndex = currentIndex;
    while (shuffledIndex == currentIndex) {
        shuffledIndex = shuffled[randomInt(shuffled.length)].index;
    }

    //Add selected media to shuffle list, so it doesn't repeat again
    shuffle.push({ index: shuffledIndex, filename: playlist[shuffledIndex].filename });

    //Return shuffled list and selected random index
    return [shuffledIndex, shuffled];
}

function doPlaylist() {
    var playlist = mp.get_property_native('playlist');
    if ((playlist === undefined) || (playlist.length <= 0)) { return false; }
    var currentIndex = getCurrentIndex();

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
        case 4:
            if (playlist.length > 1) {
                mp.command('playlist-play-index ' + getShuffled()[0]);
            }
            break;
    }

    mp.set_property_native('time-pos', 0);
    mp.set_property('pause', 'no');
    return true;
}



mp.observe_property('pause', 'bool', function(name, value) {
    if ((mp.get_property_native('time-remaining') >= 0.5) || !value) return;
    doPlaylist();
});

mp.register_event('file-loaded', function() {
    var playlist = mp.get_property_native('playlist');
    var currentIndex = getCurrentIndex();

    if (!loading_prev && (current_saved != '')) {
        prev_list.push(current_saved);
        prev_list = prev_list.slice(-prev_list_limit);
        if (!loading_next) { next_list = []; }
    }

    current_saved = playlist[currentIndex].filename;
    loading_next = false;
    loading_prev = false;
    mp.commandv('show-text', ((currentIndex+1) + '/' + playlist.length));
});

mp.add_key_binding(null, 'play-next', function() {
    var saved_loop = loop;
    loop = 2;
    doPlaylist();
    loop = saved_loop;
});

mp.add_key_binding(null, 'play-prev', function() {
    var saved_loop = loop;
    loop = -1;
    doPlaylist();
    loop = saved_loop;
});

mp.add_key_binding(null, 'obey-next', function() {
    if (next_list.length > 0) {
        var index = -1;

        while (index < 0) {
            if (next_list.length <= 0) { return; }
            next_filename = next_list.pop();
            index = getIndexByFilename(next_filename);
        }

        loading_next = true;
        mp.command('playlist-play-index ' + index);
        mp.set_property_native('time-pos', 0);
        mp.set_property('pause', 'no');
        return;
    }

    if ((loop == 0) || (loop == 1)) {
        var saved_loop = loop;
        loop = 2;
        doPlaylist();
        loop = saved_loop;
    } else {
        doPlaylist();
    }
});

mp.add_key_binding(null, 'obey-prev', function() {
    var index = -1;

    while (index < 0) {
        if (prev_list.length <= 0) { return; }
        previous_filename = prev_list.pop();
        next_list.push(current_saved);
        index = getIndexByFilename(previous_filename);
    }

    loading_prev = true;
    mp.command('playlist-play-index ' + index);
    mp.set_property_native('time-pos', 0);
    mp.set_property('pause', 'no');
});

mp.add_key_binding(null, 'loop-playlist', function() {
    loop = (loop+1) % Object.keys(loops).length;
    mp.commandv('show-text', loops[loop]);
});