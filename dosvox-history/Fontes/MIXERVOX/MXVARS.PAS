{--------------------------------------------------------}
{
{    Interface sonora para o mixer de áudio do Windows
{
{    Módulo de variáveis
{
{    Por José Antonio Borges
{
{    Em 27/06/2002
{
{---------------------------------------------------------------------}

unit mxvars;

interface

uses mmsystem;

// a opção de compilação abaixo é super-importante, os dados tem que ser packed
{$A-}

const
    versao = '3.0';

var
    mxCaps: MixerCaps;
    hmx: hMixer;
    mxl: MIXERLINE;
    mxlc: MIXERLINECONTROLS;
    mxctrl_list: array [0..30] of MIXERCONTROL;
    ctlSelec: integer;
    mxcd: TMIXERCONTROLDETAILS;
    mxdet_list: array [0..20] of MIXERCONTROLDETAILS_LISTTEXT;
    mxcd_f: array [0..20] of MIXERCONTROLDETAILS_BOOLEAN;
    mxval: array [0..5] of integer;

    ndev, qualMixer, qualFuncao, qualDispositivo: integer;
    ndest, ncon: integer;

implementation

end.
