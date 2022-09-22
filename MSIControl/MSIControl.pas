unit MSIControl;

interface

uses
  Windows, Messages, SysUtils, Dialogs, Classes, Forms, Menus, MMSystem, Graphics, ShellAPI,
  ComCtrls, Controls, StdCtrls, ExtCtrls, StrUtils, TFlatComboBoxUnit, TFlatCheckBoxUnit,
  XiTrackBar, XiButton, CustoHotKey, CustoBevel, CustoTrayIcon, TNTSystem, WinXP, MSIThemes,
  uHotKey, uNotify, uReadConsole, uDynamicData, MSIController, Functions;

type
  TForm1 = class(TForm)
    Bevel1: TCustoBevel;
    Bevel2: TCustoBevel;
    Bevel3: TCustoBevel;
    Button1: TXiButton;
    Button2: TXiButton;
    Button3: TXiButton;
    Button4: TXiButton;
    Button5: TXiButton;
    Button6: TXiButton;
    Button7: TXiButton;
    CheckBox1: TFlatCheckBox;
    ComboBox1: TFlatComboBox;
    ComboBox2: TFlatComboBox;
    ComboBox3: TFlatComboBox;
    Exit1: TMenuItem;
    HotKey1: TCustoHotKey;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    PopupMenu1: TPopupMenu;
    Restart1: TMenuItem;
    Timer1: TTimer;
    Toggle1: TMenuItem;
    ToggleAutoruns1: TMenuItem;
    ToggleCoolerBoost1: TMenuItem;
    TrackBar1: TXiTrackBar;
    TrayIcon1: TTrayIcon;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HotKey1Change(Sender: TObject);
    procedure HotKey1Enter(Sender: TObject);
    procedure HotKey1Exit(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure Restart1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ToggleAutoruns1Click(Sender: TObject);
    procedure ToggleCoolerBoost1Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar1MouseUp(Sender: TObject);
    procedure TrayIcon1Action(Sender: TObject; Code: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  DEFAULT_ROOT_KEY = HKEY_CURRENT_USER;
  DEFAULT_KEY = '\Software\WobbyChip\MSIControl';
  INACTIVE_TIMEOUT = 350;
  STARTUP_SECONDS = 300;

var
  Form1: TForm1;
  HotkeyDynData: TDynamicData;
  SettingDynData: TDynamicData;
  ShutdownCallbacks: TList;
  MSI: TMSIController;
  AppInactive: Boolean = False;
  Counter: Integer;
  mOldHotKey: Integer;
  mNewHotKey: Integer;

procedure HotkeyCallback(Key, ShortCut: Integer; CustomValue: Variant);
procedure RemoveFocus(Form: TForm);

implementation

uses
  MSIMicrophones, MSIShadowPlay, MSILanguages, MSIConnections, MSIWakeOnLan,
  MSIKeyboard, MSIMonitors;

{$R *.dfm}


//RemoveFocus
procedure RemoveFocus(Form: TForm);
begin
  if Form.Visible then begin
    with TStaticText.Create(Form) do begin
      Parent := Form;
      Left := -MaxInt;
      Top := -MaxInt;
      SetFocus;
      Destroy;
    end;
  end;
end;
//RemoveFocus


//HotkeyCallback
procedure HotkeyCallback(Key, ShortCut: Integer; CustomValue: Variant);
var
  i: Integer;
begin
  i := SettingDynData.FindIndex(0, 'Name', 'SETTING_HOTKEY_SOUND');
  if (i > -1) and SettingDynData.GetValue(i, 'Value') then PlaySound('HOTKEY', 0, SND_RESOURCE or SND_ASYNC);

  if (CustomValue = 'HOTKEY_TOGGLE_CB') then MSI.ToggleCoolerBoost;
  if (CustomValue = 'HOTKEY_TOGGLE_WEBCAM') then MSI.ToggleWebcam;

  if (CustomValue = 'HOTKEY_CHANGE_MODE_AUTO') then begin
    Form1.ComboBox2.ItemIndex := 0;
    Form1.ComboBox2Change(nil);
  end;

  if (CustomValue = 'HOTKEY_CHANGE_MODE_BASIC') then begin
    Form1.ComboBox2.ItemIndex := 1;
    Form1.ComboBox2Change(nil);
  end;

  Form1.ComboBox3Change(nil);
end;
//HotkeyCallback


procedure QueryShutdown(CreateReason: TShutdownCreateReason; DestroyReason: TShutdownDestroyReason);
var
  CloseAction: TCloseAction;
  i: Integer;
begin
  CreateReason('Closing MSIControls...');
  for i := 0 to ShutdownCallbacks.Count-1 do TProcedure(ShutdownCallbacks.Items[i]);
  CloseAction := caNone;
  Form1.FormClose(nil, CloseAction);
  DestroyReason;
  TerminateProcess(GetCurrentProcess, 0);
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
var
  Name: WideString;
  i, v: Integer;
begin
  Form1.Caption := Application.Title;
  MSI := TMSIController.Create;
  ShutdownCallbacks := TList.Create;

  if not MSI.isECLoaded then begin
    ShowMessage('There was an error initializing driver.');
    TerminateProcess(GetCurrentProcess, 0);
  end;

  HotkeyDynData := TDynamicData.Create(['Hotkey', 'Name', 'Description']);
  HotkeyDynData.CreateData(-1, -1, ['Hotkey', 'Name', 'Description'], [0, 'HOTKEY_TOGGLE_CB', 'Toggle Cooler Boost']);
  HotkeyDynData.CreateData(-1, -1, ['Hotkey', 'Name', 'Description'], [0, 'HOTKEY_TOGGLE_WEBCAM', 'Toggle Webcam']);
  HotkeyDynData.CreateData(-1, -1, ['Hotkey', 'Name', 'Description'], [0, 'HOTKEY_CHANGE_MODE_AUTO', 'Change Mode To Auto']);
  HotkeyDynData.CreateData(-1, -1, ['Hotkey', 'Name', 'Description'], [0, 'HOTKEY_CHANGE_MODE_BASIC', 'Change Mode To Basic']);

  SettingDynData := TDynamicData.Create(['Value', 'Name', 'Description']);
  SettingDynData.CreateData(-1, -1, ['Value', 'Name', 'Description'], [True, 'SETTING_HOTKEY_SOUND', 'Enable Hotkey Sounds']);
  SettingDynData.CreateData(-1, -1, ['Value', 'Name', 'Description'], [False, 'SETTING_CLEAR_CRASH_DUMPS', 'Clear Crash Dumps On Start']);
  SettingDynData.CreateData(-1, -1, ['Value', 'Name', 'Description'], [False, 'SETTING_COOLER_BOOST', 'Enable Cooler Boost']);
  SettingDynData.CreateData(-1, -1, ['Value', 'Name', 'Description'], [False, 'SETTING_WEBCAM', 'Enable MSI Webcam']);
  SettingDynData.CreateData(-1, -1, ['Value', 'Name', 'Description'], [False, 'SETTING_AUTO_DISABLE_WEBCAM', 'Disable MSI Webcam On Startup']);
  SettingDynData.CreateData(-1, -1, ['Value', 'Name', 'Description'], [False, 'SETTING_OVERHEATING', 'Prevent GPU overheating, enables Cooler Boost']);

  for i := 0 to HotkeyDynData.GetLength-1 do begin
    ComboBox1.Items.Add(HotkeyDynData.GetValue(i, 'Description'));
    Name := HotkeyDynData.GetValue(i, 'Name');
    if LoadRegistryInteger(v, DEFAULT_ROOT_KEY, DEFAULT_KEY, Name) then begin
      HotkeyDynData.SetValue(i, 'Hotkey', v);
      SetShortCut(HotkeyCallback, v, Name);
    end;
  end;

  for i := 0 to SettingDynData.GetLength-1 do begin
    ComboBox3.Items.Add(SettingDynData.GetValue(i, 'Description'));
    Name := SettingDynData.GetValue(i, 'Name');
    if LoadRegistryInteger(v, DEFAULT_ROOT_KEY, DEFAULT_KEY, Name) then SettingDynData.SetValue(i, 'Value', v);
  end;

  v := SettingDynData.FindValue(0, 'Name', 'SETTING_CLEAR_CRASH_DUMPS', 'Value');
  if (v > 0) then DeleteDirectory(GetEnvironmentVariable('LocalAppData') + '\CrashDumps');

  v := SettingDynData.FindValue(0, 'Name', 'SETTING_OVERHEATING', 'Value');
  Timer1.Enabled := (v > 0);

  v := SettingDynData.FindValue(0, 'Name', 'SETTING_AUTO_DISABLE_WEBCAM', 'Value');
  if (v > 0) then MSI.SetWebcamEnabled(False);

  if LoadRegistryInteger(v, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'FAN_MODE') then MSI.SetFanMode(TModeType(v));

  ComboBox1.ItemIndex := 0;
  ComboBox1Change(nil);
  ComboBox3.ItemIndex := 0;
  ComboBox3Change(nil);

  TrayIcon1.Icon := LoadIcon(HInstance, 'MAINICON');
  TrayIcon1.Title := Application.Title;
  TrayIcon1.AddToTray;

  LoadRegistryBoolean(Theme, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'THEME');
  AddShutdownCallback(QueryShutdown);
  ChangeTheme(Theme, Form1);
end;


procedure TForm1.FormShow(Sender: TObject);
var
  CurrentMonitor: TMonitor;
  MonitorWidth, MonitorHeigth: Integer;
begin
  try
    CurrentMonitor := Screen.MonitorFromPoint(Mouse.CursorPos);
    MonitorWidth := CurrentMonitor.Left + CurrentMonitor.Width;
    MonitorHeigth := CurrentMonitor.Top + CurrentMonitor.Height;
  except
    Restart1Click(nil);
    Exit;
  end;

  ShowWindow(Application.Handle, SW_HIDE);
  SetForegroundWindow(Handle);
  Application.OnDeactivate := FormDeactivate;

  Form1.Left := MonitorWidth - Form1.Width;
  Form1.Top := MonitorHeigth - Form1.Height - (MonitorHeigth - CurrentMonitor.WorkareaRect.Bottom);
  ComboBox1Change(nil);

  case MSI.GetFanMode of
    modeAuto: ComboBox2.ItemIndex := 0;
    modeBasic: ComboBox2.ItemIndex := 1;
    modeAdvanced: begin
      ComboBox2.ItemIndex := 2;
      TrackBar1.Enabled := False;
    end;
  end;

  TrackBar1.Position := MSI.GetBasicValue;
  if ComboBox2.Enabled and (ComboBox2.ItemIndex <> 2) then ComboBox2Change(nil);

  ComboBox3Change(nil);
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
var
  i: Integer;
begin
  for i := 0 to HotkeyDynData.GetLength-1 do begin
    SaveRegistryInteger(HotkeyDynData.GetValue(i, 'Hotkey'), DEFAULT_ROOT_KEY, DEFAULT_KEY, HotkeyDynData.GetValue(i, 'Name'));
  end;

  for i := 0 to SettingDynData.GetLength-1 do begin
    SaveRegistryBoolean(SettingDynData.GetValue(i, 'Value'), DEFAULT_ROOT_KEY, DEFAULT_KEY, SettingDynData.GetValue(i, 'Name'));
  end;

  Timer1.Enabled := False;
  MSI.Destroy;
  TrayIcon1.Destroy;
end;


procedure TForm1.FormClick(Sender: TObject);
begin
  RemoveFocus(Form1);
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


procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if (MSI.GetGPUTemp >= 95) then Inc(Counter) else Counter := 0;
  if (Counter >= 3) then MSI.SetCoolerBoostEnabled(True);
end;


procedure TForm1.PopupMenu1Popup(Sender: TObject);
begin
  PopupMenu1.Items[1].Enabled := MSIShadowPlay.ShadowPlay.IsLoaded;
end;


procedure TForm1.ToggleCoolerBoost1Click(Sender: TObject);
begin
  MSI.ToggleCoolerBoost;
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
begin
  mOldHotKey := HotKey1.HotKey;
  mNewHotKey := HotKey1.HotKey;
  DisableHotKey(ShortCutToHotKey(mOldHotKey));
end;


procedure TForm1.HotKey1Exit(Sender: TObject);
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
  if (Key > -1) then ChangeShortCut(Key, mNewHotKey) else SetShortCut(HotkeyCallback, mNewHotKey, Name);
end;


procedure TForm1.ComboBox1Change(Sender: TObject);
var
  i: Integer;
begin
  RemoveFocus(Form1);
  i := HotkeyDynData.FindIndex(0, 'Description', ComboBox1.Text);
  if (i > -1) then HotKey1.HotKey := HotkeyDynData.GetValue(i, 'Hotkey');
end;


procedure TForm1.ComboBox2Change(Sender: TObject);
begin
  RemoveFocus(Form1);

  case ComboBox2.ItemIndex of
    0: begin
      TrackBar1.Enabled := False;
      MSI.SetFanMode(modeAuto);
    end;
    1: begin
      TrackBar1.Enabled := True;
      TrackBar1.Position := MSI.GetBasicValue;
      MSI.SetBasicMode(TrackBar1.Position);
    end;
    2: begin
      ComboBox2.ItemIndex := 0;
      TrackBar1.Enabled := False;
      MSI.SetFanMode(modeAuto);
    end;
  end;

  SaveRegistryInteger(ComboBox2.ItemIndex, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'FAN_MODE');
end;


procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  Label3.Caption := IntToStr(Round(((TrackBar1.Position - TrackBar1.Min) * 100) / (TrackBar1.Max - TrackBar1.Min))) + '%';
end;


procedure TForm1.TrackBar1MouseUp(Sender: TObject);
begin
  MSI.SetBasicMode(TrackBar1.Position);
end;


procedure TForm1.ComboBox3Change(Sender: TObject);
var
  i: Integer;
  Name: WideString;
begin
  RemoveFocus(Form1);

  i := SettingDynData.FindIndex(0, 'Description', ComboBox3.Text);
  if (i < 0) then Exit;
  Name := SettingDynData.GetValue(i, 'Name');

  if Name = 'SETTING_HOTKEY_SOUND' then CheckBox1.Checked := SettingDynData.GetValue(i, 'Value');
  if Name = 'SETTING_CLEAR_CRASH_DUMPS' then CheckBox1.Checked := SettingDynData.GetValue(i, 'Value');
  if Name = 'SETTING_COOLER_BOOST' then CheckBox1.Checked := MSI.isCoolerBoostEnabled;
  if Name = 'SETTING_WEBCAM' then CheckBox1.Checked := MSI.isWebcamEnabled;
  if Name = 'SETTING_OVERHEATING' then CheckBox1.Checked := SettingDynData.GetValue(i, 'Value');
  if Name = 'SETTING_AUTO_DISABLE_WEBCAM' then CheckBox1.Checked := SettingDynData.GetValue(i, 'Value');
end;


procedure TForm1.CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  Name: WideString;
begin
  i := SettingDynData.FindIndex(0, 'Description', ComboBox3.Text);
  if (i < 0) then Exit;
  Name := SettingDynData.GetValue(i, 'Name');

  if Name = 'SETTING_HOTKEY_SOUND' then SettingDynData.SetValue(i, 'Value', CheckBox1.Checked);
  if Name = 'SETTING_CLEAR_CRASH_DUMPS' then SettingDynData.SetValue(i, 'Value', CheckBox1.Checked);
  if Name = 'SETTING_COOLER_BOOST' then MSI.SetCoolerBoostEnabled(CheckBox1.Checked);
  if Name = 'SETTING_WEBCAM' then MSI.SetWebcamEnabled(CheckBox1.Checked);

  if Name = 'SETTING_AUTO_DISABLE_WEBCAM' then begin
    SettingDynData.SetValue(i, 'Value', CheckBox1.Checked);
    if CheckBox1.Checked then MSI.SetWebcamEnabled(False);
  end;

  if Name = 'SETTING_OVERHEATING' then begin
    SettingDynData.SetValue(i, 'Value', CheckBox1.Checked);
    Timer1.Enabled := CheckBox1.Checked;
  end;
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
  Application.OnDeactivate := nil;
  Form2.ShowModal;
  Application.OnDeactivate := FormDeactivate;
end;


procedure TForm1.Button3Click(Sender: TObject);
begin
  Application.OnDeactivate := nil;
  Form3.ShowModal;
  Application.OnDeactivate := FormDeactivate;
end;


procedure TForm1.Button4Click(Sender: TObject);
begin
  Application.OnDeactivate := nil;
  Form4.ShowModal;
  Application.OnDeactivate := FormDeactivate;
end;


procedure TForm1.Button5Click(Sender: TObject);
begin
  Application.OnDeactivate := nil;
  Form5.ShowModal;
  Application.OnDeactivate := FormDeactivate;
end;


procedure TForm1.Button6Click(Sender: TObject);
begin
  Application.OnDeactivate := nil;
  Form6.ShowModal;
  MSIControl.RemoveFocus(Form1);
  Application.OnDeactivate := FormDeactivate;
end;


procedure TForm1.Button7Click(Sender: TObject);
begin
  Application.OnDeactivate := nil;
  Form8.ShowModal;
  Application.OnDeactivate := FormDeactivate;
end;


procedure TForm1.Button1Click(Sender: TObject);
var
  i: Integer;
begin
  Theme := not Theme;

  for i := 0 to Application.ComponentCount-1 do begin
    try
      if not (Application.Components[i] is TForm) then Continue;
      ChangeTheme(Theme, TForm(Application.Components[i]));
    except end;
  end;
end;


procedure TForm1.HotKey1Change(Sender: TObject);
begin
  mNewHotKey := HotKey1.HotKey;
end;

end.
