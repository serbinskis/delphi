unit WindowsXPHorrorDesktop;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Math, MMSystem, jpeg, GIFImage, Functions;

type
  TForm2 = class(TForm)
    Image0: TImage;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Image10: TImage;
    Image12: TImage;
    Image11: TImage;
    Image13: TImage;
    Timer1: TTimer;
    Timer2: TTimer;
    Timer3: TTimer;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Image0Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
    procedure Image5Click(Sender: TObject);
    procedure Image6Click(Sender: TObject);
    procedure Image7Click(Sender: TObject);
    procedure Image8Click(Sender: TObject);
    procedure Image9Click(Sender: TObject);
    procedure Image10Click(Sender: TObject);
    procedure Image11Click(Sender: TObject);
    procedure Image2DblClick(Sender: TObject);
    procedure Image3DblClick(Sender: TObject);
    procedure Image4DblClick(Sender: TObject);
    procedure Image5DblClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  GIF_IMAGE_TYPE = 0;
  JPG_IMAGE_TYPE = 1;
  CloseMessages: array [0..15] of String = ('WHY YOU WANT TO CLOSE ME?',
                                            'Tick tock, goes the clock.',
                                            'And Now what shall we play?',
                                            'Tick tock, goes the clock.',
                                            'Now Summers gone away.',
                                            'Tick tock, goes the clock.',
                                            'And then what shall we see?',
                                            'Tick tock, until the day.',
                                            'Till thou shalt marry me.',
                                            'Tick tock, goes the clock.',
                                            'And all the years they fly.',
                                            'Tick tock, and all too soon.',
                                            'You and I must die.',
                                            'I WILL HARM YOU IF YOU DOES NOT STOP!',
                                            'THE LAST WARNING!',
                                            'YOU MADE YOUR CHOICE!');

var
  Form2: TForm2;
  CloseCounter: Integer = 0;
  PayloadRunning: Boolean = False;

implementation

{$R *.dfm}


//Hide start menu
procedure HideStartMenu;
begin
  Form2.Image9.Visible := False;
  Form2.Image8.Visible := False;
  Form2.Image10.Visible := False;
  Form2.Image11.Visible := False;
  Form2.Image12.Visible := False;
end;


//Hide desktop icons
procedure HideDesktopIcon;
begin
  Form2.Image2.Visible := False;
  Form2.Image3.Visible := False;
  Form2.Image4.Visible := False;
  Form2.Image5.Visible := False;
end;


//Show desktop icons
procedure ShowDesktopIcon;
begin
  Form2.Image2.Visible := True;
  Form2.Image3.Visible := True;
  Form2.Image4.Visible := True;
  Form2.Image5.Visible := True;
end;


//Hide objects
procedure HideObjects;
begin
  HideStartMenu;
  HideDesktopIcon;
  Form2.Image7.Visible := False;
  Form2.Image13.Visible := False;
  Form2.Image6.Visible := False;
  Form2.Image1.Visible := False;
end;


//Show objects
procedure ShowObjects;
begin
  Form2.Image1.Visible := True;
  Form2.Image6.Visible := True;
  Form2.Image7.Visible := True;
  ShowDesktopIcon;
end;


//Load gif to image
procedure LoadImageGif(Image: TImage; Name: String);
var
  GIFImage: TGIFImage;
begin
  GIFImage := TGIFImage.Create;
  GIFImage.LoadFromResourceName(HInstance, Name);
  Image.Picture.Assign(GIFImage);
  GIFImage.Free;
end;


//Load gif to image
procedure LoadImageJpg(Image: TImage; Name: String);
var
  ResourceStream: TResourceStream;
  JPGImage: TJPEGImage;
begin
  ResourceStream := TResourceStream.Create(HInstance, Name, RT_RCDATA);
  JPGImage := TJPEGImage.Create;
  JPGImage.LoadFromStream(ResourceStream);
  ResourceStream.Free;
  Image.Picture.Graphic := JPGImage;
  JPGImage.Free;
end;


//Load screamer as gif
procedure RunScreamer(Name: String; Time: Integer; ImageType: Integer);
begin
  //Load image from resource
  case ImageType of
    GIF_IMAGE_TYPE: LoadImageGif(Form2.Image0, Name);
    JPG_IMAGE_TYPE: LoadImageJpg(Form2.Image0, Name);
  end;

  //Hide objects and show screamer
  HideObjects;
  Form2.Image0.Visible := True;

  //Wait for a time
  Wait(Time);

  //Clear screamer
  Form2.Image0.Picture.Assign(nil);
  Form2.Image0.Visible := False;

  //Show objects
  ShowObjects;
end;


