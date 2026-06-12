{--------------------------------------------------------}
{
{     Rotinas de configuração do DOSVOX para Windows
{
{     Autores:  José Antonio Borges
{               Júlio Tadeu Carvalho da Silveira
{               Neno Albernaz
{               Patrick Barboza
{
{     Versão 1.0:   Em Janeiro/98
{     Versão 5.0:   Em junho/2015
{     Versão 6.0:   Em setembro/2019
{     Versão 6.1:   Em Julho/2021
{     Versão 6.2:   Em Julho/2024
{
{--------------------------------------------------------}

unit dosconf;

interface
uses
    windows, sysUtils, classes,
    miniReg, dvamplia,
    dvcrt, dvwin,
    dvForm, dvSapi, dvSapGlb,
    dosVars, dosgeral, doslogo, dosquem, dosupdat, dosmsg, dosMonit, doscopia;

procedure configDosvox;
procedure editaSecao (nomeSecao: string);
function getMeusDownloads: string;

implementation

uses
    dvWav,
    dvMidi,
    mmSystem;

{--------------------------------------------------------}
{                escolhe uma seção
{--------------------------------------------------------}

function escolheSecao: string;
var
    secoes: array [0..8000] of char;
    p: pchar;
    n, i, nsecoes: integer;
begin
    escolheSecao := '';
    mensagem ('DV_SELSEC', 1);      { 'Selecione com as setas a seção a configurar' }

    getprivateProfileString (NIL, NIL, '', secoes, 8000, pchar(dosvoxIniDir + '\DOSVOX.INI'));
    p := secoes;
    nsecoes := 0;
    while p^ <> #$0 do
        begin
            nsecoes := nsecoes + 1;
            p := p + strlen(p) + 1;
        end;

    p := secoes;
    popupMenuCria (50, 1, 29, nsecoes, MAGENTA);
    while p^ <> #$0 do
        begin
            popupMenuAdiciona ('', strPas(p));
            p := p + strlen(p) + 1;
        end;

    popupMenuOrdena;

    while sintfalando do Waitmessage;
    limpaBuf;

    n := popupMenuSeleciona;
    if n <= 0 then exit;

    p := secoes;
    for i := 2 to n do
        p := p + strlen(p) + 1;
    gotoxy (1, wherey-1);
    write (strPas(p), ' - ');
    clreol;

    escolheSecao := strPas(p);
end;

{--------------------------------------------------------}
{                edita uma seção
{--------------------------------------------------------}

procedure editaSecao (nomeSecao: string);
var
    itens: array [0..64000] of char;
    contItem: array [1..200] of pShortString;
    p: pchar;
    i, nitens: integer;
    salva: integer;

begin
    mensagem ('DV_EDITCONF', 2);    {'Editore as configurações, ao final tecle ESC'}

    salva := tamRotulosForm;
    tamRotulosForm := 3;
    p := itens;
    getprivateProfileString (pchar(nomeSecao), NIL, '', itens, 64000, pchar(dosvoxIniDir + '\DOSVOX.INI'));
    while p^ <> #$0 do
        begin
            if integer(strlen(p)) > tamRotulosForm then
                tamRotulosForm := strLen (p);
            p := p + strlen(p) + 1;
        end;
    tamRotulosForm := tamRotulosForm + 1;

    p := itens;
    nitens := 0;

    formCria;
    while p^ <> #$0 do
        begin
            nitens := nitens + 1;
            getmem (contItem[nitens], sizeof (shortString));
            contItem[nitens]^ := sintAmbiente (nomeSecao, strPas(p));
            formCampo  ('', strPas (p), contItem[nItens]^, 255);
            p := p + strlen(p) + 1;
        end;
    formEdita (true);

    p := itens;
    for i := 1 to nitens do
        begin
            sintGravaAmbiente (nomeSecao, strPas(p), contItem[i]^);
            freeMem (contItem[i], 255);
            p := p + strlen(p) + 1;
        end;

    tamRotulosForm := salva;
    writeln;
end;

{--------------------------------------------------------}
{                inclui um item em uma seção
{--------------------------------------------------------}

procedure incluiItem (nomeSecao: string);
var item, conteudo: string;

begin
    repeat
        mensagem ('DV_ITEMINC', 1);     {'Nome do item a incluir'}
        sintReadln (item);
        if item = '' then exit;

        mensagem ('DV_CONTITEM', 1);    {'Informe o conteúdo deste item'}
        sintReadln (conteudo);

        sintGravaAmbiente(nomeSecao, item, conteudo);

        mensagem ('DV_OK', 2);      { 'Ok ! '}
    until false;
end;

{--------------------------------------------------------}
{                remove item de uma seção
{--------------------------------------------------------}

procedure removeItem (nomeSecao: string);
var
    itens: array [0..64000] of char;
    p: pchar;
    i, nitens: integer;
    c: char;
    n: integer;

begin
    repeat
        mensagem ('DV_SELITEMREM', 1);  {'Escolha com as setas o item a remover'}

        p := itens;
        getPrivateProfileString (pchar(nomeSecao), NIL, '', itens, 64000, pchar(dosvoxIniDir + '\DOSVOX.INI'));
        nitens := 0;
        while p^ <> #$0 do
            begin
                nitens := nitens + 1;
                p := p + strlen(p) + 1;
            end;

        p := itens;
        popupMenuCria (50, wherey, 29, nitens, MAGENTA);
        while p^ <> #$0 do
            begin
                popupMenuAdiciona ('', strPas(p));
                p := p + strlen(p) + 1;
            end;

        n := popupMenuSeleciona;
        if n <= 0 then exit;

        p := itens;
        for i := 2 to n do
            p := p + strlen(p) + 1;

        mensagem ('DV_CNFREMITEM', 0);      {'Confirma remoção do item '}
        sintWrite (strPas (p));
        write ('? ');
        c := popupMenuPorLetra('SN');
        if c = 'S' then
            begin
                sintRemoveAmbiente (nomeSecao, p);
                mensagem ('DV_OKREMOV', 2);         {'Ok, removido'}
            end;

    until false;
end;

{--------------------------------------------------------}
{                cria uma nova seção
{--------------------------------------------------------}

procedure criaNovaSecao;
var nomeSecao: string;
begin
    mensagem ('DV_NOVASECAO', 1);   {'Informe o nome da nova seção do Dosvox.ini'}
    sintReadln (nomeSecao);
    if nomeSecao = '' then exit;

    sintGravaAmbiente (nomeSecao, 'XXXXXXX', 'XXXXXXX');
    sintRemoveAmbiente(nomeSecao, 'XXXXXXX');

    mensagem ('DV_OK', 2);          { 'Ok ! '}
end;

{--------------------------------------------------------}
{       define pasta padrao de trabalho
{--------------------------------------------------------}

procedure definePastaPadraoTrabalho (novoDir: string);
var
    dirAtual,
    dirAnt: string;
begin
    dirAnt := sintAmbiente ('DOSVOX', 'DIRDEFAULT');
    if novoDir = dirAnt then
    begin
        mensagem ('DV_PPADR_MANT',1);   { 'Pasta padrão de trabalho mantida. ' }
        exit;
    end;

    getDir (0, dirAtual);
    {$I-} chdir (novoDir);  {$I+}
    if ioresult <> 0 then
    begin
        mensagem ('DV_ERRMUD', 1);      { 'Desculpe, não consegui mudar para o diretório pedido.' }
        mensagem ('DV_PPADR_MANT',1);   { 'Pasta padrão de trabalho mantida. ' }
        exit;
    end;

    sintGravaAmbiente('DOSVOX', 'DIRDEFAULT', novoDir);

    mensagem ('DV_PPADR_ALT', 0);   { 'Pasta padrão de trabalho alterada para: ' }
    if (length(novoDir) >= 2) and (novoDir[2] <> ':') then
        sintetFala (novoDir, 1)
    else
    begin
        soletra (copy (novoDir, 1, 2), 0);
        sintetFala (copy (novoDir, 3, length(novoDir)-2) , 1);
    end;

    mensagem ('DV_PPADR_ALT2', 0);  { ''Pasta de trabalho também foi alterada.' }
    getdir (0, dirAtual);
    insereNosUltimosComandos(dirAtual, 'DOSVOX', 'DT');
end;

{--------------------------------------------------------}
{       procura pasta treino
{--------------------------------------------------------}

function getPastaTreino: string;
var
    dirDosvox: string;
begin
    dirDosvox := sintAmbiente('DOSVOX', 'PGMDOSVOX');
    if (dirDosvox = '') or (dirDosvox = '@') then
        dirDosvox := 'C:\winvox';
    if dirDosvox[length(dirDosvox)] <> '\' then
        dirDosvox := dirDosvox + '\';
    dirDosvox := dirDosvox + 'treino';
    result := dirDosvox;
end;

{--------------------------------------------------------}
{       procura pasta Meus Documentos.
{--------------------------------------------------------}

function getMeusDocumentos: string;
const
    SearchTree = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\';
var
    dirDocs: string;
begin
    if not regGetString (HKEY_CURRENT_USER, SearchTree+'Personal', dirDocs) then
        result := ''
    else
        result := dirDocs;
end;

{--------------------------------------------------------}
{       procura pasta Meus downloads
{--------------------------------------------------------}

function getMeusDownloads: string;
const
    SearchTree = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\';
var
    dirDocs: string;
begin
    if not regGetString (HKEY_CURRENT_USER, SearchTree+
        '{374DE290-123F-4565-9164-39C4925E467B}', dirDocs) then
        result := ''
    else
        result := dirDocs;
end;

{--------------------------------------------------------}
{       ler nova pasta padrao de trabalho
{--------------------------------------------------------}

function leNovaPastaPadraoTrabalho: string;
var
    c: char;
    novoDir: string;
begin
    mensagem ('DV_NOVA_PPADR', 1);  { 'Informe nome da nova pasta padrão de trabalho:' }

    novoDir := sintAmbiente ('DOSVOX', 'DIRDEFAULT');
    c := sintEdita (novoDir, wherex, wherey, screenSize.X, true);    //sintReadln (novoDir);

    result := '';

    if (c = ESC) or (novoDir = '') then
        exit;
    ClrEol;
    writeln (novoDir);
    writeln;

    if not DirectoryExists (novoDir)  then
    begin
        mensagem ('DV_PASTA_NEX', 0);   { 'Pasta não existe. ' }
        mensagem ('DV_PPADR_MANT',1);   { 'Pasta padrão de trabalho mantida. ' }
        exit;
    end;
    result := novoDir;
end;

{--------------------------------------------------------}
{       ajuda da configuração da pasta padrao de trabalho
{--------------------------------------------------------}

procedure ajudaPastaPadraoTrabalho;
begin
    writeln;
    mensagem ('DV_AJUCPT_OPC', 1);  { 'As opções de definição da pasta padrão de trabalho são:' }
    mensagem ('DV_AJUCPT_T', 1);    { '  T - Treino' }
    mensagem ('DV_AJUCPT_D', 1);    { '  D - Meus Documentos' }
    mensagem ('DV_AJUCPT_A', 1);    { '  A - pasta de trabalho atual' }
    mensagem ('DV_AJUCPT_O', 1);    { '  O - outra pasta' }

    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}
{       seleciona opção de configuração das pastas
{--------------------------------------------------------}

const
    nOpPastaPadraoTrab = 4;

{--------------------------------------------------------}
function selSetasPastaPadraoTrabalho: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var
    n: integer;
const
    tabLetrasPastaPadraoTrabalho: string [nOpPastaPadraoTrab] = 'tdao';

begin
    salvaXY;
    writeln;
    garanteEspacoTela (nOpPastaPadraoTrab);
    popupMenuCria (wherex, wherey, 43, nOpPastaPadraoTrab, MAGENTA);

    MenuAdiciona ('DV_AJUCPT_T');   { '  T - Treino' }
    MenuAdiciona ('DV_AJUCPT_D');   { '  D - Meus Documentos' }
    MenuAdiciona ('DV_AJUCPT_A');   { '  A - pasta de trabalho atual' }
    MenuAdiciona ('DV_AJUCPT_O');   { '  O - outra pasta' }

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasPastaPadraoTrabalho := tabLetrasPastaPadraoTrabalho[n]
    else
        selSetasPastaPadraoTrabalho := ESC;
    restauraXY;
end;

{--------------------------------------------------------}
{       Configuração de pasta padrao de trabalho
{--------------------------------------------------------}

procedure configPastaPadraoTrabalho;

var
    c, c2: char;
    tratandoPastaPradraoTrab: boolean;

    novoDir,
    dirCorren,
    dirPadrao: string;

label
    fim;

begin
    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('DV_CONF_HEADR'));   {'DOSVOX - Configuração'}
    textBackground (BLACK);

    writeln;
    mensagem ('DV_AJUCPT_PRMPT2', 2);   { 'Configuração da pasta padrão de trabalho' }

    getdir (0, dirCorren);
    mensagem ('DV_AJUCPT_CORR', 0);     { 'A pasta corrente é: ' }
    soletra (copy (dirCorren, 1, 2), 0);
    sintetFala (copy (dirCorren, 3, length(dirCorren)-2) , 1);

    dirPadrao := sintAmbiente ('DOSVOX', 'DIRDEFAULT');
    mensagem ('DV_AJUCPT_PADR', 0);     { 'A pasta padrão de trabalho é: ' }
    soletra (copy (dirPadrao, 1, 2), 0);
    sintetFala (copy (dirPadrao, 3, length(dirPadrao)-2) , 1);

    limpaBuf;

    tratandoPastaPradraoTrab := true;
    while tratandoPastaPradraoTrab do
        begin
            writeln;
            textBackground (RED);
            mensagem ('DV_AJUCPT_PRMPT', 0);    { 'Escolha a nova pasta padrão: ' }
            textBackground (BLACK);

            pegaTeclado (c, c2);

            if (c = #0) and ((c2 = CIMA) or (c2 = BAIX) or (c2 = F9)) then
                c := selSetasPastaPadraoTrabalho;

            if c = #$1b then
            begin
                writeln;
                mensagem ('DV_OK', 1);      { 'Ok ! '}
                goto fim;
            end;

            if (c = GOTFOCUS) or (c = NOFOCUS) then
            else
            if (c = #0) and (c2 = F1) then
                 ajudaPastaPadraoTrabalho
            else
            begin
                if sintEcoarOpcao then
                    soletra (c, 1);
                writeln;
                tratandoPastaPradraoTrab := false;
                case upcase(c) of
                   'T': begin
                            novoDir := getPastaTreino;
                            if novoDir <> '' then
                               definePastaPadraoTrabalho (novoDir);
                        end;
                   'D': begin
                            novoDir := getMeusDocumentos;
                            if novoDir <> '' then
                               definePastaPadraoTrabalho (novoDir);
                        end;
                   'A': definePastaPadraoTrabalho (dirCorren);
                   'O': begin
                            novoDir := leNovaPastaPadraoTrabalho;
                            if novoDir <> '' then
                               definePastaPadraoTrabalho (novoDir);
                        end;
                else
                    mensagem ('DV_OPCINV', 1);      { 'Opção inválida.' }
                    tratandoPastaPradraoTrab := true;
                end;
            end;
        end;
fim:
    writeln;
end;

{--------------------------------------------------------}
{       ajuda da configuração de pastas
{--------------------------------------------------------}

procedure ajudaPastas;
begin
    writeln;
    mensagem ('DV_AJUCP_OPC', 1);   { 'As opções de configuração de pastas são:' }
    mensagem ('DV_AJUCP_T',   1);   { '  T - pasta padrão de trabalho' }
    mensagem ('DV_AJUCP_P',   1);   { '  P - configurar pastas preferidas' }

    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}
{       seleciona opção de configuração das pastas
{--------------------------------------------------------}

const
    nOpPastas = 2;

{--------------------------------------------------------}
function selSetasPastas: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var
    n: integer;
const
    tabLetrasPastas: string [nOpPastas] = 'tp';

begin
    salvaXY;
    writeln;
    garanteEspacoTela (nOpPastas);
    popupMenuCria (wherex, wherey, 43, nOpPastas, MAGENTA);

    MenuAdiciona ('DV_AJUCP_T');    { '  T - pasta padrão de trabalho' }
    MenuAdiciona ('DV_AJUCP_P');    { '  P - configurar pastas preferidas' }

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasPastas := tabLetrasPastas[n]
    else
        selSetasPastas := ESC;
    restauraXY;
end;

{--------------------------------------------------------}
{       Configuração de pastas
{--------------------------------------------------------}

procedure configPastas;
var
    c, c2: char;
    tratandoPastas: boolean;

label
    fim;

begin
    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('DV_CONF_HEADR'));   {'DOSVOX - Configuração'}
    textBackground (BLACK);

    tratandoPastas := true;
    while tratandoPastas do
    begin
        writeln;
        textBackground (RED);
        mensagem ('DV_AJUCP_PRMPT', 0);     {'Configurações de pastas - '}
        mensagem ('DV_OQUE', 0);            { 'O que você deseja ? ' }
        textBackground (BLACK);

        pegaTeclado (c, c2);

        if (c = #0) and ((c2 = CIMA) or (c2 = BAIX) or (c2 = F9)) then
            c := selSetasPastas;

        if c = #$1b then
        begin
            writeln;
            mensagem ('DV_OK', 1);      { 'Ok ! '}
            goto fim;
        end;

        if (c = GOTFOCUS) or (c = NOFOCUS) then
        else
        if (c = #0) and (c2 = F1) then
             ajudaPastas
        else
        begin
            if sintEcoarOpcao then
                soletra (c, 1);
            writeln;
            tratandoPastas := false;

            case upcase(c) of
               'T': configPastaPadraoTrabalho;
               'P': editaSecao ('PREFERIDOS');
            else
                mensagem ('DV_OPCINV', 1);       { 'Opção inválida.' }
                tratandoPastas := true;
            end;
        end;
    end;
fim:
    writeln;
end;

{--------------------------------------------------------}
{       seleciona opção de seleção de dispositivo de áudio.
{--------------------------------------------------------}

function selSetasDispAudio: integer;

var
    n: integer;
    t, tamMaximo: integer;
    deviceNames: TStringList;

begin
    deviceNames := TStringList.Create;
    waveGetDeviceNames (deviceNames);

    tamMaximo := 0;
    for n := 0 to deviceNames.Count-1 do
    begin
        t := Length (deviceNames[n]) +2;
        if t > tamMaximo then
            tamMaximo := t;
    end;

    salvaXY;
    writeln;
    garanteEspacoTela (deviceNames.Count);
    popupMenuCria (wherex, wherey, tamMaximo+1, deviceNames.Count, MAGENTA);
    for n := 0 to deviceNames.Count -1 do
        popupMenuAdiciona (' ' + deviceNames[n] + ' ',
                           ' ' + deviceNames[n] + ' ');
    result := popupMenuSeleciona;
    restauraXY;
    deviceNames.Destroy;
end;

{--------------------------------------------------------}
{       Seleção de dispositivo de áudio
{--------------------------------------------------------}

procedure selecionaDispAudio;

var
    c, c2: char;
    devId: integer;
    tratandoDispAudio: boolean;
label
    fim;

begin
    devId := 9999;

    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('DV_CONF_HEADR'));   { 'DOSVOX - Configuração' }
    textBackground (BLACK);

    tratandoDispAudio := true;
    while tratandoDispAudio do
    begin
        writeln;
        textBackground (RED);
        mensagem ('DV_AJUCD_PRMPT', 0);   { 'Selecione o dispositivo de áudio: ' }
        textBackground (BLACK);

        pegaTeclado (c, c2);

        if c = #$1b then
        begin
            writeln;
            mensagem ('DV_OK', 1);      { 'Ok ! '}
            goto fim;
        end;

        if (c = #0) and ((c2 = CIMA) or (c2 = BAIX) or (c2 = F9)) then
            devId := selSetasDispAudio
        else
            continue;

        if devId > 0 then
        begin
            waveSetDevice (devId-1);
            tratandoDispAudio := false;
        end
        else
        begin
            writeln;
            mensagem ('DV_OK', 1);      { 'Ok ! '}
            goto fim;
        end;
    end;

    sintFim;
    inicFala;
    writeln;
    writeln;
    mensagem    ('DV_AJUCD_SEL', 0);            { 'Ok. Selecionado dispositivo de áudio: ' }
    sintWriteln (waveGetDeviceName(devId-1));
fim:
    writeln;
end;

{--------------------------------------------------------}
{       ajuda da configuração de Fala Gravada
{--------------------------------------------------------}

procedure ajudaFalaGravada;
begin
    writeln;
    mensagem ('DV_AJUCF_OPC', 1);   { 'As opções de fala gravada são: ' }
    mensagem ('DV_AJUCF_N',   1);   { '  N - velocidade normal' }
    mensagem ('DV_AJUCF_R',   1);   { '  R - voz mais rápida' }
    mensagem ('DV_AJUCF_B',   1);   { '  B - voz de boneca' }

    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}
{       seleciona opção de configuração de fala gravada
{--------------------------------------------------------}

const
    nOpFalaGrav = 3;
    tabLetrasFalaGravada: string [nOpFalaGrav] = 'nrb';

{--------------------------------------------------------}
function selSetasFalaGravada: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var
    n: integer;

begin
    salvaXY;
    writeln;
    garanteEspacoTela (nOpFalaGrav);
    popupMenuCria (wherex, wherey, 27, nOpFalaGrav, MAGENTA);

    MenuAdiciona ('DV_AJUCF_N');    { '  N - velocidade normal' }
    MenuAdiciona ('DV_AJUCF_R');    { '  R - voz mais rápida' }
    MenuAdiciona ('DV_AJUCF_B');    { '  B - voz de boneca' }

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasFalaGravada := tabLetrasFalaGravada[n]
    else
        selSetasFalaGravada := ESC;
    restauraXY;
end;

{--------------------------------------------------------}
{       Configuração de fala gravada
{--------------------------------------------------------}

procedure configFalaGravada;

var
    c, c2:  char;
    erro,
    veloc:  integer;
    tratandoFalaGrav: boolean;
label
    fim;

begin
    val (sintAmbiente ('TRADUTOR', 'VELOCIDADE'), veloc, erro);
    if erro <> 0 then veloc := 3;
    if not veloc in [3..5] then veloc := 3;

    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('DV_CONF_HEADR'));   { 'DOSVOX - Configuração' }
    textBackground (BLACK);

    tratandoFalaGrav := true;
    while tratandoFalaGrav do
    begin
        writeln;
        textBackground (RED);
        mensagem ('DV_AJUCF_PRMPT', 0);   { 'Selecione a velocidade da fala gravada: ' }
        textBackground (BLACK);

        pegaTeclado (c, c2);

        if (c = #0) and ((c2 = CIMA) or (c2 = BAIX) or (c2 = F9)) then
            c := selSetasFalaGravada;

        if c = #$1b then
            begin
                writeln;
                mensagem ('DV_OK', 1);      { 'Ok ! '}
                goto fim;
            end;

        if (c = GOTFOCUS) or (c = NOFOCUS) then
        else
        if (c = #0) and (c2 = F1) then
            ajudaFalaGravada
        else
        begin
            if sintEcoarOpcao then
                soletra (c, 1);
            tratandoFalaGrav := false;

            case upcase(c) of          { 'NRB' - tabLetrasFalaGravada  }
                'N': veloc := 3;
                'R': veloc := 4;
                'B': veloc := 5;
            else
                mensagem ('DV_OPCINV', 1);       { 'Opção inválida.' }
                tratandoFalaGrav := true;
            end;
        end;
    end;

    sintGravaAmbiente ('TRADUTOR', 'VELOCIDADE', intToStr(veloc));

    sintFim;
    inicFala;
fim:
    writeln;
end;

{--------------------------------------------------------}
{      monta as informações de uma voz para exibir
{--------------------------------------------------------}

procedure montaInformVoz (infoSapi: TInfoSapi; out nome, genero, idioma: string);

type
    TLCID = record
        code: string[5];
        number: integer;
        language: string;
    end;

const
    NLCID = 45;
    LCID: array [1..NLCID] of TLCID = (
        {English}                       (code: 'en';    number: $0009; language: 'inglês'),                     //9
        {English - Australia}           (code: 'en-au'; number: $0C09; language: 'inglês australiano'),         //3081
        {English - Belize}              (code: 'en-bz'; number: $2809; language: 'inglês belizenho'),           //10249
        {English - Canada}              (code: 'en-ca'; number: $1009; language: 'inglês canadense'),           //4105
        {English - Ireland}             (code: 'en-ie'; number: $1809; language: 'inglês irlandês'),            //6153
        {English - Jamaica}             (code: 'en-jm'; number: $2009; language: 'inglês jamaicano'),           //8201
        {English - New Zealand}         (code: 'en-nz'; number: $1409; language: 'inglês neozelandês'),         //5129
        {English - South Africa}        (code: 'en-za'; number: $1C09; language: 'inglês sul-africano'),        //7177
        {English - Trinidad}            (code: 'en-tt'; number: $2C09; language: 'inglês trinitino'),           //11273
        {English - United Kingdom}      (code: 'en-gb'; number: $0809; language: 'inglês britânico'),           //2057
        {English - United States}       (code: 'en-us'; number: $0409; language: 'inglês americano'),           //1033
        {French - Standard}             (code: 'fr';    number: $040C; language: 'francês'),                    //1036
        {French - Belgium}              (code: 'fr-be'; number: $080C; language: 'francês belga'),              //2060
        {French - Canada}               (code: 'fr-ca'; number: $0C0C; language: 'francês canadense'),          //3084
        {French - Luxembourg}           (code: 'fr-lu'; number: $140C; language: 'francês luxemburguês'),       //5132
        {French - Switzerland}          (code: 'fr-ch'; number: $100C; language: 'francês suíço'),              //4108
        {German - Standard}             (code: 'de';    number: $0407; language: 'alemão'),                     //1031
        {German - Austrian}             (code: 'de-at'; number: $0C07; language: 'alemão austríaco'),           //3079
        {German - Lichtenstein}         (code: 'de-li'; number: $1407; language: 'alemão liechtensteiniense'),  //5127
        {German - Luxembourg}           (code: 'de-lu'; number: $1007; language: 'alemão luxemburguês'),        //4103
        {German - Switzerland}          (code: 'de-ch'; number: $0807; language: 'alemão suíço'),               //2055
        {Italian - Standard}            (code: 'it';    number: $0410; language: 'italiano'),                   //1040
        {Italian - Switzerland}         (code: 'it-ch'; number: $0810; language: 'italiano suíço'),             //2064
        {Portuguese - Standard}         (code: 'pt';    number: $0816; language: 'português '),                 //2070
        {Portuguese - Brazil}           (code: 'pt-br'; number: $0416; language: 'português brasileiro'),       //1046
        {Spanish - Standard}            (code: 'es';    number: $040A; language: 'espanhol padrão'),            //1034
        {Spanish - Spain}               (code: 'es-es'; number: $0C0A; language: 'espanhol da Espanha'),        //3082
        {Spanish - Argentina}           (code: 'es-ar'; number: $2C0A; language: 'espanhol argentino'),         //11274
        {Spanish - Bolivia}             (code: 'es-bo'; number: $400A; language: 'espanhol boliviano'),         //16394
        {Spanish - Chile}               (code: 'es-cl'; number: $340A; language: 'espanhol chileno'),           //13322
        {Spanish - Columbia}            (code: 'es-co'; number: $240A; language: 'espanhol colombiano'),        //9226
        {Spanish - Costa Rica}          (code: 'es-cr'; number: $140A; language: 'espanhol costarriquenho'),    //5130
        {Spanish - Dominican Republic}  (code: 'es-do'; number: $1C0A; language: 'espanhol dominicano'),        //7178
        {Spanish - Ecuador}             (code: 'es-ec'; number: $300A; language: 'espanhol equatoriano'),       //12298
        {Spanish - Guatemala}           (code: 'es-gt'; number: $100A; language: 'espanhol quatemalteco'),      //4106
        {Spanish - Honduras}            (code: 'es-hn'; number: $480A; language: 'espanhol hondurenho'),        //18442
        {Spanish - Mexico}              (code: 'es-mx'; number: $080A; language: 'espanhol mexicano'),          //2058
        {Spanish - Nicaragua}           (code: 'es-ni'; number: $4C0A; language: 'espanhol nicaraguense'),      //19466
        {Spanish - Panama}              (code: 'es-pa'; number: $180A; language: 'espanhol panamenho'),         //6154
        {Spanish - Peru}                (code: 'es-pe'; number: $280A; language: 'espanhol peruano'),           //10250
        {Spanish - Puerto Rico}         (code: 'es-pr'; number: $500A; language: 'espanhol portorriquenho'),    //20490
        {Spanish - Paraguay}            (code: 'es-py'; number: $3C0A; language: 'espanhol paraguaio'),         //15370
        {Spanish - El Salvador}         (code: 'es-sv'; number: $440A; language: 'espanhol salvadorenho'),      //17418
        {Spanish - Uruguay}             (code: 'es-uy'; number: $380A; language: 'espanhol uruguaio'),          //14346
        {Spanish - Venezuela}           (code: 'es-ve'; number: $200A; language: 'espanhol venezuelano')        //8202
    );

const
    DELIM: char = ';';

var
    locale: string;
    i: integer;
begin
    nome := infoSapi.nomeVoz;
    if copy (nome, 1, 10) = 'Microsoft ' then
         delete (nome, 1, 10)
    else
    if copy (nome, 1, 9) = 'ScanSoft ' then
    begin
        delete (nome, 1, 9);
        if (pos('_', nome) <> 0) then delete (nome, pos('_', nome), 99);
    end
    else
    if pos ('male voice', nome) <> 0 then
        nome := infoSapi.modo
    else
    //Exceção: deltaTalk retorna nome correto em outra propriedade
    if (ansiUpperCase(nome) = 'HOMEM') or
        (ansiUpperCase(nome) = 'MULHER') then
            nome   := infoSapi.modo;

    locale := 'Desconhecida';
    idioma := 'Desconhecida';
    for i := 1 to NLCID do
        if infoSapi.lingua = LCID[i].number then
        begin
            locale := LCID[i].code;
            idioma := LCID[i].language;
            break;
        end;

    // exceção: a voz Juliana não tem a informação registrada

    if nome = 'Juliana' then infoSapi.sexo := 1;

    // Exceção: A voz Chico Via Voice sapi 4 é criança, não Neltra
    if nome = 'Chico' then infoSapi.sexo := 3;

    case infoSapi.sexo of
        0: genero := 'Neutra';
        1: genero := 'Feminina';
        2: genero := 'Masculina';
        3: genero := 'Criança';   // Para a voz Chico Via VOice sapi 4
    end;
end;

{--------------------------------------------------------}
{      monta tabela com as informações das vozes
{--------------------------------------------------------}

type
    PVozSapi = ^TVozSapi;
    TVozSapi = record
        tipoSAPI: integer;
        nVozSAPI: longint;
        nomeVoz:   string;
        generoVoz: string;
        idiomaVoz: string;
    end;

var
    tabVozesSAPI: TList;

{--------------------------------------------------------}

procedure montaTabelaDeVozes;
var
    sapiAtual, vozAtual, velocAtual, tonalAtual: integer;

    param: TParamVoz;
    infoSapi: TInfoSapi;
    umaVoz: PVozSapi;

    i, n, maxVozes, tipo: integer;
    salvaSapiPresente: boolean;
begin
    tabVozesSapi := TList.Create;

    sapiAtual := 0;
    vozAtual := 0;
    velocAtual := 0;
    tonalAtual := 0;

    salvaSapiPresente := sapiPresente;
    if sapiPresente then
        begin
            sapiPegaParam (param);
            sapiAtual := param.tipoSapi;
            vozAtual  := param.voz;
            velocAtual := param.velocidade;
            tonalAtual := param.tom;

            sapiFim;
            sapiPresente := false;
        end;

    new (umaVoz);        // insere a voz nativa
    umavoz.nomeVoz := 'Voz Nativa';
    umavoz.tipoSAPI := 0;
    umavoz.nVozSAPI := 0;
    umavoz.generoVoz := 'Masculino';
    umavoz.idiomaVoz := 'português brasileiro';
    tabVozesSAPI.Add(umaVoz);

    for i := 3 to 6 do
        begin
            if i = 6 then tipo := 54
                     else tipo := i;
            try
                sapiPresente := sapiInic (1, 0, 0, tipo, '');
            except
            end;

            if sapiPresente then
                begin
                    maxVozes := sapiNumVozes;    // mesmo que não inicialize numVozes contém o número correto
                    for n := 1 to maxVozes do
                        begin
                            new (umaVoz);
                            umavoz.tipoSAPI := tipo;
                            umavoz.nVozSAPI := n;
                            sapiInfo(n, infoSapi);
                            montaInformVoz (infoSapi, umavoz.nomeVoz, umavoz.generoVoz, umavoz.idiomaVoz);
                            tabVozesSAPI.Add(umaVoz);
                        end;
                    sapiFim;
            end;
        end;

    if salvaSapiPresente then
        sapiPresente := sapiInic (vozAtual, velocAtual, tonalAtual, sapiAtual, '')
    else
        begin
            sintFim;
            inicFala;
        end;
end;

{--------------------------------------------------------}
{                destroi a tabela de vozes
{--------------------------------------------------------}

procedure destroiTabVozes;
var i: integer;
    p: PVozSapi;
begin
    for i := 0 to tabVozesSAPI.Count-1 do
        begin
            p := tabVozesSAPI[i];
            dispose (p);
        end;

    tabVozesSAPI.Free;
end;

{--------------------------------------------------------}
{           escolhe o sintetizador com as setas
{--------------------------------------------------------}

function escolheSint: integer;   // retorna o número na tabela
var i, y, nitem: integer;
    p: PVozSapi;
begin
    mensagem ('DV_UMMOMENTO', 0);       { 'Um momento...' }
    gotoxy (1, wherey);
    while sintFalando do waitMessage;

    montaTabelaDeVozes;

    y := wherey;
    mensagem ('DV_SINTET', 1);   {'Sintetizador, use as setas para selecionar'}

    popupMenuCria (1, wherey, 80, 24,  MAGENTA);
    for i := 0 to tabVozesSapi.count-1 do
        begin
            p := tabVozesSAPI[i];
            popupMenuAdiciona ('', p^.nomeVoz + '; ' + p^.generoVoz + '; ' + p^.idiomaVoz);
        end;

    nitem := popupMenuSeleciona;
    if (nitem > 0) and (nitem <= tabVozesSapi.count) then
        result := nitem-1
    else
        result := -1;

    limpaBaixo (y);

    writeln;
    if (nitem >= 1) and (nItem < tabVozesSapi.count) then
        begin
            p := tabVozesSAPI[nitem-1];
            sintWriteln (p^.nomeVoz);
        end;

end;

{--------------------------------------------------------}
{                ativa a voz selecionada
{--------------------------------------------------------}

procedure ativaVoz (tipoSapi, nvoz: integer);
var
    veloc, tom: integer;
    s: string;
    erro: integer;
begin
    s := trim (sintAmbiente ('TRADUTOR', 'VELOCIDADE'));
    val (s, veloc, erro);
    if erro <> 0 then veloc := 3;

    if tipoSapi = 0 then
        begin
            sintGravaAmbiente ('TRADUTOR', 'SAPI', 'NÃO');
            sintReinic(veloc, false, 0, 0, 0, 0);
            exit;
        end;

        sintGravaAmbiente ('TRADUTOR', 'SAPI', 'SIM');
        sintGravaAmbiente ('SERVFALA', 'TIPOSAPI', intToStr(tipoSapi));
        sintGravaAmbiente ('SERVFALA', 'VOZ', intToStr(nvoz));

        if tipoSapi = 4 then
            begin
                veloc := 220;
                tom := 110;
            end
        else
            begin
                veloc := 0;
                tom := 0;
            end;

        sintGravaAmbiente ('SERVFALA', 'VELOCIDADE', intToStr(veloc));
        sintGravaAmbiente ('SERVFALA', 'TOM', intToStr(tom));

        sintReinic(veloc, true, tipoSapi, nvoz, veloc, tom);
end;

{--------------------------------------------------------}
{          configura velocidade e tonalidade
{--------------------------------------------------------}

procedure configVelocTomVoz (tipoSapi, vozSapi: integer);
var param: TParamVoz;
    velsapi, tomSapi: integer;
    veloc, erro: integer;
    s: string;
begin
    s := trim (sintAmbiente ('TRADUTOR', 'VELOCIDADE'));
    val (s, veloc, erro);
    if erro <> 0 then veloc := 3;

    if tipoSapi = 4 then
        begin
            sapiPegaParam(param);

            mensagem ('DV_VELOCS', 0);  {'Velocidade '}
            sintWriteint (param.minVeloc);
            sintWrite (' a ');
            sintWriteint (param.maxVeloc);
            write (': ');
            sintReadInt (velSapi);

            mensagem ('DV_TONALS', 0);  {'Tonalidade '}
            sintWrite (intToStr(param.minTom) + ' a ' + intToStr(param.maxTom));
            write (': ');
            sintReadInt (tomSapi);

            if (velSapi < param.minVeloc) or
               (velSapi > param.maxVeloc) then
                   velSapi := param.velocidade;
            if (tomSapi < param.minTom) or
               (tomSapi > param.maxTom)  then
                   tomSapi := param.tom;
        end
    else
        begin
            mensagem ('DV_AJUCS_V', 0);  {'Velocidade (-10 a 10) '}
            sintReadInt (velSapi);
            mensagem ('DV_AJUCS_T', 0);  {'Tonalidade (-10 a 10) '}
            sintReadInt (tomSapi);

            if (velSapi < -10) or (velSapi > 10) then velSapi := 0;
            if (tomSapi < -10) or (tomSapi > 10) then tomSapi := 0;
        end;

    sintGravaAmbiente ('SERVFALA', 'VELOCIDADE', intToStr(velSapi));
    sintGravaAmbiente ('SERVFALA', 'TOM',        intToStr(tomSapi));

    sintReinic (veloc, true, tipoSapi, vozSapi, velSapi, tomSapi);
end;

{--------------------------------------------------------}
{            exibe dados do sintetizador atual
{--------------------------------------------------------}

procedure mostraSintetizadorAtual;
var
    paramVozAtual: TParamVoz;
    infoSapi: TInfoSAPI;
begin
    mensagem ('DV_AJUCS_SINT', 0);  { 'Sintetizador ativado: ' }

    sapiPegaParam(paramVozAtual);
    sapiInfo(paramVozAtual.voz, infoSapi);
    //Exceção: deltaTalk retorna nome correto em outra propriedade
    if (ansiUpperCase(infoSapi.nomeVoz) = 'HOMEM') or
        (ansiUpperCase(infoSapi.nomeVoz) = 'MULHER') then
            sintWriteln(infoSapi.modo)
    else
        sintWriteln (infoSapi.nomeVoz);
    mensagem ('DV_VELOCS', 0);
    sintWriteint (paramVozAtual.velocidade);
    writeln;
    mensagem ('DV_TONALS', 0);
    sintWriteint (paramVozAtual.tom);
    writeln;
end;

{--------------------------------------------------------}
{            escolhe uma nova voz com as setas
{--------------------------------------------------------}

procedure escolheNovaVoz;
var p: PVozSapi;
    nVozEscolhida: integer;
begin
    tabVozesSAPI := TList.Create;

    nVozEscolhida := escolheSint;
    if nVozEscolhida >= 0 then
        begin
            p := tabVozesSapi[nVozEscolhida];
            ativaVoz (p^.tipoSAPI, p^.nVozSAPI);
            if nVozEscolhida <> 0 then
                configVelocTomVoz (p^.tipoSAPI, p^.nVozSAPI);
        end;

    destroiTabVozes;
end;

{--------------------------------------------------------}
{                configuração de fala sintetizada
{--------------------------------------------------------}

procedure configFalaSintetizada;
var
    c: char;
    paramVozAtual: TParamVoz;

begin
    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('DV_CONF_HEADR'));   {'DOSVOX - Configuração'}
    textBackground (BLACK);
    writeln;

    mensagem ('DV_AJUCS_PRMPT', 2);     {'Configurações de fala sintetizada'}

    if not sapiPresente then
        mensagem ('DV_AJUCS_NAT',  2)   { 'Fala nativa ativada' }
    else
        mostraSintetizadorAtual;

    mensagem ('DV_CONFIRMA', 0);    {'Confirma? '}
    mensagem ('DV_SIMNAO', 0);      {' (S/N)? '}
    c := popupMenuPorLetra('SN');
    if (c = ESC) then exit;

    if monitAtiva then
        fimMonitoracao(true);

    writeln;
    if c = 'N' then
        escolheNovaVoz
    else
        begin
            if sapiPresente then
                begin
                    sapiPegaParam(paramVozAtual);
                    configVelocTomVoz (paramVozAtual.tipoSapi, paramVozAtual.voz);
                end;
        end;

    writeln;
    if not sapiPresente then
        mensagem ('DV_AJUCS_NAT',  2)   { 'Fala nativa ativada' }
    else
        mostraSintetizadorAtual;

    writeln;
end;

{--------------------------------------------------------}
{   configuração do retorno sonoro em cópias de arquivos.
{--------------------------------------------------------}

procedure configRetornoCopia;

var
    s: string;
    sons: ShortString;
    p: integer;
    erro: integer;
    escolhido: ShortString;

const
    instrum: string =
        '1 Piano|'+
        '2 Piano|'+
        '3 Piano eléctro-acústico|'+
        '4 Honky-tonk|'+
        '5 Piano eléctrico|'+
        '6 Piano sintético|'+
        '7 Cravo|'+
        '8 Clavineta|'+
        '9 Celesta|'+
        '10 Glockenspiel|'+
        '11 Caixa de música|'+
        '12 Vibrafone|'+
        '13 Marimba|'+
        '14 Xilofone|'+
        '15 Carrilhão de orquestra|'+
        '16 Santur|'+
        '17 Órgão Hammond|'+
        '18 Órgão percussivo|'+
        '19 Órgão de rock|'+
        '20 Órgão de tubos|'+
        '21 Harmónio|'+
        '22 Acordeão|'+
        '23 Harmónica|'+
        '24 Bandoneón|'+
        '25 Violão de cordas de nylon|'+
        '26 Violão de cordas de aço|'+
        '27 Guitarra semi-acústica|'+
        '28 Guitarra elétrica|'+
        '29 Guitarra abafada|'+
        '30 Guitarra elétrica com saturação|'+
        '31 Guitarra elétrica com distorção|'+
        '32 Harmónicos|'+
        '33 Contrabaixo dedilhado|'+
        '34 Baixo elétrico dedilhado|'+
        '35 Baixo elétrico com palhetado|'+
        '36 Baixo elétrico sem trastos|'+
        '37 Baixo elétrico pop|'+
        '38 Baixo elétrico percutido|'+
        '39 Baixo sintético analógico|'+
        '40 Baixo sintético digital|'+
        '41 Violino|'+
        '42 Viola|'+
        '43 Violoncelo|'+
        '44 Contrabaixo|'+
        '45 Cordas em trêmulo|'+
        '46 Cordas em pizzicatto|'+
        '47 Harpa|'+
        '48 Tímpanos|'+
        '49 Orquestra de cordas 1|'+
        '50 Orquestra de cordas lentas|'+
        '51 Cordas sintéticas|'+
        '52 Cordas sintéticas ressonantes|'+
        '53 Coro|'+
        '54 Voz humana (solista)|'+
        '55 Voz humana (sintética)|'+
        '56 Batida orquestral|'+
        '57 Trompete|'+
        '58 Trombone|'+
        '59 Tuba|'+
        '60 Trompete com surdina|'+
        '61 Trompa|'+
        '62 Metais|'+
        '63 Metais sintéticos - trompetes e trombones|'+
        '64 Metais sintéticos - trompas|'+
        '65 Saxofone soprano|'+
        '66 Saxofone alto|'+
        '67 Saxofone tenor|'+
        '68 Saxofone barítono|'+
        '69 Oboé|'+
        '70 Corne inglês|'+
        '71 Fagote|'+
        '72 Clarinete|'+
        '73 Flautim|'+
        '74 Flauta transversal|'+
        '75 Flauta de bisel|'+
        '76 Flauta de Pã|'+
        '77 Sopro em gargalo de garrafa|'+
        '78 Shakuhachi|'+
        '79 Assobio|'+
        '80 Ocarina|'+
        '81 Onda quadrada|'+
        '82 Onda dente de serra|'+
        '83 Calíope|'+
        '84 Chiff Lead|'+
        '85 Charango sintético|'+
        '86 Solo vox|'+
        '87 dente de serra em quintas|'+
        '88 Baixo e solo|'+
        '89 Fundo New Age|'+
        '90 Fundo morno|'+
        '91 Polysynth|'+
        '92 Space voice|'+
        '93 Vidro friccionado|'+
        '94 Fundo metálico|'+
        '95 Fundo halo|'+
        '96 Fundo com abertura do filtro|'+
        '97 Chuva de gelo|'+
        '98 Trilha sonora|'+
        '99 Cristal|'+
        '100 Atmosfera|'+
        '101 Brilhos|'+
        '102 Goblins|'+
        '103 Ecos|'+
        '104 Ficção científica|'+
        '105 Sitar|'+
        '106 Banjo|'+
        '107 Shamisen|'+
        '108 Koto|'+
        '109 Kalimba|'+
        '110 Gaita de foles|'+
        '111 Rabeca|'+
        '112 Shehnai|'+
        '113 Sino|'+
        '114 Agogô|'+
        '115 Tambor de aço|'+
        '116 Bloco de madeira|'+
        '117 Taiko|'+
        '118 Címbalos acústicos|'+
        '119 Címbalos sintéticos|'+
        '120 Prato revertido|'+
        '121 Corda de violão riscada|'+
        '122 Respiração|'+
        '123 Ondas do mar|'+
        '124 Passarinho|'+
        '125 Telefone|'+
        '126 Helicóptero|'+
        '127 Aplausos|'+
        '128 Tiro';

begin
    sons := uppercase (sintAmbiente ('DOSVOX', 'SONSEMCOPIADEARQUIVOS'));
    copiaFazSintClek := sons = 'CLEKS';
    if not copiaFazSintClek then sons := 'TONS MUSICAIS';

    val (sintAmbiente ('DOSVOX', 'INSTRUMEMCOPIADEARQUIVOS'), instrumentoEmCopiaDeArquivo, erro);
    if erro <> 0 then instrumentoEmCopiaDeArquivo := 10;
    if not instrumentoEmCopiaDeArquivo in [1..127] then instrumentoEmCopiaDeArquivo := 10;

    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('DV_CONF_HEADR'));   {'DOSVOX - Configuração'}
    textBackground (BLACK);
    writeln;

    escolhido := intToStr (instrumentoEmCopiaDeArquivo);
    p := pos (escolhido+' ', instrum);
    if p <> 0 then
    begin
        escolhido := copy (instrum, p, length(instrum) - p +1);
        p := pos ('|', escolhido);
        if p <> 0 then
            Delete (escolhido, p, length(escolhido) - p +1);
    end;

    mensagem ('DV_AJUCC_PRMPT', 2);     { 'Configure o retorno sonoro em cópias de arquivos' }

    formCria;
    formCampoLista ('DV_AJUCC_RETORNO', pegaTextoMensagem ('DV_AJUCC_RETORNO'), sons, 50, 'CLEKS|TONS MUSICAIS'); { 'Retorno sonoro' }
    formCampoLista ('DV_AJUCC_INSTRUM', pegaTextoMensagem ('DV_AJUCC_INSTRUM'), escolhido, length(instrum), instrum);     { 'Instrumento (de 1 a 127)' }
    formEdita (true);
    writeln;

    copiaFazSintClek := sons = 'CLEKS';

    if copiaFazSintClek then s := 'CLEKS' else s := 'TONS MUSICIAS';
    sintGravaAmbiente ('DOSVOX', 'SONSEMCOPIADEARQUIVOS', s);

    escolhido := trim(escolhido);
    p := pos(' ', escolhido);
    if p <> 0 then
        delete (escolhido, p, length(escolhido)-p+1);
    p := StrToInt(escolhido);
    if p in [1..127] then
        instrumentoEmCopiaDeArquivo := p;

    sintGravaAmbiente ('DOSVOX', 'INSTRUMEMCOPIADEARQUIVOS',
                        IntToStr(instrumentoEmCopiaDeArquivo));
    if copiaFazSintClek then
    begin
        sintClek;  sintClek;  sintClek;  sintClek;  sintClek;
    end
    else
    begin
        abreMidi (0);
        selInstrumento(instrumentoEmCopiaDeArquivo);
        for p := 1 to 50 do
            tocaNota (2, p, 50);
        fechaMidi;
    end;
    mensagem ('DV_AJUCC_OK', 2);  { 'Ok. Retorno sonoro configurado.' }
end;

{--------------------------------------------------------}
{                configuração de inicialização do Dosvox
{--------------------------------------------------------}

procedure configInicia;

const
    RegKey = 'Software\Microsoft\Windows\CurrentVersion\Run';

var
    iniciaWin: boolean;
    s: string;
    salvaTamRotulosForm: integer;
    ok: boolean;

begin
    s := sintAmbiente ('DOSVOX', 'INICIAWIN');
    iniciaWin := (s <> '') and (upcase(s[1]) = 'S');

    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('DV_CONF_HEADR'));   {'DOSVOX - Configuração'}
    textBackground (BLACK);
    writeln;

    mensagem ('DV_AJUCW_PRMPT', 2);     { 'Selecione opção de iniciar o Dosvox' }

    salvaTamRotulosForm := tamRotulosForm;
    tamRotulosForm := 31;
    formCria;

    formCampoBool ('DV_AJUCW_PRMPT2', pegaTextoMensagem ('DV_AJUCW_PRMPT2'), iniciaWin); { 'Iniciar o Dosvox com o Windows' }

    formEdita (true);
    writeln;
    tamRotulosForm := salvaTamRotulosForm;

    s := sintAmbiente('DOSVOX', 'PGMDOSVOX');
    if s = '' then
        s := 'c:\winvox';
    if s[length(s)] = '\' then
        s := s + 'dosvox.exe'
    else
        s := s + '\' + 'dosvox.exe';

    try
        if iniciaWin then
            ok := minireg.RegSetString(HKEY_CURRENT_USER, RegKey+'\Dosvox', s)
        else
            ok := minireg.RegDelValue(HKEY_CURRENT_USER, RegKey+'\Dosvox');
    except
        ok := false;
    end;

    if not ok then
        begin
            mensagem ('DV_AJUCW_ERR', 2);   { 'Erro: Não consegui modificar inicialização automática do Dosvox.' }
            exit;
        end;

    if iniciaWin then s := 'SIM' else s := 'NAO';
    sintGravaAmbiente ('DOSVOX', 'INICIAWIN', s);
    if iniciaWin then
        mensagem ('DV_AJUCW_OKS', 2)   { 'Ok. O Dosvox será iniciado com o Windows.' }
    else
        mensagem ('DV_AJUCW_OKN', 2);  { 'Ok. O Dosvox não será iniciado com o Windows.' }
end;

{--------------------------------------------------------}
{                configura o legado
{--------------------------------------------------------}

procedure configLegado;
var c: char;
    s: string;
begin
    mensagem ('DV_LEGADO', 0);   {'Aceita configurações feitas no dosvox 4.x? '}
    c := popupMenuPorLetra('SN');
    writeln;

    if (c = ESC) then exit;

    sintAceitaLegado := false;
    if c = 'S' then s := 'SIM' else s := 'NAO';
    sintGravaAmbiente('DOSVOX', 'LEGADO', s);

    sintAceitaLegado := c = 'S';
end;

{--------------------------------------------------------}
{        Seleciona programas mais rapido ou padrão
{--------------------------------------------------------}

procedure deixarProgramasMaisRapidos (veloz: boolean);
var
    c: char;
    nomeArq, DirConfigs: string;
begin
    repeat
        if veloz then
            mensagem ('DV_DVVELOZ', 0)      {'Deseja deixar os programas mais rápidos? '}
        else
            mensagem ('DV_DVPADRAO', 0);    {'Deseja deixar os programas na velocidade padrão? '}
        c := popupMenuPorLetra('SN');
        writeln;
        if not (c in ['S', 'N', ESC]) then
            mensagem ('DV_AJUTIL', 1);  {'  Pode usar as setas para selecionar ou conhecer todas as opções'}
    until c in ['S', 'N',ESC];

    if c in ['N', ESC] then
        begin
            mensagem ('DV_DESIST', 1);     {'Desistiu...'}
            exit;
        end;

    regGetString (HKEY_CURRENT_USER,
        'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\AppData', DirConfigs);
    DirConfigs := DirConfigs + '\Dosvox';

    if veloz then
        nomeArq := DirConfigs + '\dvVeloz.ini'
    else
        nomeArq := DirConfigs + '\dvPadrao.ini';

    atualizaAtu (nomeArq, false);
end;

{--------------------------------------------------------}
{                Recupera configuração original
{--------------------------------------------------------}

procedure recuperaConfigOriginal;
var
    c: char;
    DirConfigs, dirDoExecutavel, novoNome: string;
    arq: file;
    pnomeDir: array [0..255] of char;

begin
    repeat
        mensagem ('DV_DESRECCONF', 0);   {'Deseja recuperar a configuração original de instalação?'}
        c := popupMenuPorLetra('SN');
        writeln;
        if not (c in ['S', 'N', ESC]) then
            mensagem ('DV_AJUTIL', 1);  {'  Pode usar as setas para selecionar ou conhecer todas as opções'}
    until c in ['S', 'N',ESC];

    if c in ['N', ESC] then
        begin
            mensagem ('DV_DESIST', 1);     {'Desistiu...'}
            exit;
        end;

    regGetString (HKEY_CURRENT_USER,
        'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\AppData', DirConfigs);
    DirConfigs := DirConfigs + '\Dosvox';

    GetModuleFileName (0, pnomeDir, 255);
    dirDoExecutavel := ExtractFilePath(strPas (pnomeDir));
    delete (dirDoExecutavel, length(dirDoExecutavel), 1);

    if not fileExists (dirDoExecutavel + '\iniOriginal\Dosvox.ini') then
        begin
            mensagem ('DV_ININAO', 1); {'Dosvox.ini não foi encontrado no diretório "iniOriginal"'}
            mensagem ('DV_OPCANCEL', 1); {'Certo, operação foi cancelada'}
            exit;
        end;

    if fileExists (dirConfigs+ '\Dosvox.ini') then
        begin
            if fileExists (dirConfigs+ '\Dosvox.old') then deleteFile (dirConfigs+ '\Dosvox.old');
            novoNome := ChangeFileExt(dirConfigs+ '\Dosvox.ini', '.old'); //Backup do dosvox.ini atual
            assignFile (arq, dirConfigs+ '\Dosvox.ini');
            {$I-} rename (arq, novoNome);  {$I+}
            if ioresult <> 0 then
                begin
                    mensagem ('DV_PROTEG', 0);      { 'Arquivo está protegido para regravação' }
                    write (' ');
                    mensagem ('DV_OUJAEXI', 1);  { 'ou já existe' }
                    exit;
                end;
        end;

    sintclek; sintclek;
    mensagem ('DV_VOLTARDV', 1); {'Tecle CTRL+ALT+D para voltar ao Dosvox.'}
//    mensagem ('DV_FIMDV', 1);    {'Fim do DOSVOX.'}
    mensagem ('DV_TRAB', 1);     {'Trabalhar com você é sempre bom !' }
    mensagem ('DV_TCHAU', 1);    {'Tchau !' }
    SintFim;
    ReleaseMutex (hMutex);
    CloseHandle  (hMutex);
    doneWinCrt;
end;

{--------------------------------------------------------}
{             ajuda da configuração avançada
{--------------------------------------------------------}

procedure ajudaAvancada;
begin
    writeln;
    mensagem ('DV_AJUCG_OPC', 1);   { 'As opções de configuração avançada são:' }
    mensagem ('DV_AJUCG_E',   1);   { '  E - editar uma seção' }
    mensagem ('DV_AJUCG_I',   1);   { '  I - incluir item em uma seção' }
    mensagem ('DV_AJUCG_R',   1);   { '  R - remover item de uma seção' }
    mensagem ('DV_AJUCG_C',   1);   { '  C - criar nova seção' }
    mensagem ('DV_AJUCG_M',   1);   { '  M - editar os macrocomandos de F2 a F7' }
    mensagem ('DV_AJUCG_L',   1);   { '  L - configurações do legado da versão 4' }
    mensagem ('DV_AJUCG_O',   1);   { '  O - retornar as configurações originais'}
    mensagem ('DV_AJUTIL',    1);   { '  Pode usar as setas para selecionar ou conhecer todas as opções'} 

    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}
{            seleciona a opção de configuração avançada
{--------------------------------------------------------}

function selSetasAvancada: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

const
    tabLetrasAvancada: string = 'eircmlvpo';

var n: integer;

begin
    salvaXY;
    writeln;
    garanteEspacoTela (length(tabLetrasAvancada));
    popupMenuCria (wherex, wherey, 44, length(tabLetrasAvancada), MAGENTA);

    MenuAdiciona ('DV_AJUCG_E');   { '  E - editar uma seção' }
    MenuAdiciona ('DV_AJUCG_I');   { '  I - incluir item em uma seção' }
    MenuAdiciona ('DV_AJUCG_R');   { '  R - remover item de uma seção' }
    MenuAdiciona ('DV_AJUCG_C');   { '  C - criar nova seção' }
    MenuAdiciona ('DV_AJUCG_M');   { '  M - editar os macrocomandos de F2 a F7' }
    MenuAdiciona ('DV_AJUCG_L');   { '  L - configurações do legado da versão 4' }
    MenuAdiciona ('DV_AJUCG_V');   { '  V - aplicar mais velocidade nos programas' }
    MenuAdiciona ('DV_AJUCG_P');   { '  P - aplicar velocidade padrão nos programas' }
    MenuAdiciona ('DV_AJUCG_O');   { '  O - retornar as configurações originais' }

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasAvancada := tabLetrasAvancada[n]
    else
        selSetasAvancada := ESC;
    restauraXY;
end;

{--------------------------------------------------------}
{                configuração avancada
{--------------------------------------------------------}

procedure configAvancada;
var c, c2: char;
    tratandoAvancada: boolean;
    nomeSecao: string;
label fim;

begin
    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('DV_CONF_HEADR'));   {'DOSVOX - Configuração'}
    textBackground (BLACK);
    writeln;

    mensagem ('DV_CUIDAD', 1);      { 'A configuração avançada só deve ser feita por usuários experientes' }
    mensagem ('DV_TECLECCONT', 1);  { 'Aperte a letra C para continuar' }
    c := popupMenuPorLetra ('CN');
    while keypressed do readkey;
    if upcase (c) <> 'C' then exit;

    tratandoAvancada := true;
    while tratandoAvancada do
        begin
            writeln;
            textBackground (RED);
            mensagem ('DV_CONFG_PRMPT', 0);     {'Configurações de pastas - '}
            mensagem ('DV_OQUE', 0);            { 'O que você deseja ? ' }
            textBackground (BLACK);

            pegaTeclado (c, c2);

            if (c = #0) and ((c2 = CIMA) or (c2 = BAIX) or (c2 = F9)) then
                 c := selSetasAvancada;

            if c = #$1b then
                begin
                    writeln;
                    mensagem ('DV_OK', 1);      { 'Ok ! '}
                    goto fim;
                end;

            if (c = GOTFOCUS) or (c = NOFOCUS) then
            else
            if (c = #0) and (c2 = F1) then
                 ajudaAvancada
            else
                 begin
                     if sintEcoarOpcao then
                         soletra (c, 1);
                     tratandoAvancada := false;

                     if upcase (c) in ['E', 'I', 'R'] then
                         begin
                             writeln;
                             nomeSecao := escolheSecao;
                             if nomeSecao = '' then continue;
                         end;

                     case upcase(c) of
                        'E': editaSecao (nomeSecao);
                        'I': incluiItem (nomeSecao);
                        'R': removeItem (nomeSecao);
                        'C': criaNovaSecao;
                        'M': editaSecao ('MACROCOMANDOS');
                        'L': configLegado;
                        'V': deixarProgramasMaisRapidos (true);
                        'P': deixarProgramasMaisRapidos (false);
                        'O': recuperaConfigOriginal;
                     else
                         begin
                             mensagem ('DV_OPCINV', 1);     { 'Opção inválida.' }
                             tratandoAvancada := true;
                         end;
                     end;
                 end;
        end;
fim:
    writeln;
end;

{--------------------------------------------------------}
{          Transforma o nome da cor em código
{--------------------------------------------------------}

const
    tabCores: array[0..15] of string =
        ('Preto', 'Azul', 'Verde', 'Ciano', 'Vermelho',
         'Roxo', 'Marrom', 'Cinza', '', '', '', '', '', '', 'Amarelo', 'Branco');

{--------------------------------------------------------}

function transfCor (cor: string): integer;
var n, erro: integer;
begin
    transfCor := 0;
    cor := ansiUpperCase (trim(cor));
    if (cor <> '') and (cor[1] in ['0'..'9']) then
        begin
            val (cor, n, erro);
            if erro <> 0 then n := 0;
            transfCor := n;
        end
    else if (cor = 'PRETO') or
            (cor = 'PRETA') or (cor = 'BLACK')    then transfCor := 0
    else if (cor = 'AZUL') or (cor = 'BLUE')      then transfCor := 1
    else if (cor = 'VERDE') or (cor = 'GREEN')    then transfCor := 2
    else if (cor = 'CIANO') or (cor = 'CYAN')     then transfCor := 3
    else if (cor = 'VERMELHO') or
            (cor = 'VERMELHA') or (cor = 'RED')   then transfCor := 4
    else if (cor = 'ROXO') or
            (cor = 'ROXA') or (cor = 'MAGENTA')   then transfCor := 5
    else if (cor = 'MARROM') or (cor = 'BROWN')   then transfCor := 6
    else if (cor = 'CINZA') or (cor = 'GRAY')     then transfCor := 7
    else if (cor = 'AMARELO') or
            (cor = 'AMARELA') or (cor = 'YELLOW') then transfCor := 14
    else if (cor = 'BRANCO') or
            (cor = 'BRANCA') or (cor = 'WHITE')   then transfCor := 15;
end;

{--------------------------------------------------------}

function confereCor (n: integer): integer;
begin
    if (n < 0) or (n in [8..13]) or (n > 15) then
        n := 0;
    result := n;
end;

{--------------------------------------------------------}
{            configuração para baixa visão
{--------------------------------------------------------}

procedure configBaixaVisao;
var
    fator, corletra, corfundo, corcursor: integer;
    s_corl, s_corf, s_corc: shortString;

const
    cores: string = 'Preto|Azul|Verde|Ciano|Vermelho|Roxo|Marrom|Cinza|Amarelo|Branco';

begin
    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('DV_CONF_HEADR'));   { 'DOSVOX - Configuração' }
    textBackground (BLACK);

    writeln;
    mensagem ('DV_BAIXAV', 2);     {'Configurações para baixa visão'}
    mensagem ('DV_EDITCONF', 2);   {'Editore as configurações, ao final tecle ESC'}

    amplPegaConfig(fator, corletra, corfundo, corcursor);
    s_corl := tabCores[confereCor(corletra)];
    s_corf := tabCores[confereCor(corfundo)];
    s_corc := tabCores[confereCor(corcursor)];

    formCria;
    formCampoInt   ('DV_AJUCB_A', pegaTextoMensagem ('DV_AJUCB_A'), fator);
    formCampoLista ('DV_AJUCB_L', pegaTextoMensagem ('DV_AJUCB_L'), s_corl, 15, cores); { 'Cor da letra' }
    formCampoLista ('DV_AJUCB_F', pegaTextoMensagem ('DV_AJUCB_F'), s_corf, 15, cores); { 'Cor do fundo' }
    formCampoLista ('DV_AJUCB_C', pegaTextoMensagem ('DV_AJUCB_C'), s_corc, 15, cores); { 'Cor do cursor' }
    formEdita(true);

    if (fator < 0) or (fator > 5) then fator := 3;
    corletra  := transfCor (s_corl);
    corfundo  := transfCor (s_corf);
    corcursor := transfCor (s_corc);

    sintGravaAmbiente('BAIXAVISAO', 'AMPLIACAO', intToStr(fator));
    sintGravaAmbiente('BAIXAVISAO', 'CORLETRA', intToStr(corletra));
    sintGravaAmbiente('BAIXAVISAO', 'CORFUNDO', intToStr(corfundo));
    sintGravaAmbiente('BAIXAVISAO', 'CORCURSOR', intToStr(corcursor));

    amplEsconde;
    amplFim;
    amplCores (corLetra, corFundo, corCursor);
    amplInic(1, fator);

    mensagem ('DV_OK', 2);      { 'Ok ! '}
end;

{--------------------------------------------------------}
{             ajuda da configuração do Dosvox
{--------------------------------------------------------}

procedure ajudaConfig;
begin
    writeln;
    mensagem ('DV_AJUC_OPC', 1);    {'As opções de configuração são:'}
    mensagem ('DV_AJUC_P',   1);    { '  P - Pastas principais' }
    mensagem ('DV_AJUC_D',   1);    { '  D - selecionar dispositivo de áudio' }
    mensagem ('DV_AJUC_F',   1);    { '  F - Fala gravada' }
    mensagem ('DV_AJUC_S',   1);    { '  S - Fala sintetizada' }
    mensagem ('DV_AJUC_A',   1);    { '  A - atualização do sistema' }
    mensagem ('DV_AJUC_C',   1);    { '  C - retorno sonoro em cópias de arquivos' }
    mensagem ('DV_AJUC_W',   1);    { '  W - iniciar o Dosvox com o Windows' }
    mensagem ('DV_AJUC_I',   1);    { '  I - informações sobre o sistema Dosvox' }
    mensagem ('DV_AJUC_B',   1);    { '  B - configurações para baixa visao' }
    mensagem ('DV_AJUC_AST', 1);    { '  * - configuração avançada' }

    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}
{            seleciona opção de configuração do Dosvox
{--------------------------------------------------------}

const
    nOpConfig = 10;

{--------------------------------------------------------}
function selSetasConfig: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var n: integer;
const
    tabLetrasConfig: string [nOpConfig] = 'pdfsacwib*';

begin
    salvaXY;
    writeln;
    garanteEspacoTela (nOpConfig);
    popupMenuCria (wherex, wherey, 53, nOpConfig, MAGENTA);

    MenuAdiciona ('DV_AJUC_P');     { '  P - pastas principais' }
    MenuAdiciona ('DV_AJUC_D');     { '  D - selecionar dispositivo de áudio' }
    MenuAdiciona ('DV_AJUC_F');     { '  F - fala gravada' }
    MenuAdiciona ('DV_AJUC_S');     { '  S - fala sintetizada' }
    MenuAdiciona ('DV_AJUC_A');     { '  A - atualização do sistema' }
    MenuAdiciona ('DV_AJUC_C');     { '  C - retorno sonoro em cópias de arquivos' }
    MenuAdiciona ('DV_AJUC_W');     { '  W - iniciar o Dosvox com o Windows' }
    MenuAdiciona ('DV_AJUC_I');     { '  I - informações sobre o sistema Dosvox' }
    MenuAdiciona ('DV_AJUC_B');     { '  B - configurações para baixa visao' }
    MenuAdiciona ('DV_AJUC_AST');   { '  * - configuração avançada' }

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasConfig := tabLetrasConfig[n]
    else
        selSetasConfig := ESC;
    restauraXY;
end;

{--------------------------------------------------------}
{                configuração versão 5.0
{--------------------------------------------------------}

procedure configDosvox;
var
    c, c2: char;
    tratandoConfig: boolean;
label
    fim;

begin
    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('DV_CONF_HEADR')); {'DOSVOX - Configuração'}
    textBackground (BLACK);

    tratandoConfig := true;
    while tratandoConfig do
        begin
            writeln;
            textBackground (RED);
            mensagem ('DV_CONF_PRMPT', 0);      { 'Configurações - ' }
            mensagem ('DV_OQUE', 0);            { 'O que você deseja ? ' }
            textBackground (BLACK);

            pegaTeclado (c, c2);

            if (c = #0) and ((c2 = CIMA) or (c2 = BAIX) or (c2 = F9)) then
                c := selSetasConfig;

            if c = #$1b then
                begin
                    writeln;
                    mensagem ('DV_OK', 1);      { 'Ok ! '}
                    goto fim;
                end;

            if (c = GOTFOCUS) or (c = NOFOCUS) then
            else
            if (c = #0) and (c2 = F1) then
                ajudaConfig
            else
                begin
                    if sintEcoarOpcao then
                        soletra (c, 1);
                    writeln;
                    tratandoConfig := false;

                    case upcase(c) of
                        'P': configPastas;
                        'D': selecionaDispAudio;
                        'F': configFalaGravada;
                        'S': configFalaSintetizada;
                        'A': configAtualiza;
                        'C': configRetornoCopia;
                        'W': configInicia;
                        'I': begin
                                mostraLogo;
                                mostraQuem (versao);
                                limpaBuf;
                                tratandoConfig := true;
                             end;
                        'B': configBaixaVisao;
                        '*': configAvancada;
                    else
                         mensagem ('DV_OPCINV', 1);     { 'Opção inválida.' }
                         tratandoConfig := true;
                    end;
                end;
        end;
fim:
    writeln;
end;

var
    s: string;
    erro: integer;
begin
    s := uppercase (sintAmbiente ('DOSVOX', 'SONSEMCOPIADEARQUIVOS'));
    copiaFazSintClek := s = 'CLEKS';

    val (sintAmbiente ('DOSVOX', 'INSTRUMEMCOPIADEARQUIVOS'), instrumentoEmCopiaDeArquivo, erro);
    if erro <> 0 then instrumentoEmCopiaDeArquivo := 10;
    if not instrumentoEmCopiaDeArquivo in [1..127] then
        instrumentoEmCopiaDeArquivo := 10;

end.
