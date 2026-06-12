{--------------------------------------------------------}
{
{    Planilha eletronica VOX
{
{    Modulo de Calculos Avancados
{
{    Autor:  Jose' Antonio Borges
{
{    Em dezembro/96
{
{--------------------------------------------------------}

unit plCalc;
interface
uses
    dvcrt, dvwin,
    plvars, plcomp, plmsg, pltela;

procedure reCalcular;

implementation

{--------------------------------------------------------}
{              realiza um recalculo da planilha
{--------------------------------------------------------}

procedure reCalcular;
var x, y: integer;
begin
    for y := 1 to MAXLINPLAN do
        begin
            if plan[y] <> NIL then
                for x := 1 to MAXCELLINHA do
                     computaFormula (x, y);
        end;

    mostraTela;
end;

end.
