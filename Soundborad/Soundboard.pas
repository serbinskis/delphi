unit Soundboard;

interface

uses
  Windows, Messages, SysUtils, MMSystem, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls, Grids, Menus,
  Variants, ShellAPI, Registry, TNTDialogs, TNTClasses, TNTSysUtils, TNTGrids, TNTGraphics, XiTrackBar, TFlatCheckBoxUnit,
  TFlatPanelUnit, ATScrollBar, DirectShow, cbAudioPlay, ZipForge, uHotKey, uDynamicData, WinXP, Functions;

type
  TForm1 = class(TForm)
    About1: TMenuItem;
    ChangeName1: TMenuItem;
    CheckBox1: TFlatCheckBox;
    ConvertToFile1: TMenuItem;
    ConvertToMemory1: TMenuItem;
    Delete1: TMenuItem;
    ExitWithoutSave1: TMenuItem;
    Export1: TMenuItem;
    Favorite1: TMenuItem;
    FromList1: TMenuItem;
    FromListFile1: TMenuItem;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Import1: TMenuItem;
    Location1: TMenuItem;
    MainMenu1: TMainMenu;
    MakeaCopyToFile1: TMenuItem;
    MoveDown1: TMenuItem;
    MoveTo1: TMenuItem;
    MoveUp1: TMenuItem;
    Open1: TMenuItem;
    Panel1: TPanel;
    Panel2: TFlatPanel;
    PopupMenu1: TPopupMenu;
    SaveCurrentState1: TMenuItem;
    SaveInArchive1: TMenuItem;
    Settings1: TMenuItem;
    StaticText1: TStaticText;
    TNTStringGrid1: TTntStringGrid;
    Timer1: TTimer;
    Timer2: TTimer;
    Tools1: TMenuItem;
    TrackBar1: TXiTrackBar;
    TrackBar2: TXiTrackBar;
    procedure About1Click(Sender: TObject);
    procedure ChangeName1Click(Sender: TObject);
    procedure ChangeVertical(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure ConvertToFile1Click(Sender: TObject);
    procedure ConvertToMemory1Click(Sender: TObject);
    procedure ExitWithoutSave1Click(Sender: TObject);
    procedure Export1Click(Sender: TObject);
    procedure Favorite1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FromList1Click(Sender: TObject);
    procedure FromListFile1Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image2Click(Sender: TObject);
    procedure Image2MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image3Click(Sender: TObject);
    procedure Image3MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image3MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Import1Click(Sender: TObject);
    procedure Location1Click(Sender: TObject);
    procedure MakeaCopyToFile1Click(Sender: TObject);
    procedure MoveDown1Click(Sender: TObject);
    procedure MoveTo1Click(Sender: TObject);
    procedure MoveUp1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PauseAudio;
    procedure PlayAudio;
    procedure PopupMenu1Popup(Sender: TObject);
    procedure SaveCurrentState1Click(Sender: TObject);
    procedure SaveInArchive1Click(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
    procedure StopAudio;
    procedure TNTStringGrid1DblClick(Sender: TObject);
    procedure TNTStringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure TNTStringGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TNTStringGrid1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure TNTStringGrid1MouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure TNTStringGrid1MouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure TNTStringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    function SelectFromInput: Boolean;
  private
    { Private declarations }
  protected
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
  public
    { Public declarations }
  end;

type
  THotKey = record
    Key: Integer;
    ShortCut: Integer;
    Name: WideString;
    Description: WideString;
  end;

  TSettingsDB = record
    Device1: String;
    Device2: String;
    FormHeight: Integer;
    AlwaysNumLock: Boolean;
    StayOnTop: Boolean;
    SaveInMemory: Boolean;
  end;

const
  DECREASE_MINIMUM_PERCENT = 50;
  MAXIMUM_INPUT_LENGTH = 3;
  MAXIMUM_SIZE = 1024*1024*300;
  MINIMUM_FORM_HEIGHT = 300;
  DEFAULT_ROOT_KEY = HKEY_CURRENT_USER;
  DEFAULT_KEY = '\Software\WobbyChip\Soundboard';
  DEFAULT_HOTKEY_KEY = '\Software\WobbyChip\Soundboard\HotKeys';
  SOUNDBOARD_EXTSENSION = '.snb';
  COLS: array[0..1] of Integer = (30, 310);
  SCROLL_BY = 3;

var
  HotKeys: array[0..22] of THotKey = (
    (Key: 0; ShortCut: 106; Name: 'PLAY_AUDIO'; Description: 'Play selected sound'),
    (Key: 0; ShortCut: 110; Name: 'STOP_AUDIO'; Description: 'Stop audio'),
    (Key: 0; ShortCut: 111; Name: 'PAUSE_RESUME'; Description: 'Pause or resume sound'),
    (Key: 0; ShortCut: 36; Name: 'LOOP_AUDIO'; Description: 'Enable or disable loop'),
    (Key: 0; ShortCut: 16491; Name: 'INCREASE_AUDIO_ALL'; Description: 'Increase both devices volume'),
    (Key: 0; ShortCut: 8299; Name: 'INCREASE_AUDIO_PRIMARY'; Description: 'Increase first device volume'),
    (Key: 0; ShortCut: 16493; Name: 'DECREASE_AUDIO_ALL'; Description: 'Decrease both devices volume'),
    (Key: 0; ShortCut: 8301; Name: 'DECREASE_AUDIO_PRIMARY'; Description: 'Decrease first device volume'),
    (Key: 0; ShortCut: 109; Name: 'CLEAR_INPUT'; Description: 'Clear input'),
    (Key: 0; ShortCut: 107; Name: 'SELECT_INPUT'; Description: 'Select sound from input'),
    (Key: 0; ShortCut: 8230; Name: 'SCROLL_UP'; Description: 'Scroll up'),
    (Key: 0; ShortCut: 8232; Name: 'SCROLL_DOWN'; Description: 'Scroll down'),
    (Key: 0; ShortCut: 16494; Name: 'CLOSE_APPLICATION'; Description: 'Close application'),
    (Key: 0; ShortCut: 96; Name: 'NUMBER_0'; Description: 'Enter number "0" in input'),
    (Key: 0; ShortCut: 97; Name: 'NUMBER_1'; Description: 'Enter number "1" in input'),
    (Key: 0; ShortCut: 98; Name: 'NUMBER_2'; Description: 'Enter number "2" in input'),
    (Key: 0; ShortCut: 99; Name: 'NUMBER_3'; Description: 'Enter number "3" in input'),
    (Key: 0; ShortCut: 100; Name: 'NUMBER_4'; Description: 'Enter number "4" in input'),
    (Key: 0; ShortCut: 101; Name: 'NUMBER_5'; Description: 'Enter number "5" in input'),
    (Key: 0; ShortCut: 102; Name: 'NUMBER_6'; Description: 'Enter number "6" in input'),
    (Key: 0; ShortCut: 103; Name: 'NUMBER_7'; Description: 'Enter number "7" in input'),
    (Key: 0; ShortCut: 104; Name: 'NUMBER_8'; Description: 'Enter number "8" in input'),
    (Key: 0; ShortCut: 105; Name: 'NUMBER_9'; Description: 'Enter number "9" in input')
  );

var
  Form1: TForm1;
  SettingsDB: TSettingsDB;
  DynamicData: TDynamicData;
  PlayBitmap: TBitmap;
  PauseBitmap: TBitmap;
  StopBitmap: TBitmap;
  MicrophoneBitmap: TBitmap;
  AudioPlay1: TcbAudioPlay;
  AudioPlay2: TcbAudioPlay;
  ItemsPerPage: Integer;
  Scroll: TATScroll;
  AllowSelect: Boolean = True;
  SearchString: WideString = '';

procedure HotKeyCallback(Key, ShortCut: Integer; CustomValue: Variant);
procedure BuildList;

implementation

uses Settings, Archiving;

{$R *.dfm}


//LoadSettings
procedure LoadSettings;
var
  i: Integer;
begin
  LoadRegistryString(SettingsDB.Device1, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'Device1');
  LoadRegistryString(SettingsDB.Device2, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'Device2');
  LoadRegistryInteger(SettingsDB.FormHeight, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'FormHeight');
  LoadRegistryBoolean(SettingsDB.AlwaysNumLock, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'AlwaysNumLock');
  LoadRegistryBoolean(SettingsDB.StayOnTop, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'StayOnTop');
  LoadRegistryBoolean(SettingsDB.SaveInMemory, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'SaveInMemory');

  for i := 0 to Length(HotKeys)-1 do begin
    Form2.ComboBox3.Items.Add(HotKeys[i].Description);
    LoadRegistryInteger(HotKeys[i].ShortCut, DEFAULT_ROOT_KEY, DEFAULT_HOTKEY_KEY, HotKeys[i].Name);
    HotKeys[i].Key := SetShortCut(HotKeyCallback, HotKeys[i].ShortCut, Null);
  end;

  Form2.ComboBox3.ItemIndex := 0;
  DynamicData := TDynamicData.Create(['FileName', 'Name', 'Exstension', 'Favorite', 'Memory']);
  DynamicData.Load(DEFAULT_ROOT_KEY, DEFAULT_KEY, 'Soundboard', [loRemoveUnused, loOFReset]);
end;
//LoadSettings


//SaveSettings
procedure SaveSettings;
var
  i: Integer;
begin
  SaveRegistryString(SettingsDB.Device1, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'Device1');
  SaveRegistryString(SettingsDB.Device2, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'Device2');
  SaveRegistryInteger(SettingsDB.FormHeight, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'FormHeight');
  SaveRegistryBoolean(SettingsDB.AlwaysNumLock, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'AlwaysNumLock');
  SaveRegistryBoolean(SettingsDB.StayOnTop, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'StayOnTop');
  SaveRegistryBoolean(SettingsDB.SaveInMemory, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'SaveInMemory');

  for i := 0 to Length(HotKeys)-1 do begin
    SaveRegistryInteger(HotKeys[i].ShortCut, DEFAULT_ROOT_KEY, DEFAULT_HOTKEY_KEY, HotKeys[i].Name);
  end;

  DynamicData.Save(DEFAULT_ROOT_KEY, DEFAULT_KEY, 'Soundboard', []);
end;
//SaveSettings


//FormatNumber
function FormatNumber(Num: Integer): String;
var
  i: Integer;
begin
  Result := IntToStr(Num);

  for i := Length(IntToStr(Num)) to Length(IntToStr(DynamicData.GetLength))-1 do begin
      Result := '0' + Result;
  end;
end;
//FormatNumber


//FormatDevice
function FormatDevice(ComboBox: TCustomComboBox): Integer;
begin
  Result := -1;

  if (ComboBox.Items[ComboBox.ItemIndex] <> 'Disabled')
  or (ComboBox.Items[ComboBox.ItemIndex] <> 'Default')
  then Result := ComboBox.ItemIndex-2;
end;
//FormatDevice


//UpdateList
procedure UpdateList;
var
  i, Size: Integer;
  FileName: WideString;
begin
  Form1.StopAudio;
  for i := 0 to DynamicData.GetLength-1 do begin
    Size := Length(DynamicData.GetValueArrayByte(i, 'Memory'));
    FileName := DynamicData.GetValue(i, 'FileName');

    if (not WideFileExists(FileName)) and (Size <= 0) then begin
      WideShowMessage('File is missing and will be deleted from list:' + #13#10 + WideExtractFileName(FileName));
      DynamicData.DeleteData(i);
      UpdateList;
      Break;
    end;
  end;
end;
//UpdateList


//BuildList
procedure BuildList;
var
  i: Integer;
begin
  if DynamicData.GetLength > 0 then begin
    Form1.TNTStringGrid1.ColWidths[0] := COLS[0];
    Form1.TNTStringGrid1.ColWidths[1] := COLS[1];
    Form1.TNTStringGrid1.GridLineWidth := 1;
    Scroll.Max := DynamicData.GetLength
  end else begin
    Form1.TNTStringGrid1.ColWidths[0] := 0;
    Form1.TNTStringGrid1.ColWidths[1] := 0;
    Form1.TNTStringGrid1.GridLineWidth := 0;

    Form1.TNTStringGrid1.Cols[0].Clear;
    Form1.TNTStringGrid1.Rows[0].Clear;
    Scroll.Visible := False;
    Exit;
  end;

  if ItemsPerPage < DynamicData.GetLength
    then Scroll.Visible := True
    else Scroll.Visible := False;

  Form1.TNTStringGrid1.RowCount := DynamicData.GetLength;
  for i := 0 to DynamicData.GetLength-1 do begin
    Form1.TNTStringGrid1.Cells[0, i] := IntToStr(i+1);

    if DynamicData.GetValue(i, 'Favorite')
      then Form1.TNTStringGrid1.Cells[1, i] := '* ' + DynamicData.GetValue(i, 'Name')
      else Form1.TNTStringGrid1.Cells[1, i] := DynamicData.GetValue(i, 'Name');
    if Length(DynamicData.GetValueArrayByte(i, 'Memory')) > 0
      then Form1.TNTStringGrid1.Cells[1, i] := Form1.TNTStringGrid1.Cells[1, i] + ' [MEM]';
  end;
end;
//BuildList


//CountFavorites
function CountFavorites: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to DynamicData.GetLength-1 do begin
    if DynamicData.GetValue(i, 'Favorite') then Result := Result+1;
  end;
end;
//CountFavorites


//ProcessFile
function ProcessFile(FileName: WideString): Integer;
var
  Name, Exstension: WideString;
  Size, i: Int64;
  Memory: TArrayOfByte;
  MemoryStream: TMemoryStream;
begin
  Result := 0;

  if DynamicData.GetLength >= 999 then begin
    MessageBeep(MB_ICONEXCLAMATION);
    ShowMessage('The limit of maximum sounds has been reached.');
    Result := -1;
    Exit;
  end;

  Size := DynamicData.GetSize;
  if SettingsDB.SaveInMemory then Size := Size + GetFileSize(FileName);

  if Size >= MAXIMUM_SIZE then begin
    MessageBeep(MB_ICONEXCLAMATION);
    ShowMessage('The maximum size has been reached ' + FormatSize(MAXIMUM_SIZE, 0) + '.');
    Result := -1;
    Exit;
  end;

  if (ExtractFileExt(FileName) = '.mp3') or (ExtractFileExt(FileName) = '.wav') then begin
    Name := TNT_WideStringReplace(WideExtractFileName(FileName), WideExtractFileExt(FileName), '', [rfReplaceAll, rfIgnoreCase]);
    Exstension := WideLowerCase(WideExtractFileExt(FileName));

    i := DynamicData.CreateData(-1);
    DynamicData.SetValue(i, 'FileName', FileName);
    DynamicData.SetValue(i, 'Name', Name);
    DynamicData.SetValue(i, 'Exstension', Exstension);
    DynamicData.SetValue(i, 'Favorite', False);
    DynamicData.SetValueArrayByte(i, 'Memory', nil);

    if SettingsDB.SaveInMemory then begin
      MemoryStream := TMemoryStream.Create;
      WriteFileToStream(MemoryStream, FileName);
      MemoryStream.Position := 0;
      SetLength(Memory, MemoryStream.Size);
      MemoryStream.Read(Memory[0], MemoryStream.Size);
      MemoryStream.Free;

      DynamicData.SetValueArrayByte(i, 'Memory', Memory);
      DynamicData.SetValue(i, 'FileName', '');
    end;

    Result := 1;
  end;
end;
//ProcessFile


//PlayAudio
procedure TForm1.PlayAudio;
var
  Row: Integer;
  FileName: WideString;
  Memory: TArrayOfByte;
begin
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;
  Row := TNTStringGrid1.Row;
  FileName := DynamicData.GetValue(Row, 'FileName');
  Memory := DynamicData.GetValueArrayByte(Row, 'Memory');

  Image2.Hint := 'Pause';
  StopAudio;

  if (not WideFileExists(FileName)) and (Length(Memory) <= 0) then begin
    MessageBeep(MB_ICONEXCLAMATION);
    WideShowMessage('File not found:' + #13#10 + DynamicData.GetValue(Row, 'Name'));
    Exit;
  end;

  if (Length(Memory) > 0) then begin
    if not DirectoryExists(GetEnvironmentVariable('TEMP')) then CreateDir(GetEnvironmentVariable('TEMP'));
    FileName := GetEnvironmentVariable('TEMP') + '\' + RandomString(16, False) + DynamicData.GetValue(Row, 'Exstension');
    SaveByteArray_var(Memory, FileName);
  end;

  AudioPlay1 := TcbAudioPlay.Create(Self, FileName, FormatDevice(Form2.ComboBox1));
  AudioPlay2 := TcbAudioPlay.Create(Self, FileName, FormatDevice(Form2.ComboBox2));

  if (Length(Memory) > 0) then DeleteFileW(PWideChar(FileName));
  if Form2.ComboBox1.Items[Form2.ComboBox1.ItemIndex] <> 'Disabled' then AudioPlay1.Play;
  if Form2.ComboBox2.Items[Form2.ComboBox2.ItemIndex] <> 'Disabled' then AudioPlay2.Play;

  AudioPlay1.Volume := TrackBar1.Position;
  AudioPlay2.Volume := TrackBar2.Position;

  AudioPlay1.Loop := CheckBox1.Checked;
  AudioPlay2.Loop := CheckBox1.Checked;
end;
//PlayAudio


//PauseAudio
procedure TForm1.PauseAudio;
var
  ButtonHint: String;
begin
  ButtonHint := 'Pause';

  if Form2.ComboBox1.Items[Form2.ComboBox1.ItemIndex] <> 'Disabled' then
    if Assigned(AudioPlay1) then begin
      if Image2.Hint = 'Pause' then begin
        ButtonHint := 'Resume';
        AudioPlay1.Pause;
      end else begin
        ButtonHint := 'Pause';
        AudioPlay1.Play;
      end;
    end;

  if Form2.ComboBox2.Items[Form2.ComboBox2.ItemIndex] <> 'Disabled' then
    if Assigned(AudioPlay2) then begin
      if Image2.Hint = 'Pause' then begin
        ButtonHint := 'Resume';
        AudioPlay2.Pause;
      end else begin
        ButtonHint := 'Pause';
        AudioPlay2.Play;
      end;
    end;

  Image2.Hint := ButtonHint;
end;
//PauseAudio


//StopAudio
procedure TForm1.StopAudio;
begin
  if Assigned(AudioPlay1) then begin
    AudioPlay1.Stop;
    AudioPlay1.Free;
    AudioPlay1 := nil;
  end;

  if Assigned(AudioPlay2) then begin
    AudioPlay2.Stop;
    AudioPlay2.Free;
    AudioPlay2 := nil;
  end;
end;
//StopAudio


procedure TForm1.Settings1Click(Sender: TObject);
begin
  Form2.ShowModal;

  if SettingsDB.StayOnTop
    then SetWindowPos(Handle, HWND_TOPMOST, 0,0,0,0, SWP_NOMOVE or SWP_NOSIZE)
    else SetWindowPos(Handle, HWND_NOTOPMOST, 0,0,0,0, SWP_NOMOVE or SWP_NOSIZE);
end;


procedure TForm1.About1Click(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://serbinskis.github.io/', nil, nil, SW_SHOWMAXIMIZED);
end;


procedure TForm1.Export1Click(Sender: TObject);
var
  TNTSaveDialog: TTNTSaveDialog;
begin
  if DynamicData.GetLength <= 0 then begin
    ShowMessage('Cannot export empty playlist.');
    Exit;
  end;

  TNTSaveDialog := TTNTSaveDialog.Create(nil);
  TNTSaveDialog.Filter := 'Soundboard Files|*' + SOUNDBOARD_EXTSENSION;
  TNTSaveDialog.Options := [ofHideReadOnly, ofEnableSizing];
  TNTSaveDialog.Title := 'Soundboard: Export Playlist';

  if TNTSaveDialog.Execute then begin
    if Pos('.', TNTSaveDialog.FileName) <= 0 then TNTSaveDialog.FileName := WideChangeFileExt(TNTSaveDialog.FileName, SOUNDBOARD_EXTSENSION);

    if DynamicData.GetSize > MAXIMUM_SIZE then begin
      ShowMessage('Cannot export file bigger than ' + FormatSize(MAXIMUM_SIZE, 0) + '.');
      Exit;
    end;

    DynamicData.Save(TNTSaveDialog.FileName, []);
    ShowMessage('Playlist exported.');
  end;
end;


procedure TForm1.Import1Click(Sender: TObject);
var
  TNTOpenDialog: TTNTOpenDialog;
begin
  TNTOpenDialog := TTNTOpenDialog.Create(nil);
  TNTOpenDialog.Filter := 'Sounboard Files|*' + SOUNDBOARD_EXTSENSION;
  TNTOpenDialog.Options := [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing];
  TNTOpenDialog.Title := 'Soundboard: Import Playlist';

  if TNTOpenDialog.Execute then begin
    if GetFileSize(TNTOpenDialog.FileName) > MAXIMUM_SIZE then begin
      ShowMessage('Cannot import file bigger than ' + FormatSize(MAXIMUM_SIZE, 0) + '.');
      Exit;
    end;

    if not DynamicData.Load(TNTOpenDialog.FileName, [loRemoveUnused]) then begin
      PlaySound('SystemExclamation', 0, SND_ASYNC);
      ShowMessage('There was an error importing playlist.');
      Exit;
    end;

    UpdateList;
    BuildList;
    TNTStringGrid1.Row := 0;
    Scroll.Position := 0;

    ShowMessage('Playlist imported.');
  end;
end;


procedure TForm1.SaveInArchive1Click(Sender: TObject);
var
  i: Integer;
  Name, FileName, Exstension: WideString;
  Memory: TArrayOfByte;
  FileStream: TTNTFileStream;
  ZipArchive: TZipForge;
  TNTSaveDialog: TTNTSaveDialog;
begin
  if DynamicData.GetLength <= 0 then begin
    ShowMessage('Cannot save empty playlist.');
    Exit;
  end;

  StopAudio;

  TNTSaveDialog := TTNTSaveDialog.Create(nil);
  TNTSaveDialog.Filter := 'ZIP File|*.zip';
  TNTSaveDialog.Options := [ofHideReadOnly, ofEnableSizing];
  TNTSaveDialog.Title := 'Soundboard: Save Zip Archive';

  if TNTSaveDialog.Execute then begin
    if Pos('.', TNTSaveDialog.FileName) <= 0 then TNTSaveDialog.FileName := WideChangeFileExt(TNTSaveDialog.FileName, '.zip');

    ZipArchive := TZipForge.Create(nil);
    ZipArchive.CompressionLevel := ZipForge.clNone;
    ZipArchive.FileName := TNTSaveDialog.FileName;
    ZipArchive.OpenArchive(fmCreate);

    Form3.Show;
    Form1.Enabled := False;
    Application.ProcessMessages;

    for i := 0 to DynamicData.GetLength-1  do begin
      Name := DynamicData.GetValue(i, 'Name');
      FileName := DynamicData.GetValue(i, 'FileName');
      Exstension := DynamicData.GetValue(i, 'Exstension');
      Memory := DynamicData.GetValueArrayByte(i, 'Memory');

      if (Length(Memory) > 0) then begin
        Name := WideChangeFileExt(Name, Exstension);
        ZipArchive.AddFromBuffer(FormatNumber(i+1) + ' - ' + Name, Memory[0], Length(Memory));
      end else begin
        Name := FormatNumber(i+1) + ' - ' + WideExtractFileName(FileName);
        FileStream := TTNTFileStream.Create(FileName, fmOpenRead);
        ZipArchive.AddFromStream(Name, FileStream);
        FileStream.Free;
      end;

      Form3.ProgressBar1.Position := Round((i+1)/DynamicData.GetLength*100);
      Form3.StaticText1.Caption := IntToStr(Round((i+1)/DynamicData.GetLength*100)) + '%';
    end;

    Form3.ProgressBar1.Position := 100;
    Form3.StaticText1.Caption := '100%';
    Wait(300);

    Form3.Hide;
    Form1.Enabled := True;
    ZipArchive.CloseArchive;
  end;
end;


procedure TForm1.SaveCurrentState1Click(Sender: TObject);
begin
  SaveSettings;
  ShowMessage('Saved current state.');
end;


procedure TForm1.ExitWithoutSave1Click(Sender: TObject);
begin
  //Heck it I am just too lazy to do it properly
  TerminateProcess(GetCurrentProcess, 0);
end;


procedure TForm1.FormShow(Sender: TObject);
var
  i: Integer;
begin
  LoadSettings;
  TNTStringGrid1.SetFocus;
  DragAcceptFiles(Handle, True);

  Form2.CheckBox1.Checked := SettingsDB.AlwaysNumLock;
  Timer2.Enabled := SettingsDB.AlwaysNumLock;

  if SettingsDB.StayOnTop then SetWindowPos(Handle, HWND_TOPMOST, 0,0,0,0, SWP_NOMOVE or SWP_NOSIZE);
  Form2.CheckBox2.Checked := SettingsDB.StayOnTop;
  Form2.CheckBox3.Checked := SettingsDB.SaveInMemory;

  if SettingsDB.FormHeight <> 0 then begin
    Form1.Height := SettingsDB.FormHeight;
  end;

  Panel1.Width := Form1.Width;
  Panel1.Top := Form1.Height-51;
  TNTStringGrid1.Height := Form1.Height - TNTStringGrid1.Top - 55;
  ItemsPerPage := Trunc(TNTStringGrid1.Height/(TNTStringGrid1.DefaultRowHeight + TNTStringGrid1.GridLineWidth));

  Scroll := TATScroll.Create(Self);
  Scroll.Parent := Form1;
  Scroll.Kind := sbVertical;
  Scroll.OnChange := ChangeVertical;
  Scroll.DisableMarks := True;

  Scroll.Color := $F0F0F0;
  Scroll.ColorBorder := RGB(241, 241, 241);
  Scroll.ColorRectArrow := RGB(241, 241, 241);
  Scroll.ColorFillArrow := RGB(241, 241, 241);
  Scroll.ColorRectThumb := RGB(193, 193, 193);
  Scroll.ColorFillThumb := RGB(193, 193, 193);
  Scroll.ColorArrow := RGB(96, 96, 96);

  Scroll.Min := 0;
  Scroll.Width := 16;
  Scroll.Height := TNTStringGrid1.Height-2;
  Scroll.Top := TNTStringGrid1.Top+1;
  Scroll.Left := TNTStringGrid1.Width - (Scroll.Width div 2)-1;
  Scroll.PageSize := ItemsPerPage;

  UpdateList;
  BuildList;

  PlayBitmap := TBitmap.Create;
  PlayBitmap.LoadFromResourceName(HInstance, 'Play');
  BitBlt(Image1.Canvas.Handle, 0, 0, 25, 25, PlayBitmap.Canvas.Handle, 0, 0, SRCCOPY);

  PauseBitmap := TBitmap.Create;
  PauseBitmap.LoadFromResourceName(HInstance, 'Pause');
  BitBlt(Image2.Canvas.Handle, 0, 0, 25, 25, PauseBitmap.Canvas.Handle, 0, 0, SRCCOPY);

  StopBitmap := TBitmap.Create;
  StopBitmap.LoadFromResourceName(HInstance, 'Stop');
  BitBlt(Image3.Canvas.Handle, 0, 0, 25, 25, StopBitmap.Canvas.Handle, 0, 0, SRCCOPY);

  MicrophoneBitmap := TBitmap.Create;
  MicrophoneBitmap.LoadFromResourceName(HInstance, 'Microphone');
  BitBlt(Image4.Canvas.Handle, 0, 0, 16, 16, MicrophoneBitmap.Canvas.Handle, 0, 0, SRCCOPY);
  BitBlt(Image5.Canvas.Handle, 0, 0, 16, 16, MicrophoneBitmap.Canvas.Handle, 0, 0, SRCCOPY);

  TrackBar1.Min := Round(cbAudioPlay_MIN_VOLUME/100 * DECREASE_MINIMUM_PERCENT);
  TrackBar1.Max := cbAudioPlay_MAX_VOLUME;
  TrackBar2.Min := Round(cbAudioPlay_MIN_VOLUME/100 * DECREASE_MINIMUM_PERCENT);
  TrackBar2.Max := cbAudioPlay_MAX_VOLUME;

  Form2.ComboBox1.Items.Add('Default');
  Form2.ComboBox1.Items.Add('Disabled');
  Form2.ComboBox2.Items.Add('Default');
  Form2.ComboBox2.Items.Add('Disabled');

  for i := 0 to cbDeviceList.Count-1 do begin
    Form2.ComboBox1.Items.Add(cbDeviceList[i]);
    Form2.ComboBox2.Items.Add(cbDeviceList[i])
  end;

  Form2.ComboBox1.ItemIndex := 0;
  Form2.ComboBox2.ItemIndex := 1;

  if SettingsDB.Device1 <> '' then begin
    for i := 0 to Form2.ComboBox1.Items.Count-1 do begin
      if Form2.ComboBox1.Items[i] = SettingsDB.Device1 then begin
        Form2.ComboBox1.ItemIndex := i;
        Image4.Hint := 'First Device: ' + Form2.ComboBox1.Items[i];
      end;
    end;
  end;

  if SettingsDB.Device2 <> '' then begin
    for i := 0 to Form2.ComboBox2.Items.Count-1 do begin
      if Form2.ComboBox2.Items[i] = SettingsDB.Device2 then begin
        Form2.ComboBox2.ItemIndex := i;
        Image5.Hint := 'Second Device: ' + Form2.ComboBox2.Items[i];
      end;
    end;
  end;
end;


procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Form1.Visible := False;
  ShowWindow(Application.Handle, SW_HIDE);
  DragAcceptFiles(Handle, False);

  if SettingsDB.AlwaysNumLock then begin
    Timer2.Enabled := False;
    if GetKeyState(VK_NUMLOCK) = 1 then begin
      keybd_event(VK_NUMLOCK, 0, 0, 0);
      keybd_event(VK_NUMLOCK, 0, 2, 0);
    end;
  end;

  SettingsDB.FormHeight := Form1.Height;
  SettingsDB.Device1 := Form2.ComboBox1.Items[Form2.ComboBox1.ItemIndex];
  SettingsDB.Device2 := Form2.ComboBox2.Items[Form2.ComboBox2.ItemIndex];
  SaveSettings;
end;


procedure TForm1.WMDropFiles(var Msg: TMessage);
var
  hDrop: THandle;
  FileCount, Count: Integer;
  i, Len, Res: Integer;
  FileName: WideString;
begin
  Count := 0;
  hDrop := Msg.wParam;
  FileCount := DragQueryFileW(hDrop, $FFFFFFFF, nil, 0);

  for i := 0 to FileCount-1 do begin
    Len := DragQueryFileW(hDrop, i, nil, 0)+1;
    SetLength(FileName, Len);
    DragQueryFileW(hDrop, i, Pointer(FileName), Len);
    FileName := Trim(FileName);

    Res := ProcessFile(FileName);
    if Res = -1 then Break;
    if Res = 1 then Inc(Count);
  end;

  if Count > 0 then begin
    BuildList;
    TNTStringGrid1.Row := DynamicData.GetLength-1;
  end;

  DragFinish(hDrop);
end;


procedure TForm1.Open1Click(Sender: TObject);
var
  TNTOpenDialog: TTNTOpenDialog;
  Strings: TTNTStrings;
  i: Integer;
begin
  TNTOpenDialog := TTNTOpenDialog.Create(nil);
  TNTOpenDialog.Filter := 'MP3; WAV Files|*.mp3; *.wav';
  TNTOpenDialog.Options := [ofHideReadOnly,ofAllowMultiSelect,ofEnableSizing];
  TNTOpenDialog.Title := 'Open: Soundboard';

  if TNTOpenDialog.Execute then begin
    Strings := TNTOpenDialog.Files;

    for i := 0 to Strings.Count-1 do begin
      if ProcessFile(Strings[i]) = -1 then Break;;
    end;

    BuildList;
    TNTStringGrid1.Row := DynamicData.GetLength-1;
  end;
end;                 


procedure TForm1.TNTStringGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i: Integer;
begin
  if (ssCtrl in Shift) and ((Key = VK_UP) or (Key = VK_DOWN)) then Key := 0;

  if Key = VK_SPACE then PlayAudio;
  if Key = VK_F2 then PopupMenu1.Items[5].Click;
  if (Key = VK_PRIOR) or (Key = VK_NEXT) then Key := 0;

  if (Key = VK_DELETE) and (TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] <> '') then begin
    StopAudio;
    i := TNTStringGrid1.Row;
    DynamicData.DeleteData(i);
    BuildList;
    if i <= TNTStringGrid1.RowCount-1 then TNTStringGrid1.Row := i
    else TNTStringGrid1.Row := TNTStringGrid1.RowCount-1;
    Scroll.Position := TNTStringGrid1.TopRow-1;
    Exit;
  end;

  if (Key = Ord('F')) and (Shift = [ssCtrl]) then begin
    SearchString := WideInputBox('Find', 'Find what:', '', Form1.Font);
    if SearchString <> '' then Key := VK_F3;
  end;

  if (Key <> VK_F3) or (SearchString = '') then Exit;
  Form1.Caption := SearchString;

  for i := TNTStringGrid1.Row+1 to DynamicData.GetLength-1 do begin
    if WideContainsString(SearchString, DynamicData.GetValue(i, 'Name'), False) then begin
      TNTStringGrid1.Row := i;
      Exit;
    end;
  end;

  for i := 0 to TNTStringGrid1.Row-1 do begin
    if WideContainsString(SearchString, DynamicData.GetValue(i, 'Name'), False) then begin
      TNTStringGrid1.Row := i;
      Exit;
    end;
  end;
end;


procedure TForm1.TNTStringGrid1DblClick(Sender: TObject);
begin
  PlayAudio;
end;


procedure TForm1.PopupMenu1Popup(Sender: TObject);
begin
  PopupMenu1.Items[4].Items[1].Visible := True;
  PopupMenu1.Items[6].Visible := True;
  PopupMenu1.Items[7].Visible := True;
  PopupMenu1.Items[8].Visible := True;

  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;

  if Length(DynamicData.GetValueArrayByte(TNTStringGrid1.Row, 'Memory')) <= 0 then begin
    PopupMenu1.Items[4].Items[1].Visible := True;
    PopupMenu1.Items[6].Visible := True;
    PopupMenu1.Items[7].Visible := True;
    PopupMenu1.Items[8].Visible := False;
  end else begin
    PopupMenu1.Items[8].Visible := True;
    PopupMenu1.Items[4].Items[1].Visible := False;
    PopupMenu1.Items[6].Visible := False;
    PopupMenu1.Items[7].Visible := False;
  end;
end;


procedure TForm1.MoveUp1Click(Sender: TObject);
var
  i: Integer;
begin
  if TNTStringGrid1.Row = CountFavorites then Exit;
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;
  i := TNTStringGrid1.Row;

  DynamicData.MoveData(i, i-1);
  BuildList;
  TNTStringGrid1.Row := i-1;
end;


procedure TForm1.MoveDown1Click(Sender: TObject);
var
  i: Integer;
begin
  if TNTStringGrid1.Row = CountFavorites-1 then Exit;
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;
  i := TNTStringGrid1.Row;

  DynamicData.MoveData(i, i+1);
  BuildList;
  TNTStringGrid1.Row := i+1;
end;


procedure TForm1.MoveTo1Click(Sender: TObject);
var
  Index: String;
  Favorite: Boolean;
  i: Integer;
begin
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;

  Favorite := DynamicData.GetValue(TNTStringGrid1.Row, 'Favorite');
  Index := Trim(WideInputBox('Move To', 'Position:', IntToStr(TNTStringGrid1.Row+1), Form1.Font));
  if (Index = '') or (Index = IntToStr(TNTStringGrid1.Row+1)) then Exit;
  for i := 1 to Length(Index) do if not (Index[i] in ['0'..'9']) then Exit;
  if (StrToInt(Index) <= 0) or (StrToInt(Index) > TNTStringGrid1.RowCount) then Exit;

  if Favorite then begin
    if StrToInt(Index) > CountFavorites then Exit;
  end else begin
    if StrToInt(Index) <= CountFavorites then Exit;
  end;

  DynamicData.MoveData(TNTStringGrid1.Row, StrToInt(Index)-1);
  BuildList;
  TNTStringGrid1.Row := StrToInt(Index)-1;
end;


procedure TForm1.ChangeName1Click(Sender: TObject);
var
  CurrentName, NewName: WideString;
  i: Integer;
begin
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;

  i := TNTStringGrid1.Row;
  CurrentName := DynamicData.GetValue(i, 'Name');
  NewName := WideInputBox('Change Name', 'Name:', CurrentName, Form1.Font);
  NewName := Trim(TNT_WideStringReplace(NewName, '*', '', [rfReplaceAll, rfIgnoreCase]));
  if NewName = '' then Exit;
  DynamicData.SetValue(i, 'Name', NewName);
  TNTStringGrid1.Cells[TNTStringGrid1.Col, i] := TNT_WideStringReplace(TNTStringGrid1.Cells[TNTStringGrid1.Col, i], CurrentName, NewName, [rfReplaceAll, rfIgnoreCase]);
end;


procedure TForm1.Favorite1Click(Sender: TObject);
var
  i: Integer;
  Favorite: Boolean;
begin
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;
  Favorite := DynamicData.GetValue(TNTStringGrid1.Row, 'Favorite');
  i := CountFavorites - Integer(Favorite);

  DynamicData.MoveData(TNTStringGrid1.Row, i);
  DynamicData.SetValue(i, 'Favorite', not Favorite);
  BuildList;
  TNTStringGrid1.Row := i;
end;


procedure TForm1.FromList1Click(Sender: TObject);
var
  Key: Word;
begin
  Key := VK_DELETE;
  TNTStringGrid1KeyDown(nil, Key, []);
end;


procedure TForm1.FromListFile1Click(Sender: TObject);
var
  buttonSelected: Integer;
  Key: Word;
  FileName: WideString;
begin
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;
  buttonSelected := MessageDlg('Delete', mtConfirmation, [mbYes, mbNo], 0);

  if buttonSelected = mrYes then begin
    Key := VK_DELETE;
    FileName := DynamicData.GetValue(TNTStringGrid1.Row, 'FileName');
    TNTStringGrid1KeyDown(nil, Key, []);
    DeleteFileW(PWideChar(FileName));
  end;
end;


procedure TForm1.Location1Click(Sender: TObject);
var
  Location: WideString;
begin
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;
  Location := WideExtractFileDir(DynamicData.GetValue(TNTStringGrid1.Row, 'FileName'));
  ShellExecuteW(Handle, 'open', PWideChar(Location), nil, nil, SW_SHOW);
end;


procedure TForm1.ConvertToMemory1Click(Sender: TObject);
var
  FileName, Name: WideString;
  MemoryStream: TTNTMemoryStream;
  Memory: TArrayOfByte;
begin
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;
  StopAudio;

  FileName := DynamicData.GetValue(TNTStringGrid1.Row, 'FileName');

  if DynamicData.GetSize+GetFileSize(FileName) >= MAXIMUM_SIZE then begin
    MessageBeep(MB_ICONEXCLAMATION);
    ShowMessage('The maximum size has been reached ' + FormatSize(MAXIMUM_SIZE, 0) + '.');
    Exit;
  end;

  MemoryStream := TTNTMemoryStream.Create;
  MemoryStream.LoadFromFile(FileName);
  MemoryStream.Position := 0;
  SetLength(Memory, MemoryStream.Size);
  MemoryStream.Read(Memory[0], MemoryStream.Size);
  MemoryStream.Free;

  DynamicData.SetValueArrayByte(TNTStringGrid1.Row, 'Memory', Memory);
  DynamicData.SetValue(TNTStringGrid1.Row, 'FileName', '');
  DynamicData.SetValue(TNTStringGrid1.Row, 'Exstension', WideLowerCase(WideExtractFileExt(FileName)));

  Name := TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row];
  TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] := Name + ' [MEM]';
end;


procedure TForm1.ConvertToFile1Click(Sender: TObject);
var
  i: Integer;
  Name, Exstension: WideString;
  Memory: TArrayOfByte;
  TNTSaveDialog: TTNTSaveDialog;
begin
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;
  StopAudio;

  i := TNTStringGrid1.Row;
  Name := DynamicData.GetValue(i, 'Name');
  Exstension := DynamicData.GetValue(i, 'Exstension');
  Memory := DynamicData.GetValueArrayByte(i, 'Memory');

  TNTSaveDialog := TTNTSaveDialog.Create(nil);
  TNTSaveDialog.FileName := Name;
  TNTSaveDialog.Filter := AnsiUpperCase(Copy(Exstension, 2, Length(Exstension))) + ' File|*' + Exstension;
  TNTSaveDialog.Options := [ofHideReadOnly, ofEnableSizing];
  TNTSaveDialog.Title := 'Soundboard: Save Sound';

  if TNTSaveDialog.Execute then begin
    if Pos('.', TNTSaveDialog.FileName) <= 0 then TNTSaveDialog.FileName := WideChangeFileExt(TNTSaveDialog.FileName, Exstension);
    SaveByteArray_var(Memory, TNTSaveDialog.FileName);

    DynamicData.SetValue(i, 'FileName', TNTSaveDialog.FileName);
    DynamicData.SetValue(i, 'Exstension', WideLowerCase(WideExtractFileExt(TNTSaveDialog.FileName)));
    DynamicData.SetValueArrayByte(i, 'Memory', nil);

    Name := TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row];
    Name := TNT_WideStringReplace(Name, ' [MEM]', '', [rfReplaceAll, rfIgnoreCase]);
    TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] := Name;
  end;
