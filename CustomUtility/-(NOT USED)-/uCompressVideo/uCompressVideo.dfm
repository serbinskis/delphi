object CompressVideo: TCompressVideo
  Left = 192
  Top = 125
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Compress Video'
  ClientHeight = 405
  ClientWidth = 410
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 296
    Top = 12
    Width = 23
    Height = 13
    Caption = 'FPS:'
  end
  object Label2: TLabel
    Left = 296
    Top = 108
    Width = 63
    Height = 13
    Caption = 'Video Bitrate:'
  end
  object Label3: TLabel
    Left = 296
    Top = 60
    Width = 53
    Height = 13
    Caption = 'Video Size:'
  end
  object Label4: TLabel
    Left = 296
    Top = 156
    Width = 60
    Height = 13
    Caption = 'Audio Bitrate'
  end
  object Label5: TLabel
    Left = 296
    Top = 204
    Width = 94
    Height = 13
    Caption = 'Audio Sample Rate:'
  end
  object ListBox1: TListBox
    Left = 8
    Top = 8
    Width = 281
    Height = 370
    ItemHeight = 13
    ParentShowHint = False
    PopupMenu = PopupMenu1
    ShowHint = True
    TabOrder = 0
    OnClick = ListBox1Click
    OnKeyDown = ListBox1KeyDown
  end
  object Button1: TButton
    Left = 8
    Top = 384
    Width = 129
    Height = 17
    Caption = 'Compress'
    TabOrder = 1
    OnClick = Button1Click
  end
  object ComboBox1: TComboBox
    Left = 296
    Top = 32
    Width = 105
    Height = 21
    ItemHeight = 13
    TabOrder = 2
    Text = '23.976'
    Items.Strings = (
      '12'
      '15'
      '18'
      '20'
      '23.976'
      '24'
      '25'
      '30'
      '50'
      '60')
  end
  object ComboBox2: TComboBox
    Left = 296
    Top = 80
    Width = 105
    Height = 21
    ItemHeight = 13
    TabOrder = 3
    Text = '1280x720'
    Items.Strings = (
      '320x240'
      '352x288'
      '640x480'
      '720x480'
      '720x576'
      '1280x720'
      '1440x1080'
      '1920x1080')
  end
  object ComboBox5: TComboBox
    Left = 296
    Top = 224
    Width = 105
    Height = 21
    ItemHeight = 13
    TabOrder = 4
    Text = '48000'
    Items.Strings = (
      '22050'
      '24000'
      '44100'
      '48000')
  end
  object ComboBox3: TComboBox
    Left = 296
    Top = 128
    Width = 105
    Height = 21
    ItemHeight = 13
    TabOrder = 5
    Text = '1536k'
    Items.Strings = (
      '256k'
      '384k'
      '512k'
      '768k'
      '1024k'
      '1200k'
      '1536k'
      '1600k'
      '2000k'
      '2400k'
      '4000k'
      '5000k'
      '6000k'
      '8000k'
      '10000k'
      '15000k'
      '16000k')
  end
  object ComboBox4: TComboBox
    Left = 296
    Top = 176
    Width = 105
    Height = 21
    ItemHeight = 13
    TabOrder = 6
    Text = '320k'
    Items.Strings = (
      '24k'
      '32k'
      '64k'
      '96k'
      '128k'
      '192k'
      '224k'
      '256k'
      '320k')
  end
  object Button2: TButton
    Left = 144
    Top = 384
    Width = 145
    Height = 17
    Caption = 'Pause'
    TabOrder = 7
    OnClick = Button2Click
  end
  object PopupMenu1: TPopupMenu
    Left = 296
    Top = 256
    object Open1: TMenuItem
      Caption = 'Open'
      OnClick = CreateDialog
    end
  end
end
