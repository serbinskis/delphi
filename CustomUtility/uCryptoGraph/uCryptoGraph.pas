unit uCryptoGraph;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StdCtrls, Math, ExtCtrls, ShellAPI, Menus, Functions;

const
  WM_CALLBACK_MESSAGE = WM_USER + 7261;
  DAY_GRAPH = 'https://min-api.cryptocompare.com/data/histominute?fsym=<coin>&tsym=<currency>&limit=1440&e=CCCAGG';
  CURRENT_PRICE = 'https://min-api.cryptocompare.com/data/price?fsym=<coin>&tsyms=<currency>&e=CCCAGG';
  SKIP_GRAPH = 10;

const
  DEFAULT_ROOT_KEY = HKEY_CURRENT_USER;
  DEFAULT_KEY = '\Software\WakeOnLan';

type
  TCrypto = record
    CryptoList: array of Extended;
    MaxValue, MinValue: Extended;
    AvgValue, CurValue: Extended;
    DifPercentage: Extended;
    Currency: String;
  end;

type
  TSettingsDB = record
    Coin: String;
    Currency: String;
  end;

type
  TCryptoGraph = class(TForm)
    Image1: TImage;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    StaticText9: TStaticText;
    StaticText10: TStaticText;
    Timer1: TTimer;
    Timer2: TTimer;
    Bevel1: TBevel;
    PopupMenu1: TPopupMenu;
    Exit1: TMenuItem;
    Options1: TMenuItem;
    Update1: TMenuItem;
    procedure TrayOnClick(var msg: TMessage); message WM_CALLBACK_MESSAGE;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ApplicationDecativate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure DrawGraph(CP: TCrypto);
    procedure Options1Click(Sender: TObject);
    procedure Update1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CryptoGraph: TCryptoGraph;
  AppInactive: Boolean;
  Crypto: TCrypto;
  SettingsDB: TSettingsDB;
  TrayIconData: TNotifyIconData;

implementation

uses uCryptoSettings;

{$R *.dfm}


function Percentage(x, min, max: Extended): Extended;
begin
  Result := ((x-min)/(max-min));
end;


function PercentageNumber(p, min, max: Extended): Extended;
begin
  p := (100-p)/100;
  Result := p*min-p*max+max;
end;


function URLToString(URL: String): String;
var
  MemoryStream: TMemoryStream;
begin
  MemoryStream := TMemoryStream.Create;
  URLDownloadToStream(URL, MemoryStream);
  Result := StreamToString(MemoryStream);
  MemoryStream.Free;
end;


function CreateIcon(num: Extended): TIcon;
var
  Font: TFont;
  Bitmap: TBitmap;
  ImageList: TImageList;
  S: String;
  x, y: Integer;
begin
  Bitmap := TBitmap.Create;
  Bitmap.Width := 16;
  Bitmap.Height := 16;

  Font := TFont.Create;
  Font.Color := clGray;
  Font.Name := 'Calibri';
  Font.Size := 10;

  if num > 99 then num := 99;
  if num < -99 then num := -99;

  if num > 0 then Font.Color := clLime;
  if num < 0 then Font.Color := clRed;

  Bitmap.Canvas.Font.Assign(Font);
  S := IntToStr(Abs(Round(num)));
  x := Round(16/2 - Bitmap.Canvas.TextWidth(S)/2);
  y := Round(16/2 - Bitmap.Canvas.TextHeight(S)/2);

  Bitmap.Canvas.Brush.Color := clWhite;
  Bitmap.Canvas.Pen.Color := clBlack;

  Bitmap.Canvas.Brush.Style := bsSolid;
  Bitmap.Canvas.FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
  Bitmap.Canvas.Brush.Style := bsClear;
  Bitmap.Canvas.Rectangle(0, 0, Bitmap.Width, Bitmap.Height);
  Bitmap.Canvas.TextOut(x, y, S);

  Result := TIcon.Create;
  ImageList := TImageList.CreateSize(Bitmap.Width, Bitmap.Height);
  ImageList.AddMasked(Bitmap, RGB(255, 0, 255));
  ImageList.GetIcon(0, Result);

  Bitmap.Free;
  ImageList.Free;
  Font.Free;
