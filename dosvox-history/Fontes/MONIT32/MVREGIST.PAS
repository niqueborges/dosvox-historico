{--------------------------------------------------------}
{
{     Monitvox - módulo de funções de mouse
{     Autor: Antonio Borges
{     Em 23/3/2003
{
{--------------------------------------------------------}

unit mvRegist;

interface
uses dvcrt, dvwin, dvform, Windows, sysUtils, classes, oleAcc, mvVars, mvMsaa, mvMsg, mvPosjan;

procedure registraPosMouse;
procedure posicionaMouse;
procedure posicionamentoRapido (var xnovo, ynovo: integer);

function pegaNomeRegistrado (xob, yob: integer; nomeUltJan: string): string;
procedure registraNome (xob, yob: integer; nomeUltJan: string);

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
    sintGravaAmbiente ('MONITVOX', 'MOUSE_'+c, posicao);
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

{--------------------------------------------------------}
{               posicionamento rápido
{--------------------------------------------------------}

procedure posicionamentoRapido (var xnovo, ynovo: integer);
var
    nomes: array [0..10000] of char;
    campo: string;
    nomeCampos: TStringList;
    i, n, erro: integer;
    p: pchar;
    xy: string;
begin
    xnovo := -1;
    clrscr;
    if nomeUltJan = '' then
         begin
             mensagem ('MVSEMPRG', 1);  {'Nada foi programado'}
             exit;
         end;

    getPrivateProfileString (@nomeUltJan[1], NIL, '', nomes, 10000, pChar(monitConfigs));
    p := nomes;

    if p = #$0 then
         begin
             mensagem ('MVSEMPRG', 1);  {'Nada foi programado'}
             exit;
         end;

    nomeCampos := TStringList.Create;
    while p^ <> #0 do
        begin
            nomeCampos.add (strPas (p));
            p := p + strLen (p) + 1;
        end;

    posjan (0, 0, 30, nomeCampos.count);
    popupMenuCria (1, 1, 30, nomeCampos.count, BLACK);

    for i := 0 to nomeCampos.count-1 do
        begin
            campo := sintAmbienteArq(nomeUltJan, nomeCampos[i], '', monitConfigs);
            popupMenuAdiciona ('', campo);
        end;

    n := popupMenuSeleciona;
    if n < 1 then
        begin
            posjan (0, 0, 42, 4);
            mensagem ('MVDESIST', 1);   {'Desistiu'}
            exit;
        end;

    posjan (0, 0, 42, 4);

    xy := nomeCampos [n-1];
    nomeCampos.free;

    i := pos ('_', xy);
    val (copy (xy, 1, i-1),   xnovo, erro);
    val (copy (xy, i+1, 999), ynovo, erro);
end;

{--------------------------------------------------------}
{                recupera um nome registrado
{--------------------------------------------------------}

function pegaNomeRegistrado (xob, yob: integer; nomeUltJan: string): string;
var
    s: string;
begin
    s := intToStr (xob) + '_' + intToStr (yob);
    result := sintAmbienteArq (nomeUltJan, s, '', monitConfigs);
end;

{--------------------------------------------------------}
{                registra um nome
{--------------------------------------------------------}

procedure registraNome (xob, yob: integer; nomeUltJan: string);
var
    nomeCampo: string;
    s: string;
    c: char;
begin
    clrscr;

    s := intToStr (xob) + '_' + intToStr (yob);

    nomeCampo := sintAmbienteArq (nomeUltJan, s, '', monitConfigs);
    if nomeCampo <> '' then
        mensagem ('MVREPROG', 1);   {'Cuidado, nome sendo reprogramado'}

    mensagem ('MVNOMECP', 1);   {'Nome deste campo:'}
    c := sintEdita (nomeCampo, wherex, wherey, 40, true);
    if (c = ESC) or (nomeCampo = '') then
        begin
            mensagem ('MVDESIST', 1);   {'Desistiu'}
            exit;
        end;

    sintGravaAmbienteArq (nomeUltJan, s, nomeCampo, monitConfigs);
end;

end.

