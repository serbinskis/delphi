object Form2: TForm2
  Left = 200
  Top = 300
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 256
  ClientWidth = 320
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -13
  Font.Name = 'Calibri'
  Font.Style = []
  OldCreateOrder = False
  OnClick = FormClick
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 42
    Width = 51
    Height = 15
    Caption = 'Output 1:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 74
    Width = 51
    Height = 15
    Caption = 'Output 2:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
  end
  object Bevel1: TBevel
    Left = 6
    Top = 30
    Width = 309
    Height = 1
    Shape = bsFrame
  end
  object Bevel2: TBevel
    Left = 6
    Top = 126
    Width = 309
    Height = 1
    Shape = bsFrame
  end
  object Bevel3: TBevel
    Left = 6
    Top = 214
    Width = 309
    Height = 1
    Shape = bsFrame
  end
  object Bevel4: TBevel
    Left = 8
    Top = 223
    Width = 121
    Height = 23
    Shape = bsFrame
  end
  object StaticText1: TStaticText
    Left = 8
    Top = 8
    Width = 108
    Height = 21
    Caption = 'OUTPUT DEVICES'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Segoe UI Semibold'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object ComboBox1: TFlatComboBox
    Left = 80
    Top = 40
    Width = 233
    Height = 22
    Style = csDropDownList
    Color = clWhite
    ColorArrowBackground = clWhite
    ColorBorder = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Calibri'
    Font.Style = []
    ItemHeight = 14
    ParentFont = False
    TabOrder = 1
    ItemIndex = -1
    OnChange = ComboBoxChange
  end
  object ComboBox2: TFlatComboBox
    Left = 80
    Top = 70
    Width = 233
    Height = 22
    Style = csDropDownList
    Color = clWhite
    ColorArrowBackground = clWhite
    ColorBorder = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Calibri'
    Font.Style = []
    ItemHeight = 14
    ParentFont = False
    TabOrder = 2
    ItemIndex = -1
    OnChange = ComboBoxChange
  end
  object StaticText2: TStaticText
    Left = 8
    Top = 104
    Width = 62
    Height = 21
    Caption = 'SETTINGS'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Segoe UI Semibold'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
  end
  object CheckBox1: TFlatCheckBox
    Left = 8
    Top = 134
    Width = 121
    Height = 17
    Hint = 'Always turn on Num Lock.'
    Caption = 'Always Num Lock'
    ColorDown = 15790320
    ColorBorder = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    ShowHint = True
    TabOrder = 4
    TabStop = True
    OnMouseUp = CheckBox1MouseUp
  end
  object CheckBox3: TFlatCheckBox
    Left = 8
    Top = 166
    Width = 153
    Height = 17
    Caption = 'Save sounds in memory'
    ColorDown = 15790320
    ColorBorder = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    ShowHint = True
    TabOrder = 5
    TabStop = True
    OnMouseUp = CheckBox3MouseUp
  end
  object CheckBox2: TFlatCheckBox
    Left = 8
    Top = 150
    Width = 89
    Height = 17
    Hint = 'Application will stay on top.'
    Caption = 'Stay on top'
    ColorDown = 15790320
    ColorBorder = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    ShowHint = True
    TabOrder = 6
    TabStop = True
    OnMouseUp = CheckBox2MouseUp
  end
  object StaticText3: TStaticText
    Left = 8
    Top = 192
    Width = 61
    Height = 21
    Caption = 'HOTKEYS'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Segoe UI Semibold'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 7
  end
  object ComboBox3: TFlatComboBox
    Left = 144
    Top = 223
    Width = 169
    Height = 22
    Style = csDropDownList
    Color = clWhite
    ColorArrowBackground = clWhite
    ColorBorder = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Calibri'
    Font.Style = []
    ItemHeight = 14
    ParentFont = False
    TabOrder = 9
    ItemIndex = -1
    OnChange = ComboBox3Change
  end
  object HotKey1: THotKey
    Left = 8
    Top = 223
    Width = 121
    Height = 23
    HotKey = 0
    InvalidKeys = []
    Modifiers = []
    TabOrder = 8
    OnChange = HotKey1Change
    OnExit = HotKey1Exit
  end
end
