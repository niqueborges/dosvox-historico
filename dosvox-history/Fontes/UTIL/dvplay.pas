{
Unit: DVplay
Autor: Fabiano Ferreira
Data: 23/03/2017
Objetivo: oferecer recursos para programas que necessitem
tocar audio
}

unit dvplay;

interface
uses sysutils, mmsystem, dialogs, dvcrt;

function mOpen (nomearq,nomedisp : string): boolean;
function mclose (nomedisp : string): boolean;
function mplay (nomedisp : string): boolean;
procedure mpause(nomedisp: string);
procedure mvolup(nomedisp: string);
procedure mvoldown(nomedisp: string);
procedure mvolset(valvol: integer; nomedisp : string);
procedure mgo(nomedisp: string);
procedure mback (nomedisp: string);
procedure mgoto(posicaudio : integer; nomedisp : string);
function mnowtime(nomedisp : string): longint;
function mtotaltime(nomedisp : string) : longint;
procedure fadein(veloc,limite: integer;nomedisp: string);
procedure fadeout(veloc,limite : integer; nomedisp : string);
procedure preparavideo(nomedisp: string; numerojan : integer);

var
    volume : integer;
    tocandovideo : boolean;
    pausado : boolean;

implementation

const
    xIniTela = 1;       {* Linha e Coluna para reprodução de vídeo *}
    yIniTela = 5;

var
    comando, retorno: array [0..1024] of char;

function enviacomandomci(cmd : string): boolean;
begin
    strPCopy (comando, cmd);
    result := mciSendString(comando, retorno, 80, 0) = 0;
end;

Function GetParamComandoMCI (cmd : string): string;
begin
    strPCopy (comando, cmd);
    if mciSendString(comando, retorno, 512, 0) = 0 then
        result := StrPas(retorno)
    else
        result := '';
end;

// carrega a mídia (áudio ou vídeo)
function mOpen (nomearq,nomedisp : string): boolean;
begin
    mopen := enviaComandoMci('open "mpegvideo!' + nomearq+'"' + ' alias ' + nomedisp);
end;

// libera a mídia aberta
function mclose (nomedisp : string): boolean;
begin
    mclose := enviacomandomci('close ' + nomedisp);
end;

// toca a mídia previamente aberta
function mplay (nomedisp : string): boolean;
begin
    if enviacomandomci('play '+nomedisp) then
        begin
            mplay := true;
            pausado := false;
        end
    else
        result := false;
end;

//devolve o tempo total do audio em milisegundos
function mtotaltime(nomedisp : string) : longint;
begin
    if not enviacomandomci('status ' + nomedisp + ' length') then
        mtotaltime := 0
    else
        mtotaltime := strtoint(retorno);
end;

//devolve tempo atual do audio em milisegundos
function mnowtime(nomedisp : string): longint;
begin
    if enviacomandomci('status ' + nomedisp + ' position') then
        mnowtime := strtoint(retorno)
    else
        mnowtime := 0;
end;

//pausa o áudio corrente
procedure mpause(nomedisp: string);
begin
    if not pausado then
        if enviacomandomci('pause '+nomedisp) then
            pausado := true
        else
            mplay(nomedisp);
end;

//aumenta o volume do áudio corrente
procedure mvolup(nomedisp: string);
var
    recuperavolume : integer;

begin
    recuperavolume := volume;
    volume := volume + 50;
    if volume > 1000 then
        volume := recuperavolume
    else
        begin
            enviacomandomci('setaudio ' + nomedisp + ' left volume to ' + inttostr(volume));
            enviacomandomci('setaudio ' + nomedisp + ' right volume to ' + inttostr(volume));
        end;
end;

//abaixa o volume do áudio corrente
procedure mvoldown(nomedisp: string);
var
    recuperavolume : integer;
begin
    recuperavolume := volume;
    volume := volume - 50;
    if volume < 0 then
        volume := recuperavolume
    else
        begin
            enviacomandomci('setaudio '+nomedisp+' left volume to '  + inttostr(volume));
            enviacomandomci('setaudio '+nomedisp+' right volume to ' + inttostr(volume));
        end;
