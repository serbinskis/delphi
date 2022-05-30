unit ClipboardHistory;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
  ExtCtrls, MMSystem, Grids, Menus, Registry, DateUtils, ShellAPI, TNTSysUtils, TNTGrids,
  TNTClipBrd, TNTGraphics, TNTStdCtrls, TNTSystem, TNTDialogs, ATScrollBar, TFlatComboBoxUnit,
  TFlatCheckBoxUnit, CustoTrayIcon, uQueryShutdown, uDynamicData, Functions;

const
  INACTIVE_TIMEOUT = 350;
  SEARCH_DELAY = 1000;
  DEFAULT_ROOT_KEY = HKEY_CURRENT_USER;
  DEFAULT_KEY = '\Software\ClipboardHistory';
  COLS: array[0..3] of Integer = (60, 422, 49, 24);
  ECLIPSIS_SIZE = 5;
  ROWS_PER_SCROLL = 3;
  APPEND_ITEMS = 100;
  TOTAL_ITEMS = 'Total items: ';
  TOTAL_FOUND = 'Total found: ';

type
  TSettingsDB = record
    Monitoring: Boolean;
    PreventDuplicates: Boolean;
    MaxItems: Integer;
    MaxSize: Integer;
    RemoveAfter: Integer;
    AutoSaveAfter: Integer;
    isItemsLimited: Boolean;
    isSizeLimited: Boolean;
    isTimeLimited: Boolean;
    isAutoSave: Boolean;
    TimeIndex: Integer;
    SizeIndex: Integer;
    AutoSaveIndex: Integer;
    ShowFavorites: Boolean;
    ShowBySize: Int64;
    ShowEquality: Integer;
  end;

type
  THackGrid = class(TCustomGrid);

type
  TForm1 = class(TForm)
    About1: TMenuItem;
    Copy1: TMenuItem;
    Delete1: TMenuItem;
    DisableClipboard1: TMenuItem;
    Exit1: TMenuItem;
    Favorite1: TMenuItem;
    Favorite2: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    Restart1: TMenuItem;
    Settings1: TMenuItem;
    Shape1: TShape;
    Show1: TMenuItem;
    ShowBySize1: TMenuItem;
    ShowFavorites1: TMenuItem;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    TNTEdit1: TTNTEdit;
    TNTStringGrid1: TTNTStringGrid;
    Timer1: TTimer;
    Timer2: TTimer;
    Timer3: TTimer;
    Timer4: TTimer;
    Timer5: TTimer;
    TrayIcon1: TTrayIcon;
    function CheckEmpty: Boolean;
    procedure About1Click(Sender: TObject);
    procedure AddItem(ArrayIndex, ListIndex, Position: Integer);
    procedure ApplicationDecativate(Sender: TObject);
    procedure BuildList(ListIndex, ArrayIndex, Count: Integer);
    procedure CheckListEnding;
    procedure Copy1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure DeleteRow(ARow: Integer);
    procedure DisableClipboard1Click(Sender: TObject);
    procedure DisableClipboard;
    procedure EnableClipboard;
    procedure Exit1Click(Sender: TObject);
    procedure Favorite2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HideList;
    procedure PrepareList(Len: Integer);
    procedure Restart1Click(Sender: TObject);
    procedure ScrollChangeVertical(Sender: TObject);
    procedure Search(S: WideString);
    procedure Settings1Click(Sender: TObject);
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ShowBySize1Click(Sender: TObject);
    procedure ShowFavorites1Click(Sender: TObject);
    procedure StaticText3Click(Sender: TObject);
    procedure TNTEdit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TNTStringGrid1DblClick(Sender: TObject);
    procedure TNTStringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure TNTStringGrid1Exit(Sender: TObject);
    procedure TNTStringGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TNTStringGrid1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure TNTStringGrid1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TNTStringGrid1MouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure TNTStringGrid1MouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure TNTStringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure Timer4Timer(Sender: TObject);
    procedure Timer5Timer(Sender: TObject);
    procedure TrayIcon1Action(Sender: TObject; Code: Integer);
  private
    { Private declarations }
  public
    procedure ClipboardChanged(var Msg: TMessage); message WM_DRAWCLIPBOARD;
    { Public declarations }
  end;

var
  Form1: TForm1;
  SettingsDB: TSettingsDB;
  DynamicData: TDynamicData;
  ItemsPerPage: Integer;
  Scroll: TATScroll;
  SaveClipboard: Int64 = 0;
  AllowClipboard: Boolean = True;
  SearchMode: Boolean = False;
  AppInactive: Boolean = False;
  SavedSearch: WideString;
  doSelect: Boolean = True;

implementation

