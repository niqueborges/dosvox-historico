{--------------------------------------------------------}
{
{    Rotinas básicas para seleção de arquivos
{    Autor: José Antonio Borges
{    Em novembro/2001
{
{--------------------------------------------------------}

unit cararq;

interface
uses
  dvwin,
  dvcrt,
  windows,
  sysUtils,
  classes;

type
    TMySearchRec = record
        sr: TSearchRec;
        marcado: boolean;
    end;

    PMySearchRec = ^TMySearchRec;

function obtemNomeArqMascAnexo (dy: integer; masc: string): string;
function selecArqAnexo (xmin, ymin, xmax, ymax: integer;
                   mascSelecao: string;
                   atribArq: word; tipoOrdem: integer): string;
function escolheListArqAnexo (qualOpcao: integer): string;
function escolheFuncaoListArqAnexo (var qualOpcao: integer;
                                    var c1, c2: char): string;

function semAcentos (s: string): string;
function criaListArq (mascSelecao: string; atribArq: word): TList;
procedure liberaListArq;

procedure preparaTelaArq (xmin, ymin, xmax, ymax: integer);
procedure redesenhaListArq (qualOpcao: integer; forcaRedesenho: boolean);
procedure ordenaListArq (tipo: integer);

procedure salvaTelaArq;
procedure recuperaTelaArq;

var
    teclaObtemNomeArq: char;    // só para a função obtemNomeArq
    brAntes: string;

implementation

var
    psr: ^TMySearchRec;
    listArq: TList;
    xMinTela, xmaxTela, yminTela, ymaxTela: integer;
    yminVis, ymaxVis: integer;

    salvaCor: word;
    psaveScreenChar, psaveScreenAttrib: pchar;
    salvax, salvay: integer;

    largLinha: integer;

{-------------------------------------------------------------}
{       Retorna a extensão de um arquivo
{-------------------------------------------------------------}

function retornaExtensao (s: string): string;
var i: integer;
begin
    if pos ('.', s) = 0 then s := ''
    else
        begin
            i := length (s);
            while s[i] <> '.' do i := i - 1;
            delete (s, 1, i);
        end;
        retornaExtensao := s;
end;

{--------------------------------------------------------}

function semAcentos (s: string): string;
const
    tabMaiuscPC: array [#$80..#$ff] of char = (

    'C','U','E','A','A','A','A','C','E','E','E','I','I','I','A','A',
    'E','þ','þ','O','O','O','U','U','Y','O','U','þ','þ','þ','þ','þ',
    'A','I','O','U','N','N','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ',
    'þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ',
    'A','A','A','A','A','A','‘','C','E','E','E','E','I','I','I','I',
    'þ','N','O','O','O','O','O','X','þ','U','U','U','U','Y','þ','þ',
    'A','A','A','A','A','A','‘','C','E','E','E','E','I','I','I','I',
    'þ','N','O','O','O','O','O','X','þ','U','U','U','U','Y','þ','þ');

var
    s2: string;
    i: integer;

begin
    s2 := s;
    for i := 1 to length (s2) do
        if s2[i] in ['a'..'z'] then
            s2[i] := upcase (s2[i])
        else
        if s2[i] >= #$80 then
            s2[i] := tabMaiuscPC [s2[i]];

    semAcentos := s2;
end;

{--------------------------------------------------------}

function criaListArq (mascSelecao: string; atribArq: word): TList;
var sr: TSearchRec;
begin
    listArq := TList.Create;
    criaListArq := listArq;

    if pos ('.', mascSelecao) = 0 then
        mascSelecao := mascSelecao + '*.*'
    else
        mascSelecao := mascSelecao + '*';

    if FindFirst(mascSelecao, atribArq, sr) = 0 then
        repeat
            if (((sr.Attr and atribArq) = atribArq) or
               ((sr.Attr and (FaDirectory+FaVolumeId) = 0) and (atribArq = faAnyFile))) and
               ((sr.Name <> '.') and (sr.Name <> '..')) then
                begin
                    new (psr);
                    psr^.sr := sr;
                    psr^.marcado := false;
                    listArq.Add (psr);
                end;
        until FindNext(sr) <> 0;
    FindClose(sr);
end;

{--------------------------------------------------------}

procedure preparaTelaArq (xmin, ymin, xmax, ymax: integer);
begin
    xMinTela := xmin;
    yMinTela := ymin;
    xmaxTela := xmax;
    ymaxTela := ymax;

    yminVis := 0;
    ymaxVis := yminVis + ymaxTela-yminTela;

    largLinha := xmaxTela-xminTela+1;

    if yminVis = ymaxVis then
        brAntes := ''
    else
        brAntes := ' ';
end;

{--------------------------------------------------------}

procedure desenhaListArq;
var y: integer;
    s: string;
    psr: PMySearchRec;
const
    BRANCOS = '                                        ' +
              '                                        ';
begin
    for y := yminVis to ymaxVis do
        begin
            gotoxy (xminTela, yminTela+y-yminVis);
            textColor (WHITE);
            textBackground (6);

            if y < listArq.count then
                begin
                    psr := listArq.list[y];
                    if (psr^.sr.Attr and FaDirectory) <> 0 then
                         textColor (CYAN);
                    if psr^.marcado then
                        textColor (GREEN);
                    s := psr^.sr.FindData.cFileName + BRANCOS;
                    s := brAntes + copy (s, 1, largLinha-length(brAntes));
                    write (s);
                end;
        end;
end;

{--------------------------------------------------------}

procedure redesenhaListArq (qualOpcao: integer; forcaRedesenho: boolean);
var alterouTela: boolean;
begin
    alterouTela := false;
    while (qualOpcao < yminVis) and (yminVis > 0) do
        begin
            dec (yminVis);
            dec (ymaxVis);
            alterouTela := true;
        end;

    while (qualOpcao > ymaxVis) and (ymaxVis < listArq.count-1) do
        begin
            inc (yminVis);
            inc (ymaxVis);
            alterouTela := true;
        end;
    if alterouTela or forcaRedesenho then
        desenhaListArq;
end;

{--------------------------------------------------------}

procedure ordenaListArq (tipo: integer);

        function comparaNome (Item1, Item2: Pointer): Integer;
        begin
            Result := compareText (
                semAcentos(PMySearchRec(item1)^.sr.FindData.cFileName),
                semAcentos(PMySearchRec(item2)^.sr.FindData.cFileName));
        end;

        function comparaExtensao (Item1, Item2: Pointer): Integer;
        var ext1, ext2: string;
            n: integer;

        begin
            ext1 := PMySearchRec(item1)^.sr.FindData.cFileName;
            ext1 := retornaExtensao (ext1);
            ext2 := PMySearchRec(item2)^.sr.FindData.cFileName;
            ext2 := retornaExtensao (ext2);

            n := compareText (ext1, ext2);
            if n <> 0 then result := n
                      else result := comparaNome (Item1, Item2);
        end;

        function comparaTamanho (Item1, Item2: Pointer): Integer;
        begin
            Result := PMySearchRec(item1)^.sr.Size - PMySearchRec(item2)^.sr.Size;
        end;

        function comparaData (Item1, Item2: Pointer): Integer;
        begin
            Result := PMySearchRec(item1)^.sr.Time - PMySearchRec(item2)^.sr.Time;
        end;

begin
    case tipo of
        1: listArq.sort (@ComparaExtensao);
        2: listArq.sort (@ComparaTamanho);
        3: listArq.sort (@ComparaData);
    else
        listArq.sort (@ComparaNome);
    end;
end;

{--------------------------------------------------------}

procedure salvaTelaArq;
var i, xx, yy: integer;
begin
    salvaCor := textAttr;
    salvax := wherex;
    salvay := wherey;

    getmem (psaveScreenChar,   largLinha * (ymaxTela-yminTela+1));
    getmem (psaveScreenAttrib, largLinha * (ymaxTela-yminTela+1));
    i := 0;
    for yy := yminTela to ymaxTela do
        for xx := xminTela to xmaxTela do
            begin
                 psaveScreenChar[i]   := getScreenChar (xx, yy);
                 psaveScreenAttrib[i] := chr (getScreenAttrib (xx, yy));
                 i := i + 1;
            end;
end;

{--------------------------------------------------------}

procedure recuperaTelaArq;
var i, xx, yy: integer;
    cor, ultCor: word;
    s: string [80];
begin
    ultCor := 255;
    i := 0;
    for yy := yminTela to ymaxTela do
        begin
            gotoxy (xminTela, yy);
            s := '';
            for xx := xminTela to xmaxTela do
                begin
                     cor := word(psaveScreenAttrib[i]);
                     if cor <> ultCor then
                         begin
                             if s <> '' then write (s);
                             s := '';
                             ultCor := cor;
                             textColor (cor and $f);
                             textBackground (cor shr 4);
                         end;
                     s := s + psaveScreenChar[i];
                     i := i + 1;
                end;
            if s <> '' then write (s);
            s := '';
        end;

    freemem (psaveScreenChar,   largLinha * (ymaxTela-yminTela+1));
    freemem (psaveScreenAttrib, largLinha * (ymaxTela-yminTela+1));

    textAttr := salvaCor;
    gotoxy (salvax, salvay);
end;

{--------------------------------------------------------}

function escolheFuncaoListArqAnexo (var qualOpcao: integer;
                                var c1, c2: char): string;
var
    acabou: boolean;
    nome1, nome2: string;
    cc1: char;
    psr2, psrAux: ^TMySearchRec;
    i: integer;
    listaSelecionados: string;
    contMarcados: integer;

            procedure desenhaItem;
            begin
                gotoxy (xminTela, yminTela+qualOpcao-yminVis);
                if psr^.marcado then
                    textColor (GREEN)
                else
                if (psr^.sr.Attr and FaDirectory) <> 0 then
                    textColor (CYAN)
                else
                    textColor (WHITE);
                write (brAntes + copy (psr^.sr.FindData.cFileName, 1, largLinha-length(brAntes)));
            end;


            procedure desceCursor;
            begin
                if (GetKeyState(VK_SHIFT) < 0) and
                   (qualOpcao >= 0) and (qualOpcao < listArq.count) then
                    begin
                       psr := listArq.list[qualOpcao];
                       if not psr^.marcado then sintBip;
                       psr^.marcado := true;
                       desenhaItem;
                    end;
                qualOpcao := qualOpcao + 1;
                if (GetKeyState(VK_SHIFT) < 0) and
                   (qualOpcao >= 0) and (qualOpcao < listArq.count) then
                    begin
                       // sintBip;
                       psr := listArq.list[qualOpcao];
                       psr^.marcado := true;
                       desenhaItem;
                    end;
            end;

            procedure sobeCursor;
            begin
                if (GetKeyState(VK_SHIFT) < 0) and
                   (qualOpcao >= 0) and (qualOpcao < listArq.count) then
                    begin
                       psr := listArq.list[qualOpcao];
                       if psr^.marcado then sintClek;
                       psr^.marcado := false;
                       desenhaItem;
                    end;
                qualOpcao := qualOpcao - 1;
            end;

label jaFala;

begin
    contMarcados := 0;
    if qualOpcao < 0 then qualOpcao := 0;
    if qualOpcao >= listArq.Count then qualOpcao := listArq.Count-1;

    redesenhaListArq (qualOpcao, true);

    cc1 := ' ';
    acabou := false;
    gotoxy (xminTela, yminTela+qualOpcao-yminVis);
    c1 := GOTFOCUS;
    goto jaFala;

    repeat
        while sintFalando and (not keypressed) do
            waitMessage;  // controle das paradas de fala

        c1 := readkey;
        c2 := ' ';
        if c1 = #$0 then c2 := readkey;

jaFala:
        if (qualOpcao >= 0) and (qualOpcao < listArq.count) then
            begin
                psr := listArq.list[qualOpcao];
                desenhaItem;
            end;

        if c1 <> #0 then
            case c1 of
                ' ':   if (qualOpcao >= 0) and (qualOpcao < listArq.count) then
                           psr^.marcado := not psr^.marcado;
                '+':   if (qualOpcao >= 0) and (qualOpcao < listArq.count) then
                           psr^.marcado := true;
                '-':   if (qualOpcao >= 0) and (qualOpcao < listArq.count) then
                           psr^.marcado := false;
                '*':   begin
                           for i := 0 to listArq.count-1 do
                                begin
                                    psr2 := listArq.list[i];
                                    psr2^.marcado := true;
                                end;
                           desenhaListArq;
                       end;
                '/':   begin
                            for i := 0 to listArq.count-1 do
                                begin
                                    psr2 := listArq.list[i];
                                    psr2^.marcado := false;
                                end;
                            desenhaListArq;
                        end;

                NOFOCUS:    while not keypressed do waitMessage;
                GOTFOCUS:   ;
            else
                acabou := true;
            end
        else
            case c2 of
                F5:         begin
                                cc1:= readkey;
                                if cc1 = #0 then readkey;
                                repeat
                                      qualOpcao := qualOpcao + 1;
                                      if qualOpcao < listArq.count then
                                          psr := listArq.list[qualOpcao];
                                until (qualOpcao >= listArq.count) or
                                      (upcase(psr^.sr.FindData.cFileName[0]) = upcase(cc1));
                            end;

                CTLF5:      repeat
                                qualOpcao := qualOpcao + 1;
                                if qualOpcao < listArq.count then
                                    psr := listArq.list[qualOpcao];
                            until (qualOpcao >= listArq.count) or
                                  (upcase(psr^.sr.FindData.cFileName[0]) = upcase(cc1));

                CIMA:       sobeCursor;
                BAIX:       desceCursor;

                DIR, ESQ:   ;

                PGUP:       for i := 1 to 10 do sobeCursor;
                PGDN:       for i := 1 to 10 do desceCursor;

                HOME, CTLPGUP:
                    begin
                        if (GetKeyState(VK_SHIFT) < 0) then
                            begin
                                if qualOpcao > listArq.Count-1 then
                                    qualOpcao := listArq.Count-1;
                                for i := 0 to qualOpcao do
                                     begin
                                         psr2 := listArq.list[i];
                                         psr2^.marcado := false;
                                     end;
                                sintBip;
                                desenhaListArq;
                            end;

                        qualOpcao := 0;
                    end;

                TEND, CTLPGDN:
                    begin
                        if (GetKeyState(VK_SHIFT) < 0) then
                            begin
                                for i := qualOpcao to listArq.count-1 do
                                    if (i >= 0) and (i < listArq.count) then
                                        begin
                                            psr2 := listArq.list[i];
                                            psr2^.marcado := true;
                                        end;
                                sintBip;
                                desenhaListArq;
                            end;

                        qualOpcao := listArq.count-1;
                    end;

            else
                acabou := true;
            end;

        if qualOpcao < 0 then qualOpcao := -1;
        if qualOpcao >= listArq.count then qualOpcao := listArq.count;

        if (qualOpcao < 0) or (qualOpcao = listArq.count) then
            begin
                sintBip;
                redesenhaListArq (qualOpcao, false);
                gotoxy (xmaxTela, ymaxTela);
            end
        else
            begin
                redesenhaListArq (qualOpcao, false);

                if not acabou then
                    begin
                        psr := listArq.list[qualOpcao];
                        nome1 := psr^.sr.FindData.cFileName;
                        nome2 := psr^.sr.FindData.cAlternateFileName;

                        gotoxy (xminTela, yminTela+qualOpcao-yminVis);
                        textColor (YELLOW);
                        write (brAntes + copy (nome1, 1, largLinha-length(brAntes)));
                        gotoxy (xminTela, qualOpcao+yminTela-yminVis);

                        if c2 = DIR then  sintSoletra (nome1)
                        else
                        if c2 = ESQ then  sintSoletra (nome2)
                        else
                                begin
                                    if psr^.marcado then sintbip;
                                    sintetiza (nome1);
                                end;
                    end;
            end;
    until acabou;

    if (qualOpcao < 0) or (qualOpcao = listArq.count) or (c1 = ESC) then
        qualOpcao := -1
    else
        begin
            gotoxy (xminTela, yminTela+qualOpcao-yminVis);
            textColor (YELLOW);
            write (brAntes + copy (nome1, 1, largLinha-length(brAntes)));
            textColor (WHITE);
        end;
    // Varre o diretório de arquivos adicionando à lista de selecionados os
    // arquivos que estão marcados
    for i := 0 to listArq.count - 1 do
        begin
            psrAux := listArq.list[i];
            if psrAux^.marcado then
                begin
                    listaSelecionados := listaSelecionados + psrAux^.sr.Name + '|';
                    contMarcados := contMarcados + 1;
                end;
        end;
    // Se nenhum arquivo do diretório está marcado, então adiciona à lista de
    // selecionados o arquivo que estava selecionado no momento que o usuário
    // apertou a tecla ENTER
    if (contMarcados = 0) then
        listaSelecionados := psr^.sr.Name + '|';
    escolheFuncaoListArqAnexo := listaSelecionados;

end;

{--------------------------------------------------------}

function escolheListArqAnexo (qualOpcao: integer): string;
var c1, c2: char;
    listaSelecionados: string;
begin
    repeat
        listaSelecionados := escolheFuncaoListArqAnexo (qualOpcao, c1, c2);
    until (c1 = ESC) or (c1 = TAB) or (c1 = ENTER);
    if c1 = #0 then
        teclaObtemNomeArq := c2
    else
        teclaObtemNomeArq := c1;

    if c1 = TAB then
        escolheListArqAnexo := '-2'
    else
    if c1 = ESC then
        escolheListArqAnexo := '-1'
    else
        escolheListArqAnexo := listaSelecionados;
end;

{--------------------------------------------------------}

procedure liberaListArq;
var
    i: integer;
begin
    for i := 0 to listArq.count-1 do
        dispose (PMySearchRec(listArq[i]));
    listArq.Free;
end;

{--------------------------------------------------------}

function selecArqAnexo (xmin, ymin, xmax, ymax: integer;
                   mascSelecao: string;
                   atribArq: word; tipoOrdem: integer): string;
var
    listaSelecionados: string;
    dirAtual, dirPedido: string;
begin
    getDir (0, dirAtual);
    dirPedido := mascSelecao;
    while (dirPedido <> '') and (dirPedido [length(dirPedido)] <> '\') and
                                (dirPedido [length(dirPedido)] <> ':') do
        delete (dirPedido, length(dirPedido), 1);

    delete (mascSelecao, 1, length(dirPedido));
    if dirPedido <> '' then
        begin
            chdir (dirPedido);
            if ioresult <> 0 then
                begin
                    selecArqAnexo := '';
                    exit;
                end;
        end;

    getDir (0, dirPedido);

    criaListArq (mascSelecao, atribArq);
    if listArq.count = 0 then
        begin
            liberaListArq;
            selecArqAnexo := '';
            exit;
        end;

    ordenaListArq(tipoOrdem);

    if (xmax = 80) and (ymax = 25) then xmax := 79;
    preparaTelaArq (xmin, ymin, xmax, ymax);

    salvaTelaArq;

    listaSelecionados := escolheListArqAnexo (0);
    if listaSelecionados = '-2' then
        selecArqAnexo := '@TAB@'
    else
    if (AnsiCompareText(listaSelecionados, '-1') <> 0) and
       (AnsiCompareText(listaSelecionados, '-2') <> 0) then
        begin
//            if dirPedido = dirAtual then
//                dirPedido := ''
//            else
//                begin
                    if dirPedido [length(dirPedido)] <> '\' then
                        dirPedido := dirPedido + '\';
                    dirPedido := '|' + dirPedido + '|';
//                end;
            selecArqAnexo := dirPedido + listaSelecionados;
        end
    else
        selecArqAnexo := '';

    liberaListArq;
    recuperaTelaArq;

    chdir (dirAtual);
    if ioresult <> 0 then;
end;

{--------------------------------------------------------}

function obtemNomeArqMascAnexo (dy: integer; masc: string): string;
var c: char;
    nomeArq, diretorio: string;
    p: integer;

label deNovo;
begin
deNovo:
    nomeArq := '';
    obtemNomeArqMascAnexo := '';
    c := sintEdita (nomeArq, wherex, wherey, 255, true);
    teclaObtemNomeArq := c;
    if (c = ESC) or ((c = ENTER) and (nomeArq = '')) then exit;

    nomeArq := trim (nomeArq);
    if (nomeArq <> '') and (DirectoryExists (nomeArq))
         and (nomeArq[length(nomeArq)] <> '\')
         and (nomeArq[length(nomeArq)] <> ':') then
            nomeArq := nomeArq + '\';

    diretorio := '';
    if length (nomeArq) > 0 then
        begin
            p := length (nomeArq);
            while (p > 0) and (nomeArq[p] <> '\') do p := p - 1;
            if p > 0 then
                 diretorio := copy (nomeArq, 1, p);
        end;

    if nomeArq = '' then nomeArq := masc;

    if (c <> ENTER) or (pos ('*', nomeArq) <> 0) then
        nomeArq := selecArqAnexo (wherex, wherey, 80, wherey+dy-1, nomeArq, faArchive, 0);

    if nomeArq = '@TAB@' then
        begin
            sintClek; sintClek;
            goto deNovo;
        end;

    if (pos('\', nomeArq) = 0) and (pos (':', nomeArq) = 0) and (diretorio <> '') then
        nomeArq := diretorio + nomeArq;
    obtemNomeArqMascAnexo := nomeArq;
end;

end.
