@echo off

rem Allow local variables to be created
setlocal ENABLEDELAYEDEXPANSION

rem Globally enable or disable display of commands that are run at compile time
set echo_stat=off

rem Create variables
set CurDir=%CD%
set CurDir2=%CurDir:\=/%
set CurDir3=%CurDir2: =\ %
set GCC_FOLDER_NAME=mingw64

rem Move into the Backend folder, where all the magic happens
cd Backend
:start

rem Cleanup, it rebuild later
if exist objects.list del objects.list
if exist bootx64.efi del bootx64.efi
if exist output.map del output.map
if exist bootx64.d del bootx64.d
if exist bootx64.o del bootx64.o
if exist bootx64.out del bootx64.out

rem Also Need to tell GCC where to find as and ld
set PATH=%CD%\%GCC_FOLDER_NAME%\bin;%PATH%

rem Create the HFILES variable, which contains the massive set of includes (-I) needed by GCC.
set HFILES="%CurDir%\inc\"

rem Loop through the h_files.txt file and turn each include directory into -I strings
FOR /F "tokens=*" %%h IN ('type "%CurDir%\Backend\h_files.txt"') DO set HFILES=!HFILES! -I"%%h"

rem Converts backslashes into forward slashes on Windows.
set HFILES=%HFILES:\=/%

rem Loop through and compile the backend .c files, which are listed in c_files_windows.txt
@echo %echo_stat%
FOR /F "tokens=*" %%f IN ('type "%CurDir%\Backend\c_files_windows.txt"') DO "%GCC_FOLDER_NAME%\bin\gcc.exe" -ffreestanding -fshort-wchar -fno-stack-protector -fno-stack-check -fno-strict-aliasing -mno-stack-arg-probe -fno-merge-all-constants -m64 -mno-red-zone -DGNU_EFI_USE_MS_ABI -maccumulate-outgoing-args --std=c11 -I!HFILES! -Og -g3 -Wall -Wextra -Wdouble-promotion -fmessage-length=0 -c -MMD -MP -Wa,-adhln="%%~df%%~pf%%~nf.out" -MF"%%~df%%~pf%%~nf.d" -MT"%%~df%%~pf%%~nf.o" -o "%%~df%%~pf%%~nf.o" "%%~ff"
@echo off

rem Compile user .c files
@echo on
"%GCC_FOLDER_NAME%\bin\gcc.exe" -ffreestanding -fshort-wchar -fno-stack-protector -fno-stack-check -fno-strict-aliasing -fno-merge-all-constants -mno-stack-arg-probe -m64 -mno-red-zone -DGNU_EFI_USE_MS_ABI -maccumulate-outgoing-args --std=c11 -I!HFILES! -Og -g3 -Wall -Wextra -Wdouble-promotion -fmessage-length=0 -c -MMD -MP -Wa,-adhln="%CurDir2%\Backend\bootx64.out" -MF"%CurDir2%\Backend\bootx64.d" -MT"%CurDir2%\Backend\bootx64.o" -o "%CurDir2%\Backend\bootx64.o" "%CurDir2%\bootx64.c"
@echo off

rem Create OBJECTS variable, whose sole purpose is to allow conversion of backslashes into forward slashes in Windows
set OBJECTS=

rem Create the objects.list file, which contains properly-formatted
FOR /F "tokens=*" %%f IN ('type "%CurDir%\Backend\c_files_windows.txt"') DO (set OBJECTS="%%~df%%~pf%%~nf.o" & set OBJECTS=!OBJECTS:\=/! & set OBJECTS=!OBJECTS: =\ ! & set OBJECTS=!OBJECTS:"\ \ ="! & echo !OBJECTS! >> objects.list)

rem Add compiled user .o files to objects.list
FOR %%f IN ("%CurDir2%/Backend/*.o") DO echo "%CurDir3%/Backend/%%~nxf" >> objects.list

rem Link the object files using all the objects in objects.list to generate the output binary, which is called "bootx64.efi"
@echo on
"%GCC_FOLDER_NAME%\bin\gcc.exe" -nostdlib -Wl,--warn-common -Wl,--no-undefined -Wl,-dll -s -shared -Wl,--subsystem,10 -e UefiMain -Wl,-Map=output.map -o "bootx64.efi" @"objects.list"
@echo off

rem "%GCC_FOLDER_NAME%\bin\objcopy.exe" -O binary "program.exe" "program.bin"
"%GCC_FOLDER_NAME%\bin\size.exe" "bootx64.efi"
echo.

if not exist "bootx64.efi" goto :end
if not exist "%CD%\Testing" mkdir "%CD%\Testing"
if not exist "%CD%\Testing\EFI" mkdir "%CD%\Testing\EFI"
if not exist "%CD%\Testing\EFI\BOOT" mkdir "%CD%\Testing\EFI\BOOT"
copy /Y "bootx64.efi" "%CD%\Testing\EFI\BOOT\BOOTX64.EFI"
start qemu-system-x86_64.exe -machine q35 -m 256M -drive if=pflash,format=raw,readonly=on,file="%CD%\OVMF_CODE.fd" -hda fat:rw:"%CD%\Testing"

:end
echo.
del /s /q *.d >nul 2>nul
del /s /q *.o >nul 2>nul
del /s /q *.out >nul 2>nul
del /s /q *.map >nul 2>nul
del /s /q *.list >nul 2>nul
echo Press any key to rebuild again...
pause >nul
taskkill /f /im qemu-system-x86_64.exe >nul 2>nul
cls
goto :start
endlocal