object FormEscolher: TFormEscolher
  Left = 194
  Top = 102
  Width = 293
  Height = 249
  Caption = 'Escolher dicion'#225'rio'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 91
    Height = 13
    Caption = 'Nome do dicion'#225'rio'
  end
  object Label2: TLabel
    Left = 8
    Top = 120
    Width = 75
    Height = 13
    Caption = 'Primeira palavra'
  end
  object Label3: TLabel
    Left = 8
    Top = 64
    Width = 86
    Height = 13
    Caption = 'Arquivo de sufixos'
  end
  object e_nomedic: TEdit
    Left = 8
    Top = 32
    Width = 257
    Height = 21
    TabOrder = 1
    Text = 'diciona.dic'
  end
  object e_primPal: TEdit
    Left = 8
    Top = 144
    Width = 249
    Height = 21
    TabOrder = 3
  end
  object Button2: TButton
    Left = 96
    Top = 184
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 0
    OnClick = Button2Click
  end
  object e_nomesuf: TEdit
    Left = 8
    Top = 88
    Width = 257
    Height = 21
    TabOrder = 2
    Text = 'diciona.suf'
  end
end
