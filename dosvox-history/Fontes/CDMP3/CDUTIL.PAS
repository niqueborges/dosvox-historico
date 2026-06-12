unit cdUtil;

interface

uses dvcrt, dvWin, dvArq, dvForm, dvExec, dvSapi,
    cdDir, cdvars, cdMsg,
    winProcs, winTypes, sysUtils, mmSystem;

function pegaDirDosvox: string;
function trocaDir (dirTrab: string): boolean;

function selNomArqs (nomeDir, tipo: string): boolean;
procedure remNomArqs (nomeDir, tipo: string);
function listNomArqs: boolean;

procedure formatArq;
procedure testSapi;
procedure lerManual;
procedure copiaDirPadrao;
procedure informaProjeto;
procedure ouvirSapi;

implementation

{--------------------------------------------------------}
{                  Retorna o diretório de instalação do Dosvox
{--------------------------------------------------------}

function pegaDirDosvox: string;
var dirDosvox: string;
begin
    dirDosvox := sintAmbiente ('DOSVOX', 'PGMDOSVOX');
    if dirDosvox = '' then
        dirDosvox := 'c:\winvox';
    if dirDosvox[length(dirDosvox)] <> '\' then
        dirDosvox := dirDosvox + '\';

    result := dirDosvox;
end;

{--------------------------------------------------------}

function trocaDir (dirTrab: string): boolean;
begin

    trocaDir:= false;

    {$I-} chDir (dirTrab); {$I+}
    if ioResult <> 0 then
        begin
            {$I-} mkDir (dirTrab); {$I+}
            {$I-} chDir (dirTrab); {$I+}
            if ioResult <> 0 then
            begin
                sintBip; sintBip; sintBip;
                sintWriteln ('- ERRO - Function TrocaDir');
                exit;
            end;
        end;

    trocaDir:= true;

end;

{--------------------------------------------------------}

function selNomArqs (nomeDir, tipo: string): boolean;
var
    buscado: TSearchRec;
    dosError: integer;
    maxArqs: integer;
begin

    selNomArqs:= false;

    if (semArqTXT) and (semArqPar) then
        exit;

    //Zerar o vetor
    for MaxArqs:= 0 to numArqs + 1 do
        nomeArqTxt[maxArqs]:= '';

    if tipo = '*' then
        dosError := FindFirst ('*.*', FAARCHIVE, buscado);

    if tipo = 'T' then
        dosError := FindFirst ('*.TXT', FAARCHIVE, buscado);

    if tipo = 'P' then
        dosError := FindFirst ('*.PAR', FAARCHIVE, buscado);

    numArqs := 0;
    nomeArqTxt[numArqs]:= buscado.name;

    if nomeArqTxt[numArqs] = '' then
        exit;

    writeln;
    while dosError = 0 do
        begin
            numArqs := numArqs + 1;
            nomeArqTxt[numArqs]:= buscado.name;
            writeln (nomeArqTxt[numArqs]);
            dosError := FindNext(buscado);
        end;

    selNomArqs:= true;

    limpaBufTec;

end;

{--------------------------------------------------------}

procedure remNomArqs (nomeDir, tipo: string);
var
    buscado: TSearchRec;
    dosError: integer;
    arqTxt: text;
    maxArqs: integer;
    dirLixeira: string;
begin

    dirLixeira := sintAmbiente ('DOSVOX', 'DIRLIXEIRA');
        if dirLixeira = '' then dirLixeira := 'c:';

    maxArqs:= numArqs;

    if tipo = '*' then
        dosError := FindFirst ('*.*', FAARCHIVE, buscado);

    if tipo = 'T' then
        dosError := FindFirst ('*.TXT', FAARCHIVE, buscado);

    if tipo = 'P' then
        dosError := FindFirst ('*.PAR', FAARCHIVE, buscado);

    numArqs := 0;
    nomeArqTxt[numArqs]:= buscado.name;

    if nomeArqTxt[numArqs] = '' then
        begin
            writeln;
            mensagem ('CDNHAREM', 1); {'Não há arquivo à remover')}
            numArqs:= maxArqs;
            exit;
        end;

    while dosError = 0 do
        begin
            numArqs := numArqs + 1;
            nomeArqTxt[numArqs]:= buscado.name;
            assign (arqTxt, nomeArqTxt[numArqs]);
        {$I-} rename(arqTxt, dirLixeira + '\' + nomeArqTxt[numArqs]); {$i+}
            if ioResult <> 0 then;
            dosError := FindNext(buscado);
        end;

    writeln;
    mensagem ('CDTOTREM', 0); {'Total de arquivo(s) removido(s) --- ')}
    sintWriteInt (numArqs);
    writeln;

    if tipo = '*' then
    begin
        semArqTxt:= true;
        semArqPar:= true;
    end;

    if tipo = 'T' then
    begin
        semArqTxt:= true;
        if not selNomArqs(dirTexto, 'P') then
            semArqPar:= true;
    end;

    if tipo = 'P' then
    begin
        semArqPar:= true;
        if not selNomArqs(dirTexto, 'T') then
            semArqTxt:= true;
    end;

    limpaBufTec;