//When loading form
procedure TForm2.FormShow(Sender: TObject);
begin
  SetWindowLong(Application.Handle, GWL_EXSTYLE, WS_EX_TOOLWINDOW);

  //Set from fullscreen
  Form2.BorderStyle := bsNone;
  Form2.Color := clBlack;
  Form2.Top := 0;
  Form2.Left := 0;
  Form2.Width := GetSystemMetrics(SM_CXSCREEN);
  Form2.Height := GetSystemMetrics(SM_CYSCREEN);

  //Play creepy sound
  PlaySound('CREEPY_DESKTOP', 0, SND_RESOURCE or SND_ASYNC or SND_LOOP);

  //Set object position and play sound
  Image2.Top := 0;
  Image2.Left := 0;

  Image3.Left := 64;
  Image3.Top := 0;

  Image4.Left := GetSystemMetrics(SM_CXSCREEN) - 72;
  Image4.Top := 8;

  Image5.Left := GetSystemMetrics(SM_CXSCREEN) - 72;
  Image5.Top := GetSystemMetrics(SM_CYSCREEN) - 102;

  Image7.Left := 0;
  Image7.Top := GetSystemMetrics(SM_CYSCREEN) - 30;

  Image9.Left := 45;
  Image9.Top := GetSystemMetrics(SM_CYSCREEN) - 105;

  Image8.Left := 177;
  Image8.Top := GetSystemMetrics(SM_CYSCREEN) - 137;

  Image10.Left := 250;
  Image10.Top := GetSystemMetrics(SM_CYSCREEN) - 64;

  Image11.Left := 9;
  Image11.Top := GetSystemMetrics(SM_CYSCREEN) - 198;

  Image12.Left := 0;
  Image12.Top := GetSystemMetrics(SM_CYSCREEN) - 207;

  Image13.Left := 117;
  Image13.Top := GetSystemMetrics(SM_CYSCREEN) - 27;

  //Load cursor
  Screen.Cursors[1] := LoadCursor(HInstance, 'CURSOR');
  Cursor := 1;

  LoadImageGif(Image1, 'DESKTOP'); //Load desktop
  LoadImageGif(Image2, 'MY_COMPUTER'); //Load my computer image
  LoadImageGif(Image3, 'NOTHING'); //Load nothing
  LoadImageGif(Image4, 'DONT_OPEN_ME'); //Load dont open me
  LoadImageGif(Image5, 'RECYCLEBIN'); //Load recycle bin
end;


//When trying to close from
procedure TForm2.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  if PayloadRunning then Exit;
  ShowMessage(CloseMessages[CloseCounter]);
  Inc(CloseCounter);

  if CloseCounter = Length(CloseMessages)
    then if AnsiLowerCase(ParamStr(1)) = '-destructive' then BlueScreenOfDeath
    else TerminateProcess(OpenProcess(PROCESS_TERMINATE, False, GetCurrentProcessId), 0);
end;


//Timer for resizing if screen resolution changed
procedure TForm2.Timer1Timer(Sender: TObject);
begin
  if (GetSystemMetrics(SM_CXSCREEN) < 800) or (GetSystemMetrics(SM_CYSCREEN) < 600)
    then if AnsiLowerCase(ParamStr(1)) = '-destructive' then BlueScreenOfDeath
    else TerminateProcess(OpenProcess(PROCESS_TERMINATE, False, GetCurrentProcessId), 0);

  Form2.Top := 0;
  Form2.Left := 0;
  Form2.Width := GetSystemMetrics(SM_CXSCREEN);
  Form2.Height := GetSystemMetrics(SM_CYSCREEN);

  Image4.Left := GetSystemMetrics(SM_CXSCREEN) - 72;
  Image7.Top := GetSystemMetrics(SM_CYSCREEN) - 30;
  Image8.Top := GetSystemMetrics(SM_CYSCREEN) - 137;
  Image9.Top := GetSystemMetrics(SM_CYSCREEN) - 105;
  Image11.Top := GetSystemMetrics(SM_CYSCREEN) - 198;
  Image10.Top := GetSystemMetrics(SM_CYSCREEN) - 64;
  Image12.Top := GetSystemMetrics(SM_CYSCREEN) - 207;
  Image13.Top := GetSystemMetrics(SM_CYSCREEN) - 27;

  if Image5.Picture.Graphic <> nil then Image5.Left := GetSystemMetrics(SM_CXSCREEN) - 72;;
  if Image5.Picture.Graphic <> nil then Image5.Top := GetSystemMetrics(SM_CYSCREEN) - 102;
end;


//Jumpscare timer
procedure TForm2.Timer2Timer(Sender: TObject);
begin
  if PayloadRunning then Exit;

  //Play jumscare sound
  PlaySound('JUMPSCARE', 0, SND_RESOURCE or SND_ASYNC);

  //Load jumscare randomly
  RunScreamer('JS' + IntToStr(RandomRange(1, 9)), 3000, JPG_IMAGE_TYPE);

  //Load everything back
  PlaySound('CREEPY_DESKTOP', 0, SND_RESOURCE or SND_ASYNC or SND_LOOP);

  //Set random interval for next screamer
  Timer2.Interval := RandomRange(20000, 30000);
  PayloadRunning := False;
