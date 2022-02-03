unit Banner;

interface

uses
  Windows, Classes, Graphics, Controls, Forms, ExtCtrls, MMSystem, GIFImage;

type
  TForm1 = class(TForm)
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  GIFImage: TGIFImage;
begin
  Form1.BorderStyle := bsNone;
  Form1.Color := clBlack;
  Form1.Top := 0;
  Form1.Left := 0;
  Form1.Width := GetSystemMetrics(SM_CXSCREEN);
  Form1.Height := GetSystemMetrics(SM_CYSCREEN);

  ShowCursor(False);
  SetWindowPos(Handle, HWND_TOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
  PlaySound('SOUND', 0, SND_RESOURCE or SND_ASYNC or SND_LOOP);

  GIFImage := TGIFImage.Create;
  GIFImage.LoadFromResourceName(HInstance, 'GIF');
  Image1.Picture.Assign(GIFImage);
  GIFImage.Free;
end;

end.
