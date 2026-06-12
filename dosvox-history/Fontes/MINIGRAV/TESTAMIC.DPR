{--------------------------------------------------------}
{
{     Programa auxiliar para calibragem do microfone
{     Autor: José Antonio Borges
{     Em 31/05/2003
{
{--------------------------------------------------------}

program testaMic;

uses
    dvcrt, dvwin, mmsystem, windows, messages, uaudio;

const
    bufsize = 1024;
    samplesPerSecond = 11025;

var
    buf: array [0..BUFSIZE-1] of byte;
    nread: integer;

function calculateVolume: integer;
var i, max: integer;
    sample: byte;
begin
    max := 0;
    for i := 0 to nread-1 do
        begin
            sample := abs (buf[i]-128);
            if max < sample then max := sample;
        end;
    result := max;
end;

procedure showVolume (v: integer);
var i: integer;
    s: string[64];
begin
    setLength (s, 64);
    for i := 1 to v div 2 do
        s[i] := '@';
    for i := v div 2 + 1 to 64 do
        s[i] := '.';
    write (s, #$0d);
end;

function calculateMaxVolume (maxTime: integer): integer;
var status, v, t, max: integer;
begin
    status := initWaveRecording (samplesPerSecond, 8, 1, sizeof (buf));
    if status <> 0 then
        begin
            writeln ('Problemas, código ');
            sintWriteint (status);
            writeln;
            readln;
            doneWinCrt;
        end;

    showVolume (0);
    max := 0;
    for t := 1 to round (maxTime * samplesPerSecond / bufsize) do
        begin
            nread := getWaveBuffer (@buf);
            v := calculateVolume;
            showVolume (v);
            if max < v then max := v;
        end;

    terminateWaveRecording;
    result := max;
end;

{--------------------------------------------------------}

var
    ruidoAmbiente, volumeNormal, volumePlosivas: integer;
    op: char;
    dir: string;

begin
    dir := sintAmbiente('TESTAMIC', 'DIRTESTAMIC');
    if dir = '' then
        dir := 'c:\winvox\som\testamic';
    SintInic (0, dir);
    sintFalaPont := false;
    screensize.Y := 18;

    writeln ('Programa de medição do volume do microfone.');
    sintSom ('TMINIC');
    writeln;

    writeln ('Estarei obtendo o nível de ruído ambiente por 5 segundos.');
    sintSom ('TMRUIAMB');
    write ('Aperte Enter e fique em silêncio.');
    sintSom ('TMENTSIL');
    op:= readkey;

    if op = ESC then
    begin
        sintFim;
        doneWinCrt;
    end;

    delay (100);   // despreza som da tecla...
    ruidoAmbiente := calculateMaxVolume (5);

    textColor (yellow);
    showVolume (ruidoAmbiente);
    writeln ;
    write ('Ruído ambiente: ');
    sintSom ('TMRUI2');
    sintWriteInt (trunc(ruidoAmbiente * 100 / 128));
    writeln (' por cento.');
    sintSom ('TMPORCEN');
    if ruidoAmbiente < 10 then
    begin
        writeln ('Excelente.');
        sintSom ('TMEXEL');
    end
    else
    if ruidoAmbiente < 30 then
    begin
        writeln ('Normal.');
        sintSom ('TMNORMAL');
    end
    else
    begin
        writeln ('O ambiente está muito ruidoso.');
        sintSom ('TMMUIRUI');
    end;
    textColor (lightGray);
    writeln;

    writeln ('Aperte Enter, depois fale pelo menos três vezes a seguinte frase em voz normal:');
    sintSom ('TMENTNOR');
    write ('Estou testando o microfone.');
    sintSom ('TMTESMIC');
    readln;
    volumeNormal := calculateMaxVolume (10);

    textColor (yellow);
    showVolume (volumeNormal);
    writeln ;
    writeln ('Volume Normal: ');
    sintSom ('TMVOLNOR');
    sintWriteInt (trunc(volumeNormal * 100 / 128));
    writeln (' por cento.');
    sintSom ('TMPORCEN');
    if volumeNormal < 30  then begin writeln ('Está muito baixo.'); sintSom ('TMMUIBAI'); end;
    if volumeNormal > 120 then begin writeln ('Está muito alto.'); sintSom ('TMMUIALT'); end;
    textColor (lightGray);
    writeln;

    writeln ('Aperte Enter e depois fale forte várias vezes mas sem gritar:');
    sintSom ('TMENTFOR');
    write ('Porta, pato, pipoca, papai');
    sintSom ('TMPPP');
    readln;
    volumePlosivas := calculateMaxVolume (10);

    textColor (yellow);
    showVolume (volumePlosivas);
    writeln ;
    write ('Volume das plosivas: ');
    sintSom ('TMVOLEXP');
    sintWriteInt (trunc(volumePlosivas * 100 / 128));
    writeln (' por cento.');
    sintSom ('TMPORCEN');
    textColor (lightGray);
    if volumePlosivas < 30  then begin writeln ('Está muito baixo'); sintSom ('TMMUIBAIX'); end;
    if volumePlosivas > 126 then begin writeln ('Está muito alto'); sintSom ('TMMUIALT'); end;
    writeln;

    writeln ('Ok, aperte Enter para terminar.');
    sintSom ('TMOKTERM');
    readln;
    sintFim;
    doneWinCrt;
end.
