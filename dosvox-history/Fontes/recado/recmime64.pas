{--------------------------------------------------------}
{                                                        }
{    Programa de envio e recepção de recados             }
{                                                        }
{    Módulo de codificação MIME                          }
{                                                        }
{    Autor: José Antonio Borges                          }
{                                                        }
{    Em novembro/2014                                    }
{                                                        }
{--------------------------------------------------------}

unit recmime64;

interface

procedure CodifMime64 (nomeArqBin, nomeArqCod: string);
function codFraseMime64 (bloco: string): string;
function DecodMime64 (nomeArqOrig, nomeArqBin: string): boolean;
function DecodFraseMime64 (aConverter: string): string;
function codificaAssuntoMime64 (s: string): string;

implementation

const
    MIME64: array [0..63] of char =
       'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

{--------------------------------------------------------}
{       codifica um arquivo em MIME64
{--------------------------------------------------------}

procedure CodifMime64 (nomeArqBin, nomeArqCod: string);
var
   lidos, guarda: integer;
   byteEnt: byte;
   gravados: integer;
   s: string [80];
   bloco: array [0..1023] of byte;
   noBloco, indBloco: integer;

   arqBin: file;
   arqCod: textFile;

label erro;

begin
   assignFile (arqBin, nomeArqBin);
   reset (arqBin, 1);
   assignFile (arqCod, nomeArqCod);
   rewrite (arqCod);

   lidos := 0;
   gravados := 0;
   s := '';
   noBloco := 0;
   indBloco := 0;
   guarda := 0;

   while not eof (arqBin) do
       begin
           if noBloco = 0 then
               begin
                   {$I-} blockread (arqBin, bloco, 1024, noBloco); {$I-}
                   if ioresult <> 0 then goto erro;
                   indBloco := 0;
              end;

           while noBloco <> 0 do
               begin
                   byteEnt := bloco [indBloco];
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
                              gravados := gravados + 1;
                              guarda := byteEnt and $3f;
                              s := s + MIME64[guarda];
                          end;
                   end;
                   lidos := (lidos + 1) mod 3;
                   gravados := (gravados + 1) mod 64;

                   if gravados = 0 then
                       begin
                           writeln (arqCod, s);
                           s := '';
                       end;
               end;
       end;

   if lidos <> 0 then
       s := s + MIME64[guarda];

erro:
    while (length (s) mod 4) <> 0 do
        s := s + '=';
    if length (s) <> 0 then
        writeln (arqCod, s);

    closeFile (arqBin);
    closeFile (arqCod);
end;

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

    codFraseMime64 := s;
end;

{--------------------------------------------------------}
{       decodifica um arquivo em MIME64
{--------------------------------------------------------}

function DecodMime64 (nomeArqOrig, nomeArqBin: string): boolean;
var
    bloco, grupo: integer;
    tabInvMIME: array [0..255] of byte;
    i: integer;
    caracEnt: char;
    byteSai: byte;
    arqOrig: text;
    arqBin: file;

    buf: array [0..1023] of byte;
    posBuf: integer;

{-------------------------------------------------------------}

   function escBuf (b: byte): boolean;
   begin
       escBuf := true;
       buf[posBuf] := b;
       posBuf := posBuf + 1;
       if posBuf >= 1024 then
           begin
               {$I-}  blockWrite (arqBin, buf, 1024);  {$I+}
               if ioresult <> 0 then
                   escBuf := false;
               posBuf := 0;
           end;
   end;

{-------------------------------------------------------------}

    function flushBuf: boolean;
    begin
        flushBuf := true;
        if posBuf <> 0 then
            begin
                {$I-} blockWrite (arqBin, buf, posBuf);  {$I+}
                if ioresult <> 0 then
                    flushBuf := false;
            end;
        posBuf := 0;
    end;

label erro, proximo;
begin
   decodMime64 := false;

   for i := 0 to 255 do
       tabInvMIME [i] := 255;
   for i := 0 to 63 do
       tabInvMIME [ord(MIME64 [i])] := i;
   tabInvMIME [ord('=')] := 0;

   posBuf := 0;
   assign (arqOrig, nomeArqOrig);
   {$I-} reset (arqOrig);  {$I+}
   if ioresult <> 0 then goto erro;
   assign (arqBin, nomeArqBin);
  {$I-} rewrite (arqBin, 1);  {$I+}
   if ioresult <> 0 then goto erro;

   bloco := 0;
   caracEnt := ' ';
   posBuf := 0;
   byteSai := 0;
   while (not eof (arqOrig)) and (caracEnt <> '=') do
       begin
           read (arqOrig, caracEnt);
           if (caracEnt = #$0d) or (caracEnt = #$0a) or
              (caracEnt =  ' ') or (caracEnt =  '=') then
               goto proximo;

           grupo := tabInvMIME [ord (caracEnt)];
           if grupo = 255 then goto proximo;  {provavel erro no arquivo}

           case bloco of
               0:    byteSai := grupo shl 2;
               1:    begin
                         byteSai := byteSai or ((grupo shr 4) and $f);
                         if not escBuf (byteSai) then goto erro;
                         byteSai := (grupo and $f) shl 4;
                     end;
               2:    begin
                         byteSai := byteSai or ((grupo shr 2) and $3f);
                         if not escBuf (byteSai) then goto erro;
                         byteSai := (grupo and 3) shl 6;
                     end;
               3:    begin
                         byteSai := byteSai or (grupo and $3f);
                         if not escBuf (byteSai) then goto erro;
                     end;
           end;

           bloco := (bloco + 1) mod 4;
proximo:
        end;

   if not flushBuf then goto erro;
   decodMime64 := true;

erro:
   {$I-} close (arqOrig);  {$I+}
   if ioresult <> 0 then;
   {$I-} close (arqBin);  {$I+}
   if ioresult <> 0 then;
end;

{--------------------------------------------------------}
{       decodifica um arquivo em MIME64
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

   DecodFraseMime64 := saida;
end;

{-------------------------------------------------------------}
{             codifica assunto
{-------------------------------------------------------------}

function codificaAssuntoMime64 (s: string): string;
begin
    s := codFraseMime64 (s);
    result := '=?iso-8859-1?B?' + s + '?=';
end;

end.

