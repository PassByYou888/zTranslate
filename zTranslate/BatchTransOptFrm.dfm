object BatchTransOptForm: TBatchTransOptForm
  Left = 0
  Top = 0
  AutoSize = True
  BorderStyle = bsDialog
  BorderWidth = 20
  Caption = 'Translate Options...'
  ClientHeight = 297
  ClientWidth = 282
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 8
    Width = 79
    Height = 13
    Caption = 'source language'
  end
  object Label2: TLabel
    Left = 0
    Top = 57
    Width = 68
    Height = 13
    Caption = 'dest language'
  end
  object SourComboBox: TComboBox
    Left = 104
    Top = 0
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 0
    Text = 'automatic'
    Items.Strings = (
      'automatic'
      'Chinese'
      'English'
      'Cantonese'
      'Classical Chinese'
      'Japanese'
      'Korean'
      'French'
      'Spanish'
      'Thai'
      'Arabic'
      'Russian'
      'Portuguese'
      'German'
      'Italian'
      'Greek language'
      'Dutch'
      'Polish'
      'Bulgarian'
      'Estonia language'
      'Danish'
      'Finnish'
      'Czech'
      'Romanian'
      'Slovenia language'
      'Swedish'
      'Hungarian'
      'Traditional Chinese'
      'Vietnamese')
  end
  object Dest1ComboBox: TComboBox
    Left = 104
    Top = 51
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 1
    Text = 'automatic'
    Items.Strings = (
      'automatic'
      'Chinese'
      'English'
      'Cantonese'
      'Classical Chinese'
      'Japanese'
      'Korean'
      'French'
      'Spanish'
      'Thai'
      'Arabic'
      'Russian'
      'Portuguese'
      'German'
      'Italian'
      'Greek language'
      'Dutch'
      'Polish'
      'Bulgarian'
      'Estonia language'
      'Danish'
      'Finnish'
      'Czech'
      'Romanian'
      'Slovenia language'
      'Swedish'
      'Hungarian'
      'Traditional Chinese'
      'Vietnamese')
  end
  object DoExecuteButton: TButton
    Left = 80
    Top = 256
    Width = 97
    Height = 41
    Caption = 'Execute'
    ModalResult = 1
    TabOrder = 2
  end
  object UsedCacheWithZDBCheckBox: TCheckBox
    Left = 104
    Top = 98
    Width = 178
    Height = 17
    Caption = 'Used Cache with ZDB'
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object WorkModeRadioGroup: TRadioGroup
    Left = 104
    Top = 136
    Width = 161
    Height = 106
    Caption = 'Batch Mode'
    ItemIndex = 0
    Items.Strings = (
      'Selected'
      'Picked'
      'All')
    TabOrder = 4
  end
end
