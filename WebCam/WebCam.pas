unit WebCam;

interface

uses
  Windows, SysUtils, Classes, Forms, DateUtils, Controls, StdCtrls, ExtCtrls, ComCtrls,
  VFrames, WinXP;


type
  TForm1 = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    TrackBar1: TTrackBar;
    ComboBox1: TComboBox;
    Button1: TButton;
    procedure OnNewVideoFrame(Sender: TObject; Width, Height: integer; DataPtr: pointer);
    procedure FormShow(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Video: TVideoImage;
  TimeSaved: TDateTime;
  FPS: Integer = 0;

implementation

{$R *.dfm}


procedure TForm1.FormShow(Sender: TObject);
var
  StringList: TStringList;
  i: Integer;
begin
  TimeSaved := Now;
  StringList := TStringList.Create;
  Video := TVideoImage.Create;

  Video.OnNewVideoFrame := OnNewVideoFrame;
  Video.GetListOfDevices(StringList);

  for i := 0 to StringList.Count-1 do ComboBox1.Items.Add(StringList.Strings[i]);
  ComboBox1.ItemIndex := 0;
end;


procedure TForm1.OnNewVideoFrame(Sender: TObject; Width, Height: integer; DataPtr: Pointer);
begin
  if MilliSecondsBetween(TimeSaved, Now) >= FPS then begin;
    TimeSaved := Now;
    Video.GetBitmap(Image1.Picture.Bitmap);
  end;
end;


procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  FPS := Round(1000/TrackBar1.Position);
  if TrackBar1.Position = TrackBar1.Max then FPS := 0;
  Label1.Caption := 'FPS: ' + IntToStr(TrackBar1.Position);
end;


procedure TForm1.FormResize(Sender: TObject);
begin
  Image1.Height := Form1.ClientHeight;
  Image1.Width := Form1.ClientWidth - Image1.Left;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  if Button1.Caption = 'Start' then begin
     ComboBox1.Enabled := False;
     Video.VideoStart(ComboBox1.Items[ComboBox1.ItemIndex]);
     Button1.Caption := 'Stop';
  end else begin
     Video.VideoStop;
     ComboBox1.Enabled := True;
     Button1.Caption := 'Start';
  end;
end;

end.
