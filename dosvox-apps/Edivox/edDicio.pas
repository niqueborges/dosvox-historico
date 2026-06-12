{--------------------------------------------------------}
{
{       Interface acessível para o site
{       www.dicio.com.br
{
{       Autor: Neno Henrique da Cunha Albernaz
{       Em 01/08/2020
{
{   Praticamente cópia do original "dicio.dpr" de: José Antonio Borges, criado em 30/07/2020.
{
{--------------------------------------------------------}

Unit edDicio;

interface

uses
    dvcrt, dvwin, dvinet, classes, sysutils, libxmlparser, dvdigitexto,
    edDicion, edVars, edMensag;

procedure trataDicio;

implementation

{--------------------------------------------------------}

function downloadDicio (palavra: string): string;
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
    sock := abreConexaoSsl ('www.dicio.com.br', 443);
    if sock <= 0 then
        begin
            fala ('EDNRECON');  {'Não consegui realizar a conexão.'}
            sintclek;
            result := '';
            exit;
        end;

    writelnRede (sock, 'GET ' + pedidoHttp + ' HTTP/1.0');
    writelnRede (sock, 'Host: ' + 'www.dicio.com.br');
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

procedure consultaDicio (palavra: string);
var
    s: string;
    tagsPagina, saida: TStringList;
begin
    s := downloadDicio (palavra);
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
                    sintclek;
                    saida.Free;
                    exit;
                end;
            // saida.saveToFile ('c:\temp\'+palavra+'.txt');

            if pos (uppercase(palavra), uppercase(saida[0])) = 0 then
                if existeArqSom ('EDERROP') then
                    sintSom ('EDERROP')
                else
                    begin
                        sintBip;
                        sintBip;
                    end;

            dvDigiTexto.digiTexto(saida, false,
                1, 10, 80, 15, black, white, yellow, green,
                'dic-' + palavra + '.txt', true, 0);
            fala ('EDOK'); {'Ok'}
        end;
end;

{--------------------------------------------------------}

procedure trataDicio;
var
    s, palavra: string;
    x: integer;
begin
    if (posy <= 0) then exit;
    s := texto[posy];
    x := posx;
    while (x > 1) and (s[x-1] = ' ') do
        x := x - 1;
    while (x <= length(s)) and (s[x] in LETRAS_DE_PALAVRA) do
        x := x + 1;
    palavra := descobrePalavraAntes (x);
    if palavra = '' then
        sintBip
    else
        consultaDicio (palavra);
end;

{--------------------------------------------------------}

begin
end.
