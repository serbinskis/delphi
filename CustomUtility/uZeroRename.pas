unit uZeroRename;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, SysUtils, Messages, Dialogs, Controls, ShellAPI, StdCtrls,
  Forms, TNTStdCtrls, TNTSysUtils, TNTClasses;

var
  Operation: Boolean = False;

procedure ProceedZeroRename(var Msg: TMessage);

implementation

uses CustomUtility;


//ProceedList
procedure ProceedZeroRename(var Msg: TMessage);
var
  hDrop: THandle;
  i, j, FileCount, Len: Integer;
  buttonSelected, NameLenght: Integer;
  FileName, NewName, Temporary: WideString;
  TNTStringList: TTNTStrings;
begin
  if Operation then Exit;
  buttonSelected := MessageDlg('Do you want to zero rename these file(s)/folder(s)?', mtConfirmation, [mbYes, mbNo], 0);
  if buttonSelected <> mrYes then Exit;
  TNTStringList := TTNTStringList.Create;

  Form1.StaticText5.Hide;
  Form1.TNTListBox5.Enabled := True;
  Operation := True;

  hDrop := Msg.wParam;
  FileCount := DragQueryFileW(hDrop, $FFFFFFFF, nil, 0);
  NameLenght := Length(IntToStr(FileCount));
  if NameLenght < 2 then NameLenght := 2;

  for i := 0 to FileCount-1 do begin
    Len := DragQueryFileW(hDrop, i, nil, 0)+1;
    SetLength(FileName, Len);
    DragQueryFileW(hDrop, i, Pointer(FileName), Len);
    FileName := Trim(FileName);

    NewName := IntToStr(i+1);
    for j := Length(NewName) to NameLenght-1 do NewName := '0' + NewName;
    NewName := WideExtractFilePath(FileName) + NewName + WideExtractFileExt(FileName);

    if not MoveFileW(PWideChar(FileName), PWideChar(NewName)) then begin
      Temporary := SysErrorMessage(GetLastError);
      Form1.TNTListBox5.Items.Strings[Form1.TNTListBox5.Items.Count] := WideExtractFileName(FileName) + ': ' + Temporary;
    end else begin
      Form1.TNTListBox5.Items.Strings[Form1.TNTListBox5.Items.Count] := WideExtractFileName(FileName) + ' -> ' + WideExtractFileName(NewName);
    end;

    Form1.TNTListBox5.Selected[Form1.TNTListBox5.Items.Count-1] := True;
  end;

  for i := 0 to TNTStringList.Count-1 do begin
    FileName := TNTStringList.Strings[i];

    NewName := IntToStr(i+1);
    for j := Length(NewName) to NameLenght-1 do NewName := '0' + NewName;
    NewName := WideExtractFilePath(FileName) + NewName + WideExtractFileExt(FileName);
    MoveFileW(PWideChar(FileName), PWideChar(NewName));
    ShowMessage(SysErrorMessage(GetLastError));

    ShowMessage(NewName);
    ShowMessage('1: ' + WideExtractFileName(FileName) + ' -> ' + WideExtractFileName(NewName));
    Form1.TNTListBox5.Items.Strings[Form1.TNTListBox5.Items.Count] := WideExtractFileName(FileName) + ' -> ' + WideExtractFileName(NewName);
    Form1.TNTListBox5.Selected[Form1.TNTListBox5.Items.Count-1] := True;
  end;

  Operation := False;
  DragFinish(hDrop);
end;
//ProceedList

end.

