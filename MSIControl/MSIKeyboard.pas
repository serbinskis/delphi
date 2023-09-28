unit MSIKeyboard;

interface

uses
  Windows, Menus, Forms, uKeyboardHook, Functions;

type
  TForm7 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TEventHandler = class
    procedure KeyboardToggleClick(Sender: TObject);
  end;

var
  Form7: TForm7;
  EventHandler: TEventHandler;
  kDisabled: Boolean = False;

implementation

uses MSIControl;

{$R *.dfm}

procedure TEventHandler.KeyboardToggleClick(Sender: TObject);
begin
  kDisabled := not kDisabled;
  if (kDisabled) then StartKeyboardHook else StopKeyboardHook;
  DisableKeyboard(kDisabled);
end;

procedure TForm7.FormCreate(Sender: TObject);
var
  MenuItem: TMenuItem;
begin
  EventHandler := TEventHandler.Create;
  MenuItem := TMenuItem.Create(nil);
  MenuItem.Caption := 'Toggle Keyboard';
  MenuItem.OnClick := EventHandler.KeyboardToggleClick;
  Form1.PopupMenu1.Items.Find('Toggle').Add(MenuItem);
end;

end.
