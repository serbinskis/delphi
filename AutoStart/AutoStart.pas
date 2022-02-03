unit AutoStart;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, WinXP, StdCtrls, TntStdCtrls, MMSystem, Registry, uKBDynamic, Functions;

const
  COMPONENETS_PER_ROW = 6;
  DEFAULT_COUNTDOWN_TIME = 5;
  WM_REBUILD_CONTROL = WM_USER + 12787;
  DEFAULT_ROOT_KEY = HKEY_CURRENT_USER;
  DEFAULT_KEY = '\Software\AutoStart';

type
  TForm1 = class(TForm)
    procedure DefaultClick(Sender: TObject);
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

type
  TAutorun = record
    Name: WideString;
    CommandLine: WideString;
    Countdown: Integer;
    Default: Boolean;
  end;

  TAutorunsList = array of TAutorun;

var
  Form1: TForm1;
  Autoruns: TAutorunsList;

implementation

{$R *.dfm}


//Countdown
procedure Countdown;
var
  Counter: Integer;
  P1, P2: TPoint;
  CloseAction: TCloseAction;
begin
  if (Length(Autoruns) <= 0) or (not Autoruns[0].Default) then Exit;
  GetCursorPos(P1);
  Counter := Autoruns[0].Countdown;

  while Counter <> 0 do begin
    Form1.Caption := 'Starting in ' + IntToStr(Counter) + ' seconds.';
    Wait(1000);
    Dec(Counter);
    GetCursorPos(P2);

    if (P1.X <> P2.X) or (P1.Y <> P2.Y) then Break;

    if Counter = 0 then begin
      CloseAction := caNone;
      Form1.FormClose(nil, CloseAction);
      if Autoruns[0].CommandLine <> '' then WideWinExec(Autoruns[0].CommandLine, SW_SHOW);
      TerminateProcess(OpenProcess(PROCESS_TERMINATE, False, GetCurrentProcessId), 0);
    end;
  end;
end;
//Countdown


//SaveSettings
procedure SaveSettings;
var
  MemoryStream: TMemoryStream;
  lOptions: TKBDynamicOptions;
  Registry: TRegistry;
begin
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
  TKBDynamic.WriteTo(MemoryStream, Autoruns, TypeInfo(TAutorunsList), 1, lOptions);

  Registry := TRegistry.Create;
  Registry.RootKey := DEFAULT_ROOT_KEY;
  Registry.OpenKey(DEFAULT_KEY, True);
  Registry.WriteBinaryData('Settings', MemoryStream.Memory^, MemoryStream.Size);
  Registry.Free;

  MemoryStream.Free;
end;
//SaveSettings


//LoadSettings
procedure LoadSettings;
var
  MemoryStream: TMemoryStream;
  Registry: TRegistry;
begin
  Registry := TRegistry.Create;
  Registry.RootKey := DEFAULT_ROOT_KEY;
  Registry.OpenKey(DEFAULT_KEY, True);

  if Registry.ValueExists('Settings') then begin
    MemoryStream := TMemoryStream.Create;
    MemoryStream.SetSize(Registry.GetDataSize('Settings'));
    Registry.ReadBinaryData('Settings', MemoryStream.Memory^, MemoryStream.Size);

    try
      TKBDynamic.ReadFrom(MemoryStream, Autoruns, TypeInfo(TAutorunsList), 1);
      MemoryStream.Free;
    except
      PlaySound('SystemExclamation', 0, SND_ASYNC);
      ShowMessage('There was an error loading settings.' + #13#10 +
                  'List data may be corrupted or outdated.' + #13#10 +
                  'The clipboard list will be reset.');
      ZeroMemory(@Autoruns, SizeOf(Autoruns));
      SetLength(Autoruns, 0);
      Registry.DeleteValue('Settings');
    end;
  end;

  Registry.Free;
end;
//LoadSettings


//DeleteFromList
procedure DeleteFromList(var A: TAutorunsList; const Index: Integer);
var
  i, ArrayLength: Integer;
begin
  ArrayLength := Length(A);

  if Index = ArrayLength-1 then begin
    SetLength(A, ArrayLength-1);
    Exit;
  end;

  for i := Index to Length(A)-2  do begin
    A[i].Name := A[i+1].Name;
    A[i].CommandLine := A[i+1].CommandLine;
    A[i].Default := A[i+1].Default;
    A[i].Countdown := A[i+1].Countdown;
  end;

  SetLength(A, ArrayLength-1);
end;
//DeleteFromList


//InsertToList
procedure InsertToList(var A: TAutorunsList; Index: Integer; Default: Boolean; Name, CommandLine: WideString; Countdown: Integer);
var
  i: Integer;
begin
  SetLength(A, Length(A)+1);

  for i := Length(A)-1 downto Index+1 do begin
    A[i].Name := A[i-1].Name;
    A[i].CommandLine := A[i-1].CommandLine;
    A[i].Default := A[i-1].Default;
    A[i].Countdown := A[i-1].Countdown;
  end;

  A[Index].Name := Name;
  A[Index].CommandLine := CommandLine;
  A[Index].Default := Default;
  A[Index].Countdown := Countdown;
