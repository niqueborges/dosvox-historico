{--------------------------------------------------------}
{
{    Programa para emissão de cheques
{
{    Módulo de rotinas utilitárias
{
{    Autor: Antonio Borges
{
{    Em Agosto de 2001
{
{--------------------------------------------------------}

{$N+}

unit chUtil;

interface
uses dvcrt, dvwin, dvlenum, windows, chvars, chmsg;

function int2 (x: byte): string;
function int2str (v: longint): string;
procedure incrementaNumCheque (n: string);
function consisteData (dt: string): boolean;
function consisteConvValor (v: string; var valorDoc: double): boolean;
function porExtenso (valorConvDoc: double): string;
function poeZeroZero (valorDoc: string): string;

implementation

const
    tabint: array [0..9] of char = ('0','1','2','3','4','5','6','7','8','9');

function int2 (x: byte): string;
begin
    int2 := tabint [x div 10] + tabint [x mod 10];
end;

{-------------------------------------------------------------}

function int2str (v: longint): string;
var s: string;
begin
    s := '';
    while v <> 0 do
         begin
             s := tabint [v mod 10] + s;
             v := v div 10;
         end;
    if s = '' then
        int2Str := '0'
    else
        int2Str := s;
end;

{--------------------------------------------------------}

procedure incrementaNumCheque (n: string);
var l: longint;
    n2: string;
    erro: integer;
begin
    val (n, l, erro);
    if erro = 0 then
        begin
            l := l + 1;
            str (l, n2);
            while length (n2) < length (n) do
                n2 := '0' + n2;
            n := n2;
        end
    else
        n := 'próximo de ' + n;
end;

{--------------------------------------------------------}

function consisteData (dt: string): boolean;
const
    tabdiames: array [1..12] of integer = (31, 29, 31, 30, 31, 30,
                                           31, 31, 30, 31, 30, 31);
var
    erro, d, m, a: integer;
    s: string;
begin
    consisteData := false;
    if length (dt) <> 10 then exit;
    if (dt[3] <> '/') or (dt[6] <> '/') then exit;

    s := copy (dt, 1, 2);
    val (s, d, erro);
    if (erro <> 0) or (d < 1) or (d > 31) then exit;

    s := copy (dt, 4, 2);
    val (s, m, erro);
    if (erro <> 0) or (m < 1) or (m > 12) then exit;
    if d > tabdiames[m] then exit;

    s := copy (dt, 7, 4);
    val (s, a, erro);
    if (erro <> 0) or (a < 2000) or (a > 2080) then exit;

    consisteData := true;
end;

{--------------------------------------------------------}

function consisteConvValor (v: string; var valorDoc: double): boolean;
var
    p1, p2, pErro: integer;
label retErro;
begin
    p1 := pos ('.', v);
    p2 := pos (',', v);

    if (p1 <> 0) and (p2 <> 0) then
        goto retErro;

    if p2 <> 0 then
         begin
             v[p2] := '.';
             p1 := p2;
         end;

    if (p1 = 0) or (p1 <> (length (v) - 2)) then
        goto retErro;

    val (v, valorDoc, pErro);
    if pErro <> 0 then goto retErro;
    if valorDoc < 0.0 then goto retErro;

    consisteConvValor := true;
    exit;

retErro:
    consisteConvValor := false;
    valorDoc := 0;
end;

{--------------------------------------------------------}

function porExtenso (valorConvDoc: double): string;
var
    extenso: string;
    n1, n2: longint;

begin
    n1 := trunc(valorConvDoc);
    n2 := trunc(frac(valorConvDoc+0.005) * 100);

    if n1 = 0 then
        begin
            if n2 = 0 then
                extenso := 'zero ' + moedas
            else
            if n2 = 1 then
                extenso := 'um centavo'
            else
                extenso := numeroParaString (n2) + ' centavos';
        end
    else
        begin
            if n1 = 1 then
                extenso := 'um ' + moeda
            else
                begin
                    extenso := numeroParaString (n1);
                    if extenso [length (extenso)] = ' ' then
                        delete (extenso, length(extenso), 1);

                    if ((n1 mod 1000000) = 0) and (n1 >= 1000000) then
                        extenso := extenso + ' de ' + moedas
                    else
                        extenso := extenso + ' ' + moedas;
                end;

            if n2 <> 0 then
                if n2 = 1 then
                    extenso := extenso + ' e um centavo'
                else
                    extenso := extenso + ' e ' + numeroParaString (n2) + ' centavos';
        end;

    extenso[1] := upcase (extenso[1]);
    porExtenso := extenso;
end;

{--------------------------------------------------------}

function poeZeroZero (valorDoc: string): string;
var i: integer;
begin
   poeZeroZero := valorDoc;
   if valorDoc = '' then exit;
   for i := 1 to length (valorDoc) do
       if not (valorDoc[i] in ['0'..'9']) then exit;
   poeZeroZero := valorDoc + ',00';
end;

end.