end;

{--------------------------------------------------------}

function listNomArqs: boolean;
var maxArqs: integer;
    c: char;
begin

    listNomArqs:= false;

    maxArqs:= numArqs;

    if maxArqs = 0 then
    begin
        sintBip; sintBip;
        writeln;
        mensagem ('CDNHSEL', 1); {'Não há arquivo(s) a selecionar')}
        writeln;
        exit;
    end
    else
    begin
        writeln;
        mensagem ('CDPODCON', 1); {'Poderei converter : ')}
        writeln;
    end;

    numArqs:= 0;
    while numArqs <> maxArqs do
    begin
        numArqs:= numArqs + 1;
        sintWriteln (nomeArqTxt[numArqs]);
    end;

    if keypressed then
        c:= readkey;

    if c = ESC then
    begin
        listNomArqs:= false;
        writeln;
        mensagem ('CDDESIST', 1);
    end
    else
        listNomArqs:= true;

    limpaBufTec;

end;

{--------------------------------------------------------}

procedure formatArq;
var nomeProg, nomeArq: string;
begin

//    if semArqTxt then
//        begin
//            mensagem ('CDNAOFOR', 1); {'O diretório padrão não contém nenhum arquivo a formatar')}
//            exit;
//        end;

    nomeProg:= sintAmbiente ('DOSVOX', 'EDITOR');
    if nomeProg = '' then
        nomeProg:= dirDosvox + '\edivox.exe';

    mensagem ('CDSELSET', 1); {'Selecione o arquivo com as setas')}
    garanteEspacoTela (11);
//    nomeArq:= obtemNomeArqMasc (10, '*.TXT');
    nomeArq:= obtemNomeArqMasc (10, '*.*');
    writeln (nomeArq);
    if nomeArq = '' then
    begin
        mensagem ('CDDESIST', 1);
        exit;
    end;

    nomeArq:= '"' + nomeArq + '"';

    delay (250);
    if executaProg (nomeProg, '', nomeArq) < 32 then;
        esperaProgVoltar;
    delay (500);

    if selNomArqs(dirTexto, 'T') then
        semArqTxt:= false;

end;

{--------------------------------------------------------}

procedure testSapi;
var arqTXT: text;
    nomeArq, linha: string;
    arqTodo: string;
    erro: integer;
begin

    if not sapiOK then
    begin
//        mensagem ('CDSAPNAO', 1); {'Fala SAPI não está ativada')}
//        exit;
    val (sintAmbiente('CDMP3', 'TIPOSAPI'), confTipoSapi, erro);
    if erro <> 0 then val (sintAmbiente('SERVFALA', 'TIPOSAPI'), confTipoSapi, erro);
    if erro <> 0 then confTipoSapi := 3;
    val (sintAmbiente('CDMP3', 'NUMEROSAPI'), confNum, erro);
    if erro <> 0 then confNum:= 1;
    val (sintAmbiente('CDMP3', 'VELOCIDADESAPI'), confVeloc, erro);
    if erro <> 0 then confVeloc:= 0;
    val (sintAmbiente('CDMP3', 'TONALIDADESAPI'), confTonal, erro);
    if erro <> 0 then confTonal:= 0;
    sapiOK:= true;
    alterouSapi:= true;
    end;

    if semArqTxt then
        begin
            mensagem ('CDNAOSEL', 1); {'O diretório padrão não contém nenhum arquivo a selecionar')}
            exit;
        end;

    mensagem ('CDSELSET', 1); {'Selecione o arquivo com as setas')}
    garanteEspacoTela (11);
    nomeArq:= obtemNomeArqMasc (10, '*.TXT');
    writeln (nomeArq);
    if nomeArq = '' then
    begin
        mensagem ('CDDESIST', 1);
        exit;
    end;

    assign (arqTxt, nomeArq);
    {$I-} reset(arqTxt); {$I+}
    if ioResult <> 0 then
        exit;

    while not eof(arqTxt) do
    begin
        readln (arqTxt, linha);
        arqTodo:= arqTodo + ' ' + linha;
    end;

    {$I-} close(arqTxt); {$I+}
    if ioResult <> 0 then
        exit;

    if alterouSAPI then
        sintReinic (velocidadeDOSVOX, sapiOK, confTipoSapi, confNum, confVeloc, confTonal);

    delay (250);
    sintetiza (arqTodo);
    while sintFalando do waitMessage;
    delay (250);

    if alterouSAPI then
    begin
        sintFim;
        SintInic (0, sintAmbiente('CDMP3', 'DIRCDMP3'));
    end;

    limpaBufTec;

    mensagem ('CDOK', 1);

