{--------------------------------------------------------}
{
{    Programa de impressao do DOSVOX
{
{    Autor: Jose' Antonio Borges
{
{    Em marco/96
{
{--------------------------------------------------------}

program Imprivox;
uses DVcrt, DVWin, windows, dvArq,
     impvars, impmsg, impConf, impinipr, impform;

{--------------------------------------------------------}
{                  termina programa
{--------------------------------------------------------}

procedure terminaProg;
begin
    sintFim;
    doneWinCrt;
end;

{--------------------------------------------------------}
{                 abre os arquivos
{--------------------------------------------------------}

function abreArquivos: boolean;
label fim;
begin
    abreArquivos := false;

    nomeEntra := '';
    if paramCount >= 1 then
        begin
            nomeEntra := paramStr(1);
            while (nomeEntra <> '') and (nomeEntra[1] = ' ') do  delete (nomeEntra, 1, 1);
        end;

    if nomeEntra = '' then
        begin
            mensagem ('IMNOMARQ',0 );      {'Digite o nome do arquivo a imprimir: '}
            nomeEntra := obtemNomeArq (10);
            if nomeEntra = '' then
                exit;
            writeln;
        end;

    assign (arqentra, nomeentra);
    {$i-}  reset (arqentra, 1);  {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('IMARQNAO', 1);       {'Arquivo não foi achado'}
            exit;
        end;

    abreArquivos := true;
end;

{--------------------------------------------------------}
{                    inicializacao
{--------------------------------------------------------}

procedure inicializa;
begin
    sintInic (0, sintambiente ('IMPRIVOX', 'DIRIMPRIVOX'));

    clrscr;
    setWindowText (crtWindow, 'IMPRIVOX');
    delay (200);

    textBackground (BLUE);
    mensagem ('IMINIC', 0);     {'Programa de impressão formatada - v'}
    sintWriteln (versao);
    textBackground (BLACK);
    writeln;
end;

{--------------------------------------------------------}
{                   programa principal
{--------------------------------------------------------}

label fim;

begin
    inicializa;

    if not abreArquivos   then goto fim;
    if not pegaParametros then goto fim;

    if not abreImpressora (nomeEntra) then goto fim;

    mensagem ('IMINIFRM', 1);    {'Formatando o texto'}

    copiaAtual := 1;
    desistiu := false;
    while (copiaAtual <= ncopias) and (not desistiu) do
        begin
            if (copiaAtual <> 1) then    { na primeira cópia já está aberto }
                begin
                    {$I-} reset (arqentra, 1);  {$I+}
                    if ioresult <> 0 then
                       begin
                           mensagem ('IMERRLEI', 1);  {'Erro de leitura no arquivo'}
                           fechaImpressora;
                           goto fim;
                       end;
                end;

            desistiu := not imprimeFormatado;
            close (arqentra);

            if copiaAtual < ncopias then     { na ultima cópia não pula }
                jogaImpressora (pulaPag);

            copiaAtual := copiaAtual + 1;
        end;

    fechaImpressora;
    mensagem ('IMFIMTRA', 1);     {'Fim de trabalho'}
    terminaProg;

fim:
    mensagem ('IMPROCAN', 1);     {'Programa cancelado'}
    terminaProg;
end.
