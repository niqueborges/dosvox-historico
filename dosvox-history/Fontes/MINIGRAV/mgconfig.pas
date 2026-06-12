unit mgconfig;

interface
uses
    dvcrt, dvwin, dvForm, dvArq, sysutils, windows,
    mgvars, mgMsg, mgMp3, gramost;

procedure configPadrao;
procedure pegaParamConfig;
procedure configura;

implementation

{--------------------------------------------------------}

procedure configPadrao;
begin
    dist_eco   := DEF_DIST_ECO;
    fator_eco  := DEF_FATOR_ECO;
    dist_reverb  := DEF_DIST_REVERB;
    fator_reverb := DEF_FATOR_REVERB;
    nbufToca := DEF_BUFTOCA;
    nbufGrava := DEF_BUFGRAVA;
    rAmostra := 44100;
    maxMemoria := 0;
end;

{--------------------------------------------------------}

procedure pegaParamConfig;
var s: string;

    function pegaInt (s: string): integer;
    var i, erro: integer;
    begin
        val (s, i, erro);
        if erro <> 0 then pegaInt := 0
                    else pegaInt := i;
    end;

begin
    s := sintAmbiente ('MINIGRAV', 'MILI_ECO');
    if s = '' then   // se não foi previamente configurado, abandona
        exit;
    dist_eco := pegaInt(s) * 10;
    s := sintAmbiente ('MINIGRAV', 'FATOR_ECO');
    fator_eco := pegaInt (s);
    s := sintAmbiente ('MINIGRAV', 'MILI_REVERB');
    dist_reverb := pegaInt (s) * 10;
    s := sintAmbiente ('MINIGRAV', 'FATOR_REVERB');
    fator_reverb := pegaInt (s);
    s := sintAmbiente ('MINIGRAV', 'MAX_MEMORIA');
    maxMemoria:= pegaInt (s);
    s := sintAmbiente ('MINIGRAV', 'NBUF_TOCA');
    nbufToca := pegaInt (s);
    s := sintAmbiente ('MINIGRAV', 'NBUF_GRAVA');
    nbufGrava := pegaInt (s);
    s := sintAmbiente ('MINIGRAV', 'QUALIDADE');
    rAmostra := pegaInt (s);
    if (rAmostra > 44100) and (rAmostra < 48000) then
        rAmostra := 48000;
    if rAmostra > 48000  then
        rAmostra := 96000;
    if rAmostra = 0 then
        rAmostra := 44100;

    progFfmpeg := sintAmbiente ('MINIGRAV','PROGFFMPEG');
    if progFfmpeg = '' then
        progFfmpeg := pegarCaminhoFfmpeg;
    dirSox := sintAmbiente ('MINIGRAV','DIRSOX');
    if dirSox = '' then
        dirSox := sintAmbiente('DOSVOX', 'PGMDOSVOX')+'\sox\sox.exe';
end;

{--------------------------------------------------------}

procedure salvaParamConfig;
begin
    sintGravaAmbiente('MINIGRAV', 'MILI_ECO',     intToStr(dist_eco div 10));
    sintGravaAmbiente('MINIGRAV', 'FATOR_ECO',    intToStr(fator_eco));
    sintGravaAmbiente('MINIGRAV', 'MILI_REVERB',  intToStr(dist_reverb div 10));
    sintGravaAmbiente('MINIGRAV', 'FATOR_REVERB', intToStr(fator_reverb));
    sintGravaAmbiente('MINIGRAV', 'MAX_MEMORIA',  intToStr(maxMemoria));
    sintGravaAmbiente('MINIGRAV', 'NBUF_TOCA',    intToStr(nbufToca));
    sintGravaAmbiente('MINIGRAV', 'NBUF_GRAVA',   intToStr(nbufGrava));
    sintGravaAmbiente('MINIGRAV', 'PROGFFMPEG',    progFfmpeg);
    sintGravaAmbiente('MINIGRAV', 'QUALIDADE',    intToStr(rAmostra));
    sintGravaAmbiente('MINIGRAV', 'DIRSOX',  dirSox);