uses Settings, About;

{$R *.dfm}


//LoadSettings
procedure LoadSettings;
begin
  LoadRegistryBoolean(SettingsDB.Monitoring, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'Monitoring');
  LoadRegistryBoolean(SettingsDB.PreventDuplicates, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'PreventDuplicates');
  LoadRegistryInteger(SettingsDB.MaxItems, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'MaxItems');
  LoadRegistryInteger(SettingsDB.MaxSize, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'MaxSize');
  LoadRegistryInteger(SettingsDB.RemoveAfter, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'RemoveAfter');
  LoadRegistryInteger(SettingsDB.AutoSaveAfter, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'AutoSaveAfter');
  LoadRegistryBoolean(SettingsDB.isItemsLimited, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'isItemsLimited');
  LoadRegistryBoolean(SettingsDB.isSizeLimited, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'isSizeLimited');
  LoadRegistryBoolean(SettingsDB.isTimeLimited, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'isTimeLimited');
  LoadRegistryBoolean(SettingsDB.isAutoSave, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'isAutoSave');
  LoadRegistryInteger(SettingsDB.TimeIndex, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'TimeIndex');
  LoadRegistryInteger(SettingsDB.SizeIndex, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'SizeIndex');
  LoadRegistryInteger(SettingsDB.AutoSaveIndex, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'AutoSaveIndex');

  Form1.PopupMenu1.Items[0].Caption := Functions.Q(SettingsDB.Monitoring, 'Disable', 'Enable') + ' Clipboard';
  Form1.TrayIcon1.Icon := LoadIcon(HInstance, PChar(String(Functions.Q(SettingsDB.Monitoring, 'MAINICON', '_DISABLED'))));

  DynamicData := TDynamicData.Create(['UID', 'DateTime', 'Content', 'Favorite']);
  DynamicData.Load(DEFAULT_ROOT_KEY, DEFAULT_KEY, 'History', [loCompress, loRemoveUnused, loOFReset]);
end;
//LoadSettings


//SaveSettings
procedure SaveSettings;
begin
  Form1.TrayIcon1.Icon := LoadIcon(HInstance, '_SAVING');
  SaveRegistryBoolean(SettingsDB.Monitoring, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'Monitoring');
  SaveRegistryBoolean(SettingsDB.PreventDuplicates, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'PreventDuplicates');
  SaveRegistryInteger(SettingsDB.MaxItems, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'MaxItems');
  SaveRegistryInteger(SettingsDB.MaxSize, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'MaxSize');
  SaveRegistryInteger(SettingsDB.RemoveAfter, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'RemoveAfter');
  SaveRegistryInteger(SettingsDB.AutoSaveAfter, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'AutoSaveAfter');
  SaveRegistryBoolean(SettingsDB.isItemsLimited, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'isItemsLimited');
  SaveRegistryBoolean(SettingsDB.isSizeLimited, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'isSizeLimited');
  SaveRegistryBoolean(SettingsDB.isTimeLimited, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'isTimeLimited');
  SaveRegistryBoolean(SettingsDB.isAutoSave, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'isAutoSave');
  SaveRegistryInteger(SettingsDB.TimeIndex, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'TimeIndex');
  SaveRegistryInteger(SettingsDB.SizeIndex, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'SizeIndex');
  SaveRegistryInteger(SettingsDB.AutoSaveIndex, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'AutoSaveIndex');

  DynamicData.Save(DEFAULT_ROOT_KEY, DEFAULT_KEY, 'History', [soCompress]);
  Form1.TrayIcon1.Icon := LoadIcon(HInstance, PChar(String(Functions.Q(SettingsDB.Monitoring, 'MAINICON', '_DISABLED'))));
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


//UpdateList
procedure UpdateList;
var
  i: Integer;
  DateNow: TDateTime;
begin
  DateNow := Now;

  for i := DynamicData.GetLength-1 downto 0 do begin
    if SecondsBetween(DynamicData.GetValue(i, 'DateTime'), DateNow) < SettingsDB.RemoveAfter then Break;
    if not DynamicData.GetValue(i, 'Favorite') then DynamicData.DeleteData(i);
  end;
end;
//UpdateList


//QueryShutdown
procedure QueryShutdown(BS: TBlockShutdown);
begin
  BS.CreateReason('Saving clipboard history...');
  Form1.DisableClipboard;
  SaveSettings;
  Form1.TrayIcon1.Destroy;
  BS.DestroyReason;
  TerminateProcess(GetCurrentProcess, 0);
end;
//QueryShutdown


