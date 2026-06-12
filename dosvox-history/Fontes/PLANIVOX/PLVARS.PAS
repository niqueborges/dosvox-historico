{--------------------------------------------------------}
{
{    Planilha eletronica VOX
{
{    Modulo de variaveis
{
{    Autor:  Jose' Antonio Borges
{
{    Em dezembro/96
{
{--------------------------------------------------------}

unit plvars;
interface
const
    versao = '1.1';

{--------------------------------------------------------}
{             definicao de celula e bloco
{--------------------------------------------------------}

const
    MAXLINPLAN = 50000;
    MAXCELLINHA = 26;

    { tipo do conteudo da celula }
    nada     = 0;
    letras   = 1;
    numero   = 2;
    datahora = 3;
    form     = 4;

    { formatos de saida }
    geral      = 0;
    dinheiro   = 1;
    numerico   = 2;
    cientifico = 3;
    data       = 4;

    { flags da celula }
    centrada  = 1;
    alinDir   = 2;
    alinEsq   = 4;

    { tipos de recalculo }
    porLinha = 1;
    porColuna = 2;
    porPreced = 3;
    recalcInib = 8;

type
    PCELULA = ^TCELULA;
    PLINHA = ^TLINHA;

    TCELULA = record
        conteudo: string;
        tipo: byte;    { nada, letras, numero, form }
        resultComput: string;
        tipoResultComput: byte;   { letras, numero }

        valor: real;
        formato: byte;
        casasDec: byte;
        alinhamento: byte;
    end;

    TLINHA = record
        cel: array [1..MAXCELLINHA] of PCELULA;
    end;

    TCOLUNA = record
        largColuna: byte;
    end;

    TBLOCO = record
        xbloco1, xbloco2: byte;
        ybloco1, ybloco2: integer;
    end;

{--------------------------------------------------------}
{                        variaveis
{--------------------------------------------------------}

var
   xatual, yatual: integer;   { posicao do cursor na planilha }
   nomePlan: string;          { nome da planilha }
   nomeDir, nomeArq: string;  { diretorio e nome do arquivo da planilha }

   plan: array [1..MAXLINPLAN] of PLINHA;

   xceltela, yceltela: integer;  { primeira celula mostrada na tela }
   ultxtela: integer;            { ultima coluna mostrada na tela }
   col: array [1..MAXCELLINHA] OF TCOLUNA;

   blocoAtual: TBLOCO;
   alterouTodaTela: boolean;
   tipoRecalc: byte;

   criaSemEnter: boolean;
   posicArmazenada: string;
   falaPosCel: boolean;

   xtransp, ytransp: integer;

implementation

end.
