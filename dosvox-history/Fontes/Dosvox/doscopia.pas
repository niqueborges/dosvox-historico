unit doscopia;
interface
uses windows, sysutils, classes, shellapi,
     dvcrt, dvwin, dvwav, dvmidi, dvform, dvarq,
     dosvars, dosgeral, dosmsg, minireg;

function temSelecionados: boolean;
function copiaUmArquivo (nomeArq: string; diret: string; movendo: boolean): boolean;
procedure fazCopias (posListArq: integer; var temQueRecriarLista: boolean);
function copiaRapidaLixeira (nomeArq: string): boolean;
procedure falaTamanhoArq (tam: int64; falarMensagemTamanho:boolean);
function selecDirDest (diratual: string; var diret: string): boolean;
procedure copiaUsandoTransf (movendo: boolean);
procedure mostraDadosArq (nomeArq: string; falaNomeArq, somenteData, somenteTamanho: boolean);
function copiaRapidaUm (nomeIn, nomeOut: string; movendo: boolean; out codErro: integer): boolean;

implementation

var
    nomeArqCorrente: string;

{--------------------------------------------------------}

function temSelecionados: boolean;
var i: integer;
begin
    temSelecionados := false;
    for i := 0 to listArquivos.count-1 do
        if PMySearchRec(listArquivos[i]).marcado then
            begin
                temSelecionados := true;
                exit;
            end;
end;

