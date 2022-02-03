unit ClipboardHistory;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
  ExtCtrls, MMSystem, Grids, Menus, Registry, DateUtils, ShellAPI, TNTSysUtils, TNTGrids,
  TNTClipBrd, TNTGraphics, TNTStdCtrls, TNTSystem, ATScrollBar, TFlatComboBoxUnit,
  TFlatCheckBoxUnit, uQueryShutdown, CustoTrayIcon, uKBDynamic, Functions;

const
  INACTIVE_TIMEOUT = 350;
  SEARCH_DELAY = 1000;
  DEFAULT_ROOT_KEY = HKEY_CURRENT_USER;
  DEFAULT_KEY = '\Software\ClipboardHistory';
  ECLIPSIS_SIZE = 5;
  ROWS_PER_SCROLL = 3;
  APPEND_ITEMS = 100;
  TOTAL_ITEMS = 'Total items: ';
  TOTAL_FOUND = 'Total found: ';

const
  COL_WIDTH_0 = 60;
  COL_WIDTH_1 = 422;
  COL_WIDTH_2 = 49;
  COL_WIDTH_3 = 24;

type
  TClipboard = record
    UID: Int64;
    DateTime: TDateTime;
    Content: WideString;
  end;

  TClipboardList = array of TClipboard;

  TSettingsDB = record
    Monitoring: Boolean;
    MaxItems: Integer;
    MaxSize: Integer;
    RemoveAfter: Integer;
    SaveAfter: Integer;
    isItemsLimited: Boolean;
    isSizeLimited: Boolean;
    isTimeLimited: Boolean;
    isAutoSave: Boolean;
    TimeIndex: Integer;
    SizeIndex: Integer;
    AutoSaveIndex: Integer;
    ClipboardTable: TClipboardList;
  end;

type
  THackGrid = class(TCustomGrid);

type
  TForm1 = class(TForm)
    TNTStringGrid1: TTNTStringGrid;
    Panel1: TPanel;
    Shape1: TShape;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    TNTEdit1: TTNTEdit;
    PopupMenu1: TPopupMenu;
    Open1: TMenuItem;
    Settings1: TMenuItem;
    Exit1: TMenuItem;
    About1: TMenuItem;
    Timer1: TTimer;
    Timer2: TTimer;
    Timer3: TTimer;
    Timer4: TTimer;
    TrayIcon1: TTrayIcon;
    Restart1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TNTStringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure TNTStringGrid1MouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure TNTStringGrid1MouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ChangeVertical(Sender: TObject);
    procedure ApplicationDecativate(Sender: TObject);
    procedure AddItem(var C: TClipboard; Index, Position: Integer);
    procedure HideList;
    procedure PrepareList(Len: Integer);
    procedure BuildList(var A: TClipboardList; Start, Count: Integer);
    procedure Search(var A: TClipboardList; S: WideString);
    procedure TNTStringGrid1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure CheckListEnding;
    procedure DisableClipboard;
    procedure EnableClipboard;
    procedure TNTStringGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TNTStringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    function CheckEmpty: Boolean;
    procedure TNTEdit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Timer4Timer(Sender: TObject);
    procedure TrayIcon1Action(Sender: TObject; Code: Integer);
    procedure Restart1Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ClipBoardChanged(var Msg: TMessage); message WM_DRAWCLIPBOARD;
    { Public declarations }
  end;

var
  Form1: TForm1;
  RowChanged: Boolean;
  AppInactive: Boolean;
  SettingsDB: TSettingsDB;
  ItemsPerPage: Integer;
  Scroll: TATScroll;
  SearchMode: Boolean = False;
  AllowClipboard: Boolean = True;
  SaveClipboard: Int64 = 0;

implementation

uses Settings, About;

{$R *.dfm}


//LoadSettings
procedure LoadSettings;
var
  MemoryStream: TMemoryStream;
  Registry: TRegistry;
