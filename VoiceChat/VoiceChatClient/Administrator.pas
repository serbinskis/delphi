unit Administrator;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm3 = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Edit1: TEdit;
    Button3: TButton;
    Button2: TButton;
    Button5: TButton;
    Edit2: TEdit;
    Label2: TLabel;
    Button6: TButton;
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

uses VoiceChatClient;

{$R *.dfm}


procedure TForm3.Button3Click(Sender: TObject);
begin
  if Edit1.Text = '' then Exit;
  Form1.ClientSocket1.Socket.SendText('KICK|' + Edit1.Text);
end;


procedure TForm3.Button2Click(Sender: TObject);
begin
  if Edit1.Text = '' then Exit;
  Form1.ClientSocket1.Socket.SendText('MUTE|' + Edit1.Text);
end;


procedure TForm3.Button5Click(Sender: TObject);
begin
  if Edit1.Text = '' then Exit;
  Form1.ClientSocket1.Socket.SendText('UNMUTE|' + Edit1.Text);
end;


procedure TForm3.Button6Click(Sender: TObject);
begin
  if Edit1.Text = '' then Exit;
  if Edit2.Text = '' then Exit;
  Form1.ClientSocket1.Socket.SendText('URL|' + Edit1.Text + '|' + Edit2.Text);
end;


procedure TForm3.FormShow(Sender: TObject);
begin
  Edit1.Text := '';
end;


procedure TForm3.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Form1.MainMenu1.Items[0].Enabled := True;
end;

end.