end;


procedure TForm1.MakeaCopyToFile1Click(Sender: TObject);
var
  i: Integer;
  FileName: WideString;
  Name, Exstension: WideString;
  Memory: TArrayOfByte;
  TNTSaveDialog: TTNTSaveDialog;
begin
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;

  i := TNTStringGrid1.Row;
  FileName := DynamicData.GetValue(i, 'FileName');
  Name := DynamicData.GetValue(i, 'Name');
  Exstension := DynamicData.GetValue(i, 'Exstension');
  Memory := DynamicData.GetValueArrayByte(i, 'Memory');

  TNTSaveDialog := TTNTSaveDialog.Create(nil);
  TNTSaveDialog.FileName := Name;
  TNTSaveDialog.Filter := AnsiUpperCase(Copy(Exstension, 2, Length(Exstension))) + ' File|*' + Exstension;
  TNTSaveDialog.Options := [ofHideReadOnly, ofEnableSizing];
  TNTSaveDialog.Title := 'Soundboard: Save Sound';

  if TNTSaveDialog.Execute then begin
    if Pos('.', TNTSaveDialog.FileName) <= 0 then TNTSaveDialog.FileName := WideChangeFileExt(TNTSaveDialog.FileName, Exstension);

    if Length(Memory) > 0
      then SaveByteArray_var(Memory, TNTSaveDialog.FileName)
      else CopyFileW(PWideChar(FileName), PWideChar(TNTSaveDialog.FileName), False);
  end;
