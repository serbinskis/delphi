unit uReplaceText;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, SysUtils, Messages, Dialogs, Controls, ShellAPI, StdCtrls,
  Forms, TNTStdCtrls, TNTSysUtils, TNTClasses;

var
  Operation: Boolean = False;
  TNTStringList: TTNTStrings;

procedure ProceedReplaceText(var Msg: TMessage);

implementation

uses CustomUtility;


procedure ReplaceText(FileName, ToReplace, RepalceWith: WideString);
var
  Position: Integer;
  FilePath: WideString;
  OldFileName: WideString;
  NewFileName: WideString;
begin
  OldFileName := FileName; //Filename and path
  FilePath := WideExtractFilePath(FileName); //Only file path
  FileName := WideExtractFileName(FileName); //Only file name
  Position := Pos(WideLowerCase(ToReplace), WideLowerCase(FileName));

  if (Position > 0) then begin
    NewFileName := FilePath + TNT_WideStringReplace(FileName, ToReplace, RepalceWith, [rfReplaceAll, rfIgnoreCase]);

    try
      MoveFileW(PWideChar(OldFileName), PWideChar(NewFileName));
      Form1.TNTListBox4.Items.Strings[Form1.TNTListBox4.Items.Count] := 'Renamed: ' + FileName + ' -> ' + WideExtractFileName(NewFileName);
    except
      Form1.TNTListBox4.Items.Strings[Form1.TNTListBox4.Items.Count] := 'Cannot rename: ' + OldFileName;
    end;

    Form1.TNTListBox4.Selected[Form1.TNTListBox4.Items.Count-1] := True;
  end;
end;


//ProceedList
procedure ProceedReplaceText(var Msg: TMessage);
var
  hDrop: THandle;
  i, FileCount, Len: Integer;
  buttonSelected: Integer;
  FileName: WideString;
begin
  if Form1.TNTEdit1.Text = '' then Exit;
  buttonSelected := MessageDlg('Do you want to rename these file(s)/folder(s)?', mtConfirmation, [mbYes, mbNo], 0);
  if buttonSelected <> mrYes then Exit;

  Form1.StaticText4.Hide;
  Form1.TNTListBox4.Enabled := True;

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

  Form1.TNTEdit1.Enabled := False;
  Form1.TNTEdit2.Enabled := False;
  Operation := True;

  while TNTStringList.Count <> 0 do begin
    FileName := TNTStringList.Strings[0];
    TNTStringList.Delete(0);
    ReplaceText(FileName, Form1.TNTEdit1.Text, Form1.TNTEdit2.Text);
    Application.ProcessMessages; //Make this so the app doesn't frezze;
  end;

  Operation := False;
  Form1.TNTEdit1.Enabled := True;
  Form1.TNTEdit2.Enabled := True;
end;
//ProceedList

end.