{--------------------------------------------------------}
{       copiar ou mover (com progresso) um arquivo
{--------------------------------------------------------}

function CallBackProgresso (
            TotFileSize, TotBytesTransf, StreamSize, StreamBytesTransf: Int64;
            dwStreamNumber, dwCallbackReason: DWORD; hSourceFile, hDestFile: THandle;
            lpdata: pointer):  DWORD; stdcall;
begin
    result := PROGRESS_CONTINUE;

    if dwCallbackReason = CALLBACK_STREAM_SWITCH then
    begin
        inicializaProgresso (20, 1, 20, copiaFazSintClek, instrumentoEmCopiaDeArquivo);
        exit;
    end;

    {  dwCallbackReason = CALLBACK_CHUNK_FINISHED  }

    if not mostraProgresso (TotBytesTransf, TotFileSize) then
        result := PROGRESS_CANCEL;
end;

{--------------------------------------------------------}

function copiaRapidaUm (nomeIn, nomeOut: string; movendo: boolean; out codErro: integer): boolean;
var
    dir: string;
    cancela: BOOL;

begin
    getdir (0, dir);
    if dir[length(dir)] <> '\' then dir := dir + '\';

    if pos ('\', nomeIn)  = 0  then nomeIn  := dir + nomeIn;
    if pos ('\', nomeOut) = 0  then nomeOut := dir + nomeOut;

    if (nomeOut <> '') and (nomeOut[length(nomeOut)] = '\') then
        nomeOut := nomeOut + ExtractFileName (nomeIn);
    nomeIn := nomeIn + #0#0;
    nomeOut := nomeOut + #0#0;

    { CallBackProgresso responsável por inicalizaProgresso e finalizaProgresso }
    cancela := False;
    if movendo then
        result := MoveFileWithProgress (pchar(nomeIn), pchar(nomeOut),
                            @CallBackProgresso, nil,
                            MOVEFILE_COPY_ALLOWED or MOVEFILE_REPLACE_EXISTING)
    else
        result := CopyFileEx (pchar(nomeIn), pchar(nomeOut), @CallBackProgresso,
                            nil, @cancela, 0);
    codErro := GetLastError;
    finalizaProgresso;
end;

{--------------------------------------------------------}
{             seleciona diretório de destino
{--------------------------------------------------------}

function selecDirDest (diratual: string; var diret: string): boolean;
var
    n, p, nprefs: integer;
    c: char;
    s: string;
    dir: array [1..50] of string;
    np: integer;

const
    SearchTree = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\';

begin
    selecDirDest := false;

    mensagem ('DV_INFDEST', 1);     { 'Informe o diretório destino: ' }
    c := sintEdita (diret, wherex, wherey, 255, true);
    if c = ESC then
        begin
            mensagem ('DV_OPCANCEL', 1);    { 'Certo, operação foi cancelada' }
            exit;
        end;

    if (c = CIMA) or (c = BAIX) or (c = F9) then
        begin
            writeln;
            nprefs := 0;
            for n := 1 to 50 do
                begin
                    s := sintAmbiente ('PREFERIDOS', 'DIRPREF' + intToStr (n));
                    if s <> '' then nprefs := nprefs + 1;
                end;

             popupMenuCria (49, wherey, 50, nprefs, RED);
             np := 0;
             for n := 1 to 50 do
                 begin
                     s := sintAmbiente ('PREFERIDOS', 'DIRPREF' + intToStr (n));
                     if s <> '' then
                         begin
                             np := np + 1;
                             p := pos (',', s);
                             dir [np] := copy (s, 1, p-1);
                             popupMenuAdiciona ('', copy (s, p+1, 99));
                         end;
                 end;

             popupMenuOrdena;
             n := popupMenuSeleciona;
             if n > 0 then
                 diret := dir [n]
             else
                 diret := '';
         end;

     if diret = '' then
         begin
             mensagem ('DV_DESIST', 1);     {'Desistiu...'}
             exit;
         end;

    if dirAtual = '' then getdir (0, diratual);

    if (diret <> '') and (diret[1] = '*') then
        begin
            delete (diret, 1, 1);
            if upperCase(diret) = 'DOWNLOADS' then diret := '{374DE290-123F-4565-9164-39C4925E467B}';
            if not regGetString (HKEY_CURRENT_USER, SearchTree+diret, diret) then
                diret := '@@@'
        end;

    if uppercase(diret) = '@@\DOSVOX' then diret := getDirConfigs;

    {$I-} chdir (diret);  {$I+}
    if ioresult <> 0 then
        begin
            limpaBuf;
            mensagem ('DV_ERRDIRNA', 1);    { 'Erro: este diretório não está acessível' }
            {$I-} chdir (diratual);  {$I+}
            if ioresult <> 0 then;
            exit;
        end;

    getdir (0, diret);
    {$I-}  chdir (diratual);  {$i+}
    if ioresult <> 0 then;

    if diret = diratual then
        begin
            mensagem ('DV_NAOPOD', 1);      { 'O arquivo não pode ser copiado sobre si mesmo !' }
            exit;
        end;

    if diret [length(diret)] <> '\' then
        diret := diret + '\';

    selecDirDest := true;
end;

{--------------------------------------------------------}
{                mostra dados de arquivo
{--------------------------------------------------------}

procedure mostraDadosArq (nomeArq: string; falaNomeArq, somenteData, somenteTamanho: boolean);
var
    s: string;
    dt: TdateTime;
    srec: TSearchRec;
begin
    if (not somenteData) and (not somenteTamanho) and falaNomeArq then
        sintWriteln (nomeArq);
    if (FindFirst(nomeArq, faAnyFile, srec) <> 0) then
        begin
            mensagem ('DV_DINDISP', 1);     {'Dado não disponível'}
            exit;
        end;

    if (fileGetAttr (nomeArq) and faReadOnly) <> 0 then
         mensagem ('DV_PROTEG', 1);     { 'Arquivo está protegido para regravação' }

    if not somenteData then
        falaTamanhoArq (srec.Size, sintFalarTudo);
    writeln;
    if somenteTamanho then exit;

    if (not somenteData) and sintFalarTudo then
        mensagem ('DV_DATACRI', 0);     { 'Data de criação: ' }
    dt := FileDateToDateTime(srec.Time);
    s := dateTimeToStr (dt);
    delete (s, pos(' ', s), 99);
    sintWriteln (s);

    if (not somenteData) and sintFalarTudo then
        mensagem ('DV_HORACRI', 0);     { 'Hora de criação: ' }
    s := dateTimeToStr (dt);
    delete (s, 1, pos(' ', s));
    delete (s, length (s)-2, 3);
    sintWriteln (s);

    findClose (srec);
end;

{--------------------------------------------------------}
{                   replica um arquivo
{--------------------------------------------------------}

procedure replicaArquivo (posListArq: integer);
var
    novoNome: string;
    c: char;
    arqOut: file;
    cor: integer;
    codErro: integer;

label repergunta;
begin
    mensagem ('DV_NOMECOP', 1);     { 'Informe nome do arquivo replica: ' }
    novoNome := nomeArqCorrente;
    c := sintEditaCampo (novoNome, wherex, wherey, 255, 80, true);
    writeln;
    if (novoNome = '') or (novoNome = nomeArqCorrente) or (c = ESC) then
        begin
            mensagem ('DV_DESIST', 2);      {'Desistiu...'}
            exit;
        end;

    writeln (novoNome);
    if maiuscAnsi (novoNome) = maiuscAnsi (trim (nomeArqCorrente)) then
        begin
            limpaBuf;
            mensagem ('DV_NOMEINV', 1);     { 'Esse nome que voce escolheu não é valido.' }
            exit;
        end;

    assignFile (arqout, novoNome);
    {$I-} reset (arqout, 1); {$I+}
    if ioresult = 0 then
        begin
            {$I-} closeFile (arqout); {$I+}
            if ioresult <> 0 then;

            if sintFalarTudo then mensagem ('DV_ARQEXIS1', 0);    { 'Arquivo destino '}
repergunta:
            sintetiza (novoNome);
            mensagem ('DV_ARQEXIS2', 0);    { ' já existe.  Sobrescreve (S/N/T/ESC)? '}
            c := popupMenuPorLetra('SNTDH');
            writeln;

            if c in ['D', 'H', ^D] then
                begin
                    if c = ^D then c := 'H';
                    cor := textAttr;
                    textColor (yellow);
                    if sintFalarTudo then mensagem ('DV_DARQEXIS', 1);    {'Dados do arquivo existente'}
                    mostraDadosArq (nomeArqCorrente, true, c = 'H', false);
//Neno                    mensagem ('DV_DARQNOVO', 1);    {'Dados do novo arquivo'}
                    if sintFalarTudo then mensagem ('DV_ARQEXIS1', 1)    {'Arquivo destino '}
                    else mensagem ('DV_DESTINO', 1);    {'Destino '}
                    mostraDadosArq (novoNome, true, c = 'H', false);
                    sintBip; sintBip;
                    textAttr := cor;
                    goto repergunta;
                end;

            if not (c in ['S', 'T', ENTER]) then exit;
        end;

    if not copiaRapidaUm (nomeArqCorrente, novoNome, false, codErro) then
        begin
            mensagem ('DV_ERRARQ_NOK', 1);    { 'Operação não completada.' }
            mensagem (mensErroArquivo(codErro), 1);
            {$I-} erase (arqout); {$i+}
            if ioresult <> 0 then;
        end
    else
        begin
            sintWrite (novoNome);
            mensagem ('DV_FOIREPL', 1);     { ' foi replicado.' }
        end;
end;

{--------------------------------------------------------}
{                 funções de arquivos
{--------------------------------------------------------}

procedure falaTamanhoArq (tam: int64; falarMensagemTamanho: boolean);
var
    medida: string;
    decimal: int64;
begin
    medida := '';
    if tam >= 65536 then
        begin
            medida := 'K';
            decimal := tam mod 1024;
            tam := tam div 1024;
            if decimal > 512 then tam := tam + 1;
        end;
    if tam >= 65536 then
        begin
            medida := 'MB';
            decimal := tam mod 1024;
            tam := tam div 1024;
            if decimal > 512 then tam := tam + 1;
        end;

    if falarMensagemTamanho then
        mensagem ('DV_TAMANHO', 0);     {'Tamanho: '}
    if tam = 0 then
        begin
            write ('0');
            sintCarac ('0')     { corrige erro no sintetizador L&H }
        end
    else
        sintWrite (intToStr (tam) + medida);
end;

{--------------------------------------------------------}
{            copia um arquivo para outro diretório
{--------------------------------------------------------}

function copiaUmArquivo (nomeArq: string; diret: string; movendo: boolean): boolean;
var
    novoNome: string;
    c: char;
    cor: integer;
    codErro: integer;
begin
    copiaUmArquivo := true;
    novoNome := diret+ExtractFileName(nomeArq);
    if maiuscAnsi (novoNome) = maiuscAnsi (trim (nomearq)) then
        begin
            limpaBuf;
            mensagem ('DV_NOMEINV', 1);     { 'Esse nome que voce escolheu não é valido.' }
            exit;
        end;

    if keypressed then     { cancelamento }
        begin
            c := readkey;
            if c = #$1b then
                begin
                    mensagem ('DV_DESIST', 1);      {'Desistiu...'}
                    copiaUmArquivo := false;
                    exit;
                end
            else
                if c = ' ' then copiaMuda := not copiaMuda;
        end;

    if (not podeSobrescrever) and fileExists (novoNome) then
        begin
            if naoParaTodos then
                begin
                    if not copiaMuda then sintBip;
                    exit;
                end;
            if sintFalarTudo then mensagem ('DV_ARQEXIS1', 0);    { 'Arquivo destino ' }
            repeat
                sintetiza (novoNome);
                mensagem ('DV_ARQEXIS2', 0);    {' já existe.  Sobrescreve (S/N/T/ESC)? '}
                c := popupMenuPorLetra('SNTPDH');
                writeln;

                if c in ['D', 'H', ^D] then
                    begin
                        if c = ^D then c := 'H';
                        cor := textAttr;
                        textColor (yellow);
                        if sintFalarTudo then mensagem ('DV_DARQEXIS', 1);    {'Dados do arquivo existente'}
                        mostraDadosArq (nomeArq, true, c = 'H', false);
//Neno                        mensagem ('DV_DARQNOVO', 1);    {'Dados do novo arquivo'}
                    if sintFalarTudo then mensagem ('DV_ARQEXIS1', 1)    {'Arquivo destino '}
                    else mensagem ('DV_DESTINO', 1);    {'Destino '}
                        mostraDadosArq (novoNome, true, c = 'H', false);
                        sintBip; sintBip;
                        textAttr := cor;
                    end
                else
                if not (c in ['S', 'N', 'T', 'P', ESC, ENTER]) then
                    mensagem ('DV_AJUTIL', 1);  {'  Pode usar as setas para selecionar ou conhecer todas as opções'}
            until c in ['S', 'N', 'T', 'P', ESC, ENTER];

            if c = 'T' then podeSobrescrever := true
            else
            if c in ['N', 'P'] then
                begin
                    if c = 'P' then naoParaTodos := true;
                    if not copiaMuda then sintBip;
                    exit;
                end;

            if c = ESC then
                begin
                    copiaUmArquivo := false;
                    exit;
                end;
        end;

    if not copiaRapidaUm (nomearq, novoNome, movendo, codErro) then
         begin
            mensagem ('DV_ERRARQ_NOK', 1);   {'Operação não completada.'}
            mensagem (mensErroArquivo(codErro), 1);
            copiaUmArquivo := false;
            exit;
         end
    else
        begin
            write (nomearq);
            if copiaMuda then
                writeln
            else
                begin
                    sintetiza (nomearq);
                    if movendo then
                        mensagem ('DV_MOVIDO', 1)   { ' movido.' }
                    else
                        mensagem ('DV_COPIADO', 1); { ' copiado.' }
                end;
        end;
end;

{--------------------------------------------------------}
{            copia arquivos para outro diretório
{--------------------------------------------------------}

procedure copiaArquivos (posListArq: integer; diret: string; movendo, copiaTodos: boolean);
var
    i: integer;
    nome: string;
    copiaSelecionados: boolean;
    c: char;
begin
    copiaSelecionados := false;
    if (not copiaTodos) and temSelecionados then
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
    copiaMuda := not sintFalarTudo;
    if not (copiaTodos or copiaSelecionados) then
        begin
            nome := PMySearchRec(listArquivos[posListArq]).sr.FindData.cFileName;
            copiaUmArquivo (nome, diret, movendo);
        end
    else
        begin
            for i := 0 to listArquivos.count-1 do
                 if copiaTodos or (PMySearchRec(listArquivos[i]).marcado) then
                    begin
                        nome := PMySearchRec(listArquivos[i]).sr.FindData.cFileName;
                        if not copiaUmArquivo (nome, diret, movendo) then
                             break;
                    end;
        end;

    if wherex <> 1 then writeln;
    if not sintFalarTudo then sintclek;
end;

{--------------------------------------------------------}
{           seleciona a função com as setas
{--------------------------------------------------------}

function selSetasCopia: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var n: integer;
const
    tabLetrasCopia: string [9] = 'rdmt';

begin
    popupMenuCria (35, wherey, 44, 4, RED);
    MenuAdiciona ('DV_AJUAC_R');    {'  R - criar réplica de um arquivo'}
    MenuAdiciona ('DV_AJUAC_D');    {'  D - copiar arquivos para outro diretório'}
    MenuAdiciona ('DV_AJUAC_M');    {'  M - mover arquivos para outro diretório'}
    MenuAdiciona ('DV_AJUAC_T');    {'  T - copiar todos'}

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasCopia := tabLetrasCopia[n]
    else
        selSetasCopia := ESC;
end;

{--------------------------------------------------------}
{                       ajuda
{--------------------------------------------------------}

procedure ajudaCopia;
begin
    writeln;
    mensagem ('DV_AJUAC_OPC', 1);   {'As opções de cópia de arquivos são:'}
    mensagem ('DV_AJUAC_R', 1);     {'  R - criar réplica de um arquivo'}
    mensagem ('DV_AJUAC_D', 1);     {'  D - copiar arquivos para outro diretório'}
    mensagem ('DV_AJUAC_M', 1);     {'  M - mover arquivos para outro diretório'}
    mensagem ('DV_AJUAC_T', 1);     {'  T - copiar todos'}

    while keypressed do readkey;
end;

{--------------------------------------------------------}
{                  joga arquivos na lixeira
{--------------------------------------------------------}

function copiaRapidaLixeira (nomeArq: string): boolean;
var
    dirLixeira: string;
    err: integer;
begin
    dirLixeira := sintAmbiente ('DOSVOX', 'DIRLIXEIRA');
    if dirLixeira = '' then dirLixeira := 'c:\recycled';
    if dirLixeira [length(dirLixeira)] <> '\' then
       dirLixeira := dirLixeira + '\';

    podeSobrescrever := true;
    naoParaTodos := false;
    copiaRapidaLixeira := copiaRapidaUm (nomeArq, dirLixeira, true, err);
end;

{--------------------------------------------------------}
{                  copias de arquivos
{--------------------------------------------------------}

procedure fazCopias (posListArq: integer; var temQueRecriarLista: boolean);
var
    c, c2: char;
    nomeDir: string;
label inicio, interpreta;

begin
    temQueRecriarLista := false;
    nomeArqCorrente := PMySearchRec(listArquivos[posListArq]).sr.FindData.cFileName;
inicio:
    limpaBuf;
    textBackground (MAGENTA);
    mensagem ('DV_TIPOCOP', 0);     { 'Qual o tipo de cópia ? ' }
    textBackground (BLACK);

    pegaTeclado (c, c2);

    if c = #$1b then
        begin
            writeln;
            mensagem ('DV_OK', 1);      { 'Ok ! '}
            exit;
        end;

    if c = #0 then
        if c2 = F1 then
            begin
                ajudaCopia;
                goto inicio;
            end
        else
        if (c2 = CIMA) or (c2 = BAIX) or (c2 = F9) then
            begin
                c := selSetasCopia;
                writeln;
                goto interpreta;
            end;

    if sintEcoarOpcao then
        begin
            mensagem ('DV_OPCAO', 0);   { ' opção ' }
            soletra (c, 1);
        end;

interpreta:
    case upcase (c) of
        'R': begin
                 replicaArquivo (posListArq);
                 temQueRecriarLista := true;
             end;
        'D': if selecDirDest ('', nomeDir) then
                 copiaArquivos (posListArq, nomeDir, false, false);
        'M': if selecDirDest ('', nomeDir) then
                 begin
                     copiaArquivos (posListArq, nomeDir, true, false);
                     temQueRecriarLista := true;
                 end;
        'T': if selecDirDest ('', nomeDir) then
                     copiaArquivos (posListArq, nomeDir, false, true);
    else
        begin
             mensagem ('DV_OPCINV', 1);     { 'Opção inválida.' }
             mensagem ('DV_SEF1', 1);       { 'Aperte F1 para ajuda.' }
        end;
    end;
end;

{--------------------------------------------------------}

procedure copiaUsandoTransf (movendo: boolean);
var dirAtual: string;
    fos: TSHFileOpStruct;
    copias: array [0..65535] of char;

    procedure pegaClipboard;
    var p1, p2: pchar;
        i: integer;
        s: string;
    begin
        getClipBoard(copias, 65535);
        p1 := copias;
        p2 := copias;
        while p1^ <> #$0 do
            begin
                s := '';
                while (p1^ <> #$0d) and (p1^ <> #$0a) and (p1^ <> #$0) do
                    begin
                        s := s + p1^;
                        inc(p1);
                    end;

                if s <> '' then
                    begin
                        for i := 1 to length (s) do
                            begin
                                p2^ := s[i];
                                inc (p2);
                            end;
                        p2^ := #$0;
                        inc (p2);
                    end;

                if p1 <> #$0 then
                    inc (p1);
            end;
        p2^ := #$0;
    end;


begin
    ZeroMemory(@fos, SizeOf(fos));
    with fos do
        begin
            if movendo then
                wFunc := FO_MOVE
            else
                wFunc  := FO_COPY;
            fFlags := FOF_SILENT or FOF_NOERRORUI or FOF_NOCONFIRMATION;
            pegaClipboard;
            pFrom  := copias;
            getDir (0,dirAtual);
            pTo    := @dirAtual[1];
        end;

    if ShFileOperation(fos) = 0 then
         begin
             if movendo then
             mensagem ('DV_MOVIDO', 1)      { ' movido.' }
             else
             mensagem ('DV_COPIADO', 1);    { ' copiado.' }
         end
    else
         begin
             sintbip;
             mensagem ('DV_ERRCOPIA', 1);   { 'Sinto muito, deu erro no disco, portanto não copiei.' }
         end;
end;

{--------------------------------------------------------}

begin
end.