end;

{--------------------------------------------------------}

procedure configura;
var c, c2: char;
    mili_eco, mili_reverb: integer;
begin
    clrscr;
    mensagem ('MGCONF', 2);    {'Configurando'}

    mensagem ('MGRESET', 0);   {'Deseja retornar os valores padrões?'}
    sintLeTecla (c, c2);
    writeln;
    if c = ESC then exit;

    pegaParamConfig;

    if upcase (c) = 'S' then
        begin
            dist_eco   := DEF_DIST_ECO;
            fator_eco  := DEF_FATOR_ECO;
            dist_reverb  := DEF_DIST_REVERB;
            fator_reverb := DEF_FATOR_REVERB;
            maxMemoria := 0;
            nbufToca := DEF_BUFTOCA;
            nbufGrava := DEF_BUFGRAVA;
            progFfmpeg := pegarCaminhoFfmpeg;
            rAmostra := 44100;
        end;

    garanteEspacoTela (11);
    mili_eco := dist_eco div 10;
    mili_reverb := dist_reverb div 10;

    formCria;
    formCampoInt ('MGMSECO',  pegaTextoMensagem('MGMSECO'),  mili_eco);           {'milissegundos do eco'}
    formCampoInt ('MGPERECO', pegaTextoMensagem('MGPERECO'), fator_eco);          {'percentual do eco'}
    formCampoInt ('MGMSREV',  pegaTextoMensagem('MGMSREV'),  mili_reverb);        {'milissegundos do reverber'}
    formCampoInt ('MGPERREV', pegaTextoMensagem('MGPERREV'), fator_reverb);       {'percentual do reverber'}
    formCampoInt ('MGMAXMEM', pegaTextoMensagem('MGMAXMEM'), maxMemoria);         {'memória em Mb (0=toda)'}
    formCampoInt ('MGNBUFT',  pegaTextoMensagem('MGNBUFT'),  nbufToca);           {'buffers para tocar'}
    formCampoInt ('MGNBUFG',  pegaTextoMensagem('MGNBUFG'),  nbufGrava);          {'buffers para gravar'}
    //formCampo    ('MGCNVMP3', pegaTextoMensagem('MGCNVMP3'), progFfmpeg  ,, 80);       {'conversão mp3'}
    formCampoInt ('MGQUALID', pegaTextoMensagem('MGQUALID'), rAmostra);       {'Qualidade do som, padrão 44100'}
    //formCampo    ('MGMP3OUT', pegaTextoMensagem('MGMP3OUT'), lame_out_cmd, 80);   {'parametros para ler mp3'}
    //formCampo    ('MGMP3IN',  pegaTextoMensagem('MGMP3IN'),  lame_in_cmd,  80);   {'parametros para gerar mp3'}
    formEdita(true);

    dist_eco := mili_eco * 10;
    dist_reverb := mili_reverb * 10;

    if dist_eco = 0 then dist_eco := DEF_DIST_ECO;
    if fator_eco = 0 then fator_eco := DEF_FATOR_ECO;
    if dist_reverb = 0 then dist_reverb := DEF_DIST_REVERB;
    if fator_reverb = 0 then fator_reverb := DEF_FATOR_REVERB;

    if (nbufToca  < 2) or (nbufToca  > 8) then nbufToca  := DEF_BUFTOCA;
    if (nbufGrava < 2) or (nbufGrava > 8) then nbufGrava := DEF_BUFGRAVA;

    som.maxMemoria := maxMemoria * 1024 * 1024;

    salvaParamConfig;

    if sintFalarTudo then
    begin
        sintBip;
        sintBip;
        sintBip;
    end;
    mensagem ('MGOKCONF', 2);    {'OK, configurado'}
end;

end.
