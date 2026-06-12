{-------------------------------------------------------------}
{
{    Informações sobre os Monitores instalados
{
{    Autor: Jose' Antonio Borges
{
{    Em 09/04/2008
{
{-------------------------------------------------------------}

//  This code is converted for Borland Delphi 7 by Sorin Chitu from a VBScript,
//  coded on 17 June 2004 by Michael Baird
//
//  original code was released by Michael Baird  under the terms of
//  GNU open source license agreement (that is of course if you CAN
//  release code that uses WMI under GNU)
//
//  Please give Michael Baird credit if you use it!
//
//  This code is based on the EEDID spec found at http://www.vesa.org and by
//  Michael Baird hacking around in the windows registry the code was tested
//  on WINXP,WIN2K and WIN2K3; it should work on WINME and WIN98SE
//  It should work with multiple monitors, but that hasn't been tested either.

unit hardmoni;

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

procedure infoVideo;

implementation

procedure infoVideo;
var i: integer;
    prov, driver, res: string;
    provAnt, driverAnt, resAnt: string;
    base: string;
begin
    writeln;
    mensagem ('HVSETGRF', 2);   {'Controladores gráficos - use as setas para folhear'}

    base := 'SYSTEM\CurrentControlSet\Control\Class\' +
            '{4D36E968-E325-11CE-BFC1-08002BE10318}\';

    garanteEspacoTela (10);
    opcoesCria (wherex, wherey, 50);
    for i := 0 to 9 do
        begin
            if not RegGetString(HKEY_LOCAL_MACHINE, base +
                     '000' + chr(i + ord('0')) + '\ProviderName', prov) then
                break;

            opcoesAdiciona ('', 'Fabricante: '+ prov);

            RegGetString(HKEY_LOCAL_MACHINE, base +
                     '000' + chr(i + ord('0')) + '\DriverDesc', driver);

            opcoesAdiciona ('', '    Driver: '+ driver);
        end;

    TextBackground(Magenta);
    opcoesSeleciona;
    TextBackground(Black);

    writeln;
    mensagem ('HVSETMON', 2);   {'Monitores - use as setas para folhear'}

    base := 'SYSTEM\CurrentControlSet\Control\Class\' +
            '{4D36E96E-E325-11CE-BFC1-08002BE10318}\';

    garanteEspacoTela (10);
    opcoesCria (wherex, wherey, 50);

    provAnt := '@##@';
    for i := 0 to 9 do
        begin
            if not RegGetString(HKEY_LOCAL_MACHINE, base +
                     '000' + chr(i + ord('0')) + '\ProviderName', prov) then
                        break;

            RegGetString(HKEY_LOCAL_MACHINE, base +
                     '000' + chr(i + ord('0')) + '\DriverDesc', driver);
            RegGetString(HKEY_LOCAL_MACHINE, base +
                     '000' + chr(i + ord('0')) + '\maxResolution', res);

            if (provAnt <> prov) or (driverAnt <> driver) or (resAnt <> res) then
                begin
                    opcoesAdiciona ('', pegaTextoMensagem ('HV_FAB') + prov);    // 'Fabricante: '
                    opcoesAdiciona ('', pegaTextoMensagem ('HV_DRV') + driver);  // '    Driver: '
                    opcoesAdiciona ('', pegaTextoMensagem ('HV_RES') + res);     // '    Resolução máxima: '
                end;

            provAnt := prov;
            driverAnt := driver;
            resAnt := res;
        end;

    TextBackground(Magenta);
    opcoesSeleciona;
    TextBackground(Black);
end;

end.








