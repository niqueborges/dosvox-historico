{--------------------------------------------------------}
{
{    Programa para emissao de cheques
{
{    Módulo de variáveis
{
{    Autor: Antonio Borges
{
{    Em Agosto de 2001
{
{--------------------------------------------------------}

{$N+}

unit chVars;
interface
uses wintypes;

const
    versao = '2.5';

type
    TCoord = record
        x, y: integer;
    end;

type
    PDadosDoc = ^TDadosDoc;
    TDadosDoc = record
        DataDoc: shortString;
        tipoDoc: shortString;
        valorDoc: shortString;
        debCred: shortString;
        serieDoc: shortString;
        numeroDoc: shortString;
        favorecidoDoc: shortString;
        finalidadeDoc: shortString;
    end;

var
    ini_cheqvox: string;

    moeda : string;
    moedas : string;

    nomePessoa, identidade, expedidor, cpf, telefone, endereco, bairro, cidade: shortstring;
    bancoAtual: shortstring;

    ajusteMM,
    posValor, posExtenso1, posExtenso2,
    posFavorecido, posCidade, posDia, posMes, posAno: TCoord;
    posNome, posIdentidade, posExpedidor, posCpf,
    posTelefone, posEndereco, posBairro, posMunicipio: TCoord;

    ano4digitos, deitado: boolean ;
    nomeArqLanc: string;

    cheque: TDadosDoc;
    cidadeCheque: shortString;
    cruzadoCheque: boolean;
    valorConvCheque: double;

    valorImpresso, extenso1Impresso, extenso2Impresso, favorecidoImpresso,
    CidadeImpressa, diaImpresso, mesImpresso, anoImpresso: shortString;

    ultNumeroEmitido: string;
    ultSerieEmitida: string;

    ndocs: integer;
    listaDoc: array [1..2000] of PDadosDoc;
    linhaArq, linhaVideo: integer;

    dcImpr: HDC;
    fonte: hFont;
    pixelsXporMM, pixelsYporMM: real;

const
    tabMes: array [1..12] of string[12] = (
        'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho',
        'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro');

implementation
end.
