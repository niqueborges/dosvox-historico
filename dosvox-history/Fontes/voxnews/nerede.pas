unit nerede;

interface
uses
    sysutils,
    dvcrt,
    dvinet,
    dvssl,
    dvexec;

function HttpDownload (site: string; var status: integer): string;

// funções acessórias, úteis em algumas situações de programação de rede

function UrlEncode(s: String): String;

procedure URLcompile (URL: string;
                      var scheme, server: string;
                      var port: integer;
                      var path, fragment: string);


implementation

{-------------------------------------------------------------}
{                muda nome quando acentuado
{-------------------------------------------------------------}

function UrlEncode (s: String): String;
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
{             extrai as partes da sintaxe da URL
{              (algoritmo baseado na RFC1808)
{-------------------------------------------------------------}

procedure URLcompile (URL: string;
                      var scheme, server: string;
                      var port: integer;
                      var path, fragment: string);
var i, p, p2: integer;
    net_loc: string;
    erro: integer;

label fim;
begin
    scheme := 'HTTP';
    net_loc := '';
    path := '';
    fragment := '';

    p := pos ('#', URL);
    if p <> 0 then
        begin
            fragment := copy (URL, p+1, length (URL)-p);
            delete (URL, p, length (URL)-p+1);
        end;

    p := pos ('://', URL);
    if (p <> 0) and (p < 10) then
         begin
             scheme := copy (URL, 1, p-1);
             for i := 1 to length (scheme) do
                 scheme [i] := upcase(scheme [i]);
             delete (URL, 1, p+2);
         end;

    p := pos ('/', URL);
    if p = 0 then
        begin
            p  := pos ('?', URL);
            p2 := pos (';', URL);
            if (p = 0) and (p2 > p) then p := p2;
            if p <> 0 then
                insert ('/', URL, p);
        end;

    if p = 0  then
        begin
            net_loc := URL;
            URL := '';
        end
    else
        begin
            net_loc := copy (URL, 1, p-1);
            delete (URL, 1, p-1);
        end;

    server := net_loc;

    p := pos (':', net_loc);
    if scheme = 'HTTPS' then
        port := 443
    else
        port := 80;

    if p <> 0 then
        begin
           val (copy (net_loc, p+1, length (net_loc)-p), port, erro);
           if erro <> 0 then port := 80;
           server := copy (net_loc, 1, p-1);
        end;

    path := URL;
    if (net_loc <> '') and (path = '') then
        path := '/';

    path := urlEncode(path);
end;

{-------------------------------------------------------------}
{                download em http para a memória
{-------------------------------------------------------------}

function HttpDownload (site: string; var status: integer): string;
var
    proto, server: string;
    port: integer;
    path, fragment: string;

    sockHTTP: integer;
    pbuf: PbufRede;
    s, header: string;
    p: pchar;
    aReceber: integer;
    i, n, falta: integer;
    c: char;
    emGzip: boolean;
    httpMsg, sai: string;

label erroHTTP, redirecao;
begin
redirecao:
    result := '';
    status := -1;

    URLcompile (site, proto, server, port, path, fragment);
    httpMsg :=
        'GET' + ' ' + path + ' HTTP/1.0' + ^m^j +
        'Host: ' + server + ^m^j +
        'Accept-Language: pt-br' + ^m^j +
        'UA-CPU: x86' + ^m^j +
        'User-Agent: VoxNews 1.0' + ^m^j +
         ^m^j;

    // ainda não foi feito o processamento de proxy

    if upperCase (proto) = 'HTTPS' then
        sockHTTP := abreConexaoSSL (server, 443)
    else
        sockHTTP := abreConexao (server, port);

    if sockHTTP <= 0 then exit;

    falta := length(httpMsg);
    p := pchar(httpMsg);
    repeat
         n := sendBuf (sockHTTP, p, falta, 0);
         p := p + n;
         falta := falta - n;
    until (falta = 0) or (n <= 0);

    pbuf := inicBufRede (sockHTTP);
    if not readlnBufRede (pbuf, header, 20) then goto erroHttp;
    if copy (header, 1, 4) <> 'HTTP'        then goto erroHttp;

    delete (header, 1, pos(' ', header));
    delete (header, pos(' ', header), 999);
    try
        status := strToInt (trim(header));
    except
        status := -1;
    end;

    if status = -1 then goto erroHTTP;

    aReceber := 999999999;
    emGzip := false;
    repeat
        if not readlnBufRede (pbuf, s, 10) then goto erroHttp;

        if upperCase(copy (s, 1, 9)) = 'LOCATION:' then
            if (status div 100) = 3 then
                 begin
                     site := trim (copy (s, 10, 999));
                     fechaConexao(sockHTTP);
                     delay (2000);
                     goto redirecao;
                 end;

        if upperCase (copy (s, 1, 15)) = 'CONTENT-LENGTH:' then
            aReceber := strToInt (trim(copy (s, 16, 999)))
        else
        if upperCase(copy (s, 1, 17)) = 'CONTENT-ENCODING:' then
            emGzip := trim (copy (s, 18, 999)) = 'gzip';
    until s = '';

    sai := '';
    for i := 1 to aReceber do
        begin
            if leCaracBufRede (pbuf, c) then
                sai := sai + c
            else
                break;
        end;

    if emGzip then
        ; //  ainda não foi implementa a descompressão para GZIP');

    result := sai;

erroHttp:
    fechaConexao(sockHTTP);
end;

end.
