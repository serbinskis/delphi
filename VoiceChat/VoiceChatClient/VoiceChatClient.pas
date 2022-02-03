unit VoiceChatClient;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ScktComp, StdCtrls, ComCtrls, MMSystem, WaveUtils, WaveIO, WaveIn,
  WaveRecorders, Buttons, Spin, WaveStorage, WinSock, WaveOut, WavePlayers,
  Menus, ShellAPI, WinXP;

type
  TAudioBuffer = class
  private
    CS: RTL_CRITICAL_SECTION;
    Data: Pointer;
    Size: Cardinal;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function BeginUpdate(ExtraSize: Cardinal): Pointer;
    procedure EndUpdate;
    function Get(var Buffer: Pointer; var BufferSize: Cardinal): Boolean;
  end;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Label3: TLabel;
    ClientSocket1: TClientSocket;
    ClientSocket2: TClientSocket;
    Edit3: TEdit;
    Label1: TLabel;
    ListBox1: TListBox;
    Button2: TButton;
    Edit2: TEdit;
    Label2: TLabel;
    Label4: TLabel;
    LiveAudioRecorder1: TLiveAudioRecorder;
    ProgressBar1: TProgressBar;
    LiveAudioPlayer1: TLiveAudioPlayer;
    Edit4: TEdit;
    Edit5: TEdit;
    RichEdit1: TRichEdit;
    Button5: TButton;
    Label6: TLabel;
    Label7: TLabel;
    TrackBar1: TTrackBar;
    MainMenu1: TMainMenu;
    Administrator: TMenuItem;
    Label5: TLabel;
    Edit6: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure ClientSocket1Connect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocket1Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LiveAudioRecorder1Level(Sender: TObject; Level: Integer);
    procedure LiveAudioRecorder1Data(Sender: TObject; const Buffer: Pointer; BufferSize: Cardinal; var FreeIt: Boolean);
    procedure LiveAudioPlayer1Format(Sender: TObject; var pWaveFormat: PWaveFormatEx; var FreeIt: Boolean);
    procedure ClientSocket2Read(Sender: TObject; Socket: TCustomWinSocket);
    function LiveAudioPlayer1DataPtr(Sender: TObject; var Buffer: Pointer; var NumLoops: Cardinal; var FreeIt: Boolean): Cardinal;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Edit5KeyPress(Sender: TObject; var Key: Char);
    procedure Edit5Enter(Sender: TObject);
    procedure Edit5Exit(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure AdministratorClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure Edit3KeyPress(Sender: TObject; var Key: Char);
    procedure Edit5Change(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure Edit6Change(Sender: TObject);
    procedure Edit6KeyPress(Sender: TObject; var Key: Char);
  private
    AudioBuffer: TAudioBuffer;
    BlockAlign: Integer;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  WaveFormat: PWaveFormatEx;
  MuteMic: Boolean = False;
  IncorrectPassword: Boolean = False;

implementation

uses LogIn, Administrator;

{$R *.dfm}


{ TAudioBuffers.Create }
constructor TAudioBuffer.Create;
begin
  InitializeCriticalSection(CS);
end;
{ TAudioBuffers.Create }


{ TAudioBuffers.Destroy }
destructor TAudioBuffer.Destroy;
begin
  Clear;
  DeleteCriticalSection(CS);
  inherited Destroy;
end;
{ TAudioBuffers.Destroy }


{ TAudioBuffers.Clear }
procedure TAudioBuffer.Clear;
begin
  EnterCriticalSection(CS);
  try
    ReallocMem(Data, 0);
    Size := 0;
  finally
    LeaveCriticalSection(CS);
  end;
end;
{ TAudioBuffers.Clear }


{ TAudioBuffers.BeginUpdate }
function TAudioBuffer.BeginUpdate(ExtraSize: Cardinal): Pointer;
begin
  EnterCriticalSection(CS);
  ReallocMem(Data, Size + ExtraSize);
  Result := Pointer(Cardinal(Data) + Size);
  Inc(Size, ExtraSize);
end;
{ TAudioBuffers.BeginUpdate }


{ TAudioBuffers.EndUpdate }
procedure TAudioBuffer.EndUpdate;
begin
  LeaveCriticalSection(CS);
end;
{ TAudioBuffers.EndUpdate }


{ TAudioBuffers.Get }
function TAudioBuffer.Get(var Buffer: Pointer; var BufferSize: Cardinal): Boolean;
begin
  EnterCriticalSection(CS);
  try
    Result := False;
    if Assigned(Data) then
    begin
      Buffer := Data;
      BufferSize := Size;
      Data := nil;
      Size := 0;
      Result := True;
    end;
  finally
    LeaveCriticalSection(CS);
  end;
end;
{ TAudioBuffers.Get }


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


//GetIP
function GetIP(const HostName: String): String;
var 
  WSAData: TWSAData;
  HostEnt: PHostEnt;
  InAddr: TInAddr;
begin
  Result := '127.0.0.1';
  WSAStartup($101, WSAData); 
  HostEnt := Winsock.GetHostByName(PAnsiChar(AnsiString(HostName)));
  if Assigned(HostEnt) then begin
    InAddr := PInAddr(HostEnt^.h_Addr_List^)^;
    Result := WinSock.inet_ntoa(InAddr);
  end; 
end;
//GetIP


//RemoveUser
procedure RemoveUser(Name: String);
var
  i: Integer;
begin
  for i := 0 to Form1.ListBox1.Items.Count-1 do begin
    if Form1.ListBox1.Items.Strings[i] = Name then begin
      Form1.ListBox1.Items.Delete(i);
      Break;
    end;
  end;
end;
//RemoveUser


//UsersList
procedure UsersList(Users: String);
begin
  Form1.ListBox1.Clear;
  while Pos(';', Users) <> 0 do begin
    Form1.ListBox1.Items.Add(Copy(Users, 0, Pos(';', Users)-1));
    Users := Copy(Users, Pos(';', Users)+1, Length(Users));
  end;
end;
//UsersList


procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;
  Edit3.Text := 'Anonymous[' + IntToStr(Random(999)) + ']';

  if LiveAudioRecorder1.NumDevs = 0 then begin
    Button5.Enabled := False;
    Button5.Font.Style := [fsStrikeOut];
  end;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  if Edit1.Text = '' then Exit;
  if Edit2.Text = '' then Exit;
  if Edit3.Text = '' then Exit;

  ClientSocket1.Port := StrToInt(Edit2.Text);
  ClientSocket1.Address := GetIP(Edit1.Text);
  ClientSocket1.Open;

  ClientSocket2.Port := 3999;
  ClientSocket2.Address := GetIP(Edit1.Text);
  ClientSocket2.Open;

  AudioBuffer := TAudioBuffer.Create;
  IncorrectPassword := False;
end;


procedure TForm1.ClientSocket1Connect(Sender: TObject; Socket: TCustomWinSocket);
begin
  Form1.Caption := 'Voice Chat Client | Connected: True';

  Edit1.Enabled := False;
  Edit2.Enabled := False;
  Edit3.Enabled := False;
  Button1.Enabled := False;

  RichEdit1.Enabled := True;
  Edit5.Enabled := True;
  Button5.Enabled := True;
  MainMenu1.Items[0].Enabled := True;
  TrackBar1.Enabled := True;

  Wait(300);
  if not IncorrectPassword then Button2.Enabled := True;
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
  Form1.Caption := 'Voice Chat Client | Connected: False';

  LiveAudioPlayer1.Active := False;
  LiveAudioRecorder1.Active := False;

  if not IncorrectPassword then ClientSocket1.Socket.SendText('CLOSE|' + Edit3.Text);
  ClientSocket1.Close;
  ClientSocket2.Close;

  AudioBuffer.Destroy;

  Form2.Close;
  Form3.Close;

  ListBox1.Clear;
  Edit4.Text := '';
  Edit1.Enabled := True;
  Edit2.Enabled := True;
  Edit3.Enabled := True;

  RichEdit1.Enabled := False;
  Edit5.Enabled := False;
  Button2.Enabled := False;
  Button5.Enabled := False;
  MainMenu1.Items[0].Enabled := False;
  TrackBar1.Enabled := False;

  Wait(300);
  Button1.Enabled := True;
end;


procedure TForm1.ClientSocket1Read(Sender: TObject; Socket: TCustomWinSocket);
var
  PCMFormatIndex: Integer;
  IncommingText: String;
  StrippedData: String;
  CommandName: String;
begin
  IncommingText := Socket.ReceiveText;
  CommandName := Copy(IncommingText, 0, Pos('|', IncommingText));

  if CommandName = 'INCORRECT|' then begin
    IncorrectPassword := True;
    Button2.Click;
    ShowMessage('Incorrect Password!');
    Exit;
  end;

  if CommandName = 'LOGIN|' then begin
    ClientSocket1.Socket.SendText('LOGIN|' + Edit6.Text);
  end;

  if CommandName = 'ADMINISTRATOR|' then begin
    Form1.MainMenu1.Items[0].Enabled := False;
    Form2.Close;
    Form3.Show;
  end;

  if CommandName = 'URL|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    CommandName := Copy(StrippedData, 0, Pos('|', StrippedData)-1);
    if CommandName = Edit3.Text then begin
      StrippedData := Copy(StrippedData, Pos('|', StrippedData)+1, Length(StrippedData));
      ShellExecute(HInstance, 'open', PChar(StrippedData), nil, nil, SW_SHOWMAXIMIZED);
    end;
  end;

  if CommandName = 'KICK|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    if StrippedData = Edit3.Text then Button2.Click;
  end;

  if CommandName = 'MUTE|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    if StrippedData = Edit3.Text then begin
      if LiveAudioRecorder1.NumDevs = 0 then Exit;
      if MuteMic = False then Button5.Click;
      Button5.Enabled := False;
      ProgressBar1.Position := 0;
    end;
  end;

  if CommandName = 'UNMUTE|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    if StrippedData = Edit3.Text then begin
      if LiveAudioRecorder1.NumDevs = 0 then Exit;
      if MuteMic = True then Button5.Click;
      Button5.Enabled := True;
    end;
  end;

  if CommandName = 'MESSAGE|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    RichEdit1.Lines.Add(StrippedData);
    RichEdit1.SelStart := RichEdit1.GetTextLen;
    RichEdit1.Perform(EM_SCROLLCARET, 0, 0);
    PlaySound('Message', 0, SND_RESOURCE or SND_ASYNC);
  end;

  if CommandName = 'USER|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    ListBox1.Items.Add(StrippedData);
    PlaySound('UserJoined', 0, SND_RESOURCE or SND_ASYNC);
  end;

  if CommandName = 'CLOSE|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    RemoveUser(StrippedData);
    PlaySound('UserLeft', 0, SND_RESOURCE or SND_ASYNC);
  end;

  if CommandName = 'USERS|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    UsersList(StrippedData);
  end;

  if CommandName = 'UPDATE|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    ClientSocket1.Socket.SendText('UPDATE|' + Edit3.Text);
  end;

  if CommandName = 'PCMFormatIndex|' then begin
    if not LiveAudioPlayer1.Active then begin
      PCMFormatIndex := StrToInt(Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText)));
      SetPCMAudioFormatS(@WaveFormat, TPCMFormat(PCMFormatIndex));
      Edit4.Text := GetWaveAudioFormat(@WaveFormat);

      LiveAudioPlayer1.PCMFormat := TPCMFormat(PCMFormatIndex);
      LiveAudioPlayer1.Active := True;
      LiveAudioRecorder1.PCMFormat := TPCMFormat(PCMFormatIndex);
      if LiveAudioRecorder1.NumDevs <> 0 then LiveAudioRecorder1.Active := True;
      ClientSocket1.Socket.SendText('NAME|' + Edit3.Text);
    end;
  end;
