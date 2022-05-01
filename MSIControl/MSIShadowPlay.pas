unit MSIShadowPlay;

interface

uses
  Windows, Messages, SysUtils, StdCtrls, ExtCtrls, ComCtrls, Variants, MMSystem, Classes, Graphics, Controls,
  Forms, Menus, PsApi, TNTStdCtrls, TNTSysUtils, XiButton, TFlatComboBoxUnit, TFlatCheckBoxUnit, CustoBevel,
  CustoHotKey, uDynamicData, uHotKey, ShadowPlay, MSISettings, Functions;

type
  TForm3 = class(TForm)
    Bevel1: TCustoBevel;
    Bevel2: TCustoBevel;
    Bevel3: TCustoBevel;
    Bevel4: TCustoBevel;
    Bevel5: TCustoBevel;
    Button1: TXiButton;
    Button2: TXiButton;
    Button3: TXiButton;
    Button4: TXiButton;
    CheckBox1: TFlatCheckBox;
    CheckBox2: TFlatCheckBox;
    CheckBox3: TFlatCheckBox;
    CheckBox4: TFlatCheckBox;
    CheckBox5: TFlatCheckBox;
    ComboBox1: TFlatComboBox;
    ComboBox2: TFlatComboBox;
    Edit1: TTntEdit;
    Edit2: TTntEdit;
    HotKey1: TCustoHotKey;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure HotKey1Exit(Sender: TObject);
    procedure HotKey1Enter(Sender: TObject);
    procedure HotKey1Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CheckBox2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CheckBox3MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CheckBox4MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CheckBox5MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TSettingsSP = record
    HotkeySound: Boolean;
    AutoIT: Boolean;
    ITActivateType: Integer;
    ToggleSPHotkey: Integer;
  end;

type
  TEventHandler = class
    procedure PopupClick(Sender: TObject);
  end;

const
  PROCESS_TYPE_DISABLE = 1;
  PROCESS_TYPE_ENABLE = 2;
  DEFAULT_SP_KEY = DEFAULT_KEY + '\ShadowPlay';

var
  Form3: TForm3;
  mOldHotKey: Integer;
  mNewHotKey: Integer;
  EventHandler: TEventHandler;
  ShadowPlay: TShadowPlay;
  ShadowDynData: TDynamicData;
  SettingsSP: TSettingsSP;
  SavedHWND: HWND;
  SavedProcess: WideString;

procedure GenerateProcessList;

implementation

uses
  MSIControl, MSIThemes;

{$R *.dfm}


function GetProcessFromHWND(hwnd:HWND): WideString;
var
  pid: DWORD;
  hProcess: THandle;
  Path: array[0..4095] of WideChar;
begin
  Result := '';
  GetWindowThreadProcessId(hwnd, pid);
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, pid);

  if (hProcess = 0) then Exit;
  if GetModuleFileNameExW(hProcess, 0, @Path[0], Length(Path)) <> 0 then Result := WideExtractFileName(Path);
  CloseHandle(hProcess);
end;


procedure WindowChange(hwnd: HWND);
var
  S: WideString;
  i, j: Integer;
  bool: Boolean;
begin
  if SettingsSP.ITActivateType = 0 then Exit;
  S := GetProcessFromHWND(hwnd);
  if SavedProcess = S then Exit;
  SavedProcess := S;
  j := -1;

  if not ShadowPlay.IsShadowPlayOn then Exit;

  for i := 0 to ShadowDynData.GetLength-1 do begin
    if (ShadowDynData.GetValue(i, 'Process') = S) and (ShadowDynData.GetValue(i, 'Type') = SettingsSP.ITActivateType) then j := i;
  end;

  if (j < 0) and (SettingsSP.ITActivateType = PROCESS_TYPE_DISABLE) then ShadowPlay.EnableInstantReplay(True);
  if (j < 0) and (SettingsSP.ITActivateType = PROCESS_TYPE_ENABLE) then ShadowPlay.EnableInstantReplay(False);

  if (j > -1) and (SettingsSP.ITActivateType = PROCESS_TYPE_DISABLE) then begin
    bool := ShadowDynData.GetValue(j, 'Type') <> PROCESS_TYPE_DISABLE;
    ShadowPlay.EnableInstantReplay(bool);
  end;

  if (j > -1) and (SettingsSP.ITActivateType = PROCESS_TYPE_ENABLE) then begin
    bool := ShadowDynData.GetValue(j, 'Type') = PROCESS_TYPE_ENABLE;
    ShadowPlay.EnableInstantReplay(bool);
  end;
end;


procedure ShadowPlayHotKeyCallback(Key, ShortCut: Integer; CustomValue: Variant);
begin
  if SettingsSP.HotkeySound then PlaySound('HOTKEY', 0, SND_RESOURCE or SND_ASYNC);
  Form3.CheckBox5.Checked := ShadowPlay.ToggleShadowPlay;
