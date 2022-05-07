unit MSIMicrophones;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, StdCtrls, ComCtrls, ExtCtrls, Variants, MMSystem,
  XiTrackBar, XiButton, TFlatCheckBoxUnit, TFlatComboBoxUnit, CustoHotKey, CustoBevel, uHotKey,
  uAudioMixer, uDynamicData, MSIControl, MSIThemes, Functions;

type
  TForm2 = class(TForm)
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
    TrackBar1: TXiTrackBar;
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure ComboBoxKey(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CheckBox2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure HotKey1Change(Sender: TObject);
    procedure HotKey1Enter(Sender: TObject);
    procedure HotKey1Exit(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TSettingsMic = record
    HotkeySound: Boolean;
  end;

const
  MICROPHONE_DEFAULT = 'Default';
  DEFAULT_MICROPHONE_KEY = DEFAULT_KEY + '\Microphones';

var
  Form2: TForm2;
  MicDynData: TDynamicData;
  SettingsMic: TSettingsMic;
  mOldHotKey: Integer;
  mNewHotKey: Integer;

procedure OnDeviceChange(wParam: Integer);
procedure LoadMicrophoneSettings;
procedure GenerateList;
procedure GetMicrophoneList(List: TStrings);

implementation

{$R *.dfm}

procedure MicrophoneHotKeyCallback(Key, ShortCut: Integer; CustomValue: Variant);
var
  i, mOperation, mVolume, mIndex: Integer;
  mName: WideString;
begin
  i := MicDynData.FindIndex(0, 'HotKey', ShortCut);
  if (i < 0) then Exit;
  if SettingsMic.HotkeySound then PlaySound('HOTKEY', 0, SND_RESOURCE or SND_ASYNC);

  mName := MicDynData.GetValue(i, 'Name');
  mOperation := MicDynData.GetValue(i, 'Operation');
  mVolume := MicDynData.GetValue(i, 'Volume');

  if mName = MICROPHONE_DEFAULT
    then mIndex := GetDefaultMixerMicrophone
    else mIndex := GetMixerMicrophone(mName);

  if mIndex < 0 then Exit;

  case mOperation of
    0: begin //Set volume
      if mVolume < 0 then mVolume := 0;
      if mVolume > 100 then mVolume := 100;
      SetMicrophoneVolume(mIndex, 100-mVolume, -1);
      SetMicrophoneVolume(mIndex, mVolume, -1);
    end; //Mute or unmute
    1: SetMicrophoneVolume(mIndex, -1, 1);
    2: SetMicrophoneVolume(mIndex, -1, 0);
  end;
end;


procedure OnDeviceChange(wParam: Integer);
begin
  if (wParam = 7) then begin
    if Form2.Visible then begin
      Form2.HotKey1.OnExit := nil;
      Form2.HotKey1.HotKey := mOldHotKey;
      RemoveFocus(Form2);
      Form2.HotKey1.OnExit := Form2.HotKey1Exit;
    end;

    GetMicrophoneList(Form2.ComboBox2.Items);
    Form2.ComboBox2.ItemIndex := 0;
    Form2.ComboBox2Change(nil);
  end;
end;


procedure OnMixerChange(Msg: Integer; hMixer: HMIXER; MxId: Integer);
var
  mName, Name: WideString;
  mVolume, Volume, i: Integer;
  Fixed, isDefault: Boolean;
begin
  if Msg <> MM_MIXM_CONTROL_CHANGE then Exit;
  isDefault := uAudioMixer.isDefault(MxId);

  if isDefault
    then mName := MICROPHONE_DEFAULT
    else mName := GetMixerMicrophoneName(MxId);

  for i := 0 to MicDynData.GetLength-1 do begin
    Name := MicDynData.GetValue(i, 'Name');
    Volume := MicDynData.GetValue(i, 'Volume');
    Fixed := MicDynData.GetValue(i, 'Fixed');
    isDefault := isDefault and uAudioMixer.isDefault(Name);
    mVolume := GetMicrophoneVolume(MxId);
    if ((Name = mName) or isDefault) and (mVolume <> Volume) and Fixed then SetMicrophoneVolume(MxId, Volume, -1);
  end;
end;


procedure LoadMicrophoneSettings;
var
  i, HotKey, MxId, Volume: Integer;
  Fixed: Boolean;
  Name: WideString;
begin
  MicDynData := TDynamicData.Create(['Name', 'Operation', 'Volume', 'Fixed', 'HotKey']);
  MicDynData.Load(True, True, DEFAULT_ROOT_KEY, DEFAULT_MICROPHONE_KEY, 'BINARY_MICROPHONES', True);
  if (MicDynData.GetLength) = 0 then Form2.Button1Click(nil);

  LoadRegistryBoolean(SettingsMic.HotkeySound, DEFAULT_ROOT_KEY, DEFAULT_MICROPHONE_KEY, 'SETTING_HOTKEY_SOUND');
  Form2.CheckBox2.Checked := SettingsMic.HotkeySound;

  for i := 0 to MicDynData.GetLength-1 do begin
    Name := MicDynData.GetValue(i, 'Name');
    HotKey := MicDynData.GetValue(i, 'HotKey');
    Fixed := MicDynData.GetValue(i, 'Fixed');
    Volume := MicDynData.GetValue(i, 'Volume');
    if (Name <> MICROPHONE_DEFAULT) then MxId := GetMixerMicrophone(Name) else MxId := GetDefaultMixerMicrophone;
    if (MxId > -1) and (HotKey > 0) then SetShortCut(MicrophoneHotKeyCallback, HotKey, Null);
    if (MxId > -1) and Fixed then SetMicrophoneVolume(MxId, Volume, -1);
  end;

  GenerateList;
  SetDeviceChangeCallback(OnDeviceChange);
  SetMixerChangeCallback(OnMixerChange);
end;


procedure GenerateList;
var
  i, MxId: Integer;
  Name: WideString;
  List: TStrings;
begin
  List := Form2.ComboBox1.Items;
  List.Clear;

  for i := 0 to MicDynData.GetLength-1 do begin
    Name := MicDynData.GetValue(i, 'Name');
    if (Name <> MICROPHONE_DEFAULT) then MxId := GetMixerMicrophone(Name) else MxId := GetDefaultMixerMicrophone;
    if (Name = MICROPHONE_DEFAULT) or (MxId > -1) then List.AddObject(IntToStr(List.Count) + ' - ' + Name, TObject(i));
  end;

  Form2.ComboBox1.ItemIndex := 0;
  Form2.ComboBox1Change(nil);
end;


procedure GetMicrophoneList(List: TStrings);
var
  i: Integer;
  MixerCaps: TMixerCapsW;
begin
  List.Clear;
  List.Add(MICROPHONE_DEFAULT);

  for i := waveOutGetNumDevs to waveOutGetNumDevs+waveInGetNumDevs-1 do begin
    mixerGetDevCapsW(i, @MixerCaps, SizeOf(MixerCaps));
    List.Add(MixerCaps.szPname);
  end;
end;


//============================================================================
//============================================================================
//============================================================================


procedure TForm2.FormClick(Sender: TObject);
begin
  MSIControl.RemoveFocus(Form2);
end;


procedure TForm2.FormShow(Sender: TObject);
begin
  MSIControl.RemoveFocus(Form2);
end;


procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MicDynData.Save(True, DEFAULT_ROOT_KEY, DEFAULT_MICROPHONE_KEY, 'BINARY_MICROPHONES');
  SaveRegistryBoolean(SettingsMic.HotkeySound, DEFAULT_ROOT_KEY, DEFAULT_MICROPHONE_KEY, 'SETTING_HOTKEY_SOUND');
end;


procedure TForm2.FormCreate(Sender: TObject);
begin
  TrackBar1.Position := 100;
  LoadMicrophoneSettings;
  ChangeTheme(Theme, Form2);
end;


procedure TForm2.Button1Click(Sender: TObject);
begin
  MicDynData.CreateData(0, -1, ['Name', 'Operation', 'Volume', 'Fixed', 'HotKey'], [MICROPHONE_DEFAULT, 0, 100, False, 0]);
  GenerateList;
end;


procedure TForm2.Button2Click(Sender: TObject);
var
  i, HotKey, Key: Integer;
begin
  i := Integer(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  HotKey := MicDynData.GetValue(i, 'HotKey');

  //Unregister hotkey
  if (HotKey <> 0) then Key := ShortCutToHotKey(HotKey) else Key := -1;
  if (Key > -1) then RemoveHotKey(Key);

  MicDynData.DeleteData(i);
  GenerateList;
  if ComboBox1.Items.Count < 1 then Button1Click(nil);
end;


procedure TForm2.ComboBox1Change(Sender: TObject);
var
  i: Integer;
  Name: WideString;
begin
  if (ComboBox1.ItemIndex < 0) then Exit;
  i := Integer(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  if (i < 0) then Button2Click(nil);
  if (i < 0) then Exit;

  CheckBox1.Checked := MicDynData.GetValue(i, 'Fixed');
  TrackBar1.Position := MicDynData.GetValue(i, 'Volume');
  ComboBox3.ItemIndex := MicDynData.GetValue(i, 'Operation');
  ComboBox3Change(nil);
  HotKey1.HotKey := MicDynData.GetValue(i, 'HotKey');

  Name := MicDynData.GetValue(i, 'Name');
  GetMicrophoneList(ComboBox2.Items);

  for i := 0 to ComboBox2.Items.Count-1 do begin
    if (ComboBox2.Items[i] = Name) then ComboBox2.ItemIndex := i;
  end;
end;


procedure TForm2.HotKey1Change(Sender: TObject);
begin
  mNewHotKey := HotKey1.HotKey;
end;


procedure TForm2.HotKey1Enter(Sender: TObject);
begin
  mOldHotKey := HotKey1.HotKey;
  mNewHotKey := HotKey1.HotKey;
  DisableHotKey(ShortCutToHotKey(mOldHotKey));
end;


procedure TForm2.HotKey1Exit(Sender: TObject);
var
  i, Key: Integer;
begin
  if (mNewHotKey = mOldHotKey) then EnableHotKey(ShortCutToHotKey(mOldHotKey));
  if (mNewHotKey = mOldHotKey) then Exit;

  //Save new hotkey for microphone
  i := Integer(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  MicDynData.SetValue(i, 'HotKey', mNewHotKey);

  //Remove existing one, if there is such
  i := MicDynData.FindIndex(0, 'HotKey', mOldHotKey);
  if (i > -1) and (mOldHotKey <> 0) then MicDynData.SetValue(i, 'HotKey', 0);

  //If new hotkey is empty, just clear previous
  if (mNewHotKey = 0) then RemoveHotKey(ShortCutToHotKey(mOldHotKey));
  if (mNewHotKey = 0) then Exit;

  //Register new hotkey
  if (mOldHotKey <> 0) then Key := ShortCutToHotKey(mOldHotKey) else Key := -1;
  if (Key > -1) then ChangeShortCut(Key, mNewHotKey) else SetShortCut(MicrophoneHotKeyCallback, mNewHotKey, Null);
end;


procedure TForm2.ComboBox2Change(Sender: TObject);
var
  i: Integer;
  Name: WideString;
begin
  MSIControl.RemoveFocus(Form2);
  i := Integer(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  Name := ComboBox2.Items[ComboBox2.ItemIndex];
  MicDynData.SetValue(i, 'Name', Name);

  i := ComboBox1.ItemIndex;
  ComboBox1.Items[i] := IntToStr(i) + ' - ' + Name;
  ComboBox1.ItemIndex := i;
end;


procedure TForm2.ComboBox3Change(Sender: TObject);
var
  i: Integer;
begin
  MSIControl.RemoveFocus(Form2);
  CheckBox1.Enabled := (ComboBox3.ItemIndex = 0);
  TrackBar1.Enabled := (ComboBox3.ItemIndex = 0);

  i := Integer(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  MicDynData.SetValue(i, 'Operation', ComboBox3.ItemIndex);
end;


procedure TForm2.CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, j, MxId: Integer;
  Name, mName: WideString;
  Fixed, isDefault: Boolean;
begin
  j := Integer(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  MicDynData.SetValue(j, 'Fixed', CheckBox1.Checked);
  mName := MicDynData.GetValue(j, 'Name');

  if mName = MICROPHONE_DEFAULT
    then MxId := GetDefaultMixerMicrophone
    else MxId := GetMixerMicrophone(mName);

  isDefault := uAudioMixer.isDefault(MxId);

  //Clear duplicated fixed volume
  for i := 0 to MicDynData.GetLength-1 do begin
    Name := MicDynData.GetValue(i, 'Name');
    Fixed := MicDynData.GetValue(i, 'Fixed');
    isDefault := isDefault and (uAudioMixer.isDefault(Name) or (Name = MICROPHONE_DEFAULT));
    if (i <> j) and ((mName = Name) or isDefault) and Fixed then MicDynData.SetValue(i, 'Fixed', False);
  end;

  if CheckBox1.Checked then SetMicrophoneVolume(MxId, TrackBar1.Position, -1);
end;


procedure TForm2.CheckBox2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SettingsMic.HotkeySound := CheckBox2.Checked;
end;


procedure TForm2.TrackBar1Change(Sender: TObject);
var
  i, MxId: Integer;
  Name: WideString;
begin
  if (ComboBox1.ItemIndex < 0) then Exit;
  i := Integer(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  MicDynData.SetValue(i, 'Volume', TrackBar1.Position);
  Label5.Caption := IntToStr(TrackBar1.Position) + '%';
  Name := MicDynData.GetValue(i, 'Name');

  if Name = MICROPHONE_DEFAULT
    then MxId := GetDefaultMixerMicrophone
    else MxId := GetMixerMicrophone(Name);

  if MicDynData.GetValue(i, 'Fixed') then SetMicrophoneVolume(MxId, TrackBar1.Position, -1);
end;


procedure TForm2.ComboBoxKey(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Key := 0;
end;


initialization
  SettingsMic.HotkeySound := True;
end.