//ClipboardUpdate
procedure ClipboardUpdate;
begin
  Form1.TrayIcon1.Icon := LoadIcon(HInstance, '_NEW_TEXT');
  Wait(1000);
  Form1.TrayIcon1.Icon := LoadIcon(HInstance, 'MAINICON');
  EndThread(0);
end;
//ClipboardUpdate


//ClipboardChanged
procedure TForm1.ClipboardChanged(var Msg: TMessage);
var
  Content: WideString;
  i: Integer;
  ID: LongWord;
  DateTime: TDateTime;
  isSame, isFavorite: Boolean;
begin
  if not AllowClipboard then Exit;
  if not SettingsDB.Monitoring then Exit;

  try
    Content := TNTClipboard.AsWideText;
  except
  end;

  if (Length(Content) <= 0) or ((Length(Content) > SettingsDB.MaxSize) and SettingsDB.isSizeLimited) then Exit;
  if (Content = DynamicData.GetValue(0, 'Content')) then Exit;

  //Remove duplicates
  if SettingsDB.PreventDuplicates then begin
    for i := DynamicData.GetLength-1 downto 0 do begin
      isSame := (Content = DynamicData.GetValue(i, 'Content'));
      isFavorite := DynamicData.GetValue(i, 'Favorite');
      if isSame and (not isFavorite) then DynamicData.DeleteData(i);
    end;
  end;

  BeginThread(nil, 0, Addr(ClipboardUpdate), nil, 0, ID);
  DateTime := Now;

  DynamicData.CreateData(0);
  DynamicData.SetValue(0, 'UID', MilliSecondsBetween(DateTime, 0));
  DynamicData.SetValue(0, 'DateTime', DateTime);
  DynamicData.SetValue(0, 'Content', Content);
  DynamicData.SetValue(0, 'Favorite', False);
end;
//ClipboardChanged


//FormatSize
function FormatSize(x: Integer): String;
begin
  Result := IntToStr(x);
  if x >= (1024) then Result := Format('%d KB', [Round(x/1024)]);
  if x >= (1024*1024) then Result := Format('%d MB', [Round(x/(1024*1024))]);
end;
//FormatSize


//GetFormatBySize
function GetFormatBySize: String;
begin
  Result := '';

  if SettingsDB.ShowBySize <> 0 then begin
    Result := IntToStr(SettingsDB.ShowBySize) + 'B';
    if (SettingsDB.ShowBySize mod 1024) = 0 then Result := IntToStr(Round(SettingsDB.ShowBySize/1024)) + 'K';
    if (SettingsDB.ShowBySize mod (1024*1024)) = 0 then Result := IntToStr(Round(SettingsDB.ShowBySize/(1024*1024))) + 'M';

    case SettingsDB.ShowEquality of
      0: Result := '=' + Result;
      1: Result := '>' + Result;
      2: Result := '<' + Result;
    end;
  end;
end;
//GetFormatBySize


//SetFormatBySize
function SetFormatBySize(S: String): Boolean;
var
  i, Multiplier: Integer;
  ShowEquality: Integer;
begin
  Result := False;

  if S = '' then begin
    SettingsDB.ShowBySize := 0;
    Result := True;
    Exit;
  end;

  case Ord(S[1]) of
    Ord('='): ShowEquality := 0;
    Ord('>'): ShowEquality := 1;
    Ord('<'): ShowEquality := 2;
  else Exit;
  end;

  case Ord(S[Length(S)]) of
    Ord('B'): Multiplier := 1;
    Ord('K'): Multiplier := 1024;
    Ord('M'): Multiplier := 1024*1024;
  else Exit;
  end;

  try
    i := StrToInt(Copy(S, 2, Length(S)-2));
  except
    Exit;
  end;

  if (i > 1024) or (i < 0) then Exit;
  SettingsDB.ShowBySize := i*Multiplier;
  SettingsDB.ShowEquality := ShowEquality;
  Result := True;
end;
//SetFormatBySize


//AddItem
procedure TForm1.AddItem(ArrayIndex, ListIndex, Position: Integer);
var
  Content: WideString;
  DateTime: TDateTime;
  UID: Int64;
  isFavorite: Boolean;
