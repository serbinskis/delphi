function hexEncode(s) {
    var result = "";

    for (var i = 0; i < s.length; i++) {
        result += ("000"+s.charCodeAt(i).toString(16)).slice(-4);
    }

    return result
}

function openCurrent() {
    var filename = mp.get_property_native('path');
    if (filename === undefined) return;
    mp.command('run helper.exe -location ' + hexEncode(filename));
}

mp.add_key_binding(null, 'openCurrent', openCurrent);
