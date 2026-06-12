{--------------------------------------------------------}
{
{           Cartavox - Reformata��es e conversores MIME 64
{
{--------------------------------------------------------}

Unit carDecod;

interface

uses
    classes,
    math,
    sysutils,
    DVcrt,
    DVWin,
    carMsg,
    carVars;

function convQuotedPrintable (s: string): string;
function convYahoo (s: string): string;
function utfToAnsi (s: string): string;
procedure decodificarString (var s: string);
function codificarString (s: string): string;
function decodArqUtfToAnsi (nomeArq: string): boolean;

procedure CodifMime64;
function DecodMime64 (nomeArqOrig, nomeArqBin: string): boolean;
function codFraseMime64 (bloco: string): string;
function DecodFraseMime64 (aConverter: string): string;

{--------------------------------------------------------}

implementation

const
    MIME64: array [0..63] of char =
       'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

{-------------------------------------------------------------}
{       Testa se um caracter � hexa
{-------------------------------------------------------------}

function eHexa (c: char): boolean;
begin
    eHexa := c in ['0'..'9', 'a'..'f', 'A'..'F'];
end;

{-------------------------------------------------------------}
{       remove especificacoes quoted printable
{-------------------------------------------------------------}

function convQuotedPrintable (s: string): string;
var i: integer;
    sai: string;

    function conv16 (c: char): integer;
    begin
        if c in ['0'..'9'] then  conv16 := ord (c) - ord ('0')
        else
        if c in ['A'..'F'] then  conv16 := ord (c) - ord ('A') + 10
        else
        if c in ['a'..'f'] then  conv16 := ord (c) - ord ('a') + 10
        else
            conv16 := 0;
    end;

begin
    sai := '';
    i := 1;
    if (s <> '') and (s[length(s)] = '=') then
                                          // Antonio     and (pos ('?=', s) = 0)
        delete (s, length (s), 1);

    while i <= length (s) do
        begin
            if (i <= length(s)-2) and
               (s[i] = '=') and eHexa(s[i+1]) and eHexa(s[i+2]) then
                begin
                    sai := sai + chr ((conv16 (s[i+1]) shl 4) + conv16 (s[i+2]));
                    i := i + 3;
                end
            else
                begin
                    sai := sai + s[i];
                    i := i + 1;
                end;
        end;

    convQuotedPrintable := sai;
end;

{-------------------------------------------------------------}
{       Retorna true se a string est� em UTF-8
{-------------------------------------------------------------}

(*NenoNenofunction detectaUTF (s: string): boolean;
begin
    result := (pos('﻿', s) = 1) or
              (pos('�' , s) <> 0) or
              (pos('�' , s) <> 0) or 
              (pos('�', s) <> 0) or
              (pos('�', s) <> 0) or
              (pos('�', s) <> 0) or
              (pos('�', s) <> 0) or
              (pos('�', s) <> 0) or
              (pos('�', s) <> 0);
end;
NenoNeno*)

function detectaUTF (s: string): boolean; //Melhorada pelo Glauco FC
begin
    result := (pos('¨', s) <> 0) or
              (pos('�#', s) <> 0) or
              (pos('æ', s) <> 0) or
              (pos('º', s) <> 0) or
              (pos('×', s) <> 0) or
              (pos('´', s) <> 0) or
              (pos('¿', s) <> 0) or
              (pos(' ', s) <> 0) or
              (pos('¡', s) <> 0) or
              (pos('Û', s) <> 0) or
              (pos('Ü', s) <> 0) or
              (pos('ç', s) <> 0) or
              (pos('è', s) <> 0) or
              (pos('é', s) <> 0) or
              (pos('ê', s) <> 0) or
              (pos('ë', s) <> 0) or
              (pos('ì', s) <> 0) or
              (pos('í', s) <> 0) or
              (pos('î', s) <> 0) or
              (pos('ï', s) <> 0) or
              (pos('ò', s) <> 0) or
              (pos('ó', s) <> 0) or
              (pos('ô', s) <> 0) or
              (pos('ù', s) <> 0) or
              (pos('ú', s) <> 0) or
              (pos('û', s) <> 0) or
              (pos('ü', s) <> 0) or
              (pos('à', s) <> 0) or
              (pos('Ä', s) <> 0) or
              (pos('Ã', s) <> 0) or
              (pos('õ', s) <> 0) or
              (pos('Î', s) <> 0) or
              (pos('ö', s) <> 0) or
              (pos('Ï', s) <> 0) or
              (pos('Ç', s) <> 0) or
              (pos('À', s) <> 0) or
              (pos('Ê', s) <> 0) or
              (pos('Â', s) <> 0) or
              (pos('É', s) <> 0) or
              (pos('È', s) <> 0) or
              (pos('Í', s) <> 0) or
              (pos('á', s) <> 0) or
              (pos('Ë', s) <> 0) or
              (pos('Ì', s) <> 0) or
              (pos('ä', s) <> 0) or
              (pos('Õ', s) <> 0) or
              (pos('â', s) <> 0) or
              (pos('Ô', s) <> 0) or
              (pos('Ó', s) <> 0) or
              (pos('Ù', s) <> 0) or
              (pos('ã', s) <> 0) or
              (pos('Á', s) <> 0) or
              (pos('Ö', s) <> 0) or
              (pos('Ú', s) <> 0) or
              (pos('Ò', s) <> 0);
end;

{-------------------------------------------------------------}
{       converte de UTF-8 para Ansi
{-------------------------------------------------------------}

function utfToAnsi (s: string): string;
var b, b2: byte;
    s2: string;
    i: integer;
begin
    if not detectaUTF (s) then //quando n�o tem n�o deve decodificar
        begin
            utfToAnsi := s;
            exit;
        end;

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

{-------------------------------------------------------------}
{       converte do formato da Yahoo
{-------------------------------------------------------------}

function convYahoo (s: string): string;
var i: integer;
begin
    for i := length(s)-3 downto 1 do
        if copy (s, i, 2) = '��' then
            delete (s, i, 3);
    convYahoo := s;
end;

{-------------------------------------------------------------}
{       Converte hexa em char (ascii) - usa a unidade Math
{-------------------------------------------------------------}

function Hexatoascii(ctr: string): char;
var
    s, n: string;
    i, xpo: integer;
    v, tt: integer;
begin
    //Separa caracteres;
    s := ctr;
    i := Length(s);
    tt := 0;
    xpo := 0;
    while i > 0 do
        begin
            n := uppercase (Copy(s, i, 1));
            if (n >= 'A') and (n <= 'F') then
                begin
                    if n = 'A'then v := 10
                    else if n =         'B' then v := 11
                    else if n = 'C' then v := 12
                    else if n = 'D' then v := 13
                    else if n = 'E' then v := 14
                    else if n = 'F' then v := 15;
                end
            else
                v := StrToInt(n);

            tt := tt + trunc(v * power(16, xpo));
            Dec(i);
            Inc(xpo);
        end;
    Result := (chr(tt));
end;

{-------------------------------------------------------------}
{       Decodifica URL encode
{-------------------------------------------------------------}

procedure urlDecode (var s: string);
var
    p: integer;
    aux, sHexa: string;
    c: char;
begin
    p := pos ('%', s);
    if p <= 0 then exit;
    aux := copy(s, 1, p-1);
    sHexa := copy(s, p+1, 2);
    c := Hexatoascii (sHexa);
    s := aux + c + copy(s, p+3, length(s)-3);
    urlDecode (s);
end;

{-------------------------------------------------------------}
{   Testa se tem hexadecimal em toda string.
{       Se todo "%" existente na string est� seguido de hexa.
{-------------------------------------------------------------}

function tudoEmHexa(s: string): boolean;
var
    p: integer;
    c1, c2: char;
begin
    p := pos('%', s);
    if p = 0 then
        tudoEmHexa := true
    else
    if (p + 2) > length(s) then
        tudoEmHexa := false
    else
        begin
            c1 := s[p+1];
            c2 := s[P+2];
            if (not eHexa (c1)) or (not eHexa (c2)) then
                tudoEmHexa := false
            else
                begin
                    delete (s, 1, (p+2));
                    tudoEmHexa := tudoEmHexa (s);
                end;
        end;
end;

{-------------------------------------------------------------}
{       Identifica se uma string est� codificada em URL-Encode
{-------------------------------------------------------------}

function estaEmUrlEncode (s: string): boolean;
var
    p: integer;
    c1, c2: char;
begin
    p := pos('%', s);
    if (p <3) or ((p+2) > length(s)) then
        estaEmUrlEncode := false
    else
        begin
            c1 := s[p+1];
            c2 := s[P+2];
            if (length(s) < 5) or (copy(s, 1, 2) <> '''''') or
              (not eHexa (c1)) or (not eHexa (c2)) then
                estaEmUrlEncode := false
            else
                begin
                    delete (s, 1, (p+2));
                    estaEmUrlEncode := tudoEmHexa (s);
                end;
        end;
end;

{-------------------------------------------------------------}
{       Chama a decodifica��o e retorna a string decodificada.
{-------------------------------------------------------------}

procedure decodificarString (var s: string);
var preambulo, charset, texto: string;
    encod: char;
    i, p, p2: integer;
begin
    //Formato: =?charset?encoding?encoded text?=
    p := pos ('=?', s);
    //Formato: ISO-8859-1''encoded text
    p2 := pos ('ISO-8859-1''' , s);

    if p > 0 then
        begin
            preambulo := copy (s, 1, p-1);
            delete (s, 1, p+1);

            p := pos('?', s);
            charset := copy (s, 1, p-1);
            delete (s, 1, p);
            p := pos('?', s);
            if p > 1 then
               encod := upcase (s[p-1])
            else
               encod := ' ';
            delete (s, 1, p);
            p := pos('?=', s);
            texto := copy (s, 1, p-1);
            delete (s, 1, p+1);

            if encod = 'Q' then
                texto := convQuotedPrintable (texto)
            else
            if encod = 'B' then
                texto := DecodFraseMime64 (texto);

            if (charset <> '') and (maiuscAnsi (charset) <> 'ISO-8859-1') and (maiuscAnsi (charset) <> 'WINDOWS-1252') then
                texto := utfToAnsi(texto);

            if charset <> '' then
                for i := 1 to length (texto) do
                    if texto[i] = '_' then texto[i] := ' ';

            if s <> '' then
                decodificarString (s);

            s := preambulo + texto + s;
        end
    else
    if p2 > 0 then
        begin
            p2 := pos('-1', s);
            delete (s, 1, p2+4);
            s := s;
        end
    else
    if estaEmUrlEncode(s) then
        begin //Decodifica URL-Encode
            s := copy(s, 3, length(s)-2);
            urlDecode (s);
        end;

end;

{--------------------------------------------------------}
{       codifica um arquivo em MIME64
{--------------------------------------------------------}

procedure CodifMime64;
var
   lidos, guarda: integer;
   byteEnt: byte;
   gravados: integer;
   s: string [80];
   bloco: array [0..1023] of byte;
   noBloco, indBloco: integer;

label erro;

begin
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
                   keypressed;   {para permitir troca de processo}
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
                           writeln (arqEnv, s);
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
        writeln (arqEnv, s);
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

   DecodFraseMime64 := saida;
end;

{-------------------------------------------------------------}
{       Retorna o assunto codificado
{-------------------------------------------------------------}

function codificarString (s: string): string;
begin
    //Formato: =?charset?encoding?encoded text?=
    s := codFraseMime64 (s);
    codificarString := '=?iso-8859-1?B?' + s + '?=';
end;

{-------------------------------------------------------------}
{       Decodifica um arquivo de texto de UTF-8 para Ansi
{-------------------------------------------------------------}

function decodArqUtfToAnsi (nomeArq: string): boolean;
var
    i: integer;
    arq: text;
    linhasArquivo: TStringList;
begin
    decodArqUtfToAnsi := false;
    linhasArquivo := TStringList.create;
    try
        linhasArquivo.loadFromFile (nomeArq);
    except
         exit;
    end;

    for i := 0 to (linhasArquivo.count - 1) do
        linhasArquivo[i] := utfToAnsi (linhasArquivo[i]);

    assign (arq, nomeArq);
    {$I-} rewrite (arq); {$I+}
    if ioresult <> 0 then
        begin
            linhasArquivo.free;
            exit;
        end;

    for i := 0 to (linhasArquivo.count - 1) do
        begin
            {$I-} writeln(arq, linhasArquivo[i]); {$I+}
            if ioresult <> 0 then
                begin
                    {$i-} close (arq); {$i+}
                    if ioresult <> 0 then;
                    linhasArquivo.free;
                    exit;
                end;
        end;

    {$i-} close (arq); {$i+}
    if ioresult <> 0 then;
    linhasArquivo.free;
    decodArqUtfToAnsi := true;
end;

{--------------------------------------------------------}
begin
end.
