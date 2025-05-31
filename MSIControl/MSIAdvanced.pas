unit MSIAdvanced;

interface

uses
  Windows, Classes, Controls, Forms, ExtCtrls, ComCtrls, StdCtrls, MMSystem, CustoBevel, CustoHotKey,
  TFlatComboBoxUnit, TFlatCheckBoxUnit, MSIControl, MSIThemes, uHotKey, uDynamicData, Functions,
  XiTrackBar, TntStdCtrls, SysUtils, jpeg, TntExtCtrls, XiPanel, XiButton, MSIController;

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
    procedure TrackBar1MouseUp(Sender: TObject);
    procedure TrackBar2MouseUp(Sender: TObject);
    procedure TrackBar3MouseUp(Sender: TObject);
    procedure TrackBar4MouseUp(Sender: TObject);
    procedure TrackBar5MouseUp(Sender: TObject);
    procedure TrackBar6MouseUp(Sender: TObject);
    procedure TrackBar7MouseUp(Sender: TObject);
    procedure TrackBar8MouseUp(Sender: TObject);
    procedure TrackBar9MouseUp(Sender: TObject);
    procedure TrackBar10MouseUp(Sender: TObject);
    procedure TrackBar11MouseUp(Sender: TObject);
    procedure TrackBar12MouseUp(Sender: TObject);
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

function GetAvarageFanSpeed: Integer;
procedure SetAllFanSpeed(Speed: Integer);
function GetCPUFansSpeed: TFanSpeedArray;
function GetGPUFansSpeed: TFanSpeedArray;
procedure LoadSettings;

implementation

{$R *.dfm}

function GetAvarageFanSpeed: Integer;
var
  i: Integer;
begin
  Result := 0;
  if (not Assigned(AdvancedDynData)) then LoadSettings;

  for i := 0 to AdvancedDynData.GetLength-1 do begin
    Result := Result + AdvancedDynData.GetValue(i, 'Value');
  end;

  Result := Round(Result/AdvancedDynData.GetLength);
end;


procedure SetAllFanSpeed(Speed: Integer);
var
  i: Integer;
  CloseAction: TCloseAction;
begin
  if (Speed < 0) then Speed := 0;
  if (Speed > 150) then Speed := 150;
  if (not Assigned(AdvancedDynData)) then LoadSettings;

  for i := 0 to AdvancedDynData.GetLength-1 do begin
    AdvancedDynData.SetValue(i, 'Value', Speed);
  end;

  CloseAction := caNone;
  Form4.FormClose(nil, CloseAction);
  Form4.FormCreate(nil);
end;


function GetCPUFansSpeed: TFanSpeedArray;
var
  FansSpeed: TFanSpeedArray;
begin
  if (not Assigned(AdvancedDynData)) then LoadSettings;
  FansSpeed[0] := AdvancedDynData.FindValue(0, 'Name', 'FAN_1_1', 'Value');
  FansSpeed[1] := AdvancedDynData.FindValue(0, 'Name', 'FAN_1_2', 'Value');
  FansSpeed[2] := AdvancedDynData.FindValue(0, 'Name', 'FAN_1_3', 'Value');
  FansSpeed[3] := AdvancedDynData.FindValue(0, 'Name', 'FAN_1_4', 'Value');
  FansSpeed[4] := AdvancedDynData.FindValue(0, 'Name', 'FAN_1_5', 'Value');
  FansSpeed[5] := AdvancedDynData.FindValue(0, 'Name', 'FAN_1_6', 'Value');
  Result := FansSpeed;
end;


function GetGPUFansSpeed: TFanSpeedArray;
var
  FansSpeed: TFanSpeedArray;
begin
  if (not Assigned(AdvancedDynData)) then LoadSettings;
  FansSpeed[0] := AdvancedDynData.FindValue(0, 'Name', 'FAN_2_1', 'Value');
  FansSpeed[1] := AdvancedDynData.FindValue(0, 'Name', 'FAN_2_2', 'Value');
  FansSpeed[2] := AdvancedDynData.FindValue(0, 'Name', 'FAN_2_3', 'Value');
  FansSpeed[3] := AdvancedDynData.FindValue(0, 'Name', 'FAN_2_4', 'Value');
  FansSpeed[4] := AdvancedDynData.FindValue(0, 'Name', 'FAN_2_5', 'Value');
  FansSpeed[5] := AdvancedDynData.FindValue(0, 'Name', 'FAN_2_6', 'Value');
  Result := FansSpeed;
end;


procedure LoadSettings;
var
  Name: WideString;
  i, v: Integer;
