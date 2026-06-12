{-------------------------------------------------------------}
{
{    Informações sobre a placa mãe, trazida do Registro do Windows
{
{    Autor: Jose' Antonio Borges
{
{    Em 09/04/2008
{
{-------------------------------------------------------------}

unit hardmbrd;

interface

uses
  dvCrt,
  dvExec,
  dvWin,
  dvForm,
  dvMacro,
  windows,
  messages,
  classes,
  sysutils,
  hardmsg,
  minireg;


procedure infoPlacaMae;

implementation

{-------------------------------------------------------------}
{                mostra informações da placa mãe
{-------------------------------------------------------------}

procedure infoPlacaMae;
var
    sval: array [1..17] of shortString;
    baseReg: string;

    function rget (key: string): string;
    var s: string;
    begin
        RegGetString(HKEY_LOCAL_MACHINE, baseReg+key, s);
        result := s;
    end;

begin
    garanteEspacoTela(4);
    writeln;

    defineNovoTamanhoDeRotulos (30);
    formCria;

    baseReg := 'HARDWARE\DESCRIPTION\System\BIOS\';

    sval[1] := rget ('BaseBoardProduct');
    formCampo ('HVMODELO', pegaTextoMensagem('HVMODELO'), sval[1], 40);  // 'Modelo'

    sval[2] := rget ('BaseBoardManufacturer');
    formCampo ('HVFABRIC', pegaTextoMensagem('HVFABRIC'), sval[2], 40);    // 'Fabricante'

    sval[3] := rget ('BIOSVendor');
    formCampo ('HVFBCHIP', pegaTextoMensagem('HVFBCHIP'), sval[3], 40);   // 'Fabricante do Chip'

    sval[4] := rget ('SystemFamily');
    formCampo ('HVFMLY', pegaTextoMensagem('HVFMLY'), sval[4], 40);   // 'Família do Produto'

    sval[5] := rget ('BaseBoardVersion');
    formCampo ('HVBOARDVER', pegaTextoMensagem('HVBOARDVER'), sval[5], 40);   // 'Versão da Placa Mãe'

    sval[6] := rget ('systemversion');
    formCampo ('HVSYSVER', pegaTextoMensagem('HVSYSVER'), sval[6], 40);   // 'Versão do Produto'

    sval[7] := rget ('systemsku');
    formCampo ('HVSYSSKU', pegaTextoMensagem('HVSYSSKU'), sval[7], 40);   // 'SKU do sistema'

    sval[8] := rget ('systemproductname');
    formCampo ('HVSYSPRDNAME', pegaTextoMensagem('HVSYSPRDNAME'), sval[8], 40);   // 'Nome do Produto'

    formEdita(false);
    restauraTamanhoDeRotulos;
end;
end.
