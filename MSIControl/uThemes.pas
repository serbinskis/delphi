unit uThemes;

interface

uses
  Windows, Forms, StdCtrls, XiButton, XiTrackBar, TFlatComboBoxUnit, TFlatCheckBoxUnit,
  CustoBevel, CustoHotKey, Functions;

type
  TRGB = record
    R, G, B: Byte;
  end;

const
  BLACK_WHITE_COLOR: array[0..1] of TRGB = ((R: 255; G: 255; B: 255), (R: 0; G: 0; B: 0));
  EERIE_BLACK_COLOR: array[0..1] of TRGB = ((R: 31; G: 31; B: 31), (R: 228; G: 228; B: 228));
  BEVEL_COLOR: array[0..1] of TRGB = ((R: 76; G: 76; B: 76), (R: 182; G: 182; B: 182));

const
  TRACKBAR_BUTTON: array[0..1] of TRGB = ((R: 41; G: 204; B: 186), (R: 41; G: 204; B: 186));
  TRACKBAR_BUTTON_HOVER: array[0..1] of TRGB = ((R: 255; G: 255; B: 255), (R: 0; G: 0; B: 0));
  TRACKBAR_BEFORE: array[0..1] of TRGB = ((R: 89; G: 255; B: 237), (R: 41; G: 204; B: 186));
  TRACKBAR_AFTER: array[0..1] of TRGB = ((R: 121; G: 121; B: 121), (R: 137; G: 137; B: 137));

const
  BUTTON: array[0..1] of TRGB = ((R: 41; G: 204; B: 186), (R: 41; G: 204; B: 186));
  BUTTON_HOVER: array[0..1] of TRGB = ((R: 255; G: 255; B: 255), (R: 0; G: 0; B: 0));
  BUTTON_BORDER: array[0..1] of TRGB = ((R: 76; G: 76; B: 76), (R: 239; G: 239; B: 239));
  BUTTON_BORDER_HOVER: array[0..1] of TRGB = ((R: 148; G: 148; B: 148), (R: 146; G: 146; B: 146));

const
  ThemeCaption: array[0..1] of String = ('White', 'Dark');

var
  Theme: Boolean = False;

procedure ChangeTheme(WhiteMode: Boolean; Form: TForm);

implementation

uses
  uSettings;

procedure ChangeButtonTheme(XiButton: TXiButton; WhitMode: Boolean);
var
  i: Integer;
begin
  i := Integer(not WhitMode);
  XiButton.ColorText := RGB(BLACK_WHITE_COLOR[i].R, BLACK_WHITE_COLOR[i].G, BLACK_WHITE_COLOR[i].B);
  XiButton.OverColorText := RGB(BLACK_WHITE_COLOR[i].R, BLACK_WHITE_COLOR[i].G, BLACK_WHITE_COLOR[i].B);
  XiButton.DownColorText := RGB(BLACK_WHITE_COLOR[i].R, BLACK_WHITE_COLOR[i].G, BLACK_WHITE_COLOR[i].B);
  i := Integer(WhitMode);

  XiButton.ColorBorder := RGB(BUTTON_BORDER[i].R, BUTTON_BORDER[i].G, BUTTON_BORDER[i].B);
  XiButton.OverColorBorder := RGB(BUTTON_BORDER_HOVER[i].R, BUTTON_BORDER_HOVER[i].G, BUTTON_BORDER_HOVER[i].B);
  XiButton.DownColorBorder := RGB(BUTTON_BORDER_HOVER[i].R, BUTTON_BORDER_HOVER[i].G, BUTTON_BORDER_HOVER[i].B);

  XiButton.ColorDark := RGB(BUTTON[i].R, BUTTON[i].G, BUTTON[i].B);
  XiButton.ColorFace := RGB(BUTTON[i].R, BUTTON[i].G, BUTTON[i].B);
  XiButton.ColorGrad := RGB(BUTTON[i].R, BUTTON[i].G, BUTTON[i].B);
  XiButton.ColorLight := RGB(BUTTON[i].R, BUTTON[i].G, BUTTON[i].B);

  XiButton.OverColorDark := RGB(BUTTON_HOVER[i].R, BUTTON_HOVER[i].G, BUTTON_HOVER[i].B);
  XiButton.OverColorFace := RGB(BUTTON_HOVER[i].R, BUTTON_HOVER[i].G, BUTTON_HOVER[i].B);
  XiButton.OverColorGrad := RGB(BUTTON_HOVER[i].R, BUTTON_HOVER[i].G, BUTTON_HOVER[i].B);
  XiButton.OverColorLight := RGB(BUTTON_HOVER[i].R, BUTTON_HOVER[i].G, BUTTON_HOVER[i].B);

  XiButton.DownColorDark := RGB(BUTTON_HOVER[i].R, BUTTON_HOVER[i].G, BUTTON_HOVER[i].B);
  XiButton.DownColorFace := RGB(BUTTON_HOVER[i].R, BUTTON_HOVER[i].G, BUTTON_HOVER[i].B);
  XiButton.DownColorGrad := RGB(BUTTON_HOVER[i].R, BUTTON_HOVER[i].G, BUTTON_HOVER[i].B);
  XiButton.DownColorLight := RGB(BUTTON_HOVER[i].R, BUTTON_HOVER[i].G, BUTTON_HOVER[i].B);

  XiButton.DisabledColorDark := RGB(TRACKBAR_AFTER[i].R, TRACKBAR_AFTER[i].G, TRACKBAR_AFTER[i].B);
  XiButton.DisabledColorFace := RGB(TRACKBAR_AFTER[i].R, TRACKBAR_AFTER[i].G, TRACKBAR_AFTER[i].B);
  XiButton.DisabledColorGrad := RGB(TRACKBAR_AFTER[i].R, TRACKBAR_AFTER[i].G, TRACKBAR_AFTER[i].B);
  XiButton.DisabledColorLight := RGB(TRACKBAR_AFTER[i].R, TRACKBAR_AFTER[i].G, TRACKBAR_AFTER[i].B);