end;


procedure TForm1.Image1Click(Sender: TObject);
begin
  PlayAudio;
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Image1.Picture.Assign(nil);
  BitBlt(Image1.Canvas.Handle, 0, 0, 25, 25, PlayBitmap.Canvas.Handle, 25, 0, SRCCOPY);
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Image1.Picture.Assign(nil);
  BitBlt(Image1.Canvas.Handle, 0, 0, 25, 25, PlayBitmap.Canvas.Handle, 0, 0, SRCCOPY);
end;


procedure TForm1.Image2Click(Sender: TObject);
begin
  PauseAudio;
end;

procedure TForm1.Image2MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Image2.Picture.Assign(nil);
  BitBlt(Image2.Canvas.Handle, 0, 0, 25, 25, PauseBitmap.Canvas.Handle, 25, 0, SRCCOPY);
end;

procedure TForm1.Image2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Image2.Picture.Assign(nil);
  BitBlt(Image2.Canvas.Handle, 0, 0, 25, 25, PauseBitmap.Canvas.Handle, 0, 0, SRCCOPY);
end;


procedure TForm1.Image3Click(Sender: TObject);
begin
  StopAudio;
end;

procedure TForm1.Image3MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Image3.Picture.Assign(nil);
  BitBlt(Image3.Canvas.Handle, 0, 0, 25, 25, StopBitmap.Canvas.Handle, 25, 0, SRCCOPY);
