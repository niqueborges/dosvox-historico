{--------------------------------------------------------}
{
{     Rotinas de pesquisas de arquivos do Dosvox
{
{     Autores:  José Antonio Borges
{               Júlio Tadeu Carvalho da Silveira
{
{     Versão 1.0:   Em Janeiro/98
{     Versão 5.0:   Em julho/2015
{
{--------------------------------------------------------}

unit dosBuscaArq;

interface

uses
    windows,
    sysUtils,
    dvcrt,
    dvwin,
    dvForm,
    dvHora,
    dosVars,
    dosgeral,
    dosmsg;

procedure buscaArquivosPorNome;

implementation

uses
    Math,
    Classes,
    dosArq,
    dosCopia,
    dosProc,
    dvExec;

const
    numLinhasInferiores = 5;
    str80Tracos: string = '----------------------------------------'
                        + '----------------------------------------';

var
    procSubDir:   boolean;
    Mudo: boolean;

    listArqBusca: TStringList;
    itemAtualBusca,
    primeiroItemBusca,
    numSelecBusca: integer;

    yInicioTela,
    yFolheiaTit: integer;
    yFolheiaIni: integer;
    yFolheiaFim: integer;

    nomeBusc: string;

{--------------------------------------------------------}
function minLetras (n: integer; s: string): string;
begin
    while length(s) < n do
        s := s + ' ';
    result := s;
end;

{--------------------------------------------------------}
{   seleciona a opção dos arquivos com as setas
{--------------------------------------------------------}

function selSetasArquivos: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;
var
    n: integer;
const
    tabLetrasArquivos: string = 'ELXDTRCBN';

begin
    salvaXY;
    writeln;

    // ATENÇÃO: obter tamanho da maior mensagem para menu mais à direita
    n := length (pegaTextoMensagem('DV_AJUDA_T')) +1;

    popupMenuCria (ScreenSize.X - n, yFolheiaIni, n, length(tabLetrasArquivos), MAGENTA);

        MenuAdiciona ('DV_AJUDA_E');      {'  E - editar arquivo selecionado' }
        MenuAdiciona ('DV_AJUDA_L');      {'  L - ler arquivo selecionado' }
        MenuAdiciona ('DV_AJUDA_X');      {'  X - executar arquivo selecionado'}
        MenuAdiciona ('DV_AJUDA_D');      {'  D - dados do arquivo selecionado' }
        MenuAdiciona ('DV_AJUDA_T');      {'  T - ir para a pasta do arquivo selecionado' }
        MenuAdiciona ('DV_AJUDA_R');      {'  R - remover arquivos selecionados' }
        MenuAdiciona ('DV_AJUDA_C');      {'  C - copiar arquivos selecinados' }
        MenuAdiciona ('DV_AJUDA_B');      {'  B - repetir busca' }
        MenuAdiciona ('DV_AJUDA_N');      {'  N - nova busca' }

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasArquivos := tabLetrasArquivos[n]
    else
        selSetasArquivos := ESC;
    restauraXY;
end;

{--------------------------------------------------------}
{            copia arquivos para outro diretório
{--------------------------------------------------------}

procedure copiaArquivos (posListArq: integer; diret: string);
var
    i: integer;
    copiaSelecionados, selecionado: boolean;
    c: char;
    s: string;

begin
    copiaSelecionados := false;
    if numSelecBusca > 0 then
        begin
            if wherex <> 0 then writeln;
            mensagem ('DV_TODSEL', 0);       {'Copia todos os selecionados? '}
            c := popupMenuPorLetra('SN');
            if c = ESC then
                begin
                    mensagem ('DV_OPCANCEL', 2);    { 'Certo, operação foi cancelada' }
                    exit;
                end;
            copiaSelecionados := upcase(c) = 'S';
        end;

    podeSobrescrever := false;
    naoParaTodos := false;
    copiaMuda := false;
    if not copiaSelecionados then
        copiaUmArquivo (listArqBusca[posListArq], diret, false)
    else
        begin
            for i := 0 to listArqBusca.count-1 do
                begin
                    folheiaObtemItem (i+1, s, selecionado);
                     if selecionado then
                        if not copiaUmArquivo (listArqBusca[i], diret, false) then
                            break;
                end;
        end;

    if wherex <> 1 then writeln;
end;

{--------------------------------------------------------}
{       Gravar nome de arquivos na área de transferência.
{--------------------------------------------------------}

procedure copiaTransfSelec (comDir: boolean);
var i: integer;
    s, s2: string;
    selecionado: boolean;
begin
    s := '';
    if folheiaNumSelec (primeiroItemBusca) = 0 then
        begin
            if comDir then
                s := s + listArqBusca[itemAtualBusca-1] + #$0d + #$0a
            else
                s := s + ExtractFileName(listArqBusca[itemAtualBusca-1]) + #$0d + #$0a;
        end
    else
    for i := 0 to listArqBusca.count-1 do
        begin
            folheiaObtemItem (i+1, s2, selecionado);
            if selecionado then
                if comDir then
                    s := s + listArqBusca[i] + #$0d + #$0a
                else
                    s := s + ExtractFileName(listArqBusca[i]) + #$0d + #$0a;
        end;

    putClipBoard(@s[1]);
    sintclek;
end;

{--------------------------------------------------------}
{       Fala o tamanho dos arquivos selecionados
{--------------------------------------------------------}

procedure tamanhoArqsSelecionados;
var i, cont: integer;
    tam: int64;
    s: string;
    selecionado: boolean;
    srec: TSearchRec;
begin
    tam := 0;
    cont := 0;
    for i := listArqBusca.count-1 downto 0 do
        begin
            folheiaObtemItem (i+1, s, selecionado);
            if not selecionado then continue;
            if FindFirst(listArqBusca[i], faAnyFile, srec) <> 0 then
                begin
                    mensagem ('DV_DINDISP', 0);     {'Dado não disponível'}
                    sintetiza (listArqBusca[i]);
                    exit;
                end;
            tam := tam + srec.Size;

            if cont > 200 then
                begin
                    sintClek;
                    cont := 0;
                end
            else
                inc(cont);
        end;

    falaTamanhoArq (tam, sintFalarTudo);
end;

{--------------------------------------------------------}
{       procura próximo item do folheamento
{--------------------------------------------------------}

function procuraProximoItem(numFolhe: integer): integer;
var
    i: integer;
    buscado: string;
begin
    buscado := semAcentos (nomeBusc);
    If (buscado <> '') and (buscado [1] = '*') then
        delete (buscado, 1, 1);

     for i := (numFolhe + 1) to (listArqBusca.Count -1) do
        begin
            if pos (buscado, semAcentos (ExtractFileName(listArqBusca[i-1]))) <> 0 then
                begin
                    procuraProximoItem := i;
                    exit;
                end;
        end;

    sintbip;
    procuraProximoItem := numFolhe;
end;

{--------------------------------------------------------}

function procuraItem (numFolhe: integer): integer;
begin
    procuraItem := numFolhe;
    gotoxy (1, 24); clreol;
    textbackground (red);
    mensagem ('DV_DIGPABUS', 1); {'Digite a palavra a buscar'}
    textbackground (black);
    sintReadln (nomeBusc);
    if nomeBusc = '' then exit;
    procuraItem := procuraProximoItem (numFolhe);
end;

{--------------------------------------------------------}
{       buscar arquivos em diretórios (e subdiretórios)
{--------------------------------------------------------}

procedure buscaArquivosRecurs (nomeDir, nomeArq: string; cont: integer);
var
    searchRec: TSearchRec;

    procedure contadorBipa;
    begin
        if cont > 500then
            begin
                if not mudo then sintClek;
                while sintFalando do waitMessage;
                cont := 0;
            end
        else
            cont := cont + 1;
    end;

    //***** O folheamento não comporta maior que um integer
    function alcancouLimiteInteger: boolean;
    begin
        if  listArqBusca.Count > 255000 then //Limitado
            alcancouLimiteInteger := true
        else
            alcancouLimiteInteger := false;
    end;

    function tratarTeclaSaida: boolean;
    var c: char;
    begin
        tratarTeclaSaida := false;
        if keypressed then
            begin
                c := readkey;
                if c = ESC then
                    begin
                        procSubDir := false;
                        tratarTeclaSaida := true;
                    end
                else
                if c = ' ' then
                    mudo := not mudo
                else
                    begin
                        sintetiza (intToStr(listArqBusca.Count));
                        mensagem ('DV_ESCARQ', -1); {'Arquivos - '}
                    end;
                while sintFalando do waitMessage;
            end;
    end;

begin
    if FindFirst (nomeDir+nomeArq, (faAnyFile or faArchive) and not faDirectory, searchRec) = 0 then
        repeat
            if alcancouLimiteInteger or tratarTeclaSaida then break;
            listArqBusca.Add (nomeDir+searchRec.Name);
            contadorBipa;
        until FindNext (searchRec) <> 0;
    FindClose(searchRec);
    if not procSubDir then exit;
    // Procura nos subdiretórios
    if FindFirst (nomeDir+'*.*', faDirectory, searchRec) = 0 then
        repeat
            if alcancouLimiteInteger or tratarTeclaSaida then break;
            if (Trim(searchRec.Name) <> '.') and (Trim(searchRec.Name) <> '..') then
                buscaArquivosRecurs (IncludeTrailingPathDelimiter(nomeDir+searchRec.Name), nomeArq, cont);
            contadorBipa;
        until FindNext (searchRec) <> 0;
    FindClose(searchRec);
end;

{--------------------------------------------------------}
{   Ajustes e atualizações na lista de folheamento
{--------------------------------------------------------}

procedure insereArquivoParaFolheamento (i: integer);
begin
    folheiaAdiciona (minLetras(40, ExtractFileName(listArqBusca[i]))
                            + ' em ' + ExtractFileDir(listArqBusca[i]));
end;

{--------------------------------------------------------}
procedure atualizaItemRemovido (i: integer);
begin
    folheiaAlteraAtribs(i,
                        '*** Removido! *** ' + minLetras(22, ExtractFileName(listArqBusca[i-1]))
                                                  + ' em ' + ExtractFileDir (listArqBusca[i-1]),
                        False,
                        'Item removido: ' + ExtractFileName(listArqBusca[i-1])
                                 + ' em ' + ExtractFileDir (listArqBusca[i-1]));
end;

{--------------------------------------------------------}
procedure atualizaItensRemovidos;
var
    i: integer;
    nome: string;
    selecionado: boolean;
begin
    for i := 1 to folheiaNumItens do
    begin
        folheiaObtemItem(i, nome, selecionado);
        if selecionado and ((nome = '') or (nome[1] = '*')) then
            folheiaSeleciona (i, False);
    end;
end;

{--------------------------------------------------------}
{       remove arquivos selecionados
{--------------------------------------------------------}

procedure removeSelecionados (guardaLixeira: boolean);
var
    c: char;
    apagaSelecionados: boolean;
    i, tipoPergunta: integer;
    dirLixeira: string;
    nome: string;
    sel:   boolean;

    {----------------------------------------------------}
    function estaNaLixeira (nomeArq: string): boolean;
    begin
        estaNaLixeira := semAcentos(AnsiUpperCase(ExtractFilePath(nomeArq)))
                            =
                         dirLixeira;
    end;
    {----------------------------------------------------}
    procedure apagaUm (iArq: integer; var tipoPergunta: integer);
    var
        arq: file;
        nomeArq: string;
    begin
        nomeArq := listArqBusca[iArq-1];
        if tipoPergunta > 0 then
        begin
            if guardaLixeira then
                mensagem ('DV_CNF_ARQLIX', 0)       { 'Confirma envio para a lixeira de ' }
            else
                mensagem ('DV_CNF_ARQEXC', 0);      { 'Confirma exclusão definitiva de ' }
            sintWrite (nomeArq);
            write ('? ');

            if tipoPergunta = 1 then
                begin
                    mensagem ('DV_SIMNAO', 0);       { ' (S/N)? '}
                    c := popupMenuPorLetra('SN');
                end
            else
                begin
                    mensagem ('DV_SNTOD',  0);      { 'Sim, não ou todos? '}
                    c := popupMenuPorLetra('SNT');
                end;

            if c = 'T' then
                tipoPergunta := 0
            else
                if c <> 'S' then exit;

            if tipoPergunta = 0 then
                mensagem ('DV_UMMOMENTO', 1);   { 'Um momento...' }
        end;

        if guardaLixeira and (not estaNaLixeira(nomeArq)) then
            copiaRapidaLixeira (nomeArq)
        else
        begin
            assignFile (arq, nomeArq);
            {$I-} erase (arq);  {$I-}
            if ioresult <> 0 then
            begin
                mensagem ('DV_PROTEG', 1);      { 'Arquivo está protegido para regravação' }
                exit;
            end;
        end;
        atualizaItemRemovido(iArq);
        if tipoPergunta <> 0 then
            if guardaLixeira then
                mensagem ('DV_ARQLIX', 1)   { 'Arquivo movido para a lixeira.' }
            else
                mensagem ('DV_ARQEXC', 1);  { 'Arquivo excluído.' }
    end;
    {----------------------------------------------------}

begin
    dirLixeira := sintAmbiente ('DOSVOX', 'DIRLIXEIRA');
    if dirLixeira = '' then dirLixeira := 'c:\recycled\';
    if dirLixeira[length(dirLixeira)] <> '\' then
        dirLixeira := dirLixeira + '\';
    dirLixeira := semAcentos(AnsiUpperCase(dirLixeira));

    apagaSelecionados := False;
    if numSelecBusca >= 1 then
    begin
        mensagem ('DV_APLISEL', 0);       { 'Aplica aos selecionados? ' }
        c := popupMenuPorLetra('SN');
        if c = ESC then
        begin
            mensagem ('DV_OPCANCEL', 1);        { 'Certo, operação foi cancelada' }
            exit;
        end;

        apagaselecionados := c = 'S';
    end;

    tipoPergunta := 2;
    if apagaSelecionados then
    begin
        for i := primeiroItemBusca to folheiaNumItens do
        begin
            folheiaObtemItem (i, nome, sel);
            if (nome <> '') and (nome[1] <> '*') and sel then
                apagaUm (i, tipoPergunta);
        end;
    end
    else
    begin
        tipoPergunta := 1;
        folheiaObtemItem (itemAtualBusca, nome, sel);
        if (nome <> '') and (nome[1] <> '*') then
            apagaUm (itemAtualBusca, tipoPergunta);
    end;
end;

{--------------------------------------------------------}
{             procurar arquivos
{--------------------------------------------------------}

procedure buscaArquivosPorNome;
var
    dirAtual, nomeDir: string;
    arqProcura: ShortString;
    dirProcura:  ShortString;

    tratandoProcArq, falarItem: boolean;

    i: integer;
    c, c1, c2: char;
    s: string;
    sel: boolean;

label
    inicio,
    reIniciaBusca,
    fim,
    getOut;

    {----------------------------------------------------}
    procedure executaArquivo (nomeArq: string; executaSistOp: boolean);
    var
        ext: string;
        nomeProg: string;
    begin
        ext := maiuscAnsi (ExtractFileExt(nomeArq));
        if (ext <> '') and (ext[1] = '.') then delete (ext, 1, 1);

        if ext = '' then
        begin
            editaLeUmArquivo (nomeArq, 1);
            exit;
        end;

        if (ext = 'EXE') or (ext = 'COM') then
        begin
            nomeProg := nomeArq;
            nomeArq := '';
        end
        else
        begin
            if executaSistOp then
                nomeProg := ''
            else
                nomeProg := sintAmbiente ('DOSVOX', 'PROG.' + ext);
            if nomeProg = '' then
            begin
                nomeProg := nomeArq;
                nomeArq := '';
            end;
        end;

        if pos (' ', nomeArq) <> 0 then
            nomeArq := '"' + nomeArq + '"';

        while sintFalando do waitMessage;
        if executaPrograma (nomeProg, dirAtual, nomeArq, SW_SHOWNORMAL) then
            esperaProgVoltar;
        while sintFalando do waitMessage;
    end;
    {----------------------------------------------------}
    procedure vaiParaDiretorio (s: string);
    begin
        s := ExtractFileDir(s);
        {$I-} chdir (s); {$I+}
        if ioresult <> 0 then
            mensagem ('DV_ERRMUD', 1)  { 'Desculpe, não consegui mudar para o diretório pedido.' }
        else
        if sintFalarTudo then
            mensagem ('DV_OKMUD',  1) { 'Ok, troquei diretório de trabalho' }
        else
            mensagem ('DV_OK',  1); { 'Ok, troquei diretório de trabalho' }
    end;
    {----------------------------------------------------}

var apertouShift: boolean;
begin
    yInicioTela := 5;
    yFolheiaTit := yInicioTela;
    yFolheiaIni := yFolheiaTit +2;
    mudo := false;

inicio:
    limpaBaixo(yInicioTela);
    mensagem ('DV_AJUDA_PRMPT', 1);     { 'Selecione parâmetros para a pesquisa de arquivos. Ao final, tecle ESC.' }

    getDir (0, dirAtual);
    if (dirAtual <> '') and (dirAtual[length(dirAtual)] <> '\') then
        dirAtual := dirAtual + '\';

    arqProcura := '*.txt';
    dirProcura  := dirAtual;
    procSubDir  := True;

    formCria;
    formCampo     ('DV_AJUDA_NOME',   pegaTextoMensagem ('DV_AJUDA_NOME'),   arqProcura, 80);   { 'Nome do arquivo ou máscara' }
    formCampo     ('DV_AJUDA_DIRET',  pegaTextoMensagem ('DV_AJUDA_DIRET'),  dirProcura, 80);   { 'Procurar na pasta' }
    formCampoBool ('DV_AJUDA_SUBDIR', pegaTextoMensagem ('DV_AJUDA_SUBDIR'), procSubDir);       { 'Procurar nas subpastas?' }
    dvForm.formEdita(true);

    limpaBaixo(yInicioTela);
    if (trim(arqProcura) = '') or (trim(dirProcura) = '') then
        begin
            mensagem ('DV_DESIST', 1); {'Desistiu...'}
            exit;
        end;

    if dirProcura[length(dirProcura)] <> '\' then
        dirProcura := dirProcura + '\';
    if dirProcura <> dirAtual then
    begin
        {$I-} chdir (dirProcura); {$I+}
        if ioresult <> 0 then
        begin
            sintWrite (dirProcura + ': ');
            mensagem ('DV_AJUDA_DIRNAO', 1);    { 'pasta inexistente ou inacessível.' }
            exit;
        end;
        {$I-} chdir (dirAtual); {$I+}
    end;

    listArqBusca := TStringList.Create;

reIniciaBusca:
    listArqBusca.Clear;
    limpaBufTec;
    buscaArquivosRecurs (dirProcura, arqProcura, 0);
    limpaBufTec;
    yFolheiaFim := Min (ScreenSize.Y - numLinhasInferiores-1,
                        yFolheiaIni+listArqBusca.Count-1);

    limpaBaixo(yFolheiaTit);
    if listArqBusca.Count = 0 then
    begin
        mensagem ('DV_AJUDA_NENHUM', 1);        { 'Nenhum arquivo encontrado.' }
        goto getOut;
    end
    else
    if  listArqBusca.Count > 255000 then //Folheamento limitado pelo tamanho do integer
    begin
        mensagem ('DV_RESTRIBUS', 1);    {'Restrinja sua busca, não é possível mostrar mais de 255000 resultados.'}
        goto getOut;
    end;

    folheiaCria (WhereX, yFolheiaIni, 79, yFolheiaFim);

    for i := 0 to listArqBusca.Count-1 do
        insereArquivoParaFolheamento (i);

    mensagem ('DV_AJUDA_ARQENC', 0);    { 'Arquivos encontrados: ' }
    sintWriteInt (folheiaNumItens);
    Writeln;
    TextBackground (RED);
    mensagem ('DV_AJUDA_SELEC', 1);     { 'Selecione com as setas e tecle opção (ou F9 para menu).' }
    TextBackground (BLACK);

    limpaBaixo(yFolheiaFim+1);
    writeln (str80Tracos);

    itemAtualBusca := 1;
    tratandoProcArq := True;
    falarItem := true;
    repeat
        salvaXY;

        TextBackground (BROWN);
        folheiaExecuta (itemAtualBusca, itemAtualBusca, c1, c2, falarItem);
        apertouShift := getKeyState (vk_Shift) < 0;
        TextBackground (BLACK);
        if itemAtualBusca < 1 then itemAtualBusca := 1;
        if itemAtualBusca > folheiaNumItens then itemAtualBusca := folheiaNumItens;
        limpaBaixo(yFolheiaFim+2);

        restauraXY;

        if (c1 = #0) and (c2 = F9) then
        begin
            c1 := selSetasArquivos;
            if c1 = ESC then
                continue;
        end;

        c1 := upcase (c1);
        numSelecBusca := folheiaNumSelec (primeiroItemBusca);
        if c1 in ['E','L','X', ^M, 'R','A',^R,^A,'C', ^C, ^X] then
        begin
            if numSelecBusca > 0 then
            begin
                // Selecionou alguém...
                atualizaItensRemovidos;
                numSelecBusca := folheiaNumSelec (primeiroItemBusca);
                if numSelecBusca = 0 then
                begin
                    // Todos os selecionados são inválidos.
                    sintBip; sintBip; sintBip;
                    continue;
                end;
            end
            else
            begin
                // Não selecionou nenhum.
                primeiroItemBusca := itemAtualBusca;
            end;
            if (numSelecBusca < 2) then
            begin
                folheiaObtemItem (primeiroItemBusca, s, sel);
                if (s = '') or (s[1] = '*') then
                begin
                    sintBip; sintBip; sintBip;
                    continue;
                end;
            end;
        end;

        Window(1, yFolheiaFim+2, ScreenSize.X, ScreenSize.Y);
        if c1 = #0 then
        case c2 of
            DIR: sintsoletra (ExtractFileName(listArqBusca[itemAtualBusca-1]));
            ESQ: sintsoletra (ExtractFileDir(listArqBusca[itemAtualBusca-1]));
            CTLDIR: mostraDadosArq (listArqBusca[itemAtualBusca-1], false, true, false);
            CTLESQ: mostraDadosArq (listArqBusca[itemAtualBusca-1], false, false, true);
            f5: itemAtualBusca := procuraItem (itemAtualBusca);
            CTLF5: itemAtualBusca := procuraProximoitem (itemAtualBusca);
            F8:     falaHora;
            CTLF8:   falaDia;
        end
    else
        case c1 of

           'Q', ^Q: begin
                        if c1 = 'Q' then
                            sintetiza (intToStr(itemAtualBusca))
                        else
                        begin
                            sintetiza (intToStr(numSelecBusca));
                            if numSelecBusca <= 1 then
                                mensagem ('DV_SELEC', 0)    {' selecionado'}
                            else
                                mensagem ('DV_SELECS', 0);  {' selecionados'}
                        end;
                        mensagem ('DV_DE', 0);      {' de '}
                        sintetiza (intToStr(folheiaNumItens));
                    end;

           ESC: tratandoProcArq := False;

           'E': begin
                    if sintFalarTudo then
                        begin
                            mensagem ('DV_EDITARQ', 0);         { 'Editar arquivo: ' }
                            sintWriteln (listArqBusca[itemAtualBusca-1]);
                        end;
                    editaLeUmArquivo (listArqBusca[itemAtualBusca-1], 0);     { 0 = Edita}
                end;
           'L': begin
                    if sintFalarTudo then
                        begin
                            mensagem ('DV_LEARQ', 0);           { 'Ler arquivo: ' }
                            sintWriteln (listArqBusca[itemAtualBusca-1]);
                        end;
                    editaLeUmArquivo (listArqBusca[itemAtualBusca-1], 1);     { 1 = Lê}
                end;
           'X', ^M, ^J: begin
                    if sintFalarTudo then
                        begin
                            mensagem ('DV_EXECARQ', 0);         { 'Executar: ' }
                            sintWriteln (listArqBusca[itemAtualBusca-1]);
                        end;
                    executaArquivo   (listArqBusca[itemAtualBusca-1], c1 = ^J);
                end;
           'T': begin
                    mensagem ('DV_MUDADIR', 0);         { 'Vai para a pasta: ' }
                    sintWriteln (ExtractFileDir(listArqBusca[itemAtualBusca-1]));
                    vaiParaDiretorio (listArqBusca[itemAtualBusca-1]);
                end;

           'D', 'H': mostraDadosArq (listArqBusca[itemAtualBusca-1], false, (c1 = 'H') or apertouShift, false);
           ^D, ^T: if apertouShift then mostraDadosArq (listArqBusca[itemAtualBusca-1], false, true, false)
                   else  tamanhoArqsSelecionados;
           'R','A': begin
                        if sintFalarTudo then mensagem ('DV_SELLIX', 0);      { 'Mover para lixeira: ' }
                        removeSelecionados (true);
                    end;
           ^R ,^A : begin
                        if sintFalarTudo then mensagem ('DV_SELEXC', 0);      { 'Exclusão definitiva: ' }
                        removeSelecionados (false);
                    end;

           'C': if selecDirDest (ExtractFileDir(listArqBusca[itemAtualBusca-1]), nomeDir) then
                    copiaArquivos (itemAtualBusca - 1, nomeDir);
           ^C, ^X, ^N :  begin
                          copiaTransfSelec (c1 <> ^N);
                          moverObjetos := c1 = ^X;
                     end;

           'B': begin
                    mensagem ('DV_REPBUSCA', 0);        { 'Repetir busca anterior? ' }
                    c := popupMenuPorLetra('SN');
                    if c = 'S' then
                    begin
                        // Limpa todos os itens do folheamento e restaura tela.
                        folheiaDestroi;
                        Window(1, 1, ScreenSize.X, ScreenSize.Y);
                        goto reIniciaBusca;
                    end;
                end;
           'N': begin
                    mensagem ('DV_NOVBUSCA', 0);    { 'Realiza nova busca? ' }
                    c := popupMenuPorLetra('SN');
                    if c = 'S' then
                    begin
                        // Destroi folheamento e lista de arquivos, e restaura tela.
                        folheiaDestroi;
                        listArqBusca.Free;
                        Window(1, 1, ScreenSize.X, ScreenSize.Y);
                        goto inicio;
                    end;
                end;

           ^S: for i := 1 to folheiaNumItens do folheiaSeleciona (i, true);

           NOFOCUS, GOTFOCUS:;

        else
            mensagem ('DV_OPCINV', 1);          { 'Opção inválida.' }
        end;

        if (c1 in [NOFOCUS, 'Q', ^Q]) or
          ((c1 = #0) and (c2 in [ESQ, DIR, F8, CTLF8])) then
            falarItem := false
        else
            falarItem := true;
        limpaBuf;
        if tratandoProcArq and falarItem and sintFalarTudo and not ((c1 = #0) and (c2 in [F5, CTLF5])) then
            mensagem ('DV_CONTSEL', -1); {'Continue selecionando ou tecle ESC.'}

        Window(1, 1, ScreenSize.X, ScreenSize.Y);

    until not tratandoProcArq;

    limpaBaixo(yInicioTela);
    mensagem ('DV_OK', 1);      { 'Ok ! ' }

fim:
    folheiaDestroi;
getOut:
    listArqBusca.Free;
end;

end.
