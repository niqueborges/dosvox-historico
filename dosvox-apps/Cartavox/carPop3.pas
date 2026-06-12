{-------------------------------------------------------------}
{
{           CartaVox - Cliente POP3
{
{-------------------------------------------------------------}

unit carPop3;

interface

uses
    dvcrt,
    dvForm,
    dvHora,
    dvWin,
    sysUtils,
    windows,
    carRede,
    winSock,  //Declarar depois de carRede
    carDecod,
    careMudo,
    carMsg,
    carTela,
    carCopia,
    carUtil,
    carVars,
    carRegras,
    classes,
    carResp,
    carEst,
    carEnvia,
    carSmtp,
    carFolInt;

function receberCartas (opcaoMudo, apertouShift: boolean): integer;
function receberCartasRespAut( cartasExistentes, cartasChegadas: integer): integer;
function receberCartasServidor (opcaoMudo: boolean): boolean;
function receberCartasGrupoContas (apertouShift, opcaoMudo: boolean): integer;
procedure atualizaPosServ (numCarta: integer);
function trazEApagaCartasServidor(nCar: integer; trazer, apagarDoServidor: boolean): integer;
function apagarUmaCartaServidor (nCar: integer): boolean;
function trazerUmaCartaServidor (nCar: integer): boolean;
function senhaValida(iHostPop3, iContaUsuario: shortString; iPortaPOP3: integer; iUsaSSL: boolean): boolean;

implementation

var
    mudo, ignoraTodas, recebeTodas, trazerMudo: boolean;
    acessoServidor, naoApagaCarta, acessoGrupoContas: boolean;
    cartasTrazidas, totalDeCartas: integer;
    mascaraBip, nBip: integer;

{ Retornos }
const
    COD_OK = 0;
    COD_DESIST    = 1;
    COD_CANCELA   = 2;
    COD_ERRODISCO = 3;
    COD_ERRO = -1;

{-------------------------------------------------------------}
{           tratamento das teclas durante a recepção
{-------------------------------------------------------------}

function trataTecla (tamanhoAFalar, totalLidos: longint): char;
var
    c: char;
    tam: longInt;
begin
    while keypressed do c := readkey;

    trataTecla := c;

    if c = #$1b then exit;

    if (c = ' ') or (c = #$08) then
        mudo := not mudo
    else
        begin
            write (#$0d);  clreol;
            mensagem ('CTCARTA', 0); {'Carta'}
            sintwrite (' '+ intToStr(cartasTrazidas) + '/'+ intToStr (totalDeCartas));
            if (tamanhoAFalar > 0) and (totalLidos > 0) then
                begin
                    tam := (totalLidos * 100) div tamanhoAFalar;
                    if tam >= 0 then
                        sintWriteln (' com ' + intToStr(tam) + ' % de '+ formataTamanhoArq (tamanhoAFalar))
                    else
                        sintWriteln (' iniciada');
                end;
        end;
end;

{-------------------------------------------------------------}
{           dá bips de vez em quando
{-------------------------------------------------------------}

procedure trataBips (totalLidos: longint);
begin
    nBip := totalLidos div 16384;
    if nBip <> mascaraBip then
        begin
            write ('*');
            if not mudo then
                if bipaNoSpeaker then bipSpeaker (220)
                else sintClek;
            mascaraBip := nBip;
        end;
end;

{-------------------------------------------------------------}
{       recebe multiplas linhas do POP3
{-------------------------------------------------------------}

function multiLineReceive (nomeArq: string; tamanhoAFalar: longint): boolean;
var
    arq: text;
    s: string;
    i, lidos: integer;
    trazendo: boolean;
    totalLidos: longint;
    gravouAlgo: boolean;

label erro, erroDisco;
begin
    multiLineReceive := true;
    gravouAlgo := false;

    assign (arq, nomeArq);
    {$I-}  rewrite (arq);  {$I+}
    if ioresult <> 0 then
        begin
erroDisco:
            mensagem ('CTPROGRV', 1);  {'Problemas para gravar carta no disco'}
            multiLineReceive := false;
            {$I-}  close (arq);  {$I+}
            if ioresult <> 0 then;
            exit;
        end;

    s := '';
    totalLidos := 0;
    trazendo := true;
    mascaraBip := 999;

    while trazendo do
        begin
            if keypressed then     { cancelamento }
                if trataTecla (tamanhoAFalar, totalLidos) = #$1b then
                      goto erro;

            lidos := receive (sockPOP3, bufRecebe, BUFSIZE, 0);
            if (lidos <= 0) then
                begin
                    mensagem ('CTPROCON', 2);  {'Problemas na conexão'}
                    goto erro;
                end;
            bufRecebe [lidos] := #$0;

            if (totalLidos = 0) and (bufRecebe[0] <> '+') then
                begin
                    mensagem ('CTERRSRV', 1);   {'Erro no servidor, veja o que ele disse:'}
                    sintWriteln (strPas(bufRecebe));
                    writeln (arq, strPas(bufRecebe));
                    break;
                end;

            totalLidos := totalLidos + lidos;
            trataBips (totalLidos);

            for i := 0 to lidos-1 do
                begin
                    s := s + bufRecebe[i];
                    if bufRecebe[i] = #$0a then
                        begin
                            delete (s, length (s), 1);
                            if s [length(s)] = #$0d then
                                delete (s, length (s), 1);
                            while (s <> '') and (s[length(s)] = ' ') do
                                delete (s, length (s), 1);
                            if (s = '.') then
                                trazendo := false
                            else
                                begin
                                    if gravouAlgo then
                                        begin    // não grava +OK
                                            if copy (s, 1, 2) = '..' then
                                                delete (s, 1, 1);
                                            {$I-}  writeln (arq, s); {$I+}
                                            if ioresult <> 0 then goto erroDisco;
                                        end;
                                    gravouAlgo := true;
                                end;

                            s := '';
                        end;

                    if (s = '.' + #$0d) then
                        trazendo := false;
                end;
        end;

    {$I-}  close (arq);  {$I+}
    if ioresult <> 0 then goto erroDisco;
    writeln;
    exit;

erro:
    limpaBufTec;
    {$I-}  close (arq);  {$I+}
    if ioresult <> 0 then;

    if not gravouAlgo then
        begin
            {$I-}  erase (arq);  {$I+}
            if ioresult <> 0 then;
        end;

    writeln;
    multiLineReceive := false;
end;

{-------------------------------------------------------------}
{       envia conta e senha para POP3 e ve quantas cartas
{-------------------------------------------------------------}

function inicializaPOP3: boolean;
var
    i, lidos, posErro: integer;
    salvaAttr: word;
    s, s2, senha: string;
    c: char;

label deNovo, erro;

    procedure falaQuantasNoServidor;
    begin
        if numCartasPOP3 > 1 then
            mensagem ('CTEXISTM', 0)  {'Existem no servidor '}
        else
            mensagem ('CTEXISTE', 0);  {'Existem no servidor '}
        sintWriteInt (numCartasPOP3);
        write(' ');
        if numCartasPOP3 > 1 then
            mensagem ('CTCARTAS', 0) {'Cartas'}
        else
            mensagem ('CTCARTA', 0); {'Carta'}
        mensagem ('CTCOMUSO', 0);  {' com uso de '}
        sintWriteln (formataTamanhoArq (numBytesPop3));
        writeln;
    end;

var numCartasPOP3Aux, totalCartasATrazer: integer;
begin
    result := false;
    sockPOP3 := abreConexao (hostPOP3, portaPOP3, trazerMudo);
    if sockPOP3 = -1 then
        goto erro;

    if usaSSL then
        if not ativaSSL(sockPOP3) then
            begin
                mensagem ('CTSSLNAO', 2);   {'Segurança SSL não pode ser ativada'}
                fechaConexao (sockPOP3);
                goto erro;
            end;

    lidos := receive (sockPOP3, bufRecebe, BUFSIZE, 0);
    if (lidos <= 0) then
        goto erro;
    bufRecebe [lidos] := #$0;
    netDebug (bufRecebe, lidos);
    if (not trazerMudo) and (not acessoServidor) then
        mensagem ('CTPEGCOR', 1);  {'Pegando a correspondência'}
    StrPCopy (bufEnvia, 'USER '+ contaUsuario + CRLF);
    sendbuf (sockPOP3, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    lidos := receive (sockPOP3, bufRecebe, BUFSIZE, 0);
    if (lidos <= 0) then
        goto erro;

    while bufRecebe[lidos-1] <> #$0a do
        begin
            lidos := lidos + receive (sockPOP3, @bufRecebe[lidos], BUFSIZE, 0);
            bufRecebe [lidos] := #$0;
        end;

    bufRecebe [lidos] := #$0;

    if bufRecebe [0] <> '+' then
        begin
            mensagem ('CTACONT', 0);  {'A conta '}
            sintwrite (contaUsuario);
            mensagem ('CTNAOACE', 1);  {' não foi aceita, servidor falou assim'}
            sintWriteln (strPas (bufRecebe));
            goto erro;
        end
    else
        netDebug (bufRecebe, lidos);

        if trim (senhaSalva) = '' then
            begin
                senha := '';
                salvaAttr := textattr;
                textBackground (RED);
                mensagem ('CTINFSEN', 1);  {'Informe sua senha'}
                textBackground (BLACK);
                textColor (BLACK);
                c := sintEditaCampoMudo (senha, 1, wherey, 255, 80, true);
                writeln;
                textAttr := salvaAttr;
                if trim (senha) <> '' then senhaSalva := senha;
                if (c = ESC) or (trim(senhaSalva) = '') then goto erro;
            end;

    StrPCopy (bufEnvia, 'PASS '+ senhaSalva + CRLF);
    sendbuf (sockPOP3, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    lidos := receive (sockPOP3, bufRecebe, BUFSIZE, 0);
    if (lidos <= 0) then
        begin
            senhaSalva := '';
            goto erro;
        end;

    while bufRecebe[lidos-1] <> #$0a do
        begin
            lidos := lidos + receive (sockPOP3, @bufRecebe[lidos], BUFSIZE, 0);
            bufRecebe [lidos] := #$0;
        end;

    bufRecebe [lidos] := #$0;
    if bufRecebe [0] <> '+' then
        begin
            senhaSalva := '';
            mensagem ('CTASENHA', 0);  {'A senha '}
            mensagem ('CTNAOACE', 1);  {' não foi aceita, servidor falou assim'}
            sintWriteln (strPas (bufRecebe));
            goto erro;
        end;

    StrPCopy (bufEnvia, 'STAT' + CRLF);
    sendbuf (sockPOP3, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    lidos := receive (sockPOP3, bufRecebe, BUFSIZE, 0);
    if lidos <= 0 then
        goto erro;

    while bufRecebe[lidos-1] <> #$0a do
        begin
            lidos := lidos + receive (sockPOP3, @bufRecebe[lidos], BUFSIZE, 0);
            bufRecebe [lidos] := #$0;
        end;

    bufRecebe [lidos] := #$0;
    netDebug (bufRecebe, lidos);

    s := strPas (bufRecebe) + ' 0 0 ';   {sentinela}
    i := 1;
    while not (s[i] in ['0'..'9']) do i := i + 1;
    numCartasPOP3 := 0;
    while s[i] in ['0'..'9'] do
        begin
            numCartasPOP3 := (numCartasPOP3 * 10) + (ord(s[i]) - ord ('0'));
            i := i + 1;
        end;

    while not (s[i] in ['0'..'9']) do i := i + 1 ;
    numBytesPOP3 := 0;
    while s[i] in ['0'..'9'] do
        begin
            numBytesPOP3 := (numBytesPOP3 * 10) + (ord(s[i]) - ord ('0'));
            i := i + 1;
        end;

    if not trazerMudo then
        begin
            if numCartasPOP3 > 0 then
                falaQuantasNoServidor
            else
                mensagem ('CTNAOEXS', 2);  {'Não existem cartas no servidor.'}

            if numCartasPOP3 > 10 then
                begin
        deNovo:
                    repeat
                        textBackground (MAGENTA);
                        if acessoServidor then
                            mensagem ('CTMUQTFO', 0) {'São muitas cartas, quantas deseja folhear?'}
                        else
                            mensagem ('CTMUICAR', 0); {'São muitas cartas, quantas trago agora ? '}
                        textBackground (BLACK);
                        s := '';
                        c := sintEditaCampo (s, wherex, wherey, 255, 80, true);
                        writeln;
                        if not (c in [ENTER, ESC]) then
                            falaQuantasNoServidor;
                    until c in [ENTER, ESC];
                    if acessoGrupoContas then
                        if s = '0' then
                            begin
                                result := true;
                                numCartasPOP3 := 0;
                                exit;
                            end;
                    if (c = ESC) or (s = '0') then goto erro;
                    s2 := s;
                    numCartasPOP3Aux := numCartasPOP3;
                    totalCartasATrazer := 0;
                    if (s <> '') and (pos (';', s) = 0) then
                        begin
                            val (s, i, posErro);
                            if (posErro = 0) and (i > 0) and (i <= numCartasPOP3) then
                                totalCartasATrazer := i;
                        end
                    else
                        begin
                            s := copy (s, 1, pos(';', s)-1);
                            delete (s2, 1, pos (';', s2));
                            val (s, i, posErro);
                            if (posErro = 0) and (i > 0) and (numCartasPOP3 > i) then
                                primeiraCartaPop3 := i;
                        end;

                    val (s2, i, posErro);
                    if (posErro = 0) and (i > 0) and (i <= numCartasPOP3) then
                        numCartasPOP3 := i;
                end;
            limpaBufTec;

            if (numCartasPOP3 > 0) and (not acessoServidor) then
                begin
                    repeat
                        mensagem ('CTSELINT', 0);  {'Quer selecionar interativamente ? '}
                        c := upcase(popupMenuPorLetra ('SNGT'));
                        writeln;
                        if not (c in ['S', 'N', ENTER, ESC, 'G', 'T']) then
                            falaQuantasNoServidor;
                    until c in ['S', 'N', ENTER, ESC, 'G', 'T'];
                    if c = ESC then goto erro;
                    interativoPOP3 := c = 'S';
                    ignoraTodas := c = 'G';
                    recebeTodas := c = 'T';

                    if     (interativoPOP3) and (totalCartasATrazer > 0) and (uppercase(sintAmbiente('CARTAVOX', 'INVERTERORDEMRECEBIMENTOINTERATIVO', 'NAO')[1]) = 'S') then
                        begin
                            numCartasPOP3 := numCartasPOP3Aux;
                            primeiraCartaPop3 := numCartasPOP3Aux - totalCartasATrazer + 1;
                        end;
                end;
        end;

    result := true;
    exit;

erro:
end;

{-------------------------------------------------------------}
{       pega o tamanho da carta
{-------------------------------------------------------------}

function pegaTamanhoCarta (qual: integer): longint;
var
    s: string;
    lidos: integer;
    tamanho: longint;
    i: integer;
begin
    pegaTamanhoCarta := 0;

    str (qual, s);
    StrPCopy (bufEnvia, 'LIST ' + s + CRLF);
    sendbuf (sockPOP3, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    lidos := receive (sockPOP3, bufRecebe, BUFSIZE, 0);
    if (lidos <= 0) then
        exit;
    bufRecebe [lidos] := #$0;
    netDebug (bufRecebe, strlen (bufRecebe));
    if bufRecebe [0] <> '+' then
        begin
            sintWriteln ('Bug na carta: ' + intToStr (qual) + ':' + strPas(bufRecebe));
            exit;
        end;

    s := strPas (bufRecebe) + ' 0 0 ' ;  { sentinela }
    i := 1;
    while not (s[i] in ['0'..'9']) do i := i + 1;
    while (s[i] in ['0'..'9']) do i := i + 1;
    while not (s[i] in ['0'..'9']) do i := i + 1;
    tamanho := 0;
    while s[i] in ['0'..'9'] do
        begin
            tamanho := (tamanho * 10) + (ord(s[i]) - ord ('0'));
            i := i + 1;
        end;

    pegaTamanhoCarta := tamanho;
end;

{-------------------------------------------------------------}
{       Apaga uma carta do servidor
{-------------------------------------------------------------}

function apagarCartaServidor(qual: integer): integer;
var
    s: string;
    lidos: integer;

label erro;
begin
    if keypressed then //Cancelamento
        if trataTecla (pegaTamanhoCarta(qual), 0) = #$1b then
            goto erro;

    str (qual, s);
    StrPCopy (bufEnvia, 'DELE ' + s + CRLF);
    sendbuf (sockPOP3, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    lidos := receive (sockPOP3, bufRecebe, BUFSIZE, 0);
    if bufRecebe[0] <> '+' then
        begin
            mensagem ('CTERRSRV', 1);   {'Erro no servidor, veja o que ele disse:'}
            sintWriteln (strPas(bufRecebe));
            goto erro;
        end;
    if lidos > 0 then
        begin
            bufRecebe [lidos] := #$0;
            netDebug (bufRecebe, lidos);
        end;

    apagarCartaServidor := COD_OK;
    exit;

erro:
    apagarCartaServidor := COD_CANCELA;
end;

{-------------------------------------------------------------}
{       Ajuda das opções do recebimento interativo
{-------------------------------------------------------------}

procedure ajudaOpcInterativa;
begin
    telaPrincipal;
    textBackground (BLUE);
    mensagem ('CTAJUD01', 0); {'As opções são:'}
    textBackground (BLACK);
    writeln;
    mensagem ('CTAJIN01', 1); {'ENTER ou S - Traz a carta'}
    mensagem ('CTAJIN02', 1); {'N - Não traz a carta'}
    mensagem ('CTAJIN03', 1); {'D - Liga ou desliga o debug'}
    mensagem ('CTAJIN04', 1); {'G - Ignora todas as cartas grandes'}
    mensagem ('CTAJIN05', 1); {'T - Traz todas as cartas'}
    mensagem ('CTAJIN06', 1); {'I - Informações sobre a carta'}
    mensagem ('CTAJEN07', 1); {'ESC - Cancela'}
    if keypressed and (readkey <> ESC) then
        begin
            limpaBufTec;
            readkey;
        end;
    limpaBufTec;
    telaPrincipal;
end;

{-------------------------------------------------------------}
{       Seleciona as opções do recebimento interativo com as setas
{-------------------------------------------------------------}

function selSetasOpcInterativa: char;
var
    n: integer;
const
    tabOpcInterativa: string [10] = 'SNDGTIAZQ'+ESC;
begin
    popupMenuCria (35, wherey, 50, 10, RED);
    MenuAdiciona ('CTAJIN01'); {'ENTER ou S - Traz a carta'}
    MenuAdiciona ('CTAJIN02'); {'N - Não traz a carta'}
    MenuAdiciona ('CTAJIN03'); {'D - Liga ou desliga o debug'}
    MenuAdiciona ('CTAJIN04'); {'G - Ignora todas as cartas grandes'}
    MenuAdiciona ('CTAJIN05'); {'T - Traz todas as cartas'}
    MenuAdiciona ('CTAJIN06'); {'I - Informações sobre a carta'}
    MenuAdiciona ('CTAJIN07'); {'A - Assunto da carta'}
    MenuAdiciona ('CTAJIN08'); {'Z - Tamanho da carta'}
    MenuAdiciona ('CTAJUD10'); {'Q - Informar total de cartas'}
    MenuAdiciona ( 'CTAJEN07'); {'ESC - Cancela'}

    n := popupMenuSeleciona;

    if (n > 0) and (n <= 10) then
        selSetasOpcInterativa := tabOpcinterativa[n]
    else
        selSetasOpcInterativa := #0;
end;

{-------------------------------------------------------------}
{       pega uma carta
{-------------------------------------------------------------}

function pegaUmaCartaPOP3 (qual, nCar: integer; apagarDoServidor: boolean): integer;
var
    s, nomeTemp, nomeArqRecebe: string;
    autor, email, assunto, data, reply_to, copiasCarbono: ShortString;
    temAnexo: boolean;
    tempPath, tempFileName: array [0..144] of char;
    arq: text;
    arqFile: file;
    x: integer;
    c1, c2: char;
    tamanhoAFalar: longint;

label erroDisco, pula, trazTodas;

    {-------------------------------------------------------------}

    procedure falaCartaInterativa;
    begin
        if temAnexo then sintBip;
        if trim (autor) = '' then
            sintwriteln (email)
        else
            sintWriteln (autor);
        if sintFalarTudo then
            mensagem ('CTASSUNT', 0);  {'Assunto '}
        sintWriteln (assunto);
        if (tamanhoAFalar > 1000000) or (tamanhoAFalar > maxTamAuto) then
            begin
                mensagem ('CTTAMAN', 0); {'Tamanho '}
                sintWriteln (formataTamanhoArq (tamanhoAFalar));
            end;
    end;

    {-------------------------------------------------------------}

    procedure informaCartaInterativa;
    var tamanhoCarta: shortString;
    begin
        limpaParteTela (2, 25);
        mensagem('CTUTSETA', 1); {'Utilize as setas, tecle ESC para sair'}
        delay(10);
        gotoxy (1, 5);
        tamanhoCarta := formataTamanhoArq (tamanhoAFalar);
        formCria;
        formCampo     ('CTENVPOR', 'Autor: ', autor, 50);
        formCampo     ('CTEMAIL', 'e-mail: ', email, 50);
        formCampo     ('CTASSUNT', 'Assunto: ', assunto, 70);
        formCampo     ('CTDATENV', 'Data de envio: ', data, 50);
        formCampo     ('CTTAMAN', 'Tamanho da carta: ', tamanhoCarta, 15);
        if reply_to <> '' then
            formCampo     ('CTENCPAR', 'Encaminhada para: ', reply_to, 50);
        formCampoBool ('CTCOMANE',  'Contem anexo: ',  temAnexo);
        if copiasCarbono <> '' then
            formCampo     ('CTCOPCAR', 'Cópias carbono: ', copiasCarbono, 50);

        formEdita (false);
        mensagem ('CTOK', -1); {'OK'}
        limpabuftec;
    end;

    {-------------------------------------------------------------}

begin
    pegaUmaCartaPOP3 := COD_OK;
    tamanhoAFalar := pegaTamanhoCarta (qual);

    if recebeTodas then
        goto trazTodas
    else
    if (ignoraTodas) and (tamanhoAFalar > maxTamAuto) then
        begin
            pegaUmaCartaPOP3 := COD_DESIST;
            exit;
        end
    else
    if ignoraTodas then
        goto trazTodas;

    if interativoPOP3 or (tamanhoAFalar > maxTamAuto) then
        begin
            str (qual, s);
            StrPCopy (bufEnvia, 'TOP ' + s + ' 0' + CRLF);
            sendbuf (sockPOP3, bufEnvia, strlen (bufEnvia), 0);
            netDebug (bufEnvia, strlen (bufEnvia));

            getTempPath (144, tempPath);
            getTempFileName(tempPath, 'xxx', 0, tempFileName);
            nomeTemp := strPas (tempFileName);
            if not multiLineReceive (nomeTemp, tamanhoAFalar) then
                begin
erroDisco:
                    mensagem ('CTERRTMP', 2);  {'Problemas no arquivo temporário'}
                    pegaUmaCartaPOP3 := COD_ERRODISCO;
                    exit;
                end;

            if nCar = 0 then
                begin
                    numRegs := 1;
                    nCar := 1;
                    regLido [numRegs] := inicializaPEstrutura;
                    regLido [numRegs]^.carta := inicializaPCarta;
                end;
            regLido [nCar]^.carta^.nomArqCarta := nomeTemp;
            regLido [nCar]^.carta^.tamanho := tamanhoAFalar;
            if not carregaArqPreencheCabPrin (nCar) then goto erroDisco;

            autor := regLido [nCar]^.carta^.from;
            x := pos ('<', autor);
            if x > 1 then autor := copy (autor, 1, x-1);
            deletaMenorMaiorShort (autor);
            deletaAspasShort (autor);
            email := regLido [nCar]^.carta^.from;
            x := pos ('<', email);
            if x > 1 then email := copy (email, x + 1, length(email) - x);
            deletaMenorMaiorShort (email);
            deletaAspasShort (email);
            if email = '' then email := regLido [nCar]^.carta^.from;
            assunto := regLido [nCar]^.carta^.subject;
            assunto := pegaPrefixoAssunto(assunto) + limpaAssunto(assunto);
            deletaAspasShort (assunto);
            if assunto = '' then assunto := regLido [nCar]^.carta^.subject;
            data :=converteData (regLido [nCar]^.carta^.date, true);
            reply_to := regLido [nCar]^.carta^.reply_to;
            copiasCarbono := regLido [nCar]^.carta^.cc;
            temAnexo := regLido [nCar]^.boundary <> '';

            assign (arq, nomeTemp);
            {$I-}  erase (arq);  {$I+}
            if ioresult <> 0 then ;

            c1 := 'a';
            repeat
                if c1 <> #0 then
                    falaCartaInterativa;
                mensagem ('CTPODTRA', 0);  {'Quer trazer ? '}
                sintLeTecla (c1, c2);

                if c1 = #0 then
                    case c2 of
                        F1: ajudaOpcInterativa;
                        F8:     falaHora;
                        CTLF8:   falaDia;
                        BAIX, CIMA: c1 := selSetasOpcInterativa;
                        ESQ: falaAssunto (nCar, false, false, true);
                        CTLESQ: sintetiza(regLido [nCar]^.carta^.from);
                    end;

                case upcase (c1) of
                    'S', ENTER:; //Baixa a carta do provedor.
                    'N':    begin
                                pegaUmaCartaPOP3 := COD_DESIST;
                                repeat
                                    mensagem ('CTAPGCAR', 0);  {'Apago do servidor '}
                                    mensagem ('CTSIMNAO', 0);  {'(S/N) ?'}
                                    c1 := upcase(popupMenuPorLetra ('SN'));
                                    writeln;
                                    until upcase (c1) in ['S', 'N', ENTER, ESC, #0];
                                if upcase(c1) = 'S' then
                                    apagarCartaServidor (qual);
                                if c1 <> #0 then
                                    exit;
                            end;

                    'D':    begin
                                debug := not debug;
                                if (debug) and (pos ('@gmail.com', enderUsuario) <> 0) then
                                    begin
                                        mensagem('CTOPINSE', 1); {'Opção indisponível neste servidor'}
                                        debug := false;
                                        msgBaixo ('CTMODNOR');  {'Modo normal'}
                                    end
                                else
                                if debug then
                                    msgBaixo ('CTMODDEB')   {'Modo debug: cartas não serão apagadas'}
                                else
                                    msgBaixo ('CTMODNOR');  {'Modo normal'}
                            end;

                    'G':    begin
                                ignoraTodas := true;
                                pegaUmaCartaPOP3 := COD_DESIST;
                                exit;
                            end;

                    'T':    recebeTodas := true;
                    'I': informaCartaInterativa;
                    'Q': sintetiza(intToStr(qual) + ' de ' + intToStr(totalDeCartas));
                    ESC:   begin
                                pegaUmaCartaPOP3 := COD_CANCELA;
                                exit;
                            end;

                    'A', ^A:
                            begin
                                if temAnexo then sintBip;
                                if c1 = ^A then
                                    falaAssunto (nCar, false, false, true)
                                else
                                    sintetiza (assunto);
                                c1 := #0;
                            end;

                    'Z':    begin
                                mensagem ('CTTAMAN', -1); {'Tamanho '}
                                sintetiza (formataTamanhoArq (tamanhoAFalar));
                                c1 := #0;
                            end;

                    #0: if not (c2 in [F8, CTLF8, ESQ, CTLESQ]) then
                            c1 := 'a'; //Fala remetente e assunto.

                else
                    mensagem ('CTOPVINV', 1); {'Opção inválida, aperte F1 para ajuda'}
                end;
            until upcase (c1) in ['S', ENTER, 'T'];
        end;

    {--- pega finalmente a carta ---}

trazTodas:
    s := intToStr (qual);
    StrPCopy (bufEnvia, 'RETR ' + s + CRLF);
    sendbuf (sockPOP3, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    nomeArqRecebe := novoNomeCarta (nbaseRecebe, dirRecebe, '.$$$');
    try
        if not multiLineReceive (nomeArqRecebe, tamanhoAFalar) then
            begin
                pegaUmaCartaPOP3 := COD_CANCELA;
                exit;
            end;
    except
        sintetiza ('Erro ao baixar a carta '  + intToStr(qual));
        pegaUmaCartaPOP3 := COD_CANCELA;
        exit;
    end;

    assignFile (arqFile, nomeArqRecebe);
    {$I-} rename (arqFile, copy(nomeArqRecebe, 1, length(nomeArqRecebe)-3) + 'car');  {$I+}
    if ioresult <> 0 then
        msgBaixo ('CTPROGRV')  {'Problemas para gravar carta no disco'}
    else
    if (not debug) and (apagarDoServidor) then
        apagarCartaServidor (qual);

    if nCar > 0 then
        regLido [nCar]^.carta^.nomArqCarta := copy(nomeArqRecebe, 1, length(nomeArqRecebe)-3) + 'car';
end;

{-------------------------------------------------------------}
{       Finaliza o pop3
{-------------------------------------------------------------}

function finalizaPop3: boolean;
var lidos: integer;
begin
    finalizaPop3 := false;
    if (debug) or (naoApagaCarta) then
        begin
            StrPCopy (bufEnvia, 'RSET' + CRLF);
            sendbuf (sockPOP3, bufEnvia, strlen (bufEnvia), 0);
            netDebug (bufEnvia, strlen (bufEnvia));
            lidos := receive (sockPOP3, bufRecebe, BUFSIZE, 0);
            netDebug (bufRecebe, lidos);
        end;

    StrPCopy (bufEnvia, 'QUIT' + CRLF);
    sendbuf (sockPOP3, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    lidos := receive (sockPOP3, bufRecebe, BUFSIZE, 0);
    if lidos <= 0 then
        exit;
    bufRecebe [lidos] := #$0;
    netDebug (bufRecebe, lidos);
    finalizaPop3 := true;
end;

{-------------------------------------------------------------}
{  Pega uma carta temporária do servidor, o número da carta
{  é passado através do parâmetro 'qual'.
{-------------------------------------------------------------}

function pegaUmaCartaTempPOP3 (qual: integer): integer;
var
    s, nomeTemp: string;
    tamanhoAFalar: longint;
begin
    pegaUmaCartaTempPOP3 := COD_OK;
    tamanhoAFalar := pegaTamanhoCarta (qual);

    str (qual, s);
    StrPCopy (bufEnvia, 'TOP ' + s + ' 0' + CRLF);
    sendbuf (sockPOP3, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    nomeTemp := novoNomeCarta (nbaseRecebe, dirRecebe, '.tmp');
    if not multiLineReceive (nomeTemp, tamanhoAFalar) then
        begin
            pegaUmaCartaTempPOP3 := COD_ERRODISCO;
            deletaArquivo(nomeTemp);
            exit;
        end;

    adicionaUmRegCarta( nomeTemp, tamanhoAFalar, pegaDataArq (nomeTemp), cartasTrazidas, qual);
end;

{-------------------------------------------------------------}
{        Pega uma carta para a resposta automática
{-------------------------------------------------------------}

function pegaUmaCartaPOP3RespAut (qual: integer): integer;
var
    s, nomeArq, nomeArqRecebe: string;
    arqFile: file;
    tamanhoAFalar: longint;

label erroDisco;
begin
    pegaUmaCartaPOP3RespAut := COD_OK;
    tamanhoAFalar := pegaTamanhoCarta (qual);
    s := intToStr (qual);
    StrPCopy (bufEnvia, 'RETR ' + s + CRLF);
    sendbuf (sockPOP3, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    nomeArqRecebe := novoNomeCarta (nbaseRecebe, dirRecebe, '.$$$');
    if not multiLineReceive (nomeArqRecebe, tamanhoAFalar) then
        pegaUmaCartaPOP3RespAut := COD_ERRO
    else
        begin
            nomeArq := copy(nomeArqRecebe, 1, length(nomeArqRecebe)-3) + 'car';
            assignFile (arqFile, nomeArqRecebe);
            {$I-} rename (arqFile, nomeArq); {$I+}
            if ioresult <> 0 then
                goto erroDisco
            else
            if not debug then
                apagarCartaServidor (qual);

            adicionaUmRegCarta(nomeArq, tamanhoAFalar, pegaDataArq (nomeArq), 1, 0);
            if not carregaArqPreencheCabPrin (1) then
                pegaUmaCartaPOP3RespAut := COD_ERRO
            else
            if not prepararCartaRespAut (1, true) then
                pegaUmaCartaPOP3RespAut := COD_ERRO
            else
            if not enviarUmaCarta (regLido[1]^.carta^.nomArqCartaEnviar, true) then
                pegaUmaCartaPOP3RespAut := COD_ERRO;
            desmontaTudo (regLido [1]);
        end;

    exit;
erroDisco:
    msgBaixo ('CTPROGRV'); {'Problemas para gravar carta no disco'}
    pegaUmaCartaPOP3RespAut := COD_ERRO;
end;

{-------------------------------------------------------------}
{       comunicação com o servidor POP3
{-------------------------------------------------------------}

function receberCartas (opcaoMudo, apertouShift: boolean): integer;
var
    ncar, codPega: integer;
    apagadasDoServidor: integer;
    c1: char;
    chegoulaco: boolean;

    function tratamentoReceberCartas: boolean;
    label  erro, laco;
    begin
    laco:
    result := true;
        cartasTrazidas := ncar;
        setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Recebendo... ' + intToStr(nCar) + ' de ' + intToStr( totalDeCartas));
        textBackGround (BROWN);
        if sintFalarTudo and (interativoPOP3 and (not (ignoraTodas or recebetodas))) or
           (not mudo and (ignoraTodas or recebetodas)) then
            begin
                mensagem ('CTCARTA', 0);  {'carta'}
                sintWriteint (ncar);
            end
        else
            write ('Carta ', ncar);
        textBackGround (BLACK);
        writeln;
////            try
            codPega := pegaUmaCartaPOP3 (ncar - apagadasDoServidor, 0, true);
////            except
////                sintetiza ('Erro ao baixar a carta '  + intToStr(ncar));
////                codPega := COD_CANCELA;
////            end;
        if codPega = COD_CANCELA then chegoulaco := true;
        if chegoulaco then
            begin
                repeat
                    writeln;
                    mensagem ('CTCANREC', 0); {'Deseja cancelar o recebimento das cartas?:'}
                    c1 := popupMenuPorLetra ('SN');
                until c1 in ['S', 'N', ENTER, ESC];
                if c1 in ['N', ESC] then
                    goto laco;
            end;
        if codPega in [COD_CANCELA, COD_ERRODISCO]  then goto erro;

        if (esperaPOP3 >= 0) and (not interativoPop3) and (not debug) and
            ((ncar mod quantasReceber) = 0) and (nCar < numCartasPOP3) then
            begin
                if not finalizaPop3 then goto erro;
                fechaConexao (sockPOP3);
                delay (esperaPOP3);
                if not inicializaPOP3 then goto erro;
                apagadasDoServidor := apagadasDoServidor + quantasReceber;
            end;

        exit;
    erro:
        result := false;
    end;

label erro;
begin
    receberCartas := 0;
    if (debug) and (pos ('@gmail.com', enderUsuario) <> 0) then
        begin
            mensagem('CTOPINSE', 1); {'Opção indisponível neste servidor'}
            debug := false;
            msgBaixo ('CTMODNOR');  {'Modo normal'}
            exit;
        end;

    chegoulaco := false;
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Recebendo...');
    codPega := 0;
    trazerMudo := opcaoMudo;
    mudo := not clek;

    interativoPOP3 := apertouShift; //false;
    ignoraTodas := false;
    recebeTodas := false;
    primeiraCartaPop3 := 1;
    apagadasDoServidor := 0;

    telaPrincipal;
    textBackground (MAGENTA);
    if trazerMudo  then
    write (pegaTextoMensagem ('CTCONTAC'))  {'Contactando servidor para receber correspondência'}
    else
        mensagem ('CTCONTAC', 1);  {'Contactando servidor para receber correspondência'}
    textBackGround (BLACK);
    writeln;

    if not inicializaPOP3 then goto erro;

    totalDeCartas := numCartasPop3;
    trazerMudo := true;

    if     (not interativoPOP3) or (uppercase(sintAmbiente('CARTAVOX', 'INVERTERORDEMRECEBIMENTOINTERATIVO', 'NAO')[1]) <> 'S') then //NenoNeno
        for ncar := primeiraCartaPop3 to numCartasPOP3 do
            begin
                if not tratamentoReceberCartas then goto erro;
            end
    else
        for ncar := numCartasPOP3 downto primeiraCartaPop3 do
            if not tratamentoReceberCartas then goto erro;

    if not     finalizaPop3 then goto erro;
    if codPega = COD_CANCELA then goto erro;

    fechaConexao (sockPOP3);
    if (numCartasPop3 > 0) and not opcaoMudo then
        mensagem ('CTOKPEG', 1);  {'Ok, peguei a correspondência'}
    if numCartasPop3 > 0 then
        receberCartas := cartasTrazidas;

    if (aplicRegras) and (numCartasPop3 > 0) then
        aplicarRegrasCartas(true, false);

    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
    exit;

erro:
    if sockPOP3 >= 0 then
        fechaConexao (sockPOP3);
    writeln;
    while keypressed do readkey;
    mensagem ('CTCONCAN', 2);  {'Conexao com servidor foi cancelada'}
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
end;

{-------------------------------------------------------------}
{  Comunicação com o servidor POP3 para a resposta automática
{-------------------------------------------------------------}

function receberCartasRespAut(cartasExistentes, cartasChegadas: integer): integer;
var
    codPega: integer;
    cartasRecebidas, totalCartas: integer;

label  erro;
begin
    receberCartasRespAut := 0;
    if (debug) and (pos ('@gmail.com', enderUsuario) <> 0) then
        begin
            mensagem('CTOPINSE', 1); {'Opção indisponível neste servidor'}
            debug := false;
            msgBaixo ('CTMODNOR');  {'Modo normal'}
            exit;
        end;

    cartasRecebidas := 0;
    totalCartas := cartasChegadas;
    trazerMudo := true;
    mudo := true;

    if not inicializaPOP3 then goto erro;

    while cartasChegadas > cartasExistentes do
        begin
            setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Recebendo... ' + intToStr(cartasRecebidas + 1) + ' de ' + intToStr(totalCartas));
            codPega := pegaUmaCartaPOP3RespAut (cartasChegadas);
            if codPega = COD_ERRO then goto erro;
            if codPega = COD_OK then cartasRecebidas := cartasRecebidas + 1;
            cartasChegadas := cartasChegadas - 1;
        end;

    if not     finalizaPop3 then goto erro;
    fechaConexao (sockPOP3);
    receberCartasRespAut := cartasRecebidas;

    if (aplicRegras) and (cartasRecebidas > 0) then
        aplicarRegrasCartas(true, false);
    exit;

erro:
    if sockPOP3 >= 0 then
        fechaConexao (sockPOP3);
    writeln;
    limpaBufTec;
    mensagem ('CTCONCAN', 1);  {'Conexao com servidor foi cancelada'}
    receberCartasRespAut := -1;
            setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
end;

{-------------------------------------------------------------}
{       Comunicação com o servidor POP3 para receber cartas temporárias
{       Montagem da lista do folheamento interativo no servidor
{-------------------------------------------------------------}

function receberCartasServidor (opcaoMudo: boolean): boolean;
var
    ncar, codPega: integer;

label erro;
begin
    receberCartasServidor := true;
    trazerMudo := opcaoMudo;
    mudo := not clek;
    primeiraCartaPop3 := 1;
    acessoServidor := true;

    telaPrincipal;
    textBackground (MAGENTA);
    if trazerMudo then
        writeln(pegatextomensagem('CTCONTAC'))  {'Contactando servidor para receber correspondência'}
    else
        mensagem ('CTCONTAC', 1);  {'Contactando servidor para receber correspondência'}
    writeln;
    textBackGround (BLACK);

    if not inicializaPOP3 then goto erro;

    acessoServidor := false;
    cartasTrazidas := 0;
    totalDeCartas := numCartasPop3;
    if (totalDeCartas > 10) and (trazerMudo) then sintclek
    else
    if totalDeCartas > 10 then
        msgBaixo ('CTMOMENT');   {'Um momento...  '}

    for ncar := primeiraCartaPop3 to numCartasPOP3 do
        begin
            cartasTrazidas := cartasTrazidas + 1;
            setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Recebendo... ' + intToStr(nCar) + ' de ' + intToStr(totalDeCartas));
            codPega := pegaUmaCartaTempPOP3(ncar);
            if codPega = COD_ERRODISCO then goto erro;
        end;

    if not finalizaPop3 then goto erro;
    fechaConexao (sockPOP3);

    if cartasTrazidas > 0 then
        setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Folheando servidor...');
    exit;

erro:
    receberCartasServidor := false;
    acessoServidor := false;
    if sockPOP3 >= 0 then
        fechaConexao (sockPOP3);
    writeln;
    limpaBufTec;
    mensagem ('CTCONCAN', 1);  {'Conexao com servidor foi cancelada'}
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
end;

{-------------------------------------------------------------}
{  comunicação com o servidor POP3 para o grupo de contas
{-------------------------------------------------------------}

function receberCartasGrupoContas (apertouShift, opcaoMudo: boolean): integer;
var
    ncar, codPega: integer;
    apagadasDoServidor: integer;
    c1: char;
    chegoulaco: boolean;

label  erro, laco;
begin
    chegoulaco := false;
    ncar := 0;
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Recebendo...');
    receberCartasGrupoContas := -1;
    codPega := COD_OK;
    trazerMudo := opcaoMudo;
        mudo := not clek;

    interativoPOP3 := apertouShift;
    ignoraTodas := false;
    recebeTodas := false;
    primeiraCartaPop3 := 1;
    apagadasDoServidor := 0;

    telaPrincipal;
    textBackground (MAGENTA);
    if trazerMudo  then
        write('Acessando conta ' + nomeConfiguracao)
    else
        begin
            mensagem ('CTCONTAC', 0); {'Contactando servidor para receber correspondência'}
            sintWriteln(nomeConfiguracao);
        end;
    textBackGround (BLACK);
    writeln;

    acessoGrupoContas := true;
    if not inicializaPOP3 then goto erro;
    acessoGrupoContas := false;
    totalDeCartas := numCartasPop3;
    trazerMudo := true;
    for ncar := primeiraCartaPop3 to numCartasPOP3 do
laco:
        begin
            cartasTrazidas := ncar;
            setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Recebendo... ' + intToStr(nCar) + ' de ' + intToStr(totalDeCartas));
            textBackGround (BROWN);
            if sintFalarTudo and (interativoPOP3 and (not (ignoraTodas or recebetodas))) or
               (not mudo and (ignoraTodas or recebetodas)) then
                begin
                    mensagem ('CTCARTA', 0);  {'carta'}
                    write (' ');
                    sintWriteint (ncar);
                end
            else
                write ('Carta ', ncar);

            textBackGround (BLACK);
            writeln;

            codPega := pegaUmaCartaPOP3 (ncar - apagadasDoServidor, 0, true);
            if codPega = COD_CANCELA then
                chegoulaco := true;
            if codPega in [COD_CANCELA, COD_ERRODISCO]  then goto erro;

            if (esperaPOP3 >= 0) and (not interativoPop3) and (not debug) and
                ((ncar mod quantasReceber) = 0) and (nCar < numCartasPOP3) then
                begin
                    if not finalizaPop3 then goto erro;
                    fechaConexao (sockPOP3);
                    delay (esperaPOP3);
                    if not inicializaPOP3 then goto erro;
                    apagadasDoServidor := apagadasDoServidor + quantasReceber;
                end;
        end;

    ncar := 0;
    if not     finalizaPop3 then goto erro;
    if codPega = COD_CANCELA then goto erro;

    fechaConexao (sockPOP3);
    if (numCartasPop3 > 0) and not opcaoMudo then
        mensagem ('CTOKPEG', 1);  {'Ok, peguei a correspondência'}
    if numCartasPop3 >= 0 then
        receberCartasGrupoContas := numCartasPop3;

    if (aplicRegras) and (numCartasPop3 > 0) then
        aplicarRegrasCartas(true, false);

    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
    exit;

erro:
    if chegoulaco then
    begin
        repeat
            writeln;
            mensagem ('CTCANREC', 0); {'Deseja cancelar o recebimento das cartas?:'}
            c1 := readkey ;
        until upcase (c1) in ['S', 'N', ENTER, ESC];
        if upcase (c1) in ['N', ESC] then
            goto laco;
    end;
    if sockPOP3 >= 0 then
        fechaConexao (sockPOP3);
    writeln;
    while keypressed do readkey;
    acessoGrupoContas := false;
    mensagem ('CTCONCAN', 2);  {'Conexao com servidor foi cancelada'}
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
end;

{-------------------------------------------------------------}
{       Atualiza a posição da carta do servidor no regLido, utilizado ao apagar uma.
{-------------------------------------------------------------}

procedure atualizaPosServ (numCarta: integer);
var i: integer;
begin
    for i := 1 to numRegs do
        if regLido[i]^.posServ > regLido[numCarta]^.posServ then
            regLido[i]^.posServ := regLido[i]^.posServ -1;
end;

{----------------------------------------------------------------------}
{  Traz e apaga as cartas do servidor ou simplismente apaga as cartas
{  do servidor
{  Parâmetros:
{  nCar - indica o número da carta na lista cujo cursor está em cima.
{  trazer - se verdadeiro, as cartas são trazidas e apagadas, se falso,
{  as cartas somente são apagadas.
{   apagarDoServidor - Se false, as cartas não serão apagadas do servidor.
{----------------------------------------------------------------------}

function trazEApagaCartasServidor(nCar: integer; trazer, apagarDoServidor: boolean): integer;
var
    laco, codPega: integer;
    c: char;
    trazerSelecionados: boolean;

    function executarOTrazerApagar (numCarta: integer): boolean;
    var arqTemporario: boolean;
    label sair;
    begin
        executarOTrazerApagar := true;
        if trazer then
            setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Recebendo... ' + intToStr(cartasTrazidas) + ' de ' + intToStr(totalDeCartas))
        else
            setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Apagando ... ' + intToStr(cartasTrazidas) + ' de ' + intToStr(totalDeCartas));

        arqTemporario := maiuscansi(retornaExtensao(regLido [numCarta]^.carta^.nomArqCarta)) = 'TMP';
        if arqTemporario then
                if not apagaCarta (numCarta, false) then goto sair;

        if trazer then
            begin
//  Só vai trazer se tiver o tmp no computador
                if  arqTemporario then
                    codPega := pegaUmaCartaPOP3 (regLido[numCarta]^.posServ, numCarta, apagarDoServidor)
                else
                if apagarDoServidor then
                    codPega := apagarCartaServidor (regLido[numCarta]^.posServ);
            end
        else
            codPega := apagarCartaServidor (regLido[numCarta]^.posServ);
        if codPega in [COD_ERRODISCO, COD_CANCELA] then goto sair;

        if apagarDoServidor then
            begin
                atualizaPosServ (numCarta);
                nCar := apagaUmRegs(numCarta);
            end;

        exit;
    sair:
        executarOTrazerApagar := false;
    end;

label fim, erro;
begin
    if (trazer) and (not apagarDoServidor) and (pos ('@gmail.com', enderUsuario) <> 0) then
        begin
            mensagem('CTOPINSE', 1); {'Opção indisponível neste servidor'}
            goto fim;
        end;

    if trazer then
        setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Recebendo...')
    else
        setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Apagando...');

    codPega := COD_OK;
    trazerMudo := true;
    mudo := not clek;
    interativoPOP3 := false;
    ignoraTodas := false;
    recebeTodas := true;

    trazerSelecionados := false;
    c := 'N';
    if temItemSelecionado then
        begin
            repeat
                if trazer then
                    msgBaixo ('CTDETZSE') {'Deseja trazer todas as selecionadas?'}
                else
                    msgBaixo ('CTAPASEL');   {'Deseja apagar as selecionadas? '}
                c := upcase(popupMenuPorLetra ('SN'));
                writeln;
            until c in ['S', 'N', ENTER, ESC];

            if c = 'S' then
                trazerSelecionados := true;
        end;
    if (not trazerSelecionados) and (c = 'N') then
        repeat
            gotoxy (1, 20);
            if trazer then
                mensagem ('CTDETZAS', 0) {'Deseja trazer a carta com o assunto '}
            else
                mensagem ('CTCNFAPA', 1);  {'Confirma o apagamento desta carta com assunto'}
            if trim (regLido [nCar]^.carta^.subject) = '' then
                sintWriteLn ('Nulo')
                else
                sintWriteln (regLido [nCar]^.carta^.subject);
            mensagem ('CTSIMNAO', 0);  {'(S/N)'}
            write ('?');
            c := upcase(popupMenuPorLetra ('SN'));
            writeln (c);
        until c in ['S', 'N', ENTER, ESC];

    if (c = ESC) or ((not trazerSelecionados) and (c <> 'S')) then
        begin
            msgBaixo ('CTDESIST'); {'Desistiu'}
            goto fim;
    end;

    if not inicializaPOP3 then goto erro;

    if trazerSelecionados then
        begin
            totalDeCartas := totalDeItensSelecionados;
            cartasTrazidas := 0;
            laco := numRegs;
            while laco > 0 do
                begin
                    if regLido[laco]^.selecionado then
                        begin
                            cartasTrazidas := cartasTrazidas + 1;
                            if not executarOTrazerApagar (laco) then goto fim;
                        end;
                    laco := laco - 1;
                end;
        end
    else
        begin
            totalDeCartas := 1;
            cartasTrazidas := 1;
            if not executarOTrazerApagar (nCar) then goto fim;
        end;

    if not     finalizaPop3 then goto erro;
    fechaConexao (sockPOP3);

    if trazer then msgBaixo('CTOKPEG')  {'Ok, peguei a correspondência'}
    else
    if totalDeCartas > 1 then msgBaixo('CTOKAPAS') {'Ok, cartas apagadas'}
    else msgBaixo ('CTOKAPA');  {'Ok, carta apagada'}
    if nCar < 0 then nCar := 0
    else if nCar > numRegs then nCar := numRegs;

fim:
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Folheando servidor...');
    trazEApagaCartasServidor := nCar;
    limpabuftec;
    exit;

erro:
    if sockPOP3 >= 0 then
        fechaConexao (sockPOP3);
    while keypressed do readkey;
    msgBaixo ('CTCONCAN');  {'Conexao com servidor foi cancelada'}
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Folheando servidor...');
    trazEApagaCartasServidor := nCar;
    limpabuftec;
end;

{-------------------------------------------------------------}
{       Apaga apenas uma carta do servidor, abrindo e fechando a conexão
{       nCar é a posição da lista de cartas no Cartavox, e não no servidor.
{       A posição da carta no servidor está em regLido[nCar]^.posServ
{-------------------------------------------------------------}

function apagarUmaCartaServidor (nCar: integer): boolean;
label erro;
begin
    mudo := not clek;

    if not inicializaPOP3 then goto erro;

    totalDeCartas := 1;
    cartasTrazidas := 1;
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Apagando ... ' + intToStr(cartasTrazidas) + ' de ' + intToStr(totalDeCartas));

    if apagarCartaServidor (regLido[nCar]^.posServ) <> COD_OK then
        goto erro
    else
        atualizaPosServ (nCar);

    if not     finalizaPop3 then goto erro;
    fechaConexao (sockPOP3);

    setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Folheando servidor...');
    apagarUmaCartaServidor := true;
    limpabuftec;
    exit;

erro:
    if sockPOP3 >= 0 then
        fechaConexao (sockPOP3);
    limpaBufTec;
    msgBaixo ('CTCONCAN');  {'Conexao com servidor foi cancelada'}
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Folheando servidor...');
    apagarUmaCartaServidor := false;
    limpabuftec;
end;

{-------------------------------------------------------------}
{       Traz apenas uma carta do servidor, abrindo e fechando a conexão
{       nCar é a posição da lista de cartas no Cartavox, e não no servidor.
{       A posição da carta no servidor está em regLido[nCar]^.posServ
{-------------------------------------------------------------}

function trazerUmaCartaServidor (nCar: integer): boolean;
label erro;
begin
    if maiuscansi(retornaExtensao(regLido [nCar]^.carta^.nomArqCarta)) = 'CAR' then
        begin
            trazerUmaCartaServidor := true;
            exit;
        end;

    trazerMudo := true;
    mudo := not clek;
    interativoPOP3 := false;
    ignoraTodas := false;
    recebeTodas := true;

    if not inicializaPOP3 then goto erro;

    totalDeCartas := 1;
    cartasTrazidas := 1;
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Recebendo... ' + intToStr(cartasTrazidas) + ' de ' + intToStr(totalDeCartas));

    apagaCarta (nCar, false);
    if pegaUmaCartaPOP3 (regLido[nCar]^.posServ, nCar, false) <> 0 then
        goto erro;

    if not     finalizaPop3 then goto erro;
    fechaConexao (sockPOP3);

    setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Folheando servidor...');
    trazerUmaCartaServidor := true;
    limpabuftec;
    exit;

erro:
    if sockPOP3 >= 0 then
        fechaConexao (sockPOP3);
    limpaBufTec;
    msgBaixo ('CTCONCAN');  {'Conexao com servidor foi cancelada'}
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Folheando servidor...');
    trazerUmaCartaServidor := false;
    limpabuftec;
end;

{-------------------------------------------------------------}
{  Pede ao usuário que digite a senha de sua conta para
{  verificar se ela é válida
{-------------------------------------------------------------}

function senhaValida(iHostPop3, iContaUsuario: shortString; iPortaPOP3: integer; iUsaSSL: boolean): boolean;
var
    lidos: integer;
    salvaAttr: word;
    senha: string;
    c1: char;
label erro;

begin
    senhaValida := false;
    sockPOP3 := abreConexao (iHostPop3, iPortaPOP3, true);
    if sockPOP3 = -1 then
        goto erro;

    if iUsaSSL then
        if not ativaSSL(sockPOP3) then
            begin
                mensagem ('CTSSLNAO', 2);   {'Segurança SSL não pode ser ativada'}
                fechaConexao (sockPOP3);
                goto erro;
            end;

    lidos := receive (sockPOP3, bufRecebe, BUFSIZE, 0);
    if (lidos <= 0) then
        goto erro;
    bufRecebe [lidos] := #$0;
    netDebug (bufRecebe, lidos);
    StrPCopy (bufEnvia, 'USER '+ iContaUsuario + CRLF);
    sendbuf (sockPOP3, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    lidos := receive (sockPOP3, bufRecebe, BUFSIZE, 0);
    if (lidos <= 0) then
        goto erro;
    bufRecebe [lidos] := #$0;

    if bufRecebe [0] <> '+' then
        begin
            mensagem ('CTACONT', 0);  {'A conta '}
            sintwrite (iContaUsuario);
            mensagem ('CTNAOACE', 1);  {' não foi aceita, servidor falou assim'}
            sintWriteln (strPas (bufRecebe));
            goto erro;
        end
    else
        netDebug (bufRecebe, lidos);

    if trim (senhaSalva) = '' then
        begin
            senha := '';
            salvaAttr := textattr;
            textBackground (RED);
            mensagem ('CTINFSEN', 1);  {'Informe sua senha'}
            textBackground (BLACK);
            textColor (BLACK);
            c1 := sintEditaCampoMudo (senha, 1, wherey, 255, 80, true);
            writeln;
            textAttr := salvaAttr;
            if trim (senha) <> '' then senhaSalva := senha;
            if (c1 = ESC) or (trim(senhaSalva) = '') then goto erro;
        end;

    StrPCopy (bufEnvia, 'PASS '+ senhaSalva + CRLF);
    sendbuf (sockPOP3, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    lidos := receive (sockPOP3, bufRecebe, BUFSIZE, 0);
    if (lidos <= 0) then
        begin
            senhaSalva := '';
            goto erro;
        end;
    bufRecebe [lidos] := #$0;
    if bufRecebe [0] <> '+' then
        begin
            senhaSalva := '';
            mensagem ('CTASENHA', 0);  {'A senha '}
            mensagem ('CTNAOACE', 1);  {' não foi aceita, servidor falou assim'}
            sintWriteln (strPas (bufRecebe));
            goto erro;
        end;

    if not finalizaPop3 then goto erro;
    fechaConexao (sockPOP3);

    senhaValida := true;
    exit;

erro:
end;

{-------------------------------------------------------------}
begin
end.
