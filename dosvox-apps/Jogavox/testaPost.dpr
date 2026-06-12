{-------------------------------------------------------------}
{                  programa de teste de post
{-------------------------------------------------------------}

program xpost;
uses
    dvwin, dvcrt, dvarq, sysutils, dvinet, dvssl, videoVox;

const
   BUFSIZE = 4096;         { tamanho do buffer de rede }
   CRLF = #$0d + #$0a;

var
    nomeArq: string;
    arq: file;
    sockHTTP: integer;
    servidor, site: string;

const
    uploadSite = 'https://intervox.nce.ufrj.br/~patrick_dosvox/caos/upload3.php';

{-------------------------------------------------------------}
{    abre o site de upload, obtem servidor e lugar do site
{-------------------------------------------------------------}

function abreSite (uploadSite: string): boolean;
var i: integer;
begin
    abreWinSock;

    i := pos(':', uploadSite);
    servidor := copy (uploadSite, i+3, 999);
    i := pos ('/', servidor);
    site := copy (servidor, i, 999);
    delete (servidor, i, 999);
sintWriteln('Servidor: '+servidor);
sintWriteln('Site: '+site);

    if uppercase(copy (uploadSite, 1, 5)) = 'HTTPS' then
        sockHttp := abreConexaoSSL (servidor, 443)
    else
        sockHttp := abreConexao (servidor, 80);

    if sockHttp <= 0 then
        begin
            sintWriteln ('Não consegui abrir a conexão com ');
            sintWriteln (uploadSite);
            readln;
            result := false;
        end
    else
        result := true;
end;

{-------------------------------------------------------------}
{                  gera chave de acesso Mime
{-------------------------------------------------------------}

function geraChaveMime: string;
var i, n: integer;
    chaveMime, s: string;
begin
    s := '';
    chaveMime := '-----------';

    for i := 1 to 5 do
         begin
             n := random (255);
             str (n, s);
             chaveMime := chaveMime + s;
         end;

    result := chaveMime;
end;

{-------------------------------------------------------------}
{         converte cadeia para o padrao codificado HTTP
{-------------------------------------------------------------}

function converteValorParaHTTP (valor: string): string;
const
    tabHexa: array [0..15] of char = (
     '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
var s: string;
    i: integer;
begin
    s := '';
    for i := 1 to length (valor) do
        begin
            case valor[i] of
                '@', '*', '.', '_',
                '0'..'9', 'A'..'Z', 'a'..'z':  s := s + valor[i];
                ' ':  s := s + '+';
            else
                s := s + '%' +
                     tabHexa [ord (valor[i]) shr 4] +
                     tabHexa [ord (valor[i]) and $f];
            end;
        end;
    converteValorParaHTTP := s;
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
{                   gera o tipo de mime
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
    if      ext = 'ZIP'  then  geraTipoAplic := 'application/zip'
    else if ext = 'WAV'  then  geraTipoAplic := 'audio/x-wav'
    else if ext = 'MP3'  then  geraTipoAplic := 'audio/mpeg'
    else if ext = 'WMA'  then  geraTipoAplic := 'audio/x-ms-wma'
    else if ext = 'MID'  then  geraTipoAplic := 'audio/midi'
    else if ext = 'BMP'  then  geraTipoAplic := 'image/bmp'
    else if ext = 'GIF'  then  geraTipoAplic := 'image/gif'
    else if ext = 'JPG'  then  geraTipoAplic := 'image/jpeg'
    else if ext = 'MPG'  then  geraTipoAplic := 'video/mpeg'
    else if ext = 'MPEG' then  geraTipoAplic := 'video/mpeg'
    else if ext = 'MP4'  then  geraTipoAplic := 'video/mpeg'
    else if ext = 'HTM'  then  geraTipoAplic := 'text/html'
    else if ext = 'HTML' then  geraTipoAplic := 'text/html'
    else if ext = 'TXT'  then  geraTipoAplic := 'text/plain'
    else
        geratipoAplic := 'application/octet-stream';
end;

{-------------------------------------------------------------}
{                envia pedido de home page
{-------------------------------------------------------------}

procedure PostFile (user_name, pass_word, file_name: string);
const
    TAMBUF = 8192;
var
    cabecPost, tipoAplic: string;
    buf: array [0..TAMBUF-1] of byte;
    lidos: integer;

    tamArq: integer;

    chaveMime: string;
    dadosPost1, dadosPost2, dadosPost3:  string;
    tamDadosPost: integer;

const
    contentType = 'multipart/form-data';

begin
    chaveMime := geraChaveMime;

    tipoAplic := geraTipoAplic (file_name);

    cabecPost :=
        'POST ' + site + ' HTTP/1.0' + CRLF +
        'Host: ' + servidor + CRLF +
        'Accept-Language: pt-br' + CRLF +
        'UA-CPU: x86' + CRLF +
        'User-Agent: Jogavox 2.0' + CRLF +
        'Connection: Close' + CRLF +
        'Content-Type: ' + contentType + '; boundary=' + chaveMime + CRLF;

    dadosPost1 :=
        '--' + chaveMime + CRLF +
        'Content-Disposition: form-data; name="username"' + CRLF +
        CRLF + user_name + CRLF +

        '--' + chaveMime + CRLF +
        'Content-Disposition: form-data; name="password"' + CRLF +
        CRLF + pass_word + CRLF;

    dadosPost2 :=
        '--' + chaveMime + CRLF +
        'Content-Disposition: form-data; ' +
        'name="filename"; filename="' + file_name + '"' + CRLF +
        'Content-Type: ' + tipoAplic + CRLF + CRLF;

    dadosPost3 := CRLF + '--' + chaveMime + '--' + CRLF;

    tamArq := filesize(arq);
    tamDadosPost := length(dadosPost1) +
                    length(dadosPost2) + tamArq + length(dadosPost3);

    cabecPost := cabecPost +
        'Content-Length: ' + intToStr (tamDadosPost) + CRLF + CRLF;

    sendBuf (sockHTTP, @cabecPost[1], length (cabecPost), 0);
    sendBuf (sockHTTP, @dadosPost1[1], length (dadosPost1), 0);
    sendBuf (sockHTTP, @dadosPost2[1], length (dadosPost2), 0);
    while not eof (arq) do
       begin
           blockRead (arq, buf, 8192, lidos);
           sendBuf (sockHTTP, @buf, lidos, 0);
       end;
    sendBuf (sockHTTP, @dadosPost3[1], length (dadosPost3), 0);
end;

{-------------------------------------------------------------}
{                    programa de teste
{-------------------------------------------------------------}

var
    codret: string;
    conta, senha: string;
begin
    sintInic (0, '');
    sintWriteln ('Programa de teste de post de arquivo');
    writeln;

    sintWriteln('Informe a conta, deixe em branco para conta pública: ');
    sintReadln(conta);
    if conta = '' then
        senha := ''
    else
        begin
            sintWriteln('Informe a senha: ');
            sintSenha(senha);
        end;
    sintWriteln ('Nome do arquivo:');
    chdir('c:\winvox\treino');
    nomeArq := obtemNomeArq (wherey);
    assignFile (arq, nomeArq);
    {$I-}  reset (arq, 1);  {$I+}
    if ioresult <> 0 then
        begin
            sintWriteln ('Arquivo inexistente, aperte enter');
            readln;
        end
    else
        if abreSite (uploadSite) then
            begin
                PostFile (conta, senha, nomeArq);
                codRet := readlnRede(sockHTTP);
                writeln(codRet);
                if copy(codret, 1, 3) = '200' then
                    sintWriteln ('Ok, transmitido')
                else
                    sintWriteln ('Erro: código de retorno: ' + codret);

                fechaConexao (sockHttp);
            end;

    closeFile (arq);
    sintFim;
    readln;
end.
