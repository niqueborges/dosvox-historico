{--------------------------------------------------------}
{
{           FTPvox - conversores MIME 64
{
{    Autor: Neno Henrique da Cunha Albernaz - neno@intervox.nce.ufrj.br
{
{    Em 19/03/2023
{
{-------------------------------------------------------------}

Unit ftpDecod;

interface

uses
    classes,
    math,
    sysutils,
    DVcrt,
    DVWin;

function codFraseMime64 (bloco: string): string;
function DecodFraseMime64 (aConverter: string): string;

{--------------------------------------------------------}

implementation

const
    MIME64: array [0..63] of char =
       'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

{-------------------------------------------------------------}
{       codifica uma frase em mime64
{-------------------------------------------------------------}

function codFraseMime64 (bloco: string): string;
var
   s: string;
   lidos, guarda: integer;
   byteEnt: byte;
   noBloco, indBloco: integer;

begin
   lidos := 0;
   s := '';
   noBloco := length (bloco);
   indBloco := 1;
   guarda := 0;

   while noBloco <> 0 do
       begin
           byteEnt := ord(bloco [indBloco]);
           indBloco := indBloco + 1;
           noBloco := noBloco - 1;

           case lidos of
               0: begin
                      s := s + MIME64[byteEnt shr 2];
                      guarda := (byteEnt and 3) shl 4;
                  end;
               1: begin
                      s := s + MIME64[((byteEnt shr 4) and $f) or guarda];
                      guarda := (byteEnt and $f) shl 2;
                  end;
               2: begin
                      s := s + MIME64[((byteEnt shr 6) and $3) or guarda];
                      guarda := byteEnt and $3f;
                      s := s + MIME64[guarda];
                  end;
           end;
           lidos := (lidos + 1) mod 3;
       end;

   if lidos <> 0 then
       s := s + MIME64[guarda];

    while (length (s) mod 4) <> 0 do
        s := s + '=';

    result := s;
end;

{--------------------------------------------------------}
{       decodifica uma string em MIME64
{--------------------------------------------------------}

function DecodFraseMime64 (aConverter: string): string;
var
    bloco, grupo: integer;
    tabInvMIME: array [0..255] of byte;
    i: integer;
    caracEnt: char;
    posEnt: integer;
    byteSai: byte;
    saida: string;

begin
   for i := 0 to 255 do
       tabInvMIME [i] := 255;
   for i := 0 to 63 do
       tabInvMIME [ord(MIME64 [i])] := i;
   tabInvMIME [ord('=')] := 0;

   saida := '';

   bloco := 0;
   posEnt := 1;
   caracEnt := ' ';
   byteSai := 0;
   while (posEnt <= length (aConverter)) and (caracEnt <> '=') do
       begin
           caracEnt := aConverter[posEnt];
           posEnt := posEnt + 1;
           if (caracEnt =  ' ') or (caracEnt = '=') then
               continue;

           grupo := tabInvMIME [ord (caracEnt)];
           if grupo = 255 then continue;  {provavel erro}

           case bloco of
               0:    byteSai := grupo shl 2;
               1:    begin
                         byteSai := byteSai or ((grupo shr 4) and $f);
                         saida := saida + chr(byteSai);
                         byteSai := (grupo and $f) shl 4;
                     end;
               2:    begin
                         byteSai := byteSai or ((grupo shr 2) and $3f);
                         saida := saida + chr(byteSai);
                         byteSai := (grupo and 3) shl 6;
                     end;
               3:    begin
                         byteSai := byteSai or (grupo and $3f);
                         saida := saida + chr(byteSai);
                     end;
           end;

           bloco := (bloco + 1) mod 4;
       end;

   result := saida;
end;

{--------------------------------------------------------}
begin
end.