end;


function GetCryptoValue(Coin, Currency: String): Extended;
var
  S: String;
  x, z: Integer;
begin
  S := StringReplace(CURRENT_PRICE, '<coin>', Coin, [rfReplaceAll, rfIgnoreCase]);
  S := StringReplace(S, '<currency>', Currency, [rfReplaceAll, rfIgnoreCase]);
  S := URLToString(S);

  z := 0;
  x := Pos('":', S);

  if x <> 0 then while S[x+z] <> '}' do Inc(z);
  S := StringReplace(Copy(S, x+2, z-2), '.', ',', [rfReplaceAll, rfIgnoreCase]);
  Result := StrToFloat(S);
end;


function GetCryptInfo(Coin, Currency: String): TCrypto;
var
  StringList: TStringList;
  S: String;
  i, x, z: Integer;
begin
  Result.CurValue := GetCryptoValue(Coin, Currency);

  S := StringReplace(DAY_GRAPH, '<coin>', Coin, [rfReplaceAll, rfIgnoreCase]);
  S := StringReplace(S, '<currency>', Currency, [rfReplaceAll, rfIgnoreCase]);
  S := URLToString(S);

  StringList := TStringList.Create;
  StringList.Delimiter := '}';
  StringList.DelimitedText := S;
  SetLength(Result.CryptoList, 0);

  Result.Currency := Currency;
  Result.MaxValue := 0;
  Result.MinValue := Infinity;
  Result.AvgValue := 0;

  //Parse values
  for i := 0 to StringList.Count-1 do begin
    S := StringList.Strings[i];
    x := Pos('close', S);
    z := 7; //Length of 'close":'

    if x <> 0 then begin
      SetLength(Result.CryptoList, Length(Result.CryptoList)+1);

      while S[x+z] <> ',' do Inc(z);
      S := StringReplace(Copy(S, x+7, z-7), '.', ',', [rfReplaceAll, rfIgnoreCase]);
      Result.CryptoList[Length(Result.CryptoList)-1] := StrToFloat(S);

      x := Length(Result.CryptoList)-1;
      if Result.CryptoList[x] > Result.MaxValue then Result.MaxValue := Result.CryptoList[x];
      if Result.CryptoList[x] < Result.MinValue then Result.MinValue := Result.CryptoList[x];
      Result.AvgValue := Result.AvgValue + Result.CryptoList[x];
    end;
  end;

  Result.AvgValue := Result.AvgValue/Length(Result.CryptoList);
  Result.DifPercentage := (Percentage(Result.CurValue, Result.MinValue, Result.MaxValue) - Percentage(Result.AvgValue, Result.MinValue, Result.MaxValue))*100;
  StringList.Free;
end;


procedure DrawText(Canvas: TCanvas; Color: TColor; S: String; x, y: Integer);
var
  Font: TFont;
  Style: TBrushStyle;
begin
  Font := TFont.Create;
  Font.Color := Color;
  Font.Name := 'Calibri';
  Font.Size := 11;
  Font.Style := [fsBold];

  Style := Canvas.Brush.Style;
  Canvas.Brush.Style := bsClear;
  Canvas.Font.Assign(Font);
  Canvas.TextOut(x, y, S);
  Canvas.Brush.Style := Style;
end;


procedure TCryptoGraph.DrawGraph(CP: TCrypto);
var
  i: Integer;
  x, y, w, h: Integer;