end;
//InsertToList


procedure CreateEntry(Default: Boolean; Name, CommandLine: WideString; Countdown: Integer);
var
  Count: Integer;
  CheckBox: TTNTCheckBox;
  Edit: TTNTEdit;
  Button: TTNTButton;
begin
  Count := Form1.ComponentCount div COMPONENETS_PER_ROW;

  //Default
  CheckBox := TTNTCheckBox.Create(Form1);
  CheckBox.Parent := Form1;
  CheckBox.Checked := Default;
  CheckBox.OnClick := Form1.DefaultClick;
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
  i, Count: Integer;
  Button: TTNTButton;
begin
  while Form1.ComponentCount <> 0 do Form1.Components[0].Destroy;

  for i := 0 to Length(Autoruns)-1 do begin
    CreateEntry(Autoruns[i].Default, Autoruns[i].Name, Autoruns[i].CommandLine, Autoruns[i].Countdown);
  end;

  Count := Form1.ComponentCount div COMPONENETS_PER_ROW;

  Button := TTNTButton.Create(Form1);
  Button.Parent := Form1;
  Button.Font.Name := 'MS Sans Serif';
  Button.OnClick := Form1.AddButton;
  Button.Caption := '+';
  Button.Font.Size := 14;
  Button.Width := 23;
  Button.Height := 23;
  Button.Left := 6;
  Button.Top := 14 + (21*Count + 5*Count);
end;


procedure TForm1.RebuildEntry(var Msg: TMessage);
begin
  BuildEntries;
end;


procedure TForm1.FormCreate(Sender: TObject);
var
  id: DWORD;
begin
  LoadSettings;
  BuildEntries;

  BeginThread(nil, 0, Addr(Countdown), nil, 0, id);
end;


procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveSettings;
end;


procedure TForm1.DefaultClick(Sender: TObject);
var
  Count, Countdown: Integer;
  Name, CommandLine: WideString;
begin
  Count := (TControl(Sender).ComponentIndex div COMPONENETS_PER_ROW);

  if not TCheckBox(Sender).Checked then begin
    Autoruns[Count].Default := False;
    Exit;
  end;

  Autoruns[0].Default := False;
  Name := Autoruns[Count].Name;
  CommandLine := Autoruns[Count].CommandLine;
  Countdown := Autoruns[Count].Countdown;

  DeleteFromList(Autoruns, Count);
  InsertToList(Autoruns, 0, True, Name, CommandLine, Countdown);
  PostMessage(Form1.WindowHandle, WM_REBUILD_CONTROL, 0, 0);
end;


procedure TForm1.NameChange(Sender: TObject);
var
  Count: Integer;
begin
  Count := (TControl(Sender).ComponentIndex div COMPONENETS_PER_ROW);
  Autoruns[Count].Name := TTNTEDit(Sender).Text;
end;


procedure TForm1.CommandChange(Sender: TObject);
var
  Count: Integer;
begin
  Count := (TControl(Sender).ComponentIndex div COMPONENETS_PER_ROW);
  Autoruns[Count].CommandLine := TTNTEDit(Sender).Text
end;


procedure TForm1.CountdownChange(Sender: TObject);
var
  Count: Integer;
begin
  Count := (TControl(Sender).ComponentIndex div COMPONENETS_PER_ROW);
  CheckValue(TTNTEDit(Sender), 1, 999999);
  if TTNTEDit(Sender).Text = '' then TTNTEDit(Sender).Text := '1';
  Autoruns[Count].Countdown := StrToInt(TTNTEDit(Sender).Text);
end;


procedure TForm1.StartButton(Sender: TObject);
var
  CommandLine: WideString;
begin
  CommandLine := TTNTEdit(Form1.Components[TControl(Sender).ComponentIndex-2]).Text;
  if CommandLine = '' then Exit;
  WideWinExec(CommandLine, SW_SHOW);
  SaveSettings;
  TerminateProcess(OpenProcess(PROCESS_TERMINATE, False, GetCurrentProcessId), 0);
end;


procedure TForm1.DeleteButton(Sender: TObject);
var
  Count: Integer;
begin
  Count := (TTNTEDit(Sender).ComponentIndex div COMPONENETS_PER_ROW);
  DeleteFromList(Autoruns, Count);
  PostMessage(Form1.WindowHandle, WM_REBUILD_CONTROL, 0, 0);
end;


procedure TForm1.AddButton(Sender: TObject);
begin
  TControl(Sender).Top := TControl(Sender).Top + 26;
  SetLength(Autoruns, Length(Autoruns)+1);
  //Autoruns[Length(Autoruns)-1].Countdown := DEFAULT_COUNTDOWN_TIME;
  CreateEntry(False, '', '', DEFAULT_COUNTDOWN_TIME);
end;



end.
