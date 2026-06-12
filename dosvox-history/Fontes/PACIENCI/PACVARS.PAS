{--------------------------------------------------------}
{
{   Modulo de variaveis globais
{
{   Autor: Jose' Antonio Borges
{
{   Em 19/9/97
{
{--------------------------------------------------------}

unit pacVars;

interface

const
    CTLF1 = #94;    { teclas }

    F1    = #59;
    F8    = #66;

    INS   = #82;
    DEL   = #83;
    PGUP  = #73;
    PGDN  = #81;
    CIMA  = #72;
    BAIX  = #80;
    ESQ   = #75;
    DIR   = #77;
    HOME  = #71;
    TEND  = #79;

    ENTER = #13;
    BS    = #08;
    TAB   = #09;
    ESC   = #27;

const
    COPAS    = 3;    { nao troque estes numeros }
    OUROS    = 4;
    PAUS     = 5;
    ESPADAS  = 6;

var
    ncBaralho: integer;                  { numero de cartas ainda no baralho }
    baralho: array [1..52] of byte;      { o baralho }

    ncTiradas: integer;
    tiradas: array [1..52] of byte;
                                         { o baralho das tiradas }

    coluna: array [1..7, 1..20] of byte; { configuracao de cada coluna }
    cartasCol: array [1..7] of byte;     { numero de cartas em cada coluna }
    fechadasCol: array [1..7] of byte;   { fechadas em cada coluna }
    pilha: array [3..6] of byte;         { ultima carta jogada em cada pilha }

{ codificacao da carta no baralho e nas colunas:
{       bit 6 a 3 - valor
{           2 a 0 - naipe
}
    colAtual, linatual: integer;         { coluna e linha selecionadas }
    jogando, saiDoProg: boolean;

    h0, m0, s0, c0: word;                { hora do inicio do jogo }

implementation

end.
