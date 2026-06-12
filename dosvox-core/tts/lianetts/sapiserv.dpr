{ This version of this program is not free software }
{ Copyright (C) 2008 - NCE/UFRJ - The Dosvox Project }

{ Mini servidor para fala Sapi }
{ Autor: Antonio Borges }
{ Projeto MEC Daisy - NCE/UFRJ - 2008 }

program servSapi;

uses dvcrt, dvsapi, dvsapglb, dvinet, classes, sysutils, Windows;

const
    porta = 1955;

var
    sockListen, sock: longint;
    lidos: integer;
    pbuf: PbufRede;
    s, cmd: string;

    nomeVoz: string;
    nvoz: integer;
    tipoSapi, pitch, rate, volume: integer;

var
    paramSapi: TInfoSAPI;
    paramVoz: TParamVoz;

const
    CMD_QUIT         = '~Q';
    CMD_BREAK        = '~B';
    CMD_SET_PITCH    = '~P';
    CMD_SET_RATE     = '~R';
    CMD_SET_VOLUME   = '~V';
    CMD_IS_SPEAKING  = '~I';
    CMD_GET_SPEAKER  = '~G';   // lista tipo sapi, número da voz, voz
    CMD_SET_SPEAKER  = '~S';   // provisoriamente seguido pelo tipo sapi e num.voz
    CMD_GET_VOICES   = '~?';   // listagem o tipo sapi, número da voz, voz
                               // várias linhas, a última com um pontinho


function getNumber (var s: string): integer;
var
    v: integer;
    nega: integer;
begin
    s := trim (s);
    if s = '' then
        begin
            getNumber := 0;
            exit;
        end;
    nega := 1;
    if s[1] = '-' then
        begin
            delete (s, 1, 1);
            nega := -1;
        end;
    v := 0;
    while (s <> '') and (s[1] in ['0'..'9']) do
        begin
            v := v * 10 + ord (s[1]) - ord('0');
            delete (s, 1, 1);
        end;

    getNumber := v * nega;

end;

procedure pegaVozes;
var
    sapiAtual, vozAtual, rateAtual, pitchAtual: integer;
    tipoSapi: integer;
    param: TParamVoz;
    paramSapi: TInfoSapi;
    n, maxVozes: integer;
    listaNomes: TStringList;
begin
    sapiPegaParam (param);
    sapiAtual := param.tipoSapi;
    vozAtual := param.voz;
    rateAtual := param.velocidade;
    pitchAtual := param.tom;

    for tipoSapi := 3 to 5 do
        begin
            sapiFim;
            sapiInic (1, 0, 0, tipoSapi, '');
            maxVozes := sapiNumVozes;
            for n := 1 to maxVozes do
                begin
                    sapiInfo (n, paramSapi);
                    writelnRede (sock, intToStr (paramSapi.tipoSapi) + ' ' +
                                       intToStr (n) + ' ' +
                                       paramSapi.nomeVoz);
                end;
        end;
    writelnRede (sock, '.');
    sapiFim;
    sapiInic (vozAtual, rateAtual, pitchAtual, sapiAtual, '');
end;


begin
    screenSize.Y := 8;
    screenSize.X := 40;
    writeln;
    setWindowTitle('Servidor Sapi');
    writeln ('   Servidor SAPI - v1.0');
    writeln;
    writeln ('   Projeto MEC Daisy');
    writeln;
    writeln ('   NCE/UFRJ - 2008');
    abreWinSock;

    tipoSapi := 4;
    nvoz := 1;
    pitch := 0;
    volume := 8;
    rate := 0;

    sapiInic (nvoz, rate, pitch, tipoSapi, '');
    delay (500);
    showWindow (crtWindow, SW_HIDE);

    sockListen := escutaConexao (porta);
    repeat
         delay (500);
    until chegouRede (sockListen);

    sock := aceitaConexao (sockListen);    // só uma conexão
    fechaConexao (sockListen);
    pbuf := inicBufRede (sock);

    writelnRede(sock, '+++ Servidor de fala - v.1.0 para Windows        ');
    while readlnBufRede (pbuf, s, 0) do
        begin
            cmd := ansiUpperCase (s);
            if cmd = CMD_QUIT then
                break
            else
            if cmd = CMD_BREAK then sapiReset
            else
            if cmd = CMD_GET_SPEAKER then
                begin
                    sapiInfo (nvoz, paramSapi);
                    writelnRede(sock, intToStr (paramSapi.tipoSapi) + ' ' +
                                      intToStr (paramSapi.voz) + ' ' +
                                      paramSapi.nomeVoz);
                end
            else
            if copy (cmd, 1, length(CMD_SET_SPEAKER)) = CMD_SET_SPEAKER then
                begin
                    delete (s, 1, length (CMD_SET_SPEAKER));
                    s := trim (ansiUpperCase(s));
                    if cmd = '' then s := '3 1 0';

                    if s[1] in ['3'..'5'] then
                        begin
                           tipoSapi := getnumber(s);
                           nvoz := getnumber(s);
                           pitch := 0;
                           rate := 0;
                           volume := 8;
                        end;

                    sapiFim;
                    sapiInic (nvoz, rate, pitch, tipoSapi, '');
                end
            else
            if copy (cmd, 1, length(CMD_SET_PITCH)) = CMD_SET_PITCH then
                begin
                    delete (s, 1, length (CMD_SET_PITCH));
                    s := trim (s);
                    try
                        pitch := strToInt (s);
                    except
                        pitch := 0;
                    end;
                    sapiPegaParam(paramVoz);
                    paramVoz.tom := pitch;
                    sapiMudaParam(paramVoz);
                end
            else
            if copy (cmd, 1, length(CMD_SET_RATE)) = CMD_SET_RATE then
                begin
                    delete (s, 1, length (CMD_SET_RATE));
                    s := trim (s);
                    try
                        rate := strToInt (s);
                    except
                        rate := 0;
                    end;
                    sapiPegaParam(paramVoz);
                    paramVoz.velocidade := rate;
                    sapiMudaParam(paramVoz);
                end
            else
            if copy (cmd, 1, length(CMD_SET_VOLUME)) = CMD_SET_VOLUME then
                begin
                    delete (s, 1, length (CMD_SET_VOLUME));
                    // não implementado ainda
                end
            else
            if cmd = CMD_IS_SPEAKING then
                writelnRede(sock, intToStr (integer((sapiAtivo (2)))))
            else
            if cmd = CMD_GET_VOICES then
                pegaVozes
            else
                sapiFala (s);
        end;

    sapiFim;
    fechaConexao (sock);
    fechaWinSock;

    fimBufRede (pbuf);
    donewincrt;
end.
