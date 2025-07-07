unit MSIAdvanced;

interface

uses
  Windows, Classes, Controls, Forms, ExtCtrls, ComCtrls, StdCtrls, MMSystem, CustoBevel, CustoHotKey,
  TFlatComboBoxUnit, TFlatCheckBoxUnit, MSIControl, MSIThemes, uHotKey, uDynamicData, Functions,
  XiTrackBar, TntStdCtrls, SysUtils, jpeg, TntExtCtrls, XiPanel, XiButton, TypInfo, MSIController;

type
  TForm4 = class(TForm)
    Bevel1: TCustoBevel;
    Label1: TLabel;
    Image1: TImage;
    TrackBar1: TXiTrackBar;
    Label2: TLabel;
    TntLabel1: TTntLabel;
    TntLabel2: TTntLabel;
    TrackBar2: TXiTrackBar;
    TrackBar3: TXiTrackBar;
    TrackBar4: TXiTrackBar;
    TrackBar5: TXiTrackBar;
    TrackBar6: TXiTrackBar;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    XiPanel1: TXiPanel;
    XiPanel2: TXiPanel;
    XiPanel3: TXiPanel;
    XiPanel4: TXiPanel;
    XiPanel5: TXiPanel;
    XiPanel6: TXiPanel;
    XiPanel7: TXiPanel;
    XiPanel8: TXiPanel;
    XiPanel9: TXiPanel;
    XiPanel10: TXiPanel;
    XiPanel11: TXiPanel;
    XiPanel12: TXiPanel;
    XiPanel13: TXiPanel;
    XiPanel14: TXiPanel;
    XiPanel15: TXiPanel;
    XiPanel16: TXiPanel;
    XiPanel17: TXiPanel;
    XiPanel18: TXiPanel;
    XiPanel19: TXiPanel;
    XiPanel20: TXiPanel;
    XiPanel21: TXiPanel;
    XiPanel22: TXiPanel;
    XiPanel23: TXiPanel;
    XiPanel24: TXiPanel;
    XiPanel25: TXiPanel;
    XiPanel26: TXiPanel;
    XiPanel27: TXiPanel;
    XiPanel28: TXiPanel;
    XiPanel29: TXiPanel;
    XiPanel30: TXiPanel;
    XiPanel31: TXiPanel;
    Label8: TLabel;
    Image2: TImage;
    CustoBevel1: TCustoBevel;
    Label9: TLabel;
    TntLabel3: TTntLabel;
    TntLabel4: TTntLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    TrackBar7: TXiTrackBar;
    TrackBar10: TXiTrackBar;
    TrackBar11: TXiTrackBar;
    TrackBar12: TXiTrackBar;
    XiPanel32: TXiPanel;
    XiPanel33: TXiPanel;
    XiPanel34: TXiPanel;
    XiPanel35: TXiPanel;
    TrackBar8: TXiTrackBar;
    TrackBar9: TXiTrackBar;
    XiPanel36: TXiPanel;
    XiPanel37: TXiPanel;
    XiPanel38: TXiPanel;
    XiPanel39: TXiPanel;
    XiPanel40: TXiPanel;
    XiPanel41: TXiPanel;
    XiPanel42: TXiPanel;
    XiPanel43: TXiPanel;
    XiPanel44: TXiPanel;
    XiPanel45: TXiPanel;
    XiPanel46: TXiPanel;
    XiPanel47: TXiPanel;
    XiPanel48: TXiPanel;
    XiPanel49: TXiPanel;
    XiPanel50: TXiPanel;
    XiPanel51: TXiPanel;
    XiPanel52: TXiPanel;
    XiPanel53: TXiPanel;
    XiPanel54: TXiPanel;
    XiPanel55: TXiPanel;
    XiPanel56: TXiPanel;
    XiPanel57: TXiPanel;
    XiPanel58: TXiPanel;
    XiPanel59: TXiPanel;
    XiPanel60: TXiPanel;
    XiPanel61: TXiPanel;
    XiPanel62: TXiPanel;
    Button1: TXiButton;
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
    procedure TrackBar5Change(Sender: TObject);
    procedure TrackBar6Change(Sender: TObject);
    procedure TrackBar7Change(Sender: TObject);
    procedure TrackBar8Change(Sender: TObject);
    procedure TrackBar9Change(Sender: TObject);
    procedure TrackBar10Change(Sender: TObject);
    procedure TrackBar11Change(Sender: TObject);
    procedure TrackBar12Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TrackBarMouseUp(Sender: TObject);
    procedure TrackBarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  DEFAULT_ADVANCED_KEY = DEFAULT_KEY + '\Advanced';

