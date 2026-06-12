{--------------------------------------------------------}

{
{    Tratamento desfazer/refazer alterações  realizadas no texto
{
{    Autor: Neno Henrique da Cunha Albernaz
{
{    Em 06/06/2020
{
{--------------------------------------------------------}

Unit edDesfaz;

interface

uses
    DVWin, sysUtils, classes,
    edLinha, edVars, edMensag;

procedure inicializaDesfazer;
procedure gravarDesfazer;
procedure recuperarRefazer;
procedure recuperarDesfazer;
procedure descarregarEdDesfaz;

implementation

const
    maxDesfaz = 20;

type
    PDesfaz = ^TDesfaz;

    TDesfaz = record
        linhasArq: TStringList;
        salvaIniBloco: integer;
        salvaFimBloco: integer;
        salvaPosy: integer;
        salvaPosx: integer;
    end;

var
    linhasDesfazer: array [1..maxDesfaz] of PDesfaz;
    linhasRefazer: array [1..maxDesfaz] of PDesfaz;

{--------------------------------------------------------}

procedure inicializaDesfazer;
var
    i: integer;

    function inicDesfazer: PDesfaz;
    var desfazer : PDesfaz;
    begin
        new (desfazer);
        result := desfazer;
    end;

begin
    for i := 1 to maxDesfaz do
        begin
            linhasDesfazer[i] := inicDesfazer;
            linhasDesfazer[i]^.linhasArq := nil;
            linhasRefazer[i] := inicDesfazer;
            linhasRefazer[i]^.linhasArq := nil;
        end;
end;

{--------------------------------------------------------}

procedure descarregarEdDesfaz;
var i: integer;
begin
    for i := maxDesfaz downto 1 do
        begin
            if linhasDesfazer[i] <> nil then
                begin
                    if linhasDesfazer[i]^.linhasArq <> nil then linhasDesfazer[i]^.linhasArq.Free;
                    dispose (linhasDesfazer[i]);
                end;
            if linhasRefazer[i] <> nil then
                begin
                    if linhasRefazer[i]^.linhasArq <> nil then linhasRefazer[i]^.linhasArq.Free;
                    dispose (linhasRefazer[i]);
                end;
        end;
end;

{--------------------------------------------------------}

procedure limparListaRefazer;
var i: integer;
begin
    for i := maxDesfaz downto 1 do
        if linhasRefazer[i] <> nil then
            if linhasRefazer[i]^.linhasArq <> nil then
                linhasRefazer[i]^.linhasArq.Clear;
end;

{--------------------------------------------------------}

Procedure recuperarMarcasRefazer;
begin
    iniBloco := linhasRefazer[1]^.salvaIniBloco;
    fimBloco := linhasRefazer[1]^.salvaFimBloco;
    posy := linhasRefazer[1]^.salvaPosy;
    posx := linhasRefazer[1]^.salvaPosx;
end;

{--------------------------------------------------------}

procedure liberarPrimeiroDaListaRefazer; //Primeiro fica nil ou clear
var
    i: integer;
    aux: PDesfaz;
begin
    if (linhasRefazer[1]^.linhasArq = nil) or (linhasRefazer[1]^.linhasArq.Count = 0) then exit;
    aux := linhasRefazer[maxDesfaz];
    for i := (maxDesfaz - 1) downto 1 do
        linhasRefazer[i + 1] := linhasRefazer[i];
    linhasRefazer[1] := aux;
    if linhasRefazer[1]^.linhasArq <> nil then linhasRefazer[1]^.linhasArq.Clear;
end;

{--------------------------------------------------------}

procedure carregarRefazer;
var
    y: integer;
begin
    liberarPrimeiroDaListaRefazer;
    if linhasRefazer[1]^.linhasArq <> nil then linhasRefazer[1]^.linhasArq.Clear
    else linhasRefazer[1]^.linhasArq := TStringList.create;
    for y := 1 to maxLinhas do
        linhasRefazer[1]^.linhasArq.Add (texto[y]);
    linhasRefazer[1]^.salvaIniBloco := iniBloco;
    linhasRefazer[1]^.salvaFimBloco := fimBloco;
    linhasRefazer[1]^.salvaPosy := posy;
    linhasRefazer[1]^.salvaPosx := posx;
end;

{--------------------------------------------------------}

procedure liberarPrimeiroDaListaDesfazer; //Primeiro fica nil ou clear
var
    i: integer;
    aux: PDesfaz;
begin
    if (linhasDesfazer[1]^.linhasArq = nil) or (linhasDesfazer[1]^.linhasArq.Count = 0) then exit;
    aux := linhasDesfazer[maxDesfaz];
    for i := (maxDesfaz - 1) downto 1 do
        linhasDesfazer[i + 1] := linhasDesfazer[i];
    linhasDesfazer[1] := aux;
    if linhasDesfazer[1]^.linhasArq <> nil then linhasDesfazer[1]^.linhasArq.Clear;
end;

{--------------------------------------------------------}

procedure carregarDesfazer;
var
    y: integer;
begin
    liberarPrimeiroDaListaDesfazer;
    if linhasDesfazer[1]^.linhasArq <> nil then linhasDesfazer[1]^.linhasArq.Clear
    else linhasDesfazer[1]^.linhasArq := TStringList.create;
    for y := 1 to maxLinhas do
        linhasDesfazer[1]^.linhasArq.Add (texto[y]);
    linhasDesfazer[1]^.salvaIniBloco := iniBloco;
    linhasDesfazer[1]^.salvaFimBloco := fimBloco;
    linhasDesfazer[1]^.salvaPosy := posy;
    linhasDesfazer[1]^.salvaPosx := posx;
end;

{--------------------------------------------------------}

procedure atualizarLinhasRefazer; // Apaga primeiro e joga os outros um indice para cima.
var i: integer;
    aux: PDesfaz;
begin
    if  (linhasRefazer[1]^.linhasArq = nil) or (linhasRefazer[1]^.linhasArq.Count = 0) then exit;
    aux := linhasRefazer[1];
    for i := 1 to (maxDesfaz -1) do
        linhasRefazer[i] := linhasRefazer[i + 1];
    linhasRefazer[maxDesfaz] := aux;
    if linhasRefazer[maxDesfaz]^.linhasArq<> nil then linhasRefazer[maxDesfaz]^.linhasArq.Clear;
end;

{--------------------------------------------------------}

procedure recuperarRefazer;
var
    y: integer;
begin
    if (linhasRefazer[1]^.linhasArq = nil) or (linhasRefazer[1]^.linhasArq.Count = 0) then
        begin
            sintBip;
            exit;
        end;

    carregarDesfazer;
     texto.clear;
    texto.append('');
    texto.append('');
    texto[1]  := '';
    maxLinhas := 0;
    posy := 1;
    for y := 0 to (linhasRefazer[1]^.linhasArq.Count -1) do
        begin
            insereLinha (linhasRefazer[1]^.linhasArq[y], false);
            inc(posy);
        end;
    recuperarMarcasRefazer;
    atualizarLinhasRefazer;
    fala('EDREFEIT'); {'Refeito'}
end;

{--------------------------------------------------------}

procedure gravarDesfazer;
begin
    limparListaRefazer;
    carregarDesfazer;
end;

{--------------------------------------------------------}

procedure atualizarLinhasDesfazer; // Apaga primeiro e joga os outros um indice para cima.
var i: integer;
    aux: PDesfaz;
begin
    if  (linhasDesfazer[1]^.linhasArq = nil) or (linhasDesfazer[1]^.linhasArq.Count = 0) then exit;
    aux := linhasDesfazer[1];
    for i := 1 to (maxDesfaz -1) do
        linhasDesfazer[i] := linhasDesfazer[i + 1];
    linhasDesfazer[maxDesfaz] := aux;
    if linhasDesfazer[maxDesfaz]^.linhasArq<> nil then linhasDesfazer[maxDesfaz]^.linhasArq.Clear;
end;

{--------------------------------------------------------}

Procedure recuperarMarcasDesfazer;
begin
    iniBloco := linhasDesfazer[1]^.salvaIniBloco;
    fimBloco := linhasDesfazer[1]^.salvaFimBloco;
    posy := linhasDesfazer[1]^.salvaPosy;
    posx := linhasDesfazer[1]^.salvaPosx;
end;

{--------------------------------------------------------}

procedure recuperarDesfazer;
var
    y: integer;
begin
    if (linhasDesfazer[1]^.linhasArq = nil) or (linhasDesfazer[1]^.linhasArq.Count = 0) then
        begin
            sintBip;
            exit;
        end;

    carregarRefazer;
    texto.clear;
    texto.append('');
    texto.append('');
    texto[1]  := '';
    maxLinhas := 0;
    posy := 1;
    for y := 0 to (linhasDesfazer[1]^.linhasArq.Count -1) do
        begin
            insereLinha (linhasDesfazer[1]^.linhasArq[y], false);
            inc(posy);
        end;

    recuperarMarcasDesfazer;
    atualizarLinhasDesfazer;
    fala('EDDESFEI'); {'desfeito'}
end;

{--------------------------------------------------------}

begin
end.
