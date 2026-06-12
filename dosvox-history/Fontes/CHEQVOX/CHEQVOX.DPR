{--------------------------------------------------------}
{
{    Programa para emissão de cheques
{
{    Autor: Antonio Borges
{
{    Baseado no programa CheqVox de Xyko Gonçalves
{
{    Em Agosto de 2001
{
{--------------------------------------------------------}

{$N+}
program cheqvox;
uses dvcrt, dvwin, sysUtils, dvform,
     chvars, chmsg, chconfig, chemite, chlanc, chfolhe;

procedure inicializa;
var dir: string;
begin
    dir := sintAmbiente ('CHEQVOX', 'DIRCHEQVOX');
    if dir = '' then
        dir := sintAmbiente ('DOSVOX', 'PGMDOSVOX') + '\som\cheqvox';
    sintinic(0, dir);
    sintFalaPont := false;
    titulo;

    ini_cheqvox := sintDirAmbiente + '\Cheqvox.ini';
    if not fileExists (ini_cheqvox) then
         sintTranscreveAmbiente (ini_cheqvox);

    configInicial;

    mensagem ('CHF1AJUD', 2);    {'Aperte F1 se precisar de ajuda'}
end;

{--------------------------------------------------------}

procedure finaliza;
begin
    writeln;
    mensagem ('CHFIM', 1);    {'Fim do programa'}
    sintfim;
    doneWinCrt;
end;

{--------------------------------------------------------}

procedure ajuda;
begin
    mensagem ('CHAJUD0', 1);    {'As opções são:'}
    mensagem ('CHAJUD1', 1);    {'   C  configurar'}
    mensagem ('CHAJUD2', 1);    {'   E  emitir cheque'}
    mensagem ('CHAJUD3', 1);    {'   L  lancamento bancário'}
    mensagem ('CHAJUD4', 1);    {'   F  folhear lançamentos' }
    mensagem ('CHAJUD5', 1);    {'   X  gera extrato dos lançamentos' }
    mensagem ('CHAJUD9', 1);    {'   ESC  fim'}
    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

function selSetasOpcao: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var n: integer;
const
    tabLetrasOpcoes: string [5] = 'celfx';

begin
    garanteEspacoTela(5);
    popupMenuCria (wherex, wherey, 50, 5, MAGENTA);
    MenuAdiciona ('CHAJUD1');    {'   C  configurar'}
    MenuAdiciona ('CHAJUD2');    {'   E  emitir cheque'}
    MenuAdiciona ('CHAJUD3');    {'   L  lancamento bancário'}
    MenuAdiciona ('CHAJUD4');    {'   F  folhear lançamentos' }
    MenuAdiciona ('CHAJUD5');    {'   X  gera extrato dos lançamentos' }
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpcao := tabLetrasOpcoes[n]
    else
        selSetasOpcao := ENTER;
end;

{--------------------------------------------------------}

var
    fim: boolean;
    c, c2: char;
    label executa;
begin
    inicializa;

    fim := false;
    repeat
        writeln;
        textBackground (BLUE);
        mensagem ('CHOPCAO', 0);    {'Sua opção: '}
        textBackground (BLACK);
        sintLeTecla (c, c2);
        writeln;

        if c = #$0 then
            begin
                if (c2 = F1) then
                    ajuda
                else
                if (c2 = CIMA) or (c2 = BAIX) then
                    begin
                        c := selSetasOpcao;
                        goto executa;
                    end;
            end
        else
            begin
    executa:
                case upcase(c) of
                    'C': configura;
                    'E': emiteCheque;
                    'L': lancamentoBancario;
                    'F': folhear;
                    'X': geraExtrato;
                    BS, ENTER: ;
                    ESC: fim := true;
                else
                    begin
                        mensagem ('CHOPINV', 1);    {'Opção inválida, aperte F1 para ajuda'}
                    end;
                end;
            end;
    until fim;

    finaliza;
end.