begin
  if Length(CP.CryptoList) = 0 then Exit;

  w := Image1.Width;
  h := Image1.Height;

  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.FillRect(Rect(0, 0, w, h));

  StaticText1.Caption := Format('%.2f %s', [PercentageNumber(10, CP.MinValue, CP.MaxValue), CP.Currency]);
  StaticText2.Caption := Format('%.2f %s', [PercentageNumber(20, CP.MinValue, CP.MaxValue), CP.Currency]);
  StaticText3.Caption := Format('%.2f %s', [PercentageNumber(30, CP.MinValue, CP.MaxValue), CP.Currency]);
  StaticText4.Caption := Format('%.2f %s', [PercentageNumber(40, CP.MinValue, CP.MaxValue), CP.Currency]);
  StaticText5.Caption := Format('%.2f %s', [PercentageNumber(50, CP.MinValue, CP.MaxValue), CP.Currency]);
  StaticText6.Caption := Format('%.2f %s', [PercentageNumber(60, CP.MinValue, CP.MaxValue), CP.Currency]);
  StaticText7.Caption := Format('%.2f %s', [PercentageNumber(70, CP.MinValue, CP.MaxValue), CP.Currency]);
  StaticText8.Caption := Format('%.2f %s', [PercentageNumber(80, CP.MinValue, CP.MaxValue), CP.Currency]);
  StaticText9.Caption := Format('%.2f %s', [PercentageNumber(90, CP.MinValue, CP.MaxValue), CP.Currency]);
  StaticText10.Caption := Format('%.2f %s', [PercentageNumber(100, CP.MinValue, CP.MaxValue), CP.Currency]);

  Image1.Canvas.Pen.Color := RGB(236, 240, 249);
  Image1.Canvas.Pen.Width := 1;

  for i := 1 to 10 do begin
    y := Round(PercentageNumber(i*10, 0, h) - (PercentageNumber(10, 0, h)/2));
    Image1.Canvas.MoveTo(0, y);
    Image1.Canvas.LineTo(w, y);
  end;

  Image1.Canvas.Pen.Color := clYellow;
  Image1.Canvas.Pen.Width := 3;

  x := 0;
  y := h-Round(Percentage(CP.CryptoList[0], CP.MinValue, CP.MaxValue)*h);
  Image1.Canvas.MoveTo(x, y);

  for i := 1 to (Length(CP.CryptoList)div SKIP_GRAPH)-1 do begin
    x := Round(Percentage(i*SKIP_GRAPH, 0, Length(CP.CryptoList))*w);
    y := h-Round(Percentage(CP.CryptoList[i*SKIP_GRAPH], CP.MinValue, CP.MaxValue)*h);
    Image1.Canvas.LineTo(x, y);
  end;

  x := w;
  y := h-Round(Percentage(CP.CryptoList[Length(CP.CryptoList)-1], CP.MinValue, CP.MaxValue)*h);
  Image1.Canvas.LineTo(x, y);

  y := h-Round(Percentage(CP.AvgValue, CP.MinValue, CP.MaxValue)*h);
  Image1.Canvas.Pen.Color := clRed;
  Image1.Canvas.MoveTo(0, y);
  Image1.Canvas.LineTo(w, y);

  y := h-Round(Percentage(CP.CurValue, CP.MinValue, CP.MaxValue)*h);
  if y >= h then y := h-1;
  if y < 1 then y := 1;
  Image1.Canvas.Pen.Color := clGreen;
  Image1.Canvas.MoveTo(0, y);
  Image1.Canvas.LineTo(w, y);

  DrawText(Image1.Canvas, clRed, Format('Avg: %.4f %s', [CP.AvgValue, CP.Currency]), 10, h-25);
  DrawText(Image1.Canvas, clGreen, Format('Cur: %.4f %s', [CP.CurValue, CP.Currency]), 10, h-45);
  DrawText(Image1.Canvas, clBlack, Format('Avg/Cur: %.4f%%', [CP.DifPercentage]), 10, h-65);
end;


procedure TCryptoGraph.Timer1Timer(Sender: TObject);
begin
  if not IsInternet then Exit;

  Timer2.Enabled := False;
  Crypto := GetCryptInfo(SettingsDB.Coin, SettingsDB.Currency);
  StrPCopy(TrayIconData.szTip, 'Crypto Graph - ' + SettingsDB.Coin);

  TrayIconData.hIcon := CreateIcon(Round(Crypto.DifPercentage)).Handle;
  Shell_NotifyIcon(NIM_MODIFY, @TrayIconData);

  if CryptoGraph.Visible then begin
    DrawGraph(Crypto);
    Timer2.Enabled := True;
  end;
end;


