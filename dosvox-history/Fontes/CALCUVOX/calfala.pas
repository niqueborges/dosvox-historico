{--------------------------------------------------------}
{
{    Calculadora Vocal - versao 3.0
{
{    Módulo de síntese de números
{
{    Autor: Jose' Antonio Borges
{           Mara Lucia Caldeira
{           Julio Tadeu Carvalho da Silveira
{
{    Versão 4.0 em maio/2019
{
{--------------------------------------------------------}

unit calfala;

interface
uses
    calvars, calFunc, calMsg,
    dvcrt, dvwin, dvlenum,
    sysutils;

procedure falaUnidadeAngular;
procedure falaNumeroReal (numero: Numerico);

implementation

uses
    calTela,
    Math;

{--------------------------------------------------------}

procedure falaUnidadeAngular;
begin
    if angulosEmGraus then
        calSintetiza ('CA_GRAU')    { 'Ângulos em graus' }
    else
        calSintetiza ('CA_RAD');    { 'Ângulos em radianos' }
end;

{--------------------------------------------------------}


procedure falaNumeroReal (numero: Numerico);
var
    s: string;
    l: int64;
    i: integer;
    podeFalar: boolean;
begin
    if numero < 0 then
        begin
            sintSom ('CA_MENOS');   { 'Menos' }
            numero := -numero;
        end;

    // Alernativa feita pelo Antônio 2
(*
    l := numero;
    for i := 1 to ndecimais do
        l :=  l * 10;

    l := Round(l);
    for i := 1 to ndecimais do
        l := l / 10;

    write (l);

*)

    numero := simpleRoundTo(numero, -nDecimais);
    l := trunc (numero+0.000000000001);

    // Parte inteira

    if l > 2000000000 then
        sintsoletra (intToStr (l))
    else
        falaNumeroConv (numeroParaString (l), MASCULINO);

    if numero - trunc (numero) <> 0 then
        begin
            str (numero:tamVisor:ndecimais, s);
            podeFalar := false;
            for i := 1 to length (s) do
                begin
                    if s[i] = '.' then
                        begin
                            sintSoletra (',');  {virgula}
                            podeFalar := true;
                        end
                    else
                        if podeFalar then
                             falaNumeroConv (numeroParaString (ord(s[i]) and $f), MASCULINO);
                end;
        end;
end;

{
    l := numero;
    for i := 1 to ndecimais do
        l :=  l * 10;

    l := Round(l);
    for i := 1 to ndecimais do
        l := l / 10;
}


end.
