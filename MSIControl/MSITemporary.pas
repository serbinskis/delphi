unit MSITemporary;

interface

uses
  Windows, ShellAPI, StdCtrls, MMSystem, SysUtils, TNTSysUtils, TNTMenus, Menus, Forms, Dialogs, Functions, Classes, Controls,
  Messages, MSIThemes, MSIControl, MD5, uDynamicData;

type
  TForm11 = class(TForm)
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure AddDirectoryClick1(Sender: TObject);
    procedure RemoveDirectoryClick1(Sender: TObject);
    procedure ClearDirectoryClick1(Sender: TObject);
    procedure TrayIcon1RightDown(Sender: TObject);
  protected
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
  public
    { Public declarations }
  end;

const
  DEFAULT_TEMPORARY_KEY = DEFAULT_KEY + '\Temporary';

var
  Form11: TForm11;
  MenuItem: TMenuItem;
  AddMenuItem: TMenuItem;
  RemoveMenuItem: TMenuItem;
  ClearMenuItem: TMenuItem;
  TempDynData: TDynamicData;

implementation

{$R *.dfm}

procedure CreateLink(Path: WideString);
var
  S, FileName, Params: WideString;
  SavedCurrentDir: WideString;
begin
  if (not WideDirectoryExists(Path)) then Exit;
  S := MD5DigestToStr(MD5String(UTFEncode(Path)));
  FileName := 'C:\Windows\Temp\-(' + WideExtractFileName(Path) + '_' + S + ')-';
  if (WideDirectoryExists(FileName)) then Exit;
  Params := '/c mklink /D "' + WideExtractFileName(Path) + '" "' + FileName + '"';

  if (not DeleteDirectory(Path)) then Exit;
  WideCreateDir(FileName);
  SavedCurrentDir := WideGetCurrentDir;
  WideSetCurrentDir(WideExtractFileDir(Path));
  ExecuteWait('cmd.exe', Params, SW_HIDE);
  WideSetCurrentDir(SavedCurrentDir);
end;

procedure TForm11.WMDropFiles(var Msg: TMessage);
var
  i, Count, Len: Integer;
  FileName: WideString;
begin
  SetActiveWindow(Handle);
  SetForegroundWindow(Handle);
  Count := DragQueryFileW(Msg.wParam, $FFFFFFFF, nil, 0);
  Form11.Label1.Caption := 'PROCESSING...';
  Form11.Hint := Form11.Caption;

  for i := 0 to Count-1 do begin
    Len := DragQueryFileW(Msg.wParam, i, nil, 0)+1;
    SetLength(FileName, Len);
    DragQueryFileW(Msg.wParam, i, Pointer(FileName), Len);
    FileName := Trim(FileName);
    Form11.Caption := FileName;
    if (not WideDirectoryExists(FileName)) then Continue;
    if (TempDynData.FindIndex(0, 'Directory', FileName) < 0) then TempDynData.CreateData(-1, -1, ['Directory'], [FileName]);
    CreateLink(FileName);
  end;

  Form11.Label1.Caption := 'PROCESSING DONE!';
  Form11.Caption := Form11.Hint;
  TempDynData.Save(DEFAULT_ROOT_KEY, DEFAULT_TEMPORARY_KEY, 'BINARY_TEMPORARY', []);
end;

procedure TForm11.AddDirectoryClick1;
begin
  if (Form11.Visible) then Exit;
  Form11.Label1.Caption := Form11.Label1.Hint;
  Form11.ShowModal;
end;


procedure TForm11.RemoveDirectoryClick1(Sender: TObject);
var
  i: Integer;
begin
  i := TempDynData.FindIndex(0, 'Directory', TTntMenuItem(Sender).Caption);
  if (i >= 0) then TempDynData.DeleteData(i);
  TempDynData.Save(DEFAULT_ROOT_KEY, DEFAULT_TEMPORARY_KEY, 'BINARY_TEMPORARY', []);
end;


procedure TForm11.ClearDirectoryClick1(Sender: TObject);
begin
  TempDynData.ClearAllData;
  TempDynData.Save(DEFAULT_ROOT_KEY, DEFAULT_TEMPORARY_KEY, 'BINARY_TEMPORARY', []);
end;


procedure TForm11.TrayIcon1RightDown;
var
  i: Integer;
  DirectoryItem: TTntMenuItem;
begin
  RemoveMenuItem.Clear;

  for i := 0 to TempDynData.GetLength-1 do begin
    DirectoryItem := TTntMenuItem.Create(nil);
    DirectoryItem.Caption := TempDynData.GetValue(i, 'Directory');
    DirectoryItem.OnClick := Form11.RemoveDirectoryClick1;
    RemoveMenuItem.Add(DirectoryItem);
  end;
end;


procedure TForm11.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  TempDynData := TDynamicData.Create(['Directory']);
  TempDynData.Load(DEFAULT_ROOT_KEY, DEFAULT_TEMPORARY_KEY, 'BINARY_TEMPORARY', [loRemoveUnused, loOFDelete]);
  for i := 0 to TempDynData.GetLength-1 do CreateLink(TempDynData.GetValue(i, 'Directory'));
  MSIControl.TrayIconCallbacks.Add(@TForm11.TrayIcon1RightDown);
  ChangeTheme(Theme, self);

  DragAcceptFiles(Handle, True);
  ChangeWindowMessageFilter(WM_DROPFILES, MSGFLT_ADD);
  ChangeWindowMessageFilter(WM_COPYGLOBALDATA, MSGFLT_ADD);

  AddMenuItem := TMenuItem.Create(nil);
  AddMenuItem.Caption := 'Add directory';
  AddMenuItem.OnClick := Form11.AddDirectoryClick1;

  RemoveMenuItem := TMenuItem.Create(nil);
  RemoveMenuItem.Caption := 'Remove directory';

  ClearMenuItem := TMenuItem.Create(nil);
  ClearMenuItem.Caption := 'Remove all directory';
  ClearMenuItem.OnClick := Form11.ClearDirectoryClick1;

  MenuItem := TMenuItem.Create(nil);
  MenuItem.Caption := 'Temporary';
  MenuItem.Add([AddMenuItem, RemoveMenuItem, ClearMenuItem]);
  i := Form1.PopupMenu1.Items.IndexOf(Form1.PopupMenu1.Items.Find('Toggle'));
  Form1.PopupMenu1.Items.Insert(i+1, MenuItem);
end;

end.

