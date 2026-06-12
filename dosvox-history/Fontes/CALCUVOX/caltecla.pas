{--------------------------------------------------------}
{
{    Calculadora Vocal - versao 3.0
{
{    Módulo de funções de teclado
{
{    Autor: Jose' Antonio Borges
{           Mara Lucia Caldeira
{           Julio Tadeu Carvalho da Silveira
{
{    Versão 4.0 em maio/2019
{
{--------------------------------------------------------}

unit caltecla;

interface

uses
    calVars, calTela, sysUtils,
    dvcrt, dvAmplia, dvwin;

var
    lendoNumero: boolean;

procedure desleTecla (c: char);
procedure leTeclado (var c: char);
procedure entraNumero;

implementation

var
    mostrador: string;

{--------------------------------------------------------}

procedure desleTecla (c: char);
begin
    jaLido := true;
    ultLido := c;
end;

{--------------------------------------------------------}

procedure leTeclado (var c: char);
begin
    if jaLido then
        begin
            jaLido := false;
            c  := ultLido;
        end
    else
        if ptransf = NIL then
            c := readkey
        else
            repeat
                c := ptransf^;
                if c = '=' then
                    while keypressed do readkey;
                if c = #0 then
                    begin
                        ptransf := NIL;
                        c := readkey;
                    end
                else
                    ptransf := ptransf + 1;
            until (ptransf = NIL) or ((c <> #$0d) and (c <> #$0a));
end;

{--------------------------------------------------------}

procedure entraNumero;
var
    c: char;
    erro: integer;
    teclouPonto: boolean;
    removido: char;

begin
    if not lendoNumero then
    begin
        numVisor := 0.0;
        mostrador := '0';
        lendoNumero := true;
    end;
    teclouPonto := false;
    gotoxy (xVisor+tamVisor, yVisor);

    repeat
        leTeclado (c);
        if c = ',' then c := '.';

        if teclouPonto and (c = '.') then
            sintBip
        else
            if c = BS then
                begin
                    if length (mostrador) > 0 then
                        begin
                            removido := mostrador [length(mostrador)];
                            if removido = '.' then
                                teclouPonto := false;
                            if mostrador <> '0' then
                                begin
                                    sintSom ('_DEL');
                                    sintCarac (removido);
                                end
                            else
                                sintClek;
                            mostrador := copy (mostrador, 1, length(mostrador)-1);
                        end;

                end
            else
                if c in ['0'..'9', '.'] then
                    begin
                        if length (mostrador) >= tamVisor then
                            sintBip
                        else
                            begin
                                if (mostrador = '0') and (c in ['0'..'9']) then
                                        mostrador := '';
                                mostrador := mostrador + c;
                                sintCarac (c);
                            end;
                    end;

        if c = '.' then
            teclouPonto := true;

        if mostrador = '' then
            mostrador := '0';

        gotoxy (xVisor, yVisor);
        write (copy (brancosVisor, 1, tamVisor-length(mostrador)), mostrador);
        amplCampo(mostrador, 1);

    until not (c in ['0'..'9', '.', BS]);

    val (mostrador, numVisor, erro);

    desleTecla (c);
    //amplEsconde;
end;

begin
    mostrador := '0';
    lendoNumero := False;
end.
