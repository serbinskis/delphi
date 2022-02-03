program Banner_Created_By_WobbyChip;

uses
  Forms,
  Banner in 'Banner.pas' {Form1};

{$R Banner.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
