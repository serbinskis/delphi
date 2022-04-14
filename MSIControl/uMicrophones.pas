unit uMicrophones;

interface

uses
  Windows, SysUtils, Classes, Variants, MMSystem, TNTRegistry, TNTClasses, TNTSysUtils,
  AMixer, uSettings, uHotKey, uAudioMixer, Functions;

const
  DEFAULT_MICROPHONE_KEY = '\Software\MSIControl\Microphones';
  MICROPHONE_DEFAULT = 'Default';

var
  mOldHotKey: Integer;
  mNewHotKey: Integer;

procedure OnDeviceChange(wParam: Integer);
procedure LoadMicrophoneSettings;
procedure GetMicrophoneList(List: TStrings);
procedure GenerateOptionList(Option: Integer; List: TStrings);
procedure SetSetting(MicrophoneName: WideString; Option, Value: Integer; oHotKey, nHotKey: Integer);
procedure SetFixedVolume(MicrophoneName: WideString; Value: Integer);
function GetSettingHotKey(MicrophoneName: WideString; Option, Value: Integer): Integer;
function GetFixedVolume(MicrophoneName: WideString): Integer;

implementation

uses
  MSIControl;

procedure MicrophoneHotKeyCallback(Key, ShortCut: Integer; CustomValue: Variant);
var
  Registry: TTNTRegistry;
  mOption, mValue, mIndex: Integer;
  mName: WideString;