end;

procedure ChangeComboBoxTheme(ComboBox: TFlatComboBox; WhitMode: Boolean);
var
  i: Integer;
begin
  i := Integer(WhitMode);
  ComboBox.Color := RGB(EERIE_BLACK_COLOR[i].R, EERIE_BLACK_COLOR[i].G, EERIE_BLACK_COLOR[i].B);
  ComboBox.ColorArrow := RGB(BEVEL_COLOR[i].R, BEVEL_COLOR[i].G, BEVEL_COLOR[i].B);
  ComboBox.ColorArrowBackground := RGB(EERIE_BLACK_COLOR[i].R, EERIE_BLACK_COLOR[i].G, EERIE_BLACK_COLOR[i].B);
  ComboBox.ColorBorder := RGB(BEVEL_COLOR[i].R, BEVEL_COLOR[i].G, BEVEL_COLOR[i].B);
  ComboBox.Font.Color := RGB(BLACK_WHITE_COLOR[i].R, BLACK_WHITE_COLOR[i].G, BLACK_WHITE_COLOR[i].B);
end;

procedure ChangeCheckBoxTheme(CheckBox: TFlatCheckBox; WhitMode: Boolean);
var
  i: Integer;
begin
  i := Integer(WhitMode);
  CheckBox.ColorCheck := RGB(BLACK_WHITE_COLOR[i].R, BLACK_WHITE_COLOR[i].G, BLACK_WHITE_COLOR[i].B);
  CheckBox.Color := RGB(EERIE_BLACK_COLOR[i].R, EERIE_BLACK_COLOR[i].G, EERIE_BLACK_COLOR[i].B);
  CheckBox.ColorFocused := RGB(EERIE_BLACK_COLOR[i].R, EERIE_BLACK_COLOR[i].G, EERIE_BLACK_COLOR[i].B);
  CheckBox.ColorDown := RGB(BUTTON[i].R, BUTTON[i].G, BUTTON[i].B);
  CheckBox.ColorBorder := RGB(BEVEL_COLOR[i].R, BEVEL_COLOR[i].G, BEVEL_COLOR[i].B);
  CheckBox.Font.Color := RGB(BLACK_WHITE_COLOR[i].R, BLACK_WHITE_COLOR[i].G, BLACK_WHITE_COLOR[i].B);
end;

procedure ChangeTrackBarTheme(TrackBar: TXiTrackBar; WhitMode: Boolean);
var
  i: Integer;
