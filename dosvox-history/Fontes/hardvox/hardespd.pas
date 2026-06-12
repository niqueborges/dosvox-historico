{-------------------------------------------------------------}
{
{    Informações sobre os discos
{
{    Autor: Jose' Antonio Borges
{
{    Em 09/04/2008
{
{-------------------------------------------------------------}

unit hardespd;

interface

uses
  dvCrt,
  dvExec,
  dvWin,
  dvForm,
  windows,
  sysutils,
  hardmsg,
  FileCtrl;

procedure mostraCaracDisco;

implementation

{--------------------------------------------------------}
{               ve se disco está no drive
{--------------------------------------------------------}

FUNCTION DiskInDrive(CONST Drive: CHAR): BOOLEAN;
var
    DriveNumber:  BYTE;
    ErrorMode  : Word;
begin
    result := false;
    DriveNumber := ORD( UpCase(Drive) );
    ErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
    try
        // 'A'=1, 'B'=2, ... in DiskSize call
        if   DiskSize(DriveNumber-ORD('A')+1) <> -1
        then RESULT := TRUE
    finally
        SetErrorMode(ErrorMode)
    end;
END;

{--------------------------------------------------------}
{              vê se protegido contra escrita
{--------------------------------------------------------}

function IsDiskWriteProtected(const drive: char):  boolean;
var
    ErrorMode:  Word;
    PathName :  string;
    TempName :  string;
begin
    ErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
    try
        assert (Upcase(drive) IN ['A'..'Z'], 'Invalid drive specification');
        PathName := drive + ':\';    // example:  'A:\'
        SetLength(TempName, MAX_PATH+1);
        GetTempFileName(pChar(PathName), 'RWRO', 0, pChar(TempName));

        RESULT := (GetLastError = Windows.ERROR_WRITE_PROTECT);
        if not RESULT then  // NOT R/O ==> Disk appears to be R/W
            begin
                RESULT := not DeleteFile(TempName);
            end;
    finally
        SetErrorMode(ErrorMode);
    end;
end;

{--------------------------------------------------------}
{          mostra características de um drive
{--------------------------------------------------------}

PROCEDURE ShowDrive (DriveLetter: char);
VAR
    DriveType         :  TDriveType;
    NotUsed           :  DWORD;   // Use DWORD for D3/D4 compatibility
    VolumeFlags       :  DWORD;
    VolumeInfo        :  array[0..MAX_PATH] of char;
    VolumeSerialNumber:  Cardinal;
    montado           :  shortString;

    sval: array [1..18] of shortString;
    ReadWrite         :  shortString;
    driveNo: integer;

      {--------------------------------------------------------}

      FUNCTION GetDriveTypeString(CONST DriveType: TDriveType):  STRING;
      BEGIN
        CASE DriveType OF
          dtFloppy :  RESULT := 'Disquete ou um FLASH USB Drive';
          dtFixed  :  RESULT := 'HD ou um SSD interno';
          dtNetwork:  RESULT := ' A unidade é uma unidade de Rede';
          dtCDROM  :  RESULT := 'Unidade de CDROM ou DVDROM';
          dtRAM    :  RESULT := 'Disco RAM';
          ELSE        RESULT := 'Unidade desconhecida'
        END
      END {GetDriveTypeString};

      {--------------------------------------------------------}

      FUNCTION FormatBytes(CONST Bytes:  Int64):  STRING;
      BEGIN
        IF Bytes < 0
        THEN RESULT := 'não disponível'
        ELSE RESULT := FormatFloat('0,', Bytes)
      END {FormatBytes};

      {--------------------------------------------------------}

      procedure campo (msg: string; var valor: shortString);
      begin
          formCampo(msg, pegaTextoMensagem(msg), valor, 40);
      end;

begin
    driveNo := ord(DriveLetter) - ord('A') + 1;
    DriveType   := TDriveType(GetDriveType(pChar(DriveLetter + ':\')));
    ReadWrite := '';

    if diskInDrive (driveLetter) then
        begin
            GetVolumeInformation(pChar(DriveLetter + ':\'),
                                 VolumeInfo, SizeOf(VolumeInfo),
                                 @VolumeSerialNumber, NotUsed, VolumeFlags, NIL, 0);

            ReadWrite := 'R/W';
            if IsDiskWriteProtected(DriveLetter) then
                ReadWrite := 'R/O';
        end;

    writeln;
    garanteEspacoTela(5);
    defineNovoTamanhoDeRotulos(40);
    formCria;

    //************ completar:  mover mensagens para hardmsg *****************

    sval [1] := GetDriveTypeString(DriveType);
    campo ('HVTIPUNI', sval[1]);  // 'Tipo da Unidade'

    if DiskInDrive(driveLetter) then
        montado := 'SIM'
    else
        montado := 'NÃO';
    campo ('HVMONTAD', montado);  // Montado'

    if DiskInDrive(driveLetter) then
        begin
            campo ('HVPERMIS', ReadWrite);   // 'Permissão de escrita'

            sval [2] := FormatBytes(DiskSize(driveNo));
            campo ('HVTAMDSK', sval[2]);     // 'Tamanho do Disco'

            sval [3] := FormatBytes(DiskFree(driveNo));
            campo ('HVESPACL', sval[3]);     // 'Espaço livre'

            sval [4] := intToHex(VolumeSerialNumber, 8);
            campo ('HVNUMSER', sval[4]);     // 'Número de Série'

            sval [5] := strPas (VolumeInfo);
            campo ('HVROTULO', sval[5]);     // 'Rótulo do Volume'
        end;

    formEdita(false);
    restauraTamanhoDeRotulos;
    writeln;
end;

{--------------------------------------------------------}
{          mostra características de um dos discos
{--------------------------------------------------------}

procedure mostraCaracDisco;
var
    c: char;
    i: integer;
    letras: array [0..255] of char;
    drives: string[30];
    nomeDrive: string;
begin
    writeln;
    mensagem ('HVESCDRV', 0);  // Escolha o drive com as setas

    GetLogicalDriveStrings(255, letras);
    i := 0;
    drives := '';
    while (letras[i] <> #0) do
        begin
            drives := drives + letras[i];
            while (letras[i] <> #0) do i := i + 1;
            i := i + 1;
        end;

    garanteEspacoTela (10);
    popupMenuCria (wherex, wherey, 15, length (drives), MAGENTA);
    for i := 1 to length (drives) do
        popupMenuAdiciona('', drives[i] + nomeDrive);
    i := popupMenuSeleciona;
    if i <= 0 then
        c := ESC
    else
        c := drives[i];

    if c = ESC then
        mensagem ('HVDESIST', 1)
    else
        begin
            writeln ('Drive ', c);
            if sintFalarTudo then sintSoletra (c);
            ShowDrive (c);
        end;
end;


end.
