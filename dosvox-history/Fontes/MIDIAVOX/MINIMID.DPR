{ Programa para tocar arquivos de som - versão simplificada }
{ Autor : José Antonio Borges  }
{ Em 1998 }

uses dvcrt, dvwin, winProcs, wintypes, sysutils, mmsystem;
var nomearq: string;

var nomeDir: string;
    retornoMci: array [0..255] of char;
    erroMci: longint;

procedure falaErroMCI;
var p: array [0..255] of char;
begin
    mciGetErrorString (erroMci, p, 255);

end;

procedure sendString (s: string);
var p: array [0..255] of char;
begin
    strPcopy (p, s);
    erroMci := mciSendString (p, retornoMci, 255, 0);
end;

begin
    checkBreak := false;
    screensize.y := 3;
    setWindowText (crtWindow, 'MINIMID');

    if paramcount <> 1 then
        begin
            beep;
            exit;
        end;

    nomeArq := paramStr(1);
    while (nomeArq <> '') and (nomeArq[1] = ' ') do  delete (nomeArq, 1, 1);
    if pos ('.', nomeArq) = 0 then
        nomeArq := nomeArq + '.WAV';

    if pos ('\', nomearq) = 0 then
        begin
            getDir (0, nomeDir);
            if nomeDir [length (nomedir)] <> '\' then
                nomeDir := nomedir + '\';
            nomeArq := nomeDir + nomeArq;
        end;

    sendString ('open "' + nomearq + '" alias mysound');
    sendString ('play mysound');

    write ('Aperte qualquer tecla para terminar');
    repeat until keypressed;
    while keypressed do readkey;

    sendString ('stop mysound');
    sendString ('close mysound');

    doneWincrt;
end.
