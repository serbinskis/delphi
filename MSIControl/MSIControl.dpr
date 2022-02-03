program MSIControl_Created_By_WobbyChip;

uses
  Forms, SysUtils, Windows, TNTSystem, Functions,
  MSIControl in 'MSIControl.pas' {Form1};

{$R MSIControl.res}

begin
  if not IsAdmin then begin
    ExecuteProcessAsAdmin(WideParamStr(0), '', SW_SHOW);
    Exit;
  end;

  Application.Initialize;
  Application.ShowMainForm := False;
  Application.Title := 'MSI Control (GL65 9SE)';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
