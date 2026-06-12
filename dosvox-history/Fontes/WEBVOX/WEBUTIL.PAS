unit webutil;

interface
uses SysUtils;

procedure netDebug (s: pchar; tam: integer);
function nomeResumido (nomeArq: string): string;
function maiorData (data1, data2: string): integer;
procedure limpaArq;
function HexToInt(Palavra: string): Word;
function dataToInt (data: string): longword;
function maiusc (s: string): string;
function resolverNovoNomeArq (nomeArq: string): string;
function editaSenha (var s: string): char;
function codFraseMime64 (bloco: string): string;
function DecodFraseMime64 (aConverter: string): string;
function base64 (bloco: string): string;
function UrlEnc(s: String): String;
function utfToAnsi (s: string): string;
function ansiToIso88591 (s: string): string;
function obtemInt (s: string; default: integer): integer;

implementation
uses webvars, dvcrt, dvwin;

{-------------------------------------------------------------}
{                  codifica uma frase em mime64
{-------------------------------------------------------------}

const
    MIME64: array [0..63] of char =
       'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

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
{                     edita uma senha
{-------------------------------------------------------------}

function editaSenha (var s: string): char;
var c: char;
    i: integer;
label sai;
begin
    gotoxy (1, wherey);
    for i := 1 to length (s) do write ('*');
    s := '';

    repeat
        gotoxy (length(s) + 1, wherey);
        c := readkey;
        {sintclek;   Bernard}
        if (c = #$0) then
            begin
                c := readkey ;
                goto sai;
            end;
        if (c = ESC) or (c = ENTER) then goto sai;
        if c = BS then
            delete (s, length(s), 1)
        else
            s := s + c;
    until false;

sai:
    editaSenha := c;
end;

{-------------------------------------------------------------}
{       Retorna um nome de arquivo que não existe acrescentando um número inteiro ao fim do nome recebido
{-------------------------------------------------------------}

function resolverNovoNomeArq (nomeArq: string): string;
var
    ext, nomeArqTesta: string;
    i: integer;
begin
    ext := extractFileExt(nomeArq);
    nomeArqTesta := copy (nomeArq, 1, length(nomeArq) - length(ext));
    i := 1;
    while fileExists (nomeArqTesta + intToStr (i) + ext) do
        i := i + 1;
    result := nomeArqTesta + intToStr (i) + ext;
end;

{--------------------------------------------------------}
{       Resume o nome da URL
{--------------------------------------------------------}

function nomeResumido (nomeArq: string): string;
var p: integer;
    temp: string;
begin
    repeat
         p := pos ('/', nomeArq);
         if p <> 0 then delete (nomeArq, 1, p);
    until p = 0;

    { substitui os %.. da url pelo valor ascii }
    p := pos ('%', nomeArq);
    while p <> 0 do
       begin
          temp := nomeArq [p+1] + nomeArq [p+2];
          delete (nomeArq,p+1,2);
          nomeArq [p] := chr (HexToInt (temp));
          p := pos ('%', nomeArq);
       end;

    { remove as referências com "?" depois do nome }
    p := pos ('?', nomeArq);
    if p > 0 then
        delete (nomeArq, p, 999);

    nomeResumido := utfToAnsi (nomeArq);
end;

{---------------------------------------------------------------}
{           retorna qual a maior dadta entre as duas
{---------------------------------------------------------------}

function maiorData (data1, data2: string): integer;
begin
   if dataToInt (data1) > dataToInt (data2) then
      result := 1
   else
      result := 2;
end;

{-------------------------------------------------------------}
{                      escreve texto de debug
{-------------------------------------------------------------}

procedure netDebug (s: pchar; tam: integer);
begin
    if not debug then exit;
    textBackGround (BROWN);
    write ('>>>');
    writebuf (s, tam);
    textBackGround (BLACK);
end;

{----------------------------------------------------------}
{        limpa os cookies temporarios (sem data)
{        ou com data antiga
{----------------------------------------------------------}

procedure limpaArq;
var
//   continua: boolean;
   i, j: integer;
   s: string;
begin
//   continua := true;
   i := 0;
   while true do
      begin
          if i > ArquivoDeCookies.Count-1 then
             break;

          s := ArquivoDeCookies [i];
          if pos ('dominio',s) = 0 then
             begin
                i := i + 1;
                continue;
             end;

          s := ArquivoDeCookies [i+4];
          delete (s, 1, length ('tempo='));

          if (s = '') or (pos ('1970', s) <> 0) then   // mudar para comparar data
             for j := i to i + 7 do
                ArquivoDeCookies.Delete(i-1)
          else
             i := i + 7;
      end;
end;

function HexToInt(Palavra: string): Word;
var Indice, Num: Word;
begin
   while (Palavra <> '') and (Palavra[1] = ' ') do Delete(Palavra,1,1);
   while (Palavra <> '') and (Palavra[Length(Palavra)] = ' ') do Delete(Palavra,Length(Palavra),1);
   if Palavra[Length(Palavra)] = 'H' then Delete(Palavra,Length(Palavra),1)
   else if Palavra[1] = '$' then Delete(Palavra,1,1);
   Result := 0;
   for Indice := Length(Palavra) downto 1 do begin
      Case Palavra[Indice] of
      'A'..'F' : Num := Ord (Palavra [Indice]) - 55;
      'a'..'f' : Num := Ord (Palavra [indice]) - 87;
      '0'..'9' : Num := StrToInt (Palavra[Indice]);
      else Num :=0;
      end;
      Result := trunc(Result + Exp((Length(Palavra)-Indice)*Ln(16))*Num);
   end;

end;

function dataToInt (data: string): longword;
var
   posicao: integer;
   dd: integer;
   mm: integer;
   aa: integer;
   erro: integer;
   dataint: longword;
   mes: string;
begin
   posicao := pos ('-',data);
   while posicao <> 0 do
      begin
         data [posicao] := ' ';
         posicao := pos ('-', data);
      end;

   posicao := pos (' ', data);
   delete (data, 1, posicao);

   posicao := pos (' ', data);
   val (copy (data,1,posicao), dd, erro);
   delete (data, 1, posicao);

   posicao := pos (' ', data);
   mes := copy (data,1,posicao-1);
   delete (data, 1, posicao);

   posicao := pos (' ', data);
   val (copy (data,1,posicao), aa, erro);

   mm := 0;
   if maiusc (mes) = 'JAN' then mm := 101
   else if maiusc (mes) = 'FEB' then mm := 102
   else if maiusc (mes) = 'MAR' then mm := 103
   else if maiusc (mes) = 'APR' then mm := 104
   else if maiusc (mes) = 'MAY' then mm := 105
   else if maiusc (mes) = 'JUN' then mm := 106
   else if maiusc (mes) = 'JUL' then mm := 107
   else if maiusc (mes) = 'AGU' then mm := 108
   else if maiusc (mes) = 'SEP' then mm := 109
   else if maiusc (mes) = 'OCT' then mm := 110
   else if maiusc (mes) = 'NOV' then mm := 111
   else if maiusc (mes) = 'DEC' then mm := 112;


   dataint := aa * 100000 + mm * 100 + dd;

   result := dataint;
end;

function maiusc (s: string): string;
var
   tam, i: integer;
begin
   tam := length (s);
   for i := 1 to tam do
      s [i] := upcase (s [i]);

   result := s;
end;

{-------------------------------------------------------------}
{                  transforma cadeia em base 64
{-------------------------------------------------------------}

function base64 (bloco: string): string;
const
    MIME64: array [0..63] of char =
       'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
var
   lidos, guarda: integer;
   byteEnt: byte;
   s: string [80];
   indBloco: integer;

label erro;

begin
   lidos := 0;
   s := '';
   guarda := 0;

   for indBloco := 1 to length (bloco) do
       begin
           byteEnt := ord(bloco [indBloco]);
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

    base64 := s;
end;

{-------------------------------------------------------------}
{                muda nome quando acentuado
{-------------------------------------------------------------}

function UrlEnc(s: String): String;
var i: Integer;
begin
    Result := '';
    for i := 1 to length(s) do
        begin
            if s[i] = ' ' then
                Result := Result + '%20'
            else
            if s[i] in [#$c0..#$ff] then
                Result := Result + '%C3%' + IntToHex(Ord(s[i])-$40, 2)
            else
            if s[i] in [#$a0..#$bf] then
                Result := Result + '%C2%' + IntToHex(Ord(s[i]), 2)
            else
                Result := Result + s[i];
        end;
end;

{-------------------------------------------------------------}
{            converte de UTF-8 para Ansi
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

{-------------------------------------------------------------}
{                    converte de Ansi para ISO-8859-1
{-------------------------------------------------------------}

function ansiToIso88591 (s: string): string;
begin
    s := StringReplace(s, '%', '%25' , [rfReplaceAll]);
    s := StringReplace(s, '+', '%2B' , [rfReplaceAll]);
    s := StringReplace(s, '"', '%22' , [rfReplaceAll]);
    s := StringReplace(s, '''', '%27' , [rfReplaceAll]);
    s := StringReplace(s, '-', '%2D' , [rfReplaceAll]);
    s := StringReplace(s, '&', '%26' , [rfReplaceAll]);
    s := StringReplace(s, '(', '%28' , [rfReplaceAll]);
    s := StringReplace(s, ')', '%29' , [rfReplaceAll]);
    s := StringReplace(s, '{', '%7B' , [rfReplaceAll]);
    s := StringReplace(s, '}', '%7D' , [rfReplaceAll]);
    s := StringReplace(s, '[', '%5B' , [rfReplaceAll]);
    s := StringReplace(s, ']', '%5D' , [rfReplaceAll]);
    s := StringReplace(s, '<', '%3C' , [rfReplaceAll]);
    s := StringReplace(s, '>', '%3E' , [rfReplaceAll]);
    s := StringReplace(s, '/', '%2F' , [rfReplaceAll]);
    s := StringReplace(s, '\', '%5C' , [rfReplaceAll]);
    s := StringReplace(s, ',', '%2C' , [rfReplaceAll]);
    s := StringReplace(s, '?', '%3F' , [rfReplaceAll]);
    s := StringReplace(s, '!', '%21' , [rfReplaceAll]);
    s := StringReplace(s, ':', '%3A' , [rfReplaceAll]);
    s := StringReplace(s, ';', '%3B' , [rfReplaceAll]);
    s := StringReplace(s, '#', '%23' , [rfReplaceAll]);
    s := StringReplace(s, '$', '%24' , [rfReplaceAll]);
    s := StringReplace(s, '=', '%3D' , [rfReplaceAll]);
    s := StringReplace(s, '¨', '%A8' , [rfReplaceAll]);
    s := StringReplace(s, 'ç', '%E7' , [rfReplaceAll]);
    s := StringReplace(s, 'Ç', '%C7' , [rfReplaceAll]);
    s := StringReplace(s, 'ª', '%AA' , [rfReplaceAll]);
    s := StringReplace(s, 'º', '%BA' , [rfReplaceAll]);

    s := StringReplace(s, 'á', '%E1' , [rfReplaceAll]);
    s := StringReplace(s, 'é', '%E9' , [rfReplaceAll]);
    s := StringReplace(s, 'í', '%ED' , [rfReplaceAll]);
    s := StringReplace(s, 'ó', '%F3' , [rfReplaceAll]);
    s := StringReplace(s, 'ú', '%FA' , [rfReplaceAll]);
    s := StringReplace(s, 'Á', '%C1' , [rfReplaceAll]);
    s := StringReplace(s, 'É', '%C9' , [rfReplaceAll]);
    s := StringReplace(s, 'Í', '%CD' , [rfReplaceAll]);
    s := StringReplace(s, 'Ó', '%D3' , [rfReplaceAll]);
    s := StringReplace(s, 'Ú', '%DA' , [rfReplaceAll]);
    s := StringReplace(s, 'ã', '%E3' , [rfReplaceAll]);
    s := StringReplace(s, 'õ', '%F5' , [rfReplaceAll]);
    s := StringReplace(s, 'Ã', '%C3' , [rfReplaceAll]);
    s := StringReplace(s, 'Õ', '%D5' , [rfReplaceAll]);
    s := StringReplace(s, 'â', '%E2' , [rfReplaceAll]);
    s := StringReplace(s, 'ê', '%EA' , [rfReplaceAll]);
    s := StringReplace(s, 'î', '%EE' , [rfReplaceAll]);
    s := StringReplace(s, 'ô', '%F4' , [rfReplaceAll]);
    s := StringReplace(s, 'û', '%FB' , [rfReplaceAll]);
    s := StringReplace(s, 'Â', '%C2' , [rfReplaceAll]);
    s := StringReplace(s, 'Ê', '%CA' , [rfReplaceAll]);
    s := StringReplace(s, 'Î', '%CE' , [rfReplaceAll]);
    s := StringReplace(s, 'Ô', '%D4' , [rfReplaceAll]);
    s := StringReplace(s, 'Û', '%DB' , [rfReplaceAll]);
    s := StringReplace(s, 'à', '%E0' , [rfReplaceAll]);
    s := StringReplace(s, 'è', '%E8' , [rfReplaceAll]);
    s := StringReplace(s, 'ì', '%EC' , [rfReplaceAll]);
    s := StringReplace(s, 'ò', '%F2' , [rfReplaceAll]);
    s := StringReplace(s, 'ù', '%F9' , [rfReplaceAll]);
    s := StringReplace(s, 'À', '%C0' , [rfReplaceAll]);
    s := StringReplace(s, 'È', '%C8' , [rfReplaceAll]);
    s := StringReplace(s, 'Ì', '%CC' , [rfReplaceAll]);
    s := StringReplace(s, 'Ò', '%D2' , [rfReplaceAll]);
    s := StringReplace(s, 'Ù', '%D9' , [rfReplaceAll]);
    s := StringReplace(s, 'ä', '%E4' , [rfReplaceAll]);
    s := StringReplace(s, 'ë', '%EB' , [rfReplaceAll]);
    s := StringReplace(s, 'ï', '%EF' , [rfReplaceAll]);
    s := StringReplace(s, 'ö', '%F6' , [rfReplaceAll]);
    s := StringReplace(s, 'ü', '%FC' , [rfReplaceAll]);
    s := StringReplace(s, 'Ä', '%C4' , [rfReplaceAll]);
    s := StringReplace(s, 'Ë', '%CB' , [rfReplaceAll]);
    s := StringReplace(s, 'Ï', '%CF' , [rfReplaceAll]);
    s := StringReplace(s, 'Ö', '%D6' , [rfReplaceAll]);
    s := StringReplace(s, 'Ü', '%DC' , [rfReplaceAll]);

    s := StringReplace(s, ' ', '+' , [rfReplaceAll, rfIgnoreCase]);

    result :=  s;
end;

{---------------------------------------------------------}
{                    Recebe uma string e retorna o integer
{---------------------------------------------------------}

function obtemInt (s: string; default: integer): integer;
var v, erro: integer;
begin
    s := trim (s);
    val (s, v, erro);
    if erro <> 0 then
        obtemInt := default
    else
        obtemInt := v;
end;

{-------------------------------------------------------------}

begin
end.
