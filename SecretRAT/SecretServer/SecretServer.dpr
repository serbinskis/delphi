program SecretServer;

uses
  Forms,
  SecretServer in 'SecretServer.pas' {Form1};

{$R SecretServer.res}

begin
  Application.Initialize;
  Application.Title := 'Secret Server';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