var
  Form4: TForm4;
  AdvancedDynData: TDynamicData;
  PowerLimitDynData: TDynamicData;

function GetAvarageFanSpeed(Scenario: TScenarioType): Integer;
procedure SetAllFanSpeed(Speed: Integer; Scenario: TScenarioType);
function GetCPUFansSpeed(Scenario: TScenarioType): TFanSpeedArray;
function GetGPUFansSpeed(Scenario: TScenarioType): TFanSpeedArray;
procedure LoadSettings;

implementation

{$R *.dfm}

function GetAvarageFanSpeed(Scenario: TScenarioType): Integer;
var
  i: Integer;
  Name: WideString;
begin
  Result := 0;
  if (not Assigned(AdvancedDynData)) then LoadSettings;

  for i := 0 to Length(EC_DEFAULT_CPU_FAN_SPEED)-1 do begin
    Name := Format('FAN_%s_1_%d', [UpperCase(GetEnumName(TypeInfo(TScenarioType), Ord(Scenario))), i + 1]);
    Result := Result + AdvancedDynData.GetValue(AdvancedDynData.FindIndex(0, 'Name', Name), 'Value');
    Name := Format('FAN_%s_2_%d', [UpperCase(GetEnumName(TypeInfo(TScenarioType), Ord(Scenario))), i + 1]);
    Result := Result + AdvancedDynData.GetValue(AdvancedDynData.FindIndex(0, 'Name', Name), 'Value');
  end;

  Result := Round(Result/(Length(EC_DEFAULT_CPU_FAN_SPEED)*2));
end;


procedure SetAllFanSpeed(Speed: Integer; Scenario: TScenarioType);
var
  i: Integer;
  Name: WideString;
  CloseAction: TCloseAction;
begin
  if (Speed < 0) then Speed := 0;
  if (Speed > 150) then Speed := 150;
  if (not Assigned(AdvancedDynData)) then LoadSettings;

  for i := 0 to Length(EC_DEFAULT_CPU_FAN_SPEED)-1 do begin
    Name := Format('FAN_%s_1_%d', [UpperCase(GetEnumName(TypeInfo(TScenarioType), Ord(Scenario))), i + 1]);
    AdvancedDynData.SetValue(AdvancedDynData.FindIndex(0, 'Name', Name), 'Value', Speed);
    Name := Format('FAN_%s_2_%d', [UpperCase(GetEnumName(TypeInfo(TScenarioType), Ord(Scenario))), i + 1]);
    AdvancedDynData.SetValue(AdvancedDynData.FindIndex(0, 'Name', Name), 'Value', Speed);
  end;

  CloseAction := caNone;
  Form4.FormClose(nil, CloseAction);
end;


function GetCPUFansSpeed(Scenario: TScenarioType): TFanSpeedArray;
var
  i: Integer;
  Name: WideString;
  FansSpeed: TFanSpeedArray;
begin
  if (not Assigned(AdvancedDynData)) then LoadSettings;

  for i := 0 to Length(EC_DEFAULT_CPU_FAN_SPEED)-1 do begin
    Name := Format('FAN_%s_1_%d', [UpperCase(GetEnumName(TypeInfo(TScenarioType), Ord(Scenario))), i + 1]);
    FansSpeed[i] := AdvancedDynData.GetValue(AdvancedDynData.FindIndex(0, 'Name', Name), 'Value');
  end;

  Result := FansSpeed;
end;


function GetGPUFansSpeed(Scenario: TScenarioType): TFanSpeedArray;
var
  i: Integer;
  Name: WideString;
  FansSpeed: TFanSpeedArray;
