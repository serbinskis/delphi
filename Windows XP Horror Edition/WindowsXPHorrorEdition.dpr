program WindowsXPHorrorEdition;

uses
  Forms,
  WindowsXPHorrorEdition in 'WindowsXPHorrorEdition.pas' {Form1},
  WindowsXPHorrorDesktop in 'WindowsXPHorrorDesktop.pas' {Form2};

{$R Data.res}

begin
  Randomize;
  Application.Initialize;
  Application.Title := 'Windows XP Horror Edition';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
