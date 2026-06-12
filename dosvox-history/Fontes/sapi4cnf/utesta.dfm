object form_fala: Tform_fala
  Left = 192
  Top = 114
  Width = 314
  Height = 119
  Caption = 'Digite a frase a testar'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object e_testar: TEdit
    Left = 32
    Top = 16
    Width = 257
    Height = 21
    TabOrder = 0
    OnKeyPress = e_testarKeyPress
  end
  object b_fala: TButton
    Left = 72
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Fala'
    TabOrder = 1
    OnClick = b_falaClick
  end
  object b_cancela: TButton
    Left = 160
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Cancela'
    TabOrder = 2
    OnClick = b_cancelaClick
  end
end
