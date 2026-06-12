{-------------------------------------------------------------}
{
{    Informações sobre HD IDE
{
{    Autor: Jose' Antonio Borges
{
{    Em 09/04/2008
{
{    Código reusado a partir de Torry's Pages:
{       06/11/2000  Lynn McGuire  written with many contributions from others,
{                            IDE drives only under Windows NT/2K and 9X,
{                            maybe SCSI drives later
{       translated by Wyfinger 14/08/2007, wyfinger@mail.ru
{
{-------------------------------------------------------------}

unit hardhd;

interface
uses
  dvCrt,
  dvExec,
  dvWin,
  dvForm,
  dvString,
  windows,
  sysutils,
  hardmsg;

procedure infoHD;

implementation

type

//  GETVERSIONOUTPARAMS contains the data returned from the
//  Get Driver Version function.

GETVERSIONOUTPARAMS = packed record
   bVersion      : BYTE;  // Binary driver version.
   bRevision     : BYTE;  // Binary driver revision.
   bReserved     : BYTE;  // Not used.
   bIDEDeviceMap : BYTE;  // Bit map of IDE devices.
   fCapabilities : DWORD; // Bit mask of driver capabilities.
   dwReserved    : packed array[0..3] of DWORD; // For future use.
end;

PGETVERSIONOUTPARAMS = ^GETVERSIONOUTPARAMS;
LPGETVERSIONOUTPARAMS = ^GETVERSIONOUTPARAMS;

//  IDE registers
IDEREGS = packed record
   bFeaturesReg     : BYTE;  // Used for specifying SMART "commands".
   bSectorCountReg  : BYTE;  // IDE sector count register
   bSectorNumberReg : BYTE;  // IDE sector number register
   bCylLowReg       : BYTE;  // IDE low order cylinder value
   bCylHighReg      : BYTE;  // IDE high order cylinder value
   bDriveHeadReg    : BYTE;  // IDE drive/head register
   bCommandReg      : BYTE;  // Actual IDE command.
   bReserved        : BYTE;  // reserved for future use.  Must be zero.
end;

PIDEREGS = ^IDEREGS;
LPIDEREGS = ^IDEREGS;

//  SENDCMDINPARAMS contains the input parameters for the
//  Send Command to Drive function.
SENDCMDINPARAMS = packed record
   cBufferSize  : DWORD;    //  Buffer size in bytes
   irDriveRegs  : IDEREGS; //  Structure with drive register values.
   bDriveNumber : BYTE;     //  Physical drive number to send
                            //  command to (0,1,2,3).
   bReserved    : packed array[0..2] of BYTE;   //  Reserved for future expansion.
   dwReserved   : packed array[0..3] of DWORD;  //  For future use.
   bBuffer      : packed array[0..0] of BYTE;   //  Input buffer.
end;

PSENDCMDINPARAMS = ^SENDCMDINPARAMS;
LPSENDCMDINPARAMS = ^SENDCMDINPARAMS;

// Status returned from driver
DRIVERSTATUS = packed record
   bDriverError : BYTE;                 //  Error code from driver, or 0 if no error.
   bIDEStatus   : BYTE;                 //  Contents of IDE Error register.
                                        //  Only valid when bDriverError is SMART_IDE_ERROR.
   bReserved    : packed array[0..1] of BYTE;  //  Reserved for future expansion.
   dwReserved   : packed array[0..1] of DWORD; //  Reserved for future expansion.
end;

PDRIVERSTATUS = ^DRIVERSTATUS;
LPDRIVERSTATUS = ^DRIVERSTATUS;

// Structure returned by PhysicalDrive IOCTL for several commands
SENDCMDOUTPARAMS = packed record
   cBufferSize  : DWORD;               //  Size of bBuffer in bytes
   DriverStatus : DRIVERSTATUS;        //  Driver status structure.
   bBuffer      : packed array[0..0] of BYTE; //  Buffer of arbitrary length in which to store the data read from the                                                       // drive.
end;

PSENDCMDOUTPARAMS = ^SENDCMDOUTPARAMS;
LPSENDCMDOUTPARAMS = ^SENDCMDOUTPARAMS;

USHORT = BYTE;

// The following struct defines the interesting part of the IDENTIFY
// buffer:
IDSECTOR = packed record
   wGenConfig                 : USHORT;
   wNumCyls                   : USHORT;
   wReserved                  : USHORT;
   wNumHeads                  : USHORT;
   wBytesPerTrack             : USHORT;
   wBytesPerSector            : USHORT;
   wSectorsPerTrack           : USHORT;
   wVendorUnique              : array[0..2] of USHORT;
   sSerialNumber              : array[0..19] of CHAR;
   wBufferType                : USHORT;
   wBufferSize                : USHORT;
   wECCSize                   : USHORT;
   sFirmwareRev               : array[0..7] of CHAR;
   sModelNumber               : array[0..39] of CHAR;
   wMoreVendorUnique          : USHORT;
   wDoubleWordIO              : USHORT;
   wCapabilities              : USHORT;
   wReserved1                 : USHORT;
   wPIOTiming                 : USHORT;
   wDMATiming                 : USHORT;
   wBS                        : USHORT;
   wNumCurrentCyls            : USHORT;
   wNumCurrentHeads           : USHORT;
   wNumCurrentSectorsPerTrack : USHORT;
   ulCurrentSectorCapacity    : ULONG;
   wMultSectorStuff           : USHORT;
   ulTotalAddressableSectors  : ULONG;
   wSingleWordDMA             : USHORT;
   wMultiWordDMA              : USHORT;
   bReserved                  : array[0..127] of BYTE;
end;

PIDSECTOR = ^IDSECTOR;

SRB_IO_CONTROL = packed record
   HeaderLength : ULONG;
   Signature    : packed array[0..7] of UCHAR;
   Timeout      : ULONG;
   ControlCode  : ULONG;
   ReturnCode   : ULONG;
   Length       : ULONG;
end;

PSRB_IO_CONTROL = ^SRB_IO_CONTROL;

TDWArray = packed array of DWORD;

const
  //  Required to ensure correct PhysicalDrive IOCTL structure setup
  MAX_IDE_DRIVES               = 4;
  //  Max number of drives assuming primary/secondary, master/slave topology
  IDENTIFY_BUFFER_SIZE         = 512;
  //  IOCTL commands
  DFP_GET_VERSION              = $00074080;
  DFP_SEND_DRIVE_COMMAND       = $0007c084;
  DFP_RECEIVE_DRIVE_DATA       = $0007c088;

  FILE_DEVICE_SCSI             = $0000001b;
  IOCTL_SCSI_MINIPORT_IDENTIFY = ((FILE_DEVICE_SCSI shl 16) + $0501);
  IOCTL_SCSI_MINIPORT          = $0004D008;  //  see NTDDSCSI.H for definition

  //  Bits returned in the fCapabilities member of GETVERSIONOUTPARAMS
  CAP_IDE_ID_FUNCTION            = 1;  // ATA ID command supported
  CAP_IDE_ATAPI_ID               = 2;  // ATAPI ID command supported
  CAP_IDE_EXECUTE_SMART_FUNCTION = 4;  // SMART commannds supported

  //  Valid values for the bCommandReg member of IDEREGS.
  IDE_ATAPI_IDENTIFY = $0A1;  //  Returns ID sector for ATAPI.
  IDE_ATA_IDENTIFY   = $0EC;  //  Returns ID sector for ATA.

var
  // Define global buffers.
  IdOutCmd : Integer = SizeOf(SENDCMDOUTPARAMS) + IDENTIFY_BUFFER_SIZE - 1;

{--------------------------------------------------------}

function ConvertToString(diskdata: Pointer; firstIndex, lastIndex: Integer): string;
var
  index    : Integer;
  ch       : char;
begin
 Result := '';
 //  each integer has two characters stored in it backwards
 for index := firstIndex to lastIndex do
   begin
     //  get high byte for 1st character
     ch := Char(Integer(Pointer(Integer(diskdata)+2*index)^) shr 8);
     Result := Result + ch;
     ch := Char(Integer(Pointer(Integer(diskdata)+2*index)^));
     Result := Result + ch;
   end;

   //  end the string
   Result := Result + #0;
end;

{--------------------------------------------------------}

procedure PrintIdeInfo(drive: Integer; diskdata: array of DWORD);
var
    DriveType : shortstring;
    sval: array [1..18] of shortString;

    procedure campo (msg: string; var valor: shortString);
    begin
        formCampo(msg, pegaTextoMensagem(msg), valor, 40);
    end;

begin
    writeln;
    garanteEspacoTela (7);
    defineNovoTamanhoDeRotulos(35);
    formCria;

    sval[1] := ConvertToString (@diskdata, 35, 54);
    campo('HVMODDSK', sval[1]);   // 'Modelo do disco'

    sval[2] := globalTrim(ConvertToString (@diskdata, 18, 27));
    campo('HVNUMSER', sval[2]);   // 'Número de série'

    sval[3] := ConvertToString (@diskdata, 31, 34);
    campo('HVREVCTL', sval[3]);   // 'Número de revisão do controlador'

    sval[4] := intToStr (Word(Pointer(Integer(@diskdata)+58)^)) + ' de 512';
    campo('HVBUFINT', sval[4]);   // 'Buffers Internos'

    if Boolean(diskdata[4] and $00080) then   DriveType := 'HVREMOVI'
    else
    if Boolean(diskdata[4] and $00040) then   DriveType := 'HVFIXA'
    else                                      DriveType := 'HVDESCON';
    driveType := pegaTextoMensagem(DriveType);

    campo('HVTIPOUN', DriveType); // 'Tipo de unidade'

    sval[5] := intToStr (Word(Pointer(Integer(@diskdata)+18)^));
    campo('HVCILIND', sval[5]);   // 'Cilindros',
    sval[6] := intToStr (Word(Pointer(Integer(@diskdata)+22)^));
    campo('HVCABECA', sval[6]);   // 'Cabeças'
    sval[7] := intToStr (Word(Pointer(Integer(@diskdata)+28)^));
    campo('HVSPT', sval[7]);      // 'Setores por Trilha'

    formEdita (false);
    restauraTamanhoDeRotulos;
    writeln;

end;


{--------------------------------------------------------}

function DoIDENTIFY(hPhysicalDriveIOCTL: THandle; pSCIP: PSENDCMDINPARAMS;
           pSCOP: PSENDCMDOUTPARAMS; bIDCmd, bDriveNum: BYTE;
           lpcbBytesReturned: PDWORD): Boolean;
var
 cbBytesReturned : DWORD;
begin
 // Set up data structures for IDENTIFY command.
 pSCIP.cBufferSize := IDENTIFY_BUFFER_SIZE;
 pSCIP.irDriveRegs.bFeaturesReg := 0;
 pSCIP.irDriveRegs.bSectorCountReg := 1;
 pSCIP.irDriveRegs.bSectorNumberReg := 1;
 pSCIP.irDriveRegs.bCylLowReg := 0;
 pSCIP.irDriveRegs.bCylHighReg := 0;

 // Compute the drive number.
 pSCIP.irDriveRegs.bDriveHeadReg := $0A0 or ((bDriveNum and 1) shl 4);

 // The command can either be IDE identify or ATAPI identify.
 pSCIP.irDriveRegs.bCommandReg := bIDCmd;
 pSCIP.bDriveNumber := bDriveNum;
 pSCIP.cBufferSize := IDENTIFY_BUFFER_SIZE;

 Result := DeviceIoControl(hPhysicalDriveIOCTL, DFP_RECEIVE_DRIVE_DATA,
             pSCIP, sizeof(SENDCMDINPARAMS) - 1, pSCOP,
             sizeof(SENDCMDOUTPARAMS) + IDENTIFY_BUFFER_SIZE - 1,
             cbBytesReturned, nil);
end;

{--------------------------------------------------------}

var diskdata : array[0..255] of DWORD;

function ReadPhysicalDriveInNT (drive: integer): Boolean;
var
    driveName : PChar;
    hPhysicalDriveIOCTL : THandle;
    VersionParams : GETVERSIONOUTPARAMS;
    cbBytesReturned : DWORD;
    bIDCmd : BYTE;
    scip : SENDCMDINPARAMS;
begin
    result := False;

    //  Try to get a handle to PhysicalDrive IOCTL, report failure
    //  and exit if can't.
    driveName := PChar(Format('\\.\PhysicalDrive%d', [drive]));

    //  Windows NT, Windows 2000, must have admin rights
    hPhysicalDriveIOCTL := CreateFile(driveName,
        { dwDesiredAccess }   GENERIC_READ or GENERIC_WRITE,
        { dwShareMode }       FILE_SHARE_READ or FILE_SHARE_WRITE,
                              nil,
                              OPEN_EXISTING, 0, 0);

    if hPhysicalDriveIOCTL <> INVALID_HANDLE_VALUE then
        begin
            // Get the version, etc of PhysicalDrive IOCTL
            FillChar(VersionParams, sizeof(VersionParams), 0);
            if not DeviceIoControl(hPhysicalDriveIOCTL, DFP_GET_VERSION,
                   nil, 0, @VersionParams, sizeof(VersionParams),
                   cbBytesReturned, nil) then
                begin
//                    mensagem ('HVFALHOU', 0); //'DFP_GET_VERSION falhou no drive '
//                    sintWriteln (driveName);
                    Exit;
                end;

            if VersionParams.bIDEDeviceMap > 0 then
                begin
                    // Now, get the ID sector for all IDE devices in the system.
                    // If the device is ATAPI use the IDE_ATAPI_IDENTIFY command,
                    // otherwise use the IDE_ATA_IDENTIFY command
                    if Boolean(VersionParams.bIDEDeviceMap shr drive and $010) then
                        bIDCmd := IDE_ATAPI_IDENTIFY else bIDCmd := IDE_ATA_IDENTIFY;

                    FillChar(scip, sizeof(scip), 0);
                    FillChar(diskdata, Length(diskdata), 0);

                    if DoIDENTIFY(hPhysicalDriveIOCTL, @scip,
                             @diskdata, bIDCmd, drive, @cbBytesReturned) then
                        begin
                            result := True;
                        end;
                end;
            CloseHandle(hPhysicalDriveIOCTL);
        end;
end;

procedure infoHD;
var
    drive, n: integer;
    tipoDrive: array [1..8] of integer;

begin
    writeln;
    mensagem ('HDESCUNI', 0);   // 'Escolha a unidade com as setas '

    garanteEspacoTela (8);
    popupMenuCria(wherex, wherey, 20, 8, MAGENTA);
    n := 0;
    for drive := 0 to 7 do
        if ReadPhysicalDriveInNT (drive) then
            begin
                popupMenuAdiciona ('HD_CTL' + chr(drive + ord('0')),
                                    pegaTextoMensagem ('HD_CTL' + chr(drive + ord('0'))));
                n := n + 1;
                tipoDrive[n] := drive;
            end;

    if n = 0 then
        begin
            if sintFalarTudo then
            begin
                sintBip;
                sintBip;
                sintBip;
            end;
            mensagem ('HVSEMHDS', 2);  // Nenhum HD identificado.
            mensagem ('HVSEMHDS2', 2);  // Execute o Dosvox como administrador para utilizar esta opção.
            exit;
        end;

    drive := popupMenuSeleciona;
    if drive < 1 then
        begin
            mensagem ('HVDESIST', 2);  // Desistiu
            exit;
        end;
    drive := tipoDrive [drive];

    writeln (pegaTextoMensagem ('HD_CTL' + chr(drive + ord('0'))));

    if not ReadPhysicalDriveInNT (drive) then
        sintBip  // impossível...
    else
        PrintIdeInfo(drive, diskdata);
end;

end.
