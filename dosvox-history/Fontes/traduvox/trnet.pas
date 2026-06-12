{-------------------------------------------------------------}
{
{    Traduvox - tradutor de textos usando o Google Translator
{
{    Rotinas auxiliares para internet
{
{    Autor: José Antonio Borges
{
{    Atualizado por Patrick Barboza
{
{    Em dezembro/2023
{
{    Com a colaboração de Fabiano Ferreira
{
{-------------------------------------------------------------}

unit trnet;

interface

uses classes, sysUtils;

function utfToAnsi (s: string): string;
function ansiToUTF (s: string): string;
function stringToURL(s: string): string;
function subsCaracs(s: string) : string;

const
    MAXLINCABHTTP = 300;                        { maximo de linhas do cabecalho HTTP }
    BUFSIZE = 4096;                             { tamanho do buffer de rede }
    CRLF: string = #$0d+#$0a;                   { fim de linha }

var
    nlinCabecHTTP: integer;                     { numero de linhas do cabec. HTTP }
    cabecHTTP: array [1..MAXLINCABHTTP] of string;

implementation

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
end.
