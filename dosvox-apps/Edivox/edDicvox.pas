{--------------------------------------------------------}

{
{    Tratamento Dicvox, usa as bases de dados criadas pelo Glauco Férius
{
{    Autor: Neno Henrique da Cunha Albernaz
{
{    Em 27/06/2020
{
{--------------------------------------------------------}

Unit edDicvox;

interface

uses
    DVWin, dvCrt, windows, sysUtils, classes,
    dvexec, dvForm,
    edDicion, edVars, edUtil, edMensag;

procedure trataDicvox;

implementation

{--------------------------------------------------------}

procedure abrirDicvox (progDicvox, palavraBuscar, dicEscolhido: string);
begin
    if executaProg ('"' + progDicvox + '" /' + dicEscolhido, '', palavraBuscar) >= 32 then
        esperaProgVoltar;
    while sintFalando do waitMessage;
    limpaBufTec;
    fala ('EDOK'); {'OK'}
end;

{--------------------------------------------------------}

function menuTraduzir: string;
const
    tabTraduz: string =      // Códigos dos dicionários no Dicvox:
                                   'I' + // Inglês - Português - Inglês
                                   '1' + //Português - Inglês - Português
                                   'D' + // Espanhol - Português - Espanhol
                                   '4' + // Português - Espanhol - Português
                                   'T' + // Italiano - Português - Italiano
                                   '7' + // Português - Italiano - Português
                                   'F' + // Francês - Português - Francês
                                   'V' + // Alemão - Português
                                   'X' + // Esperanto - Português
                                   '5' + // Latim - Inglês - Latim
                                   '6' + // Inglês - Latim - Inglês
                                   'S';  // Inglês - Espanhol'

var
    nSel, i, numTraduz: integer;
begin
    sintclek;
    numTraduz := length(tabTraduz);
    popupMenuCria(40, 9, 30, numTraduz, RED);
        for i := 1 to numTraduz do
            popupMenuAdiciona ('EDAJDT' + intToStr(i), txtmsg ('EDAJDT' + intToStr(i)));
    nSel := popupMenuSeleciona;

    if (nSel > 0) and (nSel <= numTraduz) then
        result := tabTraduz[nSel]
    else
        result := '';
end;

{--------------------------------------------------------}

function menuOutros: string;
const
    tabOutros: string =      // Códigos dos dicionários no Dicvox:
                                   'M' + // Significado e origem dos nomes
                                   'R' + // Origem da Palavra
                                   '0' + // Origem da Palavra 2
                                   '8' + // Etimológico - Origem das Palavras
                                   'A' + // Jurídico de Latim
                                   'B' + // Bíblia de Almeida
                                   'K' + // Eletrônica em espanhol
                                   '2' + // Grego em português com Concordância em grego nas informações
                                   'G' + // Grego com Concordância em grego nas informações
                                   '3' + // Hebraico em português com Concordância em hebraico nas informações
                                   'H' + // Hebraico com Concordância em hebraico nas informações
                                   '9';  // Bíblico da Torre de Vigia

var
    nSel, i, numOutros: integer;
begin
    sintclek;
    numOutros := length(tabOutros);
    popupMenuCria(40, 9, 30, numOutros, RED);
        for i := 1 to numOutros do
            popupMenuAdiciona ('EDAJDO' + intToStr(i), txtmsg ('EDAJDO' + intToStr(i)));
    nSel := popupMenuSeleciona;

    if (nSel > 0) and (nSel <= numOutros) then
        result := tabOutros[nSel]
    else
        result := '';
end;

{--------------------------------------------------------}

procedure trataDicvox;
const
    tabPrincipal: string =      // Códigos dos dicionários no Dicvox:
                                   'P' + // Português
                                   'Y' + // Vocabulário Ortográfico da Língua Portuguesa (VOLP)
                                   'W' + // Webster
                                   'O' + // Oxford
                                   'E' + // Espanhol - Espanhol
                                   'N' + // Informática
                                   'J' + // Jurídico Brasileiro
                                   'U' + // Psicologia
                                   'L' + // Filosofia
                                   'C' + // Sociologia
                                   'Z' + // Química
                                   'Q';  // Significados

var
    s, dicSel, palavra, progDicvox: string;
    i, x, nSel, numPrin: integer;
begin
    progDicvox := sintAmbiente ('EDIVOX', 'PROGDICVOX', 'C:\Dicvox\DicvoxExtra.exe');
    if not FileExists(progDicvox) then
        begin
            fala ('EDPRONEN'); {'Programa não encontrado'}
            sintetiza (progDicvox);
            exit;
        end;

     if (posy <= 0) then exit;
     s := texto[posy];
    x := posx;
    while (x > 1) and (s[x-1] = ' ') do
        x := x - 1;
    while (x <= length(s)) and (s[x] in LETRAS_DE_PALAVRA) do
        x := x + 1;
     palavra := descobrePalavraAntes (x);
    if palavra = '' then
        begin
            sintBip;
            exit;
        end;

    fala ('EDDICION');    {'Dicionários - use as setas para selecionar.'}
    sintclek;
    numPrin := length(tabPrincipal);
    popupMenuCria(40, 9, 30, (numPrin + 2), RED);
        for i := 1 to numPrin do
            popupMenuAdiciona ('EDAJDP' + intToStr(i), txtmsg ('EDAJDP' + intToStr(i)));
        popupMenuAdiciona ('', 'Tradução');
        popupMenuAdiciona ('', 'Outros');
    nSel := popupMenuSeleciona;

    if (nSel > 0) and (nSel <= numPrin) then
        dicSel := tabPrincipal[nSel]
    else
    if nSel = (numPrin + 1) then
        dicSel := menuTraduzir
    else
    if nSel = (numPrin + 2) then
        dicSel := menuOutros
    else
        dicSel := '';

    if dicSel = '' then
        fala ('EDDESIST')    {'Desistiu'}
    else
        abrirDicvox (progDicvox, palavra, dicSel);
end;

{--------------------------------------------------------}

begin
end.