end;

procedure TForm1.Image3MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Image3.Picture.Assign(nil);
  BitBlt(Image3.Canvas.Handle, 0, 0, 25, 25, StopBitmap.Canvas.Handle, 0, 0, SRCCOPY);
end;


procedure TForm1.TrackBar1Change(Sender: TObject);
var
  Percent: Integer;
begin
  if Assigned(AudioPlay1) then begin
    if TrackBar1.Position = TrackBar1.Min
      then AudioPlay1.Volume := cbAudioPlay_MIN_VOLUME
      else AudioPlay1.Volume := TrackBar1.Position;
  end;

  Percent :=  100 - (Round(TrackBar1.Position/DECREASE_MINIMUM_PERCENT)*-1);
  TrackBar1.Hint := 'Volume: ' + IntToStr(Percent);

  if Percent > 70 then begin
    Image4.Picture.Assign(nil);
    BitBlt(Image4.Canvas.Handle, 0, 0, 16, 16, MicrophoneBitmap.Canvas.Handle, 0, 0, SRCCOPY);
    Exit;
  end;

  if (Percent < 70) and (Percent >= 35) then begin
    Image4.Picture.Assign(nil);
    BitBlt(Image4.Canvas.Handle, 0, 0, 16, 16, MicrophoneBitmap.Canvas.Handle, 16, 0, SRCCOPY);
    Exit;
  end;

  if (Percent < 35) and (Percent >= 1) then begin
    Image4.Picture.Assign(nil);
    BitBlt(Image4.Canvas.Handle, 0, 0, 16, 16, MicrophoneBitmap.Canvas.Handle, 32, 0, SRCCOPY);
    Exit;
  end;

  if Percent = 0 then begin
    Image4.Picture.Assign(nil);
    BitBlt(Image4.Canvas.Handle, 0, 0, 16, 16, MicrophoneBitmap.Canvas.Handle, 48, 0, SRCCOPY);
    Exit;
  end;
