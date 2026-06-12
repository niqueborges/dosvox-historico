{-------------------------------------------------------------}
{
{    Programa de controle do servidor de fala SAPI
{
{    Autor: Jose' Antonio Borges
{
{    Em 24/02/2001
{
{-------------------------------------------------------------}

program sapiUtil;
uses
  dvCrt,
  dvExec,
  dvWin,
  dvsapi,
  dvsapglb,
  dvForm,
  windows,
  sysutils,
  classes,
  sapiMsg;

var
    ambiente: string;

{-------------------------------------------------------------}
{                ativa uma voz pelos parâmetros
{-------------------------------------------------------------}

procedure ativaFalaParam (param: TParamVoz);
begin
    sintGravaAmbiente ('TRADUTOR', 'SAPI',       'SIM');
    sintGravaAmbiente ('SERVFALA', 'TIPOSAPI',   intToSTR(param.tiposapi));
    sintGravaAmbiente ('SERVFALA', 'VOZ',        intToStr(param.voz));
    sintGravaAmbiente ('SERVFALA', 'VELOCIDADE', intToStr(param.velocidade));
    sintGravaAmbiente ('SERVFALA', 'TOM',        intToStr(param.tom));

    sintFim;
    sintInic (0, ambiente);
    sapiPresente := false;
end;

{-------------------------------------------------------------}
{              informa quantas vozes instaladas
{-------------------------------------------------------------}

procedure quantasVozesInstaladas;
begin
    mensagem ('SAVOINST', 0);    // 'Vozes instaladas: '
    sintWriteint (sapiNumVozes);
    writeln;
end;

{-------------------------------------------------------------}
{       informaçoes sobre a voz atualmente selecionada
{-------------------------------------------------------------}

procedure infoVozAtual;
var param: TParamVoz;
    paramSapi: TInfoSapi;
    s1, s2: string;
begin
    sapiPegaParam (param);
    sapiInfo (param.voz, paramSAPI);

    mensagem ('SAVOZ', 0);    // 'Voz '
    sintWriteint (param.voz);
    writeln;

    sintWriteln (paramSapi.nomeVoz);
    if paramSapi.tipoSapi = 4 then
        sintWriteln (paramSapi.modo);

    mensagem ('SAVELOC', 0);    // 'Velocidade '
    sintWriteint (param.velocidade);
    str (param.minveloc, s1);
    str (param.maxveloc, s2);
    mensagem ('SACONF', 0);    // ' configurável entre '
    sintWriteln (s1 + pegaTextoMensagem ('SA_E') + s2);

    mensagem ('SATONAL', 0);    // 'Tonalidade '
    sintWriteint (param.tom);
    str (param.mintom, s1);
    str (param.maxtom, s2);
    mensagem ('SACONF', 0);    // ' configurável entre '
    sintWriteln (s1 + pegaTextoMensagem ('SA_E') + s2);
end;

{-------------------------------------------------------------}
{                 dá detalhes sobre a voz atual
{-------------------------------------------------------------}

procedure detalhesVozAtual;
var param: TParamVoz;
    paramSapi: TInfoSapi;
begin
    sapiPegaParam (param);
    sapiInfo (param.voz, paramSAPI);

    with paramSAPI do
        begin
            mensagem ('SANOMVOZ', 0);    // 'Nome da voz      '
            sintWriteln (nomevoz);
            mensagem ('SALINGUA', 0);    // 'Código da Língua '
            sintWriteint (lingua);
            writeln;
            mensagem ('SADIALET', 0);    // 'Dialeto          '
            sintWriteln (dialeto);
            mensagem ('SAMODO',   0);    // 'Modo             '
            sintWriteln (modo);
            mensagem ('SAFABRIC', 0);    // 'Fabricante       '
            sintWriteln (produtor);
            mensagem ('SAPROD',   0);    // 'Produto          '
            sintWriteln (produto);
            mensagem ('SAESTILO', 0);    // 'Estilo           '
            sintWriteln (estilo);
        end;
end;

{-------------------------------------------------------------}
{                      configura voz atual
{-------------------------------------------------------------}

procedure configuraVozAtual;
var param: TParamVoz;
    paramSapi: TInfoSapi;
begin
    sapiPegaParam (param);
    sapiInfo (param.voz, paramSAPI);

    mensagem ('SAPREENC', 1);    // 'Preencha os dados da voz depois tecle escape'
    garanteEspacoTela(4);
    formCria;
    with param do
        begin
            formCampoInt ('SAVOZ',   pegaTextomensagem ('SAVOZ'),   voz);          // 'Voz'
            formCampoInt ('SAVELOC', pegaTextomensagem ('SAVELOC'), velocidade);   // 'Velocidade'
            formCampoInt ('SATONAL', pegaTextomensagem ('SATONAL'), tom);          // 'Tonalidade'
        end;
    formEdita (true);

    mensagem ('SACONFIG', 1);    // 'Configurando o servidor'
    ativaFalaParam (param);
end;

{-------------------------------------------------------------}
{                seleciona voz interativamente
{-------------------------------------------------------------}

procedure folheiaVoz;
var
    param: TParamVoz;
    paramSapi: TInfoSapi;
    n, maxVozes: integer;
    c, c2: char;
    listaNomes: TStringList;
    salvay: integer;
    maxMostra: integer;
begin
    sapiPegaParam (param);
    mensagem ('SAUSESET', 2);    // 'Use as setas para selecionar uma voz, Enter confirma, ESC cancela'
    maxVozes := sapiNumVozes;
    n := 0;
    listaNomes := TStringList.Create;

    maxMostra := maxVozes;
    if maxMostra > 20 then maxMostra := 20;
    garanteEspacoTela (maxMostra);
    salvay := wherey;

    folheiaCria (1, wherey, 80, wherey+maxMostra-1);
    for n := 1 to maxVozes do
        begin
            sapiInfo (n, paramSapi);
            if sapiTipo = 4 then
                folheiaAdiciona (intToStr(n) + ' ' + paramSapi.modo)
            else
                folheiaAdiciona (intToStr(n) + ' ' + paramSapi.nomeVoz);
        end;
    folheiaExecuta (1, n, c, c2, true);
    folheiaDestroi;

    if (c = ESC) or (n = 0) or (n > maxVozes) then
        begin
            listaNomes.Free;
            clrscr;
            exit;
        end;

    if maxVozes > maxMostra then
        gotoxy (1, salvay + maxMostra)
    else
        gotoxy (1, salvay + maxVozes);

    sapiInfo (n, paramSapi);
    with param do
         begin
             voz := n;
             velocidade := 0;
             tom := 0;
         end;

    sintGravaAmbiente ('TRADUTOR', 'SAPI',       'SIM');
    sintGravaAmbiente ('SERVFALA', 'VOZ',        intToStr(param.voz));
    sintGravaAmbiente ('SERVFALA', 'VELOCIDADE', '0');
    sintGravaAmbiente ('SERVFALA', 'TOM',        '0');

    sintFim;
    sintInic (0, ambiente);
    sapiPresente := false;

    sapiPegaParam (param);
    sintGravaAmbiente ('SERVFALA', 'VELOCIDADE', intToStr(param.velocidade));
    sintGravaAmbiente ('SERVFALA', 'TOM',        intToStr(param.tom));

    listaNomes.Free;
end;

{-------------------------------------------------------------}
{                        inicialização
{-------------------------------------------------------------}

procedure inicializa;
begin
    sintGravaAmbiente ('TRADUTOR', 'SAPI', 'SIM');
    ambiente := sintAmbiente ('SAPIUTIL', 'DIRSAPIUTIL');
    if ambiente = '' then
        ambiente := 'c:\winvox\som\sapiutil';
    sintInic (0, ambiente);
    sapiPresente := false;
    sintFalaPont := false;

    textBackground (BLUE);
    mensagem ('SACTSAPI', 1);    // 'Controle da fala SAPI'
    textBackground (BLACK);
    writeln;
end;

{-------------------------------------------------------------}
{                  guarda um padrão de voz
{-------------------------------------------------------------}

procedure guardaNovoPadrao;
var
    sParam, sValores: string;
    s1, s2, s3, s4: string;
    c, c2: char;
    param: TParamVoz;
begin
    mensagem ('SAVOZGUA', 0);    // 'Número do padrão de voz a guardar: 1, 2 ou 3? '
    sintLeTecla (c, c2);
    writeln;
    if (c < '1') or (c > '9') then
        begin
            mensagem ('SADESIST', 1);    // 'Desistiu...'
            exit;
        end;

    sParam :=  'VOZ'+c;
    sapiPegaParam (param);
    with param do
        begin
            s1 := intToStr (voz);
            s2 := intToStr (velocidade);
            s3 := intToStr (tom);
            s4 := intToStr (tipoSapi);
            sValores := s1 + ' ' + s2 + ' ' + s3 + ' ' + s4;
        end;
    sintGravaAmbiente ('SAPIUTIL', sParam, sValores);
end;

{-------------------------------------------------------------}
{                   usa um padrão guardado
{-------------------------------------------------------------}

procedure usaPadrao;
var
    s: string;
    c, c2: char;
    param: TParamVoz;

    function extraiParam (var s: string): integer;
    var n: integer;
        negativo: integer;
    begin
        while (s <> '') and (s[1] = ' ') do delete (s, 1, 1);
        n := 0;

        negativo := 1;
        if (s <> '') and (s[1] = '-') then
            begin
                negativo := -1;
                delete (s, 1, 1);
            end;

        while (s <> '') and (s[1] in ['0'..'9']) do
            begin
                n := n * 10 + (ord(s[1]) - ord ('0'));
                delete (s, 1, 1);
            end;
        extraiParam := n * negativo;
    end;


begin
    mensagem ('SAVOZPAD', 0);    // 'Voz padrão: 1, 2 ou 3? '
    sintLeTecla (c, c2);
    writeln;
    if (c < '1') or (c > '9') then
        begin
            mensagem ('SADESIST', 1);    // 'Desistiu...'
            exit;
        end;

    s := sintAmbiente ('SAPIUTIL', 'VOZ'+c);
    with param do
        begin
            voz        := extraiParam (s);
            velocidade := extraiParam (s);
            tom        := extraiParam (s);
            tipoSapi   := extraiParam (s);
            if tipoSapi = 0 then tipoSapi := 3;
            if tipoSapi = 3 then voz := 1;
            ativaFalaParam (param);
        end;
end;

{-------------------------------------------------------------}
{                     escolhe o tipo de SAPI
{-------------------------------------------------------------}

procedure escolheTipoSapi;
var
    s: string;
begin
    mensagem ('SATIPSPX', 0);   {'Escolha o tipo de SAPI (3, 4, 5 ou 54): '}
    sintReadln (s);
    s := trim(s);
    if s = '' then
         begin
             mensagem ('SADESIST', 2);  {'Desistiu...'}
             exit;
         end;

    sintGravaAmbiente('SERVFALA', 'TIPOSAPI', copy(s, 1, 1));
    writeln;

    sintFim;
    sintInic (0, ambiente);
    sapiPresente := false;
end;

{-------------------------------------------------------------}
{                     testa a fala SAPI
{-------------------------------------------------------------}

procedure testarFala;
var
    s, ultFalada: string;
    c: char;
begin
    mensagem ('SAPITECL', 2); {'Tecle as frases, ENTER fala, ESC termina'}
    sapiPresente := true;
    ultFalada := '';
    repeat
        s := '';
        c := sintEdita (s, wherex, wherey, 80, true);
        if s <> '' then writeln;
        if c = ENTER then
            begin
                if s = '' then s := ultFalada;
                sintetiza (s);
                ultFalada := s;
            end;
    until c = ESC;
    sapiPresente := false;
end;

{-------------------------------------------------------------}
{                          ajuda
{-------------------------------------------------------------}

procedure ajuda;
begin
    writeln;
    mensagem ('SAOPCOES', 1);    // 'As opções são:'
    mensagem ('SAOP_S',   1);    // '  S - Selecionar o tipo de fala Sapi'
    mensagem ('SAOP_N',   1);    // '  N - Saber o número de vozes instaladas'
    mensagem ('SAOP_I',   1);    // '  I - Informações sobre a voz atual'
    mensagem ('SAOP_D',   1);    // '  D - Detalhes sobre a voz atual'
    mensagem ('SAOP_C',   1);    // '  C - Configurar a voz atual'
    mensagem ('SAOP_F',   1);    // '  F - Folhear as vozes instaladas'
    mensagem ('SAOP_G',   1);    // '  G - Guarda novo padrão de voz'
    mensagem ('SAOP_V',   1);    // '  V - usa uma voz anteriormente guardada'
    mensagem ('SAOP_T',   1);    // '  T - testar a voz Sapi'
    mensagem ('SA_ESC',   1);    // 'ESC - Termina'
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

function selSetasOpcao: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var n: integer;
const
    nopc = 9;
    tabLetrasOpcoes: string [nopc] = 'snidcfgvt';

begin
    garanteEspacoTela (nopc);
    popupMenuCria (wherex, wherey, 42, nopc, MAGENTA);
    MenuAdiciona ('SAOP_S');  // '  S - Selecionar o tipo de fala Sapi'
    MenuAdiciona ('SAOP_N');  // '  N - Saber o número de vozes instaladas'
    MenuAdiciona ('SAOP_I');  // '  I - Informações sobre a voz atual'
    MenuAdiciona ('SAOP_D');  // '  D - Detalhes sobre a voz atual');
    MenuAdiciona ('SAOP_C');  // '  C - Configurar a voz atual');
    MenuAdiciona ('SAOP_F');  // '  F - Folhear as vozes instaladas');
    MenuAdiciona ('SAOP_G');  // '  G - Guarda novo padrão de voz');
    MenuAdiciona ('SAOP_V');  // '  V - usa uma voz anteriormente guardada');
    MenuAdiciona ('SAOP_T');  // '  T - testar a fala');
    n := popupMenuSeleciona;
    if n > 0 then
        begin
            selSetasOpcao := tabLetrasOpcoes[n];
            gotoxy (12, wherey-1);
            write (tabLetrasOpcoes[n]);
            writeln;
        end
    else
        selSetasOpcao := ENTER;

end;

{-------------------------------------------------------------}
{                     programa principal
{-------------------------------------------------------------}

var c, c2: char;
label executa, fim;
begin
    inicializa;

    repeat
        textBackground (BLUE);
        mensagem ('SAOPCAO', 0);    // 'Sua opção: '
        textBackground (BLACK);

        sintLetecla (c, c2);
        writeln;

        if c = #0 then
            begin
                if c2 = F1 then ajuda
                else
                if (c2 = CIMA) or (c2 = BAIX) then
                    begin
                        c := selSetasOpcao;
                        goto executa;
                    end
                else
                    mensagem ('SAOPINV', 1);    // 'Opção inválida: aperte F1 para ajuda'
            end
        else
            begin
executa:
                case upcase(c) of
                    'S':  escolheTipoSapi;
                    'N':  quantasVozesInstaladas;
                    'I':  infoVozAtual;
                    'D':  detalhesVozAtual;
                    'C':  configuraVozAtual;
                    'F':  folheiaVoz;
                    'G':  guardaNovoPadrao;
                    'V':  usaPadrao;
                    'T':  testarFala;
                    ESC, BS:  ;
                else
                    mensagem ('SAOPINV', 1);    // 'Opção inválida: aperte F1 para ajuda'
                end;
            end;

        writeln;
    until c = ESC;

    mensagem ('SAPICONF', 1);    // 'SAPI configurado.'

fim:
    sintFim;
    doneWinCrt;
end.
