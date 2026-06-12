{-------------------------------------------------------------}
{
{           CartaVox - Grupo de contas
{
{-------------------------------------------------------------}

unit carCont;

interface

uses
    dvcrt,
    dvhora,
    dvForm,
    dvWin,
    sysUtils,
    windows,
    carDecod,
    careMudo,
    carMsg,
    carUtil,
    carVars,
    carTela,
    dvExec,
    classes,
    carConf,
    carMonit,
    carPop3,
    carSMTP;

procedure inicializaGrupoContas;
procedure receberGrupoContas (apertouShift: boolean);
procedure transmitirGrupoContas;
procedure monitorarGrupoContas;
function falaNumeroTotalDeCartasDaConta (somenteNaoLidas: boolean): boolean;
procedure informarCartasGrupoContas (somenteNaoLidas: boolean);

implementation

const
    NUMMAXCONTAS = 100;

const
    booleanToStr: array [boolean] of string = ('NAO', 'SIM');

type
    TConta= record
                nome: string;
                selecionado: boolean;
            end;

    Pconta= ^TConta;
    tcont = array [1..NUMMAXCONTAS] of Pconta;

var
    numContas, nFolhe: integer;
    cont : tcont;
    nomeBusc: string;

{-------------------------------------------------------------}
{       Ajuda do menu de seleção do grupo de contas
{-------------------------------------------------------------}

procedure ajudaSelecContas;
begin
    writeln;
    if not keypressed then
        mensagem ('CTAJUD01', 2); {'As opções são'}
    if not keypressed then
        mensagem ('CTAJGC01', 1); {'   A - Adicionar contas ao grupo de contas'}
    if not keypressed then
        mensagem ('CTAJGC02', 1); {'   R - Remover contas do grupo de contas'}
end;

{--------------------------------------------------------}
{  seleciona a opção do menu de seleção contas com as setas
{--------------------------------------------------------}

function selSetasSelecaoContas: char;
var n: integer;
const
    tabLetrasConfig: string [2] = 'AR';

begin
    popupMenuCria (wherex, wherey, 50, 2, MAGENTA);
    MenuAdiciona ('A - Adicionar contas ao grupo de contas');
    MenuAdiciona ('R - Remover contas do grupo de contas');

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasSelecaoContas := tabLetrasConfig[n]
    else
        selSetasSelecaoContas := ESC;
end;

{-------------------------------------------------------------}
{       Monta a tela do folheamento de contas
{-------------------------------------------------------------}

procedure telaFolheiaContas (numContas: integer);
var s: string;
begin
    clrscr;
    textBackGround (MAGENTA);
    s := pegaTextoMensagem ('CTFOGRCO'); {'Folheamento do grupo de contas'}
    s := s + ' - ' + intToStr(numContas) + ' ';
    s := s + pegaTextoMensagem('Contas'); {'Contas'}
    write (centralizaFrase (s));
    textBackground (BLACK);
    writeln;
    writeln;
    textColor (LightGray);
    write ('Nome das Contas');
    textColor (White);
    writeln;
    gotoxy (1,5); clreol;
end;

{----------------------------------------------------------------------}
{     Grava na memória ( ponteiro cont ) as informações de cada conta
{     Parâmetro adicionarContas - se é true, grava na memória as contas
{     que não estão no grupo de contas, se é false, grava na mamória as
{     contas que estão no grupo de contas
{----------------------------------------------------------------------}

procedure carregarContas(adicionarContas: boolean);
var
    nomes: array [0..4000] of char;
    p: pchar;
    estaNoGrupo: boolean;
    nomeConta: string;
    s: string;

begin
    numContas :=  0;

    getprivateProfileString (NIL, NIL, '', nomes, 4000, PChar(cartavoxConfigs));
    p := nomes;
    while p^ <> #$0 do
        begin
            nomeConta := StrPas(p);
            if sintAmbienteArq (nomeConta, 'SERVIDORSMTP', '', cartavoxConfigs) <> '' then   // configuração é válida
                begin
                    s := sintAmbienteArq (nomeConta, 'GRUPODECONTAS', '', cartavoxConfigs);
                    estaNoGrupo := (s <> '') and (upcase(s[1]) = 'S');

                    if adicionarContas then
                        begin
                            if not estaNoGrupo then
                                begin
                                    numContas := numContas + 1;
                                    new(cont[numContas]);
                                    cont[numContas]^.nome := strPas(p);
                                    cont[numContas]^.selecionado := false;
                                end;
                        end
                    else
                    if estaNoGrupo then
                        begin
                            numContas := numContas + 1;
                            new (cont[numContas]);
                            cont[numContas]^.nome := strPas(p);
                            cont[numContas]^.selecionado := false;
                        end;
                end;

            p := p + strlen(p) + 1;
        end;
end;

{---------------------------------------------------------------}
{       Monta o folheamento de contas
{---------------------------------------------------------------}

procedure inicializaFolheamentoContas;
var
    i: integer;
    nome: string;
begin
    folheiaCria (1, 6, 80, 21);
    for i :=  1 to numContas do
        begin
            nome := copy (cont[i]^.nome+BRANCOS, 1, 30);

            folheiaAdicionaEspecial (nome, cont[i]^.selecionado, cont[i]^.nome);
        end;
end;

{-------------------------------------------------------------}
{       Ajuda das opções do folheamento de contas
{-------------------------------------------------------------}

procedure ajudaFolheContas;
begin
    telaFolheiaContas (folheiaNumItens);
    textBackground (BLUE);
    mensagem ('CTAJUD01', 0); {'As opções são:'}
    textBackground (BLACK);
    writeln;
    mensagem ('CTAJFA01', 1); {'ENTER - Escolhe atual ou selecionados e sai'}
    mensagem ('CTAJFC02', 1); {'CTRL+Q - Informa quantas do total'}
    mensagem ('CTAJFC03', 1); {'CTRL+S - Informa quantas selecionadas do total'}
    mensagem ('CTAJFL10', 1); {'F5 - Procurar'}
    mensagem ('CTAJFP11', 1); {'BARRA DE ESPAÇO - Seleciona ou tira seleção'}
    mensagem ('CTAJFP12', 1); {'* - Seleciona tudo'}
    mensagem ('CTAJFP13', 1); {'/ - Tira seleção de tudo'}
    mensagem ('CTAJFL07', 1); {'ESC - Terminar folheamento'}

    if keypressed and (readkey <> ESC) then
        begin
            limpaBufTec;
            readkey;
        end;
    limpaBufTec;
end;

{--------------------------------------------------------}
{   procura próxima conta que contém as palavras buscadas
{   na procura anterior
{--------------------------------------------------------}

function procuraProximoItem(numFolhe: integer): integer;
var
    i: integer;
    buscado, item: string;
begin
    buscado := semAcentos (nomeBusc);
     for i := numFolhe +1 to folheiaNumItens do
        begin
            item := cont[i]^.nome;
            if pos (buscado, semAcentos (item)) <> 0 then
                begin
                    procuraProximoItem := i;
                    exit;
                end;
        end;

    sintbip;
    procuraProximoItem := numFolhe;
end;

{----------------------------------------------------------------------}
{       Desaloca da memória o ponteiro cont
{----------------------------------------------------------------------}

procedure descarregarContas;
begin
    while numContas >0 do
    begin
        dispose (cont[numContas]);
        numContas := numContas - 1;
    end;
end;

{----------------------------------------------------------------------}
{    Procura uma conta pelo nome no folheamento de contas
{----------------------------------------------------------------------}

function procuraItem (numFolhe: integer): integer;
begin
    procuraItem := numFolhe;
    gotoxy (1, 24); clreol;
    textbackground (red);
    mensagem ('CTPALPRO', 0);{'Digite a palavra a procurar: '}
    textbackground (black);
    sintReadln (nomeBusc);
    if nomeBusc = '' then exit;
    procuraItem := procuraProximoItem (numFolhe);
end;

{--------------------------------------------------------}
{       Ordena pelo metodo quick sort
{--------------------------------------------------------}

procedure Sort(l, r: Integer);
var
    i, j: integer;
    x: string;
    ppes: PConta;

begin
    i := l;
    j := r;

    ppes := cont[(l+r) div 2];
    x := ppes^.nome;
    x := semAcentos (x);

    repeat
        while semAcentos (cont[i]^.nome) < x do
            i := i + 1;
        while x < semAcentos (cont[j]^.nome) do
            j := j - 1;

        if i <= j then
            begin
                ppes := cont[i];
                cont[i] := cont[j];
                cont[j] := ppes;
                i := i + 1;
                j := j - 1;
            end;
    until i > j;

    if l < j then Sort(l, j);
    if i < r then Sort(i, r);
end;

{--------------------------------------------------------}
{    Cria e controla o folheamento de contas
{--------------------------------------------------------}

procedure folhearContas(adicionarContas: boolean);
var
    c, c2: char;
    i, k, indice, opFinalizadas, portaPOP3Aux, erro: integer;
    podeFalar, usaSSLAux: boolean;
    aux, item, nomeConta, contaFinalizada, senhaSalvaAux: string;
    contasSelecionadas: TStringList;
    s: string;
    hostPOP3Aux, contaUsuarioAux: shortString;
begin
    opFinalizadas := 0;
    senhaSalvaAux := senhaSalva;
    contasSelecionadas := TStringList.Create;
    telaFolheiaContas(0);

    carregarContas(adicionarContas);

    if numContas <= 0 then
        begin
            if adicionarContas then
                 msgBaixo('CTNEXCAD') {'Não existem contas a serem adicionadas.'}
            else msgBaixo('CTNEXGRU'); {'Não existem contas no grupo.'}
            exit;
        end;
    sort (1, numContas);
    inicializaFolheamentoContas;

    nFolhe:= 1;
    podeFalar := true;
    repeat
        telaFolheiaContas (folheiaNumItens);
        folheiaExecuta (nFolhe, nFolhe, c, c2, podeFalar);
        if nFolhe < 1 then NFolhe := 1;
        if nfolhe > folheiaNumItens then nFolhe := folheiaNumItens;
        sintPara;
        for k := 1 to folheiaNumItens do
            folheiaObtemItem (k, item, cont[k]^.selecionado);

        if c = #$0 then
            case c2 of
                ESQ: sintetiza (cont[nFolhe]^.nome);
                DIR: sintetiza (cont[nFolhe]^.nome);
                F1: ajudaFolheContas;
                f5: nFolhe := procuraItem (nFolhe);
                CTLF5: nFolhe := procuraProximoitem (nFolhe);
                f8: falaHora;
                CTLF8: falaDia;
            end
        else
            with cont[nFolhe]^ do
            begin
                case upcase(c) of
                    ESC: ;
                    ENTER: begin
                                aux := '';
                                if not temItemSelecionado then
                                    contasSelecionadas.add(nome)
                                else
                                    for i := 1 to numContas do
                                        if cont[i]^.selecionado then
                                            contasSelecionadas.add(cont[i]^.nome);
                                c := ESC;
                                writeln(aux);
                           end;

                    ^Q: falaQualItemDeQuantos (nFolhe, folheiaNumItens, false);
                    ^S: falaQualItemDeQuantos (nFolhe, folheiaNumItens, true);
                end;
            end;

        if (upCase(c) in[^Q, ^S]) or (c2 in [ESQ, DIR, f8, CTLF8]) then
            podeFalar := false
        else
            podeFalar := true;

        if (upcase (c) in ['A'..'Z']) or (upcase (c) in ['0' .. '9']) then
            begin
                i := nFolhe + 1;
                if i > folheiaNumItens then i := 1;
                while (i <> nFolhe) and  (maiuscAnsi (cont[i]^.nome[1]) <> upcase(c)) do
                    if i >= numContas then
                        i := 1
                    else
                        i := i + 1;
                if maiuscAnsi (cont[i]^.nome[1]) = upcase(c) then
                    nFolhe := i;

            end;

    until (c = ESC) or (numContas <= 0);

    for indice := 0 to contasSelecionadas.Count - 1 do
        begin
            gotoxy (1, 23);
            nomeConta := contasSelecionadas.Strings[indice];

            if adicionarContas then
                begin

                    s := sintAmbienteArq (nomeConta, 'SCCV', '', cartavoxConfigs);
                    senhaSalva := decodFraseMime64 (s);

                    if trim (senhaSalva) = '' then
                        begin
                            repeat
                                textBackground (BLACK);
                                if indice > 0 then
                                    begin
                                        writeln;
                                        writeln;
                                        writeln;
                                        writeln;
                                        writeln;
                                        gotoxy (1, 23);
                                    end;
                                mensagem('CTPAADCO', 0); {'Para adicionar a conta '}
                                sintWrite (nomeConta);
                                mensagem('CTAOGRCO', 1); {' ao grupo de contas, a senha precisa ser gravada. '}
                                mensagem('CTDEGRSE', 1); {'Deseja gravar a senha desta conta?'}
                                c := upcase(popupMenuPorLetra ('SN'));
                                writeln;
                            until c in ['S', 'N', ENTER, ESC];

                            if c in ['N', ESC] then
                                begin
                                    mensagem ('CTACONT', 0); {'A conta '}
                                    sintWrite (nomeConta);
                                    mensagem ('CTNFAGRC', 1); {'não foi adicionada ao grupo de contas'}
                                end
                            else
                                begin
                                    hostPOP3Aux := sintAmbienteArq (nomeConta, 'SERVIDORPOP3', '', cartavoxConfigs);
                                    contaUsuarioAux := sintAmbienteArq (nomeConta, 'CONTAUSUARIO', '', cartavoxConfigs);

                                    s := sintAmbienteArq (nomeConta, 'USASSL', '', cartavoxConfigs);
                                    usaSSLAux := (s <> '') and (upcase(s[1]) = 'S');

                                    s := sintAmbienteArq (nomeConta, 'PORTAPOP3', '', cartavoxConfigs);
                                    val (s, portaPOP3Aux, erro);
                                    if erro <> 0 then
                                        if usaSSLAux then portaPOP3Aux := 995
                                                     else portaPOP3Aux := 110;

                                    if not senhaValida(hostPOP3Aux, contaUsuarioAux, portaPOP3Aux, usaSSLAux) then
                                        begin
                                            mensagem ('CTACONT', 0); {'A conta '}
                                            sintWrite (nomeConta);
                                            mensagem ('CTNFAGRC', 1); {' não foi adicionada ao grupo de contas'}
                                            continue;
                                        end;

                                    sintGravaAmbienteArq(nomeConta, 'ARMAZENASENHA', 'SIM', cartavoxConfigs);
                                    sintGravaAmbienteArq(nomeConta, 'SCCV', codFraseMime64 (senhaSalva), cartavoxConfigs);
                                    sintGravaAmbienteArq(nomeConta, 'GRUPODECONTAS', booleanToStr[adicionarContas], cartavoxConfigs);

                                    opFinalizadas := opFinalizadas + 1;
                                    contaFinalizada := nomeConta;
                                end;
                        end
                        else
                            begin
                                sintGravaAmbienteArq(nomeConta, 'GRUPODECONTAS', booleanToStr[adicionarContas], cartavoxConfigs);
                                opFinalizadas := opFinalizadas + 1;
                                contaFinalizada := nomeConta;
                            end;
                end
                else
                    begin
                        sintGravaAmbienteArq(nomeConta, 'GRUPODECONTAS', booleanToStr[adicionarContas], cartavoxConfigs);
                        opFinalizadas := opFinalizadas + 1;
                        contaFinalizada := nomeConta;
                    end;
        end;

    if adicionarContas then
        begin
            if opFinalizadas = 1 then
                begin
                    msgbaixo ('CTACONT'); {'A conta '}
                    sintetiza (contaFinalizada);
                    msgBaixo ('CTFOADGR'); {'Foi adicionada ao grupo de contas'}
                end
            else if opFinalizadas > 1 then
                msgbaixo('CTADGRCO'); {'Contas adicionadas ao grupo de contas'}
        end
    else
        begin
            if opFinalizadas = 1 then
                begin
                    msgbaixo ('CTACONT'); {'A conta '}
                    sintetiza (contaFinalizada);
                    msgBaixo('CTREGRCO'); {'Foi retirada do grupo de contas'}
                end
            else if opFinalizadas > 1 then
                msgbaixo('CTCOREGR'); {'Contas retiradas do grupo de contas'}
        end;


    senhaSalva := senhaSalvaAux;
    contasSelecionadas.Free;
    folheiaDestroi;
    descarregarContas;
    textColor (WHITE);
    telaPrincipal;
end;

{--------------------------------------------------------}
{ seleciona as contas para serem usadas no grupo de contas
{--------------------------------------------------------}

procedure selecionarGrupoContas;
var c, c2: char;
label inicioCont;

begin
    repeat
        telaPrincipal;
        textBackground (BLUE);
        mensagem ('CTSEGRCO', 1); {'Seleção do Grupo de contas'}
        textBackground (BLACK);
        mensagem ('CTQUALOP', 0); {'Qual sua opção ? '}
        mensagem ('CTF1AJUD', 0); {'F1 ajuda '}
        sintLeTecla (c, c2);
        writeln;

        if (c = #0) and ((c2 = BAIX) or (c2 = CIMA)) then
            c := selSetasSelecaoContas
        else
            if c = #0 then ajudaSelecContas;

        case upcase (c) of
            'A':  folhearContas(true);
            'R':  folhearContas(false);
        end;

    until c = ESC;

    mensagem ('CTOK', 1);  {'OK'}
end;


{-------------------------------------------------------------}
{       Fala número de cartas nos folheamentos
{-------------------------------------------------------------}

function falaNumeroTotalDeCartasDaConta (somenteNaoLidas: boolean): boolean;
var
    i: integer;
    dirVazio: boolean;
label erro;
begin
    dirVazio := true;

    if not somenteNaoLidas then
    begin
            i := numeroDeCartasGrupoContas ('P');
            if i = -1 then goto erro
            else
            if i > 0 then
                begin
                    mensagem  ('CTPREPAR', 0); {'Preparadas'}
                    sintwriteln ('  ' + intToStr(i));
                    dirVazio := false;
                end;
        end;

    i := numeroDeCartasGrupoContas ('N');
    if i = -1 then goto erro
    else
    if (i > 0) or somenteNaoLidas then
        begin
            mensagem  ('CTNAOLID', 0); {'Não lidas'}
            sintwriteln ('  ' + intToStr(i));
            dirVazio := false;
        end;

    if not somenteNaoLidas then
    begin
            i := numeroDeCartasGrupoContas ('L');
            if i = -1 then goto erro
            else
            if i > 0 then
                begin
                    mensagem ('CTLIDAS', 0); {'Lidas'}
                    sintwriteln ('  ' + intToStr(i));
                    dirVazio := false;
                end;
            i := numeroDeCartasGrupoContas ('T');
            if i = -1 then goto erro
            else
            if i > 0 then
                begin
                    mensagem ('CTTRANSM', 0); {'Transmitidas'}
                    sintwriteln ('  ' + intTostr(i));
                    dirVazio := false;
                end;
        end;

    if dirVazio then
        mensagem ('CTSEMCAR', 1); {'Não tem carta neste diretório'}
    writeln;
    falaNumeroTotalDeCartasDaConta := true;
    exit;

erro:
    falaNumeroTotalDeCartasDaConta := false;

end;

{--------------------------------------------------------}
{       recebe as cartas das contas selecionadas
{--------------------------------------------------------}

procedure receberGrupoContas (apertouShift: boolean);
var
    nomes: array [0..4000] of char;
    nomeConta: string;
    s: string;
    p: pchar;
    c: char;
    estaNoGrupo, contaPorConta, existemContas: boolean;
    confAtual: shortString;
    cod, numTrazidas: integer;
label desistiu;
begin
    cod := 0;
    numTrazidas := 0;
    contaPorConta := false;
    existemContas := false;

    confAtual := nomeConfiguracao;
    getprivateProfileString (NIL, NIL, '', nomes, 4000, PChar(cartavoxConfigs));
    p := nomes;
    while p^ <> #$0 do
        begin
            if keypressed then
                begin
                    c := readkey;
                    if c = ESC then break;
                end;

            nomeConta := StrPas(p);
            if sintAmbienteArq (nomeConta, 'SERVIDORSMTP', '', cartavoxConfigs) <> '' then
                begin   // conta válida
                    s := sintAmbienteArq (nomeConta, 'GRUPODECONTAS', '', cartavoxConfigs);
                    estaNoGrupo := (s <> '') and (upcase(s[1]) = 'S');

                    if estaNoGrupo then
                        begin
                            if not existemContas then
                                begin
                                    if apertouShift then
                                        c := 'S'
                                    else
                                    repeat
                                        mensagem ('CTTRCAAU', 1); {'Deseja trazer as cartas de todas as contas automaticamente?'}
                                        c := upcase(popupMenuPorLetra ('SN'));
                                        writeln;
                                    until c in ['S', 'N', ENTER, ESC];
                                    if c = ESC then goto desistiu
                                    else if c = 'N' then contaPorConta := true
                                    else if c in ['S', ENTER] then contaPorConta := false;
                                end;
                            existemContas := true;
                            recuperaConfigGrupoContas (AnsiUpperCase(StrPas(p)));
                            if contaPorConta then
                                cod := receberCartasGrupoContas(false, false)
                            else
                                begin
                                    if sintFalarTudo then mensagem('CTACECON', -1) {'Acessando conta '}
                                    else sintClek;
                                    sintetiza (StrPas(p)); //Fala o nome da conta
                                    cod := receberCartasGrupoContas(apertouShift, true);
                                    numTrazidas := numTrazidas + cod;
                                    sintWriteInt (numCartasPOP3); //Fala o número de cartas da conta

                                    if sintFalarTudo then
begin
                                        if not apertouShift then
                                            begin
                                                if numCartasPOP3 > 1 then
                                                    mensagem ('CTRECEBI', -1) {'Recebidas'}
                                                else
                                                    mensagem ('CTRECEB1', -1); {'Recebida'}
                                            end
                                        else
                                        if numCartasPOP3 > 1 then
                                            mensagem ('CTCARTAS', -1) {'Recebidas'}
                                        else
                                            mensagem ('CTCARTA', -1); {'Recebida'}
end;

                                    while sintFalando and (not keypressed) do
                                        waitMessage;
                                end;
                       end;
                    if cod = -1 then break;
                end;
            p := p + strlen(p) + 1;
        end;

    if (cod <> -1) and (contaPorConta = false) and (existemContas) then
        begin
           if(numTrazidas > 0) then
               mensagem ('CTOKPEG', 1)  {'Ok, peguei a correspondência'}
           else
               mensagem ('CTNECASE', 1); {'Não existem cartas nos servidores'}
        end;

    if not existemContas then
        mensagem ('CTNAECSE', 1); {'Não existem contas selecionadas'}

    if (confAtual <> 'Lixeira') and (confAtual <> 'Spam') and (trim(confAtual) <> '') then
        recuperaConfigGrupoContas (confAtual);
    setWindowTitle ('CARTAVOX ' + confAtual);
    exit;

desistiu:
    msgBaixo ('CTDESIST'); {'Desistiu'}

end;

{--------------------------------------------------------}
{      transmite as cartas das contas selecionadas
{--------------------------------------------------------}

procedure transmitirGrupoContas;

var
    nomes: array [0..4000] of char;
    nomeConta, s: string;
    p: pchar;
    estaNoGrupo, existemContas: boolean;
    confAtual: string;
    cod: integer;
begin
    existemContas := false;
    confAtual := nomeConfiguracao;
    getprivateProfileString (NIL, NIL, '', nomes, 4000, PChar(cartavoxConfigs));
    p := nomes;
    while p^ <> #$0 do
        begin
            nomeConta := StrPas(p);
            if sintAmbienteArq (nomeConta, 'SERVIDORSMTP', '', cartavoxConfigs) <> '' then
                begin   // conta válida
                    s := sintAmbienteArq (nomeConta, 'GRUPODECONTAS', '', cartavoxConfigs);
                    estaNoGrupo := (s <> '') and (upcase(s[1]) = 'S');

                    if estaNoGrupo then
                        begin
                            existemContas := true;
                            recuperaConfigGrupoContas (AnsiUpperCase(StrPas(p)));
                            cod := transmitirCartasGrupoContas;
                            if cod = -1 then break;
                        end;
                end;
            p := p + strlen(p) + 1;
        end;

    if not existemContas then
        mensagem ('CTNAECSE', 1); {'Não existem contas selecionadas'}

    recuperaConfigGrupoContas (confAtual);
    setWindowTitle ('CARTAVOX ' + confAtual);
end;

{--------------------------------------------------------}
{           monitora as contas selecionadas
{--------------------------------------------------------}

procedure monitorarGrupoContas;
var
    nomes: array [0..4000] of char;
    nomeConta, s: string;
    p: pchar;
    estaNoGrupo, existemContas: boolean;
    contasNoGrupo: TStringList;
    confAtual: shortString;

begin
    existemContas := false;
    contasNoGrupo := TStringList.Create;

    getprivateProfileString (NIL, NIL, '', nomes, 4000, PChar(cartavoxConfigs));
    p := nomes;
    while p^ <> #$0 do
        begin
            nomeConta := StrPas(p);
            if sintAmbienteArq (nomeConta, 'SERVIDORSMTP', '', cartavoxConfigs) <> '' then
                begin   // conta válida
                    s := sintAmbienteArq (nomeConta, 'GRUPODECONTAS', '', cartavoxConfigs);
                    estaNoGrupo := (s <> '') and (upcase(s[1]) = 'S');

                    if estaNoGrupo then
                        begin
                            existemContas := true;
                            contasNoGrupo.add(AnsiUpperCase(StrPas(p)));
                        end;
                end;
            p := p + strlen(p) + 1;
        end;
    confAtual := nomeConfiguracao;

    if existemContas then monitorarCorreioGrupoContas(contasNoGrupo)
    else
        mensagem ('CTNAECSE', 1); {'Não existem contas selecionadas'}

    recuperaConfigGrupoContas (confAtual);
    setWindowTitle ('CARTAVOX ' + confAtual);
    contasNoGrupo.Free;
end;

{--------------------------------------------------------}
{   informar o total de cartas das contas selecionadas
{--------------------------------------------------------}

procedure informarCartasGrupoContas (somenteNaoLidas: boolean);
var
    nomes: array [0..4000] of char;
    nomeConta, s: string;
    p: pchar;
    estaNoGrupo, existemContas, cod: boolean;
    confAtual: string;

begin
    existemContas := false;
    confAtual := nomeConfiguracao;
    getprivateProfileString (NIL, NIL, '', nomes, 4000, PChar(cartavoxConfigs));
    p := nomes;
    while p^ <> #$0 do
        begin
            nomeConta := StrPas(p);
            if sintAmbienteArq (nomeConta, 'SERVIDORSMTP', '', cartavoxConfigs) <> '' then
                begin   // conta válida
                    s := sintAmbienteArq (nomeConta, 'GRUPODECONTAS', '', cartavoxConfigs);
                    estaNoGrupo := (s <> '') and (upcase(s[1]) = 'S');

                    if estaNoGrupo then
                        begin
                            existemContas := true;
                            recuperaConfigGrupoContas (AnsiUpperCase(StrPas(p)));
                            sintWriteln (nomeConfiguracao);
                            cod := falaNumeroTotalDeCartasDaConta (somenteNaoLidas);
                            if not cod then break;
                        end;
                end;
            p := p + strlen(p) + 1;
        end;

    while keypressed do readkey;
    if not existemContas then
        mensagem ('CTNAECSE', 1); {'Não existem contas selecionadas'}

    recuperaConfigGrupoContas (confAtual);
    setWindowTitle ('CARTAVOX ' + confAtual);
end;

{--------------------------------------------------------}
{       ajuda do menu principal do grupo de contas
{--------------------------------------------------------}

procedure ajudaConfig;
begin
    writeln;
    if not keypressed then
        mensagem ('CTAJUD01', 2); {'As opções são'}
    if not keypressed then
        mensagem ('CTAJSE01', 1); {'   S - Selecionar contas'}
    if not keypressed then
        mensagem ('CTAJSE02', 1); {'   R - Receber cartas das contas selecionadas'}
    if not keypressed then
        mensagem ('CTAJSE03', 1); {'   T - Transmitir cartas das contas selecionadas'}
    if not keypressed then
        mensagem ('CTAJSE04', 1); {'   M - Monitorar contas selecionadas'}
    if not keypressed then
        mensagem ('CTAJSE05', 1); {'   Q - Informar total de cartas das contas selecionadas'}
end;

{--------------------------------------------------------}
{  seleciona a função com as setas, opções do menu
{  principal do grupo de contas
{--------------------------------------------------------}

function selSetasConfig: char;
var n: integer;
const
    tabLetrasConfig: string [5] = 'SRTMQ';

begin
    popupMenuCria (wherex, wherey, 55, 5, MAGENTA);
    MenuAdiciona ('CTAJSE01'); {'S - Selecionar contas'}
    MenuAdiciona ('CTAJSE02'); {'R - Receber cartas das contas selecionadas'}
    MenuAdiciona ('CTAJSE03'); {'T - Transmitir cartas das contas selecionadas'}
    MenuAdiciona ('CTAJSE04'); {'M - Monitorar contas selecionadas'}
    MenuAdiciona ('CTAJSE05'); {'Q - Informar total de cartas das contas selecionadas'}

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasConfig := tabLetrasConfig[n]
    else
        selSetasConfig := ESC;
end;

{--------------------------------------------------------}
{      execução do menu principal do grupo de contas
{--------------------------------------------------------}

procedure inicializaGrupoContas;
var c, c2: char;
    apertouShift: boolean;
label inicioCont;
begin
inicioCont:
    telaPrincipal;
    textBackground (BLUE);
    mensagem ('CTGRDECO', 1); {'Grupo de contas'}
    textBackground (BLACK);
    mensagem ('CTQUALOP', 0); {'Qual sua opção ? '}
    mensagem ('CTF1AJUD', 1); {'F1 ajuda '}
    sintLeTecla (c, c2);
    apertouShift := GetKeyState(VK_SHIFT) < 0;
    writeln;

    if (c = #0) and ((c2 = BAIX) or (c2 = CIMA)) then
        c := selSetasConfig
    else
    if c = #0 then
        begin
            ajudaConfig;
            goto inicioCont;
        end;

    case upcase (c) of
        'S':  selecionarGrupoContas;
        'R':  receberGrupoContas (apertouShift);
        'T':  transmitirGrupoContas;
        'M':  monitorarGrupoContas;
        'Q':  informarCartasGrupoContas (false);
    else
        if c <> ESC then
            begin
                msgBaixo ('CTOPCINV');   {'Opção inválida'}
                goto inicioCont;
            end
        else
            msgBaixo ('CTDESIST'); {'Desistiu'}
    end;

end;

end.