end;


procedure GenerateProcessList;
var
  i, PType: Integer;
  Name: WideString;
begin
  SavedHWND := 0;
  SavedProcess := '';
  Form3.ComboBox1.Items.Clear;
  Form3.ComboBox2.Items.Clear;

  for i := 0 to ShadowDynData.GetLength-1 do begin
    Name := ShadowDynData.GetValue(i, 'Process');
    PType := ShadowDynData.GetValue(i, 'Type');
    if (PType = PROCESS_TYPE_DISABLE) then Form3.ComboBox1.Items.AddObject(Name, TObject(i));
    if (PType = PROCESS_TYPE_ENABLE) then Form3.ComboBox2.Items.AddObject(Name, TObject(i));
  end;

  Form3.ComboBox1.ItemIndex := 0;
  Form3.ComboBox2.ItemIndex := 0;
end;


procedure TEventHandler.PopupClick(Sender: TObject);
begin
  ShadowPlay.ToggleShadowPlay;
end;


procedure TForm3.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  if not SettingsSP.AutoIT then Exit;
  ShadowPlay.EnableShadowPlay(True);
  Wait(10000);
  ShadowPlay.EnableInstantReplay(True);
end;


procedure TForm3.Timer2Timer(Sender: TObject);
var
  NewHWND: HWND;
begin
  NewHWND := GetForegroundWindow;
  if (SavedHWND = NewHWND) then Exit;
  SavedHWND := NewHWND;
  WindowChange(NewHWND);
end;


procedure TForm3.FormCreate(Sender: TObject);
var
  MenuItem: TMenuItem;
begin
  ShadowPlay := TShadowPlay.Create;
  if not ShadowPlay.IsLoaded then Exit;

  ShadowDynData := TDynamicData.Create(['Process', 'Type']);
  ShadowDynData.Load(True, True, DEFAULT_ROOT_KEY, DEFAULT_SP_KEY, 'ShadowPlay', True);
  LoadRegistryBoolean(SettingsSP.HotkeySound, DEFAULT_ROOT_KEY, DEFAULT_SP_KEY, 'HotkeySound');
  LoadRegistryBoolean(SettingsSP.AutoIT, DEFAULT_ROOT_KEY, DEFAULT_SP_KEY, 'AutoIT');
  LoadRegistryInteger(SettingsSP.ITActivateType, DEFAULT_ROOT_KEY, DEFAULT_SP_KEY, 'ITActivateType');
  LoadRegistryInteger(SettingsSP.ToggleSPHotkey, DEFAULT_ROOT_KEY, DEFAULT_SP_KEY, 'ToggleSPHotkey');

  Form3.CheckBox1.Checked := (SettingsSP.ITActivateType = PROCESS_TYPE_DISABLE);
  Form3.CheckBox2.Checked := (SettingsSP.ITActivateType = PROCESS_TYPE_ENABLE);
  Form3.CheckBox3.Checked := SettingsSP.HotkeySound;
  Form3.CheckBox4.Checked := SettingsSP.AutoIT;

  case SettingsSP.ITActivateType of
    PROCESS_TYPE_DISABLE: if ShadowPlay.IsShadowPlayOn then ShadowPlay.EnableInstantReplay(True);
    PROCESS_TYPE_ENABLE: if ShadowPlay.IsShadowPlayOn then ShadowPlay.EnableInstantReplay(False);
  end;

  if SettingsSP.ToggleSPHotkey > 0 then SetShortCut(ShadowPlayHotKeyCallback, SettingsSP.ToggleSPHotkey);
  GenerateProcessList;

  EventHandler := TEventHandler.Create;
  MenuItem := TMenuItem.Create(nil);
  MenuItem.Caption := 'Toggle Shadow Play';
  MenuItem.OnClick := EventHandler.PopupClick;
  Form1.PopupMenu1.Items.Insert(1, MenuItem);

  Timer1.Enabled := True;
  Timer2.Enabled := True;
  HotKey1.HotKey := SettingsSP.ToggleSPHotkey;
  Form1.Button3.Enabled := MSIShadowPlay.ShadowPlay.IsLoaded;
  ChangeTheme(Theme, Form3);
end;


procedure TForm3.FormShow(Sender: TObject);
begin
  MSIControl.RemoveFocus(Form3);
  CheckBox5.Checked := ShadowPlay.IsShadowPlayOn;
end;


procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ShadowDynData.Save(True, DEFAULT_ROOT_KEY, DEFAULT_SP_KEY, 'ShadowPlay');
  SaveRegistryBoolean(SettingsSP.HotkeySound, DEFAULT_ROOT_KEY, DEFAULT_SP_KEY, 'HotkeySound');
  SaveRegistryBoolean(SettingsSP.AutoIT, DEFAULT_ROOT_KEY, DEFAULT_SP_KEY, 'AutoIT');
  SaveRegistryInteger(SettingsSP.ITActivateType, DEFAULT_ROOT_KEY, DEFAULT_SP_KEY, 'ITActivateType');
  SaveRegistryInteger(SettingsSP.ToggleSPHotkey, DEFAULT_ROOT_KEY, DEFAULT_SP_KEY, 'ToggleSPHotkey');
