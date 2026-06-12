{--------------------------------------------------------}
{    Programa FichaVox}
{   Montagem de fichario}
{--------------------------------------------------------}

unit fvMontFi;

interface
    uses windows, dvcrt, dvWin, sysUtils, fvMsg, fvVars, fvArqui,
fvProc;

    procedure montarFichario;
    procedure indexarArquivo;

implementation

var
    arqin, arqout: file;

{-----------------------------------------------------------------------}
{Função queabre um diretório (TRUE=aberto ou FALSE=não aberto).
{-----------------------------------------------------------------------}

function abrirdiretorio (diretorio: string): boolean;
begin
    {$i-}chdir (diretorio);{$i+}
    if ioresult <> 0 then
        abrirdiretorio := false
    else
        abrirdiretorio := true;
end;

{-----------------------------------------------------------------------}
{Cria um diretório, cria arquivo FICHAS.IND.ind}
{-----------------------------------------------------------------------}

function criar_dir (diretorio: string): boolean;
begin
    {$i-}mkdir (diretorio);{$i+}
    if ioresult <> 0 then
        begin
            mensagem ('FVNCRDIR',1);
            {Desculpe, mas não consegui criar o fichario .}
            criar_dir := false;
            exit;
        end
    else
        begin
            mensagem ('FVCRIDIR',1); {fichario criado.}
            criar_dir := true;
        end;
end;

{----------------------------------------------------------------------}
{Testa o nome do arquivo para não associar a uma ficha  o MODELO.TXT e}
{nem o FICHAS.IND}
{----------------------------------------------------------------------}

procedure alocarArquivo(NNArq: string; textoArq: boolean);

    function EstencaoArq (nNArq: string): boolean;
    begin
        if ((pos ('.MP3', NNArq) <> 0) or (pos ('.MID',nNArq) <> 0) or
        (pos ('.AWV', NNArq) <> 0) or (pos ('.RM',nNArq) <> 0) or
        (pos ('.ZIP', NNArq) <> 0) or (pos ('.ARJ',nNArq) <> 0) or
        (pos ('.DOC', NNArq) <> 0) or (pos ('.RTF',nNArq) <> 0) or
        (pos ('.PDF', NNArq) <> 0) or (pos ('.BAT',nNArq) <> 0) or
        (pos ('.EXE', NNArq) <> 0) or (pos ('.SYS',nNArq) <> 0) or
        (pos ('.DLL', NNArq) <> 0) or (pos ('.PPT',nNArq) <> 0) or
        (pos ('.XLS', NNArq) <> 0) or (pos ('.INI',nNArq) <> 0) or
        (pos ('.HTM', NNArq) <> 0) or (pos ('.DPR',nNArq) <> 0) or
       (pos ('.CAR', NNArq) <> 0) or (pos ('.CHK',nNArq) <> 0) or
       (pos ('.PAS', NNArq) <> 0) or (pos ('.PS',nNArq) <> 0) or
       (pos ('.LOG', NNArq) <> 0) or (pos ('.ENV',nNArq) <> 0) or
       (pos ('.Ra', NNArq) <> 0) or (pos ('.H',nNArq) <> 0) or
       (pos ('.TBO', NNArq) <> 0) or (pos ('.TDS',nNArq) <> 0) or
       (pos ('.OBJ', NNArq) <> 0) or (pos ('.PAG',nNArq) <> 0) or
       (pos ('.JCF', NNArq) <> 0) or (pos ('.$$$',nNArq) <> 0) or
       (pos ('.TIF', NNArq) <> 0) or (pos ('.TMP',nNArq) <> 0) or
       (pos ('.GIF', NNArq) <> 0) or (pos ('.PCX',nNArq) <> 0) or
       (pos ('.JPG', NNArq) <> 0) or (pos ('.BMP',nNArq) <> 0) or
       (pos ('.DSP', NNArq) <> 0) or (pos ('.OCX',nNArq) <> 0) or
       (pos ('.NLS', NNArq) <> 0) or (pos ('.VXD',nNArq) <> 0) or
       (pos ('.DRV', NNArq) <> 0) or (pos ('.TON',nNArq) <> 0) or
       (pos ('.AX', NNArq) <> 0) or (pos ('.TWD',nNArq) <> 0) or
       (pos ('.CPX', NNArq) <> 0) or (pos ('.CPL',nNArq) <> 0) or
        (pos ('.DAT', NNArq) <> 0) or (pos ('.COM',nNArq) <> 0)) then
            estencaoArq := TRUE
        else
            estencaoArq := FALSE;
    end;

    function pegaNomeFicha (nNArq: string): string;
    var
        nArq: text;
        s: string;

    begin
        if textoArq then
            begin
                if estencaoArq (nNArq) then
                    begin
                        pegaNomeFicha := nNarq;
                        exit;
                    end;

                assign (nArq, nNArq);
                {$i-} reset (nArq); {$i+}
                if ioresult <> 0 then
                    begin
                        pegaNomeFicha := nNarq;
                        exit;
                    end;
                repeat
                    readln (nArq, s);
                    s := copy (s, 1, 128);
                until ((s <> '') or (eof (nArq)));

                while (s <> '') and ((s[1] = ' ') or (s[1] = ^I)) do
                    delete (s, 1, 1);

                if s = '' then
                    pegaNomeFicha := nNArq
                else
                    pegaNomeFicha := s;
                close (nArq);
            end
        else
            pegaNomeFicha := nNarq
    end;

var
    nArq: text;
    i: integer;

begin
    i:= numFichas+1;
    if i > numMaxFichas then
        begin
            mensagem ('FVDIRCHE',1);{O fichario já esta cheio.}
            exit;
        end;

    NNArq := maiuscAnsi (NNArq);
    if NNArq = '.' then exit;
    if NNArq = '..' then exit;
    if NNArq = 'FICHAS.IND' then exit;
    if NNArq= 'MODELO.TXT' then exit;
    if not (teste_newNomeArq (NNArq)) then exit;

    if (pos ('.', NNArq) = 0) then
    begin
        assign (nArq, nNArq);
        {$i-} reset (nArq); {$i+}
        if ioresult <> 0 then exit
        else close (nArq);
    end;

    i := numFichas + 1;
    new (Fichario[i]);
    Fichario[i]^.nomeArq := NNArq;
    Fichario[i]^.chave := pegaNomeFicha (NNArq);
    Fichario[i]^.original := i;
    fichario[i]^.selecionado := FALSE;
    numFichas := i;
end;

{----------------------------------------------------------------------}
{Busca os arquivos que não tem ficha associada e coloca no indice vcom}
{um nome genérico de ficha.}
{----------------------------------------------------------------------}

procedure indexarArquivo;
var
    ret: integer;
    opc: char;
    textoArq: boolean;
    DirInfo: TSearchRec;
    cont: integer;

begin
    cont := 0;
    if numFichas >= NUMMAXFICHAS Then
        begin
            mensagem ('FVDIRCHE',1);{O fichario já esta cheio.}
            exit;
        end;

    mensagem ('FVTXTARQ', 0);
    {'Deseja pegar primeira linha escrita do arquivo? '}
    opc := upcase (sintReadkey);
    writeln (opc);
    if opc = 'N' then
        textoArq := FALSE
    else
    if opc = ESC then
        begin
            mensagem ('FVDESIST', 1);
            exit;
        end
    else
        textoArq := TRUE;

    mensagem ('FVINDEXA',1);   {indexando...}
    ret := sysUtils.FindFirst ('*.*', faAnyFile, DirInfo);
    if ret = 0 then
        repeat

            cont := cont + 1;
            if cont > 50 then
               begin
                  cont := 0;
                  sintClek;
               end;
            alocarArquivo (DirInfo.FindData.cFileName, textoArq);
            ret := findNext (DirInfo);
        until ret <> 0;

    FindClose (DirInfo);
    mensagem ('FVARQIND',1);{'Arquivos indexados.'}
end;

{--------------------------------------------------------}
{                  copias de arquivos
{--------------------------------------------------------}

    { esta rotina recebe os nomes dos arquivos ja' assinalados }
    {  aos arquivos arqin e arqout }

    function copiaUm: boolean;
    const
        BUFSIZE = 8192;
    type
        BUFFER = array [0..BUFSIZE-1] of byte;

    var tam: longint;
        nbytes: word;
        buf: ^BUFFER;
        erro: word;
    label fim;

    begin
        copiaUm:= false;

        {$I-} reset (arqin, 1); {$I+}
        if ioresult <> 0 then exit;
        {$I-} rewrite (arqout, 1); {$I+}
        if ioresult <> 0 then exit;

        new (buf);

        tam := filesize (arqin);
        while tam > 0 do
            begin
                nbytes := BUFSIZE;
                if tam < BUFSIZE then nbytes := tam;

                {$I-} blockread  (arqin,  buf^, nbytes); {$I+}
                if ioresult <> 0 then
                    begin
                        limpaBufTec;
                        mensagem ('FVERRLEI', 1);
                        goto fim;
                    end;

                {$I-} blockwrite (arqout, buf^, nbytes); {$I+}
                erro := ioresult;
                if erro = 101 then
                    begin
                        limpaBufTec;
                        mensagem ('FVFALESP', 1);
                        goto fim;
                    end;

                tam := tam - BUFSIZE;
            end;

        copiaUm := true;

fim:
        dispose (buf);

        {$I-} close (arqin);  {$I+}
        if ioresult <> 0 then;
        {$I-} close (arqout); {$I+}
        if ioresult <> 0 then
            copiaUm := false;
    end;

{--------------------------------------------------------}
    procedure copiaTodos (diret: string; numArqs: integer);
    var
        i: integer;
        nomearq: string;

    begin
        for i := 1 to numArqs do
            begin
                nomearq := fichario[i]^.nomeArq;
                assign (arqin, nomearq);
                assign (arqout, diret+'\'+nomearq);

                if not copiaUm then
                    begin
                         mensagem ('FVERRCOP', 1);
                       sintetiza (nomearq);
                         exit;
                    end
                else
                    begin
                       write (nomearq);
                       sintetiza (nomearq);
                       mensagem ('FVFOICOP', 1);
                    end;
            end;
    end;

{--------------------------------------------------------}
{Monta um fichario a partir de um diretório}
{----------------------------------------------------------------------}

procedure montarFichario;
var
    DirInfo: TSearchRec;
    dirIn, dirOut: string;
    mascara: string;
    opc: char;
    i,numArqs, ret, cont: integer;

begin
    mensagem ('FVDIRORI', 1);{'Digite o nome do diretório de origem: '}
    sintReadln (dirOut);
    if dirOut = '' then
        begin
            mensagem ('FVDESIST',1);
            exit;
        end;
    if not (abrirdiretorio (dirOut)) then
        begin
            mensagem ('FVNABDIR',1);
            exit;
        end;
    mensagem ('FVNOMMAS', 0);{'Informe a mascara de seleção? por exemplo '}
    writeln (' *.txt: ');
    sintSoletra ('*.txt');
    sintReadln (mascara);
        if mascara = '' then
            mascara := '*.*';

    repeat
        mensagem ('FVDNFIDE', 1);{'Digite o nome do fichario de destino: '}
        sintReadln (dirIn);
        if dirIn = '' then
            begin
                {$i-}chdir (caminho);{$i+}
                if ioresult <> 0 then exit;
                mensagem ('FVDESIST',1);
                exit;
            end;
        if abrirdiretorio (dirIn) then
            begin
                mensagem ('FVJAEXIS', 1);{'Fichario já existe.'}
                mensagem ('FVDEADFI', 1); {'Deseja adicionar a este fichario? '}
                opc := upcase (readkey);
            end
        else
            begin
                mensagem ( 'FVNAOEXI', 1);{ 'fichario não existe.'}
                mensagem ( 'FVPCRDIR', 1);{'deseja criar este fichario?'}
                opc := upcase (readkey);
                if opc = 'N' then
                    opc := 'N'
                else
                if not (criar_dir (dirIn)) then
                    begin
                        mensagem ('FVTENNOV', 0);{'Deseja tentar novamente?'}
                        opc := upcase (readkey);
                        writeln;
                        if opc = 'S' then opc := 'N'
                        else
                            begin
                                {$i-}chdir (caminho);{$i+}
                                if ioresult <> 0 then;
                                mensagem ('FVDESIST',1);
                                exit;
                            end;
                    end
                else
                    opc := 'S';
            end;
        if opc <> 'S' then
            begin
                mensagem ('FVDIESSA', 1);
                {'Digite ESC para sair, ou outra tecla para continuar.'}
                opc := readkey;
                if opc = ESC then
                    begin
                        {$i-}chdir (caminho);{$i+}
                        if ioresult <> 0 then;
                        exit;
                    end
                else
                    opc := 'N';
            end;
    until opc = 'S';

    descarregar_fichas;
    numFichas := 0;
    {$i-}chdir (dirOut);{$i+}
    if ioresult <> 0 then exit;
    i := 0;
    cont := 0;
    ret := sysUtils.FindFirst (mascara, faAnyFile, DirInfo);
    if ret = 0 then
        repeat

            cont := cont + 1;
            if cont > 50 then
               begin
                  cont := 0;
                  sintClek;
               end;

            newNomeArq :=  DirInfo.FindData.cFileName;
            if (newNomeArq <> 'FICHAS.IND') and
               (newNomeArq <> 'MODELO.txt') then
                begin
                    i := i +1;
                    new (Fichario[i]);
                    fichario[i]^.nomeArq := newNomeArq;
                end;
            ret := findNext (DirInfo);
        until ret <> 0;

    FindClose (DirInfo);
    numArqs := i;
    copiaTodos (dirIn, numArqs);
    descarregar_fichas;
    {$i-}chdir (dirIn);{$i+}
    if ioresult <> 0 then;
    carregar_fichas;
    indexarArquivo;
    mensagem ('OK',1);
end;

{----------------------------------------------------------------------}

end.
