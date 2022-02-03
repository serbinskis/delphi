program SecretClient_Created_By_WobbyChip;

uses
  Windows, Forms,
  SecretClient in 'SecretClient.pas' {ClientForm};

begin
  hMutex := CreateMutex(nil, False, 'SecretClient');
  if WaitForSingleObject(hMutex, 0) <> WAIT_TIMEOUT then begin
    Application.Initialize;
    Application.ShowMainForm := False;
    Application.CreateForm(TClientForm, ClientForm);
    Application.Run;
  end;
end.
