unit MSILanguages;

interface

uses
  Windows, Classes, Controls, Forms, ExtCtrls, ComCtrls, StdCtrls, MMSystem, CustoBevel,
  CustoHotKey, TFlatComboBoxUnit, TFlatCheckBoxUnit, MSIControl, MSIThemes, uHotKey,
  uDynamicData, Functions;

type
  TForm4 = class(TForm)
    Bevel1: TCustoBevel;
    Bevel2: TCustoBevel;
    CheckBox1: TFlatCheckBox;
    ComboBox1: TFlatComboBox;
    HotKey1: TCustoHotKey;
    Label1: TLabel;
    Label2: TLabel;
    procedure CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ComboBox1Change(Sender: TObject);
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
  TSettingsLan = record
    HotkeySound: Boolean;
  end;

const
  DEFAULT_LANGUAGES_KEY = DEFAULT_KEY + '\Languages';

var
  Form4: TForm4;
  LanDynData: TDynamicData;
  SettingsLan: TSettingsLan;
  mOldHotKey: Integer;
  mNewHotKey: Integer;

function LayoutActive(kbLayout: HKL):Boolean;
procedure GetLanguageList(List: TStrings);

implementation

{$R *.dfm}

function LayoutActive(kbLayout: HKL):Boolean;
var
  HklList: array [0..9] of HKL;
  i: Integer;
begin
  Result := True;
  if (kbLayout = 0) or (kbLayout = 1) then Exit;
  Result := False;

  for i := 0 to GetKeyboardLayoutList(SizeOf(HklList), HklList)-1 do begin
    if HklList[i] = kbLayout then Result := True;
  end;
end;


procedure GetLanguageList(List: TStrings);
var
  HklList: array [0..9] of HKL;
  AklName: array [0..255] of WideChar;
  i: Integer;
begin
  List.Clear;
  List.AddObject('Next', TObject(1));
  List.AddObject('Previous', TObject(0));

  for i := 0 to GetKeyboardLayoutList(SizeOf(HklList), HklList)-1 do begin
    GetLocaleInfoW(LoWord(HklList[i]), LOCALE_SLANGUAGE, AklName, SizeOf(AklName));
    List.AddObject(AklName, TObject(HklList[i]));
  end;
end;


procedure LanguageHotKeyCallback(Key, ShortCut: Integer; CustomValue: Variant);
const
  WM_INPUTLANGCHANGEREQUEST = $0050;
var
  Dummy: DWORD;
  fWindow, kbLayout: HWND;
begin
  if SettingsLan.HotkeySound then PlaySound('HOTKEY', 0, SND_RESOURCE or SND_ASYNC);
  fWindow := GetForegroundWindow;
  SetForegroundWindow(Application.Handle);
  kbLayout := CustomValue;
  SendMessageTimeOut(Application.Handle, WM_INPUTLANGCHANGEREQUEST, 0, kbLayout, SMTO_ABORTIFHUNG, 200, Dummy);
  SetForegroundWindow(fWindow);
end;


procedure TForm4.FormCreate(Sender: TObject);
var
  i, Hotkey: Integer;
  kbLayout: HKL;
begin
  LanDynData := TDynamicData.Create(['kbLayout', 'Hotkey']);
  LanDynData.Load(True, True, DEFAULT_ROOT_KEY, DEFAULT_LANGUAGES_KEY, 'Languages', True);
  LoadRegistryBoolean(SettingsLan.HotkeySound, DEFAULT_ROOT_KEY, DEFAULT_LANGUAGES_KEY, 'HotkeySound');

  for i := 0 to (LanDynData.GetLength-1) do begin
    kbLayout := LanDynData.GetValue(i, 'kbLayout');
    Hotkey := LanDynData.GetValue(i, 'Hotkey');
    if (Hotkey > 0) and LayoutActive(kbLayout) then SetShortCut(LanguageHotKeyCallback, Hotkey, kbLayout);
  end;

  CheckBox1.Checked := SettingsLan.HotkeySound;
  GetLanguageList(ComboBox1.Items);
  ComboBox1.ItemIndex := 0;
  ComboBox1Change(nil);
  ChangeTheme(Theme, Form4);
end;


procedure TForm4.FormShow(Sender: TObject);
begin
  MSIControl.RemoveFocus(Form4);
end;


procedure TForm4.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LanDynData.Save(True, DEFAULT_ROOT_KEY, DEFAULT_LANGUAGES_KEY, 'Languages');
  SaveRegistryBoolean(SettingsLan.HotkeySound, DEFAULT_ROOT_KEY, DEFAULT_LANGUAGES_KEY, 'HotkeySound');
end;


procedure TForm4.FormClick(Sender: TObject);
begin
  MSIControl.RemoveFocus(Form4);
end;


procedure TForm4.ComboBox1Change(Sender: TObject);
var
  i: Integer;
  kbLayout: HKL;
begin
  kbLayout := Hkl(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  i := LanDynData.FindIndex(0, 'kbLayout', kbLayout);
  HotKey1.HotKey := Q((i < 0), 0, LanDynData.GetValue(i, 'Hotkey'));
end;


procedure TForm4.HotKey1Exit(Sender: TObject);
var
  i, Key: Integer;
  kbLayout: HKL;
begin
  if (mNewHotKey = mOldHotKey) then EnableHotKey(ShortCutToHotKey(mOldHotKey));
  if (mNewHotKey = mOldHotKey) then Exit;

  kbLayout := Hkl(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  i := LanDynData.FindIndex(0, 'kbLayout', kbLayout);
  if i < 0 then i := LanDynData.CreateData(-1);
  LanDynData.SetValue(i, 'kbLayout', kbLayout);
  LanDynData.SetValue(i, 'Hotkey', mNewHotKey);

  if (mNewHotKey = 0) then LanDynData.DeleteData(i);
  if (mNewHotKey = 0) then RemoveHotKey(ShortCutToHotKey(mOldHotKey));
  if (mNewHotKey = 0) then Exit;

  if (mOldHotKey <> 0) then Key := ShortCutToHotKey(mOldHotKey) else Key := -1;
  if (Key > -1) then ChangeShortCut(Key, mNewHotKey) else SetShortCut(LanguageHotKeyCallback, mNewHotKey, kbLayout);
end;


procedure TForm4.HotKey1Enter(Sender: TObject);
begin
  mOldHotKey := HotKey1.HotKey;
  mNewHotKey := HotKey1.HotKey;
  DisableHotKey(ShortCutToHotKey(mOldHotKey));
end;


procedure TForm4.HotKey1Change(Sender: TObject);
begin
  mNewHotKey := HotKey1.HotKey;
end;


procedure TForm4.CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SettingsLan.HotkeySound := CheckBox1.Checked;
end;


initialization
  SettingsLan.HotkeySound := True;
end.
