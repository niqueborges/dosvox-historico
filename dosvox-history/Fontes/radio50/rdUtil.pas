{--------------------------------------------------------}
{                                                        }
{    Radio50 - Executor interativo de streams de áudio   }
{                                                        }
{    Rotinas utilitárias
{                                                        }
{    Autor:  Neno Henrique da Cunha Albernaz
{                                                        }
{    Em Novembro/2021                                     }
{                                                        }
{--------------------------------------------------------}

unit rdUtil;

interface
uses
    dvcrt,
    dvwin,
    Windows,
    dvexec,
    dvForm,
    dvAmplia,
    sysUtils,
    rdVars,
    classes,
    rdmsg;

function  pegaCategoria (s: string): string;
function  pegaNomeRadio (s: string): string;
function  pegaSite(s: string): string;
function  comTocadorExterno (site: string): boolean;
function  tirarTocadorExterno (site: string): string;
function  editarRadioFolheamento (n: integer; categoria: string; var nomeRadio, site: string): boolean;
function  folheiaBuscaItem (n: integer): integer;
function  folheiaBuscaItemNovamente (n: integer): integer;
procedure falaQualItemDeQuantos (n: integer; Selecionado: boolean);
procedure selecionarTodosItensFolheamento;
function  veSeApaga (nomeRadio: string): boolean;
function  removerRadio (n: integer; categoria: string; sl: TStringList): integer;
function  escolherNumeroPreferidas (var n: integer): boolean;
procedure adicionarAosPreferidos(nomeRadio, site: string);
function  procurarSeUsaTocadorExterno (n: integer; categoria: string; slBusca: TStringList): integer;
function  folheiaPosicionaInicial (c: char; n: integer): integer;
procedure   verificarSeRadioToca (n: integer; categoria: string; sl: TStringList);
procedure copiaAreaTransfSelec (n: integer; categoria, arqIndice: string; apertouShift: boolean; sl: TStringList);
procedure geraArqivosM3U (n: integer; categoria, arqIndice: string; sl: TStringList);

implementation

{--------------------------------------------------------}
{       Retorna a categoria, do formato"[Categoria]NomeRadio=Site".
    {--------------------------------------------------------}

function pegaCategoria (s: string): string;
begin
    if (pos('[', s) = 0) or (pos(']', s) = 0) then
        result := ''
    else
        begin
            delete(s, 1, pos('[', s));
            result := copy (s, 1, pos(']', s)-1);
        end;
end;

{--------------------------------------------------------}
{       Retorna o nome da rádio, do formato"[Categoria]NomeRadio=Site".
    {--------------------------------------------------------}

function pegaNomeRadio (s: string): string;
begin
    if pos(']', s) <> 0  then delete(s, 1, pos(']', s));
    if pos('=', s) <> 0  then delete(s,  pos('=', s), length(s));
    result := s;
end;

{--------------------------------------------------------}
{       Retorna o site, do formato"[Categoria]NomeRadio=Site" ou "NomeRadio=Site".
    {--------------------------------------------------------}

function pegaSite(s: string): string;
begin
    if pos('=', s) = 0 then
        result := ''
    else
        result := copy (s, pos('=', s)+1, length(s));
end;

{--------------------------------------------------------}
{       Retorna se utiliza tocador externo para o site.
    {--------------------------------------------------------}

function comTocadorExterno (site: string): boolean;
begin
    result := pos (' ', trim(site)) <> 0;
end;

{--------------------------------------------------------}
{       Retira o tocador externo do site, se existir.
    {--------------------------------------------------------}

function tirarTocadorExterno (site: string): string;
begin
    if comTocadorExterno (site) then delete (site, 1, pos(' ', trim(site)));

    result := trim(site);
end;

{--------------------------------------------------------}
{       Edita uma rádio atualizando o folheamento.
    {--------------------------------------------------------}

function  editarRadioFolheamento (n: integer; categoria: string; var nomeRadio, site: string): boolean;
var
    sn, nomeRadioAux, siteAux: string;
    c: char;
    tocadorExterno: boolean;
begin
    result := false;
    clrscr;
    textBackground (BLUE);
    write ('Categoria: ' + categoria);
    textBackground (BLACK);
    writeln;

    if comTocadorExterno (site) then
        begin
            tocadorExterno := true;
            site := tirarTocadorExterno (site);
        end
    else
        tocadorExterno := false;

    mensagem ('RDEDNOMR', 1);  {'Editore o nome da rádio: '}
    sintetiza (nomeRadio);
    nomeRadioAux := nomeRadio;
    c := sintEdita(nomeRadioAux, wherex, wherey, 300, true);
    writeln (nomeRadioAux);
    if c = ESC then
        exit;

    mensagem ('RDEDENDR', 1);  {'Editore o endereço de acesso da rádio: '}
    sintetiza (site);
    siteAux := site;
    c := sintEdita(siteAux, wherex, wherey, 300, true);
    writeln (siteAux);
    if c = ESC then
        exit;

    mensagem ('RDUSAPGX', 0);  {'Usa programa externo para acesso: '}
    if tocadorExterno then
        begin
            c := popupMenuPorLetra ('S');
            if c = ENTER then c := 'S';
        end
    else
        begin
            c := popupMenuPorLetra ('N');
            if c = ENTER then c := 'N';
        end;
    if c = ESC then
        exit;

    while pos('=', nomeRadioAux) <> 0 do nomeRadioAux [pos('=', nomeRadioAux)] := '-';
    while pos('[', nomeRadioAux) <> 0 do nomeRadioAux [pos('[', nomeRadioAux)] := '-';
    while pos(']', nomeRadioAux) <> 0 do nomeRadioAux [pos(']', nomeRadioAux)] := '-';
    if pos('=', siteAux) = 1 then delete (siteAux, 1, 1);
    if c = 'S' then siteAux := 'FFMPEG ' + siteAux; // A palavra FFMPEG foi para manter o padrão atual do radio50.ini, pode ser qualquer uma na frente do site.

    result := true;
    if categoria <> 'PREFERIDAS' then
        sintRemoveAmbienteArq (categoria, nomeRadio, arqIndice);
    nomeRadio := nomeRadioAux;
    site := siteAux;
    if categoria = 'PREFERIDAS' then
        begin
            sn := intToStr(n);
            sintGravaAmbienteArq (categoria, sn, nomeRadio + '=' + site, arqIndice);
            folheiaAltera(n, sn + ' - ' + nomeRadio);
        end
    else
        begin
            sintGravaAmbienteArq (categoria, nomeRadio, site, arqIndice);
            folheiaAltera(n, nomeRadio);
        end;
end;

{--------------------------------------------------------}
{       busca um item no folheamento ativo.
{--------------------------------------------------------}

var
    nomeBusca: string = '';

function folheiaBuscaItemNovamente (n: integer): integer;
var
    i, salvaN: integer;
    item: string;
    selec: boolean;
begin
    result := n;
    salvaN := n;
    inc (n);
    if n >= folheiaNumItens then n := 1;
    for i := N to folheiaNumItens do
        begin
            folheiaObtemItem (i, item, selec);
            if pos (nomeBusca, lowerCase(semAcentos(item))) <> 0 then
                begin
                    result := i;
                    break;
                end;
        end;

    if result = salvaN then sintclek;
end;

function folheiaBuscaItem (n: integer): integer;
begin
    limpaBaixo(25);
    mensagem ('RDQUATXT', 0);  {'Qual o texto? '}
    sintReadln (nomeBusca);
    nomeBusca := lowerCase(semAcentos(nomeBusca));
    if nomeBusca = '' then
        begin
            limpaBaixo(25);
            if sintFalarTudo then mensagem ('RDDESIST', 0)  {'Desistiu'}
            else write(pegaTextoMensagem('RDDESIST')); {'Desistiu'}
        end
    else
        n := folheiaBuscaItemNovamente (n);

    result := n;
end;

{--------------------------------------------------------}
{       Retorna se tem item selecionado no folheamento.
{--------------------------------------------------------}

function temItemSelecionado: boolean;
var
    i: integer;
    item: string;
begin
    for i := 1 to folheiaNumItens do
        begin
            folheiaObtemItem (i, item, result);
            if result then break;
        end;
end;

{-------------------------------------------------------------}
{       Fala qual item ou as selecionadas do  total.
{-------------------------------------------------------------}

procedure falaQualItemDeQuantos (n: integer; Selecionado: boolean);
begin
    if selecionado then n := folheiaNumSelec (n);
    sintetiza (intToStr (n));
    if selecionado then
        if n >1 then mensagem ('RDSELECS', -1) {'selecionado'}
        else mensagem ('RDSELECI', -1); {'selecionados'}
    mensagem ('RDDE', -1); {'de'}
    sintetiza (intToStr(folheiaNumItens));
end;

{--------------------------------------------------------}
{       Seleciona todos os itens do folheamento
{--------------------------------------------------------}

procedure selecionarTodosItensFolheamento;
var
    i: integer;
begin
    for i := 1 to folheiaNumItens do
        folheiaSeleciona (i, true);
end;

{--------------------------------------------------------}
{       Pergunta se apaga a rádio.
{--------------------------------------------------------}

function veSeApaga (nomeRadio: string): boolean;
var c: char;
begin
    mensagem ('RDCNFRMI', 0);    {'Confirma remoção do item '}
    sintWrite (nomeRadio);
    write ('? ');
    c := popupMenuPorLetra('SN');
    writeln;
    result := upcase(c) = 'S';
end;

{--------------------------------------------------------}
{       Remove uma rádio ou as selecionadas
{--------------------------------------------------------}

function removerUmaRadio (n: integer; categoria, nomeRadio: string; sl: TStringList; var fazPergunta: boolean): boolean;
var
c: char;
begin
    if categoria = '' then categoria := pegaCategoria(sl[n-1]);
    if fazPergunta then
        begin
            textBackground (BLUE);
            write (categoria);
            textBackground (BLACK);
            writeln;
            mensagem ('RDCNFRMI', 0);   {'Confirma remoção do item '}
            sintWrite (nomeRadio);
            write ('? ');
            c := popupMenuPorLetra('SNT');
            if c = 'T' then fazPergunta := false;
        end
    else
        begin
            c := 'S';
            textBackground (BLUE);
            write (categoria);
            textBackground (BLACK);
            writeln;
            write (nomeRadio + ' ');
        end;

    if c in ['S', 'T'] then
        begin
            sintGravaAmbienteArq ('RADIOS_REMOVIDAS_EM_' + formatdatetime('DD/MM/YYYY',now), categoria + ' - ' + nomeRadio, sintAmbienteArq (categoria, nomeRadio, '', arqIndice), sintDirAmbiente + '\Radio50.log');
            sintRemoveAmbienteArq (categoria, nomeRadio, arqIndice);
            folheiaRemoveItem (n);
            if sl <> NIL then sl.Delete(n-1);
            if fazPergunta then mensagem ('RDOKRM', 2)        {'Ok, removido'}
            else writeln (pegaTextoMensagem('RDOKRM'));        {'Ok, removido'}
            result := true;
        end
    else
        result := false;
end;

function removerRadio (n: integer; categoria: string; sl: TStringList): integer;
var
    c: char;
    i, totalItens: integer;
    apagarSelecionado, selecionado, fazPergunta: boolean;
    item: string;
begin
    result := n;
    clrscr;
    if temItemSelecionado then
        begin
            repeat
                mensagem ('RDAPASEL', 1);   {'Deseja apagar as selecionadas? '}
                c := popupMenuPorLetra ('SNT');
                writeln;
            until upcase (c) in ['S', 'N', 'T', ESC];
            if c = ESC then exit;
            apagarSelecionado := c = 'S';
            fazPergunta := c <> 'T';
        end
    else
        begin
            apagarSelecionado := false;
            fazPergunta := true;
        end;

    if not apagarSelecionado then
        begin
            if removerUmaRadio (n, categoria, pegaNomeRadio (sl[n-1]), sl, fazPergunta) then
                n := n - 1;
        end
    else
        begin
            totalItens := folheiaNumItens;
            for i := totalItens downto 1 do
                begin
                    folheiaObtemItem (i, item, selecionado);
                    if selecionado then
                        if not removerUmaRadio (i, categoria, pegaNomeRadio (sl[i-1]), sl, fazPergunta) then
                            exit
                        else
                            if i <= n then n := n - 1;

                    if keypressed then
                        begin
                            while keypressed do c := readkey;
                            if c = ESC then
                                begin
                                    mensagem ('RDDESIST', 1); {'Desistiu'}
                                    exit;
                                end;
                            sintetiza (intToStr(((totalItens - i)* 100) div totalItens) + ' %');
                        end;
                end;
        end;

    if n < 0 then n := 0;
    result := n;
end;

{--------------------------------------------------------}
{       Lista a categoria PREFERIDAS, retornando a posição escolhida.
{--------------------------------------------------------}

function escolherNumeroPreferidas (var n: integer): boolean;
var
    i, p: integer;
    s: string;
begin
    popupMenuCria (wherex, wherey, 70, maxPreferidas, MAGENTA);
    for i := 1 to maxPreferidas do
        begin
            s := sintAmbienteArq ('PREFERIDAS', intToStr(i), '', arqIndice);
            p := pos ('=', s);
            if p = 0 then
                s := ''
            else
                s := copy (s, 1, p-1);
            popupMenuAdiciona ('',  intToStr(i) + ' ' + s);
        end;

    n := popupMenuSeleciona;

    if (n < 1) or (n > MAXPREFERIDAS) then
        result := false
    else
        result := true;
end;

{--------------------------------------------------------}
{       Adiciona um item a categoria PREFERIDAS.
{--------------------------------------------------------}

procedure adicionarAosPreferidos(nomeRadio, site: string);
var
    n, erro: integer;
    sn: string;
    c: char;
begin
    mensagem ('RDADIPREF', 1);  {'Adicionar preferida'}
    mensagem ('RDINFNUMENT', 0);  {'Informe o número da rádio entre '}
    sintWrite (' 1 e ' + intToStr(MAXPREFERIDAS)); writeln (': ');
    mensagem ('RDUTSETA', 1);  {'Ou use as setas'}
    c := sintEdita(sn, wherex, wherey, 2, true);
    if c = ESC then exit;
    if c = ENTER then
        begin
            val (sn, n, erro);
            if (erro <> 0) or (n < 1) or (n > MAXPREFERIDAS) then
                begin
                    mensagem ('RDNUMINV', 2);  {'Número inválido'}
                    mensagem ('RDUSSEDNU',  1);  {'Use as setas para descobrir os números.}
                    exit;
                end;

            if trim(sintAmbienteArq ('PREFERIDAS', sn, '', arqIndice)) <> '' then
                begin
                    mensagem ('RDEXRAPO', 0); {'Já existe rádio nessa posição, sobrescreve? '}
                    c := popupMenuPorLetra ('SN');
                    writeln;
                    if c <> 'S' then exit;
                end;
        end
    else
        if not escolherNumeroPreferidas (n) then
            exit
        else
            sn := intToStr(n);

    sintGravaAmbienteArq ('PREFERIDAS', sn, nomeRadio + '=' + site, arqIndice);
    mensagem ('RDOK', 1); {'Ok'}
end;

{--------------------------------------------------------}
{       Retorna o site do arquivo de rádios.
{--------------------------------------------------------}

function pegaSiteNoArq (n: integer; categoria: string; slBusca: TStringList): string;
var
    s: string;
    selec: boolean;
begin
    if categoria = 'PREFERIDAS' then
        begin
            s := sintAmbienteArq ('PREFERIDAS', intToStr(n), '', arqIndice);
            delete (s, 1, pos('=', s));
        end
    else
        begin
            folheiaObtemItem (n, s, selec);
            if categoria = '' then s := sintAmbienteArq (pegaCategoria(slBusca[n-1]), s, '', arqIndice)
            else s := sintAmbienteArq (categoria, s, '', arqIndice);
        end;

    result := trim (s);
end;

{--------------------------------------------------------}
{       Retorna o índice do folheamento do primeiro site com tocador externo, se houver.
{--------------------------------------------------------}

function procurarSeUsaTocadorExterno (n: integer; categoria: string; slBusca: TStringList): integer;
var
    i, salvaN: integer;
begin
    result := n;
    salvaN := n;
    inc (n);
    if n >= folheiaNumItens then n := 1;
    for i := N to folheiaNumItens do
        begin
            if pos (' ', pegaSiteNoArq (i, categoria, slBusca)) <> 0 then
                begin
                    result := i;
                    break;
                end;
        end;

    if result = salvaN then sintclek;
end;

{--------------------------------------------------------}
{       Retorna a posição com o caracter teclado.
{--------------------------------------------------------}

function folheiaPosicionaInicial (c: char; n: integer): integer;
var
    salvaN: integer;
    item: string;
    selec: boolean;
begin
    salvaN := n;
    inc (n);
    if n >= folheiaNumItens then
        begin
            n := 1;
            sintclek;
        end;
    folheiaObtemItem (n, item, selec);

    while (n <> salvaN) and (upcase(c) <> upcase(semAcentos(item)[1])) do
        if n >= folheiaNumItens then
            begin
                n := 1;
                folheiaObtemItem (n, item, selec);
                sintClek;
            end
        else
            begin
                inc (n);
                folheiaObtemItem (n, item, selec);
            end;

    result := n;
end;

{--------------------------------------------------------}
{       Testa se rádio toca com FFPlay
{--------------------------------------------------------}

function linkRadioExiste (url: string): boolean;
begin
    result := true; //Neno colocar teste se link válido.
end;

{--------------------------------------------------------}
{       Remove rádio que não toca.
{--------------------------------------------------------}

procedure removeRadioQueNaoToca (n: integer; categoria, nomeRadio: string; sl: TStringList; mudo: boolean);
begin
    if categoria = '' then categoria := pegaCategoria(sl[n-1]);
    sintGravaAmbienteArq ('RADIOS_REMOVIDAS_NAO_TOCAM_EM_' + formatdatetime('DD/MM/YYYY',now), categoria + ' - ' + nomeRadio,  sintAmbienteArq (categoria, nomeRadio, '', arqIndice), sintDirAmbiente + '\Radio50.log');
    sintRemoveAmbienteArq (categoria, nomeRadio, arqIndice);
    folheiaRemoveItem (n);
    if sl <> NIL then sl.Delete(n-1);
    if not mudo then mensagem ('RDOKRM', -1)        {'Ok, removido'}
    else sintBip;
end;

{--------------------------------------------------------}
{       Verifica se a rádio toca, se não tocar a remove.
{--------------------------------------------------------}

procedure verificarSeRadioToca (n: integer; categoria: string; sl: TStringList);
var
    c: char;
    i, totalItens: integer;
    apagarSelecionado, selecionado: boolean;
    item: string;

begin
    if temItemSelecionado then
        begin
            repeat
                mensagem ('RDDETOSEL', 1);   {'Deseja as selecionadas? '}
                c := popupMenuPorLetra ('SN');
                writeln;
            until upcase (c) in ['S', 'N', ESC];
            if c = ESC then exit;
            apagarSelecionado := c = 'S';
        end
    else
        apagarSelecionado := false;

    if not apagarSelecionado then
        begin
            if linkRadioExiste (pegaSite (sl[n-1])) then
            mensagem ('RDOK', -1) {'Ok'}
            else
                removeRadioQueNaoToca (n, categoria, pegaNomeRadio (sl[n-1]), sl, false);
        end
    else
        begin
            totalItens := folheiaNumItens;
            for i := totalItens downto 1 do
                begin
                    folheiaObtemItem (i, item, selecionado);
                    if selecionado and (not linkRadioExiste (pegaSite (sl[i-1]))) then
                        removeRadioQueNaoToca (i, categoria, pegaNomeRadio (sl[i-1]), sl, true);
                    if keypressed then
                        begin
                            while keypressed do c := readkey;
                            if c = ESC then
                                begin
                                    mensagem ('RDDESIST', 1); {'Desistiu'}
                                    exit;
                                end;
                            sintetiza (intToStr(((totalItens - i)* 100) div totalItens) + ' %');
                        end;
                end;
        end;
end;

{--------------------------------------------------------}
{       Copia o item na posição atual ou os selecionados para a área de transferência.
{--------------------------------------------------------}

procedure copiaAreaTransfSelec (n: integer; categoria, arqIndice: string; apertouShift: boolean; sl: TStringList);
var
    i, totalItens: integer;
    selecionado, semCategoria: boolean;
    item, s: string;
begin
    semCategoria := categoria = '';
    if not temItemSelecionado then
        begin
            item := sl[n-1];
            if apertouShift and semCategoria then
                item := copy(item, pos(']', item)+1, pos('=', item) - pos (']', item) - 1)
            else
            if (not apertouShift) and (not semCategoria) then
                item := '['+categoria+']' + sl[n-1] + '=' + sintAmbienteArq (categoria, sl[n-1], '', arqIndice);
            putClipBoard(pchar(item));
        end
    else
        begin
            s := '';
            totalItens := folheiaNumItens;
            for i := 1 to totalItens do
                begin
                    folheiaObtemItem (i, item, selecionado);
                    if selecionado then
                        begin
                            item := sl[i-1];
                            if apertouShift and semCategoria then
                                item := copy(item, pos(']', item)+1, pos('=', item) - pos (']', item) - 1)
                            else
                            if (not apertouShift) and (not semCategoria) then
                                item := '['+categoria+']' + sl[i-1] + '=' + sintAmbienteArq (categoria, sl[i-1], '', arqIndice);
                            s := s + item + #$0d + #$0a;
                        end;
                end;

            putClipBoard(@s[1]);
        end;

    sintClek; sintclek;
end;

{--------------------------------------------------------}
{       Troca caracteres indesejáveis na string que será o nome do arquivo.
{--------------------------------------------------------}

function acertaNomeArq (s: string): string;
var i: integer;
begin
    result := s;
    i := 1;
    While (s <> '') and (i < length(s)) do
        if s[i] in ['`', '´', '~', '^'] then delete(s, i, 1)
        else if s[i] in ['/', '\', ':', #$0C] then s[i] := '-'
        else inc(i);

    if (trim(s) <> '') and (s[1] <> '.') then
        result := s;
end;

{--------------------------------------------------------}
{       Gera arquivos M3U das rádios selecionadas.
{--------------------------------------------------------}

function gravarUmArqM3u (nomeArq, site, nomeDir: string): boolean;
var
    slM3u: TStringList;
begin
    slM3u := TStringList.Create;
    slM3u.Add (site);
    try
        slM3u.SaveToFile (nomeDir + acertaNomeArq(nomeArq) + '.m3u');
        result := true;
    except
        mensagem ('RDNAOGRAM3U', 0); {'Não consegui gravar o arquivo M3U '}
        sintWriteLn (nomeDir + nomeArq);
        result := false;
    end;
    slM3u.Free;
end;

procedure geraArqivosM3U (n: integer; categoria, arqIndice: string; sl: TStringList);
var
    c: char;
    i, totalItens: integer;
    selecionado, semCategoria: boolean;
    item, nomeDirDestino: string;
begin
    repeat
        mensagem ('RDDESGEM3U', 1);   {'Deseja gerar arquivos M3U dos itens selecionados?'}
        c := popupMenuPorLetra ('SN' + ESC);
        writeln;
    until upcase (c) in ['S', 'N', ENTER, ESC];
    if upcase(c) in ['N', ESC] then exit;

    nomeDirDestino := sintAmbiente('RADIO50', 'DIRARQUIVOSM3U', copy(sintAmbiente('DOSVOX', 'PGMDOSVOX', 'C:\Winvox'), 1, 3) + 'Radios_M3U');
    if not DirectoryExists (nomeDirDestino)  then
        begin
            {$I-}  mkdir (nomeDirDestino);  {$I+}
            if ioresult <> 0 then
                begin
                    mensagem ('RDDIRNCRI', 1); {'Não consegui criar o diretório destino da gravação.'}
                    exit;
                end;
        end;

    mensagem ('RDGERARQM3U', 0);   {'Gerando arquivos M3U em '}
    sintWriteLn (nomeDirDestino);
    if nomeDirDestino [length(nomeDirDestino)] <> '\' then nomeDirDestino := nomeDirDestino + '\';

    semCategoria := categoria = '';
    if not temItemSelecionado then
        begin
            item := sl[n-1];
            if semCategoria then
                begin
                    categoria := pegaCategoria(sl[n-1]);
                    item := copy(item, pos(']', item)+1, pos('=', item) - pos (']', item) - 1)
                end;
            gravarUmArqM3u (item, tirarTocadorExterno (sintAmbienteArq (categoria, item, '', arqIndice)), nomeDirDestino);
        end
    else
        begin
            totalItens := folheiaNumItens;
            for i := 1 to totalItens do
                begin
                    folheiaObtemItem (i, item, selecionado);
                    if selecionado then
                        begin
                            item := sl[i-1];
                            if semCategoria then
                                begin
                                    categoria := pegaCategoria(sl[i-1]);
                                    item := copy(item, pos(']', item)+1, pos('=', item) - pos (']', item) - 1)
                                end;
                            if not gravarUmArqM3u (item, tirarTocadorExterno (sintAmbienteArq (categoria, item, '', arqIndice)), nomeDirDestino) then break;
                        end;
                end;
        end;

    mensagem ('RDOK', -1);
end;

{--------------------------------------------------------}

begin
end.
