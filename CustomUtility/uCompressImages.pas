unit uCompressImages;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, SysUtils, Messages, Dialogs, Controls, ShellAPI, StdCtrls,
  Forms, TNTStdCtrls, TNTSysUtils, TNTClasses, Graphics, jpeg,
  PNGImage, TFlatEditUnit, TFlatSpinEditUnit;

var
  Operation: Boolean = False;
  TNTStringList: TTNTStrings;

procedure ProceedImageCompress(var Msg: TMessage);
procedure CheckFolder(FileName: WideString);
procedure CheckImage(FileName: WideString);

implementation

uses CustomUtility;


//CompressImage
procedure CompressImage(FileName: WideString; Percent: Integer);
var
  PNGObject: TPNGObject;
  Bitmap: TBitmap;
  JPEGImage: TJpegImage;
  MemoryStream: TTNTMemoryStream;
  beforeSize, afterSize: Integer;
begin
  //If PNG convert and compress
  if ExtractFileExt(FileName) = '.png' then begin;
    try
      SetFileAttributesW(PWideChar(FileName), 0);
      MemoryStream := TTNTMemoryStream.Create;
      MemoryStream.LoadFromFile(FileName);

      PNGObject := TPNGObject.Create;
      PNGObject.LoadFromStream(MemoryStream);

      Bitmap := TBitmap.Create;
      Bitmap.Width := PNGObject.Width;
      Bitmap.Height := PNGObject.Height;
      PNGObject.Draw(Bitmap.Canvas, Bitmap.Canvas.ClipRect);

      JPEGImage := TJpegImage.Create;
      JPEGImage.Assign(Bitmap);
      JPEGImage.CompressionQuality := Percent;
      JPEGImage.DIBNeeded;
      JPEGImage.Compress;

      MemoryStream.Clear;
      JPEGImage.SaveToStream(MemoryStream);
      MemoryStream.SaveToFile(WideChangeFileExt(FileName, '.jpg'));
      DeleteFileW(PWideChar(FileName));
      Form1.TNTListBox3.Items.Strings[Form1.TNTListBox3.Items.Count] := 'Compressed: ' + FileName + ' -> .jpg' + #13#10;

      PNGObject.Free;
      Bitmap.Free;
      JpegImage.Free;
      MemoryStream.Free;
    except
      Form1.TNTListBox3.Items.Strings[Form1.TNTListBox3.Items.Count] := 'Error compressing: ' + FileName + ' -> .jpg' + #13#10;
    end;

    Exit;
  end;

  //If JPG compress
  try
    MemoryStream := TTNTMemoryStream.Create;
    MemoryStream.LoadFromFile(FileName);
    beforeSize := MemoryStream.Size;

    JPEGImage := TJpegImage.Create;
    JPEGImage.LoadFromStream(MemoryStream);
    JPEGImage.CompressionQuality := Percent;
    JPEGImage.DIBNeeded;
    JPEGImage.Compress;

    MemoryStream.Clear;
    JPEGImage.SaveToStream(MemoryStream);
    afterSize := MemoryStream.Size;

    if afterSize < beforeSize then begin
      MemoryStream.SaveToFile(FileName);
      Form1.TNTListBox3.Items.Strings[Form1.TNTListBox3.Items.Count] :=  'Compressed: ' + FileName + #13#10;
    end else begin
      Form1.TNTListBox3.Items.Strings[Form1.TNTListBox3.Items.Count] :=  'Compression is bigger: ' + FileName + #13#10;
    end;

    JPEGImage.Free;
    MemoryStream.Free;
  except
    Form1.TNTListBox3.Items.Strings[Form1.TNTListBox3.Items.Count] := 'Error compressing: ' + FileName + #13#10;
  end;
end;
//CompressImage


//CheckFolder
procedure CheckFolder(FileName: WideString);
var
  srSearch: TWIN32FindDataW;
  Handle: THandle;
begin
  Handle := FindFirstFileW(PWideChar(FileName + '\*.*'), srSearch);
  if Handle <> INVALID_HANDLE_VALUE then begin
    repeat
      try
        if ((srSearch.dwFileAttributes and faDirectory) = 0) then begin
          CheckImage(FileName + '\' + srSearch.cFileName);
        end;
      except
        continue;
      end;
    until not FindNextFileW(Handle, srSearch);
    Windows.FindClose(Handle);
  end;
end;
//CheckFolder


//CheckImage
procedure CheckImage(FileName: WideString);
var
  Exstension: String;
begin
  if WideDirectoryExists(FileName) then begin
    CheckFolder(FileName);
  end else begin
    Exstension := ExtractFileExt(FileName);
    if (Exstension = '.png') or (Exstension = '.jpg') or (Exstension = '.jpeg') then TNTStringList.Add(FileName);
  end;
end;
//CheckImage


//ProceedList
procedure ProceedImageCompress(var Msg: TMessage);
var
  hDrop: THandle;
  i, FileCount, Len: Integer;
  buttonSelected: Integer;
  FileName: WideString;
begin
  buttonSelected := MessageDlg('Do you want to compress these image(s)?', mtConfirmation, [mbYes, mbNo], 0);
  if buttonSelected <> mrYes then Exit;

  hDrop := Msg.wParam;
  if not Assigned(TNTStringList) then TNTStringList := TTNTStringList.Create;
  FileCount := DragQueryFileW(hDrop, $FFFFFFFF, nil, 0);

  for i := 0 to FileCount-1 do begin
    Len := DragQueryFileW(hDrop, i, nil, 0)+1;
    SetLength(FileName, Len);
    DragQueryFileW(hDrop, i, Pointer(FileName), Len);
    CheckImage(Trim(FileName));
  end;

  if TNTStringList.Count > 0 then begin
    Form1.StaticText3.Hide;
    Form1.TNTListBox3.Enabled := True;
  end;

  DragFinish(hDrop);
  if Operation then Exit;

  Operation := True;
  Form1.FlatSpinEdit1.Enabled := False;
  Form1.FlatSpinEdit1.Update;

  while TNTStringList.Count <> 0 do begin
    FileName := TNTStringList.Strings[0];
    TNTStringList.Delete(0);
    CompressImage(FileName, Form1.FlatSpinEdit1.Value);
    Form1.TNTListBox3.Selected[Form1.TNTListBox3.Items.Count-1] := True;
    Application.ProcessMessages; //Make this so the app doesn't frezze;
  end;

  Operation := False;
  Form1.FlatSpinEdit1.Enabled := True;
end;
//ProceedList

end.

