program MPV;

{$R mpv.res}

uses
  Windows, Classes, Messages, SysUtils, ShellAPI, DateUtils, Dialogs,
  TNTSystem, TNTSysUtils, TNTClasses, TNTDialogs, ZipForge, Functions,
  WinXP;

const
  MPV_REPLACE = 1;
  MPV_APPEND = 2;
  MPV_PARAMETERS = '--input-ipc-server=\\.\pipe\mpvsocket --idle';
  MPV_STARTTITLE = 'No file - mpv';
  MPV_UNPAUSE_COMMAND = '{"command": ["set_property", "pause", false]}' + #13#10;
  UPDATE_TIMEOUT = 100;


//===============================================================================================================================
//+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
//===============================================================================================================================

//ClearWatch
procedure ClearWatch;
var
  srSearch: TWIN32FindDataW;
  hSearch: THandle;
  FileDate: TDateTime;
  Path: WideString;
begin
  Path := GetEnvironmentVariable('AppData') + '\mpv\watch_later\';
  hSearch := FindFirstFileW(PWideChar(Path + '\*.*'), srSearch);

  if (hSearch <> INVALID_HANDLE_VALUE) then begin
    repeat
      try
        if not (((srSearch.dwFileAttributes and faDirectory) = 0)) then Continue;
        FileDate := FileDateToDateTime(WideFileAge(Path + srSearch.cFileName));
        if DaysBetween(Now, FileDate) >= 30 then DeleteFileW(PWideChar(Path + srSearch.cFileName));
      except
        Continue;
      end;
    until not FindNextFileW(hSearch, srSearch);
    Windows.FindClose(hSearch);
  end;
end;
//ClearWatch


//SendMessage
procedure SendMessage(Command: WideString);
var
  Handle, BytesWritten: THandle;
  pipeMessage: String;
begin
  pipeMessage := UTFEncode(Command);
  Handle := CreateFile('\\.\pipe\mpvsocket', GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_FLAG_WRITE_THROUGH, 0);
  WriteFile(Handle, pipeMessage[1], Length(pipeMessage), BytesWritten, nil);
  CloseHandle(Handle);
end;
//SendMessage


//FormatFile
function FormatFile(FileName: WideString; MPVOption: Integer): WideString;
begin
  //Replace filename with double slashes
  FileName := TNT_WideStringReplace(FileName, '\', '\\', [rfReplaceAll, rfIgnoreCase]);

  //Choose way to load file
  case MPVOption of
    MPV_REPLACE: FileName := 'loadfile "' + FileName + '" replace' + #13#10;
    MPV_APPEND: FileName := 'loadfile "' + FileName + '" append-play' + #13#10;
  end;

  Result := FileName;
end;
//FormatFile


//Extract
procedure Extract;
var
  ZipForge: TZipForge;
begin
  ZipForge := TZipForge.Create(nil);
  ZipForge.OpenArchive(TResourceStream.Create(HInstance, 'MPV', RT_RCDATA), False);
  ZipForge.BaseDir := GetEnvironmentVariable('TEMP') +'\MPV';
  ZipForge.ExtractFiles('*.*');
  ZipForge.CloseArchive();
  ZipForge.Free;

  SaveResource(GetEnvironmentVariable('TEMP') +'\MPV\input.conf', 'INPUT', RT_RCDATA);
  SaveResource(GetEnvironmentVariable('TEMP') +'\MPV\mpv.conf', 'CONF', RT_RCDATA);
  ClearWatch;
end;
//Extract

//===============================================================================================================================
//+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
//===============================================================================================================================


var
  hMutex, ProccessHandle: THandle;
begin
  //Create mutex
  hMutex := CreateMutex(nil, False, 'MPV');

  //Check for already running instance
  if not (WaitForSingleObject(hMutex, 0) <> WAIT_TIMEOUT) then begin
    if (WideParamStr(1) <> '') then SendMessage(FormatFile(WideParamStr(1), MPV_REPLACE) + MPV_UNPAUSE_COMMAND);
    Exit;
  end;

  //Extract and launch MPV
  if not WideFileExists(GetEnvironmentVariable('TEMP') + '\MPV\mpv.exe') then Extract;
  ProccessHandle := ExecuteProcess(GetEnvironmentVariable('TEMP') + '\MPV\mpv.exe', MPV_PARAMETERS, SW_SHOW);

  //Wait for window to appear
  while (FindWindowExtd(MPV_STARTTITLE) = 0) do Sleep(UPDATE_TIMEOUT);

  //Load file if exists
  if (WideParamStr(1) <> '') then SendMessage(FormatFile(WideParamStr(1), MPV_REPLACE) + MPV_UNPAUSE_COMMAND);

  WaitForSingleObject(ProccessHandle, INFINITE);
  DeleteDirectory(GetEnvironmentVariable('TEMP') + '\MPV');
end.