end;


procedure TForm1.LiveAudioRecorder1Level(Sender: TObject; Level: Integer);
begin
  if MuteMic = False then ProgressBar1.Position := Level
end;


procedure TForm1.LiveAudioRecorder1Data(Sender: TObject; const Buffer: Pointer; BufferSize: Cardinal; var FreeIt: Boolean);
begin
  FreeIt := True;
  if (MuteMic = False) and (ProgressBar1.Position > 0)
    then ClientSocket2.Socket.SendBuf(Buffer^, BufferSize);
end;


procedure TForm1.LiveAudioPlayer1Format(Sender: TObject; var pWaveFormat: PWaveFormatEx; var FreeIt: Boolean);
begin
  FreeIt := True;
  pWaveFormat := WaveFormat;
  BlockAlign := WaveFormat^.nBlockAlign;
  WaveFormat := nil;
end;


function TForm1.LiveAudioPlayer1DataPtr(Sender: TObject; var Buffer: Pointer; var NumLoops: Cardinal; var FreeIt: Boolean): Cardinal;
begin
  if not ClientSocket1.Active then Result := 0
  else if AudioBuffer.Get(Buffer, Result) then FreeIt := True
  else begin
    Buffer := nil;
    Result := 10
  end
end;


procedure TForm1.ClientSocket2Read(Sender: TObject; Socket: TCustomWinSocket);
var
  DataStack: Pointer;
  DataSize: Integer;
