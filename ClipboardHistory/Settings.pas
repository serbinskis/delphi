unit Settings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, TFlatCheckBoxUnit, TFlatEditUnit,
  TFlatSpinEditUnit, TFlatComboBoxUnit, TFlatPanelUnit, uKBDynamic, WinXP,
  TNTDialogs, TNTClasses, TNTSysUtils, Functions;

type
  TForm2 = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    FlatCheckBox0: TFlatCheckBox;
    FlatCheckBox1: TFlatCheckBox;
    FlatCheckBox2: TFlatCheckBox;
    FlatCheckBox3: TFlatCheckBox;
    FlatComboBox1: TFlatComboBox;
    FlatComboBox2: TFlatComboBox;
    SpinEdit1: TFlatSpinEditInteger;
    SpinEdit2: TFlatSpinEditInteger;
    SpinEdit3: TFlatSpinEditInteger;
    Export1: TFlatPanel;
    Import1: TFlatPanel;
    Clear1: TFlatPanel;
    Bevel4: TBevel;
    FlatCheckBox4: TFlatCheckBox;
    SpinEdit4: TFlatSpinEditInteger;
    FlatComboBox3: TFlatComboBox;
    StaticText5: TStaticText;
    StaticText2: TStaticText;
    StaticText1: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FlatComboBox1Change(Sender: TObject);
    procedure FlatComboBox2Change(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure SpinEdit3Change(Sender: TObject);
    procedure Import1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Export1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Clear1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Export1Click(Sender: TObject);
    procedure Import1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure SpinEdit1Exit(Sender: TObject);
    procedure SpinEdit2Exit(Sender: TObject);
    procedure SpinEdit3Exit(Sender: TObject);
    procedure SpinEdit4Exit(Sender: TObject);
    procedure SpinEdit4Change(Sender: TObject);
    procedure FlatComboBox3Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  MAXIMUM_SIZE = 1024*1024*500;

var
  Form2: TForm2;

implementation

uses ClipboardHistory;

{$R *.dfm}

//SimulatePress
procedure SimulatePress(Button: TFlatPanel);
begin
  Button.Color := RGB(240, 240, 240);
  Wait(100);
  Button.Color := RGB(255, 255, 255);
end;
//SimulatePress


//CountMemory
function CountMemory(var A: TClipboardList): Int64;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Length(A)-1 do begin
    Result := Result + Length(A[i].Content) * SizeOf(WideChar);
    Result := Result + SizeOf(A[i].DateTime);
    Result := Result + SizeOf(A[i].UID);
  end;
end;
//CountMemory


procedure TForm2.FormShow(Sender: TObject);
begin
  Form1.DisableClipboard;
  ShowWindow(Application.Handle, SW_HIDE);
  StaticText1.SetFocus;

  Form1.Timer3.Enabled := False;

  FlatCheckBox0.Checked := SettingsDB.Monitoring;
  FlatCheckBox1.Checked := SettingsDB.isTimeLimited;
  FlatCheckBox2.Checked := SettingsDB.isSizeLimited;
  FlatCheckBox3.Checked := SettingsDB.isItemsLimited;
  FlatCheckBox4.Checked := SettingsDB.isAutoSave;

  FlatComboBox1.ItemIndex := SettingsDB.TimeIndex;
  FlatComboBox2.ItemIndex := SettingsDB.SizeIndex;
  FlatComboBox3.ItemIndex := SettingsDB.AutoSaveIndex;

  case SettingsDB.TimeIndex of
    0: SpinEdit1.Value := Round(SettingsDB.RemoveAfter/60);
    1: SpinEdit1.Value := Round(SettingsDB.RemoveAfter/60/60);
    2: SpinEdit1.Value := Round(SettingsDB.RemoveAfter/60/60/24);
    3: SpinEdit1.Value := Round(SettingsDB.RemoveAfter/60/60/24/7);
    4: SpinEdit1.Value := Round(SettingsDB.RemoveAfter/60/60/24/30);
  end;

  case SettingsDB.SizeIndex of
    0: SpinEdit2.Value := SettingsDB.MaxSize;
    1: SpinEdit2.Value := Round(SettingsDB.MaxSize/1024);
    2: SpinEdit2.Value := Round(SettingsDB.MaxSize/1024/1024);
  end;

  case SettingsDB.AutoSaveIndex of
    0: SpinEdit4.Value := Round(SettingsDB.SaveAfter/60);
    1: SpinEdit4.Value := Round(SettingsDB.SaveAfter/60/60);
  end;

  SpinEdit3.Value := SettingsDB.MaxItems;
  StaticText5.Caption := 'Size: ' + FormatSize(CountMemory(SettingsDB.ClipboardTable), 2);
end;


procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SettingsDB.Monitoring := FlatCheckBox0.Checked;
  SettingsDB.isTimeLimited := FlatCheckBox1.Checked;
  SettingsDB.isSizeLimited := FlatCheckBox2.Checked;
  SettingsDB.isItemsLimited := FlatCheckBox3.Checked;
  SettingsDB.isAutoSave := FlatCheckBox4.Checked;

  SettingsDB.TimeIndex := FlatComboBox1.ItemIndex;
  SettingsDB.SizeIndex := FlatComboBox2.ItemIndex;
  SettingsDB.AutoSaveIndex := FlatComboBox3.ItemIndex;

  SpinEdit1Exit(nil);
  SpinEdit2Exit(nil);
  SpinEdit3Exit(nil);

  case FlatComboBox1.ItemIndex of
    0: SettingsDB.RemoveAfter := SpinEdit1.Value*60;
    1: SettingsDB.RemoveAfter := SpinEdit1.Value*60*60;
    2: SettingsDB.RemoveAfter := SpinEdit1.Value*60*60*24;
    3: SettingsDB.RemoveAfter := SpinEdit1.Value*60*60*24*7;
    4: SettingsDB.RemoveAfter := SpinEdit1.Value*60*60*24*30;
  end;

  case FlatComboBox2.ItemIndex of
    0: SettingsDB.MaxSize := SpinEdit2.Value;
    1: SettingsDB.MaxSize := SpinEdit2.Value*1024;
    2: SettingsDB.MaxSize := SpinEdit2.Value*1024*1024;
  end;

  case FlatComboBox3.ItemIndex of
    0: SettingsDB.SaveAfter := SpinEdit2.Value*60;
    1: SettingsDB.SaveAfter := SpinEdit2.Value*60*60;
  end;

  Form1.Timer3.Interval := SettingsDB.SaveAfter*1000;
  Form1.Timer3.Enabled := True;

  SettingsDB.MaxItems := SpinEdit3.Value;
  Form1.EnableClipboard;
end;


procedure TForm2.SpinEdit1Change(Sender: TObject);
begin
  case FlatComboBox1.ItemIndex of
    0: CheckValue(SpinEdit1, 1, 9999);
    1: CheckValue(SpinEdit1, 1, 9999);
    2: CheckValue(SpinEdit1, 1, 9999);
    3: CheckValue(SpinEdit1, 1, 100);
    4: CheckValue(SpinEdit1, 1, 100);
  end;
end;

procedure TForm2.SpinEdit2Change(Sender: TObject);
begin
  case FlatComboBox2.ItemIndex of
    0: CheckValue(SpinEdit2, 1, 1024);
    1: CheckValue(SpinEdit2, 1, 1024);
    2: CheckValue(SpinEdit2, 1, 2);
  end;
end;

procedure TForm2.SpinEdit3Change(Sender: TObject);
begin
  CheckValue(SpinEdit3, 1, 10000);
end;


procedure TForm2.SpinEdit4Change(Sender: TObject);
begin
  case FlatComboBox3.ItemIndex of
    0: CheckValue(SpinEdit4, 1, 60);
    1: CheckValue(SpinEdit4, 1, 24);
  end;
end;


procedure TForm2.FlatComboBox1Change(Sender: TObject);
begin
  StaticText1.SetFocus;
  SpinEdit1Change(nil);
end;


procedure TForm2.FlatComboBox2Change(Sender: TObject);
begin
  StaticText1.SetFocus;
  SpinEdit2Change(nil);
end;


procedure TForm2.FlatComboBox3Change(Sender: TObject);
begin
  StaticText1.SetFocus;
  SpinEdit4Change(nil);
end;


procedure TForm2.Export1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  StaticText1.SetFocus;
  SimulatePress(Export1);
end;


procedure TForm2.Import1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SimulatePress(Import1);
end;


procedure TForm2.Clear1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SimulatePress(Clear1);
end;


procedure TForm2.Export1Click(Sender: TObject);
var
  TNTSaveDialog: TTNTSaveDialog;
  MemoryStream: TTNTMemoryStream;
  lOptions: TKBDynamicOptions;
begin
  if Length(SettingsDB.ClipboardTable) <= 0 then begin
    ShowMessage('Cannot export empty list.');
    Exit;
  end;

  TNTSaveDialog := TTNTSaveDialog.Create(nil);
  TNTSaveDialog.Filter := 'CLIPBOARD Files|*.clipboard';
  TNTSaveDialog.Options := [ofHideReadOnly, ofEnableSizing];
  TNTSaveDialog.Title := 'Clipboard History: Export Clipboard History';

  if TNTSaveDialog.Execute then begin
    if Pos('.', TNTSaveDialog.FileName) <= 0 then TNTSaveDialog.FileName := WideChangeFileExt(TNTSaveDialog.FileName, '.clipboard');

    lOptions := [
      kdoAnsiStringCodePage

      {$IFDEF KBDYNAMIC_DEFAULT_UTF8}
      ,kdoUTF16ToUTF8
      {$ENDIF}

      {$IFDEF KBDYNAMIC_DEFAULT_CPUARCH}
      ,kdoCPUArchCompatibility
      {$ENDIF}
    ];

    MemoryStream := TTNTMemoryStream.Create;
    TKBDynamic.WriteTo(MemoryStream, SettingsDB.ClipboardTable, TypeInfo(TClipboardList), 1, lOptions);

    if MemoryStream.Size > MAXIMUM_SIZE then begin
      MemoryStream.Free;
      ShowMessage('Cannot export file bigger than ' + FormatSize(MAXIMUM_SIZE, 0) + '.');
      Exit;
    end;

    CompressStream(MemoryStream);
    MemoryStream.SaveToFile(TNTSaveDialog.FileName);
    MemoryStream.Free;

    ShowMessage('Exported clipboard history.');
  end;
end;


procedure TForm2.Import1Click(Sender: TObject);
var
  ClipboardTable: TClipboardList;
  TNTOpenDialog: TTNTOpenDialog;
  MemoryStream: TTNTMemoryStream;
  srSearch: TWIN32FindDataW;
  FileSize: Int64;
  i: Integer;
  DateTime: TDateTime;
  buttonSelected: Integer;
begin
  TNTOpenDialog := TTNTOpenDialog.Create(nil);
  TNTOpenDialog.Filter := 'CLIPBOARD Files|*.clipboard';
  TNTOpenDialog.Options := [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing];
  TNTOpenDialog.Title := 'Clipboard History: Import Clipboard History';

  if TNTOpenDialog.Execute then begin
    FindFirstFileW(PWideChar(TNTOpenDialog.FileName), srSearch);
    FileSize := (srSearch.nFileSizeHigh * 4294967296) + srSearch.nFileSizeLow;

    if FileSize > MAXIMUM_SIZE then begin
      ShowMessage('Cannot import file bigger than ' + FormatSize(MAXIMUM_SIZE, 0) + '.');
      Exit;
    end;

    MemoryStream := TTNTMemoryStream.Create;
    MemoryStream.LoadFromFile(TNTOpenDialog.FileName);
    DecompressStream(MemoryStream);

    TKBDynamic.ReadFrom(MemoryStream, ClipboardTable, TypeInfo(TClipboardList), 1);
    MemoryStream.Free;

    if Length(ClipboardTable) <= 0 then begin
      ShowMessage('There was an error importing list.');
      Exit;
    end;

    SetLength(SettingsDB.ClipboardTable, 0);
    SettingsDB.ClipboardTable := ClipboardTable;
    if Length(SettingsDB.ClipboardTable) > SettingsDB.MaxItems then SetLength(SettingsDB.ClipboardTable, SettingsDB.MaxItems);
    buttonSelected := MessageDlg('Do you want to reset date?', mtConfirmation, [mbYes, mbNo], 0);

    if buttonSelected = mrYes then begin
      DateTime := Now;

      for i := 0 to Length(SettingsDB.ClipboardTable)-1 do begin
        SettingsDB.ClipboardTable[i].DateTime := DateTime;
      end;
    end;

    StaticText5.Caption := 'Size: ' + FormatSize(CountMemory(SettingsDB.ClipboardTable), 2);
    ShowMessage('Imported clipboard history.');
  end;
end;


procedure TForm2.Clear1Click(Sender: TObject);
var
  buttonSelected: Integer;
begin
  buttonSelected := MessageDlg('Are you sure you want to clear the list?', mtConfirmation, [mbYes, mbNo], 0);
  if buttonSelected <> mrYes then Exit;
  ZeroMemory(@SettingsDB.ClipboardTable, SizeOf(SettingsDB.ClipboardTable));
  SetLength(SettingsDB.ClipboardTable, 0);
  StaticText5.Caption := 'Size: ' + FormatSize(CountMemory(SettingsDB.ClipboardTable), 2);
end;


procedure TForm2.SpinEdit1Exit(Sender: TObject);
begin
  if SpinEdit1.Text = '' then SpinEdit1.Text := '1';
end;


procedure TForm2.SpinEdit2Exit(Sender: TObject);
begin
  if SpinEdit2.Text = '' then SpinEdit2.Text := '1';
end;


procedure TForm2.SpinEdit3Exit(Sender: TObject);
begin
  if SpinEdit3.Text = '' then SpinEdit3.Text := '1';
end;


procedure TForm2.SpinEdit4Exit(Sender: TObject);
begin
  if SpinEdit4.Text = '' then SpinEdit4.Text := '1';
end;

end.
