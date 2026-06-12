{--------------------------------------------------------}
{
{    Programa para tornar o I-CHING acessível aos cegos
{
{    Autor: José Antonio Borges
{
{    Em 24/06/97
{
{--------------------------------------------------------}

program ichinvox;

uses dvcrt, dvWin,
     ichVars, ichCalc, ichInter, ichTela;

{--------------------------------------------------------}
{                      inicializacao
{--------------------------------------------------------}

procedure inicializa;
var dir: string;
begin
    randomize;
    pergunta := '';
    telaBasica;

    dir := sintAmbiente('ICHINVOX', 'DIRICHINVOX');
    if dir = '' then
        dir := '\winvox\som\ichinvox';

    sintInic (0, dir);

    dirTextos := sintAmbiente ('ICHINVOX', 'TEXTOICHINVOX');
    if dir = '' then
        dir := '\winvox\ichinvox';

    if dirTextos [length (dirTextos)] <> '\' then
        dirTextos := dirTextos + '\';

    sintSom ('ICINIC');
end;

{--------------------------------------------------------}
{                       finalizacao
{--------------------------------------------------------}

procedure finaliza;
begin
    sintSom ('ICFINAL');
    while sintFalando do;
    sintFim;
    doneWinCrt;
end;

{--------------------------------------------------------}
{                   programa principal
{--------------------------------------------------------}

begin
    inicializa;

    repeat
        telaBasica;
        pedePergunta;
        realizaJogada;

        calculaDiagnostico;
        fazMutacao;
        calculaPrognostico;

        exibeResumo (false);

        interacao;

        pergunta := '';

    until not outraConsulta;

    finaliza;
end.
