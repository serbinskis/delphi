unit Settings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, TFlatCheckBoxUnit, TFlatEditUnit,
  TFlatSpinEditUnit, TFlatComboBoxUnit, TFlatPanelUnit, TNTDialogs, TNTClasses,
  TNTSysUtils, WinXP, Functions;

type
  TForm2 = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    CheckBox0: TFlatCheckBox;
    CheckBox1: TFlatCheckBox;
    CheckBox2: TFlatCheckBox;
    CheckBox3: TFlatCheckBox;
    ComboBox1: TFlatComboBox;
    ComboBox2: TFlatComboBox;
    SpinEdit1: TFlatSpinEditInteger;
    SpinEdit2: TFlatSpinEditInteger;
    SpinEdit3: TFlatSpinEditInteger;
    Panel1: TFlatPanel;
    Panel2: TFlatPanel;
    Panel3: TFlatPanel;
    Panel4: TFlatPanel;
    Bevel4: TBevel;
    CheckBox4: TFlatCheckBox;
    SpinEdit4: TFlatSpinEditInteger;
    ComboBox3: TFlatComboBox;
    StaticText5: TStaticText;
    StaticText2: TStaticText;
    StaticText1: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    CheckBox5: TFlatCheckBox;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure SpinEdit3Change(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure Panel2Click(Sender: TObject);
    procedure Panel3Click(Sender: TObject);
    procedure Panel4Click(Sender: TObject);
    procedure SpinEdit1Exit(Sender: TObject);
    procedure SpinEdit2Exit(Sender: TObject);
    procedure SpinEdit3Exit(Sender: TObject);
    procedure SpinEdit4Exit(Sender: TObject);
    procedure SpinEdit4Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure PanelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  MAXIMUM_SIZE = 1024*1024*500;
  DO_COMPRESS = True;
  CLIPBOARD_EXTENSION = '.clp';

var
  Form2: TForm2;

procedure SimulatePress(Button: TFlatPanel);

implementation

uses ClipboardHistory, Duplicates;

{$R *.dfm}

//SimulatePress
procedure SimulatePress(Button: TFlatPanel);
begin
  Button.Color := RGB(240, 240, 240);
  Wait(100);
  Button.Color := RGB(255, 255, 255);
end;
//SimulatePress


procedure TForm2.FormShow(Sender: TObject);
begin
  Form1.DisableClipboard;
  ShowWindow(Application.Handle, SW_HIDE);
  StaticText1.SetFocus;

  Form1.Timer3.Enabled := False;

  CheckBox0.Checked := SettingsDB.Monitoring;
  CheckBox5.Checked := SettingsDB.PreventDuplicates;
  CheckBox1.Checked := SettingsDB.isTimeLimited;
  CheckBox2.Checked := SettingsDB.isSizeLimited;
  CheckBox3.Checked := SettingsDB.isItemsLimited;
  CheckBox4.Checked := SettingsDB.isAutoSave;

  ComboBox1.ItemIndex := SettingsDB.TimeIndex;
  ComboBox2.ItemIndex := SettingsDB.SizeIndex;
  ComboBox3.ItemIndex := SettingsDB.AutoSaveIndex;

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
  StaticText5.Caption := 'Size: ' + FormatSize(DynamicData.GetSize, 2);
end;


procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SettingsDB.Monitoring := CheckBox0.Checked;
  SettingsDB.PreventDuplicates := CheckBox5.Checked;
  SettingsDB.isTimeLimited := CheckBox1.Checked;
  SettingsDB.isSizeLimited := CheckBox2.Checked;
  SettingsDB.isItemsLimited := CheckBox3.Checked;
  SettingsDB.isAutoSave := CheckBox4.Checked;

  SettingsDB.TimeIndex := ComboBox1.ItemIndex;
  SettingsDB.SizeIndex := ComboBox2.ItemIndex;
  SettingsDB.AutoSaveIndex := ComboBox3.ItemIndex;

  SpinEdit1Exit(nil);
  SpinEdit2Exit(nil);
  SpinEdit3Exit(nil);

  case ComboBox1.ItemIndex of
    0: SettingsDB.RemoveAfter := SpinEdit1.Value*60;
    1: SettingsDB.RemoveAfter := SpinEdit1.Value*60*60;
    2: SettingsDB.RemoveAfter := SpinEdit1.Value*60*60*24;
    3: SettingsDB.RemoveAfter := SpinEdit1.Value*60*60*24*7;
    4: SettingsDB.RemoveAfter := SpinEdit1.Value*60*60*24*30;
  end;

  case ComboBox2.ItemIndex of
    0: SettingsDB.MaxSize := SpinEdit2.Value;
    1: SettingsDB.MaxSize := SpinEdit2.Value*1024;
    2: SettingsDB.MaxSize := SpinEdit2.Value*1024*1024;
  end;

  case ComboBox3.ItemIndex of
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
  case ComboBox1.ItemIndex of
    0: CheckValue(SpinEdit1, 1, 9999);
    1: CheckValue(SpinEdit1, 1, 9999);
    2: CheckValue(SpinEdit1, 1, 9999);
    3: CheckValue(SpinEdit1, 1, 100);
    4: CheckValue(SpinEdit1, 1, 100);
  end;
end;

procedure TForm2.SpinEdit2Change(Sender: TObject);
begin
  case ComboBox2.ItemIndex of
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
  case ComboBox3.ItemIndex of
    0: CheckValue(SpinEdit4, 1, 60);
    1: CheckValue(SpinEdit4, 1, 24);
  end;
end;


procedure TForm2.ComboBox1Change(Sender: TObject);
begin
  StaticText1.SetFocus;
  SpinEdit1Change(nil);
end;


procedure TForm2.ComboBox2Change(Sender: TObject);
begin
  StaticText1.SetFocus;
  SpinEdit2Change(nil);
end;


procedure TForm2.ComboBox3Change(Sender: TObject);
begin
  StaticText1.SetFocus;
  SpinEdit4Change(nil);
end;


procedure TForm2.PanelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  StaticText1.SetFocus;
  SimulatePress(TFlatPanel(Sender));
end;


procedure TForm2.Panel1Click(Sender: TObject);
var
  TNTSaveDialog: TTNTSaveDialog;
begin
  if DynamicData.GetLength <= 0 then begin
    ShowMessage('Cannot export empty list.');
    Exit;
  end;

  TNTSaveDialog := TTNTSaveDialog.Create(nil);
  TNTSaveDialog.Filter := 'CLIPBOARD Files|*' + CLIPBOARD_EXTENSION;
  TNTSaveDialog.Options := [ofHideReadOnly, ofEnableSizing];
  TNTSaveDialog.Title := 'Clipboard History: Export Clipboard History';

  if TNTSaveDialog.Execute then begin
    if Pos('.', TNTSaveDialog.FileName) <= 0 then TNTSaveDialog.FileName := WideChangeFileExt(TNTSaveDialog.FileName, CLIPBOARD_EXTENSION);

    if DynamicData.GetSize > MAXIMUM_SIZE then begin
      ShowMessage('Cannot export file bigger than ' + FormatSize(MAXIMUM_SIZE, 0) + '.');
      Exit;
    end;

    DynamicData.Save(DO_COMPRESS, TNTSaveDialog.FileName);
    ShowMessage('Exported clipboard history.');
  end;
end;


procedure TForm2.Panel2Click(Sender: TObject);
var
  TNTOpenDialog: TTNTOpenDialog;
  srSearch: TWIN32FindDataW;
  FileSize: Int64;
  i: Integer;
  DateTime: TDateTime;
  buttonSelected: Integer;
begin
  TNTOpenDialog := TTNTOpenDialog.Create(nil);
  TNTOpenDialog.Filter := 'CLIPBOARD Files|*' + CLIPBOARD_EXTENSION;
  TNTOpenDialog.Options := [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing];
  TNTOpenDialog.Title := 'Clipboard History: Import Clipboard History';

  if TNTOpenDialog.Execute then begin
    FindFirstFileW(PWideChar(TNTOpenDialog.FileName), srSearch);
    FileSize := (srSearch.nFileSizeHigh * 4294967296) + srSearch.nFileSizeLow;

    if FileSize > MAXIMUM_SIZE then begin
      ShowMessage('Cannot import file bigger than ' + FormatSize(MAXIMUM_SIZE, 0) + '.');
      Exit;
    end;

    DynamicData.Load(DO_COMPRESS, True, TNTOpenDialog.FileName, False);

    if DynamicData.GetLength <= 0 then begin
      ShowMessage('There was an error importing list.');
      Exit;
    end;

    if (DynamicData.GetLength > SettingsDB.MaxItems) and CheckBox3.Checked then DynamicData.SetLength(SettingsDB.MaxItems);
    buttonSelected := MessageDlg('Do you want to reset date?', mtConfirmation, [mbYes, mbNo], 0);

    if buttonSelected = mrYes then begin
      DateTime := Now;

      for i := 0 to DynamicData.GetLength-1 do begin
        DynamicData.SetValue(i, 'DateTime', DateTime);
      end;
    end;

    StaticText5.Caption := 'Size: ' + FormatSize(DynamicData.GetSize, 2);
    ShowMessage('Imported clipboard history.');
  end;
end;


procedure TForm2.Panel3Click(Sender: TObject);
var
  buttonSelected: Integer;
begin
  buttonSelected := MessageDlg('Are you sure you want to clear the list?', mtConfirmation, [mbYes, mbNo], 0);
  if buttonSelected <> mrYes then Exit;
  DynamicData.ResetData;
  StaticText5.Caption := 'Size: ' + FormatSize(DynamicData.GetSize, 2);
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

procedure TForm2.Panel4Click(Sender: TObject);
begin
  Form4.ShowModal;
end;

end.
