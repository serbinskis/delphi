unit UploadClient;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, StdCtrls, WinSock, ScktComp,
  Dialogs, FileCtrl, WinXP, Functions;

type
  TClientForm = class(TForm)
    ClientSocket1: TClientSocket;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure ClientSocket1Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocket1Error(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  MyIPAddress = '';
  Socket1Port = 0;

var
  ClientForm: TClientForm;
  OperationCompleted: Boolean;

implementation

{$WARN SYMBOL_PLATFORM OFF}
{$R *.dfm}


//UploadFolder
procedure UploadFolder(Directory: String);
var
  srSearch: TSearchRec;
  FileStream: TFileStream;
begin
  OperationCompleted := False;
  ClientForm.ClientSocket1.Socket.SendText('CD|' + ExtractFileName(Directory));
  while OperationCompleted = False do Wait(1);

  if FindFirst(Directory + '\*.*', faAnyFile, srSearch) = 0 then begin
    repeat
      try
        if ((srSearch.Attr and faDirectory) = 0) then begin
          OperationCompleted := False;
          ClientForm.ClientSocket1.Socket.SendText('FILE|' + IntToStr(srSearch.Size) + '|' + srSearch.Name);
          while not OperationCompleted do Wait(1);

          if srSearch.Size > 0 then begin
            FileStream := TFileStream.Create(Directory + '\' + srSearch.Name, fmOpenRead or fmShareDenyNone);

            OperationCompleted := False;
            ClientForm.ClientSocket1.Socket.SendStream(FileStream);
            while not OperationCompleted do Wait(1);
          end;
        end;

        if ((srSearch.Attr and faDirectory) = faDirectory)
        and (srSearch.Name <> '.') and (srSearch.Name <> '..')
          then UploadFolder(Directory + '\' + srSearch.Name);
      except
        continue;
      end;
    until FindNext(srSearch) <> 0;
    FindClose(srSearch);
  end;

  OperationCompleted := False;
  ClientForm.ClientSocket1.Socket.SendText('CD|..');
  while OperationCompleted = False do Wait(1);
end;
//UploadFolder


procedure TClientForm.FormCreate(Sender: TObject);
begin
  ClientSocket1.Port := Socket1Port;
  ClientSocket1.Address := GetIP(MyIPAddress);
  ClientSocket1.Open;

  Wait(5000);
  if not ClientSocket1.Socket.Connected then Application.Terminate;
end;


procedure TClientForm.ClientSocket1Error(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
end;


procedure TClientForm.ClientSocket1Read(Sender: TObject; Socket: TCustomWinSocket);
var
  IncommingText: String;
  CommandName: String;
  Directory: String;
begin
  IncommingText := Socket.ReceiveText;
  CommandName := Copy(IncommingText, 0, Pos('|', IncommingText));
  if CommandName = 'DONE|' then OperationCompleted := True;

  if CommandName = 'READY|' then begin
    if SelectDirectory(Directory, [], 0) then UploadFolder(Directory);
    ClientSocket1.Close;
    Application.Terminate;
  end;
end;

end.
