{--------------------------------------------------------}
{
{    Rotinas utilitárias
{
{    Autor: Neno Henrique da Cunha Albernaz
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 25/07/2020
{
{--------------------------------------------------------}

Unit edUtil;

interface

uses
    DVcrt, DVWin, sysutils, windows,
    edvars, edMensag;

function blocoInvalido: Boolean;
function blocoTodoTexto: Boolean;
function lTrim (s: string): string;
function GetTempFile_htm: String;
function resolverNovoNomeArq (nomeArq: string): string;
function tudoNumeral (s: string): boolean;

implementation

{--------------------------------------------------------}

function blocoInvalido: Boolean;
begin
    if ((iniBloco <= 0) or (fimbloco < iniBloco)) and (upcase(sintAmbiente('EDIVOX', 'SELECIONARTODOTEXTOQUANDOBLOCOINVALIDO', 'NAO')[1]) = 'S') then
        begin
            iniBloco := 1;
            fimbloco := maxLinhas;
        end;

    result := (iniBloco <= 0) or (fimbloco < iniBloco);
end;

{--------------------------------------------------------}

function blocoTodoTexto: Boolean;
begin
    result := (iniBloco = 1) and (fimbloco = maxLinhas);
end;

{--------------------------------------------------------}

function lTrim (s: string): string;
begin
    while (s <> '') and (s[1] = ' ') do delete (s, 1, 1);
    result := s;
end;

{--------------------------------------------------------}

function GetTempFile_htm: String;
var
    tempFileName, tempPath: array[0..255] of Char;
begin
    getTempPath (255, tempPath);
    getTempFileName(tempPath, 'htm', 0, tempFileName);

    result := strPas (tempFileName) + strPas('.htm');
end;

{-------------------------------------------------------------}
{       Retorna um nome de arquivo que não existe acrescentando um número inteiro ao fim do nome recebido
{-------------------------------------------------------------}

function resolverNovoNomeArq (nomeArq: string): string;
var
    ext, nomeArqTesta: string;
    i: integer;
begin
    ext := extractFileExt(nomeArq);
    nomeArqTesta := copy (nomeArq, 1, length(nomeArq) - length(ext));
    i := 1;
    while fileExists (nomeArqTesta + intToStr (i) + ext) do
        i := i + 1;

    result := nomeArqTesta + intToStr (i) + ext;
end;

{--------------------------------------------------------}
{       Retorna true se todos os caracteres forem números
{-------------------------------------------------------------}

function tudoNumeral (s: string): boolean;
var l: integer;
begin
    for l := 1 to length(s) do
        if not (s[l] in ['0' .. '9']) then
            begin
                result := false;
                exit;
            end;

    result := true;
end;

{--------------------------------------------------------}

begin
end.
