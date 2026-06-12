{------------------------------------------------------}
{
{    PyVox - interface sonora para Python
{
{    Módulo de tradução de mensagens
{
{    Por Patrick Barboza
{
{    Baseado no código reescrito para o traduvox
{
{    Em 17/05/2024
{
{------------------------------------------------------}

unit pyTrad;

interface
uses
  dvwin,
  dvcrt,
  dvinet,
  winsock,
  sysUtils,
  classes;

function abreGoogle: boolean;
procedure fechaGoogle;
function traduzFraseGoogle (aTraduzir: string; var traduzido: string): string;

implementation

const
    MAXLINCABHTTP = 300;                        { maximo de linhas do cabecalho HTTP }
    BUFSIZE = 4096;                             { tamanho do buffer de rede }
    CRLF: string = #$0d+#$0a;                   { fim de linha }

var
    sock: integer;
    pbuf: PbufRede;
    nlinCabecHTTP: integer;                     { numero de linhas do cabec. HTTP }
    cabecHTTP: array [1..MAXLINCABHTTP] of string;

{-------------------------------------------------------------}

function subsCaracs(s: string) : string;
begin
    s := stringReplace(s,'&#39;','''',[rfreplaceall]);
    s := stringReplace(s,'&quot;','"',[rfreplaceall]);
    result := trim(s);
end;

function utfToAnsi (s: string): string;
var b, b2: byte;
    s2: string;
    i: integer;
begin
    s2 := '';
    s := s + ' ';
    i := 1;
    while i <= length (s) - 1 do
        begin
            b := ord(s[i]);
            if (b < $80) or ((b and $e0) <> $c0)then
                s2 := s2 + s[i]
            else
                begin
                    b2 := ord (s[i+1]) and $3f;
                    b := (b and $03) shl 6;
                    s2 := s2 + chr(b or b2);
                    i := i + 1;
                end;
            i := i + 1;
        end;
    utfToAnsi := s2;
end;

function ansiToUTF (s: string): string;
var b: byte;
    s2: string;
    i: integer;
begin
    s2 := '';
    for i := 1 to length (s) do
        begin
            b := ord(s[i]);
            if b <= $7f then
                s2 := s2 + s[i]
            else
                s2 := s2 + chr ($c0 or ((b shr 6) and $3f)) +
                           chr ($80 or (b and $3f));
        end;
    ansiToUTF := s2;
end;

{--------------------------------------------------------}
{
{   transforma string para a codificação usada em URLs
{
{--------------------------------------------------------}

function stringToURL(s: string): string;
var i: integer;
begin
    result := '';
    for i := 1 to length(s) do
        begin
            if s[i] in ['0'..'9', 'a'..'z', 'A'..'Z', '.', '-', '_', '~'] then
                result := result + s[i]
            else
                result := result + '%' + intToHex(ord(s[i]), 2);
        end;
end;

{--------------------------------------------------------}
{
{   transforma string para a codificação usada em URLs
{
{--------------------------------------------------------}

function URLToString(s: string): string;

    function hex(c: char): integer;
    begin
        if c in ['0'..'9'] then result := ord(c) - ord('0')
        else
        if c in ['a'..'f'] then result := ord(c) - ord('a') + 10
        else
        if c in ['A'..'F'] then result := ord(c) - ord('A') + 10
        else
            result := 0;
    end;

var i, n: integer;

begin
    result := '';
    i := 1;
    while i <= length(s) do
        begin
            if (s[i] = '%') and (i <= length(s)-2) then
                begin
                    n := (hex(s[i+1]) shl 4) + hex(s[i+1]);
                    result := result + chr(n);
                    i := i + 3;
                end
            else
                begin
                    result := result + s[i];
                    i := i + 1;
                end;
        end;
end;

{-------------------------------------------------------------}

function abreGoogle: boolean;
begin
    abreGoogle := false;
    pbuf := NIL;
    abreWinSock;
    sock := abreConexaoSsl ('translate.google.com', 443);
    if sock <= 0 then
        begin
            sintWriteln ('O tradutor do Google na Internet está inacessível.');
            exit;
        end;

    pbuf := inicBufRede(sock);
    abreGoogle := true;
end;

{-------------------------------------------------------------}

procedure fechaGoogle;
begin
    if pbuf <> NIL then
        begin
            fimBufRede(pbuf);
            closeSocket (sock);
            pbuf := NIL;
        end;
    fechaWinsock;
end;

{-------------------------------------------------------------}

function removeUnicodes (s: string): string;
var cod, s2: string;
    i, j: integer;
begin
    i := 1;
    s2 := '';
    while i <= length (s) do
        begin
            if (i < length(s) - 6) and (copy (s, i, 6) = '\u0026') then
                begin
                    for j := i+6 to length(s) do
                        if s[j] = ';' then break;   // assumindo sempre códigos bem formados
                    cod := copy (s, i+6, j-i-6);
                    if cod = '' then cod := ' ';    // prevenindo...

                    if cod[1] = '#'  then begin
                                               delete (cod, 1, 1);
                                               s2 := s2 + chr(strToInt (cod));
                                          end
                    else
                    if cod = 'quot' then s2 := s2 + '"'
                    else
                    if cod = 'amp'  then s2 := s2 + '&'
                    else
                    if cod = 'lt'   then s2 := s2 + '<'
                    else
                    if cod = 'gt'   then s2 := s2 + '>'
                    else
                        s2 := s2 + copy (s, i, length (cod)+1);
                    i := j + 1;
                end
            else
            if (i < length(s) - 4) and (copy (s, i, 4) = '\u00') then
                begin
                    cod := copy (s, i+4, 2);
                    hexToBin (@cod[1], @j, sizeof (j));
                    s2 := s2 + chr(j);
                    i := i + 6;
                end
            else
                begin
                    s2 := s2 + s[i];
                    i := i + 1;
                end;
        end;

    result := s2;
end;

{-------------------------------------------------------------}

function traduzFraseGoogle (aTraduzir: string; var traduzido: string): string;
var
    s, status: string;
    p: integer;
const
    nomePag = 'translate.google.com';
    linguaOrig = 'en';
    linguaDest = 'pt';

begin
    traduzido := '';
    aTraduzir := stringtourl(ansitoutf(aTraduzir));
    s :=   'GET /m?sl='+linguaOrig+'&tl='+linguaDest+'&q='+aTraduzir+'&op=translate HTTP/1.1'             + CRLF +
        'Host: '+nomePag + CRLF +
        'Connection: Close'                      + CRLF +
        'Accept: */*'                 + CRLF +
        'Accept-Encoding: identity'                 + CRLF +
        'UA-CPU: x86'                            + CRLF +
        'User-Agent: Webvox'                 + CRLF;

    //Assume que a rede está pronta (antes foi preparada usando abreGoogle)
    writelnRede (sock, s);

    {*
     *  Traz cabeçalho da mensagem
     *}
    nlinCabecHTTP := 0;

    if not readlnBufRede (pbuf, s, 10) then
        s := '';
    status := s;

    {*  Primeira linha: código da resposta *}

    delete (status, 1, pos (' ', status));
    result := status;

    {* Armazena todas as linhas do cabecalho *}

    while s <> '' do
    begin
        inc(nlinCabecHTTP);
        cabecHTTP[nlinCabecHTTP] := s;
        if not readlnBufRede (pbuf, s, 10) then
            s := '';
    end;

    // Traz dados após o cabeçalho
    while readlnBufRede (pbuf, s, 10) and (s <> '') do
    begin
        traduzido := traduzido + s;
    end;

    if (copy (status, 1, 3) <> '200') then
        exit;

    {*  Procura e extrai texto traduzido *}
    p := pos ('"result-container">', traduzido);
    if (p <> 0) then
    begin
        p := p + 19;
        traduzido := copy(traduzido,p,length(traduzido)-p+1);
        traduzido := copy (traduzido,1,pos('<',traduzido)-1);
        traduzido := utfToAnsi(traduzido);
        traduzido := subsCaracs(traduzido);
    end
    else
        traduzido := '';
    end;

end.
