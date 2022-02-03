object Form1: TForm1
  Left = 188
  Top = 123
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Upload Server'
  ClientHeight = 441
  ClientWidth = 335
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 104
    Top = 8
    Width = 48
    Height = 13
    Caption = 'Server IP:'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 200
    Top = 8
    Width = 60
    Height = 13
    Caption = 'Server Port:'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 311
    Top = 32
    Width = 15
    Height = 13
    Alignment = taRightJustify
    Caption = '0%'
  end
  object Edit1: TEdit
    Left = 104
    Top = 24
    Width = 89
    Height = 21
    TabOrder = 0
  end
  object Edit2: TEdit
    Left = 200
    Top = 24
    Width = 89
    Height = 21
    TabOrder = 1
    Text = '0'
  end
  object Button1: TButton
    Left = 8
    Top = 22
    Width = 89
    Height = 25
    Caption = 'Start Server'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 56
    Width = 321
    Height = 329
    ReadOnly = True
    TabOrder = 3
    WordWrap = False
  end
  object Memo2: TMemo
    Left = 8
    Top = 392
    Width = 321
    Height = 41
    ReadOnly = True
    TabOrder = 4
    WordWrap = False
  end
  object ServerSocket1: TServerSocket
    Active = False
    Port = 0
    ServerType = stNonBlocking
    OnClientConnect = ServerSocket1ClientConnect
    OnClientRead = ServerSocket1ClientRead
    OnClientError = ServerSocket1ClientError
    Left = 16
    Top = 64
  end
end
