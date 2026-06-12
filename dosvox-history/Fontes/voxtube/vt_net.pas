{
    VoxTube - utilitário de acessibilização do YouTube  ;

Rotinas de acesso a rede;

    Autores:
        Antonio Borges,
        Fabiano Ferreira,
        Glauco Constantino,
        Neno Albernaz,
        Patrick Barbosa;

    Versão 1.0 em Fevereiro de 2013;

    Versão 6.0 em Março de 2024;
}

unit vt_net;

interface

function stringToURL(s: string): string;
function URLToString(s: string): string;

function pedeAoYoutube (pedidoHTTP: string): string;

implementation
uses
 dvcrt,
 dvwin,
 dvinet,
vt_msg,
 sysutils;


function stringToURL(s: string): string;
var i: integer;
begin
    result := '';
    for i := 1 to length(s) do
        begin
            if s[i] in ['0'..'9', 'a'..'z', 'A'..'Z', '.', '-', '_', '~'] then
                result := result + s[i]
            else
                result := result + '%' + intToHex(ord(s[i]), 2);
        end;
end;

{--------------------------------------------------------}
{   transforma string para a codificação usada em URLs
{--------------------------------------------------------}

function URLToString(s: string): string;

    function hex(c: char): integer;
    begin
        if c in ['0'..'9'] then result := ord(c) - ord('0')
        else
        if c in ['a'..'f'] then result := ord(c) - ord('a') + 10
        else
        if c in ['A'..'F'] then result := ord(c) - ord('A') + 10
        else
            result := 0;
    end;

var i, n: integer;

begin
    result := '';
    i := 1;
    while i <= length(s) do
        begin
            if (s[i] = '%') and (i <= length(s)-2) then
                begin
                    n := (hex(s[i+1]) shl 4) + hex(s[i+1]);
                    result := result + chr(n);
                    i := i + 3;
                end
            else
                begin
                    result := result + s[i];
                    i := i + 1;
                end;
        end;
end;

{--------------------------------------------------------}
{              manda um pedido ao Youtube
{--------------------------------------------------------}

function pedeAoYoutube (pedidoHTTP: string): string;
var
    pbuf: PbufRede;
    s, x: string;
    ok: boolean;
    sock: integer;
begin
    abreWinsock;
    sock := abreConexaossl ('portalwinvox.com.br', 443);
    if sock <= 0 then
        begin
            mensagem('VTNAOCON', 1); {'Não consegui realizar a conexão.'}
            result := '';
            exit;
        end;
    writelnRede (sock, 'GET ' + pedidoHttp + ' HTTP/1.0');
    writelnRede (sock, 'Host: ' + 'portalwinvox.com.br');
    writelnRede (sock, 'User-Agent: Voxtube 3.0');
writelnrede(sock, 'Accept: */*');
writelnrede(sock, 'Accept-Encoding: identity');
writelnrede(sock, 'Connection: Close');
    writelnRede (sock, '');

    pbuf := inicBufRede (sock);
    repeat
readlnBufRede(pbuf, s, 0);
    until s = '';

s := '<n>';

repeat
ok := readlnBufRede(pbuf, x, 0);
s := s + x + '<n>';
until not ok;
    fimBufRede (pbuf);
    fechaConexao (sock);
    result := s;
    fechaWinsock;
end;

end.
