object Form1: TForm1
  Left = 315
  Top = 114
  Width = 547
  Height = 490
  Caption = 'Gravador de difones'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 312
    Top = 32
    Width = 31
    Height = 13
    Caption = 'Difone'
  end
  object l_nomeArq: TLabel
    Left = 312
    Top = 72
    Width = 38
    Height = 13
    Caption = 'xxx.wav'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object l_difo: TLabel
    Left = 368
    Top = 24
    Width = 45
    Height = 37
    Caption = '_ _'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object l_conta: TLabel
    Left = 32
    Top = 208
    Width = 43
    Height = 13
    Caption = '0 difones'
  end
  object l_nomeDB: TLabel
    Left = 312
    Top = 8
    Width = 33
    Height = 13
    Caption = 'xxx.dat'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Image1: TImage
    Left = 16
    Top = 368
    Width = 489
    Height = 57
  end
  object Panel1: TPanel
    Left = 16
    Top = 280
    Width = 489
    Height = 81
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 13
  end
  object b_proximo: TButton
    Left = 376
    Top = 112
    Width = 49
    Height = 25
    Caption = '&Seguinte'
    TabOrder = 3
    OnClick = b_proximoClick
  end
  object b_anterior: TButton
    Left = 312
    Top = 112
    Width = 49
    Height = 25
    Caption = '&Anterior'
    TabOrder = 2
    OnClick = b_anteriorClick
  end
  object ListBox1: TListBox
    Left = 24
    Top = 16
    Width = 265
    Height = 185
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ItemHeight = 14
    ParentFont = False
    TabOrder = 0
    OnClick = ListBox1Click
    OnDblClick = ListBox1DblClick
  end
  object b_gravar: TButton
    Left = 432
    Top = 152
    Width = 75
    Height = 25
    Caption = '&Gravar'
    TabOrder = 5
    OnClick = b_gravarClick
  end
  object b_tocar: TButton
    Left = 432
    Top = 112
    Width = 75
    Height = 25
    Caption = '&Tocar'
    TabOrder = 4
    OnClick = b_tocarClick
  end
  object b_diretorio: TButton
    Left = 432
    Top = 72
    Width = 75
    Height = 25
    Caption = '&Diret'#243'rio'
    TabOrder = 1
    OnClick = DiretorioClick
  end
  object b_cortaInicio: TButton
    Left = 24
    Top = 240
    Width = 75
    Height = 25
    Caption = 'Corta in'#237'cio'
    TabOrder = 9
    OnClick = b_cortaInicioClick
    OnKeyPress = b_cortaInicioKeyPress
  end
  object b_adicfim: TButton
    Left = 288
    Top = 240
    Width = 75
    Height = 25
    Caption = 'Adic. Fim'
    TabOrder = 12
    OnClick = b_adicfimClick
  end
  object b_adicInicio: TButton
    Left = 112
    Top = 240
    Width = 75
    Height = 25
    Caption = 'Adic Inicio'
    TabOrder = 10
    OnClick = b_adicInicioClick
  end
  object b_cortaFim: TButton
    Left = 200
    Top = 240
    Width = 75
    Height = 25
    Caption = 'Corta Fim'
    TabOrder = 11
    OnClick = b_cortafimClick
    OnKeyPress = b_cortaFimKeyPress
  end
  object maisVol50: TButton
    Left = 200
    Top = 208
    Width = 73
    Height = 25
    Caption = '+ vol 50%'
    TabOrder = 7
    OnClick = maisVol50Click
  end
  object menosVol25: TButton
    Left = 112
    Top = 208
    Width = 73
    Height = 25
    Caption = '- vol 25%'
    TabOrder = 6
    OnClick = menosVol25Click
  end
  object maisVol100: TButton
    Left = 288
    Top = 208
    Width = 73
    Height = 25
    Caption = '+ vol 100%'
    TabOrder = 8
    OnClick = maisVol100Click
  end
  object Button2: TButton
    Left = 272
    Top = 264
    Width = 17
    Height = 17
    Caption = 'X!'
    TabOrder = 14
    OnClick = Button2Click
  end
  object Button1: TButton
    Left = 96
    Top = 264
    Width = 17
    Height = 17
    Caption = 'X!'
    TabOrder = 15
    OnClick = Button1Click
  end
  object Button3: TButton
    Left = 24
    Top = 224
    Width = 17
    Height = 17
    Caption = 'X!'
    TabOrder = 16
    OnClick = Button3Click
  end
  object MainMenu1: TMainMenu
    Left = 424
    object Arquivo1: TMenuItem
      Caption = '&Arquivo'
      object Carregarbase1: TMenuItem
        Caption = '&Carregar base'
        OnClick = Carregarbase1Click
      end
      object Sair1: TMenuItem
        Caption = '&Fim'
        OnClick = Sair1Click
      end
    end
    object Amostra1: TMenuItem
      Caption = 'Amostra'
      object Anterior1: TMenuItem
        Caption = 'Anterior'
        ShortCut = 116
        OnClick = Anterior1Click
      end
      object Prxima1: TMenuItem
        Caption = 'Seguinte'
        ShortCut = 117
        OnClick = Prxima1Click
      end
      object ocar1: TMenuItem
        Caption = 'Tocar'
        ShortCut = 118
        OnClick = tocar1Click
      end
      object Gravar1: TMenuItem
        Caption = 'Gravar'
        ShortCut = 119
        OnClick = Gravar1Click
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = '*.dat|*.dat'
    Left = 448
    Top = 32
  end
  object SaveDialog1: TSaveDialog
    Filter = '*.dat|*.dat'
    Left = 480
    Top = 32
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 344
    Top = 144
  end
end
