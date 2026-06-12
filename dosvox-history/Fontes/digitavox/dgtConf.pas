{-------------------------------------------------------------}
{
{       Digitavox - Rotinas de configuração
{
{       Autor: Neno Henrique da Cunha Albernaz
{              neno@intervox.nce.ufrj.br
{       Em 15de Março de 2020
{       * Boa parte reaproveitada da unit dosTec.pas do Dosvox.
{
{-------------------------------------------------------------}

unit dgtConf;

interface

uses
    windows, sysUtils, classes,
    miniReg, dvamplia,
    dvcrt, dvwin,
    dvForm, dvSapi, dvSapGlb,
    dgtTela, dgtAjuda, dgtUtil, dgtVars, dgtMsg;

procedure inicializarParametros;
procedure inicializarFala;
procedure configDigitavox;

implementation

uses
    mmSystem;

const
    booleanToStr: array [boolean] of string = ('NAO', 'SIM');

{-------------------------------------------------------------}
{                Inicializa os parâmetros globais
{-------------------------------------------------------------}

procedure inicializarParametros;
var
    s: string;
begin
    dirCursos := sintambiente ('DIGITAVOX', 'DIRCURSOS');
    if dirCursos = '' then
        begin
            dirCursos := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\Digitavox\Cursos';
            sintGravaAmbiente('DIGITAVOX', 'DIRCURSOS', dirCursos);
        end;
    dirUsuarios := sintambiente ('DIGITAVOX', 'DIRUSUARIOS');
    if dirUsuarios = '' then
        begin
            dirUsuarios := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\Digitavox\Usuarios';
            sintGravaAmbiente('DIGITAVOX', 'DIRUSUARIOS', dirUsuarios);
        end;
    dirRelatorios := sintambiente ('DIGITAVOX', 'DIRRELATORIOS');
    if dirRelatorios = '' then
        begin
            dirRelatorios := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\Digitavox\Relatorios';
            sintGravaAmbiente('DIGITAVOX', 'DIRRELATORIOS', dirRelatorios);
        end;

    s := sintambiente ('DIGITAVOX', 'COMEFEITOS');
    if s = '' then sintGravaAmbiente('DIGITAVOX', 'COMEFEITOS', 'SIM');
    comEfeitos := (upperCase(s) + 'S')[1] = 'S';
    s := sintambiente ('DIGITAVOX', 'FALARTECLA');
    if s = '' then sintGravaAmbiente('DIGITAVOX', 'FALARTECLA', 'SIM');
    falarTecla := (upperCase(s) + 'S')[1] = 'S';
    s := sintambiente ('DIGITAVOX', 'MODOTESTEATIVO');
    if s = '' then sintGravaAmbiente('DIGITAVOX', 'MODOTESTEATIVO', 'NAO');
    modoTesteAtivo  := (upperCase(s) + 'N')[1] = 'S';
end;

{-------------------------------------------------------------}
{       Inicializa o sintetizador
{-------------------------------------------------------------}

procedure inicializarFala;

var
    s,dirSons: string;
    comSapi: boolean;
    erro, velGeral, confTipoSapi, confNum, confVeloc, confTonal: integer;
begin
    dirSons := sintAmbiente ('DIGITAVOX', 'DIRDIGITAVOX');
    if dirSons = '' then
        begin
            dirSons := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\digitavox';
            sintGravaAmbiente('DIGITAVOX', 'DIRDIGITAVOX', dirSons);
        end;

    s := sintAmbiente('DIGITAVOX', 'SAPI');
    comSapi := uppercase(copy(s, 1, 1)) = 'S';

    s := sintAmbiente ('DIGITAVOX', 'VELOCIDADE');
    if s = '0' then s :=  trim (sintAmbiente ('TRADUTOR', 'VELOCIDADE'));
    val (s, velGeral, erro);
    if erro <> 0 then velGeral := 0;
    sintInic (velGeral, dirSons);
    if not comSapi then exit;

    val (sintAmbiente('DIGITAVOX', 'VOZSAPI'), confNum, erro);
    if erro <> 0 then exit;
    val (sintAmbiente('DIGITAVOX', 'TIPOSAPI'), confTipoSapi, erro);
    if erro <> 0 then exit;
    val (sintAmbiente('DIGITAVOX', 'VELOCIDADESAPI'), confVeloc, erro);
    if erro <> 0 then exit;
    val (sintAmbiente('DIGITAVOX', 'TONALIDADESAPI'), confTonal, erro);
    if erro <> 0 then exit;

    sintReinic (velGeral, comSapi, confTipoSapi, confNum, confVeloc, confTonal);
end;

{--------------------------------------------------------}
{       ajuda da configuração de Fala Gravada
{--------------------------------------------------------}

procedure ajudaFalaGravada;
begin
    writeln;
    mensagem ('DGTAJUCF_OPC', 1);   { 'As opções de fala gravada são: ' }
    mensagem ('DGTAJUCF_N',   1);   { '  N - velocidade normal' }
    mensagem ('DGTAJUCF_R',   1);   { '  R - voz mais rápida' }
    mensagem ('DGTAJUCF_B',   1);   { '  B - voz de boneca' }

    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}
{       seleciona opção de configuração de fala gravada
{--------------------------------------------------------}

function selSetasFalaGravada: char;
var n: integer;
const
    nOpFalaGrav = 3;
    tabLetrasFalaGravada: string [nOpFalaGrav] = 'nrb';

begin
    salvaXY;
    writeln;
    garanteEspacoTela (nOpFalaGrav);
    popupMenuCria (wherex, wherey, 27, nOpFalaGrav, MAGENTA);

    MenuAdiciona ('DGTAJUCF_N');    { '  N - velocidade normal' }
    MenuAdiciona ('DGTAJUCF_R');    { '  R - voz mais rápida' }
    MenuAdiciona ('DGTAJUCF_B');    { '  B - voz de boneca' }

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasFalaGravada := tabLetrasFalaGravada[n]
    else
        selSetasFalaGravada := ESC;
    restauraXY;
end;

{--------------------------------------------------------}
{       Configuração de fala gravada
{--------------------------------------------------------}

procedure configFalaGravada;

var
    c, c2:  char;
    erro,
    veloc:  integer;
    tratandoFalaGrav: boolean;
label
    fim;

begin
    val (sintAmbiente ('DIGITAVOX', 'VELOCIDADE'), veloc, erro);
    if erro <> 0 then veloc := 3;
    if not veloc in [3..5] then veloc := 3;

    telaPrincipal;
    textBackground (BLUE);
    writeln (pegaTextoMensagem('DGTCONF'));   { 'Digitavox - Configuração' }
    textBackground (BLACK);

    tratandoFalaGrav := true;
    while tratandoFalaGrav do
    begin
        writeln;
        textBackground (RED);
        mensagem ('DGTSEFGRA', 0);   { 'Selecione a velocidade da fala gravada: ' }
        textBackground (BLACK);

        pegaTeclado (false, c, c2);

        if (c = #0) and (c2 in [CIMA, BAIX, F9]) then
            c := selSetasFalaGravada;

        if c = #$1b then
            begin
                writeln;
                mensagem ('DGTOK', 1);      { 'Ok ! '}
                goto fim;
            end;

        if (c = GOTFOCUS) or (c = NOFOCUS) then
        else
        if (c = #0) and (c2 = F1) then
            ajudaFalaGravada
        else
        begin
            soletra (c, 1);
            tratandoFalaGrav := false;

            case upcase(c) of
                'N': veloc := 3;
                'R': veloc := 4;
                'B': veloc := 5;
            else
                mensagem ( 'DGTOPVINV', 1);  {'Opção inválida, aperte F1 para ajuda'}
                tratandoFalaGrav := true;
            end;
        end;
    end;

    sintGravaAmbiente ('DIGITAVOX', 'VELOCIDADE', intToStr(veloc));

    sintFim;
    inicializarFala;
fim:
    writeln;
end;

{--------------------------------------------------------}
{      monta as informações de uma voz para exibir
{--------------------------------------------------------}

procedure montaInformVoz (infoSapi: TInfoSapi; out nome, genero, idioma: string);

type
    TLCID = record
        code: string[5];
        number: integer;
        language: string;
    end;

const
    NLCID = 45;
    LCID: array [1..NLCID] of TLCID = (
        {English}                       (code: 'en';    number: $0009; language: 'inglês'),                     //9
        {English - Australia}           (code: 'en-au'; number: $0C09; language: 'inglês australiano'),         //3081
        {English - Belize}              (code: 'en-bz'; number: $2809; language: 'inglês belizenho'),           //10249
        {English - Canada}              (code: 'en-ca'; number: $1009; language: 'inglês canadense'),           //4105
        {English - Ireland}             (code: 'en-ie'; number: $1809; language: 'inglês irlandês'),            //6153
        {English - Jamaica}             (code: 'en-jm'; number: $2009; language: 'inglês jamaicano'),           //8201
        {English - New Zealand}         (code: 'en-nz'; number: $1409; language: 'inglês neozelandês'),         //5129
        {English - South Africa}        (code: 'en-za'; number: $1C09; language: 'inglês sul-africano'),        //7177
        {English - Trinidad}            (code: 'en-tt'; number: $2C09; language: 'inglês trinitino'),           //11273
        {English - United Kingdom}      (code: 'en-gb'; number: $0809; language: 'inglês britânico'),           //2057
        {English - United States}       (code: 'en-us'; number: $0409; language: 'inglês americano'),           //1033
        {French - Standard}             (code: 'fr';    number: $040C; language: 'francês'),                    //1036
        {French - Belgium}              (code: 'fr-be'; number: $080C; language: 'francês belga'),              //2060
        {French - Canada}               (code: 'fr-ca'; number: $0C0C; language: 'francês canadense'),          //3084
        {French - Luxembourg}           (code: 'fr-lu'; number: $140C; language: 'francês luxemburguês'),       //5132
        {French - Switzerland}          (code: 'fr-ch'; number: $100C; language: 'francês suíço'),              //4108
        {German - Standard}             (code: 'de';    number: $0407; language: 'alemão'),                     //1031
        {German - Austrian}             (code: 'de-at'; number: $0C07; language: 'alemão austríaco'),           //3079
        {German - Lichtenstein}         (code: 'de-li'; number: $1407; language: 'alemão liechtensteiniense'),  //5127
        {German - Luxembourg}           (code: 'de-lu'; number: $1007; language: 'alemão luxemburguês'),        //4103
        {German - Switzerland}          (code: 'de-ch'; number: $0807; language: 'alemão suíço'),               //2055
        {Italian - Standard}            (code: 'it';    number: $0410; language: 'italiano'),                   //1040
        {Italian - Switzerland}         (code: 'it-ch'; number: $0810; language: 'italiano suíço'),             //2064
        {Portuguese - Standard}         (code: 'pt';    number: $0816; language: 'português '),                 //2070
        {Portuguese - Brazil}           (code: 'pt-br'; number: $0416; language: 'português brasileiro'),       //1046
        {Spanish - Standard}            (code: 'es';    number: $040A; language: 'espanhol padrão'),            //1034
        {Spanish - Spain}               (code: 'es-es'; number: $0C0A; language: 'espanhol da Espanha'),        //3082
        {Spanish - Argentina}           (code: 'es-ar'; number: $2C0A; language: 'espanhol argentino'),         //11274
        {Spanish - Bolivia}             (code: 'es-bo'; number: $400A; language: 'espanhol boliviano'),         //16394
        {Spanish - Chile}               (code: 'es-cl'; number: $340A; language: 'espanhol chileno'),           //13322
        {Spanish - Columbia}            (code: 'es-co'; number: $240A; language: 'espanhol colombiano'),        //9226
        {Spanish - Costa Rica}          (code: 'es-cr'; number: $140A; language: 'espanhol costarriquenho'),    //5130
        {Spanish - Dominican Republic}  (code: 'es-do'; number: $1C0A; language: 'espanhol dominicano'),        //7178
        {Spanish - Ecuador}             (code: 'es-ec'; number: $300A; language: 'espanhol equatoriano'),       //12298
        {Spanish - Guatemala}           (code: 'es-gt'; number: $100A; language: 'espanhol quatemalteco'),      //4106
        {Spanish - Honduras}            (code: 'es-hn'; number: $480A; language: 'espanhol hondurenho'),        //18442
        {Spanish - Mexico}              (code: 'es-mx'; number: $080A; language: 'espanhol mexicano'),          //2058
        {Spanish - Nicaragua}           (code: 'es-ni'; number: $4C0A; language: 'espanhol nicaraguense'),      //19466
        {Spanish - Panama}              (code: 'es-pa'; number: $180A; language: 'espanhol panamenho'),         //6154
        {Spanish - Peru}                (code: 'es-pe'; number: $280A; language: 'espanhol peruano'),           //10250
        {Spanish - Puerto Rico}         (code: 'es-pr'; number: $500A; language: 'espanhol portorriquenho'),    //20490
        {Spanish - Paraguay}            (code: 'es-py'; number: $3C0A; language: 'espanhol paraguaio'),         //15370
        {Spanish - El Salvador}         (code: 'es-sv'; number: $440A; language: 'espanhol salvadorenho'),      //17418
        {Spanish - Uruguay}             (code: 'es-uy'; number: $380A; language: 'espanhol uruguaio'),          //14346
        {Spanish - Venezuela}           (code: 'es-ve'; number: $200A; language: 'espanhol venezuelano')        //8202
    );

const
    DELIM: char = ';';

var
    locale: string;
    i: integer;
begin
    nome := infoSapi.nomeVoz;
    if copy (nome, 1, 10) = 'Microsoft ' then
         delete (nome, 1, 10)
    else
    if copy (nome, 1, 9) = 'ScanSoft ' then
    begin
        delete (nome, 1, 9);
        if (pos('_', nome) <> 0) then delete (nome, pos('_', nome), 99);
    end
    else
    if pos ('male voice', nome) <> 0 then
        nome := infoSapi.modo;

    locale := 'Desconhecida';
    idioma := 'Desconhecida';
    for i := 1 to NLCID do
        if infoSapi.lingua = LCID[i].number then
        begin
            locale := LCID[i].code;
            idioma := LCID[i].language;
            break;
        end;

    // exceção: a voz Juliana não tem a informação registrada

    if nome = 'Juliana' then infoSapi.sexo := 1;

    case infoSapi.sexo of
        0: genero := 'Neutra';
        1: genero := 'Feminina';
        2: genero := 'Masculina';
    end;
end;

{--------------------------------------------------------}
{      monta tabela com as informações das vozes
{--------------------------------------------------------}

type
    PVozSapi = ^TVozSapi;
    TVozSapi = record
        tipoSAPI: integer;
        nVozSAPI: longint;
        nomeVoz:   string;
        generoVoz: string;
        idiomaVoz: string;
    end;

var
    tabVozesSAPI: TList;

{--------------------------------------------------------}

procedure montaTabelaDeVozes;
var
    sapiAtual, vozAtual, velocAtual, tonalAtual: integer;

    param: TParamVoz;
    infoSapi: TInfoSapi;
    umaVoz: PVozSapi;

    i, n, maxVozes, tipo: integer;
    salvaSapiPresente: boolean;
begin
    tabVozesSapi := TList.Create;

    sapiAtual := 0;
    vozAtual := 0;
    velocAtual := 0;
    tonalAtual := 0;

    salvaSapiPresente := sapiPresente;
    if sapiPresente then
        begin
            sapiPegaParam (param);
            sapiAtual := param.tipoSapi;
            vozAtual  := param.voz;
            velocAtual := param.velocidade;
            tonalAtual := param.tom;

            sapiFim;
            sapiPresente := false;
        end;

    new (umaVoz);        // insere a voz nativa
    umavoz.nomeVoz := 'Voz Nativa';
    umavoz.tipoSAPI := 0;
    umavoz.nVozSAPI := 0;
    umavoz.generoVoz := 'Masculino';
    umavoz.idiomaVoz := 'português brasileiro';
    tabVozesSAPI.Add(umaVoz);

    for i := 3 to 6 do
        begin
            if i = 6 then tipo := 54
                     else tipo := i;
            try
                sapiPresente := sapiInic (1, 0, 0, tipo, '');
            except
            end;

            if sapiPresente then
                begin
                    maxVozes := sapiNumVozes;    // mesmo que não inicialize numVozes contém o número correto
                    for n := 1 to maxVozes do
                        begin
                            new (umaVoz);
                            umavoz.tipoSAPI := tipo;
                            umavoz.nVozSAPI := n;
                            sapiInfo(n, infoSapi);
                            montaInformVoz (infoSapi, umavoz.nomeVoz, umavoz.generoVoz, umavoz.idiomaVoz);
                            tabVozesSAPI.Add(umaVoz);
                        end;
                    sapiFim;
            end;
        end;

    if salvaSapiPresente then
        sapiPresente := sapiInic (vozAtual, velocAtual, tonalAtual, sapiAtual, '')
    else
        begin
            sintFim;
            inicializarFala;
        end;
end;

{--------------------------------------------------------}
{                destroi a tabela de vozes
{--------------------------------------------------------}

procedure destroiTabVozes;
var i: integer;
    p: PVozSapi;
begin
    for i := 0 to tabVozesSAPI.Count-1 do
        begin
            p := tabVozesSAPI[i];
            dispose (p);
        end;

    tabVozesSAPI.Free;
end;

{--------------------------------------------------------}
{           escolhe o sintetizador com as setas
{--------------------------------------------------------}

function escolheSint: integer;   // retorna o número na tabela
var i, y, nitem: integer;
    c, c2: char;
    p: PVozSapi;
begin
    mensagem ('DGTUMMOME', 0);       { 'Um momento...' }
    gotoxy (1, wherey);
    while sintFalando do waitMessage;

    montaTabelaDeVozes;

    y := wherey;
    mensagem ('DGTSINTET', 1);   {'Sintetizador, use as setas para selecionar'}

    folheiaCria (1, wherey, 80, 24);
    for i := 0 to tabVozesSapi.count-1 do
        begin
            p := tabVozesSAPI[i];
            folheiaAdiciona(p^.nomeVoz + '; ' + p^.generoVoz + '; ' + p^.idiomaVoz);
        end;
    if folheiaExecuta(1, nitem, c, c2, true) then
        result := nitem-1
    else
        result := -1;

    folheiaDestroi;
    limpaBaixo (y);

    writeln;
    if (nitem >= 1) and (nItem < tabVozesSapi.count) then
        begin
            p := tabVozesSAPI[nitem-1];
            sintWriteln (p^.nomeVoz);
        end;

end;

{--------------------------------------------------------}
{                ativa a voz selecionada
{--------------------------------------------------------}

procedure ativaVoz (tipoSapi, nvoz: integer);
var
    veloc, velocSAPI, tonSAPI: integer;
    s: string;
    erro: integer;
begin
    s := trim (sintAmbiente ('DIGITAVOX', 'VELOCIDADE'));
    if s = '0' then s :=  trim (sintAmbiente ('TRADUTOR', 'VELOCIDADE'));
    val (s, veloc, erro);
    if erro <> 0 then veloc := 3;

    if tipoSapi = 0 then
        begin
            sintGravaAmbiente ('DIGITAVOX', 'SAPI', 'NÃO');
            sintReinic(veloc, false, 0, 0, 0, 0);
            exit;
        end;

    sintGravaAmbiente ('DIGITAVOX', 'SAPI', 'SIM');
    sintGravaAmbiente ('DIGITAVOX', 'TIPOSAPI', intToStr(tipoSapi));
    sintGravaAmbiente ('DIGITAVOX', 'VOZSAPI', intToStr(nvoz));

    if tipoSapi = 4 then
        begin
            velocSAPI := 220;
            tonSAPI := 110;
        end
    else
        begin
            velocSAPI := 0;
            tonSAPI := 0;
        end;

    sintGravaAmbiente ('DIGITAVOX', 'VELOCIDADESAPI', intToStr(velocSAPI));
    sintGravaAmbiente ('DIGITAVOX', 'TONALIDADESAPI', intToStr(tonSAPI));

    sintfim;
    inicializarFala;
end;

{--------------------------------------------------------}
{          configura velocidade e tonalidade
{--------------------------------------------------------}

procedure configVelocTomVoz (tipoSapi, vozSapi: integer);
var
    param: TParamVoz;
    minVeloc, maxVeloc, minTon, maxTon, velSapiPadrao, tonSapiPadrao: integer;
    velsapi, tonSapi: integer;
    veloc, erro: integer;
    s: string;
begin
    s := trim (sintAmbiente ('DIGITAVOX', 'VELOCIDADE'));
    if s = '0' then s :=  trim (sintAmbiente ('TRADUTOR', 'VELOCIDADE'));
    val (s, veloc, erro);
    if (erro <> 0) or (veloc < 3) or (veloc > 5) then veloc := 3;

    if tipoSapi = 4 then
        begin
            sapiPegaParam(param);
            minVeloc := param.minVeloc;
            maxVeloc := param.maxVeloc;
            minTon := param.minTom;
            maxTon := param.maxTom;
            velSapiPadrao := param.velocidade;
            tonSapiPadrao := param.tom;

            mensagem ('DGTVELOCS', 0);  {'Velocidade '}
            sintWrite ( intToStr(minVeloc) + ' a ' + intToStr(maxVeloc) + ': ');
            sintReadInt (velSapi);

            mensagem ('DGTTONALS', 0);  {'Tonalidade '}
            sintWrite (intToStr(minTon) + ' a ' + intToStr(maxTon) + ': ');
            sintReadInt (tonSapi);

            if (velSapi < minVeloc) or (velSapi > maxVeloc) then
                  velSapi := velSapiPadrao;
            if (tonSapi < minTon) or (tonSapi > maxTon)  then
                  tonSapi := tonSapiPadrao;
        end
    else
        begin
            mensagem ('DGTAJUCS_V', 0);  {'Velocidade (-10 a 10) '}
            sintReadInt (velSapi);
            mensagem ('DGTAJUCS_T', 0);  {'Tonalidade (-10 a 10) '}
            sintReadInt (tonSapi);

            if (velSapi < -10) or (velSapi > 10) then velSapi := 0;
            if (tonSapi < -10) or (tonSapi > 10) then tonSapi := 0;
        end;

    sintGravaAmbiente ('DIGITAVOX', 'VELOCIDADESAPI', intToStr(velSapi));
    sintGravaAmbiente ('DIGITAVOX', 'TONALIDADESAPI',        intToStr(tonSapi));

    sintReinic (veloc, true, tipoSapi, vozSapi, velSapi, tonSapi);
end;

{--------------------------------------------------------}
{            exibe dados do sintetizador atual
{--------------------------------------------------------}

procedure mostraSintetizadorAtual;
var
    paramVozAtual: TParamVoz;
    infoSapi: TInfoSAPI;
begin
    mensagem ('DGTAJUCS_SINT', 0);  { 'Sintetizador ativado: ' }

    sapiPegaParam(paramVozAtual);
    sapiInfo(paramVozAtual.voz, infoSapi);
    sintWriteln (infoSapi.nomeVoz);

    mensagem ('DGTVELOCS', 0); {'Velocidade '}
    sintWriteint (paramVozAtual.velocidade);
    writeln;
    mensagem ('DGTTONALS', 0); {'Tonalidade '}
    sintWriteint (paramVozAtual.tom);
    writeln;
end;

{--------------------------------------------------------}
{            escolhe uma nova voz com as setas
{--------------------------------------------------------}

procedure escolheNovaVoz;
var p: PVozSapi;
    nVozEscolhida: integer;
begin
    tabVozesSAPI := TList.Create;

    nVozEscolhida := escolheSint;
    if nVozEscolhida < 0 then
        mensagem ('DGTAJUCS_NAO', 1)   { 'Voz não encontrada' }
    else
        begin
            p := tabVozesSapi[nVozEscolhida];
            ativaVoz (p^.tipoSAPI, p^.nVozSAPI);
            if nVozEscolhida <> 0 then
                configVelocTomVoz (p^.tipoSAPI, p^.nVozSAPI);
        end;

    destroiTabVozes;
end;

{--------------------------------------------------------}
{                configuração de fala sintetizada
{--------------------------------------------------------}

procedure configFalaSintetizada;
var
    c: char;
    paramVozAtual: TParamVoz;

begin
    telaPrincipal;
    textBackground (BLUE);
    writeln (pegaTextoMensagem('DGTCONF')); {'Digitavox - Configuração'}
    textBackground (BLACK);
    writeln;

    mensagem ('DGTAJUCS_SIN', 2);     {'Configurações de fala sintetizada'}

    if not sapiPresente then
        mensagem ('DGTAJUCS_NAT',  2)   { 'Fala nativa ativada' }
    else
        mostraSintetizadorAtual;

    mensagem ('DGTCONFIRMA', 0);    {'Confirma? '}
    mensagem ('DGTSIMNAO', 0);      {' (S/N)? '}
    c := popupMenuPorLetra('SN');
    if (c = ESC) then exit;

    writeln;
    if c = 'N' then
        escolheNovaVoz
    else
        begin
            if sapiPresente then
                begin
                    sapiPegaParam(paramVozAtual);
                    configVelocTomVoz (paramVozAtual.tipoSapi, paramVozAtual.voz);
                end;
        end;

    writeln;
    if not sapiPresente then
        mensagem ('DGTAJUCS_NAT',  2)   { 'Fala nativa ativada' }
    else
        mostraSintetizadorAtual;

    writeln;
end;

{-------------------------------------------------------------}
{                Outras configurações
{-------------------------------------------------------------}

procedure outrasConfiguracoes;
var
    velGeral, erro: integer;
    s: string;
begin
    telaPrincipal;
    textBackground (BLUE);
    mensagem ('DGTCONFAV', 1); {'Digitavox - Configuração avançada'}
    writeln;

    s := trim(sintAmbiente ('DIGITAVOX', 'VELOCIDADE'));
    if s = '' then s := '0';
    val (s, velGeral, erro);
    if erro <> 0 then velGeral := 0;

    formCria;
    tamRotulosForm := tamRotulosForm + 5;
    formCampoInt  ('DGTVELFAL', pegaTextoMensagem('DGTVELFAL'), velGeral); {'Velocidade de fala de 3 a 5'}
    formCampoBool ('DGTCOMEFE', pegaTextoMensagem ('DGTCOMEFE'), comEfeitos);  {'Com efeito'}
    formCampoBool ('DGTFALTEC', pegaTextoMensagem ('DGTFALTEC'), falarTecla);  {'Falar tecla'}
    formEdita (true);
    tamRotulosForm := tamRotulosForm - 5;

    if (velGeral < 3) or (velGeral> 5) then velGeral := 0;
    sintGravaAmbiente('DIGITAVOX', 'VELOCIDADE', intToStr(velGeral));
    if velGeral = 0 then sintGravaAmbiente ('DIGITAVOX', 'SAPI', 'NÃO');
    sintGravaAmbiente('DIGITAVOX', 'COMEFEITOS', booleanToStr[comEfeitos]);
    sintGravaAmbiente('DIGITAVOX', 'FALARTECLA', booleanToStr[falarTecla]);

    sintFim;
    inicializarFala;
    while keypressed do readkey;
    msgBaixo ('DGTFIMCFG');   {'Fim da configuração'}
end;

{--------------------------------------------------------}
{                Recupera configuração original
{--------------------------------------------------------}

procedure recuperaConfigOriginal;
var
    c: char;
begin
    telaPrincipal;
    repeat
        mensagem ('DGTDESRECCONF', 0);   {'Deseja recuperar a configuração original de instalação?'}
        c := popupMenuPorLetra('SN');
        writeln;
        if not (c in ['S', 'N', ESC]) then
            mensagem ('DGTAJUTIL', 1);  {'  Pode usar as setas para selecionar ou conhecer todas as opções'}
    until c in ['S', 'N',ESC];

    if c in ['N', ESC] then
        begin
            mensagem ('DGTDESIST', 1);     {'Desistiu...'}
            exit;
        end;

    sintGravaAmbiente('DIGITAVOX', 'DIRDIGITAVOX', '@\som\digitavox');
    sintGravaAmbiente('DIGITAVOX', 'DIRCURSOS', '@\Digitavox\Cursos');
    sintGravaAmbiente('DIGITAVOX', 'DIRUSUARIOS', '@\Digitavox\Usuarios');
    sintGravaAmbiente('DIGITAVOX', 'DIRRELATORIOS', '@\Digitavox\Relatorios');
    sintGravaAmbiente('DIGITAVOX', 'COMEFEITOS', 'SIM');
    sintGravaAmbiente('DIGITAVOX', 'FALARTECLA', 'SIM');
    sintGravaAmbiente('DIGITAVOX', 'MODOTESTEATIVO', 'Nao');
    sintGravaAmbiente('DIGITAVOX', 'VELOCIDADE', '0');
    sintGravaAmbiente('DIGITAVOX', 'SAPI', 'NÃO');
    sintGravaAmbiente('DIGITAVOX', 'TIPOSAPI', '5');
    sintGravaAmbiente('DIGITAVOX', 'VOZSAPI', '1');
    sintGravaAmbiente('DIGITAVOX', 'VELOCIDADESAPI', '0');
    sintGravaAmbiente('DIGITAVOX', 'TONALIDADESAPI', '0');

    sintFim;
    inicializarFala;
    inicializarParametros;
    mensagem ('DGTOK', 1);     {'Ok'}
end;

{--------------------------------------------------------}
{       ajuda da configuração do Digitavox
{--------------------------------------------------------}

procedure ajudaConfig;
begin
    writeln;
    mensagem ('DGTAJUC_OPC', 1);    {'As opções de configuração são:'}
    mensagem ('DGTAJUC_F',   1);    { '  F - Fala gravada' }
    mensagem ('DGTAJUC_S',   1);    { '  S - Fala sintetizada' }
    mensagem ('DGTAJUC_O', 1);    { '  O - outras configurações' }
    mensagem ('DGTAJUC_O', 1);    { '  O - outras configurações' }
    mensagem ('DGTAJUC_R', 1);    { '  R - recuperar configuração original' }

    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}
{       seleciona opção de configuração do Digitavox
{--------------------------------------------------------}

function selSetasConfig: char;
var n: integer;
const
    nOpConfig = 4;
    tabLetrasConfig: string [nOpConfig] = 'fsor';

begin
    salvaXY;
    writeln;
    garanteEspacoTela (nOpConfig);
    popupMenuCria (wherex, wherey, 53, nOpConfig, MAGENTA);

    MenuAdiciona ('DGTAJUC_F');   { '  F - fala gravada' }
    MenuAdiciona ('DGTAJUC_S');   { '  S - fala sintetizada' }
    MenuAdiciona ('DGTAJUC_O');   { '  O - outras configurações' }
    MenuAdiciona ('DGTAJUC_R');   { '  R - recuperar configuração original' }

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasConfig := tabLetrasConfig[n]
    else
        selSetasConfig := ESC;
    restauraXY;
end;

{--------------------------------------------------------}
{                configuração
{--------------------------------------------------------}

procedure configDigitavox;
var
    c, c2: char;
    tratandoConfig: boolean;
label
    fim;

begin
    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('DGTDICONF')); {'Digitavox - Configuração'}
    textBackground (BLACK);

    tratandoConfig := true;
    while tratandoConfig do
        begin
            writeln;
            textBackground (RED);
            mensagem ('DGTCONFIG', 0);      { 'Configurações - ' }
            mensagem ('DGTOQUE', 0);            { 'O que você deseja ? ' }
            textBackground (BLACK);

            pegaTeclado (false, c, c2);

            if (c = #0) and ( c2 in [CIMA, BAIX, F9]) then
                c := selSetasConfig;

            if c = #$1b then
                begin
                    writeln;
                    mensagem ('DGTOK', 1);      { 'Ok'}
                    goto fim;
                end;

            if (c = GOTFOCUS) or (c = NOFOCUS) then
            else
            if (c = #0) and (c2 = F1) then
                ajudaConfig
            else
                begin
                    if falarTecla then soletra (c, 1);
                    writeln;
                    tratandoConfig := false;

                    case upcase(c) of
                        'F': configFalaGravada;
                        'S': configFalaSintetizada;
                        'O': outrasConfiguracoes;
                        'R': recuperaConfigOriginal;
                    else
                         mensagem ('DGTOPVINV', 1);     {'Opção inválida, aperte F1 para ajuda' }
                         tratandoConfig := true;
                    end;
                end;
        end;
fim:
    writeln;
end;

{--------------------------------------------------------}

begin
end.
