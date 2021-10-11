object FrmAbout: TFrmAbout
  Left = 392
  Top = 252
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FrmAbout'
  ClientHeight = 264
  ClientWidth = 332
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel: TPanel
    Tag = 99
    Left = 4
    Top = 4
    Width = 325
    Height = 221
    ParentBackground = False
    TabOrder = 0
    object ImageLogo: TImage
      Left = 140
      Top = 8
      Width = 48
      Height = 48
      AutoSize = True
      Transparent = True
    end
    object LabelProg: TLabel
      Left = 8
      Top = 50
      Width = 313
      Height = 57
      Alignment = taCenter
      AutoSize = False
      Caption = 'Program Name'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -27
      Font.Name = 'Times New Roman'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
      WordWrap = True
    end
    object LabelDevName: TLabel
      Left = 8
      Top = 112
      Width = 313
      Height = 25
      Alignment = taCenter
      AutoSize = False
      Caption = 'LabelDevName'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object LabelVersion: TLabel
      Left = 8
      Top = 172
      Width = 313
      Height = 21
      Alignment = taCenter
      AutoSize = False
      Caption = 'LabelDevName'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object labelAuthorName: TLabel
      Left = 8
      Top = 140
      Width = 313
      Height = 25
      Alignment = taCenter
      AutoSize = False
      Caption = 'Author Name'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Times New Roman'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object ButtonQuit: TButton
    Left = 128
    Top = 232
    Width = 75
    Height = 25
    Caption = 'ButtonQuit'
    TabOrder = 1
    OnClick = ButQuitClick
  end
  object TimerEffect: TTimer
    Enabled = False
    OnTimer = TimerEffectTimer
    Left = 32
    Top = 232
  end
end
