unit image2bin;

interface

uses
  SysUtils, Windows, Classes, Graphics, uDynamicData, Functions;

type
  TColorRGB = array [0..2] of byte;

procedure ConvertBmp2Bin(Bitmap: TBitmap; Stream: TStream);
function CompressBin(Stream: TStream): Boolean;

implementation

//ColorToRGB
function ColorToRGB(Color: TColor): TColorRGB;
begin
  Result[0] := GetRValue(Color);
  Result[1] := GetGValue(Color);
  Result[2] := GetBValue(Color);
end;
//ColorToRGB


//ColorDistance
function ColorDistance(a, b: Integer): Extended;
var
  aRGB, bRGB: TColorRGB;
begin
  aRGB := ColorToRGB(a);
  bRGB := ColorToRGB(b);
  Result := Sqrt(((aRGB[0]-bRGB[0]) * (aRGB[0]-bRGB[0])) +
                 ((aRGB[1]-bRGB[1]) * (aRGB[1]-bRGB[1])) +
                 ((aRGB[2]-bRGB[2]) * (aRGB[2]-bRGB[2])));
end;
//ColorDistance


//NearestColor
function NearestColor(color: Integer; var colors: array of Integer): Integer;
var
  i: Integer;
begin
  Result := 0;

  for i := 0 to Length(colors)-1 do begin
    if ColorDistance(color, colors[i]) < ColorDistance(color, colors[Result])
      then Result := i;
  end;
end;
//NearestColor


//Sort colors by amount
function SortCallback(v1, v2: Variant; Progress: Extended; Changed: Boolean): Boolean;
begin
  Result := v1 > v2;
end;


//ConvertBmp2Bin
procedure ConvertBmp2Bin(Bitmap: TBitmap; Stream: TStream);
var
  DynamicData: TDynamicData;
  i, y, x, c: Integer;
  a, r, g, b: Char;
  color: TColor;
  colorRGB: TColorRGB;
  colorArray: array of Integer;
begin
  DynamicData := TDynamicData.Create([]);
  Stream.Position := 0;
  Stream.Size := 0;

  //Generate the color table
  for y := 0 to Bitmap.Height-1 do begin
    for x := 0 to Bitmap.Width-1 do begin
      color := Bitmap.Canvas.Pixels[x, y];
      i := DynamicData.FindIndex('color', color);

      if i > -1 then begin
        c := DynamicData.GetValue(i, 'amount');
        DynamicData.SetValue(i, 'amount', c+1);
      end else begin
        DynamicData.CreateData(-1);
        DynamicData.SetValue(DynamicData.GetLength-1, 'color', color);
        DynamicData.SetValue(DynamicData.GetLength-1, 'amount', 1);
      end;
    end;
  end;

  //Sort and set size
  DynamicData.Sort('amount', SortCallback, stInsertion);
  if DynamicData.GetLength > 255 then DynamicData.SetLength(255);
  SetLength(colorArray, DynamicData.GetLength);

  //Write the color table information
  a := Chr(DynamicData.GetLength);
  Stream.Write(a, 1);

  //Write color table data, and store colors in array for faster access
  for i := 0 to DynamicData.GetLength-1 do begin
    colorArray[i] := DynamicData.GetValue(i, 'color');
    colorRGB := ColorToRGB(colorArray[i]);
    r := Chr(colorRGB[0] div 4);
    g := Chr(colorRGB[1] div 4);
    b := Chr(colorRGB[2] div 4);
    Stream.Write(r, 1);
    Stream.Write(g, 1);
    Stream.Write(b, 1);
  end;

  //Write the pixel data
  for y := 0 to Bitmap.Height-1 do begin
    for x := 0 to Bitmap.Width-1 do begin
      color := Bitmap.Canvas.Pixels[x,y];
      a := Chr(NearestColor(color, colorArray));
      Stream.Write(a, 1);
    end;
  end;

  DynamicData.Destroy;
  Stream.Position := 0;
end;
//ConvertBmp2Bin


//CompressBin
function CompressBin(Stream: TStream): Boolean;
const
  BUFFER_SIZE = 65536;
  LMIN = 4;
  LMAX = 32767;
var
  buffer: array [0..BUFFER_SIZE-1] of UCHAR;
  bytes: array [0..BUFFER_SIZE-1] of UCHAR;
  l, ml, mp2, ml3: WORD; //unsigned short
  fsize, bi, pos: Integer;
  p, mp, bs, bx: Integer;
  b: UCHAR;
  ml2: Char;
begin
  Result := False;

  if Stream.Size > BUFFER_SIZE then begin
    //WriteLn('The input file is too large for compressing.');
    Exit;
  end else if Stream.Size <= 0 then begin
    //WriteLn('The input file is empty.');
    Exit;
  end;

  //Epmty array and read data to buffer
  FillChar(buffer[0], BUFFER_SIZE, 0);
  FillChar(bytes[0], BUFFER_SIZE, 0);
  fsize := Stream.Size;
  Stream.Read(buffer[0], BUFFER_SIZE); //fread(buf, 1, BUFFER_SIZE, infile);

  //Epmty stream to write to it later
  Stream.Position := 0;
  Stream.Size := 0;

  bi := 0;
  pos := 0;
  while pos < fsize do begin
    l := 0;
    ml := 0;
    p := 0;
    mp := 0;

    while (p < pos) do begin //for (; p < pos; p++)
      if (buffer[p] = buffer[pos+l]) and (l < LMAX) then begin
        l := l + 1
      end else begin
        if (l >= ml) and ((pos - p + l) < 32768) then begin
          ml := l;
          mp := p;
        end;

        p := p - l;
        l := 0;
      end;
      p := p + 1
    end;

    if (l >= ml) and ((pos - p + l) < 32768) then begin
      ml := l;
      mp := p;
    end;

    if ml >= LMIN then begin
      bs := 0;
      while bi > 0 do begin
        bx := bi;
        if bx > 128 then bx := 128;
        b := (1 shl 7) or (bx-1);

        Stream.Write(b, 1);
        Stream.Write(bytes[bs], bx);

        bi := bi - bx;
        bs := bs + bx;
      end;

      mp2 := (pos - mp + ml);

      if ml < 64 then begin
        ml2 := Char(ml);
        Stream.Write(ml2, 1);
      end else begin
        ml3 := $4000 or ml; //ml3 = ml2 but unsigned short
        ml3 := (ml3 shr 8) or (ml3 shl 8);
        Stream.Write(ml3, 2); //unsigned short is 2 bytes long
      end;

      Stream.Write(mp2, 2); //unsigned short is 2 bytes long
      pos := pos + ml;
    end else begin
      bytes[bi] := buffer[pos]; //bytes[bi++] = buf[pos++]
      Inc(bi);
      Inc(pos);
    end;
  end;

  bs := 0;
  while bi > 0 do begin
    bx := bi;
    if bx > 128 then bx := 128;
    b := (1 shl 7) or (bx - 1);

    Stream.Write(b, 1);
    Stream.Write(bytes[bs], bx);

    bi := bi - bx;
    bs := bs + bx;
  end;

  Stream.Position := 0;
  Result := True;
end;
//CompressBin

end.
