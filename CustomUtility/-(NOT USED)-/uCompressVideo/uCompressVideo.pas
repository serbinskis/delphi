unit uCompressVideo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ShellAPI, StrUtils, Menus, ZipForge;

type
  TCompressVideo = class(TForm)
    ListBox1: TListBox;
    Button1: TButton;
    ComboBox1: TComboBox;
    Label1: TLabel;
    ComboBox2: TComboBox;
    Label2: TLabel;
    ComboBox5: TComboBox;
    Label3: TLabel;
    ComboBox3: TComboBox;
    Label4: TLabel;
    ComboBox4: TComboBox;
    Label5: TLabel;
    PopupMenu1: TPopupMenu;
    Open1: TMenuItem;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Button1Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure CreateDialog(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
  public
    { Public declarations }
  end;

type
  NTSTATUS = LongInt;
  TProcFunction = function(ProcHandle: THandle): NTSTATUS; stdcall;

const
  AllowedFormats = '.rm .3gp .3g2 .mpg .mpeg .ts .mts .mov .dif .wmv .asf .vfw .avi .avs .amv .mkv .webm .mp4 .flv .fli .gif .vob .xv .yuv .cpk .bik .ogm .h264 .264 .m4v .f4v';
  STATUS_SUCCESS = $00000000;
  PROCESS_SUSPEND_RESUME = $0800;

var
  CompressVideo: TCompressVideo;
  ReadOnly, AppTerminated, Suspended: Boolean;
  PID: Integer;
  VideoInput, VideoOutput: String;

implementation

{$R *.dfm}

//External functions
function AttachConsole(dwProcessID: Integer): Boolean; stdcall; external 'kernel32.dll';


//SuspendProcess
function SuspendProcess(const PID: DWORD): Boolean;
var
  LibHandle: THandle;
  ProcHandle: THandle;
  NtSuspendProcess: TProcFunction;
begin
  Result := False;
  LibHandle := SafeLoadLibrary('ntdll.dll');
  if LibHandle <> 0 then
  try
    @NtSuspendProcess := GetProcAddress(LibHandle, 'NtSuspendProcess');
    if @NtSuspendProcess <> nil then
    begin
      ProcHandle := OpenProcess(PROCESS_SUSPEND_RESUME, False, PID);
      if ProcHandle <> 0 then
      try
        Result := NtSuspendProcess(ProcHandle) = STATUS_SUCCESS;
      finally
        CloseHandle(ProcHandle);
      end;
    end;
  finally
    FreeLibrary(LibHandle);
  end;
end;
//SuspendProcess


//ResumeProcess
function ResumeProcess(const PID: DWORD): Boolean;
var
  LibHandle: THandle;
  ProcHandle: THandle;
  NtResumeProcess: TProcFunction;
begin
  Result := False;
  LibHandle := SafeLoadLibrary('ntdll.dll');
  if LibHandle <> 0 then
  try
    @NtResumeProcess := GetProcAddress(LibHandle, 'NtResumeProcess');
    if @NtResumeProcess <> nil then
    begin
      ProcHandle := OpenProcess(PROCESS_SUSPEND_RESUME, False, PID);
      if ProcHandle <> 0 then
      try
        Result := NtResumeProcess(ProcHandle) = STATUS_SUCCESS;
      finally
        CloseHandle(ProcHandle);
      end;
    end;
  finally
    FreeLibrary(LibHandle);
  end;
end;
//ResumeProcess


//Wait
procedure Wait(millisecs: Integer);
var
  tick: dword;
  AnEvent: THandle;
begin
  AnEvent := CreateEvent(nil, False, False, nil);
  try
    tick := GetTickCount + dword(millisecs);
    while (millisecs > 0) and (MsgWaitForMultipleObjects(1, AnEvent, False, millisecs, QS_ALLINPUT) <> WAIT_TIMEOUT) do begin
      Application.ProcessMessages;
      if Application.Terminated then Exit;
      millisecs := tick - GetTickcount;
    end;
  finally
    CloseHandle(AnEvent);
  end;
end;
//Wait


//RecursiveAdd
procedure RecursiveAdd(path: String);
var
  srSearch: TSearchRec;
  fileName: String;
begin
  if FindFirst(path + '\*.*', faAnyFile and not faDirectory, srSearch) = 0 then begin
    repeat
      fileName := path + '\' + srSearch.Name;
      if AnsiContainsText(AllowedFormats, ExtractFileExt(fileName))
        then CompressVideo.Listbox1.Items.Add(fileName)
    until FindNext(srSearch) <> 0;
    FindClose(srSearch);
  end;
end;
//RecursiveAdd


//GatherDuration
function GatherDuration(Info: String): Integer;
var
  Duration: String;
  i, Hours, Minutes, Seconds: Integer;
begin
  i := Pos('Duration: ', Info);
  Duration := Copy(Info, i+10, 8);

  Hours := StrToInt(Copy(Duration, 1, 2));
  Minutes := StrToInt(Copy(Duration, 4, 2));
  Seconds := StrToInt(Copy(Duration, 7, 2));
  Result := Seconds + (Minutes*60) + (Hours*60*60);
end;
//GatherDuration


//GatherTime
function GatherTime(Info: String): Integer;
var
  Time: String;
  i, Hours, Minutes, Seconds: Integer;
begin
  i := Pos('time=', Info);
  Time := Copy(Info, i+5, 8);

  Hours := StrToInt(Copy(Time, 1, 2));
  Minutes := StrToInt(Copy(Time, 4, 2));
  Seconds := StrToInt(Copy(Time, 7, 2));
  Result := Seconds + (Minutes*60) + (Hours*60*60);
end;
//GatherTime


//SetPercent
procedure SetPercent(Index, Percent: Integer);
var
  LCaption: String;
  P: Integer;
begin
  LCaption := CompressVideo.ListBox1.Items.Strings[Index];

  if LCaption[1] = '[' then begin
    P := Pos('-', LCaption);
    LCaption := Copy(LCaption, P+2, Length(LCaption));
  end;

  CompressVideo.ListBox1.Items.Delete(Index);
  CompressVideo.ListBox1.Items.Insert(Index, '[' + IntToStr(Percent) + '%] - ' + LCaption);
  Index := Index - 28;
  if Index < 0 then Index := 0;
  if Index > 0 then Index := Index + 5;
  if Index > CompressVideo.ListBox1.TopIndex then CompressVideo.ListBox1.TopIndex := Index;
end;
//SetPercent


//ExecuteFFMPEG
procedure ExecuteFFMPEG(Executable, Parametrs: String; HWND: WORD; Index: Integer);
const
  BufferSize = 1024*1024;
var
  CharsReaden, i: DWORD;
  CursorPositionY: SHORT;
  Info, FileName: String;
  startUpInfo: TStartUpInfo;
  ProcInfo: TProcessInformation;
  StdOutHandle: THandle;
  Buffer: PChar;
  Coord: TCoord;
  ConsoleScreenBufferInfo: TConsoleScreenBufferInfo;
  TimeSeconds, DurationSeconds, Percent, AllowedCheck: Integer;
begin
  FillChar(startUpInfo, SizeOf(TStartUpInfo), 0);
  startUpInfo.cb := SizeOf(TStartUpInfo);
  startUpInfo.wShowWindow := HWND;
  startUpInfo.dwFlags := STARTF_USESHOWWINDOW;
  FileName := CompressVideo.ListBox1.Items[Index];

  TimeSeconds := 0;
  DurationSeconds := 0;
  Percent := 0;
  AllowedCheck := 0;

  if CreateProcess(PChar(Executable), PChar('"' + Executable + '"' + Parametrs), nil, nil, true, NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcInfo) then begin
    PID := ProcInfo.dwProcessId;
    while not AttachConsole(ProcInfo.dwProcessId) do begin
      AllowedCheck := AllowedCheck + 1;
      if AllowedCheck > 50 then Break;
      Wait(100);
    end;

    GetMem(Buffer, BufferSize);
    StdOutHandle := GetStdHandle(STD_OUTPUT_HANDLE);
    Coord.X := 0;
    CursorPositionY := 0;

    while WaitForSingleObject(ProcInfo.hProcess, 0) = WAIT_TIMEOUT do begin
      GetConsoleScreenBufferInfo(StdOutHandle, ConsoleScreenBufferInfo);
      while Suspended do if AppTerminated then Exit else Wait(1000);

      Info := '';
      if CursorPositionY = ConsoleScreenBufferInfo.dwCursorPosition.Y+1 then begin
        Coord.Y := ConsoleScreenBufferInfo.dwCursorPosition.Y;
        ReadConsoleOutputCharacter(StdOutHandle, Buffer, ConsoleScreenBufferInfo.dwSize.X, Coord, CharsReaden);
        Info := TrimRight(Copy(Buffer, 1, ConsoleScreenBufferInfo.dwSize.X));
      end else begin
        for i := CursorPositionY to ConsoleScreenBufferInfo.dwCursorPosition.Y do begin
          Coord.Y := i;
          ReadConsoleOutputCharacter(StdOutHandle, Buffer, ConsoleScreenBufferInfo.dwSize.X, Coord, CharsReaden);
          Info := Info + TrimRight(Copy(Buffer, 1, ConsoleScreenBufferInfo.dwSize.X));
        end;
      end;

      if DurationSeconds = 0 then if AnsiContainsText(Info, 'Duration: ') then DurationSeconds := GatherDuration(Info);
      if AnsiContainsText(Info, ' time=') then TimeSeconds := GatherTime(Info);

      if (TimeSeconds <> 0) and (DurationSeconds <> 0) then Percent := Round(TimeSeconds/DurationSeconds*100);
      SetPercent(Index, Percent);
      CursorPositionY := ConsoleScreenBufferInfo.dwCursorPosition.Y+1;
      Wait(1000);
    end;

    if AppTerminated then Exit;
    if DurationSeconds <> 0 then while not DeleteFile(FileName) do Wait(100);
    if DurationSeconds <> 0 then while not MoveFile(PChar(ExtractFilePath(FileName) + 'temp_' + ExtractFileName(FileName)), PChar(FileName)) do Wait(100);
    if DurationSeconds <> 0 then SetPercent(Index, 100);
    FreeConsole;
  end;
end;
//ExecuteFFMPEG


//BeginButton
procedure TCompressVideo.Button1Click(Sender: TObject);
var
  i, P: Integer;
  LCaption: String;
  Index: Integer;
  Executable, Parametrs: String;
  vFPS, vSize, vKBS, aKBS, aRate: String;
  ZipForge: TZipForge;
begin
  Index := 0;
  ReadOnly := True;
  Button1.Enabled := False;
  ComboBox1.Enabled := False;
  ComboBox2.Enabled := False;
  ComboBox3.Enabled := False;
  ComboBox4.Enabled := False;
  ComboBox5.Enabled := False;

  for i := 0 to ListBox1.Items.Count-1 do begin
    LCaption := ListBox1.Items.Strings[i];
    if LCaption[1] = '[' then begin
      P := Pos('-', LCaption);
      ListBox1.Items.Delete(i);
      ListBox1.Items.Insert(i, Copy(LCaption, P+2, Length(LCaption)));
    end;
  end;

  if ListBox1.Items.Count > 0 then begin
    ZipForge := TZipForge.Create(nil);
    ZipForge.OpenArchive(TResourceStream.Create(HInstance, 'ARCHIVE', RT_RCDATA), False);
    ZipForge.BaseDir := PChar(GetEnvironmentVariable('TEMP'));
    ZipForge.ExtractFiles('ffmpeg.exe');
    ZipForge.CloseArchive();
    Executable := GetEnvironmentVariable('TEMP') +'\ffmpeg.exe';
  end;

  while Index <= ListBox1.Items.Count-1 do begin
    VideoInput := ListBox1.Items[Index];
    VideoOutput := ExtractFilePath(VideoInput) + 'temp_' + ExtractFileName(VideoInput);

    vFPS := ComboBox1.Text;
    vSize := ComboBox2.Text;
    vKBS := ComboBox3.Text;
    aKBS := ComboBox4.Text;
    aRate := ComboBox5.Text;

    Parametrs := ' -y -i "' + VideoInput + '" -s ' + vSize + ' -b:v ' + vKBS + ' -r ' + vFPS + ' -c:v libx264 -ar ' + aRate + ' -b:a ' + aKBS + ' -c:a aac  "' + VideoOutput + '"';
    ExecuteFFMPEG(Executable, Parametrs, SW_HIDE, Index);
    if AppTerminated then Exit;
    Index := Index + 1;
  end;

  ReadOnly := False;
  Button1.Enabled := True;
  ComboBox1.Enabled := True;
  ComboBox2.Enabled := True;
  ComboBox3.Enabled := True;
  ComboBox4.Enabled := True;
  ComboBox5.Enabled := True;
  DeleteFile(Executable);
end;
//BeginButton


//SetupDialog
procedure SetupDialog();
var
  WindowRect: TRect;
  X, Y: Integer;
  DialogWindow: Thandle;
begin
  while FindWindow(nil, 'Open: Compress Video') = 0 do Sleep(10);
  DialogWindow := FindWindow(nil, 'Open: Compress Video');
  GetWindowRect(DialogWindow, WindowRect);
  X := Round((GetSystemMetrics(SM_CXSCREEN) / 2) - ((WindowRect.Right - WindowRect.Left) / 2));
  Y := Round((GetSystemMetrics(SM_CYSCREEN) / 2) - ((WindowRect.Bottom - WindowRect.Top) / 2));
  while not SetWindowPos(DialogWindow, HWND_TOPMOST, X, Y, 0, 0, SWP_NOSIZE) do Sleep(10);
  SetActiveWindow(DialogWindow);
  SetForegroundWindow(DialogWindow);
  EndThread(0);
end;
//SetupDialog


//CreateDialog
procedure TCompressVideo.CreateDialog(Sender: TObject);
var
  Strings: TStrings;
  id: LongWord;
  i: Integer;
  OpenDialog: TOpenDialog;
begin
  if ReadOnly then Exit;
  OpenDialog := TOpenDialog.Create(nil);
  OpenDialog.Options := [ofHideReadOnly,ofAllowMultiSelect,ofEnableSizing];
  OpenDialog.Title := 'Open: Compress Video';
  OpenDialog.Filter := 'Video File|*.rm;*.3gp;*.3g2;*.mpg;*.mpeg;*.ts;*.mts;*.mov;*.dif;*.wmv;*.asf;*.vfw;*.avi;*.avs;*.amv;*.mkv;*.webm;*.mp4;*.flv;*.fli;*.gif;*.vob;*.xv;*.yuv;*.cpk;*.bik;*.ogm;*.h264;*.264;*.m4v;*.f4v';
  BeginThread(nil, 0, Addr(SetupDialog), nil, 0, id);
  OpenDialog.Execute;
  Strings := OpenDialog.Files;

  for i := 0 to Strings.Count-1 do begin
    Listbox1.Items.Add(Strings[i]);
  end;
end;
//CreateDialog


procedure TCompressVideo.Button2Click(Sender: TObject);
begin
  if ReadOnly then begin
    if Suspended then begin
      Suspended := False;
      Button2.Caption := 'Pause';
      ResumeProcess(PID);
    end else begin
      Suspended := True;
      Button2.Caption := 'Resume';
      SuspendProcess(PID);
    end;
  end;
end;


procedure TCompressVideo.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, True);
end;


