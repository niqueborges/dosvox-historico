{--------------------------------------------------------}
{
{       Interface acessível para o site dicio e seus parceiros:
{       www.dicio.com.br
{       www.sinonimos.com.br
{       www.antonimos.com.br
{       www.conjugacao.com.br
{
{       Autor: Neno Henrique da Cunha Albernaz
{       Em 01/08/2020
{
{   Boa parte do original "dicio.dpr" de: José Antonio Borges, criado em 30/07/2020.
{
{--------------------------------------------------------}

Unit edDicSite;

interface

uses
    dvcrt, dvwin, dvinet, classes, sysutils, libxmlparser, dvdigitexto,
    edDicion, edVars, edMensag, edTela;

procedure trataDicioSites;

implementation

{--------------------------------------------------------}

function downloadSite (palavra, enderSite: string): string;
var
    pbuf: PbufRede;
    s: string;
    c: char;
    ok: boolean;
    sock: integer;
    pedidoHttp: string;

begin
    fala ('EDAGUARD'); {'Aguarde ...'}

    pedidoHttp := '/'+ LowerCase(semAcentos(palavra))+'/';

    abreWinsock;
    sock := abreConexaoSsl (enderSite, 443);
    if sock <= 0 then
        begin
            fala ('EDNRECON');  {'Não consegui realizar a conexão.'}
            result := '';
            exit;
        end;

    writelnRede (sock, 'GET ' + pedidoHttp + ' HTTP/1.0');
    writelnRede (sock, 'Host: ' + enderSite);
    writelnRede (sock, 'User-Agent: DicioVox 1.0');
    writelnRede (sock, 'Accept-Language: pt-br');
    writelnRede (sock, 'UA-CPU: x86');
    writelnRede (sock, '');

    pbuf := inicBufRede (sock);
    repeat
        ok := readlnBufRede(pbuf, s, 500);
    until (not ok) or (s = '');

    s := '';
    repeat
        while not temDadoBufRede(pbuf) do delay (100);
        ok := leCaracBufRede(pbuf, c);
        if ok then s := s + c;
    until not ok;

    fimBufRede (pbuf);
    fechaConexao (sock);
    result := s;
    fechaWinsock;

    gotoxy (1, wherey); clreol;
end;

{--------------------------------------------------------}

procedure geraSaida (tagsPagina, saida: TStringList);
var
    acumulado: string;

    function busca (i: integer; tag: string): integer;
    var j: integer;
    begin
        for j := i to tagsPagina.Count-1 do
            if pos (tag, tagsPagina[j]) = 1 then break;
        result := j;
    end;

    function pegaTag (i: integer): string;
    begin
        result := copy (tagsPagina[i], pos('=', tagsPagina[i])+1, 999);
        delete (result, length(result), 1);
    end;

    procedure descarrega;
    begin
        saida.add (trim (acumulado));
        acumulado := '';
    end;

    procedure reduzBrancos;
    var i: integer;
    begin
        while (saida.Count > 0) and (saida[0] = '') do
            saida.Delete(0);
        for i := saida.Count-2 downto 1 do
            if (saida[i] = '') and (saida[i-1] = '') then
                saida.delete (i);
    end;

var i: integer;

begin
    i := 0;
    acumulado := '';
    i := busca (i, 'TAG=h2|');
    if i < 0 then exit;

    while (i < tagsPagina.count) and
          (pos ('TAG=div|class=sg-feedback', tagsPagina[i]) <> 1) do
        begin
             if pos ('TAG=h2|', tagsPagina[i]) = 1 then
                 begin
                     descarrega;
                     descarrega;
                     acumulado := acumulado + '**';
                 end
             else
             if pos ('TAG=h3|', tagsPagina[i]) = 1 then
                 begin
                     descarrega;
                     acumulado := acumulado + '*';
                 end
             else
             if pos('TAG=span|class=', tagsPagina[i]) = 1 then
                 begin
                     descarrega;
                     acumulado := acumulado + '+';
                 end
             else
             if (tagsPagina[i] = 'TAG=br|') or
                (tagsPagina[i] = 'TAG=li|') or
                (tagsPagina[i] = 'TAG=span|') or
                (pos ('TAG=div', tagsPagina[i]) = 1) or
                (pos ('TAG=p', tagsPagina[i]) = 1) then
                    descarrega
             else
             if (pos ('TAG=a|', tagsPagina[i]) = 1) or
                (tagsPagina[i] = 'TAG=strong|') or
                (tagsPagina[i] = 'TAG=i|') or
                (tagsPagina[i] = 'TAG=b|') then
                 acumulado := acumulado + ' '
             else
             if pos('T=', tagsPagina[i]) = 1 then
                 acumulado := acumulado + pegaTag(i);

            i := i + 1;
        end;
    descarrega;

    reduzBrancos;
end;

{--------------------------------------------------------}

procedure decodificaDicio (s: string; tagsPagina: TStringList);
var
    parser: TXmlParser;
    tagCompilada: string;
    i: integer;
begin
    parser := tXmlParser.create;
    tagsPagina.Clear;

    parser.normalize := true;   // compacta espaços em branco
    parser.loadFromBuffer(@s[1]);

    while parser.scan do
        begin
            case parser.curpartType of
                ptcomment, ptendtag, ptpi: ;

                ptstarttag, ptemptytag:
                    begin
                        tagCompilada := 'TAG='+parser.CurName+'|';
                        for i := 0 to Parser.CurAttr.Count-1 do
                            begin
                                tagCompilada := tagCompilada + Parser.CurAttr.Name (i) + '=' +
                                                      Parser.CurAttr.Value (i)+'|';
                            end;
                        tagsPagina.add(tagCompilada);
                    end;

                ptcontent:
                    begin
                        tagCompilada := 'T='+parser.curcontent+'|';
                        tagsPagina.add(tagCompilada);
                    end;
            end;
        end;
    parser.Free;
end;

{--------------------------------------------------------}

procedure consultaDicio (palavra, enderSite: string);
var
    s: string;
    tagsPagina, saida: TStringList;
begin
    if palavra = '' then exit;
    s := downloadSite (palavra, enderSite);
    if s <> '' then
        begin
            tagsPagina := TStringList.create;
            decodificaDicio(s, tagsPagina);
            // tagsPagina.saveToFile ('c:\temp\'+palavra+'.tags');

            saida := TStringList.create;
            geraSaida (tagsPagina, saida);
            if saida.Count = 0 then
                begin
                    fala ('EDPANEN');  {'Palavra não encontrada'}
                    saida.Free;
                    exit;
                end;
            // saida.saveToFile ('c:\temp\'+palavra+'.txt');

            dvDigiTexto.digiTexto(saida, false,
                1, wherey, 80, 25-wherey, black, white, yellow, green,
                'dic-' + palavra + '.txt', true, 0);

            fala ('EDOK'); {'Ok'}
        end
    else
        fala ('EDREVAZ'); {'Site retornou vazio'}

end;

{--------------------------------------------------------}

function temConexao: boolean;
var
    sock: integer;
begin
    abreWinSock;
    sock := abreConexaoSsl ('www.dicio.com.br', 443);
    result := sock > 0;
    fechaConexao (sock);
    fechaWinSock;
end;

{--------------------------------------------------------}

procedure trataDicioSites;
const
    SITE_D = 'www.dicio.com.br';
    SITE_S = 'www.sinonimos.com.br';
    SITE_A = 'www.antonimos.com.br';
    SITE_C = 'www.conjugacao.com.br';

var
    c: char;
    s, palavra: string;
    x: integer;

label deNovo;
begin
    if not temConexao then
        begin
            fala ('EDNRECON'); {'Não consegui realizar a conexão'}
            exit;
        end;

     if (posy <= 0) then exit;
     s := texto[posy];
    x := posx;
    while (x > 1) and (s[x-1] = ' ') do
        x := x - 1;
    while (x <= length(s)) and (s[x] in LETRAS_DE_PALAVRA) do
        x := x + 1;
     palavra := descobrePalavraAntes (x);
    if palavra = '' then
        begin
            sintBip;
            exit;
        end;

    fala ('EDDICONL');   {'Qual dicionario on line?'}
    c := leTeclaMaiusc;
deNovo:
    escreveTela;

    case c of
        'D': consultaDicio (palavra, SITE_D);
        'S': consultaDicio (palavra, SITE_S);
        'A': consultaDicio (palavra, SITE_A);
        'C': consultaDicio (palavra, SITE_C);

        #$0: begin
                c := ajuda (readkey, 'EDAJDOL', 5);
                goto deNovo;
            end;

        #$1b: begin
                fala ('EDDESIST');
                exit;
            end
    else
        sintBip;
    end;

    escreveTela;
end;

{--------------------------------------------------------}

begin
end.
