program Helper;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows, ShellAPI, Dialogs, Classes,
  TNTSystem, TNTSysUtils, TNTDialogs, WinXP, Functions;

const
  MPV_DIALOG = 'Open: MPV';

type
  TEventHandler = class
    procedure OnShow(Sender: TObject);
  end;

var
  Parameter: WideString;
  OpenDialog: TTNTOpenDialog;
  hMainHandle: HWND;
  LWndClass: TWndClass;
  EventHandler: TEventHandler;


function HexDecode(S: String): WideString;
var
  i: Integer;
begin
  Result := '';

  for i := 0 to (Length(S) div 4)-1 do  begin
    Result := Result + WideChar(StrToInt('$' + Copy(S, i*4+1, 4)));
  end;
end;


procedure TEventHandler.OnShow(Sender: TObject);
var
  Handle: HWND;
  Buffer: array [0..127] of Char;
begin
  Handle := GetWindow(hMainHandle, GW_HWNDFIRST);

  while Handle <> 0 do begin
    GetWindowText(Handle, Buffer, SizeOf(Buffer));
    if StrPas(Buffer) = MPV_DIALOG then begin
      SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
      Break;
    end;
    Handle := GetWindow(Handle, GW_HWNDNEXT);
  end;
end;


function WindowProc(hWnd, Msg: Longint; wParam: WPARAM; lParam: LPARAM): Longint; stdcall;
begin
  Result := DefWindowProc(hWnd, Msg, wParam, lParam);
end;


begin
  if AnsiLowerCase(ParamStr(1)) = '-recycle' then begin
    Parameter := HexDecode(WideParamStr(2));
    if WideFileExists(Parameter) then MoveToRecycleBin(Parameter);
  end;

  if AnsiLowerCase(ParamStr(1)) = '-location' then begin
    Parameter := WideExtractFileDir(HexDecode(WideParamStr(2)));
    ShellExecuteW(0, 'open', PWideChar(Parameter), nil, nil, SW_SHOW);
  end;

  if AnsiLowerCase(ParamStr(1)) = '-opendialog' then begin
    LWndClass.hInstance := HInstance;
    LWndClass.lpszClassName := 'MPVHelper' + 'Wnd';
    LWndClass.Style := CS_PARENTDC;
    LWndClass.lpfnWndProc := @WindowProc;

    Windows.RegisterClass(LWndClass);
    hMainHandle := CreateWindow(LWndClass.lpszClassName, 'MPVHelper', 0,0,0,0,0,0,0, HInstance, nil);
    ShowWindow(hMainHandle, SW_HIDE);
    EventHandler := TEventHandler.Create;

    OpenDialog := TTNTOpenDialog.Create(nil);
    OpenDialog.Options := [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing];
    OpenDialog.Title := MPV_DIALOG;
    OpenDialog.OnShow := EventHandler.OnShow;

    if not OpenDialog.Execute then Exit;
    OpenDialog.Files.Delimiter := #10;
    Write(UTFEncode(TNT_WideStringReplace(OpenDialog.Files.DelimitedText, '"', '', [rfReplaceAll, rfIgnoreCase])));
  end;
end.
