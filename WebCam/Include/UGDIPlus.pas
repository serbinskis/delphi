unit UGDIPlus;

// Version 1.2

// Basic routines for reading a JPEG stream for use in VFrames
// Please note: There are a lot of sources for GDI+, which are complete and tested.
//              (e.g. here http://www.progdigy.com/ )
//              My own curiosity is the reason for this unit here. Maybe it can
//              be easily replaced by one of the community-versions


// With more or less help/inspirations from the following sites:
// http://www.activevb.de/tipps/vb6tipps/tipp0687.html
// http://www.codeproject.com/KB/GDI-plus/MemImage.aspx
// http://www.pcreview.co.uk/forums/thread-1897219.php
// http://www.delphipraxis.net/post514521.html
// http://com.it-berater.org/gdiplus/noframes/image_functions.htm
// http://www.efg2.com/Lab/Library/UseNet/1997/1026.txt
// http://www.delphipraxis.net/post514521.html
// http://www.delphi-library.de/topic_Wie+kann+ich+flimmerfrei+in+den+Canvas+Zeichnen_74.html&sid=76167fc6f086b0cd8f208ea73acc8f58
// http://www.delphipraxis.net/126837-layeredwindows-sporadische-zugriffsverletzung-bei-streams.html


interface



USES Windows, Graphics, SysUtils, Classes, ActiveX;



FUNCTION GDIPlus_LoadBMPStream(OleStream: IStream; BMP: TBitmap): integer;
FUNCTION GDIPlus_LoadBMPStream2(Stream: TStream; BMP: TBitmap): integer;
FUNCTION GDIPlusAvailable: boolean;




implementation


TYPE
  TPixelFormat = integer;

TYPE
  // http://msdn.microsoft.com/en-us/library/ms534434%28v=vs.85%29.aspx
  EncoderParameter   = packed record
                         Guid           : TGUID;    // Identifies the parameter category
                         NumberOfValues : cardinal; // Number of values in the array pointed to by the Value data member.
                         Type_          : cardinal; // Identifies the data type of the parameter
                         Value          : Pointer;  // Pointer to an array of values
                       end;
  TEncoderParameter  = EncoderParameter;
  PEncoderParameter  = ^TEncoderParameter;

  // http://msdn.microsoft.com/en-us/library/ms534435%28v=vs.85%29.aspx
  EncoderParameters  = packed record
                         Count     : DWord;                             // Number of EncoderParameter objects in the array.
                         Parameter : array[0..0] of TEncoderParameter;  // Array of EncoderParameter objects.
                       end;
  TEncoderParameters = EncoderParameters;
  PEncoderParameters = ^TEncoderParameters;
  
  // http://msdn.microsoft.com/en-us/library/ms534466%28v=vs.85%29.aspx
  ImageCodecInfo     = packed record
                         Clsid             : TGUID;  // Codec identifier.
                         FormatID          : TGUID;  // File format identifier.
                         CodecName         : PWChar; // Pointer to a null-terminated string that contains the codec name.
                         DllName           : PWChar; // Pointer to a null-terminated string that contains the path name of the DLL in which the codec resides.
                         FormatDescription : PWChar; // Pointer to a null-terminated string that contains the name of the file format used by the codec.
                         FilenameExtension : PWChar; // Pointer to a null-terminated string that contains all file-name extensions associated with the codec
                         MimeType          : PWChar; // Pointer to a null-terminated string that contains the mime type of the codec.
                         Flags             : DWord;  // Combination of flags from the ImageCodecFlags enumeration.
                         Version           : DWord;  // Integer that indicates the version of the codec.
                         SigCount          : DWord;  // Integer that indicates the number of signatures used by the file format associated with the codec.
                         SigSize           : DWord;  // Integer that indicates the number of bytes in each signature.
                         SigPattern        : PByte;  // Pointer to an array of bytes that contains the pattern for each signature.
                         SigMask           : PByte;  // Pointer to an array of bytes that contains the mask for each signature.
                       end;
  TImageCodecInfo    = ImageCodecInfo;
  PImageCodecInfo    = ^TImageCodecInfo;

  PARGB  = ^ARGB;
  ARGB   = DWORD;
  ColorPalette = packed record
    Flags  : UINT ;                 // Palette flags
    Count  : UINT ;                 // Number of color entries
    Entries: array [0..0] of ARGB ; // Palette color entries
  end;

  TColorPalette = ColorPalette;
  PColorPalette = ^TColorPalette;



