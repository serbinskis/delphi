object CryptoSettings: TCryptoSettings
  Left = 192
  Top = 125
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 76
  ClientWidth = 204
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Calibri'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object StaticText2: TStaticText
    Left = 8
    Top = 43
    Width = 56
    Height = 19
    Caption = 'Currency:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object StaticText1: TStaticText
    Left = 8
    Top = 11
    Width = 32
    Height = 19
    Caption = 'Coin:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object ComboBox2: TFlatComboBox
    Left = 72
    Top = 40
    Width = 121
    Height = 23
    Color = clWhite
    ColorArrow = 8026746
    ColorArrowBackground = clWhite
    ColorBorder = 8026746
    ItemHeight = 15
    Items.Strings = (
      'USD'
      'EUR'#10
      'GBP'#10
      'CNY'#10
      'AED'#10
      'AFN'#10
      'ALL'#10
      'AMD'#10
      'ANG'#10
      'AOA'#10
      'ARS'#10
      'AUD'#10
      'AWG'#10
      'AZN'#10
      'BAM'#10
      'BBD'#10
      'BDT'#10
      'BGN'#10
      'BHD'#10
      'BIF'#10
      'BMD'#10
      'BND'#10
      'BOB'#10
      'BRL'#10
      'BSD'#10
      'BTN'#10
      'BWP'#10
      'BYN'#10
      'BZD'#10
      'CAD'#10
      'CDF'#10
      'CHF'#10
      'CLF'#10
      'CLP'#10
      'COP'#10
      'CRC'#10
      'CUC'#10
      'CUP'#10
      'CVE'#10
      'CZK'#10
      'DJF'#10
      'DKK'#10
      'DOP'#10
      'DZD'#10
      'EGP'#10
      'ERN'#10
      'ETB'#10
      'FJD'#10
      'FKP'#10
      'GEL'#10
      'GGP'#10
      'GHS'#10
      'GIP'#10
      'GMD'#10
      'GNF'#10
      'GTQ'#10
      'GYD'#10
      'HKD'#10
      'HNL'#10
      'HRK'#10
      'HTG'#10
      'HUF'#10
      'IDR'#10
      'ILS'#10
      'IMP'#10
      'INR'#10
      'IQD'#10
      'IRR'#10
      'ISK'#10
      'JEP'#10
      'JMD'#10
      'JOD'#10
      'JPY'#10
      'KES'#10
      'KGS'#10
      'KHR'#10
      'KMF'#10
      'KPW'#10
      'KRW'#10
      'KWD'#10
      'KYD'#10
      'KZT'#10
      'LAK'#10
      'LBP'#10
      'LKR'#10
      'LRD'#10
      'LSL'#10
      'LYD'#10
      'MAD'#10
      'MDL'#10
      'MGA'#10
      'MKD'#10
      'MMK'#10
      'MNT'#10
      'MOP'#10
      'MRO'#10
      'MRU'#10
      'MUR'#10
      'MVR'#10
      'MWK'#10
      'MXN'#10
      'MYR'#10
      'MZN'#10
      'NAD'#10
      'NGN'#10
      'NIO'#10
      'NOK'#10
      'NPR'#10
      'NZD'#10
      'OMR'#10
      'PAB'#10
      'PEN'#10
      'PGK'#10
      'PHP'#10
      'PKR'#10
      'PLN'#10
      'PYG'#10
      'QAR'#10
      'RON'#10
      'RSD'#10
      'RUB'#10
      'RWF'#10
      'SAR'#10
      'SBD'#10
      'SCR'#10
      'SDG'#10
      'SEK'#10
      'SGD'#10
      'SHP'#10
      'SLL'#10
      'SOS'#10
      'SRD'#10
      'STD'#10
      'STN'#10
      'SVC'#10
      'SYP'#10
      'SZL'#10
      'THB'#10
      'TJS'#10
      'TMT'#10
      'TND'#10
      'TOP'#10
      'TRY'#10
      'TTD'#10
      'TWD'#10
      'TZS'#10
      'UAH'#10
      'UGX'#10
      'UYU'#10
      'UZS'#10
      'VES'#10
      'VND'#10
      'VUV'#10
      'WST'#10
      'XAF'#10
      'XAG'#10
      'XAU'#10
      'XCD'#10
      'XDR'#10
      'XOF'#10
      'XPF'#10
      'YER'#10
      'ZAR'#10
      'ZMW'#10
      'ZWL')
    TabOrder = 2
    Text = 'USD'
    ItemIndex = 0
  end
  object ComboBox1: TFlatComboBox
    Left = 72
    Top = 8
    Width = 121
    Height = 23
    Color = clWhite
    ColorArrow = 8026746
    ColorArrowBackground = clWhite
    ColorBorder = 8026746
    ItemHeight = 15
    Items.Strings = (
      'BTC'
      'BNB'
      'ETH'
      'DOGE')
    TabOrder = 3
    Text = 'BTC'
    ItemIndex = 0
  end
end
