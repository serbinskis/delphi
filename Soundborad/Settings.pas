unit Settings;

interface

uses
  Windows, Classes, Controls, Forms, StdCtrls, ExtCtrls, ComCtrls, TFlatComboBoxUnit,
  TFlatCheckBoxUnit, uHotKey;

type
  TForm2 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    ComboBox1: TFlatComboBox;
    ComboBox2: TFlatComboBox;
    ComboBox3: TFlatComboBox;
    CheckBox1: TFlatCheckBox;
    CheckBox2: TFlatCheckBox;
    CheckBox3: TFlatCheckBox;
    HotKey1: THotKey;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormClick(Sender: TObject);
    procedure CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CheckBox2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CheckBox3MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ComboBoxChange(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure HotKey1Exit(Sender: TObject);
    procedure HotKey1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses Soundboard;

{$R *.dfm}

procedure TForm2.FormCreate(Sender: TObject);
begin
  CheckBox3.Hint := 'Every file will be saved in memory and will not containt file.' + #13#10 +
                    '(Warning) This is experimental function. It can cause perfomance and crash issues.';

  SetWindowRgn(HotKey1.Handle, CreateRectRgn(2, 2, HotKey1.Width-2, HotKey1.Height-2), True);
end;


procedure TForm2.FormShow(Sender: TObject);
var
  i: Integer;
begin
  if SettingsDB.StayOnTop
    then SetWindowPos(Handle, HWND_TOPMOST, 0,0,0,0, SWP_NOMOVE or SWP_NOSIZE)
    else SetWindowPos(Handle, HWND_NOTOPMOST, 0,0,0,0, SWP_NOMOVE or SWP_NOSIZE);

  Form2.Top := Round((Form1.Height - Form2.Height)/2) + Form1.Top;
  Form2.Left := Round((Form1.Width - Form2.Width)/2) + Form1.Left;

  for i := 0 to Length(HotKeys)-1 do begin
    ChangeShortcut(HotKeys[i].Key, 0);
  end;

  ComboBox3Change(nil);
end;


procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
begin
  Form1.Image4.Hint := 'First Device: ' + ComboBox1.Items[ComboBox1.ItemIndex];
  Form1.Image5.Hint := 'Second Device: ' + ComboBox2.Items[ComboBox2.ItemIndex];
  HotKey1Exit(nil);

  for i := 0 to Length(HotKeys)-1 do begin
    ChangeShortcut(HotKeys[i].Key, HotKeys[i].ShortCut);
  end;
end;


procedure TForm2.FormClick(Sender: TObject);
begin
  StaticText1.SetFocus;
end;


procedure TForm2.CheckBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SettingsDB.AlwaysNumLock := CheckBox1.Checked;
  Form1.Timer2.Enabled := SettingsDB.AlwaysNumLock;
  if SettingsDB.AlwaysNumLock then Exit;

  if GetKeyState(VK_NUMLOCK) = 1 then begin
    keybd_event(VK_NUMLOCK, 0, 0, 0);
    keybd_event(VK_NUMLOCK, 0, 2, 0);
  end;
end;


procedure TForm2.CheckBox2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SettingsDB.StayOnTop := CheckBox2.Checked;

  if SettingsDB.StayOnTop
    then SetWindowPos(Handle, HWND_TOPMOST, 0,0,0,0, SWP_NOMOVE or SWP_NOSIZE)
    else SetWindowPos(Handle, HWND_NOTOPMOST, 0,0,0,0, SWP_NOMOVE or SWP_NOSIZE);

  SetForegroundWindow(Handle);
end;


procedure TForm2.CheckBox3MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SettingsDB.SaveInMemory := CheckBox3.Checked;
end;


procedure TForm2.ComboBoxChange(Sender: TObject);
begin
  StaticText1.SetFocus;
end;


procedure TForm2.HotKey1Change(Sender: TObject);
const
  hkExclusions = [144, 111, 45, 40, 39, 38, 37, 36, 35, 34, 33];
begin
  if ShortCutToKey(HotKey1.HotKey) in hkExclusions then HotKey1.Modifiers := HotKey1.Modifiers + [hkExt];
end;


procedure TForm2.HotKey1Exit(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to Length(HotKeys)-1 do begin
    if HotKeys[i].Description = ComboBox3.Text then begin
      HotKeys[i].ShortCut := HotKey1.HotKey;
      Break;
    end;
  end;
end;


procedure TForm2.ComboBox3Change(Sender: TObject);
var
  i: Integer;
begin
  StaticText1.SetFocus;

  for i := 0 to Length(HotKeys)-1 do begin
    if HotKeys[i].Description = ComboBox3.Text then begin
      HotKey1.HotKey := HotKeys[i].ShortCut;
      HotKey1Change(nil);
      Break;
    end;
  end;
end;

end.
