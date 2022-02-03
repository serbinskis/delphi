unit LogIn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm2 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    Label2: TLabel;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses Administrator, VoiceChatClient;

{$R *.dfm}


procedure TForm2.Button1Click(Sender: TObject);
begin
  Form1.ClientSocket1.Socket.SendText('ADMINISTRATOR|' + Edit1.Text + '|' + Edit2.Text);
end;


procedure TForm2.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_RETURN then begin
    Key := #0;
    Edit2.SetFocus;
  end;
end;


procedure TForm2.Edit2KeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_RETURN then begin
    Key := #0;
    Button1.Click
  end;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  Edit1.Text := '';
  Edit2.Text := '';
  Edit1.SetFocus;
end;

end.