begin
  LoadRegistryBoolean(SettingsDB.Monitoring, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'Monitoring');
  LoadRegistryInteger(SettingsDB.MaxItems, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'MaxItems');
  LoadRegistryInteger(SettingsDB.MaxSize, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'MaxSize');
  LoadRegistryInteger(SettingsDB.RemoveAfter, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'RemoveAfter');
  LoadRegistryInteger(SettingsDB.SaveAfter, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'SaveAfter');
  LoadRegistryBoolean(SettingsDB.isItemsLimited, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'isItemsLimited');
  LoadRegistryBoolean(SettingsDB.isSizeLimited, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'isSizeLimited');
  LoadRegistryBoolean(SettingsDB.isTimeLimited, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'isTimeLimited');
  LoadRegistryBoolean(SettingsDB.isAutoSave, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'isAutoSave');
  LoadRegistryInteger(SettingsDB.TimeIndex, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'TimeIndex');
  LoadRegistryInteger(SettingsDB.SizeIndex, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'SizeIndex');
  LoadRegistryInteger(SettingsDB.AutoSaveIndex, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'AutoSaveIndex');

  Registry := TRegistry.Create;
  Registry.RootKey := DEFAULT_ROOT_KEY;
  Registry.OpenKey(DEFAULT_KEY, True);

  if Registry.ValueExists('History') then begin
    MemoryStream := TMemoryStream.Create;
    MemoryStream.SetSize(Registry.GetDataSize('History'));
    Registry.ReadBinaryData('History', MemoryStream.Memory^, MemoryStream.Size);
    DecompressStream(MemoryStream);

    try
      TKBDynamic.ReadFrom(MemoryStream, SettingsDB.ClipboardTable, TypeInfo(TClipboardList), 1);
      MemoryStream.Free;
    except
      PlaySound('SystemExclamation', 0, SND_ASYNC);
      ShowMessage('There was an error loading clipboard list.' + #13#10 +
                  'List data may be corrupted or outdated.' + #13#10 +
                  'The clipboard list will be reset.');
      ZeroMemory(@SettingsDB.ClipboardTable, SizeOf(SettingsDB.ClipboardTable));
      SetLength(SettingsDB.ClipboardTable, 0);
      Registry.DeleteValue('History');
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
begin
  SaveRegistryBoolean(SettingsDB.Monitoring, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'Monitoring');
  SaveRegistryInteger(SettingsDB.MaxItems, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'MaxItems');
  SaveRegistryInteger(SettingsDB.MaxSize, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'MaxSize');
  SaveRegistryInteger(SettingsDB.RemoveAfter, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'RemoveAfter');
  SaveRegistryInteger(SettingsDB.SaveAfter, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'SaveAfter');
  SaveRegistryBoolean(SettingsDB.isItemsLimited, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'isItemsLimited');
  SaveRegistryBoolean(SettingsDB.isSizeLimited, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'isSizeLimited');
  SaveRegistryBoolean(SettingsDB.isTimeLimited, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'isTimeLimited');
  SaveRegistryBoolean(SettingsDB.isAutoSave, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'isAutoSave');
  SaveRegistryInteger(SettingsDB.TimeIndex, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'TimeIndex');
  SaveRegistryInteger(SettingsDB.SizeIndex, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'SizeIndex');
  SaveRegistryInteger(SettingsDB.AutoSaveIndex, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'AutoSaveIndex');

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
  TKBDynamic.WriteTo(MemoryStream, SettingsDB.ClipboardTable, TypeInfo(TClipboardList), 1, lOptions);
  CompressStream(MemoryStream);

  Registry := TRegistry.Create;
  Registry.RootKey := DEFAULT_ROOT_KEY;
  Registry.OpenKey(DEFAULT_KEY, True);
  Registry.WriteBinaryData('History', MemoryStream.Memory^, MemoryStream.Size);
  Registry.Free;

  MemoryStream.Free;
end;
//SaveSettings


