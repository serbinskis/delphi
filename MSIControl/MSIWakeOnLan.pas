unit MSIWakeOnLan;

interface

uses
  Windows, SysUtils, Classes, Controls, Menus, Forms, MMSystem, DateUtils, ExtCtrls, StdCtrls, TntStdCtrls, XiButton,
  TFlatComboBoxUnit, CustoBevel, MSIControl, MSIThemes, uDynamicData, Functions;

type
  TForm6 = class(TForm)
    Bevel1: TCustoBevel;
    Bevel2: TCustoBevel;
    Bevel3: TCustoBevel;
    Bevel4: TCustoBevel;
    Bevel5: TCustoBevel;
    Bevel6: TCustoBevel;
    Button1: TXiButton;
    Button2: TXiButton;
    Button3: TXiButton;
    Button4: TXiButton;
    ComboBox1: TFlatComboBox;
    Edit1: TTntEdit;
    Edit2: TTntEdit;
    Edit3: TTntEdit;
    Edit4: TTntEdit;
    Edit5: TTntEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBoxKey(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Edit1Exit(Sender: TObject);
    procedure Edit2Exit(Sender: TObject);
    procedure Edit3Exit(Sender: TObject);
    procedure Edit4Exit(Sender: TObject);
    procedure Edit5Change(Sender: TObject);
    procedure Edit5Exit(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TEventHandler = class
    procedure WakeOnLanClick(Sender: TObject);
  end;

const
  WOL_DEFAULT = 'New Device';
  WOL_DEFAULT_PORT = 5;
  DEFAULT_WOL_KEY = DEFAULT_KEY + '\WakeOnLan';

var
  Form6: TForm6;
  WoLDynData: TDynamicData;
  WoLMenu: TMenuItem;
  EventHandler: TEventHandler;

implementation

{$R *.dfm}

procedure CreateMenuItem(i: Integer);
var
  MenuItem: TMenuItem;
  SubItem: TMenuItem;
begin
  MenuItem := TMenuItem.Create(WoLMenu);
  MenuItem.Caption := WoLDynData.GetValue(i, 'Name');
  Form6.ComboBox1.Items.AddObject(MenuItem.Caption, MenuItem);
  WoLMenu.Add(MenuItem);

  SubItem := TMenuItem.Create(MenuItem);
  SubItem.Caption := 'Start';
  SubItem.Hint := WoLDynData.GetValue(i, 'UID');
  SubItem.OnClick := EventHandler.WakeOnLanClick;
  MenuItem.Add(SubItem);

  SubItem := TMenuItem.Create(MenuItem);
  SubItem.Caption := 'Stop';
  SubItem.Hint := WoLDynData.GetValue(i, 'UID');
  SubItem.OnClick := EventHandler.WakeOnLanClick;
  MenuItem.Add(SubItem);

  SubItem := TMenuItem.Create(MenuItem);
  SubItem.Caption := 'Options';
  SubItem.Hint := WoLDynData.GetValue(i, 'UID');
  SubItem.OnClick := EventHandler.WakeOnLanClick;
  MenuItem.Add(SubItem);
end;


procedure TEventHandler.WakeOnLanClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  i: Integer;
begin
  MenuItem := TMenuItem(Sender);
  i := WoLDynData.FindIndex(0, 'UID', MenuItem.Hint);
  if (i < 0) then Exit;
  Form6.ComboBox1.ItemIndex := i;
  Form6.ComboBox1Change(nil);

  if (MenuItem.Caption = 'Start') then Form6.Button3Click(nil);
  if (MenuItem.Caption = 'Stop') then Form6.Button4Click(nil);

  if (MenuItem.Caption = 'Options') then begin
    if not Form1.Visible then Form1.Show;
    if not Form6.Visible then Form1.Button6Click(nil);
  end;
end;


procedure TForm6.FormClick(Sender: TObject);
begin
  MSIControl.RemoveFocus(Form6);
end;


procedure TForm6.FormShow(Sender: TObject);
begin
  MSIControl.RemoveFocus(Form6);
end;


procedure TForm6.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  WoLDynData := TDynamicData.Create(['UID', 'Name', 'IP', 'IPv4', 'Mac', 'Port']);
  WoLDynData.Load(DEFAULT_ROOT_KEY, DEFAULT_WOL_KEY, 'BINARY_WAKEONLAN', [loRemoveUnused, loOFDelete]);

  WoLMenu := TMenuItem.Create(nil);
  WoLMenu.Caption := 'Wake On Lan';
  Form1.PopupMenu1.Items.Insert(0, WoLMenu);

  for i := 0 to (WoLDynData.GetLength-1) do CreateMenuItem(i);

  ComboBox1.ItemIndex := 0;
  ComboBox1.Enabled := (ComboBox1.Items.Count > 0);
  ComboBox1Change(nil);

  for i := 0 to Form6.ComponentCount-1 do begin
    if (Form6.Components[i].ClassName = 'TTntEdit') then TEdit(Form6.Components[i]).Enabled := ComboBox1.Enabled;
  end;

  Button3.Enabled := (ComboBox1.Items.Count > 0);
  Button4.Enabled := (ComboBox1.Items.Count > 0);
  ChangeTheme(Theme, Form6);
end;


procedure TForm6.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  WoLDynData.Save(DEFAULT_ROOT_KEY, DEFAULT_WOL_KEY, 'BINARY_WAKEONLAN', []);
end;


procedure TForm6.Button1Click(Sender: TObject);
var
  i: Integer;
  UID: String;
begin
  UID := IntToStr(MilliSecondsBetween(Now, 0));
  i := WoLDynData.CreateData(-1, -1, ['UID', 'Name', 'IP', 'IPv4', 'Mac', 'Port'], [UID, WOL_DEFAULT, '', '', '', WOL_DEFAULT_PORT]);

  CreateMenuItem(i);
  Button3.Enabled := True;
  Button4.Enabled := True;
  ComboBox1.Enabled := True;
  ComboBox1.ItemIndex := ComboBox1.Items.Count-1;
  ComboBox1Change(nil);

  for i := 0 to Form6.ComponentCount-1 do begin
    if (Form6.Components[i].ClassName = 'TTntEdit') then TEdit(Form6.Components[i]).Enabled := True;
  end;
end;


procedure TForm6.Button2Click(Sender: TObject);
var
  MenuItem: TMenuItem;
  i: Integer;
begin
  if (ComboBox1.ItemIndex < 0) then Exit;
  WoLDynData.DeleteData(ComboBox1.ItemIndex);

  MenuItem := TMenuItem(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
  WoLMenu.Remove(MenuItem);

  ComboBox1.Items.Delete(ComboBox1.ItemIndex);
  ComboBox1.Enabled := (ComboBox1.Items.Count > 0);
  Button3.Enabled := (ComboBox1.Items.Count > 0);
  Button4.Enabled := (ComboBox1.Items.Count > 0);

  for i := 0 to Form6.ComponentCount-1 do begin
    if (Form6.Components[i].ClassName = 'TTntEdit') then TEdit(Form6.Components[i]).Text := '';
    if (Form6.Components[i].ClassName = 'TTntEdit') then TEdit(Form6.Components[i]).Enabled := ComboBox1.Enabled;
  end;

  ComboBox1.ItemIndex := 0;
  ComboBox1Change(nil);
end;


procedure TForm6.ComboBox1Change(Sender: TObject);
begin
  if (ComboBox1.ItemIndex < 0) then Exit;
  MSIControl.RemoveFocus(Form6);

  Edit1.Text := WoLDynData.GetValue(ComboBox1.ItemIndex, 'Name');
  Edit2.Text := WoLDynData.GetValue(ComboBox1.ItemIndex, 'IP');
  Edit3.Text := WoLDynData.GetValue(ComboBox1.ItemIndex, 'IPv4');
  Edit4.Text := WoLDynData.GetValue(ComboBox1.ItemIndex, 'Mac');
  Edit5.Text := WoLDynData.GetValue(ComboBox1.ItemIndex, 'Port');
end;


procedure TForm6.ComboBoxKey(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Key := 0;
end;

procedure TForm6.Edit5Change(Sender: TObject);
begin
  CheckValue(Edit5, 1, 999999);
end;


procedure TForm6.EditEnter(Sender: TObject);
begin
  TEdit(Sender).PasswordChar := #0;
end;


procedure TForm6.EditKeyPress(Sender: TObject; var Key: Char);
begin
  if (Ord(Key) > 128) then Key := #0;
  if (Ord(Key) = 13) then MSIControl.RemoveFocus(Form6);
  if (Ord(Key) = 13) then Key := #0;
end;


procedure TForm6.Edit1Exit(Sender: TObject);
var
  i: Integer;
begin
  Edit1.Text := Trim(Edit1.Text);
  if (Edit1.Text = '') then Edit1.Text := WOL_DEFAULT;
  TMenuItem(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).Caption := Edit1.Text;
  WoLDynData.SetValue(ComboBox1.ItemIndex, 'Name', Edit1.Text);

  i := ComboBox1.ItemIndex;
  ComboBox1.Items[ComboBox1.ItemIndex] := Edit1.Text;
  ComboBox1.ItemIndex := i;
end;


procedure TForm6.Edit2Exit(Sender: TObject);
begin
  TEdit(Sender).PasswordChar := #42;
  TEdit(Sender).Text := Trim(TEdit(Sender).Text);
  WoLDynData.SetValue(ComboBox1.ItemIndex, 'IP', TEdit(Sender).Text);
end;


procedure TForm6.Edit3Exit(Sender: TObject);
begin
  TEdit(Sender).PasswordChar := #42;
  TEdit(Sender).Text := Trim(TEdit(Sender).Text);
  WoLDynData.SetValue(ComboBox1.ItemIndex, 'IPv4', TEdit(Sender).Text);
end;


procedure TForm6.Edit4Exit(Sender: TObject);
begin
  TEdit(Sender).PasswordChar := #42;
  TEdit(Sender).Text := Trim(TEdit(Sender).Text);
  if Length(TEdit(Sender).Text) < 17 then TEdit(Sender).Text := '';
  WoLDynData.SetValue(ComboBox1.ItemIndex, 'Mac', TEdit(Sender).Text);
end;


procedure TForm6.Edit5Exit(Sender: TObject);
begin
  TEdit(Sender).PasswordChar := #42;
  TEdit(Sender).Text := Trim(TEdit(Sender).Text);
  if (TEdit(Sender).Text = '') then TEdit(Sender).Text := IntToStr(WOL_DEFAULT_PORT);
  WoLDynData.SetValue(ComboBox1.ItemIndex, 'Port', TEdit(Sender).Text);
end;


procedure TForm6.Button3Click(Sender: TObject);
var
  IP, Mac: String;
  Port: Integer;
  isValid: Boolean;
begin
  if (ComboBox1.ItemIndex < 0) then Exit;

  IP := WoLDynData.GetValue(ComboBox1.ItemIndex, 'IP');
  Mac := WoLDynData.GetValue(ComboBox1.ItemIndex, 'Mac');
  Port := WoLDynData.GetValue(ComboBox1.ItemIndex, 'Port');
  isValid := (IP <> '') and (Mac <> '') and (Port > 0);

  if not isValid then begin
    PlaySound('SystemExclamation', 0, SND_ASYNC);
    if not Form1.Visible then Form1.Show;
    if not Form6.Visible then Form1.Button6Click(nil);
    Exit;
  end;

  WakeOnLan(IP, Mac, Port);
end;


procedure TForm6.Button4Click(Sender: TObject);
var
  IPv4: String;
begin
  if (ComboBox1.ItemIndex < 0) then Exit;
  IPv4 := WoLDynData.GetValue(ComboBox1.ItemIndex, 'IPv4');

  if (IPv4 = '') then begin
    PlaySound('SystemExclamation', 0, SND_ASYNC);
    if not Form1.Visible then Form1.Show;
    if not Form6.Visible then Form1.Button6Click(nil);
    Exit;
  end;

  if not PingReachable(IPv4) then Exit;
  WinExec(PChar('shutdown.exe -m ' + IPv4 + ' -s -t 0'), SW_HIDE);
end;

end.
