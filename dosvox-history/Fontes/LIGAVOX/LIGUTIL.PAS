{--------------------------------------------------------}
{        LIGAVOX - rotinas utilitarias
{--------------------------------------------------------}

unit ligUtil;

interface
uses dvCrt, dvWin, dvComm,
    winTypes, winProcs, sysutils, shellApi;

procedure saiLink (s: string; espera: integer);
function discaModem(numeroTel: string): boolean;
procedure desligaModem;

implementation

{--------------------------------------------------------}
{                   sai string no link
{--------------------------------------------------------}

procedure saiLink (s: string; espera: integer);
var i: integer;
    c: char;
begin
    for i := 1 to length (s) do
        begin
            esclink (s[i]);
            delay (50);
        end;

    for i := 1 to espera div 100 do
        begin
            while chegouLink do
                begin
                    lelink(c);
                    write (c);
                    if c = #$0a then
                        sintclek;
                end;
            delay (100);
        end;
end;

{--------------------------------------------------------}
{                     disca modem
{--------------------------------------------------------}

function discaModem (numeroTel: string): boolean;
var tonePulse: string;
begin
    tonePulse:= sintAmbiente('LIGAVOX', 'TONEPULSE');
    if tonePulse = '' then
        tonePulse:= 'P';

    saiLink ('ATH1'+ENTER, 500);
    saiLink ('ATD'+ tonePulse + numeroTel+ENTER, 1000);

    discaModem:= true;

end;

{--------------------------------------------------------}
{                   desliga modem
{--------------------------------------------------------}

procedure desligaModem;
begin

    saiLink ('+++', 500);
    saiLink ('ATH0'+ENTER, 500);
    saiLink ('ATS0=0'+ENTER, 500);

end;

begin
end.
