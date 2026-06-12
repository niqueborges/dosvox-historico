program metrovox;

uses dvCrt, dvWin, dvHora, videoVox,
    mtEfeit, mtConf, mtMsg, mtVars,
    sysutils, mmSystem;

var
    c: char;
    tempo, repeteCompasso: integer;
    velocidadeDosvox, erro: integer;
    novosValores: boolean;

{--------------------------------------------------------}
{Menu principal
{--------------------------------------------------------}

procedure ajudaPrincipal;
begin
    writeln;

    mensagem ('MTOPTEC', 1); {'Opções nas teclas : '}
    delay (250);
    writeln;
    mensagem ('MTF1', 1); {'F1, ajuda'}
    mensagem ('MTF2', 1); {'F2, grava modelo'}
    mensagem ('MTF4', 1); {'F4, informa diapasão'}
    mensagem ('MTF6', 1); {'F6, informa novo valor'}
    mensagem ('MTF8', 1); {'F8, informa hora'}
    mensagem ('MTF9', 1); {'F9, informa novos efeitos'}
    mensagem ('MTCTLF9', 1); {'Control F9, modelos pré-definidos'}
    mensagem ('MTBARR1', 1); {'Barra de espaço, informa valor BPM atual'}
    mensagem ('MTSET', 1); {'Setas, cima e baixo, acresce ou decresce valor em 1 bpm'}
    mensagem ('MTPG', 1); {'PGUP ou PGDOWN, acresce ou decresce valor em 10 bpm'}
    mensagem ('MTESC1', 1); {'ESC, termina o programa'}
    delay (250);
    writeln;
    mensagem ('MTQUAL', 1); {'Qual sua opção ? '}

    writeln;
end;

{--------------------------------------------------------}
{Menu diapasão
{--------------------------------------------------------}

procedure ajudaDiapasao;
begin
    writeln;

    mensagem ('MTOPTEC', 1); {'Opções nas teclas : '}
    delay (250);
    writeln;
    mensagem ('MTA', 1); {'A -- nota LA'}
    mensagem ('MTB', 1); {'B -- nota SI'}
    mensagem ('MTD', 1); {'D -- nota RÉ'}
    mensagem ('MTE', 1); {'E -- nota MI'}
    mensagem ('MTG', 1); {'G -- nota SOL'}
    mensagem ('MTX', 1); {'X -- nota MI (oitavada)'}
    mensagem ('MTM', 1); {'M -- acorde MI maior'}
    mensagem ('MTS', 1); {'S -- acorde SOL maior'}
    mensagem ('MTBARR2', 1); {'Barra de espaço -- todas as cordas'}
    mensagem ('MTR', 1); {'R -- ativa ação repetida'}
    mensagem ('MTESC2', 1); {'ESC, retorna ao metrônomo'}
    delay (250);
    writeln;
    mensagem ('MTQUAL', 1); {'Qual sua opção ? '}

    writeln;
end;

{--------------------------------------------------------}
{Apresenta afinação do violão
{--------------------------------------------------------}

procedure informaDiapasao;
var c1: char;
    repete: boolean;

procedure tocaNota (c2: char);
begin

    sintVeloc (1);
    if repete then
    begin
        repeat
            sintSom ((c2));
            delay (500);
        until keyPressed;
    end
    else
        sintSom ((c2));
    sintVeloc (velocidadeDosvox);

end;

begin

    sintVeloc (1);
    sintSom ('MTDIMU');
    sintVeloc (velocidadeDosvox);

    mensagem ('MTINFNOT', 1); {'Informe a nota desejada, F1 ajuda : '}

    repeat

        c1:= readkey;
        if c1 = #0 then
            c1:= readkey;

        case upcase(c1) of
            F1: ajudaDiapasao;
            #32: tocaNota ('T');
            'E': tocaNota (c1);
            'A': tocaNota (c1);
            'D': tocaNota (c1);
            'G': tocaNota (c1);
            'B': tocaNota (c1);
            'X': tocaNota (c1);
            'M': tocaNota (c1);
            'S': tocaNota (c1);
            'R': begin
                repete:= not repete;
                if repete then
                    sintSom ('MTREP') {'irei repetir as notas'}
                else
                    sintSom ('MTNAOREP') {'não irei repetir as notas'}
                end;
        else
            if c1 <> ESC then
                mensagem ('MTAPTF1', 1);  {'Opção inválida, aperte F1 para ajuda'}
        end; //relativo ao case
    until c1 = ESC;

    limpaBufTec;

    writeln;
    mensagem ('MTRETOR', 1); {'OK, retornando ao metrônomo'}

end;

{--------------------------------------------------------}
{Finaliza o programa
{--------------------------------------------------------}

procedure finaliza;
begin

    sintVeloc (1);
    mensagem ('MTFIM', 1); {'Fim do programa'}
    sintVeloc (velocidadeDosvox);

    sintFim;
    doneWinCrt;

end;

{--------------------------------------------------------}
{Informa tempo e compasso
{--------------------------------------------------------}

procedure informaTempComp;
var opCom: char;
begin

    if (novosValores) or (bpmStr = '') then
    begin
        mensagem ('MTINFBPM', 0); {'Informe BPM, sugiro 60 : '}
        sintEditaCampo (bpmStr, wherex, wherey, 250, 80, true);
        val (bpmStr, bpm, erro);
        if erro <> 0 then
            bpm:= 60;
        writeln;
    end
    else
    begin
        val (bpmStr, bpm, erro);
        if erro <> 0 then
            bpm:= 60;
    end;

    if bpm < 1  then
        bpm:= 60;
    if bpm > 500  then
        bpm:= 500;

    if (novosValores) or (compassoStr = '') then
    begin
        mensagem ('MTINFCOM', 1); {'Informe unidade de compasso'}
        delay (150);
        mensagem ('MTINFBTQ', 0); {'Pressione : B - binário / T - ternário / Q - Quaternário'}
        opCom:= sintReadkey;
        writeln (opCom);
    end
    else
        opCom:= compassoStr[1];

    if upcase(opCom) = 'B' then
        compasso:= 2
    else
    if upcase(opCom) = 'T' then
        compasso:= 3
    else
    if upcase(opCom) = 'Q' then
        compasso:= 4
    else
    begin
        val (opCom, compasso, erro);
        if erro <> 0 then
            compasso:= 4;
    end;

    writeln; writeln;

    tempo := trunc ((1.0 / bpm) * 60000);

end;

{--------------------------------------------------------}
{Processa metrônomo
{--------------------------------------------------------}

procedure processa;
var opcao: char;
    ouvirEfeitos: boolean;
label de_novo;
begin

    mensagem ('MTOKF1', 1); {'OK, F1 ajuda'}

    ouvirEfeitos:= true;

    repeat

    de_novo:

    if ouvirEfeitos then
    begin

        if not keypressed then
        begin
            sndPlaySound (@somTempo[1], snd_async);
            delay (tempo);
        end;

        if compasso > 1 then
        begin
            repeteCompasso:= 0;
                repeat
                    repeteCompasso:= repeteCompasso + 1;
                    if not keypressed then
                    begin
                        sndPlaySound (@somCompasso[1], snd_async);
                        delay (tempo);
                    end;
                until (repeteCompasso = (compasso - 1)) or (keypressed);
        end;

    end; //Relativo ao ouvirEfeitos

        if keypressed then
            begin
                c:= readkey;
                if c = #0 then
                    c:= readkey;

                case c of
                    F1: ajudaPrincipal;
                    F2: gravaConf;
                    F3: leitorDeTela;
                    F4: informaDiapasao;
                    F6: begin
                        novosValores:= true;
                        informaTempComp;
                    end;
                    F8: falaHora;
                    F9: begin
                        if not usarPadrao then
                            if carregaEfeitos then
                            begin
                                usarEfeitos:= true;
                                trocarSom;
                                usarEfeitos:= false;
                            end
                            else
                                mensagem ('MTARQINE', 1); {'Arquivo que contém os efeitos não existe';}
                    end;
                    CTLF9: begin
                        if not usarPadrao then
                            if carregaModelos then
                            begin
                                usarModelos:= true;
                                trocarSom;
                                usarModelos:= false;
                            end
                            else
                                mensagem ('MTARQINE', 1); {'Arquivo que contém os efeitos não existe';}
                    end;
                    TAB: begin
                        ouvirEfeitos:= not ouvirEfeitos;
                        if not ouvirEfeitos then
                            sintBip;
                        limpaBufTec;
                        goto de_novo;
                    end;
                    #32: begin
                        tempo := trunc ((1.0 / bpm) * 60000);
                        mensagem ('MTVALBPM', 0); {'Valor BPM = '}
                        sintWrite (intToStr(bpm));
                        mensagem ('MTPAUATI', 1); {' -- PAUSE ATIVADA'}
                        while true do
                        begin
                            c:= readkey;
                            if c = #32 then
                                break;
                        end;
                        limpaBufTec;
                        mensagem ('MTPAUDES', 1); {' -- PAUSE DESATIVADA'}
                    end;
                    cima: bpm := bpm + 1;
                    baix: bpm := bpm - 1;
                    pgup: bpm := bpm + 10;
                    pgdn: bpm := bpm - 10;
                end; //relativo ao case

                if bpm < 1  then
                    bpm:= 60
                else
                if bpm > 500  then
                    bpm:= 500;

                if (c = CIMA) or (c = BAIX) or
                   (c = PGUP) or (c = PGDN) then
                begin
                    str (bpm, bpmStr);
                    tempo := trunc ((1.0 / bpm) * 60000);
                    sintetiza (intToStr(bpm));
                end
                else
                if c = esc then
                        begin
                            limpaBufTec;
                            mensagem ('MTCONFIM', 0); {'Confirma o fim do programa ? ';}
                            opcao:= sintReadkey;
                            writeln (opcao);
                        end;

            end; //relativo ao keypressed

    until (upcase(opcao) = 'S') or (opcao = ENTER);

end;

{--------------------------------------------------------}
{Inicializa o programa
{--------------------------------------------------------}

procedure inicializa;
var
    dir: string;
begin
    dir := sintAmbiente('METROVOX', 'DIRMETROVOX');
    if dir = '' then
        dir := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\metrovox';
    SintInic (0, dir);

    bpmStr:= '';
    compassoStr:= '';
    somTempo:= '';
    somCompasso:= '';
    usarPadrao:= false;
    novosValores:= false;

    val (sintAmbiente('TRADUTOR', 'VELOCIDADE'), velocidadeDosvox, erro);
    if erro <> 0 then
        velocidadeDosvox:= 2;

    clrscr;
    sintVeloc (1);
    mensagem ('MTINIC', 1); {'METRONOMO VOX - V. 1.0'}
    writeln ('Projeto DOSVOX - NCE/UFRJ');
    writeln; writeln;
    sintVeloc (velocidadeDosvox);

    if not carregaOcorrencias then
        usarPadrao:= true;

    pegaConf;

    if somTempo = '' then
        somTempo:= sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\metrovox\efeitos\padrao1.wav'
    else
        somTempo:= sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\metrovox\efeitos\' + somTempo + '.wav';

    if somCompasso = '' then
        somCompasso:= sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\metrovox\efeitos\padrao2.wav'
    else
        somCompasso:= sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\metrovox\efeitos\' + somCompasso + '.wav';

    informaTempComp;

end;

{--------------------------------------------------------}
{Rotina principal
{--------------------------------------------------------}

begin

    inicializa;
    processa;
    finaliza;

end.