begin
  Content := DynamicData.GetValue(ArrayIndex, 'Content');
  DateTime := DynamicData.GetValue(ArrayIndex, 'DateTime');
  UID := DynamicData.GetValue(ArrayIndex, 'UID');
  isFavorite := DynamicData.GetValue(ArrayIndex, 'Favorite');

  TNTStringGrid1.Cells[0, ListIndex] := ' ' + FormatDate(DateTime);
  TNTStringGrid1.Cells[2, ListIndex] := ' ' + FormatSize(Length(Content));
  TNTStringGrid1.Cells[1, ListIndex] := Trim(TNT_WideStringReplace(Copy(Content, Position, 100), #10, ' ', [rfReplaceAll]));
  TNTStringGrid1.Cells[3, ListIndex] := ' ' + WideString(WideChar(10060));
  TNTStringGrid1.Cells[4, ListIndex] := IntToStr(UID);
  TNTStringGrid1.Cells[5, ListIndex] := IntToStr(Integer(isFavorite));
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
  if (Len > 0) and (TNTStringGrid1.Cells[4, 0] = '') then begin
    PrepareList(0);
    Exit;
  end;

  if Len > 0 then begin
    TNTStringGrid1.ColWidths[0] := COLS[0];
    TNTStringGrid1.ColWidths[2] := COLS[2];
    TNTStringGrid1.ColWidths[3] := COLS[3];
    TNTStringGrid1.GridLineWidth := 1;
    StaticText2.Visible := False;
  end else begin
    HideList;
    StaticText2.Top := Round((TNTStringGrid1.Height-StaticText2.Height)/2) + TNTStringGrid1.Top;
    StaticText2.Left := Round((TNTStringGrid1.Width-StaticText2.Width)/2);
    StaticText2.Visible := True;
  end;

  if ItemsPerPage <= Len then begin
    TNTStringGrid1.ColWidths[1] := COLS[1]-Scroll.Width;
    Scroll.Max := Len;
    Scroll.Visible := True;
  end else begin
    TNTStringGrid1.ColWidths[1] := COLS[1];
    Scroll.Visible := False;
  end;
end;
//PrepareList


//BuildList
procedure TForm1.BuildList(ListIndex, ArrayIndex, Count: Integer);
var
  isFavorite: Boolean;
  isMatchingSize: Boolean;
  Content: WideString;
label
  TryAgain;
begin
  if DynamicData.GetLength = 0 then begin
    StaticText1.Caption := TOTAL_ITEMS + '0';
    PrepareList(0);
    Exit;
  end;

  if ListIndex = 0 then TNTStringGrid1.Rows[0].Clear;

TryAgain:
  if (Count > 0) and (ArrayIndex+1 <= DynamicData.GetLength) then begin;
    isMatchingSize := (SettingsDB.ShowBySize = 0);

    if not isMatchingSize then begin
      Content := DynamicData.GetValue(ArrayIndex, 'Content');
      case SettingsDB.ShowEquality of
        0: isMatchingSize := (Length(Content) = SettingsDB.ShowBySize);
        1: isMatchingSize := (Length(Content) > SettingsDB.ShowBySize);
        2: isMatchingSize := (Length(Content) < SettingsDB.ShowBySize);
      end;
    end;

    if not isMatchingSize or (SettingsDB.ShowFavorites and not DynamicData.GetValue(ArrayIndex, 'Favorite')) then begin
      Inc(ArrayIndex);
      goto TryAgain;
    end;

    TNTStringGrid1.RowCount := ListIndex+1;
    AddItem(ArrayIndex, ListIndex, 1);

    Inc(ListIndex);
    Inc(ArrayIndex);
    Dec(Count);
    goto TryAgain;
  end;

  if TNTStringGrid1.Cells[5, 0] <> ''
    then isFavorite := Boolean(StrToInt(TNTStringGrid1.Cells[5, 0]))
    else isFavorite := False;

  StaticText1.Caption := TOTAL_ITEMS + IntToStr(DynamicData.GetLength);
  PrepareList(TNTStringGrid1.RowCount*Integer(not (SettingsDB.ShowFavorites and not isFavorite)))
end;
//BuildList


//Search
procedure TForm1.Search(S: WideString);
var
  i, Position, Count: Integer;
  Content: WideString;
  isFavorite: Boolean;
  isMatchingSize: Boolean;
begin
  Count := 0;
  S := WideLowerCase(S);

  for i := 0 to DynamicData.GetLength-1 do begin
      Content := DynamicData.GetValue(i, 'Content');
      Position := Pos(S, WideLowerCase(Content));
      isFavorite := DynamicData.GetValue(i, 'Favorite');
      if not SettingsDB.ShowFavorites then isFavorite := True;
      isMatchingSize := (SettingsDB.ShowBySize = 0);

      if not isMatchingSize then begin
        case SettingsDB.ShowEquality of
          0: isMatchingSize := (Length(Content) = SettingsDB.ShowBySize);
          1: isMatchingSize := (Length(Content) > SettingsDB.ShowBySize);
          2: isMatchingSize := (Length(Content) < SettingsDB.ShowBySize);
        end;
      end;

      if (Position > 0) and isFavorite and isMatchingSize then begin
        if Position > 1 then Position := Position - 35;
        if Position < 1 then Position := 1;
        AddItem(i, Count, Position);
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
var
  UID: Int64;
begin
  if SearchMode or (not Scroll.Visible) then Exit;
  if (TNTStringGrid1.RowCount - (TNTStringGrid1.TopRow + ItemsPerPage)) > 2 then Exit;
  if TNTStringGrid1.RowCount > DynamicData.GetLength then Exit;
  UID := StrToInt64(TNTStringGrid1.Cells[4, TNTStringGrid1.RowCount-1]);
  BuildList(TNTStringGrid1.RowCount-1, DynamicData.FindIndex(0, 'UID', UID), APPEND_ITEMS);
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
  SetQueryShutdown(QueryShutdown);

  Scroll := TATScroll.Create(Self);
  Scroll.Parent := Form1;
  Scroll.Align := alNone;
  Scroll.Kind := sbVertical;
  Scroll.OnChange := ScrollChangeVertical;
  Scroll.DisableMarks := True;
  Scroll.Min := 0;
  Scroll.Width := 16;
  Scroll.Height := TNTStringGrid1.Height-2;
  Scroll.Top := TNTStringGrid1.Top+1;
  Scroll.Left := TNTStringGrid1.Width - Scroll.Width-1;

  TrayIcon1.Title := TOTAL_ITEMS + IntToStr(DynamicData.GetLength);
  TrayIcon1.AddToTray;

  Timer1.Enabled := True;
  Timer2.Interval := SEARCH_DELAY;
  Timer3.Interval := SettingsDB.AutoSaveAfter*1000;
  Timer3.Enabled := True;
  Timer5.Enabled := True;
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
  BuildList(0, 0, ItemsPerPage*2);
  TNTStringGrid1.Selection := TGridRect(Rect(0,-1,0,-1));

  TNTEdit1.Text := '';
  Timer4.Enabled := True;
  TNTStringGrid1.SetFocus;
end;


procedure TForm1.FormHide(Sender: TObject);
var
  Msg: TMessage;
  Index: Integer;
  isFavorite: Boolean;
begin
  Application.OnDeactivate := nil;
  Timer4.Enabled := False;
  EnableClipboard;

  if (SaveClipboard <> 0) and SettingsDB.Monitoring then begin
    Index := DynamicData.FindIndex(0, 'UID', SaveClipboard);
    isFavorite := False;
    if Index > -1 then isFavorite := DynamicData.GetValue(Index, 'Favorite');
    if Index > 0 then DynamicData.DeleteData(Index);
    ClipboardChanged(Msg);
    DynamicData.SetValue(0, 'Favorite', isFavorite);
  end;

  SaveClipboard := 0;
end;


procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  PopupMenu1.Destroy;
  TrayIcon1.OnAction := nil;
  SaveSettings;
  TrayIcon1.Destroy;
end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  UpdateList;
  TrayIcon1.Title := TOTAL_ITEMS + IntToStr(DynamicData.GetLength);
  Timer1.Enabled := True;
end;


procedure TForm1.Timer2Timer(Sender: TObject);
begin
  Timer2.Enabled := False;
  if (TNTEdit1.Text = '') then Exit;
  SearchMode := True;
  HideList;
  Wait(10);
  Search(TNTEdit1.Text);
end;


procedure TForm1.Timer3Timer(Sender: TObject);
begin
  if Form1.Visible then Exit;
  Timer1Timer(nil);
  Timer1.Enabled := False;
  SaveSettings;
  Timer1.Enabled := True;
end;


procedure TForm1.DeleteRow(ARow: Integer);
var
  Index: Integer;
  LastIndex: Integer;
begin
  Index := DynamicData.FindIndex(0, 'UID', StrToInt64(TNTStringGrid1.Cells[4, ARow]));
  LastIndex := DynamicData.FindIndex(0, 'UID', StrToInt64(TNTStringGrid1.Cells[4, TNTStringGrid1.RowCount-1]))-1;
  PrepareList(TNTStringGrid1.RowCount-1);
  THackGrid(TNTStringGrid1).DeleteRow(ARow);
  DynamicData.DeleteData(Index);
  TNTStringGrid1.Selection := TGridRect(Rect(0,-1,0,-1));

  if not SearchMode
    then BuildList(TNTStringGrid1.RowCount, LastIndex+1, 1)
    else StaticText1.Caption := TOTAL_FOUND + IntToStr(StrToInt(StringReplace(StaticText1.Caption, TOTAL_FOUND, '', [rfReplaceAll, rfIgnoreCase]))-1);

  if SearchMode and (Index > TNTStringGrid1.RowCount-ItemsPerPage) then begin
    if TNTStringGrid1.TopRow-1 < 0 then Exit;
    TNTStringGrid1.TopRow :=  TNTStringGrid1.TopRow-1;
    Scroll.Position := Scroll.Position-1;
  end;

  if (not SearchMode) and (Index > DynamicData.GetLength-ItemsPerPage) then begin
    if TNTStringGrid1.TopRow-1 < 0 then Exit;
    TNTStringGrid1.TopRow :=  TNTStringGrid1.TopRow-1;
    Scroll.Position := Scroll.Position-1;
  end;
end;


procedure TForm1.TNTStringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  CanSelect := False;
  if ACol = 3 then Exit;
  if not (GetKeyState(VK_LBUTTON) < 0) then Exit; //This used to cancel second event when button gets released
  Mouse_Event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0); //Release mouse button so event doesn't happen infinite times

  if ACol = 1 then TNTStringGrid1.Selection := TGridRect(Rect(1,ARow,1,ARow));
end;


procedure TForm1.TNTStringGrid1DblClick(Sender: TObject);
var
  Point: TPoint;
  ACol, ARow: Integer;
begin
  if TNTStringGrid1.Selection.Top < 0 then Exit;
  if TNTStringGrid1.Selection.Left <> 1 then Exit;
  if TNTStringGrid1.Selection.Right <> 1 then Exit;

  ACol := TNTStringGrid1.Selection.Left;
  ARow := TNTStringGrid1.Selection.Top;
  Point := TNTStringGrid1.ScreenToClient(Mouse.CursorPos);

  if PtInRect(TNTStringGrid1.CellRect(ACol, ARow), Point) then Copy1Click(nil);
end;


procedure TForm1.TNTStringGrid1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Point: TPoint;
  i, Index: Integer;
begin
  if Button = mbLeft then begin
    Point := TNTStringGrid1.ScreenToClient(Mouse.CursorPos);

    for i := TNTStringGrid1.TopRow to TNTStringGrid1.TopRow+TNTStringGrid1.VisibleRowCount+1 do begin
      if PtInRect(TNTStringGrid1.CellRect(3, i), Point) then begin
        TNTStringGrid1.Selection := TGridRect(Rect(1,i,1,i));
        doSelect := False;
        keybd_event(VK_DELETE, 0, 0, 0);
        keybd_event(VK_DELETE, 0, $80, 0);
        Break;
      end;
    end;
  end;


  if Button = mbRight then begin
    PopupMenu2.Items[0].Visible := TNTStringGrid1.Selection.Top >= 0;

    if TNTStringGrid1.Selection.Top >= 0 then begin
      Index := DynamicData.FindIndex(0, 'UID', StrToInt64(TNTStringGrid1.Cells[4, TNTStringGrid1.Selection.Top]));

      if DynamicData.GetValue(Index, 'Favorite')
        then PopupMenu2.Items[0].Items[2].Caption := 'Unfavorite'
        else PopupMenu2.Items[0].Items[2].Caption := 'Favorite';
    end;

    if SettingsDB.ShowFavorites
      then PopupMenu2.Items[1].Items[0].Caption := 'Hide Favorites'
      else PopupMenu2.Items[1].Items[0].Caption := 'Show Favorites';

    GetCursorPos(Point);
    PopupMenu2.Popup(Point.X, Point.Y);
  end;
end;


procedure TForm1.TNTStringGrid1Exit(Sender: TObject);
begin
  TNTStringGrid1.Selection := TGridRect(Rect(0,-1,0,-1));
end;


procedure TForm1.TNTStringGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Row: Integer;
  isScrolledOut: Boolean;
begin
  if (Key = VK_PRIOR) or (Key = VK_NEXT) then Key := 0;

  if (Key = VK_DELETE) and (TNTStringGrid1.Selection.Top >= 0) then begin
    Row := TNTStringGrid1.Selection.Top;
    DeleteRow(Row);

    if not doSelect then begin
      doSelect := True;
      Exit;
    end;

    if Row >= TNTStringGrid1.RowCount then Row := Row-1;
    if (TNTStringGrid1.RowCount = 1) and (TNTStringGrid1.Cells[4, 0] = '') then Exit;
    if Row < TNTStringGrid1.TopRow then Scroll.Position := Row;
    TNTStringGrid1.Selection := TGridRect(Rect(1,Row,1,Row));

    isScrolledOut := (Row < TNTStringGrid1.TopRow);
    if isScrolledOut or (Row+1 > (TNTStringGrid1.TopRow + ItemsPerPage-1)) then begin
      Scroll.Position := Row - (ItemsPerPage-1);
      TNTStringGrid1.Repaint;
    end;
  end;

  if (Key = VK_DOWN) then begin
    Row := TNTStringGrid1.Selection.Top;
    if Row < 0 then Exit;
    if Row+1 >= TNTStringGrid1.RowCount then Exit;
    TNTStringGrid1.Selection := TGridRect(Rect(1,Row+1,1,Row+1));

    isScrolledOut := (Row < TNTStringGrid1.TopRow);
    if isScrolledOut or (Row+1 > (TNTStringGrid1.TopRow + ItemsPerPage-1)) then begin
      Scroll.Position := Row - (ItemsPerPage-2);
      TNTStringGrid1.Repaint;
    end;
  end;

  if (Key = VK_UP) then begin
    Row := TNTStringGrid1.Selection.Top;
    if Row <= 0 then Exit;
    TNTStringGrid1.Selection := TGridRect(Rect(1,Row-1,1,Row-1));

    isScrolledOut := (Row > (TNTStringGrid1.TopRow + ItemsPerPage-1));
    if isScrolledOut or (Row-1 < TNTStringGrid1.TopRow) then begin
      Scroll.Position := Row-1;
      TNTStringGrid1.Repaint;
    end;
  end;
end;


procedure TForm1.Copy1Click(Sender: TObject);
var
  Index: Integer;
begin
  SaveClipboard := StrToInt64(TNTStringGrid1.Cells[4, TNTStringGrid1.Selection.Top]);
  TNTStringGrid1.Selection := TGridRect(Rect(0,-1,0,-1));
  Index := DynamicData.FindIndex(0, 'UID', SaveClipboard);
  TNTClipboard.AsWideText := DynamicData.GetValue(Index, 'Content');
end;


procedure TForm1.Delete1Click(Sender: TObject);
begin
  DeleteRow(TNTStringGrid1.Selection.Top);
  TNTStringGrid1.Selection := TGridRect(Rect(0,-1,0,-1));
end;


procedure TForm1.Favorite2Click(Sender: TObject);
var
  Index, Row: Int64;
  isFavorite: Boolean;
begin
  Row := TNTStringGrid1.Selection.Top;
  TNTStringGrid1.Selection := TGridRect(Rect(0,-1,0,-1));

  Index := DynamicData.FindIndex(0, 'UID', StrToInt64(TNTStringGrid1.Cells[4, Row]));
  isFavorite := DynamicData.GetValue(Index, 'Favorite');
  DynamicData.SetValue(Index, 'Favorite', not isFavorite);
  TNTStringGrid1.Cells[5, Row] := IntToStr(Integer(not isFavorite));
  TNTStringGrid1.Repaint;
end;


procedure TForm1.ShowFavorites1Click(Sender: TObject);
begin
  TNTStringGrid1.Selection := TGridRect(Rect(0,-1,0,-1));
  SettingsDB.ShowFavorites := not SettingsDB.ShowFavorites;
  Scroll.Position := 0;

  if SearchMode
    then Search(TNTEdit1.Text)
    else BuildList(0, 0, ItemsPerPage*2);
end;


procedure TForm1.ShowBySize1Click(Sender: TObject);
var
  SizeFormat: WideString;
  i1, i2: Int64;
begin
  i1 := SettingsDB.ShowBySize;
  i2 := SettingsDB.ShowEquality;

  SizeFormat := WideInputBox('Show By Size', 'Format: (=|>|<)1024(B|K|M)', GetFormatBySize, Form1.Font);
  if not SetFormatBySize(SizeFormat) then ShowMessage('Incorrect size format!');
  StaticText3.Caption := GetFormatBySize;

  if (i1 <> SettingsDB.ShowBySize) or (i2 <> SettingsDB.ShowEquality) then begin
    TNTStringGrid1.Selection := TGridRect(Rect(0,-1,0,-1));
    Scroll.Position := 0;

    if SearchMode
      then Search(TNTEdit1.Text)
      else BuildList(0, 0, ItemsPerPage*2);
  end;
end;


procedure TForm1.StaticText3Click(Sender: TObject);
begin
  ShowBySize1Click(nil);
end;


procedure TForm1.ScrollChangeVertical(Sender: TObject);
begin
  TNTStringGrid1.TopRow := Scroll.Position;
  CheckListEnding;
end;


procedure TForm1.TNTStringGrid1MouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if TNTStringGrid1.RowCount = TNTStringGrid1.VisibleRowCount then Exit;
  CheckListEnding;

  if TNTStringGrid1.TopRow + ROWS_PER_SCROLL > TNTStringGrid1.RowCount - ItemsPerPage
    then TNTStringGrid1.TopRow := TNTStringGrid1.RowCount - ItemsPerPage
    else TNTStringGrid1.TopRow := TNTStringGrid1.TopRow + ROWS_PER_SCROLL;

  Scroll.Position := TNTStringGrid1.TopRow;
end;


procedure TForm1.TNTStringGrid1MouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if TNTStringGrid1.RowCount = TNTStringGrid1.VisibleRowCount then Exit;

  if TNTStringGrid1.TopRow - ROWS_PER_SCROLL < 0
    then TNTStringGrid1.TopRow := 0
    else TNTStringGrid1.TopRow := TNTStringGrid1.TopRow - ROWS_PER_SCROLL;

  Scroll.Position := TNTStringGrid1.TopRow;
end;


procedure TForm1.TNTStringGrid1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if not TNTStringGrid1.Focused then TNTStringGrid1.SetFocus;
end;


procedure TForm1.DisableClipboard1Click(Sender: TObject);
begin
  SettingsDB.Monitoring := not SettingsDB.Monitoring;
  PopupMenu1.Items[0].Caption := Functions.Q(SettingsDB.Monitoring, 'Disable', 'Enable') + ' Clipboard';
  TrayIcon1.Icon := LoadIcon(HInstance, PChar(String(Functions.Q(SettingsDB.Monitoring, 'MAINICON', '_DISABLED'))));
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
    if (SavedSearch <> '') then BuildList(0, 0, ItemsPerPage*2);
    if (SavedSearch <> '') then Scroll.Position := 0;
    Result := True;
  end;

  SavedSearch := TNTEdit1.Text;
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


procedure TForm1.Timer5Timer(Sender: TObject);
var
  Msg: TMessage;
begin
  Form1.ClipboardChanged(Msg);
end;


procedure TForm1.TNTStringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  isFavorite: Boolean;
begin
  TNTStringGrid1.Canvas.Font.Name := TNTStringGrid1.Font.Name;
  TNTStringGrid1.Canvas.Font.Size := TNTStringGrid1.Font.Size;

  if TNTStringGrid1.Cells[5, ARow] <> ''
    then isFavorite := Boolean(StrToInt(TNTStringGrid1.Cells[5, ARow]))
    else isFavorite := False;

  if gdFixed in State then begin
    TNTStringGrid1.Canvas.Brush.Color := FLAT_STYLE_DOWN_COLOR;
    TNTStringGrid1.Canvas.Font.Color := clBlack;
  end else if gdSelected in State then begin
    TNTStringGrid1.Canvas.Brush.Color := FLAT_STYLE_BLUE;
    TNTStringGrid1.Canvas.Font.Color := clWhite;
  end else if isFavorite then begin
    TNTStringGrid1.Canvas.Brush.Color := $00D7FFFF;
    TNTStringGrid1.Canvas.Font.Color := clBlack;
  end else begin
    TNTStringGrid1.Canvas.Brush.Color := $00FFFFFF;
    TNTStringGrid1.Canvas.Font.Color := clBlack;
  end;

  TNTStringGrid1.Canvas.FillRect(Rect);
  WideCanvasTextOut(TNTStringGrid1.Canvas, Rect.Left+3, Rect.Top+2, TNTStringGrid1.Cells[ACol, ARow]);

  //Remove last pixels in col 1 (simulate eclipsis)
  if ACol = 1 then begin
    Rect.Left := Rect.Left + ((Rect.Right-Rect.Left) - ECLIPSIS_SIZE);
    TNTStringGrid1.Canvas.FillRect(Rect);
  end;

  //Redraw col lines becasue WideCanvasTextOut overdraw them
  if ACol > 0 then begin
    Rect.Left := Rect.Right;
    Rect.Right := Rect.Right+1;
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
  SettingsDB.PreventDuplicates := True; //Prevent duplicated saved
  SettingsDB.MaxItems := 2000; //Max items
  SettingsDB.MaxSize := 1024*1024*10; //Max size
  SettingsDB.RemoveAfter := 60*60*24*30; //Seconds (1 month)
  SettingsDB.AutoSaveAfter := 60*60*2; //Seconds (2 hours)
  SettingsDB.isItemsLimited := True; //Item limitation
  SettingsDB.isSizeLimited := True; //Size limitation
  SettingsDB.isTimeLimited := True; //Time limitation
  SettingsDB.isAutoSave := True; //Autosave
  SettingsDB.TimeIndex := 4; //Time index in combobox
  SettingsDB.SizeIndex := 2; //Size index in combobox
  SettingsDB.AutoSaveIndex := 1; //AutoSave index in combobox
  SettingsDB.ShowFavorites := False; //Show only favorites
  SettingsDB.ShowBySize := 0; //Size in bytes
  SettingsDB.ShowEquality := 0; //0 - Equals, 1 - Bigger, 2 - Smaller
end.
