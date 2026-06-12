{---------------------------------------------------}

{
{     Medidor de bateria de Laptop
{     Autor: José Antonio Borges
{     Em 20/5/2008
{
{---------------------------------------------------}

program powervox;

uses dvwin, dvcrt, windows, sysutils;

const
    CRLF = ^m^j;
var
    powerStatus: _SYSTEM_POWER_STATUS;
    s: string;
    hh, mm: string;

    function hora (seg: DWORD): string;
    var
        horas, minutos: integer;
        s: string;
    begin
        if seg > 3600 then
            begin
                horas := seg div 3600;
                minutos := (seg mod 3600) div 60;

                if horas   > 1 then hh := ' horas'   else hh := ' hora';
                if minutos > 1 then mm := ' minutos' else mm := ' minuto';

                if minutos > 0 then
                    s := intToStr (horas)+ hh + ' e '+ intToStr (minutos) + mm
                else
                    s := intToStr (horas) + hh;
            end
        else
        if seg > 60 then
            begin
                minutos := seg div 60;
                if minutos > 1 then mm := ' minutos' else mm := ' minuto';
                s := intToStr (minutos) + mm
            end
        else
            s := intToStr (seg) + ' segundos ';
        hora := s;
    end;

begin
    screenSize.Y := 8;
    clrscr;
    sintInic (0, '');

    setWindowTitle ('PowerVox - Medidor de bateria');

    getsystempowerstatus (powerStatus);
    if (powerStatus.BatteryFlag = 1288888888888888) or ((powerStatus.BatteryFlag and 128) <> 0) then //Neno
        s := 'Não há bateria.'
    else
        begin
            if powerStatus.BatteryLifeTime <> $FFFFFFFF then
                s := hora (powerStatus.BatteryLifeTime);

            s := s + CRLF;
            s := s + intToStr (powerStatus.BatteryLifePercent) + ' por cento restante.';

            s := s + CRLF + 'Nível da bateria:';
            if powerStatus.BatteryFlag = 255 then
                s := s + ' indeterminado.'
            else
                begin
                    if (powerStatus.BatteryFlag and 1) <> 0 then
                        s := s + ' alto.';
                    if (powerStatus.BatteryFlag and 2) <> 0 then
                        s := s + ' baixo.';
                    if (powerStatus.BatteryFlag and 4) <> 0 then
                        s := s + ' crítico.';
                    if (powerStatus.BatteryFlag and 8) <> 0 then
                        s := s + ' Carregando.';
                    if (powerStatus.BatteryFlag and 128) <> 0 then
                        s := s + ' não há bateria.';
                end;

            if powerStatus.BatteryFullLifeTime <> $FFFFFFFF then
                begin
                    s := s + CRLF + 'Duração máxima: ';
                    s := s + intToStr (powerStatus.BatteryFullLifeTime) + ' segundos.';
                end;
        end;

    s := s + ' Energia externa: ';
    case powerStatus.ACLineStatus of
        0: s := s + 'desligada.';
        1: s := s + 'ligada.';
      255: s := s + 'indeterminada.';
    end;

    sintWrite (s);

    sintFim;
    doneWincrt;
end.
