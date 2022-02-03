program MiniRecycleBin;

//{$APPTYPE CONSOLE}

{$R MiniRecycleBin.res}

uses
  Windows, Messages, SysUtils, Classes, ShellAPI, Menus,
  ExtCtrls, Dialogs, Forms, DateUtils, ShlObj, ShellNotify;

type
  TEventHandler = class
    procedure HandlePopupItem(Sender: TObject);
    procedure OnTimer(Sender: TObject);
  end;

type
  TNotifyIconData = record
    cbSize: DWORD;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array [0..63] of AnsiChar;
  end;

type
  PSHQueryRBInfo = ^TSHQueryRBInfo;
  TSHQueryRBInfo = packed record
    cbSize: Integer;
    i64Size: Int64;
    i64NumItems: Int64;
  end;

type
  TSHQueryRecycleBin = function(RootPath: PChar; Query: PSHQueryRBInfo): Integer; stdcall;
  TSHEmptyRecycleBin = function(Wnd: HWND; pszRootPath: PChar; dwFlags: DWORD): HRESULT; stdcall;

const
  UPDATE_TIMEOUT = 1500;
  APP_NAME = 'MiniRecycleBin';
  RECYCLE_BIN = '$RECYCLE.BIN';
  MenuItems: array [0..3] of String = ('Open', 'Empty', 'Update', 'Exit');

var
  TaskbarRestart: Cardinal;
  WM_CALLBACK_MESSAGE: Integer;
  hMainHandle: HWND;
  LibHandle, hMutex: THandle;
  EventHandler: TEventHandler;
  LWndClass: TWndClass;

var
  SHQueryRecycleBin: TSHQueryRecycleBin;
  SHQueryRBInfo: TSHQueryRBInfo;
  SHEmptyRecycleBin: TSHEmptyRecycleBin;

var
  NotifyEvents: TShellNotifyEvents;
  NotifyEntrys: array[0..1023] of SHChangeNotifyEntry;
  Entries: Integer;
  Events: Longint;

var
  TrayIconData: TNotifyIconData;
  PopupMenu: TPopupMenu;
  Item: TMenuItem;
  Timer: TTimer;

var
  ExplorerRestarted: Boolean;
  SavedTime: TDateTime;
  Msg: TMsg;
  i: Integer;


//FormatSize
function FormatSize(x: Int64): String;
begin
  Result := Format('%d Bytes', [x]);
  if x > (1024) then Result := Format('%d KB', [Round(x / 1024)]);
  if x > (1024 * 1024) then Result := Format('%d MB', [Round(x / (1024 * 1024))]);
  if x > (1024 * 1024 * 1024) then Result := Format('%.2f GB', [x / (1024 * 1024 * 1024)]);
end;
//FormatSize


//OutputConsole
procedure OutputConsole(S: String);
begin
  if (GetStdHandle(STD_OUTPUT_HANDLE) <> 0) then WriteLn(S);
end;
//OutputConsole


//UpdateRecycleBin
procedure UpdateRecycleBin;
begin
  if MillisecondsBetween(SavedTime, Now) < UPDATE_TIMEOUT then Exit;
  SavedTime := Now;

  OutputConsole('UpdateRecycleBin');
  EventHandler.OnTimer(nil);
  Timer.Interval := UPDATE_TIMEOUT;
  Timer.Enabled := True;
end;
//UpdateRecycleBin


//RegisterShellNotify
procedure RegisterShellNotify;
begin
  OutputConsole('RegisterShellNotify');

  //Create notify event
  NotifyEvents := [neCreate, neDelete, neMkDir, neRmDir, neUpdateDir, neUpdateItem];
  Events := NotifyEventsToLongint(NotifyEvents);

  //Fill information
  Entries := 1;
  NotifyEntrys[0].pidl := nil;
  NotifyEntrys[0].fRecursive := True;

  //Register notify change
  SHChangeNotifyRegister(hMainHandle, SHCNF_ACCEPT_INTERRUPTS + SHCNF_ACCEPT_NON_INTERRUPTS, Events, WM_SHELLNOTIFY, Entries, @NotifyEntrys);
end;
//RegisterShellNotify


//Process timer events
procedure TEventHandler.OnTimer(Sender: TObject);
begin
  Timer.Enabled := False;
  OutputConsole('Timer event');

  SHQueryRecycleBin(nil, @SHQueryRBInfo);
  StrPCopy(TrayIconData.szTip, FormatSize(SHQueryRBInfo.i64Size));

  if SHQueryRBInfo.i64NumItems <> 0 then begin
    TrayIconData.hIcon := LoadIcon(HInstance, 'RECYCLEFULL');
    PopupMenu.Items[1].Enabled := True;
  end else begin
    TrayIconData.hIcon := LoadIcon(HInstance, 'RECYCLEEMPTY');
    PopupMenu.Items[1].Enabled := False;
  end;

  if ExplorerRestarted then begin
    ExplorerRestarted := False;
    Shell_NotifyIcon(NIM_ADD, @TrayIconData);
    RegisterShellNotify;
  end else begin
    Shell_NotifyIcon(NIM_MODIFY, @TrayIconData);
  end;
end;
//Process timer events


