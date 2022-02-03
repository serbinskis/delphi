function openDialog() {
    var was_ontop = mp.get_property_native("ontop");
    if (was_ontop) mp.set_property_native("ontop", false);
    
	var res = mp.utils.subprocess({
        'args': ['helper.exe', '-OpenDialog'],
        'cancellable': false
    });

    if (was_ontop) mp.set_property_native("ontop", true);
    if ((res.status != 0) || (!res.stdout)) return;
    var filenames = res.stdout.split('\n');

    for (var i = 0; i < filenames.length; i++) {
        mp.commandv('loadfile', filenames[i], ((i == 0) ? 'replace' : 'append-play'));
        if (i == 0) mp.set_property("pause", "no");
    }
}

mp.add_key_binding(null, 'openDialog', openDialog);
