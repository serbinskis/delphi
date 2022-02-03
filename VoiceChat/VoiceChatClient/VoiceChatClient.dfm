object Form1: TForm1
  Left = 185
  Top = 125
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Voice Chat Client | Connected: False'
  ClientHeight = 475
  ClientWidth = 585
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 8
    Top = 40
    Width = 80
    Height = 13
    Caption = 'Server Address:'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label1: TLabel
    Left = 8
    Top = 64
    Width = 32
    Height = 13
    Caption = 'Name:'
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
  object Label4: TLabel
    Left = 8
    Top = 184
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
  object Label6: TLabel
    Left = 296
    Top = 56
    Width = 170
    Height = 13
    Caption = 'Microphone fromat and volume:'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label7: TLabel
    Left = 296
    Top = 8
    Width = 92
    Height = 13
    Caption = 'Audio volume: 75'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
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
    Caption = 'Connect'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 8
    Top = 56
    Width = 137
    Height = 21
    TabOrder = 1
    Text = '127.0.0.1'
  end
  object Edit3: TEdit
    Left = 8
    Top = 200
    Width = 137
    Height = 21
    TabOrder = 2
    OnChange = Edit3Change
    OnKeyPress = Edit3KeyPress
  end
  object ListBox1: TListBox
    Left = 152
    Top = 8
    Width = 129
    Height = 215
    ItemHeight = 13
    TabOrder = 3
    OnClick = ListBox1Click
  end
  object Button2: TButton
    Left = 80
    Top = 8
    Width = 65
    Height = 25
    Caption = 'Disconnect'
    Enabled = False
    TabOrder = 4
    OnClick = Button2Click
  end
  object Edit2: TEdit
    Left = 8
    Top = 104
    Width = 137
    Height = 21
    TabOrder = 5
    Text = '0'
    OnKeyPress = Edit2KeyPress
  end
  object ProgressBar1: TProgressBar
    Left = 296
    Top = 96
    Width = 273
    Height = 17
    TabOrder = 6
  end
  object Edit4: TEdit
    Left = 296
    Top = 72
    Width = 273
    Height = 21
    Enabled = False
    ReadOnly = True
    TabOrder = 7
  end
  object Edit5: TEdit
    Left = 8
    Top = 448
    Width = 569
    Height = 21
    Enabled = False
    TabOrder = 8
    Text = 'Enter Message'
    OnChange = Edit5Change
    OnEnter = Edit5Enter
    OnExit = Edit5Exit
    OnKeyPress = Edit5KeyPress
  end
  object RichEdit1: TRichEdit
    Left = 8
    Top = 232
    Width = 569
    Height = 209
    Enabled = False
    ReadOnly = True
    TabOrder = 9
  end
  object Button5: TButton
    Left = 296
    Top = 120
    Width = 113
    Height = 25
    Caption = 'Mute Microphone'
    Enabled = False
    TabOrder = 10
    OnClick = Button5Click
  end
  object TrackBar1: TTrackBar
    Left = 288
    Top = 24
    Width = 289
    Height = 25
    Enabled = False
    Max = 100
    Position = 75
    TabOrder = 11
    TickStyle = tsNone
    OnChange = TrackBar1Change
  end
  object Edit6: TEdit
    Left = 8
    Top = 152
    Width = 137
    Height = 21
    TabOrder = 12
    OnChange = Edit6Change
    OnKeyPress = Edit6KeyPress
  end
  object ClientSocket1: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 3300
    OnConnect = ClientSocket1Connect
    OnRead = ClientSocket1Read
    Left = 416
    Top = 120
  end
  object ClientSocket2: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 3999
    OnRead = ClientSocket2Read
    Left = 448
    Top = 120
  end
  object LiveAudioRecorder1: TLiveAudioRecorder
    PCMFormat = Mono16bit22050Hz
    BufferLength = 100
    BufferCount = 10
    Async = True
    OnLevel = LiveAudioRecorder1Level
    OnData = LiveAudioRecorder1Data
    Left = 512
    Top = 120
  end
  object LiveAudioPlayer1: TLiveAudioPlayer
    PCMFormat = Mono16bit22050Hz
    Options = [woSetVolume]
    BufferInternally = False
    BufferLength = 100
    BufferCount = 10
    OnFormat = LiveAudioPlayer1Format
    OnDataPtr = LiveAudioPlayer1DataPtr
    Left = 544
    Top = 120
  end
  object MainMenu1: TMainMenu
    Left = 480
    Top = 120
    object Administrator: TMenuItem
      Caption = 'Administrator'
      Enabled = False
      OnClick = AdministratorClick
    end
  end
end
