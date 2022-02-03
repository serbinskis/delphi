unit MBR_UEFI_Note_Builder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, Forms, Dialogs, StdCtrls, Buttons, ExtCtrls,
  ShellAPI, MiniMod, acWorkRes, Graphics, ComCtrls, jpeg, TFlatComboBoxUnit, TFlatEditUnit, TFlatPanelUnit,
  XiButton, TNTClasses, TNTSysUtils, TNTDialogs, TNTStdCtrls, WinXP, Functions;

type
  TForm1 = class(TForm)
    Button1: TXiButton;
    Button2: TXiButton;
    Button3: TXiButton;
    Button4: TXiButton;
    RichEdit1: TRichEdit;
    Image1: TImage;
    Image2: TImage;
    Edit1: TTNTEdit;
    ComboBox1: TFlatComboBox;
    ComboBox2: TFlatComboBox;
    ComboBox3: TFlatComboBox;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    OpenDialog1: TTNTOpenDialog;
    SaveDialog1: TTNTSaveDialog;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure ComboBoxChange(Sender: TObject);
    procedure RichEdit1OnChange(Sender: TObject);
    procedure RichEdit1KeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  MAX_TEXT_LENGTH = 3000;
  ENDING_ADDRESS = $75E94;
  MBR_COLOR_ADDRESS = $7AD44;
  UEFI_COLOR_ADDRESS = $81834;
  MBR_TEXT_ADDRESS = $7AF04;
  UEFI_TEXT_ADDRESS = $84244;

var
  MiniMODClass: TMiniMOD;
  Form1: TForm1;
  HexColor: String = '0F';

implementation

{$R *.dfm}


procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if Form1.AlphaBlendValue >= 254 then Timer1.Enabled := False else Form1.AlphaBlendValue := Form1.AlphaBlendValue + 5;
end;


procedure TForm1.Timer2Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  if Form1.AlphaBlendValue = 0 then Application.Terminate else Form1.AlphaBlendValue := Form1.AlphaBlendValue - 5;
end;


procedure TForm1.RichEdit1OnChange(Sender: TObject);
var
  i: Integer;
begin
  i := RichEdit1.SelStart;
  RichEdit1.Text := RemoveDiacritics(RichEdit1.Text, '?');
  RichEdit1.SelStart := i;
  RichEdit1.Font.Name := ' ';
  RichEdit1.Font.Name := 'Terminal';
end;


procedure TForm1.RichEdit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) > 128 then Key := #0;
end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  Timer2.Enabled := True;
end;


procedure TForm1.FormShow(Sender: TObject);
var
  ResStream: TResourceStream;
  FontsCount: DWORD;
  ArrayOfByte: array of byte;
begin
  ResStream := TResourceStream.Create(HInstance, 'Terminal', RT_RCDATA);
  AddFontMemResourceEx(ResStream.Memory, ResStream.Size, nil, @FontsCount);
  ResStream.Free;

  ResStream := TResourceStream.Create(HInstance, 'Music', RT_RCDATA);
  SetLength(ArrayOfByte, ResStream.Size);
  ResStream.Read(ArrayOfByte[0], ResStream.Size);
  ResStream.Free;

  MiniMODClass := TMiniMOD.Create(44100, True, True);
  MiniMODClass.Load(ArrayOfByte, Length(ArrayOfByte));
  MiniMODClass.Play;

  RichEdit1.Text := Copy(RichEdit1.Text, 1, Length(RichEdit1.Text)-2);
  Button4Click(nil);
  StaticText1.SetFocus;

  Timer1.Enabled := True;
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('https://wobbychip.github.io/'), nil, nil, SW_SHOWMAXIMIZED);
end;


procedure TForm1.Button3Click(Sender: TObject);
var
  MemoryStream: TMemoryStream;
  Icon: TIcon;
  Bitmap: TBitmap;
begin
  OpenDialog1.Filter := 'ICO (*.ico)|*.ico';
  if not OpenDialog1.Execute then Exit;
  if AnsiLowerCase(ExtractFileExt(OpenDialog1.FileName)) <> '.ico' then Exit;

  MemoryStream := TMemoryStream.Create;
  LoadFileMemoryStream(OpenDialog1.FileName, MemoryStream);

  Icon := TIcon.Create;
  Icon.LoadFromStream(MemoryStream);
  MemoryStream.Free;

  Bitmap := TBitmap.Create;
  Bitmap.Width := Icon.Width;
  Bitmap.Height := Icon.Height;
  Bitmap.Canvas.Brush.Color := FLAT_STYLE_DOWN_COLOR;
  Bitmap.Canvas.FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
  Bitmap.Canvas.Draw(0, 0, Icon);
  ResizeBitmap(Bitmap, 32, 32);

  Image1.Canvas.Draw(16, 16, Bitmap);
  if Image1.Picture = nil then Exit;
  Edit1.Text := OpenDialog1.FileName;

  Icon.Free;
  Bitmap.Free;
end;


