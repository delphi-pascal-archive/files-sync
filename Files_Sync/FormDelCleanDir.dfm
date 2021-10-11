object FrmDelDir: TFrmDelDir
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'FrmDelDir'
  ClientHeight = 445
  ClientWidth = 498
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object CheckListBoxDirSource: TCheckListBox
    Left = 8
    Top = 24
    Width = 481
    Height = 132
    OnClickCheck = CheckListBoxDirClickCheck
    ItemHeight = 13
    TabOrder = 0
  end
  object CheckListBoxDirTarget: TCheckListBox
    Left = 7
    Top = 184
    Width = 481
    Height = 132
    OnClickCheck = CheckListBoxDirClickCheck
    ItemHeight = 13
    TabOrder = 1
  end
  object ButtonOk: TButton
    Left = 150
    Top = 412
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 2
    OnClick = ButtonOkClick
  end
  object ButtonCancel: TButton
    Left = 262
    Top = 412
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = ButtonCancelClick
  end
  object ButtonStop: TButton
    Left = 356
    Top = 412
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 4
    OnClick = ButtonStopClick
  end
  object PanelConfirm: TPanel
    Left = 8
    Top = 328
    Width = 273
    Height = 73
    Hint = '99'
    TabOrder = 5
    object ImageConfirm: TImage
      Left = 16
      Top = 16
      Width = 16
      Height = 16
      Picture.Data = {
        07544269746D617036030000424D360300000000000036000000280000001000
        000010000000010018000000000000030000C40E0000C40E0000000000000000
        0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6087BB000018FFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF4776
        D2467FDA3E72A1000C26FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFF2C6AE02971E73574C4000029FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF547EE13376
        F01660DC2D6FD6487DC600001CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFF5374C3426FD6356FD6316FDB3A78EA3D75D400002AFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5F71905C7EC44772C90000
        3EFFFFFF3F73DD366ACF4A77C000002EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFF73748E747F9D000020FFFFFFFFFFFFFFFFFFFFFFFF4771CA5B81E100003B
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFF5F7CC64966C85A78CF000021FFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6778C76482CF
        000029FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFF6681B9507CB200001FFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        5171A26B88B4000007FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF697A9B8690A100000BFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFF737EA47E8CA8000016FFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFF}
      Transparent = True
    end
    object ImageNotRecycle: TImage
      Left = 16
      Top = 40
      Width = 16
      Height = 16
      Picture.Data = {
        07544269746D617036030000424D360300000000000036000000280000001000
        000010000000010018000000000000030000C40E0000C40E0000000000000000
        0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF796C568C7E
        62796B557C6F676D65665E6166FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFF95877BE5D0BBCFBA9FC4B79DCACAB893A0926C8276536B5F
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D5D570000FF0000FFF0D6
        BEDDD2B4ADBC9CC2E2C3AFD9BAC6EBD16575630000FF0000FFFFFFFFFFFFFFFF
        FFFFFFFFFFDADACCFDE3D70000FF0000FFDAD4B14A6A3BA1D9A4AFEFBBAFE2B6
        0000FF0000FF726360FFFFFFFFFFFFFFFFFFFFFFFFC5C7B1E8CDBFFAD7C90000
        FF0000FF5381462A722C2E7C350000FF0000FFE7E5D3867572FFFFFFFFFFFFFF
        FFFFFFFFFFC7C4A8FFEEE0FFF7EAE4D1BC0000FF0000FF307E2B0000FF0000FF
        84A279D6D8C48E827CFFFFFFFFFFFFFFFFFFE8E7C1E0D8BAFFFCEDFFFEF3BAB3
        9FB8CCA20000FF0000FF0000FFA4E79CB5D7A8AFBAA08E89808B827EFFFFFFFF
        FFFFE2D7B1FFFFE2FFFEF1F6EDE3AEB4A19FBB970000FF0000FF0000FF3A782C
        4B703EC9DBBC999C8D7B7870FFFFFFFFFFFFEBDBB7FFFFE5EBE2D5DADBD1C4D5
        C70000FF0000FF5490490000FF0000FF416733DFF4D3ACB5A1605F55FFFFFFFF
        FFFFE3CEB2FFFFEDFBF7ECEEF6EF0000FF0000FFD1FDD4A2D39D9BCA8B0000FF
        0000FFDBF2CCC9D3BC6C6B5DFFFFFFFFFFFFE8D7C2FFF4E2FBF9EF0000FF0000
        FFCCECE1DBFFE9DFFFE3E3FFD9E6FFD40000FF0000FFF0F5DA82806EFFFFFFFF
        FFFFFFFFFFE6E0D5E8E6DE0000FFE8F7F9D4ECECC2E4DEC4E9D9D5F4D7DBF4CE
        EDF7CC0000FFFEF9DA756E5AFFFFFFFFFFFFFFFFFFEEEEE8FFFEFAE0E0E0E9F1
        F8EBFCFFD8F7FFD9FCFFE5FFF6DDEED3BEBE96E1D5ABFFF5D17B6E58FFFFFFFF
        FFFFFFFFFFF9FFFEFFFFFFF3EAEDDBD9E5D2DCEED1EEFFCFF3FFCFEDEEDFECDC
        C5B995E0C89EDEC4A08F7D66FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFEAF1FFDAF6FFB7DBF3CBE8EFD9E5D9DDCCABF0D0A5EFCFABFFEDD4FFFFFFFF
        FFFF}
      Transparent = True
    end
    object CheckBoxConfirm: TCheckBox
      Left = 40
      Top = 16
      Width = 225
      Height = 17
      Caption = 'CheckBoxConfirm'
      TabOrder = 0
    end
    object CheckBoxNotRecycle: TCheckBox
      Left = 40
      Top = 40
      Width = 225
      Height = 17
      Caption = 'CheckBoxNotRecycle'
      TabOrder = 1
    end
  end
  object PanelProgressBar: TPanel
    Left = 288
    Top = 328
    Width = 201
    Height = 73
    TabOrder = 6
    object LabelProgress: TLabel
      Left = 19
      Top = 16
      Width = 67
      Height = 13
      Caption = 'LabelProgress'
    end
    object ProgressBarDelete: TProgressBar
      Left = 16
      Top = 40
      Width = 153
      Height = 17
      Position = 50
      Smooth = True
      Step = 1
      TabOrder = 0
    end
  end
  object CheckBoxSource: TCheckBox
    Left = 12
    Top = 4
    Width = 261
    Height = 17
    Caption = 'CheckBoxSource'
    TabOrder = 7
    OnClick = CheckBoxListClick
  end
  object CheckBoxTarget: TCheckBox
    Left = 12
    Top = 166
    Width = 261
    Height = 17
    Caption = 'CheckBoxTarget'
    TabOrder = 8
    OnClick = CheckBoxListClick
  end
end
