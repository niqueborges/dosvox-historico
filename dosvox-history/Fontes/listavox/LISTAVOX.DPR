{--------------------------------------------------------}
{
{    Programa de impressao comum
{
{    Autor: Jose' Antonio Borges e Geraldo Junior
{
{    Em 26/06/2000
{
{--------------------------------------------------------}

program listavox;
uses dvCrt, dvWin, dvarq, windows, 
     lisVars, lisMsg, lisConf, lisIniPr, lisImpr;

{--------------------------------------------------------}
{                  termina programa
{--------------------------------------------------------}

procedure terminaProg;
begin
    sintFim;
    delay (1000);
    doneWinCrt;
end;

{--------------------------------------------------------}
{                 abre os arquivos
{--------------------------------------------------------}

procedure abreArquivos;
label fim;
begin
    nomeEntra := '';
    if paramCount >= 1 then
        begin
            nomeEntra := paramStr(1);
            while (nomeEntra <> '') and (nomeEntra[1] = ' ') do  delete (nomeEntra, 1, 1);
        end;

    if nomeEntra = '' then
        begin
            mensagem ('LINOMARQ', 1);    {'Qual o nome do arquivo a imprimir ? '}
            nomeEntra := obtemNomeArq (10);
            writeln;
            if nomeEntra = '' then
                goto fim;
        end;

    assign (arqentra, nomeentra);
    {$i-}  reset (arqentra, 1);  {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('LIARQNAO', 1);     {'Este arquivo não existe'}
            goto fim;
        end;

    exit;

fim:
    mensagem ('LIIMPCAN', 1);                {'Impressão cancelada'}
    terminaProg;
end;

{--------------------------------------------------------}
{                    inicializacao
{--------------------------------------------------------}

procedure inicializa;
var
    dir: string;
begin
    dir := sintAmbiente ('LISTAVOX', 'DIRLISTAVOX');
    if dir = '' then
        dir := 'c:\winvox\som\listavox';
    sintInic (0, dir);

    clrscr;
    setWindowText (crtWindow, 'LISTAVOX');
    delay (200);

    textBackground (BLUE);
    mensagem ('LIINIC', 0);     {'Impressor - NCE/UFRJ - v.'}
    writeln (versao);
    sintSoletra (versao);
    textBackground (BLACK);
    writeln;
end;

{--------------------------------------------------------}
{                   programa principal
{--------------------------------------------------------}

label fim;

begin
    inicializa;
    abreArquivos;

    if pegaParametros then
        if abreImpressora (nomeEntra) then
            imprime
        else
            mensagem ('LIERRPRN', 1);    {'Não consegui alocar a impressora'}

    terminaProg;
end.
