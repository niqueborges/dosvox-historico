{--------------------------------------------------------------}
{
{   PPTVOX - exibidor interativo de apresentações
[
{   Programa Principal
{
{   Autores: Antonio Borges, Bernard Condorcet e Mara Caldeira
{
{   Junho/2015
{
{   Versão original: julho/2008
{
{--------------------------------------------------------------}

program pptvox;

uses
  dvcrt,
  dvwin,

  windows,
  messages,
  SysUtils,

  ppvars,
  ppmsg,
  ppjanela,
  ppArq,
  ppproc,
  ppdesen,
  ppinic;

procedure finaliza;  forward;

{--------------------------------------------------------}
{     Diretório de trabalho, estilos e figura de fundo
{--------------------------------------------------------}

procedure defineDirTrab;
var infDirTrab: char;
begin

    mensagem ('PPDIRTRA', 1); {('Informe o diretório de trabalho');}
    delay (100);
    mensagem ('PPENTPAD', 1); {('Pressionando ENTER usarei o padrão');}
    infDirTrab:= sintEditaCampo (dirEstilos, 1, wherey, 255, 80, true);

    if infDirTrab = ESC then
        finaliza;

    if dirEstilos = '' then
        getDir (0, dirEstilos);

    if not trocaDir(dirEstilos) then
        finaliza
    else
    begin
        writeln;
        mensagem ('PPIRETRA', 0); {('OK, irei trabalhar em : ');}
        sintWriteln (dirEstilos);

        figuraDeFundo:= (sintAmbiente('PPTVOX', 'FIGURADEFUNDO'));
        if not existeArq(trim(figuraDeFundo)) then
            figuraDeFundo := fundoPadrao;
    end;

end;

{--------------------------------------------------------}
{                       Inicialização
{--------------------------------------------------------}

// Abre a janeta do PPTVOX, títulos, Inicializa as
// variaveis, Fontes, Cor do fundo, player e efeitos de
// teclado

procedure inicializa;
var jan: integer;
    dir: string;
begin
    // evita duas instância deste programa simultaneas

    jan := findWindowEx(0, 0, 'dvwincrt', 'PPTVOX');
    if jan <> 0 then
        halt;

    // cabeçalho
    clrscr;
    setWindowText (crtWindow, 'PPTVOX');

    dir := sintAmbiente('PPTVOX', 'DIRPPTVOX');
    if dir = '' then
        dir := 'c:\winvox\som\pptvox';
    SintInic (0, dir);

    textBACKGROUND (BLUE);
    mensagem ('PPINIC', 0); {'PPTVOX - V:'}
    sintWriteln (versao);
    textBackground (BLACK);
    writeln;
    writeln ('PROJETO DOSVOX - Instituto Tércio Pacitti - NCE/UFRJ');
    writeln;

    // inicializações

    getDir (0, dirPPX);

    inicializaVariaveis;
    inicializaConfigPlayer;
    inicializaCoresEFontes;

    if paramCount = 0 then
        defineDirTrab
    else
        begin
            if not pegaParamLinhaDeComando then
                finaliza;
        end;

    if not existeArq ('Padrão PPTVOX.est') then
        geraArqPadrao;     // *********** melhorar com a resolução da tela atual ************

end;

{--------------------------------------------------------------}
{                       termina o programa
{--------------------------------------------------------------}

// Mensagem do Fim do programa, finaliza a fala, e destroi a janela

procedure finaliza;
begin
    writeln;
    mensagem ('PPFIM', 0);  {'Fim do programa'}
    delay (100);
    sintSom ('PPSAIR');
    while sintFalando do waitMessage;

    delay (500);
    sintFim;
    doneWincrt;

end;

{--------------------------------------------------------}
{            Início do programa PPTVOX.PAS
{--------------------------------------------------------}

begin
    inicializa;
    processa;
    finaliza;
end.
