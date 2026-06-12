{--------------------------------------------------------}
{
{           Cartavox - Procura de cartas
{
{--------------------------------------------------------}

unit carBusca;

interface

uses
    dvarq,
    dvcrt,
    dvform,
    dvWin,
    sysutils,
    windows,
    carDecod,
    carEst,
    carMsg,
    carTela,
    carUtil,
    carVars,
    carAjuda;

procedure procurarNaCarta (folheiaAchados: boolean; nCar: integer);

implementation

{--------------------------------------------------------}
{       procura uma string no cabeçalho da carta ou na carta toda
{--------------------------------------------------------}

procedure procurarNaCarta (folheiaAchados: boolean; nCar: integer);
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
                        s := linhasArquivo[i];
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
            'A': begin
                    if trim(limpaAssunto(regLido [nCar]^.carta^.subject)) = '' then
                        procuraUmItem := textoBusc = (regLido [nCar]^.carta^.subject)
                    else
                        procuraUmItem := textoBusc = limpaAssunto(regLido [nCar]^.carta^.subject);
                 end;
            'D': procuraUmItem := pos (textoBusc, regLido [nCar]^.carta^.delivered_to + regLido [nCar]^.carta^.to_ + regLido [nCar]^.carta^.bcc) <> 0;
            'R': procuraUmItem := textoBusc = retornaEmail (regLido [nCar]^.carta^.from);
            'H': procuraUmItem := textoBusc = dateToStr (fileDateToDateTime (regLido [nCar]^.carta^.datahora))
        else
            procuraUmItem := procuraEmUmArquivo (nCar, tipoProcura);
        end;
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
        if sintFalarTudo then
            mensagem ('CTF1AJUD', 1)         {'F1 ajuda '}
        else
            writeLn (pegaTextoMensagem('CTF1AJUD'));         {'F1 ajuda '}
        c := upcase (readkey);
        if c = #0 then
            begin
                c := readkey;
                if c = F1 then ajudaBuscaFoleamentoCartas
                else
                if (c = BAIX) or (c = CIMA) then c := selSetasBuscaFoleamentoCartas;
            end;
    until c in ['C', 'T', 'B', 'A', 'R', 'D', 'H', ESC, ENTER, '0' .. '9'];
    if sintFalarTudo and (not agruparPorAssunto) then
        sintWriteln (c);

    if (not agruparPorAssunto) and (c in ['R', 'D', 'A']) then
        for i := 1 to numRegs do
            if not regLido [i]^.carta^.preenchido then
                begin
                    selecionado := regLido [i]^.selecionado;
                    carregaArqPreencheCabPrin ( i);
                    regLido [i]^.selecionado := selecionado;
                    if clek and ( (i mod 500) = 0) then sintclek;
                    if keypressed then c2 := quantasCartasDoTotal (i, numRegs);
                    if c2 = ESC then break;
                end;

    case c of
        'A': begin
                textoBusc := limpaAssunto(regLido [nCar]^.carta^.subject);
                if trim (textoBusc) = '' then
                    textoBusc := regLido [nCar]^.carta^.subject;
             end;
        'D': if trim (regLido [nCar]^.carta^.delivered_to) <> '' then
                textoBusc := retornaEmail (regLido [nCar]^.carta^.delivered_to)
             else
             if trim (regLido [nCar]^.carta^.to_) <> '' then
                textoBusc := retornaEmail (regLido [nCar]^.carta^.to_)
             else
                textoBusc := retornaEmail (regLido [nCar]^.carta^.bcc);
        'R': textoBusc := retornaEmail (regLido [nCar]^.carta^.from);
        'H': textoBusc := dateToStr (fileDateToDateTime (regLido [nCar]^.carta^.datahora))
    else
    if c in ['0' .. '9'] then
        begin
            textoBusc := trim(sintAmbiente('CARTAVOX', 'PROCURAAUTOMATIZADA' + c));
            if textoBusc = '' then
                begin
                    mensagem ('CTPNCONF', 1); {'Tipo de procura não configurado.'}
                    sintbip;
                    exit;
                end;
            if (length(textoBusc)  < 3) or (pos(' ', textoBusc) = 0) or
              (not(upcase(textoBusc[1]) in ['C', 'B', 'T'])) then
                begin
                    mensagem ('CTPROAER', 0);  {'Erro na procura automatizada número '}
                    sintWriteln (c);
                    exit;
                end;
            c := upcase(textoBusc[1]);
            delete (textoBusc, 1, 2);
            sintWrite (c); write(' ');
            sintWriteln (textoBusc);
            sintclek;
            textoBusc := semAcentos (textoBusc);
        end
    else
        repeat
            textoBusc := 'reply-to';
            if c in ['C', ENTER] then
                mensagem ('CTINFPRO', 1)    {'Informe o texto a procurar no cabeçalho da carta'}
            else
            if C = 'T' then
                mensagem ('CTINPROT', 1)    {'Informe o texto a procurar em toda carta'}
            else
            if c = 'B' then
                mensagem ('CTPROCOR', 1)    {'Informe o texto a procurar no corpo da carta'}
            else
                begin
                    mensagem ('CTDESIST', 2);  {'Desistiu...'}
                    exit;
                end;
            c2 := sintEditaCampo (textoBusc, 1, wherey, 255, 80, true);
            textoBusc := semAcentos (textoBusc);
        until c2 in [ENTER, ESC];
    end;

    if ((c2 = ESC) or (textoBusc = '')) and (not agruparPorAssunto) then
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

                    if keypressed then
                        begin
                            while keypressed do c := upcase(readkey);
                            case c of
                                ESC: begin
                                        mensagem ('CTDESIST', 2);  {'Desistiu...'}
                                        exit;
                                    end;
                            else
                                begin
                                    falaQualItemDeQuantos (numRegs - atual, numRegs, false);
                                    sintetiza (intToStr(((numRegs - atual)* 100) div numRegs) + ' %');
                                end;
                            end;
                        end;

                end;
        end;

    if not agruparPorAssunto then
        if achouJaUma then
            msgBaixo ('CTACHEI')     {'Achei'}
        else
            msgBaixo ('CTNACHEI');    {'Não achei'}
end;

{-------------------------------------------------------------}

begin
end.
