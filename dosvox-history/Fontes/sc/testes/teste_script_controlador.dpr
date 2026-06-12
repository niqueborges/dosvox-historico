{------------------------------------------------------------------------------}
{
{                                  TESTE.PAS
{
{    Testa Script Controlador
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Autor:      Oswaldo Vernet
{    Data:       21/08/2015
{    Alterações:
{
{------------------------------------------------------------------------------}

program teste_script_controlador;

uses
   classes, dvscript, dvwin;

function funcaoRemota (str : string) : string;
var
    frase : string;
begin
    write (str + ' ');
    readln (frase);
    funcaoRemota := str + ' ' + frase
end;

function geraScript : TSTringList;
var
    script : TStringList;
begin
    script := TStringList.create;

    script.Add ('chama remoto "Quem bate?" s');
    script.Add ('escreve s');
    script.Add ('escreve $x, $y');
    script.Add ('z  := $x');
    script.Add ('$x := $y');
    script.Add ('$y := z');
    script.Add ('$l := [ 1, 2, 3, 4, 5, 6 ]');
    script.Add ('escreve $x, $y, z, $l');

    geraScript := script
end;

procedure testa_scriptvox;
var
    ultlinha : integer;
    linha    : String;
begin
    sintinic (0,'');

    executaLinha ('$x:=35');
    executaLinha ('$y:=42');

    executaScriptControladorList (geraScript, @funcaoRemota, ultlinha, linha);

    writeln ('De volta ao programa principal');

    writeln ('x+3 = ',  calculaExpressao ('$x+3'));
    writeln ('y+4 = ',  calculaExpressao ('$y+4'));
    writeln ('l[1] = ', calculaExpressao ('$l[1]'));

    readln
end;

begin
    testa_scriptvox
end.


