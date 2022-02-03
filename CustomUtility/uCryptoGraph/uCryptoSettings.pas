unit uCryptoSettings;

interface

uses
  Windows, Messages, ShellAPI, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StdCtrls, WinXP, Menus, TFlatComboBoxUnit, Functions;

type
  TCryptoSettings = class(TForm)
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    ComboBox2: TFlatComboBox;
    ComboBox1: TFlatComboBox;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CryptoSettings: TCryptoSettings;

implementation

uses uCryptoGraph;

{$R *.dfm}


procedure TCryptoSettings.FormShow(Sender: TObject);
var
  i, ActiveMonitor: Integer;
  MonitorWidth, MonitorHeigth: Integer;
begin
  ShowWindow(Application.Handle, SW_HIDE);
  StaticText1.SetFocus;

  ComboBox1.Text := SettingsDB.Coin;
  ComboBox2.Text := SettingsDB.Currency;

  for i := 0 to ComboBox1.Items.Count-1 do begin
    if ComboBox1.Items[i] = SettingsDB.Coin then begin
      ComboBox1.ItemIndex := i;
      Break;
    end;
  end;

  for i := 0 to ComboBox2.Items.Count-1 do begin
    if ComboBox2.Items[i] = SettingsDB.Currency then begin
      ComboBox2.ItemIndex := i;
      Break;
    end;
  end;

  ActiveMonitor := GetActiveMonitor;
  MonitorWidth := Screen.Monitors[ActiveMonitor].Left + Screen.Monitors[ActiveMonitor].Width;
  MonitorHeigth := Screen.Monitors[ActiveMonitor].Top + Screen.Monitors[ActiveMonitor].Height;

  CryptoSettings.Left := Trunc((MonitorWidth-CryptoSettings.Width)/2);
  CryptoSettings.Top := Trunc((MonitorHeigth-CryptoSettings.Height)/2);
end;


procedure TCryptoSettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SettingsDB.Coin := ComboBox1.Text;
  SettingsDB.Currency := ComboBox2.Text;

  CryptoSettings.Hide;
  CryptoGraph.Timer1Timer(nil);

  SaveRegistryString(SettingsDB.Coin, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'Coin');
  SaveRegistryString(SettingsDB.Currency, DEFAULT_ROOT_KEY, DEFAULT_KEY, 'Currency');
end;

end.

