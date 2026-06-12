unit ppVars;

interface

uses
    windows,
    classes;

const
    versao = '3.0 em desenvolvimento';
    MAXSLIDES = 200;
    fundoPadrao = 'c:\winvox\PPTVOX\padrao.jpg';

type
    TSlide = record
         modelo: (capa, listaSimples, figura, video,textofigura);
         titulo: string;
         arquivo: string;
         som: string;
         fundo: string;
         linhas: TStringList;
    end;
    PSlide = ^TSlide;

var
    janProg: integer;
    nomeJan: array [0..256] of char;
    nomeJanProg: array [0..256] of char;
    dirPPX, dirEstilos: string;

    slides: array [0..MAXSLIDES] of TSlide;
    slideAtual, linhaAtual: integer;
    nSlides: integer;
    fonteTitulo, fonteDetalhe, fonteSimbolo: HFont;
    textoBranco: boolean;
    figuraDeFundo: string;
    corLetra: string;
    apagaSempreOFundo: boolean;

    xtitulo:  integer = 20;    // posição do título
    ytitulo:  integer = 30;
    xdetalhe: integer = 60;    // posição do primeiro detalhe (item da transparência)
    ydetalhe: integer = 60;
    xfigura:  integer = 60;    // posição do primeiro detalhe (item da transparência)
    yfigura:  integer = 60;

    xdet, ydet: integer;
    xtit, ytit: integer;
    xfig, yfig: integer;
    x1fig, y1fig: integer;
    x2fig, y2fig: integer;

    nomeArq, nomeArqTransf, nomeArqTXT, nomeEstilo, novoNomeEstilo, nomeProg: string;
    capturouEstilo: boolean;
    criandoSlide, salvarSlide: boolean;

    apresentando:boolean;
    hora, min, seg, cent: word;
    horaInic, minInic, minInic_bk: word;
    apresentaAuto, repeteAuto, leAuto: boolean;
    primeiraVez: boolean;
    tempoSlide, tempoLinha: integer;

    nomeArqDic, nomeArqSufixos, nomeArqInexist, nomeArqNomes, nomeArqSugTroca: string;
    comDic, soletrando: boolean;

    trocSlides, trocLinhas, primSlide, ultSlide, ultLinha: string;

    larguraTela, alturaTela: integer;

    debugar: boolean;
    erroNoTitulo: boolean;
    erroNaFigura: boolean;
    erroNaLinha: array [0..20] of integer;

    debugCriando, debugEditando: boolean;
    sintDimensoesOK: boolean;

    resolucaoGrafica, resolucaoEstilo: string;

    f_tit, f_lin: string;
    t_tit, t_lin: integer;

    tempoApresentacao: integer;

    exportandoPPT: boolean;

    saltarSlide: integer;

    tocarSlide, informarFoto: boolean;

    musicaDeFundo: string;
    tocarFundoMusical: boolean;

    e_player: string;
    ativarPlayer: boolean;

    ativFigSom: boolean;

implementation

end.
