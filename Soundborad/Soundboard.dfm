object Form1: TForm1
  Left = 200
  Top = 123
  ActiveControl = CheckBox1
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Soundboard'
  ClientHeight = 760
  ClientWidth = 350
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Calibri'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object Image1: TImage
    Left = 8
    Top = 12
    Width = 25
    Height = 25
    Hint = 'Play'
    ParentShowHint = False
    ShowHint = True
    OnClick = Image1Click
    OnMouseDown = Image1MouseDown
    OnMouseUp = Image1MouseUp
  end
  object Image2: TImage
    Left = 40
    Top = 12
    Width = 25
    Height = 25
    Hint = 'Pause'
    ParentShowHint = False
    ShowHint = True
    OnClick = Image2Click
    OnMouseDown = Image2MouseDown
    OnMouseUp = Image2MouseUp
  end
  object Image3: TImage
    Left = 72
    Top = 12
    Width = 25
    Height = 25
    Hint = 'Stop'
    ParentShowHint = False
    ShowHint = True
    OnClick = Image3Click
    OnMouseDown = Image3MouseDown
    OnMouseUp = Image3MouseUp
  end
  object Image4: TImage
    Left = 112
    Top = 5
    Width = 16
    Height = 16
    Hint = 'First Device: Default'
    ParentShowHint = False
    ShowHint = True
  end
  object Image5: TImage
    Left = 112
    Top = 26
    Width = 16
    Height = 16
    Hint = 'Second Device: Disabled'
    ParentShowHint = False
    ShowHint = True
  end
  object TrackBar2: TXiTrackBar
    Left = 136
    Top = 20
    Width = 145
    Height = 28
    Hint = 'Volume: 100'
    BackColor = clWhite
    TickColor = clBlack
    DisabledTickColor = clSilver
    SlideBorderColor = clBlack
    SlideFaceColor = clWhite
    SlideGradColor = clWhite
    DisabledSlideBorderColor = 12500670
    DisabledSlideFaceColor = 14211288
    DisabledSlideGradColor = 15263976
    DisabledThumbBorderColor = 11908533
    DisabledThumbFaceColor = 15395562
    DisabledThumbGradColor = 13619151
    ThumbBorderColor = clBlack
    ThumbFaceColor = 14120960
    ThumbGradColor = 14120960
    OverThumbBorderColor = clBlack
    OverThumbFaceColor = 14120960
    OverThumbGradColor = 14120960
    DownThumbBorderColor = clBlack
    DownThumbFaceColor = 14120960
    DownThumbGradColor = 14120960
    SmoothCorners = False
    ColorScheme = csCustom
    Position = 0
    Min = 0
    Max = 10
    Frequency = 1
    TickStyle = tsNone
    TickMarks = tmBottomRight
    Orientation = trHorizontal
    BorderWidth = 3
    ParentShowHint = False
    ShowHint = True
    OnChange = TrackBar2Change
  end
  object TNTStringGrid1: TTntStringGrid
    Left = 8
    Top = 48
    Width = 335
    Height = 705
    Color = clWhite
    ColCount = 2
    Ctl3D = False
    DefaultColWidth = -1
    DefaultRowHeight = 20
    DefaultDrawing = False
    RowCount = 1
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    ParentCtl3D = False
    ParentFont = False
    PopupMenu = PopupMenu1
    ScrollBars = ssNone
    TabOrder = 0
    OnDblClick = TNTStringGrid1DblClick
    OnDrawCell = TNTStringGrid1DrawCell
    OnKeyDown = TNTStringGrid1KeyDown
    OnMouseMove = TNTStringGrid1MouseMove
    OnMouseWheelDown = TNTStringGrid1MouseWheelDown
    OnMouseWheelUp = TNTStringGrid1MouseWheelUp
    OnSelectCell = TNTStringGrid1SelectCell
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 0
    Height = 2
    Cursor = crSizeNS
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 1
    OnMouseDown = Panel1MouseDown
    OnMouseUp = Panel1MouseUp
  end
  object TrackBar1: TXiTrackBar
    Left = 136
    Top = -1
    Width = 145
    Height = 28
    Hint = 'Volume: 100'
    BackColor = clWhite
    TickColor = clBlack
    DisabledTickColor = clSilver
    SlideBorderColor = clBlack
    SlideFaceColor = clWhite
    SlideGradColor = clWhite
    DisabledSlideBorderColor = 12500670
    DisabledSlideFaceColor = 14211288
    DisabledSlideGradColor = 15263976
    DisabledThumbBorderColor = 11908533
    DisabledThumbFaceColor = 15395562
    DisabledThumbGradColor = 13619151
    ThumbBorderColor = clBlack
    ThumbFaceColor = 14120960
    ThumbGradColor = 14120960
    OverThumbBorderColor = clBlack
    OverThumbFaceColor = 14120960
    OverThumbGradColor = 14120960
    DownThumbBorderColor = clBlack
    DownThumbFaceColor = 14120960
    DownThumbGradColor = 14120960
    SmoothCorners = False
    ColorScheme = csCustom
    Position = 0
    Min = 0
    Max = 10
    Frequency = 1
    TickStyle = tsNone
    TickMarks = tmBottomRight
    Orientation = trHorizontal
    BorderWidth = 3
    ParentShowHint = False
    ShowHint = True
    OnChange = TrackBar1Change
  end
  object CheckBox1: TFlatCheckBox
    Left = 296
    Top = 4
    Width = 49
    Height = 17
    Caption = 'Loop'
    ColorDown = 15790320
    ColorBorder = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    TabStop = True
    OnClick = CheckBox1Click
  end
  object Panel2: TFlatPanel
    Left = 296
    Top = 25
    Width = 48
    Height = 18
    ParentColor = True
    ColorHighLight = clBlack
    ColorShadow = clBlack
    TabOrder = 5
  end
  object StaticText1: TStaticText
    Left = 304
    Top = 26
    Width = 38
    Height = 15
    Alignment = taRightJustify
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
  end
  object MainMenu1: TMainMenu
    Left = 16
    Top = 56
    object Open1: TMenuItem
      Caption = 'Open'
      OnClick = Open1Click
    end
    object Import1: TMenuItem
      Caption = 'Import'
      OnClick = Import1Click
    end
    object Export1: TMenuItem
      Caption = 'Export'
      OnClick = Export1Click
    end
    object Settings1: TMenuItem
      Caption = 'Settings'
      OnClick = Settings1Click
    end
    object Tools1: TMenuItem
      Caption = 'Tools'
      object SaveInArchive1: TMenuItem
        Caption = 'Save Audio In Archive'
        OnClick = SaveInArchive1Click
      end
      object SaveCurrentState1: TMenuItem
        Caption = 'Save Current State'
        OnClick = SaveCurrentState1Click
      end
      object ExitWithoutSave1: TMenuItem
        Caption = 'Exit Without Save'
        OnClick = ExitWithoutSave1Click
      end
    end
    object About1: TMenuItem
      Caption = 'About'
      OnClick = About1Click
    end
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 48
    Top = 56
    object MoveUp1: TMenuItem
      Caption = 'Move Up'
      OnClick = MoveUp1Click
    end
    object MoveDown1: TMenuItem
      Caption = 'Move Down'
      OnClick = MoveDown1Click
    end
    object MoveTo1: TMenuItem
      Caption = 'Move To'
      OnClick = MoveTo1Click
    end
    object Favorite1: TMenuItem
      Caption = 'Favorite'
      OnClick = Favorite1Click
    end
    object Delete1: TMenuItem
      Caption = 'Delete'
      object FromList1: TMenuItem
        Caption = 'From List'
        OnClick = FromList1Click
      end
      object FromListFile1: TMenuItem
        Caption = 'From List + File'
        OnClick = FromListFile1Click
      end
    end
    object ChangeName1: TMenuItem
      Caption = 'Rename'
      OnClick = ChangeName1Click
    end
    object Location1: TMenuItem
      Caption = 'Location'
      OnClick = Location1Click
    end
    object ConvertToMemory1: TMenuItem
      Caption = 'Convert To Memory'
      OnClick = ConvertToMemory1Click
    end
    object ConvertToFile1: TMenuItem
      Caption = 'Convert To File'
      OnClick = ConvertToFile1Click
    end
    object MakeaCopyToFile1: TMenuItem
      Caption = 'Make a Copy To File'
      OnClick = MakeaCopyToFile1Click
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 20
    OnTimer = Timer1Timer
    Left = 80
    Top = 56
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 250
    OnTimer = Timer2Timer
    Left = 112
    Top = 56
  end
end
