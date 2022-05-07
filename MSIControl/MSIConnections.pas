unit MSIConnections;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Menus, ComCtrls, ExtCtrls, StdCtrls, Graphics, Controls,
  Forms, MMSystem, TFlatCheckBoxUnit, TFlatComboBoxUnit, CustoHotKey, CustoBevel, MSIControl, MSIThemes,
  uHotKey, uBluetooth, uDynamicData, Functions;

type
  TForm5 = class(TForm)
    Bevel1: TCustoBevel;
    Bevel2: TCustoBevel;
    CheckBox1: TFlatCheckBox;
    ComboBox1: TFlatComboBox;
    ComboBox2: TFlatComboBox;
    HotKey1: TCustoHotKey;
    Label1: TLabel;
    Label2: TLabel;
    procedure CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HotKey1Change(Sender: TObject);
    procedure HotKey1Enter(Sender: TObject);
    procedure HotKey1Exit(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TEventHandler = class
    procedure EthernetToggleClick(Sender: TObject);
    procedure BluetoothToggleClick(Sender: TObject);
  end;

const
  DEFAULT_CON_KEY = DEFAULT_KEY + '\Connections';

var
  Form5: TForm5;
  EventHandler: TEventHandler;
  HotkeyDynData: TDynamicData;
  SettingDynData: TDynamicData;
  mOldHotKey: Integer;
  mNewHotKey: Integer;
  isBluetooth: Boolean;

implementation

{$R *.dfm}

procedure ConnectionsHotkeyCallback(Key, ShortCut: Integer; CustomValue: Variant);
var
  i: Integer;
begin
  i := SettingDynData.FindIndex(0, 'Name', 'SETTING_HOTKEY_SOUND');
  if (i > -1) and SettingDynData.GetValue(i, 'Value') then PlaySound('HOTKEY', 0, SND_RESOURCE or SND_ASYNC);

  if (CustomValue = 'HOTKEY_TOGGLE_ETHERNET') then begin
    EventHandler.EthernetToggleClick(nil);
  end;

  if (CustomValue = 'HOTKEY_TOGGLE_BLUETOOTH') then begin
    if isBluetooth then EnableBluetooth(not IsBluetoothEnabled);
  end;

  if (CustomValue = 'HOTKEY_TOGGLE_DISCOVERY') then begin
    if isBluetooth then EnableBluetoothDiscovery(not IsBluetoothDiscoverable);
  end;

  Form5.ComboBox2Change(nil);
end;


procedure TEventHandler.EthernetToggleClick(Sender: TObject);
var
  b: Boolean;
begin
  b := not GetEthernetEnabled;

  while GetEthernetEnabled <> b do begin
    SetEthernetEnabled(b);
    Wait(1000);
  end;
end;


procedure TEventHandler.BluetoothToggleClick(Sender: TObject);
begin
  EnableBluetooth(not IsBluetoothEnabled);
end;


procedure TForm5.FormShow(Sender: TObject);
begin
  MSIControl.RemoveFocus(Form5);
  ComboBox2Change(nil);
end;


procedure TForm5.FormClick(Sender: TObject);

begin
  MSIControl.RemoveFocus(Form5);
end;


procedure TForm5.FormCreate(Sender: TObject);
var
  MenuItem: TMenuItem;
  Name: WideString;
  i, v: Integer;
begin
  HotkeyDynData := TDynamicData.Create(['Hotkey', 'Name', 'Description']);
  HotkeyDynData.CreateData(-1, -1, ['Hotkey', 'Name', 'Description'], [0, 'HOTKEY_TOGGLE_ETHERNET', 'Toggle Ethernet']);
  HotkeyDynData.CreateData(-1, -1, ['Hotkey', 'Name', 'Description'], [0, 'HOTKEY_TOGGLE_BLUETOOTH', 'Toggle Bluetooth']);
  HotkeyDynData.CreateData(-1, -1, ['Hotkey', 'Name', 'Description'], [0, 'HOTKEY_TOGGLE_DISCOVERY', 'Toggle Bluetooth Discovery']);

  SettingDynData := TDynamicData.Create(['Value', 'Name', 'Description']);
  SettingDynData.CreateData(-1, -1, ['Value', 'Name', 'Description'], [True, 'SETTING_HOTKEY_SOUND', 'Enable Hotkey Sounds']);
  SettingDynData.CreateData(-1, -1, ['Value', 'Name', 'Description'], [False, 'SETTING_AUTO_ENABLE_ETHERNET', 'Enable Ethernet On Startup']);
  SettingDynData.CreateData(-1, -1, ['Value', 'Name', 'Description'], [False, 'SETTING_AUTO_ENABLE_BLUETOOTH', 'Enable Bluetooth On Startup']);
  SettingDynData.CreateData(-1, -1, ['Value', 'Name', 'Description'], [False, 'SETTING_AUTO_DISABLE_DISCOVERY', 'Disable Bluetooth Discovery On Startup']);
  SettingDynData.CreateData(-1, -1, ['Value', 'Name', 'Description'], [False, 'SETTING_ENABLE_ETHERNET', 'Enable Ethernet']);
  SettingDynData.CreateData(-1, -1, ['Value', 'Name', 'Description'], [False, 'SETTING_ENABLE_BLUETOOTH', 'Enable Bluetooth']);
  SettingDynData.CreateData(-1, -1, ['Value', 'Name', 'Description'], [False, 'SETTING_ENABLE_DISCOVERY', 'Enable Bluetooth Discovery']);

  for i := 0 to HotkeyDynData.GetLength-1 do begin
    ComboBox1.Items.Add(HotkeyDynData.GetValue(i, 'Description'));
    Name := HotkeyDynData.GetValue(i, 'Name');
    if LoadRegistryInteger(v, DEFAULT_ROOT_KEY, DEFAULT_CON_KEY, Name) then begin
      HotkeyDynData.SetValue(i, 'Hotkey', v);
      SetShortCut(ConnectionsHotkeyCallback, v, Name);
    end;
  end;

  for i := 0 to SettingDynData.GetLength-1 do begin
    ComboBox2.Items.Add(SettingDynData.GetValue(i, 'Description'));
    Name := SettingDynData.GetValue(i, 'Name');
    if LoadRegistryInteger(v, DEFAULT_ROOT_KEY, DEFAULT_CON_KEY, Name) then SettingDynData.SetValue(i, 'Value', v);
  end;

  EventHandler := TEventHandler.Create;
  MenuItem := TMenuItem.Create(nil);
  MenuItem.Caption := 'Toggle Ethernet';
  MenuItem.OnClick := EventHandler.EthernetToggleClick;
  Form1.PopupMenu1.Items.Find('Toggle').Add(MenuItem);

  EventHandler := TEventHandler.Create;
  MenuItem := TMenuItem.Create(nil);
  MenuItem.Caption := 'Toggle Bluetooth';
  MenuItem.OnClick := EventHandler.BluetoothToggleClick;
  if isBluetooth then Form1.PopupMenu1.Items.Find('Toggle').Add(MenuItem);

  v := SettingDynData.FindValue(0, 'Name', 'SETTING_AUTO_ENABLE_ETHERNET', 'Value');
  if (v > 0) then SetEthernetEnabled(True);

  v := SettingDynData.FindValue(0, 'Name', 'SETTING_AUTO_ENABLE_BLUETOOTH', 'Value');
  if (v > 0) and isBluetooth then EnableBluetooth(True);

  v := SettingDynData.FindValue(0, 'Name', 'SETTING_AUTO_DISABLE_DISCOVERY', 'Value');
  if (v > 0) and isBluetooth then EnableBluetoothDiscovery(False);

  ComboBox1.ItemIndex := 0;
  ComboBox1Change(nil);
  ComboBox2.ItemIndex := 0;
  ComboBox2Change(nil);
  ChangeTheme(Theme, Form5);
end;


procedure TForm5.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
begin
  for i := 0 to HotkeyDynData.GetLength-1 do begin
    SaveRegistryInteger(HotkeyDynData.GetValue(i, 'Hotkey'), DEFAULT_ROOT_KEY, DEFAULT_CON_KEY, HotkeyDynData.GetValue(i, 'Name'));
  end;

  for i := 0 to SettingDynData.GetLength-1 do begin
    SaveRegistryBoolean(SettingDynData.GetValue(i, 'Value'), DEFAULT_ROOT_KEY, DEFAULT_CON_KEY, SettingDynData.GetValue(i, 'Name'));
  end;
end;


procedure TForm5.HotKey1Change(Sender: TObject);
begin
  mNewHotKey := HotKey1.HotKey;
end;


procedure TForm5.HotKey1Enter(Sender: TObject);
begin
  mOldHotKey := HotKey1.HotKey;
  mNewHotKey := HotKey1.HotKey;
  DisableHotKey(ShortCutToHotKey(mOldHotKey));
end;


procedure TForm5.HotKey1Exit(Sender: TObject);
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
  if (Key > -1) then ChangeShortCut(Key, mNewHotKey) else SetShortCut(ConnectionsHotkeyCallback, mNewHotKey, Name);
end;


procedure TForm5.ComboBox1Change(Sender: TObject);
var
  i: Integer;
begin
  RemoveFocus(Form5);
  i := HotkeyDynData.FindIndex(0, 'Description', ComboBox1.Text);
  if (i > -1) then HotKey1.HotKey := HotkeyDynData.GetValue(i, 'Hotkey');
end;


procedure TForm5.ComboBox2Change(Sender: TObject);
var
  i: Integer;
  Name: WideString;
begin
  RemoveFocus(Form5);
  i := SettingDynData.FindIndex(0, 'Description', ComboBox2.Text);
  if (i < 0) then Exit;
  CheckBox1.Enabled := True;

  Name := SettingDynData.GetValue(i, 'Name');
  if Name = 'SETTING_HOTKEY_SOUND' then CheckBox1.Checked := SettingDynData.GetValue(i, 'Value');
  if Name = 'SETTING_AUTO_ENABLE_ETHERNET' then CheckBox1.Checked := SettingDynData.GetValue(i, 'Value');
  if Name = 'SETTING_AUTO_ENABLE_BLUETOOTH' then CheckBox1.Checked := SettingDynData.GetValue(i, 'Value');
  if Name = 'SETTING_AUTO_DISABLE_DISCOVERY' then CheckBox1.Checked := SettingDynData.GetValue(i, 'Value');
  if Name = 'SETTING_ENABLE_ETHERNET' then CheckBox1.Checked := GetEthernetEnabled;

  if Name = 'SETTING_ENABLE_BLUETOOTH' then begin
    CheckBox1.Enabled := isBluetooth;
    if isBluetooth then CheckBox1.Checked := IsBluetoothEnabled;
  end;

  if Name = 'SETTING_ENABLE_DISCOVERY' then begin
    CheckBox1.Enabled := isBluetooth;
    if isBluetooth then CheckBox1.Checked := IsBluetoothDiscoverable;
  end;
end;


procedure TForm5.CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  Name: WideString;
begin
  i := SettingDynData.FindIndex(0, 'Description', ComboBox2.Text);
  if (i < 0) then Exit;
  Name := SettingDynData.GetValue(i, 'Name');

  if Name = 'SETTING_HOTKEY_SOUND' then SettingDynData.SetValue(i, 'Value', CheckBox1.Checked);
  if Name = 'SETTING_AUTO_ENABLE_ETHERNET' then SettingDynData.SetValue(i, 'Value', CheckBox1.Checked);
  if Name = 'SETTING_AUTO_ENABLE_BLUETOOTH' then SettingDynData.SetValue(i, 'Value', CheckBox1.Checked);
  if Name = 'SETTING_AUTO_DISABLE_DISCOVERY' then SettingDynData.SetValue(i, 'Value', CheckBox1.Checked);
  if Name = 'SETTING_ENABLE_ETHERNET' then SetEthernetEnabled(CheckBox1.Checked);
  if Name = 'SETTING_ENABLE_BLUETOOTH' then EnableBluetooth(CheckBox1.Checked);
  if Name = 'SETTING_ENABLE_DISCOVERY' then EnableBluetoothDiscovery(CheckBox1.Checked);
end;


initialization
  isBluetooth := (GetBluetoothStatus <> 0) and (GetBluetoothStatus <> 3);
end.