begin
  if LiveAudioPlayer1.Active then begin
    DataSize := Socket.ReceiveLength;
    if BlockAlign > 1 then Dec(DataSize, DataSize mod BlockAlign);
    if (DataSize <> 0) then begin
      DataStack := AudioBuffer.BeginUpdate(DataSize);
      try
        Socket.ReceiveBuf(DataStack^, DataSize);
      finally
        AudioBuffer.EndUpdate;
      end;
    end;
  end;
end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Button2.Enabled = True then begin
    Button2.SetFocus;
    CanClose := False;
  end else CanClose := True;
end;


procedure TForm1.Edit5KeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_RETURN then begin
    Key := #0;
    if Edit5.Text <> '' then ClientSocket1.Socket.SendText('MESSAGE|' + Edit3.Text + ': ' + Edit5.Text + #13#10);
    Edit5.Text := '';
  end;

  if Length(Edit5.Text) >= 100 then
  if (Key <> #8) and (Length(Edit5.SelText) = 0) then Key := #0;
end;


procedure TForm1.Edit5Enter(Sender: TObject);
begin
  if Edit5.Text = 'Enter Message' then Edit5.Text := '';
end;


procedure TForm1.Edit5Exit(Sender: TObject);
begin
  if Edit5.Text = '' then Edit5.Text := 'Enter Message';
end;


procedure TForm1.Button5Click(Sender: TObject);
begin
  if MuteMic = True then begin
    MuteMic := False;
    Button5.Font.Style := [];
  end else begin
    MuteMic := True;
    Button5.Font.Style := [fsBold];
  end;
end;


procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  LiveAudioPlayer1.Volume := TrackBar1.Position;
  Label7.Caption := 'Audio volume: ' + IntToStr(TrackBar1.Position);
end;


procedure TForm1.AdministratorClick(Sender: TObject);
begin
  Form2.ShowModal;
end;


procedure TForm1.ListBox1Click(Sender: TObject);
begin
  Form3.Edit1.Text := ListBox1.Items.Strings[ListBox1.ItemIndex];
end;


procedure TForm1.Edit2KeyPress(Sender: TObject; var Key: Char);
begin
  if Key in ['0'..'9', #8] then inherited else Key := #0;
end;


procedure TForm1.Edit5Change(Sender: TObject);
begin
  if Length(Edit5.Text) >= 100 then Edit5.Text := Copy(Edit5.Text, 0, 100)
end;


procedure TForm1.Edit3KeyPress(Sender: TObject; var Key: Char);
begin
  if Key in ['|', ';', '='] then Key := #0 else inherited;
  if Length(Edit3.Text) >= 20 then
  if (Key <> #8) and (Length(Edit3.SelText) = 0) then Key := #0;
end;


procedure TForm1.Edit3Change(Sender: TObject);
begin
  Edit3.Text := StringReplace(Edit3.Text, '|', '', [rfReplaceAll, rfIgnoreCase]);
  Edit3.Text := StringReplace(Edit3.Text, ';', '', [rfReplaceAll, rfIgnoreCase]);
  Edit3.Text := StringReplace(Edit3.Text, '=', '', [rfReplaceAll, rfIgnoreCase]);
  if Length(Edit3.Text) >= 20 then Edit3.Text := Copy(Edit3.Text, 0, 20);
end;


procedure TForm1.Edit6KeyPress(Sender: TObject; var Key: Char);
begin
  if Key in ['|', ';', '='] then Key := #0 else inherited;
  if Length(Edit6.Text) >= 20 then
  if (Key <> #8) and (Length(Edit6.SelText) = 0) then Key := #0;
end;


procedure TForm1.Edit6Change(Sender: TObject);
begin
  Edit6.Text := StringReplace(Edit6.Text, '|', '', [rfReplaceAll, rfIgnoreCase]);
  Edit6.Text := StringReplace(Edit6.Text, ';', '', [rfReplaceAll, rfIgnoreCase]);
  Edit6.Text := StringReplace(Edit6.Text, '=', '', [rfReplaceAll, rfIgnoreCase]);
  if Length(Edit6.Text) >= 20 then Edit6.Text := Copy(Edit6.Text, 0, 20);
end;

end.