//DisableClipboard
procedure TForm1.DisableClipboard;
begin
  AllowClipboard := False;
  Timer1.Enabled := False;
end;
//DisableClipboard


//EnableClipboard
procedure TForm1.EnableClipboard;
begin
  AllowClipboard := True;
  Timer1.Enabled := True;
end;
//EnableClipboard


//DeleteFromList
procedure DeleteFromList(var A: TClipboardList; const Index: Integer);
var
  i, ArrayLength: Integer;
begin
  ArrayLength := Length(A);

  if Index = ArrayLength-1 then begin
    SetLength(A, ArrayLength-1);
    Exit;
  end;

  for i := Index to Length(A)-2  do begin
    A[i].UID := A[i+1].UID;
    A[i].DateTime := A[i+1].DateTime;
    A[i].Content := A[i+1].Content;
  end;

  SetLength(A, ArrayLength-1);
end;
//DeleteFromList


//InsertToList
procedure InsertToList(var A: TClipboardList; const Index: Integer; DateTime: TDateTime; Content: WideString);
var
  i: Integer;
begin
  if SettingsDB.isItemsLimited and (Length(A) >= SettingsDB.MaxItems) then SetLength(A, SettingsDB.MaxItems-1);
  SetLength(A, Length(A)+1);

  for i := Length(A)-1 downto Index+1 do begin
    A[i].UID := A[i-1].UID;
    A[i].DateTime := A[i-1].DateTime;
    A[i].Content := A[i-1].Content;
  end;

  A[Index].UID := MilliSecondsBetween(DateTime, 0);;
  A[Index].DateTime := DateTime;
  A[Index].Content := Content;
end;
//InsertToList


//UpdateList
procedure UpdateList(var A: TClipboardList);
var
  i: Integer;
  DateNow: TDateTime;
begin
  DateNow := Now;

  for i := Length(A)-1 downto 0 do begin
    if SecondsBetween(SettingsDB.ClipboardTable[i].DateTime, DateNow) < SettingsDB.RemoveAfter then Break;
    SetLength(A, Length(A)-1);
  end;
end;
//UpdateList


function FindUID(var A: TClipboardList; UID: Int64): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to Length(A)-1 do begin
    if A[i].UID = UID then begin
      Result := i;
      Break;
    end;
  end;
end;


//QueryShutdown
procedure QueryShutdown(BS: TBlockShutdown);
begin
  BS.CreateReason('Saving settings...');
  SaveSettings;
  BS.DestroyReason;
  Application.Terminate;
end;
//QueryShutdown


//ClipboardUpdate
procedure ClipboardUpdate;
begin
  Form1.TrayIcon1.Icon := LoadIcon(HInstance, 'RED');
  Wait(1000);
  Form1.TrayIcon1.Icon := LoadIcon(HInstance, 'MAINICON');
  EndThread(0);
end;
//ClipboardUpdate


//ClipBoardChanged
procedure TForm1.ClipBoardChanged(var Msg: TMessage);
var
  Content: WideString;
  ID: LongWord;
begin
  if not AllowClipboard then Exit;
  if not SettingsDB.Monitoring then Exit;

  try
    Content := TNTClipboard.AsWideText;
  except
  end;

  if (Length(Content) <= 0) or ((Length(Content) > SettingsDB.MaxSize) and SettingsDB.isSizeLimited) then Exit;
  if (Length(SettingsDB.ClipboardTable) > 0) and (Content = SettingsDB.ClipboardTable[0].Content) then Exit;
  BeginThread(nil, 0, Addr(ClipboardUpdate), nil, 0, ID);
  InsertToList(SettingsDB.ClipboardTable, 0, Now, Content);
end;
//ClipBoardChanged


//FormatSize
function FormatSize(x: Integer): String;
begin
  Result := IntToStr(x);
  if x >= (1024) then Result := Format('%d KB', [Round(x / 1024)]);
  if x >= (1024 * 1024) then Result := Format('%d MB', [Round(x / (1024 * 1024))]);
