{--------------------------------------------------------}
{                                                        }
{    Programa acesso simplificado ao Google              }
{                                                        }
{    Módulo de processamento HTTP                        }
{                                                        }
{    Autores: Antonio Borges e Fabiano Ferreira          }
{       Em maio/2013                                     }
{                                                        }
{    Atualizado por Antonio Borges e Patrick Barboza     }
{       Em fevereiro/2025                                }
{                                                        }
{--------------------------------------------------------}

unit gvhttp;

interface
uses windows, sysutils, shellApi, classes,
     dvcrt, dvWin, dvInet, dvArq, dvForm, dvExec, dvSsl, winsock,
     gvVars, gvMsg;

function GetDefaultBrowser: string;
function UrlEncode2(s: String): String;
function httpTransport (site: string; port: integer;
                        httpMsg: string;
                        var status: integer;
                        var newLocation: string;
                        var cookies: TStringList): string;
function iniciaComunicGoogle: boolean;

implementation

uses gvhtml;

{--------------------------------------------------------}
{                Get standard browser                    }
{--------------------------------------------------------}

function GetDefaultBrowser: string;
var
    tmp : PChar;
    res : PChar;
begin
    tmp := StrAlloc(255);
    res := StrAlloc(255);
    try
        GetTempPath (255,tmp);
        FileCreate (tmp+'htmpl.htm');
        FindExecutable ('htmpl.htm',tmp,Res);
        Result := ExtractFilePath(res) + ExtractFileName(res);
        SysUtils.DeleteFile (tmp+'htmpl.htm');
    finally
        StrDispose(tmp);
        StrDispose(res);
    end;
end;

{--------------------------------------------------------}
{                     URL encoding                       }
{--------------------------------------------------------}

function UrlEncode2(s: String): String;
var i: Integer;
begin
    Result := '';
    for i := 1 to length(s) do
        begin
            if s[i] in ['0'..'9', 'a'..'z', 'A'..'Z', '.', '-', '_', '~'] then
                Result := Result + s[i]
            else
                Result := Result + '%' + IntToHex(Ord(s[i]), 2);
        end;
end;

{--------------------------------------------------------}
{                 HTTP protocol processing               }
{--------------------------------------------------------}

function httpTransport (site: string; port: integer;
                        httpMsg: string;
                        var status: integer;
                        var newLocation: string;
                        var cookies: TStringList): string;
var
    n, falta: integer;
    sockHTTP: integer;
    pbuf: PbufRede;
    s, header: string;
    p: pchar;
    aReceber: integer;
    i: integer;
    c: char;
    sai: string;
label erroHTTP;
begin
    result := '';
    status := -1;
    cookies.Clear;

    sockHTTP := abreConexao (site, port);
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

    if copy (header, 1, 4) <> 'HTTP' then
        goto erroHttp;

    delete (header, 1, pos(' ', header));
    delete (header, pos(' ', header), 999);
    try
        status := strToInt (trim(header));
    except
        status := -1;
    end;

    if status = -1 then goto erroHTTP;

    aReceber := 999999999;
    repeat
        if not readlnBufRede (pbuf, s, 10) then goto erroHttp;

        if debug then
            begin
                textColor (LIGHTMAGENTA);
                writeln (s);
                textColor (WHITE);
            end;

        if upperCase (copy (s, 1, 15)) = 'CONTENT-LENGTH:' then
            aReceber := strToInt (trim(copy (s, 16, 999)))
        else
        if upperCase(copy (s, 1, 9)) = 'LOCATION:' then
            newLocation := trim (copy (s, 10, 999))
        else
        if upperCase(copy (s, 1, 11)) = 'SET-COOKIE:' then
            cookies.add (trim (copy (s, 12, 999)));
    until s = '';

    sai := '';
    if aReceber > 0 then
        for i := 1 to aReceber do
            begin
                if leCaracBufRede (pbuf, c) then
                    sai := sai + c
                else
                    break;
            end;

    result := sai;
    fechaConexao(sockHTTP);
    exit;

erroHttp:
    fechaConexao(sockHTTP);
    mensagem ('GVERHTTP', 1);  {'Erro no protocolo HTTP'}
end;

{--------------------------------------------------------}
{            obtém página básica e cookie                }
{--------------------------------------------------------}

function iniciaComunicGoogle: boolean;
var
    s, httpMsg: string;
    status: integer;
    p, i: integer;
    sl: TStringList;
begin
    mensagem ('GVABRGOO', 2);     {'Abrindo comunicação com o Google'}
    repeat
        httpMsg :=
            'GET ' + urlGoogle + ' HTTP/1.0' + ^m^j +
            'Host: ' + siteGoogle + ^m^j +
            'Accept-Language: pt-br' + ^m^j +
            'UA-CPU: x86' + ^m^j +
            'User-Agent: Lynx 2.0' + ^m^j +
            ^m^j;

        s := httpTransport (siteGoogle, 80, httpMsg, status, newLocation, cookies);
        if (status div 100) = 3 then
             begin
                  delete (newLocation, 1, pos (':', newLocation)+2);
                  p := pos ('/', newLocation);
                  if p <> 0 then
                       begin
                           urlGoogle := copy (newLocation, p, 999);
                           delete (newlocation, p, 999);
                           siteGoogle := newLocation;
                       end;
             end;
    until (status div 100) <> 3;

    sl := TStringList.create;
    sl.assign (HTMLparaStringList(s));
    iflsig := '';
    for i := 0 to sl.Count-1 do
        if (pos ('hidden', sl[i]) <> 0) and (pos ('iflsig', sl[i]) <> 0) then
            begin
                iflsig := sl[i];
                p := pos ('value=', iflsig);
                delete (iflsig, 1, p+6);
                delete (iflsig, pos('"', iflsig), 999);
            end;

    sl.free;

    if status <> 200 then
        begin
            mensagem ('GVPRBGOO', 2);  {'Comunicação com a Google não foi estabelecida'}
            iniciaComunicGoogle := false;
            exit;
        end;

    mensagem ('GVCOMGOO', 2);  {'Comunicação estabelecida com a Google'}

    if debug then
        begin
            textColor (GREEN);
            writeln ('Site:   ', siteGoogle);
            writeln ('URL:    ', urlGoogle);
            for i := 0 to cookies.Count-1 do
                writeln ('Cookie: ', cookies[i]);
            textColor (WHITE);
            writeln;
        end;

    iniciaComunicGoogle := true;
end;

end.