type
  GPPixelFormat       = integer;
  GPSTATUS            = integer;
  GPBITMAP            = integer;
  GPIMAGE             = integer;
  GDIPlusStartupInput = record
                          GdiPlusVersion           : integer;
                          DebugEventCallback       : integer;
                          SuppressBackgroundThread : integer;
                          SuppressExternalCodecs   : integer;
                        end;


VAR
  hGDIP                        : Cardinal = 0;
  GdipToken                    : Integer;
  StartUpInfo                  : GDIPlusStartupInput;
  GdiplusStartup               : function(var token: Integer; var lpInput: GDIPlusStartupInput; lpOutput: Integer): GPSTATUS; stdcall;
  GdiplusShutdown              : function(var token: Integer): GPSTATUS; stdcall;

  GdipGetImageDimension        : function(image: Integer; var Width, Height: Single): GPSTATUS; stdcall;
  GdipDisposeImage             : function(image: Integer): GPSTATUS; stdcall;
  GdipCreateBitmapFromStream   : function(OleStream: IStream; VAR bitmap: GPBITMAP): GPSTATUS; stdcall;
  GdipCreateHBITMAPFromBitmap  : function(bitmap: GPBITMAP; var hbmReturn: integer;  background: integer): GPSTATUS; stdcall;
  GdipGetImagePixelFormat      : function(image: GPIMAGE; out format: GPPIXELFORMAT): GPSTATUS; stdcall;
  GdipGetImagePaletteSize      : function(image: GPIMAGE; var size: Integer): GPSTATUS; stdcall;
  GdipGetImagePalette          : function(image: GPIMAGE; palette: PCOLORPALETTE; size: Integer): GPSTATUS; stdcall;




FUNCTION GDIPlus_ToBitmap(hImg: GPBITMAP; BMP: TBitmap): integer;
VAR
  j, hb              : integer;
  bm                 : TBitmap;
  ImgWidth, ImgHeight: Single;
  PixelFormat        : GPPixelFormat;
  BitsPerPixel       : integer;
  PalSize            : integer;
  PColPal            : PColorPalette;
  PLP                : PLogPalette;
  G                  : ARRAY[0..255] OF integer;
BEGIN
  IF hGDIP = 0 then
    begin
      Result := -1;
      exit;
    end;

  IF not(assigned(BMP)) THEN
    BEGIN
      Result := 6;
      EXIT;
    END;


  PColPal := nil;
  bm := TBitmap.Create;
  GdipGetImageDimension(hImg, ImgWidth, ImgHeight);
  GdipGetImagePixelFormat(hImg, PixelFormat);
  BitsPerPixel := (PixelFormat shr 8) and $FF;
  CASE BitsPerPixel and $FFFF OF
     1 : BM.PixelFormat := pf1bit;
     4 : BM.PixelFormat := pf4bit;
     8 : BM.PixelFormat := pf8bit;
    15 : BM.PixelFormat := pf15bit;
    16 : BM.PixelFormat := pf16bit;
    24 : BM.PixelFormat := pf24bit;
    ELSE BM.PixelFormat := pf32bit;
  END; {case}
  BMP.Width  := round(ImgWidth);
  BMP.Height := round(ImgHeight);
  PLP := nil;
  PalSize := 0;
  Result := GdipCreateHBITMAPFromBitmap(hImg, hb, 0);
  IF Result = 0 then
    begin
      // Palette loading necessary?
      IF BitsPerPixel <= 8 then
        begin
          Result := GdipGetImagePaletteSize(hImg, PalSize);
          IF Result = 0 then
            begin
              GetMem(PColPal, PalSize);
              GetMem(PLP, PalSize-4);
              Result := GdipGetImagePalette(hImg, PColPal, PalSize);
              IF Result = 0 then
                begin
                  PLP^.palVersion := $300;
                  PLP^.palNumEntries := PColPal^.Count;
                  move(PColPal^.Entries[0], PLP^.palPalEntry[0], PalSize-8);
                  move(PColPal^.Entries[0], G, PalSize-8);
                  FOR j := 0 TO 255 DO
                    G[j] := G[J] and $00FFFFFF;
                  move(G, PLP^.palPalEntry[0], PalSize-8);
                  bm.PixelFormat := pf8bit;
                  SetDIBColorTable(BM.Canvas.Handle, 0, PLP^.palNumEntries, PLP^.palPalEntry[0]);
                end;
            end;
        end;
      // Apply image data
      try
        bm.Handle := THandle(hb);
      except
      end;
      {
      // If palette is used, apply it
      IF PLP <> nil then
        SetDIBColorTable(PNG.Canvas.Handle, 0, PLP^.palNumEntries, PLP^.palPalEntry[0]);
      }
      {
      // At the moment, force at least 24bit image. Palette handling will be added later...
      IF BMP.PixelFormat < pf24bit then
        BMP.PixelFormat := pf24bit;
      }  
      BMP.Canvas.Draw(0, 0, bm);

      // Delete temporary objects
      try
        DeleteObject(THandle(hb));
      except
      end;
      IF PLP <> nil then
        FreeMem(PLP, PalSize-4);
      IF PColPal <> nil then
        FreeMem(PColPal, PalSize);
    end;

  bm.Free;
