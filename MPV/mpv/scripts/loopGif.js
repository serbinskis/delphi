function file_loaded() {
    var filename = mp.get_property_native('filename');
    var extsenion = filename.split('.').pop().toLowerCase();
    if (extsenion == 'gif') {
        mp.set_property_native("time-pos", 0);
        mp.set_property_native("pause", false);
        mp.set_property_native("loop-file", true);
    }
}

mp.register_event("file-loaded", file_loaded);