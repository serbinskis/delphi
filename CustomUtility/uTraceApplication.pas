unit uTraceApplication;

interface

uses 
  SysUtils, Windows, Messages, ShellAPI, TlHelp32, ActiveX, Variants, StrUtils,
  ComObj, PsAPI, StdCtrls, Forms, Dialogs, Controls, TNTStdCtrls, TNTSysUtils,
  TNTClasses, Functions;

type
  CustomArray = array of Integer;

var
  Operation: Boolean = False;
  LaunchedPIDArray: CustomArray;
  ParentPIDArray: CustomArray;

const
  ExcludedProcesses: array [0..1] of WideString = ('conhost.exe', 'svchost.exe');

procedure TraceApplication(var Msg: TMessage);
function GetCommandLineFromPID(ProcessID: DWORD): WideString;
function GetProccessName(ProcessID: DWORD): WideString;
function ExecuteGetPID(FileName: WideString): DWORD;

implementation

uses CustomUtility;


//AddToArray
procedure AddToArray(var A: CustomArray; PID: Integer);
begin
  SetLength(A, Length(A)+1);
  A[Length(A)-1] := PID;
end;
//AddToArray


//ContainsArray
function ContainsArray(var A: CustomArray; PID: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;

  for i := Low(A) to High(A) do begin
    if A[i] = PID then begin
      Result := True;
      Break;
    end;
  end;
end;
//ContainsArray


//ContainsArrayString
function ContainsArrayString(Process: WideString): Boolean;
var
  i: Integer;
begin
  Result := False;

  for i := Low(ExcludedProcesses) to High(ExcludedProcesses) do begin
    if ExcludedProcesses[i] = Process then begin
      Result := True;
      Break;
    end;
  end;
end;
//ContainsArrayString


//GetCommandLineFromPID
function GetCommandLineFromPID(ProcessID: DWORD): WideString;
var
  FSWbemLocator: OLEVariant;
  FWMIService: OLEVariant;
  FWbemObjectSet: OLEVariant;
begin;
  try
    FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
    FWMIService := FSWbemLocator.ConnectServer('localhost', 'root\CIMV2', '', '');
    FWbemObjectSet := FWMIService.Get(Format('Win32_Process.Handle="%d"',[ProcessID]));
    Result := VarToWideStr(FWbemObjectSet.CommandLine);
  except
    Result := 'null';
  end;
end;
//GetCommandLineFromPID


//GetProccessName
function GetProccessName(ProcessID: DWORD): WideString;
var
  hProcess: THandle;
  Path: array[0..MAX_PATH - 1] of WideChar;
begin
  if ProcessID <> 0 then begin
    hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, false, ProcessID);
    GetModuleFileNameExW(hProcess, 0, Path, MAX_PATH);
    Result := WideExtractFileName(Path);
  end;
end;
//GetProccessName


//ExecuteGetPID
function ExecuteGetPID(FileName: WideString): DWORD;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  StartupInfo.cb := SizeOf(StartupInfo);
  CreateProcessW(nil, PWideChar('"' + FileName + '"'), nil, nil, false, 0, nil, PWideChar(WideExtractFilePath(FileName)), StartupInfo, ProcessInfo);
  Result := ProcessInfo.dwProcessId;
end;
//ExecuteGetPID


//WriteListBox
procedure WriteListBox(S: WideString);
begin
  Form1.TNTListBox6.Items.Strings[Form1.TNTListBox6.Items.Count] := S;
  Form1.TNTListBox6.Selected[Form1.TNTListBox6.Items.Count-1] := True;
end;
//WriteListBox


//TraceApplication
procedure TraceApplication(var Msg: TMessage);
var
  hDrop: THandle;
  Proccess: TProcessEntry32W;
  Snapshot: THandle;
  ProccessID: DWORD;
  buttonSelected, Len: Integer;
  Executable: WideString;
begin
  if Operation then Exit;
  buttonSelected := MessageDlg('Do you want to run this executable?', mtConfirmation, [mbYes, mbNo], 0);
  if buttonSelected <> mrYes then Exit;

  Form1.StaticText6.Hide;
  Form1.TNTListBox6.Clear;
  Form1.TNTListBox6.Enabled := True;
  Operation := True;

  hDrop := Msg.wParam;
  Len := DragQueryFileW(hDrop, 0, nil, 0)+1;
  SetLength(Executable, Len);
  DragQueryFileW(hDrop, 0, Pointer(Executable), Len);
  Executable := Trim(Executable);
  DragFinish(hDrop);

  ProccessID := ExecuteGetPID(Executable);
  AddToArray(ParentPIDArray, ProccessID);

  SetConsoleTitleW(PWideChar('TraceApplication -> ' + IntToStr(ProccessID) + ': ' + WideExtractFileName(Executable)));
  CoInitialize(nil);

  while true do begin
    Snapshot := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
    Proccess.dwSize := SizeOf(TProcessEntry32W);
    Process32FirstW(Snapshot, Proccess);
    repeat
      if not ContainsArray(LaunchedPIDArray, Proccess.th32ProcessID) then
      if ContainsArray(ParentPIDArray, Proccess.th32ParentProcessID) then
      if not ContainsArrayString(Proccess.szExeFile) then
      if Length(GetProccessName(Proccess.th32ParentProcessID)) > 1 then begin
        AddToArray(LaunchedPIDArray, Proccess.th32ProcessID);
        AddToArray(ParentPIDArray, Proccess.th32ProcessID);

        WriteListBox(IntToStr(Proccess.th32ParentProcessID) + ': ' + GetProccessName(Proccess.th32ParentProcessID) + ' -> ' + IntToStr(Proccess.th32ProcessID) + ': ' + Proccess.szExeFile);
        WriteListBox('Command Line -> ' + GetCommandLineFromPID(Proccess.th32ProcessID));
        WriteListBox(#13#10 + '-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' + #13#10);
      end;
    until not Process32NextW(Snapshot, Proccess);
    Application.ProcessMessages();

    if not PIDExists(ProccessID) then begin
      WriteListBox('Process exited.');
      WriteListBox(#13#10 + '-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' + #13#10);
      Operation := False;
      Break;
    end;
  end;
end;
//TraceApplication

end.

