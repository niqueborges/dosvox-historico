{--------------------------------------------------------}
{
{    Planilha eletronica VOX
{
{    Modulo principal
{
{    Autor:  Jose' Antonio Borges
{
{    Em dezembro/96
{
{--------------------------------------------------------}

program planivox;
uses
  dvcrt,
  dvwin,
  sysUtils,
  dvAmplia,
  plvars,
  plmsg,
  pltela,
  plopera,
  plarq;

{--------------------------------------------------------}
{                    inicializacao
{--------------------------------------------------------}

procedure inicializa;
var salva: integer;
    dir: string;
begin
    dir := sintAmbiente ('PLANIVOX', 'DIRPLANIVOX');
    if dir = '' then
        dir := 'c:\winvox\som\planivox';
    SintInic (0, dir);

    salva := amplFator;
    amplFim;
    amplInic(25-salva, salva);

    novaPlanilha (true);
    sintSom ('PLINIC');
    sintetiza (versao);

    criaSemEnter := true;
    posicArmazenada:= '';
    falaPosCel := true;

    setWindowTitle('Planivox');
    if paramCount <> 0 then
         begin
              nomePlan := paramStr(1);
              if upperCase (copy (nomePlan, length(nomePlan)-3, 4)) = '.CSV' then
                  begin
                      carregaCSV(nomePlan);
                      delete (nomePlan, length(nomePlan)-3, 4);
                      nomePlan := nomePlan + '.csv';
                  end
              else
                  carregaPlanilha(nomePlan);
              nomeArq := nomePlan;
         end;
end;

{--------------------------------------------------------}
{                      operacao
{--------------------------------------------------------}

procedure finaliza;
begin
    sintFim;
    gotoxy (1, 25);
    clreol;
    doneWinCrt;
end;

{--------------------------------------------------------}
{                 programa principal
{--------------------------------------------------------}

begin
    inicializa;
    opera;
    finaliza;
end.
