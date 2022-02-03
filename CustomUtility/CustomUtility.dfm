object Form1: TForm1
  Left = 192
  Top = 125
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'CustomUtility'
  ClientHeight = 415
  ClientWidth = 775
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 777
    Height = 417
    ActivePage = Others
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Zero Wipe'
      object TNTListBox1: TTntListBox
        Left = 0
        Top = 2
        Width = 767
        Height = 385
        Ctl3D = False
        Enabled = False
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ItemHeight = 15
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 1
        OnKeyDown = TNTListBoxKeyDown
      end
      object StaticText1: TStaticText
        Left = 312
        Top = 183
        Width = 142
        Height = 19
        Alignment = taCenter
        Caption = 'Drop files or folders here'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Remove Diacritics'
      ImageIndex = 1
      object TNTListBox2: TTntListBox
        Left = 0
        Top = 2
        Width = 767
        Height = 385
        Ctl3D = False
        Enabled = False
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ItemHeight = 15
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 0
        OnKeyDown = TNTListBoxKeyDown
      end
      object StaticText2: TStaticText
        Left = 312
        Top = 183
        Width = 142
        Height = 19
        Alignment = taCenter
        Caption = 'Drop files or folders here'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Compress Images'
      ImageIndex = 2
      object TNTListBox3: TTntListBox
        Left = 0
        Top = 2
        Width = 767
        Height = 385
        Ctl3D = False
        Enabled = False
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ItemHeight = 15
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 0
        OnKeyDown = TNTListBoxKeyDown
      end
      object StaticText3: TStaticText
        Left = 312
        Top = 183
        Width = 142
        Height = 19
        Alignment = taCenter
        Caption = 'Drop files or folders here'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object FlatSpinEdit1: TFlatSpinEditInteger
        Left = 704
        Top = 8
        Width = 57
        Height = 21
        ColorBorder = clBlack
        ColorFlat = clWindow
        AutoSize = False
        MaxValue = 100
        MinValue = 1
        ParentColor = True
        TabOrder = 2
        Value = 70
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Replace Text'
      ImageIndex = 3
      object TNTEdit1: TTntEdit
        Left = 0
        Top = 0
        Width = 380
        Height = 23
        Hint = 'Text To Replace'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object TNTEdit2: TTntEdit
        Left = 386
        Top = 0
        Width = 380
        Height = 23
        Hint = 'Text To Replace With'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object TNTListBox4: TTntListBox
        Left = 0
        Top = 28
        Width = 767
        Height = 359
        Ctl3D = False
        Enabled = False
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ItemHeight = 15
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 2
        OnKeyDown = TNTListBoxKeyDown
      end
      object StaticText4: TStaticText
        Left = 312
        Top = 183
        Width = 142
        Height = 19
        Alignment = taCenter
        Caption = 'Drop files or folders here'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
      end
    end
    object TabSheet5: TTabSheet
      Caption = 'Zero Rename'
      ImageIndex = 4
      object TNTListBox5: TTntListBox
        Left = 0
        Top = 2
        Width = 767
        Height = 385
        Ctl3D = False
        Enabled = False
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ItemHeight = 15
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 0
        OnKeyDown = TNTListBoxKeyDown
      end
      object StaticText5: TStaticText
        Left = 312
        Top = 183
        Width = 142
        Height = 19
        Alignment = taCenter
        Caption = 'Drop files or folders here'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
    end
    object TabSheet6: TTabSheet
      Caption = 'Trace Application'
      ImageIndex = 5
      object TNTListBox6: TTntListBox
        Left = 0
        Top = 2
        Width = 767
        Height = 385
        Ctl3D = False
        Enabled = False
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ItemHeight = 15
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 0
        OnKeyDown = TNTListBoxKeyDown
      end
      object StaticText6: TStaticText
        Left = 320
        Top = 183
        Width = 120
        Height = 19
        Alignment = taCenter
        Caption = 'Drop executable here'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
    end
    object Others: TTabSheet
      Caption = 'Others'
      ImageIndex = 7
      object Button1: TButton
        Left = 8
        Top = 8
        Width = 89
        Height = 25
        Caption = 'Wake On Lan'
        TabOrder = 0
        OnClick = Button1Click
      end
      object Button2: TButton
        Left = 104
        Top = 8
        Width = 89
        Height = 25
        Caption = 'Crypto Graph'
        TabOrder = 1
        OnClick = Button2Click
      end
    end
  end
  object Timer1: TTimer
    Interval = 10
    OnTimer = Timer1Timer
    Left = 732
    Top = 377
  end
end
