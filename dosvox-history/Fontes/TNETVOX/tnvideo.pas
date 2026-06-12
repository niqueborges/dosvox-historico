{-------------------------------------------------------------}
{
{    Telnet Falado
{
{    Le pedacos do video
{
{    Autor: Jose' Antonio Borges
{
{    Em 10/01/99
{
{-------------------------------------------------------------}

unit tnvideo;
interface
uses
    winprocs, dvcrt, sysUtils, dvWin,
    tnvars, videovox, tnMsg;

procedure salvaTela;
procedure restauraTela;
function qualLinhaInversa (primeira, ultima: integer): integer;
procedure leLinhaVideo (n: integer);

implementation

type
    vet = array [1..31, 1..80] of byte;
var
    vetTela, vetAttr: ^vet;
    salvax, salvay, salvaAttr: integer;

{--------------------------------------------------------}
{              encontra linha invertida na tela
{--------------------------------------------------------}

function qualLinhaInversa (primeira, ultima: integer): integer;
var x, y: integer;
begin
    for y := primeira to ultima do   { geralmente 1 a 24 }
        for x := 1 to 80 do
            if (getScreenAttrib (x, y) and $e0) <> 0 then
                 begin
                     qualLinhaInversa := y;
                     exit;
                 end;

    qualLinhaInversa := -1;
end;

{--------------------------------------------------------}
{            le toda uma linha do video
{--------------------------------------------------------}

procedure leLinhaVideo (n: integer);
var s: string;
    i: integer;
    tudoBranco: boolean;
    c: char;

begin
    if (n < 1) or (n > numLinhasTerm) then exit;

    tudoBranco := false;
    s := '';
    for i := 0 to 79 do
        begin
            c := getScreenChar (i+1, n);
            s := s + c;
            if c <> ' ' then tudoBranco := false;
        end;

    if tudoBranco then
        sintClek
    else
        sintetiza (s);

    sintClek;
end;

{-------------------------------------------------------------}
{                     salva a tela
{-------------------------------------------------------------}

procedure salvaTela;
var x, y: integer;
begin
    salvaAttr := textAttr;
    salvax := wherex;
    salvay := wherey;
    new (vetTela);
    new (vetAttr);
    for y := 1 to numLinhasTerm+1 do
        for x := 1 to 80 do
             begin
                 vetTela^[y, x] := ord(getScreenChar (x, y));
                 vetAttr^[y, x] := getScreenAttrib (x, y);
             end;
end;

{-------------------------------------------------------------}
{                     restaura a tela
{-------------------------------------------------------------}

procedure restauraTela;
var x, y, xm: integer;
    s: string;
begin
    window (1, 1, 80, numLinhasTerm+1);
    textAttr := LIGHTGRAY;
    clrscr;
    textBackground (BLUE);
    gotoxy (52, numLinhasTerm+1);
    mensagem ('TNTECF4', 0);      {'Tecle ALT F4 para desligar'}

    gotoxy (1, 1);

    for y := 1 to numLinhasTerm+1 do
        begin
            s := '';
            xm := 80;
            if y = numLinhasTerm+1 then xm := 79;
            for x := 1 to xm do
                 begin
                     if vetAttr^[y, x] <> textAttr then
                         begin
                             if s <> '' then write (s);
                             s := '';
                             textAttr := vetAttr^[y, x];
                         end;
                     s := s + (chr(vetTela^[y, x]));
                 end;
            if s <> '' then write (s);
        end;

    textAttr := salvaAttr;
    window (1, 1, 80, numLinhasTerm);
    gotoxy (salvax, salvay);

    dispose (vetTela);
    dispose (vetAttr);
end;

end.
