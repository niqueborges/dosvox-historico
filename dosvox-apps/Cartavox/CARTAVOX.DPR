{-------------------------------------------------------------}
{
{       Programa de correio, cliente SMTP e POP3
{
{       Autor: Jose' Antonio Borges
{       Em 10 de abril de 1998
{
{       Atualizado por: Neno Henrique da Cunha Albernaz
{       De 2002 a 2018
{
{-------------------------------------------------------------}

{-------------------------------------------------------------}
{       arquivos de inclusao obrigatoria
{-------------------------------------------------------------}

program Cartavox;
uses
    dvcrt,
    dvform,
    dvhora,
    dvWin,
    sysutils,
    windows,
    carApeli,
    carConf,
    carDecod,
    carEnvia,
    carFolhe,
    carList,
    carMonit,
    carMsg,
    carPop3,
    carRede,
    carSMTP,
    carTela,
    carUtil,
    carVars,
    carRegras,
    carResp,
    carFolInt,
    carSpam,
    carIMAP,
    carCont,
    carAjuda;

{-------------------------------------------------------------}
{       rotina de inicializacao
{-------------------------------------------------------------}

procedure inicializa;
begin
    randomize;
    debug := false;
    sintInic (0, sintambiente ('CARTAVOX', 'DIRCARTAVOX', sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\cartavox'));

    cartavoxConfigs := sintAmbiente ('CARTAVOX','ARQCONFIGS', sintDirAmbiente + '\Cartavox.ini');

    clrscr;
    limpaBufTec;
    textBACKGROUND (BLUE);
    write (pegaTextoMensagem('CTINIC'));  {'CARTAVOX - Correio Eletrônico - NCE/UFRJ - v.'}
    writeln (VERSAO);
    textBackground (BLACK);
    writeln;

    if sintFalarTudo then
        begin
            mensagem ('CTINIC', -1);  {'CARTAVOX - Correio Eletrônico - NCE/UFRJ - v.'}
            sintetiza (VERSAO);
            if not keypressed then delay(5);
            sintclek;
        end;
    while sintFalando do waitMessage;  // controle das paradas de fala

    pegaConfigInicial;
    if (upcase(sintAmbiente('CARTAVOX', 'FALARCONFIGURACAONAABERTURA', 'SIM')[1]) = 'S') and
       (trim(nomeConfiguracao) <> '') and (paramCount <> 2) then
        begin
            sintetiza (nomeConfiguracao);
            sintclek;
        end;

    if not sintFalarTudo then
        mensagem ('CTCARTAVOX', -1);  {'CARTAVOX'}

    if (hostSMTP = '') or (hostPOP3 = '') or (enderUsuario = '') or (contaUsuario = '') or
       (dirRecebe = '') or (dirEnvia = '') then
            configurar;

    nbaseEnvia  := 0;
    nbaseRecebe := 0;
    nbaseCopia  := 0;
    pCC  := NIL;
    pBCC := NIL;

    abreRede;

    if paramCount = 1 then
        prepararCarta ('P', 0, false, paramStr(1), pegaDirAtual)
    else
    if (paramCount = 2) and (paramStr(1) = '/L') then
        begin
            fechaRede;
            abreUmaCarta (paramStr(2));
            mensagem ('CTOK', 1);
            apagaArquivosTemporarios;
            sintFim;
            doneWinCrt;
        end;
end;

{--------------------------------------------------------}
{       verificar cartas enviadas
{--------------------------------------------------------}

procedure verificarPreparadasOuTransmitidas;
var
    c: char;
begin
    repeat
        telaPrincipal;
        mensagem ('CTQUEVER', 0);    {'Verificar preparadas ou transmitidas ? '}
        c := popupMenuPorLetra ('PT' + ^t + ^p);
    until c in ['T', 'P', ^T, ^P, ESC];

    if c = esc then
        msgBaixo ('CTDESIST') {'Desistiu'}
    else
        folhearCartas (c, '');
end;

{-------------------------------------------------------------}
{       Fala número de cartas nos folheamentos
{-------------------------------------------------------------}

procedure falaNumeroTotalDeCartas;
var
    i: integer;
    dirVazio: boolean;
begin
    dirVazio := true;
    i := numeroDeCartas (dirEnvia, 'P');
    if i > 0 then
        begin
            mensagem  ('CTPREPAR', 0); {'Preparadas'}
            sintwriteln ('  ' + intToStr(i));
            dirVazio := false;
        end;
    i := numeroDeCartas (dirRecebe, 'N');
    if i > 0 then
        begin
            mensagem  ('CTNAOLID', 0); {'Não lidas'}
            sintwriteln ('  ' + intToStr(i));
            dirVazio := false;
        end;
    i := numeroDeCartas (dirRecebe, 'L');
    if i > 0 then
        begin
            mensagem ('CTLIDAS', 0); {'Lidas'}
            sintwriteln ('  ' + intToStr(i));
            dirVazio := false;
        end;
    i := numeroDeCartas (dirEnvia, 'T');
    if i > 0 then
        begin
            mensagem ('CTTRANSM', 0); {'Transmitidas'}
            sintwriteln ('  ' + intTostr(i));
            dirVazio := false;
        end;
    if dirVazio then
        mensagem ('CTSEMCAR', 1); {'Não tem carta neste diretório'}
    writeln;
end;

{-------------------------------------------------------------}
{       Rotina de saida do Cartavox
{-------------------------------------------------------------}

function terminaPrograma: boolean;
var
    c: char;
    sair: boolean;
begin
    sair := false;
    telaPrincipal;
    if perguntaAoSair then
        begin
            repeat
                mensagem ('CTCONSAI', 0); {'Confirma saida do Cartavox?'}
                c := upcase(popupMenuPorLetra ('SN'));
                writeln;
            until c in ['S', 'N', ENTER, ESC];
            if c in ['S', ENTER] then
                sair := true;
        end
    else
        sair := true;

    if sair then
        sair := not transmitirPreparadas;

    if not sair then
        begin
            msgBaixo ('CTDESIST'); {'Desistiu'}
        telaPrincipal;
        end;

    TerminaPrograma := sair;
end;

{-------------------------------------------------------------}
{                     programa principal
{-------------------------------------------------------------}

var
    c1, c2: char;
    dirAtual: string;
    nCarRecebidas: integer;
    processando, apertouShift: boolean;
begin
    inicializa;

    getDir(0, dirAtual);
    processando := true;
    while (processando)  do
        begin
            textBackground (BLUE);
            mensagem ('CTQUALOP', 0);  {'Qual sua opção ? '}
            textBackground (BLACK);
            c1 := readkey();
            apertouShift := GetKeyState(VK_SHIFT) < 0;
            c2 := #$0;
            if c1 = #0 then
                 c2 := readkey
            else
                if sintEcoarOpcao and not (upcase(c1) in ['F', 'N', 'L', ^F, ^N, ^L, 'I', ^I, ESC, ^R, ^M, ^G, ^J]) then
                    sintCarac (c1);
            if c1 <> ^G then
                writeln (c1);

            if (c1 = #0) and (c2 in [CIMA, BAIX, F9]) then
                begin
                    c1 := selSetasOpcaoPrincipal (c2);
                    telaPrincipal;
                end
            else
            if (not opcoesBasicas) and (upcase(c1) = 'O') then
                c1 := selSetasOutrasOpcoesPrincipal (c2);

            c1 := upcase(c1);
            if c1 = #0 then
                case c2 of
                    F1: ajudaPrincipal;
                    F8: falaHora;
                    CTLF8: falaDia;
                    DEL, HOME: begin
                            if sintFalarTudo then mensagem ('CTINIC', -1);  {'CARTAVOX - Correio eletrônico - NCE/UFRJ - v.'}
                            sintetiza (VERSAO);
                         end;
                end
            else
            if (opcoesBasicas) and //Abaixo opções retiradas  do básico
              (c1 in ['P', 'J', 'G', ^G, 'S', ^S, 'D', 'B', 'U', 'K', 'X', 'Y', ^Y, ^Z, ^X, ^C, ^Q]) then
                mensagem ('CTOPVINV', 2)  {'Opção inválida, aperte F1 para ajuda'}
            else
            case c1 of
                'E': prepararCarta ('P', 0, false, '', dirAtual);
                ^E: if apertouShift then
                        prepararCarta (^P, 0, false, enderUsuario, dirAtual)
                    else
                        prepararCarta (^P, 0, false, '', dirAtual);

                'P': prepararCarta ('T', 0, false, '', dirAtual);
                ^P: if apertouShift then
                        prepararCarta (^T, 0, false, enderUsuario, dirAtual)
                    else
                        prepararCarta (^T, 0, false, '', dirAtual);

                'T':  transmitirCartas (false, 'P', false);
                ^T:  transmitirCartas (false, 'P', true);
                'R', ^R: begin
                            nCarRecebidas := receberCartas (c1 = ^R, apertouShift);
                            if c1 = ^R then
                                if nCarRecebidas = 0 then
                                    mensagem ('CTNAOEXS', 1) {'Não existem cartas no servidor.'}
                                else
                                if apertouShift then
                                   mensagem ('CTOK', 1) {'Ok'}
                                else
                                   begin
                                        mensagem ('CTRECEBI', 0); {'Recebidas'}
                                        write (': ');
                                        sintWriteint (nCarRecebidas);
                                        writeln;
                                end;
                            if (nCarRecebidas > 0) and (autoEnviaDuplicadasLixeira) then
                                removeCartasDuplicadas (false);
                            if (c1 = ^R) and (nCarRecebidas >0) and (matarSpamAutomaticamente) then
                                matarSpansNaoLidas(true, true);
                     end;
                'F', 'N', 'L', ^F, ^N, ^L:  folhearCartas (c1, '');
                'J', ^J: folhearCartasServidor(c1);
                'G', ^G: begin
                        agruparPorAssunto := true;
                        if c1 = ^G then
                            folhearCartas (^N, '')
                        else
                            folhearCartas ('N', '');
                    end;
                'I':  begin
                         sintetiza (nomeConfiguracao);
                         delay (200);
                      end;
                ^I:   begin
                         sintSoletra (nomeConfiguracao);
                         delay (200);
                      end;
                'Q': if apertouShift then falaNumeroTotalDeCartasDaConta (false)
                     else falaNumeroTotalDeCartas;
                'S': mataSpam (false);
                ^S: begin
                        mataSpam (false);
                        nCarRecebidas := receberCartas (true, apertouShift);
                        if nCarRecebidas > 0 then
                           begin
                                mensagem ('CTRECEBI', 0); {'Recebidas'}
                                write (': ');
                                sintWriteint (nCarRecebidas);
                                writeln;
                           end;
                    end;
                'C':  configurar;
                'A':  editarApelidos;
                'V':  verificarPreparadasOuTransmitidas;
                'M':  monitorarCorreio;
                'D':  begin
                          debug := not debug;
                          if debug then
                              mensagem ('CTMODDEB', 2)   {'Modo debug: cartas não serão apagadas'}
                          else
                              mensagem ('CTMODNOR', 2);  {'Modo normal'}
                          writeln;
                      end;

                'Z': removeCartasDuplicadas (true);
                'B': inicializaRegras;
                'U': respostaAutomatica;
                'K': inicializaGrupoContas;
                'X': chamaIMAPUtil;
                'Y': matarSpansNaoLidas(false, false);
                ^Y: matarSpansNaoLidas(true, false);
                ^Z: receberGrupoContas (apertouShift);
                ^X: transmitirGrupoContas;
                ^C: monitorarGrupoContas;
                ^Q: informarCartasGrupoContas (apertouShift);

                ESC, ^W: processando := not terminaPrograma;
                #$0d: telaPrincipal;
            else
                mensagem ('CTOPVINV', 2);  {'Opção inválida, aperte F1 para ajuda'}
            end;
       end;

    if (guardaSenha) and (trim(senhaSalva) <> '') then
        sintGravaAmbiente('CARTAVOX', 'SCCV', codFraseMime64 (senhaSalva))
    else
    if (nomeConfiguracao <> 'Lixeira') and (nomeConfiguracao <> 'Spam') then
        sintRemoveAmbiente('CARTAVOX', 'SCCV');

    apagaArquivosTemporarios;

    fechaRede;
    if sintFalarTudo then
        msgBaixo ('CTFIM');  {'Fim do Correio'}

    sintFim;
    doneWinCrt;
end.

