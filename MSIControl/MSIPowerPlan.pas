unit MSIPowerPlan;

interface

uses
  Windows, MMSystem, Menus, Forms, uPowerPlan, Functions;

type
  TForm9 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure TrayIcon1RightDown(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TEventHandler = class
    procedure MenuClick(Sender: TObject);
  end;

var
  Form9: TForm9;
  EventHandler: TEventHandler;
  PowerPlan: TPowerPlan;
  MenuItem: TMenuItem;

implementation

uses MSIControl;

{$R *.dfm}

procedure TEventHandler.MenuClick(Sender: TObject);
var
  i: Integer;
  b: Boolean;
begin
  b := PowerPlan.SetActiveScheme(TMenuItem(Sender).Hint);
  i := MSIControl.SettingDynData.FindIndex(0, 'Name', 'SETTING_HOTKEY_SOUND');
  if ((i > -1) and b) and MSIControl.SettingDynData.GetValue(i, 'Value') then PlaySound('HOTKEY', 0, SND_RESOURCE or SND_ASYNC);
  Form9.TrayIcon1RightDown(nil);
end;


procedure TForm9.TrayIcon1RightDown(Sender: TObject);
var
  i: Integer;
  PlanItem: TMenuItem;
  ActiveScheme: String;
begin
  PowerPlan.Update;
  MenuItem.Clear;
  ActiveScheme := PowerPlan.GetActiveScheme;

  for i := 0 to PowerPlan.GetSchemesCount-1 do begin
    PlanItem := TMenuItem.Create(nil);
    PlanItem.Caption := PowerPlan.GetFriendlyName(i);
    PlanItem.Hint := PowerPlan.GetGUID(i);
    PlanItem.OnClick := EventHandler.MenuClick;
    MenuItem.Add(PlanItem);
    PlanItem.Default := (PlanItem.Hint = ActiveScheme);
  end;
end;


procedure TForm9.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  PowerPlan := TPowerPlan.Create;
  EventHandler := TEventHandler.Create;
  Form1.TrayIcon1.OnRightDown := Form9.TrayIcon1RightDown;

  MenuItem := TMenuItem.Create(nil);
  MenuItem.Caption := 'Power Plan';
  i := Form1.PopupMenu1.Items.IndexOf(Form1.PopupMenu1.Items.Find('Toggle'));
  Form1.PopupMenu1.Items.Insert(i+1, MenuItem);
end;

end.

