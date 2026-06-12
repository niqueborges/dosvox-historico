{--------------------------------------------------------}
{
{    NIMVOX - Jogo dos Palitinhos
{
{    Variáveis globais
{
{    Por Patrick Barboza
{
{    Em agosto/2021
{
{--------------------------------------------------------}

unit nimVars;

interface

const
   COMPUTADOR = 1;
   MAXLINHAS = 20;

var
   totlinhas: integer;
   linha, ordem : array [1..MAXLINHAS] of byte;
   vez, pauzinhos, lin, quantos : byte;
   partidas, vitorias, derrotas : integer;
   st : char;

implementation

end.
