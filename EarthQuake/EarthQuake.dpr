program EarthQuake;

{$R EarthQuake.res}

uses
  Windows, Classes, Messages, Graphics, MMSystem;

var
  ResourceStream: TResourceStream;
  Bitmap: TBitmap;
  Point: TPoint;
  ThreadId: LongWord;


procedure ShakeScreen;
begin
  Bitmap := TBitmap.Create;
  Bitmap.Width := GetSystemMetrics(SM_CXSCREEN);
  Bitmap.Height := GetSystemMetrics(SM_CYSCREEN);
  BitBlt(Bitmap.Canvas.Handle, 0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN), GetDC(0), 0, 0, SRCCOPY);

  while true do begin
    GetCursorPos(Point);
    SetCursorPos((Point.x + Random(50)) , (Point.y + Random(50)));

    BitBlt(GetDC(0), 0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN), Bitmap.Canvas.Handle, 0, 0, SRCCOPY);
    BitBlt(GetDC(0), 0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN), GetDC(0), 0, 0, SRCERASE);
    BitBlt(GetDC(0), Random(50), Random(50), GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN), Bitmap.Canvas.Handle, 0, 0, SRCCOPY);
    BitBlt(GetDC(0), 0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN), GetDC(0), 0, 0, SRCERASE);
    BitBlt(GetDC(0),  Random(50) - Random(50),  Random(50) - Random(50), GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN), Bitmap.Canvas.Handle, 0, 0, SRCCOPY);

    SetCursorPos((Point.x - (Random(50) - Random(50))) , (Point.y - (Random(50) - Random(50))));
    Sleep(20);
  end;
end;


begin
  PostMessage(FindWindow('Shell_TrayWnd', nil), WM_COMMAND, 419, 0);
  Sleep(1000);

  ResourceStream := TResourceStream.Create(HInstance, 'EARTHQUAKE', 'WAVE');
  ThreadId := BeginThread(nil, 0, Addr(ShakeScreen), nil, 0, ThreadId);
  PlaySound(ResourceStream.Memory, 0, SND_MEMORY or SND_SYNC);
  TerminateThread(ThreadId, 0);

  BitBlt(GetDC(0), 0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN), Bitmap.Canvas.Handle, 0, 0, SRCCOPY);
end.
