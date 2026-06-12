{-------------------------------------------------------------}
{
{       Gerador de arquivo de log
{
{       Autor: Neno Henrique da Cunha Albernaz
{              neno@intervox.nce.ufrj.br
{       Em 08 de Abril de 2023
{
{-------------------------------------------------------------}

unit dvArqLog;

interface

procedure gravarArqLog (s, nomeArqLog: string);

implementation

{--------------------------------------------------------}
{ Grava arquivo de log
{--------------------------------------------------------}

procedure gravarArqLog (s, nomeArqLog: string);
var arqLog: textFile;
begin
    assignfile (arqLog, nomeArqLog);
    {$I-}     append(arqLog); {$I+}
    if ioresult <> 0 then
        rewrite (arqLog);
    writeln(arqLog, s);
    closefile(arqLog);
end;

{-------------------------------------------------------------}

begin
end.