end;

{--------------------------------------------------------}

procedure lerManual;
var nomeProg, nomeArq: string;
begin

    nomeProg:= dirDosvox + '\webvox.exe';
    nomeArq:= dirDosvox + '\manual\cdmp3.htm';

    delay (250);
    if executaProg (nomeProg, '', nomeArq) < 32 then;
        esperaProgVoltar;
    delay (500);

end;

{--------------------------------------------------------}

procedure copiaDirPadrao;
var
    parametros: string;
    cmd_ou_command: string;
    infoSistOp: _OSVERSIONINFO;

begin
    mensagem ('CDCOPIA', 1);    {'Efetuando cópia'}

    parametros := ' /c xcopy /y /f /h /s . "' + dirCopia + '"';

    infoSistOp.dwOSVersionInfoSize := sizeof(infoSistOp);
    GetVersionEx(infoSistOp);
    if infoSistop.dwMajorVersion < 5 then
        cmd_ou_command := 'command' { usa command em Windows inferior ao 2000 }
    else
        cmd_ou_command := 'cmd'; { usa cmd em Windows 2000 ou superior (NT >= 5) }

    if executaProgEX (cmd_ou_command, '.', parametros, SW_SHOWMINIMIZED) < 32 then;
        esperaProgVoltar;

    mensagem ('CDCPOK', 1);    {'Cópia concluída'}

end;

{--------------------------------------------------------}

procedure informaProjeto;
begin

    writeln;
    mensagem ('CDPROALO', 0); {'Projeto alocado em --- ')}
    sintWriteln (dirTexto);
    delay (200);
    mensagem ('CDTAMA', 0); {'Tamanho --- ')}
    infTamDir (dirTexto);
    writeln;

end;

{--------------------------------------------------------}

procedure ouvirSapi;
var tipo, numero, velocidade, tonalidade: integer;
    tec: char;
    frase, frase_r: string;
    erro: integer;
    podeTrocar: boolean;

    procedure ajuda;
    begin
        sintSom ('CDMENU');
        delay (100);
        mensagem ('CDOP', 1); {'Opções nas teclas:'}
        delay (100);
        mensagem ('CDCIMBAI', 1); {'  CIMA e BAIXO - Selecionar voz')}
        mensagem ('CDDIRESQ', 1); {'  DIR e ESQ - Selecionar velocidade')}
        mensagem ('CDCDICES', 1); {'  CTRL+DIR e CTRL+ESQ - Selecionar tonalidade')}
        mensagem ('CDNOVVAL', 1); {'  V - Novos valores')}
        mensagem ('CDNOVFRA', 1); {'  F - Nova frase')}
        mensagem ('CDNUMVOZ', 1); {'  N - Informar número da voz')}
        mensagem ('CDNUMF4', 1); {'  F4 - Modo silencioso'}
        mensagem ('CDNUMF5', 1); {'  F5 - Modo digitação'}
    end;

