program ClipboardHistory_Created_By_Serbinskis;

uses
  Windows, Dialogs, Forms,
  ClipboardHistory in 'ClipboardHistory.pas' {Form1},
  Settings in 'Settings.pas' {Form2},
  About in 'About.pas' {Form3},
  Duplicates in 'Duplicates.pas' {Form4};

{$R ClipboardHistory.res}

var
  hMutex: THandle;
  i: Integer;
begin
  hMutex := CreateMutex(nil, False, 'Clipboard History');
  if WaitForSingleObject(hMutex, 0) <> WAIT_TIMEOUT then begin
    Application.Initialize;
    Application.Title := 'Clipboard History';
    Application.CreateForm(TForm1, Form1);
    Application.CreateForm(TForm2, Form2);
    Application.CreateForm(TForm3, Form3);
    Application.CreateForm(TForm4, Form4);
    Application.ShowMainForm := False;
    i := GetWindowLong(Application.Handle, GWL_EXSTYLE);
    SetWindowLong(Application.Handle, GWL_EXSTYLE, i or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
    Application.Run;
  end else begin
    Application.Title := 'Clipboard History';
    ShowMessage('Clipboard history is already running.');
  end;
end.
