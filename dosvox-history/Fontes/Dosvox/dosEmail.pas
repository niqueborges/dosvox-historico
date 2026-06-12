{-------------------------------------------------------------}
{
{    Prepara uma carta para transmissão pelo Cartavox (MIME)
{    Autor: Antonio Borges
{    Em 2/3/2005
{
{-------------------------------------------------------------}

unit dosEmail;

interface

uses
  windows, sysUtils, classes,
  dvcrt, dvWin, dosmsg;

procedure preparaCarta (nomeArqEnviar, nomeUsuario, nomeDest, assunto: string;
                        nomesDosArquivos: TStringList);

implementation

var
    arqEnv: textFile;
    arqBin: file;
    chaveMime: string;

{-------------------------------------------------------------}
{       gera carta padrao
{-------------------------------------------------------------}

procedure geraCartaPadrao (nomesDosArquivos: TStringList);
var i: integer;
begin
    writeln (arqEnv, '--', chaveMime);
    writeln   (arqEnv, 'Content-Type: text/plain; charset=ISO-8859-1');
    writeln (arqEnv, '');
    write (arqEnv, intToStr(nomesDosArquivos.count));
    if nomesDosArquivos.Count = 1 then
        writeln (arqEnv, ' arquivo anexado:')
    else
        writeln (arqEnv, ' arquivos anexados:');
    writeln (arqEnv);
    for i := 0 to nomesDosArquivos.count-1 do
        writeln (arqEnv, nomesDosArquivos[i]);
end;

{-------------------------------------------------------------}
{       gera chave de acesso Mime
{-------------------------------------------------------------}

function geraChaveMime: string;
var i, n: integer;
    s: string;
    chaveMime: string;
begin
    chaveMime := '=================';             { gera chave Mime randomica }
    for i := 1 to 10 do
         begin
             n := random (255);
             str (n, s);
             chaveMime := chaveMime + s;
         end;
    geraChaveMime := chaveMime;
end;

{-------------------------------------------------------------}
{               gere mime type
{-------------------------------------------------------------}

function geraTipoAplic (nome: string): string;
var ext: string [4];
    i: integer;
label achou;
begin
    ext := '';
    for i := length (nome) downto length (nome)-3 do
        if nome[i] = '.' then goto achou
        else ext := upcase(nome[i]) + ext;
achou:
    if      ext = '$'    then  geraTipoAplic := 'text/plain'
    else if ext = 'ASF'  then  geraTipoAplic := 'video/x-ms-asf'
    else if ext = 'BMP'  then  geraTipoAplic := 'image/bmp'
    else if ext = 'CAR'  then  geraTipoAplic := 'message/rfc822'
    else if ext = 'DAT'  then  geraTipoAplic := 'application/ms-tnef'
    else if ext = 'DOC'  then  geraTipoAplic := 'application/msword'
    else if ext = 'GIF'  then  geraTipoAplic := 'image/gif'
    else if ext = 'HTM'  then  geraTipoAplic := 'text/html'
    else if ext = 'HTML' then  geraTipoAplic := 'text/html'
    else if ext = 'JPG'  then  geraTipoAplic := 'image/jpeg'
    else if ext = 'MID'  then  geraTipoAplic := 'audio/midi'
    else if ext = 'MP3'  then  geraTipoAplic := 'audio/mpeg'
    else if ext = 'MPE'  then  geraTipoAplic := 'audio/mpeg'
    else if ext = 'MPG'  then  geraTipoAplic := 'video/mpg'
    else if ext = 'PDF'  then  geraTipoAplic := 'application/pdf'
    else if ext = 'PPS'  then  geraTipoAplic := 'application/vnd.ms-powerpoint'
    else if ext = 'RAM'  then  geraTipoAplic := 'application/vnd.rn-realmedia'
    else if ext = 'RM'   then  geraTipoAplic := 'application/vnd.rn-realmedia'
    else if ext = 'RTF'  then  geraTipoAplic := 'text/enriched'
    else if ext = 'TXT'  then  geraTipoAplic := 'text/plain'
    else if ext = 'WAV'  then  geraTipoAplic := 'audio/x-wav'
    else if ext = 'WMV'  then  geraTipoAplic := 'video/x-ms-wmv'
    else if ext = 'ZIP'  then  geraTipoAplic := 'application/x-zip-compressed'
    else
        geratipoAplic := 'Unknown'
end;

{-------------------------------------------------------------}
{               simplifica um nome de arquivo
{-------------------------------------------------------------}

function simplificaNomeArq (nomeOrig: string): string;
var nome: string;
begin
    nome := nomeOrig;
    while pos (':', nome) > 0 do
        delete (nome, 1, pos (':', nome) );
    while pos ('\', nome) > 0 do
        delete (nome, 1, pos ('\', nome) );
    if nome = '' then nome := 'x.txt';
    simplificaNomeArq := nome;
end;

{--------------------------------------------------------}
{       codifica um arquivo em MIME64
{--------------------------------------------------------}

const
    MIME64: array [0..63] of char =
       'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

procedure geraMime64;
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
{       prepara os arquivos anexados
{-------------------------------------------------------------}

procedure preparaAnexo (nomeArq: string; chaveMime: string);
var nome, tipoAplic: string;
begin
    writeln (arqEnv, '--', chaveMime);

    nome := simplificaNomeArq (nomeArq);
    tipoAplic := geraTipoAplic (nome);

    write   (arqEnv, 'Content-Type: ' + tipoAplic + '; ');
    writeln (arqEnv, 'name="', nome, '"');
    writeln (arqEnv, 'Content-Transfer-Encoding: base64');
    write   (arqEnv, 'Content-Disposition: attachment; ');
    writeln (arqEnv, 'filename="', nome, '"');
    writeln (arqEnv);

    assign (arqBin, nomeArq);
    {$I-}  reset (arqBin, 1);  {$I+}
    if ioresult <> 0 then exit;
    geraMime64;
    close (arqBin);
end;

{-------------------------------------------------------------}
{       prepara formato SMTP para envio
{-------------------------------------------------------------}

procedure preparaCarta (nomeArqEnviar, nomeUsuario, nomeDest, assunto: string;
                        nomesDosArquivos: TStringList);
var
    Year, Month, Day, DayOfWeek: Word;
    Hour, Minute, Second, Sec100: Word;
    i, i1, i2: integer;
    enderUsuario, enderDest: string;
    {$IFDEF VER150}
    date_and_time: TDateTime;
    {$ENDIF}

const
    tabMes: array [1..12] of string [3] = (
       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
label erro;

begin
    assign (arqEnv, nomeArqEnviar);
    {$I-}  rewrite (arqEnv);  {$I+}
    if ioresult <> 0 then goto erro;

    enderUsuario := nomeUsuario;
    i1 := pos ('<', enderUsuario);
    if i1 <> 0 then
        begin
            i2 := pos ('>', enderUsuario);
            enderUsuario := copy (enderUsuario, i1+1, i2-i1-1);
        end;
    writeln (arqEnv, 'MAIL FROM:<', enderUsuario, '>');

    enderDest := nomeDest;
    i1 := pos ('<', enderDest);
    if i1 <> 0 then
        begin
            i2 := pos ('>', enderDest);
            enderDest := copy (enderDest, i1+1, i2-i1-1);
        end;
    writeln (arqEnv, 'RCPT TO:<', enderDest, '>');

    writeln (arqEnv, 'DATA');
    {$IFDEF VER150}
        date_and_time := now;
        decodeDate (date_and_time, Year, Month, Day);
        decodeTime (date_and_time, Hour, Minute, Second, Sec100);
    {$ELSE}
        getDate(Year, Month, Day, DayOfWeek);
        getTime (Hour, Minute, Second, Sec100);
    {$ENDIF}
    write (arqEnv, 'Date: ', Day, ' ', tabMes [Month], ' ', Year);
    writeln (arqEnv,  ' ', Hour, ':', Minute, ':', Second, ' -0300');
    writeln (arqEnv, 'From: ', nomeUsuario);
    writeln (arqEnv, 'To: ', nomeDest);
    writeln (arqEnv, 'Subject: ', assunto);

    chaveMime := geraChaveMime;
    writeln (arqEnv, 'Mime-Version: 1.0');
    write   (arqEnv, 'Content-Type: multipart/mixed; boundary=');
    writeln (arqEnv, '"', chaveMime, '"');
    writeln (arqEnv);

    geraCartaPadrao (nomesDosArquivos);

    for i := 0 to nomesDosArquivos.count-1 do
        preparaAnexo (nomesDosArquivos[i], chaveMime);
    writeln (arqEnv, '--', chaveMime, '--');

    writeln (arqEnv, '.');
    close (arqEnv);

    while keypressed do readkey;
    mensagem ('DV_CARTPREPVOX', 1);     {'Carta preparada para transmissão pelo Cartavox'}
    exit;

erro:
    {$I-} close (arqEnv);  {$I+}
    if ioresult <> 0 then;
    {$I-} erase (arqEnv);  {$I+}
    if ioresult <> 0 then;

    mensagem ('DV_ERRCARQENV', 1);      {'Erro ao criar arquivo para envio'}
end;

end.
