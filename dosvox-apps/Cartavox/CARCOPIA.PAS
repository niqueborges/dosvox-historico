{-------------------------------------------------------------}
{
{          cartaVox - rotinas de copia e remoção de arquivos
{
{-------------------------------------------------------------}

unit carcopia;

interface

uses
    classes,
    dvarq,
    dvcrt,
    dvform,
    dvwin,
    sysutils,
    windows,
    miniReg,
    carEst,
    carDecod,
    carmsg,
    carTela,
    carutil,
    carVars;

function fazCopias (posListArq: integer; dirAtual: string): integer;
function copiaLixeira (nomeArq: string): boolean;
function copiaUm (nomeIn, nomeOut: string): boolean;
function moveParaDirSpam (nCar: integer): boolean;
function apagaCarta (nCar: integer; enviarLixeira: boolean): boolean;
function removerCarta (nCar: integer; enviarLixeira, apagarTodas, apertouShift: boolean): integer;
function tiraCopia (nomeOrig: string): boolean;
function selecDirDest (var diret: string): boolean;

var
    podeSobrescrever, adicionar, mudo: boolean;

implementation
uses carEnvia, carRegras;

var
    nomeArq: string;

{--------------------------------------------------------}
{       copia um arquivo
{--------------------------------------------------------}

{               Esta rotina recebe os nomes dos arquivos já assinalados }

function copiaUm (nomeIn, nomeOut: string): boolean;
const
    BUFSIZE = 56*1024;

var
    tam: int64;
    nbytes, ntransf: integer;
    buf: pchar;
    erro: word;
    deuProblema: boolean;
    arqin: integer;
    arqout: file;
    fant, fnovo: integer;
    lidos: integer;

label fim;
begin
    copiaUm := false;
    deuProblema := true;

    arqin := FileOpen(nomeIn, fmOpenRead or fmShareDenyNone);
    if arqin < 0 then exit;
    assignFile (arqout, nomeOut);
    {$I-} rewrite (arqout, 1); {$I+}
    if ioresult <> 0 then
        begin
            fileClose (arqin);
            exit;
        end;

    getmem (buf, BUFSIZE);

    tam := FileSeek(arqin, 0, 2);
    fileSeek (arqin, 0, 0);
    while tam > 0 do
        begin
            nbytes := BUFSIZE;
            if tam < BUFSIZE then nbytes := tam;

            lidos := fileRead (arqin, buf^, nbytes);
            if lidos <> nbytes then
                begin
                    limpaBufTec;
                    msgBaixo ('CTERRLEI');      {Houve um erro de leitura no arquivo original.}
                    goto fim;
                end;

            {$I-} blockwrite (arqout, buf^, nbytes, ntransf); {$I+}
            erro := ioresult;
            if ntransf <> nbytes then
                begin
                    limpaBufTec;
                    msgBaixo ('CTFALESP');      {'Não existia espaco suficiente para escrever.'}
                    goto fim;
                end
            else
                if erro <> 0 then
                    begin
                        limpaBufTec;
                        msgBaixo ('CTERRDSK');  {'Não consegui escrever este arquivo.'}
                        goto fim;
                    end;


            tam := tam - BUFSIZE;
        end;

    copiaUm := true;
    deuProblema := false;

fim:
    freemem (buf, BUFSIZE);

    fileClose (arqin);
    {$I-} closeFile (arqout); {$I+}
    if ioresult <> 0 then
        begin
            copiaUm := false;
            deuProblema := true;
        end;

    if deuProblema then
        begin
            {$I-}  erase (arqout);  {$I+}
            if ioresult <> 0 then;
        end
    else
        begin
            fant := fileOpen (nomeIn, fmOpenRead);
            fnovo := fileOpen (nomeOut, fmOpenReadWrite);
            if (fant <> -1) and (fnovo <> -1) then
                FileSetDate (fnovo, FileGetDate(fant));
            if fant <> -1  then fileClose (fant);
            if fnovo <> -1 then fileClose (fnovo);
        end;
end;

{--------------------------------------------------------}
{       seleciona diretório de destino
{--------------------------------------------------------}

function selecDirDest (var diret: string): boolean;
var diratual: string;
    n, p, nprefs: integer;
    c: char;
    s: string;
    dir: array [1..50] of string;
    np: integer;

const
    SearchTree = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\';

begin
    selecDirDest := false;

    mensagem ('CTINFDDS', 1);    {'Informe o diretório destino: '}
    c := sintEdita (diret, wherex, wherey, 255, true);
    writeln;
    if c = ESC then
        begin
            msgBaixo ('CTCANCG');   {'Certo, operação foi cancelada'}
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

             popupMenuCria (49, wherey, 30, nprefs, RED);
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
             mensagem ('CTDESIST', 1);  {'Desistiu...'}
             exit;
         end;

    getdir (0, diratual);

    if (diret <> '') and (diret[1] = '*') then
        begin
            delete (diret, 1, 1);
            if upperCase(diret) = 'DOWNLOADS' then diret := '{374DE290-123F-4565-9164-39C4925E467B}';
            if not regGetString (HKEY_CURRENT_USER, SearchTree+diret, diret) then
                diret := '@@@';
        end;

    {$I-} chdir (diret);  {$I+}
    if ioresult <> 0 then
        begin
            limpaBufTec;
            msgBaixo ('CTERRODI');        {'Erro: este diretório não está acessível'}
            {$I-} chdir (diratual);  {$I+}
            if ioresult <> 0 then;
            exit;
        end;

    getdir (0, diret);
    {$I-}  chdir (diratual);  {$i+}
    if ioresult <> 0 then;

    if diret [length(diret)] <> '\' then
        diret := diret + '\';

    selecDirDest := true;
end;

{-------------------------------------------------------------}
{       Seleciona a conta de destino
{-------------------------------------------------------------}

function selecConfigDest (var dirEt: string): boolean;
var
    nomes: array [0..1000] of char;
    p: pchar;
    nnomes, tam: integer;
    nomeConfig, dirAtual: string;
begin
    selecConfigDest := false;
    tam := getprivateProfileString (NIL, NIL, '', nomes, 1000, PChar(cartavoxConfigs));
    p := nomes;
    if (tam >= 1) and (p^ = #$0) then p := p + 1;   {evita falha em cartavox.ini com erro}

    nnomes := 0;
    while p^ <> #$0 do
        begin
            nnomes := nnomes + 1;
            p := p + strlen(p) + 1;
        end;

    p := nomes;
    if (tam >= 1) and (p^ = #$0) then p := p + 1;

    if nnomes = 0 then
        begin
            mensagem ('CTCNFNAO', 1); {'Configuração não achada'}
            exit;
        end;

    mensagem ('CTSETCON', 2); {'Escolha com as setas a configuração'}
    if not keypressed then delay (300);
    popupMenuCria (wherex, wherey, 79-wherex, nnomes, MAGENTA);
    while p^ <> #$0 do
        begin
            popupMenuAdiciona ('', maiuscansi(strPas(p)));
            p := p + strlen(p) + 1;
        end;

    popupMenuOrdena;
    popupMenuSeleciona;
    nomeConfig := trim(opcoesItemSelecionado);
    if nomeConfig = '' then
        begin
            mensagem ('CTDESIST', 1);  {'Desistiu...'}
            exit;
        end;
    if folheiaRecebidas then
        dirEt := sintAmbienteArq (nomeConfig, 'DIRRECEBE', '', cartavoxConfigs)
    else
        dirEt := sintAmbienteArq (nomeConfig, 'DIRENVIA', '', cartavoxConfigs);

if not existeDir (dirEt) then
        begin
            mensagem ('CTERRODI', 1); {'Erro: este diretório não está acessível'}
            exit;
        end;
    getdir (0, diratual);
    if dirEt = dirAtual then
        begin
            mensagem ('CTNAOPOD', 1); {'O arquivo não pode ser copiado sobre si mesmo !'}
            exit;
        end;

    if diret [length(diret)] <> '\' then
        diret := diret + '\';
    selecConfigDest := true;
end;

{--------------------------------------------------------}
{       replica um arquivo
{--------------------------------------------------------}

procedure replicaArquivo;
var
    novoNome: string;
    c: char;
    arqOut: file;
begin
    mensagem ('CTINFDST', 1);  {'Informe o nome completo do arquivo destino:'}
    sintReadln (novoNome);
    if novoNome = '' then
        begin
            msgBaixo ('CTDESIST'); {'Desistiu'}
            exit;
        end;

    if (maiuscAnsi (novoNome) = maiuscAnsi (trim (nomearq))) or
    (novoNome[length(novoNome)] = '\') or (novoNome[length(novoNome)] = '/') then
        begin
            limpaBufTec;
            msgBaixo ('CTATAINV'); {'Nome de arquivo inválido'}
            exit;
        end;

    assignFile (arqout, novoNome);
    {$I-} reset (arqout, 1); {$I+}
    if ioresult = 0 then
        begin
            close (arqout);
            mensagem ('CTJAEXI1', 0); {'O arquivo destino'}
            writeln (' ' + novoNome);
            delay (100);
            sintetiza (novoNome);
            delay (100);
            mensagem ('CTJAEXI2', 0); {'já existe.  Sobrescreve (S/N/T/ESC)? '}
            c := upcase(popupMenuPorLetra ('SNT'));
            writeln;
            if (c = 'N') or (c = ESC) then exit;
        end;

    if not copiaUm (nomeArq, novoNome) then
        begin
            msgBaixo ('CTERRDSK');  {'Erro de escrita no disco'}
            {$I-} erase (arqout); {$i+}
            if ioresult <> 0 then;
        end
    else
        begin
            sintWrite (novoNome);
            msgBaixo ('CTFOICOP'); {' Copiado'}
        end;
end;

{--------------------------------------------------------}
{       copia um arquivo para outro diretório
{--------------------------------------------------------}

function copiaUmArquivo (posListArq: integer; diret: string; movendo: boolean): boolean;
var
    nomeArq, novoNome, s: string;
    arqin, arqOut: file;
    resulta, resulta2: integer;
    c: char;

label trocaNome;

begin
    copiaUmArquivo := true;

    nomeArq := regLido [posListArq]^.carta^.nomArqCarta;
    novoNome := diret+ nomeArq;

    if maiuscAnsi (novoNome) = maiuscAnsi (trim (nomearq)) then
        begin
            limpaBufTec;
            msgBaixo ('CTATAINV'); {'Nome de arquivo inválido'}
            exit;
        end;

    if pos ('M.', novoNome) <> 0 then
        s := copy (novoNome, 1, pos ('.', novoNome)-2) + copy (novoNome, pos ('.', novoNome), length (novoNome))
    else
        s := copy (novoNome, 1, pos ('.', novoNome)-1) + 'M.' + copy (novoNome, pos ('.', novoNome)+1, length (novoNome));
    assign (arqout, s);
    {$I-} reset (arqout, 1);  {$I+}
    resulta := ioresult;
    {$I-} close (arqout);  {$I+}
    if ioresult <> 0 then ;

    assign (arqout, novoNome);
    {$I-} reset (arqout, 1); {$I+}
    resulta2 := ioresult;
    {$I-} close (arqout);  {$I+}
    if ioresult <> 0 then ;

trocaNome:
    if ((resulta = 0) or (resulta2 = 0)) and (not podeSobrescrever) then
    if adicionar then
        begin
            if pos ('M.', novoNome) <> 0 then
                s := copy (nomeArq, pos ('.', nomeARq)-1, length (nomeArq))
            else
                s := copy (nomeArq, pos ('.', nomeARq), length (nomeArq));
            novoNome := novoNomeCarta (nbaseCopia, diret,s);
            assign (arqout, novoNome);
        end
    else
        begin
            mensagem ('CTJAEXI1', 0); {'O arquivo destino'}
            write (' ' + nomeArq + ' ');
            delay (100);
            sintetiza (nomearq);
            delay (100);
            mensagem ('CTJAEXI2', 1); {'já existe.  Sobrescreve (S/N/T/ESC)? '}
            mensagem ('CTADICIO', 0);     {'Tecle A para Adicionar todos'}
            c := upcase(popupMenuPorLetra ('SNTA'));
            writeln;
            if c = 'A' then
                begin
                    adicionar := true;
                    goto trocaNome;
                end
            else
            if c = 'N' then exit
            else
            if c = 'T' then podeSobrescrever := true
    else
            if c = ESC then
                begin
                    copiaUmArquivo := false;
                    exit;
                end;
        end;

    if not copiaUm (nomeArq, novoNome) then
        begin
            msgBaixo ('CTERRDSK'); {'Erro de escrita no disco'}
            copiaUmArquivo := false;
            exit;
        end
    else
        begin
            writeln (nomearq);
            if not mudo then
                begin
                    sintetiza (nomearq);
                    if movendo then
                        mensagem ('CTFOIMOV', 1) {'Movido'}
                    else
                        mensagem ('CTFOICOP', 1); {'Copiado'}
                    if adicionar and (novoNome <> (diret+nomeArq)) then
                        begin
                            novoNome := copy (novoNome, length (dirEt) + 1, length (novoNome));
                            mensagem ('CTCOMONO', 0); {'com o nome'}
                            writeln (' '+novoNome);
                            delay (100);
                            sintetiza (novoNome);
                            delay (100);
                        end;
                end;

            if movendo then
                begin
                    assignFile (arqin, nomeArq);
                    {$I-} erase (arqin);  {$I+}
                    if ioresult <> 0 then
                        mensagem ('CTNAOAPO', 1);  {'Não pude apagar o arquivo original'}
                end;
        end;

    if keypressed then     { cancelamento }
        begin
            c := readkey;
            if c = #$1b then
                begin
                    msgBaixo ('CTDESIST'); {'Desistiu ...'}
                    copiaUmArquivo := false;
                    exit;
                end
            else
            if c = ' ' then mudo := not mudo
            else quantasCartasDoTotal (posListArq, numRegs);
        end;

end;

{--------------------------------------------------------}
{       copia arquivos para outro diretório
{--------------------------------------------------------}

function copiaArquivos (posListArq: integer; diret: string; movendo, copiaTodos: boolean): integer;
var
    c: char;
    i, numRegsAux, nCarSaida: integer;
    viAux: array [1..MAXCARTAS] of integer;
    copiaSelecionados: boolean;
begin
    copiaArquivos := posListArq;
    copiaSelecionados := false;
    if (not copiaTodos) and temItemSelecionado then
        begin
            mensagem ('CTCOPSEL', 0);   {'Copia todas as selecionadas? '}
            c := upcase(popupMenuPorLetra ('SN'));
            writeln;
            if c = ESC then
                begin
                    mensagem ('CTDESIST', 2);   {'Desistiu'}
                    exit;
                end;
            copiaSelecionados := c = 'S';
        end;

    podeSobrescrever := false;
    adicionar := false;
    mudo := false;
    nCarSaida := posListArq;
    if not (copiaTodos or copiaSelecionados) then
        begin
            copiaUmArquivo (posListArq, diret, movendo);
            if movendo then
                begin
                    apagaUmRegs (posListArq);
                    nCarSaida := nCarSaida-1;
                end;
        end
    else
        begin
            numRegsAux := 0;
            for i := 1 to numRegs do
                if copiaTodos or (regLido [i]^.selecionado) then
                    begin
                        if not copiaUmArquivo (i, diret, movendo) then break;
                        if movendo then
                            begin
                                regLido[i]^.carta^.partesCarta.free;
                                dispose (regLido [i]);
                            end;
                    end
                else
                if movendo then
                    begin
                        numRegsAux := numRegsAux + 1;
                        viAux[numRegsAux] := i;
                    end;

            if movendo and (numRegsAux > 0) then
                begin
                    if i < numRegs then
                        while i <= numRegs do
                            begin
                                numRegsAux := numRegsAux + 1;
                                viAux[numRegsAux] := i;
                                i := i + 1;
                            end;

                    for i := 1 to numRegsAux do
                        begin
                            regLido[i] := regLido[viAux[i]];
                            if posListArq = viAux[i] then
                                nCarSaida := i
                            else
                            if viAux[i] < posListArq then
                                nCarSaida := i;
                        end;
                end;

            if movendo then
                numRegs := numRegsAux;
        end;
    copiaArquivos := nCarSaida;

    if keypressed then readkey;
end;

{--------------------------------------------------------}
{       Adiciona o texto do arquivo a outro já existente
{--------------------------------------------------------}

procedure adicionaArquivo (nCar, quantos: integer; dirAtual: string);
var
    s: string;
    arqin, arqout: text;
    c: char;
    adicionarSelecionados, todosArquivos: boolean;
    numAdicionados: integer;

label fim;

begin
    mensagem ('CTINFDST', 1); {'Informe o nome completo do arquivo destino:'}
    garanteEspacoTela (5);
    nomeArq := obtemNomeArq (5);
    Writeln;
    if trim (nomeArq) = '' then
        begin
            msgBaixo ('CTDESIST');  {'Desistiu...'}
            exit;
        end;

    if pos ('.', nomeArq) = 0 then nomeArq := nomeArq + '.txt';
    if (pos ('\', nomeArq) = 0) and (pos ('/', nomeArq) = 0) then
        nomeArq := dirAtual + '\' + nomeArq;

    assign (arqout, nomearq);
    {$I-} append (arqout);  {$i+}
    if ioresult <> 0 then
        begin
            repeat
                mensagem ('CTARQNDC', 0); {'Arquivo não existe, deseja cria-lo? '}
                c := upcase(popupMenuPorLetra ('SN'));
                writeln;
            until c in ['S', 'N', ENTER, ESC];
            if c in ['N', ESC] then
                begin
                    msgBaixo ('CTDESIST');  {'Desistiu...'}
                    exit;
                end;
            {$I-} rewrite (arqout);  {$i+}
            if ioresult <> 0 then
                begin
                    mensagem ('CTERRDSK', 1);  {'Erro de escrita no disco'}
                    exit;
                end;
        end;

    adicionarSelecionados := false;

    if (quantos = 1) and temItemSelecionado then
        begin
            repeat
                mensagem ('CTADISEL', 0);   {'Deseja adicionar todas as selecionadas? '}
                c := upcase(popupMenuPorLetra ('SN'));
                writeln;
            until upcase (c) in ['S', 'N', ENTER, ESC];
            if c = ESC then
                begin
                    mensagem ('CTDESIST', 2);   {'Desistiu'}
                    exit;
                end;
            adicionarSelecionados := c in ['S', ENTER];
        end;

    if quantos > 1 then todosArquivos := true
    else todosArquivos := false;

    if todosArquivos or adicionarSelecionados then
        nCar := 1;
    if adicionarSelecionados then
        quantos := numRegs;

    numAdicionados := 0;
    repeat
        if not (todosArquivos or (regLido [nCar]^.selecionado) or (quantos = 1)) then
            begin
                nCar := nCar + 1;
                continue;
            end;

        numAdicionados := numAdicionados + 1;
        if not adicionaOriginal then
            begin
                if preencheArqResposta (nCar, false, false, false, true, s) then;
                assign (arqin, s);
            end
        else
            begin
                carregaArqPreencheCabPrin (nCar);
                assign (arqin, regLido [nCar]^.carta^.nomArqCarta);
            end;
        {$I-} reset (arqin); {$I+}
        if ioresult <> 0 then
            begin
                mensagem ('CTERRLEI', 1);  {'Erro de leitura do arquivo'}
                {$I-} close (arqout); {$I+}
                if ioresult <> 0 then;
                exit;
            end;

        sintClek;
        {$I-} writeln (arqout, '');  {$I+}
    if ioresult <> 0 then
            begin
                mensagem ('CTERRDSK', 1);  {'Erro de escrita no disco'}
                goto fim;
            end;

        {$I-} writeln (arqout, '            Início da Carta');  {$I+}
        if ioresult <> 0 then;
        while not eof (arqin) do
            begin
                {$I-}  readln (arqin, s);  {$I+}
                if ioresult <> 0 then
                    begin
                        mensagem ('CTERRLEI', 1);  {'Erro de leitura do arquivo'}
                        goto fim;
                    end;
                {$I-} writeln (arqout, s); {$I+}
                if ioresult <> 0 then
                    begin
                        mensagem ('CTERRDSK', 1);   {'Erro de escrita no disco'}
                        goto fim;
                    end;
            end;
        {$I-} close (arqin); {$I+}
        if not adicionaOriginal then
            begin
                {$I-}  erase (arqin);  {$I+}
                if ioresult <> 0 then;
            end;

        nCar := nCar + 1;
    until nCar > quantos;
    sintWriteInt (numAdicionados); write (' ');
    mensagem ('CTFOICOP', 1); {' Copiado'}
fim:
    {$I-} close (arqin); {$I+}
    if ioresult <> 0 then;
    if not adicionaOriginal then
        begin
            {$I-}  erase (arqin);  {$I+}
            if ioresult <> 0 then;
        end;
    {$I-} close (arqout); {$I+}
    if ioresult <> 0 then;
end;

{--------------------------------------------------------}
{       seleciona a função com as setas
{--------------------------------------------------------}

function selSetasCopia: char;
var
    n, numOpc: integer;
const
    tabLetrasCopia: string [9] = 'cdmta' + ^A + ^D + #10 + ^R;
begin
    if folheiaRecebidas then numOpc := 9
    else numOpc := 8;
    popupMenuCria (35, wherey, 44, numOpc, RED);
    MenuAdiciona ('CTAJU52A'); {'     c - copiar a carta para um arquivo'}
    MenuAdiciona ('CTAJU53A');  {'    d - copiar carta para outro diretório'}
    MenuAdiciona ('CTAJU54A');  {'    m - mover'}
    MenuAdiciona ('CTAJU55A');  {'    t - copiar todas'}
    MenuAdiciona ('CTAJU56A');  {'    A - Adicionar a um arquivo'}
    MenuAdiciona ('CTAJU57');   {'    CTRL + A - Adicionar todas a um arquivo'}
    MenuAdiciona ('CTAJU58');  {'    CTRL + d - copiar carta para outra configuração'}
    MenuAdiciona ('CTAJU59');  {'    CTRL + m - mover para outra configuração'}
    if folheiaRecebidas then
        MenuAdiciona ('CTAJU60');  {'    CTRL + r - mover para pasta de regra'}

    n := popupMenuSeleciona;
    if (n > 0) and (n <= numOpc) then
        selSetasCopia := tabLetrasCopia[n]
    else
        selSetasCopia := ESC;
end;

{--------------------------------------------------------}
{       ajuda
{--------------------------------------------------------}

procedure ajudaCopia;
begin
    writeln;
    mensagem ('CTAJUD51', 1);  {'As opções de cópia de cartas são:'}
    mensagem ('CTAJU52A', 1); {'C - copiar a carta para um arquivo'}
    mensagem ('CTAJU53A', 1);  {'    d - copiar carta para outro diretório'}
    mensagem ('CTAJU54A', 1);  {'    m - mover'}
    mensagem ('CTAJU55A', 1);  {'    t - copiar todas'}
    mensagem ('CTAJU56A', 1);  {'    A - Adicionar a um arquivo'}
    mensagem ('CTAJU57', 1);  {'    CTRL + A - Adicionar todas a um arquivo'}
    mensagem ('CTAJU58', 1);  {'    CTRL + d - copiar carta para outra configuração'}
    mensagem ('CTAJU59', 1);  {'    CTRL + m - mover para outra configuração'}
    if folheiaRecebidas then
        mensagem ('CTAJU60', 1);  {'    CTRL + r - mover para pasta de regra'}

    limpaBuftec;
end;

{--------------------------------------------------------}
{       copias de arquivos
{--------------------------------------------------------}

function fazCopias (posListArq: integer; dirAtual: string): integer;
var
    c, c2: char;
    nomeDir: string;
label inicio;

begin
    fazCopias := posListArq;
    nomeArq := regLido [posListArq]^.carta^.nomArqCarta;
inicio:
    limpabufTec;
    textBackground (MAGENTA);
    mensagem ('CTTIPCOP', 0);    {'Qual o tipo de cópia ? '}
    textBackground (BLACK);

    sintLeTecla (c, c2);

    if c = #$1b then
        begin
            writeln;
            mensagem ('CTOK', 1);    {'OK'}
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
            end;

    c := upcase(c);
    case c of
        'A': adicionaArquivo (posListArq, 1, dirAtual);
        ^A: adicionaArquivo (posListArq, numRegs, dirAtual);
        'C': replicaArquivo;
        'D', 'T', 'M': if selecDirDest (nomeDir) then
                 fazCopias := copiaArquivos (posListArq, nomeDir, c = 'M', c = 'T');
        ^D, ^T, {^M}#10: if selecConfigDest (nomeDir) then
                 fazCopias := copiaArquivos (posListArq, nomeDir, c = #10, c = ^T);

        'R', ^R: if folheiaRecebidas then
                begin
                    if obtemNomePastaRegra (nomeDir) then
                         fazCopias := copiaArquivos (posListArq, nomeDir, true, false);
                end
            else
                mensagem ('CTOPVINV', 1); {'Opção inválida, aperte F1 para ajuda'}

        ESC: mensagem ('CTOK', 1); {'OK'}
    else
        begin
             mensagem ('CTOPVINV', 1); {'Opção inválida, aperte F1 para ajuda'}
        end;
    end;
end;

{-------------------------------------------------------------}
{       Move a carta para o diretório de Spam
{-------------------------------------------------------------}

function moveParaDirSpam (nCar: integer): boolean;
var
    nomeArq: string;
    arq: text;
begin
    result := false;
    if (dirSpam = '') or (not existeDir (dirSpam))  then dirSpam := sintDirAmbiente + '\Spam';
    if dirSpam [length(dirSpam)] <> '\' then dirSpam := dirSpam + '\';

    podeSobrescrever := true;
    nomeArq := regLido [nCar]^.carta^.nomArqCarta;
    while (pos ('\', nomeArq) <> 0) and (trim(nomeArq) <> '') do
        delete (nomeArq, 1, pos ('\', nomeArq));
    if copiaUm (regLido [nCar]^.carta^.nomArqCarta, dirSpam + nomeArq) then
        begin
            assign (arq, regLido [nCar]^.carta^.nomArqCarta);
            {$I-}  erase (arq);  {$I+}
            if ioresult <> 0 then
                msgBaixo ('CTERRDSK')  {'Erro de escrita no disco'}
            else
                result := true;
        end;
end;

{--------------------------------------------------------}
{       joga arquivos na lixeira
{--------------------------------------------------------}

function copiaLixeira (nomeArq: string): boolean;
begin
    if (dirLixeira = '') or (not existeDir (dirLixeira))  then dirLixeira := sintAmbiente ('DOSVOX', 'DIRLIXEIRA');
    if dirLixeira = '' then dirLixeira := 'c:\recycled';
    if dirLixeira [length(dirLixeira)] <> '\' then
        dirLixeira := dirLixeira + '\';

    podeSobrescrever := true;
    while (pos ('\', nomeArq) <> 0) and (trim(nomeArq) <> '') do
        delete (nomeArq, 1, pos ('\', nomeArq));
    copiaLixeira := copiaUm (nomeArq, dirLixeira+nomeArq);
end;

{-------------------------------------------------------------}
{       Remove o arquivo  da carta
{-------------------------------------------------------------}

function apagaCarta (nCar: integer; enviarLixeira: boolean): boolean;
var arq: text;
begin
    apagaCarta := false;
    if enviarLixeira then
        if not copiaLixeira (regLido [nCar]^.carta^.nomArqCarta) then exit;
    assign (arq, regLido [nCar]^.carta^.nomArqCarta);
    {$I-}  erase (arq);  {$I+}
    if ioresult <> 0 then
        msgBaixo ('CTERRDSK')  {'Erro de escrita no disco'}
    else
        apagaCarta := true;
end;

function removerCarta (nCar: integer; enviarLixeira, apagarTodas, apertouShift: boolean): integer;
var
    c: char;
    i, numRegsAux, apagados, totalApagar: integer;
    apagarSelecionado: boolean;
label desistiu, fim;

begin
    if apertouShift  then
        begin
            if apagaCarta (nCar, enviarLixeira) then nCar := apagaUmRegs (nCar);
            goto fim;
        end;

    result := nCar;
    apagarSelecionado := false;
    if (not apagarTodas) and  temItemSelecionado then
        begin
            repeat
                msgBaixo ('CTAPASEL');   {'Deseja apagar as selecionadas? '}
                c := upcase(popupMenuPorLetra ('SN'));
                writeln;
            until upcase (c) in ['S', 'N', ESC];
            if c = ESC then
                begin
                    msgBaixo ('CTDESIST');   {'Desistiu'}
                    exit;
                end;
            apagarSelecionado := c = 'S';
        end
    else
    if apagarTodas then
        begin
            repeat
                gotoxy (1, 20);
                mensagem ('CTAPATCA', 0);   {'Deseja apagar todas as cartas? '}
                c := upcase(popupMenuPorLetra ('SN'));
                writeln;
            until c in ['S', 'N', ESC];
            if c <> 'S' then
                begin
                    msgBaixo ('CTDESIST');   {'Desistiu'}
                    exit;
                end;
        end;

    if not (apagarTodas or apagarSelecionado) then
        begin
            repeat
                gotoxy (1, 20);
                mensagem ('CTCNFAPA', 1);  {'Confirma o apagamento desta carta com assunto'}
                sintWriteln (regLido [nCar]^.carta^.subject);
                mensagem ('CTSIMNAO', 0);  {'(S/N) ? '}
                c := upcase(popupMenuPorLetra ('SN'));
                writeln;
            until c in ['S', 'N', ENTER, ESC];
            if c <> 'S' then
                begin
                    msgBaixo ('CTDESIST'); {'Desistiu'}
                    exit;
                end
            else
                begin
                    if not apagaCarta (nCar, enviarLixeira) then exit
                    else
                        nCar := apagaUmRegs (nCar);
                    msgBaixo ('CTOKAPA');  {'Ok, carta apagada'}
                end;
        end
    else
        begin
            numRegsAux := numRegs;
            apagados := 0;
            if apagarTodas then
            totalApagar := numRegs
            else
                totalApagar := totalDeItensSelecionados;

            for i := numRegsAux downto 1 do
                if apagarTodas or (regLido [i]^.selecionado) then
                    begin
                        if not apagaCarta (i, enviarLixeira) then break
                        else
                            begin
                                nCar := apagaUmRegs (i);
                                apagados := apagados + 1;
                            end;
                        if keypressed then
                            begin
                                while keypressed do c := readkey;
                                if c = ESC then
                                    begin
                                        msgBaixo ('CTDESIST'); {'Desistiu'}
                                        goto desistiu;
                                    end;
                                falaQualItemDeQuantos (apagados, totalApagar, false);
                                sintetiza (intToStr((apagados * 100) div totalApagar) + ' %');
                            end;
                    end;
            msgBaixo ('CTOKAPAS');  {'Ok, cartas apagadas'}
        end;

desistiu:
fim:

    if nCar > numRegs then nCar := numRegs
    else if nCar < 0 then nCar := 0;
    result := nCar;
end;

{-------------------------------------------------------------}
{       tira copia do arquivo enviado
{-------------------------------------------------------------}

function tiraCopia (nomeOrig: string): boolean;
const
    BUFSIZE = 1024;

var nomearq: string;
    arqin, arqout: file;
    buf: array [0..BUFSIZE-1] of byte;
    erro, nbytes: integer;
    tam: longint;

label fim;

begin
    tiraCopia := true;
    if maiuscAnsi (copy (trim(nomeOrig), length(nomeOrig)-3, 4)) = '.CPR' then
        nomeArq := novoNomeCarta (nbaseCopia, dirEnvia, '.ENV')
    else
        nomeArq := novoNomeCarta (nbaseCopia, dirEnvia, '.CPR');

    assign (arqin, nomeOrig);
    assign (arqout, nomearq);

    {$I-} reset (arqin, 1); {$I+}
    if ioresult <> 0 then
        begin
            msgBaixo ('CTERRLEI');  {'Erro de leitura do arquivo'}
            tiraCopia := false;
            exit;
        end;
    {$I-} rewrite (arqout, 1); {$I+}
    if ioresult <> 0 then
        begin
            msgBaixo ('CTERRDSK');  {'Erro de escrita no disco'}
            tiraCopia := false;
            goto fim;
        end;

    tam := filesize (arqin);
    while tam > 0 do
        begin
            nbytes := BUFSIZE;
            if tam < BUFSIZE then nbytes := tam;

            {$I-} blockread  (arqin,  buf, nbytes); {$I+}
            if ioresult <> 0 then
                begin
                    msgBaixo ('CTERRLEI');  {'Erro de leitura do arquivo'}
                    tiraCopia := false;
                    goto fim;
                end;

            {$I-} blockwrite (arqout, buf, nbytes); {$I+}
            erro := ioresult;
            if erro = 101 then
                begin
                    msgBaixo ('CTERRDSK');  {'Erro de escrita no disco'}
                    tiraCopia := false;
                    goto fim;
                end;

            tam := tam - BUFSIZE;
        end;

fim:

    {$I-} close (arqin);  {$I+}
    if ioresult <> 0 then;
    {$I-} close (arqout); {$I+}
    if ioresult <> 0 then;
end;

{-------------------------------------------------------------}
begin
end.
