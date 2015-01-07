object fmUserAndPassword: TfmUserAndPassword
  Left = 465
  Top = 305
  Width = 303
  Height = 173
  Caption = 'Input UserName and Password'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 24
    Top = 24
    Width = 50
    Height = 13
    Caption = 'UserName'
  end
  object lbl2: TLabel
    Left = 24
    Top = 64
    Width = 46
    Height = 13
    Caption = 'Password'
  end
  object edt1: TEdit
    Left = 96
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'edt1'
  end
  object edt2: TEdit
    Left = 96
    Top = 64
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'edt2'
  end
  object btn1: TButton
    Left = 80
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btn2: TButton
    Left = 176
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
