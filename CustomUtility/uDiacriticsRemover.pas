unit uDiacriticsRemover;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, SysUtils, Messages, Dialogs, Controls, ShellAPI, StdCtrls,
  Forms, TNTStdCtrls, TNTSysUtils, TNTClasses;

const
  UNTRANSFORMABLE_CHARACTER: array  [0..1] of string = ('?', '_');

var
  Operation: Boolean = False;
  TNTStringList: TTNTStrings;

procedure ProceedRemoveDiacritics(var Msg: TMessage);

implementation

uses CustomUtility;

//RemoveDiacritics
function RemoveDiacritics(const Input: WideString): String;
const
  CodePage = 20127;
begin
  SetLength(Result, WideCharToMultiByte(CodePage, 0, PWideChar(Input), Length(Input), nil, 0, nil, nil));
  WideCharToMultiByte(CodePage, 0, PWideChar(Input), Length(Input), PAnsiChar(Result), Length(Result), nil, nil);
  Result := StringReplace(Result, UNTRANSFORMABLE_CHARACTER[0], UNTRANSFORMABLE_CHARACTER[1], [rfReplaceAll, rfIgnoreCase]);
end;
//RemoveDiacritics


//ProceedList
procedure ProceedRemoveDiacritics(var Msg: TMessage);
var
  hDrop: THandle;
  i, FileCount, Len: Integer;
  buttonSelected: Integer;
  FileName: WideString;
  NewName: WideString;
begin
  buttonSelected := MessageDlg('Do you want to remove diacritics from these file(s)/folder(s)?', mtConfirmation, [mbYes, mbNo], 0);
  if buttonSelected <> mrYes then Exit;

  Form1.StaticText2.Hide;
  Form1.TNTListBox2.Enabled := True;

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
    NewName := WideExtractFilePath(FileName) + RemoveDiacritics(WideExtractFileName(FileName));

    if not MoveFileW(PWideChar(FileName), PWideChar(NewName)) then begin
      Form1.TNTListBox2.Items.Strings[Form1.TNTListBox2.Items.Count] := 'Cannot rename, [' + SysErrorMessage(GetLastError) + ']: ' + WideExtractFileName(FileName);
    end else begin
      Form1.TNTListBox2.Items.Strings[Form1.TNTListBox2.Items.Count] := WideExtractFileName(FileName) + ' -> ' + WideExtractFileName(NewName);
    end;

    Form1.TNTListBox2.Selected[Form1.TNTListBox2.Items.Count-1] := True;
    Application.ProcessMessages; //Make this so the app doesn't frezze;
  end;

  Operation := False;
end;
//ProceedList

end.

