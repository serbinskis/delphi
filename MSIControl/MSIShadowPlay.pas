unit MSIShadowPlay;

interface

uses
  Windows, Messages, SysUtils, StdCtrls, ExtCtrls, ComCtrls, Variants, MMSystem, Classes, Graphics, Controls,
  Forms, Menus, PsApi, TNTStdCtrls, TNTSysUtils, XiButton, TFlatComboBoxUnit, TFlatCheckBoxUnit, CustoBevel,
  CustoHotKey, uDynamicData, uHotKey, ShadowPlay, MSIControl, MSIThemes, Functions;

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
    ComboBox1: TFlatComboBox;
    ComboBox2: TFlatComboBox;
    ComboBox3: TFlatComboBox;
    ComboBox4: TFlatComboBox;
    Edit1: TTntEdit;
    Edit2: TTntEdit;
    HotKey1: TCustoHotKey;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CheckBox2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CheckBox3MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox4Change(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HotKey1Change(Sender: TObject);
    procedure HotKey1Enter(Sender: TObject);
    procedure HotKey1Exit(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TEventHandler = class
    procedure ToggleSPClick(Sender: TObject);
  end;

const
  PROCESS_TYPE_DISABLE = 1;
  PROCESS_TYPE_ENABLE = 2;
  DEFAULT_SP_KEY = DEFAULT_KEY + '\ShadowPlay';

var
  Form3: TForm3;
  ShadowDynData: TDynamicData;
  HotkeyDynData: TDynamicData;
  SettingDynData: TDynamicData;
  ShadowPlay: TShadowPlay;
  mOldHotKey: Integer;
  mNewHotKey: Integer;
  SavedHWND: HWND;
  SavedProcess: WideString;

procedure GenerateProcessList;

implementation

{$R *.dfm}

procedure WindowChange(hwnd: HWND);
var
  S: WideString;
  i, j, ITActivateType: Integer;
  bool: Boolean;
begin
  i := SettingDynData.FindIndex(0, 'Name', 'SETTING_IT_ACTIVATE_TYPE');
  if (i > -1) then ITActivateType := SettingDynData.GetValue(i, 'Value') else ITActivateType := 0;
  if ITActivateType = 0 then Exit;

  S := GetProcessFromHWND(hwnd);
  if SavedProcess = S then Exit;
  SavedProcess := S;
  j := -1;

  if not ShadowPlay.IsShadowPlayOn then Exit;

  for i := 0 to ShadowDynData.GetLength-1 do begin
    if (ShadowDynData.GetValue(i, 'Process') = S) and (ShadowDynData.GetValue(i, 'Type') = ITActivateType) then j := i;
  end;

  if (j < 0) and (ITActivateType = PROCESS_TYPE_DISABLE) then ShadowPlay.EnableInstantReplay(True);
  if (j < 0) and (ITActivateType = PROCESS_TYPE_ENABLE) then ShadowPlay.EnableInstantReplay(False);

  if (j > -1) and (ITActivateType = PROCESS_TYPE_DISABLE) then begin
    bool := ShadowDynData.GetValue(j, 'Type') <> PROCESS_TYPE_DISABLE;
    ShadowPlay.EnableInstantReplay(bool);
  end;

  if (j > -1) and (ITActivateType = PROCESS_TYPE_ENABLE) then begin
    bool := ShadowDynData.GetValue(j, 'Type') = PROCESS_TYPE_ENABLE;
    ShadowPlay.EnableInstantReplay(bool);
  end;
end;


procedure ShadowPlayHotkeyCallback(Key, ShortCut: Integer; CustomValue: Variant);
var
  i: Integer;
begin
  i := SettingDynData.FindIndex(0, 'Name', 'SETTING_HOTKEY_SOUND');
  if (i > -1) and SettingDynData.GetValue(i, 'Value') then PlaySound('HOTKEY', 0, SND_RESOURCE or SND_ASYNC);

  if (CustomValue = 'HOTKEY_TOGGLE_SP') then begin
    ShadowPlay.ToggleShadowPlay;
  end;

  if (CustomValue = 'HOTKEY_TOGGLE_IT') then begin
    ShadowPlay.ToggleInstantReplay;
  end;

  Form3.ComboBox4Change(nil);
end;


procedure GenerateProcessList;
var
  i, PType: Integer;
  Name: WideString;
begin
  SavedHWND := 0;
  SavedProcess := '';
  Form3.ComboBox2.Items.Clear;
  Form3.ComboBox3.Items.Clear;

  for i := 0 to ShadowDynData.GetLength-1 do begin
    Name := ShadowDynData.GetValue(i, 'Process');
    PType := ShadowDynData.GetValue(i, 'Type');
    if (PType = PROCESS_TYPE_DISABLE) then Form3.ComboBox2.Items.AddObject(Name, TObject(i));
    if (PType = PROCESS_TYPE_ENABLE) then Form3.ComboBox3.Items.AddObject(Name, TObject(i));
  end;

  Form3.ComboBox2.ItemIndex := 0;
  Form3.ComboBox3.ItemIndex := 0;
end;


procedure TEventHandler.ToggleSPClick(Sender: TObject);
begin
  ShadowPlay.ToggleShadowPlay;
end;


procedure TForm3.Timer1Timer(Sender: TObject);
var
  isOn: Boolean;
begin
  Timer1.Enabled := False;
  if not Boolean(SettingDynData.FindValue(0, 'Name', 'SETTING_AUTO_ENABLE_IT', 'Value')) then Exit;

  isOn := ShadowPlay.IsShadowPlayOn;
  if not isOn then ShadowPlay.EnableShadowPlay(True);
  if not isOn then Wait(10000);
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
  EventHandler: TEventHandler;
  Name: WideString;
  i, v: Integer;
begin
  ShadowPlay := TShadowPlay.Create;
  Form1.Button3.Enabled := ShadowPlay.IsLoaded;
  if not ShadowPlay.IsLoaded then Exit;

  ShadowDynData := TDynamicData.Create(['Process', 'Type']);
  ShadowDynData.Load(True, True, DEFAULT_ROOT_KEY, DEFAULT_SP_KEY, 'BINARY_SHADOWPLAY', True);
  GenerateProcessList;

  HotkeyDynData := TDynamicData.Create(['Hotkey', 'Name', 'Description']);
  HotkeyDynData.CreateData(-1, -1, ['Hotkey', 'Name', 'Description'], [0, 'HOTKEY_TOGGLE_SP', 'Toggle Shadow Play']);
  HotkeyDynData.CreateData(-1, -1, ['Hotkey', 'Name', 'Description'], [0, 'HOTKEY_TOGGLE_IT', 'Toggle Instant Replay']);

  SettingDynData := TDynamicData.Create(['Visible', 'Value', 'Name', 'Description']);
  SettingDynData.CreateData(-1, -1, ['Visible', 'Value', 'Name', 'Description'], [True, True, 'SETTING_HOTKEY_SOUND', 'Enable Hotkey Sounds']);
  SettingDynData.CreateData(-1, -1, ['Visible', 'Value', 'Name', 'Description'], [True, False, 'SETTING_AUTO_ENABLE_IT', 'Enable Instant Replay On Startup']);
  SettingDynData.CreateData(-1, -1, ['Visible', 'Value', 'Name', 'Description'], [True, False, 'SETTING_ENABLE_SP', 'Enable Shadow Play']);
  SettingDynData.CreateData(-1, -1, ['Visible', 'Value', 'Name', 'Description'], [False, 0, 'SETTING_IT_ACTIVATE_TYPE', '']);

  for i := 0 to HotkeyDynData.GetLength-1 do begin
    ComboBox1.Items.Add(HotkeyDynData.GetValue(i, 'Description'));
    Name := HotkeyDynData.GetValue(i, 'Name');
    if LoadRegistryInteger(v, DEFAULT_ROOT_KEY, DEFAULT_SP_KEY, Name) then begin
      HotkeyDynData.SetValue(i, 'Hotkey', v);
      SetShortCut(ShadowPlayHotkeyCallback, v, Name);
    end;
  end;

  for i := 0 to SettingDynData.GetLength-1 do begin
    if SettingDynData.GetValue(i, 'Visible') then ComboBox4.Items.Add(SettingDynData.GetValue(i, 'Description'));
    Name := SettingDynData.GetValue(i, 'Name');
    if LoadRegistryInteger(v, DEFAULT_ROOT_KEY, DEFAULT_SP_KEY, Name) then SettingDynData.SetValue(i, 'Value', v);
  end;

  Form3.CheckBox1.Checked := (SettingDynData.FindValue(0, 'Name', 'SETTING_IT_ACTIVATE_TYPE', 'Value') = PROCESS_TYPE_DISABLE);
  Form3.CheckBox2.Checked := (SettingDynData.FindValue(0, 'Name', 'SETTING_IT_ACTIVATE_TYPE', 'Value') = PROCESS_TYPE_ENABLE);

  if Form3.CheckBox1.Checked then if ShadowPlay.IsShadowPlayOn then ShadowPlay.EnableInstantReplay(True);
  if Form3.CheckBox2.Checked then if ShadowPlay.IsShadowPlayOn then ShadowPlay.EnableInstantReplay(False);

  EventHandler := TEventHandler.Create;
  MenuItem := TMenuItem.Create(nil);
  MenuItem.Caption := 'Toggle Shadow Play';
  MenuItem.OnClick := EventHandler.ToggleSPClick;
  Form1.PopupMenu1.Items.Find('Toggle').Add(MenuItem);

  ComboBox1.ItemIndex := 0;
  ComboBox1Change(nil);

  ComboBox4.ItemIndex := 0;
  ComboBox4Change(nil);

  Timer1.Enabled := True;
  Timer2.Enabled := True;
  ChangeTheme(Theme, Form3);
end;


procedure TForm3.FormShow(Sender: TObject);
begin
  MSIControl.RemoveFocus(Form3);
end;


procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
begin
  ShadowDynData.Save(True, DEFAULT_ROOT_KEY, DEFAULT_SP_KEY, 'BINARY_SHADOWPLAY');

  for i := 0 to HotkeyDynData.GetLength-1 do begin
    SaveRegistryInteger(HotkeyDynData.GetValue(i, 'Hotkey'), DEFAULT_ROOT_KEY, DEFAULT_SP_KEY, HotkeyDynData.GetValue(i, 'Name'));
  end;

  for i := 0 to SettingDynData.GetLength-1 do begin
    SaveRegistryBoolean(SettingDynData.GetValue(i, 'Value'), DEFAULT_ROOT_KEY, DEFAULT_SP_KEY, SettingDynData.GetValue(i, 'Name'));
  end;
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
  if ComboBox2.ItemIndex < 0 then Exit;
  i := Integer(ComboBox2.Items.Objects[ComboBox2.ItemIndex]);
  ShadowDynData.DeleteData(i);
  GenerateProcessList;
end;


procedure TForm3.Button4Click(Sender: TObject);
var
  i: Integer;
begin
  if ComboBox3.ItemIndex < 0 then Exit;
  i := Integer(ComboBox3.Items.Objects[ComboBox3.ItemIndex]);
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
  i, Key: Integer;
  Name: WideString;
begin
  if (mNewHotKey = mOldHotKey) then EnableHotKey(ShortCutToHotKey(mOldHotKey));
  if (mNewHotKey = mOldHotKey) then Exit;

  i := HotkeyDynData.FindIndex(0, 'Description', ComboBox1.Text);
  HotkeyDynData.SetValue(i, 'Hotkey', mNewHotKey);

  if (mNewHotKey = 0) then RemoveHotKey(ShortCutToHotKey(mOldHotKey));
  if (mNewHotKey = 0) then Exit;

  if (mOldHotKey <> 0) then Key := ShortCutToHotKey(mOldHotKey) else Key := -1;
  Name := HotkeyDynData.GetValue(i, 'Name');
  if (Key > -1) then ChangeShortCut(Key, mNewHotKey) else SetShortCut(ShadowPlayHotkeyCallback, mNewHotKey, Name);
end;


procedure TForm3.CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
begin
  i := SettingDynData.FindIndex(0, 'Name', 'SETTING_IT_ACTIVATE_TYPE');
  SettingDynData.SetValue(i, 'Value', Q(CheckBox1.Checked, 1, 0));

  if CheckBox1.Checked then CheckBox2.Checked := False;
  SavedHWND := 0;
  SavedProcess := '';
end;


procedure TForm3.CheckBox2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
begin
  i := SettingDynData.FindIndex(0, 'Name', 'SETTING_IT_ACTIVATE_TYPE');
  SettingDynData.SetValue(i, 'Value', Q(CheckBox2.Checked, 2, 0));

  if CheckBox2.Checked then CheckBox1.Checked := False;
  SavedHWND := 0;
  SavedProcess := '';
end;


procedure TForm3.ComboBox1Change(Sender: TObject);
var
  i: Integer;
begin
  RemoveFocus(Form3);
  i := HotkeyDynData.FindIndex(0, 'Description', ComboBox1.Text);
  if (i > -1) then HotKey1.HotKey := HotkeyDynData.GetValue(i, 'Hotkey');
end;


procedure TForm3.ComboBox4Change(Sender: TObject);
var
  i: Integer;
  Name: WideString;
begin
  RemoveFocus(Form3);
  i := SettingDynData.FindIndex(0, 'Description', ComboBox4.Text);
  if (i < 0) then Exit;

  Name := SettingDynData.GetValue(i, 'Name');
  if Name = 'SETTING_HOTKEY_SOUND' then CheckBox3.Checked := SettingDynData.GetValue(i, 'Value');
  if Name = 'SETTING_AUTO_ENABLE_IT' then CheckBox3.Checked := SettingDynData.GetValue(i, 'Value');
  if Name = 'SETTING_ENABLE_SP' then CheckBox3.Checked := ShadowPlay.IsShadowPlayOn;
end;


procedure TForm3.CheckBox3MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  Name: WideString;
begin
  i := SettingDynData.FindIndex(0, 'Description', ComboBox4.Text);
  if (i < 0) then Exit;
  Name := SettingDynData.GetValue(i, 'Name');

  if Name = 'SETTING_HOTKEY_SOUND' then SettingDynData.SetValue(i, 'Value', CheckBox3.Checked);
  if Name = 'SETTING_AUTO_ENABLE_IT' then SettingDynData.SetValue(i, 'Value', CheckBox3.Checked);
  if Name = 'SETTING_ENABLE_SP' then ShadowPlay.EnableShadowPlay(CheckBox3.Checked);
end;

end.
