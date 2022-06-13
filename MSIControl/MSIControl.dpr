program MSIControl_Created_By_WobbyChip;

uses
  Forms, SysUtils, Windows, Dialogs, TNTSystem, Functions,
  MSIControl in 'MSIControl.pas' {Form1},
  MSIMicrophones in 'MSIMicrophones.pas' {Form2},
  MSIShadowPlay in 'MSIShadowPlay.pas' {Form3},
  MSILanguages in 'MSILanguages.pas' {Form4},
  MSIConnections in 'MSIConnections.pas' {Form5},
  MSIWakeOnLan in 'MSIWakeOnLan.pas' {Form6},
  MSIKeyboard in 'MSIKeyboard.pas' {Form7};

{$R MSIControl.res}

begin
  if not IsAdmin then begin
    ExecuteProcessAsAdmin(WideParamStr(0), '', SW_SHOW);
    Exit;
  end;

  if InstanceExists('MSIControl') then begin
    Application.Title := 'MSIControl';
    ShowMessage('MSIControl is already running.');
    Exit;
  end;

  Application.Initialize;
  Application.ShowMainForm := False;
  Application.Title := 'MSI Control (GL65 9SE)';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TForm6, Form6);
  Application.CreateForm(TForm7, Form7);
  Application.Run;
end.
