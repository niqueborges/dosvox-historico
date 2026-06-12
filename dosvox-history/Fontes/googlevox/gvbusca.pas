{--------------------------------------------------------}
{                                                        }
{    Programa acesso simplificado ao Google              }
{                                                        }
{    Módulo de controle da busca                         }
{                                                        }
{    Autores: Antonio Borges e Fabiano Ferreira          }
{       Em maio/2013                                     }
{                                                        }
{    Atualizado por Antonio Borges e Patrick Barboza     }
{       Em fevereiro/2025                                }
{                                                        }
{--------------------------------------------------------}

unit gvbusca;

interface
uses windows, sysutils, shellApi, classes,
     dvcrt, dvWin, dvInet, dvArq, dvForm, dvExec, dvSsl, winsock,
     gvHttp, gvHtml, gvVars, gvMsg;

procedure buscaNoGoogle (busca: string; pagAtual: integer);

implementation

var
    ind: integer;
    titulo, origem, descricao, url: string;
    sl: TStringList;
    linkInicioTopico: string;

{-----------------------------------------------------------}
{          Adiciona uma pesquisa ao histórico de busca
{-----------------------------------------------------------}

procedure adicionaAosUltimos (chaveBusca: string);
var i, j: integer;
begin
    for i := 1 to 10 do
        begin
            if chaveBusca = ultimasBuscas[i] then
                begin
                    for j := i to 10-1 do
                        ultimasBuscas[j] := ultimasBuscas[j+1];
                    ultimasBuscas[10] := '';
                end;
        end;

    if (chaveBusca <> '') and (chaveBusca <> ultimasBuscas[1]) then
       begin
           for i := 10 downto 2 do
               ultimasBuscas[i] := ultimasBuscas[i-1];
           ultimasBuscas[1] := chaveBusca;
           for i := 1 to 10 do
               sintGravaAmbiente ('GOOGLEVOX', intToStr(i), ultimasBuscas[i]);
       end;
end;

{--------------------------------------------------------}
{    Localiza o início de um resultado da busca
{--------------------------------------------------------}

function buscaInicioItem: boolean;
begin
    repeat
        ind := ind + 1;
        if ind > sl.Count-1 then
            begin
                result := false;
                exit;
            end;
    until pos(linkInicioTopico, sl[ind]) = 1; // que marca o início de um item
    linkInicioTopico := copy (sl[ind], 1, 16);
    result := true;
end;

{--------------------------------------------------------}
{    Pega somente o que seja texto da estrutura html
{--------------------------------------------------------}

function ignoraAteTextoEPega: string;
begin
    repeat
        ind := ind + 1;
    until (ind >= sl.Count) or (pos('<', sl[ind]) = 0);
    if ind < sl.Count then
        result := sl[ind]
    else
        result := '';
end;

{--------------------------------------------------------}
{    Pega todas as informações de um resultado
{--------------------------------------------------------}

procedure pegaInformacoes (var link, titulo, origem, descricao: string);
begin
    link := sl[ind];
    delete (link, 1, pos('http', link)-1);
    delete (link, pos('&amp', link), 999);
    titulo := ignoraAteTextoEPega;
    origem := ignoraAteTextoEPega;
    descricao := ignoraAteTextoEPega;

   repeat
      ind := ind + 1;
   until (ind >= sl.Count) or (pos('</table', sl[ind]) = 1);   //Marca fim da lista de resultados
end;

{--------------------------------------------------------}
{    Retira linhas vazias da lista html
{--------------------------------------------------------}

procedure tiraBrancosListaHtml;
var
    i: integer;
begin
    for i := sl.count-1 downto 0 do
        if trim(sl[i]) = '' then
            sl.Delete(i);
end;

{--------------------------------------------------------}
{    Salta a estrutura inicial da página
{--------------------------------------------------------}

procedure pulaInicioPag;
var
    ind2: integer;
begin
    while (ind < sl.Count) and (pos('</tbody', sl[ind]) <> 1) do
        ind := ind + 1;

    for ind2 := ind+25 to ind+55 do
        begin
            if (ind2 < sl.count) and (pos(' href="#"', sl[ind2]) > 0) then
                begin
                    //Assume que não foi encontrado resultado
                    ind := sl.count-1;
                    break;
                end;
        end;
end;

{--------------------------------------------------------}
{            faz uma pesquisa pelo site                  }
{--------------------------------------------------------}

function trazDoGoogle (busca: string; pagAtual: integer): string;
var
    httpMsg, cook, infosite, s: string;
    i, status: integer;
begin
    infosite := '/search' +
         '?ie=ISO%2D8859%2D1'+
         '&hl=pt-BR'+
         '&source=hp&biw=&bih=' +
         '&q=' + UrlEncode2(busca) +
         '&btnG=Pesquisa+Google' +
         '&iflsig=' + iflsig +
         '&start=' + intToStr(pagAtual*10)+
         '&gbv=1';

    httpMsg :=
            'GET ' + infosite + ' HTTP/1.0' + ^m^j +
            'Host: ' + siteGoogle + ^m^j +
            'Accept-Language: pt-br' + ^m^j +
            'UA-CPU: x86' + ^m^j +
            'User-Agent: Lynx 2.0' + ^m^j;

    for i := 0 to cookies.count-1 do
        begin
            cook := copy (cookies[i], 1, pos(';', cookies[i])-1);
            if pos (copy (cook, 1, pos('=', cook)), infosite) = 1 then
                httpMsg := httpMsg + 'Cookie=' + cook + ^m^j;
        end;

    httpMsg := httpMsg + ^m^j;

    if debug then
        begin
            textColor (YELLOW);
            sintWriteln ('Site:   '+ siteGoogle);
            sintWriteln ('URL:    '+ infosite);
            for i := 0 to cookies.count-1 do
                 writeln ('Cookie: ', cookies[i]);
            textColor (WHITE);
            sintWrite ('Aperte enter');
            readln;
            writeln;
        end;

    s := httpTransport (siteGoogle, 80, httpMsg, status, newLocation, cookies);

    if status <> 200 then
        begin
            mensagem ('GVPRBGOO', 2);  {'Comunicação com a Google não foi estabelecida'}
            s := '';
            exit;
        end;
    result := s;
end;

{--------------------------------------------------------}
{                      faz uma busca                     }
{--------------------------------------------------------}

procedure buscaNoGoogle (busca: string; pagAtual: integer);
var
    s: string;
    numRegLidos: integer;

begin
    numRegLidos := 0;
    ind := 0;

    s := trazDoGoogle (semAcentos(busca), pagAtual);   //Acentuação produz resultados imprecisos

    if s <> '' then
        begin
            sl := TStringList.create;
            sl.assign (HTMLparaStringList(s));

        tiraBrancosListaHtml;
            if debug then
                sl.SaveToFile('\temp\html - ' + UrlEncode2(busca) + '.htm');

            pulaInicioPag;
            linkInicioTopico := '<a';

            while (buscaInicioItem) and (ind <= sl.Count) do   //Garante não sair do limite da stringList
                begin
                    pegaInformacoes (url, titulo, origem, descricao);
                    resultado.add (traduzLetrasHTML(titulo));
                    resultado.add (traduzLetrasHTML(origem)+^m^j+traduzLetrasHTML(descricao));
                    url := hexDecode(url);
                    resultado.add (url);
                    numRegLidos := numRegLidos + 1;
                end;
        end;
if debug then
resultado.saveToFile('\temp\resultado - '+busca+'.txt');

    writeln;
    if numRegLidos <> 0 then
        begin
            adicionaAosUltimos (busca);   //Só adiciona se encontrar pelo menos um resultado
            sintWriteln (intToStr(numRegLidos) + ' registros encontrados'); //Não fala número 0 se não achar nada
        end;
    limpabuftec;
end;
end.
