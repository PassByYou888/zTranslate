object BatchTransOptForm: TBatchTransOptForm
  Left = 0
  Top = 0
  AutoSize = True
  BorderStyle = bsDialog
  BorderWidth = 20
  Caption = 'Translate Options...'
  ClientHeight = 153
  ClientWidth = 249
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
    Top = 33
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
    Top = 27
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
    Left = 64
    Top = 112
    Width = 97
    Height = 41
    Caption = 'Execute'
    ModalResult = 1
    TabOrder = 2
  end
  object NextNoPromptCheckBox: TCheckBox
    Left = 48
    Top = 72
    Width = 177
    Height = 17
    Caption = 'No prompt with next Time'
    TabOrder = 3
  end
end