end;


procedure TForm1.TrackBar2Change(Sender: TObject);
var
  Percent: Integer;
begin
  if Assigned(AudioPlay2) then begin
    if TrackBar2.Position = TrackBar2.Min
      then AudioPlay2.Volume := cbAudioPlay_MIN_VOLUME
      else AudioPlay2.Volume := TrackBar2.Position;
  end;

  Percent :=  100 - (Round(TrackBar2.Position/DECREASE_MINIMUM_PERCENT)*-1);
  TrackBar2.Hint := 'Volume: ' + IntToStr(Percent);

  if Percent > 70 then begin
    Image5.Picture.Assign(nil);
    BitBlt(Image5.Canvas.Handle, 0, 0, 16, 16, MicrophoneBitmap.Canvas.Handle, 0, 0, SRCCOPY);
    Exit;
  end;

  if (Percent < 70) and (Percent >= 35) then begin
    Image5.Picture.Assign(nil);
    BitBlt(Image5.Canvas.Handle, 0, 0, 16, 16, MicrophoneBitmap.Canvas.Handle, 16, 0, SRCCOPY);
    Exit;
  end;

  if (Percent < 35) and (Percent >= 1) then begin
    Image5.Picture.Assign(nil);
    BitBlt(Image5.Canvas.Handle, 0, 0, 16, 16, MicrophoneBitmap.Canvas.Handle, 32, 0, SRCCOPY);
    Exit;
  end;

  if Percent = 0 then begin
    Image5.Picture.Assign(nil);
    BitBlt(Image5.Canvas.Handle, 0, 0, 16, 16, MicrophoneBitmap.Canvas.Handle, 48, 0, SRCCOPY);
    Exit;
  end;
