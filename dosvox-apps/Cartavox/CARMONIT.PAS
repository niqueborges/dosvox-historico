{-------------------------------------------------------------}
{
{           CartaVox - Monitora correio
{
{-------------------------------------------------------------}

unit carMonit;

interface

uses
    dvcrt,
    dvWin,
    dvHora,
    sysUtils,
    windows,
    careMudo,
    carMsg,
    carPop3,
    carRede,
    winSock,    //Declarar depois de carRede
    carUtil,
    carVars,
    carEnvia,
    carConf,
    carSMTP,
    carSpam,
    carAjuda,
    classes;

procedure monitorarRespAut;
procedure monitorarCorreioGrupoContas(listaGrupo: TStringList);
procedure monitorarCorreio;

implementation

var
    chegAntes: integer;

{-------------------------------------------------------------}
{       envia conta e senha para POP3 e ve quantas cartas
{-------------------------------------------------------------}

function verificaPOP3 (hostPOP3: string; portaPOP3: integer;
                       conta, senha: string; respAut: boolean): integer;
    { já prevendo futuramente monitoração de várias contas }
var
    i, lidos: integer;
    s: string;
    numCartas: integer;

label erro;

    function sendRec (s: string): string;
    begin
        StrPCopy (bufEnvia, s + CRLF);
        sendBuf (sockPOP3, bufEnvia, strlen (bufEnvia), 0);
        netDebug (bufEnvia, strlen (bufEnvia));

        lidos := receive (sockPOP3, bufRecebe, BUFSIZE, 0);
        bufRecebe [lidos] := #$0;
        netDebug (bufRecebe, lidos);

        if lidos = 0 then
            sendRec := '-'
        else
            sendRec := strPas (bufRecebe);
    end;

begin
    numCartas := -1;

    sockPOP3 := carrede.abreConexao (hostPOP3, portaPOP3, true);
    if sockPOP3 = -1 then
        begin
            senhaSalva := '';
            goto erro;
        end;

    if usaSSL then
        if not ativaSSL(sockPOP3) then
            begin
                mensagem ('CTSSLNAO', 2);   {'Segurança SSL não pode ser ativada'}
                fechaConexao (sockPOP3);
                goto erro;
            end;

    lidos := receive (sockPOP3, bufRecebe, BUFSIZE, 0);
    if (lidos <= 0) then
        begin
            senhaSalva := '';
            goto erro;
        end;
    bufRecebe [lidos] := #$0;
    netDebug (bufRecebe, lidos);

    s := sendRec ('USER '+ contaUsuario);
    if s[1] <> '+' then
        begin
            senhaSalva := '';
            goto erro;
        end;
    s := sendRec ('PASS '+ senha);
    if s[1] <> '+' then
        begin
            senhaSalva := '';
            mensagem ('CTERRSEN', 1);    {'Senha está errada'}
            goto erro;
        end;

    numCartas := 0;

    s := sendRec ('STAT');
    if s[1] <> '+' then
        begin
            senhaSalva := '';
            goto erro;
        end;

    s := s + ' 0 0 ';   {sentinela}
    i := 1;
    while not (s[i] in ['0'..'9']) do i := i + 1;
    numCartasPOP3 := 0;
    while s[i] in ['0'..'9'] do
        begin
            numCartas := (numCartas * 10) + (ord(s[i]) - ord ('0'));
            i := i + 1;
        end;

    if (numCartas <> 0) and (not respAut) then
        begin
            if (numCartas > chegAntes) then
                begin
                    sintSom ('CTPLIM');
                    if nomeConfiguracao <> '' then
                        mensagem (nomeConfiguracao, -1);
                end;
            chegAntes := numCartas;
        end;

erro:
    if sockPOP3 <> -1 then
        fechaConexao (sockPOP3);
    verificaPop3 := numCartas;
end;

{-------------------------------------------------------------}
{       Monitoração da resposta automática
{-------------------------------------------------------------}

procedure monitorarRespAut;
var
    salvaAttr: word;
    senha: string;
    i, cartasExistentes: integer;
    c: char;
    chegadas, cartasRecebidas, totalCartas: integer;

label fim;
begin
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
            if (c = ESC) or (trim(senhaSalva) = '') then goto fim;
        end;

    cartasExistentes := verificaPop3 (hostPOP3, portaPOP3, contaUsuario, senhaSalva, true);
    if cartasExistentes = -1 then
        begin
             msgBaixo ('CTCONCAN');  {'Conexao com servidor foi cancelada'}
             senhaSalva := '';
             exit;
        end;
    mensagem ('CTREAUFE', 1); {'Resposta automática de férias ativada'}

    setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' (Resposta automática)');
    chegAntes := 0;
    totalCartas := 0;
    c := ' ';
    repeat
        chegadas := verificaPop3 (hostPOP3, portaPOP3, contaUsuario, senhaSalva, true);
        if chegadas = -1 then
            senhaSalva := ''
        else
            for i := 1 to 120 do
                begin
                    delay (500);

                    if keypressed then
                        begin
                            c := readkey;
                            if c = #0 then c := readkey;
                            if c = F8 then     falaHora
                            else
                            if c = CTLF8 then   falaDia
                            else
                            if c = ESC then break
                            else
                            if totalCartas > 0 then
                                begin
                                    mensagem ('CTRECEBI', 0); {'Recebidas'}
                                    write (': ');
                                    sintWriteint (totalCartas);
                                    writeln;
                                end
                            else
                                begin
                                    mensagem ('CTDISPON', 0);   {'Cartas disponíveis: '}
                                    sintWriteint (chegadas);
                                    writeln;
                                end;
                        end;
                end;

        if (chegadas > cartasExistentes) then
            begin
                cartasRecebidas := receberCartasRespAut (cartasExistentes, chegadas);
                if cartasRecebidas = -1 then
                    chegadas := -1
                else
                if cartasRecebidas > 0 then
                    totalCartas := totalCartas + cartasRecebidas;
                if (cartasRecebidas > 0) and (debug) then
                    cartasExistentes := cartasExistentes + cartasRecebidas;

                setWindowTitle (pegaTextoMensagem('CTRECEBI'{'Recebidas'})+
                    ' ' + intToStr(totalCartas) + ' - CARTAVOX ' +
                    nomeConfiguracao + ' (Resposta Automática) ');
            end;

    until (chegadas = -1) or (c = ESC);

    while keypressed do readkey;
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
    mensagem ('CTOK', 1); {'OK'}
    exit;

fim:
    mensagem ('CTDESIST', 1); {'Desistiu'}
    writeln;
end;

{-------------------------------------------------------------}
{       Monitoração do grupo de contas
{-------------------------------------------------------------}

procedure monitorarCorreioGrupoContas(listaGrupo: TStringList);
var
    contaAtual: string;
    i, indice, iVet, tot, cod: integer;
    c: char;
    seg: integer;
    chegadas, jaRecebidas: integer;
    receberAutomaticamente, entrouRecebe: boolean;
    vetNumChegadas : Array[0..1000] of integer;

label fim;
begin
    seg := tempoReMonitorar;// 15;
    receberAutomaticamente := receberaAutMonitorar;

    entrouRecebe := false;
    cod := 0;
    chegAntes := 0;
    jaRecebidas := 0;
    indice := 0;
    c := ' ';
    repeat

        if  indice <= listaGrupo.Count - 1 then
            contaAtual := listaGrupo.Strings[indice]
        else
            begin
                for i := 1 to seg * 2 do
                    begin
                        delay (500);
                        if keypressed then
                            begin
                                c := readkey;
                                if receberAutomaticamente and (jaRecebidas > 0) then
                                    begin
                                        mensagem ('CTRECEBI', 0);  {'Recebidas'}
                                        write (': ');
                                        sintWriteint (jaRecebidas);
                                        writeln;
                                    end
                                else
                                    begin
                                        tot := 0;
                                        for iVet:=0 to 999 do
                                            tot := tot + vetNumChegadas[iVet];
                                        mensagem ('CTDISPON', 0);  {'Cartas disponíveis: '}
                                        sintWriteint (tot);
                                        writeln;
                                    end;
                                if c = ESC then break;
                            end;
                    end;
                indice := 0;
                contaAtual := listaGrupo.Strings[indice];
            end;
        recuperaConfigGrupoContas (contaAtual);

        if receberAutomaticamente then
            setWindowTitle (pegaTextoMensagem('CTRECEBI'{'Recebidas'})+': ' + intToStr(jaRecebidas) + ' - Cartavox monitorando grupo de contas')
        else
            begin
                tot := 0;
                for iVet:=0 to 999 do tot := tot + vetNumChegadas[iVet];
                setWindowTitle ('Cartas disponíveis: ' + intToStr(tot) + ' - Cartavox monitorando grupo de contas');
            end;

        chegadas := verificaPop3 (hostPOP3, portaPOP3, contaUsuario, senhaSalva, true);

        if receberAutomaticamente then
            begin
                if chegadas > 0 then
                    begin
                        sintSom ('CTPLIM');
                        if nomeConfiguracao <> '' then
                            mensagem (nomeConfiguracao, -1);
                    end;
            end
        else
           begin
               if chegadas > 0 then
                   begin
                       if not avisaNovasMonitorar then
                           begin
                               sintSom ('CTPLIM');
                               if nomeConfiguracao <> '' then
                                   mensagem (nomeConfiguracao, -1);
                               vetNumChegadas[indice] := chegadas;
                           end
                       else
                           begin
                               if chegadas > vetNumChegadas[indice] then
                                   begin
                                       sintSom ('CTPLIM');
                                       if nomeConfiguracao <> '' then
                                           mensagem (nomeConfiguracao, -1);
                                       vetNumChegadas[indice] := chegadas;
                                   end;
                           end;
                   end;
           end;

        if chegadas = -1 then break
        else if (chegadas > 0) and receberAutomaticamente then
            begin
                sintSom ('CTPLIM');
                mensagem (nomeConfiguracao, -1);
                cod := receberCartasGrupoContas (false, true);
                if cod = -1 then break;
                jaRecebidas := jaRecebidas + chegadas;
            end;

        indice := indice + 1;

    until (chegadas = -1) or (c = ESC);

    if receberAutomaticamente then
        for indice:=0 to listaGrupo.Count-1 do
            begin
                contaAtual := listaGrupo.Strings[indice];
                recuperaConfigGrupoContas (contaAtual);
                chegadas := verificaPop3 (hostPOP3, portaPOP3, contaUsuario, senhaSalva, true);
                if chegadas > 0 then
                    begin
                        writeln;
                        cod := receberCartasGrupoContas (false, false);
                        if cod = -1 then break;
                        entrouRecebe := true;
                    end
            end;

    while keypressed do readkey;
    if (entrouRecebe = false) and (cod <> -1) then mensagem ('CTOK', 1); {'OK'}
    writeln;
    exit;

fim:
    mensagem ('CTDESIST', 1); {'Desistiu'}
    writeln;
end;

{-------------------------------------------------------------}
{       Monitoração da conta atual
{-------------------------------------------------------------}

procedure monitorarCorreio;
var
    salvaAttr: word;
    senha: string;
    c: char;
    i, seg, chegadas, jaRecebidas: integer;
    receberAutomaticamente: boolean;
begin
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
            if (c = ESC) or (trim(senhaSalva) = '') then
                begin
                    mensagem ('CTDESIST', 1); {'Desistiu'}
                    writeln;
                    exit;
                end;
        end;

    // Os parâmetros de configuração do monitoramento:
    seg := tempoReMonitorar;
    receberAutomaticamente := receberaAutMonitorar;

    setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' (MONITORANDO)');
    jaRecebidas := 0;
    chegAntes := 0;
    c := ' ';
    repeat
        chegadas := verificaPop3 (hostPOP3, portaPOP3, contaUsuario, senhaSalva, false);
        if chegadas > 0 then
            setWindowTitle (pegaTextoMensagem('CTDISPON') + ' ' + intToStr(chegadas) + ' - CARTAVOX ' + nomeConfiguracao + ' (MONITORANDO)'){Disponíveis}
        else
        if jaRecebidas > 0 then
            setWindowTitle (pegaTextoMensagem('CTRECEBI')+' ' + intToStr(jaRecebidas) + ' - CARTAVOX ' + nomeConfiguracao + ' (MONITORANDO) ') {'Recebidas'}
        else
            setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' (MONITORANDO)');

        if chegadas = -1 then
            begin
                mensagem ('CTERCONX', 1);    {'Erro na conexão com o correio'}
                senhaSalva := '';
            end
        else
            for i := 1 to seg * 2 do
                begin
                    delay (500);
                    if keypressed then
                        begin
                            c := upcase(readkey);
                            if c = #0 then c := readkey;

                            if (c in ['S', ^S]) and (chegadas > 0) then mataSpam (false);
                            if c in ['R', ^S] then
                                begin
                                    receberAutomaticamente := true;
                                    c := ESC;
                                end;

                            if c = F1 then ajudaMonitoramento
                            else
                            if c = F8 then     falaHora
                            else
                            if c = CTLF8 then   falaDia
                            else
                            if c = ESC then break
                            else
                            if c = ^R then
                                begin
                                    receberAutomaticamente := not receberAutomaticamente;
                                    if receberAutomaticamente then sintbip
                                    else sintclek;
                                    limpabuftec;
                                end
                            else
                                if receberAutomaticamente and (jaRecebidas > 0) then
                                    begin
                                        mensagem ('CTRECEBI', 0); {'Recebidas'}
                                        write (': ');
                                        sintWriteint (jaRecebidas);
                                        writeln;
                                    end
                                else
                                    begin
                                        mensagem ('CTDISPON', 0);   {'Cartas disponíveis: '}
                                        sintWriteint (chegadas);
                                        writeln;
                                    end;
                        end;
                end;

        if ((not avisaNovasMonitorar) and ((chegadas >0) or (jaRecebidas > 0))) or
          (avisaNovasMonitorar and (chegadas > 0)  and receberAutomaticamente) then
            begin
                sintSom ('CTPLIM');
                if nomeConfiguracao <> '' then
                    mensagem (nomeConfiguracao, -1);
            end;

        if (chegadas > 0)  and receberAutomaticamente then
            begin
                writeln;
                if (receberCartas (true, false)> 0) and matarSpamAutomaticamente then
                    begin
                        chegadas := chegadas - matarSpansNaoLidas(true, true);
                        if chegadas < 0 then chegadas := 0;
                    end;
                jaRecebidas := jaRecebidas + chegadas;
                if (jaRecebidas > 0) and (c <> ESC) then
                    begin
                        mensagem ('CTRECEBI', 0); {'Recebidas'}
                        write (': ');
                        sintWriteint (jaRecebidas);
                        writeln;
                    end;
            end;

    until (chegadas = -1) or (c = ESC);

    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);

        mensagem ('CTOK', 2); {'OK'}

end;

{-------------------------------------------------------------}
begin
end.

