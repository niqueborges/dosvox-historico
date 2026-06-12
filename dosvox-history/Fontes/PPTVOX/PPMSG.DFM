object pptmsg: Tpptmsg
  Left = 192
  Top = 107
  Width = 341
  Height = 132
  Caption = 'Confirma'#231#227'o'
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
    Left = 64
    Top = 16
    Width = 198
    Height = 20
    Caption = 'Deseja Realmente sair ?'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Button1: TButton
    Left = 64
    Top = 56
    Width = 75
    Height = 25
    Caption = '&Sim'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object Button2: TButton
    Left = 184
    Top = 56
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&N'#227'o'
    ModalResult = 2
    TabOrder = 1
  end
end