procedure TForm1.Button4Click(Sender: TObject);
begin
  Image1.Canvas.Brush.Color := FLAT_STYLE_DOWN_COLOR;
  Image1.Canvas.FillRect(Rect(0, 0, Image1.Width, Image1.Height));

  Image1.Canvas.Pen.Color := clBlack;
  Image1.Canvas.Rectangle(0, 0, Image1.Width, Image1.Height);

  Edit1.Text := '';
end;


procedure TForm1.ComboBoxChange(Sender: TObject);
var
  Color: TColor;
  HexChar: Char;
begin
  StaticText1.SetFocus;

  case TComboBox(Sender).ItemIndex of
    0: begin Color := $00000000; HexChar := '0'; end;
    1: begin Color := $00AA0000; HexChar := '1'; end;
    2: begin Color := $0000AA00; HexChar := '2'; end;
    3: begin Color := $00AAAA00; HexChar := '3'; end;
    4: begin Color := $000000AA; HexChar := '4'; end;
    5: begin Color := $00AA00AA; HexChar := '5'; end;
    6: begin Color := $000055AA; HexChar := '6'; end;
    7: begin Color := $00AAAAAA; HexChar := '7'; end;
    8: begin Color := $00555555; HexChar := '8'; end;
    9: begin Color := $00FF5555; HexChar := '9'; end;
    10: begin Color := $0055FF55; HexChar := 'A'; end;
    11: begin Color := $00FFFF55; HexChar := 'B'; end;
    12: begin Color := $005555FF; HexChar := 'C'; end;
    13: begin Color := $00FF55FF; HexChar := 'D'; end;
    14: begin Color := $0055FFFF; HexChar := 'E'; end;
    15: begin Color := $FFFFFF; HexChar := 'F'; end;
    else begin Color := $00000000; HexChar := '0'; end;
  end;

  if TComboBox(Sender).Name = 'ComboBox1' then begin
    RichEdit1.Font.Color := Color;
    HexColor[2] := HexChar;
  end;

  if TComboBox(Sender).Name = 'ComboBox2' then begin
    RichEdit1.Color := Color;
    HexColor[1] := HexChar;
  end;
end;


procedure TForm1.Button1Click(Sender: TObject);
var
  i: Integer;
  CustomMBR, nw: Cardinal;
  ArrayOfByte: array of byte;
begin
  SaveDialog1.InitialDir := WideGetCurrentDir;
  if not SaveDialog1.Execute then Exit;

  SaveResource(SaveDialog1.FileName, 'CustomMBR', RT_RCDATA);
  CustomMBR := CreateFileW(PWideChar(SaveDialog1.FileName), GENERIC_WRITE,FILE_SHARE_WRITE, nil, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  SetLength(ArrayOfByte, 1);

  //Ending
  case ComboBox3.ItemIndex of
    0: ArrayOfByte[0] := Ord('1');
    1: ArrayOfByte[0] := Ord('2');
    2: ArrayOfByte[0] := Ord('3');
    else ArrayOfByte[0] := Ord('1');
  end;

  SetFilePointer(CustomMBR, ENDING_ADDRESS, nil, FILE_BEGIN);
  WriteFile(CustomMBR, ArrayOfByte[0], 1, nw, nil);

  //MBR Color
  ArrayOfByte[0] := StrToInt('$' + HexColor) ;
  SetFilePointer(CustomMBR, MBR_COLOR_ADDRESS, nil, FILE_BEGIN);
  WriteFile(CustomMBR, ArrayOfByte[0], 1, nw, nil);

  //UEFI Color
  SetFilePointer(CustomMBR, UEFI_COLOR_ADDRESS, nil, FILE_BEGIN);
  WriteFile(CustomMBR, ArrayOfByte[0], 1, nw, nil);

  //MBR Text
  SetLength(ArrayOfByte, MAX_TEXT_LENGTH);
  FillChar(ArrayOfByte[0], MAX_TEXT_LENGTH, 0);
  Move(RichEdit1.Text[1], ArrayOfByte[0], Length(RichEdit1.Text) * SizeOf(Char));
  SetFilePointer(CustomMBR, MBR_TEXT_ADDRESS, nil, FILE_BEGIN);
  WriteFile(CustomMBR, ArrayOfByte[0], MAX_TEXT_LENGTH, nw, nil);

  //UEFI Text
  SetLength(ArrayOfByte, MAX_TEXT_LENGTH*2);
  FillChar(ArrayOfByte[0], MAX_TEXT_LENGTH*2, 0);
  SetFilePointer(CustomMBR, UEFI_TEXT_ADDRESS, nil, FILE_BEGIN);
  for i := 0 to Length(RichEdit1.Text) do ArrayOfByte[i*2] := Ord(RichEdit1.Text[i+1]);
  WriteFile(CustomMBR, ArrayOfByte[0], MAX_TEXT_LENGTH*2, nw, nil);
  CloseHandle(CustomMBR);

  //Add icon to executable
  if Edit1.Text <> '' then begin
    if not AddIconResource(SaveDialog1.FileName, Edit1.Text, '1') then ShowMessage('Could not add icon!');
  end;

  WideShowMessage('File Created -> ' + SaveDialog1.FileName);
end;

end.