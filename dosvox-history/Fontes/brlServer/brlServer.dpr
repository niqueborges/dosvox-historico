{--------------------------------------------------------}
{
{    brlServer, servidor de linhas Braille multi cliente
{
{    Módulo principal
{
{    Autores: Patrick Barboza e Antonio Borges
{
{    Em julho/agosto/2023
{
{    Atualizado em Agosto/2024
{
{--------------------------------------------------------}

program brlServer;

uses
    windows,
    sysUtils,
    dvCrt,
    dvWin,
    dvForm,
    dvInet,
    brlRede,
    brlDispositivos,
    brlVars;

{--------------------------------------------------------}

procedure inicializa;
var
    parametro: string;
begin
    sintInic(0, '');
    setWindowTitle('BRLServer - Servidor de linhas Braille');

    textBackground(BLUE);
    sintWrite('Servidor de linhas Braille - Versão ');
    writeln(VERSAO);
    sintSoletra(VERSAO);
    if TIPOVERSAO <> '' then sintWrite(' '+TIPOVERSAO);
    textBackground(BLACK);
    writeln;

    writeln('Instituto Tércio Pacitti, NCE/UFRJ');
    writeln('Projeto DOSVOX - 2024');
    if paramCount >= 1 then
    begin
        parametro := paramStr(1);
        if (upperCase(parametro) = '/D') then
        begin
            debug := true;
            sintWriteln('Depuração ligada');
        end;
    end;
end;

{--------------------------------------------------------}

procedure termina;
begin
    sintWriteln('Fim do servidor');
    fechaDispositivo;
    delay(500);
    sintFim;
    doneWinCrt;
end;

{--------------------------------------------------------}
{    Programa principal
{--------------------------------------------------------}

var
    c: char;
begin
    inicializa;

    nomeDisp := selecionarDispositivo;
    if (nomeDisp = SEM_BRAILLE) then
    begin
        sintWriteln('Nenhum dispositivo definido.');
        sintWriteln('Deseja configurar um agora?');
        c := popupMenuPorLetra('SN');
        if upCase(c) = 'S' then configuraDispositivo
        else
        begin
            sintWriteln('Desistiu...');
            termina;
        end;
    end;
    if inicializaDispositivo (nomeDisp) then
         processaRede;

    termina;
end.
