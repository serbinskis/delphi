object Form1: TForm1
  Left = 182
  Top = 125
  Width = 800
  Height = 519
  Caption = 'WebCam Snapshot'
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 144
    Top = 0
    Width = 640
    Height = 480
    Stretch = True
  end
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 38
    Height = 13
    Caption = 'FPS: 60'
  end
  object TrackBar1: TTrackBar
    Left = 8
    Top = 24
    Width = 130
    Height = 21
    Align = alCustom
    Max = 60
    Min = 1
    PageSize = 1
    Position = 60
    TabOrder = 0
    OnChange = TrackBar1Change
  end
  object ComboBox1: TComboBox
    Left = 16
    Top = 56
    Width = 113
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
  end
  object Button1: TButton
    Left = 16
    Top = 88
    Width = 113
    Height = 25
    Caption = 'Start'
    TabOrder = 2
    OnClick = Button1Click
  end
end