end;
//FormatSize


//AddItem
procedure TForm1.AddItem(var C: TClipboard; Index, Position: Integer);
begin
  TNTStringGrid1.Cells[0, Index] := ' ' + FormatDate(C.DateTime);
  TNTStringGrid1.Cells[2, Index] := ' ' + FormatSize(Length(C.Content));
  TNTStringGrid1.Cells[1, Index] := Trim(TNT_WideStringReplace(Copy(C.Content, Position, 100), #10, ' ', [rfReplaceAll]));
  TNTStringGrid1.Cells[3, Index] := ' ' + WideString(WideChar(10060));
  TNTStringGrid1.Cells[4, Index] := IntToStr(C.UID);
end;
//AddItem


//HideList
procedure TForm1.HideList;
begin
  TNTStringGrid1.RowCount := 0;
  TNTStringGrid1.Cols[0].Clear;
  TNTStringGrid1.Rows[0].Clear;
  TNTStringGrid1.TopRow := 0;
  Scroll.Position := 0;

  TNTStringGrid1.ColWidths[0] := 0;
  TNTStringGrid1.ColWidths[1] := 0;
  TNTStringGrid1.ColWidths[2] := 0;
  TNTStringGrid1.ColWidths[3] := 0;
  TNTStringGrid1.GridLineWidth := 0;
  Scroll.Visible := False;
end;
//HideList


//PrepareList
procedure TForm1.PrepareList(Len: Integer);
begin
  if Len > 0 then begin
    TNTStringGrid1.ColWidths[0] := COL_WIDTH_0;
    TNTStringGrid1.ColWidths[2] := COL_WIDTH_2;
    TNTStringGrid1.ColWidths[3] := COL_WIDTH_3;
    TNTStringGrid1.GridLineWidth := 1;
    StaticText2.Visible := False;
  end else begin
    HideList;
    StaticText2.Top := Round((TNTStringGrid1.Height - StaticText2.Height)/2) + TNTStringGrid1.Top;
    StaticText2.Left := Round((TNTStringGrid1.Width - StaticText2.Width)/2);
    StaticText2.Visible := True;
  end;

  if ItemsPerPage <= Len then begin
    TNTStringGrid1.ColWidths[1] := COL_WIDTH_1 - Scroll.Width;
    Scroll.Max := Len;
    Scroll.Visible := True;
  end else begin
    TNTStringGrid1.ColWidths[1] := COL_WIDTH_1;
    Scroll.Visible := False;
  end;
end;
//PrepareList


//BuildList
procedure TForm1.BuildList(var A: TClipboardList; Start, Count: Integer);
var
  i: Integer;
begin
  StaticText1.Caption := TOTAL_ITEMS + IntToStr(Length(A));

  if (Start + Count) > Length(A) then Count := Length(A)-Start;
  TNTStringGrid1.RowCount := Start+Count;

  for i := Start to Start+Count-1 do begin
    AddItem(A[i], i, 1);
  end;

  PrepareList(TNTStringGrid1.RowCount);
end;
//BuildList


//Search
procedure TForm1.Search(var A: TClipboardList; S: WideString);
var
  i, Position, Count: Integer;
begin
  Count := 0;
  S := WideLowerCase(S);

  for i := 0 to Length(A)-1 do begin
      Position := Pos(S, WideLowerCase(A[i].Content));

      if (Position > 0) then begin
        if Position > 1 then Position := Position - 35;
        if Position < 1 then Position := 1;
        AddItem(A[i], Count, Position);
        Inc(Count);
      end;
  end;

  TNTStringGrid1.RowCount := Count;
  StaticText1.Caption := TOTAL_FOUND + IntToStr(Count);
  PrepareList(Count);
end;
//Search


//CheckListEnding
procedure TForm1.CheckListEnding;
begin
  if SearchMode then Exit;
  if (TNTStringGrid1.RowCount - (TNTStringGrid1.TopRow + ItemsPerPage)) > 2 then Exit;
  if TNTStringGrid1.RowCount > Length(SettingsDB.ClipboardTable) then Exit;
  BuildList(SettingsDB.ClipboardTable, TNTStringGrid1.RowCount, APPEND_ITEMS);
end;
//CheckListEnding


procedure TForm1.TrayIcon1Action(Sender: TObject; Code: Integer);
var
  Point: TPoint;
begin
  case Code of
    WM_RBUTTONDOWN: begin
      if (Form2.Visible or Form3.Visible) then Exit;
      GetCursorPos(Point);
      SetForegroundWindow(Application.Handle);
      Application.ProcessMessages;
      PopupMenu1.Popup(Point.X, Point.Y);
    end;

    WM_LBUTTONUP: begin
      if (Form2.Visible or Form3.Visible) then begin
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
  LoadSettings;
  SetClipboardViewer(Handle);

  Scroll := TATScroll.Create(Self);
  Scroll.Parent := Form1;
  Scroll.Align := alNone;
  Scroll.Kind := sbVertical;
  Scroll.OnChange := ChangeVertical;
  Scroll.DisableMarks := True;
  Scroll.Min := 0;
  Scroll.Width := 16;
  Scroll.Height := TNTStringGrid1.Height-2;
  Scroll.Top := TNTStringGrid1.Top+1;
  Scroll.Left := TNTStringGrid1.Width - Scroll.Width-1;

  TrayIcon1.Icon := LoadIcon(HInstance, 'MAINICON');
  TrayIcon1.Title := TOTAL_ITEMS + IntToStr(Length(SettingsDB.ClipboardTable));
  TrayIcon1.AddToTray;

  Timer1.Enabled := True;
  Timer2.Interval := SEARCH_DELAY;
  Timer3.Interval := SettingsDB.SaveAfter*1000;
  Timer3.Enabled := True;
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
  end;

  SetForegroundWindow(Handle);
  Application.OnDeactivate := ApplicationDecativate;
  SearchMode := False;
  DisableClipboard;

  Form1.Left := MonitorWidth - Form1.Width;
  Form1.Top := MonitorHeigth - Form1.Height - (MonitorHeigth - CurrentMonitor.WorkareaRect.Bottom);

  ItemsPerPage := Trunc((TNTStringGrid1.Height/(TNTStringGrid1.DefaultRowHeight + TNTStringGrid1.GridLineWidth))+0.5);
  Scroll.PageSize := ItemsPerPage;
  Scroll.Position := 0;

  TNTStringGrid1.TopRow := 0;
  BuildList(SettingsDB.ClipboardTable, 0, ItemsPerPage*2);
  TNTStringGrid1.Selection := TGridRect(Rect(0,-1,0,-1));

  TNTEdit1.Text := '';
  Timer4.Enabled := True;
  TNTStringGrid1.SetFocus;
end;


procedure TForm1.FormHide(Sender: TObject);
var
  Msg: TMessage;
  Index: Integer;
begin
  Application.OnDeactivate := nil;
  Timer4.Enabled := False;
  EnableClipboard;

  if SaveClipboard <> 0 then begin
    Index := FindUID(SettingsDB.ClipboardTable, SaveClipboard);
    if Index > 0 then DeleteFromList(SettingsDB.ClipboardTable, Index);
    ClipBoardChanged(Msg);
    SaveClipboard := 0;
  end;
end;


procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TrayIcon1.Destroy;
  SaveSettings;
end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  UpdateList(SettingsDB.ClipboardTable);
  TrayIcon1.Title := TOTAL_ITEMS + IntToStr(Length(SettingsDB.ClipboardTable));
  Timer1.Enabled := True;
end;


procedure TForm1.Timer2Timer(Sender: TObject);
begin
  Timer2.Enabled := False;
  if (TNTEdit1.Text = '') then Exit;
  HideList;
  Wait(100);

  SearchMode := True;
  Search(SettingsDB.ClipboardTable, TNTEdit1.Text);
end;


procedure TForm1.Timer3Timer(Sender: TObject);
begin
  Timer1Timer(nil);
  Timer1.Enabled := False;
  SaveSettings;
  Timer1.Enabled := True;
end;


procedure TForm1.TNTStringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
  Index: Integer;
begin
  CanSelect := False;
  if not (GetKeyState(VK_LBUTTON) < 0) then Exit; //This used to cancel second event when button gets released
  Mouse_Event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0); //Release mouse button so event doesn't happen infinite times

  if ACol = 3 then begin
    Index := FindUID(SettingsDB.ClipboardTable, StrToInt64(TNTStringGrid1.Cells[4, ARow]));
    PrepareList(TNTStringGrid1.RowCount-1);
    THackGrid(TNTStringGrid1).DeleteRow(ARow);
    DeleteFromList(SettingsDB.ClipboardTable, Index);

    if not SearchMode
      then BuildList(SettingsDB.ClipboardTable, TNTStringGrid1.RowCount, 1)
      else StaticText1.Caption := TOTAL_FOUND + IntToStr(StrToInt(StringReplace(StaticText1.Caption, TOTAL_FOUND, '', [rfReplaceAll, rfIgnoreCase]))-1);

    if SearchMode and (Index > TNTStringGrid1.RowCount-ItemsPerPage) then begin
      if TNTStringGrid1.TopRow - 1 < 0 then Exit;
      TNTStringGrid1.TopRow :=  TNTStringGrid1.TopRow - 1;
      Scroll.Position := Scroll.Position - 1;
    end;

    if (not SearchMode) and (Index > Length(SettingsDB.ClipboardTable)-ItemsPerPage) then begin
      if TNTStringGrid1.TopRow - 1 < 0 then Exit;
      TNTStringGrid1.TopRow :=  TNTStringGrid1.TopRow - 1;
      Scroll.Position := Scroll.Position - 1;
    end;
  end;

  if ACol = 1 then begin
    SaveClipboard := StrToInt64(TNTStringGrid1.Cells[4, ARow]);
    Index := FindUID(SettingsDB.ClipboardTable, SaveClipboard);
    TNTClipboard.AsWideText := SettingsDB.ClipboardTable[Index].Content;
    TNTStringGrid1.Selection := TGridRect(Rect(1,ARow,1,ARow));
    Wait(200);
    TNTStringGrid1.Selection := TGridRect(Rect(0,-1,0,-1));
  end;
end;


procedure TForm1.ChangeVertical(Sender: TObject);
begin
  TNTStringGrid1.TopRow := Scroll.Position;
  CheckListEnding;
end;


procedure TForm1.TNTStringGrid1MouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if TNTStringGrid1.RowCount = TNTStringGrid1.VisibleRowCount then begin
    RowChanged := True;
    Exit;
  end;

  CheckListEnding;

  if TNTStringGrid1.TopRow + ROWS_PER_SCROLL > TNTStringGrid1.RowCount - ItemsPerPage
    then TNTStringGrid1.TopRow := TNTStringGrid1.RowCount - ItemsPerPage
    else TNTStringGrid1.TopRow := TNTStringGrid1.TopRow + ROWS_PER_SCROLL;

  Scroll.Position := TNTStringGrid1.TopRow;
end;


procedure TForm1.TNTStringGrid1MouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if TNTStringGrid1.RowCount = TNTStringGrid1.VisibleRowCount then begin
    RowChanged := True;
    Exit;
  end;

  if TNTStringGrid1.TopRow - ROWS_PER_SCROLL < 0
    then TNTStringGrid1.TopRow := 0
    else TNTStringGrid1.TopRow := TNTStringGrid1.TopRow - ROWS_PER_SCROLL;

  Scroll.Position := TNTStringGrid1.TopRow;
end;


procedure TForm1.TNTStringGrid1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if not TNTStringGrid1.Focused then TNTStringGrid1.SetFocus;
end;


procedure TForm1.Open1Click(Sender: TObject);
begin
  if Form1.Visible
    then Form1.Hide
    else Form1.Show;
end;


procedure TForm1.Settings1Click(Sender: TObject);
begin
  if Form1.Visible then Form1.Hide;
  Form2.ShowModal;
end;


procedure TForm1.About1Click(Sender: TObject);
begin
  if Form1.Visible then Form1.Hide;
  Form3.ShowModal;
end;


procedure TForm1.Restart1Click(Sender: TObject);
var
  CloseAction: TCloseAction;
begin
  CloseAction := caNone;
  FormClose(nil, CloseAction);
  WideWinExec(WideParamStr(0), SW_SHOW);
  TerminateProcess(GetCurrentProcess, 0);
end;


procedure TForm1.Exit1Click(Sender: TObject);
var
  CloseAction: TCloseAction;
begin
  CloseAction := Forms.caNone;
  FormClose(nil, CloseAction);
  TerminateProcess(GetCurrentProcess, 0);
end;


procedure TForm1.ApplicationDecativate(Sender: TObject);
begin
  AppInactive := True;
  Form1.Hide;
  Wait(INACTIVE_TIMEOUT);
  AppInactive := False;
end;


function TForm1.CheckEmpty: Boolean;
begin
  Result := False;

  if (TNTEdit1.Text = '') then begin
    Timer2.Enabled := False;
    SearchMode := False;
    Wait(100);
    BuildList(SettingsDB.ClipboardTable, 0, ItemsPerPage*2);
    Result := True;
  end;
end;


procedure TForm1.TNTEdit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if CheckEmpty then Exit;
  Timer2.Enabled := False;
  Timer2.Enabled := True;
end;


procedure TForm1.Timer4Timer(Sender: TObject);
begin
  if (TNTEDit1.Text = '') and (not TNTEDit1.Focused) then SetPlaceholder(TNTEDit1, TNTEDit1.Font, TNTEDit1.Hint);
end;


procedure TForm1.TNTStringGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_PRIOR) or (Key = VK_NEXT) then Key := 0;
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

  //Remove last pixels in col 1 (simulate eclipsis)
  if ACol = 1 then begin
    Rect.Left := Rect.Left + ((Rect.Right - Rect.Left) - ECLIPSIS_SIZE);
    TNTStringGrid1.Canvas.FillRect(Rect);
  end;

  //Redraw col lines becasue WideCanvasTextOut overdraw them
  if ACol > 0 then begin
    Rect.Left := Rect.Right;
    Rect.Right := Rect.Right + 1;
    TNTStringGrid1.Canvas.Brush.Color := FLAT_STYLE_GRAY_COLOR;
    TNTStringGrid1.Canvas.FillRect(Rect);
  end;
end;


procedure TForm1.Shape1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  StaticText1.SetFocus;
end;


initialization
  SettingsDB.Monitoring := True; //Enable clipboard saving
  SettingsDB.MaxItems := 2000; //Max items
  SettingsDB.MaxSize := 1024*1024*10; //Max size
  SettingsDB.RemoveAfter := 60*60*24*30; //Seconds (1 month)
  SettingsDB.SaveAfter := 60*60*2; //Seconds (2 hours)
  SettingsDB.isItemsLimited := True; //Item limitation
  SettingsDB.isSizeLimited := True; //Size limitation
  SettingsDB.isTimeLimited := True; //Time limitation
  SettingsDB.isAutoSave := True; //Autosave
  SettingsDB.TimeIndex := 4; //Time index in combobox
  SettingsDB.SizeIndex := 2; //Size index in combobox
  SettingsDB.AutoSaveIndex := 1; //AutoSave index in combobox
end.
