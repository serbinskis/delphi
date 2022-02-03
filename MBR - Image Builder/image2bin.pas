unit image2bin;

interface

uses
  SysUtils, Windows, Classes, Graphics, Functions;

type
  TColorRGB = array [0..2] of byte;
  TDimensionalArray = array of array of Integer;

function ConvertBmp2Bin(Bitmap: TBitmap; Stream: TStream): Boolean;
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


//Delete2DArray
procedure Delete2DArray(var Arr: TDimensionalArray; Index: Integer);
var
  i: Integer;
begin
  for i := Index to High(Arr)-1 do begin
    Arr[i][0] := Arr[i+1][0];
    Arr[i][1] := Arr[i+1][1];
  end;

  SetLength(Arr, High(Arr));
end;
//Delete2DArray


//Insert2DArray
procedure Insert2DArray(var Arr: TDimensionalArray; Index, Count, Color: Integer);
var
  i: Integer;
begin
  SetLength(Arr, High(Arr)+2, 2);

  for i := High(Arr) downto Index+1 do begin
    Arr[i][0] := Arr[i-1][0];
    Arr[i][1] := Arr[i-1][1];
  end;

  Arr[Index][0] := Count;
  Arr[Index][1] := Color;
end;
//Insert2DArray


//Sort2DArray
procedure Sort2DArray(var Arr: TDimensionalArray);
var
  i, Index, Pos: Integer;
  Count, Color: Integer;
begin
  Pos := 0;
  Index := 0;

  while Pos <= High(Arr) do begin
    Count := Arr[Pos][0];
    for i := Pos to High(Arr) do begin
      if Arr[i][0] <= Count then begin
        Count := Arr[i][0];
        Index := i;
      end;
    end;

    If Index <> 0 then begin
      Count := Arr[Index][0];
      Color := Arr[Index][1];

      Delete2DArray(Arr, Index);
      Insert2DArray(Arr, 0, Count, Color);
    end;

    Inc(Pos);
    Index := 0;
  end;
end;
//Sort2DArray


//ColorDistance
function ColorDistance(a, b: Integer): Extended;
var
  aRGB, bRGB: TColorRGB;
begin
  aRGB := ColorToRGB(a);
  bRGB := ColorToRGB(b);
  Result := Sqrt(((aRGB[0]-bRGB[0]) * (aRGB[0]-bRGB[0])) +
                 ((aRGB[1]-bRGB[1]) * (aRGB[1]-bRGB[1])) +
                 ((aRGB[2]-bRGB[2]) * (aRGB[2]-bRGB[2])) );
end;
//ColorDistance


//NearestColor
function NearestColor(color: Integer; var ArrayOfColors: array of TColor): Integer;
var
  i: Integer;
begin
  Result := 0;

  for i := 0 to Length(ArrayOfColors)-1 do begin
    if ColorDistance(color, ArrayOfColors[i]) < ColorDistance(color, ArrayOfColors[Result])
      then Result := i;
  end;
end;
//NearestColor


//ConvertBmp2Bin
function ConvertBmp2Bin(Bitmap: TBitmap; Stream: TStream): Boolean;
var
  i, y, x: Integer;
  Found: Boolean;
  Color: TColor;
  ColorRGB: TColorRGB;
  Colors: TDimensionalArray; //0 - Count; 1 - TColor
  ArrayOfColors: array of TColor;
  a, R, G, B: Char;
begin
  Result := False;

  //Epmty stream to write to it later
  Stream.Position := 0;
  Stream.Size := 0;

  //Generate the color table
  for y := 0 to Bitmap.Height-1 do begin
    for x := 0 to Bitmap.Width-1 do begin
      Color := Bitmap.Canvas.Pixels[x,y];

      Found := False;
      for i := Low(Colors) to High(Colors) do begin
        if Color = Colors[i][1] then begin
          Colors[i][0] := Colors[i][0] + 1;
          Found := True;
          Break;
        end;
      end;

      if not Found then begin
        SetLength(Colors, High(Colors)+2, 2);
        Colors[High(Colors)][1] := Color;
        Colors[High(Colors)][0] := 1;
      end;
    end;
  end;

  //Sort 2DArray by count
  Sort2DArray(Colors);

  //Convert 2DArray to just array
  for i := Low(Colors) to High(Colors) do begin
    SetLength(ArrayOfColors, Length(ArrayOfColors)+1);
    ArrayOfColors[Length(ArrayOfColors)-1] := Colors[i][1];
    ColorRGB := ColorToRGB(ArrayOfColors[Length(ArrayOfColors)-1]);
  end;

  //Get the most used colors (at most 256)
  If Length(ArrayOfColors) > 256 then SetLength(ArrayOfColors, 256);

  //Write the color table information
  a := Chr(Length(ArrayOfColors));
  Stream.Write(a, 1);
  for i := 0 to Length(ArrayOfColors)-1 do begin
    ColorRGB := ColorToRGB(ArrayOfColors[i]);
    R := Chr(ColorRGB[0] div 4);
    G := Chr(ColorRGB[1] div 4);
    B := Chr(ColorRGB[2] div 4);
    Stream.Write(R, 1);
    Stream.Write(G, 1);
    Stream.Write(B, 1);
  end;

  //Write the pixel data
  for y := 0 to Bitmap.Height-1 do begin
    for x := 0 to Bitmap.Width-1 do begin
      Color := Bitmap.Canvas.Pixels[x,y];
      a := Chr(NearestColor(Color, ArrayOfColors));
      Stream.Write(a, 1);
    end;
  end;

  Stream.Position := 0;
  Result := True;
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
  b: UCHAR; //unsigned char
  ml2: Char; //char
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
