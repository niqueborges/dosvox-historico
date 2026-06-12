Unit cdConfig;

interface

uses dvCrt, dvWin, dvForm,
    windows, sysUtils,
    cdVars, cdMsg, cdUtil;

procedure ajustarSaida;
function  primeiraLetra (s: string): char;

implementation

const
    booleanToStr: array [boolean] of string = ('NAO', 'SIM');

{--------------------------------------------------------}

function primeiraLetra (s: string): char;
begin
    result := upcase((trim(s)+' ')[1]);
end;

{--------------------------------------------------------}

procedure ajustarSaida;
var
    confPontua, confAvi,  confSil, confEfeit, confCabec, confSapi: boolean;
confMP3, confCD, confDir: shortString;
    confLinha, erro: integer;
    frase: string;
    opcao: char;
label novosValores, fim;
begin

    //Recuperando informações do DOSVOX.INI

    confPontua := upcase(sintAmbiente('CDMP3', 'SINTETIZARPONTUACAO', 'NAO')[1]) = 'S';
    confMP3  := sintAmbiente('CDMP3', 'QUALIDADEMP3', 'A');
    confCD  := sintAmbiente('CDMP3', 'CD', 'D');
    confDir  := dirSom;
    confAvi:= informa_avisos;
    confSil:= introduz_silencio;
    confEfeit:= upcase(sintAmbiente ('CDMP3', 'COMEFEITO', 'SIM')[1]) = 'S';
    confCabec:= introduz_cabec;
    val (sintAmbiente('CDMP3', 'QUEBRARLINHA', '100'), confLinha, erro);
    if erro <> 0 then confLinha:= 100;
    confSapi  := upcase(sintAmbiente('CDMP3', 'ALTERARSINTESE', 'NAO')[1]) = 'S';
    val (sintAmbiente('CDMP3', 'TIPOSAPI', '3'), confTipoSapi, erro);
    if erro <> 0 then val (sintAmbiente('SERVFALA', 'TIPOSAPI'), confTipoSapi, erro);
    if erro <> 0 then confTipoSapi := 3;
    val (sintAmbiente('CDMP3', 'NUMEROSAPI', '1'), confNum, erro);
    if erro <> 0 then confNum:= 1;
    val (sintAmbiente('CDMP3', 'VELOCIDADESAPI', '0'), confVeloc, erro);
    if erro <> 0 then confVeloc:= 0;
    val (sintAmbiente('CDMP3', 'TONALIDADESAPI', '0'), confTonal, erro);
    if erro <> 0 then confTonal:= 0;
    proglame  := sintAmbiente('CDMP3', 'PROG_LAME', pegaDirDosvox + 'lame.exe');

    // Apresentando o formulário

    novosValores:

    textBackground (BLUE);
    writeln;
    mensagem ('CDAJUSTE', 1); {'Ajustes de saída'}
    textBackground (BLACK);

    sintBip; sintBip;

    garanteEspacoTela(16);
    tamRotulosForm := 38;
    formCria;
    formCampoBool ('CDSINPON', 'Sintetizar pontuação : ', confPontua);
    formCampo    ('CDQUAMP3', 'Qualidade do MP3 (alta ou baixa) : ', confMP3, 1);
    formCampo    ('CDUNIDCD', 'Unidade do CD : ', confCD, 1);
    formCampo    ('CDDIRAUD', 'Diretório de audio : ', confDir, 28);
    formCampoBool ('CDATIAVI', 'Ativar avisos : ', confAvi);
    formCampoBool ('CDINTSIL', 'Introduzir silêncio : ', confSil);
    formCampoBool ('CDINTEFE', 'Introduzir efeito : ', confEfeit);
    formCampoBool ('CDINTCAB', 'Introduzir cabeçalho : ', confCabec);
    formCampoInt ('CDLINARQ', 'Linhas por arquivo : ', confLinha);
    formCampoBool ('CDCOMSAP', 'Alterar síntese (sim ou não) : ', confSapi);
    formCampoInt ('CDTIPSAP', 'Tipo SAPI (3, 4 ou 5) : ', confTipoSapi);
    formCampoInt ('CDNUMSAP', 'Número SAPI : ', confNum);
    formCampoInt ('CDVELSAP', 'Velocidade SAPI : ', confVeloc);
    formCampoInt ('CDTONSAP', 'Tonalidade SAPI : ', confTonal);
    formCampo    ('CDGERMP3', 'Gerador de MP3 : ', proglame, 144);
    formEdita (true);

    //Efetuando modificações

    sintFalaPont:= confPontua;