end;


procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if Assigned(AudioPlay1) then AudioPlay1.Loop := CheckBox1.Checked;
  if Assigned(AudioPlay2) then AudioPlay2.Loop := CheckBox1.Checked;
end;


procedure TForm1.Panel1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Timer1.Enabled := True;
end;


procedure TForm1.Panel1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Timer1.Enabled := False;
end;


procedure TForm1.Timer1Timer(Sender: TObject);
var
  Point: TPoint;
  FormHeight: Integer;
  NewTop: Integer;
begin
  GetCursorPos(Point);
  FormHeight := Point.Y - Form1.Top + 5;
  if FormHeight < MINIMUM_FORM_HEIGHT then Exit;

  Form1.Height := FormHeight;
  Panel1.Top := Form1.Height-51;
  TNTStringGrid1.Height := Form1.Height - TNTStringGrid1.Top - 55;
  ItemsPerPage := Trunc(TNTStringGrid1.Height/(TNTStringGrid1.DefaultRowHeight + TNTStringGrid1.GridLineWidth));
  Scroll.Height := TNTStringGrid1.Height-2;
  Scroll.PageSize := ItemsPerPage;

  if TNTStringGrid1.TopRow + ItemsPerPage > DynamicData.GetLength then begin
    NewTop := DynamicData.GetLength-ItemsPerPage;
    if NewTop < 0 then NewTop := 0;
    TNTStringGrid1.TopRow := NewTop;
    Scroll.Position := TNTStringGrid1.TopRow;
  end;

  if ItemsPerPage < DynamicData.GetLength
    then Scroll.Visible := True
    else Scroll.Visible := False;
