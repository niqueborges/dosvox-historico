unit dosform;
interface
uses
    windows, sysUtils, classes,
    dvcrt, dvwin, dvform,
    dosgeral, dosmsg, dosproc, dosed, dvmacro,
    dosVars;

procedure formataUnidade;

function SHFormatDrive(hWnd: HWND; Drive: Word; fmtID: Word;
              Options: Word): Longint stdcall;
              external 'Shell32.dll' Name 'SHFormatDrive';

type
    TCallBackCommand = (
        PROGRESS,  DONEWITHSTRUCTURE,
    	UNKNOWN2,  UNKNOWN3,  UNKNOWN4, UNKNOWN5,
    	INSUFFICIENTRIGHTS,
	    FSNOTSUPPORTED,
    	VOLUMEINUSE,
    	UNKNOWN9, UNKNOWNA,
    	DONE,
	    UNKNOWNC, UNKNOWND,
    	OUTPUT,
        STRUCTUREPROGRESS,
        CLUSTERSIZETOOSMALL, // 16
        UNKNOWN11, UNKNOWN12, UNKNOWN13, UNKNOWN14, UNKNOWN15,
        UNKNOWN16, UNKNOWN17, UNKNOWN18, PROGRESS2, UNKNOWN1A) ;
             // added 1.1, Vista percent done seems to duplicate PROGRESS

function FormatCallback (Command: TCallBackCommand; SubAction: DWORD;
                         ActionInfo: Pointer): Boolean; stdcall;

implementation

var
    FmifsLib: THandle;
    formatoOk: boolean;

    FormatEx: procedure (
        DriveRoot: PWCHAR;
        MediaFlag: DWORD;
        Format: PWCHAR;
        DiskLabel: PWCHAR;
        QuickFormat: BOOL;
        ClusterSize: DWORD;
        Callback: Pointer); stdcall;

const
    // media flags
    FMIFS_HARDDISK  = $0C ;
    FMIFS_REMOVABLE = $0B ;
    FMIFS_FLOPPY    = $08 ;

function FormatCallback (Command: TCallBackCommand; SubAction: DWORD;
                         ActionInfo: Pointer): Boolean; stdcall;
var
    flag: pboolean ;
    info: string ;

begin
    result := true;
    info := '' ;
    case Command of
        Progress:  ;
        Progress2: ;
        Output:    ;
        Done:
            begin
                flag := ActionInfo ;
                if flag^ then
                    begin
                        info := 'Término OK';
                        formatoOk := true;
                    end
                else
                    begin
                        info := 'Operação mal sucedida' ;
                        formatoOk := false;
                        sintBip; sintBip; sintBip;
                    end;
            end ;

        DoneWithStructure: info := 'Estrutura criada sem problemas' ;
        InsufficientRights: info := 'Você não tem privilégios para fazer isso' ;
        UNKNOWN9: info := 'Este dispositivo não admite formatação rápida' ;
        ClusterSizeTooSmall: info := 'Cluster Size inadequado' ; // 1.1
	    FSNotSupported: info := 'Tipo de formato não suportado' ; // 1.1
    	VolumeInUse: info := 'Não posso: Volume está sendo usado' ; // 1.1
        StructureProgress:
            begin
            //    percent := ActionInfo ;  does not seem to be a result
            //    if percent <> Nil then progper := percent^ ;
            end ;
        else
            info := 'Informações da formatação: ' + IntToStr (Ord (Command)) ;
    end ;
    if info <> '' then
        sintWriteln (info);
end ;

{--------------------------------------------------------}

function formata (drive: char; QuickFormat: boolean; nome: string): boolean;
var
    wdrive, wfilesystem, wdisklabel: widestring ;
    mediaflags, newsize: DWORD ;
begin
    FmifsLib := LoadLibrary ('fmifs.dll');
    if FmifsLib = 0 then
        begin
            mensagem ('DV_PROBFORM', 1);    { 'Problemas na formatação, verifique proteção de escrita.' }
            result := false;
            exit;
        end;

    FormatEx := GetProcAddress (fmifsLib, 'FormatEx') ;

    wdrive := upcase (drive) + ':\';
    nome := uppercase (nome);
    wdisklabel := nome;
    wfilesystem := 'FAT32';
    mediaflags := FMIFS_FLOPPY or FMIFS_REMOVABLE;
    newsize := 0;   // default

    FormatEx (PWchar(wdrive), mediaflags, PWchar (wfilesystem),
              PWchar (wdisklabel), QuickFormat, newsize, @FormatCallback);
    FreeLibrary(FmifsLib);
    formata := formatoOk;
end;

{--------------------------------------------------------}

function formatavel (drive: char): Boolean;
var
    drvtype: word;
    drives: dword;
    raizDrive: string;
begin
    drives := GetLogicalDrives;
    if (drives and(1 shl (ord (drive) - ord ('A')))) = 0 then
        begin
            result := false;
            exit;
        end;

    raizDrive := drive + ':\';
    drvtype := GetDriveType(@raizDrive[1]);
    Result := (drvtype <> DRIVE_FIXED) and (drvtype <> DRIVE_CDROM) and
              (drvtype <> DRIVE_REMOTE);
end;

{--------------------------------------------------------}

function getVolumeName(DriveName: Char): string;
var
    max, Flags: DWORD;
    Buf: array [0..MAX_PATH] of Char;
begin
    try
        GetVolumeInformation(PChar(DriveName + ':\'), Buf, sizeof(Buf), nil, max, Flags, nil, 0);
        Result := StrPas(buf);
    except
        result := '';
    end;
end;

{--------------------------------------------------------}
{                  formata uma mídia
{--------------------------------------------------------}

procedure formataUnidade;
var drive: char;
    c: char;
    rotulo: string;
    rapida: boolean;

label cancela;

    {--------------------------------------------------------}
    function selInterativaMidia: char;
    var
        c, c2: char;
        i: integer;
        letras: array [0..255] of char;
        drives: string[30];
        nomeDrive: string;
        sdrive: string;
        vol: array [0..30] of char;
        dummy: DWord;
    begin
        sintLeTecla (c, c2);
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

begin
    mensagem ('DV_INFLDRV', 0);     {'Informe a letra da unidade a formatar: '}
    drive := upcase(selInterativaMidia);
    if not formatavel(drive) then
        begin
            mensagem ('DV_DRVINV', 1);  { 'Unidade inválida.' }
            exit;
        end;

    mensagem ('DV_FORMRAP', 0);         { 'Posso usar formatação rápida ? ' }
    c := popupMenuPorLetra('SN');
    if c = #$1b then goto cancela;

    rapida := upcase (c) <> 'N';

    mensagem ('DV_ROTULOGRAV', 0);      {'Edite o nome do rótulo a gravar (12 letras): '}
    rotulo := GetVolumeName(drive);
    c := sintEdita (rotulo, wherex, wherey, 12, true);
    if c = #$1b then goto cancela;
    writeln;

    mensagem ('DV_TECENTFORMAT', 1);    {'Aperte enter para formatar'}
    repeat
        c := readkey;
    until (c = #$1b) or (c = #$0d);
    if c = #$1b then
        begin
cancela:
            mensagem ('DV_FORMCANC', 1);    { 'Formatação cancelada.' }
            exit;
        end;

    if formata (drive, rapida, rotulo) then
        mensagem ('DV_UNIFOR', 1)     { unidade bem formatada }
    else
        mensagem ('DV_PROBFR', 1);    { problemas na formatação }
end;

end.
