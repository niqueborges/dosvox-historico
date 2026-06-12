{------------------------------------------------------------------------------}
{
{                               SCRIPT_DUPLO.PAS
{
{    Testa 2 Execuções de um mesmo Script
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Autor:      Oswaldo Vernet
{    Data:       29/06/2016
{    Alterações:
{
{------------------------------------------------------------------------------}

program script_duplo;

uses
   classes, dvscript, dvwin;

procedure testa_scriptvox;
var
    ultlinha : integer;
    linha    : String;
begin
    sintinic (0,'');

    executaLinha ('$i:=2');
    executaLinha ('$j:=42');

    writeln ('Vou executar o script (1a vez)');

    executaScript ('script.pro', '', ultlinha, linha);

    writeln ('De volta ao programa principal');

    writeln ('$i = ',  calculaExpressao ('$i'));
    writeln ('$j = ',  calculaExpressao ('$j'));

    writeln ('Vou executar o script (2a vez)');

    executaScript ('script.pro', '', ultlinha, linha);

    writeln ('De volta ao programa principal');

    writeln ('$i = ',  calculaExpressao ('$i'));
    writeln ('$j = ',  calculaExpressao ('$j'));

    readln
end;

begin
    testa_scriptvox
end.