end;


procedure TForm1.Timer2Timer(Sender: TObject);
begin
  if GetKeyState(VK_NUMLOCK) <> 1 then begin
    keybd_event(VK_NUMLOCK, 0, 0, 0);
    keybd_event(VK_NUMLOCK, 0, 2, 0);
  end;
end;


procedure TForm1.TNTStringGrid1MouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
  i: Integer;
begin
  for i := 1 to SCROLL_BY do begin
    if (TNTStringGrid1.RowCount - TNTStringGrid1.TopRow) > ItemsPerPage then begin
      TNTStringGrid1.TopRow := TNTStringGrid1.TopRow+1;
      Scroll.Position := TNTStringGrid1.TopRow;
    end;
  end;

  AllowSelect := False;
end;


procedure TForm1.TNTStringGrid1MouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
  i: Integer;
begin
  for i := 1 to SCROLL_BY do begin
    if TNTStringGrid1.TopRow <> 0 then begin
      TNTStringGrid1.TopRow := TNTStringGrid1.TopRow-1;
      Scroll.Position := TNTStringGrid1.TopRow;
    end;
  end;


  AllowSelect := False;
end;


procedure TForm1.TNTStringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  CanSelect := False;
  CanSelect := AllowSelect;
  AllowSelect := True;

  if CanSelect then begin
    if ARow < TNTStringGrid1.TopRow then begin
      Scroll.Position := ARow;
      TNTStringGrid1.Repaint;
      Scroll.Repaint;
    end;

    if ARow > (TNTStringGrid1.TopRow + ItemsPerPage - 1) then begin
      Scroll.Position := ARow - (ItemsPerPage - 1);
      TNTStringGrid1.Repaint;
      Scroll.Repaint;
    end;
  end;

  if not (GetKeyState(VK_LBUTTON) < 0) then Exit; //This used to cancel second event when button gets released
  Mouse_Event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0); //Release mouse button so event doesn't happen infinite times
end;


procedure TForm1.ChangeVertical(Sender: TObject);
begin
  TNTStringGrid1.TopRow := Scroll.Position;
end;


procedure TForm1.TNTStringGrid1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if not TNTStringGrid1.Focused then TNTStringGrid1.SetFocus;
end;


