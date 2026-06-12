{-------------------------------------------------------------}
{
{    Webvox - Módulo de interpretação da URL
{
{    Autores: Jose' Antonio Borges e Bernard Condorcet Porto
{
{    Em 18/10/99
{
{-------------------------------------------------------------}

unit weburl;
interface
uses dvcrt, dvWin, sysUtils;

function maiusc (s: string): string;
procedure completaEsquema (var nomePag: string);
procedure compilaURL (nomePag: string;
    var scheme, net_loc, path, params, query, fragment: string);
procedure montaURLrelativa (nomeRelativo, nomeBase: string;
                            var nomeAbsoluto: string);
procedure extraiNomePorta (scheme, net_loc: string; var nomeComp: string;
                            var porta: word);
function UrlEncode2(s: String): String;

implementation

{-------------------------------------------------------------}
{            transforma uma cadeia em maiúsculas
{-------------------------------------------------------------}

function maiusc (s: string): string;
var s2: string;
    i: integer;
begin
    s2 := s;
    for i := 1 to length (s) do
        s2 [i] := upcase (s[i]);
    maiusc := s2;
end;

{-------------------------------------------------------------}
{         completa esquema da pagina quando vem de teclado
{-------------------------------------------------------------}

procedure completaEsquema (var nomePag: string);
var i: integer;
begin
    while (nomePag <> '') and (nomePag [1] = ' ') do
        delete (nomePag, 1, 1);
    while (nomePag <> '') and (nomePag [length(nomePag)] = ' ') do
        delete (nomePag, length(nomePag), 1);

    for i := 1 to length (nomePag) do
        if nomePag[i] = '\' then nomePag[i] := '/';

    if (length (nomePag) > 2) and (upcase(nomePag[1]) in ['A'..'Z']) and
                            (nomePag[2] = ':') then
       begin
           // nomePag [2] := '|';
           nomePag := 'file://'+ nomePag;
       end
    else
       begin
           if pos (':', nomePag) = 0 then
               nomePag := 'http://'+ nomePag
       end;
end;


{-------------------------------------------------------------}
{              traduz nome e porta de acesso
{-------------------------------------------------------------}

procedure extraiNomePorta (scheme, net_loc: string; var nomeComp: string;
                           var porta: word);
var p, erro: integer;
begin
    if scheme <> 'HTTPS' then
        porta := 80
    else
        porta := 443;
    nomeComp := net_loc;

    p := pos (':', net_loc);
    if p <> 0 then
        begin
           val (copy (net_loc, p+1, length (net_loc)-p), porta, erro);
           if erro <> 0 then
               if scheme <> 'HTTPS' then
                   porta := 80
               else
                   porta := 443;

           nomeComp := copy (net_loc, 1, p-1);
        end;
end;

{-------------------------------------------------------------}
{             extrai o nome da sintaxe HTTP
{              algoritmo baseado na RFC1808
{-------------------------------------------------------------}

procedure compilaURL (nomePag: string;
    var scheme, net_loc, path, params, query, fragment: string);
var i, p: integer;
label fim;
begin
    scheme := '';
    net_loc := '';
    path := '';
    params := '';
    query := '';
    fragment := '';

    p := pos ('#', nomePag);
    if p <> 0 then
        begin
            fragment := copy (nomePag, p+1, length (nomePag)-p);
            delete (nomePag, p, length (nomePag)-p+1);
        end;

    p := pos ('://', nomePag);
    if (p <> 0) and (p < 10) then
         begin
             scheme := copy (nomePag, 1, p-1);
             for i := 1 to length (scheme) do
                 scheme [i] := upcase(scheme [i]);
             delete (nomePag, 1, p);
         end
    else
         begin
              if maiusc (copy (nomePag, 1, 7)) = 'MAILTO:' then
                   begin
                       scheme := 'MAILTO';
                       delete (nomePag, 1, 7);
                   end;
         end;

    if scheme = 'FILE' then
        begin
            if copy (nomePag, 1, 2) = '//' then
                delete (nomePag, 1, 2);
        end
    else
    if copy (nomePag, 1, 2) = '//' then
        begin
            delete (nomePag, 1, 2);
            p := pos ('/', nomePag);
            if p = 0  then p := pos ('?', nomePag);
            if p = 0  then p := pos (';', nomePag);
            if p = 0  then
                begin
                    net_loc := nomePag;
                    nomePag := '';
                end
            else
                begin
                    net_loc := copy (nomePag, 1, p-1);
                    delete (nomePag, 1, p-1);
                end;
        end;

    p := pos ('?', nomePag);
    if p <> 0 then
        begin
            query := copy (nomePag, p+1, length (nomePag)-p);
            delete (nomePag, p, length (nomePag)-p+1);
        end;

    p := pos (';', nomePag);
    if p <> 0 then
        begin
            params := copy (nomePag, p+1, length (nomePag)-p);
            delete (nomePag, p, length (nomePag)-p+1);
        end;

    path := nomePag;

    if (net_loc <> '') and (path = '') then
        path := '/';
end;

{-------------------------------------------------------------}
{           transforma url relativa em absoluta
{              algoritmo baseado na RFC1808
{-------------------------------------------------------------}

procedure montaURLrelativa (nomeRelativo, nomeBase: string;
                            var nomeAbsoluto: string);
var
    scheme, net_loc, path, params, query, fragment: string;
    bscheme, bnet_loc, bpath, bparams, bquery, bfragment: string;
    i, p: integer;
label 7, tiraUmaBarra, achouUltimaBarra;

begin
    compilaURL (nomeRelativo, scheme, net_loc, path, params, query, fragment);

    if (scheme = '') and (net_loc = '') and (path = '') and
       (params = '') and (query = '') and (fragment = '') then
           begin
               nomeAbsoluto := nomeBase;
               exit;
           end;

   if scheme <> '' then
         begin
              nomeAbsoluto := nomeRelativo;
              exit;
         end;

    compilaURL (nomeBase, bscheme, bnet_loc, bpath, bparams, bquery, bfragment);
    scheme := bscheme;

    if net_loc <> '' then goto 7;
    net_loc := bnet_loc;

    if (path <> '') and (path[1] = '/') then goto 7;
    if path = '' then
        begin
            path := bpath;
            if params <> '' then goto 7;
            params := bparams;

            if query <> '' then goto 7;
            query := bquery;
            goto 7;
        end
    else
        begin
    tiraUmaBarra:
            for i := length (bpath) downto 1 do
                if bpath[i] = '/' then goto achouUltimaBarra;
            i := 0;
    achouUltimaBarra:
            delete (bpath, i+1, length (bpath)-i);

            if copy (path, 1, 3) = '../' then
                begin
                    delete (path, 1, 3);
                    if (bpath <> '') and (bpath [length(bpath)] = '/') then        {tem alguma barra antes}
                       if (pos ('/', bpath) <> length (bpath))then
                            delete (bpath, length (bpath), 1);
                    goto tiraUmaBarra;
                end;

            bpath := bpath + path;
            while (length (bpath) >= 2) and (bpath [1] = '.') and (bpath [2] = '/') do
                delete (bpath, 1, 2);
            repeat
                p := pos ('./', bpath);
                if p <> 0 then delete (bpath, p, 2);
            until p = 0;

            while copy (bpath, length(bpath)-1, 2) = '/.' do
                delete (bpath, length (bpath)-1, 2);
            if bpath = '.' then bpath := '';

            { itens c e d da RFC não foram implementados }

            path := bpath;
        end;
7:
    nomeAbsoluto := scheme + '://'+
                 net_loc + path;
    if params <> '' then
         nomeAbsoluto := nomeAbsoluto + ';' + params;
    if query <> '' then
         nomeAbsoluto := nomeAbsoluto + '?' + query;
    if fragment <> '' then
         nomeAbsoluto := nomeAbsoluto + '#' + fragment;
end;

{-------------------------------------------------------------}
{            troca especiais da URL por hexa
{-------------------------------------------------------------}

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

end.
