{-------------------------------------------------------------}
{
{    Telnet Falado
{
{    Modulo de autobusca
{
{    Autor: Jose' Antonio Borges
{
{    Em 24/04/98
{
{-------------------------------------------------------------}

unit tnbusca;
interface
uses
    winprocs, wintypes, dvcrt, sysUtils, dvWin, winsock,
    tnvars, tnfala, tnansi, tnRede, tnMsg,
    dvHora, videovox;

procedure autoBusca;
procedure autoRebusca;

implementation

var txtBusc: string;

{-------------------------------------------------------------}
{                     pede texto a buscar
{-------------------------------------------------------------}

procedure pedeTexto;
var c: char;
begin
    txtBusc := '';
    repeat
        c := readkey;
        if c = #$1b then
            begin
                sintBip; sintBip;
                txtBusc := '';
                exit;
            end;

        if c = BS then   { Backspace }
            begin
                if txtBusc <> '' then
                    begin
                        sintSom ('_DEL');
                        sintCarac (txtBusc [length(txtBusc)]);
                        delete (txtBusc, length (txtBusc), 1);
                    end;
            end
        else
            if c <> ENTER then
                begin
                    txtBusc := txtBusc + c;
                    sintCarac (c);
                end;
    until c = ENTER;
end;

{-------------------------------------------------------------}
{         envia seta para baixo até chegar texto buscado
{-------------------------------------------------------------}

procedure autoRebusca;
var achou: boolean;
    i, y: integer;
    c: char;
    s: string;
begin
    if txtBusc = '' then
        begin
            sintBip; sintBip;
            exit;
        end;

    for i := 1 to length (txtBusc) do
         txtBusc [i] := upcase (txtBusc [i]);

    achou := false;
    while not (keypressed or achou) do
        begin
            escLetras (#$1b + '[B');
            repeat
                delay (delaybusca);
            until keypressed or chegoulink;

            if chegouLink then sintClek;

            while chegouLink do
                begin
                    leLink (c);
		    ansiwrite (c);
                end;

            s := '';
            y := wherey;
            for i := 1 to 80 do
                s := s + upcase (getScreenChar (i, y));

            if pos (txtBusc, s) <> 0 then
                achou := true;
        end;

    if keypressed then
        begin
            sintBip; sintBip;
            while keypressed do readkey;
        end;
    ultycur := -1;
end;

{-------------------------------------------------------------}
{                  pede texto e busca
{-------------------------------------------------------------}

procedure autoBusca;
begin
    msgBaixo ('TNINFBUS');
    pedeTexto;
    msgBaixo ('');
    if txtBusc <> '' then
        autoRebusca;
end;

begin
    txtBusc := '';
end.
