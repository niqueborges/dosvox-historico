{ This version of this program is not free software }
{ Copyright (C) 2008 - NCE/UFRJ - The Dosvox Project }

{ Mini servidor para fala Sapi }
{ Autor: Antonio Borges }
{ Projeto MEC Daisy - NCE/UFRJ - 2008 }

program servSapi;

uses dvcrt, dvsapi, dvsapglb, dvinet, classes, sysutils, Windows;

var
    porta: integer;

var
    sockListen, sock: longint;

    erroSapi: boolean;
    tipoSapi, pitch, rate, volume: integer;
    nvoz: integer;
    emUTF: boolean;

const
    CMD_QUIT            = '~Q';
    CMD_SPEAK_DIR       = '~D';
    CMD_BREAK           = '~B';
    CMD_SET_UTF         = '~U';   // seguido por zero, volta a ANSI
    CMD_SET_PITCH       = '~P';
    CMD_SET_RATE        = '~R';
    CMD_SET_VOLUME      = '~V';
    CMD_IS_SPEAKING     = '~I';
    CMD_GET_SPEAKER     = '~G';   // lista tipo sapi, número da voz, voz
    CMD_SET_SPEAKER     = '~S';   // provisoriamente seguido pelo tipo sapi e num.voz
    CMD_GET_PARAMETERS  = '~T';   // obtém os parâmetros atuais da voz
    CMD_GET_VOICES      = '~?';   // listagem o tipo sapi, número da voz, voz
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

function trocaLetrasDir (s: string): string;
var i: integer;
    saida: string;
begin
    saida := '';
    for i := 3 to length (s) do
        begin
            case s[i] of
                ':': saida := saida + ' dois pontos ';
                ';': saida := saida + ' ponto e vírgula ';
                '/': saida := saida + ' barra ';
                '\': saida := saida + ' contrabarra ';
                '?': saida := saida + ' interrogação ';
                '!': saida := saida + ' exclamação ';
                '@': saida := saida + ' arrôba ';
                '.': saida := saida + ' ponto ';
                '-': saida := saida + ' traço ';
                '_': saida := saida + ' sublinhado ';
                '$': saida := saida + ' cifrão ';
                '~': saida := saida + ' til ';
                '=': saida := saida + ' igual ';
                '&': saida := saida + ' ê comercial ';
                '#': saida := saida + ' sinal de número ';
            else
                saida := saida + s[i];
            end;
        end;
    result := saida;
end;

type
    TLCID = record
        code: string[5];
        number: integer;
    end;

