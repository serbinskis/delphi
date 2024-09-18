unit About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ShellAPI, ExtCtrls;

type
  TForm3 = class(TForm)
    Label1: TLabel;
    Image1: TImage;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    Image2: TImage;
    Button1: TButton;
    procedure FormShow(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label1MouseEnter(Sender: TObject);
    procedure Label1MouseLeave(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.FormShow(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
  Label1.Font.Color := RGB(44, 161, 248);
end;


procedure TForm3.Label1Click(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://serbinskis.github.io', nil, nil, SW_SHOWMAXIMIZED);
end;


procedure TForm3.Label1MouseEnter(Sender: TObject);
begin
  Label1.Font.Style := [fsUnderline];
end;


procedure TForm3.Label1MouseLeave(Sender: TObject);
begin
  Label1.Font.Style := [];
end;


procedure TForm3.Button1Click(Sender: TObject);
begin
  Form3.Close;
end;

end.
