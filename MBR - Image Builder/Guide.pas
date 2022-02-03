unit Guide;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pngimage, ExtCtrls;

type
  TForm2 = class(TForm)
    Image1: TImage;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses MBR_Image_Builder;

{$R *.dfm}

procedure TForm2.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Form2.Hide;
  Form1.Show;
end;

end.
