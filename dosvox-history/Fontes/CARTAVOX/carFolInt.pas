{--------------------------------------------------------}
{
{   Cartavox - Folheador de cartas interativo no servidor
{
{           Atualizado por: Neno Henrique da Cunha Albernaz
{          Em Outubro de 2015
{
{--------------------------------------------------------}

unit carFolInt;

interface

uses
    dvarq,
    dvcrt,
    dvform,
    dvhora,
    dvWin,
    sysutils,
    windows,
    classes,
    carApeli,
    carCopia,
    carDecod,
    carEst,
    carLeit,
    carList,
    carMsg,
    carTela,
    carUtil,
    carVars,
    carSpam,
    carRegras,
    carSMTP,
    carAjuda;

procedure folhearCartasServidor (tipoFolhe: char);

implementation

uses
    carPop3;

{--------------------------------------------------------}
{  procura uma carta pela opção escolhida pelo usuário
{--------------------------------------------------------}

procedure procurarNaCartaServidor (folheiaAchados: boolean; nCar: integer);
var
    c, c2: char;
    atual, cont, i, total: integer;
    achouJaUma, selecionado: boolean;
    textoBusc: string;

    procedure contadorBipa (limite: integer);
    begin
        cont := cont + 1;
        if (cont mod limite) = 0 then
            begin
                sintBip;
                cont := 0;
            end;
    end;

    function procuraEmUmArquivo (nCar: integer; tipoProcura: char): boolean;
    var
        s: string;
        i: integer;
    label naoAchou;
    begin
        if carregaLinhasArquivo (regLido [nCar]^.carta^.nomArqCarta) then
            begin
                i := 0;
                if tipoProcura = 'B' then
                    repeat
                        if (i >= 0) and (i < linhasArquivo.count) then  // programação defensiva
                            s := trim (linhasArquivo[i]);
                        i := i + 1;
                    until (s = '') or (i >= linhasArquivo.count);

                while i < linhasArquivo.count do
                    begin
                        s := trim (linhasArquivo[i]);
                        if (upcase (tipoProcura) in ['C', ENTER]) and (s = '') then
                            goto naoAchou;
                        decodificarString(s);
                        if pos (textoBusc, semAcentos (s)) <> 0 then
                            break;

                        i := i + 1;
                        if i >= linhasArquivo.count then
                            goto naoAchou;
                        contadorBipa (100000);
                    end;
            end
        else
            begin
                procuraEmUmArquivo := false;
                exit;
            end;

        procuraEmUmArquivo := true;
        destroiLinhasArquivo;
        exit;

    naoAchou:
        procuraEmUmArquivo := false;
        destroiLinhasArquivo;
    end;

    function procuraUmItem (nCar: integer; tipoProcura: char): boolean;
    begin
        case tipoProcura of
            'A': procuraUmItem := textoBusc = limpaAssunto(regLido [nCar]^.carta^.subject);
            'R': procuraUmItem := textoBusc = retornaEMail (regLido [nCar]^.carta^.from);
            'H': procuraUmItem := textoBusc = dateToStr (fileDateToDateTime (regLido [nCar]^.carta^.datahora))
        else
            procuraUmItem := procuraEmUmArquivo (nCar, tipoProcura);
        end;
    end;

    procedure ajuda;
    begin
        mensagem ('CTAJUD01', 2); {'As opções são'}
        if not keypressed then
            mensagem ('CTCABCAR', 1); {'    C - Cabeçalho da carta'}
        if not keypressed then
            mensagem ('CTPROASS',1); {' A - Assunto desta carta'}
        if not keypressed then
            mensagem ('CTPROREM',1); {' R - Remetente desta carta'}
        if not keypressed then
            mensagem ('CTPRODAT', 1); {' H - Data de chegada desta carta'}
    end;

    function selSetas: char;
    var
        n: integer;
    const tabOpc: string[4] = 'CARH';
    begin
        popupMenuCria (35, wherey, 50, 7, RED);
        MenuAdiciona ('CTCABCAR'); {'    C - Cabeçalho da carta'}
        MenuAdiciona ('CTPROASS'); {' A - Assunto desta carta'}
        MenuAdiciona ('CTPROREM'); {' R - Remetente desta carta'}
        MenuAdiciona ('CTPRODAT'); {' H - Data de chegada desta carta'}

        n := popupMenuSeleciona;
        if (n >=1) and (n <= 4) then
            selSetas := tabOpc [n]
        else
            selSetas := #0;
    end;

begin
    c2 := #$0;
    if agruparPorAssunto then
        c:= 'A'
    else
    repeat
        limpaParteTela (20, 25);
        if not folheiaAchados then
            mensagem ('CTPROINV', 1); {'Procura invertida'}
        mensagem ('CTTIPPRO', 0); {'Qual o tipo de procura?'}
        write ('   ');
        mensagem ('CTF1AJUD', 1);         {'F1 ajuda '}
        c := upcase (readkey);
        if c = #0 then
            begin
                c := readkey;
                if c = F1 then ajuda
                else
                if (c = BAIX) or (c = CIMA) then c := selSetas;
            end;
    until c in ['C', 'A', 'R', 'H', ESC, ENTER];
    if not agruparPorAssunto then
        sintWriteln (c);

    if c in ['A', 'R'] then
        for i := 1 to numRegs do
            if not regLido [i]^.carta^.preenchido then
                begin
                    selecionado := regLido [i]^.selecionado;
                    carregaArqPreencheCabPrin ( i);
                    regLido [i]^.selecionado := selecionado;
                    if (i mod 500) = 0 then sintclek;
                end;

    case c of
        'A': begin
                textoBusc := limpaAssunto(regLido [nCar]^.carta^.subject);
                if trim (textoBusc) = '' then
                    textoBusc := regLido [nCar]^.carta^.subject;
             end;
        'R': textoBusc := retornaEMail (regLido [nCar]^.carta^.from);
        'H': textoBusc := dateToStr (fileDateToDateTime (regLido [nCar]^.carta^.datahora))
    else
        repeat
            textoBusc := 'reply-to';
            if c in ['C', ENTER] then
                mensagem ('CTINFPRO', 1)    {'Informe o texto a procurar no cabeçalho da carta'}
            else
                begin
                    mensagem ('CTDESIST', 2);  {'Desistiu...'}
                    exit;
                end;
            c2 := sintEditaCampo (textoBusc, 1, wherey, 255, 80, true);
            textoBusc := semAcentos (textoBusc);
        until c2 in [ENTER, ESC];
    end;

    if (c2 = ESC) or (textoBusc = '') then
        begin
            mensagem ('CTDESIST', 2);  {'Desistiu...'}
            exit;
        end;

    cont := 0;
    atual := numRegs;
    achouJaUma := false;
    while (atual > 0) and (not achouJaUma) do
        if folheiaAchados then
            begin
                if procuraUmItem (atual, c) then
                    achouJaUma := true
                else
                    begin
                        atual := atual -1;
                        contadorBipa (1500);
                    end;
            end
        else
            if not procuraUmItem (atual, c) then
                achouJaUma := true
            else
                begin
                    atual := atual -1;
                    contadorBipa (1500);
                end;

    if achouJaUma then
        begin
            total := numRegs;
            for i := total downto atual+1 do
                apagaUmRegs (i);
            atual := atual -1;
            while atual > 0 do
                begin
                    if folheiaAchados and (not procuraUmItem (atual, c)) then
                            apagaUmRegs (atual)
                        else
                    if (not folheiaAchados) and procuraUmItem (atual, c) then
                            apagaUmRegs (atual);
                    atual := atual -1;
                    contadorBipa (1500);
                end;
        end;

    if not agruparPorAssunto then
        if achouJaUma then
            msgBaixo ('CTACHEI')     {'Achei'}
        else
            msgBaixo ('CTNACHEI');    {'Não achei'}
end;

{--------------------------------------------------------}
{   Inicializa o folheamento de cartas no servidor
{--------------------------------------------------------}

procedure inicializaFolheamento;
var
    i: integer;
    s: string;
begin
    folheiaCria (1, 3, 80, 17);
    for i :=  1 to numRegs do
        begin
            s := '';
            folheiaAdicionaEspecial (s, regLido [i]^.selecionado, s);
        end;
end;

{-------------------------------------------------------------}
{  Preenche item com as informações da carta, se ainda vazio
{-------------------------------------------------------------}

procedure preencheItemOnlineServidor (nItem: integer; var conteudo, fala: string;
                              var selec: boolean);
var
    s, s2: string;
begin
    if (conteudo <> '') or (fala <> '') then exit;
    folheiaObtemItem (nItem, s, regLido[nItem]^.selecionado);

    carregaArqPreencheCabPrin (nItem);
    s := regLido [nItem]^.carta^.from;
    s := retornarNome (s, false);

    s2 := regLido [nItem]^.carta^.subject;
    s2 := pegaPrefixoAssunto(s2) + limpaAssunto(s2);
    deletaAspas (s2);
    if s2 = '' then s2:= 'NULO';

    conteudo := copy (s+BRANCOS, 1, 30) +  copy (s2+BRANCOS, 1, 50);
    if FALANOMEPRIMEIRO then
        fala := s + ' ' + s2
    else
        fala := s2 + ' ' + s;
    selec := regLido [nItem]^.selecionado;
end;

{----------------------------------------------------------------------}
{       Cabeçalho da tela do folheamento das cartas no servidor
{----------------------------------------------------------------------}

procedure telaFolheamentoCartasServidor;
var s: string;
begin
    clrscr;
    textBackGround (MAGENTA);
    s := 'Folheamento interativo no servidor';
    s := s + ' - ' + intToStr(numRegs) + ' ';
    if numRegs > 1 then
         s := s  + pegaTextoMensagem('CTCARTAS') {'Cartas'}
    else
                  s := s  + pegaTextoMensagem('CTCARTA'); {'Carta'}
    write (centralizaFrase (s));
    textBackground (BLACK);
    writeln (centralizaFrase(pegaTextoMensagem ('CTUSESET')));  {'Folheando: use as setas, depois tecle sua opção'}
end;

{--------------------------------------------------------}
{           folheamento no servidor
{--------------------------------------------------------}

procedure folhearCartasServidor (tipoFolhe: char);
var
    c, c2: char;
    nCar, i, totalAntes, totalDepois: integer;
    s, dirAtual: string;
    podeFalar, aux, apertouShift: boolean;

label procurarAchou;
begin
    totalAntes := numeroDeCartas (dirRecebe, 'F');
    if not receberCartasServidor (tipoFolhe = ^j) then
        begin
            for i := 1 to numRegs do
                if not apagaCarta (i, false) then break;
            desmontaListaDeCartas;
            exit;
        end;

    if numRegs = 0 then
        begin
            if tipoFolhe = ^j then
                msgBaixo ('CTNAOEXS');  {'Não existem cartas no servidor.'}
            exit;
        end;

    getDir (0, dirAtual);
            {$I-}  chdir (dirRecebe);  {$I+}
            if ioresult <> 0 then ;

    ordenarLista ('posServ', ordemInversa, false);

procurarAchou:
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Folheando servidor...');
    telaFolheamentoCartas;
    if sintFalarTudo then
        begin
            if numRegs > 1 then
                falaNumeroCartas;
        mensagem ('CTUSESET', -1);  {'Folheando: use as setas, depois tecle sua opção'}
        end
    else
    if numRegs > 1 then
        sintetiza (intToStr(numRegs));

    nCar := 1;
    podeFalar := true;
    repeat
        telaFolheamentoCartasServidor;
        inicializaFolheamento;
        folheiaCorDoMeio (1, 30, CYAN);

        FolheiaPreencheItemOnline := @preencheItemOnlineServidor;
        folheiaExecuta (nCar, nCar, c, c2, podeFalar);
        apertouShift := GetKeyState(VK_SHIFT) < 0;
        FolheiaPreencheItemOnline := NIL;

        if nCar < 1 then nCar := 1;
        if nCar > numRegs then nCar := numRegs;
        sintPara;
        for i := 1 to numRegs do
            folheiaObtemItem (i, s, regLido[i]^.selecionado);

        gotoxy (1, 19);
        if c2 = F9 then
            c := selSetasFolheiaServidor (c2);

        if c = #0 then
            begin
                case c2 of
                    ESQ, DIR: begin
                            s := regLido [nCar]^.carta^.subject;
                            if c2 = DIR then
                                s := pegaPrefixoAssunto(s) + limpaAssunto(s)
                            else
                                s := limpaAssunto(s);
                            if trim(s) = '' then
                                s := 'Nulo';
                            sintetiza (s);
                            contemAnexos (nCar);
                         end;
                    F1:    ajudaFolheiaServidor;
                    F3:  begin
                                folheiaDestroi;
                                escolheOrdenacao (true);
                                goto procurarAchou;
                         end;
                    F5, f6:  begin
                                folheiaDestroi;
                                aux := agruparPorAssunto;
                                agruparPorAssunto := false;
                                procurarNaCartaServidor (c2 = F5, nCar);
                                agruparPorAssunto := aux;
                                goto procurarAchou;
                         end;
                    F7 : nCar := trazEApagaCartasServidor(nCar, false, true);
                    F8:     falaHora;
                    CTLF8:   falaDia;
                    F12: begin {Não faz nada, continua folheando}
                            if sintFalarTudo then
                                msgBaixo ('CTCNTFOL')  {'Continue folheando ou tecle ESC'}
                            else
                                sintClek;
                            writeln;
                         end;
                end;
            end
        else
            begin
                c := upcase (c);
                case c of
                    'I': infoCarta (nCar);
                    ^I:   begin
                             sintSoletra (nomeConfiguracao);
                             delay (200);
                          end;
                    'B': editarApelidos;
                    'N': sintetiza (regLido [nCar]^.carta^.nomArqCarta);
                    ^N : sintetiza (intToStr (nCar));
                    'D': if apertouShift then falarDatasCarta (nCar, true)
                         else tamanhoCarta (nCar);
                    ^D : if apertouShift then falarDatasCarta (nCar, false)
                         else tamanhoTodasCartas;

                    'P':
                        begin
                            folheiaDestroi;
                            if carregaLinhasArquivo (regLido[ncar]^.carta^.nomArqCarta) then//Aloca o arquivo da carta
                                begin
                                    preencheCartaPrincipal (regLido[ncar]);//preenche o cabeçalho principal da carta
                                    destroiLinhasArquivo;//Desaloca o arquivo da carta
                                end;
                            mostraItensCarta ( regLido[nCar]);
                        end;
                    'A': nCar := trazEApagaCartasServidor(nCar, false, true);
                    'R', ^R: nCar := trazEApagaCartasServidor(nCar, true, c = 'R');
                    'L', ENTER, CTLENTER:
                        begin
                            folheiaDestroi;
                            if (c <> CTLENTER) and (pos ('@gmail.com', enderUsuario) <> 0) then
                                msgBaixo ('CTOPINSE') {'Opção indisponível neste servidor'}
                            else
                            if trazerUmaCartaServidor (nCar) then
                                leCarta (nCar, false, false, true);
                            if c = CTLENTER then
                                begin
                                    if pos ('@gmail.com', enderUsuario) = 0 then
                                        apagarUmaCartaServidor (nCar)
                                    else
                                            atualizaPosServ (nCar);
                                    nCar := apagaUmRegs(nCar);
                                end;
                            limpaBufTec;
                         end;

                    'F': sintetiza (regLido [nCar]^.carta^.from);
                    ^F: if trim (regLido [nCar]^.carta^.delivered_to) <> '' then
                            sintetiza (regLido [nCar]^.carta^.delivered_to)
                        else
                        if trim (regLido [nCar]^.carta^.to_) <> '' then
                            sintetiza (regLido [nCar]^.carta^.to_)
                        else
                            sintetiza (regLido [nCar]^.carta^.bcc);
                    'S': selecionaApelido (nCar, true);
                    ^B, ^L: adicionaNoMataSpam (nCar, c = ^B);
                    'J': begin
                            falaNomePrimeiro := not falaNomePrimeiro;
                            if falaNomePrimeiro then begin sintClek; sintClek; sintClek; end
                            else begin sintBip; sintBip; sintBip; end;
                         end;

                    ^C: begin
                            putClipBoard(pchar(retornaEMail(regLido [nCar]^.carta^.from)));
                            sintClek; sintclek;
                         end;

                    #32: regLido [nCar]^.selecionado := not regLido [nCar]^.selecionado;
                    #47: for i := 1 to numRegs do
                            regLido [i]^.selecionado := false;
                    ^S: for i := 1 to numRegs do
                            regLido [i]^.selecionado := true;

                    'Q', ^Q: falaQualItemDeQuantos (nCar, folheiaNumItens, c = ^Q);
                    'G': nCar := posicaoNomeArqCarta (nCar);
                    ^G: nCar := posicaoCarta (nCar);
                    'T': transmitirCartas (false, 'P', false);
                    ESC: //if perguntaAoSairFolheamento then
                        repeat
                            msgBaixo('CTSAIFOL'); {'Deseja sair do folheamento?'}
                            c := upcase(popupMenuPorLetra ('SN'));
                            if c in ['S', ENTER] then c := ESC
                            else
                                begin
                                    c := 'N';
                                    msgBaixo('CTDESIST'); {'Desistiu'}
                                    if sintFalarTudo then
                                        msgBaixo ('CTCNTFOL')  {'Continue folheando ou tecle ESC'}
                                    else
                                        sintClek;
                                end;
                        until c in ['S', 'N', ENTER, ESC];

                else
                    if c <> ESC then msgBaixo ('CTOPVINV'); {'Opção invalida'}
                end;

                if (numRegs >0) and (c <> ESC) and
                    (upcase(c) in ['I', 'B', 'P', 'A', ^A, 'S', 'R', ^R, ENTER, 'L', CTLENTER]) then
                        if sintFalarTudo then
                            msgBaixo ('CTCNTFOL')  {'Continue folheando ou tecle ESC'}
                        else
                            sintClek;
            end;

        if numRegs <= 0 then
            begin
                msgBaixo ('CTSEMCAR');  {'Não tem carta neste diretório'}
                c := ESC;
            end
        else
        if (upCase(c) in[^N, 'D', ^D, 'F', ^F, 'Q', ^Q, ^C,
            'I', 'B', 'P', 'A', ^A, 'S', 'R', ^R]) or
            (c2 in [ESQ, DIR, f8, CTLF8]) then
            podeFalar := false
        else
            podeFalar := true;

        if not (upcase (c) = 'P') then
            folheiaDestroi;

    until c = #$1b;

    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
    if numRegs > 0 then
        begin
            if sintFalarTudo then
                msgBaixo ('CTFOLFIM');  {'Folheamento terminado'}
//  --- Deleta os arquivos temporários ---
            for i := 1 to numRegs do
                if maiuscansi(retornaExtensao(regLido [i]^.carta^.nomArqCarta)) = 'TMP' then
                    if not apagaCarta (i, false) then break;
            desmontaListaDeCartas;
        end;

    totalDepois := numeroDeCartas (dirRecebe, 'F');
    if (aplicRegras) and (totalDepois > totalAntes) then
        aplicarRegrasCartas(true, false);

            {$I-}  chdir (dirAtual);  {$I+}
            if ioresult <> 0 then ;
end;

{-------------------------------------------------------------}

begin
end.
