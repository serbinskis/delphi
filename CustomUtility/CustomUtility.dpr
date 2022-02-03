program CustomUtility_Created_By_WobbyChip;

uses
  Forms, SysUtils, Windows, Dialogs, TNTSystem, Functions,
  CustomUtility in 'CustomUtility.pas' {Form1},
  uWakeOnLan in 'uWakeOnLan\uWakeOnLan.pas' {WakeOnLan},
  uCryptoGraph in 'uCryptoGraph\uCryptoGraph.pas' {CryptoGraph},
  uCryptoSettings in 'uCryptoGraph\uCryptoSettings.pas' {CryptoSettings};

{$R uWakeOnLan\uWakeOnLan.res}
{$R CustomUtility.res}

var
  i: Integer;
begin
  if AnsiLowerCase(ParamStr(1)) = '-wakeonlan' then begin
    Application.Initialize;
    Application.ShowMainForm := False;
    Application.Title := 'Wake On Lan';
    Application.CreateForm(TWakeOnLan, WakeOnLan);
    Application.Run;
    Exit;
  end;

  if AnsiLowerCase(ParamStr(1)) = '-cryptograph' then begin
    Application.Initialize;
    Application.ShowMainForm := False;
    Application.CreateForm(TCryptoGraph, CryptoGraph);
    Application.CreateForm(TCryptoSettings, CryptoSettings);
    i := GetWindowLong(Application.Handle, GWL_EXSTYLE);
    SetWindowLong(Application.Handle, GWL_EXSTYLE, i or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
    Application.Run;
    Exit;
  end;

  if not IsAdmin then begin
    if ExecuteProcessAsAdmin(WideParamStr(0), '', SW_SHOW) <> 0 then Exit;
  end;

  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