begin
  if GetSettingByName('MICROPHONES_HOTKEY_SOUNDS') then PlaySound('HOTKEY', 0, SND_RESOURCE or SND_ASYNC);

  Registry := TTNTRegistry.Create;
  Registry.RootKey := DEFAULT_ROOT_KEY;
  Registry.OpenKey(DEFAULT_MICROPHONE_KEY + '\' + IntToStr(ShortCut), True);

  if Registry.ValueExists('Name') then mName := Registry.ReadString('Name');
  if Registry.ValueExists('Option') then mOption := Registry.ReadInteger('Option') else mOption := -1;
  if Registry.ValueExists('Value') then mValue := Registry.ReadInteger('Value') else mValue := -1;
  if (mOption < 0) or (mOption > 1) then Exit;

  if mName = 'Default'
    then mIndex := GetDefaultMixerMicrophone
    else mIndex := GetMixerMicrophone(mName);

  if mIndex < 0 then Exit;

  case mOption of
    0: begin //Set volume
      if mValue < 0 then mValue := 0;
      if mValue > 20 then mValue := 20;
      SetMicrophoneVolume(mIndex, 100-(mValue*5), -1);
      SetMicrophoneVolume(mIndex, mValue*5, -1);
    end;
    1: begin //Mute or Unmute
      if mValue < 0 then mValue := 0;
      if mValue > 1 then mValue := 1;
      SetMicrophoneVolume(mIndex, -1, Integer(not Boolean(mValue)));
    end;
  end;

  Registry.Free;
end;

procedure OnDeviceChange(wParam: Integer);
begin
  if (wParam = 7) then begin
    if Form1.Visible then begin
      Form1.HotKey2.OnExit := nil;
      Form1.HotKey2.HotKey := mOldHotKey;
      RemoveFocus;
      Form1.HotKey2.OnExit := Form1.HotKey2Exit;
    end;

    GetMicrophoneList(Form1.ComboBox4.Items);
    Form1.ComboBox4.ItemIndex := 0;
    Form1.ComboBox4Change(nil);
  end;
end;

procedure OnMixerChange(Msg: Integer; hMixer: HMIXER; MxId: Integer);
var
  mName: WideString;
  mVolume: Integer;
begin
  if Msg <> MM_MIXM_CONTROL_CHANGE then Exit;

  if MxId = GetDefaultMixerMicrophone
    then mName := 'Default'
    else mName := GetMixerMicrophoneName(MxId);

  mVolume := GetFixedVolume(mName);
  if mVolume < 0 then Exit;
  if mVolume > 100 then mVolume := 100;
  if mVolume = GetMicrophoneVolume(MxId) then Exit;
  SetMicrophoneVolume(MxId, mVolume, -1);
end;

procedure LoadMicrophoneSettings;
var
  Registry: TTNTRegistry;
  SubList: TTNTStringList;
  i, j, MxId: Integer;
  Name: WideString;
begin
  SubList := TTNTStringList.Create;
  Registry := TTNTRegistry.Create;
  Registry.RootKey := DEFAULT_ROOT_KEY;
  Registry.OpenKey(DEFAULT_MICROPHONE_KEY, True);
  Registry.GetKeyNames(SubList);

  for i := 0 to SubList.Count-1 do begin
    Registry.OpenKey(DEFAULT_MICROPHONE_KEY + '\' + SubList.Strings[i], True);
    if Registry.ValueExists('Name') then Name := Registry.ReadString('Name');
    if Name <> MICROPHONE_DEFAULT then j := GetMixerMicrophone(Name) else j := 0;
    if j > -1 then SetShortCut(MicrophoneHotKeyCallback, StrToInt(SubList.Strings[i]), Null);
  end;

  Registry.OpenKey(DEFAULT_MICROPHONE_KEY, True);
  Registry.GetValueNames(SubList);

  for i := 0 to SubList.Count-1 do begin
    j := Registry.ReadInteger(SubList.Strings[i]);
    if j < 0 then j := 0;
    if j > 100 then j := 0;

    if SubList.Strings[i] = MICROPHONE_DEFAULT then MxId := GetDefaultMixerMicrophone else MxId := GetMixerMicrophone(SubList.Strings[i]);
    if MxId > -1 then SetMicrophoneVolume(MxId, j, -1);
  end;

  SubList.Free;
  Registry.Free;

  GetMicrophoneList(Form1.ComboBox4.Items);
  Form1.ComboBox4.ItemIndex := 0;
  Form1.ComboBox4Change(nil);

  SetDeviceChangeCallback(OnDeviceChange);
  SetMixerChangeCallback(OnMixerChange);
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

procedure GenerateOptionList(Option: Integer; List: TStrings);
var
  i: Integer;
begin
  List.Clear;

  case Option of
    0: begin
      for i := 0 to 20 do List.Add('Volume ' + IntToStr(i*5) + '%');
    end;
    1: begin
      List.Add('Enable');
      List.Add('Disable');
    end;
  end;
end;

procedure SetSetting(MicrophoneName: WideString; Option, Value: Integer; oHotKey, nHotKey: Integer);
var
  Key: Integer;
begin
  DeleteRegistryKey(DEFAULT_ROOT_KEY, DEFAULT_MICROPHONE_KEY + '\' + IntToStr(oHotKey));

  if nHotKey = 0 then begin
    RemoveHotKey(ShortCutToHotKey(oHotKey));
    Exit;
  end;

  SaveRegistryWideString(MicrophoneName, DEFAULT_ROOT_KEY, DEFAULT_MICROPHONE_KEY + '\' + IntToStr(nHotKey), 'Name');
  SaveRegistryInteger(Option, DEFAULT_ROOT_KEY, DEFAULT_MICROPHONE_KEY + '\' + IntToStr(nHotKey), 'Option');
  SaveRegistryInteger(Value, DEFAULT_ROOT_KEY, DEFAULT_MICROPHONE_KEY + '\' + IntToStr(nHotKey), 'Value');

  if oHotKey <> 0 then Key := ShortCutToHotKey(oHotKey) else Key := -1;
  if Key > -1 then ChangeShortCut(Key, nHotKey) else SetShortCut(MicrophoneHotKeyCallback, nHotKey, Null);
end;

function GetSettingHotKey(MicrophoneName: WideString; Option, Value: Integer): Integer;
var
  Registry: TTNTRegistry;
  SubKeys: TTNTStringList;
  i, o, v: Integer;
  x: WideString;
begin
  Result := 0;

  SubKeys := TTNTStringList.Create;
  Registry := TTNTRegistry.Create;
  Registry.RootKey := DEFAULT_ROOT_KEY;
  Registry.OpenKey(DEFAULT_MICROPHONE_KEY, True);
  Registry.GetKeyNames(SubKeys);

  for i := 0 to SubKeys.Count-1 do begin
    Registry.OpenKey(DEFAULT_MICROPHONE_KEY + '\' + SubKeys.Strings[i], True);
    if Registry.ValueExists('Name') then x := Registry.ReadString('Name');
    if Registry.ValueExists('Option') then o := Registry.ReadInteger('Option') else o := -1;
    if Registry.ValueExists('Value') then v := Registry.ReadInteger('Value') else v := -1;
    if (MicrophoneName = x) and (Option = o) and (Value = v) then Result := StrToInt(SubKeys.Strings[i]);
  end;

  SubKeys.Free;
  Registry.Free;
end;

procedure SetFixedVolume(MicrophoneName: WideString; Value: Integer);
var
  MxId: Integer;
begin
  MicrophoneName := TNT_WideStringReplace(MicrophoneName, '\', '_', [rfReplaceAll]);

  if Value > -1 then begin
    SaveRegistryInteger(Value, DEFAULT_ROOT_KEY, DEFAULT_MICROPHONE_KEY, MicrophoneName);
    if MicrophoneName = MICROPHONE_DEFAULT then MxId := GetDefaultMixerMicrophone else MxId := GetMixerMicrophone(MicrophoneName);
    if MxId > -1 then SetMicrophoneVolume(MxId, Value, -1);
  end else begin
    DeleteRegistryValue(DEFAULT_ROOT_KEY, DEFAULT_MICROPHONE_KEY, MicrophoneName);
  end;
end;

function GetFixedVolume(MicrophoneName: WideString): Integer;
begin
  Result := -1;
  MicrophoneName := TNT_WideStringReplace(MicrophoneName, '\', '_', [rfReplaceAll]);
  LoadRegistryInteger(Result, DEFAULT_ROOT_KEY, DEFAULT_MICROPHONE_KEY, MicrophoneName);
end;

end.