unit AutoStart;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, WinXP, StdCtrls, TNTSystem, TNTSysUtils, TNTStdCtrls, uKBDynamic,
  uDynamicData, Functions;

const
  COMPONENETS_PER_ROW = 6;
  DEFAULT_COUNTDOWN_TIME = 5;
  WM_REBUILD_CONTROL = WM_USER + 12787;
  DEFAULT_ROOT_KEY = HKEY_CURRENT_USER;
  DEFAULT_FILENAME = 'AutoStart.bin';

type
  TForm1 = class(TForm)
    procedure EnableClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure NameChange(Sender: TObject);
    procedure CommandChange(Sender: TObject);
    procedure CountdownChange(Sender: TObject);
    procedure StartButton(Sender: TObject);
    procedure DeleteButton(Sender: TObject);
    procedure AddButton(Sender: TObject);
    procedure RebuildEntry(var Msg : TMessage); message WM_REBUILD_CONTROL;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  DynamicData: TDynamicData;

implementation

{$R *.dfm}


//Countdown
procedure Countdown;
var
  i, Counter: Integer;
  P1, P2: TPoint;
  CloseAction: TCloseAction;
begin
  if (DynamicData.GetLength <= 0) or (not DynamicData.GetValue(0, 'Enabled')) then Exit;
  GetCursorPos(P1);
  Counter := DynamicData.GetValue(0, 'Countdown');

  while (Counter <> 0) do begin
    Form1.Caption := 'Starting in ' + IntToStr(Counter) + ' seconds.';
    Wait(1000);
    Dec(Counter);
    GetCursorPos(P2);
    if (P1.X <> P2.X) or (P1.Y <> P2.Y) then Break;
  end;

  if (Counter > 0) then Exit;
  CloseAction := caNone;
  Form1.FormClose(nil, CloseAction);

  for i := 0 to DynamicData.GetLength-1 do begin
    if not DynamicData.GetValue(i, 'Enabled') then Continue;
    if (DynamicData.GetValue(i, 'CommandLine') <> '') then WideWinExec(DynamicData.GetValue(i, 'CommandLine'), SW_SHOW);
  end;

  TerminateProcess(GetCurrentProcess, 0);
end;
//Countdown


procedure CreateEntry(Enabled: Boolean; Name, CommandLine: WideString; Countdown: Integer);
var
  Count: Integer;
  CheckBox: TTNTCheckBox;
  Edit: TTNTEdit;
  Button: TTNTButton;
begin
  Count := Form1.ComponentCount div COMPONENETS_PER_ROW;

  //Enabled
  CheckBox := TTNTCheckBox.Create(Form1);
  CheckBox.Parent := Form1;
  CheckBox.Checked := Enabled;
  CheckBox.OnClick := Form1.EnableClick;
  CheckBox.Width := 15;
  CheckBox.Height := 16;
  CheckBox.Left := 8;
  CheckBox.Top := 13 + (21*Count + 5*Count);

  //Name
  Edit := TTNTEdit.Create(Form1);
  Edit.Parent := Form1;
  Edit.OnChange := Form1.NameChange;
  Edit.Text := Name;
  Edit.Width := 100;
  Edit.Height := 21;
  Edit.Left := 30;
  Edit.Top := 10 + (21*Count + 5*Count);

  //CommandLine
  Edit := TTNTEdit.Create(Form1);
  Edit.Parent := Form1;
  Edit.OnChange := Form1.CommandChange;
  Edit.Text := CommandLine;
  Edit.Width := 500;
  Edit.Height := 21;
  Edit.Left := 135;
  Edit.Top := 10 + (21*Count + 5*Count);

  //Countdown
  Edit := TTNTEdit.Create(Form1);
  Edit.Parent := Form1;
  Edit.OnChange := Form1.CountdownChange;
  Edit.Text := IntToStr(Countdown);
  Edit.Width := 45;
  Edit.Height := 21;
  Edit.Left := 640;
  Edit.Top := 10 + (21*Count + 5*Count);

  //Start button
  Button := TTNTButton.Create(Form1);
  Button.Parent := Form1;
  Button.Font.Name := 'Segoe UI';
  Button.Font.Style := [fsBold];
  Button.OnClick := Form1.StartButton;
  Button.Caption := 'S';
  Button.Width := 23;
  Button.Height := 23;
  Button.Left := 690;
  Button.Top := 9 + (21*Count + 5*Count);

  //Add new button
  Button := TTNTButton.Create(Form1);
  Button.Parent := Form1;
  Button.OnClick := Form1.DeleteButton;
  Button.Caption := WideString(WideChar(10060));
  Button.Width := 23;
  Button.Height := 23;
  Button.Left := 716;
  Button.Top := 9 + (21*Count + 5*Count);
end;


procedure BuildEntries;
var
  i, Countdown: Integer;
  Button: TTNTButton;
  Name, CommandLine: WideString;
  Enabled: Boolean;
