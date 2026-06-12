{--------------------------------------------------------}
{
{    Calculadora Vocal - versao 4.0
{
{    Módulo principal
{
{    Autor: Jose' Antonio Borges
{           Mara Lucia Caldeira
{           Julio Tadeu Carvalho da Silveira
{
{    Versão 1.0 em 5/5/1996
{    Versão 3.0 em setembro/2015
{    Versão 4.0 em maio/2019
{
{--------------------------------------------------------}

program Calcuvox;

uses
  DVcrt,
  DVWin,
  DVHora,
  DVleNum,
  classes,
  calvars,
  calmem,
  calajuda,
  caltela,
  calfita,
  caltecla,
  calrevisao,
  calfala,
  calopera,
  sysUtils,
  math,
  CalMsg;

{--------------------------------------------------------}

procedure inicializa;
var i: integer;
    amb: string;

begin
    clrscr;
    setWindowTitle ('Calcuvox');

    amb := sintAmbiente ('CALCUVOX', 'DIRCALCUVOX');
    if (amb = '') or (not FileExists(amb+'\CA_INIC.WAV')) then
        amb := 'c:\winvox\som\calcuvox';

    sintInic (0, amb);

    numVisor   := 0;
    acumulador := 0;

    repetindoOp := false;
    
    angulosEmGraus := true;

    ultOp := ' ';
    nDecimais := 2;
    posFita := 0;
    ptransf := NIL;
    topoPilha := 0;

    for i := 0 to 9+26 do
        memoria [i] := 0.0;
    ultimasExpressoes := TStringList.Create;

    exibeCalculadora (True);
end;

{--------------------------------------------------------}

function confirmaSaida: boolean;
begin
    GotoXY(xMens, yMens);
    clreol;
    textBackground (RED);
    write (' Confirma saída (s/n)? ');
    sintSom ('CA_CNFSAI');          { ' Confirma saída (s/n)? ' }

    confirmaSaida := upcase (sintReadkey) = 'S';

    textBackground (BLACK);
    GotoXY(xMens, yMens);
    clreol;
    if not result then
        sintSom ('CA_INIC');    { ' Calculadora Vocal' }

end;

{--------------------------------------------------------}

procedure termina;
begin
    gotoxy (1, 25);
    textBackground (BLACK);
    sintSom ('CA_FIM');     { 'Calculadora desligada' }
    sintFim;
end;

{--------------------------------------------------------}

begin
{$R+}
    inicializa;

    repeat
        repeat until not entraComando;
    until confirmaSaida;

    termina;
end.

