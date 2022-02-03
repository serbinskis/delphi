unit uTemperature;

interface

uses 
  Windows, SysUtils, Classes, Controls, Dialogs;

type
  TStringArray = array of string;

const
  Days : array[1..7] of string = ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday') ;
  R = 150;
  G = 75;
  B = 0;

procedure EnableTemperature;
procedure DisableTemperature;
procedure ResetTemperature;
procedure PrepareConsole(LogList: TStringList);
procedure AddToArray(text: String; var LogList: TStringList);
procedure Temperature;

implementation

//External functions
function GetConsoleWindow: HWND; stdcall; external kernel32;
function AttachConsole(dwProcessID: Integer): Boolean; stdcall; external 'kernel32.dll';


//EnableTemperature
procedure EnableTemperature;
var
  GammaArray: array[0..2, 0..255] of Word;
  i, x, Red, Green, Blue: Integer;
begin
  for x := 1 to 8 do begin
   for i := 0 to 255 do begin
      Red := i * (128 + 128 + Round(x * ((R - 128) / 8 ))); //150
      if Red > 65535 then GammaArray[0, i] := 65535 else GammaArray[0, i] := Red; //Red
      Green := i * (128 + 128 + Round(x * ((G - 128) / 8 ))); //75
      if Green > 65535 then GammaArray[1, i] := 65535 else GammaArray[1, i] := Green; //Green
      Blue := i * (128 + 128 + Round(x * ((B - 128) / 8 ))); //0
      if Blue > 65535 then GammaArray[2, i] := 65535 else GammaArray[2, i] := Blue; //Blue
   end;
   SetDeviceGammaRamp(GetDC(0), GammaArray);
   Sleep(50);
  end;
end;
//EnableTemperature


//DisableTemperature
procedure DisableTemperature;
var
  GammaArray: array[0..2, 0..255] of Word;
  i, x, Red, Green, Blue: Integer;
begin
  for x := 1 to 8 do begin
   for i := 0 to 255 do begin
      Red := i * (R + 128 - Round(x * ((R - 128) / 8 ))); //150
      if Red > 65535 then GammaArray[0, i] := 65535 else GammaArray[0, i] := Red; //Red
      Green := i * (G + 128 - Round(x * ((G - 128) / 8 ))); //75
      if Green > 65535 then GammaArray[1, i] := 65535 else GammaArray[1, i] := Green; //Green
      Blue := i * (B + 128 - Round(x * ((B - 128) / 8 ))); //0
      if Blue > 65535 then GammaArray[2, i] := 65535 else GammaArray[2, i] := Blue; //Blue
   end;
   SetDeviceGammaRamp(GetDC(0), GammaArray);
   Sleep(50);
  end;
end;
//DisableTemperature


//ResetTemperature
procedure ResetTemperature;
var
  GammaArray: array[0..2, 0..255] of Word;
  i, Value: Integer;
begin
  for i := 0 to 255 do begin
    Value := i * (128 + 128);
    if Value > 65535 then Value := 65535;
    GammaArray[0, i] := Value; //Red
    GammaArray[1, i] := Value; //Green
    GammaArray[2, i] := Value; //Blue
  end;
  SetDeviceGammaRamp(GetDC(0), GammaArray);
end;
//ResetTemperature


//PrepareConsole
procedure PrepareConsole(LogList: TStringList);
var
  CharsWritten: DWORD;
  startUpInfo: TStartUpInfo;
  ProcInfo: TProcessInformation;
begin
  FillChar(startUpInfo, SizeOf(TStartUpInfo), 0);
  startUpInfo.cb := SizeOf(TStartUpInfo);
  startUpInfo.wShowWindow := SW_HIDE;
  startUpInfo.dwFlags := STARTF_USESHOWWINDOW;

  if CreateProcess(PChar(paramstr(0)), PChar('"' + paramstr(0) + '" -AllocConsole'), nil, nil, true, NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcInfo) then begin
    while not AttachConsole(ProcInfo.dwProcessId) do Sleep(10);
    TerminateProcess(ProcInfo.hProcess, 0);
    SetConsoleTitle('Temperature');
    DeleteMenu(GetSystemMenu(GetConsoleWindow, false), SC_CLOSE, MF_BYCOMMAND);
    SetWindowLong(GetConsoleWindow, GWL_STYLE, (GetWindowLong(GetConsoleWindow, GWL_STYLE) and -131073 and -65537));

    WriteConsole(GetStdHandle(STD_OUTPUT_HANDLE), Pointer(LogList.Text), Length(LogList.Text), CharsWritten, nil);
    ShowWindow(GetConsoleWindow, SW_SHOW);
  end;
