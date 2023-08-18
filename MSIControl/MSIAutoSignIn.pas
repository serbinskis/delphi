unit MSIAutoSignIn;

interface

uses
  Windows, Menus, Forms, Classes, ExtCtrls, MSIControl, uWTSSessions, Functions;

type
  TForm10 = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TEventHandler = class
    procedure MenuClick(Sender: TObject);
  end;

const
  DEFAULT_AUTOSIGNIN_KEY = DEFAULT_KEY + '\AutoSignIn';

var
  Form10: TForm10;
  EventHandler: TEventHandler;
  MenuItem: TMenuItem;
  UserName: WideString;
  SessionId: Integer;
  Counter: Integer = 0;
  Limit: Integer = 5;

implementation

{$R *.dfm}

procedure TEventHandler.MenuClick(Sender: TObject);
begin
  Form10.Timer1.Enabled := not Form10.Timer1.Enabled;
  MenuItem.Default := Form10.Timer1.Enabled;
  SaveRegistryBoolean(Form10.Timer1.Enabled, DEFAULT_ROOT_KEY, DEFAULT_AUTOSIGNIN_KEY, 'ENABLED');
end;


procedure TForm10.Timer1Timer(Sender: TObject);
begin
  if (WTGetUserState(UserName) = WTSDisconnected) then Inc(Counter) else Counter := 0;
  if (Counter >= Limit) then WTSConnectSessionW(SessionId, WTSGetActiveConsoleSessionId(), '', True);
  if (Counter >= Limit) then Counter := 0;
end;


procedure TForm10.FormCreate(Sender: TObject);
var
  b: Boolean;
begin
  EventHandler := TEventHandler.Create;
  MenuItem := TMenuItem.Create(nil);
  MenuItem.Caption := 'Toggle Auto Sign In';
  MenuItem.OnClick := EventHandler.MenuClick;
  Form1.PopupMenu1.Items.Find('Toggle').Add(MenuItem);

  UserName := GetEnvironmentVariable('UserName');
  SessionId := WTFindSessionId(UserName);
  b := False;

  if (not LoadRegistryBoolean(b, DEFAULT_ROOT_KEY, DEFAULT_AUTOSIGNIN_KEY, 'ENABLED'))
    then SaveRegistryBoolean(b, DEFAULT_ROOT_KEY, DEFAULT_AUTOSIGNIN_KEY, 'ENABLED');

  Timer1.Enabled := b;
  MenuItem.Default := b;

  if (not LoadRegistryInteger(Limit, DEFAULT_ROOT_KEY, DEFAULT_AUTOSIGNIN_KEY, 'TRIGGER_COUNT'))
    then SaveRegistryInteger(Limit, DEFAULT_ROOT_KEY, DEFAULT_AUTOSIGNIN_KEY, 'TRIGGER_COUNT');
end;

end.