end;


//Timer for half life 3 secret
procedure TForm2.Timer3Timer(Sender: TObject);
begin
  if PayloadRunning then Exit;

  if (GetKeyState(VK_CONTROL) >= 0) or
     (GetKeyState(VK_SHIFT) >= 0) or
     (GetKeyState(VK_MENU) >= 0) or
     (GetKeyState(Ord('H')) >= 0) or
     (GetKeyState(Ord('L')) >= 0) or
     (GetKeyState(Ord('3')) >= 0) then Exit;

  //Hide objects
  PayloadRunning := True;
  HideObjects;

  //Play half life sound
  PlaySound('HALF_LIFE_3', 0, SND_RESOURCE or SND_ASYNC);

  //Change Background
  RunScreamer('HALF_LIFE_3', 15000, JPG_IMAGE_TYPE);

  //Load everything back
  PlaySound('CREEPY_DESKTOP', 0, SND_RESOURCE or SND_ASYNC or SND_LOOP);
  ShowObjects;
  PayloadRunning := False;
end;


//When clicking on my computer
procedure TForm2.Image2Click(Sender: TObject);
begin
  HideStartMenu;
end;


//When clicking on nothing
procedure TForm2.Image3Click(Sender: TObject);
begin
  HideStartMenu;
end;


//When clicking on desktop
procedure TForm2.Image1Click(Sender: TObject);
begin
  HideStartMenu;
end;


//When clicking on taskbar
procedure TForm2.Image6Click(Sender: TObject);
begin
  HideStartMenu;
end;


//When clicking on recycle bin
procedure TForm2.Image5Click(Sender: TObject);
begin
  HideStartMenu;
end;


//When clicking on dont open me
procedure TForm2.Image4Click(Sender: TObject);
begin
  HideStartMenu;
end;
//StartMenu Hide


//When clicking on artifact one
procedure TForm2.Image8Click(Sender: TObject);
begin
  Image8.Picture.Bitmap.Assign(nil);
end;


//When clicking on artifact two
procedure TForm2.Image9Click(Sender: TObject);
begin
  Image9.Picture.Bitmap.Assign(nil);
end;


//When double clicking recycle bin
procedure TForm2.Image5DblClick(Sender: TObject);
begin
  LoadImageGif(Image5, 'RECYCLEBIN_GLITCH');
  Image5.Enabled := False;
end;


//When clicking on start button - show or hide start menu
procedure TForm2.Image7Click(Sender: TObject);
begin
  if PayloadRunning then Exit;
  Image12.Visible := not Image12.Visible;
  Image11.Visible := not Image11.Visible;
  Image10.Visible := not Image10.Visible;
  Image8.Visible := not Image8.Visible;
  Image9.Visible := not Image9.Visible;
end;


//When clicking on turn off computer
procedure TForm2.Image10Click(Sender: TObject);
begin
  MyExitWindows(EWX_REBOOT or EWX_FORCE);
  TerminateProcess(OpenProcess(PROCESS_TERMINATE, False, GetCurrentProcessId), 0);
end;


//When double clicking on my computer
procedure TForm2.Image2DblClick(Sender: TObject);
var
  ButtonSelected: Integer;
begin
  if PayloadRunning then Exit;
  PayloadRunning := True;

  ButtonSelected := MessageDlg('DO YOU SERIOUSLY WANT TRASH YOUR COMPUTER FOREVER?', mtConfirmation, [mbYes, mbNo], 0);
  if ButtonSelected <> mrYes then MessageDlg('DO YOU SERIOUSLY WANT TRASH YOUR COMPUTER FOREVER?', mtConfirmation, [mbYes], 0);

  while true do begin
    Wait(1);
    if Image2.Left >= (GetSystemMetrics(SM_CXSCREEN) - 64) then Image2.Left := (GetSystemMetrics(SM_CXSCREEN)- 64) else Image2.Left := Image2.Left + 20;
    if Image2.Top >= (GetSystemMetrics(SM_CYSCREEN) - 94) then Image2.Top := (GetSystemMetrics(SM_CYSCREEN) - 94) else Image2.Top := Image2.Top + 11;
    SetCursorPos(Image2.Left + 32, Image2.Top + 32);

    if Image2.Left = (GetSystemMetrics(SM_CXSCREEN) - 64) then if Image2.Top = (GetSystemMetrics(SM_CYSCREEN) - 94) then begin
      Image2.Picture.Assign(nil);
      Image5.Picture.Assign(nil);
      sndPlaySound(nil, SND_ASYNC);
      Break;
    end;
  end;

  //Hide objects and cursor
  HideObjects;
  ShowCursor(False);

  //Wait for a time
  Wait(5000);

  //Load jumpscare
  PlaySound('FNAF_JUMPSCARE', 0, SND_RESOURCE or SND_ASYNC);
  RunScreamer('FNAF_JUMPSCARE', 2000, GIF_IMAGE_TYPE);

  //Load fake rsod
  PlaySound('RSOD', 0, SND_RESOURCE or SND_ASYNC or SND_LOOP);
  RunScreamer('RSOD', 2000, GIF_IMAGE_TYPE);

  //Cause real bsod or exit
  if AnsiLowerCase(ParamStr(1)) = '-destructive'
    then BlueScreenOfDeath
    else TerminateProcess(OpenProcess(PROCESS_TERMINATE, False, GetCurrentProcessId), 0);