end;

//ajusta o volume do audio
procedure mvolset(valvol: integer; nomedisp : string);
begin
    enviacomandomci ('setaudio '+nomedisp+' left volume to ' + inttostr(valvol));
    enviacomandomci ('setaudio '+nomedisp+' right volume to ' + inttostr(valvol));
end;

//avança 5 segundos no áudio corrente
procedure mgo(nomedisp: string);
var
    tamtotal, posatual, avanca : integer;
begin
    tamtotal := mtotaltime(nomedisp);
    posatual := mnowtime(nomedisp);
    avanca := posatual + 5000;
    if avanca >= tamtotal then
        avanca := avanca - 4000;
    enviacomandomci ('play ' + nomedisp+' from ' + inttostr(avanca));
end;

//recua 5 segundos no audio corrente
procedure mback (nomedisp: string);
var
    recua : integer;
begin
    recua := mnowtime(nomedisp) - 5000;
    if recua < 1 then
        recua := 1;
    enviacomandomci ('play '+nomedisp+' from ' + inttostr(recua));
end;

//pula para um ponto no áudio
procedure mgoto(posicaudio : integer; nomedisp : string);
begin
    if posicaudio <= mtotaltime(nomedisp) then
        enviacomandomci ('play '+nomedisp+' from ' + inttostr(posicaudio));
end;

//Aumenta o volume gradativamente (fade in)
procedure fadein(veloc, limite: integer; nomedisp: string);
begin
    while (volume < limite) do
        begin
            mvolup(nomedisp);
            sleep(veloc);
        end;
end;

//Diminui o volume gradativamente (fade out)
procedure fadeout(veloc,limite: integer; nomedisp: string);
begin
    while ( volume > limite) do
        begin
            mvoldown(nomedisp);
            sleep(veloc);
        end;
end;

//prepara região da tela para reprodução de vídeos
procedure preparavideo(nomedisp: string; numerojan : integer);
var
    s: string;
    p: integer;

    xTela:  integer;
    yTela:  integer;
    dxTela: integer;
    dyTela: integer;

    dxVideo: integer;
    dyVideo: integer;

label
    pronto;

begin
    { Local destinado a reprodução de vídeos }
    xTela  := (xIniTela-1)  * CharSize.X;
    yTela  := (yIniTela-1)  * CharSize.Y;
    dxTela := 80 * CharSize.X - xTela -1;
    dyTela := 25 * CharSize.Y - yTela -1;

    s := trim (GetParamComandoMCI ('where '+nomedisp+' source'));

    p := pos (' ', s);
    if p = 0 then goto pronto;
    delete (s, 1, p);
    s := trim (s);

    p := pos (' ', s);
    if p = 0 then goto pronto;
    delete (s, 1, p);
    s := trim (s);

    p := pos (' ', s);
    if p = 0 then goto pronto;
    dxVideo := StrToInt (trim (copy (s, 1, p))) * 100;
    dyVideo := StrToInt (trim (copy (s, p, length(s) - p+1))) * 100;

    if dxVideo > dxTela then
        begin
            dyVideo := trunc (dyVideo * (dxTela / dxVideo));
            dxVideo := dxTela;
        end;
    if dyVideo > dyTela then
        begin
            dxVideo := trunc (dxVideo * (dyTela / dyVideo));
            dyVideo := dyTela;
        end;

    enviaComandoMci ('window '+nomedisp+' handle '+ intToStr(numerojan));

pronto:
    tocandoVideo := True;
    enviaComandoMci ('put midia destination at ' +
                intToStr(xTela + (dxTela - dxVideo) div 2) + ' ' +
                intToStr(yTela + (dyTela - dyVideo) div 2) + ' ' +
                intToStr(dxVideo) + ' ' +
                intToStr(dyVideo));
end;

//inicializa volume
begin
    volume := 1000;
end.
