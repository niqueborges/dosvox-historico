{--------------------------------------------------------}
{                                                        }
{    Programa de acesso rápido usando imap               }
{                                                        }
{    Módulo de tratamento de envelope                    }
{                                                        }
{    Autor: José Antonio Borges e Fabiano Ferreira       }
{                                                        }
{    Em abril/2013                                       }
{                                                        }
{--------------------------------------------------------}

unit iuenvel;

interface

uses
    dvcrt,
    dvwin,
    sysutils,
    iuvars,
    iumsg,
    Windows,
    dateUtils;

type
    vetBytes = array [0..1023] of byte;

function envelope (s: string;
                   var env_date, env_subject, env_from: string): boolean;

procedure ignora_ate (ign: string; var s: string);
procedure removeCarac_ate (c: char; var s: string);
function pegaCadeia (var texto: string): string;
function pegaNumero (var s: string): integer;
function utfToAnsi (s: string): string;
function decodFraseMime64 (aConverter: string): string;
function decodBinMime64 (s: string; var buf: vetBytes): integer;
function codFraseMime64 (bloco: string): string;
function convQuotedPrintable (s: string): string;

implementation

const
    MIME64: array [0..63] of char =
       'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

{-------------------------------------------------------------}
{       converte de UTF-8 para Ansi                           }
{-------------------------------------------------------------}

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

{--------------------------------------------------------}
{       decodifica uma cadeia em MIME64                  }
{--------------------------------------------------------}

function decodFraseMime64 (aConverter: string): string;
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

   for i := length(saida) downto 1 do
       if saida[i] = #$0 then delete (saida, i, 1);

   result := saida;
end;

