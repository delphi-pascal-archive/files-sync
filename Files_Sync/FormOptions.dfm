object FrmOptions: TFrmOptions
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'FrmOptions'
  ClientHeight = 314
  ClientWidth = 387
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonOk: TButton
    Left = 96
    Top = 280
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 0
    OnClick = ButtonOkClick
  end
  object ButtonCancel: TButton
    Left = 216
    Top = 280
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = ButtonCancelClick
  end
  object PageControlOptions: TPageControl
    Left = 8
    Top = 8
    Width = 369
    Height = 265
    ActivePage = TabSheetDisplay
    TabOrder = 2
    object TabSheetDisplay: TTabSheet
      Caption = 'TabSheetDisplay'
      object GroupBoxColor: TGroupBox
        Left = 12
        Top = 16
        Width = 337
        Height = 113
        Caption = 'GroupBoxColor'
        TabOrder = 0
        object LabelColorPair: TLabel
          Left = 16
          Top = 24
          Width = 68
          Height = 13
          Caption = 'LabelColorPair'
        end
        object LabelColorImpair: TLabel
          Left = 16
          Top = 44
          Width = 80
          Height = 13
          Caption = 'LabelColorImpair'
        end
        object PanelColorPair: TPanel
          Tag = 99
          Left = 156
          Top = 24
          Width = 165
          Height = 17
          ParentBackground = False
          TabOrder = 0
          OnClick = ColorClick
        end
        object PanelColorImpair: TPanel
          Tag = 99
          Left = 156
          Top = 44
          Width = 165
          Height = 17
          ParentBackground = False
          TabOrder = 1
          OnClick = ColorClick
        end
        object ButtonColorDef: TButton
          Left = 184
          Top = 70
          Width = 113
          Height = 25
          Caption = 'ButtonColorDef'
          TabOrder = 2
          OnClick = ColorClick
        end
      end
      object CheckBoxColWidth: TCheckBox
        Left = 28
        Top = 160
        Width = 309
        Height = 17
        Caption = 'CheckBoxColWidrh'
        TabOrder = 1
      end
    end
    object TabSheetCompare: TTabSheet
      Caption = 'TabSheetCompare'
      object GroupBoxCmp_NTFS_FAT: TGroupBox
        Left = 24
        Top = 12
        Width = 209
        Height = 53
        Caption = 'Cmp_NTFS_FAT_Grp'
        TabOrder = 0
        object CheckBoxCmp_Ignore_2s: TCheckBox
          Left = 16
          Top = 24
          Width = 186
          Height = 17
          Caption = 'CheckBoxCmp_Ignore_2s'
          TabOrder = 0
        end
      end
      object GroupBoxTimezone: TGroupBox
        Left = 24
        Top = 80
        Width = 308
        Height = 49
        Caption = 'GroupBoxTimezone'
        TabOrder = 1
        object LabelTimezone: TLabel
          Left = 16
          Top = 24
          Width = 70
          Height = 13
          Caption = 'LabelTimezone'
        end
        object LabelHours: TLabel
          Left = 256
          Top = 24
          Width = 53
          Height = 13
          Caption = 'LabelHours'
        end
        object SpinEditTimeZone: TSpinEdit
          Left = 212
          Top = 20
          Width = 38
          Height = 22
          MaxLength = 3
          MaxValue = 23
          MinValue = -23
          TabOrder = 0
          Value = 0
        end
      end
    end
    object TabSheetHistory: TTabSheet
      Caption = 'TabSheetHistory'
      ImageIndex = 1
      object LabelHistory: TLabel
        Left = 8
        Top = 8
        Width = 59
        Height = 13
        Caption = 'LabelHistory'
      end
      object ComboBoxHistory: TComboBox
        Left = 8
        Top = 24
        Width = 137
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 0
        OnClick = OnHistoryActions
      end
      object ButtonDeleteAll: TButton
        Left = 280
        Top = 22
        Width = 73
        Height = 25
        Caption = 'ButtonDeleteAll'
        TabOrder = 1
        OnClick = OnHistoryActions
      end
      object ListBoxHistory: TListBox
        Left = 8
        Top = 56
        Width = 345
        Height = 169
        ItemHeight = 13
        MultiSelect = True
        TabOrder = 2
        OnClick = OnHistoryActions
      end
      object ButtonDelete: TButton
        Left = 192
        Top = 22
        Width = 73
        Height = 25
        Caption = 'ButtonDelete'
        TabOrder = 3
        OnClick = OnHistoryActions
      end
    end
  end
  object ColorDialog: TColorDialog
    Left = 40
    Top = 280
  end
end