end;


procedure TForm3.FormClick(Sender: TObject);
begin
  MSIControl.RemoveFocus(Form3);
end;


procedure TForm3.Button1Click(Sender: TObject);
var
  i: Integer;
  S: WideString;
begin
  S := Trim(Edit1.Text);
  if (S = '') or (ExtractFileExt(S) <> '.exe') then Exit;

  for i := 0 to ShadowDynData.GetLength-1 do begin
    if (ShadowDynData.GetValue(i, 'Process') = S) and (ShadowDynData.GetValue(i, 'Type') = PROCESS_TYPE_DISABLE) then Exit;
  end;

  i := ShadowDynData.CreateData(0);
  ShadowDynData.SetValue(i, 'Process', Edit1.Text);
  ShadowDynData.SetValue(i, 'Type', PROCESS_TYPE_DISABLE);
  GenerateProcessList;
end;


procedure TForm3.Button3Click(Sender: TObject);
var
  i: Integer;
  S: WideString;
begin
  S := Trim(Edit1.Text);
  if (S = '') or (ExtractFileExt(S) <> '.exe') then Exit;

  for i := 0 to ShadowDynData.GetLength-1 do begin
    if (ShadowDynData.GetValue(i, 'Process') = S) and (ShadowDynData.GetValue(i, 'Type') = PROCESS_TYPE_ENABLE) then Exit;
  end;

  i := ShadowDynData.CreateData(0);
  ShadowDynData.SetValue(i, 'Process', Edit1.Text);
  ShadowDynData.SetValue(i, 'Type', PROCESS_TYPE_ENABLE);
  GenerateProcessList;
end;


procedure TForm3.Button2Click(Sender: TObject);
var
  i: Integer;
begin
  if ComboBox1.ItemIndex < 0 then Exit;
  i := Integer(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  ShadowDynData.DeleteData(i);
  GenerateProcessList;
end;


procedure TForm3.Button4Click(Sender: TObject);
var
  i: Integer;
begin
  if ComboBox2.ItemIndex < 0 then Exit;
  i := Integer(ComboBox2.Items.Objects[ComboBox2.ItemIndex]);
  ShadowDynData.DeleteData(i);
  GenerateProcessList;
end;


procedure TForm3.HotKey1Change(Sender: TObject);
begin
  mNewHotKey := HotKey1.HotKey;
end;


procedure TForm3.HotKey1Enter(Sender: TObject);
begin
  mOldHotKey := HotKey1.HotKey;
  mNewHotKey := HotKey1.HotKey;
  DisableHotKey(ShortCutToHotKey(mOldHotKey));
end;


procedure TForm3.HotKey1Exit(Sender: TObject);
var
  Key: Integer;
begin
  if (mNewHotKey = mOldHotKey) then EnableHotKey(ShortCutToHotKey(mOldHotKey));
  if (mNewHotKey = mOldHotKey) then Exit;
  SettingsSP.ToggleSPHotkey := mNewHotKey;

  if (mNewHotKey = 0) then RemoveHotKey(ShortCutToHotKey(mOldHotKey));
  if (mNewHotKey = 0) then Exit;

  if (mOldHotKey <> 0) then Key := ShortCutToHotKey(mOldHotKey) else Key := -1;
  if (Key > -1) then ChangeShortCut(Key, mNewHotKey) else SetShortCut(ShadowPlayHotKeyCallback, mNewHotKey, Null);
end;


procedure TForm3.CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SettingsSP.ITActivateType := Q(CheckBox1.Checked, 1, 0);
  if CheckBox1.Checked then CheckBox2.Checked := False;
  SavedHWND := 0;
  SavedProcess := '';
end;


procedure TForm3.CheckBox2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SettingsSP.ITActivateType := Q(CheckBox2.Checked, 2, 0);
  if CheckBox2.Checked then CheckBox1.Checked := False;
  SavedHWND := 0;
  SavedProcess := '';
end;


procedure TForm3.CheckBox3MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SettingsSP.HotkeySound := CheckBox3.Checked;
end;


procedure TForm3.CheckBox4MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SettingsSP.AutoIT := CheckBox5.Checked;
end;


procedure TForm3.CheckBox5MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CheckBox5.Checked := ShadowPlay.ToggleShadowPlay;
end;


initialization
  SettingsSP.HotkeySound := True;
  SettingsSP.AutoIT := False;
  SettingsSP.ITActivateType := 0;
  SettingsSP.ToggleSPHotkey := 0;
end.