END;







FUNCTION GDIPlus_LoadBMPStream(OleStream: IStream; BMP: TBitmap): integer;
VAR
  hImg               : GPBITMAP;
BEGIN
  IF hGDIP = 0 then
    begin
      Result := -1;
      exit;
    end;

  IF not(assigned(BMP)) THEN
    BEGIN
      Result := 6;
      EXIT;
    END;


  Result := GdipCreateBitmapFromStream(OleStream, hImg);
  IF Result = 0 then
    begin
      Result := GDIPlus_ToBitmap(hImg, BMP);
      GdipDisposeImage(hImg);
    end;
END;



FUNCTION GDIPlus_LoadBMPStream2(Stream: TStream; BMP: TBitmap): integer;
var
  OleStream: IStream;
begin
  OleStream := TStreamAdapter.Create(Stream);
  Result := GDIPlus_LoadBMPStream(OleStream, BMP);
end;




PROCEDURE GDIPlus_Start;
VAR
  OK : boolean;
BEGIN
  hGDIP := LoadLibrary('gdiplus.dll');
  if hGDIP <> 0 then
    begin
      OK := false;
      GdiplusStartup := GetProcAddress(hGDIP, 'GdiplusStartup');
      if Assigned(GdiplusStartup) then
        BEGIN
          FillChar(StartUpInfo, SizeOf(StartUpInfo), 0);
          StartUpInfo.GdiPlusVersion := 1;
          if GdiplusStartup(GdipToken, StartUpInfo, 0) = 0 then
            BEGIN
              GdiplusShutdown             := GetProcAddress(hGDIP, 'GdiplusShutdown');
              GdipGetImageDimension       := GetProcAddress(hGDIP, 'GdipGetImageDimension');
              GdipDisposeImage            := GetProcAddress(hGDIP, 'GdipDisposeImage');
              GdipCreateBitmapFromStream  := GetProcAddress(hGDIP, 'GdipCreateBitmapFromStream');
              GdipCreateHBITMAPFromBitmap := GetProcAddress(hGDIP, 'GdipCreateHBITMAPFromBitmap');
              GdipGetImagePixelFormat     := GetProcAddress(hGDIP, 'GdipGetImagePixelFormat');
              GdipGetImagePaletteSize     := GetProcAddress(hGDIP, 'GdipGetImagePaletteSize');
              GdipGetImagePalette         := GetProcAddress(hGDIP, 'GdipGetImagePalette');
              OK := (@GdiplusShutdown             <> nil) and
                    (@GdipGetImageDimension       <> nil) and
                    (@GdipDisposeImage            <> nil) and
                    (@GdipCreateBitmapFromStream  <> nil) and
                    (@GdipCreateHBITMAPFromBitmap <> nil) and
                    (@GdipGetImagePixelFormat     <> nil) and
                    (@GdipGetImagePaletteSize     <> nil) and
                    (@GdipGetImagePalette         <> nil);
            END;
        END;
      IF not(OK) THEN
        BEGIN
          try
            IF GdipToken <> 0 then
              GdiplusShutdown(GdipToken);
            GdipToken := 0;
          except
            GdipToken := 0;
          end;
          try
            FreeLibrary(hGDIP);
            hGDIP := 0;
          except
            hGDIP := 0;          
          end;
        END;
    end;
END;



PROCEDURE GDIPlus_Stop;
BEGIN
  IF GdipToken <> 0 then
    begin
      GdiplusShutdown(GdipToken);
      GdipToken := 0;
    end;
  IF hGDIP <> 0 then
    begin
      FreeLibrary(hGDIP);
      hGDIP := 0;
    end;
END;



FUNCTION GDIPlusAvailable: boolean;
BEGIn
  Result := hGDIP <> 0;
END;



initialization
  GDIPlus_Start;

finalization
  GDIPlus_Stop;

end.
