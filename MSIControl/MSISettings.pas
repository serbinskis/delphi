unit MSISettings;

interface

uses
  Windows, uHotKey, MSIThemes, Functions;

type
  THotKey = record
    Key: Integer;
    ShortCut: Integer;
    Name: WideString;
    Description: WideString;
  end;

type
  TSetting = record
    Name: WideString;
    Description: WideString;
  end;

var
  HotKeys: array[0..6] of THotKey = (
    (Key: 0; ShortCut: 0; Name: 'TOGGLE_COOLER_BOOST'; Description: 'Toggle Cooler Boost'),
    (Key: 0; ShortCut: 0; Name: 'CHANGE_MODE_BASIC'; Description: 'Change Mode To Basic'),
    (Key: 0; ShortCut: 0; Name: 'CHANGE_MODE_AUTO'; Description: 'Change Mode To Auto'),
    (Key: 0; ShortCut: 0; Name: 'TOGGLE_WEBCAM'; Description: 'Toggle Webcam'),
    (Key: 0; ShortCut: 0; Name: 'MUTE_AUDIO'; Description: 'Mute Audio'),
    (Key: 0; ShortCut: 0; Name: 'INCREASE_AUDIO'; Description: 'Increase Audio'),
    (Key: 0; ShortCut: 0; Name: 'DECREASE_AUDIO'; Description: 'Decrease Audio')
  );

var
  Settings: array[0..5] of TSetting = (
    (Name: 'HOTKEY_SOUNDS'; Description: 'HotKey Sounds'),
    (Name: 'MICROPHONES_HOTKEY_SOUNDS'; Description: 'Microphones HotKey Sounds'),
    (Name: 'LANGUAGES_HOTKEY_SOUNDS'; Description: 'Languages HotKey Sounds'),
    (Name: 'WEBCAM'; Description: 'MSI Webcam'),
    (Name: 'COOLER_BOOST'; Description: 'Cooler Boost'),
    (Name: 'TRAY_UPDATE'; Description: 'Fan Mode Tray Update')
  );

const
  DEFAULT_ROOT_KEY = HKEY_CURRENT_USER;
  DEFAULT_KEY = '\Software\MSIControl';
  DEFAULT_HOTKEY_KEY = '\Software\MSIControl\HotKeys';
  THEME_REGISTRY_NAME = 'THEME';
  INACTIVE_TIMEOUT = 350;

const
  APPCOMMAND_VOLUME_MUTE = $80000;
  APPCOMMAND_VOLUME_UP = $A0000;
  APPCOMMAND_VOLUME_DOWN = $90000;

const
  AUTO_MODE = $0C;
  BASIC_MODE = $4C;
  ADVANCED_MODE = $8C;

const
  //0 - Address; 1 - ON; 2 - OFF
  EC_WEBCAM: array[0..2] of Integer = ($2E, $4B, $49);
  EC_CB: array[0..2] of Integer = ($98, $80, $00);
  //0 - Address; 1 - Speed Address; 2 - Auto; 3 - Basic; 4 - Advanced;
  EC_FANS: array[0..4] of Integer = ($F4, $F5, AUTO_MODE, BASIC_MODE, ADVANCED_MODE);

procedure LoadSettings;
procedure UpdateSettingByDescription(Description: WideString; Value, Registry: Boolean);
procedure UpdateSettingByName(Name: WideString; Value, Registry: Boolean);
function GetSettingByDescription(Description: WideString): Boolean;
function GetSettingByName(Name: WideString): Boolean;
function GetNameFromDescription(Description: WideString): WideString;
function GetDescriptionFromName(Name: WideString): WideString;

implementation

uses
  MSIControl, MSIMicrophones, MSIShadowPlay, MSILanguages;

procedure LoadSettings;
var
  i: Integer;
begin
  LoadRegistryBoolean(Theme, DEFAULT_ROOT_KEY, DEFAULT_KEY, THEME_REGISTRY_NAME);

  for i := 0 to Length(HotKeys)-1 do begin
    Form1.ComboBox1.Items.Add(HotKeys[i].Description);
    LoadRegistryInteger(HotKeys[i].ShortCut, DEFAULT_ROOT_KEY, DEFAULT_HOTKEY_KEY, HotKeys[i].Name);
    HotKeys[i].Key := SetShortCut(HotKeyCallback, HotKeys[i].ShortCut, HotKeys[i].Name);
  end;

  for i := 0 to Length(Settings)-1 do begin
    Form1.ComboBox3.Items.Add(Settings[i].Description);
  end;

  Form1.ComboBox1.ItemIndex := 0;
  Form1.ComboBox3.ItemIndex := 0;
  LoadLanguageSetting;
end;


procedure UpdateSettingByDescription(Description: WideString; Value, Registry: Boolean);
var
  i: Integer;
begin
  if Registry then for i := 0 to Length(Settings)-1 do begin
    if Settings[i].Description = Description then begin
      SaveRegistryBoolean(Value, DEFAULT_ROOT_KEY, DEFAULT_KEY, Settings[i].Name);
    end;
  end;

  if Form1.ComboBox3.Text = Description then Form1.CheckBox1.Checked := Value;
end;


procedure UpdateSettingByName(Name: WideString; Value, Registry: Boolean);
var
  i: Integer;
begin
  if Registry then for i := 0 to Length(Settings)-1 do begin
    if Settings[i].Name = Name then begin
      SaveRegistryBoolean(Value, DEFAULT_ROOT_KEY, DEFAULT_KEY, Settings[i].Name);
    end;
  end;

  if GetNameFromDescription(Form1.ComboBox3.Text) = Name then Form1.CheckBox1.Checked := Value;
end;


function GetSettingByDescription(Description: WideString): Boolean;
var
  i: Integer;
begin
  Result := False;

  for i := 0 to Length(Settings)-1 do begin
    if Settings[i].Description = Description
      then LoadRegistryBoolean(Result, DEFAULT_ROOT_KEY, DEFAULT_KEY, Settings[i].Name);
  end;
end;


function GetSettingByName(Name: WideString): Boolean;
var
  i: Integer;
begin
  Result := False;

  for i := 0 to Length(Settings)-1 do begin
    if Settings[i].Name = Name
      then LoadRegistryBoolean(Result, DEFAULT_ROOT_KEY, DEFAULT_KEY, Settings[i].Name);
  end;
end;

function GetNameFromDescription(Description: WideString): WideString;
var
  i: Integer;
begin
  Result := '';

  for i := 0 to Length(Settings)-1 do begin
    if Settings[i].Description = Description then Result := Settings[i].Name;
  end;
end;


function GetDescriptionFromName(Name: WideString): WideString;
var
  i: Integer;
begin
  Result := '';

  for i := 0 to Length(Settings)-1 do begin
    if Settings[i].Name = Name then Result := Settings[i].Description;
  end;
end;

end.