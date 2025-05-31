object Form4: TForm4
  Left = 1083
  Top = 125
  BorderStyle = bsDialog
  Caption = 'Advanced Fan Speeds'
  ClientHeight = 531
  ClientWidth = 434
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'Calibri'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClick = FormClick
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 35
    Height = 18
    Caption = 'FAN 1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'Calibri'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Image1: TImage
    Left = 16
    Top = 224
    Width = 400
    Height = 3
    AutoSize = True
    Picture.Data = {
      0A544A504547496D61676572070000FFD8FFE000104A46494600010101006000
      600000FFE100664578696600004D4D002A000000080004011A00050000000100
      00003E011B000500000001000000460128000300000001000200000131000200
      0000100000004E00000000000000600000000100000060000000015061696E74
      2E4E455420352E312E3700FFDB00430001010101010101010101010101010101
      0101010101010101010101010101010101010101010101010101010101010101
      01010101010101010101010101010101FFDB0043010101010101010101010101
      0101010101010101010101010101010101010101010101010101010101010101
      010101010101010101010101010101010101010101FFC0001108000301900301
      1200021101031101FFC4001F0000010501010101010100000000000000000102
      030405060708090A0BFFC400B5100002010303020403050504040000017D0102
      0300041105122131410613516107227114328191A1082342B1C11552D1F02433
      627282090A161718191A25262728292A3435363738393A434445464748494A53
      5455565758595A636465666768696A737475767778797A838485868788898A92
      939495969798999AA2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7
      C8C9CAD2D3D4D5D6D7D8D9DAE1E2E3E4E5E6E7E8E9EAF1F2F3F4F5F6F7F8F9FA
      FFC4001F0100030101010101010101010000000000000102030405060708090A
      0BFFC400B5110002010204040304070504040001027700010203110405213106
      1241510761711322328108144291A1B1C109233352F0156272D10A162434E125
      F11718191A262728292A35363738393A434445464748494A535455565758595A
      636465666768696A737475767778797A82838485868788898A92939495969798
      999AA2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4
      D5D6D7D8D9DAE2E3E4E5E6E7E8E9EAF2F3F4F5F6F7F8F9FAFFDA000C03010002
      110311003F00F9A348FE0FA49FCCD15FF5258CF81FF8A3F91FF3455BE0F9A3D0
      74CFB8BFF5CDBFF431457CD62F77FE35F933CFADF03F547A2699F7C7F9FE34A2
      BE6313F0BFF0BFCA479F53E197AFFEDA7A1699F713FDD7FF00D0CD15F318BDE5
      EB1FC91C33DBE7FA33D174BFE0FF00707FE81457CD62F69FF89FFE948F367BFC
      BF567A369BD53E87FA515F318BF8DFAFF99C157E17FD7467A1E964E62FF79BFF
      0040A2BE6F17F054F4FF00DB8E0A9F04BD0F45D179DB9ECF263DB0A0FF00327D
      CD15F338CDBE51FCD9E6CF75E87A0E9BF707FBA7FF00433457CD62FE2FFB79FE
      47156F8BFAEC8F48D33A0FF7BFF654A2BE5717FF00B6FF00F2479F57AFF8BFCC
      EFEC7FD5FF00C03FF67A2BE6719F6FE7FA1CB0FE22FF0013FD4B4FD3F1FF001A
      2BE5719F14BFAE8CFA8CBB68FF00D7B7FF00A5A299EA7EA7F9D15F358CD9FA3F
      CCFB4CBF65FE25FF00A4A29BF6FA37F2A2BE5B1DF0CFFC32FCCFBECB7EC7F8A9
      7E8547FBC7F0A2BE6EBFC32FF0FEA7D9E07E3A7FE32ABFF17FC0BFAD15F2F8E7
      EF4BFC32FC8FB9CBB75FF6E7FE94527EBF87F53457CBE33AFF00DBA7DA65DBC3
      FC53FF00D21959BB7FBA28AF99C56F53E7FF00A533ED707BC7D63F9144FDE3FE
      F2FF0023457CE62779FABFC99F7184DA1FF5EA3FFB695E4EDF8FF4A2BE6B11D3
      FC4CFB3CBFEDFF00861FA94DBF8BDB77AD15F2B88F897CFF0033EDF03B3F587E
      4547E9F8FF008D15E063375FE07FA9F6382F8BFEDE8FE68ACFFE1FFB3515F318
      AFB5FE147DA60B7A7E7535FF00C0A05493AB7D3FA515F358CFB4FAD9EBE8F4FB
      8FB1C06F0FF1AFCCA6FD547BFF008515F3D8BF86FD7FE048FB3C17F0D7F8BFF6
      E6546FFD99BB7D28AF9BC5FC3FF6F7EA7DA60BF88BFC3FA32BBFDE3F87F21457
      CF62DFF13D3FF6C3EBF2FDE9FAAFCD15E4EFFEEFF8D15F3D88FF00DB59F6383F
      863FF5F3F58951B953F4FF00EBFF003A2BE7715F1CBE5F99F55827EEC3FC4FF3
      6557E9F8FF0043457CFE2FE2FF00B79FE47D865BF02FF0CBFF004B653EC7EA3F
      AD15E062B687ABFD0FAEC2FC52FF000FEA88A4EDF8FF004A2BE7711B7FDBFF00
      E67D7E0F77FE05FA155FEF1FF3DA8AF1AB7C53F9FE47D3611FBB4FD3FF006E2A
      1E87E87F9515E257DE3E8FF33E9707F14BFEDDFCC87B0FA9FE428AF0EAEDF291
      F5384DA7EABF2646FD3F1FE868AF1EB7C1F347D0D0F8DFF85FE68CE9FEEB7FBD
      FD68AC297F123F3FFD259EE61F7A7FE1FF00DB0E7EE7BFFD743FFB3515EB52E9
      FE1FF23DEA1F0C7FC3FA9CD5D7FAB1FEF8FF00D05A8AF6F0FBFF00DB9FAC4F77
      0FBFFDB9FAC4E76E7EECBF53FF00A1515EB51F8A1E9FFB6B3DBC3FFCBBF91CF5
      DFDDFF00809FE7457AD87F897ACBFF00493DCC36DFF6F3FF00D251CDDD7FF17F
      D28AF6E8F4FF00B74F6B0FD7FC28E76E3B7FBA68AF5F0FB7FDBFFA44F730FD7F
      C48E6E6FB87FDD6FE5457B54B7F9C7F33DCA3F1AFF00147F3302EFEE9FAFFECA
      68AF5686F1FEBED1EE50DE3FD7DA397B9FBF27D47F4A2BDBA1F0C3D7FF006E67
      BD87FF00976615D7DD97FCF71457B586DA9FABFCD9ECD0DE1EBFAB39BB9FBDF9
      7F23457B1477F9BFC8F770DF0FDFF9A39DB8FBE3F1FE7457AB4FAFCBF53DBA1B
      4BD57E473773DFFEBA1FFD9A8AF670FBFF00DB9FAC4F7F0FF043FEBDC7F247FF
      D9}
  end
  object Bevel1: TCustoBevel
    Left = 16
    Top = 31
    Width = 400
    Height = 1
    Shape = bsFrame
    Color = clBlack
  end
  object Label2: TLabel
    Left = 24
    Top = 48
    Width = 32
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = '100%'
  end
  object TntLabel1: TTntLabel
    Left = 8
    Top = 232
    Width = 25
    Height = 26
    Caption = #10052#65039
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -21
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
  end
  object TntLabel2: TTntLabel
    Left = 400
    Top = 232
    Width = 21
    Height = 26
    Caption = #55357#56613
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -21
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 176
    Top = 48
    Width = 32
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = '100%'
  end
  object Label4: TLabel
    Left = 208
    Top = 48
    Width = 32
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = '100%'
  end
  object Label5: TLabel
    Left = 240
    Top = 48
    Width = 32
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = '100%'
  end
  object Label6: TLabel
    Left = 272
    Top = 48
    Width = 32
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = '100%'
  end
  object Label7: TLabel
    Left = 304
    Top = 48
    Width = 32
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = '100%'
  end
  object Label8: TLabel
    Left = 16
    Top = 272
    Width = 35
    Height = 18
    Caption = 'FAN 2'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'Calibri'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Image2: TImage
    Left = 16
    Top = 488
    Width = 400
    Height = 3
    AutoSize = True
    Picture.Data = {
      0A544A504547496D61676572070000FFD8FFE000104A46494600010101006000
      600000FFE100664578696600004D4D002A000000080004011A00050000000100
      00003E011B000500000001000000460128000300000001000200000131000200
      0000100000004E00000000000000600000000100000060000000015061696E74
      2E4E455420352E312E3700FFDB00430001010101010101010101010101010101
      0101010101010101010101010101010101010101010101010101010101010101
      01010101010101010101010101010101FFDB0043010101010101010101010101
      0101010101010101010101010101010101010101010101010101010101010101
      010101010101010101010101010101010101010101FFC0001108000301900301
      1200021101031101FFC4001F0000010501010101010100000000000000000102
      030405060708090A0BFFC400B5100002010303020403050504040000017D0102
      0300041105122131410613516107227114328191A1082342B1C11552D1F02433
      627282090A161718191A25262728292A3435363738393A434445464748494A53
      5455565758595A636465666768696A737475767778797A838485868788898A92
      939495969798999AA2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7
      C8C9CAD2D3D4D5D6D7D8D9DAE1E2E3E4E5E6E7E8E9EAF1F2F3F4F5F6F7F8F9FA
      FFC4001F0100030101010101010101010000000000000102030405060708090A
      0BFFC400B5110002010204040304070504040001027700010203110405213106
      1241510761711322328108144291A1B1C109233352F0156272D10A162434E125
      F11718191A262728292A35363738393A434445464748494A535455565758595A
      636465666768696A737475767778797A82838485868788898A92939495969798
      999AA2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4
      D5D6D7D8D9DAE2E3E4E5E6E7E8E9EAF2F3F4F5F6F7F8F9FAFFDA000C03010002
      110311003F00F9A348FE0FA49FCCD15FF5258CF81FF8A3F91FF3455BE0F9A3D0
      74CFB8BFF5CDBFF431457CD62F77FE35F933CFADF03F547A2699F7C7F9FE34A2
      BE6313F0BFF0BFCA479F53E197AFFEDA7A1699F713FDD7FF00D0CD15F318BDE5
      EB1FC91C33DBE7FA33D174BFE0FF00707FE81457CD62F69FF89FFE948F367BFC
      BF567A369BD53E87FA515F318BF8DFAFF99C157E17FD7467A1E964E62FF79BFF
      0040A2BE6F17F054F4FF00DB8E0A9F04BD0F45D179DB9ECF263DB0A0FF00327D
      CD15F338CDBE51FCD9E6CF75E87A0E9BF707FBA7FF00433457CD62FE2FFB79FE
      47156F8BFAEC8F48D33A0FF7BFF654A2BE5717FF00B6FF00F2479F57AFF8BFCC
      EFEC7FD5FF00C03FF67A2BE6719F6FE7FA1CB0FE22FF0013FD4B4FD3F1FF001A
      2BE5719F14BFAE8CFA8CBB68FF00D7B7FF00A5A299EA7EA7F9D15F358CD9FA3F
      CCFB4CBF65FE25FF00A4A29BF6FA37F2A2BE5B1DF0CFFC32FCCFBECB7EC7F8A9
      7E8547FBC7F0A2BE6EBFC32FF0FEA7D9E07E3A7FE32ABFF17FC0BFAD15F2F8E7
      EF4BFC32FC8FB9CBB75FF6E7FE94527EBF87F53457CBE33AFF00DBA7DA65DBC3
      FC53FF00D21959BB7FBA28AF99C56F53E7FF00A533ED707BC7D63F9144FDE3FE
      F2FF0023457CE62779FABFC99F7184DA1FF5EA3FFB695E4EDF8FF4A2BE6B11D3
      FC4CFB3CBFEDFF00861FA94DBF8BDB77AD15F2B88F897CFF0033EDF03B3F587E
      4547E9F8FF008D15E063375FE07FA9F6382F8BFEDE8FE68ACFFE1FFB3515F318
      AFB5FE147DA60B7A7E7535FF00C0A05493AB7D3FA515F358CFB4FAD9EBE8F4FB
      8FB1C06F0FF1AFCCA6FD547BFF008515F3D8BF86FD7FE048FB3C17F0D7F8BFF6
      E6546FFD99BB7D28AF9BC5FC3FF6F7EA7DA60BF88BFC3FA32BBFDE3F87F21457
      CF62DFF13D3FF6C3EBF2FDE9FAAFCD15E4EFFEEFF8D15F3D88FF00DB59F6383F
      863FF5F3F58951B953F4FF00EBFF003A2BE7715F1CBE5F99F55827EEC3FC4FF3
      6557E9F8FF0043457CFE2FE2FF00B79FE47D865BF02FF0CBFF004B653EC7EA3F
      AD15E062B687ABFD0FAEC2FC52FF000FEA88A4EDF8FF004A2BE7711B7FDBFF00
      E67D7E0F77FE05FA155FEF1FF3DA8AF1AB7C53F9FE47D3611FBB4FD3FF006E2A
      1E87E87F9515E257DE3E8FF33E9707F14BFEDDFCC87B0FA9FE428AF0EAEDF291
      F5384DA7EABF2646FD3F1FE868AF1EB7C1F347D0D0F8DFF85FE68CE9FEEB7FBD
      FD68AC297F123F3FFD259EE61F7A7FE1FF00DB0E7EE7BFFD743FFB3515EB52E9
      FE1FF23DEA1F0C7FC3FA9CD5D7FAB1FEF8FF00D05A8AF6F0FBFF00DB9FAC4F77
      0FBFFDB9FAC4E76E7EECBF53FF00A1515EB51F8A1E9FFB6B3DBC3FFCBBF91CF5
      DFDDFF00809FE7457AD87F897ACBFF00493DCC36DFF6F3FF00D251CDDD7FF17F
      D28AF6E8F4FF00B74F6B0FD7FC28E76E3B7FBA68AF5F0FB7FDBFFA44F730FD7F
      C48E6E6FB87FDD6FE5457B54B7F9C7F33DCA3F1AFF00147F3302EFEE9FAFFECA
      68AF5686F1FEBED1EE50DE3FD7DA397B9FBF27D47F4A2BDBA1F0C3D7FF006E67
      BD87FF00976615D7DD97FCF71457B586DA9FABFCD9ECD0DE1EBFAB39BB9FBDF9
      7F23457B1477F9BFC8F770DF0FDFF9A39DB8FBE3F1FE7457AB4FAFCBF53DBA1B
      4BD57E473773DFFEBA1FFD9A8AF670FBFF00DB9FAC4F7F0FF043FEBDC7F247FF
      D9}
  end
  object CustoBevel1: TCustoBevel
    Left = 16
    Top = 295
    Width = 400
    Height = 1
    Shape = bsFrame
    Color = clBlack
  end
  object Label9: TLabel
    Left = 24
    Top = 312
    Width = 32
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = '100%'
  end
  object TntLabel3: TTntLabel
    Left = 8
    Top = 496
    Width = 25
    Height = 26
    Caption = #10052#65039
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -21
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
  end
  object TntLabel4: TTntLabel
    Left = 400
    Top = 496
    Width = 21
    Height = 26
    Caption = #55357#56613
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -21
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
  end
  object Label10: TLabel
    Left = 176
    Top = 312
    Width = 32
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = '100%'
  end
  object Label11: TLabel
    Left = 208
    Top = 312
    Width = 32
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = '100%'
  end
  object Label12: TLabel
    Left = 240
    Top = 312
    Width = 32
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = '100%'
  end
  object Label13: TLabel
    Left = 272
    Top = 312
    Width = 32
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = '100%'
  end
  object Label14: TLabel
    Left = 304
    Top = 312
    Width = 32
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = '100%'
  end
  object TrackBar1: TXiTrackBar
    Left = 24
    Top = 72
    Width = 33
    Height = 150
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
    SmoothCorners = True
    ColorScheme = csCustom
    Position = 0
    Min = 0
    Max = 150
    Frequency = 1
    TickStyle = tsNone
    TickMarks = tmBottomRight
    Orientation = trVertical
    BorderWidth = 7
    ParentShowHint = False
    ShowHint = True
    OnChange = TrackBar1Change
    OnMouseUp = TrackBar1MouseUp
  end
  object TrackBar4: TXiTrackBar
    Left = 240
    Top = 72
    Width = 33
    Height = 150
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
    SmoothCorners = True
    ColorScheme = csCustom
    Position = 0
    Min = 0
    Max = 150
    Frequency = 1
    TickStyle = tsNone
    TickMarks = tmBottomRight
    Orientation = trVertical
    BorderWidth = 7
    ParentShowHint = False
    ShowHint = True
    OnChange = TrackBar4Change
    OnMouseUp = TrackBar4MouseUp
  end
  object TrackBar5: TXiTrackBar
    Left = 272
    Top = 72
    Width = 33
    Height = 150
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
    SmoothCorners = True
    ColorScheme = csCustom
    Position = 0
    Min = 0
    Max = 150
    Frequency = 1
    TickStyle = tsNone
    TickMarks = tmBottomRight
    Orientation = trVertical
    BorderWidth = 7
    ParentShowHint = False
    ShowHint = True
    OnChange = TrackBar5Change
    OnMouseUp = TrackBar5MouseUp
  end
  object TrackBar6: TXiTrackBar
    Left = 304
    Top = 72
    Width = 33
    Height = 150
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
    SmoothCorners = True
    ColorScheme = csCustom
    Position = 0
    Min = 0
    Max = 150
    Frequency = 1
    TickStyle = tsNone
    TickMarks = tmBottomRight
    Orientation = trVertical
    BorderWidth = 7
    ParentShowHint = False
    ShowHint = True
    OnChange = TrackBar6Change
    OnMouseUp = TrackBar6MouseUp
  end
  object XiPanel1: TXiPanel
    Left = 16
    Top = 68
    Width = 2
    Height = 156
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 4
    UseDockManager = True
  end
  object XiPanel2: TXiPanel
    Left = 414
    Top = 68
    Width = 2
    Height = 156
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 5
    UseDockManager = True
  end
  object XiPanel3: TXiPanel
    Left = 16
    Top = 68
    Width = 400
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 6
    UseDockManager = True
  end
  object XiPanel4: TXiPanel
    Left = 16
    Top = 97
    Width = 18
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 9
    UseDockManager = True
  end
  object TrackBar2: TXiTrackBar
    Left = 176
    Top = 72
    Width = 33
    Height = 150
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
    SmoothCorners = True
    ColorScheme = csCustom
    Position = 0
    Min = 0
    Max = 150
    Frequency = 1
    TickStyle = tsNone
    TickMarks = tmBottomRight
    Orientation = trVertical
    BorderWidth = 7
    ParentShowHint = False
    ShowHint = True
    OnChange = TrackBar2Change
    OnMouseUp = TrackBar2MouseUp
  end
  object TrackBar3: TXiTrackBar
    Left = 208
    Top = 72
    Width = 33
    Height = 150
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
    SmoothCorners = True
    ColorScheme = csCustom
    Position = 0
    Min = 0
    Max = 150
    Frequency = 1
    TickStyle = tsNone
    TickMarks = tmBottomRight
    Orientation = trVertical
    BorderWidth = 7
    ParentShowHint = False
    ShowHint = True
    OnChange = TrackBar3Change
    OnMouseUp = TrackBar3MouseUp
  end
  object XiPanel5: TXiPanel
    Left = 47
    Top = 97
    Width = 139
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 10
    UseDockManager = True
  end
  object XiPanel6: TXiPanel
    Left = 199
    Top = 97
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 11
    UseDockManager = True
  end
  object XiPanel7: TXiPanel
    Left = 231
    Top = 97
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 12
    UseDockManager = True
  end
  object XiPanel8: TXiPanel
    Left = 263
    Top = 97
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 13
    UseDockManager = True
  end
  object XiPanel9: TXiPanel
    Left = 295
    Top = 97
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 14
    UseDockManager = True
  end
  object XiPanel10: TXiPanel
    Left = 327
    Top = 97
    Width = 88
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 15
    UseDockManager = True
  end
  object XiPanel11: TXiPanel
    Left = 327
    Top = 129
    Width = 88
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 16
    UseDockManager = True
  end
  object XiPanel12: TXiPanel
    Left = 295
    Top = 129
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 17
    UseDockManager = True
  end
  object XiPanel13: TXiPanel
    Left = 263
    Top = 129
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 18
    UseDockManager = True
  end
  object XiPanel14: TXiPanel
    Left = 231
    Top = 129
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 19
    UseDockManager = True
  end
  object XiPanel15: TXiPanel
    Left = 199
    Top = 129
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 20
    UseDockManager = True
  end
  object XiPanel16: TXiPanel
    Left = 47
    Top = 129
    Width = 139
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 21
    UseDockManager = True
  end
  object XiPanel17: TXiPanel
    Left = 16
    Top = 129
    Width = 18
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 22
    UseDockManager = True
  end
  object XiPanel18: TXiPanel
    Left = 327
    Top = 161
    Width = 88
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 23
    UseDockManager = True
  end
  object XiPanel19: TXiPanel
    Left = 16
    Top = 161
    Width = 18
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 24
    UseDockManager = True
  end
  object XiPanel20: TXiPanel
    Left = 47
    Top = 161
    Width = 139
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 25
    UseDockManager = True
  end
  object XiPanel21: TXiPanel
    Left = 199
    Top = 161
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 26
    UseDockManager = True
  end
  object XiPanel22: TXiPanel
    Left = 231
    Top = 161
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 27
    UseDockManager = True
  end
  object XiPanel23: TXiPanel
    Left = 263
    Top = 161
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 28
    UseDockManager = True
  end
  object XiPanel24: TXiPanel
    Left = 295
    Top = 161
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 29
    UseDockManager = True
  end
  object XiPanel25: TXiPanel
    Left = 327
    Top = 193
    Width = 88
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 30
    UseDockManager = True
  end
  object XiPanel26: TXiPanel
    Left = 16
    Top = 193
    Width = 18
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 31
    UseDockManager = True
  end
  object XiPanel27: TXiPanel
    Left = 47
    Top = 193
    Width = 139
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 32
    UseDockManager = True
  end
  object XiPanel28: TXiPanel
    Left = 199
    Top = 193
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 33
    UseDockManager = True
  end
  object XiPanel29: TXiPanel
    Left = 231
    Top = 193
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 34
    UseDockManager = True
  end
  object XiPanel30: TXiPanel
    Left = 263
    Top = 193
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 35
    UseDockManager = True
  end
  object XiPanel31: TXiPanel
    Left = 295
    Top = 193
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 36
    UseDockManager = True
  end
  object TrackBar7: TXiTrackBar
    Left = 24
    Top = 336
    Width = 33
    Height = 150
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
    SmoothCorners = True
    ColorScheme = csCustom
    Position = 0
    Min = 0
    Max = 150
    Frequency = 1
    TickStyle = tsNone
    TickMarks = tmBottomRight
    Orientation = trVertical
    BorderWidth = 7
    ParentShowHint = False
    ShowHint = True
    OnChange = TrackBar7Change
    OnMouseUp = TrackBar7MouseUp
  end
  object TrackBar10: TXiTrackBar
    Left = 240
    Top = 336
    Width = 33
    Height = 150
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
    SmoothCorners = True
    ColorScheme = csCustom
    Position = 0
    Min = 0
    Max = 150
    Frequency = 1
    TickStyle = tsNone
    TickMarks = tmBottomRight
    Orientation = trVertical
    BorderWidth = 7
    ParentShowHint = False
    ShowHint = True
    OnChange = TrackBar10Change
    OnMouseUp = TrackBar10MouseUp
  end
  object TrackBar11: TXiTrackBar
    Left = 272
    Top = 336
    Width = 33
    Height = 150
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
    SmoothCorners = True
    ColorScheme = csCustom
    Position = 0
    Min = 0
    Max = 150
    Frequency = 1
    TickStyle = tsNone
    TickMarks = tmBottomRight
    Orientation = trVertical
    BorderWidth = 7
    ParentShowHint = False
    ShowHint = True
    OnChange = TrackBar11Change
    OnMouseUp = TrackBar11MouseUp
  end
  object TrackBar12: TXiTrackBar
    Left = 304
    Top = 336
    Width = 33
    Height = 150
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
    SmoothCorners = True
    ColorScheme = csCustom
    Position = 0
    Min = 0
    Max = 150
    Frequency = 1
    TickStyle = tsNone
    TickMarks = tmBottomRight
    Orientation = trVertical
    BorderWidth = 7
    ParentShowHint = False
    ShowHint = True
    OnChange = TrackBar12Change
    OnMouseUp = TrackBar12MouseUp
  end
  object XiPanel32: TXiPanel
    Left = 16
    Top = 332
    Width = 2
    Height = 156
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 41
    UseDockManager = True
  end
  object XiPanel33: TXiPanel
    Left = 414
    Top = 332
    Width = 2
    Height = 156
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 42
    UseDockManager = True
  end
  object XiPanel34: TXiPanel
    Left = 16
    Top = 332
    Width = 400
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 43
    UseDockManager = True
  end
  object XiPanel35: TXiPanel
    Left = 16
    Top = 361
    Width = 18
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 44
    UseDockManager = True
  end
  object TrackBar8: TXiTrackBar
    Left = 176
    Top = 336
    Width = 33
    Height = 150
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
    SmoothCorners = True
    ColorScheme = csCustom
    Position = 0
    Min = 0
    Max = 150
    Frequency = 1
    TickStyle = tsNone
    TickMarks = tmBottomRight
    Orientation = trVertical
    BorderWidth = 7
    ParentShowHint = False
    ShowHint = True
    OnChange = TrackBar8Change
    OnMouseUp = TrackBar8MouseUp
  end
  object TrackBar9: TXiTrackBar
    Left = 208
    Top = 336
    Width = 33
    Height = 150
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
    SmoothCorners = True
    ColorScheme = csCustom
    Position = 0
    Min = 0
    Max = 150
    Frequency = 1
    TickStyle = tsNone
    TickMarks = tmBottomRight
    Orientation = trVertical
    BorderWidth = 7
    ParentShowHint = False
    ShowHint = True
    OnChange = TrackBar9Change
    OnMouseUp = TrackBar9MouseUp
  end
  object XiPanel36: TXiPanel
    Left = 47
    Top = 361
    Width = 139
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 47
    UseDockManager = True
  end
  object XiPanel37: TXiPanel
    Left = 199
    Top = 361
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 48
    UseDockManager = True
  end
  object XiPanel38: TXiPanel
    Left = 231
    Top = 361
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 49
    UseDockManager = True
  end
  object XiPanel39: TXiPanel
    Left = 263
    Top = 361
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 50
    UseDockManager = True
  end
  object XiPanel40: TXiPanel
    Left = 295
    Top = 361
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 51
    UseDockManager = True
  end
  object XiPanel41: TXiPanel
    Left = 327
    Top = 361
    Width = 88
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 52
    UseDockManager = True
  end
  object XiPanel42: TXiPanel
    Left = 327
    Top = 393
    Width = 88
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 53
    UseDockManager = True
  end
  object XiPanel43: TXiPanel
    Left = 295
    Top = 393
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 54
    UseDockManager = True
  end
  object XiPanel44: TXiPanel
    Left = 263
    Top = 393
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 55
    UseDockManager = True
  end
  object XiPanel45: TXiPanel
    Left = 231
    Top = 393
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 56
    UseDockManager = True
  end
  object XiPanel46: TXiPanel
    Left = 199
    Top = 393
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 57
    UseDockManager = True
  end
  object XiPanel47: TXiPanel
    Left = 47
    Top = 393
    Width = 139
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 58
    UseDockManager = True
  end
  object XiPanel48: TXiPanel
    Left = 16
    Top = 393
    Width = 18
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 59
    UseDockManager = True
  end
  object XiPanel49: TXiPanel
    Left = 327
    Top = 425
    Width = 88
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 60
    UseDockManager = True
  end
  object XiPanel50: TXiPanel
    Left = 16
    Top = 425
    Width = 18
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 61
    UseDockManager = True
  end
  object XiPanel51: TXiPanel
    Left = 47
    Top = 425
    Width = 139
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 62
    UseDockManager = True
  end
  object XiPanel52: TXiPanel
    Left = 199
    Top = 425
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 63
    UseDockManager = True
  end
  object XiPanel53: TXiPanel
    Left = 231
    Top = 425
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 64
    UseDockManager = True
  end
  object XiPanel54: TXiPanel
    Left = 263
    Top = 425
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 65
    UseDockManager = True
  end
  object XiPanel55: TXiPanel
    Left = 295
    Top = 425
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 66
    UseDockManager = True
  end
  object XiPanel56: TXiPanel
    Left = 327
    Top = 457
    Width = 88
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 67
    UseDockManager = True
  end
  object XiPanel57: TXiPanel
    Left = 16
    Top = 457
    Width = 18
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 68
    UseDockManager = True
  end
  object XiPanel58: TXiPanel
    Left = 47
    Top = 457
    Width = 139
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 69
    UseDockManager = True
  end
  object XiPanel59: TXiPanel
    Left = 199
    Top = 457
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 70
    UseDockManager = True
  end
  object XiPanel60: TXiPanel
    Left = 231
    Top = 457
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 71
    UseDockManager = True
  end
  object XiPanel61: TXiPanel
    Left = 263
    Top = 457
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 72
    UseDockManager = True
  end
  object XiPanel62: TXiPanel
    Left = 295
    Top = 457
    Width = 19
    Height = 2
    ColorFace = clBlack
    ColorGrad = clBlack
    ColorLight = clBlack
    ColorDark = clBlack
    ColorScheme = csCustom
    FillDirection = fdVertical
    BevelOuter = bvNone
    TabOrder = 73
    UseDockManager = True
  end
  object Button1: TXiButton
    Left = 184
    Top = 500
    Width = 75
    Height = 25
    HelpType = htKeyword
    ColorFace = clBlue
    ColorGrad = clRed
    ColorDark = clLime
    ColorLight = clYellow
    ColorBorder = clBlack
    ColorText = clBlack
    OverColorFace = clWhite
    OverColorGrad = clWhite
    OverColorDark = clWhite
    OverColorLight = clWhite
    OverColorBorder = 14120960
    OverColorText = clBlack
    DownColorFace = 15790320
    DownColorGrad = 15790320
    DownColorDark = 15790320
    DownColorLight = 15790320
    DownColorBorder = 10048512
    DownColorText = clBlack
    DisabledColorFace = clSilver
    DisabledColorGrad = clSilver
    DisabledColorDark = clSilver
    DisabledColorLight = clSilver
    DisabledColorBorder = clBlack
    DisabledColorText = clBlack
    ColorFocusRect = clNone
    ColorScheme = csCustom
    Ctl3D = True
    Layout = blGlyphLeft
    Spacing = 4
    TransparentGlyph = True
    Gradient = False
    HotTrack = True
    Caption = 'Default'
    TabOrder = 74
    OnClick = Button1Click
  end
end
