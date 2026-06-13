object ppmsg: Tppmsg
  Left = 237
  Top = 159
  Width = 330
  Height = 127
  Caption = 'Finalizar'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 56
    Top = 24
    Width = 199
    Height = 20
    Caption = 'Dedeja Realmente sair ?'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Button1: TButton
    Left = 40
    Top = 64
    Width = 75
    Height = 25
    Caption = '&Sim'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object Button2: TButton
    Left = 200
    Top = 64
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&N'#227'o'
    ModalResult = 2
    TabOrder = 1
  end
end
