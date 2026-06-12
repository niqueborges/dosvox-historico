unit brutil;

interface

uses dvcrt, dvwin, brvars, brmsg, SysUtils, Classes;

var
   txtIngles: boolean;

function convMinusc (c: char): char;
function cnvhexa (c1, c2: char): byte;
function carregaTabBraille: boolean;

implementation

{--------------------------------------------------------}
{             converte uma letra para minuscula
{--------------------------------------------------------}

function convMinusc (c: char): char;
begin
    if c in ['A'..'Z'] then
        c := chr (ord(c) + $20)
    else

    if c in [#$c0..#$df] then
        c := chr (ord(c) + $20);

    convMinusc := c;
end;

{--------------------------------------------------------}
{             converte um caracter para exadecimal
{--------------------------------------------------------}

function cnvhexa (c1, c2: char): byte;
var v1, v2: integer;
begin
    c1 := upcase (c1);
    c2 := upcase (c2);

    if c1 >= 'A' then
        v1 := ord (c1) - ord ('A') + 10
    else
        v1 := ord (c1) - ord ('0');

    if c2 >= 'A' then
        v2 := ord (c2) - ord ('A') + 10
    else
        v2 := ord (c2) - ord ('0');

    cnvhexa := (v1 shl 4) or v2;
end;

{--------------------------------------------------------}
{             Carrega a tabela Braille
{--------------------------------------------------------}

function carregaTabBraille: boolean;
var
    arqConfig: text;
    linha, i: integer;
    s: string[255];
    nomeAmb: string;

label proxima, erro;

begin
    for i := 0 to 255 do
        tabPrinter [chr(i)] := i;
    if usaBrailleAntigo   then nomeAmb := nomeAmBCode
                          else nomeAmb := nomeAmBCode2;
    assignFile (arqConfig, nomeAmb);

    {$I-}  reset (arqConfig);   {$I+}
    if ioresult <> 0 then
        begin
           writeln;
           sintWriteln (nomeAmb);
           mensagem ('BRCNFERR', 1);  {'Arquivo de configuração inexistente, programa cancelado'}
           carregaTabBraille := false;
           exit;
        end;

    linha := 0;
    while not eof (arqConfig) do
        begin
            linha := linha + 1;
            {$I-} readln (arqConfig, s); {$I+}

            if (s = '') or (s[1] = '*') then
                goto proxima;

            if s[3] <> '=' then goto erro;

            i := cnvhexa (s[1], s[2]);
            tabPrinter [chr(i)] := cnvHexa (s[4], s[5]);
            if (ioresult <> 0) or (i < 0) or (i > 255) then
                goto erro;
proxima:
        end;

    closeFile (arqConfig);
    carregaTabBraille := true;
    exit;

    {-----------------}

erro:
    closeFile (arqConfig);
    mensagem ('BRERRLIN', 0);   { 'Erro no arquivo de configuração na linha ' }
    sintWriteint (linha);
    writeln;

    carregaTabBraille := false;
end;

end.

