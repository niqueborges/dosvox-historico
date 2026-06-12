{--------------------------------------------------------}
{
{    Programa de impressao comum
{
{    Variáveis globais
{
{    Autor: Jose' Antonio Borges e Geraldo Junior
{
{    Em 26/06/2000
{
{--------------------------------------------------------}

unit lisVars;

interface
uses wintypes;

const
    versao = '2.2';

var
    arqEntra:  file;
    nomeEntra: string;

    linhasPapel, colunasPapel, primLinha, primCol, ultLinha, ultCol: integer;
    pagInicial, pagFinal, numInicial: integer;
    numerando: boolean;
    ncopias: integer;

    DCimpr: hDC;
    fonte: hFont;
    xfonte, yfonte: integer;

    acabouArq: boolean;
    copiaAtual: integer;
    numPag, nlinPag: integer;

implementation
end.
