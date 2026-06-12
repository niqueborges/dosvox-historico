{--------------------------------------------------------}
{
{           Cartavox - Folheador de cartas
{
{--------------------------------------------------------}

unit carFolhe;

interface

uses
    dvarq,
    dvcrt,
    dvform,
    dvhora,
    dvWin,
    sysutils,
    windows,
    carApeli,
    carCopia,
    CARCC,
    carDecod,
    carEnvia,
    carEst,
    carLeit,
    carList,
    carMsg,
    carSMTP,
    carTela,
    carUtil,
    carVars,
    carSpam,
    carResp,
    carConf,
    carBusca,
    carAjuda;

    procedure folhearCartas (tipoFolheamento: char; pastaRegra: string);
procedure abreUmaCarta (nomeArq: string);

implementation

{-------------------------------------------------------------}
{       Trata o reenvio da carta
{-------------------------------------------------------------}

procedure reenviarCarta (nCar: integer);
var
    c: char;
    reenviarSelecionadas: boolean;
begin
    repeat
        limpaParteTela (19, 25);
        textBackground (RED);
        if temItemSelecionado then
            mensagem ('CTREESEL', 0)   {'Deseja reenviar todas as selecionadas? '}
        else
            mensagem ('CTREECAR', 0); {'Deseja reenviar esta carta? '}
        c := upcase(popupMenuPorLetra ('SN'));
        textBackground (BLACK);
        writeln;
    until c in ['S', 'N', ENTER, ESC];

    if (upcase(c) = ESC) or (not temItemSelecionado and (upcase(c) = 'N')) then
        begin
            msgBaixo ('CTDESIST');  {'Desistiu'}
            exit;
        end;

    if temItemSelecionado then
        reenviarSelecionadas := upcase(c) in ['S', ENTER]
    else
        reenviarSelecionadas := false;
    if not reenviarSelecionadas then
        begin
            if tiraCopia (regLido[nCar]^.carta^.nomArqCarta) then
                msgBaixo ('CTCARPRP'); {'Carta preparada para envio'}
        end
    else
    for nCar := 1 to numRegs do
        if regLido[nCar]^.selecionado then
            if not tiraCopia (regLido[nCar]^.carta^.nomArqCarta) then exit;

    if reenviarSelecionadas then
        if totalDeItensSelecionados > 1 then
            msgBaixo ('CTCARPRS') {'Cartas preparadas para envio'}
        else
            msgBaixo ('CTCARPRP'); {'Carta preparada para envio'}
end;

{-------------------------------------------------------------}
{       Troca o remetente de uma ou todas selecionadas, altera para a configuração escolhida.
{-------------------------------------------------------------}

function trocarRemetenteCartaPreparada (nCar: integer; dirAtual: string): boolean;
var
    c: char;
    i: integer;
    selecionadas: boolean;
    nomeConfiguracaoAux: string;

label desistiu;

begin
    trocarRemetenteCartaPreparada := false;
    selecionadas := false;
    telaFolheamentoCartas;
    mensagem ('CTMUDREM', 1); {'Mudar remetente'}
    if not keypressed then delay (200);
    if trim(nomeConfiguracao) = '' then
        begin
            mensagem ('CTSALCON', 1); {'Deve salvar a configuração para realizar esta operação'}
            exit;
        end;

    if temCartaSelecionada then
        begin
            repeat
                limpaParteTela (19, 25);
                textBackground (RED);
                mensagem ('CTTRCOSE', 0); {'Deseja trocar de conta todas as selecionadas? '}
                c := upcase(popupMenuPorLetra ('SN'));
                textBackground (BLACK);
                writeln;
            until c in ['S', 'N', ENTER, ESC];
            if c = ESC then goto desistiu;
            if c in ['S', ENTER] then selecionadas := true;
        end;

    nomeConfiguracaoAux := nomeConfiguracao;
    if not recuperaConfig (false, true) then goto desistiu;

if not existeDir (dirEnvia) then
        begin
            mensagem ('CTERRODI', 1); {'Erro: este diretório não está acessível'}
            if uppercase(nomeConfiguracaoAux) = 'LIXEIRA' then
                mudarParaConfigLixeira (false)
            else
            if uppercase(nomeConfiguracaoAux) = 'SPAM' then
                mudarParaConfigSpam (false)
            else
                recuperaConfigGrupoContas (nomeConfiguracaoAux);
            exit;
        end;

    if not selecionadas then
        prepararCarta ('Z', nCar, true, '', dirAtual)
    else
        for i :=  numRegs downto 1 do
            if regLido [i]^.selecionado then
                prepararCarta ('Z', i, true, '', dirAtual);

    trocarRemetenteCartaPreparada := true;
    exit;
desistiu:
    mensagem ('CTDESIST', 1); {'Desistiu ...'}
end;

{--------------------------------------------------------}
{   Folheia e responde cartas
{   TipoFolheamento:
{       F - todas Recebidas
{       L - recebidas Lidas
{       N - recebidas Não lidas
{       T Transmitidas
{       P Preparadas
{       CONTROL + <tipo folheamento>, mostram somente a da conta atual, no
{       caso de várias contas no mesmo diretório.
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

procedure preencheItemOnline (nItem: integer; var conteudo, fala: string;
                              var selec: boolean);
var
    s, s2: string;
begin
    if (conteudo <> '') or (fala <> '') then exit;
    folheiaObtemItem (nItem, s, regLido[nItem]^.selecionado);

    carregaArqPreencheCabPrin (nItem);

    if folheiaRecebidas then
        s := regLido [nItem]^.carta^.from
    else
        s := regLido [nItem]^.carta^.to_;
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

{-------------------------------------------------------------}
{       Troca de folheamento
{-------------------------------------------------------------}

function trocaDeFolheamento (dirAtual: string): boolean;
var c: char;
begin
    repeat
        msgBaixo ('CTQUAFOL'); {'Qual o tipo de folheamento? (F/N/L/P/T)'}
        c := popupMenuPorLetra ('FNLPT');
    until c in ['F', 'N', 'L', 'P', 'T', ^F, ^N, ^L, ^P, ^T, ENTER, ESC];

    if c in [ENTER, ESC] then
        begin
            result := false;
            msgBaixo ('CTDESIST'); {'Desistiu'}
        end
    else
        begin
            result := true;
            folheiaDestroi;
            desmontaListaDeCartas;
            {$I-}  chdir (dirAtual);  {$I+}
            if ioresult <> 0 then;
            folhearCartas (c, '');
        end;
end;

{-------------------------------------------------------------}
{       Passa carta a carta abrindo direto para leitura automaticamente
{    Opções:
{       ESC - Sair e voltar ao folheamento;
{       Enter, barra de espaço ou seta para baixo - abre direto a carta atual;
{       A - avança para a próxima carta;
{       R - Recua para carta anterior;
{       C ou Q - Fala em qual carta que está do total.
{-------------------------------------------------------------}

function  leituraCartasAutomatica (nCar: integer; listarPartesCarta: boolean): integer;
var
    c: char;
    selecionado, lerPrimeiraParte: boolean;
begin
    folheiaDestroi;
    sintclek;
    lerPrimeiraParte := true;
    while nCar <= numRegs do
        begin
            if not regLido [nCar]^.carta^.preenchido then
                begin
                    selecionado := regLido [nCar]^.selecionado;
                    carregaArqPreencheCabPrin ( nCar);
                    regLido [nCar]^.selecionado := selecionado;
                end;
            falaRemetente (nCar);
            if not agruparPorAssunto then
                falaAssunto (nCar, true, false, false);
            sintclek;

            if keypressed then
                begin
                    while keypressed do c := upcase(readkey);
                    case c of
                        F1: ajudaLeituraCartasAutomatica;
                        'A', BAIX: begin
                                nCar := Ncar +1;
                                sintclek;
                            end;
                        'R', CIMA: begin
                                nCar := Ncar -1;
                                if nCar < 1 then
                                    begin
                                        nCar := 1;
                                        sintbip;
                                    end
                                else
                                    sintclek;
                            end;
                        ESQ, DIR: begin
                                falaAssunto (nCar, c = DIR, false, true);
                                sintclek;
                            end;
                        'C', 'Q': falaQualItemDeQuantos (nCar, numRegs, false);
                        'F': begin
                                listarPartesCarta := not listarPartesCarta;
                                if listarPartesCarta then
                                    sintclek
                                else
                                    sintbip;
                            end;
                        ESC: break;
                    end;
                    if not (c in [' ', ENTER, 'L']) then continue;
                end;

            leCarta (nCar, false, lerPrimeiraParte, listarPartesCarta);
            if (folheiaRecebidas) and
               (pos ('M.CAR', uppercase(regLido[nCar]^.carta^.nomArqCarta)) = 0) then
                  marcarArquivo(nCar, 'M', true, nbaseRecebe);
            if (listarPartesCarta and regLido[ncar]^.contemAnexos) or (regLido[ncar]^.content_type = 'text/html')  then sintclek;
            nCar := Ncar + 1;
        end;
    limpaBufTec;
    mensagem ('CTOK', -1); {'Ok'}

    result := nCar;
end;

{--------------------------------------------------------}
{                    folheamento
{--------------------------------------------------------}

procedure folhearCartas (tipoFolheamento: char; pastaRegra: string);
var
    c, c2: char;
    nCar, i: integer;
    dirAtual, dirAtualCartas, extensao, s: string;
    podeFalar, auxBoolean: boolean;
    apertouShift: boolean;

label procurarAchou;

begin
    if not agruparPorAssunto then
        case tipoFolheamento of
            'F', ^F: msgBaixo ('CTRECEBI'); {'Recebidas'}
            'N', ^N: msgBaixo ('CTNAOLID'); {'Não lidas'}
            'L', ^l: msgBaixo ('CTLIDAS'); {'Lidas'}
            'P', ^P: msgBaixo ('CTPREPAR'); {'Preparadas'}
            'T', ^T: msgBaixo ('CTTRANSM'); {'Transmitidas'}
        end;

    tipoFolheGlobal := tipoFolheamento;
    getDir (0, dirAtual);

    folheiaServidor := false; //No momento utilizado somente no carAjuda.pas
    case tipoFolheamento of
        'F', 'L', 'N', ^F, ^L, ^N:
            begin
                folheiaRecebidas := true;
                folheiaTransmitidas := false;
                extensao := 'CAR';
                {$I-}  chdir (dirRecebe);  {$I+}
                if ioresult <> 0 then
                    begin
                        msgBaixo ('CTERDREC'); {'Diretório de recepção de cartas inexistente'}
                        exit;
                    end;
            end;
        'P', ^P:
            begin
                folheiaRecebidas := false;
                folheiaTransmitidas := false;
                extensao := 'CPR';
                {$I-}  chdir (dirEnvia);  {$I+}
                if ioresult <> 0 then
                    begin
                        msgBaixo ('CTERDENV'); {'Diretório para cartas a enviar inexistente'}
                        exit;
                    end;
            end;
        'T', ^T:
            begin
                folheiaRecebidas := false;
                folheiaTransmitidas := true;
                extensao := 'ENV';
                {$I-}  chdir (dirEnvia);  {$I+}
                if ioresult <> 0 then
                    begin
                        msgBaixo ('CTERDENV'); {'Diretório para cartas a enviar inexistente'}
                        exit;
                    end;
            end;
    end;

    if pastaRegra <> '' then
        begin
            getDir (0, dirAtualCartas);
            dirRecebe := pastaRegra;
            {$I-}  chdir (dirRecebe);  {$I+}
            if ioresult <> 0 then ;
        end;

    montaListaDeCartas (extensao, tipoFolheamento);
    if numRegs = 0 then
        begin
            msgBaixo ('CTSEMCAR');  {'Não tem carta neste diretório'}
            agruparPorAssunto := false;
            if pastaRegra <> '' then dirRecebe := dirAtualCartas;
            exit;
        end;

    if ordenarDataEnvio or agruparPorAssunto then
        ordenarLista ('date', ordemInversa, not agruparPorAssunto)
    else
        ordenarLista ('datahora', ordemInversa, sintFalarTudo);

    if agruparPorAssunto then
        procurarNaCarta (true, 1);

procurarAchou:
    telaFolheamentoCartas;
    if sintFalarTudo and (not agruparPorAssunto) then
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
        telaFolheamentoCartas;
        inicializaFolheamento;
        folheiaCorDoMeio (1, 30, CYAN);

        FolheiaPreencheItemOnline := @preencheItemOnline;
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
            c := selSetasFolheia (c2);

        if c = #0 then
            begin
                if (opcoesBasicas) and //Abaixo opções retiradas  do básico
                  (c2 in [F7, CTLF2, F2]) then
                    msgBaixo ('CTOPVINV') {'Opção inválida, aperte F1 para ajuda'}
                else
                case c2 of
                    CTLF2, F2, F4: if (tipoFolheamento in ['N', ^N]) and agruparPorAssunto then
                            begin
                                for i := 1 to numRegs do
                                    if c2 = CTLF2 then
                                        apagaCarta (i, not apertouShift)
                                    else
                                    if c2 = F2 then
                                        begin
                                            if not marcarArquivo(i, 'G', true, nbaseRecebe) then break;
                                        end
                                    else
                                        if not marcarArquivo(i, 'M', true, nbaseRecebe) then break;
                                c := ESC;
                            end;

                    ESQ, DIR: falaAssunto (nCar, c2 = DIR, false, true);
                    CTLESQ: sintetiza(regLido [nCar]^.carta^.from);
                    CTLDIR: if apertouShift then listarCopiasCarbono (nCar)
                            else sintetiza (regLido [nCar]^.carta^.to_ + '  ' + regLido [nCar]^.carta^.cc + ' ' + regLido [nCar]^.carta^.bcc);

                    F1:    ajudaFolheia;

                    F3:  begin
                                folheiaDestroi;
                                escolheOrdenacao(folheiaRecebidas);
                                goto procurarAchou;
                         end;

                    F5, f6:  begin
                                folheiaDestroi;
                                auxBoolean := agruparPorAssunto;
                                agruparPorAssunto := false;
                                procurarNaCarta (c2 = F5, nCar);
                                agruparPorAssunto := auxBoolean;
                                goto procurarAchou;
                         end;

                    F7, CTLF7: nCar := removerCarta (nCar, c2 = F7, false, apertouShift);
                    F8       : falaHora;
                    CTLF8    : falaDia;
                    DEL      : if apagaCarta (nCar, not apertouShift) then nCar := apagaUmRegs (nCar);

                    F12: begin {Não faz nada, continua folheando}
                            if sintFalarTudo then
                                msgBaixo ('CTCNTFOL')  {'Continue folheando ou tecle ESC'}
                            else
                                sintClek;
                         end;

                end;
            end
        else
            begin
                c := upcase (c);

                if (opcoesBasicas) and //Abaixo opções retiradas  do básico
                  (c in ['J', 'B', 'N', ^B, ^L, 'O', 'G', ^G, 'V', 'U']) then
                    msgBaixo ('CTOPVINV') {'Opção inválida, aperte F1 para ajuda'}
                else
                case c of
                    'J': begin
                            falaNomePrimeiro := not falaNomePrimeiro;
                            if falaNomePrimeiro then begin sintClek; sintClek; sintClek; end
                            else begin sintBip; sintBip; sintBip; end;
                         end;
                    'I': infoCarta (nCar);
                    ^I:   begin
                             sintSoletra (nomeConfiguracao);
                             delay (200);
                          end;
                    'B': editarApelidos;
                    'N': sintetiza (regLido [nCar]^.carta^.nomArqCarta);

                    'M':   if folheiaRecebidas then
                                marcaOuDesmarca(nCar, false, nbaseRecebe, true)
                            else
                                msgBaixo ('CTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}

                    'D': if apertouShift then falarDatasCarta (nCar, true)
                         else tamanhoCarta (nCar);
                    ^D : if apertouShift then falarDatasCarta (nCar, false)
                         else tamanhoTodasCartas;

                    'L', ENTER, CTLENTER:
                        if c <> CTLENTER then
                            begin
                                folheiaDestroi;
                                executarForaDosvoxGlobal := apertouShift;
                                leCarta (nCar, true, false, true);
                                if (folheiaRecebidas) and
                                   (pos ('M.CAR', uppercase(regLido[nCar]^.carta^.nomArqCarta)) = 0) then
                                        marcarArquivo(nCar, 'M', true, nbaseRecebe);
                                limpaBufTec;
                            end
                        else
                            nCar := leituraCartasAutomatica (nCar, upcase(sintAmbiente ('CARTAVOX', 'LISTARPARTESCARTALEITURAAUTOMATICA', 'NAO')[1]) = 'S');

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

                    'A', ^A: nCar := removerCarta (nCar, (c = 'A'), false, apertouShift);

                    'R', 'E': if folheiaRecebidas or (folheiaTransmitidas  and (c = 'E')) then
                            begin
                                folheiaDestroi;
                                prepararCarta (c, nCar, false, '', dirAtual);
                            end
                        else
                        if (folheiaTransmitidas) and (c = 'R') then
                            reenviarCarta (nCar)
                        else
                        if  (not folheiaTransmitidas) and (c = 'E') then
                            begin
                                folheiaDestroi;
                                prepararCarta ('E', nCar, true, '', dirAtual);
                            end
                        else
                        if (not folheiaRecebidas) and (not folheiaTransmitidas)  and (c = 'R') then
                            begin
                                if trocarRemetenteCartaPreparada (nCar, dirAtual) then
                                    begin
                                        folheiaDestroi;
                                        desmontaListaDeCartas;
                                        {$I-}  chdir (dirAtual);  {$I+}
                                        if ioresult <> 0 then;
                                        folhearCartas (tipoFolheamento, '');
                                        exit;
                                    end;
                            end
                        else
                            msgBaixo ('CTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}

                    ^R, ^E: if folheiaRecebidas  or (folheiaTransmitidas  and (c in [^E, ^R])) then
                            begin
                                folheiaDestroi;
                                prepararCarta (c, nCar, false, '', dirAtual);
                            end
                         else msgBaixo ('CTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}

                    'F': sintetiza (regLido [nCar]^.carta^.from);
                    ^F: if trim (regLido [nCar]^.carta^.delivered_to) <> '' then
                            sintetiza (regLido [nCar]^.carta^.delivered_to)
                        else
                        if trim (regLido [nCar]^.carta^.to_) <> '' then
                            sintetiza (regLido [nCar]^.carta^.to_)
                        else
                            sintetiza (regLido [nCar]^.carta^.bcc);

                    'C': begin
                            nCar := fazCopias (nCar, dirAtual);
                            limpaBufTec;
                            if nCar > numRegs then nCar := numRegs;
                         end;

                    ^C: begin
                            putClipBoard(pchar(retornaEMail(regLido [nCar]^.carta^.from)));
                            sintClek; sintclek;
                        end;

                    'S': selecionaApelido (nCar, folheiaRecebidas);
                    ^B, ^L: if folheiaRecebidas then
                             adicionaNoMataSpam (nCar, c = ^B)
                         else
                             msgBaixo ('CTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}
                    #32: regLido [nCar]^.selecionado := not regLido [nCar]^.selecionado;
                    #47: for i := 1 to numRegs do
                            regLido [i]^.selecionado := false;
                    ^S: for i := 1 to numRegs do
                            regLido [i]^.selecionado := true;

                    'O':
                        begin
                            editaArquivo (regLido [nCar]^.carta^.nomarqCarta);
                            regLido [nCar]^.carta^.preenchido := false;
                            carregaArqPreencheCabPrin (nCar);
                            limpabuftec;
                        end;

                    'T': if tipoFolheamento in ['P', ^P] then
                                begin
                                    transmitirCartas (true, tipoFolheamento, false);
                                    folheiaDestroi;
                                    desmontaListaDeCartas;
                                    {$I-}  chdir (dirAtual);  {$I+}
                                    if ioresult <> 0 then;
                                    folhearCartas (tipoFolheamento, '');
                                    exit;
                                end
                          else
                                transmitirCartas (false, 'P', false);

                    ^T: if folheiaTransmitidas then
                            enviarUmaCarta (regLido [nCar]^.carta^.nomArqCarta, false)
                        else
                            msgBaixo ('CTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}

                    'Q', ^Q: falaQualItemDeQuantos (nCar, folheiaNumItens, c = ^Q);
                    ^N: sintetiza (intToStr(nCar));
                    'G': nCar := posicaoNomeArqCarta (nCar);
                    ^G: nCar := posicaoCarta (nCar);
                    'V': begin
                            agruparPorAssunto := false;
                            if trocaDeFolheamento (dirAtual) then
                                begin
                                    if pastaRegra <> '' then
                                        dirRecebe := dirAtualCartas;
                                    exit;
                                end;
                         end;

                    ^P: if tipoFolheamento in ['N', ^N] then
                            begin
                                if agruparPorAssunto then
                                    begin
                                        for i := 1 to numRegs do
                                            if not marcarArquivo(i, 'G', true, nbaseRecebe) then
                                                break;
                                    end
                                else
                                    agruparPorAssunto := true;
                                c := ESC;
                            end
                        else
                            msgBaixo ('CTENFONL'); {'Entre no folheamento de não lidas para usar esta opção.'}

                    'U': if folheiaRecebidas then ativaRespAut (true, false, nCar);

                    'Z': nCar := gravarTodosAnexos (nCar);

                    ESC: if perguntaAoSairFolhe then
                            repeat
                                msgBaixo('CTSAIFOL'); {'Deseja sair do folheamento?'}
                                c := upcase(popupMenuPorLetra ('SN'));
                                if c in ['S', ENTER] then c := ESC
                                else
                                    begin
                                        msgBaixo('CTDESIST'); {'Desistiu'}
                                        c := 'N';
                                        if sintFalarTudo then
                                            msgBaixo ('CTCNTFOL')  {'Continue folheando ou tecle ESC'}
                                        else
                                            sintclek;
                                    end;
                                if c = ESC then
                                    agruparPorAssunto := false;
                            until upcase(c) in ['S', 'N', ENTER, ESC]
                          else
                            agruparPorAssunto := false;

                    ^W: begin  //Fecha folheamento direto sem perguntar.
                            c := ESC;
                            agruparPorAssunto := false;
                        end;

                else
                    if c <> ESC then msgBaixo ('CTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}
                end;

                if (numRegs >0) and (c <> ESC) and
                    (upcase(c) in ['I', ^I, 'B', ENTER, 'L', CTLENTER, 'P', 'A', ^A,
                    'R', ^R, 'E', ^E, 'C', 'S', 'O', 'T', 'U']) then
                        if sintFalarTudo then
                            msgBaixo ('CTCNTFOL')  {'Continue folheando ou tecle ESC'}
                        else
                            sintclek;

            end;

        if numRegs <= 0 then
            begin
                if (not agruparPorAssunto) and
                    not ((tipoFolheamento in ['P', ^P]) and (numRegs=0)) then
                    msgBaixo ('CTSEMCAR');  {'Não tem carta neste diretório'}
                c := ESC;
            end;

        if (upCase(c) in['N' , 'D', ^D, 'F', ^F, 'Q', ^Q, ^N, ^C,
            'I', ^I, 'B', 'P', 'A', ^A, 'R', ^R, 'E', ^E, 'C',
            'S', 'O', 'T', 'U']) or
            ( (c in [ENTER, 'L', CTLENTER]) and (not falaraposLeituraCarta)) or
            (c2 in [ESQ, DIR, CTLESQ, CTLDIR, f8, CTLF8, DEL]) then
            podeFalar := false
        else
            podeFalar := true;

        if not (upcase (c) in ['L', ENTER, CTLENTER, 'P', 'R', ^R, 'E', ^E]) then
            folheiaDestroi;

    until c in [#$1b, ^W];

    if (numRegs > 0) and (not agruparPorAssunto) then
        if sintFalarTudo then
            msgBaixo ('CTFOLFIM');  {'Folheamento terminado'}
    desmontaListaDeCartas;
    {$I-}  chdir (dirAtual);  {$I+}
    if ioresult <> 0 then;

    if agruparPorAssunto then
        folhearCartas (tipoFolheamento, pastaRegra);

    if pastaRegra <> '' then dirRecebe := dirAtualCartas;
end;
{-------------------------------------------------------------}
{       Carrega e abre uma carta para leitura
{-------------------------------------------------------------}

procedure abreUmaCarta (nomeArq: string);
var tipo, dirAtual: shortString;
begin
    getDir (0, dirAtual);
    if dirAtual[length(dirAtual)] = '\' then delete(dirAtual, length(dirAtual), 1);

    numRegs :=1;
    regLido [numRegs] := inicializaPEstrutura;
    regLido [numRegs]^.carta := inicializaPCarta;
    regLido [numRegs]^.carta^.nomArqCarta := dirAtual + '\' + nomeArq;

    tipo := ansiUpperCase(extractFileExt(nomeArq));
    if tipo = '.CAR' then     tipoFolheGlobal := 'F'
    else if tipo = '.ENV' then     tipoFolheGlobal := 'T'
    else tipoFolheGlobal := 'P';
    telaFolheamentoCartas;

    dirEnvia := dirAtual;
    dirRecebe := dirAtual;
    {$I-}  chdir (dirAtual);  {$I+}
                if ioresult <> 0 then ;

    leCarta (1, false, false, true);

    desmontaListaDeCartas;
end;

{-------------------------------------------------------------}

begin
end.
