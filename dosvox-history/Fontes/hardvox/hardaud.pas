{-------------------------------------------------------------}
{
{    Informações sobre os dispositivos multimidia
{
{    Autor: Jose' Antonio Borges
{
{    Em 09/04/2008
{
{-------------------------------------------------------------}

unit hardaud;

interface

uses
  dvCrt,
  dvExec,
  dvWin,
  dvForm,
  windows,
  sysutils,
  hardmsg,
  mmsystem;

procedure infoAudio;

implementation

{-------------------------------------------------------------}
{                  informações sobre áudio
{-------------------------------------------------------------}

procedure infoAudio;
var i, ndev: integer;
    audioCap: WAVEOUTCAPS;
    midiCap: MIDIOUTCAPS;
begin
    writeln;
    ndev := WaveOutGetNumDevs;
    if ndev < 1 then
        begin
            mensagem ('HVSEMWAV', 2);    {'Essa máquina não tem dispositivos de áudio'}
        end
    else
        begin
            mensagem ('HVSETWAV', 2);    {'Áudio - Use as setas para folhear'}

            garanteEspacoTela (ndev);
            opcoesCria (wherex, wherey, 40);
            for i := 0 to ndev-1 do
                begin
                    WaveOutGetDevCaps(i, @audioCap, sizeof (audioCap));
                    opcoesAdiciona('', audioCap.szPname);
                end;
            TextBackground(Magenta);
            opcoesSeleciona;
            TextBackground(Black);
        end;

    writeln;
//    writeln;
//    gotoxy (1, wherey + 2);

    ndev := MidiOutGetNumDevs;
    if ndev < 1 then
        begin
            mensagem ('HVSEMMID', 2);    {'Essa máquina não tem dispositivos de midi'}
        end
    else
        begin
            mensagem ('HVSETMID', 2);    {'Midi  - Use as setas para folhear'}

            garanteEspacoTela (ndev);
            opcoesCria (wherex, wherey, 40);
            for i := 0 to ndev-1 do
                begin
                    MidiOutGetDevCaps(i, @midiCap, sizeof (midiCap));
                    opcoesAdiciona('', midiCap.szPname);
                end;
            TextBackground(Magenta);
            opcoesSeleciona;
            TextBackground(Black);
        end;

    gotoxy (1, wherey + ndev);
end;

end.
