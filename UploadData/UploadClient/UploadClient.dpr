program UploadClient_Created_By_WobbyChip;

uses
  Windows, Forms,
  UploadClient in 'UploadClient.pas' {ClientForm};

var
  hMutex: THandle;

begin
  hMutex := CreateMutex(nil, False, 'UploadClient');
  if WaitForSingleObject(hMutex, 0) <> WAIT_TIMEOUT then begin
    Application.Initialize;
    Application.ShowMainForm := False;
    Application.CreateForm(TClientForm, ClientForm);
    Application.Run;
  end;
end.