{--------------------------------------------------------}
{      decodifica em binário uma linha em MIME64
{--------------------------------------------------------}

function decodBinMime64 (s: string; var buf: vetBytes): integer;
var
    bloco, grupo: integer;
    tabInvMIME: array [0..255] of byte;
    i: integer;
    caracEnt: char;
    byteSai: byte;
    ncsai: integer;

begin
   for i := 0 to 63 do
       tabInvMIME [ord(MIME64 [i])] := i;
   tabInvMIME [ord('=')] := 0;

   ncSai := 0;
   bloco := 0;
   byteSai := 0;
   for i := 1 to length(s) do
       begin
           caracEnt := s[i];
           if caracEnt = '=' then break;

           grupo := tabInvMIME [ord (caracEnt)];

           case bloco of
               0:    byteSai := grupo shl 2;
               1:    begin
                         byteSai := byteSai or ((grupo shr 4) and $f);
                         buf[ncSai] := byteSai;
                         inc (ncSai);
                         byteSai := (grupo and $f) shl 4;
                     end;
               2:    begin
                         byteSai := byteSai or ((grupo shr 2) and $3f);
                         buf[ncSai] := byteSai;
                         inc (ncSai);
                         byteSai := (grupo and 3) shl 6;
                     end;
               3:    begin
                         byteSai := byteSai or (grupo and $3f);
                         buf[ncSai] := byteSai;
                         inc (ncSai);
                     end;
           end;

           bloco := (bloco + 1) mod 4;
        end;

    result := ncSai;
end;

{-------------------------------------------------------------}
{       codifica uma frase em mime64                          }
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

{-------------------------------------------------------------}
{       remove especificacoes quoted printable                }
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

    function eHexa (c: char): boolean;
    begin
        eHexa := c in ['0'..'9', 'a'..'f', 'A'..'F'];
    end;

begin
    for i := 1 to length(s) do
        if s[i] = '_' then
            s[i] := ' ';

    sai := '';
    i := 1;
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

{--------------------------------------------------------}
{ ignora até uma certa palavra, removendo-a também       }
{--------------------------------------------------------}

procedure ignora_ate (ign: string; var s: string);
var p: integer;
begin
    p := pos (ign, s);
    if p <= 0 then
        s := ''
    else
        delete (s, 1, p+length(ign)-1);
    s := trim (s);
end;

{--------------------------------------------------------}
{ remove até uma letra, inclusive                        }
{--------------------------------------------------------}

procedure removeCarac_ate (c: char; var s: string);
var x: string;
begin
    if s = '' then exit;
    repeat
         x := s[1];
         delete (s, 1, 1);
    until (x = c) or (s = '');
    s := trim (s);
end;

{--------------------------------------------------------}
{ pega trecho até espaço ou fim da linha                 }
{--------------------------------------------------------}

function pegaPalavra (var s: string): string;
var
    p: integer;
begin
    s := trimLeft(s);
    result := '';
    if s = '' then exit;

    p := pos (' ', s);
    if p = 0 then
        result := s
    else
        begin
            result := copy (s, 1, p-1);
            delete (s, 1, p);
            s := trimLeft(s);
        end;
end;

{--------------------------------------------------------}
{ pega número inteiro                                    }
{--------------------------------------------------------}

function pegaNumero (var s: string): integer;
var
    num: string;
begin
    result := 0;
    num := '';
    s := trimLeft(s);
    if s = '' then exit;

    while (s <> '') and (s[1] in ['0'..'9']) do
        begin
            num := num + s[1];
            delete (s, 1, 1);
        end;

    s := trimLeft(s);
    result := strToInt(num);
end;

{--------------------------------------------------------}
{ extrai a primeira cadeia, removendo do texto original  }
{--------------------------------------------------------}

function pegaCadeia (var texto: string): string;
var p, p1, p2: integer;
    cadeia: string;
    saida: string;
    charset, pedaco: string;
    codif: char;
    c: char;

begin
    texto := trimLeft(texto);
    if copy (texto, 1, 3) = 'NIL' then
        begin
            delete (texto, 1, 3);
            if copy (texto, 1, 1) = ' ' then delete (texto, 1, 1);
            result := '';
            exit;
        end;

    removecarac_ate ('"', texto);

    cadeia := '';
    p := 1;
    repeat
        c := texto[p];
        if c = '"' then break;
        if c <> '\' then
            cadeia := cadeia + c
        else
            begin
                p := p + 1;
                if p <= length(texto) then   // preventivo
                    cadeia := cadeia + texto[p];
            end;
        p := p + 1;
    until p > length(texto);

    delete (texto, 1, p);

    saida := '';
    repeat
        p1 := pos ('=?', cadeia);
        if p1 = 0 then
            saida := saida + cadeia
        else
        if p1 > 1 then
             begin
                 saida := saida + copy (cadeia, 1, p1-1);
                 delete (cadeia, 1, p1-1);
             end
        else
        // if  p1 = 1 then   // há uma subcadeia no início
            begin
                delete (cadeia, 1, 2);
                p := pos ('?', cadeia);
                charset := upperCase (copy (cadeia, 1, p-1));
                delete (cadeia, 1, p);
                codif := ' ';
                if cadeia <> '' then
                    codif := upcase(cadeia[1]);
                delete (cadeia, 1, 2);

                p2 := pos ('?=', cadeia);
                if p2 = 0 then p2 := 9999;
                pedaco := copy (cadeia, 1, p2-1);

                if codif = 'B' then
                    pedaco := DecodFraseMime64(pedaco)
                else
                if codif = 'Q' then
                    pedaco := convQuotedPrintable(pedaco);

                if charset = 'UTF-8' then
                       pedaco := utfToAnsi(pedaco);

                saida := saida + pedaco;
                delete (cadeia, 1, p2+2);
            end;
    until p1 = 0;

    texto := trimleft(texto);
    result := saida;
end;

{--------------------------------------------------------}
{ decodifica data                                        }
{--------------------------------------------------------}

function convData (data: string): string;
var
    dia, mes, ano, hora: string;
    saida: string;
    i: integer;
const
    mesIngles = 'JanFebMarAprMayJunJulAugSepOctNovDec';

begin
    saida := '';
    pegaPalavra (data);
    dia := pegaPalavra (data);
    mes := pegaPalavra (data);
    for i := 0 to 11 do
        if mes = copy (mesIngles, i*3+1, 3) then
            begin
                // Acerta o mês e coloca com dois dígitos.
                mes := intToStr(i + 1);
                if length(mes) = 1 then mes := '0' + mes;
                break;
            end;
    ano := pegaPalavra (data);
    hora := pegaPalavra (data);;


    result := dia + '/' + mes + '/' + ano + ' ' + hora;
end;

{--------------------------------------------------------}
{ processa um envelope imap                              }
{--------------------------------------------------------}

function envelope (s: string;
                   var env_date, env_subject, env_from: string): boolean;
var
    addr_name, addr_adl,  addr_mailbox, addr_host: string;
begin
    ignora_ate('ENVELOPE', s);
    if s = '' then
        begin
            result := false;
            exit;
        end;

    removecarac_ate  ('(', s);
    env_date := pegacadeia (s);
    env_date := convData (env_date);
    env_subject := pegacadeia (s);
    removecarac_ate ('(', s);
    removecarac_ate ('(', s);

    addr_name := pegacadeia (s);
    addr_adl := pegacadeia (s);
    addr_mailbox := pegacadeia (s);
    addr_host := pegacadeia (s);
    if addr_name = '' then
        env_from := '<'+ addr_mailbox + '@' + addr_host + '>'
    else
        env_from := '"'+ addr_name+ '" <'+ addr_mailbox + '@' + addr_host + '>';
    result := true;
End;

end.
