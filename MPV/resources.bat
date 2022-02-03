@echo off
del mpv.res
powershell.exe -Command "Compress-Archive mpv\mpv.exe mpv.zip -Force"
powershell.exe -Command "Compress-Archive mpv\helper.exe mpv.zip -Update"
powershell.exe -Command "Compress-Archive mpv\scripts mpv.zip -Update"
BRCC32 mpv.rc
del mpv.zip
timeout /t 5 /nobreak