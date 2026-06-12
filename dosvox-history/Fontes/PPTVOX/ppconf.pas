Unit ppConf;

interface

uses dvCrt, dvWin, dvForm,
    windows, winprocs, wintypes, sysUtils, mmsystem,
    ppArq, ppEstilo, ppAuto, ppMsg, ppVars;

procedure configuraPPT;
procedure tocaArqSom (comando, nomeDisp: string);

implementation

{--------------------------------------------------------}

procedure configuraPPT;
var confNomEst, confSlides, confLinhas, confSlideInic, confSlideFim, confLinhaFim: shortString;
    confAuto, confFonteTit, confFonteLin, confTamTit, confTamLin: shortString;
    confFigFun, confCorLet: shortString;
    confDirTrab, confPlayer: shortString;
    erro: integer;
    opcao: char;
begin

    //Recuperando informações

    confNomEst:= nomeEstilo;
    confFigFun:= figuraDeFundo;
    confCorLet:= corLetra;
    confFonteTit:= f_tit;
    confFonteLin:= f_lin;
    confTamTit:= intToStr(t_tit);
    confTamLin:= intToStr(t_lin);
    confSlides:= trocSlides;
    confLinhas:= trocLinhas;
    confSlideInic:= primSlide;
    confSlideFim:= ultSlide;
    confLinhaFim:= ultLinha;
    confAuto:= 'NÃO';
    confDirTrab:= dirEstilos;
    confPlayer:= e_player;

    if pos ('.', confNomEst) <> 0 then
        delete (confNomEst, pos ('.', confNomEst), length (confNomEst));

    textBackground (BLUE);
    writeln;
    mensagem ('PPMSGEFE', 1); {('Configurando');}
    textBackground (BLACK);
    sintSom ('PPPAICON');

    garanteEspacoTela(20);
    formCria;

    formCampo    ('PPNOMEST', 'Estilo: ', confNomEst, 200);
    formCampo    ('PPFIGFUN', 'Figura de fundo: ', confFigFun, 200);
    formCampo    ('PPCORLET', 'Cor da letra: ', confCorLet, 200);
    formCampo    ('PPFONTIT', 'Fonte título: ', confFonteTit, 200);
    formCampo    ('PPFONLIN', 'Fonte linha: ', confFonteLin, 200);
    formCampo    ('PPTAMTIT', 'Tamanho título: ', confTamTit, 200);
    formCampo    ('PPTAMLIN', 'Tamanho linha: ', confTamLin, 200);
    formCampo    ('PPAUTOM', 'Automatizar: ', confAuto, 200);
    formCampo    ('PPDIRTRB', 'Dir. trabalho: ', confDirTrab, 200);
    formCampo    ('PPINDPLAY', 'Player: ', confPlayer, 200);
    formCampo    ('PPTROSLD', 'Troca de slides: ', confslides, 200);
    formCampo    ('PPTROLIN', 'Troca de linhas: ', confLinhas, 200);
    formCampo    ('PPULTLIN', 'Última linha: ', confLinhaFim, 200);
    formCampo    ('PPPRISLI', 'Primeiro slide: ', confSlideInic, 200);
    formCampo    ('PPULTSLI', 'Último slide: ', confSlideFim, 200);

    formEdita (true);

    if not existeArq(trim(confFigFun)) then
    begin
        sintBip; sintBip;
        writeln;
        mensagem ('PPASSPAD', 1); {('Figura de fundo inexistente, assumirei o padrão');}
        writeln;
        confFigFun:= fundoPadrao;
    end
    else
    figuraDeFundo:= confFigFun;

    corLetra:= confCorLet;
    f_tit:= confFonteTit;
    f_lin:= confFonteLin;
    val (confTamTit, t_tit, erro);
    if erro <> 0 then t_tit:= 36;
    val (confTamLin, t_lin, erro);
    if erro <> 0 then t_lin:= 24;

    trocSlides:= confSlides;
    trocLinhas:= confLinhas;
    primSlide:= confSlideINic;
    ultSlide:= confSlideFim;
    ultLinha:= confLinhaFim;

    if (confDirTrab <> '') and (pos('\', confDirTrab) <> 0) then
    begin
        dirEstilos:= confDirTrab;
        if not trocaDir(dirEstilos) then
            dirEstilos:= 'c:\winvox\PPTVOX';
    end;

    if confPlayer <> '' then
        e_player:= confPlayer;

    writeln;
    mensagem ('PPDESDIS', 0); {('Deseja salvar em disco ? ');}
    opcao:= sintReadkey;
    writeln (opcao);

    if upcase(opcao) = 'S' then
    begin

        sintGravaAmbiente ('PPTVOX', 'FIGURADEFUNDO', maiuscAnsi(confFigFun));
        sintGravaAmbiente ('PPTVOX', 'CORDALETRA',    maiuscAnsi(confCorLet));
        sintGravaAmbiente ('PPTVOX', 'TROCADESLIDES', maiuscAnsi(confSlides));
        sintGravaAmbiente ('PPTVOX', 'TROCADELINHAS', maiuscAnsi(confLinhas));
        sintGravaAmbiente ('PPTVOX', 'PRIMEIROSLIDE', maiuscAnsi(confSlideInic));
        sintGravaAmbiente ('PPTVOX', 'ULTIMOSLIDE',   maiuscAnsi(confSlideFim));
        sintGravaAmbiente ('PPTVOX', 'ULTIMALINHA',   maiuscAnsi(confLinhaFim));
        sintGravaAmbiente ('PPTVOX', 'FONTETITULO',   maiuscAnsi(confFonteTit));
        sintGravaAmbiente ('PPTVOX', 'FONTELINHA',    maiuscAnsi(confFonteLin));
        sintGravaAmbiente ('PPTVOX', 'TAMTITULO',     maiuscAnsi(confTamTit));
        sintGravaAmbiente ('PPTVOX', 'TAMLINHA',      maiuscAnsi(confTamLin));

        sintGravaAmbiente ('PPTVOX', 'DIRPADRAO', maiuscAnsi(dirEstilos));
        sintGravaAmbiente ('PPTVOX', 'PLAYER',    maiuscAnsi(e_player));

        delay (100);
        mensagem ('PPOK', 1);
        delay (100);

        novoNomeEstilo:= confNomEst;
        criaEstilo;
    end
    else
        mensagem ('PPDESIST', 1);

    if pos ('.', trocSlides) <> 0 then
        delete (trocSlides, pos ('.', trocSlides), length (trocSlides));
    if pos ('.', trocLinhas) <> 0 then
        delete (trocLinhas, pos ('.', trocLinhas), length (trocLinhas));
    if pos ('.', primSlide) <> 0 then
        delete (primSlide, pos ('.', primSlide), length (primSlide));
    if pos ('.', ultSlide) <> 0 then
        delete (ultSlide, pos ('.', ultSlide), length (ultSlide));
    if pos ('.', ultLinha) <> 0 then
        delete (ultLinha, pos ('.', ultLinha), length (ultLinha));

    if upcase (confAuto[1]) = 'S' then
    begin
        sintBip; sintBip;
        defineTempo;
    end;

    clrscr;
    limpaBufTec;

end;

{--------------------------------------------------------}

procedure tocaArqSom (comando, nomeDisp: string);
var ret : longInt;
    i : integer;

Function EnviaComandoMCI (cmd : string) : LongInt;
var comando: array [0..127] of char;
    erro: longint;
    retorno: array [0..255] of char;
begin

    strPCopy (comando, cmd);
    erro := mciSendString(comando, retorno, 127, 0);
    EnviaComandoMCI := erro;
    keypressed;

end;

{--------------------------------------------------------}

begin

//    nomeDisp:= '"' + nomeDisp + '"';

    for i:= 1 to length(comando) do
    comando[i]:= upcase(comando[i]);

    if comando = 'TOCAR' then
    begin
        ret := enviaComandoMCI ('open ' + nomedisp + ' alias disp1');
        if ret > 0 then;
        ret := enviaComandoMCI ('play disp1 from 1');
        if ret > 0 then;
    end;

    if comando = 'PARAR' then
    begin
        ret:= enviaComandoMCI ('stop disp1');
        if ret > 0 then;
        ret:= enviaComandoMCI ('close disp1');
        if ret > 0 then;
    end;

    if comando = 'PAUSAR' then
    begin
        ret:= enviaComandoMCI ('pause disp1');
        if ret > 0 then;
        readKey;
        ret := enviaComandoMCI ('play disp1');
        if ret > 0 then;
    end;

end;

end.
