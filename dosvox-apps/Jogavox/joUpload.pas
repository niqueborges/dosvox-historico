{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Módulo de upload do jogo
{
{    Autores: José Antonio Borges
{             Patrick Barboza
{
{    Em Dezembro/2024
{
{--------------------------------------------------------}

unit joUpLoad;

interface

uses
    dvCrt,
    dvWin,
    windows,
    sysUtils,
    classes,
    dvInet,
    dvSsl,
    dvExec,
    joVars,
    joMsg,
joUtil;

procedure upLoad;

implementation

const
    URL_UPLOAD_DEFAULT = URL_JOGOS_DEFAULT + 'Caos/delphi_upload.php';
    BUFSIZE = 4096;         { tamanho do buffer de rede }
    CRLF = #$0d + #$0a;

var
    sockHTTP: integer;
    servidor, site: string;

{--------------------------------------------------------}
{                 Comprimir o arquivo zip
{--------------------------------------------------------}

function compacta(pastaJogo:string): string;
var
    compactador, dirAtual, param: String;
begin
    result := '';
    getDir(0, dirAtual);
    chDir(dirBaseJogos);

    if fileExists(obtemDirDosvox+'\zip.exe') then
        begin
            compactador := '"' + obtemDirDosvox + '\zip.exe" -r';
            param := '"'+pastaJogo+'.zip" "'+pastaJogo+'"';
            executaProgEX (compactador, dirBaseJogos, param, SW_SHOWMINIMIZED);
            delay(1000);
            esperaProgVoltar;
        end
    else
        begin
            chDir(dirAtual);
            exit;
        end;
    chDir(dirAtual);
    result := pastaJogo;
end;

{-------------------------------------------------------------}
{    abre o site de upload, obtém servidor e lugar do site
{-------------------------------------------------------------}

function abreSite: boolean;
var i: integer;
    s: string;
begin
    abreWinSock;

    s := sintAmbiente('JOGAVOX', 'SITEUPLOAD', URL_UPLOAD_DEFAULT);   { se não haver valor padrão de site de upload assume default   }
    i := pos(':', s);
    servidor := copy (s, i+3, 999);
    i := pos ('/', servidor);
    site := copy (servidor, i, 999);
    delete (servidor, i, 999);

    if uppercase(copy (s, 1, 5)) = 'HTTPS' then
        sockHttp := abreConexaoSSL (servidor, 443)
    else
        sockHttp := abreConexao (servidor, 80);

    if sockHttp <= 0 then
        begin
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
{                Trata o erro do servidor
{-------------------------------------------------------------}

function trataErro(erro: string): string;
var
    l: TStringList;
    res: string;
begin
    res := '';
    if pos('Senha equivocada', erro) > 0 then
        res := 'Usuário ou senha incorretos'
    else
    if pos('HTTP/1.1 404', erro) > 0 then
        res := 'HTTP/1.1 404 Not Found'
    else
        begin
            l := TStringList.Create;
            l.text := erro;
            res := utf8ToAnsi(l[7]);   //Linha da resposta do php após cabeçalho do servidor
            res := StringReplace(res, '<br>', ' ', [rfReplaceAll, rfIgnoreCase]);
            l.Free;
        end;
    result := res;
end;

{-------------------------------------------------------------}
{                Envia dados via post
{-------------------------------------------------------------}

function postFile(user_name: string; pass_word: string; file_name: string; var msgErro: string): boolean;
const
    CONTENTTYPE = 'multipart/form-data';
    TAMBUF = 8192;

var
    cabecPost, tipoAplic: string;
    buf: array [0..TAMBUF-1] of byte;
    lidos: integer;
    arq: file;
    tamArq: integer;
    chaveMime: string;
    dadosPost1, dadosPost2, dadosPost3:  string;
    tamDadosPost: integer;

begin
    result := false;
    msgErro := '';
    assignFile (arq, file_name);
    {$I-}  reset (arq, 1);  {$I+}
    if ioresult <> 0 then
        begin
            msgErro := 'JOERARQ';   {'Arquivo a enviar foi apagado ou não existe'}
            exit;
        end;

    if not abreSite then
        begin
            msgErro := 'JOERCONEC';   {'Não foi possível conectar com o servidor de upload'}
            exit;
        end;

    chaveMime := geraChaveMime;

    tipoAplic := geraTipoAplic (file_name);

    cabecPost :=
        'POST ' + site + ' HTTP/1.0' + CRLF +
        'Host: ' + servidor + CRLF +
        'Accept-Language: pt-br' + CRLF +
        'UA-CPU: x86' + CRLF +
        'User-Agent: Jogavox ' + versao + CRLF +
        'Connection: Close' + CRLF +
        'Content-Type: ' + CONTENTTYPE + '; boundary=' + chaveMime + CRLF;

    //Passa nome de usuário
    dadosPost1 :=
        '--' + chaveMime + CRLF +
        'Content-Disposition: form-data; name="username"' + CRLF +
        CRLF + user_name + CRLF +

        //Passa senha do usuário
        '--' + chaveMime + CRLF +
        'Content-Disposition: form-data; name="password"' + CRLF +
        CRLF + pass_word + CRLF;

    //Passa nome do arquivo a enviar
    dadosPost2 :=
        '--' + chaveMime + CRLF +
        'Content-Disposition: form-data; ' +
        'name="filename"; filename="' + file_name + '"' + CRLF +
        'Content-Type: ' + tipoAplic + CRLF + CRLF;

    //Fecha o post
    dadosPost3 := CRLF + '--' + chaveMime + '--' + CRLF;

    //Gera o Content-Length
    tamArq := filesize(arq);
    tamDadosPost := length(dadosPost1) +
        length(dadosPost2) + tamArq + length(dadosPost3);

    //Acrescenta ao cabeçalho o Content-Length calculado
    cabecPost := cabecPost +
        'Content-Length: ' + intToStr (tamDadosPost) + CRLF + CRLF;

    //Envia os dados
    sendBuf (sockHTTP, @cabecPost[1], length (cabecPost), 0);
    sendBuf (sockHTTP, @dadosPost1[1], length (dadosPost1), 0);
    sendBuf (sockHTTP, @dadosPost2[1], length (dadosPost2), 0);
    //Envia o arquivo sem codificação
    while not eof (arq) do
        begin
            blockRead (arq, buf, 8192, lidos);
            sendBuf (sockHTTP, @buf, lidos, 0);
        end;
    //Envia o fechamento do post
    sendBuf (sockHTTP, @dadosPost3[1], length (dadosPost3), 0);
    closeFile (arq);
    msgErro := readlnRede(sockHTTP);
    fechaConexao (sockHttp);
    //Remove o arquivo após enviado
    deleteFile(file_name);
    if pos('HTTP/1.1 200 OK', msgErro) > 0 then
        result := true
end;

{--------------------------------------------------------}
{                 Publica o jogo
{--------------------------------------------------------}

procedure upLoad;
var
    nomeConta, senha: string;
    arqEnviar, dirAtual: string;
    resUpload: string;
begin
    mensagem('JOPRENV', 1);   {'Preparando jogo para envio. Por favor, aguarde.'}

    arqEnviar := compacta(copy(dirJogo, lastDelimiter('\', dirJogo)+1, 999));
    if arqEnviar = '' then
        begin
            mensagem('JOCNAOENC', 1);   {'Programa zip.exe não encontrado'}
            exit;
        end;

    mensagem('JOPRENV2', 1);   {'Jogo pronto para envio'}
    writeln;

    mensagem('JOINFCONTA', 1);   {'Informe o nome de sua conta. Teclando enter, assumo conta pública'}
    sintReadln(nomeConta);
    if nomeConta = '' then
        senha := ''
    else
        begin
            mensagem('JOINFSENHA', 0);   {'Informe sua senha:'}
            sintSenha(senha);
        end;

    mensagem('JOENVIANDO', 1);   {'Enviando jogo, por favor, aguarde.'}

    getDir(0, dirAtual); //Diretório do jogo atualmente em edição
    chDir(dirBaseJogos); //Jogo a ser enviado fica fora da pasta do projeto em edição

    if postFile (nomeConta, senha, arqEnviar+'.zip', resUpload) then
        begin
            //Tenta enviar a capa do jogo
            if fileExists(arqEnviar+'.jpg') then
                postFile (nomeConta, senha, arqEnviar+'.jpg', resUpload);
            //Tenta enviar a descrição do jogo
            if fileExists(arqEnviar+'.txt') then
                postFile (nomeConta, senha, arqEnviar+'.txt', resUpload);
            mensagem('JOENVIADO', 2);   {'Jogo enviado com sucesso!'}
        end
    else
        begin
            mensagem('JOERROENV1', 1);   {'Erro ao enviar o jogo'}
            if pos('HTTP/', resUpload) > 0 then   //Assume que é erro do servidor
                begin
                    mensagem('JOERROENV2', 1);   {'Mensagem do servidor:'}
                    sintWriteln(trataErro(resUpLoad));
                end
            else   //Assume que é erro de arquivo ou de conexão ao servidor
                begin
                    mensagem(resUpload, 1);   //Mensagem é gerada na chamada de postFile
                end;
            end;
    chDir(dirAtual);
end;

end.
