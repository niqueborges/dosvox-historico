{-------------------------------------------------------------}
{
{    Informações sobre a CPU, capturadas no registry
{
{    Autor: Jose' Antonio Borges
{
{    Em 09/04/2008
{
{-------------------------------------------------------------}

unit hardcpu;

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

procedure infoCPU;

implementation
{
    HKEY_LOCAL_MACHINE

        HARDWARE\DESCRIPTION\System\CentralProcessor\0   // futuramente mais de uma CPU

[1]         'ProcessorNameString'   // 'Processador'
[2]         '~Mhz'                  // 'Velocidade em MHz'
[3]         'VendorIdentifier'      // 'Fabricante'
[4]         'Identifier'            // 'Identificação'
[5]         'Update Status'         // 'Status da atualização'
[6]         'Identifier'            // 'Tipo da Placa Mãe'

        HARDWARE\DESCRIPTION\System

[7]         'SystemBiosDate'        // 'Data da BIOS'
[8]         'SystemBiosVersion'     // 'Versão da BIOS'
[9]         'VideoBiosDate'         // 'Data da BIOS de vídeo'
[10]        'VideoBiosVersion'      // 'Versão da BIOS de vídeo'

}

procedure globalTrim (var s: shortString);
var
    i, esq, dir: integer;
    espacolido: boolean;
label
    continue;
begin
    s := TrimLeft (s);
    i := 1;
    espacolido := true;

    while i <= length(s) do
        begin
            if s[i] = ' ' then
                begin
                    if not espacolido then
                        espacolido := true
                    else
                        begin
                            esq := i;
                            dir := i+1;
                            while (dir <= length(s)) and (s[dir] = ' ') do
                                dir := dir +1;
                            if dir > length(s) then
                                i := dir
                            else
                                begin
                                    i := esq;
                                    espacolido := false;
                                    while dir <= length(s) do
                                        begin
                                            s[esq] := s[dir];
                                            esq := esq +1;
                                            dir := dir +1;
                                        end;
                                    while esq <= length(s) do
                                        begin
                                            s[esq] := ' ';
                                            esq := esq +1;
                                        end;
                                end;
                            goto continue;
                        end
                end
            else
                espacolido := false;

            i := i +1;
continue:
        end;    // while i <= length(s)

    s := TrimRight (s);

end;

procedure infoCPU;
var
    ncpu: integer;
    base: string;
    sval: array [1..18] of shortString;
    i: integer;
    s: string;

    function rget (key: string): string;
    var s: string;
    begin
        RegGetString(HKEY_LOCAL_MACHINE,
            base + '\' + key, s);
        result := s;
    end;

    function rgetDWord (key: string): Cardinal;
    var v: Cardinal;
    begin
        RegGetDWORD (HKEY_LOCAL_MACHINE,
            base + '\' + key, v);
        result := v;
    end;

   begin
    ncpu := 0;   // futuramente para processar mais de uma CPU
    base := 'HARDWARE\DESCRIPTION\System\CentralProcessor\' + chr (ncpu + ord('0'));

    garanteEspacoTela(10);
    writeln;

    defineNovoTamanhoDeRotulos(30);
    formCria;

    sval[1] := rget ('ProcessorNameString');
    globalTrim(sval[1]);
    formCampo ('HVPROCES', pegaTextoMensagem('HVPROCES'),  sval[1], 40);  // 'Processador'

    sval[2] := intToStr (rgetDWord ('~Mhz'));
    formCampo ('HVVELCPU', pegaTextoMensagem('HVVELCPU'),  sval[2], 40);  // 'Velocidade em MHz'

    sval[3] := rget ('VendorIdentifier');
    formCampo ('HVFABCPU', pegaTextoMensagem('HVFABCPU'),  sval[3], 40);  // 'Fabricante'

    sval[4] := rget ('Identifier');
    formCampo ('HVCPUID',  pegaTextoMensagem('HVCPUID'),   sval[4], 40);  // 'Identificação'

    sval[5] := intToStr (rgetDWord ('Update Status'));
    formCampo ('HVSTATAT', pegaTextoMensagem('HVSTATAT'),  sval[5], 40);  // 'Status da atualização'

    sval[6] := rget ('Identifier');
    formCampo ('HVTIPOPM', pegaTextoMensagem('HVTIPOPM'),  sval[6], 40);  // 'Tipo da Placa Mãe'

    base := 'HARDWARE\DESCRIPTION\System';

    sval[7] := rget ('SystemBiosDate');
    formCampo ('HVDTBIOS', pegaTextoMensagem('HVDTBIOS'),  sval[7], 40);  // 'Data da BIOS'

    RegGetMultiString(HKEY_LOCAL_MACHINE, base + '\SystemBiosVersion', s);
    sval[8] := s;
    for i := 1 to length (s) do if s[i] = #$0 then s[i] := '|';
    formCampo ('HVVBIOS', pegaTextoMensagem('HVVBIOS'),    sval[8], 40);  // 'Versão da BIOS'

    sval[9] := rget ('VideoBiosDate');
    formCampo ('HVDBIOSV', pegaTextoMensagem('HVDBIOSV'),  sval[9], 40);  // 'Data da BIOS de vídeo'

    RegGetMultiString (HKEY_LOCAL_MACHINE, base + '\VideoBiosVersion', s);
    sval[10] := pchar(s);
    formCampo ('HVVBIOSV', pegaTextoMensagem('HVVBIOSV'),  sval[10], 40);  // 'Versão da BIOS de vídeo'

    formEdita (false);
    restauraTamanhoDeRotulos;
end;

end.
