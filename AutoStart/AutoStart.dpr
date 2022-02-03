program AutoStart_Created_By_WobbyChip;

uses
  Forms,
  AutoStart in 'AutoStart.pas' {Form1};

{$R AutoStart.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