begin
  AdvancedDynData := TDynamicData.Create(['Value', 'Name']);
  AdvancedDynData.CreateData(-1, -1, ['Value', 'Name'], [0, 'FAN_1_1']);
  AdvancedDynData.CreateData(-1, -1, ['Value', 'Name'], [40, 'FAN_1_2']);
  AdvancedDynData.CreateData(-1, -1, ['Value', 'Name'], [50, 'FAN_1_3']);
  AdvancedDynData.CreateData(-1, -1, ['Value', 'Name'], [60, 'FAN_1_4']);
  AdvancedDynData.CreateData(-1, -1, ['Value', 'Name'], [80, 'FAN_1_5']);
  AdvancedDynData.CreateData(-1, -1, ['Value', 'Name'], [90, 'FAN_1_6']);

  AdvancedDynData.CreateData(-1, -1, ['Value', 'Name'], [0, 'FAN_2_1']);
  AdvancedDynData.CreateData(-1, -1, ['Value', 'Name'], [50, 'FAN_2_2']);
  AdvancedDynData.CreateData(-1, -1, ['Value', 'Name'], [60, 'FAN_2_3']);
  AdvancedDynData.CreateData(-1, -1, ['Value', 'Name'], [70, 'FAN_2_4']);
  AdvancedDynData.CreateData(-1, -1, ['Value', 'Name'], [85, 'FAN_2_5']);
  AdvancedDynData.CreateData(-1, -1, ['Value', 'Name'], [95, 'FAN_2_6']);

  for i := 0 to AdvancedDynData.GetLength-1 do begin
    Name := AdvancedDynData.GetValue(i, 'Name');
    if not LoadRegistryInteger(v, DEFAULT_ROOT_KEY, DEFAULT_ADVANCED_KEY, Name) then continue;
    AdvancedDynData.SetValue(i, 'Value', v);
  end;
end;


procedure TForm4.FormCreate(Sender: TObject);
begin
  ChangeTheme(Theme, self);
  LoadSettings;
end;


procedure TForm4.FormShow(Sender: TObject);
begin
  MSIControl.RemoveFocus(self);

  TrackBar1.Position := TrackBar1.Max - AdvancedDynData.FindValue(0, 'Name', 'FAN_1_1', 'Value');
  TrackBar2.Position := TrackBar2.Max - AdvancedDynData.FindValue(0, 'Name', 'FAN_1_2', 'Value');
  TrackBar3.Position := TrackBar3.Max - AdvancedDynData.FindValue(0, 'Name', 'FAN_1_3', 'Value');
  TrackBar4.Position := TrackBar4.Max - AdvancedDynData.FindValue(0, 'Name', 'FAN_1_4', 'Value');
  TrackBar5.Position := TrackBar5.Max - AdvancedDynData.FindValue(0, 'Name', 'FAN_1_5', 'Value');
  TrackBar6.Position := TrackBar6.Max - AdvancedDynData.FindValue(0, 'Name', 'FAN_1_6', 'Value');

  TrackBar7.Position := TrackBar7.Max - AdvancedDynData.FindValue(0, 'Name', 'FAN_2_1', 'Value');
  TrackBar8.Position := TrackBar8.Max - AdvancedDynData.FindValue(0, 'Name', 'FAN_2_2', 'Value');
  TrackBar9.Position := TrackBar9.Max - AdvancedDynData.FindValue(0, 'Name', 'FAN_2_3', 'Value');
  TrackBar10.Position := TrackBar10.Max - AdvancedDynData.FindValue(0, 'Name', 'FAN_2_4', 'Value');
  TrackBar11.Position := TrackBar11.Max - AdvancedDynData.FindValue(0, 'Name', 'FAN_2_5', 'Value');
  TrackBar12.Position := TrackBar12.Max - AdvancedDynData.FindValue(0, 'Name', 'FAN_2_6', 'Value');
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
  i: Integer;
begin
  for i := 0 to AdvancedDynData.GetLength-1 do begin
    DeleteRegistryValue(DEFAULT_ROOT_KEY, DEFAULT_ADVANCED_KEY, AdvancedDynData.GetValue(i, 'Name'));
  end;

  Form4.OnCreate(nil);
  Form4.FormShow(nil);
  Form1.TrackBar1.Position := GetAvarageFanSpeed;
  if (Form1.ComboBox2.ItemIndex = 4) then Form1.ComboBox2Change(nil);
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

procedure TForm4.TrackBar1MouseUp(Sender: TObject);
var
  i: Integer;
begin
  i := AdvancedDynData.FindIndex(0, 'Name', 'FAN_1_1');
  AdvancedDynData.SetValue(i, 'Value', (TrackBar1.Max - TrackBar1.Position));
  Form1.TrackBar1.Position := GetAvarageFanSpeed;
  if (Form1.ComboBox2.ItemIndex = 4) then Form1.ComboBox2Change(nil);
end;

procedure TForm4.TrackBar2MouseUp(Sender: TObject);
var
  i: Integer;
begin
  i := AdvancedDynData.FindIndex(0, 'Name', 'FAN_1_2');
  AdvancedDynData.SetValue(i, 'Value', (TrackBar2.Max - TrackBar2.Position));
  Form1.TrackBar1.Position := GetAvarageFanSpeed;
  if (Form1.ComboBox2.ItemIndex = 4) then Form1.ComboBox2Change(nil);
