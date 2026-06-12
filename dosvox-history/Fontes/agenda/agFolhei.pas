{--------------------------------------------------------}
{                  AGENVOX - visualização das ocorrências
{--------------------------------------------------------}

unit agFolhei;

interface

uses dvCrt, dvWin, dvHora, dvArq, dvForm, dvAmplia,
    agProg, agForm, agUtil, agVars, agMsg;

procedure carregaNomeArq;
procedure verificaCompromissos;
procedure menuFolhear;
procedure trataTecladoFolhear;
procedure escolheUmDia;
procedure verificaDesperta;
procedure sonsDoDespertador;
procedure trocaData (c: char);
procedure montaNomeArq;
procedure iniciaFolheamento;

const
    hs: array [1..96] of string = ('00:15', '00:30', '00:45',
     '01:00', '01:15', '01:30', '01:45',
    '02:00', '02:15', '02:30', '02:45',
    '03:00', '03:15', '03:30', '03:45',
    '04:00', '04:15', '04:30', '04:45',
    '05:00', '05:15', '05:30', '05:45',
    '06:00', '06:15', '06:30', '06:45',
    '07:00', '07:15', '07:30', '07:45',
    '08:00', '08:15', '08:30', '08:45',
    '09:00', '09:15', '09:30', '09:45',
    '10:00', '10:15', '10:30', '10:45',
    '11:00', '11:15', '11:30', '11:45',
    '12:00', '12:15', '12:30', '12:45',
    '13:00', '13:15', '13:30', '13:45',
    '14:00', '14:15', '14:30', '14:45',
    '15:00', '15:15', '15:30', '15:45',
    '16:00', '16:15', '16:30', '16:45',
    '17:00', '17:15', '17:30', '17:45',
    '18:00', '18:15', '18:30', '18:45',
    '19:00', '19:15', '19:30', '19:45',
    '20:00', '20:15', '20:30', '20:45',
    '21:00', '21:15', '21:30', '21:45',
    '22:00', '22:15', '22:30', '22:45',
    '23:00', '23:15', '23:30', '23:45', '24:00');

    nomeDia: array [0..6] of string [20] =
       ('Domingo', 'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado');

    nomeMes: array [1..12] of string [12] =
       ('Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
        'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro');

var numHora, numLin: integer;
    tempoCompromisso: string[5];
    diaSemana: integer;
    numDespert, maxDespert, erro: integer;
    hh, mn: array [1..96] of word;
    avisoCompromisso: array [1..96] of string[100];
    avisoDespert: array [1..96] of string[100];
    agendaInteligente, bipaAtivo: boolean;
    debug: boolean;
    stopCloseNaPlaca: boolean;

implementation

{--------------------------------------------------------}
{Carrega nomes e compromissos num vetor
{--------------------------------------------------------}

procedure carregaNomeArq;
var arq: text;
begin

    assign (arq, 'Compromissos da Agenda');
    {$i-} reset (arq); {$i+}
    if IOresult <> 0  then
        begin
            rewrite (arq);
            reset (arq);
        end;

        numLin:= 0;
    maxLin:= 0;

    while not eof (arq) do
        begin
            numLin:= numLin + 1;
            readln (arq, linhaCompromisso[numLin]);
            if linhaCompromisso[numLin] = '' then
                begin
                    numLin:= 0;
                    break;
                end;
        end;

    close (arq);

    maxLin:= numLin;

end;

{--------------------------------------------------------}
{Verifica ocorrencia de compromissos
{--------------------------------------------------------}

procedure verificaCompromissos;
var agendou: boolean;
    label fim;
begin

    if not jaEscolheuDia then
        begin
            str (dia, dd);
            if length (dd) = 1 then
                dd:= ('0' + dd);
            str (mes, mm);
            if length (mm) = 1 then
                mm:= ('0' + mm);
            str (ano, aa);
        end;

    tocaEfeito ('agTroPag');

    diaSemana := (4+calcDias (dia, mes, ano)) mod 7;
    sintWrite (nomeDia[diaSemana] + ', ');

    mensagem ('AGDIA', 0);  {'dia '}
    sintWriteln (dd);
    writeln;

    jaEscolheuDia:= false;
    agendou:= false;
    recargaNoVetor:= false;
    numDespert:= 0;
    maxDespert:= 0;

    if numLin = 0 then
        goto fim;

    for numHora:= 1 to 96 do
        begin

            tempoCompromisso:= hs[numHora];
            delete (tempoCompromisso, 3, 1);
            nomeDados:= (aa + mm + dd + tempoCompromisso + '.age');

            avisoCompromisso[numHora]:= '';

            for numLin:= 1 to maxLin do
                begin

                    if copy (linhaCompromisso[numLin], 1,
                    pos ('=', linhaCompromisso[numLin]) - 1) = nomeDados then
                        begin
                            mensagem ('AGAGECOM', 0);  {'Você agendou um compromisso às: '}
                            sintWrite (hs[numHora] + ' - ');
                            sintWriteln (copy (linhaCompromisso[numLin],
                            pos ('=', linhaCompromisso[numLin]) + 1, length (linhaCompromisso[numLin])));
                            avisoCompromisso[numHora]:= (copy (linhaCompromisso[numLin],
                            pos ('=', linhaCompromisso[numLin]) + 1, length (linhaCompromisso[numLin])));
                            verificaAtributos;
                            if somaDespert then
                                begin
                                    numDespert:= numDespert + 1;
                                    avisoDespert[numDespert]:= avisoCompromisso[numHora];
                                    val (copy (tempoCompromisso, 1, 2),
                                    hh[numDespert], erro);
                                    val (copy (tempoCompromisso, 3, 2),
                                    mn[numDespert], erro);
                                    maxDespert:= numDespert;
                                    somaDespert:= false;
                                end;
                            agendou:= true;
                            break;
                        end;
                end;
            if recargaNoVetor then
                break;
        end;

    fim:
    if not agendou then
        begin
            mensagem ('AGAGEVAZ', 1);  {'A agenda está vazia'}
            despertaOk:= false;
        end;

end;

{--------------------------------------------------------}
{Menu de opções no folheamento
{--------------------------------------------------------}

procedure menuFolhear;
begin

    tocaEfeito ('agMenu');

    mensagem ('AGOPTEC', 1); {'Opções nas teclas: '}
    mensagem ('AGCIMBAI', 1); {'Setas cima e baixo, caminham entre as horas'}
    mensagem ('AGDIRESQ', 1); {'Setas direita e esquerda, caminham entre os dias'}
    mensagem ('AGENTER', 1); {'A tecla ENTER, seleciona um compromisso'}
    mensagem ('AGDEL', 1); {'A tecla DEL, remove um compromisso'}
    mensagem ('AGHOMEND', 1); {'As teclas HOME e END, apresentam apenas compromissos'}
    mensagem ('AGINS', 1); {'A tecla INS, informa dia, mês e ano'}
    mensagem ('AGCTRLB', 1); {'CTRL + B, ativa ou desativa o bip'}
    mensagem ('AGCTRLR', 1); {'CTRL + R, remove compromissos antigos'}
    mensagem ('AGCTRLS', 1); {'CTRL + S, altera o som do despertador'}
    mensagem ('AGTEL', 1); {'F9, Caderno de Telefones'}
    mensagem ('AGQUALOP', 0); {'Qual sua opção? '}

end;

{--------------------------------------------------------}
{Trata teclado no folheamento
{--------------------------------------------------------}

procedure trataTecladoFolhear;
var c1, c2: char;
    processando: boolean;
label deNovo, executa, pulaHome, pulaUntilHome, pulaTend, pulaUntilTend;
begin

    numHora:= 1;
    processando := true;

    mensagem ('AGSETFOL', 1);  {'Folheando, use as setas, F1 ajuda'}

    while (processando)  do
       begin

           deNovo:

           if recargaNoVetor then
               begin
                   carregaNomeArq;
                   verificaCompromissos;
                   if numLin = 0 then
                       for numHora:= 1 to 96 do
                           avisoCompromisso[numHora]:= '';
                   numHora:= 1;
                   goto deNovo;
               end;

           if (despertaOk <> false) or (agendainteligente <> false) or (bipaAtivo <> false) then
               verificaDesperta;

           sintTecla (c1, c2);
           writeln;

           if stopCloseNaPlaca then
               begin
                   falahora;
                   tocaTudo((somDespert), 'S');
                   stopCloseNaPlaca:= false;
               end;

           if (maxDespert = 0) or (mn[maxDespert] = 99) then
               despertaOk:= false;

           if (c1 = #0) and (c2 = CIMA) then
                begin
                    if numHora > 1 then
                        numHora:= numHora - 1;
                        tocaEfeito ('agSetHor');

                    amplCampo (hs[numHora] + ' ' + avisoCompromisso[numHora], 1);

                    sintWrite (hs[numHora]);
                    if avisoCompromisso[numHora] <> '' then
                        tocaEfeito ('agSetCom');
                    sintWriteln (avisoCompromisso[numHora]);
                    amplCampo (hs[numHora] + ' ' + avisoCompromisso[numHora], 1);
                end
           else
           if (c1 = #0) and (c2 = BAIX) then
                begin
                    if numHora < 96 then
                        numHora:= numHora + 1;
                        tocaEfeito ('agSetHor');

                    amplCampo (hs[numHora] + ' ' + avisoCompromisso[numHora], 1);
                    sintWrite (hs[numHora] + ' ');
                    if avisoCompromisso[numHora] <> '' then
                        tocaEfeito ('agSetCom');
                    sintWriteln (avisoCompromisso[numHora]);
                    amplCampo (hs[numHora] + ' ' + avisoCompromisso[numHora], 1);
                end
           else
           if (c1 = #0) and (c2 = DIR) then
                begin
                    trocaData ('+');
                    verificaCompromissos;
                    numHora:= 1;
                end
           else
           if (c1 = #0) and (c2 = ESQ) then
                begin
                    trocaData ('-');
                    verificaCompromissos;
                    numHora:= 1;
                end
           else
           if (c1 = #0) and (c2 = PGUP) then
                begin
                    if numHora >= 10 then
                        numHora:= numHora - 10
                    else
                        NumHora:= 1;
                    sintWrite (hs[numHora]);
                    if avisoCompromisso[numHora] <> '' then
                        tocaEfeito ('agSetCom');
                    sintWriteln (avisoCompromisso[numHora]);
                end
           else
           if (c1 = #0) and (c2 = PGDN) then
                begin
                    if numHora <= 86 then
                        numHora:= numHora + 10
                    else
                        NumHora:= 96;
                    sintWrite (hs[numHora]);
                    if avisoCompromisso[numHora] <> '' then
                        tocaEfeito ('agSetCom');
                    sintWriteln (avisoCompromisso[numHora]);
                end
           else
           if (c1 = #0) and (c2 = F1) then
               menuFolhear
           else
           if (c1 = #0) and (c2 = F9) then
               begin
                   abreTelefones;
                   if not trocaDir (dir_agenda) then
                       exit;
               end
           else
           if (c1 = #0) and (c2 = F8) then
               begin
                   falaDia;
                   FalaHora;
               end
           else
           if (c1 = #0) and (c2 = DEL) then
               begin
                   montaNomeArq;
                   removeCompromissos;
                   tocaEfeito ('agVolta');
               end
           else
           if (c1 = #0) and (c2 = TEND) then
               begin
                   repeat
                   if numHora < 96 then
                       numHora:= numHora + 1
                   else
                       goto pulaUntilTend;
                   if avisoCompromisso[numHora] <> '' then
                       begin
                           sintWrite (hs[numHora]);
                           tocaEfeito ('agSetCom');
                           sintWriteln (avisoCompromisso[numHora]);
                           goto pulaTend;
                       end;
                   until numHora = 96;
                   pulaUntilTend:
mensagem ('AGNAOPON', 1);  {'Não existe nenhum compromisso além deste ponto'}
                   pulaTend:
               end
           else
           if (c1 = #0) and (c2 = HOME) then
               begin
                   repeat
                   if numHora > 1 then
                       numHora:= numHora - 1
                   else
                       goto pulaUntilHome;
                   if avisoCompromisso[numHora] <> '' then
                       begin
                           sintWrite (hs[numHora]);
                           tocaEfeito ('agSetCom');
                           sintWriteln (avisoCompromisso[numHora]);
                           goto pulaHome;
                       end;
                   until numHora = 1;
                   pulaUntilHome:
mensagem ('AGNAOPON', 1);  {'Não existe nenhum compromisso além deste ponto'}
                   pulaHome:
               end
               else
           if (c1 = #0) and (c2 = INS) then
               begin
                   sintetiza (nomeDia[diaSemana] + ', ');
                   sintetiza (dd + ' de ');
                   sintetiza (nomeMes[mes] + ' de ');
                   sintetiza (aa);
               end
           else
executa:
               case upcase(c1) of

                   ^B:  begin
                       bipaAtivo:= not bipaAtivo;
                       if bipaAtivo then
                           begin
                               mensagem ('AGBIPATI', 1);   {'Bip ativo'}
                               usarRelogio:= true;
                           end
                       else
                           mensagem ('AGBIPDES', 1);  {'Bip desativado'}
                   end;

//                   ^I:  begin
//                       agendaInteligente:= not agendaInteligente;
//                       if agendaInteligente then
//                           begin
//                               mensagem ('AGAGEINT', 1);   {'Modo inteligente '}
//                               usarRelogio:= true;
//                           end
//                       else
//                           mensagem ('AGAGENOM', 1);  {'Modo normal'}
//                   end;

                   ^D:  begin
                             debug := not debug;
                             if debug then
                                 mensagem ('AGMODDEB', 1)   {'Modo debug'}
                             else
                                 mensagem ('AGMODNOR', 1);  {'Modo normal'}
                   end;

                   ^T: sintWriteInt (maxLin);

                   ^R: begin
                       removeCompromissosPassados;
                       tocaEfeito ('agVolta');
                   end;

                   ^S: sonsDoDespertador;

                   ^X: sintReadln (dbg);

                   ENTER: begin
                       montaNomeArq;
                       iniciaDados;
                       tocaEfeito ('agVolta');
                   end;
                   ESC:  processando := false;
               else
                   mensagem ('AGOPINV', 1);  {'Opção inválida, aperte F1 para ajuda'}
               end;
       end;

    despertaOk:= false;
end;

{--------------------------------------------------------}
{Escolhe um dia qualquer
{--------------------------------------------------------}

procedure escolheUmDia;
var escData: string;
    dv, mv, av, numDig, digErro: integer;
label deNovo, erro;
begin

    deNovo:

    mensagem ('AGDIADES', 0);  {'Informe o dia desejado, no formato dia/mês/ano: '}
    sintReadln (escData);

    if escData = '' then
        exit;

    dd:= copy (escData, 1, pos ('/', escData) - 1 );
    delete (escData, 1, pos ('/', escData));
    numDig:= length (dd);
    if numDig = 1 then
        dd:= '0' + dd;
    val (dd, dv, digErro);
    if digErro <> 0 then goto erro;
    if (dv < 1) or (dv > 31) then goto erro;
    dia:= dv;

    mm:= copy (escData, 1, pos ('/', escData) - 1 );
    delete (escData, 1, pos ('/', escData));
    numDig:= length (mm);
    if numDig = 1 then
        mm:= '0' + mm;
    val (mm, mv, digErro);
    if digErro <> 0 then goto erro;
    if (mv < 1) or (mv > 12) then goto erro;
    mes:= mv;

    aa:= escData;
    numDig:= length (aa);
    if numDig <> 4 then         goto erro;
    val (aa, av, digErro);
    if digErro <> 0 then goto erro;
    ano:= av;

    //Tratamento para anos bissextos
    if (mes = 2) then
        if (dia = 29) and (ano mod 4 <> 0)  then
        begin
            mensagem ('AGNAOBIS', 1);  {'Desculpe, mas este ano não é bissexto'}
            goto erro;
        end;

            jaEscolheuDia:= true;
    recargaNoVetor:= true;
            trataTecladoFolhear;
            exit;

    erro:
    mensagem ('AGDATERR', 1);  {'Data inválida, por favor digite novamente'}
    goto deNovo;

end;

{--------------------------------------------------------}
{Loop para testar o relógio
{--------------------------------------------------------}

procedure verificaDesperta;
const tabVivo: array [0..3] of char = ('-', '\', '|', '/');
var diaAtual, mesAtual, anoAtual, semAtual: word;
    diaCompara: word;
    caracVivo : integer;
begin

    if not KeyPressed then
        begin
            tocaEfeito ('agClock');
            falaHora;

    if agendaInteligente then
        begin
            getDate (anoAtual, mesAtual, diaAtual, semAtual);
            diaCompara:= diaAtual;
        end;

            repeat

            caracVivo := (caracVivo + 1) mod 4;
            write (tabVivo [caracVivo]);
            gotoxy (1, wherey);

                if debug then
                    begin
                        if keyPressed then
                            exit;
                        bipSpeaker (5000)
                    end;

                delay (250);
                getTime (hora, min, seg, cent);

                if agendaInteligente then
                    begin
                        delay (250);
                        getDate (anoAtual, mesAtual, diaAtual, semAtual);
                        if bipaNoSpeaker then
                            bipaNoSpeaker:= false;
                        if diaCompara <> diaAtual then
                            begin
                                trocaData ('+');
                                verificaCompromissos;
                                numHora:= 1;
                                diaCompara:= diaAtual;
                            end;
                end;

                if bipaAtivo then
                    begin
                        if (seg < 2) and ((min = 0) or (min = 15) or (min = 30) or (min = 45)) then
                            begin
                            if bipaNoSpeaker then
                                bipSpeaker (5000)
                            else
                                begin
                                    if min = 0 then
                                        tocaEfeito ('bigban')
                                    else
                                        falaHora;
                                    delay (2000);
                                end;
                            end;
                    end;

                if despertaOk then
                    begin

                        for numDespert:= 1 to maxDespert do
                            if (mn[numDespert] = min) and (hh[numDespert] = hora) then
                                begin

                                    if bipaNoSpeaker then
                                        begin
                                            repeat
                                                bipSpeaker (5000);
                                                delay (250);
                                            until keyPressed;
                                            while keyPressed do readkey;
                                            sintWriteln (avisoDespert[numDespert]);
                                            keyPressed;
                                            mn[numDespert]:= 99;
                                            exit;
                                        end;

                                        if stopCloseNaPlaca then
                                            begin
                                                tocaTudo((somDespert), 'S');
                                                stopCloseNaPlaca:= false;
                                            end;
                                        tocaTudo((somDespert), 'P');
                                        stopCloseNaPlaca:= true;
                                        sintWriteln (avisoDespert[numDespert]);
                                        mn[numDespert]:= 99;
                                end;
                    end;

                until keyPressed;
        end;

end;

{--------------------------------------------------------}
{Escolhe o som do despertador
{--------------------------------------------------------}

procedure sonsDoDespertador;
var s: string;
begin

    if not trocaDir (dir_sonsDoDespertador) then
        exit;

    mensagem ('AGSETDES', 1);  {'Use as setas e escolha um novo som para o despertador'}
    garanteEspacoTela (10);
    s:= obtemNomeArq (10);
    writeln (s);

    if s <> '' then
        somDespert:= s
    else
        mensagem ('AGOKCAN', 1);  {'OK, operação cancelada'}

    sintWrite ('Assumido então ');
    sintWriteln (somDespert);

    if maiusc(somDespert) = 'SPEAKER' then
        bipaNoSpeaker:= true
    else
        bipaNoSpeaker:= false;

    if not trocaDir (dir_agenda) then
        exit;

end;

{--------------------------------------------------------}
{Troca data no folheamento
{--------------------------------------------------------}

procedure trocaData (c: char);
begin

    despertaOk:= false;

    if c = '+' then
        begin

            if (dia = 31) and (mes = 12) then
                begin
                    ano:= ano + 1;
                    mes:= 1;
                    dia:= 1;
                    exit;
        end;

            if (dia = 31)
and ((mes = 1)
or (mes = 3)
or (mes = 5)
or (mes = 7)
or (mes = 8)
or (mes = 10)) then
                begin
                    dia:= 1;
                    mes:= mes + 1;
                    exit;
                end;

            if (mes = 2) then
                if (dia = 29) or
                   ((dia = 28) and (ano mod 4 <> 0))  then
                begin
                    dia:= 1;
                    mes:= mes + 1;
                    exit;
                end;

            if (dia = 30)
and ((mes = 4)
or (mes = 6)
or (mes = 9)
or (mes = 11)) then
                begin
                    dia:= 1;
                    mes:= mes + 1;
                    exit;
                end;

            dia:= dia + 1;
            exit;

                end;

    if c = '-' then
        begin

            if (dia = 1) and (mes = 1) then
                begin
                    ano:= ano - 1;
                    mes:= 12;
                    dia:= 31;
                    exit;
        end;

            if (dia = 1)
and (mes = 3) then
                begin
                    dia:= 28;
                    mes:= mes - 1;
                    exit;
                end;

            if (dia = 1)
and ((mes = 5)
or (mes = 7)
or (mes = 10)
or (mes = 12)) then
                begin
                    dia:= 30;
                    mes:= mes - 1;
                    exit;
                end;

            if (dia = 1)
and ((mes = 2)
or (mes = 4)
or (mes = 6)
or (mes = 8)
or (mes = 9)
or (mes = 11)) then
                begin
                    dia:= 31;
                    mes:= mes - 1;
                    exit;
                end;

            dia:= dia - 1;
            exit;

                end;

end;

{--------------------------------------------------------}
{Monta nome completo do arquivo de trabalho
{--------------------------------------------------------}

procedure montaNomeArq;
begin

    str (dia, dd);
    if length (dd) = 1 then
        dd:= ('0' + dd);
    str (mes, mm);
    if length (mm) = 1 then
        mm:= ('0' + mm);
    str (ano, aa);

    tempoCompromisso:= hs[numHora];
    delete (tempoCompromisso, 3, 1);

    nomeDados:= (aa + mm + dd + tempoCompromisso + '.age');

end;

{--------------------------------------------------------}
{Rotina principal
{--------------------------------------------------------}

procedure iniciaFolheamento;
var statusBip: string;
begin

    statusBip:= (sintAmbiente('AGENDA', 'BIPATIVO'));
    if statusBip = '' then
        bipaAtivo:= false
    else
    if maiusc(statusBip[1]) <> 'N' then
        bipaAtivo:= true;

    recargaNoVetor:= true;

    trataTecladoFolhear;

end;

end.
