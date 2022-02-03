unit UploadServer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StdCtrls, ComCtrls, ExtCtrls, WinXP, Functions, ScktComp;

type
  TForm1 = class(TForm)
    ServerSocket1: TServerSocket;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Button1: TButton;
    Label3: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ServerSocket1ClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ServerSocket1ClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ServerSocket1ClientConnect(Sender: TObject; Socket: TCustomWinSocket);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TServerSocketAccess = class(TServerSocket)
  end;

var
  Form1: TForm1;
  FileName, CurrentUser: String;
  FileSize: Int64;
  FileStream: TFileStream;

implementation

{$R *.dfm}


procedure TForm1.FormShow(Sender: TObject);
begin
  Edit1.Text := GetIPV4;
  Button1.SetFocus;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  if Button1.Caption = 'Start Server' then begin
    SetCurrentDir(ExtractFileDir(ParamStr(0)));
    ServerSocket1.Port := StrToInt(Edit2.Text);
    TServerSocketAccess(ServerSocket1).Address := Edit1.Text;
    ServerSocket1.Open;

    Edit1.Enabled := False;
    Edit2.Enabled := False;
    Button1.Enabled := False;
    Wait(500);
    Button1.Caption := 'Stop Server';
    Button1.Enabled := True;
  end else begin
    ServerSocket1.Close;
    CurrentUser := '';

    Edit1.Enabled := True;
    Edit2.Enabled := True;
    Button1.Enabled := False;
    Wait(500);
    Button1.Caption := 'Start Server';
    Button1.Enabled := True;
  end;
end;


procedure TForm1.ServerSocket1ClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
  Buffer: array [0..9999] of Char;
  IncommingLen, RecievedLen: Integer;
  IncommingText: String;
  StrippedData: String;
  CommandName: String;
begin
  if FileSize > 0 then begin
    IncommingLen := Socket.ReceiveLength;
    while IncommingLen > 0 do begin
      RecievedLen := Socket.ReceiveBuf(Buffer, SizeOf(Buffer));
      if RecievedLen <= 0 then Break else FileStream.Write(Buffer, RecievedLen);

      Memo2.Clear;
      Memo2.Lines.Add('Reciving file ' + IntToStr(FileStream.Size) + ' of ' + IntToStr(FileSize) + ' bytes');
      Label3.Caption := Format('%.2f', [(FileStream.Size / FileSize) * 100]) + '%';
      if FileStream.Size >= FileSize then begin
        Label3.Caption := '100%';
        FileSize := 0;
        FileStream.Free;
        Socket.SendText('DONE|');
        Break;
      end;
    end;
    Exit;
  end;

  IncommingText := Socket.ReceiveText;
  if Length(IncommingText) <= 1 then Exit;
  CommandName := Copy(IncommingText, 0, Pos('|', IncommingText));
  Memo1.Lines.Add(StringReplace(IncommingText, #13#10, '', [rfReplaceAll, rfIgnoreCase]));
  SendMessage(Memo1.Handle, WM_VSCROLL, SB_BOTTOM, 0);

  if CommandName = 'CD|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    if not DirectoryExists(GetCurrentDir + '\' + StrippedData) then CreateDir(GetCurrentDir + '\' + StrippedData);
    SetCurrentDir(GetCurrentDir + '\' + StrippedData);
    Socket.SendText('DONE|');
    Exit;
  end;

  if CommandName = 'FILE|' then begin
    StrippedData := Copy(IncommingText, Pos('|', IncommingText)+1, Length(IncommingText));
    FileSize := StrToInt(Copy(StrippedData, 0, Pos('|', StrippedData)-1));
    StrippedData := Copy(StrippedData, Pos('|', StrippedData)+1, Length(StrippedData));

    FileName := GetCurrentDir + '\' + StrippedData;
    if FileExists(FileName) then DeleteFile(FileName);
    FileStream := TFileStream.Create(FileName, fmCreate or fmOpenWrite);
    if FileSize = 0 then FileStream.Free;
    Socket.SendText('DONE|');
    Exit;
  end;
end;


procedure TForm1.ServerSocket1ClientConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  if ServerSocket1.Socket.ActiveConnections > 1 then begin
    Socket.Close;
  end else begin
    Socket.SendText('READY|');
  end;
end;


procedure TForm1.ServerSocket1ClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  Memo1.Lines.Add('ServerSocket1 Error: ' + IntToStr(ErrorCode));
  Socket.Close;
  ErrorCode := 0;
  SetCurrentDir(ExtractFileDir(ParamStr(0)));
end;

end.
