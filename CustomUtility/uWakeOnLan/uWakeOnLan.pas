unit uWakeOnLan;

interface

uses
  Windows, Messages, ShellAPI, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, WinXP, Functions, Registry, Menus;

const
  WM_CALLBACK_MESSAGE = WM_USER + 9372;
  DEFAULT_ROOT_KEY = HKEY_CURRENT_USER;
  DEFAULT_KEY = '\Software\WakeOnLan';

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
  TWakeOnLan = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    PopupMenu1: TPopupMenu;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    AddNew1: TMenuItem;
    Exit1: TMenuItem;
    procedure TrayOnClick(var msg: TMessage); message WM_CALLBACK_MESSAGE;
    procedure FormCreate(Sender: TObject);
    procedure Edit5Change(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure PopupItemClick(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure EditChange(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WakeOnLan: TWakeOnLan;
  TaskbarRestart: Cardinal;
  TrayIconData: TNotifyIconData;
  ParentCaption: String;
  ParentItem: TMenuItem;
  id: LongWord;

implementation

{$R *.dfm}


//Process message loop
function WindowProc(hWnd, Msg: Longint; wParam: WPARAM; lParam: LPARAM): Longint; stdcall;
begin
  if Msg = TaskbarRestart then Shell_NotifyIcon(NIM_ADD, @TrayIconData);
  Result := DefWindowProc(hWnd, Msg, wParam, lParam);
end;
//Process message loop


//MessageLoop
procedure MessageLoop;
var
  LWndClass: TWndClass;
  AppName: String;
  Msg: TMsg;
begin
  //Initialization
  Randomize;
  AppName := IntToStr(Random(32767));

  //Create class
  FillChar(LWndClass, SizeOf(LWndClass), 0);
  LWndClass.hInstance := HInstance;
  LWndClass.lpszClassName := PChar(AppName + 'Wnd');
  LWndClass.Style := CS_PARENTDC;
  LWndClass.lpfnWndProc := @WindowProc;

  //Register class and create window and get taskbar restart message
  Windows.RegisterClass(LWndClass);
  CreateWindow(LWndClass.lpszClassName, PChar(AppName), 0,0,0,0,0,0,0, HInstance, nil);
  TaskbarRestart := RegisterWindowMessage('TaskbarCreated');

  //Process messages
  while GetMessage(Msg, 0,0,0) do begin
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;
end;
//MessageLoop


//AddEntry
procedure AddEntry(Name: String);
var
  Item: TMenuItem;
  SubItem: TMenuItem;
begin
  Item := TMenuItem.Create(WakeOnLan.PopupMenu1);
  Item.Caption := Name;
  Item.OnClick := WakeOnLan.PopupItemClick;

  SubItem := TMenuItem.Create(Item);
  SubItem.Caption := 'Start';
  SubItem.OnClick := WakeOnLan.PopupItemClick;
  Item.Add(SubItem);

  SubItem := TMenuItem.Create(Item);
  SubItem.Caption := 'Stop';
  SubItem.OnClick := WakeOnLan.PopupItemClick;
  Item.Add(SubItem);

  SubItem := TMenuItem.Create(Item);
  SubItem.Caption := 'Options';
  SubItem.OnClick := WakeOnLan.PopupItemClick;
  Item.Add(SubItem);

  SubItem := TMenuItem.Create(Item);
  SubItem.Caption := 'Delete';
  SubItem.OnClick := WakeOnLan.PopupItemClick;
  Item.Add(SubItem);

  WakeOnLan.PopupMenu1.Items.Insert(WakeOnLan.PopupMenu1.Items.Count-2, Item);
  ParentItem := Item;
end;
//AddEntry


//LoadSettings
procedure LoadSettings(Name: String);
var
  S, Key: String;
  I: Integer;
begin
  WakeOnLan.Hint := Name;
  Key := DEFAULT_KEY + '\' + Name;
  WakeOnLan.Edit1.Text := Name;

  S := '';
  LoadRegistryString(S, DEFAULT_ROOT_KEY, Key, 'IPAddress');
  WakeOnLan.Edit2.Text := S;

  S := '';
  LoadRegistryString(S, DEFAULT_ROOT_KEY, Key, 'IPv4Address');
  WakeOnLan.Edit3.Text := S;

  S := '';
  LoadRegistryString(S, DEFAULT_ROOT_KEY, Key, 'MacAddress');
  WakeOnLan.Edit4.Text := S;

  I := -1;
  LoadRegistryInteger(I, DEFAULT_ROOT_KEY, Key, 'Port');
  WakeOnLan.Edit5.Text := '';
  if I <> -1 then WakeOnLan.Edit5.Text := IntToStr(I);
end;
//LoadSettings


//SaveSettings
procedure SaveSettings;
var
  Key: String;
  Registry: TRegistry;
  MenuItem: TMenuItem;
begin
  //Check if selected name is empty
  if WakeOnLan.Edit1.Text = '' then begin
    WakeOnLan.Edit1.SetFocus;
    ShowMessage('Please enter a name.');
    Exit;
  end;

  //Check if selected name is not taken
  if WakeOnLan.Edit1.Text <> ParentCaption then begin
    MenuItem := WakeOnLan.PopupMenu1.Items.Find(WakeOnLan.Edit1.Text);
    if Assigned(MenuItem) then begin
      WakeOnLan.Edit1.SetFocus;
      ShowMessage('This name is already taken.');
      Exit;
    end;
  end;

  WakeOnLan.Visible := False;
  Key := DEFAULT_KEY + '\' + WakeOnLan.Edit1.Text;

  //Create registry key
  Registry := TRegistry.Create;
  Registry.RootKey := DEFAULT_ROOT_KEY;
  Registry.OpenKey(Key, True);
  Registry.Free;

  //Save only if not blank
  if WakeOnLan.Edit2.Text <> '' then SaveRegistryString(WakeOnLan.Edit2.Text, DEFAULT_ROOT_KEY, Key, 'IPAddress');
  if WakeOnLan.Edit3.Text <> '' then SaveRegistryString(WakeOnLan.Edit3.Text, DEFAULT_ROOT_KEY, Key, 'IPv4Address');
  if WakeOnLan.Edit4.Text <> '' then SaveRegistryString(WakeOnLan.Edit4.Text, DEFAULT_ROOT_KEY, Key, 'MacAddress');
  if WakeOnLan.Edit5.Text <> '' then SaveRegistryInteger(StrToInt(WakeOnLan.Edit5.Text), DEFAULT_ROOT_KEY, Key, 'Port');

  //If new name then delete old registry and rename menu item
  if WakeOnLan.Edit1.Text <> ParentCaption then begin
    Registry := TRegistry.Create;
    Registry.RootKey := DEFAULT_ROOT_KEY;
    Registry.DeleteKey(DEFAULT_KEY + '\' + ParentCaption);
    Registry.Free;

    ParentItem.Caption := WakeOnLan.Edit1.Text;
  end;
end;
//SaveSettings


procedure TWakeOnLan.TrayOnClick(var Msg: TMessage);
var
  Point: TPoint;
begin
  if Msg.LParam = WM_RBUTTONDOWN then begin
    if WakeOnLan.Visible then begin
      SetForegroundWindow(Application.Handle);
      Application.ProcessMessages;
    end else begin
      GetCursorPos(Point);
      SetForegroundWindow(Application.Handle);
      Application.ProcessMessages;
      PopupMenu1.Popup(Point.X, Point.Y);
    end;
  end;

  if Msg.LParam = WM_LBUTTONDOWN then begin
    if WakeOnLan.Visible then begin
      SetForegroundWindow(Application.Handle);
      Application.ProcessMessages;
    end;
  end;
end;


procedure TWakeOnLan.FormCreate(Sender: TObject);
var
  Registry: TRegistry;
  SubKeys: TStringList;
  i: Integer;
begin
  SubKeys := TStringList.Create;

  Registry := TRegistry.Create;
  Registry.RootKey := DEFAULT_ROOT_KEY;
  Registry.OpenKey(DEFAULT_KEY, True);
  Registry.GetKeyNames(SubKeys);

  for i := 0 to SubKeys.Count-1 do begin
    AddEntry(SubKeys.Strings[i]);
  end;

  Registry.Free;
  SubKeys.Free;

  FillChar(TrayIconData, SizeOf(TrayIconData), 0);
  TrayIconData.cbSize := SizeOf(TrayIconData);
  TrayIconData.Wnd := Handle;
  TrayIconData.uID := 0;
  TrayIconData.uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
  TrayIconData.uCallbackMessage := WM_CALLBACK_MESSAGE;
  TrayIconData.hIcon := LoadIcon(HInstance, '_WAKEONLAN');
  StrPCopy(TrayIconData.szTip, WakeOnLan.Caption);
  Shell_NotifyIcon(NIM_ADD, @TrayIconData);

  BeginThread(nil, 0, Addr(MessageLoop), nil, 0, id);
end;


procedure TWakeOnLan.FormShow(Sender: TObject);
var
  ActiveMonitor: Integer;
  MonitorWidth, MonitorHeigth: Integer;
begin
  ShowWindow(Application.Handle, SW_HIDE);
  StaticText1.SetFocus;

  Edit2.PasswordChar := #42;
  Edit3.PasswordChar := #42;
  Edit4.PasswordChar := #42;
  Edit5.PasswordChar := #42;

  ActiveMonitor := GetActiveMonitor;
  MonitorWidth := Screen.Monitors[ActiveMonitor].Left + Screen.Monitors[ActiveMonitor].Width;
  MonitorHeigth := Screen.Monitors[ActiveMonitor].Top + Screen.Monitors[ActiveMonitor].Height;

  WakeOnLan.Left := Trunc((MonitorWidth-WakeOnLan.Width)/2);
  WakeOnLan.Top := Trunc((MonitorHeigth-WakeOnLan.Height)/2);
end;


procedure TWakeOnLan.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if WakeOnLan.Visible then begin
    SaveSettings;
    CanClose := False;
  end;
end;


procedure TWakeOnLan.Edit5Change(Sender: TObject);
begin
  CheckValue(Edit5, 1, 999999);
end;


procedure TWakeOnLan.PopupItemClick(Sender: TObject);
var
  ItemCaption, NewName: String;
  MenuItem: TMenuItem;
  i: Integer;
  Registry: TRegistry;
begin
  ItemCaption := TMenuItem(Sender).Caption;
  ParentCaption := TMenuItem(Sender).Parent.Caption;

  //Add New
  if ItemCaption = 'Add New' then begin
    i := 0;
    NewName := 'New Entry';
    MenuItem := WakeOnLan.PopupMenu1.Items.Find(NewName);

    while Assigned(MenuItem) do begin
      i := i+1;
      NewName := 'New Entry (' + IntToStr(i) + ')';
      MenuItem := nil;
      MenuItem := WakeOnLan.PopupMenu1.Items.Find(NewName);
    end;

    AddEntry(NewName);
    ParentCaption := NewName;

    Edit1.Text := NewName;
    Edit2.Text := '';
    Edit3.Text := '';
    Edit4.Text := '';
    Edit5.Text := '';
    if not WakeOnLan.Visible then WakeOnLan.Visible := True;
  end;

  //Exit
  if ItemCaption = 'Exit' then begin
    Shell_NotifyIcon(NIM_DELETE, @TrayIconData);
    Application.Terminate;
  end;

  //Start
  if ItemCaption = 'Start' then begin
    LoadSettings(ParentCaption);

    if (Edit2.Text = '') or (Edit4.Text = '') or (Edit5.Text = '') then begin
      if not WakeOnLan.Visible then WakeOnLan.Visible := True;
      Exit;
    end;

    Functions.WakeOnLan(Edit2.Text, Edit4.Text, StrToInt(Edit5.Text));
  end;

  //Stop
  if ItemCaption = 'Stop' then begin
    LoadSettings(ParentCaption);

    if Edit3.Text = '' then begin
      if not WakeOnLan.Visible then WakeOnLan.Visible := True;
      Exit;
    end;

    if not PingReachable(Edit3.Text) then Exit;
    WinExec(PChar('shutdown -m ' + Edit3.Text + ' -s -t 0'), SW_HIDE);
  end;

  //Options
  if ItemCaption = 'Options' then begin
    ParentItem := TMenuItem(Sender).Parent;
    LoadSettings(ParentCaption);
    if not WakeOnLan.Visible then WakeOnLan.Visible := True;
  end;

  //Delete
  if ItemCaption = 'Delete' then begin
    PopupMenu1.Items.Remove(TMenuItem(Sender).Parent);
    Registry := TRegistry.Create;
    Registry.RootKey := DEFAULT_ROOT_KEY;
    Registry.DeleteKey(DEFAULT_KEY + '\' + ParentCaption);
    Registry.Free;
  end;
end;


procedure TWakeOnLan.EditKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) > 128 then Key := #0;
  if Key = '\' then Key := #0;
end;


procedure TWakeOnLan.EditChange(Sender: TObject);
begin
  TEdit(Sender).Text := StringReplace(TEdit(Sender).Text, '\', '', [rfReplaceAll, rfIgnoreCase]);
  TEdit(Sender).Text := RemoveDiacritics(TEdit(Sender).Text, '');
end;


procedure TWakeOnLan.EditEnter(Sender: TObject);
begin
  TEdit(Sender).PasswordChar := #0;
end;


procedure TWakeOnLan.EditExit(Sender: TObject);
begin
  TEdit(Sender).PasswordChar := #42;
end;

end.

