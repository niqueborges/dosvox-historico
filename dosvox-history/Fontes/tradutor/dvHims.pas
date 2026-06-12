{--------------------------------------------------------}
{
{    Unit: dvHims.pas
{
{    Autores: Patrick Barboza e Antonio Borges
{
{    Em 07/06/2023
{
{    Descrição: Compatibilidade do sistema DOSVOX com
{        linhas Braille da HIMS INC (Agora Selvas BLV)
{        http://selvasblv.com
{
{    Com o apoio da empresa tecnoVisão
{        http://tecnovisao.net
{
{--------------------------------------------------------}

unit dvHims;

interface
uses Windows, messages, sysutils, dvcrt, dvWin, dvBrUnif;

{---------------------------------------------------------}

var
    hinstDll_HIMS: THandle;

    open_HIMS: function (var port: byte;
                         windowsToUse: HWND;
                         windowsMessageToUse: integer): integer cdecl;
    cellCount_HIMS : function : integer cdecl;
    write_HIMS : function (chars: pbyte): boolean cdecl;
    getKeyData_HIMS : function (
           wParam: pword; lParam: plongInt): boolean cdecl;
    close_HIMS : function : boolean cdecl;

{---------------------------------------------------------}

var
    cellsTotal: integer = 0;

function loadHIMS: boolean;
procedure unloadHIMS;
function loadedHIMS: boolean;
function openHIMS: integer;
function HIMSnumCells: integer;
procedure writeHIMS (xCur, yCur: integer; text: string);
function getKeyDataHIMS (
           wParam: pword; lParam: plongInt): boolean;
procedure closeHIMS;

{---------------------------------------------------------}

implementation

function getDLLPath: string;
var s: string;
begin
    if fileExists ('.\HanSoneConnect.dll') then
        s := '.'
    else
        begin
            s := sintAmbiente('DOSVOX', 'PGMDOSVOX');
            if s = '' then s := '\winvox';
        end;

    if not fileExists ('.\HanSoneConnect.dll') then
        s := '\windows\system32';
    result := s;
end;

function DLLExists: boolean;
begin
    result := fileExists(getDLLPath+'\HanSoneConnect.dll');
end;

function loadHIMS: boolean;
begin
    if not DLLExists then
        begin
        loadHIMS := false;
        exit;
    end;
    hinstDll_HIMS := LoadLibrary(pchar (getDllPath+'\HanSoneConnect.dll'));
    if hinstDll_HIMS = 0 then
        begin
            loadHIMS := false;
            exit;
        end;

    @open_HIMS := GetProcAddress (hinstDll_HIMS,'Open');
    @cellCount_HIMS := GetProcAddress (hinstDll_HIMS,'GetBSCellCount');
    @write_HIMS := GetProcAddress (hinstDll_HIMS,'SendData');
    @close_HIMS := GetProcAddress (hinstDll_HIMS,'Close');
    @getKeyData_HIMS := GetProcAddress (hinstDll_HIMS,'GetKeyData');

    if (@open_HIMS = NIL) or
       (@cellCount_HIMS = NIL) or
       (@write_HIMS = NIL) or
       (@close_HIMS = NIL) or
       (@getKeyData_HIMS = NIL) then
        begin
            FreeLibrary (hinstDll_HIMS);
            hinstDll_HIMS := 0;
            loadHIMS := false;
            exit;
        end;

    loadHIMS := true;
end;

procedure unloadHIMS;
begin
    if hinstDll_HIMS <> 0 then
        begin
            FreeLibrary (hinstDll_HIMS);
            hinstDll_HIMS := 0;
    end;
end;

function loadedHIMS: boolean;
begin
    loadedHIMS := hinstDll_HIMS <> 0;
end;

function openHIMS: integer;
var
    port: byte;
    r: integer;
begin
    port := 0;
    r := open_HIMS (port, CRTWINDOW, 0);
    if r <> 0 then HIMSNumCells;
    result := r;
end;

function HIMSnumCells: integer;
begin
    if cellsTotal = 0 then
        cellsTotal := cellCount_HIMS;
    result := cellsTotal;
end;

procedure writeHIMS (xCur, yCur: integer; text: string);
{   Código retirado da unit dvFocus80.pas   }
{   Autores: Antonio Borges e Julio Silveira   }
{   Modificado para adicionar o cursor   }
var i: integer;
    brl: packed array [0..40] of byte;
begin
    if not loadedHIMS then exit;
    text := brailleUnificado(text);
    for i := 1 to length(text) do
        if text[i] > #$ff then
            text[i] := ' ';

    while length(text) <= cellsTotal do
        text := text + ' ';
    delete (text, 41, 9999);

    for i := 1 to length(text) do
        brl[i-1] := AmbCodeParaBin[chr(MetaBrailleParaAMBCode[text[i]])];

    // Adiciona o cursor
    if (xCur > 0) and (yCur > 0) then
        brl[xCur-1] := brl[xCur-1] or $C0;

    write_HIMS(@brl);
end;

function getKeyDataHIMS (
           wParam: pword; lParam: plongInt): boolean;
begin
    repeat
        result := getKeyData_HIMS(wParam, lParam);
        delay (1000);
    until false;
end;

procedure closeHIMS;
begin
    if loadedHims then
        begin
        writeHims (0,0,'');   // Limpa o display antes de sair
        close_HIMS;
    unloadHIMS;
    end;
end;

end.
