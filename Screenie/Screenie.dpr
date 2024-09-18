program Screenie;

uses
  Forms,
  Screenie in 'Screenie.pas' {Form1};

{$R Screenie.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
