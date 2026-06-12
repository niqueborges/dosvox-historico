{--------------------------------------------------------}
{
{     Rotinas de manipulação de discos e mídias do Dosvox
{
{     Autores:  José Antonio Borges
{               Júlio Tadeu Carvalho da Silveira
{
{     Versão 1.0:   Em Janeiro/98
{     Versão 5.0:   Em julho/2015
{
{--------------------------------------------------------}

unit dosdisco;

interface

uses
    windows, sysUtils, shellapi, shlObj,
    dvcrt, dvwin, dvForm, dosBuscaArq,
    dosgeral, dosmsg, dosform, dosDir,
    dosVars, dosPref, dosGrava, ejectUSB;

procedure trataDiscos;

implementation

{--------------------------------------------------------}
{             ajuda do processamento de arquivos
{--------------------------------------------------------}

procedure ajudaDiscos;
begin
    writeln;
        mensagem ('DV_AJUD_OPC', 1);    {'As opcoes de manuseio de discos e mídias são:'}
        mensagem ('DV_AJUD_P',   1);    {'    P - pastas preferidas'}
        mensagem ('DV_AJUD_T',   1);    {'    T - trocar a pasta atual'}
        mensagem ('DV_AJUD_D',   1);    {'    D - escolher disco ou mídia atual'}
        mensagem ('DV_AJUD_I',   1);    {'    I - informar qual a pasta atual'}
        mensagem ('DV_AJUD_V',   1);    {'    V - voltar à pasta anterior'}
        mensagem ('DV_AJUD_B',   1);    {'    B - busca de arquivos por nome'}
        mensagem ('DV_AJUD_C',   1);    {'    C - criar pasta'}
        mensagem ('DV_AJUD_E',   1);    {'    E - espaço livre e tamanho da mídia'}
        mensagem ('DV_AJUD_G',   1);    {'    G - gravar midia'}
        mensagem ('DV_AJUD_R',   1);    {'    R - remover mídia'}
        mensagem ('DV_AJUD_N',   1);    {'    N - renomear midia'}
        mensagem ('DV_AJUD_F',   1);    {'    F - formatar mídia'}
        mensagem ('DV_AJUD_L',   1);    {'    L - esvaziar a lixeira do Dosvox'}

    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

function selSetasDisco: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var n: integer;
const
    tabLetrasDisco: string = 'PTDIVBCEGRNFL';

begin
    salvaXY;
    writeln;

    popupMenuCria (wherex, wherey, 50, length(tabLetrasDisco), MAGENTA);

        MenuAdiciona ('DV_AJUD_P');      {'    P - pastas preferidas'}
        MenuAdiciona ('DV_AJUD_T');      {'    T - trocar a pasta atual'}
        MenuAdiciona ('DV_AJUD_D');      {'    D - escolher disco ou mídia atual'}
        MenuAdiciona ('DV_AJUD_I');      {'    I - informar qual a pasta atual'}
        MenuAdiciona ('DV_AJUD_V');      {'    V - voltar à pasta anterior'}
        MenuAdiciona ('DV_AJUD_B');      {'    B - busca de arquivos por nome'}
        MenuAdiciona ('DV_AJUD_C');      {'    C - criar pasta'}
        MenuAdiciona ('DV_AJUD_E');      {'    E - espaço livre e tamanho da mídia'}
        MenuAdiciona ('DV_AJUD_G');      {'    G - gravar midia'}
        MenuAdiciona ('DV_AJUD_R');      {'    R - remover mídia'}
        MenuAdiciona ('DV_AJUD_N');      {'    N - renomear midia'}
        MenuAdiciona ('DV_AJUD_F');      {'    F - formatar mídia'}
        MenuAdiciona ('DV_AJUD_L');      {'    L - esvaziar a lixeira do Dosvox'}

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasDisco := tabLetrasDisco[n]
    else
        selSetasDisco := ESC;
    restauraXY;
end;

{--------------------------------------------------------}
{                    verifica o espaco em disco
{--------------------------------------------------------}

procedure verifEspaco;
var
    dfree, dsize: int64;
    medida: char;
    drive: integer;
    dir: string;
begin
    medida := 'K';
    getDir (0, dir);
    drive := ord (dir[1]) - ord ('A') + 1;
    dsize := disksize (drive) div 1024;

    if dsize > 1024*1024 then
        begin
            medida := 'M';
            dsize := dsize div 1024;
        end;

    if medida = 'K' then
        mensagem ('DV_TAMDSK', 0)       { 'Tamanho do disco em K: ' }
    else
        mensagem ('DV_TAMMEGA', 0);     { 'Tamanho do disco em Mb: '}
//    falaNum (dsize, 1);
    sintWriteInt (dsize);
    writeln;

    medida := 'K';
    dfree := diskfree (drive) div 1024;
    if dfree > 1024*1024 then
        begin
            medida := 'M';
            dfree := dfree div 1024;
        end;

    if medida = 'K' then
        mensagem ('DV_LIVDSK', 0)       { 'Espaço livre em K: ' }
    else
        mensagem ('DV_LIVRMEGA', 0);    { 'Espaço livre em Mb: ' }
    sintWriteInt (dfree);
    writeln;
end;

{--------------------------------------------------------}
{             seleção interativa da midia
{--------------------------------------------------------}

function selInterativaMidia: char;
var
    c: char;
    i: integer;
    letras: array [0..255] of char;
    drives: string[30];
    nomeDrive: string;
    sdrive: string;
    vol: array [0..30] of char;
    dummy: DWord;
begin
    c := readkey;
    if sintEcoarOpcao and (upcase(c) in ['A' .. 'Z']) then soletra (c, 1);

    if c <> #$0 then
        writeln
    else
        begin
            GetLogicalDriveStrings(255, letras);
            i := 0;
            drives := '';
            while (letras[i] <> #0) do
                begin
                    drives := drives + letras[i];
                    while (letras[i] <> #0) do i := i + 1;
                    i := i + 1;
                end;

            while keypressed do readkey;

            popupMenuCria (wherex, wherey, 15, length (drives), RED);
            setErrorMode (SEM_FAILCRITICALERRORS);
            for i := 1 to length (drives) do
                begin
                    nomeDrive := '';
                    sdrive := drives[i] + ':\';
                    nomeDrive := '';
                    vol := '';
                    GetVolumeInformation(@sdrive[1], vol, 30, NIL, dummy, dummy, NIL, 30);
                    if vol <> '' then
                        nomeDrive := ' - ' + vol;

                    popupMenuAdiciona('', drives[i] + nomeDrive);
                end;
            setErrorMode (0);
            popupMenuOrdena;
            i := popupMenuSeleciona;
            if i <= 0 then
                c := ESC
            else
                c := drives[i];
            writeln (c);
        end;

    result := c;
end;

{--------------------------------------------------------}
{                escolhe o disco de trabalho
{--------------------------------------------------------}

procedure escolheDisco;
var c: char;
begin
    writeln;
    mensagem ('DV_INFNDISC', 0);    { 'Informe novo disco de trabalho: ' }

    c := selInterativaMidia;

    if c = ESC then
        mensagem ('DV_DESIST', 1)   { 'Desistiu...' }
    else
        if upcase(c) in ['A'..'Z'] then
            begin
                {$i-} chdir (c+':'); {$i+}
                if ioresult <> 0 then
                    mensagem ('DV_ERRNDISC', 1);    { 'Não consegui mudar de disco. Sinto muito.' }
            end
        else
            mensagem ('DV_ERRNDISC', 1);            { 'Não consegui mudar de disco. Sinto muito.' }
end;

{--------------------------------------------------------}
{            ejeta volume
{--------------------------------------------------------}

function ejectVolume(aDrive: char): boolean;

const
    FSCTL_LOCK_VOLUME     = (9 shl 16) or (0 shl 14) or (6 shl 2) or 0;
    FSCTL_DISMOUNT_VOLUME = (9 shl 16) or (0 shl 14) or (8 shl 2) or 0;
    FSCTL_UNLOCK_VOLUME   = (9 shl 16) or (0 shl 14) or (7 shl 2) or 0;

    IOCTL_STORAGE_MEDIA_REMOVAL = ($2d shl 16) or (1 shl 14) or ($201 shl 2) or 0;
    IOCTL_STORAGE_EJECT_MEDIA   = ($2d shl 16) or (1 shl 14) or ($202 shl 2) or 0;

const
    LOCK_RETRIES = 5;

var
    aVolumeHandle: THandle;

    VolumeName: string;
    AccessFlags: DWORD;
    DriveType:Cardinal;

    Retries: integer;
    BytesReturned: Cardinal;
    Ok: boolean;

    PMRBuffer: BOOL;

begin
    result := false;
    ADrive := upcase(ADrive);
    DriveType := GetDriveType(PChar(ADrive + ':\'));
    case DriveType of
        DRIVE_REMOVABLE:  AccessFlags := GENERIC_READ or GENERIC_WRITE;
        DRIVE_CDROM:      AccessFlags := GENERIC_READ;
        DRIVE_FIXED:      AccessFlags := GENERIC_READ or GENERIC_WRITE;
    else
        mensagem ('DV_DISINV', 2);  {'Dispositivo inválido'}
        exit;
    end;

    VolumeName := Format('\\.\%s:', [ADrive]);
    aVolumeHandle := CreateFile(PChar(VolumeName), AccessFlags,
        FILE_SHARE_READ or FILE_SHARE_WRITE, NIL, OPEN_EXISTING, 0, 0);
    if aVolumeHandle = 0 then
        begin
            mensagem ('DV_NAOABV', 2); {'Não pude abrir o volume'}
            exit;
        end;

    for Retries := 1 to LOCK_RETRIES do
        begin
            ok := DeviceIoControl(AVolumeHandle, FSCTL_LOCK_VOLUME, NIL, 0,
                      NIL, 0, BytesReturned, nil);
            if ok then break;
            sleep(1000);
        end;
    if not ok then
        begin
            mensagem ('DV_SEMACX', 2);   {'Não pude garantir acesso exclusivo'}
            closeHandle (aVolumeHandle);
            exit;
        end;

    ok := DeviceIoControl(AVolumeHandle, FSCTL_DISMOUNT_VOLUME, NIL, 0,
                              NIL, 0, BytesReturned, nil);
    if not ok then
        begin
            mensagem ('DV_NDISMO', 2);  {'Não pude desmontar o volume'}
            closeHandle (aVolumeHandle);
            exit;
        end;

    PMRBuffer := false;
    ok := DeviceIoControl(AVolumeHandle, IOCTL_STORAGE_MEDIA_REMOVAL,
                              @PMRBuffer, SizeOf(PMRBuffer),
                              NIL, 0, BytesReturned, nil);
    if not ok then
        begin
            mensagem ('DV_NTIRPR', 2);  {'Não pude tirar a proteção contra remoção'}
            closeHandle (aVolumeHandle);
            exit;
        end;

    ok := DeviceIoControl(AVolumeHandle, IOCTL_STORAGE_EJECT_MEDIA, NIL, 0,
                              NIL, 0, BytesReturned, nil);
    if not ok then
        begin
            mensagem ('DV_NAOEJE', 2);   {'Não pude ejetar a mídia'}
            closeHandle (aVolumeHandle);
            exit;
        end;

    ok := DeviceIoControl(AVolumeHandle, FSCTL_UNLOCK_VOLUME, NIL, 0,
                              NIL, 0, BytesReturned, nil);
    if not ok then
        begin
            mensagem ('DV_NLIBV', 2);   {'Não pude liberar o acesso da mídia'}
            closeHandle (aVolumeHandle);
            exit;
        end;

    ShChangeNotify (SHCNE_MEDIAREMOVED, SHCNF_PATH, PChar(ADrive + ':\'), NIL);

    closeHandle (aVolumeHandle);

    if DriveType = DRIVE_REMOVABLE then
        result := Eject_USB(aDrive, 4, 300, True, True)
    else
        result := true;
end;

{--------------------------------------------------------}
{            remove mídia
{--------------------------------------------------------}

procedure removeMidia;
var c: char;
begin
    writeln;
    mensagem ('DV_UNIREM', 0);   {'Informe a unidade a remover'}

    c := selInterativaMidia;
    if c = ESC then
        begin
            mensagem ('DV_DESIST', 1);  {'Desistiu...'}
            exit;
        end;

    mensagem ('DV_UMMOMENTO', 2);       {'Um momento...'}

    c := upcase(c);
    if ejectVolume(c) then
        mensagem ('DV_OKREMOV', 2)      {'Ok, removido'}
    else
        begin
            sintBip;
            mensagem ('DV_NAORM', 2);   {'Não foi possível remover.'}
        end;
end;

{--------------------------------------------------------}
{            informa diretorio de trabalho
{--------------------------------------------------------}

procedure informaDirTrab;
var dir: string;
begin
    getdir (0, Dir);
    if sintFalarTudo then
        mensagem ('DV_DIRATU', 0);          { 'O diretório atual é ' }
    soletra (copy (Dir, 1, 2), 0);
    sintetFala (copy (Dir, 3, length(Dir)-2) , 1);
end;

{--------------------------------------------------------}
{        seleciona diretorio de trabalho
{--------------------------------------------------------}

procedure selecDirTrab;
var novoDir: string;
    c: char;
begin
    mensagem ('DV_INFNDIR', 1);     { 'Informe o novo diretório de trabalho: ' }
    novoDir := '';
    c := pegaUltimosComandos (novodir, 'DOSVOX', 'DT', false);

    writeln;
    if c = #$1b then
        exit;

    novoDir := trim (novoDir);
    if novoDir = '' then exit;

    if uppercase(novoDir) = '@@\DOSVOX' then novoDir := getDirConfigs;

    {$I-} chdir (novoDir); {$i+}
    if ioresult <> 0 then
         mensagem ('DV_ERRMUD', 1)      { 'Desculpe, não consegui mudar para o diretório pedido.' }
    else
        begin
            if sintFalarTudo then
                mensagem ('DV_OKMUD',  1) { 'Ok, troquei diretório de trabalho' }
            else
                mensagem ('DV_OK',  1); { 'Ok, troquei diretório de trabalho' }
            getDir (0, novoDir);
            insereNosUltimosComandos(novoDir, 'DOSVOX', 'DT');
        end;
end;

{--------------------------------------------------------}
{                         cria diretorio
{--------------------------------------------------------}

procedure criaDir;
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
                           mensagem ('DV_ERRDIRCRI', 1)   { 'Desculpe mas não consegui criar o diretório pedido.' }
                       else
                           begin
                               getDir (0, novoDir);
                               insereNosUltimosComandos(novoDir, 'DOSVOX', 'DT');
                           end;
                   end;
         end;
end;

{--------------------------------------------------------}
{             volta ao penúltimo diretório
{--------------------------------------------------------}

procedure voltaPenultDir;
var dirAtual: string;
begin
    getDir (0, dirAtual);
    {$I-}  chDir (penultSubDir);   {$I+}
    if ioresult <> 0 then;

    penultSubDir := dirAtual;
    informaDirTrab;
end;

{--------------------------------------------------------}
{             renomeia uma mídia
{--------------------------------------------------------}

procedure renomeiaMidia;
var c: char;
    unid: char;
    nome: string;
    u: string;
    status: boolean;
begin
    writeln;
    mensagem ('DV_UNRENO', 0);   {'Informe a unidade a renomear'}

    unid := selInterativaMidia;
    if unid = ESC then
        begin
            mensagem ('DV_DESIST', 1);      {'Desistiu...'}
            exit;
        end;

    mensagem ('DV_NOMERN', 0);   {'Qual o novo nome (12 letras): '}
    nome := '';
    c := sintEdita (nome, wherex, wherey, 12, true);
    if c = ESC then
        begin
            mensagem ('DV_DESIST', 2);      {'Desistiu...'}
            exit;
        end;

    writeln;
    u := unid + ':\';
    status := SetVolumeLabel (pchar(u), pchar(nome));
    if status then
        mensagem ('DV_OKRENO', 2)    {'Ok, unidade renomeada.'}
    else
        begin
            mensagem ('DV_NORENO', 1);   {'Não foi possível renomear.'}
            sintWriteln ('Status ' + intToStr(getLastError));
            writeln;
        end;
end;

{--------------------------------------------------------}
{             esvaziar a Lixeira do Dosvox
{--------------------------------------------------------}

procedure esvaziaLixeira;
var
    c: char;
    fos: TSHFileOpStruct;
    dirLixeira: string;
    dummy: string;
    numSub, numArq: int64;

begin
    dirLixeira := sintAmbiente ('DOSVOX', 'DIRLIXEIRA');
    if dirLixeira = '' then exit;

    numSub := 0;
    numArq := 0;
    GetDirSize(dirLixeira ,  true, numSub, numArq);
    if (numSub = 0) and  (numArq = 0) then
        begin
            mensagem ('DV_LIXEIRAVAZ', 1); {'Lixeira vazia.'}
            exit;
        end;
    if numArq > 0 then
        begin
            mensagem ('DV_ESCARQ', 0);      { 'Arquivos - ' }
            sintWriteInt (numArq);
            write ('        ');
        end;
    if numSub > 0 then
        begin
            if sintFalarTudo then mensagem ('DV_SUBDIR', 0)  {'Subdiretórios - '}
            else mensagem ('DV_PASTAS', 0);  {'Pastas - '}
            sintWriteInt (numSub);
            writeln;
        end;

    mensagem ('DV_AJUDL_PRMPT', 0);     { 'Esvaziar a lixeira do Dosvox. Confirma? ' }
    c := popupMenuPorLetra('SN');
    writeln;
    if c <> 'S' then
    begin
        mensagem ('DV_DESIST', 1);  {'Desistiu...'}
        exit;
    end;

    if dirLixeira[length(dirLixeira)] <> '\' then
        dirLixeira := dirLixeira + '\';

    dirLixeira := dirLixeira + '*.*';
    dirLixeira := dirLixeira + #0#0;
    dummy := #0#0;

    ZeroMemory(@fos, SizeOf(fos));
    with fos do
        begin
            wFunc  := FO_DELETE;
            fFlags := FOF_SILENT or FOF_NOERRORUI or FOF_NOCONFIRMATION;
            pFrom  := @dirLixeira[1];
            pTo    := @dummy[1];
        end;

    mensagem ('DV_UMMOMENTO', 2);       { 'Um momento...' }
    if ShFileOperation(fos) = 0 then
        mensagem ('DV_AJUDL_OK',  2)    { 'Ok. A lixeira do Dosvox foi esvaziada.' }
    else
        mensagem ('DV_AJUDL_NOK', 2);   { 'Erro: a lixeira do Dosvox não foi esvaziada.' }
end;

{--------------------------------------------------------}
{             funcoes de tratamento de discos
{--------------------------------------------------------}

procedure trataDiscos;
var
    tratandoDiscos: boolean;
    dirInicial, dirFinal: string;
    c, c2: char;
label fim;
begin
    getDir (0, dirInicial);

    tratandoDiscos := true;
    while tratandoDiscos do
        begin
            write (#$0d);
            textBackground (RED);
            mensagem ('DV_DISCOS', 0);      { 'Discos - ' }
            mensagem ('DV_OQUE', 0);        { 'O que você deseja ? ' }
            textBackground (BLACK);

            pegaTeclado (c, c2);

            if (c = #0) and ((c2 = CIMA) or (c2 = BAIX) or (c2 = F9)) then
                 c := selSetasDisco;

            if c = #$1b then
                begin
                    writeln;
                    mensagem ('DV_OK', 1);      { 'Ok ! '}
                    goto fim;
                end;

            if (c = GOTFOCUS) or (c = NOFOCUS) then
            else
            if (c = #0) and (c2 = F1) then
                 ajudaDiscos
            else
                 begin
                     if sintEcoarOpcao and (c >= ' ') then
                         soletra (c, 1);
                     writeln;
                     tratandoDiscos := false;

                     case upcase(c) of

                         'P':   trataPreferidos;
                         'T':   selecDirTrab;
                         'D':   escolheDisco;
                         'I':   informaDirTrab;
                         'V':   voltaPenultDir;
                         'B':   buscaArquivosPorNome;
                         'C':   criaDir;
                         'E':   verifEspaco;
                         'G':   gravaMidia;
                         'R':   removeMidia;
                         'N':   renomeiaMidia;
                         'F':   formataUnidade;
                         'L':   esvaziaLixeira;
                       ENTER:   tratandoDiscos := true;

                     else
                         mensagem ('DV_OPCINV', 1);     { 'Opção inválida.' }
                         tratandoDiscos := true;
                     end;
                 end;
        end;

fim:
    getDir (0, dirFinal);
    if dirInicial <> DirFinal then
        penultSubDir := dirInicial;
    writeln;
end;

end.