begin
  if (not Assigned(AdvancedDynData)) then LoadSettings;

  for i := 0 to Length(EC_DEFAULT_CPU_FAN_SPEED)-1 do begin
    Name := Format('FAN_%s_2_%d', [UpperCase(GetEnumName(TypeInfo(TScenarioType), Ord(Scenario))), i + 1]);
    FansSpeed[i] := AdvancedDynData.GetValue(AdvancedDynData.FindIndex(0, 'Name', Name), 'Value');
  end;

  Result := FansSpeed;
end;


procedure LoadSettings;
var
  Scenario: TScenarioType;
  Name: WideString;
  i, v: Integer;
begin
  AdvancedDynData := TDynamicData.Create(['Value', 'Name']);

  for Scenario := Succ(Low(TScenarioType)) to High(TScenarioType) do begin
    for i := 0 to Length(EC_DEFAULT_CPU_FAN_SPEED)-1 do begin
      Name := Format('FAN_%s_1_%d', [UpperCase(GetEnumName(TypeInfo(TScenarioType), Ord(Scenario))), i + 1]);
      AdvancedDynData.CreateData(-1, -1, ['Value', 'Name'], [EC_DEFAULT_CPU_FAN_SPEED[i], Name]);
      Name := Format('FAN_%s_2_%d', [UpperCase(GetEnumName(TypeInfo(TScenarioType), Ord(Scenario))), i + 1]);
      AdvancedDynData.CreateData(-1, -1, ['Value', 'Name'], [EC_DEFAULT_GPU_FAN_SPEED[i], Name]);
    end;
  end;

  for Scenario := Succ(Low(TScenarioType)) to High(TScenarioType) do begin
    Name := Format('TDP_1_%s', [UpperCase(GetEnumName(TypeInfo(TScenarioType), Ord(Scenario)))]);
    AdvancedDynData.CreateData(-1, -1, ['Value', 'Name'], [300, Name]);
    Name := Format('TDP_2_%s', [UpperCase(GetEnumName(TypeInfo(TScenarioType), Ord(Scenario)))]);
    AdvancedDynData.CreateData(-1, -1, ['Value', 'Name'], [300, Name]);
  end;

  for i := 0 to AdvancedDynData.GetLength-1 do begin
    Name := AdvancedDynData.GetValue(i, 'Name');
    if not LoadRegistryInteger(v, DEFAULT_ROOT_KEY, DEFAULT_ADVANCED_KEY, Name) then Continue;
    AdvancedDynData.SetValue(i, 'Value', v);
  end;
end;


procedure TForm4.FormCreate(Sender: TObject);
begin
  ChangeTheme(Theme, self);
  LoadSettings;
end;


procedure TForm4.FormShow(Sender: TObject);
var
  Scenario: TScenarioType;
  Name: WideString;
  i: Integer;
begin
  MSIControl.RemoveFocus(self);
  Scenario := TScenarioType(Form1.ComboBox2.ItemIndex+1);

  for i := 0 to Form4.ComponentCount-1 do begin
    if not (Form4.Components[i] is TXiTrackBar) then Continue;
    Name := Format(TXiTrackBar(Form4.Components[i]).Hint, [UpperCase(GetEnumName(TypeInfo(TScenarioType), Ord(Scenario)))]);
    TXiTrackBar(Form4.Components[i]).Position := TXiTrackBar(Form4.Components[i]).Max - AdvancedDynData.FindValue(0, 'Name', Name, 'Value');
  end;
end;


procedure TForm4.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
begin
  for i := 0 to AdvancedDynData.GetLength-1 do begin
    SaveRegistryInteger(AdvancedDynData.GetValue(i, 'Value'), DEFAULT_ROOT_KEY, DEFAULT_ADVANCED_KEY, AdvancedDynData.GetValue(i, 'Name'));
  end;
end;


procedure TForm4.FormClick(Sender: TObject);
begin
  MSIControl.RemoveFocus(self);
end;


procedure TForm4.Button1Click(Sender: TObject);
var
  Scenario: TScenarioType;
  Name: WideString;
  i: Integer;
