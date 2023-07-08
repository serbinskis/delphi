unit MSIMonitors;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, StdCtrls, TntStdCtrls, Messages, ComCtrls, ExtCtrls, MMSystem,
  DateUtils, XiTrackBar, XiButton, TFlatCheckBoxUnit, TFlatComboBoxUnit, CustoHotKey, CustoBevel, MSIControl,
  MSIThemes, uHotKey, DDCCI, uDynamicData, Functions;

type
  TForm8 = class(TForm)
    Bevel1: TCustoBevel;
    Bevel2: TCustoBevel;
    Button1: TXiButton;
    Button2: TXiButton;
    CheckBox1: TFlatCheckBox;
    CheckBox2: TFlatCheckBox;
    ComboBox1: TFlatComboBox;
    ComboBox2: TFlatComboBox;
    ComboBox3: TFlatComboBox;
    HotKey1: TCustoHotKey;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TTntLabel;
    TrackBar1: TXiTrackBar;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    CustoBevel1: TCustoBevel;
    Edit1: TTntEdit;
    Edit2: TTntEdit;
    CustoBevel2: TCustoBevel;
    Edit3: TTntEdit;
    CustoBevel3: TCustoBevel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CheckBox2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure ComboBoxKey(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HotKey1Change(Sender: TObject);
    procedure HotKey1Enter(Sender: TObject);
    procedure HotKey1Exit(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure Edit1Exit(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure Edit2Exit(Sender: TObject);
    procedure Edit3Exit(Sender: TObject);
  private
    { Private declarations }
  public
    procedure WMDeviceChange(var Msg: TMessage); message WM_DEVICECHANGE;
    { Public declarations }
  end;

type
  TSettingsMon = record
    HotkeySound: Boolean;
  end;

const
  DEFAULT_MONITOR_KEY = DEFAULT_KEY + '\Monitors';

var
  Form8: TForm8;
  DDCCI: TDDCCI;
  MonDynData: TDynamicData;
  SettingsMon: TSettingsMon;
  mOldHotKey: Integer;
  mNewHotKey: Integer;

procedure LoadMonitorSettings;
procedure GenerateList;
procedure GetMonitorList(List: TStrings);
procedure ExecuteMonitor(i: Integer);

implementation

{$R *.dfm}


procedure ShutdownCallback;
var
  i, j: Integer;
  DeviceID: WideString;
  EnableOnStartup: Boolean;
  HotkeySound: Boolean;
begin
  DDCCI.Update;
  HotkeySound := SettingsMon.HotkeySound;
  SettingsMon.HotkeySound := False;

  for i := 0 to MonDynData.GetLength-1 do begin
    DeviceID := MonDynData.GetValue(i, 'DeviceID');
    EnableOnStartup := MonDynData.GetValue(i, 'EnableOnStartup');
    j := DDCCI.GetIndexByDeviceID(DeviceID);
    if (j > -1) and (EnableOnStartup) then ExecuteMonitor(i);
  end;

  SettingsMon.HotkeySound := HotkeySound;
end;


procedure TForm8.WMDeviceChange(var Msg: TMessage);
begin
  if (Msg.wParam <> 7) or not Form8.Visible then Exit;

  Form8.HotKey1.OnExit := nil;
  Form8.HotKey1.HotKey := mOldHotKey;
  RemoveFocus(self);
  Form8.HotKey1.OnExit := Form8.HotKey1Exit;

  GenerateList;
end;


procedure ExecuteMonitor(i: Integer);
var
  DeviceID: WideString;
  Value, Address, Value1, Value2: Variant;
begin
  DeviceID := MonDynData.GetValue(i, 'DeviceID');
  Value := MonDynData.GetValue(i, 'Value');

  case MonDynData.GetValue(i, 'Operation') of
    0: DDCCI.PowerOn(DeviceID);
    1: DDCCI.PowerOff(DeviceID);
    2: DDCCI.PowerToggle(DeviceID);
    3: DDCCI.SetBrightness(DeviceID, Value);
    4: DDCCI.SetBrightness(DeviceID, DDCCI.GetBrightness(DeviceID)+Value);
    5: DDCCI.SetBrightness(DeviceID, DDCCI.GetBrightness(DeviceID)-Value);
    6: DDCCI.SetValue(DeviceID, MonDynData.GetValue(i, 'Address'), MonDynData.GetValue(i, 'Value1'));
    7: begin
      Address := MonDynData.GetValue(i, 'Address');
      Value1 := MonDynData.GetValue(i, 'Value1');
      Value2 := MonDynData.GetValue(i, 'Value2');
      Value := DDCCI.GetValue(DeviceID, Address);
      DDCCI.SetValue(DeviceID, Address, Q((Value = Value1), Value2, Value1));
    end;
  else end;
end;


procedure MonitorHotKeyCallback(Key, ShortCut: Integer; CustomValue: Variant);
var
  DeviceID: WideString;
  i: Integer;
begin
  i := MonDynData.FindIndex(0, 'HotKey', ShortCut);
  if (i < 0) then Exit;
  DeviceID := MonDynData.GetValue(i, 'DeviceID');
  if (DDCCI.Update.GetIndexByDeviceID(DeviceID) < 0) then Exit;
  if SettingsMon.HotkeySound then PlaySound('HOTKEY', 0, SND_RESOURCE or SND_ASYNC);
  ExecuteMonitor(i);
end;


procedure LoadMonitorSettings;
var
  i, j, HotKey: Integer;
  DeviceID: WideString;
  EnableOnStartup: Boolean;
  isStartup: Boolean;
begin
  DDCCI := TDDCCI.Create(True);
  MonDynData := TDynamicData.Create(['DeviceID', 'EnableOnStartup', 'Operation', 'Value', 'Address', 'Value1', 'Value2', 'ID', 'HotKey']);
  MonDynData.Load(DEFAULT_ROOT_KEY, DEFAULT_MONITOR_KEY, 'BINARY_MONITORS', [loRemoveUnused, loOFDelete]);

  LoadRegistryBoolean(SettingsMon.HotkeySound, DEFAULT_ROOT_KEY, DEFAULT_MONITOR_KEY, 'SETTING_HOTKEY_SOUND');
  Form8.CheckBox2.Checked := SettingsMon.HotkeySound;
  isStartup := STARTUP_SECONDS > (GetTickCount64/1000);

  for i := 0 to MonDynData.GetLength-1 do begin
    DeviceID := MonDynData.GetValue(i, 'DeviceID');
    HotKey := MonDynData.GetValue(i, 'HotKey');
    EnableOnStartup := MonDynData.GetValue(i, 'EnableOnStartup');
    j := DDCCI.GetIndexByDeviceID(DeviceID);
    if (j > -1) and (EnableOnStartup and isStartup) then ExecuteMonitor(i);
    if (j > -1) and (HotKey > 0) then SetShortCut(MonitorHotKeyCallback, HotKey);
  end;

  GenerateList;
end;


procedure GenerateList;
var
  i, j: Integer;
  DeviceID: WideString;
  ID: Int64;
  List: TStrings;
begin
  DDCCI.Update;
  List := Form8.ComboBox1.Items;
  List.Clear;

  Form8.ComboBox2.Items.Clear;
  Form8.Button1.Enabled := ((DDCCI.GetMonitorCount) <> 0);
  Form8.Button2.Enabled := ((DDCCI.GetMonitorCount) <> 0);
  Form8.ComboBox1.Enabled := ((DDCCI.GetMonitorCount) <> 0);
  Form8.HotKey1.Enabled := ((DDCCI.GetMonitorCount) <> 0);
  Form8.ComboBox2.Enabled := ((DDCCI.GetMonitorCount) <> 0);
  Form8.ComboBox3.Enabled := ((DDCCI.GetMonitorCount) <> 0);

  for i := 0 to MonDynData.GetLength-1 do begin
    DeviceID := MonDynData.GetValue(i, 'DeviceID');
    j := DDCCI.GetIndexByDeviceID(DeviceID);
    if (j < 0) then Continue;
    ID := MonDynData.GetValue(i, 'ID');
    List.AddObject(DDCCI.GetFriendlyName(j) + ' (' + DDCCI.GetDeviceName(j) + ')', TObject(ID));
  end;

  if (DDCCI.GetMonitorCount <> 0) and (MonDynData.GetLength = 0) then Form8.Button1Click(nil);
  Form8.ComboBox1.ItemIndex := 0;
  Form8.ComboBox1Change(nil);
end;


function ToHex(S: string): Byte;
var
  IsValid: Boolean;
  i: Integer;
begin  
  S := UpperCase(S);
  IsValid := True;

  for i := 1 to Length(S) do begin
    if not (S[I] in ['0'..'9', 'A'..'F']) then begin
      IsValid := False;
      Break;
    end;
  end;

  Result := Q(IsValid, StrToIntDef('$' + S, 0), 0);
end;


procedure GetMonitorList(List: TStrings);
var
  i: Integer;
begin
  List.Clear;

  for i := 0 to DDCCI.GetMonitorCount-1 do begin
    List.Add(DDCCI.GetFriendlyName(i) + ' (' + DDCCI.GetDeviceName(i) + ')');
  end;
end;


procedure TForm8.FormClick(Sender: TObject);
begin
  MSIControl.RemoveFocus(self);
end;


procedure TForm8.FormShow(Sender: TObject);
begin
  MSIControl.RemoveFocus(self);
  GenerateList;
end;


procedure TForm8.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MonDynData.Save(DEFAULT_ROOT_KEY, DEFAULT_MONITOR_KEY, 'BINARY_MONITORS', []);
  SaveRegistryBoolean(SettingsMon.HotkeySound, DEFAULT_ROOT_KEY, DEFAULT_MONITOR_KEY, 'SETTING_HOTKEY_SOUND');
end;


procedure TForm8.FormCreate(Sender: TObject);
begin
  TrackBar1.Position := 50;
  LoadMonitorSettings;
  ChangeTheme(Theme, self);
  MSIControl.ShutdownCallbacks.Add(@ShutdownCallback);
end;


procedure TForm8.Button1Click(Sender: TObject);
var
  ID: Int64;
begin
  DDCCI.Update;

  ID := Int64(TObject(MilliSecondsBetween(Now, 0)));
  MonDynData.CreateData(-1, -1, ['DeviceID', 'EnableOnStartup', 'Operation', 'Value', 'ID', 'HotKey'], [DDCCI.GetDeviceID(0), False, 0, -1, ID, 0]);
  GenerateList;
  ComboBox1.ItemIndex := ComboBox1.Items.Count-1;
end;


procedure TForm8.Button2Click(Sender: TObject);
var
  i, HotKey, Key: Integer;
  ID: Int64;
begin
  ID := Int64(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  i := MonDynData.FindIndex(0, 'ID', ID);
  HotKey := MonDynData.GetValue(i, 'HotKey');

  //Unregister hotkey
  if (HotKey <> 0) then Key := ShortCutToHotKey(HotKey) else Key := -1;
  if (Key > -1) then RemoveHotKey(Key);

  MonDynData.DeleteData(i);
  GenerateList;
end;


procedure TForm8.ComboBox1Change(Sender: TObject);
var
  i: Integer;
  ID: Int64;
  Name: String;
  DeviceID: WideString;
begin
  if (ComboBox1.ItemIndex < 0) then Exit;
  ID := Int64(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  i := MonDynData.FindIndex(0, 'ID', ID);
  if (i < 0) then Exit;

  ComboBox3.ItemIndex := MonDynData.GetValue(i, 'Operation');
  ComboBox3Change(nil);
  HotKey1.HotKey := MonDynData.GetValue(i, 'HotKey');
  CheckBox1.Checked := MonDynData.GetValue(i, 'EnableOnStartup');
  DeviceID := MonDynData.GetValue(i, 'DeviceID');
  Label7.Visible := not DDCCI.isSupported(DeviceID);

  Name := ComboBox1.Items[ComboBox1.ItemIndex];
  GetMonitorList(ComboBox2.Items);

  for i := 0 to ComboBox2.Items.Count-1 do begin
    if (ComboBox2.Items[i] = Name) then ComboBox2.ItemIndex := i;
  end;
end;


procedure TForm8.HotKey1Change(Sender: TObject);
begin
  mNewHotKey := HotKey1.HotKey;
end;


procedure TForm8.HotKey1Enter(Sender: TObject);
begin
  mOldHotKey := HotKey1.HotKey;
  mNewHotKey := HotKey1.HotKey;
  DisableHotKey(ShortCutToHotKey(mOldHotKey));
end;


procedure TForm8.HotKey1Exit(Sender: TObject);
var
  i, ID, Key: Int64;
begin
  if (mNewHotKey = mOldHotKey) then EnableHotKey(ShortCutToHotKey(mOldHotKey));
  if (mNewHotKey = mOldHotKey) then Exit;

  //Save new hotkey for microphone
  ID := Int64(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  i := MonDynData.FindIndex(0, 'ID', ID);
  MonDynData.SetValue(i, 'HotKey', mNewHotKey);

  //Remove existing one, if there is such
  i := MonDynData.FindIndex(0, 'HotKey', mOldHotKey);
  if (i > -1) and (mOldHotKey <> 0) then MonDynData.SetValue(i, 'HotKey', 0);

  //If new hotkey is empty, just clear previous
  if (mNewHotKey = 0) then RemoveHotKey(ShortCutToHotKey(mOldHotKey));
  if (mNewHotKey = 0) then Exit;

  //Register new hotkey
  if (mOldHotKey <> 0) then Key := ShortCutToHotKey(mOldHotKey) else Key := -1;
  if (Key > -1) then ChangeShortCut(Key, mNewHotKey) else SetShortCut(MonitorHotKeyCallback, mNewHotKey);
end;


procedure TForm8.ComboBox2Change(Sender: TObject);
var
  i: Integer;
  ID: Int64;
  DeviceID: WideString;
begin
  MSIControl.RemoveFocus(self);
  ID := Int64(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  i := MonDynData.FindIndex(0, 'ID', ID);
  DeviceID := DDCCI.GetDeviceID(ComboBox2.ItemIndex);
  MonDynData.SetValue(i, 'DeviceID', DeviceID);
  Label7.Visible := not DDCCI.isSupported(DeviceID);

  i := ComboBox1.ItemIndex;
  ComboBox1.Items[i] := DDCCI.GetFriendlyName(ComboBox2.ItemIndex) + ' (' + DDCCI.GetDeviceName(ComboBox2.ItemIndex) + ')';
  ComboBox1.ItemIndex := i;
end;


procedure TForm8.ComboBox3Change(Sender: TObject);
var
  ID: Int64;
  Value: Variant;
  i, Brightness: Integer;
  DeviceID: WideString;
begin
  ID := Int64(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  i := MonDynData.FindIndex(0, 'ID', ID);
  MonDynData.SetValue(i, 'Operation', ComboBox3.ItemIndex);

  Value := MonDynData.GetValue(i, 'Value');
  TrackBar1.Enabled := ((ComboBox3.ItemIndex >= 3) and (ComboBox3.ItemIndex <= 5));

  Edit1.Enabled := ((ComboBox3.ItemIndex = 6) or (ComboBox3.ItemIndex = 7));
  Edit2.Enabled := ((ComboBox3.ItemIndex = 6) or (ComboBox3.ItemIndex = 7));
  Edit3.Enabled := (ComboBox3.ItemIndex = 7);

  if (TrackBar1.Enabled) then begin
    DeviceID := MonDynData.GetValue(i, 'DeviceID');
    Brightness := DDCCI.GetBrightness(DeviceID);

    if (ComboBox3.ItemIndex = 3) then TrackBar1.Position := Q((Value < 0), Brightness, Value);
    if (ComboBox3.ItemIndex = 4) then TrackBar1.Position := Q((Value < 0), 5, Value);
    if (ComboBox3.ItemIndex = 5) then TrackBar1.Position := Q((Value < 0), 5, Value);
  end;

  if (Edit1.Enabled) then begin
     Value := MonDynData.GetValue(i, 'Address');
     Edit1.Text := IntToHex(Q((Value <> MonDynData.Null), Value, 0), 2);
     Value := MonDynData.GetValue(i, 'Value1');
     Edit2.Text := IntToStr(Q((Value <> MonDynData.Null), Value, 0));
     Value := MonDynData.GetValue(i, 'Value2');
     Edit3.Text := IntToStr(Q((Value <> MonDynData.Null), Value, 0));
     Edit1Exit(Form8.Edit1);
     Edit2Exit(Form8.Edit2);
     Edit3Exit(Form8.Edit3);
  end;
end;


procedure TForm8.CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ID: Int64;
  i: Integer;
begin
  MSIControl.RemoveFocus(self);
  ID := Int64(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  i := MonDynData.FindIndex(0, 'ID', ID);
  MonDynData.SetValue(i, 'EnableOnStartup', CheckBox1.Checked);
end;


procedure TForm8.TrackBar1Change(Sender: TObject);
var
  ID: Int64;
  i: Integer;
begin
  Label5.Caption := IntToStr(TrackBar1.Position) + '%';
  if (ComboBox1.ItemIndex < 0) then Exit;

  ID := Int64(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  i := MonDynData.FindIndex(0, 'ID', ID);
  MonDynData.SetValue(i, 'Value', TrackBar1.Position);
end;


procedure TForm8.CheckBox2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SettingsMon.HotkeySound := CheckBox2.Checked;
end;


procedure TForm8.ComboBoxKey(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Key := 0;
end;


procedure TForm8.Edit1Exit(Sender: TObject);
var
  id: Int64;
  i: Integer;
begin
  TTNTEdit(Sender).Text := IntToHex(ToHex(TTNTEdit(Sender).Text), 2);
  if (ComboBox1.ItemIndex < 0) then Exit;

  id := Int64(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  i := MonDynData.FindIndex(0, 'ID', id);
  MonDynData.SetValue(i, 'Address', ToHex(TTNTEdit(Sender).Text));
end;


procedure TForm8.Edit1KeyPress(Sender: TObject; var Key: Char);
var
  b0, b1, b2: Boolean;
begin
  b0 := (Length(TTNTEdit(Sender).Text) >= 2);
  b1 := (Ord(Key) <> 8);
  b2 := TTNTEdit(Sender).SelLength > 0;
  Key := UpperCase(String(Key))[1];
  if not (Key in ['0'..'9', 'A'..'F', #8]) then Key := #0;
  if (b0 and b1 and (not b2)) then Key := #0;
end;


procedure TForm8.Edit2KeyPress(Sender: TObject; var Key: Char);
var
  b0, b1, b2: Boolean;
begin
  b0 := (Length(TTNTEdit(Sender).Text) >= 3);
  b1 := (Ord(Key) <> 8);
  b2 := TTNTEdit(Sender).SelLength > 0;
  Key := UpperCase(String(Key))[1];
  if not (Key in ['0'..'9', #8]) then Key := #0;
  if (b0 and b1 and (not b2)) then Key := #0;
end;


procedure TForm8.Edit2Exit(Sender: TObject);
var
  Value: Integer;
  id: Int64;
begin
  Value := StrToIntDef(TTNTEdit(Sender).Text, 0);
  if (Value > 255) then Value := 255;
  if (Value < 0) then Value := 0;
  TTNTEdit(Sender).Text := IntToStr(Value);

  id := Int64(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  id := MonDynData.FindIndex(0, 'ID', id);
  MonDynData.SetValue(id, 'Value1', Value);
end;


procedure TForm8.Edit3Exit(Sender: TObject);
var
  Value: Integer;
  id: Int64;
begin
  Value := StrToIntDef(TTNTEdit(Sender).Text, 0);
  if (Value > 255) then Value := 255;
  if (Value < 0) then Value := 0;
  TTNTEdit(Sender).Text := IntToStr(Value);

  id := Int64(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  id := MonDynData.FindIndex(0, 'ID', id);
  MonDynData.SetValue(id, 'Value2', Value);
end;

initialization
  SettingsMon.HotkeySound := True;
end.

