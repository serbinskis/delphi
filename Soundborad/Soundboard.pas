unit Soundboard;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls, Grids, Menus, Variants,
  ShellAPI, Registry, TNTDialogs, TNTClasses, TNTSysUtils, TNTGrids, TNTGraphics, XiTrackBar, TFlatCheckBoxUnit,
  TFlatPanelUnit, ATScrollBar, DirectShow, cbAudioPlay, uKBDynamic, ZipForge, uHotKey, WinXP, Functions;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Settings1: TMenuItem;
    TNTStringGrid1: TTntStringGrid;
    PopupMenu1: TPopupMenu;
    ChangeName1: TMenuItem;
    MoveUp1: TMenuItem;
    MoveDown1: TMenuItem;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Open1: TMenuItem;
    Image5: TImage;
    Favorite1: TMenuItem;
    Delete1: TMenuItem;
    Location1: TMenuItem;
    Timer1: TTimer;
    Timer2: TTimer;
    Panel1: TPanel;
    MoveTo1: TMenuItem;
    FromList1: TMenuItem;
    FromListFile1: TMenuItem;
    Export1: TMenuItem;
    Import1: TMenuItem;
    ConvertToMemory1: TMenuItem;
    ConvertToFile1: TMenuItem;
    Tools1: TMenuItem;
    SaveInArchive1: TMenuItem;
    TrackBar1: TXiTrackBar;
    TrackBar2: TXiTrackBar;
    CheckBox1: TFlatCheckBox;
    Panel2: TFlatPanel;
    StaticText1: TStaticText;
    MakeaCopyToFile1: TMenuItem;
    About1: TMenuItem;
    AddFromYouTube1: TMenuItem;
    SaveCurrentState1: TMenuItem;
    ExitWithoutSave1: TMenuItem;
    procedure PlayAudio;
    procedure StopAudio;
    procedure PauseAudio;
    procedure TrackBar1Change(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TNTStringGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TNTStringGrid1DblClick(Sender: TObject);
    procedure MoveUp1Click(Sender: TObject);
    procedure MoveDown1Click(Sender: TObject);
    procedure MoveTo1Click(Sender: TObject);
    procedure Favorite1Click(Sender: TObject);
    procedure FromList1Click(Sender: TObject);
    procedure FromListFile1Click(Sender: TObject);
    procedure ChangeName1Click(Sender: TObject);
    procedure Location1Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image2Click(Sender: TObject);
    procedure Image2MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image3Click(Sender: TObject);
    procedure Image3MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image3MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Open1Click(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure TNTStringGrid1MouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure TNTStringGrid1MouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure TNTStringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure ChangeVertical(Sender: TObject);
    procedure Export1Click(Sender: TObject);
    procedure Import1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure ConvertToMemory1Click(Sender: TObject);
    procedure ConvertToFile1Click(Sender: TObject);
    procedure MakeaCopyToFile1Click(Sender: TObject);
    procedure SaveInArchive1Click(Sender: TObject);
    procedure TNTStringGrid1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure TNTStringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    function SelectFromInput: Boolean;
    procedure About1Click(Sender: TObject);
    procedure AddFromYouTube1Click(Sender: TObject);
    procedure SaveCurrentState1Click(Sender: TObject);
    procedure ExitWithoutSave1Click(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
  public
    { Public declarations }
  end;

type
  TMemory = array of byte;

  TAudio = record
    FileName: WideString;
    Name: WideString;
    Exstension: WideString;
    Favorite: Boolean;
    Memory: TMemory;
  end;

  TAudioList = array of TAudio;

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
    AudioTable: TAudioList;
  end;

const
  DECREASE_MINIMUM_PERCENT = 50;
  MAXIMUM_INPUT_LENGTH = 3;
  MAXIMUM_SIZE = 1024*1024*300;
  MINIMUM_FORM_HEIGHT = 300;
  DEFAULT_ROOT_KEY = HKEY_CURRENT_USER;
  DEFAULT_KEY = '\Software\Soundboard';
  DEFAULT_HOTKEY_KEY = '\Software\Soundboard\HotKeys';
  COL_WIDTH: array[0..1] of Integer = (30, 310);
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
  PlayBitmap: TBitmap;
  PauseBitmap: TBitmap;
  StopBitmap: TBitmap;
  MicrophoneBitmap: TBitmap;
  SettingsDB: TSettingsDB;
  AudioPlay1: TcbAudioPlay;
  AudioPlay2: TcbAudioPlay;
  ItemsPerPage: Integer;
  Scroll: TATScroll;
  AllowSelect: Boolean = True;
  SearchString: WideString = '';

procedure HotKeyCallback(Key, ShortCut: Integer; CustomValue: Variant);
procedure InsertToList(var A: TAudioList; const Index: Integer; Name, FileName, Exstension: WideString; Favorite: Boolean; Memory: TMemory; NewFile: Boolean);
procedure BuildList(var A: TAudioList);
function CountMemory(var A: TAudioList): Int64;

implementation

uses Settings, Archiving, YouTube;

{$R *.dfm}

//LoadSettings
procedure LoadSettings;
var
  MemoryStream: TMemoryStream;
  Registry: TRegistry;
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
  Registry := TRegistry.Create;
  Registry.RootKey := DEFAULT_ROOT_KEY;
  Registry.OpenKey(DEFAULT_KEY, True);

  if Registry.ValueExists('Soundboard') then begin
    MemoryStream := TMemoryStream.Create;
    MemoryStream.SetSize(Registry.GetDataSize('Soundboard'));
    Registry.ReadBinaryData('Soundboard', MemoryStream.Memory^, MemoryStream.Size);
    MemoryStream.Position := 0;

    try
      TKBDynamic.ReadFrom(MemoryStream, SettingsDB.AudioTable, TypeInfo(TAudioList), 1);
      MemoryStream.Free;
    except
      MessageBeep(MB_ICONEXCLAMATION);
      ShowMessage('There was an error loading playlist.' + #13#10 +
                  'Playlist may be corrupted or outdated.' + #13#10 +
                  'The playlist will be reset.');
      ZeroMemory(@SettingsDB.AudioTable, SizeOf(SettingsDB.AudioTable));
      SetLength(SettingsDB.AudioTable, 0);
      Registry.DeleteValue('Soundboard');
    end;
  end;

  Registry.Free;
end;
//LoadSettings


//SaveSettings
procedure SaveSettings;
var
  MemoryStream: TMemoryStream;
  lOptions: TKBDynamicOptions;
  Registry: TRegistry;
  i: Integer;
begin
  SaveRegistryString(SettingsDB.Device1, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'Device1');
  SaveRegistryString(SettingsDB.Device2, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'Device2');
  SaveRegistryInteger(SettingsDB.FormHeight, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'FormHeight');
  SaveRegistryBoolean(SettingsDB.AlwaysNumLock, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'AlwaysNumLock');
  SaveRegistryBoolean(SettingsDB.StayOnTop, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'StayOnTop');
  SaveRegistryBoolean(SettingsDB.SaveInMemory, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'SaveInMemory');

  lOptions := [
    kdoAnsiStringCodePage

    {$IFDEF KBDYNAMIC_DEFAULT_UTF8}
    ,kdoUTF16ToUTF8
    {$ENDIF}

    {$IFDEF KBDYNAMIC_DEFAULT_CPUARCH}
    ,kdoCPUArchCompatibility
    {$ENDIF}
  ];

  MemoryStream := TMemoryStream.Create;
  TKBDynamic.WriteTo(MemoryStream, SettingsDB.AudioTable, TypeInfo(TAudioList), 1, lOptions);
  MemoryStream.Position := 0;

  Registry := TRegistry.Create;
  Registry.RootKey := DEFAULT_ROOT_KEY;
  Registry.OpenKey(DEFAULT_KEY, True);
  Registry.WriteBinaryData('Soundboard', MemoryStream.Memory^, MemoryStream.Size);
  Registry.Free;
  MemoryStream.Free;

  for i := 0 to Length(HotKeys)-1 do begin
    SaveRegistryInteger(HotKeys[i].ShortCut, DEFAULT_ROOT_KEY, DEFAULT_HOTKEY_KEY, HotKeys[i].Name);
  end;
end;
//SaveSettings


//FormatNumber
function FormatNumber(Num: Integer): String;
var
  i: Integer;
begin
  Result := IntToStr(Num);

  for i := Length(IntToStr(Num)) to Length(IntToStr(Length(SettingsDB.AudioTable)))-1 do begin
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
  then Result := ComboBox.ItemIndex - 2;
end;
//FormatDevice


//DeleteFromList
procedure DeleteFromList(var A: TAudioList; const Index: Integer);
var
  i, ArrayLength: Integer;
begin
  Form1.StopAudio;
  ArrayLength := Length(A);

  if Index = ArrayLength-1 then begin
    SetLength(A, ArrayLength-1);
  end else begin
    for i := Index to Length(A)-2  do begin
      A[i].FileName := A[i+1].FileName;
      A[i].Name := A[i+1].Name;
      A[i].Exstension := A[i+1].Exstension;
      A[i].Favorite := A[i+1].Favorite;
      A[i].Memory := A[i+1].Memory;
    end;
    SetLength(A, ArrayLength-1);
  end;
end;
//DeleteFromList


//InsertToList
procedure InsertToList(var A: TAudioList; const Index: Integer; Name, FileName, Exstension: WideString; Favorite: Boolean; Memory: TMemory; NewFile: Boolean);
var
  i, ArrayLength: Integer;
  MemoryStream: TTNTMemoryStream;
begin
  ArrayLength := Length(A);
  SetLength(A, ArrayLength+1);

  for i := Length(A)-1 downto Index+1 do begin
    A[i].FileName := A[i-1].FileName;
    A[i].Name := A[i-1].Name;
    A[i].Exstension := A[i-1].Exstension;
    A[i].Favorite := A[i-1].Favorite;
    A[i].Memory := A[i-1].Memory;
  end;

  A[Index].FileName := FileName;
  A[Index].Name := Name;
  A[Index].Exstension := Exstension;
  A[Index].Favorite := Favorite;
  A[Index].Memory := nil;

  if Memory <> nil then begin
     A[Index].Memory := Memory;
  end else begin
    if (NewFile) and (SettingsDB.SaveInMemory) then begin
      MemoryStream := TTNTMemoryStream.Create;
      MemoryStream.LoadFromFile(FileName);
      MemoryStream.Position := 0;
      SetLength(A[Index].Memory, MemoryStream.Size);
      MemoryStream.Read(A[Index].Memory[0], MemoryStream.Size);
      MemoryStream.Free;

      A[Index].FileName := '';
    end;
  end;
end;
//InsertToList


//UpdateList
procedure UpdateList(var A: TAudioList);
var
  i: Integer;
begin
  Form1.StopAudio;
  for i := 0 to Length(A)-1 do begin
    if (not WideFileExists(A[i].FileName)) and (Length(A[i].Memory) <= 0) then begin
      WideShowMessage('File is missing and will be deleted from list:' + #13#10 + WideExtractFileName(A[i].FileName));
      DeleteFromList(SettingsDB.AudioTable, i);
      UpdateList(SettingsDB.AudioTable);
      Break;
    end;
  end;
end;
//UpdateList


//BuildList
procedure BuildList(var A: TAudioList);
var
  i: Integer;
begin
  if Length(A) > 0 then begin
    Form1.TNTStringGrid1.ColWidths[0] := COL_WIDTH[0];
    Form1.TNTStringGrid1.ColWidths[1] := COL_WIDTH[1];
    Form1.TNTStringGrid1.GridLineWidth := 1;
    Scroll.Max := Length(A);
  end else begin
    Form1.TNTStringGrid1.ColWidths[0] := 0;
    Form1.TNTStringGrid1.ColWidths[1] := 0;
    Form1.TNTStringGrid1.GridLineWidth := 0;

    Form1.TNTStringGrid1.Cols[0].Clear;
    Form1.TNTStringGrid1.Rows[0].Clear;
    Scroll.Visible := False;
    Exit;
  end;

  if ItemsPerPage < Length(A)
    then Scroll.Visible := True
    else Scroll.Visible := False;

  Form1.TNTStringGrid1.RowCount := Length(A);
  for i := 0 to Length(A)-1 do begin
    Form1.TNTStringGrid1.Cells[0, i] := IntToStr(i+1);
    if A[i].Favorite
      then Form1.TNTStringGrid1.Cells[1, i] := '* ' + A[i].Name
      else Form1.TNTStringGrid1.Cells[1, i] := A[i].Name;
    if Length(A[i].Memory) > 0
      then Form1.TNTStringGrid1.Cells[1, i] := Form1.TNTStringGrid1.Cells[1, i] + ' [MEM]';
  end;
end;
//BuildList


//CountFavorites
function CountFavorites(var A: TAudioList): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Length(A)-1 do begin
    if A[i].Favorite then Result := Result + 1;
  end;
end;
//CountFavorites


//CountMemory
function CountMemory(var A: TAudioList): Int64;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Length(A)-1 do begin
    Result := Result + Length(A[i].FileName);
    Result := Result + Length(A[i].Name);
    Result := Result + Length(A[i].Exstension);
    Result := Result + 1; //Favorite -> Boolean -> 1 Byte
    Result := Result + Length(A[i].Memory);
  end;
end;
//CountMemory


//ProcessFile
function ProcessFile(FileName: WideString): Integer;
var
  Name, Exstension: WideString;
  Favorite: Boolean;
  Size: Int64;
begin
    Result := 0;

    if Length(SettingsDB.AudioTable) >= 999 then begin
      MessageBeep(MB_ICONEXCLAMATION);
      ShowMessage('The limit of maximum sounds has been reached.');
      Result := -1;
      Exit;
    end;

    Size := CountMemory(SettingsDB.AudioTable);
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
      Favorite := False;
      InsertToList(SettingsDB.AudioTable, Length(SettingsDB.AudioTable), Name, FileName, Exstension, Favorite, nil, True);
      Result := 1;
    end;
end;
//ProcessFile


//PlayAudio
procedure TForm1.PlayAudio;
var
  FileName: WideString;
begin
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;
  FileName := SettingsDB.AudioTable[TNTStringGrid1.Row].FileName;

  Image2.Hint := 'Pause';
  StopAudio;

  if (not WideFileExists(FileName)) and (Length(SettingsDB.AudioTable[TNTStringGrid1.Row].Memory) <= 0) then begin
    MessageBeep(MB_ICONEXCLAMATION);
    WideShowMessage('File not found:' + #13#10 + SettingsDB.AudioTable[TNTStringGrid1.Row].Name);
    Exit;
  end;

  if (Length(SettingsDB.AudioTable[TNTStringGrid1.Row].Memory) > 0) then begin
    if not DirectoryExists(GetEnvironmentVariable('TEMP')) then CreateDir(GetEnvironmentVariable('TEMP'));
    FileName := GetEnvironmentVariable('TEMP') + '\' + RandomString(16, False) + SettingsDB.AudioTable[TNTStringGrid1.Row].Exstension;
    SaveByteArray(SettingsDB.AudioTable[TNTStringGrid1.Row].Memory, FileName);
  end;

  AudioPlay1 := TcbAudioPlay.Create(Self, FileName, FormatDevice(Form2.ComboBox1));
  AudioPlay2 := TcbAudioPlay.Create(Self, FileName, FormatDevice(Form2.ComboBox2));

  if (Length(SettingsDB.AudioTable[TNTStringGrid1.Row].Memory) > 0) then DeleteFileW(PWideChar(FileName));
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
  ShellExecute(0, 'open', 'https://wobbychip.github.io/', nil, nil, SW_SHOWMAXIMIZED);
end;


procedure TForm1.Export1Click(Sender: TObject);
var
  TNTSaveDialog: TTNTSaveDialog;
  MemoryStream: TTNTMemoryStream;
  lOptions: TKBDynamicOptions;
begin
  if Length(SettingsDB.AudioTable) <= 0 then begin
    ShowMessage('Cannot export empty playlist.');
    Exit;
  end;

  TNTSaveDialog := TTNTSaveDialog.Create(nil);
  TNTSaveDialog.Filter := 'PLAYLIST Files|*.playlist';
  TNTSaveDialog.Options := [ofHideReadOnly, ofEnableSizing];
  TNTSaveDialog.Title := 'Soundboard: Export Playlist';

  if TNTSaveDialog.Execute then begin
    if Pos('.', TNTSaveDialog.FileName) <= 0 then TNTSaveDialog.FileName := WideChangeFileExt(TNTSaveDialog.FileName, '.playlist');

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
    TKBDynamic.WriteTo(MemoryStream, SettingsDB.AudioTable, TypeInfo(TAudioList), 1, lOptions);

    if MemoryStream.Size > MAXIMUM_SIZE then begin
      MemoryStream.Free;
      ShowMessage('Cannot export file bigger than ' + FormatSize(MAXIMUM_SIZE, 0) + '.');
      Exit;
    end;

    MemoryStream.Position := 0;
    MemoryStream.SaveToFile(TNTSaveDialog.FileName);
    MemoryStream.Free;

    ShowMessage('Playlist exported.');
  end;
end;


procedure TForm1.Import1Click(Sender: TObject);
var
  AudioList: TAudioList;
  TNTOpenDialog: TTNTOpenDialog;
  MemoryStream: TTNTMemoryStream;
  srSearch: TWIN32FindDataW;
  FileSize: Int64;
begin
  TNTOpenDialog := TTNTOpenDialog.Create(nil);
  TNTOpenDialog.Filter := 'PLAYLIST Files|*.playlist';
  TNTOpenDialog.Options := [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing];
  TNTOpenDialog.Title := 'Soundboard: Import Playlist';

  if TNTOpenDialog.Execute then begin
    FindFirstFileW(PWideChar(TNTOpenDialog.FileName), srSearch);
    FileSize := (srSearch.nFileSizeHigh * 4294967296) + srSearch.nFileSizeLow;

    if FileSize > MAXIMUM_SIZE then begin
      ShowMessage('Cannot import file bigger than ' + FormatSize(MAXIMUM_SIZE, 0) + '.');
      Exit;
    end;

    MemoryStream := TTNTMemoryStream.Create;
    MemoryStream.LoadFromFile(TNTOpenDialog.FileName);
    MemoryStream.Position := 0;

    TKBDynamic.ReadFrom(MemoryStream, AudioList, TypeInfo(TAUdioList), 1);
    MemoryStream.Free;

    if Length(AudioList) <= 0 then begin
      ShowMessage('There was an error importing playlist.');
      Exit;
    end;

    SetLength(SettingsDB.AudioTable, 0);
    SettingsDB.AudioTable := AudioList;
    UpdateList(SettingsDB.AudioTable);
    BuildList(SettingsDB.AudioTable);
    TNTStringGrid1.Row := 0;
    Scroll.Position := 0;

    ShowMessage('Playlist imported.');
  end;
end;


procedure TForm1.SaveInArchive1Click(Sender: TObject);
var
  i: Integer;
  Name, FileName: WideString;
  FileStream: TTNTFileStream;
  ZipArchive: TZipForge;
  TNTSaveDialog: TTNTSaveDialog;
begin
  if Length(SettingsDB.AudioTable) <= 0 then begin
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

    for i := 0 to Length(SettingsDB.AudioTable)-1  do begin
      if (Length(SettingsDB.AudioTable[i].Memory) > 0) then begin
        Name := WideChangeFileExt(SettingsDB.AudioTable[i].Name, SettingsDB.AudioTable[i].Exstension);
        ZipArchive.AddFromBuffer(FormatNumber(i+1) + ' - ' + Name, SettingsDB.AudioTable[i].Memory[0], Length(SettingsDB.AudioTable[i].Memory));
      end else begin
        FileName := SettingsDB.AudioTable[i].FileName;
        Name := FormatNumber(i+1) + ' - ' + WideExtractFileName(FileName);
        FileStream := TTNTFileStream.Create(FileName, fmOpenRead);
        ZipArchive.AddFromStream(Name, FileStream);
        FileStream.Free;
      end;

      Form3.ProgressBar1.Position := Round((i+1)/Length(SettingsDB.AudioTable)*100);
      Form3.StaticText1.Caption := IntToStr(Round((i+1)/Length(SettingsDB.AudioTable)*100)) + '%';
    end;

    Form3.ProgressBar1.Position := 100;
    Form3.StaticText1.Caption := '100%';
    Wait(300);

    Form3.Hide;
    Form1.Enabled := True;
    ZipArchive.CloseArchive;
  end;
end;


procedure TForm1.AddFromYouTube1Click(Sender: TObject);
begin
  Form4.ShowModal;
end;


procedure TForm1.SaveCurrentState1Click(Sender: TObject);
begin
  SaveSettings;
  ShowMessage('Saved current state.');
end;


procedure TForm1.ExitWithoutSave1Click(Sender: TObject);
begin
  //Heck it I am just too lazy to do it properly
  TerminateProcess(OpenProcess(PROCESS_TERMINATE, False, GetCurrentProcessId), 0);
end;


procedure TForm1.FormShow(Sender: TObject);
var
  i: Integer;
begin
  DragAcceptFiles(Handle, True);
  TNTStringGrid1.SetFocus;
  LoadSettings;

  Form2.CheckBox1.Checked := SettingsDB.AlwaysNumLock;
  Timer2.Enabled := SettingsDB.AlwaysNumLock;

  if SettingsDB.StayOnTop then SetWindowPos(Handle, HWND_TOPMOST, 0,0,0,0, SWP_NOMOVE or SWP_NOSIZE);
  Form2.CheckBox2.Checked := SettingsDB.StayOnTop;
  Form2.CheckBox3.Checked := SettingsDB.SaveInMemory;

  if SettingsDB.FormHeight <> 0 then begin
    Form1.Height := SettingsDB.FormHeight;
  end;

  Panel1.Width := Form1.Width;
  Panel1.Top := Form1.Height - 51;
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
  Scroll.Height := TNTStringGrid1.Height - 2;
  Scroll.Top := TNTStringGrid1.Top + 1;
  Scroll.Left := TNTStringGrid1.Width - (Scroll.Width div 2) - 1;
  Scroll.PageSize := ItemsPerPage;

  UpdateList(SettingsDB.AudioTable);
  BuildList(SettingsDB.AudioTable);

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
    Len := DragQueryFileW(hDrop, i, nil, 0) + 1;
    SetLength(FileName, Len);
    DragQueryFileW(hDrop, i, Pointer(FileName), Len);
    FileName := Trim(FileName);

    Res := ProcessFile(FileName);
    if Res = -1 then Break;
    if Res = 1 then Inc(Count);
  end;

  if Count > 0 then begin
    BuildList(SettingsDB.AudioTable);
    TNTStringGrid1.Row := Length(SettingsDB.AudioTable)-1;
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

    BuildList(SettingsDB.AudioTable);
    TNTStringGrid1.Row := Length(SettingsDB.AudioTable)-1;
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
    i := TNTStringGrid1.Row;
    DeleteFromList(SettingsDB.AudioTable, i);
    BuildList(SettingsDB.AudioTable);
    if i <= TNTStringGrid1.RowCount - 1 then TNTStringGrid1.Row := i
    else TNTStringGrid1.Row := TNTStringGrid1.RowCount - 1;
    Scroll.Position := TNTStringGrid1.TopRow - 1;
    Exit;
  end;

  if (Key = Ord('F')) and (Shift = [ssCtrl]) then begin
    SearchString := WideInputBox('Find', 'Find what:', '', Form1.Font);
    if SearchString <> '' then Key := VK_F3;
  end;

  if (Key <> VK_F3) or (SearchString = '') then Exit;
  Form1.Caption := SearchString;

  for i := TNTStringGrid1.Row+1 to Length(SettingsDB.AudioTable)-1 do begin
    if WideContainsString(SearchString, SettingsDB.AudioTable[i].Name, False) then begin
      TNTStringGrid1.Row := i;
      Exit;
    end;
  end;

  for i := 0 to TNTStringGrid1.Row-1 do begin
    if WideContainsString(SearchString, SettingsDB.AudioTable[i].Name, False) then begin
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

  if Length(SettingsDB.AudioTable[TNTStringGrid1.Row].Memory) <= 0 then begin
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
  FileName, Name, Exstension: WideString;
  Favorite: Boolean;
  Memory: TMemory;
  i: Integer;
begin
  if TNTStringGrid1.Row = CountFavorites(SettingsDB.AudioTable) then Exit;
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;

  i := TNTStringGrid1.Row;
  FileName := SettingsDB.AudioTable[i].FileName;
  Name := SettingsDB.AudioTable[i].Name;
  Exstension := SettingsDB.AudioTable[i].Exstension;
  Favorite := SettingsDB.AudioTable[i].Favorite;
  Memory := SettingsDB.AudioTable[i].Memory;

  DeleteFromList(SettingsDB.AudioTable, i);
  InsertToList(SettingsDB.AudioTable, i-1, Name, FileName, Exstension, Favorite, Memory, False);
  BuildList(SettingsDB.AudioTable);
  TNTStringGrid1.Row := i-1;
end;


procedure TForm1.MoveDown1Click(Sender: TObject);
var
  FileName, Name, Exstension: WideString;
  Favorite: Boolean;
  Memory: TMemory;
  i: Integer;
begin
  if TNTStringGrid1.Row = CountFavorites(SettingsDB.AudioTable)-1 then Exit;
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;

  i := TNTStringGrid1.Row;
  FileName := SettingsDB.AudioTable[i].FileName;
  Name := SettingsDB.AudioTable[i].Name;
  Exstension := SettingsDB.AudioTable[i].Exstension;
  Favorite := SettingsDB.AudioTable[i].Favorite;
  Memory := SettingsDB.AudioTable[i].Memory;

  DeleteFromList(SettingsDB.AudioTable, i);
  InsertToList(SettingsDB.AudioTable, i+1, Name, FileName, Exstension, Favorite, Memory, False);
  BuildList(SettingsDB.AudioTable);
  TNTStringGrid1.Row := i+1;
end;


procedure TForm1.MoveTo1Click(Sender: TObject);
var
  Index: String;
  FileName, Name, Exstension: WideString;
  Favorite: Boolean;
  Memory: TMemory;
  i: Integer;
begin
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;

  i := TNTStringGrid1.Row;
  FileName := SettingsDB.AudioTable[i].FileName;
  Name := SettingsDB.AudioTable[i].Name;
  Exstension := SettingsDB.AudioTable[i].Exstension;
  Favorite := SettingsDB.AudioTable[i].Favorite;
  Memory := SettingsDB.AudioTable[i].Memory;

  Index := Trim(WideInputBox('Move To', 'Position:', IntToStr(TNTStringGrid1.Row+1), Form1.Font));
  if (Index = '') or (Index = IntToStr(TNTStringGrid1.Row+1)) then Exit;
  for i := 1 to Length(Index) do if not (Index[i] in ['0'..'9']) then Exit;
  if (StrToInt(Index) <= 0) or (StrToInt(Index) > TNTStringGrid1.RowCount) then Exit;

  if Favorite then begin
    if StrToInt(Index) > CountFavorites(SettingsDB.AudioTable) then Exit;
  end else begin
    if StrToInt(Index) <= CountFavorites(SettingsDB.AudioTable) then Exit;
  end;

  DeleteFromList(SettingsDB.AudioTable, TNTStringGrid1.Row);
  InsertToList(SettingsDB.AudioTable, StrToInt(Index)-1, Name, FileName, Exstension, Favorite, Memory, False);
  BuildList(SettingsDB.AudioTable);
  TNTStringGrid1.Row := StrToInt(Index)-1;
end;


procedure TForm1.ChangeName1Click(Sender: TObject);
var
  CurrentName, NewName: WideString;
  i: Integer;
begin
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;

  i := TNTStringGrid1.Row;
  CurrentName := SettingsDB.AudioTable[i].Name;
  NewName := WideInputBox('Change Name', 'Name:', CurrentName, Form1.Font);
  NewName := Trim(TNT_WideStringReplace(NewName, '*', '', [rfReplaceAll, rfIgnoreCase]));
  if NewName = '' then Exit;
  SettingsDB.AudioTable[i].Name := NewName;
  TNTStringGrid1.Cells[TNTStringGrid1.Col, i] := TNT_WideStringReplace(TNTStringGrid1.Cells[TNTStringGrid1.Col, i], CurrentName, NewName, [rfReplaceAll, rfIgnoreCase]);
end;


procedure TForm1.Favorite1Click(Sender: TObject);
var
  FileName, Name, Exstension: WideString;
  Favorite: Boolean;
  Memory: TMemory;
begin
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;

  FileName := SettingsDB.AudioTable[TNTStringGrid1.Row].FileName;
  Name := SettingsDB.AudioTable[TNTStringGrid1.Row].Name;
  Exstension := SettingsDB.AudioTable[TNTStringGrid1.Row].Exstension;
  Favorite := not SettingsDB.AudioTable[TNTStringGrid1.Row].Favorite;
  Memory := SettingsDB.AudioTable[TNTStringGrid1.Row].Memory;

  DeleteFromList(SettingsDB.AudioTable, TNTStringGrid1.Row);
  InsertToList(SettingsDB.AudioTable, CountFavorites(SettingsDB.AudioTable), Name, FileName, Exstension, Favorite, Memory, False);
  BuildList(SettingsDB.AudioTable);

  if Favorite then begin
    TNTStringGrid1.Row := CountFavorites(SettingsDB.AudioTable)-1;
  end else begin
    TNTStringGrid1.Row := CountFavorites(SettingsDB.AudioTable);
  end;
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
    FileName := SettingsDB.AudioTable[TNTStringGrid1.Row].FileName;
    TNTStringGrid1KeyDown(nil, Key, []);
    DeleteFileW(PWideChar(FileName));
  end;
end;


procedure TForm1.Location1Click(Sender: TObject);
var
  Location: WideString;
begin
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;
  Location := WideExtractFileDir(SettingsDB.AudioTable[TNTStringGrid1.Row].FileName);
  ShellExecuteW(Handle, 'open', PWideChar(Location), nil, nil, SW_SHOW);
end;


procedure TForm1.ConvertToMemory1Click(Sender: TObject);
var
  FileName, Name: WideString;
  MemoryStream: TTNTMemoryStream;
  Memory: TMemory;
begin
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;
  StopAudio;

  FileName := SettingsDB.AudioTable[TNTStringGrid1.Row].FileName;

  if CountMemory(SettingsDB.AudioTable)+GetFileSize(FileName) >= MAXIMUM_SIZE then begin
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

  SettingsDB.AudioTable[TNTStringGrid1.Row].Memory := Memory;
  SettingsDB.AudioTable[TNTStringGrid1.Row].FileName := '';
  SettingsDB.AudioTable[TNTStringGrid1.Row].Exstension := WideLowerCase(WideExtractFileExt(FileName));

  Name := TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row];
  TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] := Name + ' [MEM]';
end;


procedure TForm1.ConvertToFile1Click(Sender: TObject);
var
  Name, Exstension: WideString;
  Memory: TMemory;
  TNTSaveDialog: TTNTSaveDialog;
begin
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;
  StopAudio;

  Name := SettingsDB.AudioTable[TNTStringGrid1.Row].Name;
  Exstension := SettingsDB.AudioTable[TNTStringGrid1.Row].Exstension;
  Memory := SettingsDB.AudioTable[TNTStringGrid1.Row].Memory;

  TNTSaveDialog := TTNTSaveDialog.Create(nil);
  TNTSaveDialog.FileName := Name;
  TNTSaveDialog.Filter := AnsiUpperCase(Copy(Exstension, 2, Length(Exstension))) + ' File|*' + Exstension;
  TNTSaveDialog.Options := [ofHideReadOnly, ofEnableSizing];
  TNTSaveDialog.Title := 'Soundboard: Save Sound';

  if TNTSaveDialog.Execute then begin
    if Pos('.', TNTSaveDialog.FileName) <= 0 then TNTSaveDialog.FileName := WideChangeFileExt(TNTSaveDialog.FileName, Exstension);
    SaveByteArray(Memory, TNTSaveDialog.FileName);

    SettingsDB.AudioTable[TNTStringGrid1.Row].FileName := TNTSaveDialog.FileName;
    SettingsDB.AudioTable[TNTStringGrid1.Row].Exstension := WideLowerCase(WideExtractFileExt(TNTSaveDialog.FileName));
    SetLength(SettingsDB.AudioTable[TNTStringGrid1.Row].Memory, 0);

    Name := TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row];
    Name := TNT_WideStringReplace(Name, ' [MEM]', '', [rfReplaceAll, rfIgnoreCase]);
    TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] := Name;
  end;
end;


procedure TForm1.MakeaCopyToFile1Click(Sender: TObject);
var
  FileName: WideString;
  Name, Exstension: WideString;
  Memory: TMemory;
  TNTSaveDialog: TTNTSaveDialog;
begin
  if TNTStringGrid1.Cells[TNTStringGrid1.Col, TNTStringGrid1.Row] = '' then Exit;

  FileName := SettingsDB.AudioTable[TNTStringGrid1.Row].FileName;
  Name := SettingsDB.AudioTable[TNTStringGrid1.Row].Name;
  Exstension := SettingsDB.AudioTable[TNTStringGrid1.Row].Exstension;
  Memory := SettingsDB.AudioTable[TNTStringGrid1.Row].Memory;

  TNTSaveDialog := TTNTSaveDialog.Create(nil);
  TNTSaveDialog.FileName := Name;
  TNTSaveDialog.Filter := AnsiUpperCase(Copy(Exstension, 2, Length(Exstension))) + ' File|*' + Exstension;
  TNTSaveDialog.Options := [ofHideReadOnly, ofEnableSizing];
  TNTSaveDialog.Title := 'Soundboard: Save Sound';

  if TNTSaveDialog.Execute then begin
    if Pos('.', TNTSaveDialog.FileName) <= 0 then TNTSaveDialog.FileName := WideChangeFileExt(TNTSaveDialog.FileName, Exstension);

    if Length(Memory) > 0
      then SaveByteArray(Memory, TNTSaveDialog.FileName)
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

  Percent :=  100 - (Round(TrackBar1.Position / DECREASE_MINIMUM_PERCENT) * -1);
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

  Percent :=  100 - (Round(TrackBar2.Position / DECREASE_MINIMUM_PERCENT) * -1);
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
  Panel1.Top := Form1.Height - 51;
  TNTStringGrid1.Height := Form1.Height - TNTStringGrid1.Top - 55;
  ItemsPerPage := Trunc(TNTStringGrid1.Height/(TNTStringGrid1.DefaultRowHeight + TNTStringGrid1.GridLineWidth));
  Scroll.Height := TNTStringGrid1.Height-2;
  Scroll.PageSize := ItemsPerPage;

  if TNTStringGrid1.TopRow + ItemsPerPage > Length(SettingsDB.AudioTable) then begin
    NewTop := Length(SettingsDB.AudioTable) - ItemsPerPage;
    if NewTop < 0 then NewTop := 0;
    TNTStringGrid1.TopRow := NewTop;
    Scroll.Position := TNTStringGrid1.TopRow;
  end;

  if ItemsPerPage < Length(SettingsDB.AudioTable)
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
      TNTStringGrid1.TopRow := TNTStringGrid1.TopRow + 1;
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
      TNTStringGrid1.TopRow := TNTStringGrid1.TopRow - 1;
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
      TNTStringGrid1.Row := StrToInt(StaticText1.Caption) - 1;
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
  WideCanvasTextOut(TNTStringGrid1.Canvas, Rect.Left + 3, Rect.Top + 2, TNTStringGrid1.Cells[ACol,ARow]);
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
