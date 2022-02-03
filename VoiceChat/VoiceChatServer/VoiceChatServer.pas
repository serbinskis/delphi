unit VoiceChatServer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScktComp, ComCtrls, idglobal, ExtCtrls, ShellAPI, WinSock,
  MMSystem, WaveUtils, WaveIO, WaveOut, WavePlayers, WaveStorage, StrUtils, WinXP;

type
  TForm1 = class(TForm)
    Button1: TButton;
    ServerSocket1: TServerSocket;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    ListBox1: TListBox;
    Timer1: TTimer;
    ServerSocket2: TServerSocket;
    ComboBox1: TComboBox;
    Label3: TLabel;
    Button2: TButton;
    Label4: TLabel;
    Edit3: TEdit;
    Label5: TLabel;
    Edit4: TEdit;
    Label6: TLabel;
    Edit5: TEdit;
    GroupBox1: TGroupBox;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure ServerSocket1Accept(Sender: TObject; Socket: TCustomWinSocket);
    procedure ServerSocket1ClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure FormCreate(Sender: TObject);
    procedure ServerSocket2ClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure Button2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    WaveFormat: TWaveFormatEx;
    procedure BuildAudioFormatList;
  public
    { Public declarations }
  end;

type
  TServerSocketAccess = class(TServerSocket)
  end;

var
  Form1: TForm1;
  PCMFormatIndex: Integer;


implementation

{$R *.dfm}


//GetIPV4
function GetIPV4: String;
type
  TaPInAddr = array[0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  i: Integer;
  WSAData: TWSAData;
  HostEnt: PHostEnt;
  pPtr: PaPInAddr;
  buffer: array [0..127] of Char;
Begin
  Result := '';
  WSAStartup($101, WSAData);
  GetHostName(buffer, 128);
  HostEnt := GetHostByName(buffer);
  if HostEnt = nil then Exit;
  pPtr := PaPInAddr(HostEnt^.h_addr_list);

  i := 0;
  while pPtr^[i] <> nil do begin
    Result := inet_ntoa(pPtr^[i]^);
    Inc(i);
  end;

  WSACleanup;
end;
//GetIPV4


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


//UpdateList
procedure UpdateList(Name: String);
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
//UpdateList


//SendAll
procedure SendAll(Msg: String; Exception: Integer);
var
  i, Handle: Integer;
begin
  for i := 0 to Form1.ServerSocket1.Socket.ActiveConnections-1 do begin
    Handle := Form1.ServerSocket1.Socket.Connections[i].SocketHandle;
    if Handle <> Exception then begin
      Form1.ServerSocket1.Socket.Connections[i].SendText(Msg);
    end;
  end;
end;
//SendAll


//BuildAudioFormatList
procedure TForm1.BuildAudioFormatList;
var
  PCM: TPCMFormat;
  WaveFormat: TWaveFormatEx;
begin
  with ComboBox1.Items do
  begin
    BeginUpdate;
    try
      Clear;
      for PCM := Succ(Low(TPCMFormat)) to High(TPCMFormat) do
      begin
        SetPCMAudioFormatS(@WaveFormat, PCM);
        Add(GetWaveAudioFormat(@WaveFormat));
      end;
    finally
      EndUpdate;
    end;
  end;
end;
//BuildAudioFormatList


procedure TForm1.FormCreate(Sender: TObject);
begin
  BuildAudioFormatList;
  ComboBox1.ItemIndex := 11;
  Edit1.Text := GetIPV4;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  ServerSocket1.Port := StrToInt(Edit2.Text);
  TServerSocketAccess(ServerSocket1).Address := Edit1.Text;
  ServerSocket1.Open;

  ServerSocket2.Port := 3999;
  TServerSocketAccess(ServerSocket2).Address := Edit1.Text;
  ServerSocket2.Open;

  Button1.Enabled := False;
  Edit1.Enabled := False;
  Edit2.Enabled := False;
  ComboBox1.Enabled := False;

  SetPCMAudioFormatS(@WaveFormat, TPCMFormat(ComboBox1.ItemIndex));
  PCMFormatIndex := ComboBox1.ItemIndex;
  Memo1.Lines.Add('Server listening on ' + IntToStr(ServerSocket1.Port) + ' | ' + GetWaveAudioFormat(@WaveFormat));
end;


procedure TForm1.ServerSocket1Accept(Sender: TObject; Socket: TCustomWinSocket);
begin
  Socket.SendText('LOGIN|');
end;


procedure TForm1.ServerSocket1ClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
  IncommingText: String;
  StrippedData: String;
  CommandName: String;
begin
  IncommingText := Socket.ReceiveText;
  CommandName := Copy(IncommingText, 0, Pos('|', IncommingText));
  Memo1.Lines.Add(StringReplace(IncommingText, #13#10, '', [rfReplaceAll, rfIgnoreCase]));
  SendMessage(Memo1.Handle, WM_VSCROLL, SB_LINEDOWN, 0);

  if CommandName = 'LOGIN|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));

    if StrippedData = Edit3.Text
    then Socket.SendText('PCMFormatIndex|' + IntToStr(PCMFormatIndex))
    else begin
      Socket.SendText('INCORRECT|');
      Socket.Close;
    end;
  end;

  if CommandName = 'ADMINISTRATOR|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    CommandName := Copy(StrippedData, 0, Pos('|', StrippedData)-1);
    if CommandName = Edit4.Text then begin
      StrippedData := Copy(StrippedData, Pos('|', StrippedData)+1, Length(StrippedData));
      if StrippedData = Edit5.Text then Socket.SendText('ADMINISTRATOR|');
    end;
  end;

  if CommandName = 'URL|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    SendAll('URL|' + StrippedData, -1);
  end;

  if CommandName = 'KICK|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    SendAll('KICK|' + StrippedData, -1);
  end;

  if CommandName = 'MUTE|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    SendAll('MUTE|' + StrippedData, -1);
  end;

  if CommandName = 'UNMUTE|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    SendAll('UNMUTE|' + StrippedData, -1);
  end;

  if CommandName = 'MESSAGE|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    SendAll('MESSAGE|' + StrippedData, -1);
  end;

  if CommandName = 'CLOSE|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    UpdateList(StrippedData);
    SendAll('CLOSE|' + StrippedData, Socket.SocketHandle);
  end;

  if CommandName = 'UPDATE|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    ListBox1.Items.Add(StrippedData);
  end;

  if CommandName = 'NAME|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    ListBox1.Items.Add(StrippedData);
    ListBox1.Items.Delimiter := ';';
    Socket.SendText('USERS|' + ListBox1.Items.DelimitedText + ';');
    SendAll('USER|' + StrippedData, Socket.SocketHandle);
  end;
end;


procedure TForm1.ServerSocket2ClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
  DataPacket: Pointer;
  DataSize: Integer;
  i, Handle: Integer;
begin
  DataSize := Socket.ReceiveLength;
  if DataSize > 0 then begin
    GetMem(DataPacket, DataSize);
    Socket.ReceiveBuf(DataPacket^, DataSize);

    for i := 0 to ServerSocket2.Socket.ActiveConnections-1 do begin
      Handle := ServerSocket2.Socket.Connections[i].SocketHandle;
      if Handle <> Socket.SocketHandle then begin
        try
          ServerSocket2.Socket.Connections[i].SendBuf(DataPacket^, DataSize);
        except
          continue;
        end;
      end;
    end;

  end;
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
  ListBox1.Clear;
  SendAll('UPDATE|', -1);
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if ServerSocket1.Active then Button2.Click;
end;

end.
