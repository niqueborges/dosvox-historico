{--------------------------------------------------------}
{
{    Programa de conversao baseado na tabela MIME64.
{    Autores: Paulo Veronesi e Antonio Borges
{    Em 9/9/98
{
{--------------------------------------------------------}

program mimevox;
uses dvwin, dvcrt;

const
    MIME64: array [0..63] of char =
       'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

var
    arqBin: file of byte;
    arqCarac: text;
    nomeArqEntra, nomeArqSai: string;
    opcao: char;

{--------------------------------------------------------}
{                   escreve e fala cadeia
{--------------------------------------------------------}

procedure sintWrite (cadeia: string);
begin
    write (cadeia);
    sintetiza (cadeia);
end;

{--------------------------------------------------------}

procedure sintWriteln (cadeia: string);
begin
    writeln (cadeia);
    sintetiza (cadeia);
end;

{--------------------------------------------------------}
{               codifica um arquivo em MIME64
{--------------------------------------------------------}

procedure Codifica;
var
   lidos, guarda: integer;
   byteEnt: byte;
   gravados: integer;
   s: string [80];
begin
   lidos := 0;
   gravados := 0;
   guarda := 0;
   s := '';
   while not eof (arqBin) do
       begin
           read (arqBin, byteEnt);
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
                   writeln (arqCarac, s);
                   s := '';
               end;
       end;

   if lidos <> 0 then
       s := s + MIME64[guarda];

    while (length (s) mod 4) <> 0 do
        s := s + '=';
    if length (s) <> 0 then
        writeln (arqCarac, s);
end;

{--------------------------------------------------------}
{              decodifica um arquivo em MIME64
{--------------------------------------------------------}

procedure decodifica;
var
    bloco, grupo: integer;
    tabInvMIME: array [0..255] of byte;
    i: integer;
    caracEnt: char;
    byteSai: byte;
label proximo;
begin
   for i := 0 to 63 do
       tabInvMIME [ord(MIME64 [i])] := i;
   tabInvMIME [ord('=')] := 0;

   bloco := 0;
   caracEnt := ' ';
   while (not eof (arqCarac)) and (caracEnt <> '=') do
       begin
           read (arqCarac, caracEnt);
           if (caracEnt = #$0d) or (caracEnt = #$0a) or
              (caracEnt =  ' ') or (caracEnt =  '=') then
               goto proximo;

           grupo := tabInvMIME [ord (caracEnt)];

           case bloco of
               0:    byteSai := grupo shl 2;
               1:    begin
                         byteSai := byteSai or ((grupo shr 4) and $f);
                         write (arqBin, byteSai);
                         byteSai := (grupo and $f) shl 4;
                     end;
               2:    begin
                         byteSai := byteSai or ((grupo shr 2) and $3f);
                         write (arqBin, byteSai);
                         byteSai := (grupo and 3) shl 6;
                     end;
               3:    begin
                        byteSai := byteSai or (grupo and $3f);
                        write (arqBin, byteSai);
                     end;
           end;

           bloco := (bloco + 1) mod 4;
proximo:
        end;
end;

{--------------------------------------------------------}
{              decodifica um arquivo em MIME64
{--------------------------------------------------------}

function abreArquivos: boolean;
begin
   abreArquivos := false;

   sintWriteln ('Digite o nome do arquivo de entrada');
   sintReadln (nomeArqEntra);
   if nomeArqEntra = '' then
       exit;

   if opcao = 'C' then
       begin
           assignFile (arqBin, nomeArqEntra);
          {$I-} reset (arqBin);  {$I+}
       end
   else
       begin
           assignFile (arqCarac, nomeArqEntra);
          {$I-} reset (arqCarac);  {$I+}
       end;

   if ioresult <> 0 then
       begin
           sintWriteln ('Arquivo inexistente');
           exit;
       end;

   sintWriteln ('Digite o nome do arquivo de saida');
   sintReadln (nomeArqSai);
   if nomeArqSai = '' then
       exit;

   if opcao = 'C' then
       begin
           assignFile (arqCarac, nomeArqSai);
           {$I-}  rewrite (arqCarac);  {$I+}
       end
   else
       begin
           assignFile (arqBin, nomeArqSai);
           {$I-}  rewrite (arqBin);  {$I+}
       end;

   if ioresult <> 0 then
       begin
           sintWriteln ('Não pude criar o arquivo');
           exit;
       end;

   abreArquivos := true;
end;

{--------------------------------------------------------}
{           busca trecho codificado em uma carta
{--------------------------------------------------------}

procedure buscaTrecho;
var i: integer;
    s: string;
begin
    while not eof (arqCarac) do
        begin
            readln (arqCarac, s);
            for i := 1 to length (s) do
                s[i] := upcase (s[i]);
            if pos ('CONTENT-TRANSFER-ENCODING: BASE64', s) <> 0 then
                 begin
                     while (not eof (arqCarac)) and (s <> '') do
                         readln (arqCarac, s);
                     exit;
                 end;

        end;

    closeFile (arqCarac);
    sintWriteln ('Nao encontrei o trecho Mime na carta');
    sintWriteln ('Programa cancelado');
    sintFim;
    halt;
end;

{--------------------------------------------------------}
{                    programa principal
{--------------------------------------------------------}

label fim;
var resp: char;
begin
   sintInic (0, '');

   sintWriteln ('Programa Mime64');
   writeln;
   sintWrite ('Digite C para codificar ou D para Decodificar  ');
   opcao := Readkey;
   sintCarac (opcao);
   writeln (opcao);
   opcao := upcase (opcao);

   if opcao = #$1b then goto fim;
   if not (opcao in ['D', 'C']) then
       begin
           sintWriteln ('Opção inválida');
           goto fim;
       end;

   if abreArquivos then
       begin
           case upcase (opcao) of
               'C': codifica;
               'D': begin
                        sintWrite ('Trecho a extrair pertence a uma carta ? ');
                        resp := readkey;
                        sintCarac (resp);
                        writeln (resp);
                        if upcase (resp) = 'S' then
                             buscaTrecho;
                        sintWriteln ('Espere');
                        decodifica;
                    end;
           end;

           closeFile (arqCarac);
           closeFile (arqBin);

           sintWriteln ('Ok');
       end;

fim:
   sintWriteln ('Fim do programa');
   sintFim;
end.
