{--------------------------------------------------------}
{
{    Interface sonora para o mixer de áudio do Windows
{
{    Módulo de seleção de linhas
{
{    Por José Antonio Borges
{
{    Em 27/06/2002
{
{---------------------------------------------------------------------}

unit mxline;

interface

uses windows, dvcrt, dvWin, dvForm, mmsystem, sysUtils, mxVars, mxMsg;

function selFuncaoMixer: integer;
function selDispositivoMixer (qualFuncao: integer): integer;

implementation

{---------------------------------------------------------------------}

function selFuncaoMixer: integer;
var i, sel: integer;
begin
    selFuncaoMixer := -1;
    limpaBaixo (5);
    mensagem ('MXESCDST', 1);   {'Escolha a propriedade a controlar'}

    popupMenuCria(wherex, wherey, 50, mxcaps.cDestinations, RED);
    mxl.cbStruct := sizeof(mxl);
    for i := 0 to mxcaps.cDestinations-1 do
        begin
            mxl.dwDestination := i;
            if mixerGetLineInfo(hmx, @mxl, MIXER_GETLINEINFOF_DESTINATION) <> MMSYSERR_NOERROR then
                popupMenuAdiciona ('', 'Linha inacessível')
            else
                popupMenuAdiciona ('', mxl.szName);
        end;

    sel := popupMenuSeleciona - 1;
    if sel < 0 then
        begin
            mensagem ('MXDESIST', 1);  {'Desistiu...'}
            exit;
        end
    else
        begin
            mxl.dwDestination := sel;
            mixerGetLineInfo(hmx, @mxl, MIXER_GETLINEINFOF_DESTINATION);
            gotoxy (1, 5); clreol;
            textBackground (RED);
            writeln (mxl.szName);
            textBackground (BLACK);
        end;

    selFuncaoMixer := sel;
end;

{---------------------------------------------------------------------}

function selDispositivoMixer (qualFuncao: integer): integer;
var i: integer;
    sel: integer;
begin
    selDispositivoMixer := -1;

    limpaBaixo (7);
    mensagem ('MXESCDIS', 1);   {'Escolha o dispositivo'}

    mxl.cbStruct := sizeof(mxl);
    mxl.dwDestination := qualFuncao;
    if mixerGetLineInfo(hmx, @mxl, MIXER_GETLINEINFOF_DESTINATION) <> MMSYSERR_NOERROR then
        begin
            mensagem ('MXNEXDIS', 1);  {'Não existe este dispositivo'}
            exit;
        end;

    ncon := mxl.cConnections;
    garanteEspacoTela(ncon+1);

    popupMenuCria(wherex, wherey, 50, ncon+1, MAGENTA);
    popupMenuAdiciona ('', mxl.szName);
    for i := 0 to ncon-1 do
        begin
            mxl.dwSource := i;
            mixerGetLineInfo(hmx, @mxl, MIXER_GETLINEINFOF_SOURCE);
            popupMenuAdiciona ('', mxl.szName);
        end;

    sel := popupMenuSeleciona - 1;
    if sel < 0 then exit;

    if sel = 0 then
        mixerGetLineInfo(hmx, @mxl, MIXER_GETLINEINFOF_DESTINATION)
    else
        begin
           mxl.dwSource := sel-1;
           mixerGetLineInfo(hmx, @mxl, MIXER_GETLINEINFOF_SOURCE);
        end;

    gotoxy (1, 7); clreol;
    textBackground (BLUE);
    writeln (mxl.szName);
    textBackground (BLACK);

    selDispositivoMixer := sel;
end;

end.

