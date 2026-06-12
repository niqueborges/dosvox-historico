{-------------------------------------------------------------}
{
{    Webvox - Módulo de tratamento do cabecalho
{
{    Autor: Jose' Antonio Borges
{
{    Em 14/05/98
{
{-------------------------------------------------------------}

unit webCabec;

interface
uses windows, sysUtils, shellApi,
     dvcrt, dvWin, dvInet, winsock, dvssl,
     webVars, webMsg;

function trazCabecHTTP: integer;   { retorna codigo de erro }
function buscaInfoCabec (texto: string): string;
procedure debugCabec;

implementation

{-------------------------------------------------------------}
{                 pega um caractere do buffer
{-------------------------------------------------------------}

function leCaracBuf (var c: char): boolean;
begin
    if posBufRecebe >= lidosBufRecebe then
         begin
             repeat
                 if keypressed then
                     if readkey = #$1b then
                         begin
                             mensagem ('WBRECINT', 1);
                             leCaracBuf := false;
                             exit;
                         end
                     else
                         begin
                             write (#$0d);
                             sintWriteInt (0);
                             write ('  ');
                         end;
             until chegouRede (sockHTTP);
             lidosBufRecebe := receiveBuf (sockHTTP, bufRecebe, BUFSIZE, 0);
             posBufRecebe := 0;
         end;

    if lidosBufRecebe > 0 then
         begin
             c := bufRecebe [posBufRecebe];
             posBufRecebe := posBufRecebe + 1;
             leCaracBuf := true;
         end
    else
         begin
             c := #$0a;   {line feed}
             leCaracBuf := false;
         end;
end;

{-------------------------------------------------------------}
{         pega uma cadeia terminada por CRLF do buffer
{-------------------------------------------------------------}

function leStringBuf (var s: string): boolean;
var c: char;
begin
    leStringBuf := true;
    s := '';
    repeat
         if leCaracBuf (c) then
             s := s + c
         else
             begin
                 leStringBuf := false;
                 exit;
             end;
    until c = #$0a;

    if s = '' then exit;
    if s[length (s)] = #$0a then delete (s, length (s), 1);
    if s = '' then exit;
    if s[length (s)] = #$0d then delete (s, length (s), 1);
end;

{-------------------------------------------------------------}
{                    Isola o cabecalho HTTP
{-------------------------------------------------------------}

function trazCabecHTTP: integer;   { retorna codigo de erro }
var
    s: string;
    n, i, p: integer;

label erro, fimCabec;

begin
    nlinCabecHTTP := 0;

    lidosBufRecebe := 32766;
    posBufRecebe := 32766;

    for i := 1 to MAXLINCABHTTP do
        begin
            if not leStringBuf (cabecHTTP[i]) then
                goto erro;

            if cabecHTTP [i] = '' then
                 begin
                     nlinCabecHTTP := i-1;
                     goto fimCabec;
                 end;

(*
            if debug then
                begin
                    textBackGround (BROWN);
                    writeln (cabecHTTP [i]);
                    textBackGround (BLACK);
                end;
*)
        end;

fimCabec:

{ descobre codigo de retorno }

    if nlinCabecHTTP > 0 then
        begin
            s := cabecHTTP [1];
            p := 1;
            while (p <= length (s)) and (s[p] <> ' ') do
                p := p + 1;

            p := p+1;
            n := 0;
            while (p <= length (s)) and (s[p] in ['0'..'9']) do
                begin
                    n := n * 10 + ord (s[p]) - ord ('0');
                    p := p + 1;
                end;

            trazCabecHttp := n;
        end
    else
        begin
erro:
            trazCabecHTTP := 504;   { simula gateway timeout }
            cabecHTTP [1] := 'HTTP/1.0 504 Conexão não estabelecida';
        end;
end;

{-------------------------------------------------------------}
{                busca uma informacao no cabecalho
{-------------------------------------------------------------}

function buscaInfoCabec (texto: string): string;
var s: string;
    i, n: integer;
label pula, erro, achou;
begin
    for n := 1 to nlinCabecHTTP do
        begin
            s := cabecHTTP [n];
            for i := 1 to length (texto) do
                if upcase (texto[i]) <> upcase (s[i]) then
                    goto pula;
            goto achou;
pula:;
        end;

    buscaInfoCabec := '';
    exit;

achou:

    n := length (texto);
    s := copy (s, n+1, length(s)-n);

    while (s <> '') and (s[1] = ' ') do
        delete (s, 1, 1);
    if (s <> '') and (s[1] = '"') then
        delete (s, 1, 1);
    if (s <> '') and (s[length (s)] = '"') then
        delete (s, length(s), 1);

    buscaInfoCabec := s;
end;

{-------------------------------------------------------------}
{                  mostra o cabecalho
{-------------------------------------------------------------}

procedure debugCabec;
var n: integer;
begin
    textBackground (RED);
    for n := 1 to nlinCabecHTTP do
        writeln (cabecHTTP [n]);
    textBackground (BLACK);

    sintWriteln ('Tecle enter');
    readln;
end;

end.