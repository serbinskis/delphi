object Form3: TForm3
  Left = 185
  Top = 124
  BorderStyle = bsDialog
  Caption = 'Administrator'
  ClientHeight = 195
  ClientWidth = 195
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 180
    Height = 177
    Caption = 'Administrator'
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 24
      Width = 55
      Height = 13
      Caption = 'Username:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 8
      Top = 104
      Width = 24
      Height = 13
      Caption = 'URL:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Edit1: TEdit
      Left = 8
      Top = 40
      Width = 161
      Height = 21
      TabOrder = 0
    end
    object Button3: TButton
      Left = 8
      Top = 72
      Width = 49
      Height = 20
      Caption = 'Kick'
      TabOrder = 1
      OnClick = Button3Click
    end
    object Button2: TButton
      Left = 64
      Top = 72
      Width = 51
      Height = 20
      Caption = 'Mute'
      TabOrder = 2
      OnClick = Button2Click
    end
    object Button5: TButton
      Left = 120
      Top = 72
      Width = 51
      Height = 20
      Caption = 'Unmute'
      TabOrder = 3
      OnClick = Button5Click
    end
    object Edit2: TEdit
      Left = 8
      Top = 120
      Width = 161
      Height = 21
      TabOrder = 4
    end
    object Button6: TButton
      Left = 8
      Top = 144
      Width = 161
      Height = 20
      Caption = 'Open URL'
      TabOrder = 5
      OnClick = Button6Click
    end
  end
end