procedure TCompressVideo.FormDestroy(Sender: TObject);
begin
  DragAcceptFiles(Handle, False);
end;


procedure TCompressVideo.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  AppTerminated := True;
  TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), PID), 0);
  if fileExists(VideoOutput) then while not DeleteFile(VideoOutput) do Wait(50);
end;


procedure TCompressVideo.ListBox1Click(Sender: TObject);
begin
  ListBox1.Hint := ListBox1.Items.Strings[ListBox1.ItemIndex]
end;


procedure TCompressVideo.WMDropFiles(var Msg: TMessage);
var
  hDrop: THandle;
  FileCount: Integer;
  NameLen: Integer;
  I: Integer;
  S: String;
begin
  hDrop := Msg.wParam;
  if ReadOnly then Exit;
  FileCount := DragQueryFile(hDrop, $FFFFFFFF, nil, 0);

  for I := 0 to FileCount-1 do begin
    NameLen := DragQueryFile(hDrop, I, nil, 0) + 1;
    SetLength(S, NameLen);
    DragQueryFile(hDrop, I, Pointer(S), NameLen);
    if fileExists(S) then begin
      if AnsiContainsText(AllowedFormats, ExtractFileExt(S)) then Listbox1.Items.Add(S);
    end else begin
      RecursiveAdd(Trim(S));
    end;
  end;

  DragFinish(hDrop);
end;


procedure TCompressVideo.ListBox1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i: Integer;
begin
  if (Key = $2E) and (ReadOnly = False) then begin
    if ListBox1.ItemIndex <> -1 then begin
      if ListBox1.ItemIndex-1 > 0 then i := ListBox1.ItemIndex-1 else i := 0;
      ListBox1.Items.Delete(ListBox1.ItemIndex);
      if ListBox1.Items.Count > 0 then Listbox1.Selected[i] := True;
    end;
  end;
end;

end.
