{-------------------------------------------------------------}
{
{    Telnet Falado
{
{    Interpretação dos códigos do TI200
{
{    Autor: Jose' Antonio Borges
{
{    Em 24/04/98
{
{-------------------------------------------------------------}

unit tnti200;
interface
    uses dvwin, dvcrt, tnRede, tnAnsi;

procedure ti200write (c: char);

implementation

procedure ti200write (c: char);
var ll, cc: char;
begin
    if c = #$1f then      { enderecamento usado no TI200 }
        begin
            lelink (ll);
            lelink (cc);
            gotoxy (ord (cc) - 31, ord (ll) - 31);
        end
    else
        ansiWrite (c);
end;

end.
