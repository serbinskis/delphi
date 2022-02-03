object Form1: TForm1
  Left = 188
  Top = 124
  BorderStyle = bsDialog
  Caption = 'Voice Chat Server'
  ClientHeight = 350
  ClientWidth = 410
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 40
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
    Left = 8
    Top = 88
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
    Left = 8
    Top = 184
    Width = 103
    Height = 13
    Caption = 'PCM Audio Format:'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 8
    Top = 136
    Width = 88
    Height = 13
    Caption = 'Server Password:'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 65
    Height = 25
    Caption = 'Start Server'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 8
    Top = 56
    Width = 121
    Height = 21
    TabOrder = 1
  end
  object Edit2: TEdit
    Left = 8
    Top = 104
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '0'
  end
  object ListBox1: TListBox
    Left = 137
    Top = 8
    Width = 121
    Height = 215
    ItemHeight = 13
    TabOrder = 3
  end
  object ComboBox1: TComboBox
    Left = 8
    Top = 200
    Width = 121
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 4
  end
  object Button2: TButton
    Left = 80
    Top = 8
    Width = 51
    Height = 25
    Caption = 'Update'
    TabOrder = 5
    OnClick = Button2Click
  end
  object Edit3: TEdit
    Left = 8
    Top = 152
    Width = 121
    Height = 21
    TabOrder = 6
    Text = 'password'
  end
  object GroupBox1: TGroupBox
    Left = 264
    Top = 8
    Width = 137
    Height = 115
    Caption = 'Administrator'
    TabOrder = 7
    object Label5: TLabel
      Left = 8
      Top = 68
      Width = 53
      Height = 13
      Caption = 'Password:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label6: TLabel
      Left = 8
      Top = 20
      Width = 33
      Height = 13
      Caption = 'Login:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Edit4: TEdit
      Left = 8
      Top = 36
      Width = 121
      Height = 21
      TabOrder = 0
      Text = 'admin'
    end
    object Edit5: TEdit
      Left = 8
      Top = 84
      Width = 121
      Height = 21
      TabOrder = 1
      Text = 'admin'
    end
  end
  object Memo1: TMemo
    Left = 8
    Top = 232
    Width = 393
    Height = 113
    ReadOnly = True
    TabOrder = 8
  end
  object ServerSocket1: TServerSocket
    Active = False
    Port = 3300
    ServerType = stNonBlocking
    OnAccept = ServerSocket1Accept
    OnClientRead = ServerSocket1ClientRead
    Left = 264
    Top = 128
  end
  object Timer1: TTimer
    Interval = 30000
    OnTimer = Timer1Timer
    Left = 328
    Top = 128
  end
  object ServerSocket2: TServerSocket
    Active = False
    Port = 3999
    ServerType = stNonBlocking
    OnClientRead = ServerSocket2ClientRead
    Left = 296
    Top = 128
  end
end
