unit Archiving;

interface

uses
  Windows, Classes, Controls, Forms, ComCtrls, StdCtrls, ExtCtrls, TFlatProgressBarUnit;

type
  TForm3 = class(TForm)
    StaticText1: TStaticText;
    ProgressBar1: TFlatProgressBar;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

uses Soundboard;

{$R *.dfm}

procedure TForm3.FormShow(Sender: TObject);
begin
  if SettingsDB.StayOnTop
    then SetWindowPos(Handle, HWND_TOPMOST, 0,0,0,0, SWP_NOMOVE or SWP_NOSIZE)
    else SetWindowPos(Handle, HWND_NOTOPMOST, 0,0,0,0, SWP_NOMOVE or SWP_NOSIZE);

  Form3.Top := Form1.Top + Round((Form1.Height - Form3.Height)/2);
  Form3.Left := Form1.Left + Round((Form1.Width - Form3.Width)/2);

  ProgressBar1.Position := 0;
  StaticText1.Caption := '0%';
  StaticText1.Top := ProgressBar1.Top+2;
  StaticText1.Left := ProgressBar1.Left;
  StaticText1.Width := ProgressBar1.ClientWidth;
  StaticText1.Height := ProgressBar1.ClientHeight;
end;

end.
