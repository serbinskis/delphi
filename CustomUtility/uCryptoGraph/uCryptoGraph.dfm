object CryptoGraph: TCryptoGraph
  Left = 192
  Top = 125
  BorderStyle = bsNone
  Caption = 'Crypto Graph'
  ClientHeight = 336
  ClientWidth = 594
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnHide = FormHide
  OnPaint = FormPaint
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 8
    Top = 8
    Width = 480
    Height = 320
    Align = alCustom
  end
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 481
    Height = 321
    Shape = bsFrame
  end
  object StaticText1: TStaticText
    Left = 496
    Top = 304
    Width = 11
    Height = 21
    Caption = '1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object StaticText2: TStaticText
    Left = 496
    Top = 272
    Width = 11
    Height = 21
    Caption = '2'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object StaticText3: TStaticText
    Left = 496
    Top = 240
    Width = 11
    Height = 21
    Caption = '3'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object StaticText4: TStaticText
    Left = 496
    Top = 208
    Width = 11
    Height = 21
    Caption = '4'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
  object StaticText5: TStaticText
    Left = 496
    Top = 176
    Width = 11
    Height = 21
    Caption = '5'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
  end
  object StaticText6: TStaticText
    Left = 496
    Top = 144
    Width = 11
    Height = 21
    Caption = '6'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
  end
  object StaticText7: TStaticText
    Left = 496
    Top = 112
    Width = 11
    Height = 21
    Caption = '7'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
  end
  object StaticText8: TStaticText
    Left = 496
    Top = 80
    Width = 11
    Height = 21
    Caption = '8'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 7
  end
  object StaticText9: TStaticText
    Left = 496
    Top = 48
    Width = 11
    Height = 21
    Caption = '9'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 8
  end
  object StaticText10: TStaticText
    Left = 496
    Top = 16
    Width = 18
    Height = 21
    Caption = '10'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 9
  end
  object Timer1: TTimer
    Interval = 60100
    OnTimer = Timer1Timer
    Left = 16
    Top = 16
  end
  object PopupMenu1: TPopupMenu
    Left = 80
    Top = 16
    object Options1: TMenuItem
      Caption = 'Options'
      OnClick = Options1Click
    end
    object Update1: TMenuItem
      Caption = 'Update'
      OnClick = Update1Click
    end
    object Exit1: TMenuItem
      Caption = 'Exit'
      OnClick = Exit1Click
    end
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = Timer2Timer
    Left = 48
    Top = 16
  end
end
