{--------------------------------------------------------}
{
{    Calculadora Vocal - versao 4.0
{
{    Módulo de variáveis
{
{    Autor: Jose' Antonio Borges
{           Mara Lucia Caldeira
{           Julio Tadeu Carvalho da Silveira
{
{    Versão 4.0 em maio/2019
{
{--------------------------------------------------------}

unit calvars;

interface
uses classes;

const
    versao = '4.0a';

const
    maxDigitos = 18;
    maxNumero  = 999999999999999999;

type
    Numerico = Extended;

var
    numVisor:   Numerico;
    acumulador: Numerico;
    operando2:  Numerico;

    repetindoOp: boolean;

    jaLido: boolean;
    ultLido: char;
    ultOp: char;
    nDecimais: integer;
    memoria: array [0..9+26] of Numerico;

    posFita, nrFita: integer;
    valorFita: array [1..5000] of Numerico;
    opFita:    array [1..5000] of string[4];

    ptransf: pchar;
    areaTransf: array [0..65000] of char;

    angulosEmGraus: boolean;

    ultimasExpressoes: TStringList;

const
    TAMPILHA = 20;

type
    ItemPilha = record
        valor: Numerico;
        oper:  char;
    end;
var
    pilha: array [1..TAMPILHA] of ItemPilha;
    topoPilha: integer;

function tamanhoCampo (valor: Numerico; precisao: integer): integer;

implementation

function tamanhoCampo (valor: Numerico; precisao: integer): integer;
var
    strValor: string;
begin
    str (valor:0:precisao, strValor);
    result := length (strValor);
end;

end.
