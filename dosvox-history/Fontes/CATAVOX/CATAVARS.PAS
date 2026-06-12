{--------------------------------------------------------}
{
{    Programa Cata Palavras - Variáveis globais
{
{    Autor: Jose' Antonio Borges
{
{    Em 02/05/98
{
{--------------------------------------------------------}

unit cataVars;

interface
const
    ESC   = #$1b;
    ENTER = #$0d;

const
    DIM = 20;

type
    strDIM = string[DIM];
var
    nPal: integer;
    tabPal: array [1..25] of strDIM;
    achada: array [1..25] of boolean;
    tabul: array [0..DIM+1, 0..DIM+1] of char;
    marcado: array [1..DIM, 1..DIM] of boolean;
    jogo, njogos: integer;
    arq: text;

    xcur, ycur: integer;
    processando: boolean;
    achadas: integer;

    titulo: string;
    nivel: integer;
    h0, m0, s0, c0: word;

implementation
end.