object Form4: TForm4
  Left = 201
  Top = 600
  BorderStyle = bsDialog
  Caption = 'Add Audio From YouTube'
  ClientHeight = 110
  ClientWidth = 320
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -13
  Font.Name = 'Calibri'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object StaticText1: TStaticText
    Left = 160
    Top = 77
    Width = 153
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 0
  end
  object Button1: TButton
    Left = 8
    Top = 73
    Width = 65
    Height = 24
    Caption = 'Serach'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 80
    Top = 73
    Width = 75
    Height = 24
    Caption = 'Download'
    TabOrder = 2
    OnClick = Button2Click
  end
  object ComboBox1: TFlatComboBox
    Left = 160
    Top = 40
    Width = 153
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
    TabOrder = 3
    ItemIndex = -1
  end
  object Edit1: TTntEdit
    Left = 8
    Top = 40
    Width = 145
    Height = 22
    Hint = 'Enter Video Code'
    AutoSize = False
    MaxLength = 11
    TabOrder = 4
    OnEnter = EditEnter
    OnExit = EditExit
  end
  object Edit2: TTntEdit
    Left = 8
    Top = 8
    Width = 305
    Height = 23
    Hint = 'Audio Name'
    MaxLength = 1000
    TabOrder = 5
    OnEnter = EditEnter
    OnExit = EditExit
  end
end
