{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Rotinas utilitárias
{
{    Autor: Patrick Barboza
{
{    Em Dezembro/2024
{
{--------------------------------------------------------}

unit joUtil;

interface

uses dvCrt, dvWin;

function obtemDirDosvox: String;

implementation

{--------------------------------------------------------}
{                  Obtém o diretório do Dosvox
{--------------------------------------------------------}

function obtemDirDosvox: String;
var
    dir: String;
begin
    dir := SintAmbiente('DOSVOX', 'PGMDOSVOX');
    if (dir = '') or (dir = '@') then
        dir := 'C:\Winvox';

    result := dir;
end;

end.