begin
  while (Form1.ComponentCount <> 0) do Form1.Components[0].Destroy;

  for i := 0 to DynamicData.GetLength-1 do begin
    Enabled := DynamicData.GetValue(i, 'Enabled');
    Name := DynamicData.GetValue(i, 'Name');
    CommandLine := DynamicData.GetValue(i, 'CommandLine');
    Countdown := DynamicData.GetValue(i, 'Countdown');
    CreateEntry(Enabled, Name, CommandLine, Countdown);
  end;

  i := Form1.ComponentCount div COMPONENETS_PER_ROW;

  Button := TTNTButton.Create(Form1);
  Button.Parent := Form1;
  Button.Font.Name := 'MS Sans Serif';
  Button.OnClick := Form1.AddButton;
  Button.Caption := '+';
  Button.Font.Size := 14;
  Button.Width := 23;
  Button.Height := 23;
  Button.Left := 6;
  Button.Top := 14 + (21*i + 5*i);
end;


procedure TForm1.RebuildEntry(var Msg: TMessage);
begin
  BuildEntries;
end;


procedure TForm1.FormCreate(Sender: TObject);
var
  id: DWORD;
begin
  SetCurrentDirectoryW(PWideChar(WideExtractFileDir(WideParamStr(0))));
  DynamicData := TDynamicData.Create(['Name', 'CommandLine', 'Countdown', 'Enabled']);
  DynamicData.Load(DEFAULT_FILENAME, [loRemoveUnused, loOFReset]);

  BuildEntries;
  BeginThread(nil, 0, Addr(Countdown), nil, 0, id);
end;


procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (DynamicData.GetLength > 0) then begin
    SaveRegistryWideString(WideParamStr(0), HKEY_CURRENT_USER, 'Software\Microsoft\Windows\CurrentVersion\Run', 'AutoStart');
    DynamicData.Save(DEFAULT_FILENAME, []);
    SetFileAttributesW(DEFAULT_FILENAME, faSysFile or faHidden);
  end else begin
    DeleteRegistryValue(HKEY_CURRENT_USER, 'Software\Microsoft\Windows\CurrentVersion\Run', 'AutoStart');
    DeleteFileW(DEFAULT_FILENAME);
  end
end;


procedure TForm1.EnableClick(Sender: TObject);
var
  i: Integer;
  Enabled: Boolean;
begin
  i := (TControl(Sender).ComponentIndex div COMPONENETS_PER_ROW);
  Enabled := TCheckBox(Sender).Checked;
  DynamicData.SetValue(i, 'Enabled', Enabled);
  DynamicData.MoveData(i, Q(Enabled, 0, DynamicData.GetLength-1));
  PostMessage(Form1.WindowHandle, WM_REBUILD_CONTROL, 0, 0);
end;


procedure TForm1.NameChange(Sender: TObject);
var
  i: Integer;
begin
  i := (TControl(Sender).ComponentIndex div COMPONENETS_PER_ROW);
  DynamicData.SetValue(i, 'Name', TTNTEDit(Sender).Text);
end;


procedure TForm1.CommandChange(Sender: TObject);
var
  i: Integer;
begin
  i := (TControl(Sender).ComponentIndex div COMPONENETS_PER_ROW);
  DynamicData.SetValue(i, 'CommandLine', TTNTEDit(Sender).Text);
end;


procedure TForm1.CountdownChange(Sender: TObject);
var
  i: Integer;
begin
  i := (TControl(Sender).ComponentIndex div COMPONENETS_PER_ROW);
  CheckValue(TTNTEDit(Sender), 1, 999999);
  if TTNTEDit(Sender).Text = '' then TTNTEDit(Sender).Text := '1';
  DynamicData.SetValue(i, 'Countdown', StrToInt(TTNTEDit(Sender).Text));
end;


procedure TForm1.StartButton(Sender: TObject);
var
  CloseAction: TCloseAction;
  CommandLine: WideString;
begin
  CommandLine := TTNTEdit(Form1.Components[TControl(Sender).ComponentIndex-2]).Text;
  if CommandLine = '' then Exit;
  WideWinExec(CommandLine, SW_SHOW);
  CloseAction := caNone;
  Form1.FormClose(nil, CloseAction);
  TerminateProcess(GetCurrentProcess, 0);
end;


procedure TForm1.DeleteButton(Sender: TObject);
var
  i: Integer;
begin
  i := (TTNTEDit(Sender).ComponentIndex div COMPONENETS_PER_ROW);
  DynamicData.DeleteData(i);
  PostMessage(Form1.WindowHandle, WM_REBUILD_CONTROL, 0, 0);
end;


procedure TForm1.AddButton(Sender: TObject);
begin
  TControl(Sender).Top := TControl(Sender).Top + 26;
  DynamicData.CreateData(-1, -1, ['Name', 'CommandLine', 'Countdown', 'Enabled'], ['', '', DEFAULT_COUNTDOWN_TIME, False]);
  CreateEntry(False, '', '', DEFAULT_COUNTDOWN_TIME);
end;



end.
