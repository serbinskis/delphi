object Form1: TForm1
  Left = 192
  Top = 123
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsNone
  Caption = 'Clipboard History'
  ClientHeight = 495
  ClientWidth = 560
  Color = clWhite
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Calibri'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object Shape1: TShape
    Left = 0
    Top = 0
    Width = 560
    Height = 33
    OnMouseDown = Shape1MouseDown
  end
  object TNTStringGrid1: TTntStringGrid
    Left = 0
    Top = 32
    Width = 560
    Height = 463
    Color = clWhite
    ColCount = 6
    Ctl3D = False
    DefaultColWidth = -1
    DefaultRowHeight = 21
    DefaultDrawing = False
    RowCount = 1
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected]
    ParentCtl3D = False
    ParentFont = False
    ScrollBars = ssNone
    TabOrder = 0
    OnDblClick = TNTStringGrid1DblClick
    OnDrawCell = TNTStringGrid1DrawCell
    OnExit = TNTStringGrid1Exit
    OnKeyDown = TNTStringGrid1KeyDown
    OnMouseMove = TNTStringGrid1MouseMove
    OnMouseUp = TNTStringGrid1MouseUp
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
  end
  object StaticText1: TStaticText
    Left = 4
    Top = 8
    Width = 78
    Height = 19
    Caption = 'Total items: 0'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object TNTEdit1: TTntEdit
    Left = 432
    Top = 6
    Width = 121
    Height = 21
    Hint = 'Search'
    Ctl3D = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 3
    OnKeyUp = TNTEdit1KeyUp
  end
  object StaticText2: TStaticText
    Left = 224
    Top = 248
    Width = 127
    Height = 27
    Caption = 'The list is empty'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    Visible = False
  end
  object StaticText3: TStaticText
    Left = 340
    Top = 8
    Width = 78
    Height = 19
    Alignment = taRightJustify
    AutoSize = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    OnClick = StaticText3Click
  end
  object PopupMenu1: TPopupMenu
    Left = 8
    Top = 40
    object Open1: TMenuItem
      Caption = 'Open'
      OnClick = Open1Click
    end
    object Settings1: TMenuItem
      Caption = 'Settings'
      OnClick = Settings1Click
    end
    object About1: TMenuItem
      Caption = 'About'
      OnClick = About1Click
    end
    object Restart1: TMenuItem
      Caption = 'Restart'
      OnClick = Restart1Click
    end
    object Exit1: TMenuItem
      Caption = 'Exit'
      OnClick = Exit1Click
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 1500
    OnTimer = Timer1Timer
    Left = 72
    Top = 40
  end
  object Timer2: TTimer
    Enabled = False
    OnTimer = Timer2Timer
    Left = 104
    Top = 40
  end
  object Timer3: TTimer
    Enabled = False
    Interval = 0
    OnTimer = Timer3Timer
    Left = 136
    Top = 40
  end
  object Timer4: TTimer
    Enabled = False
    Interval = 10
    OnTimer = Timer4Timer
    Left = 168
    Top = 40
  end
  object TrayIcon1: TTrayIcon
    OnAction = TrayIcon1Action
    Left = 40
    Top = 40
  end
  object PopupMenu2: TPopupMenu
    Left = 8
    Top = 72
    object Favorite1: TMenuItem
      Caption = 'Operation'
      object Copy1: TMenuItem
        Caption = 'Copy'
        OnClick = Copy1Click
      end
      object Delete1: TMenuItem
        Caption = 'Delete'
        OnClick = Delete1Click
      end
      object Favorite2: TMenuItem
        Caption = 'Favorite'
        OnClick = Favorite2Click
      end
    end
    object Show1: TMenuItem
      Caption = 'Show'
      object ShowFavorites1: TMenuItem
        Caption = 'Show Favorites'
        OnClick = ShowFavorites1Click
      end
      object ShowBySize1: TMenuItem
        Caption = 'Show By Size'
        OnClick = ShowBySize1Click
      end
    end
  end
end
