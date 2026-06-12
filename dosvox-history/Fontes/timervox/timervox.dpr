{-------------------------------------------------}
{  Timer de cozinha
{  Autor: Antonio Borges
{  Em 06/03/2011
{-------------------------------------------------}

program timervox;

uses
    windows,
    dvwin,
    dvcrt,
    dvExec,
    SysUtils;
var
    s: string;
    tempo0, semana0: integer;


function emSegundos (s: string): integer;
var i, x, seg, p, erro: integer;
    extrai: string;
begin
     result := -1;
     s := trim(s) + ':';
     seg := 0;
     for i := 1 to 3 do
         begin
             p := pos (':', s);
             extrai := copy (s, 1, p-1);
             delete (s, 1, p);
             val (extrai, x, erro);
             if (erro <> 0) or (x < 0) then
                 exit;
             seg := seg*60 + x;
             if s = '' then break;
         end;
     if s <> '' then exit;

     result := seg;
end;

function pegaTempo: integer;
var
    ano, mes, dia, hora, minuto, segundo, semana, cent: word;
    ndias: integer;
begin
    getDate(ano, mes, dia, semana);
    dvcrt.gettime (hora, minuto, segundo, cent);
    ndias := semana - semana0;
    if ndias < 0 then ndias := ndias + 7;
    hora := hora + ndias*24;
    result := (((hora*60+minuto)*60+segundo))*100+cent;
end;

procedure tocarArquivoSom (nomeArq: string);
var nomeProg: string;
begin
    nomeProg := sintAmbiente ('TIMERVOX', 'TOCADOR', sintAmbiente('DOSVOX', 'PGMDOSVOX', '@') + '\Midiavox.exe');
    while sintFalando do waitMessage;
    nomeArq := trim (nomeArq);
    if pos (' ', nomeArq) <> 0 then
        if nomeArq [1] <> '"' then
            nomeArq := '"' + nomeArq + '"';
    if executaProg (nomeProg, '', nomeArq) >= 32 then
        esperaProgVoltar;
end;

procedure temporiza (tempoTotal: integer);
const
    gatilho = 3;   // em décimos de segundo
var
    tempo, segFaltando: integer;
    minDif, segDif: integer;
    decimosSobrando, janTempo: integer;
    arquivoTocar: string;
label bli;
begin
    gotoxy (1, 3); clreol;
    showWindow (crtWindow, SW_SHOWMINIMIZED);
    arquivoTocar := sintAmbiente ('TIMERVOX', 'ARQUIVOTOCAR', '');
    tempo0 := pegaTempo;

    repeat
        tempo := pegaTempo;
        janTempo := tempo-tempo0;         // em centésimos
        segFaltando := tempoTotal - (janTempo div 100);

        delay (200);
        decimosSobrando := (janTempo mod 100) div 10;
        if decimosSobrando > gatilho then continue;   // gatilho: 3 décimos

        gotoxy (1, 7);
        write (segFaltando);             // em segundos
        clreol;
        gotoxy (1, 4);

        minDif := (segFaltando div 60) mod 60;
        segDif := segFaltando mod 60;

        if segFaltando >= 3600 then   // se >= uma hora
            begin
                if (minDif = 0) and (segDif = 0) then
                    begin
                        limpaBufTec; clreol;
                        if (segFaltando div 3600) = 1 then
                            begin
                                writeln (intToStr(segFaltando div 3600) + ' hora');
                                sintetiza ('uma hora');
                            end
                        else
                        if (segFaltando div 3600) = 2 then
                            begin
                                writeln (intToStr(segFaltando div 3600) + ' horas');
                                sintetiza ('duas horas');
                            end
                        else
                            sintWriteln (intToStr(segFaltando div 3600) + ' horas');
                        delay (1000);
                    end;
            end
        else
        if segFaltando >= 600 then    // se >= dez minutos
            begin
                if ((minDif mod 10) = 0) and (segDif = 0) then
                    begin
                        limpaBufTec; clreol;
                        sintWriteln (intToStr(segFaltando div 60) + ' minutos');
                        delay (1000);
                    end;
            end
        else
        if segFaltando > 60 then      // se >= um minuto
            begin
                if segDif = 0 then
                    begin
                        limpaBufTec; clreol;
                        sintWriteln (intToStr(segFaltando div 60) + ' minutos');
                        delay (800);
                    end;
            end
        else
        if segFaltando > 10 then
            begin
                if (segDif mod 10) = 0 then
                    begin
                        limpaBufTec; clreol;
                        sintWriteln (intToStr(segFaltando) + ' segundos');
                    end;
            end
        else
            begin
                limpaBufTec; clreol;
                sintWrite (intToStr(segFaltando));
                writeln (' segundos ');
            end;

        delay (gatilho*100);   // 3 décimos de gatilho

        if keypressed then
             begin
                  limpaBufTec;
                  gotoxy (1, 6);
                  sintWriteln (intToStr(segFaltando div 3600) + ' horas ' +
                               intToStr(segFaltando div 60) + ' minutos ' +
                               intToStr(segFaltando mod 60) + ' segundos.');
                  delay (1000);
                  gotoxy (1, 6); clreol;
             end;

    until segFaltando <= 0;

    gotoxy (1, 4);
    showWindow (crtWindow, SW_SHOWNORMAL);
    limpaBufTec;
    if (arquivoTocar <> '') and (FileExists (arquivoTocar)) then
        tocarArquivoSom(arquivoTocar)
    else
    while not keypressed do
        sintBip;
    limpaBufTec;
end;

var
    c: char;
    tempoTotal: integer;
    entrouPorParametro: boolean;
label fim, novoTempo;
begin
    screensize.y := 7;
    clrscr;
    sintInic (0, '');
    setWindowTitle('Temporizador Vox');
    if paramCount <> 0 then
        begin
            entrouPorParametro := true;
            s := paramStr(1);
            writeln ('Quantidade de tempo:' + s);
        end
    else
        begin
            entrouPorParametro := false;
novoTempo:
            sintetiza ('Temporizador');
            writeln ('Quantidade de tempo (hora:minutos:segundos) ou tecle ESC para sair ');
            sintetiza ('Quantidade de tempo (hora dois pontos minutos dois pontos segundos) ou tecle ESC para sair');
            s := '';
            c := sintEditaCampo (s, wherex, wherey, 8, 80, true);
            writeln;
            if (trim(s) = '') or (c = ESC) then goto fim;
            sintWrite ('Aperte enter para temporizar  ');
            c := readkey; writeln (c);
            if c = ESC then goto fim;
        end;

    tempoTotal := emSegundos(s);
    if tempoTotal > 0 then
        temporiza (tempoTotal)
    else
        sintWriteln ('Especificação de tempo errada');
    if not entrouPorParametro then goto novoTempo;

fim:
    sintFim;
    doneWinCrt;
end.
