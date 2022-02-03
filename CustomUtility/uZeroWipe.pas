unit uZeroWipe;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, SysUtils, Messages, Dialogs, Controls, ShellAPI, StdCtrls,
  Forms, TNTStdCtrls, TNTSysUtils, TNTClasses;

const
  BLOCK_SIZE = 1024*1024*10;

var
  Operation: Boolean = False;
  TNTStringList: TTNTStrings;

procedure ProceedZeroWipe(var Msg: TMessage);
procedure WipeFile(FileName: WideString);
procedure WipeDirectory(FileName: WideString);

implementation

uses CustomUtility;

//ZeroWipe
procedure WipeFile(FileName: WideString);
var
  srSearch: TWIN32FindDataW;
  SizeOfFile, SizeOfWritten: Int64;
  Handle, BytesWritten: THandle;
  ZeroBlock: array of byte;
  Percent, NewName: WideString;
  Index: Integer;
begin
  Index := Form1.TNTListBox1.Items.Count;
  SetFileAttributesW(PWideChar(FileName), faArchive);
  Handle := FindFirstFileW(PWideChar(FileName), srSearch);
  SizeOfFile := (srSearch.nFileSizeHigh * 4294967296) + srSearch.nFileSizeLow;
  Windows.FindClose(Handle);

  if SizeOfFile < 0 then begin
    Form1.TNTListBox1.Items.Strings[Index] := 'Too Big: ' + FileName;
    Form1.TNTListBox1.Selected[Index] := True;
    Exit;
  end;

  if SizeOfFile < BLOCK_SIZE then begin
    SetLength(ZeroBlock, SizeOfFile)
  end else begin
    SetLength(ZeroBlock, BLOCK_SIZE);
  end;

  Handle := CreateFileW(PWideChar(FileName), GENERIC_WRITE, FILE_SHARE_WRITE + FILE_SHARE_READ, nil, OPEN_EXISTING, 0,0);
  Percent := '[0%] -> ';
  SizeOfWritten := 0;

  Form1.TNTListBox1.Items.Strings[Index] := Percent + FileName;
  Form1.TNTListBox1.Selected[Index] := True;

  while SizeOfWritten < SizeOfFile do begin
    if SizeOfWritten <> 0 then Percent := '[' + IntToStr(Round(100 * (SizeOfWritten / SizeOfFile))) + '%] -> ';
    Form1.TNTListBox1.Items.Strings[Index] := Percent + FileName;
    WriteFile(Handle, ZeroBlock[0], Length(ZeroBlock), BytesWritten, nil);

    if (BytesWritten = 0) and (SizeOfFile <> 0) then begin
      Form1.TNTListBox1.Items.Strings[Index] := 'Access Denied: ' + FileName;
      Form1.TNTListBox1.Selected[Index] := True;
      Exit;
    end;

    SizeOfWritten := SizeOfWritten + BytesWritten;
    Application.ProcessMessages;
  end;

  Form1.TNTListBox1.Items.Strings[Index] := '[100%] -> ' + FileName;
  Form1.TNTListBox1.Selected[Index] := True;

  SetFilePointer(Handle, 0, nil, FILE_BEGIN);
  SetEndOfFile(Handle);
  CloseHandle(Handle);

  NewName := WideExtractFilePath(FileName) + WideString(Char($A0));
  MoveFileW(PWideChar(FileName), PWideChar(NewName));
  DeleteFileW(PWideChar(NewName));
  Form1.TNTListBox1.Items.Strings[Index] := 'Wiped: ' + FileName;
  Form1.TNTListBox1.Selected[Index] := True;
end;
//ZeroWipe


//RecursivelyWipe
procedure WipeDirectory(FileName: WideString);
var
  srSearch: TWIN32FindDataW;
  Handle: THandle;
  NewName: WideString;
begin
  Handle := FindFirstFileW(PWideChar(FileName + '\*.*'), srSearch);
  if Handle <> INVALID_HANDLE_VALUE then begin
    repeat
      try
        if ((srSearch.dwFileAttributes and faDirectory) = 0) then begin
          WipeFile(FileName + '\' + srSearch.cFileName);
        end;

        if ((srSearch.dwFileAttributes and faDirectory) = faDirectory) and (WideString(srSearch.cFileName) <> '.') and (WideString(srSearch.cFileName) <> '..') then begin
          WipeDirectory(FileName + '\' + srSearch.cFileName);
        end;
      except
        continue;
      end;
    until not FindNextFileW(Handle, srSearch);
    Windows.FindClose(Handle);

    SetFileAttributesW(PWideChar(FileName), faArchive);
    NewName := WideExtractFilePath(FileName) + WideString(Char($A0));
    MoveFileW(PWideChar(FileName), PWideChar(NewName));

    if not RemoveDirectoryW(PWideChar(NewName)) then begin
      Form1.TNTListBox1.Items.Strings[Form1.TNTListBox1.Items.Count] := 'Cannot wipe, [' + SysErrorMessage(GetLastError) + ']: ' + FileName;
      Form1.TNTListBox1.Selected[Form1.TNTListBox1.Items.Count-1] := True;
      MoveFileW(PWideChar(NewName), PWideChar(FileName));
      Exit;
    end;

    Form1.TNTListBox1.Items.Strings[Form1.TNTListBox1.Items.Count] := 'Wiped: ' + FileName;
    Form1.TNTListBox1.Selected[Form1.TNTListBox1.Items.Count-1] := True;
  end;
end;
//RecursivelyWipe


//ProceedList
procedure ProceedZeroWipe(var Msg: TMessage);
var
  hDrop: THandle;
  i, FileCount, Len: Integer;
  buttonSelected: Integer;
  FileName: WideString;
begin
  buttonSelected := MessageDlg('Do you want to wipe these file(s)/folder(s)?', mtConfirmation, [mbYes, mbNo], 0);
  if buttonSelected <> mrYes then Exit;

  Form1.StaticText1.Hide;
  Form1.TNTListBox1.Enabled := True;

  hDrop := Msg.wParam;
  if not Assigned(TNTStringList) then TNTStringList := TTNTStringList.Create;
  FileCount := DragQueryFileW(hDrop, $FFFFFFFF, nil, 0);

  for i := 0 to FileCount-1 do begin
    Len := DragQueryFileW(hDrop, i, nil, 0)+1;
    SetLength(FileName, Len);
    DragQueryFileW(hDrop, i, Pointer(FileName), Len);
    TNTStringList.Add(Trim(FileName));
  end;

  DragFinish(hDrop);
  if Operation then Exit;

  Operation := True;

  while TNTStringList.Count <> 0 do begin
    FileName := TNTStringList.Strings[0];
    TNTStringList.Delete(0);
    if WideFileExists(FileName) then WipeFile(FileName);
    if WideDirectoryExists(FileName) then WipeDirectory(FileName);
  end;

  Operation := False;
end;
//ProceedList

end.