//    if primeiraLetra (confMP3) = 'B' then
//        qualidaMp3:= '-f'
//    else
//        qualidaMp3:= '-h';

    if primeiraLetra (confMP3) = 'B' then
        qualidaMp3:= qBaixa
    else
    if primeiraLetra (confMP3) = 'M' then
        qualidaMp3:= qMaxima
    else
        qualidaMp3:= qAlta;

    unidadeCD := copy(confCD, 1, 1);

    informa_avisos:= confAvi;
    introduz_silencio:= confSil;

    if (nomeEfeitoWav = '') or (not fileExists (nomeEfeitoWav)) then confEfeit := false;
    introduz_efeito:= confEfeit;
    if sapiOK and (confTipoSapi = 4) then introduz_efeito:= false; //Neno temporariamente enquanto SAPI 4 não grava com efeito.
    introduz_cabec:= confCabec;

    if confDir <> '' then
        dirSom:= confDir
    else
        dirSom:= 'WAVMP3';

    if confLinha <= 0 then confLinha:= 100;
    numLinhas:= confLinha;

    if proglame = '' then
        proglame := pegaDirDosvox + 'lame.exe';

    // gravando DOSVOX.INI

    sintGravaAmbiente('CDMP3', 'SINTETIZARPONTUACAO', booleanToStr[confPontua]);
    sintGravaAmbiente ('CDMP3', 'QUALIDADEMP3', confMP3);
    sintGravaAmbiente ('CDMP3', 'CD', confCD);
    sintGravaAmbiente ('CDMP3', 'CLEK', booleanToStr[confAvi]);
    sintGravaAmbiente ('CDMP3', 'COMSILENCIO', booleanToStr[confSil]);
    sintGravaAmbiente ('CDMP3', 'COMEFEITO', booleanToStr[confEfeit]);
    sintGravaAmbiente ('CDMP3', 'ESCREVECABEC', booleanToStr[confCabec]);
    sintGravaAmbiente ('CDMP3', 'QUEBRARLINHA', intToStr(confLinha));
    sintGravaAmbiente ('CDMP3', 'ALTERARSINTESE', booleanToStr[confSapi]);
    sintGravaAmbiente ('CDMP3', 'TIPOSAPI', intToStr(confTipoSapi));
    sintGravaAmbiente ('CDMP3', 'NUMEROSAPI', intToStr(confNum));
    sintGravaAmbiente ('CDMP3', 'VELOCIDADESAPI', intToStr(confVeloc));
    sintGravaAmbiente ('CDMP3', 'TONALIDADESAPI', intToStr(confTonal));
    sintGravaAmbiente ('CDMP3', 'PROG_LAME', proglame);

    writeln;
    mensagem ('CDAGUARD', 1); {'Aguarde por favor'}

    sapiOK := confSapi;
    if sapiOK then
    begin
        sintPara;
        delay (250);
        sintReinic (velocidadeDOSVOX, sapiOK, confTipoSapi, confNum, confVeloc, confTonal);
        delay (250);
        alterouSAPI:= true;
    end;

    sintBip; sintBip;

    if sapiOK then
    begin
            mensagem ('CDAJUSAP', 1); {'Ajuste da voz SAPI'}
            mensagem ('CDDIGFRA', 1); {'Digite uma frase ou pressione ENTER para que eu possa testar'}
            frase:= 'AJUSTE SAPI: TESTE - "Irei converter os arquivos utilizando esse padrão" -';
            opcao:= sintEditaCampo (frase, 1, wherey, 255, 80, true);
            if opcao <> ESC then
                sintetiza (frase)
            else
            goto fim;
            writeln;
            mensagem ('CDDESALT', 0); {'Deseja alterar essa voz (sim ou não) ? '}
            opcao:= popupMenuPorLetra ('SN');
            if upcase(opcao) = 'S' then
                goto novosValores;
        end;

    fim:

    sapiOK:= sapiPresente;
    mensagem ('CDOKAJUS', 1); {'OK, ajustado'}

    if alterouSAPI then
        begin
            sintFim;
            SintInic (0, sintAmbiente('CDMP3', 'DIRCDMP3'));
        end;
end;

{--------------------------------------------------------}

begin
end.