//Process popup menu events
procedure TEventHandler.HandlePopupItem(Sender: TObject);
begin
  if TMenuItem(Sender).Caption = 'Open' then begin
    ShellExecute(0, 'open', PChar('shell:RecycleBinFolder'), nil, nil, SW_SHOW);
  end;

  if TMenuItem(Sender).Caption = 'Empty' then begin
    SHEmptyRecycleBin(0, nil, 0);
    OnTimer(nil);
  end;

  if TMenuItem(Sender).Caption = 'Update' then begin
    OnTimer(nil);
  end;

  if TMenuItem(Sender).Caption = 'Exit' then begin
    Shell_NotifyIcon(NIM_DELETE, @TrayIconData);
    TerminateProcess(OpenProcess(PROCESS_TERMINATE, False, GetCurrentProcessId), 0);
  end;
end;
//Process popup menu events


//Process tray icon messages
function WindowProc(hWnd, Msg: Longint; wParam: WPARAM; lParam: LPARAM): Longint; stdcall;
var
  Point: TPoint;
  NotifyEvent: TShellNotifyEvent;
  pItem: PItemIDArray;
  Path: String;
begin
  OutputConsole('Message -> ' + IntToStr(Msg) + ' | lParam -> ' + IntToStr(lParam) + ' | wParam -> ' + IntToStr(wParam));

  if Msg = WM_SHELLNOTIFY then begin
    NotifyEvent := LongintToNotifyEvent(LParam and SHCNE_ALLEVENTS);
    pItem := PItemIDArray(wParam);
    Path := PidlToStr(pItem^.pidl[0]);

    case NotifyEvent of
      neCreate: if Pos(RECYCLE_BIN, UpperCase(Path)) > 0 then UpdateRecycleBin;
      neDelete: if Pos(RECYCLE_BIN, UpperCase(Path)) > 0 then UpdateRecycleBin;
      neMkDir: if Pos(RECYCLE_BIN, UpperCase(Path)) > 0 then UpdateRecycleBin;
      neRenameFolder: if Pos(RECYCLE_BIN, UpperCase(Path)) > 0 then UpdateRecycleBin;
      neRenameItem: if Pos(RECYCLE_BIN, UpperCase(Path)) > 0 then UpdateRecycleBin;
      neRmDir: if Pos(RECYCLE_BIN, UpperCase(Path)) > 0 then UpdateRecycleBin;
      neUpdateDir: UpdateRecycleBin;
      neUpdateItem: UpdateRecycleBin;
    end;
  end;

  if Msg = WM_CALLBACK_MESSAGE then begin
    case lParam of
      WM_RBUTTONUP: begin
        GetCursorPos(Point);
        SetForegroundWindow(hMainHandle);
        PopupMenu.Popup(Point.X, Point.Y);
      end;

      WM_LBUTTONDBLCLK: begin
        ShellExecute(0, 'open', PChar('shell:RecycleBinFolder'), nil, nil, SW_SHOW);
      end;
    end;
  end;

  if Msg = TaskbarRestart then begin
    ExplorerRestarted := True;
    EventHandler.OnTimer(nil);
  end;

  Result := DefWindowProc(hWnd, Msg, wParam, lParam);
end;
//Process tray icon messages


//Main
begin
  //Check if application is already running
  hMutex := CreateMutex(nil, False, APP_NAME);
  if WaitForSingleObject(hMutex, 0) = WAIT_TIMEOUT then begin
    Application.Title := 'Mini Recycle Bin';
    ShowMessage('Mini Recycle Bin is already running.');
    Exit;
  end;

  //Generate random callback message
  Randomize;
  WM_CALLBACK_MESSAGE := WM_USER + Random(131072);

  //Load lib for recycle bin functions
  LibHandle := SafeLoadLibrary('shell32.dll');
  @SHQueryRecycleBin := GetProcAddress(LibHandle, 'SHQueryRecycleBinA');
  @SHEmptyRecycleBin := GetProcAddress(LibHandle, 'SHEmptyRecycleBinA');
  SHQueryRBInfo.cbSize := SizeOf(SHQueryRBInfo);

  //Create class
  LWndClass.hInstance := HInstance;
  LWndClass.lpszClassName := APP_NAME + 'Wnd';
  LWndClass.Style := CS_PARENTDC;
  LWndClass.lpfnWndProc := @WindowProc;

  //Register class and create window and get taskbar restart message
  Windows.RegisterClass(LWndClass);
  hMainHandle := CreateWindow(LWndClass.lpszClassName, APP_NAME, 0,0,0,0,0,0,0, HInstance, nil);
  TaskbarRestart := RegisterWindowMessage('TaskbarCreated');

  //Create tray icon
  FillChar(TrayIconData, SizeOf(TrayIconData), 0);
  TrayIconData.cbSize := SizeOf(TrayIconData);
  TrayIconData.Wnd := hMainHandle;
  TrayIconData.uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
  TrayIconData.uCallbackMessage := WM_CALLBACK_MESSAGE; //User definied messege
  TrayIconData.hIcon := LoadIcon(HInstance, 'RECYCLEEMPTY');

  //Create popup menu
  PopupMenu := TPopupMenu.Create(nil);
  PopupMenu.AutoHotkeys := maManual;
  EventHandler := TEventHandler.Create;

  //Add items to popup menu
  for i := 0 to Length(MenuItems)-1 do begin
    Item := TMenuItem.Create(PopupMenu);
    Item.Caption := MenuItems[i];
    Item.OnClick := EventHandler.HandlePopupItem;
    PopupMenu.Items.Add(Item);
  end;

  //Create timer
  Timer := TTimer.Create(nil);
  Timer.OnTimer := EventHandler.OnTimer;
  Timer.Enabled := False;

  //Call this event because it will add tray icon & register shell notify
  ExplorerRestarted := True;
  EventHandler.OnTimer(nil);

  //Process messages and loop program
  while GetMessage(Msg, 0,0,0) do begin
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;
end.
