program TogglePasswordProtectedSharing;

{$APPTYPE CONSOLE}

uses
  Windows, Messages, StrUtils, TNTSystem, TNTSysUtils, Functions;

var
  advancedSharing: HWND = 0;
  bEnable: Boolean = False;

function EnumChildren(hControl: HWND; lParam: LPARAM): BOOL; stdcall;
var
  className: array[0..259] of Char;
  buttonText: String;
  bPress: Boolean;
  Len: Integer;
begin
  Result := True;
  GetClassName(hControl, className, Length(ClassName));
  if (className <> 'Button') then Exit;

  buttonText := '';
  Len := SendMessage(hControl, WM_GETTEXTLENGTH, 0, 0);
  if (Len <= 0) then Exit;

  SetLength(buttonText, Len);
  SendMessage(hControl, WM_GETTEXT, Len+1, Windows.LPARAM(PChar(buttonText)));

  bPress := False;
  if ((not bEnable) and AnsiContainsText(buttonText, 'Turn off password protected sharing')) then bPress := True;
  if (bEnable and AnsiContainsText(buttonText, 'Turn on password protected sharing')) then bPress := True;
  if AnsiContainsText(buttonText, 'Save changes') then bPress := True;

  if (not bPress) then Exit;
  PostMessage(hControl, WM_SETFOCUS, 0, 0);
  PostMessage(hControl, BM_CLICK, 0, 0);
end;


begin
  if (not IsAdminAccount) or ((ParamStr(1) <> '0') and (ParamStr(1) <> '1')) then begin
    WriteLn('This application will only work with the English version of Windows 10.');
    WriteLn('This application will only work with an admin account.', #10);
    WriteLn('Usage:');
    WriteLn('  Usage: ', WideExtractFileName(WideParamStr(0)), ' 0 -> Turn off password protected sharing');
    WriteLn('  Usage: ', WideExtractFileName(WideParamStr(0)), ' 1 -> Turn on password protected sharing');
    Exit;
  end;

  bEnable := (ParamStr(1) = '1');
  advancedSharing := FindWindow(nil, 'Advanced sharing settings');
  if (advancedSharing <> 0) then TerminateProcess(OpenProcess(PROCESS_TERMINATE, False, GetPIDFromHWND(advancedSharing)), 0);
  WinExec('control.exe /name Microsoft.NetworkAndSharingCenter /page Advanced', SW_SHOW);

  repeat
    advancedSharing := FindWindow(nil, 'Advanced sharing settings');
    Sleep(1);
  until (advancedSharing <> 0);

  Sleep(100);
  while not IsWindowVisible(advancedSharing) do Sleep(1);
  ShowWindow(advancedSharing, SW_HIDE);

  Sleep(1000);
  SetForegroundWindow(advancedSharing);
  EnumChildWindows(advancedSharing, @EnumChildren, 0);

  Sleep(1000);
  TerminateProcess(OpenProcess(PROCESS_TERMINATE, False, GetPIDFromHWND(advancedSharing)), 0);
end.
