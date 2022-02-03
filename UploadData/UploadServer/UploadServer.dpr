program UploadServer_Created_By_WobbyChip;

uses
  Forms,
  UploadServer in 'UploadServer.pas' {Form1};

begin
  Application.Initialize;
  Application.Title := 'Upload Server';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
