unit uBatteryStatus;

interface

uses
  SysUtils, Windows;

procedure BatteryStatus;

implementation

//External functions
function GetConsoleWindow: HWND; stdcall; external kernel32;
function AttachConsole(dwProcessID: Integer): Boolean; stdcall; external 'kernel32.dll';


//BatteryStatus
procedure BatteryStatus;
var
  pSysPowerStatus: SYSTEM_POWER_STATUS;
  BatteryLifePercent: Integer;
  BatteryChargingState: Integer;
  BatteryChargingString: String;
  startUpInfo: TStartUpInfo;
  ProcInfo: TProcessInformation;
  WindowRect: TRect;
  Point: TPoint;
  X, Y: Integer;
begin
  FillChar(startUpInfo, SizeOf(TStartUpInfo), 0);
  startUpInfo.cb := SizeOf(TStartUpInfo);
  startUpInfo.wShowWindow := SW_HIDE;
  startUpInfo.dwFlags := STARTF_USESHOWWINDOW;

  if CreateProcess(PChar(paramstr(0)), PChar('"' + paramstr(0) + '" -AllocConsole'), nil, nil, true, NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcInfo) then begin
    while not AttachConsole(ProcInfo.dwProcessId) do Sleep(10);
    TerminateProcess(ProcInfo.hProcess, 0);
    SetConsoleTitle('BatteryStatus');

    GetWindowRect(GetConsoleWindow, WindowRect);
    GetCursorPos(Point);
    X := Round(Point.X - ((WindowRect.Right - WindowRect.Left) / 2));
    Y := Round(Point.Y - ((WindowRect.Bottom - WindowRect.Top) / 2));
    while not SetWindowPos(GetConsoleWindow, HWND_TOP, X, Y, 0, 0, SWP_NOSIZE) do Sleep(10);
    SetActiveWindow(GetConsoleWindow);
    SetForegroundWindow(GetConsoleWindow);
    ShowWindow(GetConsoleWindow, SW_SHOW);
  end;

  BatteryLifePercent := 0;
  BatteryChargingState := 0;

  while true do begin
    Sleep(1000);
    GetSystemPowerStatus(pSysPowerStatus);
    if (BatteryLifePercent <> pSysPowerStatus.BatteryLifePercent)
    or (BatteryChargingState <> pSysPowerStatus.ACLineStatus) then begin
      BatteryLifePercent := pSysPowerStatus.BatteryLifePercent;
      BatteryChargingState := pSysPowerStatus.ACLineStatus;
      if BatteryChargingState = 0 then BatteryChargingString := 'disconnected';
      if BatteryChargingState = 1 then BatteryChargingString := 'connected';
      WriteLn('Battery life percent is ', BatteryLifePercent, '%', ' | ', TimeToStr(Now), ' | AC is ', BatteryChargingString)
    end;
  end;
end;
//BatteryStatus

end.

