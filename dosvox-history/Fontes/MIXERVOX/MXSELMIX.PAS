{--------------------------------------------------------}
{
{    Interface sonora para o mixer de áudio do Windows
{
{    Módulo de seleção dos mixers
{
{    Por José Antonio Borges
{
{    Em 27/06/2002
{
{---------------------------------------------------------------------}

unit mxselmix;

interface

uses windows, dvcrt, mmsystem, sysUtils, dvWin, dvForm,
     mxVars, mxMsg;

procedure fechaMixer;
function selMixer: boolean;

implementation

{---------------------------------------------------------------------}

procedure fechaMixer;
begin
    if hmx <> 0 then
        begin
            mixerClose (hmx);
            hmx := 0;
        end;
end;

{---------------------------------------------------------------------}

function selMixer: boolean;
var i: integer;
begin
    fechaMixer;

    selMixer := false;
    ndev := mixerGetNumDevs;
    qualMixer := 0;
    hmx := 0;

    if ndev < 1 then
        begin
            mensagem ('MXSEMMIX', 1);    {'Essa máquina não tem mixers'}
            readkey;
            exit;
        end
    else
    if ndev > 1 then
        begin
            mensagem ('MXSELMIX', 1); {'Escolha com as setas o mixer a regular'}
            popupMenuCria (wherex, wherey, 50, ndev, RED);
            for i := 0 to ndev-1 do
                begin
                    mixerGetDevCaps(i, @mxcaps, sizeof (mxCaps));
                    popupMenuAdiciona('', mxcaps.szPname);
                end;

            qualMixer := popupMenuSeleciona - 1;
            if qualMixer < 0 then
                begin
                    mensagem ('MXDESIST', 1);  {'Desistiu...'}
                    exit;
                end
            else
        end;

    mixerGetDevCaps(qualMixer, @mxcaps, sizeof (mxCaps));

    limpaBaixo (3);
    mensagem ('MXNOMMIX', 0);   {'Nome do mixer: '}
    sintWriteln (mxcaps.szPname);

    if mixerOpen (@hmx, qualMixer, 0, 0, 0) <> MMSYSERR_NOERROR then
        begin
            mensagem ('MXNAOABR', 1);   {'Não consegui abrir este mixer'}
            exit;
        end;

    writeln;
    selMixer := true;
end;

end.
