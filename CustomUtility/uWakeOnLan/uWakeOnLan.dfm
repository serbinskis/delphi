object WakeOnLan: TWakeOnLan
  Left = 192
  Top = 125
  BorderStyle = bsDialog
  Caption = 'Wake On Lan'
  ClientHeight = 165
  ClientWidth = 220
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Calibri'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object Edit2: TEdit
    Left = 88
    Top = 40
    Width = 121
    Height = 23
    TabOrder = 0
    OnChange = EditChange
    OnEnter = EditEnter
    OnExit = EditExit
    OnKeyPress = EditKeyPress
  end
  object Edit3: TEdit
    Left = 88
    Top = 72
    Width = 121
    Height = 23
    TabOrder = 1
    OnChange = EditChange
    OnEnter = EditEnter
    OnExit = EditExit
    OnKeyPress = EditKeyPress
  end
  object Edit4: TEdit
    Left = 88
    Top = 104
    Width = 121
    Height = 23
    TabOrder = 2
    OnChange = EditChange
    OnEnter = EditEnter
    OnExit = EditExit
    OnKeyPress = EditKeyPress
  end
  object Edit5: TEdit
    Left = 88
    Top = 136
    Width = 121
    Height = 23
    TabOrder = 3
    OnChange = Edit5Change
    OnEnter = EditEnter
    OnExit = EditExit
  end
  object StaticText2: TStaticText
    Left = 8
    Top = 43
    Width = 65
    Height = 19
    Caption = 'IP Address:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
  end
  object StaticText3: TStaticText
    Left = 8
    Top = 75
    Width = 78
    Height = 19
    Caption = 'IPv4 Address:'
    TabOrder = 5
  end
  object StaticText4: TStaticText
    Left = 8
    Top = 107
    Width = 78
    Height = 19
    Caption = 'Mac Address:'
    TabOrder = 6
  end
  object StaticText5: TStaticText
    Left = 8
    Top = 139
    Width = 30
    Height = 19
    Caption = 'Port:'
    TabOrder = 7
  end
  object Edit1: TEdit
    Left = 88
    Top = 8
    Width = 121
    Height = 23
    TabOrder = 8
    OnChange = EditChange
    OnKeyPress = EditKeyPress
  end
  object StaticText1: TStaticText
    Left = 8
    Top = 11
    Width = 38
    Height = 19
    Caption = 'Name:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 9
  end
  object PopupMenu1: TPopupMenu
    AutoHotkeys = maManual
    Left = 8
    Top = 8
    object AddNew1: TMenuItem
      Caption = 'Add New'
      OnClick = PopupItemClick
    end
    object Exit1: TMenuItem
      Caption = 'Exit'
      OnClick = PopupItemClick
    end
  end
end
