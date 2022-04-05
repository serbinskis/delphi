unit Duplicates;

interface

uses
  Windows, Classes, Controls, Forms, ComCtrls, StdCtrls, ExtCtrls, SysUtils, DateUtils,
  TFlatProgressBarUnit, TFlatPanelUnit, TFlatCheckBoxUnit, Functions;

type
  TForm4 = class(TForm)
    StaticText1: TStaticText;
    ProgressBar1: TFlatProgressBar;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    FlatPanel2: TFlatPanel;
    FlatPanel1: TFlatPanel;
    CheckBox1: TFlatCheckBox;
    procedure FormShow(Sender: TObject);
    procedure FlatPanel2Click(Sender: TObject);
    procedure FlatPanel1Click(Sender: TObject);
    procedure PanelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;
  StartCount: Integer = -1;
  CompareState: Integer; //-1 - force stop, 0 - stoped, 1 - working, 2 - paused
  SavedDate: TDateTime;

implementation

uses ClipboardHistory, Settings;

{$R *.dfm}

procedure CompareCallback(v1, v2: Variant; idx1, idx2: Integer; var d1, d2: Boolean; Progress: Extended; Changed: Boolean; var Cancelled: Boolean);
var
  exclFavorite: Boolean;
  isSame, f1, f2: Boolean;
begin
  Cancelled := (CompareState = -1);
  if Cancelled then Exit;
  while CompareState = 2 do Wait(100);

  exclFavorite := Form4.CheckBox1.Checked;
  isSame := (v1 = v2);

  if exclFavorite and isSame then begin
    f2 := DynamicData.GetValue(idx2, 'Favorite');
    if (idx1 > -1) then f1 := DynamicData.GetValue(idx1, 'Favorite') else f1 := False;
    if (idx1 > -1) and (not f1) and (f2) then d1 := True; //if 2nd favorite and 1st not, delete original
    if (not d1) and (not f2) then d2 := True; //if not delete original & 2nd not favorite, delete second
    //if both favorite do nothing
  end else if isSame then d2 := True;

  if Changed and (MilliSecondsBetween(Now, SavedDate) >= 50) then begin
    SavedDate := Now;
    Form4.StaticText1.Caption := FloatToStrf(Progress, ffFixed, 8, 2) + '%';
    Form4.ProgressBar1.Position := Round(Progress);
    Form4.StaticText2.Caption := 'Total Items: ' + IntToStr(DynamicData.GetLength);
    Form4.StaticText3.Caption := 'Deleted Items: ' + IntToStr(StartCount-DynamicData.GetLength);
    Application.ProcessMessages;
  end;
end;


procedure TForm4.FormShow(Sender: TObject);
begin
  Form4.Top := Form2.Top + Round((Form2.Height - Form4.Height)/2);
  Form4.Left := Form2.Left + Round((Form2.Width - Form4.Width)/2);

  StaticText2.Caption := 'Total Items:';
  StaticText3.Caption := 'Deleted Items:';

  ProgressBar1.Position := 0;
  StaticText1.Caption := '0%';
  StaticText1.Top := ProgressBar1.Top+2;
  StaticText1.Left := ProgressBar1.Left;
  StaticText1.Width := ProgressBar1.ClientWidth;
  StaticText1.Height := ProgressBar1.ClientHeight;
end;


procedure TForm4.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  PanelMouseDown(FlatPanel1, mbLeft, [], 0, 0);
  FlatPanel1Click(FlatPanel1);
end;


procedure TForm4.FlatPanel2Click(Sender: TObject);
begin
  if CompareState = 1 then begin
    CompareState := 2;
    FlatPanel2.Caption := 'Resume';
    Exit;
  end;

  if CompareState = 2 then begin
    CompareState := 1;
    FlatPanel2.Caption := 'Pause';
    Exit;
  end;

  Form1.DisableClipboard;
  CheckBox1.Enabled := False;
  CompareState := 1;
  FlatPanel2.Caption := 'Pause';

  StartCount := DynamicData.GetLength;
  DynamicData.Compare('Content', CompareCallback);
  if (CompareState <> -1) then ProgressBar1.Position := 100;
  if (CompareState <> -1) then StaticText1.Caption := '100%';

  PanelMouseDown(FlatPanel1, mbLeft, [], 0, 0);
  FlatPanel1Click(FlatPanel1);
end;


procedure TForm4.FlatPanel1Click(Sender: TObject);
begin
  CompareState := -1;
  CheckBox1.Enabled := True;
  FlatPanel2.Caption := 'Start';

  if (StartCount > -1) then begin
    Form2.StaticText5.Caption := 'Size: ' + FormatSize(DynamicData.GetSize, 2);
    Form4.StaticText2.Caption := 'Total Items: ' + IntToStr(DynamicData.GetLength);
    Form4.StaticText3.Caption := 'Deleted Items: ' + IntToStr(StartCount-DynamicData.GetLength);
  end;

  Form1.EnableClipboard;
end;


procedure TForm4.PanelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SimulatePress(TFlatPanel(Sender));
end;

end.
