{--------------------------------------------------------}
{
{     Monitvox - módulo de funções de mouse
{     Autor: Antonio Borges
{     Em 23/3/2003
{
{--------------------------------------------------------}

unit mvmouse;

interface
uses dvcrt, dvwin, Windows, sysUtils, oleAcc, mvVars, mvMsaa, mvMostra, mvMsg;

procedure registraPosMouse;
procedure posicionaMouse;

implementation

procedure registraPosMouse;
var pt: TPoint;
    posicao: string;
    c: char;
begin
    getCursorPos (pt);
    mensagem ('MOLETRA', 0);   {'Que letra associa a esta posição?'}
    c := sintReadkey;
    writeln (c);

    if (c = ESC) or (c = #$0) or (c < #20) or (c >= #$7f) then
        begin
            mensagem ('MODESIST', 1);   {'Desistiu'}
            while keypressed do readkey;
            exit;
        end;

    posicao := sintAmbiente ('MONITVOX', 'MOUSE_'+c);
    if posicao <> '' then
        begin
            mensagem ('MOJAREG', 0);  {'Letra já registrada, sobrescreve? '}
            c := sintReadkey;
            writeln (c);
            if upcase (c) = 'N' then
                exit;
        end;

    posicao := intToStr (pt.x) + ',' + intToStr (pt.y);
    sintGravaAmbiente ('MONITVOX', pchar ('MOUSE_'+c), posicao));
end;

procedure posicionaMouse;
var c: char;
    pt: TPoint;
    p: integer;
    posicao: string;
begin
    mensagem ('MOQLETRA', 0);    {'Que letra? '}
    c := sintReadkey;
    writeln (c);

    posicao := trim (sintAmbiente ('MONITVOX', 'MOUSE_'+c));
    p := pos (',', posicao);
    if p = 0 then
        begin
            mensagem ('MONAOREG', 0);  {'Letra não registrada'}
            exit;
        end;

    pt.x := strToInt (copy (posicao, 1, p-1));
    pt.y := strToInt (copy (posicao, p+1, 99));
    setCursorPos (pt.x, pt.y);
    mensagem ('MOOKREP', 1);   {'Mouse reposicionado'}
end;

end.

