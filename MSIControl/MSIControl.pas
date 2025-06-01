unit MSIControl;

interface

uses
  Windows, Messages, SysUtils, Dialogs, Classes, Forms, Menus, MMSystem, Graphics, ShellAPI,
  ComCtrls, Controls, StdCtrls, ExtCtrls, StrUtils, TFlatComboBoxUnit, TFlatCheckBoxUnit,
  XiTrackBar, XiButton, CustoHotKey, CustoBevel, CustoTrayIcon, TNTSystem, TNTMenus, WinXP,
  MSIThemes, uHotKey, uNotify, uReadConsole, uDynamicData, MSIController, Functions,
  Buttons, TntButtons, TntStdCtrls;

type
  TForm1 = class(TForm)
    Bevel1: TCustoBevel;
    Bevel2: TCustoBevel;
    Bevel3: TCustoBevel;
    Button1: TXiButton;
    Button2: TXiButton;
    Button3: TXiButton;
    Button5: TXiButton;
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
    PopupMenu1: TTntPopupMenu;
    Restart1: TMenuItem;
    Toggle1: TMenuItem;
    ToggleAutoruns1: TMenuItem;
    ToggleCoolerBoost1: TMenuItem;
    TrackBar1: TXiTrackBar;
    TrayIcon1: TTrayIcon;
    Label5: TTntLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
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
    procedure Restart1Click(Sender: TObject);
    procedure ToggleAutoruns1Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar1MouseUp(Sender: TObject);
    procedure TrayIcon1Action(Sender: TObject; Code: Integer);
    procedure Label5Click(Sender: TObject);
    procedure Label5MouseEnter(Sender: TObject);
    procedure Label5MouseLeave(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  DEFAULT_ROOT_KEY = HKEY_CURRENT_USER;
  DEFAULT_KEY = '\Software\Serbinskis\MSIControl';
  INACTIVE_TIMEOUT = 350;
  STARTUP_SECONDS = 300;

var
  Form1: TForm1;
  HotkeyDynData: TDynamicData;
  SettingDynData: TDynamicData;
  ShutdownCallbacks: TList;
  TrayIconCallbacks: TList;
  MSI: TMSIController;
  AppInactive: Boolean = False;
  mOldHotKey: Integer;
  mNewHotKey: Integer;

procedure HotkeyCallback(Key, ShortCut: Integer; CustomValue: Variant);
procedure RemoveFocus(Form: TForm);

implementation

uses
  MSIMicrophones, MSIShadowPlay, MSIAdvanced, MSIConnections, MSIWakeOnLan,
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
  if (i > -1) and SettingDynData.GetValue(i, 'Value') then PlaySound('HOTKEY', 0, SND_ASYNC or SND_RESOURCE); // TSoundThread.Play('HOTKEY', SND_RESOURCE);
  Sleep(10); // Small pause to allow the thread to start playing the sound; otherwise, it might be skipped (still bugged)

  if (CustomValue = 'HOTKEY_CHANGE_SCENARIO_ECO') then begin
    Form1.ComboBox2.ItemIndex := 0;
    Form1.ComboBox2Change(nil);
  end;

  if (CustomValue = 'HOTKEY_CHANGE_SCENARIO_BALANCED') then begin
    Form1.ComboBox2.ItemIndex := 1;
    Form1.ComboBox2Change(nil);
  end;

  if (CustomValue = 'HOTKEY_CHANGE_SCENARIO_AUTO') then begin
    Form1.ComboBox2.ItemIndex := 2;
    Form1.ComboBox2Change(nil);
  end;

  if (CustomValue = 'HOTKEY_CHANGE_SCENARIO_COOLERBOOST') then begin
    Form1.ComboBox2.ItemIndex := 3;
    Form1.ComboBox2Change(nil);
  end;

  if (CustomValue = 'HOTKEY_CHANGE_SCENARIO_ADVANCED') then begin
    Form1.ComboBox2.ItemIndex := 4;
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
  i: Integer;
  Point: TPoint;
begin
  case Code of
    WM_RBUTTONUP: begin
      if Form1.Visible then Exit;
      for i := 0 to TrayIconCallbacks.Count-1 do TProcedure(TrayIconCallbacks.Items[i]);
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
  TrayIconCallbacks := TList.Create;

  if not MSI.isECLoaded(False) then begin
    ShowMessage('There was an error initializing driver.');
    TerminateProcess(GetCurrentProcess, 0);
  end;

  HotkeyDynData := TDynamicData.Create(['Hotkey', 'Name', 'Description']);
  HotkeyDynData.CreateData(-1, -1, ['Hotkey', 'Name', 'Description'], [0, 'HOTKEY_CHANGE_SCENARIO_ECO', 'Change Scenario To ECO-silent']);
  HotkeyDynData.CreateData(-1, -1, ['Hotkey', 'Name', 'Description'], [0, 'HOTKEY_CHANGE_SCENARIO_BALANCED', 'Change Scenario To Balanced']);
  HotkeyDynData.CreateData(-1, -1, ['Hotkey', 'Name', 'Description'], [0, 'HOTKEY_CHANGE_SCENARIO_AUTO', 'Change Scenario To Auto']);
  HotkeyDynData.CreateData(-1, -1, ['Hotkey', 'Name', 'Description'], [0, 'HOTKEY_CHANGE_SCENARIO_COOLERBOOST', 'Change Scenario To Cooler Boost']);
  HotkeyDynData.CreateData(-1, -1, ['Hotkey', 'Name', 'Description'], [0, 'HOTKEY_CHANGE_SCENARIO_ADVANCED', 'Change Scenario To Advanced']);

  SettingDynData := TDynamicData.Create(['Value', 'Name', 'Description']);
  SettingDynData.CreateData(-1, -1, ['Value', 'EC', 'Name', 'Description'], [True, False, 'SETTING_HOTKEY_SOUND', 'Enable Hotkey Sounds']);
  SettingDynData.CreateData(-1, -1, ['Value', 'EC', 'Name', 'Description'], [False, False, 'SETTING_CLEAR_CRASH_DUMPS', 'Clear Crash Dumps On Start']);

  for i := 0 to HotkeyDynData.GetLength-1 do begin
    ComboBox1.Items.Add(HotkeyDynData.GetValue(i, 'Description'));
    Name := HotkeyDynData.GetValue(i, 'Name');
    if LoadRegistryInteger(v, DEFAULT_ROOT_KEY, DEFAULT_KEY, Name) then begin
      HotkeyDynData.SetValue(i, 'Hotkey', v);
      SetShortCut(HotkeyCallback, v, Name);
    end;
  end;

  for i := 0 to SettingDynData.GetLength-1 do begin
    Name := SettingDynData.GetValue(i, 'Name');
    if LoadRegistryInteger(v, DEFAULT_ROOT_KEY, DEFAULT_KEY, Name) then SettingDynData.SetValue(i, 'Value', v);
    if (not MSI.isECLoaded(True)) and SettingDynData.GetValue(i, 'EC') then continue;
    ComboBox3.Items.Add(SettingDynData.GetValue(i, 'Description'));
  end;

  v := SettingDynData.FindValue(0, 'Name', 'SETTING_CLEAR_CRASH_DUMPS', 'Value');
  if (v > 0) then DeleteDirectory(GetEnvironmentVariable('LocalAppData') + '\CrashDumps');

  if LoadRegistryInteger(v, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'SCENARIO_MODE') then begin
    ComboBox2.ItemIndex := v;
    ComboBox2Change(nil);
  end;

  ComboBox1.ItemIndex := 0;
  ComboBox1Change(nil);
  ComboBox3.ItemIndex := 0;
  ComboBox3Change(nil);

  PopupMenu1.Items.Find('Toggle').Items[1].Visible := False;
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

  case MSI.GetScenario of
    scenarioSilent: begin ComboBox2.ItemIndex := 0; TrackBar1.Enabled := False; end;
    scenarioBalanced: begin ComboBox2.ItemIndex := 1; TrackBar1.Enabled := False; end;
    scenarioAuto: begin ComboBox2.ItemIndex := 2; TrackBar1.Enabled := False; end;
    scenarioCoolerBoost: begin ComboBox2.ItemIndex := 3; TrackBar1.Enabled := False; end;
    scenarioAdvanced: begin ComboBox2.ItemIndex := 4; TrackBar1.Enabled := True; end;
  end;

  TrackBar1.Position := GetAvarageFanSpeed;
  //if ComboBox2.Enabled and (ComboBox2.ItemIndex <> 2) then ComboBox2Change(nil);

  HotKey1.Enabled := MSI.isECLoaded(True);
  ComboBox1.Enabled := MSI.isECLoaded(True);
  ComboBox2.Enabled := MSI.isECLoaded(True);
  TrackBar1.Enabled := MSI.isECLoaded(True) and TrackBar1.Enabled;
  Label5.Enabled := MSI.isECLoaded(True);
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


procedure TForm1.ToggleAutoruns1Click(Sender: TObject);
var
  S: WideString;
begin
  S := ReadOutput('schtasks.exe /query /tn MSIControl');

  if AnsiContainsText(S, 'ERROR') then begin
    ExecuteProcessAsAdmin('schtasks.exe', '/create /sc onlogon /rl highest /tn MSIControl /tr "\"' + WideParamStr(0) + '\"" /f', SW_HIDE);
    ShowMessage('Application added to autoruns.');
  end else begin
    ExecuteProcessAsAdmin('schtasks.exe', '/delete /tn MSIControl /f', SW_HIDE);
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
var
  CpuFansSpeed: TFanSpeedArray;
  GpuFansSpeed: TFanSpeedArray;
  FansResetValue: Integer;
begin
  RemoveFocus(Form1);

  case ComboBox2.ItemIndex of
    0: begin
      TrackBar1.Enabled := False;
      MSI.SetScenario(scenarioSilent, 0, 0, nil, nil);
    end;
    1: begin
      TrackBar1.Enabled := False;
      MSI.SetScenario(scenarioBalanced, nil, nil);
    end;
    2: begin
      TrackBar1.Enabled := False;
      MSI.SetScenario(scenarioAuto, nil, nil);
    end;
    3: begin
      TrackBar1.Enabled := False;
      TrackBar1.Position := 150;
      FillChar(CpuFansSpeed, SizeOf(CpuFansSpeed), 150);
      MSI.SetScenario(scenarioCoolerBoost, 150, 150, @CpuFansSpeed, @CpuFansSpeed);
    end;
    4: begin
      TrackBar1.Enabled := True;
      TrackBar1.Position := GetAvarageFanSpeed;
      FansResetValue := Q((TrackBar1.Position = 0), 0, -1);
      CpuFansSpeed := GetCPUFansSpeed;
      GpuFansSpeed := GetGPUFansSpeed;
      MSI.SetScenario(scenarioAdvanced, FansResetValue, FansResetValue, @CpuFansSpeed, @GpuFansSpeed);
    end;
  end;

  SaveRegistryInteger(ComboBox2.ItemIndex, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'SCENARIO_MODE');
end;


procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  Label3.Caption := IntToStr(TrackBar1.Position) + '%';
end;


procedure TForm1.TrackBar1MouseUp(Sender: TObject);
var
  CpuFansSpeed: TFanSpeedArray;
  GpuFansSpeed: TFanSpeedArray;
  FansResetValue: Integer;
begin
  FansResetValue := Q((TrackBar1.Position = 0), 0, -1);
  SetAllFanSpeed(TrackBar1.Position);
  CpuFansSpeed := GetCPUFansSpeed;
  GpuFansSpeed := GetGPUFansSpeed;
  MSI.SetScenario(scenarioAdvanced, FansResetValue, FansResetValue, @CpuFansSpeed, @GpuFansSpeed);
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


procedure TForm1.Label5Click(Sender: TObject);
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

procedure TForm1.Label5MouseEnter(Sender: TObject);
var
  R, G, B: Byte;
  C: TColor;
begin
  Label5.Tag := 100;
  C := ColorToRGB(Label5.Font.Color);
  R := GetRValue(C);
  G := GetGValue(C);
  B := GetBValue(C);

  if (R > Label5.Tag) then R := R - Label5.Tag else R := 0;
  if (G > Label5.Tag) then G := G - Label5.Tag else G := 0;
  if (B > Label5.Tag) then B := B - Label5.Tag else B := 0;

  Label5.Color := Label5.Font.Color;
  Label5.Font.Color := RGB(R, G, B);
end;

procedure TForm1.Label5MouseLeave(Sender: TObject);
begin
  Label5.Font.Color := Label5.Color;
end;

end.