end;


//When click on dont open me load notepad and the granny
procedure TForm2.Image4DblClick(Sender: TObject);
begin
  if PayloadRunning then Exit;
  PayloadRunning := True;

  //Play sound and change screamer to notepad
  PlaySound('NOTEPAD', 0, SND_RESOURCE or SND_ASYNC);

  //Make screamer unstreacted and centered
  Image0.Stretch := False;
  Image0.Center := True;

  ShowCursor(False); //Hide cursor
  Image0.Visible := True; //Show screamer
  Image13.Visible := True; //Small image on taskbar

  //Load notepad as screamer
  LoadImageJpg(Image0, 'NOTEPAD');

  //Wait for a time
  Wait(7000);

  //Make screamer streacted and uncentered
  Image0.Stretch := True;
  Image0.Center := False;

  //Play granny screamer and sound
  PlaySound('GRANNY', 0, SND_RESOURCE or SND_ASYNC);
  RunScreamer('GRANNY', 4000, GIF_IMAGE_TYPE);

  //Load everything back
  PlaySound('CREEPY_DESKTOP', 0, SND_RESOURCE or SND_ASYNC or SND_LOOP);

  //Load glitching dont open me
  LoadImageGif(Image4, 'DONT_OPEN_ME_GLITCH');

  //Disable dont open me and show cursor
  Image4.Enabled := False;
  ShowCursor(True);
  PayloadRunning := False;
end;


//When double click on nothing play ass weird animation
procedure TForm2.Image3DblClick(Sender: TObject);
begin
  if PayloadRunning then Exit;
  PayloadRunning := True;

  //Play ass weird animation and sound
  PlaySound('ANIMATION', 0, SND_RESOURCE or SND_ASYNC or SND_LOOP);
  RunScreamer('ANIMATION', 130000, GIF_IMAGE_TYPE);

  //Load everything back
  PlaySound('CREEPY_DESKTOP', 0, SND_RESOURCE or SND_ASYNC or SND_LOOP);

  //Load glitching dont open me
  LoadImageGif(Image3, 'NOTHING_GLITCH');
  Image3.Enabled := False;
  PayloadRunning := False;
end;


//When cliciing on user profile image
procedure TForm2.Image11Click(Sender: TObject);
begin
  PayloadRunning := True;

  //Hide objects and wait for a time
  HideObjects;
  sndPlaySound(nil, SND_ASYNC);
  Wait(1000);

  //Load door as screamer
  LoadImageJpg(Image0, 'DOOR');

  //Make screamer visible and enabled for click
  Image0.Visible := True;
  Image0.Enabled := True;
  PlaySound('DOOR_KNOCKING', 0, SND_RESOURCE or SND_ASYNC or SND_LOOP);
end;


//When clicking on door
procedure TForm2.Image0Click(Sender: TObject);
begin
  //Disable clicking and remove sound
  Image0.Enabled := False;
  sndPlaySound(nil, SND_ASYNC);

  //Wait for a time
  Wait(3000);

  //Load door opening gif
  PlaySound('DOOR_OPENING', 0, SND_RESOURCE or SND_ASYNC);
  RunScreamer('DOOR_OPENING', 8000, GIF_IMAGE_TYPE);

  //Load screamer gif after door opened
  PlaySound('DOOR_SCREAMER', 0, SND_RESOURCE or SND_ASYNC);
  RunScreamer('DOOR_SCREAMER', 3000, GIF_IMAGE_TYPE);

  //Load go to sleep gif
  PlaySound('GO_TO_SLEEP', 0, SND_RESOURCE or SND_ASYNC);
  RunScreamer('GO_TO_SLEEP', 5000, JPG_IMAGE_TYPE);

  //Load everything back
  PlaySound('CREEPY_DESKTOP', 0, SND_RESOURCE or SND_ASYNC or SND_LOOP);

  //Load glitching gif to user profile image
  LoadImageGif(Image11, 'P666_GLITCH');
  Image11.Enabled := False;
  PayloadRunning := False;
end;

end.