begin
//    tipo:= 3;
    numero:= 1;
    velocidade:= 0;
    tonalidade:= 0;
    podeTrocar:= true;

    writeln;
    mensagem ('CDINFTIP', 0); {'Informe o tipo SAPI (3, 4 ou 5) : ')}
    tec:= popupMenuPorLetra ('345');

    val (tec, tipo, erro);
    if erro <> 0 then tipo := 3;

    if (tipo < 3) or (tipo > 5) then
    begin
        mensagem ('CDDESIST', 1);
        exit;
    end;

    writeln;
    frase:= 'AJUSTE SAPI: TESTE - "Poderei converter os arquivos utilizando esse padrão" -';
    mensagem ('CDDIGMSG', 1); {'Digite uma frase qualquer : ')}
    tec:= sintEditaCampo (frase, 1, wherey, 255, 80, true);

    if (tec = ESC) or (frase = '') then
    begin
        mensagem ('CDDESIST', 1);
        exit;
    end;

    writeln;
    mensagem ('CDUSESET', 1); {'Use as setas, F1 ajuda')}
    writeln;

    repeat

        limpaBufTec;

        if podeTrocar then
        begin
            sintReinic (velocidadeDOSVOX, true, tipo, numero, velocidade, tonalidade);
            try
                sintetiza (frase);
            except end;
            while sapiAtivo(1) do waitMessage;
        end;

        tec:= readkey;
        if tec = #0 then
        tec:= readkey;

        if tec = F1 then
            ajuda;

        if tec = F4 then
        begin
            podeTrocar:= not podeTrocar;
            sintBip;
        end;

        if tec = F5 then
        begin
            sintBip; sintBip; sintBip;
            sintWriteln ('Digite qualquer frase e pressione ENTER.  Para sair, ESCAPE');
            repeat
                sintReadln (frase_r);
                try
                    sintetiza (frase_r);
                except end;
                while sapiAtivo(1) do waitMessage;
            until frase_r = '';
            sintBip; sintBip; sintBip;
        end;

        if (tec = BAIX) or (tec = CIMA) then
        begin

            podeTrocar:= true;

            if (tec= BAIX) and (numero < sapiNumVozes) then
                numero:= numero + 1;
            if (tec = CIMA) and (numero > 1) then
                numero:= numero - 1;

        end;

        if (tec = dir) or (tec = esq) then
        begin

            if (tec= dir) and (velocidade < 500) then
                velocidade:= velocidade + 1;
            if (tec = esq) and (velocidade > 0) then
                velocidade:= velocidade - 1;

            if podeTrocar then
            begin
                writeln;
                mensagem ('CDVELOCI', 0); {'Velocidade : ')}
            end;

            sintWriteInt (velocidade);
            writeln;
            while sapiAtivo(1) do waitMessage;

        end;

        if (tec = CTLDIR) or (tec = CTLESQ) then
        begin

            if (tec= CTLDIR) and (tonalidade < 500) then
                tonalidade:= tonalidade + 1;
            if (tec = CTLESQ) and (tonalidade > 0) then
                tonalidade:= tonalidade - 1;

            if podeTrocar then
            begin
                writeln;
                mensagem ('CDTONALI', 0); {'Tonalidade : ')}
            end;

            sintWriteInt (tonalidade);
            writeln;
            while sapiAtivo(1) do waitMessage;

        end;

        if upcase(tec) = 'F' then
        begin
            podeTrocar:= true;
            writeln;
            mensagem ('CDREEDIT', 1); {'Reedite a frase : ')}
            sintEditaCampo (frase, 1, wherey, 255, 80, true);
        end;

        if upcase(tec) = 'V' then
        begin
            podeTrocar:= true;
            writeln;
            mensagem ('CDINUVOZ', 0); {'Informe o número da voz : ')}
            sintReadInt (numero);
            writeln;
            mensagem ('CDINFVEL', 0); {'Informe a velocidade : ')}
            sintReadInt (velocidade);
            writeln;
            mensagem ('CDINFTON', 0); {'Informe a tonalidade : ')}
            sintReadInt (tonalidade);
        end;

        if upcase(tec) = 'N' then
        begin
            podeTrocar:= true;
            writeln;
            mensagem ('CDVOZATU', 0); {'Voz atual : ')}
            sintWriteInt (numero);
            delay (100);
            writeln;
            mensagem ('CDVOZINS', 0); {'Vozes instaladas : ')}
            sintWriteInt (sapiNumVozes);
            while sapiAtivo(1) do waitMessage;
        end;

        while sintFalando do waitMessage;

    until (tec = ENTER) or (tec = ESC);

    if tec = ENTER then
    begin

        mensagem ('CDASSCON', 0); {'Assumo esta voz para a conversão dos textos? (SIM ou NÃO) : '}
        tec:= popupMenuPorLetra ('SN');

        if tec = 'S' then
        begin
            confTipoSapi:= tipo;
            confNum:= numero;
            confVeloc:= velocidade;
            confTonal:= tonalidade;
            sapiOK:= true;
            alterouSapi:= true;
            mensagem ('CDOK', 1);
        end
        else
            mensagem ('CDDESIST', 1);

    end
    else
        mensagem ('CDOK', 1);

    delay (250);
    sintFim;
    SintInic (0, sintAmbiente('CDMP3', 'DIRCDMP3'));
    delay (250);

    limpaBufTec;

end;

{--------------------------------------------------------}

begin
end.
