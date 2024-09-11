program Soundboard_Created_By_Serbinskis;

uses
  Windows, Dialogs, Forms,
  Soundboard in 'Soundboard.pas' {Form1},
  Settings in 'Settings.pas' {Form2},
  Archiving in 'Archiving.pas' {Form3};

{$R Soundboard.res}

var
  hMutex: THandle;
begin
  hMutex := CreateMutex(nil, False, 'Soundboard');
  if WaitForSingleObject(hMutex, 0) <> WAIT_TIMEOUT then begin
    Application.Initialize;
    Application.CreateForm(TForm1, Form1);
    Application.CreateForm(TForm2, Form2);
    Application.CreateForm(TForm3, Form3);
    Application.Run;
  end else begin
    ShowMessage('Soundboard is already running.');
  end;
end.
