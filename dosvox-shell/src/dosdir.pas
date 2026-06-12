unit dosdir;

interface
uses
     windows, sysutils, classes, shellapi, dvAmplia,
     dvcrt, dvwin, dvarq, dvform, dvHora, dvexec,
     dosBuscaArq, dosVars, dosproc, dosgeral, dosmsg;

procedure trataSubDiretorio (nomeJanelaComDir: boolean; var vaiParaArquivos: boolean);
procedure selecSubDir (nomeDir: string);
function GetDirSize(dir: string; subdir: Boolean; var numSub, numArq: int64): int64;

implementation

uses dosCopia, dosPref, dosArq;

var
    listDir: TList;
    numDirAtual: integer;
    tipoOrd: integer;

    vetDir: array [1..30] of integer;
    nivelDir: integer;

    mudo: boolean;
    processarTodos: boolean;
    masc: string;

{--------------------------------------------------------}

function temSelecionados: boolean;
var i: integer;
begin
    temSelecionados := false;
    for i := 0 to listDir.count-1 do
        if PMySearchRec(listDir[i]).marcado then
            begin
                temSelecionados := true;
                exit;
            end;
end;

{--------------------------------------------------------}
{                  opcao de diretorio
{--------------------------------------------------------}

procedure ajudaSubDirs;
begin
    mensagem ('DV_AJUS_OPC', 1);    {'Use as setas, depois acione'}

    mensagem ('DV_AJUS_ENTER', 1);  {'   ENTER - seleciona diretório e continua'}
    mensagem ('DV_AJUS_S', 1);      {'   S - sai indo para o diretório pai'}
    mensagem ('DV_AJUS_I', 1);      {'   I - informa diretório atual'}
    mensagem ('DV_AJUS_D', 1);      {'   D - obtém dados'}
    mensagem ('DV_AJUS_C', 1);      {'   C - cria novo subdiretório'}
    mensagem ('DV_AJUS_K', 1);      {'   K - copia'}
    mensagem ('DV_AJUS_R', 1);      {'   R - remove'}
    mensagem ('DV_AJUS_N', 1);      {'   N - troca o nome'}
    mensagem ('DV_AJUS_P', 1);      {'   P - diretórios preferidos'}

    mensagem ('DV_AJU_F9', 1);  {'Aperte F9 para conhecer outras opções'}
    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}

procedure copiaTransfSelec (comDir: boolean);
var i: integer;
    s, dir: string;
begin
    s := '';
    if comDir then
        begin
            getdir (0, dir);
            if dir [length(dir)] <> '\' then
                dir := dir + '\';
        end;

    for i := 0 to listDir.count-1 do
        begin
            if PMySearchRec(listDir[i]).marcado then
                 s := s + dir + PMySearchRec(listDir[i]).sr.Name + #$0d + #$0a;
        end;
    if s = '' then
        if numDirAtual >= 0 then
            s := s + dir + PMySearchRec(listDir[numDirAtual]).sr.Name + #$0d + #$0a;

    putClipBoard(@s[1]);
    sintclek;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

function selSetasDir: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var n: integer;
label menuContinua;
const
    tabLetrasPrincipal: string = ENTER+'tscrnpkdvixzgb+';
    tabLetrasCont     : string =  ^c+^n+^v+^x;

begin
    popupMenuCria (20, wherey, 60, length(tabLetrasPrincipal), RED);
    MenuAdiciona ('DV_AJUS_ENTER'); {'   ENTER - seleciona diretório e continua'}
    MenuAdiciona ('DV_AJUS_T');     {'   T - seleciona e sai'}
    MenuAdiciona ('DV_AJUS_S');     {'   S - sai indo para o diretório pai'}
    MenuAdiciona ('DV_AJUS_C');     {'   C - cria novo subdiretório'}
    MenuAdiciona ('DV_AJUS_R');     {'   R - remove'}
    MenuAdiciona ('DV_AJUS_N');     {'   N - troca o nome'}
    MenuAdiciona ('DV_AJUS_P');     {'   P - diretórios preferidos'}
    MenuAdiciona ('DV_AJUS_K');     {'   K - copia'}
    MenuAdiciona ('DV_AJUS_D');     {'   D - obtém dados'}
    MenuAdiciona ('DV_AJUS_V');     {'   V - volta ao penúltimo processado'}
    MenuAdiciona ('DV_AJUS_I');     {'   I - informa diretório atual'}
    MenuAdiciona ('DV_AJUS_X');     {'   X - executar o diretório atual'}
    MenuAdiciona ('DV_AJUS_Z');     {'   Z - compactar subdiretório'}
    MenuAdiciona ('DV_AJUS_G');     {'   G - exibir um grupo de subdiretórios'}
    MenuAdiciona ('DV_AJUD_B');     {'   B - busca de arquivos por nome'}
    MenuAdiciona ('DV_AJU_MA');     {'   + - folhear mais opções'}

    n := popupMenuSeleciona;
    if n > 0 then
        if tabLetrasPrincipal[n] = '+' then
            goto menuContinua
        else
            selSetasDir := tabLetrasPrincipal[n]
    else
        begin
             selSetasDir := ESC;
             clreol;
        end;
    exit;