function TForm1.SelectFromInput: Boolean;
begin
  Result := True;

  if StaticText1.Caption <> '' then begin
    if (StrToInt(StaticText1.Caption) > 0) and (StrToInt(StaticText1.Caption) <= TNTStringGrid1.RowCount) then begin
      TNTStringGrid1.Row := StrToInt(StaticText1.Caption)-1;
      StaticText1.Caption := '';
    end else begin
      StaticText1.Caption := '';
      Result := False;
    end;
  end;
end;


procedure TForm1.TNTStringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  TNTStringGrid1.Canvas.Font.Name := TNTStringGrid1.Font.Name;
  TNTStringGrid1.Canvas.Font.Size := TNTStringGrid1.Font.Size;

  if gdFixed in State then begin
    TNTStringGrid1.Canvas.Brush.Color := FLAT_STYLE_DOWN_COLOR;
    TNTStringGrid1.Canvas.Font.Color := clBlack;
  end else
  if gdSelected in State then begin
    TNTStringGrid1.Canvas.Brush.Color := FLAT_STYLE_BLUE;
    TNTStringGrid1.Canvas.Font.Color := clWhite;
  end else begin
    TNTStringGrid1.Canvas.Brush.Color := $00FFFFFF;
    TNTStringGrid1.Canvas.Font.Color := clBlack;
  end;

  TNTStringGrid1.Canvas.FillRect(Rect);
  WideCanvasTextOut(TNTStringGrid1.Canvas, Rect.Left+3, Rect.Top+2, TNTStringGrid1.Cells[ACol,ARow]);
end;


procedure HotKeyCallback(Key, ShortCut: Integer; CustomValue: Variant);
var
  CloseAction: TCloseAction;
  Handled: Boolean;
  Name: WideString;
  i: Integer;
begin
  for i := 0 to Length(HotKeys)-1 do begin
    if HotKeys[i].Key = Key then Name := HotKeys[i].Name;
  end;

  if (Name = 'PLAY_AUDIO') and Form1.SelectFromInput then Form1.PlayAudio; //PLAY_AUDIO
  if (Name = 'STOP_AUDIO') then Form1.StopAudio; //STOP_AUDIO
  if (Name = 'PAUSE_RESUME') then Form1.PauseAudio; //PAUSE_RESUME
  if (Name = 'LOOP_AUDIO') then Form1.CheckBox1.Checked := not Form1.CheckBox1.Checked; //LOOP_AUDIO

  //INCREASE_SOUND_ALL
  if (Name = 'INCREASE_AUDIO_ALL') then begin
    if Form1.TrackBar1.Position <> Form1.TrackBar1.Max then Form1.TrackBar1.Position := Form1.TrackBar1.Position + Round((Form1.TrackBar1.Min/20) * -1);
    if Form1.TrackBar2.Position <> Form1.TrackBar1.Max then Form1.TrackBar2.Position := Form1.TrackBar2.Position + Round((Form1.TrackBar2.Min/20) * -1);
  end;

  //INCREASE_SOUND_PRIMARY
  if (Name = 'INCREASE_AUDIO_PRIMARY') then begin
    if Form1.TrackBar1.Position <> Form1.TrackBar1.Max then Form1.TrackBar1.Position := Form1.TrackBar1.Position + Round((Form1.TrackBar1.Min/20) * -1);
  end;

  //DECREASE_SOUND_ALL
  if (Name = 'DECREASE_AUDIO_ALL') then begin
    if Form1.TrackBar1.Position <> Form1.TrackBar1.Min then Form1.TrackBar1.Position := Form1.TrackBar1.Position + Round(Form1.TrackBar1.Min/20);
    if Form1.TrackBar2.Position <> Form1.TrackBar1.Min then Form1.TrackBar2.Position := Form1.TrackBar2.Position + Round(Form1.TrackBar2.Min/20);
  end;

  //DECREASE_SOUND_PRIMARY
  if (Name = 'DECREASE_AUDIO_PRIMARY') then begin
    if Form1.TrackBar1.Position <> Form1.TrackBar1.Min then Form1.TrackBar1.Position := Form1.TrackBar1.Position + Round(Form1.TrackBar1.Min/20);
  end;

  if (Name = 'CLEAR_INPUT') then Form1.StaticText1.Caption := ''; //CLEAR_INPUT
  if (Name = 'SELECT_INPUT') then Form1.SelectFromInput; //SELECT_INPUT

  //SCROLL_UP
  if (Name = 'SCROLL_UP') then begin
    Form1.TNTStringGrid1MouseWheelUp(Form1.TNTStringGrid1, [], Point(0,0), Handled);
    AllowSelect := True;
    Exit;
  end;

  //SCROLL_DOWN
  if (Name = 'SCROLL_DOWN') then begin
    Form1.TNTStringGrid1MouseWheelDown(Form1.TNTStringGrid1, [], Point(0,0), Handled);
    AllowSelect := True;
    Exit;
  end;

  //CLOSE_APPLICATION
  if (Name = 'CLOSE_APPLICATION') then begin
    CloseAction := Forms.caNone;
    Form1.FormClose(nil, CloseAction);
    TerminateProcess(OpenProcess(PROCESS_TERMINATE, False, GetCurrentProcessId), 0);
  end;

  //All numbers
  if (Name = 'NUMBER_0') and (Length(Form1.StaticText1.Caption) < MAXIMUM_INPUT_LENGTH) then Form1.StaticText1.Caption := Form1.StaticText1.Caption + '0';
  if (Name = 'NUMBER_1') and (Length(Form1.StaticText1.Caption) < MAXIMUM_INPUT_LENGTH) then Form1.StaticText1.Caption := Form1.StaticText1.Caption + '1';
  if (Name = 'NUMBER_2') and (Length(Form1.StaticText1.Caption) < MAXIMUM_INPUT_LENGTH) then Form1.StaticText1.Caption := Form1.StaticText1.Caption + '2';
  if (Name = 'NUMBER_3') and (Length(Form1.StaticText1.Caption) < MAXIMUM_INPUT_LENGTH) then Form1.StaticText1.Caption := Form1.StaticText1.Caption + '3';
  if (Name = 'NUMBER_4') and (Length(Form1.StaticText1.Caption) < MAXIMUM_INPUT_LENGTH) then Form1.StaticText1.Caption := Form1.StaticText1.Caption + '4';
  if (Name = 'NUMBER_5') and (Length(Form1.StaticText1.Caption) < MAXIMUM_INPUT_LENGTH) then Form1.StaticText1.Caption := Form1.StaticText1.Caption + '5';
  if (Name = 'NUMBER_6') and (Length(Form1.StaticText1.Caption) < MAXIMUM_INPUT_LENGTH) then Form1.StaticText1.Caption := Form1.StaticText1.Caption + '6';
  if (Name = 'NUMBER_7') and (Length(Form1.StaticText1.Caption) < MAXIMUM_INPUT_LENGTH) then Form1.StaticText1.Caption := Form1.StaticText1.Caption + '7';
  if (Name = 'NUMBER_8') and (Length(Form1.StaticText1.Caption) < MAXIMUM_INPUT_LENGTH) then Form1.StaticText1.Caption := Form1.StaticText1.Caption + '8';
  if (Name = 'NUMBER_9') and (Length(Form1.StaticText1.Caption) < MAXIMUM_INPUT_LENGTH) then Form1.StaticText1.Caption := Form1.StaticText1.Caption + '9';
end;


initialization
  SettingsDB.Device1 := 'Default';
  SettingsDB.Device2 := 'Disabled';
  SettingsDB.FormHeight := 0;
  SettingsDB.AlwaysNumLock := True;
  SettingsDB.StayOnTop := False;
  SettingsDB.SaveInMemory := False;
end.
