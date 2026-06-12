{-------------------------------------------------------------}
{
{    Informações sobre o nome do computador
{
{    Autor: Jose' Antonio Borges
{
{    Em 09/04/2008
{
{-------------------------------------------------------------}

unit hardnome;

interface
uses
  dvCrt,
  dvExec,
  dvWin,
  dvForm,
  windows,
  sysutils,
  minireg,
  hardmsg;

procedure informacoesSistema;

implementation

{-------------------------------------------------------------}
function GetComputerName: string;
var
  buffer: array[0..256] of Char;
  Size: Cardinal;
begin
  Size := 256 + 1;
  Windows.GetComputerName(@buffer, Size);
  Result := StrPas(buffer);
end;

{-------------------------------------------------------------}
function Is64BitWindows: boolean;
type
  TIsWow64Process = function(hProcess: THandle; var Wow64Process: BOOL): BOOL;
    stdcall;
var
  DLLHandle: THandle;
  pIsWow64Process: TIsWow64Process;
  IsWow64: BOOL;
begin
  Result := False;
  DllHandle := LoadLibrary('kernel32.dll');
  if DLLHandle <> 0 then begin
    pIsWow64Process := GetProcAddress(DLLHandle, 'IsWow64Process');
    Result := Assigned(pIsWow64Process)
      and pIsWow64Process(GetCurrentProcess, IsWow64) and IsWow64;
    FreeLibrary(DLLHandle);
  end;
end;

{-------------------------------------------------------------}
procedure informacoesSistema;
var
    sval: array [1..17] of shortString;
    baseReg: string;
    s: string;

    function rget (key: string): string;
    var s: string;
    begin
        RegGetString(HKEY_LOCAL_MACHINE, baseReg+key, s);
        result := s;
    end;

begin
    garanteEspacoTela(12);
    writeln;

    defineNovoTamanhoDeRotulos (30);
    formCria;

    sval[1] := getComputerName;
    formCampo ('HVNMCOMP', pegaTextoMensagem('HVNMCOMP'), sval[1], 40);  // 'Nome do Computador'

    baseReg := 'SYSTEM\HardwareConfig\Current\';

    sval[2] := rget ('SystemManufacturer');
    formCampo ('HVFABRIC', pegaTextoMensagem('HVFABRIC'), sval[2], 40);  // 'Fabricante'

    baseReg := 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\';

    sval[3] := rget ('ProductName');
    formCampo ('HVSISTOP', pegaTextoMensagem('HVSISTOP'), sval[3],  40);  // 'Sistema Operacional'

    if Is64BitWindows then
        sval[4] := '64 bits'
    else
        sval[4] := '32 bits';
    formCampo ('HVSISTOP2', pegaTextoMensagem('HVSISTOP2'), sval[4],  40);  // 'Arquitetura do sistema operacional'

    sval[5] := rget ('CurrentVersion');
    formCampo ('HVSISVER', pegaTextoMensagem('HVSISVER'), sval[5],  40);  // 'Versão atual'
    sval[6] := rget ('CSDVersion');
    formCampo ('HVSISVAT', pegaTextoMensagem('HVSISVAT'), sval[6],  40);  // 'Versão da Atualização'
    sval[7] := rget ('RegisteredOwner');
    formCampo ('HVPROPRI', pegaTextoMensagem('HVPROPRI'), sval[7],  40);  // 'Proprietário'
    sval[8] := rget ('RegisteredOrganization');
    formCampo ('HVORGAN',  pegaTextoMensagem('HVORGAN'),  sval[8],  40);  // 'Organização'
    sval[9] := rget ('CurrentType');
    formCampo ('HVTIPSIS', pegaTextoMensagem('HVTIPSIS'), sval[9],  40);  // 'Tipo de sistema'
    sval[10] := rget ('CurrentBuildNumber');
    formCampo ('HVNUMGER', pegaTextoMensagem('HVNUMGER'), sval[10], 40);  // 'Número de geração atual'
    sval[11] := rget ('SystemRoot');
    formCampo ('HVROOTDI', pegaTextoMensagem('HVROOTDI'), sval[11], 40);  // 'Diretório de Root'

    baseReg := 'SOFTWARE\Microsoft\DirectX\';
    s := rget ('Version');
    Delete(s, 1, POS('.', s));
    sval[12] := Copy(s, 1, POS('.', s)-1);
    Delete(s, 1, POS('.', s));
    sval[12] := sval[12] + '.' + Copy(s, 1, POS('.', s)-1);

    formCampo ('HVDIRECX', pegaTextoMensagem('HVDIRECX'), sval[12], 40);  // 'DirectX versão'

    formEdita(false);
    restauraTamanhoDeRotulos;

end;

end.
