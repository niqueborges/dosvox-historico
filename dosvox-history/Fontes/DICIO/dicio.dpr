{--------------------------------------------------------}
{   Interface acessível para o site Dicio
{   www.dicio.com.br
{   Autor: José Antonio Borges
{   Em 30/07/2020
{--------------------------------------------------------}

program dicio;
uses
  dvcrt,
  dvwin,
  dvinet,
  classes,
  sysutils,
  libxmlparser,
  dvdigitexto;

{--------------------------------------------------------}
{              programa principal
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
    sintWrite ('Um momento');
    pedidoHttp := '/'+ LowerCase(semAcentos(palavra))+'/';

    abreWinsock;
    sock := abreConexaoSsl ('www.dicio.com.br', 443);
    if sock <= 0 then
        begin
            writeln ('Não consegui realizar a conexão.');
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


var palavra, s: string;
    tagsPagina, saida: TStringList;
begin
    sintInic (0, '');
    textBackground (BLUE);
    sintWriteln ('DÍCIO');
    textBackground (BLACK);

    repeat
        clrscr;
        textBackground (BLUE);
        writeln ('DICIO - versão acessível para deficientes visuais');
        textBackground (BLACK);
        textColor (YELLOW);
        writeln ('Se você não é deficiente visual, use o dicionário em http://www.dicio.com.br');
        textColor (WHITE);

        writeln;
        sintWrite ('Qual a palavra buscada: ');
        sintReadln (palavra);
        if palavra = '' then break;

        s := downloadDicio (palavra);
        if s <> '' then
            begin
                tagsPagina := TStringList.create;
                decodificaDicio(s, tagsPagina);
                // tagsPagina.saveToFile ('c:\temp\'+palavra+'.tags');

                saida := TStringList.create;
                geraSaida (tagsPagina, saida);
                if saida.Count = 0 then
                    saida.Add('Palavra não achada');
                // saida.saveToFile ('c:\temp\'+palavra+'.txt');

                writeln ('-------------------------------------------------------------------------------');
                dvDigiTexto.digiTexto(saida, false,
                    1, wherey, 80, 25-wherey, black, white, yellow, green,
                    'dic-' + palavra + '.txt', true, 0);
            end;
    until palavra = '';

    sintWriteln ('Dicionário fechado');
    sintFim;
end.
