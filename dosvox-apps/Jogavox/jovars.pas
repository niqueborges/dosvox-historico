{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Módulo de variáveis globais
{
{    Autores: José Antonio Borges
{             Lidiane Figueira Silva
{             Bernard Condorcet
{
{    Em Janeiro/2009
{
{--------------------------------------------------------}

unit jovars;

interface

uses classes, windows, sysutils;

const
    versao = '5.0';

const
    MAXLUGARES = 1000;
    MAXSLIDESLUGAR = 50;
    URL_JOGOS_DEFAULT = 'https://intervox.nce.ufrj.br/~projetojogavox/Site_Jogavox/Jogos/';

const
    simNao = 'SIM|NÃO';
    listaFontes: string = 'Arial|Courier New|Times New Roman|Verdana';
    listaTamanhos: string = '12|14|16|18|20|22|24|26|28|30';
    listaCores: string = 'Preto|Azul|Verde|Ciano|Vermelho|Roxo|Marrom|Cinza|Amarelo|Branco';
    listaPosicoes: string = 'centro|cima|baixo|esquerda|direita|' +
                            'centro esquerda|centro direita|' +
                            'cima esquerda|cima centro|cima direita|' +
                            'baixo esquerda|baixo centro|baixo direita';
    listaAvancos: string = 'AUTO|SIM|NÃO|5S|1S|500MS';
    listaEfeitos: string =
                'ESQUERDA'
        + '|' + 'DIREITA'
        + '|' + 'CIMA'
        + '|' + 'BAIXO'
        + '|' + 'ESQUERDA DIREITA'
        + '|' + 'CIMA BAIXO'
        + '|' + 'QUADRADOS'
        + '|' + 'CRESCER'
        + '|' + 'PREENCHER'
        + '|' + 'DIAGONAL';

type
    PLugar = ^TLugar;
    PSlide = ^TSlide;
    PAcao  = ^TAcao;

    TFonteLetras = record
        nomeFonte: string;
        tamFonte: integer;
        negrito: boolean;
        hfonte: THandle;
        larguraLetra: integer;
        alturaLetra: integer;
    end;

    TDadosGerais = record
        nomeJogo: string;
        autor: string;
        dataCriacao: string;
        versao: string;
        dataVersao: string;
        comentarios: array[1..5] of string;
        nomeScriptControlador: string;
    end;

    TJogo = record
        dadosGerais: TDadosGerais;
        numLugares: integer;
        lugares: array [1..MAXLUGARES] of PLugar;
        fundoDefault: string;   // arquivo JPG padrão
        fonteTexto: TFonteLetras;
        corLetraDefault: string;
        corFundoDefault: string;
        aleatorio: boolean;
        narrando: boolean;
    end;

    TAcao = record
        condicao: string;
        novoLugar: string;
    end;

    TLugar = record
        nome: string;
        categoria: string;

        respostaEsperada: string;
        memoriaResposta: string;
        lugarOk: string;
        lugarErro: string;
        pontuacao: integer;
        jogoTerminaAqui: boolean;

        scriptEntrada: string;
        scriptSaida: string;

        midiaLugar: string;
        corFundo: string;
        corLetra: string;
        fundo: string;      { fundo comum àquele lugar }
        ImagemA: string;   // NOVO teste
        ImagemB: string;   // NOVO teste

        numSlides: integer;
        slides: array [1..MAXSLIDESLUGAR] of PSlide;
    end;

    TSlide = record
        titulo: string;
        figura: string;
        posFigura: string;
        midiaSlide: string;
        esperaMidia: boolean;
        efeito: string;
        avancaEm: string;
        falaTexto: string;
        posTexto: string;
        texto: TStringList;
    end;

var
    nomeArqJogo: string;
    jogo: TJogo;

    indLocalEditando: integer;
    indSlideEditando: integer;

    dirJogo: string;
    dirBaseJogos: string;
    listaDirJogos: TStringList;
    lista: TStringList;
    dirBaseMidias: string;
    listaDirMidias: TStringList;
    dirBaseModelos: string;
    arqTempGrafico: string;

    jogando: boolean;
    lugarEmJogo: integer;
    pontosJogo: integer;
    ncoment: integer;

    categoria:string;
    url_jogos: string;

function GetTempFile(filetype: string): String;

implementation

{--------------------------------------------------------}
{          obtém o nome de um arquivo temporário
{--------------------------------------------------------}

function GetTempFile(filetype: string): String;
var
    tempFileName, tempPath: array[0..255] of Char;
begin
    getTempPath (255, tempPath);
    getTempFileName(tempPath, pchar(filetype), 0, tempFileName);
    result := strPas (tempFileName);
end;

end.
