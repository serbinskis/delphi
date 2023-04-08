program PortableApp;

uses
  Windows, Classes, SysUtils, StrUtils, TNTSysUtils, ZipForge, Functions;

const
  FOLDER_NAME = '';
  EXECUTABLE_NAME = '';

var
  hMutex, hProcess: THandle;
  ZipArchive: TZipForge;
begin
  hMutex := CreateMutex(nil, False, PChar(StringReplace(ReverseString(FOLDER_NAME), ' ', '_', [rfReplaceAll, rfIgnoreCase])));
  if (WaitForSingleObject(hMutex, 0) = WAIT_TIMEOUT) then Exit;

  if not WideFileExists(GetTempDirectory + FOLDER_NAME + '\' + EXECUTABLE_NAME) then begin
    ZipArchive := TZipForge.Create(nil);
    ZipArchive.OpenArchive(TResourceStream.Create(HInstance, 'ARCHIVE', RT_RCDATA), False);
    ZipArchive.BaseDir := GetTempDirectory + FOLDER_NAME;
    ZipArchive.ExtractFiles('*.*');
    ZipArchive.CloseArchive;
  end;

  hProcess := ExecuteProcess(GetTempDirectory + FOLDER_NAME + '\' + EXECUTABLE_NAME, '', SW_SHOW);
  if (hProcess > 0) then WaitForSingleObject(hProcess, INFINITE);

  while not WideDeleteFile(GetTempDirectory + FOLDER_NAME + '\' + EXECUTABLE_NAME) do Sleep(500);
  DeleteDirectory(GetTempDirectory + FOLDER_NAME);
end.