end;

procedure TForm4.TrackBar3MouseUp(Sender: TObject);
var
  i: Integer;
begin
  i := AdvancedDynData.FindIndex(0, 'Name', 'FAN_1_3');
  AdvancedDynData.SetValue(i, 'Value', (TrackBar3.Max - TrackBar3.Position));
  Form1.TrackBar1.Position := GetAvarageFanSpeed;
  if (Form1.ComboBox2.ItemIndex = 4) then Form1.ComboBox2Change(nil);
end;

procedure TForm4.TrackBar4MouseUp(Sender: TObject);
var
  i: Integer;
begin
  i := AdvancedDynData.FindIndex(0, 'Name', 'FAN_1_4');
  AdvancedDynData.SetValue(i, 'Value', (TrackBar4.Max - TrackBar4.Position));
  Form1.TrackBar1.Position := GetAvarageFanSpeed;
  if (Form1.ComboBox2.ItemIndex = 4) then Form1.ComboBox2Change(nil);
end;

procedure TForm4.TrackBar5MouseUp(Sender: TObject);
var
  i: Integer;
begin
  i := AdvancedDynData.FindIndex(0, 'Name', 'FAN_1_5');
  AdvancedDynData.SetValue(i, 'Value', (TrackBar5.Max - TrackBar5.Position));
  Form1.TrackBar1.Position := GetAvarageFanSpeed;
  if (Form1.ComboBox2.ItemIndex = 4) then Form1.ComboBox2Change(nil);
end;

procedure TForm4.TrackBar6MouseUp(Sender: TObject);
var
  i: Integer;
begin
  i := AdvancedDynData.FindIndex(0, 'Name', 'FAN_1_6');
  AdvancedDynData.SetValue(i, 'Value', (TrackBar6.Max - TrackBar6.Position));
  Form1.TrackBar1.Position := GetAvarageFanSpeed;
  if (Form1.ComboBox2.ItemIndex = 4) then Form1.ComboBox2Change(nil);
end;

procedure TForm4.TrackBar7MouseUp(Sender: TObject);
var
  i: Integer;
begin
  i := AdvancedDynData.FindIndex(0, 'Name', 'FAN_2_1');
  AdvancedDynData.SetValue(i, 'Value', (TrackBar7.Max - TrackBar7.Position));
  Form1.TrackBar1.Position := GetAvarageFanSpeed;
  if (Form1.ComboBox2.ItemIndex = 4) then Form1.ComboBox2Change(nil);
end;

procedure TForm4.TrackBar8MouseUp(Sender: TObject);
var
  i: Integer;
begin
  i := AdvancedDynData.FindIndex(0, 'Name', 'FAN_2_2');
  AdvancedDynData.SetValue(i, 'Value', (TrackBar8.Max - TrackBar8.Position));
  Form1.TrackBar1.Position := GetAvarageFanSpeed;
  if (Form1.ComboBox2.ItemIndex = 4) then Form1.ComboBox2Change(nil);
end;

procedure TForm4.TrackBar9MouseUp(Sender: TObject);
var
  i: Integer;
begin
  i := AdvancedDynData.FindIndex(0, 'Name', 'FAN_2_3');
  AdvancedDynData.SetValue(i, 'Value', (TrackBar9.Max - TrackBar9.Position));
  Form1.TrackBar1.Position := GetAvarageFanSpeed;
  if (Form1.ComboBox2.ItemIndex = 4) then Form1.ComboBox2Change(nil);
end;

procedure TForm4.TrackBar10MouseUp(Sender: TObject);
var
  i: Integer;
begin
  i := AdvancedDynData.FindIndex(0, 'Name', 'FAN_2_4');
  AdvancedDynData.SetValue(i, 'Value', (TrackBar10.Max - TrackBar10.Position));
  Form1.TrackBar1.Position := GetAvarageFanSpeed;
  if (Form1.ComboBox2.ItemIndex = 4) then Form1.ComboBox2Change(nil);
end;

procedure TForm4.TrackBar11MouseUp(Sender: TObject);
var
  i: Integer;
begin
  i := AdvancedDynData.FindIndex(0, 'Name', 'FAN_2_5');
  AdvancedDynData.SetValue(i, 'Value', (TrackBar11.Max - TrackBar11.Position));
  Form1.TrackBar1.Position := GetAvarageFanSpeed;
  if (Form1.ComboBox2.ItemIndex = 4) then Form1.ComboBox2Change(nil);
end;

procedure TForm4.TrackBar12MouseUp(Sender: TObject);
var
  i: Integer;
begin
  i := AdvancedDynData.FindIndex(0, 'Name', 'FAN_2_6');
  AdvancedDynData.SetValue(i, 'Value', (TrackBar12.Max - TrackBar12.Position));
  Form1.TrackBar1.Position := GetAvarageFanSpeed;
  if (Form1.ComboBox2.ItemIndex = 4) then Form1.ComboBox2Change(nil);
end;

end.
