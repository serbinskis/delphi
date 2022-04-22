object Form2: TForm2
  Left = 200
  Top = 276
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 370
  ClientWidth = 405
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClick = FormClick
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 6
    Top = 24
    Width = 390
    Height = 2
  end
  object Bevel2: TBevel
    Left = 5
    Top = 112
    Width = 390
    Height = 2
  end
  object Bevel3: TBevel
    Left = 5
    Top = 320
    Width = 390
    Height = 2
  end
  object Bevel4: TBevel
    Left = 5
    Top = 248
    Width = 390
    Height = 2
  end
  object CheckBox1: TFlatCheckBox
    Left = 8
    Top = 122
    Width = 161
    Height = 17
    Caption = 'Remove items older than'
    ColorDown = 15790320
    ColorBorder = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    TabStop = True
  end
  object CheckBox3: TFlatCheckBox
    Left = 8
    Top = 186
    Width = 169
    Height = 17
    Caption = 'Maximum number of items'
    ColorDown = 15790320
    ColorBorder = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    TabStop = True
  end
  object CheckBox2: TFlatCheckBox
    Left = 8
    Top = 154
    Width = 177
    Height = 17
    Caption = 'Do not save text bigger than'
    ColorDown = 15790320
    ColorBorder = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    TabStop = True
  end
  object CheckBox0: TFlatCheckBox
    Left = 8
    Top = 32
    Width = 129
    Height = 17
    Caption = 'Clipboard monitor'
    ColorDown = 15790320
    ColorBorder = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    TabStop = True
  end
  object ComboBox1: TFlatComboBox
    Left = 320
    Top = 120
    Width = 70
    Height = 22
    Style = csDropDownList
    Color = clWindow
    ColorArrowBackground = clWhite
    ColorBorder = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Calibri'
    Font.Style = []
    ItemHeight = 14
    Items.Strings = (
      'Minutes'
      'Hours'
      'Days'
      'Weeks'
      'Month')
    ParentFont = False
    TabOrder = 4
    Text = 'Minutes'
    ItemIndex = 0
    OnChange = ComboBox1Change
  end
  object ComboBox2: TFlatComboBox
    Left = 320
    Top = 152
    Width = 70
    Height = 22
    Style = csDropDownList
    Color = clWindow
    ColorArrowBackground = clWhite
    ColorBorder = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Calibri'
    Font.Style = []
    ItemHeight = 14
    Items.Strings = (
      'Bytes'
      'KB'
      'MB')
    ParentFont = False
    TabOrder = 5
    Text = 'Bytes'
    ItemIndex = 0
    OnChange = ComboBox2Change
  end
  object SpinEdit1: TFlatSpinEditInteger
    Left = 192
    Top = 120
    Width = 121
    Height = 22
    ColorBorder = clBlack
    ColorFlat = clWhite
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    MaxValue = 99999
    MinValue = 1
    ParentColor = True
    ParentFont = False
    TabOrder = 6
    Value = 1
    OnChange = SpinEdit1Change
    OnExit = SpinEdit1Exit
  end
  object SpinEdit2: TFlatSpinEditInteger
    Left = 192
    Top = 152
    Width = 121
    Height = 22
    ColorBorder = clBlack
    ColorFlat = clWhite
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    MaxValue = 99999
    MinValue = 1
    ParentColor = True
    ParentFont = False
    TabOrder = 7
    Value = 1
    OnChange = SpinEdit2Change
    OnExit = SpinEdit2Exit
  end
  object SpinEdit3: TFlatSpinEditInteger
    Left = 192
    Top = 184
    Width = 121
    Height = 22
    ColorBorder = clBlack
    ColorFlat = clWhite
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    MaxValue = 99999
    MinValue = 1
    ParentColor = True
    ParentFont = False
    TabOrder = 8
    Value = 1
    OnChange = SpinEdit3Change
    OnExit = SpinEdit3Exit
  end
  object Panel2: TFlatPanel
    Left = 88
    Top = 332
    Width = 75
    Height = 25
    Hint = 'Import clipboard list'
    Caption = 'Import'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentColor = True
    ColorHighLight = clBlack
    ColorShadow = clBlack
    TabOrder = 9
    OnClick = Panel2Click
    OnMouseDown = PanelMouseDown
  end
  object Panel1: TFlatPanel
    Left = 8
    Top = 332
    Width = 75
    Height = 25
    Hint = 'Export clipboard list'
    Caption = 'Export'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentColor = True
    ColorHighLight = clBlack
    ColorShadow = clBlack
    TabOrder = 10
    OnClick = Panel1Click
    OnMouseDown = PanelMouseDown
  end
  object Panel3: TFlatPanel
    Left = 168
    Top = 332
    Width = 75
    Height = 25
    Hint = 'Clear clipboard list'
    Caption = 'Clear'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentColor = True
    ColorHighLight = clBlack
    ColorShadow = clBlack
    TabOrder = 11
    OnClick = Panel3Click
    OnMouseDown = PanelMouseDown
  end
  object CheckBox4: TFlatCheckBox
    Left = 8
    Top = 258
    Width = 161
    Height = 17
    Caption = 'Auto save every'
    ColorDown = 15790320
    ColorBorder = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 12
    TabStop = True
  end
  object SpinEdit4: TFlatSpinEditInteger
    Left = 192
    Top = 256
    Width = 121
    Height = 22
    ColorBorder = clBlack
    ColorFlat = clWhite
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    MaxValue = 99999
    MinValue = 1
    ParentColor = True
    ParentFont = False
    TabOrder = 13
    Value = 1
    OnChange = SpinEdit4Change
    OnExit = SpinEdit4Exit
  end
  object ComboBox3: TFlatComboBox
    Left = 320
    Top = 256
    Width = 70
    Height = 22
    Style = csDropDownList
    Color = clWindow
    ColorArrowBackground = clWhite
    ColorBorder = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Calibri'
    Font.Style = []
    ItemHeight = 14
    Items.Strings = (
      'Minutes'
      'Hours')
    ParentFont = False
    TabOrder = 14
    Text = 'Hours'
    ItemIndex = 1
    OnChange = ComboBox3Change
  end
  object StaticText5: TStaticText
    Left = 256
    Top = 335
    Width = 133
    Height = 22
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Size:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 15
  end
  object StaticText2: TStaticText
    Left = 8
    Top = 4
    Width = 88
    Height = 17
    AutoSize = False
    Caption = 'FEATURES'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI Semibold'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 16
  end
  object StaticText1: TStaticText
    Left = 8
    Top = 92
    Width = 149
    Height = 18
    AutoSize = False
    Caption = 'STORE && AUTO-CLEAN'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI Semibold'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 17
  end
  object StaticText3: TStaticText
    Left = 8
    Top = 228
    Width = 73
    Height = 18
    AutoSize = False
    Caption = 'AUTO-SAVE'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI Semibold'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 18
  end
  object StaticText4: TStaticText
    Left = 8
    Top = 300
    Width = 177
    Height = 18
    AutoSize = False
    Caption = 'EXPORT && IMPORT && CLEAR'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI Semibold'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 19
  end
  object Panel4: TFlatPanel
    Left = 288
    Top = 34
    Width = 105
    Height = 25
    Hint = 'Clear duplicated items'
    Caption = 'Clear duplicates'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentColor = True
    ColorHighLight = clBlack
    ColorShadow = clBlack
    TabOrder = 20
    OnClick = Panel4Click
    OnMouseDown = PanelMouseDown
  end
  object CheckBox5: TFlatCheckBox
    Left = 8
    Top = 56
    Width = 129
    Height = 17
    Hint = 'Ignores favorites'
    Caption = 'Prevent duplicates'
    ColorDown = 15790320
    ColorBorder = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    ShowHint = True
    TabOrder = 21
    TabStop = True
  end
end