menuContinua:
    popupMenuCria (20, wherey, 60, length(tabLetrasCont), BLACK);
    MenuAdiciona ('DV_AJUA_CTL_C');     {'  Ctrl+C - copiar nomes para área de transferência'}
    MenuAdiciona ('DV_AJUA_CTL_N');     {'  Ctrl+N - jogar os nomes sem incluir diretório'}
    MenuAdiciona ('DV_AJUA_CTL_V');     {'  Ctrl+V - copiar arquivos da área de transferência'}
    MenuAdiciona ('DV_AJUA_CTL_X');     {'  Ctrl+X - mover arquivos para área de transferência'}

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasDir := tabLetrasCont[n]
    else
        begin
             selSetasDir := ESC;
             clreol;
        end;
end;

{--------------------------------------------------------}
{               recria a lista de diretórios
{--------------------------------------------------------}

procedure recriaLista (masc: string; atrib: word; tipoOrd: integer);
begin
    if listDir <> NIL then
        liberaListArq;
    listDir := criaListArq (masc, atrib);
    ordenaListArq(tipoOrd);
end;

{--------------------------------------------------------}

procedure reordena;
var
    c: char;
begin
//    mensagem ('DV_TIPORDSUB', 0);  {'Ordena por Nome, Tamanho ou Data? '}
    mensagem ('DV_TIPORDSUB2', 0);  {'Ordena por Nome ou Data? '}
//    c := popupMenuPorLetra('NTD');
    c := popupMenuPorLetra('ND');
    if c = ESC then
        begin
            mensagem ('DV_OPCANCEL', 2);        { 'Certo, operação foi cancelada' }
            exit;
        end;

    case c of
//Não funcionando        'T': tipoOrd := 2;
        'D': tipoOrd := 3;
    else
        tipoOrd := 0;
    end;

    numDirAtual := 0;
    recriaLista (masc, FaDirectory, tipoOrd);
end;

{--------------------------------------------------------}

procedure criarSubDir;
var novoDir: string;
    c: char;
begin
     mensagem ('DV_DIRCRI', 0);     { 'Nome do diretório a criar: ' }
     writeln;
     novoDir := '';
     c := sintEdita (novoDir, wherex, wherey, 255, true);
     novoDir := trim (novoDir);
     writeln;
     if (c = #$1b) or (novoDir = '') then exit;

     {$I-} mkdir (novoDir); {$i+}
     if ioresult <> 0 then
          mensagem ('DV_ERRDIRCRI', 1)  { 'Desculpe mas não consegui criar o diretório pedido.' }
     else
         begin
              mensagem ('DV_OKDIRCRI', 1);      { 'Ok, criei o diretório !' }
              mensagem ('DV_QUERD', 0);         { 'Ele vai ser o novo diretório de trabalho ' }
              mensagem ('DV_SIMNAO', 0);        { ' (S/N)? ' }
              c := popupMenuPorLetra('SN');
              if c = 'S' then
                   begin
                       {$I-} chdir (novoDir); {$i+}
                       if ioresult <> 0 then
                            mensagem ('DV_ERRDIRCRI', 1)    { 'Desculpe mas não consegui criar o diretório pedido.' }
                       else
                           begin
                               if (novoDir[1] = '\') or
                                   ( (length (novoDir) >= 3) and
                                   (novoDir[2] = ':') and (novoDir[3] = '\')  ) then
                                   nivelDir := 0    { evita voltas invalidas }
                               else
                                   if nivelDir <= 30 then
                                       begin
                                           nivelDir := nivelDir + 1;
                                           vetDir [nivelDir] := numDirAtual ;
                                       end;
                               numDirAtual := 0;
                           end;
                   end;
         end;
end;

{--------------------------------------------------------}

function subDirProibido (nomeSubDir: string): boolean;
var
    dirAtual, dirApagar: string;
begin
    getDir (0, dirAtual);
    if dirAtual [length(dirAtual)] <> '\' then
         dirAtual := dirAtual + '\';
    delete (dirAtual, 1, 2);
    dirAtual := maiuscAnsi (dirAtual);

    dirApagar := dirAtual + maiuscAnsi (nomeSubDir);

    subDirProibido :=
       (nomeSubDir = '.') or
       (nomeSubDir = '..') or
       (dirAtual = '\WINDOWS') or
       (dirAtual = '\WINNT') or
       (dirApagar = '\WINDOWS') or
       (dirApagar = '\WINNT') or
       (dirApagar = '\WINDOWS\SYSTEM') or
       (dirApagar = '\WINDOWS\SYSTEM32') or
       (dirApagar = '\WINNT\SYSTEM') or
       (dirApagar = '\WINNT\SYSTEM32') or
       (dirApagar = '\ARQUIVOS DE PROGRAMAS') or
       (dirApagar = '\PROGRAM FILES') or
       (dirApagar = '\DOCUMENTS AND SETTINGS') or
       (dirApagar = '\WINVOX') or
       (dirApagar = '\WINVOX\SOM') or
       (dirApagar = '\WINVOX\SOM\LETRAS') or
       (dirApagar = '\WINVOX\SOM\DIFONES');
end;

{--------------------------------------------------------}

procedure trocaNomeSubDir (nomeDir: string);
var novoNome: string;
begin
    if subDirProibido (nomeDir) then
        begin
             mensagem ('DV_ERRNOMEMUD', 1); {'Não pude mudar o nome'}
             exit;
        end;

    mensagem ('DV_EDITNOVNOME', 1);     {'Editore o novo nome'}
    novoNome := nomeDir;
    if sintEdita (novoNome, wherex, wherey, 255, true) = ESC then
         novoNome := '';
    novoNome := trim (novoNome);
    if novoNome = '' then
        begin
            mensagem ('DV_DESIST', 1);      {'Desistiu...'}
            exit;
        end;

    if moveFile (@nomedir[1], @novoNome[1]) then
        mensagem ('DV_OKNOMEMUD', 1)    {'OK, nome mudado'}
    else
        mensagem ('DV_ERRNOMEMUD', 1)   {'Não pude mudar o nome'}
end;

{--------------------------------------------------------}

procedure superDeletaSubDir(nomeDir: string; atual: integer);
var
    c: char;
    fos: TSHFileOpStruct;
begin
    if subDirProibido(nomeDir) then
        begin
            mensagem ('DV_ERRREMDIR', 0);   { 'Desculpe: não consegui remover o diretório pedido.' }
            sintWriteln (nomeDir);
            exit;
       end;

    if not processarTodos then
        begin
            mensagem ('DV_CNFAPA', 0);      { 'Confirma remoção de ' }
            sintWriteln (nomedir);
            mensagem ('DV_SNTOD', 0);       { 'Sim, não ou todos? '}
            c := popupMenuPorLetra('SNTD');
            if not (c in ['S', 'T']) then
                exit;
            if upcase (c) = 'T' then
                processarTodos := true;
        end;

    ZeroMemory(@fos, SizeOf(fos));
    with fos do
        begin
            wFunc  := FO_DELETE;
            fFlags := FOF_SILENT or FOF_NOCONFIRMATION or FOF_NOERRORUI;
            pFrom  := PChar(nomeDir + #0);
        end;

    if ShFileOperation(fos) <> 0 then
        begin
            sintBip;
            sintWriteln (nomedir);
            mensagem ('DV_ERRREMDIR', 1)    { 'Desculpe: não consegui remover o diretório pedido.' }
        end
    else
        begin
            if not mudo then
                begin
                    mensagem ('DV_OKREMDIR', 1);     { 'Ok, apaguei o diretório !' }
                    sintWriteln (nomedir);
                end;
            if atual <= numDirAtual then
                numDirAtual := numDirAtual - 1;
        end;
end;

{--------------------------------------------------------}

procedure removeSubDir (nomedir: string; atual: integer);
var
    c: char;
begin
    if not processarTodos then
        begin
            mensagem ('DV_CNFAPA', 0);  { 'Confirma remoção de ' }
            sintWriteln (nomedir);
            mensagem ('DV_SNTOD', 0);   { 'Sim, não ou todos? ' }
            c := popupMenuPorLetra('SNT');
            if not (c in ['S', 'T']) then
                exit;
            if upcase (c) = 'T' then
                processarTodos := true;
        end;

    {$I-} rmdir (nomedir); {$i+}
    if ioresult <> 0 then
         mensagem ('DV_ERRREMDIR', 1)   { 'Desculpe: não consegui remover o diretório pedido.' }
    else
        begin
            if not mudo then
                mensagem ('DV_OKREMDIR', 1)     { 'Ok, apaguei o diretório !' }
            else
                sintclek;
            if atual <= numDirAtual then
                numDirAtual := numDirAtual - 1;
        end;
end;

{--------------------------------------------------------}

function copiaSubDir (nomeDir, novoDir: string): boolean;
var
    fos: TSHFileOpStruct;
    c: char;
begin
    copiaSubDir := false;
    if not processarTodos then
        repeat
            if directoryExists (novoDir+nomeDir) then   // esse comando fica dentro do loop
                                                        // pois o usuário pode apagar externamente
                                                        // ou trocar de disco.
                begin
                    if naoParaTodos then
                        begin
                            copiaSubDir := true;
                            if sintFalarTudo and (not mudo) then sintBip;
                            exit;
                        end;
                    if keypressed then mudo := not mudo;
                    limpaBufTec;
                    while sintFalando do waitMessage;
                    mensagem ('DV_DIREXIS', 0);     {'Diretório já existe: '}
                    while sintFalando do waitMessage;
                    sintWriteln (novoDir+nomeDir);
                    while sintFalando do waitMessage;
                    mensagem ('DV_SOBRE_SN', 0);    {'Sobrescreve (S/N)? '}
                    while sintFalando do waitMessage;
                    c := popupMenuPorLetra('SNTPD');
                    writeln;
                    if not (c in ['S', 'N', 'T', 'P', 'D', ESC, ENTER]) then
                        mensagem ('DV_AJUTIL', 1);  {'  Pode usar as setas para selecionar ou conhecer todas as opções'}

                    if c = ENTER then c := 'S'
                    else
                    if c = 'D'then c := ESC;

                    if c =  ESC then
                        begin
                            mensagem ('DV_DESIST', 1);  {'Desistiu...'}
                            exit;
                        end
                    else
                    if c in ['N', 'P'] then
                        begin
                            copiaSubDir := true;
                            if c = 'P' then naoParaTodos := true;
                            sintBip;
                            exit;
                        end
                    else
                    if c = 'T' then
                        processarTodos := true;
                end
            else c := 'S';
            mudo := processarTodos;
        until c in ['S', 'T'];

    if sintFalarTudo and (not mudo) then mensagem ('DV_UMMOMENTO', 1);       {'Um momento...'}

    ZeroMemory(@fos, SizeOf(fos));
    with fos do
        begin
            wFunc  := FO_COPY;
            fFlags := FOF_NOERRORUI or FOF_NOCONFIRMATION;
            pFrom  := PChar(nomeDir + #0);
            pTo    := PChar(novoDir);
        end;

    if ShFileOperation(fos) = 0 then
        begin
            copiaSubDir := true;
            if keypressed then mudo := not mudo;
            limpaBufTec;
            if sintFalarTudo then
                begin
                    sintWrite (nomeDir);
                    while sintFalando do waitMessage;
                    mensagem ('DV_COPIADO', 1);    { ' copiado.'}
                    while sintFalando do waitMessage;
                end;
        end
    else
        begin
            sintbip;
            mensagem ('DV_ERRCOPIA', 1);   { 'Sinto muito, deu erro no disco, portanto não copiei.' }
        end;
    while sintFalando do waitMessage;
end;

{--------------------------------------------------------}

procedure processarDirSelec (tipoPro: char; nomeDir: string);
var
    i :integer;
    c: char;
    processarSelecionados: boolean;
    novoDir: string;
begin
    if tipoPro = ^R then
        begin
            textBackground (RED);
            mensagem ('DV_PERIGO', 0);      {'Atenção, essa operação é irreversível...'}
            textBackground (BLACK);
            writeln;
            mensagem ('DV_TECLECCONT', 0);  {'Aperte a tecla C para continuar'}
            c := popupMenuPorLetra ('CN');
            writeln;
            if upcase(c) <> 'C' then
                begin
                    mensagem ('DV_DESIST', 1);      {'Desistiu...'}
                    exit;
                end;
        end
    else
    if tipoPro in ['K', ^K] then
        begin
            novoDir := '';
            if not selecDirDest ('', novoDir) then exit;
        end;

    mudo := false;
    processarTodos := false;
    naoParaTodos := false;
    processarSelecionados := false;
    if temSelecionados then
        repeat
            if tipoPro in ['K', ^K] then
                mensagem ('DV_TODSEL', 0)        {'Copia todos os selecionados? '}
            else
            if tipoPro in ['R', ^R] then
                mensagem ('DV_APGSELEC', 0);     {'Apaga todos os selecionados? '}
            c := popupMenuPorLetra('SND');
            writeln;
            if c in ['D', ESC] then
                begin
                    mensagem ('DV_OPCANCEL', 2);    { 'Certo, operação foi cancelada' }
                    exit;
                end
            else
                processarSelecionados := c = 'S';
            if tipoPro in ['R', ^R] then mudo := processarSelecionados;
        until c in ['S', 'N'];

    if processarSelecionados then
        begin
            for i := listDir.count-1 downto 0 do
                if PMySearchRec(listDir[i]).marcado then
                    begin
                        if keypressed then
                            begin
                                c := readkey;
                                if c = ESC then break
                                else mudo := not mudo;
                            end;

                        nomeDir := PMySearchRec(listDir[i]).sr.FindData.cFileName;
                        case tipoPro of
                            'K': if not copiaSubDir (nomeDir, novoDir) then exit;
                            ^R: superDeletaSubDir(nomeDir, i);
                            'R': removeSubDir (nomedir, i);
                        end;
                    end;
            if not sintFalarTudo then sintclek;
        end
    else
        begin
            case tipoPro of
                'K': copiaSubDir (nomeDir, novoDir);
                ^R: superDeletaSubDir(nomeDir, numDirAtual);
                'R': removeSubDir (nomedir, numDirAtual);
            end;
        end;

    if numDirAtual < 0 then numDirAtual := 0;
    limpabuftec;
end;

{--------------------------------------------------------}

procedure selecSubDir (nomeDir: string);
var dirMudado: string;
begin
    writeln;
    {$I-} chdir (nomedir); {$i+}
    if ioresult <> 0 then
         mensagem ('DV_ERRMUD', 1)      { 'Desculpe, não consegui mudar para o diretório pedido.' }
    else
        begin
            getdir (0, dirMudado);
            insereNosUltimosComandos(dirMudado, 'DOSVOX', 'DT');
            if sintFalarTudo then
                mensagem ('DV_OKMUD',  1) { 'Ok, troquei diretório de trabalho' }
            else
                mensagem ('DV_OK',  1); { 'Ok, troquei diretório de trabalho' }
             if nivelDir <= 30 then
                 begin
                     nivelDir := nivelDir + 1;
                     vetDir [nivelDir] := numDirAtual;
                 end;
             numDirAtual := 0;
        end;
end;

{--------------------------------------------------------}

procedure selecDirPai;
var dirMudado: string;
begin
    {$I-} chdir ('..');  {$I+}
    if ioresult <> 0 then
         mensagem ('DV_ERRMUD', 1)      { 'Desculpe, não consegui mudar para o diretório pedido.' }
    else
        begin
            if sintFalarTudo then
                mensagem ('DV_OKMUD',  1) { 'Ok, troquei diretório de trabalho' }
            else
                mensagem ('DV_OK',  1); { 'Ok, troquei diretório de trabalho' }

            getdir (0, dirMudado);
            insereNosUltimosComandos(dirMudado, 'DOSVOX', 'DT');

            if nivelDir > 0 then
                begin
                    numDirAtual := vetDir [nivelDir];
                    nivelDir := nivelDir - 1;
                end
            else
                numDirAtual := 0;
        end;
end;

{--------------------------------------------------------}

procedure informaDirecTrab;
var dir: string;
    c: char;
begin
    getdir (0, Dir);
    if sintFalarTudo then mensagem ('DV_DIRATU', 0);      { 'O diretório atual é ' }
    soletra (copy (Dir, 1, 2), 0);
    sintetFala (copy (Dir, 3, length(Dir)-2) , 1);

    mensagem ('DV_QERSOLET', 0);    { 'Quer que soletre' }
    mensagem ('DV_SIMNAO', 0);      { ' (S/N)? ' }
    c := popupMenuPorLetra('SN');
    if upcase (c) = 'S' then
        sintSoletra (dir);
end;

{--------------------------------------------------------}

function GetDirSize(dir: string; subdir: Boolean; var numSub, numArq: int64): int64;
var
    rec: TSearchRec;
    found: int64;
begin
    Result := 0;
    if dir[Length(dir)] <> '\' then dir := dir + '\';
    found := FindFirst(dir + '*.*', faAnyFile, rec);
    while found = 0 do
        begin
            Inc(Result, Int64(rec.FindData.nFileSizeHigh) shl Int64(32) +
                        Int64(rec.FindData.nFileSizeLow));

            if (rec.Attr and faDirectory > 0) and (rec.Name <> '.') and
              (rec.Name <> '..') and (subdir = True) then
                begin
                    inc (numSub, 1);
                    Inc(Result, GetDirSize(dir + rec.Name, True, numSub, numArq));
                end
            else
            if  (rec.Name <> '.') and (rec.Name <> '..') then
                inc (numArq, 1);
            found := FindNext(rec);
        end;
    FindClose(rec);
end;

{--------------------------------------------------------}

procedure falaHoraCriaDir (comMensagem: boolean);
begin
    if comMensagem then
        begin
            mensagem ('DV_DATACRI', 0);     { 'Data de criação: ' }
            sintWrite (tabNomesDias [dayOfWeek
                (FileDateToDateTime(PMySearchRec(listDir[numDirAtual]).sr.Time))]         + ' ');
        end;
    sintWriteln (dateToStr (FileDateToDateTime(PMySearchRec(listDir[numDirAtual]).sr.Time))
        + ' ' + timeToStr (FileDateToDateTime(PMySearchRec(listDir[numDirAtual]).sr.Time)));
    writeln;
end;

{--------------------------------------------------------}

procedure dadosDir (soFalaNumItens, selecionados, soFalaTamanho: boolean);
var
    i: integer;
    numSubDir, numArq, tamanho: int64;
    medida: string;
    decimal: longint;
begin
    numSubDir := 0;
    numArq := 0;
    if not selecionados then
        tamanho := GetDirSize(PMySearchRec(listDir[numDirAtual]).sr.FindData.cFileName, true, numSubDir, numArq)
    else
        begin
            tamanho := 0;
            for i := 0 to listDir.count-1 do
                if PMySearchRec(listDir[i]).marcado then
                    begin
                        tamanho := tamanho + GetDirSize(PMySearchRec(listDir[i]).sr.FindData.cFileName, true, numSubDir, numArq);
                        numSubDir := numSubDir + 1;
                    end;
        end;

    if not soFalaNumItens then
        begin
            medida := '';
            if tamanho >= 65536 then
                begin
                    medida := 'K';
                    decimal := tamanho mod 1024;
                    tamanho := tamanho div 1024;
                    if decimal > 512 then tamanho := tamanho + 1;
                end;
            if tamanho >= 65536 then
                begin
                    medida := 'MB';
                    decimal := tamanho mod 1024;
                    tamanho := tamanho div 1024;
                    if decimal > 512 then tamanho := tamanho + 1;
                end;

            if sintFalarTudo then
                mensagem ('DV_TAMANHO', 0);     {'Tamanho: '}
            if tamanho = 0 then
                sintCarac ('0')    // corrige erro no sintetizador L&H
            else
                begin
                    sintWriteInt (tamanho);
                    write (' ');
                    sintWrite ( medida);
                end;
            writeln;
            delay (50);
            if soFalaTamanho then exit;
            if not selecionados then
                falaHoraCriaDir (sintFalarTudo)
            else
                mensagem ('DV_SELECS', 1);  {' selecionados'}
        end;

    if numArq > 0 then
        begin
            mensagem ('DV_ESCARQ', 0);      { 'Arquivos - ' }
            sintWriteInt (numArq);
            write ('        ');
            delay (50);
        end;
    if numSubDir > 0 then
        begin
            if sintFalarTudo then mensagem ('DV_SUBDIR', 0)  {'Subdiretórios - '}
            else mensagem ('DV_PASTAS', 0);     {'Pastas - '}
            sintWriteInt (numSubDir);
        end;
    if (numArq = 0) and (numSubDir = 0) then
        sintsoletra('0');
    writeln;
end;

{--------------------------------------------------------}

procedure voltaPenultDir;
var dir: string;
    dirMudado: string;
begin
    getDir (0, dir);
    {$I-} chdir (penultSubDir);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('DV_ERRMUD', 1);   { 'Desculpe, não consegui mudar para o diretório pedido.' }
            exit;
        end;

    getdir (0, dirMudado);
    insereNosUltimosComandos(dirMudado, 'DOSVOX', 'DT');

    if sintFalarTudo then mensagem ('DV_DIRATU', 0);          { 'O diretório atual é ' }
    soletra (copy (penultSubDir, 1, 2), 0);
    sintetFala (copy (penultSubDir, 3, length(penultSubDir)-2) , 1);
    sintClek;
    penultSubDir := dir;

    nivelDir := 0;
    numDirAtual := 0;
end;

{--------------------------------------------------------}

function confirmaSeContinua: boolean;
var c, c2: char;
begin
    mensagem ('DV_TECLECCONT', 1);      {'Aperte a tecla C para continuar'}
    pegaTeclado (c, c2);
    if upcase(c) <> 'C' then
        begin
            mensagem ('DV_OPCANCEL', 1);    { 'Certo, operação foi cancelada' }
            confirmaSeContinua := false;
        end
    else
        confirmaSeContinua := true;
end;

{--------------------------------------------------------}

procedure compactarDiretorio (nomeDir: string);
var compactador: string;
begin
    compactador := sintambiente('DOSVOX', 'COMPACTADOR');
    if compactador = '' then
        begin
            mensagem ('DVNOCOMP', 1);   {'Não consegui acionar o compactador'}
            exit;
        end;

    mensagem ('DV_COMPSDIR', 1);    {'Compactar subdiretório'}
    if not confirmaSeContinua then exit;
    mensagem ('DV_AGUCOMPACT', 1);  {'Um momento, compactando'}
    nomeDir := '"'+ StringReplace(nomeDir, '.', '_', [rfReplaceAll, rfIgnoreCase]) + '" "'+ nomedir+ '"';
    if executaPrograma (compactador, '', nomeDir, SW_SHOWMINIMIZED) then;
        esperaProgVoltar;
    limpaBuf;
    mensagem ('DV_OKCOMPAC', 1);    {'Ok, compactado'}
end;

{--------------------------------------------------------}

{--------------------------------------------------------}

procedure tocaDir;
var
    dir, nomeArq, nomeProg: string;
    i: integer;
    arq: text;
    selecionados: boolean;

    function criaNomeArqTemp: string;
    var
        tempPath: array [0..144] of char;
    begin
        getTempPath (144, tempPath);
        criaNomeArqTemp := strPas(tempPath) + '\MusicList.m3u';
    end;

    procedure montaListaMusic(dirMusic: string; subdir: Boolean);
    var
        rec: TSearchRec;
        found: int64;
    begin
        if dirMusic[Length(dirMusic)] <> '\' then dirMusic := dirMusic + '\';
        found := FindFirst(dirMusic + '*.*', faAnyFile, rec);
        while found = 0 do
            begin
                if (rec.Attr and faDirectory > 0) and (rec.Name <> '.') and
                  (rec.Name <> '..') and (subdir = True) then
                    montaListaMusic (dirMusic + rec.Name, true)
                else
                if  (rec.Name <> '.') and (rec.Name <> '..') and
                 ((pos ('.MP3',maiuscansi(rec.Name)) = length (rec.Name) - 3) or
                  (pos ('.WAV',maiuscansi(rec.Name)) = length (rec.Name) - 3) or
                  (pos ('.WMA',maiuscansi(rec.Name)) = length (rec.Name) - 3) or
                  (pos ('.M4A',maiuscansi(rec.Name)) = length (rec.Name) - 3) or
                  (pos ('.MID',maiuscansi(rec.Name)) = length (rec.Name) - 3)) then
                    begin
                        {$I-} writeln(arq, dirMusic + rec.Name); {$I+}
                        if ioresult <> 0 then
                            mensagem  ('DVERRMID', 2);  {'Não consegui gerar a lista de mídias.'}
                    end;

                found := FindNext(rec);
            end;
        FindClose(rec);
    end;

begin
    getdir (0, dir);
    if dir [length(dir)] <> '\' then
        dir := dir + '\';
    nomeArq := criaNomeArqTemp;
    selecionados := temSelecionados;

    mensagem ('DV_EXECSDIR', 1);    {'Executar subdiretório'}
    if not confirmaSeContinua then exit;

    mensagem ('DV_UMMOMENTO', 1);   {'Um momento...'}
    assign (arq, nomeArq);
    {$I-} rewrite (arq); {$I+}
    if ioresult <> 0 then
        mensagem  ('DVERRMID', 2)  {'Não consegui gerar a lista de mídias.'}
    else
        begin
            if not selecionados then
                montaListaMusic (dir + PMySearchRec(listDir[numDirAtual]).sr.FindData.cFileName, true)
            else
                for i := 0 to listDir.count-1 do
                    if PMySearchRec(listDir[i]).marcado then
                        montaListaMusic (dir + PMySearchRec(listDir[i]).sr.FindData.cFileName, true);
            {$i-} close (arq); {$i+}
            if ioresult <> 0 then
                mensagem  ('DVERRMID', 2)  {'Não consegui gerar a lista de mídias.'}
            else
                begin
                     nomeProg := sintAmbiente ('DOSVOX', 'PROG.M3U');
                     if nomeProg = '' then
                         begin
                             nomeProg := nomeArq;
                             nomeArq := '';
                         end;
                     if pos (' ', nomeArq) <> 0 then
                          nomeArq := '"' + nomeArq + '"';
                     while sintFalando do waitMessage;
                     if executaPrograma (nomeProg, '', nomeArq, SW_SHOWNORMAL) then
                          esperaProgVoltar;
                    limpaBuf;
                    mensagem ('DV_OK', 1);      { 'Ok ! '}
                end;
        end;
end;

{--------------------------------------------------------}

procedure dirSelecaoPorMascara;
begin
    mensagem ('DV_MASCSE', 0);      { 'Informe a máscara de seleção: ' }
    sintReadln (masc);
    if (masc = '') or (masc[1] = ' ') then
        masc := '*.*';

    recriaLista (masc, FaDirectory, tipoOrd);
    numDirAtual := 0;
end;

{--------------------------------------------------------}

procedure copiaDirUsandoTransf (movendo: boolean);
begin
    copiaUsandoTransf (movendo);
    recriaLista (masc, FaDirectory, tipoOrd);
end;

{--------------------------------------------------------}

procedure dirNoExplorer(nomeDir: string);
var dir: string;
begin
    getDir (0, dir);
    if dir[length(dir)] <> '\' then
        dir := dir + '\';

    mensagem ('DV_ABRWEXP', 2);     { 'Abrindo diretório no Windows Explorer' }
    shellExecute (0, 'OPEN', '', '', pchar(dir+nomeDir), SW_SHOWNORMAL);
    esperaProgVoltar;
end;

{--------------------------------------------------------}

procedure trataSubDiretorio (nomeJanelaComDir: boolean; var vaiParaArquivos: boolean);
var
    c, c2: char;
    ymin, i: integer;
    dirInicial, dirFinal: string;
    nomeDir: string;
    fator, dummy: integer;
    apertouShift: boolean;

label executaFunc;

begin
    vaiParaArquivos := false;

    getDir (0, dirInicial);
    if nomeJanelaComDir then
        if sintFalarTudo then setWindowTitle('Subdiretórios - ' + dirInicial)
        else setWindowTitle('Pastas - ' + dirInicial);

    if isAudioCd (dirInicial[1]) then
        begin
            mensagem ('DV_CDNAODIR', 2);    {'CD de áudio não tem diretórios'}
            exit;
        end;

    if DiskSize(0) < 1 then
        begin
            mensagem ('DV_DISCOREMOV', 2);   {'Disco foi removido.'}
            exit;
        end;

    listDir := NIL;
    nivelDir := 0;

    limpaBuf;
    numDirAtual := 0;

    textBackground (RED);
    if sintFalarTudo then
        mensagem ('DV_AJUSDIR1', -1)                   { 'Subdiretórios: Use as setas para selecionar' }
    else
        mensagem ('DV_PASTAS', -1);               {'Pastas - '}
    write (pegaTextoMensagem('DV_AJUSDIR1')); { 'Subdiretórios: Use as setas para selecionar' }
    textBackground (BLACK); writeln;
    if sintFalarTudo and (not keypressed) then
        mensagem ('DV_AJUSDIR2', 1)     { 'Depois tecle sua opção' }
    else
        writeln;

    masc := '*.*';
    tipoOrd := 0;
    c := 'S'; //Para forçar criar a lista na primeira vez que entra no loop
    amplPegaConfig(fator, dummy, dummy, dummy);

    repeat
        if DiskSize(0) < 1 then
            begin
                mensagem ('DV_DISCOREMOV', 2);  {'Disco foi removido.'}
                exit;
            end;

        if nomeJanelaComDir then
            begin
                getDir (0, dirFinal);
                if sintFalarTudo then
                    setWindowTitle('Subdiretórios - ' + dirFinal)
                else
                    setWindowTitle('Pastas - ' + dirFinal);
            end;

        if upcase(c) in ['S', ^H, ENTER, GOTFOCUS, 'V', ^K] then
            masc := '*.*';
        if (c2 = F2) or (upcase(c) in ['C', 'S', ^H, ENTER, GOTFOCUS, 'V', 'N', 'R', ^R, ^K, ^V]) then
            recriaLista (masc, FaDirectory, tipoOrd);

        if not (upcase(c) in [^V, 'S', ^H, 'G']) and
                         (listDir.count = 0) then
            begin
                textBackground (RED);
                mensagem ('DV_SEMSDIR', 0);     { 'Nao existem subdiretórios aqui.' }
                textBackground (BLACK);
                writeln;
            end;

        ymin := 25-listDir.count+1;
        if ymin <= fator then ymin := fator+1;
        if ymin < 1 then ymin := 1;
        preparaTelaArq (41, ymin, 79, 25);

        salvaTelaArq;
        escolheFuncaoListArq (numDirAtual, c, c2);
        recuperaTelaArq;
        apertouShift := getKeyState (vk_Shift) < 0;

executaFunc:
        if ((numDirAtual >= 0) and (numDirAtual < listDir.count)) or
           (upcase(c) in ['S', ^H,'C','I','V','A','Q', ^Q, 'G', ^V]) or (c2 in [F8, CTLF8, F1, F9]) then
            begin
                if numDirAtual >= 0 then
                    nomeDir := PMySearchRec(listDir[numDirAtual]).sr.FindData.cFileName
                else
                    nomeDir := '';
                if upcase(c) in ['Q', ^Q] then
                    begin
                        falaQualItemDeQuantos (numDirAtual+1, c = ^Q, listDir);
                        writeln;
                        textBackground (RED);
                        if sintFalarTudo then
                            mensagem ('DV_CONTSEL', 0) { 'Continue selecionando ou tecle ESC' }
                        else
                            write (pegaTextoMensagem('DV_CONTSEL')); { 'Continue selecionando ou tecle ESC' }
                        textBackground (BLACK);
                        writeln;
                    end
                else
                if c = #$0 then
                    case c2 of
                        CTLDIR: falaHoraCriaDir (false);
                        CTLESQ: dadosDir (false, apertouShift, true);
                        F1: ajudaSubDirs;
                        F2: trocaNomeSubDir (nomeDir);
                        F7, DEL:
                            begin
                                 c := 'R';
                                 goto executaFunc;
                            end;

                        F8: falaHora;
                     CTLF8: falaDia;

                        F9: begin
                                 write (#$0d, nomeDir, #$0d);
                                 c2 := 'a';
                                 c := selSetasDir;
                                 goto executaFunc;
                            end;
                    end
                else
                    begin
                        if (c <> GOTFOCUS) and (c <> ESC) then
                            begin
                                write (nomeDir);
                                if sintEcoarOpcao and (c > #32 {<> ENTER}) then
                                    begin
                                        write (' -> ');
                                        mensagem ('DV_OPCAO', 0);   { ' opção ' }
                                        if c < ' ' then
                                            begin  sintBip; writeln; end
                                        else
                                            soletra (c, 1);
                                    end
                                else
                                    writeln;
                            end;

                        c := upcase (c);
                        case c of
                            'B': buscaArquivosPorNome;
                            'G': dirSelecaoPorMascara;
                            'T': begin
                                      selecSubDir (nomeDir);
                                      if nomeJanelaComDir then c := ENTER
                                      else c := ESC;
                                  end;
                            'S', ^H: selecDirPai; // ^H é Backspace
                            'C': criarSubDir;
                            ^j : dirNoExplorer(nomeDir); {ctl-enter}
                            ^m : selecSubDir (nomeDir); {enter}
                            'N': trocaNomeSubDir (nomeDir);
                            'R', ^R, 'K': processarDirSelec (c, nomeDir);
                            ^S : for i := 0 to listDir.count-1 do PMySearchRec(listDir[i]).marcado := true;
                            'D', 'F', ^D, ^T, ^F:  if (c = ^D) and apertouShift then
                                      falaHoraCriaDir (false)
                                  else
                                      dadosDir (c in ['F', ^F], c in [^D, ^T, ^F], false);

                            'H': falaHoraCriaDir (false);
                            'I': informaDirecTrab;
                            'V': voltaPenultDir;
                            'O': reordena;
                            'P': trataPreferidos;
                            'A': begin
                                      vaiParaArquivos := true;
                                      c := ESC;
                                  end;

                            ^N : copiaTransfSelec (false);
                            ^C, ^X : begin
                                      copiaTransfSelec (true);
                                      moverObjetos := c = ^X;
                                  end;

                            ^V : begin
                                      copiaDirUsandoTransf (moverObjetos);
                                      moverObjetos:= false;
                                  end;

                            'Z': compactarDiretorio (nomeDir);
                            'X': tocaDir;

                            GOTFOCUS: ;
                            ESC: ;
                        else
                            begin
                                mensagem ('DV_OPCINV', 1);     { 'Opção inválida.' }
                                if not keypressed then
                                    mensagem ('DV_SEF1', 1);   { 'Aperte F1 para ajuda.' }
                            end;
                        end;

                        limpaBuf;
                        if not (c in [^S, ESC]) then
                            begin
                                writeln;
                                textBackground (RED);
                                if sintFalarTudo then
                                    mensagem ('DV_CONTSEL', 0)    { 'Continue selecionando ou tecle ESC' }
                                else
                                    write (pegaTextoMensagem('DV_CONTSEL')); { 'Continue selecionando ou tecle ESC' }
                                textBackground (BLACK);
                                writeln;
                            end;
                    end;
            end;
    until c = ESC;

    liberaListArq;

    getDir (0, dirFinal);
    if dirInicial <> DirFinal then
        penultSubDir := dirInicial;
    writeln;
end;

begin
end.