begin
  Scenario := TScenarioType(Form1.ComboBox2.ItemIndex+1);

  for i := 0 to Length(EC_DEFAULT_CPU_FAN_SPEED)-1 do begin
    Name := Format('FAN_%s_1_%d', [UpperCase(GetEnumName(TypeInfo(TScenarioType), Ord(Scenario))), i + 1]);
    DeleteRegistryValue(DEFAULT_ROOT_KEY, DEFAULT_ADVANCED_KEY, Name);
    Name := Format('FAN_%s_2_%d', [UpperCase(GetEnumName(TypeInfo(TScenarioType), Ord(Scenario))), i + 1]);
    DeleteRegistryValue(DEFAULT_ROOT_KEY, DEFAULT_ADVANCED_KEY, Name);
  end;

  Form4.OnCreate(nil);
  Form4.FormShow(nil);
  Form1.TrackBar1.Position := GetAvarageFanSpeed(TScenarioType(Form1.ComboBox2.ItemIndex+1));
  if (Form1.ComboBox2.ItemIndex = 4) then Form1.ComboBox2Change(nil);
end;


procedure TForm4.TrackBarMouseUp(Sender: TObject);
var
  Scenario: TScenarioType;
  Name: WideString;
  i: Integer;
begin
  Scenario := TScenarioType(Form1.ComboBox2.ItemIndex+1);
  Name := Format(TXiTrackBar(Sender).Hint, [UpperCase(GetEnumName(TypeInfo(TScenarioType), Ord(Scenario)))]);
  i := AdvancedDynData.FindIndex(0, 'Name', Name);
  AdvancedDynData.SetValue(i, 'Value', (TXiTrackBar(Sender).Max - TXiTrackBar(Sender).Position));
  Form1.TrackBar1.Position := GetAvarageFanSpeed(TScenarioType(Form1.ComboBox2.ItemIndex+1));
  Form1.ComboBox2Change(nil);
  TXiTrackBar(Sender).SetFocus;
end;


procedure TForm4.TrackBarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  TrackBarMouseUp(Sender);
end;


procedure TForm4.TrackBar1Change(Sender: TObject);
begin
  Label2.Caption := IntToStr(TrackBar1.Max - TrackBar1.Position) + '%';
end;

procedure TForm4.TrackBar2Change(Sender: TObject);
begin
  Label3.Caption := IntToStr(TrackBar2.Max - TrackBar2.Position) + '%';
end;

procedure TForm4.TrackBar3Change(Sender: TObject);
begin
  Label4.Caption := IntToStr(TrackBar3.Max - TrackBar3.Position) + '%';
end;

procedure TForm4.TrackBar4Change(Sender: TObject);
begin
  Label5.Caption := IntToStr(TrackBar4.Max - TrackBar4.Position) + '%';
end;

procedure TForm4.TrackBar5Change(Sender: TObject);
begin
  Label6.Caption := IntToStr(TrackBar5.Max - TrackBar5.Position) + '%';
end;

procedure TForm4.TrackBar6Change(Sender: TObject);
begin
  Label7.Caption := IntToStr(TrackBar6.Max - TrackBar6.Position) + '%';
end;

procedure TForm4.TrackBar7Change(Sender: TObject);
begin
  Label9.Caption := IntToStr(TrackBar7.Max - TrackBar7.Position) + '%';
end;

procedure TForm4.TrackBar8Change(Sender: TObject);
begin
  Label10.Caption := IntToStr(TrackBar8.Max - TrackBar8.Position) + '%';
end;

procedure TForm4.TrackBar9Change(Sender: TObject);
begin
  Label11.Caption := IntToStr(TrackBar9.Max - TrackBar9.Position) + '%';
end;

procedure TForm4.TrackBar10Change(Sender: TObject);
begin
  Label12.Caption := IntToStr(TrackBar10.Max - TrackBar10.Position) + '%';
end;

procedure TForm4.TrackBar11Change(Sender: TObject);
begin
  Label13.Caption := IntToStr(TrackBar11.Max - TrackBar11.Position) + '%';
end;

procedure TForm4.TrackBar12Change(Sender: TObject);
begin
  Label14.Caption := IntToStr(TrackBar12.Max - TrackBar12.Position) + '%';
end;

end.