begin
  i := Integer(WhitMode);
  TrackBar.BackColor := RGB(EERIE_BLACK_COLOR[i].R, EERIE_BLACK_COLOR[i].G, EERIE_BLACK_COLOR[i].B);
  TrackBar.SlideBorderColor := RGB(TRACKBAR_AFTER[i].R, TRACKBAR_AFTER[i].G, TRACKBAR_AFTER[i].B);
  TrackBar.SlideFaceColor := RGB(TRACKBAR_AFTER[i].R, TRACKBAR_AFTER[i].G, TRACKBAR_AFTER[i].B);
  TrackBar.SlideGradColor := RGB(TRACKBAR_AFTER[i].R, TRACKBAR_AFTER[i].G, TRACKBAR_AFTER[i].B);

  TrackBar.ThumbBorderColor := RGB(TRACKBAR_BUTTON[i].R, TRACKBAR_BUTTON[i].G, TRACKBAR_BUTTON[i].B);
  TrackBar.ThumbFaceColor := RGB(TRACKBAR_BUTTON[i].R, TRACKBAR_BUTTON[i].G, TRACKBAR_BUTTON[i].B);
  TrackBar.ThumbGradColor := RGB(TRACKBAR_BUTTON[i].R, TRACKBAR_BUTTON[i].G, TRACKBAR_BUTTON[i].B);

  TrackBar.DownThumbBorderColor := RGB(TRACKBAR_BUTTON_HOVER[i].R, TRACKBAR_BUTTON_HOVER[i].G, TRACKBAR_BUTTON_HOVER[i].B);
  TrackBar.DownThumbFaceColor := RGB(TRACKBAR_BUTTON_HOVER[i].R, TRACKBAR_BUTTON_HOVER[i].G, TRACKBAR_BUTTON_HOVER[i].B);
  TrackBar.DownThumbGradColor := RGB(TRACKBAR_BUTTON_HOVER[i].R, TRACKBAR_BUTTON_HOVER[i].G, TRACKBAR_BUTTON_HOVER[i].B);

  TrackBar.OverThumbBorderColor := RGB(TRACKBAR_BUTTON_HOVER[i].R, TRACKBAR_BUTTON_HOVER[i].G, TRACKBAR_BUTTON_HOVER[i].B);
  TrackBar.OverThumbFaceColor := RGB(TRACKBAR_BUTTON_HOVER[i].R, TRACKBAR_BUTTON_HOVER[i].G, TRACKBAR_BUTTON_HOVER[i].B);
  TrackBar.OverThumbGradColor := RGB(TRACKBAR_BUTTON_HOVER[i].R, TRACKBAR_BUTTON_HOVER[i].G, TRACKBAR_BUTTON_HOVER[i].B);
end;

procedure ChangeBevelTheme(Bevel: TCustoBevel; WhitMode: Boolean);
var
  i: Integer;
begin
  i := Integer(WhitMode);
  Bevel.Color := RGB(BEVEL_COLOR[i].R, BEVEL_COLOR[i].G, BEVEL_COLOR[i].B);
end;

procedure ChangeLabelTheme(cLabel: TLabel; WhitMode: Boolean);
var
  i: Integer;
begin
  i := Integer(WhitMode);
  cLabel.Font.Color := RGB(BLACK_WHITE_COLOR[i].R, BLACK_WHITE_COLOR[i].G, BLACK_WHITE_COLOR[i].B);
end;

procedure ChangeHotKeyTheme(HotKey: TCustoHotKey; WhitMode: Boolean);
var
  i: Integer;
begin
  i := Integer(WhitMode);
  HotKey.Color := RGB(EERIE_BLACK_COLOR[i].R, EERIE_BLACK_COLOR[i].G, EERIE_BLACK_COLOR[i].B);
  HotKey.Font.Color := RGB(BLACK_WHITE_COLOR[i].R, BLACK_WHITE_COLOR[i].G, BLACK_WHITE_COLOR[i].B);
  HotKey.SetBorderColor(RGB(BEVEL_COLOR[i].R, BEVEL_COLOR[i].G, BEVEL_COLOR[i].B));
end;

procedure ChangeTheme(WhiteMode: Boolean; Form: TForm);
var
  i, j: Integer;
  Name: String;
begin
  i := Integer(WhiteMode);
  SaveRegistryBoolean(WhiteMode, DEFAULT_ROOT_KEY, DEFAULT_KEY, THEME_REGISTRY_NAME);
  Form.Color := RGB(EERIE_BLACK_COLOR[i].R, EERIE_BLACK_COLOR[i].G, EERIE_BLACK_COLOR[i].B);

  for j := 0 to Form.ComponentCount-1 do begin
    Name := Form.Components[j].ClassName;
    if Name = 'TCustoBevel' then ChangeBevelTheme(TCustoBevel(Form.Components[j]), WhiteMode);
    if Name = 'TLabel' then ChangeLabelTheme(TLabel(Form.Components[j]), WhiteMode);
    if Name = 'TFlatComboBox' then ChangeComboBoxTheme(TFlatComboBox(Form.Components[j]), WhiteMode);
    if Name = 'TFlatCheckBox' then ChangeCheckBoxTheme(TFlatCheckBox(Form.Components[j]), WhiteMode);
    if Name = 'TCustoHotKey' then ChangeHotKeyTheme(TCustoHotKey(Form.Components[j]), WhiteMode);
    if Name = 'TXiTrackBar' then ChangeTrackBarTheme(TXiTrackBar(Form.Components[j]), WhiteMode);
    if Name = 'TXiButton' then ChangeButtonTheme(TXiButton(Form.Components[j]), WhiteMode);
    if (Name = 'TXiButton') and (TButton(Form.Components[j]).HelpKeyword = 'Theme') then TButton(Form.Components[j]).Caption := ThemeCaption[Integer(Theme)] + ' Theme';
  end;
end;

end.