{--------------------------------------------------------}
{
{    Interface sonora para o mixer de áudio do Windows
{
{    Por José Antonio Borges
{
{    Em 27/06/2002
{
{---------------------------------------------------------------------}

program mixerVox;
uses
  dvcrt,
  dvwin,
  dvForm,
  windows,
  sysUtils,
  mmsystem,
  mxvars,
  mxmsg,
  mxselmix,
  mxline,
  mxajust;

{--------------------------------------------------------}

procedure finaliza;
begin
    mensagem ('MXFIM', 1);    {'Controle do mixer terminado'}
    sintFim;
    delay (1000);
    doneWinCrt;
end;

{---------------------------------------------------------------------}

procedure inicializa;
var
    dir: string;
begin
    clrscr;

    dir := sintAmbiente ('MIXERVOX2', 'DIRMIXERVOX');
    if dir = '' then
        dir := 'c:\winvox\som\mixervox';
    sintInic (0, dir);

    mensagem ('MXINIC', 0);   {'Mixer Vox - v '}
    write (' - v ');
    sintWriteln (versao);
    writeln;
    while sintFalando do;
    while keypressed do readkey;
end;

{---------------------------------------------------------------------}

label fim;

begin
    inicializa;

    if not selMixer then goto fim;

    qualFuncao := 0;
    repeat
        qualFuncao := selFuncaoMixer;
        if qualFuncao >= 0 then
            begin
                repeat
                    qualDispositivo := selDispositivoMixer (qualFuncao);
                    if qualDispositivo >= 0 then
                        ajustaDispositivoMixer;
                until qualDispositivo < 0;
            end;

        delay (500);
    until qualFuncao < 0;

fim:
    fechaMixer;
    finaliza;
end.
