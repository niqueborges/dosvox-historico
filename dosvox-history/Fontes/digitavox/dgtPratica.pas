{-------------------------------------------------------------}
{
{       Digitavox - Pratica da lição
{
{       Autor: Neno Henrique da Cunha Albernaz
{              neno@intervox.nce.ufrj.br
{       Em 05 de Outubro de 2019
{
{-------------------------------------------------------------}

unit dgtPratica;

interface

uses
    dvcrt,
    dvWin,
    sysutils,
    windows,
    classes,
    dvform,
    dvhora,
    dgtMsg,
    dgtTela,
    dgtVars,
    dgtUtil,
    dgtOriDedo,
    dgtEstatistica,
    dgtAjuda;

function praticarLicao (nLicao, quantidadeLicoes, divisorTempo: integer; nomeCurso, nomeArqCurso: string; poucasRepeticoes: boolean): boolean;

implementation

var
    listaExer: TStringList;
    soletraExer: boolean;
    tudoEmMaiusculo: boolean;
    repeticoesExer: integer;
    tempoPorCaracter: integer;
    mediaExer: integer;
    tempoTotalLicao: longInt;
    tempoPraticaLicao, tempoPraticaInicial: longInt;
    totalLetrasLicao: integer;
    nLetrasAcertou: integer;
    nLetrasErrou: integer;
    percentualAcerto: integer;
    totalPalavrasLicao: integer;
    nPalavrasAcertou: integer;
    nPalavrasErrou: integer;

{-------------------------------------------------------------}
{       Carrega nas variaveis os itens de uma lição
{-------------------------------------------------------------}

procedure carregarLicao (nLicao: integer; nomeArqCurso: string);
var
    s, licao: string;
begin
    licao := 'LICAO' + intToStr(nLicao);
    s := sintAmbienteArq (licao, 'SOLETRAEXER', '', nomeArqCurso);
    soletraExer := upperCase (s + 'S')[1] = 'S';
    s := sintAmbienteArq (licao, 'TUDO_EM_MAIUSCULO', '', nomeArqCurso);
    tudoEmMaiusculo := upperCase (s + 'S')[1] = 'S';
    s := sintAmbienteArq (licao, 'REPETICOESEXER', '', nomeArqCurso);
    if s = '' then s := '1';
    repeticoesExer := strToInt (s);
    if repeticoesExer < 1 then repeticoesExer := 1;
    s := sintAmbienteArq (licao, 'TEMPOPORCARACTER', '10', nomeArqCurso);
    if s = '' then s := '1';
    tempoPorCaracter := strToInt (s);
    if tempoPorCaracter < 1 then tempoPorCaracter := 1;
    s := sintAmbienteArq (licao, 'MEDIAEXER', '', nomeArqCurso);
    if s = '' then s := '90';
    mediaExer := strToInt (s);
    if (mediaExer < 1) or (mediaExer > 100) then mediaExer := 90;
end;

{-------------------------------------------------------------}
{       Fala o exercício, fazendo o teste se é para soletrar
{-------------------------------------------------------------}

procedure falarExercicio (exer: string; nlf: integer);
begin
    mostraAtividade;

    if soletraExer then
        soletra(exer, nlf)
    else
        begin
            if exer[1] = ' ' then sintSoletra (' ');
            sintetFala (exer,  nlf);
        end;
end;

{-------------------------------------------------------------}
{       Fala o tempo de prática, o tempo total e o percentual gasto
{-------------------------------------------------------------}

procedure falaTempoGasto (tempoPraticaLicao, tempoTotalLicao: longInt);
begin
    mensagem ('DGTTPDECO', -1); {'Tempo decorrido:'}
    sintetiza(formataTempo (tempoPraticaLicao));
    mensagem ('DGTTPTOT', -1); {'Tempo total:'}
    sintetiza (formataTempo (tempoTotalLicao));
    mensagem ('DGTPERGAS', -1); {'Percentual gasto'}
    sintetiza (intToStr((tempoPraticaLicao * 100) div (tempoPraticaLicao + tempoTotalLicao)) + ' %');
end;

{--------------------------------------------------------}
{       Grava o tempo inicial da lição
{--------------------------------------------------------}

procedure iniciaTempoPratica;
var h, m, s, c: word;
begin
    getTime(h, m, s, c);
    tempoPraticaInicial := ((h*60+m)*60+s)*100+c;
end;

{--------------------------------------------------------}
{       Grava o tempo final da lição e acumula a diferença com o inicial
{--------------------------------------------------------}

procedure finalizaTempoPratica;
var h, m, s, c: word;
begin
    getTime(h, m, s, c);
    tempoPraticaLicao := tempoPraticaLicao + (((h*60+m)*60+s)*100+c) - tempoPraticaInicial;
end;

{-------------------------------------------------------------}
{       Realização do exercício
{-------------------------------------------------------------}

function fazerExercicio (rep, nLicao: integer; exer, nomeCurso,  nomeArqCurso: string): char;
var
    c, c2: char;
    k, k2, nErro: integer;
    digitouPalavraCorreta: boolean;
label inicio;
begin
    nErro := 0;
    digitouPalavraCorreta := true;
    exer := exer + ' ';    // Tem que digitar um espaço no fim do exercício.
    c := ESC;
    result := ENTER;
    for k := 1 to length(exer) do
        begin
inicio:
            telaPraticaExercicio (rep, repeticoesExer, exer, k, nLicao , nomeCurso);
            pegaTeclado (falarTecla, c, c2);

            if c = ESC then
                begin
                    result := c;
                    break;
                end
            else
            if c = #0 then
                begin
                    finalizaTempoPratica;
                    if c2 = F9 then
                        c := selSetasPraticaLicao (nLicao, nomeCurso, c2);

                    if c = ESC then
                        begin
                            result := c;
                            break;
                        end
                    else
                    case c2 of
                        F1      : ajudaPraticaLicao (nLicao, nomeCurso);
                        F2, BAIX: begin
                                      sintSoletra (exer[k]);
                                      falaDedoTecla (exer[k], c2);
                                  end;

                        f3, CTLDIR: for k2 := k to length(exer) do
                                      sintSoletra (exer[k2]);

                        ESQ     : sintetiza (intToStr(rep) + ' de ' + intToStr(repeticoesExer));
                        CTLESQ  : if (nLetrasAcertou + nLetrasErrou) > 0 then sintetiza( intToStr((nLetrasAcertou * 100) div (nLetrasAcertou + nLetrasErrou)) + ' %')
                                  else sintetiza ('0 %');

                        CTLUP   : falaApresentacaoOuInstrucao (true, 'LICAO' + intToStr(nLicao), nomeArqCurso);
                        CTLDOWN : falaApresentacaoOuInstrucao (false, 'LICAO' + intToStr(nLicao), nomeArqCurso);
                        F4, DIR : falarExercicio (copy (exer, k, length(exer)), -1);
                        CTLF4   : desligarFalarTecla;
                        F5, CIMA: falarExercicio (exer, -1);
                        F6      : begin
                                      mensagem ('DGTLICAO', -1); {'Lição'}
                                      sintetiza (intToStr(nLicao));
                                      sintclek;
                                      falaApresentacaoOuInstrucao (true, 'LICAO' + intToStr(nLicao), nomeArqCurso);
                                  end;

                        F7      : falaApresentacaoOuInstrucao (false, 'LICAO' + intToStr(nLicao), nomeArqCurso);
                        F8      : falaHora;
                        CTLF8   : falaDia;
                        F9      : ; // Saiu do F9 com ESC
                        F12     : falaTempoGasto (tempoPraticaLicao, tempoTotalLicao);

                    else
                        msgBaixo ('DGTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}
                    end;
                    while not keypressed do;
                    iniciaTempoPratica;
                    goto inicio;
                end;

            if (tudoEmMaiusculo and (upcase(c) = upcase(exer[k]))) or ((not tudoEmMaiusculo) and (c = exer[k])) then
                begin
                    inc (nLetrasAcertou);
                    nErro := 0;
                end
            else
                begin
                    if not tocaEfeito (somErroExercicio) then sintBip;
                    while sintFalando do waitMessage;
                    inc (nLetrasErrou);
                    inc (nErro);
                    if nErro >= 3 then
                        begin
                            if keypressed then tocaEfeito (somErroExercicio);
                            while sintFalando do waitMessage;
                            mensagem ('DGTEXCERR', -1); {'Excesso de erro, tecle F1 para ajuda.'}
                            while sintFalando do waitMessage;
                        end;
                    if (not soletraExer) and  (not(exer[k] in [' ', '.', ';', ':', ',', '?', '!'])) then digitouPalavraCorreta := false;
                    addListaLetrasErrou (exer[k]);
                end;

            if (not soletraExer) and  (exer[k] = ' ') then
                begin
                    if digitouPalavraCorreta then inc (nPalavrasAcertou)
                    else inc (nPalavrasErrou);
                    digitouPalavraCorreta := true;
                end;

        end;
end;

{-------------------------------------------------------------}
{       Carrega os exercícios da lição em uma TStringList
{-------------------------------------------------------------}

function carregarExer (nLicao: integer; nomeArqCurso: string): boolean;
var
    s, licao: string;
    i: integer;
begin
    listaExer := TStringList.create;
    licao := 'LICAO' + intToStr(nLicao);
    i := 1;
    s := sintAmbienteArq (licao, 'EXER' + intToStr(i), '', nomeArqCurso);
    while s <> '' do
        begin
            listaExer.add (s);
            inc (i);
            s := sintAmbienteArq (licao, 'EXER' + intToStr(i), '', nomeArqCurso);
        end;

    if listaExer.count > 0 then
        result := true
    else
        result := false;
end;

{-------------------------------------------------------------}
{       Retorna o total de letras que devem ser digitadas na lição
{-------------------------------------------------------------}

function calcularTotalLetrasLicao: integer;
var
    i: integer;
    t: integer;
begin
    t := 0;
    for i := 0 to (listaExer.count -1) do
        t := t + length(listaExer[i]) + 1;
    result := t * repeticoesExer;
end;

{-------------------------------------------------------------}
{       Retorna o total de palavras que devem ser digitadas na lição
{-------------------------------------------------------------}

function calcularTotalPalavrasLicao: integer;
var
    i, p: integer;
    s: string;
    totalPalavras: integer;
begin
    totalPalavras := 0;
    for i := 0 to (listaExer.count -1) do
        begin
    s := trim(listaExer[i]);
            while s <> '' do
                begin
                    inc (totalPalavras);
                    p := pos (' ', s);
                    if p > 0 then
                        delete (s, 1, p)
                    else
                        s := '';
                    s := trim(s);
                end;
        end;

    result := totalPalavras * repeticoesExer;
end;

{-------------------------------------------------------------}
{       Praticar os exercícios da lição
{-------------------------------------------------------------}

function praticarLicao (nLicao, quantidadeLicoes, divisorTempo: integer; nomeCurso, nomeArqCurso: string; poucasRepeticoes: boolean): boolean;
var
    c: char;
    qtdExer, r, i, percentualPalavrasCorretas: integer;
    licao, exer, s, chegouNoFim, concluiu: string;
    desistiu: boolean;

label  fim;
begin
    carregarLicao (nLicao, nomeArqCurso);
    writeln;
    if modoTesteAtivo and poucasRepeticoes then
        begin
            if repeticoesExer > 2 then repeticoesExer := 2;
            mensagem ('DGTPOUREP', -1); {'Poucas repetições'}
        end;

    carregarExer (nLicao, nomeArqCurso);
    qtdExer := listaExer.count;
    totalLetrasLicao := calcularTotalLetrasLicao;
    nLetrasAcertou := 0;
    nLetrasErrou := 0;
    inicializaListaLetrasErrou;
    if soletraExer then
        totalPalavrasLicao := 0
    else
        totalPalavrasLicao := calcularTotalPalavrasLicao;
    nPalavrasAcertou := 0;
    nPalavrasErrou := 0;
    desistiu := false;
    tempoTotalLicao := (tempoPorCaracter * totalLetrasLicao * 100) div divisorTempo;
    tempoPraticaLicao := 0;
    licao := 'LICAO' + intToStr(nLicao);
    telaCursoLicao (nLicao, nomeCurso);
    writeln;
    mensagem ('DGTLICAO', -1); {'Lição'}
    sintetiza (intToStr(nLicao));

    falaApresentacaoOuInstrucao (true, 'LICAO' + intToStr(nLicao), nomeArqCurso);
    falaApresentacaoOuInstrucao (false, 'LICAO' + intToStr(nLicao), nomeArqCurso);

    for r := 1 to repeticoesExer do //Passa as repetições dos exercícios.
        for i := 0 to (qtdExer - 1) do //Passa por exercícios da lição.
            begin
                if (qtdExer > 1) or (r = 1) then
                    begin
                        exer := trim(listaExer[i]);
                        if i > 0 then tocaEfeito (somInicioExercicio);

                        telaPraticaExercicio (r, repeticoesExer, exer, 1, nLicao , nomeCurso);
                        falarExercicio (exer, -1);

                        while not keypressed do;
                        iniciaTempoPratica;
                    end;

                c := fazerExercicio (r, nLicao, exer, nomeCurso, nomeArqCurso);
                if c = ESC then
                    begin
                        finalizaTempoPratica;
                        limpaBaixo (wherey);
                        mensagem ('DGTDESIST', 2); {'Desistiu ...'}
                        desistiu := true;
                        goto fim;
                    end;

                finalizaTempoPratica;
                if tempoPraticaLicao > tempoTotalLicao then goto fim;
                if r < repeticoesExer then
                    iniciaTempoPratica;
            end;

fim:
    while keypressed do sintBip; // Alertar para o usuário parar de digitar
    limpaBufTec;
    listaExer.free;
    tocaEfeito (somFimExercicio);
    while sintFalando do waitMessage;
    delay (100);
    limpaBufTec;
    result := false;
    if (nLetrasAcertou + nLetrasErrou) > 0 then
        begin
            chegouNoFim := 'Não';
            concluiu := 'Não';
            percentualAcerto := (nLetrasAcertou * 100) div (nLetrasAcertou + nLetrasErrou);

            if (nPalavrasAcertou + nPalavrasErrou) > 0 then
                percentualPalavrasCorretas := (nPalavrasAcertou * 100) div (nPalavrasAcertou + nPalavrasErrou)
            else
                percentualPalavrasCorretas := 0;

            if tempoPraticaLicao > tempoTotalLicao then
                begin
                    limpaBufTec;
                    tocaEfeito ('clock');
                    mensagem ('DGTTMPESG', 1); {'Tempo esgotado ...'}
                    while sintFalando do waitMessage;
                    if comEfeitos then sintclek;
                end
            else
            if not desistiu then
                begin
                    chegouNoFim := 'Sim';
                    if percentualAcerto < mediaExer then
                        mensagem('DGTMEIN', 2) {'Percentual de acerto insuficiente, por favor refaça a lição.'}
                    else
                        begin
                            s := sintAmbienteArq (retiraNomeDir(nomeArqCurso), 'ULTIMACONCLUIDA', '', nomeArqUsuario);
                            if (s = '') or (nLicao > strToInt(s)) then
                                sintGravaAmbienteArq (retiraNomeDir(nomeArqCurso), 'ULTIMACONCLUIDA', intToStr(nLicao), nomeArqUsuario);
                            tocaEfeito (somConcluiuLicao);
                            mensagem ('DGTPARABE', 1); {'Parabéns! Lição concluída.'}
                            while sintFalando do waitMessage;
                            concluiu := 'Sim';
                            result := true;
                        end;
                end;

            gravaEstatisticasLicao (nLicao, nLetrasacertou, nLetrasErrou, nPalavrasAcertou, nPalavrasErrou, percentualAcerto, percentualPalavrasCorretas,
                                    tempoTotalLicao, tempoPraticaLicao, divisorTempo, repeticoesExer, totalLetrasLicao, totalPalavrasLicao,
                                    chegouNoFim, concluiu,nomeArqUsuario, nomeArqCurso);

            mostraEstatisticasLicao (nLicao, nLetrasacertou, nLetrasErrou, nPalavrasAcertou, nPalavrasErrou, percentualAcerto, percentualPalavrasCorretas,
                                     tempoTotalLicao, tempoPraticaLicao, totalLetrasLicao, totalPalavrasLicao, nomeCurso, concluiu);
        end;

    finalizaListaLetrasErrou;
end;

{-------------------------------------------------------------}

begin
end.