end;
//PrepareConsole


//AddToArray
procedure AddToArray(text: String; var LogList: TStringList);
const
  LogLength = 500;
var
  CharsWritten: Cardinal;
  ConsoleText: String;
begin
  if LogList.Count > 0 then if LogList[LogList.Count-1] = text then exit;
  if GetStdHandle(STD_OUTPUT_HANDLE) <> 0 then begin
    ConsoleText := text + #13#10;
    WriteConsole(GetStdHandle(STD_OUTPUT_HANDLE), Pointer(ConsoleText), Length(ConsoleText), CharsWritten, nil);
  end;
  if LogList.Count = LogLength then LogList.Delete(0);
  if LogList.Count < LogLength then LogList.Add(text);
end;
//AddToArray


//Temperature
procedure Temperature;
label
  Ending;
var
  buttonSelected: Integer;
  hMutex: THandle;
  lpMsg: TMsg;
  Hours, Minutes: Word;
  Seconds, Miliseconds: Word;
  Enabled, Reset, Showed: Boolean;
  StringList: TStringList;
begin
  hMutex := CreateMutex(NIL, False, 'Temperature_');
  if WaitForSingleObject(hMutex, 0) <> wait_TimeOut then begin
    Showed := False;
    Enabled := False;
    Reset := True;
    StringList := TStringList.Create;
    RegisterHotKey(0, 101, MOD_CONTROL or MOD_ALT, VK_F10);
    RegisterHotKey(0, 102, MOD_CONTROL or MOD_ALT, VK_F11);
    RegisterHotKey(0, 103, MOD_CONTROL or MOD_ALT, VK_F12);

    while true do begin
      while PeekMessage(lpMsg, 0, 0, 0, PM_REMOVE) do begin //if lpMsg.Message = WM_HOTKEY then
        if lpMsg.wParam = 101 then begin
          SetActiveWindow(GetConsoleWindow);
          SetForegroundWindow(GetConsoleWindow);
          buttonSelected := MessageDlg('Do you want to close Temperature application?', mtConfirmation, [mbYes,mbNo], 0);
          if buttonSelected = mrYes then Exit;
        end;
        if lpMsg.wParam = 102 then begin
          if Showed = False then begin
            Showed := True;
            PrepareConsole(StringList);
            SetActiveWindow(GetConsoleWindow);
            SetForegroundWindow(GetConsoleWindow);
          end else begin
            Showed := False;
            FreeConsole;
          end;
        end;
        if lpMsg.wParam = 103 then begin
          if Reset = False then begin
            Reset := True;
            AddToArray('Hotkey | Reset Temperature', StringList);
            ResetTemperature;
          end else begin
            Reset := False;
            AddToArray('Hotkey | Enable Temperature', StringList);
            EnableTemperature;
          end;
        end;
      end;

      DecodeTime(Now, Hours, Minutes, Seconds, Miliseconds);
      AddToArray(('[' + IntToStr(DayOfWeek(Date)) + '] Today -> ' + Days[DayOfWeek(Date)] + ' | Hours -> ' + Copy(TimeToStr(Now), 0, 5)), StringList);

      if (Days[DayOfWeek(Date)] <> 'Saturday') and (Days[DayOfWeek(Date)] <> 'Friday') then
      if (Hours >= 21) or (Hours < 6) then
      if Enabled = False then begin
        if (Days[DayOfWeek(Date)] = 'Sunday') and (Hours < 6) then goto Ending;
        Enabled := True;
        AddToArray('Date | Enabling Scheldue', StringList);
        if Reset = True then begin
          AddToArray('Date | Enabling Temperature', StringList);
          EnableTemperature;
          Reset := False;
        end;
      end;

      Ending:

      if (Days[DayOfWeek(Date)] <> 'Saturday') and (Days[DayOfWeek(Date)] <> 'Friday') then
      if (Hours >= 6) and (Hours < 21) then if Enabled = True then begin
        Enabled := False;
        AddToArray('Date | Disabling Scheldue', StringList);
        if Reset = False then begin
          AddToArray('Date | Disabling Temperature', StringList);
          DisableTemperature;
          Reset := True;
        end;
      end;
      Sleep(500);
    end;
  end;
end;
//Temperature

end.

