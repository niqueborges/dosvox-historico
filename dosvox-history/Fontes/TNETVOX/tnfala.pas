{--------------------------------------------------------}
{
{     Rotinas de fala
{
{     Autor: José Antonio Borges
{
{     Em abril/95
{
{--------------------------------------------------------}

unit tnfala;
interface

uses dvcrt, dvwin, tnMsg, tnVars, tnBufVid;

type str8 = string[8];

var
    falaTempInibida: boolean;

procedure acumulaTudo (c: char);
procedure despejaTudo;

procedure acumulaPalavra (c: char);
function letecla (npula: integer): char;

procedure leLinhaVideo (n: integer);
procedure lePedacoLinhaVideo (n, x1, x2: integer; soletrando: boolean);
procedure gravaPedacoLinhaVideo (n, x1, x2: integer; soletrando: boolean);
procedure buscaCampo (var xi, yi, xf, yf: integer);

implementation
uses tnansi;

var
    palavra: string;
    ultLetraFalada: char;
    nvezesFalada: integer;
    bufFalaTudo: string;

{--------------------------------------------------------}
{                   ve se tem vogais
{--------------------------------------------------------}

function temVogais (palavra: string): boolean;
const
    consoantes: set of char =
        ['b'..'d', 'f'..'h', 'j'..'n', 'p'..'t', 'v'..'z',
         'B'..'D', 'F'..'H', 'J'..'N', 'P'..'T', 'V'..'Z'];
var i: integer;
begin
    for i := 1 to length (palavra) do
        if not (palavra[i] in consoantes) then
             begin
                 temVogais := true;
                 exit;
             end;
    temVogais := false;
end;

{--------------------------------------------------------}
{           remove caracteres estranhos da fala
{--------------------------------------------------------}

procedure removeLixo (var s: string);
var bipa: boolean;
    i: integer;
begin
    bipa := false;
    for i := 1 to length (s) do
        if s[i] in [#$00..#$1f,
                    ':', ';', '.', '[', ']', '(', ')',
                    #$8c, #$91, #$92, #$9b..#$bf] then
            begin
                s[i] := ' ';
                bipa := true;
            end;

    if bipa then
        sintClek;
end;

{--------------------------------------------------------}
{                   acumula qualquer coisa
{--------------------------------------------------------}

procedure acumulaTudo (c: char);
begin
    bufFalaTudo := bufFalaTudo + c;
    if length (bufFalaTudo) > 200 then
        despejaTudo
    else
    if (length (bufFalaTudo) > 80) and (c <= ' ') then
        despejaTudo;
end;

{--------------------------------------------------------}
{                   fala tudo
{--------------------------------------------------------}

procedure despejaTudo;
begin
    sintetiza (bufFalaTudo);
    bufFalaTudo := '';
end;

{--------------------------------------------------------}
{                   acumula palavra
{--------------------------------------------------------}

procedure acumulaPalavra (c: char);
const ENTER = #$0d;
label fim;

begin
    if (c = ultLetraFalada) and (not (c in ['0'..'9'])) then
        begin
            if nvezesFalada > 10 then goto fim;
            nvezesFalada := nvezesFalada + 1;
            if (nvezesFalada > 2) and (c <> ' ') then
                c := ENTER;
        end
    else
        begin
            ultLetraFalada := c;
            nvezesFalada := 0;
        end;

    if c = #$1b then
        begin
            falaTempInibida := true;
            exit;
        end;

    if falaTempInibida then
         begin
             if (c in ['A'..'Z', 'a'..'z']) then
                falaTempInibida := false;
            exit;
         end;

    if c = #$08 then
        delete (palavra, length(palavra), 1)
    else
    if not ((c in ['a'..'z']) or (c in ['A'..'Z']) or (c in ['0'..'9']) or
            (c >= #128) ) then
        begin
            if c > #$20 then
                palavra := palavra + c;

            if palavra <> '' then
                if temVogais (palavra) then
                     begin
                         escBufVideo;
                         removeLixo (palavra);
                         sintetiza (palavra);
                     end
                else
                    sintSoletra (palavra);

            palavra := '';
        end
    else
        palavra := palavra + c;

fim:
    if c = ENTER then sintclek;
end;

{--------------------------------------------------------}
{              le uma tecla, pulando linhas
{--------------------------------------------------------}

function letecla (npula: integer): char;
var
    i: integer;
    c: char;
begin
    c := sintReadkey;
    write(c);
    for i := 1 to npula do writeln;
    letecla := c;
end;

{--------------------------------------------------------}
{    verifica linha inversa da tela anterior ao cursor
{--------------------------------------------------------}

procedure buscaCampo (var xi, yi, xf, yf: integer);
var
    x, y: integer;
label
     achouCampo, achouInicio, achouFim;

begin
    x := xi;
    y := yi;

    if (getScreenAttrib (x, y) and $f0) = 0 then
        begin
            x := x+1;
            if x > 80 then x := 80;
            if (getScreenAttrib (x, y) and $f0) = 0 then
                begin
                    x := x - 2;
                    if x < 1 then x := x + 1;
                end;
        end;

    while y <> 0 do
        begin
           if (getScreenAttrib (x, y) and $f0) <> 0 then
               goto achouCampo;

           x := x - 1;
           if x = 0 then
               begin
                   x := 80;
                   y := y - 1;
               end;

        end;

    sintBip;
    exit;   { nao achou }

achouCampo:
    xi := x;
    yi := y;

    while y <> 0 do
        begin
           if (getScreenAttrib (x, y) and $f0) = 0 then
               goto achouInicio;

           xi := x;
           yi := y;

           x := x - 1;
           if x = 0 then
               begin
                   x := 80;
                   y := y - 1;
               end;

        end;

achouInicio:

    xf := xi;
    yf := yi;
    x := xi;
    y := yi;

    while y <> 0 do
        begin
           if (getScreenAttrib (x, y) and $f0) = 0 then
               goto achouFim;

           xf := x;
           yf := y;

           x := x + 1;
           if x > 80 then
               begin
                   x := 1;
                   y := y - 1;
               end;

        end;

achouFim:
end;

{--------------------------------------------------------}
{                 le uma linha do video
{--------------------------------------------------------}

procedure lePedacoLinhaVideo (n, x1, x2: integer; soletrando: boolean);
var s: string;
    i: integer;
    tudoBranco: boolean;
    c: char;

begin
    if n < 1  then n := 1;
    if n > numLinhasTerm+1 then n := numLinhasTerm+1;

    tudoBranco := true;
    s := '';
    for i := x1 to x2 do
        begin
            c := getScreenChar (i, n);
            if c < #32 then c := ' ';
            s := s + c;
            if c <> ' ' then tudoBranco := false;
        end;

    if tudoBranco then
        sintclek
    else
        if soletrando then
            sintSoletra (s)
        else
            sintetiza (s);
end;

{--------------------------------------------------------}
{                 le uma linha do video
{--------------------------------------------------------}

procedure gravaPedacoLinhaVideo (n, x1, x2: integer; soletrando: boolean);
var s: string;
    i: integer;
    c: char;
    arq: text;
label erro;
begin
    if n < 1  then n := 1;
    if n > numLinhasTerm+1 then n := numLinhasTerm+1;

    s := '';
    for i := x1 to x2 do
        begin
            c := getScreenChar (i, n);
            s := s + c;
        end;

    assign (arq, nomeArqTelas);

    {$I-} reset (arq); {$I+}
    if ioresult <> 0 then
        begin
            {$I-}  rewrite (arq);   {$I+}
            if ioresult <> 0 then goto erro;
        end
    else
       begin
           close (arq);
           {$I-} append (arq); {$I+}
           if ioresult <> 0 then goto erro;
       end;

    for i := 1 to length (s) do
        if s[i] in [#0..#31] then s[i] := ' ';

    while (s <> '') and (s[length(s)] = ' ') do
        delete (s, length(s), 1);

    writeln (arq, s);
    close (arq);
    exit;

erro:
    msgBaixo ('TNERGRAV');  {'Erro de gravacao'}
    delay (1000);
    msgBaixo ('');
end;

{-------------------------------------------------------------}
{                le uma linha inteira do video
{-------------------------------------------------------------}

procedure leLinhaVideo (n: integer);
begin
    lePedacoLinhaVideo (n, 1, 80, false);
end;


begin
    palavra := '';
    falaTempInibida := false;
    ultLetraFalada := #$0;
    nvezesFalada := 0;
    bufFalaTudo := '';
end.
