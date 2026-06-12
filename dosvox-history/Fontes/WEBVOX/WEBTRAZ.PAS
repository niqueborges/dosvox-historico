{-------------------------------------------------------------}
{
{    Webvox - Módulo de acesso a rede e arquivos
{
{    Autor: Jose' Antonio Borges
{
{    Em 14/05/98
{
{-------------------------------------------------------------}

unit WEBTRAZ;

interface
uses windows, sysutils, shellApi, webutil,
     dvcrt, dvWin, dvInet, dvArq, dvForm, dvExec, dvSsl, winsock,
     webVars, webMsg, webUrl, webCabec, webCook, webMail,
     webFtp, webJava;

function trazerPagina (nomePag: string; metodo: char): boolean;
function tipoParaDownload(s: string): boolean;   //Patrick
function voltarPagina: boolean;
function carregarArquivo (nomePag: string): boolean;
procedure recarregaPagina;

implementation
uses webBmark;

var quantosTrazidos: int64;
    autentProxy: boolean;
    tipoHTTP: string;
    ultimaBusca: string = '';

{-------------------------------------------------------------------------}
{       Retorna verdadeiro caso um Content-Type seja válido para download
{-------------------------------------------------------------------------}

function tipoParaDownload(s: string): boolean;   //Patrick
begin
    result := false;
    s := lowercase(s);
    if (s = 'application/download') or   //Retirada de trazTextoHTTP
        (s = 'application/octet-stream') or
        (s = 'application/zip') or
        (s = 'application/x-msdownload') or
        (s = 'application/force-download') then
            result := true;
end;

{--------------------------------------------------------}
{       Fala o tamanho do arquivo
{--------------------------------------------------------}

procedure falaTamanhoArq (tam: int64);
var
    medida: char;
    decimal: longint;
begin
    medida := ' ';
    if tam >= 65536 then
        begin
            medida := 'K';
            decimal := tam mod 1024;
            tam := tam div 1024;
            if decimal > 512 then tam := tam + 1;
        end;

    sintWrite (intToStr (tam) + medida);
end;

{-------------------------------------------------------------}
{                 recebe cabecalho e pagina
{-------------------------------------------------------------}

function recebeTextoHTTP (nomeArq, nome: string): boolean;
var
   arq: file;
   s: string;
   lidos, erro: integer;
   trazendo, comClek: boolean;
   k, maxRecebe: int64;
   c: char;
   opCancel: char;
label fim, erroDisco;

begin
    recebeTextoHTTP := true;
    quantosTrazidos := 0;
    s := sintAmbiente ('WEBVOX', 'CLEK') + 'S'; // no mínimo uma letra
    c := s[1];
    comClek := upcase (c) <> 'N';

    if debug then
        writeln ('Arquivo de trabalho: ', nomearq);

    assign (arq, nomeArq);
    {$I-}  rewrite (arq, 1);  {$I+}
    if ioresult <> 0 then
        begin
erroDisco:
            mensagem ('WBERRDSK', 1);  {'Problemas para gravar texto no disco'}
            recebeTextoHTTP := false;
            {$I-}  close (arq);  {$I+}
            if ioresult <> 0 then;
            fechaConexao (sockHTTP);
            exit;
        end;

    if posBufRecebe < lidosBufRecebe then
        begin
            {$I-}  blockWrite (arq, bufRecebe [posBufRecebe], lidosBufRecebe-posBufRecebe);  {$I+}
            quantosTrazidos := lidosBufRecebe-posBufRecebe;
            if ioresult <> 0 then goto erroDisco;
            lidosBufRecebe := 0;   {programação preventiva}
        end;

    s := buscaInfoCabec ('Content-length:');
    val (s, k, erro);
    if erro <> 0 then k := $7ffffffffffffff0;  // infinito

    maxRecebe := k;
    trazendo := true;
    while trazendo and
        ((quantosTrazidos < maxRecebe) or (maxRecebe = 0)) do
        begin
            repeat
                if keypressed then
                    begin
                        c := readkey;
                        if c = ' ' then
                            begin
                                comClek := not comClek;
                                sintBip;
                            end
                        else
                        if c = #$1b then
                            begin
                                mensagem ('WBCANCEL', 0);  {'Confirma o cancelamento? (S/N): '}
                                opCancel:= popupMenuPorLetra ('SN');
                                writeln;
                                if opCancel = 'S' then
                                begin
                                    mensagem ('WBRECINT', 1);
                                    exit;
                                end;
                            end
                        else
                            begin
                                write (#$0d);  clreol;
                                sintWriteInt ((quantosTrazidos * 100) div k);
                                if (s <> '') and (erro = 0) then
                                    begin
                                        sintWrite ('% de ');
                                        falaTamanhoArq (k);
                                    end;
                                if nomeArqDownload = '' then sintWrite (' ' + nomeResumido (nome))
                                else sintWrite (' ' + nomeResumido (nomeArqDownload)); //Patrick. Para aqueles que tem nome de download obtido
                                write ('  ');
                            end;
                    end;

            until chegouRede (sockHTTP);

            if maxRecebe-quantosTrazidos >= BUFSIZE then
                lidos := receiveBuf (sockHTTP, bufRecebe, BUFSIZE, 0)
            else
                lidos := receiveBuf (sockHTTP, bufRecebe, maxRecebe-quantosTrazidos, 0);

            if (lidos <= 0) then
                goto fim;

            if comClek then sintClek;

            quantosTrazidos := quantosTrazidos + lidos;

            {$I-}  blockWrite (arq, bufRecebe, lidos);  {$I+}
            if ioresult <> 0 then goto erroDisco;
        end;
fim:
    fechaConexao (sockHTTP);

    {$I-}  close (arq);  {$I+}
    if ioresult <> 0 then goto erroDisco;
    exit;
end;

{-------------------------------------------------------------}
{                trata Gzip
{-------------------------------------------------------------}

procedure trataGzip (nomeTemp: string);
var
    arq: file;
    nomeNovo, dirDosvox: string;
begin
    nomeNovo := nomeTemp + '.gz';
    assign (arq, nomeTemp);
    {$I-} rename (arq, nomeNovo);  {$I+}
    if ioresult <> 0 then;

    dirDosvox := sintAmbiente('DOSVOX', 'PGMDOSVOX');
    if (dirDosvox <> '') and (dirDosvox[length(dirDosvox)] <> '\') then dirDosvox := dirDosvox + '\';

    mensagem  ('WBGZIP', 1);  {'Descomprimindo com gzip'}
    while sintFalando do waitMessage;
    if executaProgEx (dirDosvox + 'gzip.exe', '.', '-d ' + nomeTemp+'.gz', SW_SHOWMINIMIZED) < 32 then
        begin
            mensagem ('WBGZIPNO', 1);  {'GZIP não está instalado'}
            assign (arq, nomeNovo);
            {$I-} rename (arq, nomeTemp);  {$I+}
            if ioresult <> 0 then;
        end
    else
        esperaProgVoltar;
end;

{-------------------------------------------------------------}
{                envia pedido de home page
{-------------------------------------------------------------}

function trazTextoHTTP (metodo, net_loc, nome, tipoHTTP: string; autent: string): integer;
var
    tempPath, tempFileName: array [0..144] of char;
    codigo: integer;
    sn, ext: string[15];
    tipo: string;
    penv, faltaEnviar, enviados: integer;
    p: pointer;
    ind: integer;
    posfname: integer;

begin
    nome := urlEnc (nome);
    StrPCopy (bufEnvia, metodo + ' ' + nome + ' HTTP/'+ tipoHTTP + CRLF);
    sendBuf (sockHTTP, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    StrPCopy (bufEnvia, 'Host: ' + net_loc + CRLF);
    sendBuf (sockHTTP, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    StrPCopy (bufEnvia, 'Accept-Language: pt-br' + CRLF);
    sendBuf (sockHTTP, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    StrPCopy (bufEnvia, 'UA-CPU: x86' + CRLF);
    sendBuf (sockHTTP, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

//Google parou de funcionar, modificado pela linha abaixo em 28/01/2025    StrPCopy (bufEnvia, 'User-Agent: Webvox ' + versao + CRLF);
    StrPCopy (bufEnvia, 'User-Agent: Lynx ' + versao + CRLF);
    sendBuf (sockHTTP, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    StrPCopy (bufEnvia, 'Connection: Close ' + versao + CRLF);
    sendBuf (sockHTTP, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    if autent <> '' then
        begin
            if autentProxy then
                StrPCopy (bufEnvia, 'Proxy-Authorization: Basic ' + base64 (autent) + CRLF)
            else
                StrPCopy (bufEnvia, 'Authorization: Basic ' + base64 (autent) + CRLF);
            sendBuf (sockHTTP, bufEnvia, strlen (bufEnvia), 0);
            netDebug (bufEnvia, strlen (bufEnvia));
        end;

        if debug then
            begin
                sintWrite ('Aperte enter');
                readln;
            end;

    enviaCookies;

    if metodo = 'POST' then
        begin
            str (tamDadosPost, sn);
            if maiuscAnsi (copy (formContentType, 1, 9)) = 'MULTIPART' then
               StrPCopy (bufEnvia, 'Content-Type: ' + formContentType +
                                   '; ' + 'boundary=' + chaveMime + CRLF)
            else
                StrPCopy (bufEnvia, 'Content-Type: ' + formContentType + CRLF);

            sendBuf (sockHTTP, bufEnvia, strlen (bufEnvia), 0);
            netDebug (bufEnvia, strlen (bufEnvia));

            StrPCopy (bufEnvia, 'Content-Length: ' + sn + CRLF);
            sendBuf (sockHTTP, bufEnvia, strlen (bufEnvia), 0);
            netDebug (bufEnvia, strlen (bufEnvia));
        end;

    StrPCopy (bufEnvia, CRLF);
    sendBuf (sockHTTP, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    if metodo = 'POST' then
        begin
            faltaEnviar := tamDadosPost;
            penv := 0;
            repeat
                p := @dadosPost[penv];
                enviados := sendBuf (sockHTTP, p, faltaEnviar, 0);
                faltaEnviar := faltaEnviar - enviados;
                penv := penv + enviados;
            until (faltaEnviar = 0) or (enviados = 0);
            // netDebug (dadosPost, strlen (dadosPost));
        end;

    codigo := trazCabecHttp;
    if debug then
        debugCabec;

    if codigo <> 504 then
        begin
            getTempPath (144, tempPath);
            getTempFileName(tempPath, 'web', 0, tempFileName);
            nomeTemp := strPas (tempFileName);

            tipo := buscaInfoCabec ('Content-type:');
            if tipo = '' then
                tipo := 'text/html';

            nomeArqDownload := '';
            if tipoParaDownload (tipo) then   //Patrick se for content-type válido para download
                begin
                    nomeArqDownload := buscaInfoCabec ('Content-Disposition: attachment;'); //Mais garantido de ser algo para baixar
                    posfname := pos ('filename=', nomeArqDownload);
                    if posfname = 0 then
                        nomeArqDownload := ''
                    else
                        begin
                            delete (nomeArqDownload, 1, posfname+8);
                            nomeArqDownload := trim (nomeArqDownload);
                        end;
                end;

            tipoCodificacao := buscaInfoCabec ('Content-encoding:');

            charsetAtual := '';
            ind := pos ('charset', tipo);
            if ind <> 0 then
                begin
                    charsetAtual := maiuscAnsi (copy (tipo, ind+8, 999));
                    while (ind > 1) do
                        begin
                            ind := ind - 1;
                            if tipo[ind] = ';' then
                                    begin
                                    delete (tipo, ind, 999);
                                    tipo := trim (tipo);
                                    break;
                                end;
                        end;
                end;

            ext := '';
            if tipo = 'text/plain' then  ext := 'TXT'
            else
            if (tipo = 'audio/midi') or (tipo = 'audio/mid') then  ext := 'MID'
            else
            if tipo = 'audio/mpeg' then  ext := 'MP3'
            else
            if tipo = 'audio/x-pn-realaudio' then ext := 'RAM'
            else
            if tipo = 'audio/x-wav' then ext := 'WAV'
            else
            if tipo = 'text/html' then   ext := 'HTM'
            else
            if tipo = 'application/xhtml+xml' then   ext := 'HTM'
            else
            if tipo = 'application/xhtml' then   ext := 'HTM';

            if ext <> '' then
                begin
                    delete (nomeTemp, length (nomeTemp)-2, 3);
                    nomeTemp := nomeTemp + ext;
                end;

             if not recebeTextoHTTP (nomeTemp, nome) then
                begin
                    mensagem ('WBRECINT', 1);  {'Recepção interrompida'}
                    codigo := 500;
                    cabecHttp[1] := 'HTTP/' + tipoHTTP + ' 500 Recepção interrompida';
                end
            else
                begin
                    if maiuscAnsi (tipoCodificacao) = 'GZIP' then
                        trataGzip (nomeTemp);
                end;
        end;

    trazTextoHTTP := codigo;
end;

{-------------------------------------------------------------}
{                        ajuda
{-------------------------------------------------------------}

procedure ajudaTrazPag;
begin
    mensagem ('WBAJU101', 1);  {'Tecle um nome tradicional da web, por exemplo:'}
    mensagem ('WBAJU102', 1);  {'http://www.nomedaempresa.com.br'}
    mensagem ('WBAJU103', 1);  {'Para acessar a página do DOSVOX tecle'}
    mensagem ('WBAJU104', 1);  {'http://intervox.nce.ufrj.br/dosvox'}
    writeln;
end;

{-------------------------------------------------------------}
{                registra página trazida na pilha
{-------------------------------------------------------------}

procedure registraPilha (nomePag, nomeTemp: string; linhaAtual: integer; tempApagavel: boolean);
var i: integer;
begin
    if topoPilhaPag < MAXPILHA then
        topoPilhaPag := topoPilhaPag + 1
    else
        begin
            dispose (pilhaPag[1]);
            for i := 1 to MAXPILHA-1 do
                pilhaPag [i] := pilhaPag [i+1];
        end;
    new (pilhaPag [topoPilhaPag]);

    with pilhaPag [topoPilhaPag]^ do
        begin
            nomePagina := nomePag;
            nomePagAtual := nomePag;      { variáveis globais }
            posicao := linhaAtual;
            posFormPreenc := ntagsForms;
            nomeArqTemp := nomeTemp;
            podeApagarTemp := tempApagavel;
            jaCompilado := false;
            charset := charsetAtual;
            tituloPagPilha := nomePag;
            usaSSLPilha := usaSSL;
        end;
end;

{-------------------------------------------------------------}
{           traz uma pagina HTTP de um arquivo local
{-------------------------------------------------------------}

function carregarArquivo (nomePag: string): boolean;
var arq: text;
    tipo, rotulo: string;
    i: integer;
    dir: string;

label erroDisco;
begin
    carregarArquivo := false;
    if nomePag = '' then
        begin
            mensagem ('WBINFARQ', 1);  {'Informe o nome o arquivo a carregar'}
            garanteEspacoTela (10);
            nomePag := obtemNomeArq (10);
            writeln (nomePag);
        end;

    while (nomePag <> '') and (nomePag[1] = ' ') do delete (nomePag, 1, 1);
    if nomePag = '' then exit;

    getDir (0, dir);
    if nomePag [2] <> ':' then
        nomePag := dir[1] + ':' + nomePag;

    completaEsquema (nomePag);
    if (copy (maiusc(nomePag), 1, 7) <> 'FILE://') then
        begin
            carregarArquivo := trazerPagina (nomePag, 'G');
            exit;
        end;

    delete (nomePag, 1, 7);

    for i := 1 to length (nomePag) do
        if nomePag[i] = '/' then nomePag[i] := '\';

    getDir (0, dir);
    if nomePag[1] = '\' then
         nomePag := dir[1] + ':' + nomePag
    else
    if nomePag [2] <> ':' then
        begin
            if dir [length(dir)] = '\' then delete (dir, length(dir), 1);
            nomePag := dir + '\'  + nomePag;
        end;

    { abre arquivo }

    assign (arq, nomePag);
    {$I-}  reset (arq);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('WBARQNAO', 1);  {'Este arquivo não existe'}
            exit;
        end;
    close (arq);

    nlinCabecHTTP := 1;

    i := length (nomepag);
    while (i > 1) and (nomePag[i] <> '.') do
        i := i - 1;
    tipo := maiusc (copy (nomePag, i, 9999));
    if (tipo = '.TXT') then
        cabecHTTP [1] := 'Content-type:text/plain'
    else
    if (tipo = '.MID') or (tipo = '.MIDI') then
        cabecHTTP [1] := 'Content-type:audio/midi'
    else
    if (tipo = '.RAM') or (tipo = '.RM') then
        cabecHTTP [1] := 'Content-type:audio/x-pn-realaudio'
    else
    if (tipo = '.ZIP') then
        cabecHTTP [1] := 'Content-type:application/zip'
    else
    if (tipo = '.WAV') then
        cabecHTTP [1] := 'Content-type:audio/x-wav'
    else
    if (tipo = '.MP3') then
        cabecHTTP [1] := 'Content-type:audio/mpeg'
    else
    if (tipo = '.WMA') then
        cabecHTTP [1] := 'Content-type:audio/x-ms-wma'
    else
    if (tipo = '.BMP') then
        cabecHTTP [1] := 'Content-type:image/bmp'
    else
    if (tipo = '.GIF') then
        cabecHTTP [1] := 'Content-type:image/gif'
    else
    if (tipo = '.JPG') then
        cabecHTTP [1] := 'Content-type:image/jpeg'
    else
    if (tipo = '.MPG') or (tipo = '.MPEG') then
        cabecHTTP [1] := 'Content-type:video/mpeg'
    else
    if (tipo = '.WMV') then
        cabecHTTP [1] := 'Content-type:video/msvideo'

    else
        cabecHTTP [1] := 'Content-type:text/html';

    { guarda em formato padrao HTTP }

    nomeTemp := nomePag;
    rotulo := '';    {provisório}

    for i := 1 to length (nomePag) do
        if nomePag[i] = '\' then nomePag[i] := '/';
    nomePagAtual := 'file://'+ nomePag;

    linhaAtual := 1;
    nomeBase := nomePagAtual;
    registraPilha (nomePagAtual, nomeTemp, linhaAtual, false);

    if falarCarregamento then //Neno
        mensagem ('WBOK', 1);  {'OK'}
    carregarArquivo := true;
end;

{-------------------------------------------------------------}
{            se com proxy, checa se tem barra final
{-------------------------------------------------------------}

function checaBarraFinal (uriPag: string): string;
var i: integer;
label fim;
begin
    checaBarraFinal := uriPag;
    if maiusc (copy (uriPag, 1, 7)) <> 'HTTP://' then exit;

    delete (uriPag, 1, 7);
    if pos ('/', uripag) <> 0 then exit;

    i := pos (';', uriPag);
    if i <> 0 then goto fim;

    i := pos ('?', uriPag);
    if i <> 0 then goto fim;

    i := length (uriPag) + 1;

fim:
    insert ('/', uriPag, i);
    checaBarraFinal := 'HTTP://' + uriPag;
end;

{-------------------------------------------------------------}
{                    Testa se  o endereço é página de internet ou não
{-------------------------------------------------------------}

function enderecoInternet (nomePag: string): boolean;
begin
    nomePag := uppercase (trim (nomePag));
    if (copy (nomePag, 1, 7) = 'HTTP://') or
       (copy (nomePag, 1, 8) = 'HTTPS://') or
       (copy (nomePag, 1, 4) = 'WWW.') or
       ((pos ('.', nomePag) <> 0) and (pos(' ', nomePag) = 0)) or
       (pos ('/', nomePag) <> 0) then
        result := true
    else
        result := false;
end;

{-------------------------------------------------------------}
{                    Monta o endereço de busca no Google
{-------------------------------------------------------------}

function nomePagBuscarNoGoogle (nomePag: string): string;
const
    g1: string = 'http://www.google.com.br/search?ie=ISO%2D8859%2D1&hl=pt%2DBR&source=hp&biw=&bih=&q=';
    g2: string = '&btnG=Pesquisa+Google&gbv=1';
begin
    result := g1 + ansiToIso88591 (nomePag) + g2;
end;

{-------------------------------------------------------------}
{                    traz uma pagina
{-------------------------------------------------------------}

function trazerPagina (nomePag: string; metodo: char): boolean;
var
    scheme, net_loc, path, params, query: string;
    fragment: string;
    hostPag, uriPag: string;
    codigo, portaPag: word;
    nomeAbsoluto: string;
    msgAutent, autent: string;
    rebuscando: boolean;
    p: integer;
    conta, senha: string;
    primeiraTent: boolean;
    tit: string;
    c: char;

label
    registra, rebusca, deNovo, trazDeNovo;

begin
    trazerPagina := false;
    rebuscando := false;
    autent := '';
    primeiraTent := true;

    if nomePag = '' then
        begin
deNovo:
            mensagem ('WBPAGTRA', 1);  {'Informe o nome da página a trazer (? ajuda)'}
            nomePag := ultimaBusca;
            c := sintEdita (nomePag, wherex, wherey, 250, true);
            writeln;

            if c = ESC then
                begin
                    result := false;
                    mensagem ('WBDESIST', 1);  {'Desistiu...'}
                    exit;
                end;

            if c = BAIX then
                begin
                    folheiaBookMarks;
                    result := false;
                    exit;
                end;

            if nomePag = '?' then
                begin
                    ajudaTrazPag;
                    goto deNovo;
                end;

            if nomePag = '' then exit;
            if not enderecoInternet (nomePag) then
                begin
                    ultimaBusca := nomePag;
                    nomePag := nomePagBuscarNoGoogle (nomePag);
                end;

            metodo := 'G';
            completaEsquema (nomePag);
            linhaAtual := 1;
        end;

    if nomePag = '?' then
        begin
            ajudaTrazPag;
            goto deNovo;
        end;

rebusca:
    tit := 'WEBVOX Buscando ' + nomePag;
    setWindowText (crtWindow, @tit[1]);

    if pos ('JAVASCRIPT:', maiuscAnsi (nomePag)) <> 0 then
         nomePag := simulaJavaScript (nomePag);

    compilaURL (nomePag, scheme, net_loc, path, params, query, fragment);
    if scheme = 'MAILTO' then
         begin
             if net_loc = '' then net_loc := path;
             miniCorreio (net_loc);
             exit;
         end;

    if (scheme = 'FTP') and (not comProxy) then
         begin
             miniFtp (net_loc, path);
             exit;
         end;

    if scheme = 'FILE' then
        begin
            cookie := '';
            delete (nomepag, 1, 7);
            StringReplace(nomepag, '/', '\', [rfReplaceAll]);
            trazerPagina := carregarArquivo (nomePag);
            exit;
        end;

    if (scheme = 'MMS') or (scheme = 'RTSP') then
        begin
            mensagem ('WBEXECAT', 2);  {'Executor ativado'}
            executaProg (nomePag, '', '');
            exit;
        end;

    usaSSL := scheme = 'HTTPS';
    if ((scheme = 'HTTP') or (scheme = 'HTTPS')) and (net_loc = '') then
        begin
            montaURLrelativa (nomePag, nomeBase, nomeAbsoluto);
            nomePag := nomeAbsoluto;
            compilaURL (nomePag, scheme, net_loc, path, params, query, fragment);
        end;

    rotuloInicial := fragment;

    if (scheme <> 'HTTP') and (scheme <> 'HTTPS') and
       (scheme <> 'FILE') and (scheme <> 'FTP') then
        begin
            mensagem ('WBSOHTTP', 1);  {'Este programa só aceita páginas HTTP ou FTP'}
            exit;
        end;

    montaCookies (nomePag);

    {... completar - verificar se página anteriormente carregada e assim não trazer ...}

    if not rebuscando then
        begin
            if (not mudo) and (falarCarregamento) then
                mensagem ('WBCONTAC', 1)  {'Contactando...  '}
            else
                writeln (pegaTextoMensagem ('WBCONTAC')); {'Contactando...  '}
            while sintFalando do waitMessage;
        end;

trazDeNovo:
    if comProxy then
         sockHTTP := abreConexao (hostProxy, portaProxy)
    else
         begin
             extraiNomePorta (scheme, net_loc, hostPag, portaPag);
             // if debug then
                 // writeln ('NET_LOC ', net_loc, '->', hostPag, '->', portaPag);

             if usaSSL then
                 sockHTTP := abreConexaoSSL (hostPag, portaPag)
             else
                 sockHTTP := abreConexao (hostPag, portaPag);
          end;

    if (sockHTTP <= 0) then
        begin
            mensagem ('WBNAOCON', 1);     {'Não consegui realizar a conexão'}
            exit;
        end;

    if comProxy then
        uriPag := checaBarraFinal (nomePag)
    else
        begin
            uriPag := path;
            if params <> '' then uriPag := uriPag + ';' + params;
            if query  <> '' then uriPag := uriPag + '?' + query;
        end;

    tipoHTTP := '1.0';
//    if pos ('alertatotal.net', nomePag) <> 0 then tipoHTTP := '1.0';   // provisório

    if metodo = 'G' then
        codigo := trazTextoHTTP ('GET', net_loc, uriPag, tipoHTTP, autent)
    else
        codigo := trazTextoHTTP ('POST', net_loc, uriPag, tipoHTTP, autent);

    writeln;
    if (codigo = 301) or (codigo = 302) or (codigo = 303) then   // ************** verificar
        begin
            cookie := obtemCookie;
            if cookie <> '' then
               gravaCookie (cookie, nomePag);

            nomeBase := nomePag;
            nomePag := buscaInfoCabec ('Location:');
            montaURLrelativa (nomePag, nomeBase, nomeAbsoluto);
            nomePag := nomeAbsoluto;
            writeln (pegaTextoMensagem ('WBPAGALT'));  {'Buscando página alternativa'}
            writeln (nomePag);
            rebuscando := true;
            goto rebusca;
        end;

    if (codigo = 401) or (codigo = 407) then   // ***** verificar ******
        begin
            if codigo = 401 then
                begin
                    msgAutent := buscaInfoCabec ('WWW-Authenticate:');
                    autentProxy := false;
                end
            else
                begin
                    msgAutent := buscaInfoCabec ('Proxy-Authenticate:');
                    autentProxy := true;
                end;
            p := pos ('realm', msgAutent);
            while (p <= length (msgAutent)) and (msgAutent[p] <> '=') do p := p + 1;
            msgAutent := copy (msgAutent, p+2, 999);

            if primeiraTent and (msgAutent = ultMsgAutent) then
                begin
                    autent := ultAutent;
                    primeiraTent := false;
                    goto trazDeNovo;
                end;

            if autent = '' then
                mensagem ('WBAUTENT', 1)    {'Servidor solicitou autenticação'}
            else
                mensagem ('WBERRAUT', 1);    {'Autenticação não foi aceita'}
            sintWriteln (msgAutent);

            mensagem ('WBCONTA', 0);   {'Informe sua conta  '}
            sintReadln (conta);
            if conta = '' then
                begin
                    linhaAtual := 1;
                    registraPilha (nomePag, '$#$', linhaAtual, true);
                    mensagem ('WBDESIST', 1);  {'Desistiu...'}
                    exit;
                end;

            mensagem ('WBSENHA', 0);   {'Informe sua senha  '}
            p := textAttr;
            textColor (black);
            readln (senha);
            textAttr := p;

            autent := conta + ':' + senha;
            ultMsgAutent := msgAutent;
            ultAutent := autent;
            goto trazDeNovo;
        end;

    if codigo = 403 then
        begin
            textBackground (RED);
            mensagem ('WBCOBLOQ', 0);   {'Conteúdo do site está bloqueado.'}
            textBackground (BLACK);
            writeln;
            mensagem ('WBAPTENT', 1);   {'Aperte enter'}
            repeat
                c := readkey;
            until (c = ENTER) or (c = ESC);
            if c = ESC then
                begin
                    mensagem ('WBDESIST', 1);  {'Desistiu...'}
                    exit;
                end;
        end;

    if (codigo = 200) or (codigo = 305) or (codigo = 403) then    // 305 tratado parcialmente
        begin
            cookie := obtemCookie;
            if cookie <> '' then
               gravaCookie (cookie, nomePag);
            if (not mudo) and (falarCarregamento) then
               mensagem ('WBOK', 1) {'OK'}
            else
               writeln (pegaTextoMensagem ('WBOK')); {'OK'}
            linhaAtual := 1;      { *** verificar se fragmento *** }
            registraPilha (nomePag, nomeTemp, linhaAtual, true);
            nomeBase := nomePag;
            trazerPagina := true;
        end
    else
        begin
            linhaAtual := 1;
            registraPilha (nomePag, '$#$', linhaAtual, true);
            mensagem ('WBNAOPAG', 1);   {'Página não foi trazida'}
            mensagem ('WBMSGSRV', 1);   {'Mensagem do servidor'}
            sintWriteln (cabecHTTP [1]);
        end;

    tituloJan := nomePag;
    tit := 'WEBVOX ' + tituloJan;
    setWindowText (crtWindow, @tit[1]);
end;

{-------------------------------------------------------------}
{                 voltar à penultima página lida
{-------------------------------------------------------------}

function voltarPagina: boolean;
var arq: file;
    i: integer;
    tit: string;
begin
    { provisorio }
    voltarPagina := false;
    nlinCabecHTTP := 1;
    cabecHTTP [1] := 'Content-type:text/html';

    if topoPilhaPag <= 1 then
         begin
             mensagem ('WBNAOVOL', 1);    {'Não posso, estou primeira página lida'}
             exit;
         end;

    if pilhaPag [topoPilhaPag]^.podeApagarTemp then
        begin
            assign (arq, pilhaPag [topoPilhaPag]^.nomeArqTemp);
            {$I-}  erase (arq);  {$I+}
            if ioresult <> 0 then;
        end;

    with pilhaPag [topoPilhaPag]^ do
        begin
            for i := posFormPreenc+1 to ntagsForms do
                tagsForms^[i] := '';
            ntagsForms := posFormPreenc;
        end;

    topoPilhaPag := topoPilhaPag - 1;
    with pilhaPag [topoPilhaPag]^ do
        begin
            nomePagAtual := nomePagina;
            linhaAtual := posicao;
            nomeTemp := nomeArqTemp;
            charsetAtual := charset;
            tituloJan := tituloPagPilha;
            usaSSL := usaSSLPilha;
         end;

    nomeBase := nomePagAtual;

    mensagem ('WBVOLPAG', 1);    {'Voltando à pagina anterior'}
    writeln (nomePagAtual);

    tit := 'WEBVOX ' + tituloJan;
    setWindowText (crtWindow, @tit[1]);
    voltarPagina := true;
end;

{-------------------------------------------------------------}
{                 recarrega página atual
{-------------------------------------------------------------}

procedure recarregaPagina;
var arq: file;
    aTrazer: string;
    i: integer;
begin
    { provisorio }
    nlinCabecHTTP := 1;
    cabecHTTP [1] := 'Content-type: text/html';

    if topoPilhaPag < 1 then
         begin
             mensagem ('WBSEMPAG', 1);    {'Não tenho página na memória'}
             exit;
         end;

    if pilhaPag [topoPilhaPag]^.podeApagarTemp then
        begin
            assign (arq, pilhaPag [topoPilhaPag]^.nomeArqTemp);
            {$I-}  erase (arq);  {$I+}
            if ioresult <> 0 then;
        end;

    for i := pilhaPag [topoPilhaPag]^.posFormPreenc+1 to ntagsForms do
        tagsForms^[i] := '';
    ntagsForms := pilhaPag [topoPilhaPag]^.posFormPreenc;

    aTrazer := pilhaPag [topoPilhaPag]^.nomePagina;

    topoPilhaPag := topoPilhaPag - 1;
    nomeBase := '';
    nomePagAtual := '';

    trazerPagina (aTrazer, 'G');
end;

end.