procedure TCryptoGraph.Timer2Timer(Sender: TObject);
begin
  if CryptoGraph.Visible then begin
    if not IsInternet then Exit;
    Crypto.CurValue := GetCryptoValue(SettingsDB.Coin, SettingsDB.Currency);
    DrawGraph(Crypto);
  end;
end;


procedure TCryptoGraph.TrayOnClick(var Msg: TMessage);
var
  Point: TPoint;
begin
  case Msg.LParam of
    WM_RBUTTONDOWN: begin
      GetCursorPos(Point);
      SetForegroundWindow(Application.Handle);
      Application.ProcessMessages;
      PopupMenu1.Popup(Point.X, Point.Y);
    end;

    WM_LBUTTONUP: begin
      if (not CryptoGraph.Visible and not AppInactive)
        then CryptoGraph.Show
        else CryptoGraph.Hide;
    end;
  end;
end;


procedure TCryptoGraph.FormCreate(Sender: TObject);
begin
  Application.Title := 'Crypto Graph';
  while not IsInternet do Wait(1000);

  LoadRegistryString(SettingsDB.Coin, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'Coin');
  LoadRegistryString(SettingsDB.Currency, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'Currency');

  if ParamStr(2) <> '' then SettingsDB.Coin := AnsiUpperCase(ParamStr(2));
  if ParamStr(3) <> '' then SettingsDB.Currency := AnsiUpperCase(ParamStr(3));

  FillChar(TrayIconData, SizeOf(TrayIconData), 0);
  TrayIconData.cbSize := SizeOf(TrayIconData);
  TrayIconData.Wnd := Handle;
  TrayIconData.uID := 0;
  TrayIconData.uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
  TrayIconData.uCallbackMessage := WM_CALLBACK_MESSAGE;
  TrayIconData.hIcon := CreateIcon(0).Handle;
  StrPCopy(TrayIconData.szTip, Application.Title);
  Shell_NotifyIcon(NIM_ADD, @TrayIconData);

  Timer1Timer(nil);
end;


procedure TCryptoGraph.FormShow(Sender: TObject);
var
  ActiveMonitor: Integer;
  MonitorWidth, MonitorHeigth: Integer;
  WorkareaRect: TRect;
begin
  SetForegroundWindow(Handle);
  Application.OnDeactivate := ApplicationDecativate;

  ActiveMonitor := GetActiveMonitor;
  MonitorWidth := Screen.Monitors[ActiveMonitor].Left + Screen.Monitors[ActiveMonitor].Width;
  MonitorHeigth := Screen.Monitors[ActiveMonitor].Top + Screen.Monitors[ActiveMonitor].Height;
  WorkareaRect := Screen.Monitors[ActiveMonitor].WorkareaRect;

  CryptoGraph.Left := MonitorWidth - CryptoGraph.Width - 5;
  CryptoGraph.Top := MonitorHeigth - CryptoGraph.Height - (MonitorHeigth - WorkareaRect.Bottom) - 5;

  DrawGraph(Crypto);
  Timer2.Enabled := True;
end;


procedure TCryptoGraph.FormHide(Sender: TObject);
begin
  Application.OnDeactivate := nil;
end;


procedure TCryptoGraph.ApplicationDecativate(Sender: TObject);
begin
  AppInactive := True;
  Timer2.Enabled := False;
  CryptoGraph.Hide;
  Wait(350);
  AppInactive := False;
end;


procedure TCryptoGraph.FormPaint(Sender: TObject);
begin
  Canvas.Rectangle(0, 0, CryptoGraph.Width, CryptoGraph.Height);
end;


procedure TCryptoGraph.Options1Click(Sender: TObject);
begin
  CryptoSettings.Show;
end;


procedure TCryptoGraph.Update1Click(Sender: TObject);
begin
  Timer1Timer(nil);
end;


procedure TCryptoGraph.Exit1Click(Sender: TObject);
begin
  Shell_NotifyIcon(NIM_DELETE, @TrayIconData);
  Application.Terminate;
end;


initialization
  SettingsDB.Coin := 'BTC';
  SettingsDB.Currency := 'USD';
end.