const
    LCID: array [1..118] of TLCID = (
        {Afrikaans} (code: 'af'; number:$0436), //1078
        {Albanian} (code: 'sq'; number:$041C), //1052
        {Arabic - U.A.E.} (code: 'ar-ae'; number:$3801), //14337
        {Arabic - Bahrain} (code: 'ar-bh'; number:$3C01), //15361
        {Arabic - Algeria} (code: 'ar-dz'; number:$1401), //5121
        {Arabic - Egypt} (code: 'ar-eg'; number:$0C01), //3073
        {Arabic - Iraq} (code: 'ar-iq'; number:$0801), //2049
        {Arabic - Jordan} (code: 'ar-jo'; number:$2C01), //11265
        {Arabic - Kuwait} (code: 'ar-kw'; number:$3401), //13313
        {Arabic - Lebanon} (code: 'ar-lb'; number:$3001), //12289
        {Arabic - Libya} (code: 'ar-ly'; number:$1001), //4097
        {Arabic - Morocco} (code: 'ar-ma'; number:$1801), //6145
        {Arabic - Oman} (code: 'ar-om'; number:$2001), //8193
        {Arabic - Qatar} (code: 'ar-qa'; number:$4001), //16385
        {Arabic - Saudia Arabia} (code: 'ar-sa'; number:$0401), //1025
        {Arabic - Syria} (code: 'ar-sy'; number:$2801), //10241
        {Arabic - Tunisia} (code: 'ar-tn'; number:$1C01), //7169
        {Arabic - Yemen} (code: 'ar-ye'; number:$2401), //9217
        {Basque} (code: 'eu'; number:$042D), //1069
        {Belarusian} (code: 'be'; number:$0423), //1059
        {Bulgarian} (code: 'bg'; number:$0402), //1026
        {Catalan} (code: 'ca'; number:$0403), //1027
        {Chinese} (code: 'zh'; number:$0004), //4
        {Chinese - PRC} (code: 'zh-cn'; number:$0804), //2052
        {Chinese - Hong Kong} (code: 'zh-hk'; number:$0C04), //3076
        {Chinese - Singapore} (code: 'zh-sg'; number:$1004), //4100
        {Chinese - Taiwan} (code: 'zh-tw'; number:$0404), //1028
        {Croatian} (code: 'hr'; number:$041A), //1050
        {Czech} (code: 'cs'; number:$0405), //1029
        {Danish} (code: 'da'; number:$0406), //1030
        {Dutch} (code: 'nl'; number:$0413), //1043
        {Dutch - Belgium} (code: 'nl-be'; number:$0813), //2067
        {English} (code: 'en'; number:$0009), //9
        {English - Australia} (code: 'en-au'; number:$0C09), //3081
        {English - Belize} (code: 'en-bz'; number:$2809), //10249
        {English - Canada} (code: 'en-ca'; number:$1009), //4105
        {English - Ireland} (code: 'en-ie'; number:$1809), //6153
        {English - Jamaica} (code: 'en-jm'; number:$2009), //8201
        {English - New Zealand} (code: 'en-nz'; number:$1409), //5129
        {English - South Africa} (code: 'en-za'; number:$1C09), //7177
        {English - Trinidad} (code: 'en-tt'; number:$2C09), //11273
        {English - United Kingdom} (code: 'en-gb'; number:$0809), //2057
        {English - United States} (code: 'en-us'; number:$0409), //1033
        {Estonian} (code: 'et'; number:$0425), //1061
        {Farsi} (code: 'fa'; number:$0429), //1065
        {Finnish} (code: 'fi'; number:$040B), //1035
        {Faeroese} (code: 'fo'; number:$0438), //1080
        {French - Standard} (code: 'fr'; number:$040C), //1036
        {French - Belgium} (code: 'fr-be'; number:$080C), //2060
        {French - Canada} (code: 'fr-ca'; number:$0C0C), //3084
        {French - Luxembourg} (code: 'fr-lu'; number:$140C), //5132
        {French - Switzerland} (code: 'fr-ch'; number:$100C), //4108
        {Gaelic - Scotland} (code: 'gd'; number:$043C), //1084
        {German - Standard} (code: 'de'; number:$0407), //1031
        {German - Austrian} (code: 'de-at'; number:$0C07), //3079
        {German - Lichtenstein} (code: 'de-li'; number:$1407), //5127
        {German - Luxembourg} (code: 'de-lu'; number:$1007), //4103
        {German - Switzerland} (code: 'de-ch'; number:$0807), //2055
        {Greek} (code: 'el'; number:$0408), //1032
        {Hebrew} (code: 'he'; number:$040D), //1037
        {Hindi} (code: 'hi'; number:$0439), //1081
        {Hungarian} (code: 'hu'; number:$040E), //1038
        {Icelandic} (code: 'is'; number:$040F), //1039
        {Indonesian} (code: 'in'; number:$0421), //1057
        {Italian - Standard} (code: 'it'; number:$0410), //1040
        {Italian - Switzerland} (code: 'it-ch'; number:$0810), //2064
        {Japanese} (code: 'ja'; number:$0411), //1041
        {{Korean} (code: 'ko'; number:$0412), //1042
        {Latvian} (code: 'lv'; number:$0426), //1062
        {Lithuanian} (code: 'lt'; number:$0427), //1063
        {Macedonian} (code: 'mk'; number:$042F), //1071
        {Malay - Malaysia} (code: 'ms'; number:$043E), //1086
        {Maltese} (code: 'mt'; number:$043A), //1082
        {Norwegian - Bokmål} (code: 'no'; number:$0414), //1044
        {Polish} (code: 'pl'; number:$0415), //1045
        {Portuguese - Standard} (code: 'pt'; number:$0816), //2070
        {Portuguese - Brazil} (code: 'pt-br'; number:$0416), //1046
        {Raeto-Romance} (code: 'rm'; number:$0417), //1047
        {Romanian} (code: 'ro'; number:$0418), //1048
        {Romanian - Moldova} (code: 'ro-mo'; number:$0818), //2072
        {Russian} (code: 'ru'; number:$0419), //1049 //
        {Russian - Moldova} (code: 'ru-mo'; number:$0819), //2073
        {Serbian - Cyrillic} (code: 'sr'; number:$0C1A), //3098
        {Setsuana} (code: 'tn'; number:$0432), //1074
        {Slovenian} (code: 'sl'; number:$0424), //1060
        {Slovak} (code: 'sk'; number:$041B), //1051
        {Sorbian} (code: 'sb'; number:$042E), //1070
        {Spanish - Standard} (code: 'es'; number:$040A), //1034
        {Spanish - Argentina} (code: 'es-ar'; number:$2C0A), //11274
        {Spanish - Bolivia} (code: 'es-bo'; number:$400A), //16394
        {Spanish - Chile} (code: 'es-cl'; number:$340A), //13322
        {Spanish - Columbia} (code: 'es-co'; number:$240A), //9226
        {Spanish - Costa Rica} (code: 'es-cr'; number:$140A), //5130
        {Spanish - Dominican Republic} (code: 'es-do'; number:$1C0A), //7178
        {Spanish - Ecuador} (code: 'es-ec'; number:$300A), //12298
        {Spanish - Guatemala} (code: 'es-gt'; number:$100A), //4106
        {Spanish - Honduras} (code: 'es-hn'; number:$480A), //18442
        {Spanish - Mexico} (code: 'es-mx'; number:$080A), //2058
        {Spanish - Nicaragua} (code: 'es-ni'; number:$4C0A), //19466
        {Spanish - Panama} (code: 'es-pa'; number:$180A), //6154
        {Spanish - Peru} (code: 'es-pe'; number:$280A), //10250
        {Spanish - Puerto Rico} (code: 'es-pr'; number:$500A), //20490
        {Spanish - Paraguay} (code: 'es-py'; number:$3C0A), //15370
        {Spanish - El Salvador} (code: 'es-sv'; number:$440A), //17418
        {Spanish - Uruguay} (code: 'es-uy'; number:$380A), //14346
        {Spanish - Venezuela} (code: 'es-ve'; number:$200A), //8202
        {Sutu} (code: 'sx'; number:$0430), //1072
        {Swedish} (code: 'sv'; number:$041D), //1053
        {Swedish - Finland} (code: 'sv-fi'; number:$081D), //2077
        {Thai} (code: 'th'; number:$041E), //1054
        {Turkish} (code: 'tr'; number:$041F), //1055
        {Tsonga} (code: 'ts'; number:$0431), //1073
        {Ukranian} (code: 'uk'; number:$0422), //1058
        {Urdu - Pakistan} (code: 'ur'; number:$0420), //1056
        {Vietnamese} (code: 'vi'; number:$042A), //1066
        {Xhosa} (code: 'xh'; number:$0434), //1076
        {Yiddish} (code: 'ji'; number:$043D), //1085
        {Zulu} (code: 'zu'; number:$0435) // 1077
    );

function converteVoz (n: integer): string;
var
    name, synth, locale, gender: string;
    i: integer;
    paramSapi: TInfoSapi;
begin
    sapiInfo (n, paramSapi);
    name := paramSapi.nomeVoz;
    if copy (name, 1, 10) = 'Microsoft ' then
         delete (name, 1, 10)
    else
    if copy (name, 1, 9) = 'ScanSoft ' then
         begin
             delete (name, 1, 9);
             if (pos('_', name) <> 0) then delete (name, pos('_', name), 99);
         end
    else
    if pos ('male voice', name) <> 0 then
        name := paramSapi.modo;

    if paramSapi.produto = 'Não disponível' then
        synth := paramSapi.produtor
    else
        synth := paramSapi.produto;
    locale := 'pt-br';
    for i := 1 to 118 do
        if paramSapi.lingua = LCID[i].number then
            begin
                locale := LCID[i].code;
                break;
            end;
    if name = 'Juliana' then paramSapi.sexo := 1;
    case paramSapi.sexo of
        0: gender := 'Neutral';
        1: gender := 'Female';
        2: gender := 'Male';
    end;
    result := name + ';' + synth + ';' + locale + ';' + gender

(*
    writelnRede (sock, '-->' + paramSapi.nomeVoz + ';' +
                       paramSapi.modo + ';' +
                       paramSapi.produtor + ';' +
                       paramSapi.produto + ';' +
                       paramSapi.estilo + ';' +
                       paramSapi.dialeto  + ';' +
                       intToStr (paramSapi.tipoSapi) + ';' +
                       intToStr (paramSapi.voz) + ';' +
                       intToStr (paramSapi.sexo) + ';' +
                       intToStr (paramSapi.idade) + ';' +
                       intToStr (paramSapi.lingua) + ';'
                       );
*)
end;

procedure pegaVozes;
var
    sapiAtual, vozAtual, rateAtual, pitchAtual: integer;
    tipoSapi: integer;
    param: TParamVoz;
    n, maxVozes: integer;
const
    tabSexo: array [1..2] of char = ('F', 'M');
begin
    sapiPegaParam (param);
    sapiAtual := param.tipoSapi;
    vozAtual := param.voz;
    rateAtual := param.velocidade;
    pitchAtual := param.tom;

    sapiFim;
    for tipoSapi := 3 to 5 do
        begin
            if sapiInic (1, 0, 0, tipoSapi, '') then
                begin
                    maxVozes := sapiNumVozes;
                    for n := 1 to maxVozes do
                         writelnRede (sock, converteVoz(n));
                    sapiFim;
                end;
        end;

    writelnRede (sock, '.');

    sapiInic (vozAtual, rateAtual, pitchAtual, sapiAtual, '');
end;

function pegaVozPeloNome (nomeBuscado: string; var tipoSapi, nvoz: integer): boolean;
var
    sapiAtual, vozAtual, rateAtual, pitchAtual: integer;
    tipo: integer;
    param: TParamVoz;
    paramSapi: TInfoSapi;
    n, maxVozes: integer;
    nome: string;
label achou;
begin
    sapiPegaParam (param);
    sapiAtual := param.tipoSapi;
    vozAtual := param.voz;
    rateAtual := param.velocidade;
    pitchAtual := param.tom;

    nomeBuscado := ansiUpperCase (nomeBuscado);
    sapiFim;
    for tipo := 5 downto 3 do
        begin
            if sapiInic (1, 0, 0, tipo, '') then
                begin
                    maxVozes := sapiNumVozes;
                    for n := 1 to maxVozes do
                          begin
                              nome := ansiUpperCase (converteVoz (n));
                              if pos (nomeBuscado, nome) <> 0 then
                                  begin
                                      tipoSapi := tipo;
                                      nvoz := n;
                                      result := true;
                                      sapiFim;
                                      goto achou;
                                  end;
                          end;
                    sapiFim;
                end;
        end;

    result := false;

achou:
    sapiInic (vozAtual, rateAtual, pitchAtual, sapiAtual, '');
end;


function utfToAnsi (s: string): string;
var b, b2: byte;
    s2: string;
    i: integer;
begin
    s2 := '';
    s := s + ' ';
    i := 1;
    while i <= length (s) - 1 do
        begin
            b := ord(s[i]);
            if (b < $80) or ((b and $e0) <> $c0)then
                s2 := s2 + s[i]
            else
                begin
                    b2 := ord (s[i+1]) and $3f;
                    b := (b and $03) shl 6;
                    s2 := s2 + chr(b or b2);
                    i := i + 1;
                end;
            i := i + 1;
        end;
    utfToAnsi := s2;
end;

procedure inicializa;
var afalar: string;
    t, np: integer;
begin
    afalar := '';
    porta := 1955;
    emUTF := true;
    erroSapi := true;

    tipoSapi := 5;
    nvoz := 1;
    pitch := 0;
    rate := 0;

    if paramCount <> 0 then
        begin
            np := 1;
            while np <= paramCount do
                begin
                    if ansiUpperCase (paramStr(np)) = '-P' then
                        begin
                           np := np + 1;
                           porta := strToInt (paramStr(np));
                        end
                    else
                    if ansiUpperCase (paramStr(np)) = '-S' then
                        begin
                           np := np + 1;
                           tipoSapi := strToInt (paramStr(np));
                           np := np + 1;
                           nvoz := strToInt (paramStr(np));
                           np := np + 1;
                           pitch := strToInt (paramStr(np));
                           np := np + 1;
                           rate := strToInt (paramStr(np));
                        end
                    else
                        afalar := afalar + ' ' + paramStr(np);
                    np := np + 1;
                end;

            if sapiInic (nvoz, rate, pitch, tipoSapi, '') then
                erroSapi := false;

        end
    else
        for t := 5 downto 3 do
            if sapiInic (nvoz, rate, pitch, t, '') then
                begin
                    erroSapi := false;
                    tipoSapi := t;
                    break;
                end;

    if (not erroSapi) and (afalar <> '') then
        begin
            sapiFala(aFalar);
            while sapiAtivo(1) do delay (100);
        end;
end;

var
    paramVoz: TParamVoz;
    s, cmd: string;
    pbuf: PbufRede;
    tom, vel, vol, maxv, minv, posic: integer;
    mudouOk: boolean;

begin
    screenSize.Y := 7;
    screenSize.X := 40;
    writeln;
    showWindow (crtWindow, SW_HIDE);

    setWindowTitle('Servidor Sapi');
    writeln ('   Servidor SAPI - v1.0');
    writeln;
    writeln ('   Projeto MEC Daisy');
    writeln;
    writeln ('   NCE/UFRJ - 2008');

    abreWinSock;
    inicializa;

    delay (500);

    sockListen := escutaConexao (porta);
    repeat
         delay (500);
    until chegouRede (sockListen);

    sock := aceitaConexao (sockListen);    // só uma conexão
    fechaConexao (sockListen);
    pbuf := inicBufRede (sock);

    if erroSapi then
        writelnRede(sock, '--- Nenhum sistema Sapi está instalado')
    else
        writelnRede(sock, '+++ Servidor de fala - v1.2');

    while readlnBufRede (pbuf, s, 0) do
        begin
            writeln (s);
            cmd := ansiUpperCase (s);
            if erroSapi and (cmd <> CMD_QUIT) then
                begin
                    writelnRede(sock, '--- Nenhum sistema Sapi está instalado')
                end
            else
            if cmd = CMD_QUIT then
                break
            else
            if cmd = CMD_BREAK then sapiReset
            else
            if copy (cmd, 1, length(CMD_SET_UTF)) = CMD_SET_UTF then
                begin
                    delete (s, 1, length (CMD_SET_UTF));
                    emUTF := getNumber(s) <> 0;
                end
            else
            if cmd = CMD_GET_SPEAKER then
                begin
                    if erroSapi then
                        writelnRede(sock, 'SAPI inoperante!')   // Sapi não está ativo
                    else
                        writelnRede (sock, converteVoz (nvoz));
                end
            else
            if copy (cmd, 1, length(CMD_SET_SPEAKER)) = CMD_SET_SPEAKER then
                begin
                    mudouOk := true;

                    delete (s, 1, length (CMD_SET_SPEAKER));
                    s := trim (ansiUpperCase(s));
                    if cmd = '' then s := '3 1 0';

                    if s[1] in ['3'..'5'] then
                        begin
                           tipoSapi := getnumber(s);
                           nvoz := getnumber(s);
                        end
                    else
                        begin
                            if s[1] <> '"' then
                                begin
                                    posic := pos (' ', s);
                                    if posic <> 0 then delete (s, posic, 999);
                                end
                            else
                                begin
                                    delete (s, 1, 1);
                                    if s[length(s)] = '"' then
                                        delete (s, length(s), 1);
                                end;

                            if not pegaVozPeloNome (s, tipoSapi, nvoz) then
                                begin
                                    tipoSapi := 3;
                                    nvoz := 1;
                                    mudouOk := false;
                                end;
                        end;

                    sapiFim;

                    pitch := 0;
                    rate := 0;
                    volume := 8;
                    if sapiInic (nvoz, rate, pitch, tipoSapi, '') and mudouOk then
                        writelnRede (sock, '1')
                    else
                        begin
                            writelnRede (sock, '0');
                            sapiInic (1, 0, 0, 3, '');   // se problema tenta ir pela lianeTTS
                        end;
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
                writelnRede(sock, intToStr (integer((sapiAtivo (1)))))
            else
            if cmd = CMD_GET_VOICES then
                pegaVozes
            else
            if cmd = CMD_GET_PARAMETERS then
                begin
                    sapiPegaParam(paramVoz);
                    minv := paramVoz.minTom;
                    maxv := paramVoz.maxTom;
                    tom := paramVoz.tom;
                    tom := (((tom-minv) * 20) div (maxv-minv)) - 10;

                    minv := paramVoz.minVeloc;
                    maxv := paramVoz.maxVeloc;
                    vel := paramVoz.velocidade;
                    vel := (((vel-minv) * 20) div (maxv-minv)) - 10;
                    vol := 10;
                    writelnRede (sock, intToStr(tom) + ';' + intToStr(vel) + ';' + intToStr(vol));
                end
            else

                begin
                    if copy (cmd, 1, length(CMD_SPEAK_DIR)) = CMD_SPEAK_DIR then
                        s := trocaLetrasDir(s);
                    if emUTF then
                        s := utfToAnsi (s);
                    sapiFala (s);
                end;
        end;

    if not erroSapi then sapiFim;
    fechaConexao (sock);
    fechaWinSock;

    fimBufRede (pbuf);
    donewincrt;
end.

