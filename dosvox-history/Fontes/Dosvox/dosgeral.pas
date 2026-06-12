unit dosgeral;

interface
uses
    windows, classes, sysutils, minireg,
    dvcrt, dvwin, dvHora, dvArq, dosmsg, dosVars;

procedure limpaBuf;
function  pegaTeclado (var c1, c2: char): boolean;
procedure problemaDisco;
function totalDeItensSelecionados (listAux: TList):integer;
procedure falaQualItemDeQuantos (nItem: integer; Selecionados: boolean; listAux: TList);
procedure falaAreaTransf;
function  IsAudioCD(Drive: Char): Boolean;
procedure heapStatus;

procedure salvaXY;
procedure restauraXY;

function getDirConfigs: string;

implementation

var
    xSalva,
    ySalva: integer;

{--------------------------------------------------------}

function totalDeItensSelecionados (listAux: TList): integer;
var i, t: integer;
begin
    t := 0;
    for i := listAux.count-1 downto 0 do
        if PMySearchRec(listAux[i]).marcado then
            t := t + 1;
    totalDeItensSelecionados := t;
end;

{-------------------------------------------------------------}

procedure falaQualItemDeQuantos (nItem: integer; Selecionados: boolean; listAux: TList);
begin
    if selecionados then
        nItem := totalDeItensSelecionados (listAux)
    else
    if (nItem <= 0) and (listAux.count > 0) then
        nItem := 1;

    sintWriteInt (nItem);
    if selecionados then
        if nItem <= 1 then
            mensagem ('DV_SELEC', 0)    {' selecionado'}
        else
            mensagem ('DV_SELECS', 0);  {' selecionados'}

    mensagem ('DV_DE', 0);      {' de '}
    sintWriteInt (listAux.count);
    writeln;
end;

{--------------------------------------------------------}
{           Sintetiza a área de transferência
{--------------------------------------------------------}

procedure falaAreaTransf;
var
    buf: PChar;
    hmem: THandle;
Begin
    if not openClipboard (crtWindow) then exit;
    hmem := getClipboardData (CF_TEXT);
    if hmem = 0 then
        begin
            closeClipboard;
            exit;
        end;

    limpaBufTec;
    sintclek;
    buf := globalLock (hmem);
    sintetiza (strPas(buf));

    globalUnlock (hmem);
    closeClipboard;
    limpaBufTec;
    sintclek;
end;

{--------------------------------------------------------}
{                limpa o buffer do teclado
{--------------------------------------------------------}

procedure limpaBuf;
begin
    if not semLimpaBuf then
        while keypressed do readkey;
end;

{--------------------------------------------------------}
{              pega um dado do teclado sem ecoar
{--------------------------------------------------------}

function pegaTeclado (var c1, c2: char): boolean;
label inicio;
begin

inicio:
    if not keypressed then
        if sintFalando then waitMessage;

    c1 := readkey;
    if c1 = NOFOCUS then
        goto inicio;
    result := getKeyState (vk_Shift) < 0;

    c2 := ' ';
    if c1 = #0 then
        begin
            c2 := readkey;

            // Nota: originalmente havia uma linha aparentemente inócua
            // if c2 in [#16..#18] then c1 := readkey;
            // Seria algo sobre linha braille?

            if (not  result) and (c2 in [F11, F8]) then
                begin
                    case c2 of
                        F11: sintBateria;
                        F8: falaHora;
                    end;
                    goto inicio;
                end;
        end;
end;

{--------------------------------------------------------}
{               assinala erro de disco
{--------------------------------------------------------}

procedure problemaDisco;
begin
    limpabufTec;
    mensagem ('DV_PROBDISC', 1);    { 'Cuidado, houve problemas no disco !' }
end;

{--------------------------------------------------------}
{                ve se drive contem CD de áudio
{--------------------------------------------------------}

function IsAudioCD(Drive: Char): Boolean;
var
    DrivePath: string;
    MaximumComponentLength: DWORD;
    FileSystemFlags: DWORD;
    VolumeName: string;
    OldErrorMode: UINT;
    DriveType: UINT;
begin
    Result := False;
    DrivePath := Drive + ':\';
    OldErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
    try
        DriveType := GetDriveType(PChar(DrivePath));
    finally
        SetErrorMode(OldErrorMode);
    end;

    if DriveType <> DRIVE_CDROM then Exit;

    SetLength(VolumeName, 64);
    GetVolumeInformation(PChar(DrivePath), PChar(VolumeName), Length(VolumeName),
                         nil, MaximumComponentLength, FileSystemFlags, nil, 0);
    if (lStrCmp(PChar(VolumeName), 'Audio-CD') = 0) or
       (lStrCmp(PChar(VolumeName), 'Audio CD') = 0) then
           Result := True;
end;

{--------------------------------------------------------}
{                 diagnostica o heap
{--------------------------------------------------------}

procedure heapStatus;
var
   hstatus: THeapStatus;
begin
    hStatus := GetHeapStatus;
    with hstatus do
        begin
            writeln;
            write (' TotalAddrSpace: ', TotalAddrSpace);
            writeln (' TotalUncommitted: ', TotalUncommitted);
            write (' TotalCommitted: ', TotalCommitted);
            writeln (' TotalAllocated: ', TotalAllocated);
            write (' TotalFree: ', TotalFree);
            writeln (' FreeSmall: ', FreeSmall);
            write (' FreeBig: ', FreeBig);
            writeln (' Overhead: ', Overhead);
            writeln (' HeapErrorCode: ', HeapErrorCode);
            writeln;
            readln;
        end;
end;

procedure salvaXY;
begin
    xSalva := whereX;
    ySalva := whereY;
end;

procedure restauraXY;
begin
    gotoXY (xSalva, ySalva);
end;

{--------------------------------------------------------}
{       retorna a pasta de configuração do Dosvox.
{--------------------------------------------------------}

function getDirConfigs: string;
var s: string;
begin
    regGetString (HKEY_CURRENT_USER,
        'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\AppData', s);
    if s <> '' then
        result := s + '\Dosvox'
    else
        result := '';
end;

{--------------------------------------------------------}

begin
end.
