unit MSIControl;

interface

uses
  Windows, Messages, SysUtils, Dialogs, Classes, Forms, Menus, MMSystem, Graphics, ShellAPI,
  ComCtrls, Controls, StdCtrls, ExtCtrls, StrUtils, TFlatComboBoxUnit, TFlatCheckBoxUnit,
  XiTrackBar, XiButton, CustoHotKey, CustoBevel, CustoTrayIcon, TNTSystem, EmbeddedController,
  uHotKey, uQueryShutdown, uAudioMixer, uThemes, uSettings, uMicrophones, uLanguages, uReadConsole,
  WinXP, Functions;

type
  TForm1 = class(TForm)
    PopupMenu1: TPopupMenu;
    ToggleCoolerBoost1: TMenuItem;
    ToggleAutoruns1: TMenuItem;
    Exit1: TMenuItem;
    Bevel1: TCustoBevel;
    Bevel2: TCustoBevel;
    Bevel3: TCustoBevel;
    Bevel4: TCustoBevel;
    Bevel5: TCustoBevel;
    CheckBox1: TFlatCheckBox;
    CheckBox2: TFlatCheckBox;
    ComboBox1: TFlatComboBox;
    ComboBox2: TFlatComboBox;
    ComboBox3: TFlatComboBox;
    ComboBox4: TFlatComboBox;
    ComboBox5: TFlatComboBox;
    ComboBox6: TFlatComboBox;
    ComboBox7: TFlatComboBox;
    HotKey1: TCustoHotKey;
    HotKey3: TCustoHotKey;
    HotKey2: TCustoHotKey;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    TrackBar1: TXiTrackBar;
    Button1: TXiButton;
    TrayIcon1: TTrayIcon;
    Timer1: TTimer;
    Restart1: TMenuItem;
    ToggleEthernet1: TMenuItem;
    procedure ToggleCoolerBoost1Click(Sender: TObject);
    procedure ToggleAutoruns1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar1MouseUp(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure ComboBoxKey(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure HotKey1Exit(Sender: TObject);
    procedure HotKey1Enter(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TrayIcon1Action(Sender: TObject; Code: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure ComboBox4Change(Sender: TObject);
    procedure ComboBox5Change(Sender: TObject);
    procedure ComboBox6Change(Sender: TObject);
    procedure HotKey2Enter(Sender: TObject);
    procedure HotKey2Exit(Sender: TObject);
    procedure HotKey2Change(Sender: TObject);
    procedure CheckBox2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ComboBox7Change(Sender: TObject);
    procedure HotKey3Enter(Sender: TObject);
    procedure HotKey3Exit(Sender: TObject);
    procedure HotKey3Change(Sender: TObject);
    procedure CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Restart1Click(Sender: TObject);
    procedure ToggleEthernet1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  AppInactive: Boolean = False;
  CurrentMode: Integer = 0;
  EC: TEmbeddedController;

procedure HotKeyCallback(Key, ShortCut: Integer; CustomValue: Variant);
procedure ToggleCoolerBoost;
procedure RemoveFocus;

implementation

{$R *.dfm}


//SetAutoMode
procedure SetAutoMode;
begin
  while EC.readByte(EC_FANS[0]) <> EC_FANS[2] do EC.writeByte(EC_FANS[0], EC_FANS[2]);
end;
//SetAutoMode


//GetBasicValue
function GetBasicValue: Integer;
var
  bResult: Byte;
begin
  while not EC.readByte(EC_FANS[1], bResult) or (bResult = 255) do;
  if bResult >= 128 then Result := 128 - bResult else Result := bResult;
end;
//GetBasicValue


//SetBasicMode
procedure SetBasicMode(Value: Integer);
begin
  if (Value < -15) or (Value > 15) then Exit;
  if (Value <= 0) then Value := 128 + Abs(Value);
  while EC.readByte(EC_FANS[0]) <> EC_FANS[3] do EC.writeByte(EC_FANS[0], EC_FANS[3]);
  while EC.readByte(EC_FANS[1]) <> Value do EC.writeByte(EC_FANS[1], Value);
end;
//SetBasicMode


//GetMode
function GetMode: Byte;
begin
  while not EC.readByte(EC_FANS[0], Result) or (Result = 255) do;
end;
//GetMode


//GetWebcamStatus
function GetWebcamStatus: Boolean;
var
  bResult: Byte;
begin
  while not EC.readByte(EC_WEBCAM[0], bResult) do;
  Result := (bResult = EC_WEBCAM[1]);
end;
//GetWebcamStatus


//SetWebcamStatus
procedure SetWebcamStatus(b: Boolean);
begin
  SetDeviceChangeCallback(nil);

  if b then begin
    while (EC.readByte(EC_WEBCAM[0]) <> EC_WEBCAM[1]) do EC.writeByte(EC_WEBCAM[0], EC_WEBCAM[1]);
  end else begin
    while (EC.readByte(EC_WEBCAM[0]) <> EC_WEBCAM[2]) do EC.writeByte(EC_WEBCAM[0], EC_WEBCAM[2]);
  end;

  Wait(1000);
  SetDeviceChangeCallback(OnDeviceChange);
end;
//SetWebcamStatus


//GetCoolerBoostStatus
function GetCoolerBoostStatus: Boolean;
var
  bResult: Byte;
begin
  while not EC.readByte(EC_CB[0], bResult) or (bResult = 255) do;
  Result := (bResult >= EC_CB[1]);
end;
//GetCoolerBoostStatus


//ToggleCoolerBoost
procedure ToggleCoolerBoost;
var
  bResult: Byte;
begin
  while not EC.readByte(EC_CB[0], bResult) or (bResult = 255) do;

  if bResult >= EC_CB[1] then begin
    while (EC.readByte(EC_CB[0]) <> EC_CB[2]) do EC.writeByte(EC_CB[0], EC_CB[2])
  end else begin
    while (EC.readByte(EC_CB[0]) <> EC_CB[1]) do EC.writeByte(EC_CB[0], EC_CB[1]);
  end;
end;
//ToggleCoolerBoost


//RemoveFocus
procedure RemoveFocus;
begin
  if Form1.Visible then begin
    with TStaticText.Create(Form1) do begin
      Parent := Form1;
      Left := -MaxInt;
      Top := -MaxInt;
      SetFocus;
      Destroy;
    end;
  end;
end;
//RemoveFocus


//HotKeyCallback
procedure HotKeyCallback(Key, ShortCut: Integer; CustomValue: Variant);
var
  bResult: Byte;
begin
  if (CustomValue = 'TOGGLE_COOLER_BOOST') then begin
    if GetSettingByName('HOTKEY_SOUNDS') then PlaySound('HOTKEY', 0, SND_RESOURCE or SND_ASYNC);
    ToggleCoolerBoost;
    UpdateSettingByName('COOLER_BOOST', GetCoolerBoostStatus, False);
  end;

  if (CustomValue = 'CHANGE_MODE_AUTO') then begin
    if GetSettingByName('HOTKEY_SOUNDS') then PlaySound('HOTKEY', 0, SND_RESOURCE or SND_ASYNC);
    Form1.ComboBox2.ItemIndex := 0;
    Form1.ComboBox2Change(nil);
  end;

  if (CustomValue = 'CHANGE_MODE_BASIC') then begin
    if GetSettingByName('HOTKEY_SOUNDS') then PlaySound('HOTKEY', 0, SND_RESOURCE or SND_ASYNC);
    Form1.ComboBox2.ItemIndex := 1;
    Form1.ComboBox2Change(nil);
  end;

  if (CustomValue = 'TOGGLE_WEBCAM') then begin
    if GetSettingByName('HOTKEY_SOUNDS') then PlaySound('HOTKEY', 0, SND_RESOURCE or SND_ASYNC);
    while not EC.readByte(EC_WEBCAM[0], bResult) do;
    UpdateSettingByName('WEBCAM', (bResult <> EC_WEBCAM[1]), False);
    SetWebcamStatus(bResult <> EC_WEBCAM[1]);
  end;

  if (CustomValue = 'MUTE_AUDIO') then SendMessage(Form1.Handle, WM_APPCOMMAND, Form1.Handle, APPCOMMAND_VOLUME_MUTE);
  if (CustomValue = 'INCREASE_AUDIO') then SendMessage(Form1.Handle, WM_APPCOMMAND, Form1.Handle, APPCOMMAND_VOLUME_UP);
  if (CustomValue = 'DECREASE_AUDIO') then SendMessage(Form1.Handle, WM_APPCOMMAND, Form1.Handle, APPCOMMAND_VOLUME_DOWN);
end;
//HotKeyCallback


procedure QueryShutdown(BS: TBlockShutdown);
var
  CloseAction: TCloseAction;
begin
  BS.CreateReason('Disabling drivers...');
  CloseAction := caNone;
  Form1.FormClose(nil, CloseAction);
  BS.DestroyReason;
  TerminateProcess(GetCurrentProcess, 0);
end;


procedure TForm1.Timer1Timer(Sender: TObject);
var
  bResult: Byte;
begin
  while not EC.readByte(EC_CB[0], bResult) or (bResult = 255) do;

  if (bResult >= EC_CB[1]) then begin
    if CurrentMode <> EC_CB[0] then TrayIcon1.Icon := LoadIcon(HInstance, '_TURBO');
    CurrentMode := EC_CB[0];
    Exit;
  end;

  while not EC.readByte(EC_FANS[0], bResult) or (bResult = 255) do;

  case bResult of
    AUTO_MODE: begin
      if CurrentMode <> AUTO_MODE then TrayIcon1.Icon := LoadIcon(HInstance, '_AUTO');
      CurrentMode := AUTO_MODE;
    end;
    BASIC_MODE: begin
      if CurrentMode <> BASIC_MODE then TrayIcon1.Icon := LoadIcon(HInstance, '_BASIC');
      CurrentMode := BASIC_MODE;
    end;
    ADVANCED_MODE: begin
      if CurrentMode <> ADVANCED_MODE then TrayIcon1.Icon := LoadIcon(HInstance, '_ADVANCED');
      CurrentMode := ADVANCED_MODE;
    end;
    else begin
      TrayIcon1.Icon := LoadIcon(HInstance, 'MAINICON');
      CurrentMode := 0;
    end;
  end;
end;


procedure TForm1.TrayIcon1Action(Sender: TObject; Code: Integer);
var
  Point: TPoint;
begin
  case Code of
    WM_RBUTTONUP: begin
      if Form1.Visible then Exit;
      GetCursorPos(Point);
      SetForegroundWindow(Application.Handle);
      Application.ProcessMessages;
      PopupMenu1.Popup(Point.X, Point.Y);
    end;

    WM_LBUTTONUP: begin
      if Form1.Visible then begin
        SetForegroundWindow(Handle);
        Exit;
      end;

      if (not Form1.Visible and not AppInactive)
        then Form1.Show
        else Form1.Hide;
    end;
  end;
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.Caption := Application.Title;
  EC := TEmbeddedController.Create;
  EC.retry := 5;

  if (not EC.driverFileExist or not EC.driverLoaded) then begin
    EC.Close;
    ShowMessage('There was an error initializing driver.');
    TerminateProcess(GetCurrentProcess, 0);
  end;

  LoadSettings;
  ChangeTheme(Theme, Form1);
  TrayIcon1.Icon := LoadIcon(HInstance, 'MAINICON');
  TrayIcon1.Title := Application.Title;
  TrayIcon1.AddToTray;
  Timer1.Enabled := GetSettingByName('TRAY_UPDATE');
  SetQueryShutdown(QueryShutdown);
end;


procedure TForm1.FormShow(Sender: TObject);
var
  CurrentMonitor: TMonitor;
  MonitorWidth, MonitorHeigth: Integer;
  bResult: Byte;
begin
  try
    CurrentMonitor := Screen.MonitorFromPoint(Mouse.CursorPos);
    MonitorWidth := CurrentMonitor.Left + CurrentMonitor.Width;
    MonitorHeigth := CurrentMonitor.Top + CurrentMonitor.Height;
  except
    Restart1Click(nil);
  end;

  ShowWindow(Application.Handle, SW_HIDE);
  SetForegroundWindow(Handle);
  Application.OnDeactivate := FormDeactivate;

  Form1.Left := MonitorWidth - Form1.Width;
  Form1.Top := MonitorHeigth - Form1.Height - (MonitorHeigth - CurrentMonitor.WorkareaRect.Bottom);
  ComboBox1Change(nil);

  case GetMode of
    AUTO_MODE: ComboBox2.ItemIndex := 0;
    BASIC_MODE: ComboBox2.ItemIndex := 1;
    ADVANCED_MODE: begin
      ComboBox2.ItemIndex := 2;
      TrackBar1.Enabled := False;
    end;
  end;

  if TrackBar1.Position = 0 then TrackBar1.Position := 0; //Fix some visual issues
  if ComboBox2.Enabled and (ComboBox2.ItemIndex <> 2) then ComboBox2Change(nil);

  while not EC.readByte(EC_WEBCAM[0], bResult) do;
  UpdateSettingByName('WEBCAM', (bResult = EC_WEBCAM[1]), False);

  GetLanguageList(ComboBox7.Items);
  ComboBox7.ItemIndex := 0;
  ComboBox7Change(nil);

  Form1.Repaint;
end;


procedure TForm1.FormHide(Sender: TObject);
begin
  Application.OnDeactivate := nil;
  HotKey1Exit(nil);
end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
end;


procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled := False;
  TrayIcon1.Destroy;
  EC.Close;
end;


procedure TForm1.FormClick(Sender: TObject);
begin
  with TStaticText.Create(Self) do begin
    Parent := Self;
    Left := -MaxInt;
    Top := -MaxInt;
    SetFocus;
    Destroy;
  end;
end;


procedure TForm1.FormPaint(Sender: TObject);
begin
  Canvas.Pen.Color := RGB(BEVEL_COLOR[Integer(Theme)].R, BEVEL_COLOR[Integer(Theme)].G, BEVEL_COLOR[Integer(Theme)].B);
  Canvas.Rectangle(0, 0, Form1.ClientWidth, Form1.ClientHeight);
end;


procedure TForm1.FormDeactivate(Sender: TObject);
begin
  AppInactive := True;
  Form1.Hide;
  Wait(INACTIVE_TIMEOUT);
  AppInactive := False;
end;


procedure TForm1.ToggleCoolerBoost1Click(Sender: TObject);
begin
  ToggleCoolerBoost;
end;


procedure TForm1.ToggleEthernet1Click(Sender: TObject);
var
  b: Boolean;
begin
  b := not GetEthernetEnabled;

  while GetEthernetEnabled <> b do begin
    SetEthernetEnabled(b);
    Wait(1000);
  end;
end;


procedure TForm1.ToggleAutoruns1Click(Sender: TObject);
var
  S: WideString;
begin
  S := ReadOutput('schtasks.exe /QUERY /TN MSIControl');

  if AnsiContainsText(S, 'ERROR') then begin
    ExecuteProcessAsAdmin('SchTasks', '/Create /SC ONLOGON /RL HIGHEST /TN MSIControl /TR "' + WideParamStr(0) + '" /F', SW_HIDE);
    ShowMessage('Application added to autoruns.');
  end else begin
    ExecuteProcessAsAdmin('SchTasks', '/Delete /TN MSIControl /F', SW_HIDE);
    ShowMessage('Application removed from autoruns.');
  end;
end;


procedure TForm1.Restart1Click(Sender: TObject);
var
  CloseAction: TCloseAction;
begin
  CloseAction := caNone;
  FormClose(nil, CloseAction);
  ExecuteProcessAsAdmin(WideParamStr(0), '', SW_SHOW);
  TerminateProcess(GetCurrentProcess, 0);
end;


procedure TForm1.Exit1Click(Sender: TObject);
var
  CloseAction: TCloseAction;
begin
  CloseAction := caNone;
  FormClose(nil, CloseAction);
  TerminateProcess(GetCurrentProcess, 0);
end;


procedure TForm1.HotKey1Enter(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to Length(HotKeys)-1 do begin
    ChangeShortcut(HotKeys[i].Key, 0);
  end;
end;


procedure TForm1.HotKey1Exit(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to Length(HotKeys)-1 do begin
    if HotKeys[i].Description = ComboBox1.Text then begin
      HotKeys[i].ShortCut := HotKey1.HotKey;
      SaveRegistryInteger(HotKeys[i].ShortCut, DEFAULT_ROOT_KEY, DEFAULT_HOTKEY_KEY, HotKeys[i].Name);
      Break;
    end;
  end;

  for i := 0 to Length(HotKeys)-1 do begin
    ChangeShortcut(HotKeys[i].Key, HotKeys[i].ShortCut);
  end;
end;


procedure TForm1.ComboBox1Change(Sender: TObject);
var
  i: Integer;
begin
  RemoveFocus;

  for i := 0 to Length(HotKeys)-1 do begin
    if HotKeys[i].Description = ComboBox1.Text then begin
      HotKey1.HotKey := HotKeys[i].ShortCut;
      Break;
    end;
  end;
end;


procedure TForm1.ComboBox2Change(Sender: TObject);
begin
  RemoveFocus;

  case ComboBox2.ItemIndex of
    0: begin
      TrackBar1.Enabled := False;
      SetAutoMode;
    end;
    1: begin
      TrackBar1.Enabled := True;
      TrackBar1.Position := GetBasicValue;
      SetBasicMode(TrackBar1.Position);
    end;
    2: begin
      ComboBox2.ItemIndex := 0;
      TrackBar1.Enabled := False;
      SetAutoMode;
    end;
  end;
end;


procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  Label3.Caption := IntToStr(Round(((TrackBar1.Position - TrackBar1.Min) * 100) / (TrackBar1.Max - TrackBar1.Min))) + '%';
end;


procedure TForm1.TrackBar1MouseUp(Sender: TObject);
begin
  SetBasicMode(TrackBar1.Position);
end;


procedure TForm1.HotKey2Change(Sender: TObject);
begin
  mNewHotKey := HotKey2.HotKey;
end;


procedure TForm1.HotKey2Enter(Sender: TObject);
begin
  mOldHotKey := HotKey2.HotKey;
  mNewHotKey := HotKey2.HotKey;
  DisableHotKey(ShortCutToHotKey(mOldHotKey));
end;

procedure TForm1.HotKey2Exit(Sender: TObject);
begin
  SetSetting(ComboBox4.Text, ComboBox5.ItemIndex, ComboBox6.ItemIndex, mOldHotKey, mNewHotKey);
end;


procedure TForm1.ComboBox4Change(Sender: TObject);
begin
  RemoveFocus;
  ComboBox5.ItemIndex := 0;
  ComboBox5Change(nil);
end;


procedure TForm1.ComboBox5Change(Sender: TObject);
begin
  RemoveFocus;
  GenerateOptionList(ComboBox5.ItemIndex, ComboBox6.Items);
  ComboBox6.ItemIndex := 0;
  ComboBox6Change(nil);
  CheckBox2.Visible := (ComboBox5.ItemIndex = 0);
end;


procedure TForm1.ComboBox6Change(Sender: TObject);
begin
  RemoveFocus;
  HotKey2.HotKey := GetSettingHotKey(ComboBox4.Text, ComboBox5.ItemIndex, ComboBox6.ItemIndex);
  CheckBox2.Checked := (GetFixedVolume(ComboBox4.Text) = (ComboBox6.ItemIndex*5));
end;


procedure TForm1.CheckBox2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if CheckBox2.Checked
    then SetFixedVolume(ComboBox4.Text, ComboBox6.ItemIndex*5)
    else SetFixedVolume(ComboBox4.Text, -1);
end;


procedure TForm1.ComboBox7Change(Sender: TObject);
var
  KeyboardLayout: HKL;
begin
  KeyboardLayout := Hkl(ComboBox7.Items.Objects[ComboBox7.ItemIndex]);
  HotKey3.HotKey := GetLanguageHotKey(KeyboardLayout);
end;


procedure TForm1.HotKey3Change(Sender: TObject);
begin
  lNewHotKey := HotKey3.HotKey;
end;


procedure TForm1.HotKey3Enter(Sender: TObject);
begin
  lOldHotKey := HotKey3.HotKey;
  lNewHotKey := HotKey3.HotKey;
  DisableHotKey(ShortCutToHotKey(lOldHotKey));
end;


procedure TForm1.HotKey3Exit(Sender: TObject);
var
  KeyboardLayout: HKL;
begin
  KeyboardLayout := Hkl(ComboBox7.Items.Objects[ComboBox7.ItemIndex]);
  SetLanguageHotKey(KeyboardLayout, lOldHotKey, lNewHotKey);
end;


procedure TForm1.ComboBox3Change(Sender: TObject);
var
  Name: WideString;
begin
  RemoveFocus;
  Name := GetNameFromDescription(ComboBox3.Text);

  if Name = 'WEBCAM' then begin
    CheckBox1.Checked := GetWebcamStatus;
    Exit;
  end;

  if Name = 'COOLER_BOOST' then begin
    CheckBox1.Checked := GetCoolerBoostStatus;
    Exit;
  end;

  CheckBox1.Checked := GetSettingByDescription(ComboBox3.Text);
end;


procedure TForm1.CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Name: WideString;
begin
  RemoveFocus;
  Name := GetNameFromDescription(ComboBox3.Text);

  if Name = 'WEBCAM' then begin
    SetWebcamStatus(CheckBox1.Checked);
    Exit;
  end;

  if Name = 'COOLER_BOOST' then begin
    ToggleCoolerBoost;
    CheckBox1.Checked := GetCoolerBoostStatus;
    Exit;
  end;

  if Name = 'TRAY_UPDATE' then begin
    Timer1.Enabled := CheckBox1.Checked;

    if not CheckBox1.Checked then begin
      TrayIcon1.Icon := LoadIcon(HInstance, 'MAINICON');
      CurrentMode := 0;
    end else Timer1Timer(nil);
  end;

  UpdateSettingByDescription(ComboBox3.Text, CheckBox1.Checked, True);
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  Theme := not Theme;

  try
    ChangeTheme(Theme, Form1);
  except
  end;
end;


procedure TForm1.ComboBoxKey(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Key := 0;
end;

end.
