{-------------------------------------------------------------}
{
{       Digitavox - Tratamento das lições
{
{       Autor: Neno Henrique da Cunha Albernaz
{              neno@intervox.nce.ufrj.br
{       Em 05 de Outubro de 2019
{
{-------------------------------------------------------------}

unit dgtLicoes;

interface

uses
    dvcrt,
    dvWin,
    sysutils,
    windows,
    dvform,
    dvhora,
    dgtMsg,
    dgtTela,
    dgtVars,
    dgtUtil,
    dgtPratica,
    dgtAjuda;

procedure  validarLicoes (nomeArqCurso: string);
procedure ListaDadosLicao (nomeCurso, nomeArqCurso: string);
procedure listaLicoesCurso (divisorTempo: integer; nomeArqCurso: string);

implementation

{-------------------------------------------------------------}
{       Retorna se a lição tem todos os parâmetros esenciais
{-------------------------------------------------------------}

function licaoValida (nLicao: integer; nomeArqCurso: string): boolean;
var licao: string;
begin
    licao := 'LICAO' + intToStr(nLicao);
    if ( sintAmbienteArq (licao, 'APT1', '', nomeArqCurso) = '') or
         (sintAmbienteArq (licao, 'IST1', '', nomeArqCurso) = '') or
         (sintAmbienteArq (licao, 'EXER1', '', nomeArqCurso) = '') or
         (sintAmbienteArq (licao, 'SOLETRAEXER', '', nomeArqCurso) = '') or
         (sintAmbienteArq (licao, 'REPETICOESEXER', '', nomeArqCurso) = '') or
         (sintAmbienteArq (licao, 'TEMPOPORCARACTER', '', nomeArqCurso) = '') or
         (sintAmbienteArq (licao, 'MEDIAEXER', '', nomeArqCurso) = '') or
         (sintAmbienteArq (licao, 'TUDO_EM_MAIUSCULO', '', nomeArqCurso) = '') then
            result := false
    else
            result := true;
end;

{-------------------------------------------------------------}
{       Varre todas as lições de um curso, fala na primeira lição com problema ou "Ok" para todas válidas
{-------------------------------------------------------------}

procedure  validarLicoes (nomeArqCurso: string);
var
    i, qtdLicoes: integer;
begin
    qtdLicoes := strToInt (sintAmbienteArq ('CURSO', 'QUANTIDADELICOES', '',  nomeArqCurso));
    for i := 1 to qtdLicoes do
        if not licaoValida (i, nomeArqCurso) then
            begin
                mensagem ('DGTLICAO', -1);        {'Lição'}
                sintetiza (intToStr(i));
                delay (50);
                msgBaixo ('DGTLIPRO'); {'Esta lição está com problemas ....'}
                exit;
            end;
    msgBaixo ('DGTOK'); {'Ok'}
end;

{-----------------------------------------}
{       Lista as informações da lição
{-----------------------------------------}

procedure mostraDadosLicao (nLicao, divisorTempo: integer; nomeCurso, nomeArqCurso: string);
var
    nItem, i: integer;
    qtdExer,tempoPorCaracter, repeticoesExer: integer;
    totalLetrasLicao, totalPalavrasLicao: integer;
    tempoTotalLicao: longInt;
    c, c2: char;
    item, s, s2, licao: string;
    soletraExer, selecionado: boolean;
begin
    if not licaoValida (nLicao, nomeArqCurso) then
        begin
            msgBaixo ('DGTLIPRO'); {'Esta lição está com problemas ....'}
            exit;
        end;

    telaCursoLicao (nLicao, nomeCurso);
    writeln (centralizaFrase(pegaTextoMensagem('DGTDADLI'))); {' Leia os dados da lição com as setas verticais, tecle ESC para sair'}
    mensagem ('DGTDADLI', -1); {'Leia os dados da lição com as setas verticais, tecle ESC para sair'}
    if comEfeitos then sintclek;
    licao := 'LICAO' + intToStr(nLicao);
    qtdExer := quantidadeExerLicao (nLicao, nomeArqCurso);

    folheiaCria (wherex, wherey, 79, 23);
    s := copy (nomeCurso + BRANCOS, 1, 80);
    folheiaAdicionaEspecial (s, false, 'Curso: ' + nomeCurso);
    s := copy ('Lição: ' + intToStr(nLicao) + BRANCOS, 1, 80);
    folheiaAdicionaEspecial (s, false, 'Lição: ' + intToStr(nLicao));

    s := sintAmbienteArq (retiraNomeDir(nomeArqCurso), 'ULTIMACONCLUIDA', '', nomeArqUsuario);
    if (trim(s) = '') or (nLicao > strToInt(s)) then s := 'Não'
    else s := 'Sim';
    s2 := 'Concluída: ' + s;
    s := copy (s2 + BRANCOS, 1, 80);
    folheiaAdicionaEspecial (s, false, s2);

    s := sintAmbienteArq (licao, 'REPETICOESEXER', '', nomeArqCurso);
    repeticoesExer := strToInt (s);
    s2 := 'Repetições: ' + s;
    s := copy (s2 + BRANCOS, 1, 80);
    folheiaAdicionaEspecial (s, false, s2);

    s:= sintAmbienteArq (licao, 'TEMPOPORCARACTER', '', nomeArqCurso);
    tempoPorCaracter := strToInt (s);
    s2:= 'Tempo por caractere em segundos: ' + s;
    if divisorTempo > 1 then s2 := s2 + '/' + intToStr(divisorTempo);
    s := copy (s2 + BRANCOS, 1, 80);
    folheiaAdicionaEspecial (s, false, s2);

    totalLetrasLicao := quantidadeLetrasLicao (qtdExer, repeticoesExer, nLicao, nomeArqCurso);
    s2:= 'Total de caracteres: ' + intToStr(totalLetrasLicao);
    s := copy (s2 + BRANCOS, 1, 80);
    folheiaAdicionaEspecial (s, false, s2);

    s := sintAmbienteArq (licao, 'SOLETRAEXER', '', nomeArqCurso);
    soletraExer := upcase((s + 'S')[1]) = 'S';
    if not soletraExer then
        begin
            totalPalavrasLicao := quantidadePalavrasLicao (qtdExer, repeticoesExer, nLicao, nomeArqCurso);
            s2:= 'Total de palavras: ' + intToStr(totalPalavrasLicao);
            s := copy (s2 + BRANCOS, 1, 80);
            folheiaAdicionaEspecial (s, false, s2);
        end;

    tempoTotalLicao := (tempoPorCaracter * totalLetrasLicao * 100) div divisorTempo;
    s2:= 'Tempo máximo para concluir: ' + formataTempo (tempoTotalLicao);
    s := copy (s2 + BRANCOS, 1, 80);
    folheiaAdicionaEspecial (s, false, s2);
    s2 := 'Percentual de acertos mínimo: ' + sintAmbienteArq (licao, 'MEDIAEXER', '', nomeArqCurso);
    s := copy (s2 + BRANCOS, 1, 80);
    folheiaAdicionaEspecial (s, false, s2);
    s2 := 'Maiúsculas dispensadas: ' + sintAmbienteArq (licao, 'TUDO_EM_MAIUSCULO', '', nomeArqCurso);
    s := copy (s2 + BRANCOS, 1, 80);
    folheiaAdicionaEspecial (s, false, s2);
    s2 := 'Quantidade de exercícios: ' + intToStr(qtdExer);
    s := copy (s2 + BRANCOS, 1, 80);
    folheiaAdicionaEspecial (s, false, s2);

    for i :=  1 to qtdExer do
        begin
            s2 := 'Exercício ' + intToStr(i) + ': ' + sintAmbienteArq (licao, 'EXER' + intToStr(i), '', nomeArqCurso);
            s := copy (s2 + BRANCOS, 1, 80);
            folheiaAdicionaEspecial (s, false, s2);
        end;

    nItem := 1;
    repeat
        folheiaExecuta (nItem, nItem, c, c2, true);
        folheiaObtemItem (nItem, item, selecionado);
        item := trim (copy (item, pos(':', item)+1, length (item)));

        if upcase (c) = ^C then
            begin
                putClipBoard(@item[1]);
                sintclek; sintclek;
            end
        else
        if upcase (c) <> ESC then
            c := sintEditaCampo (item, 1, 25, 255, 80, true);
    until upcase(c) = ESC;
    folheiaDestroi;
end;

{-------------------------------------------------------------}
{       Mostra os dados da lição, perguntando qual lição?
{-------------------------------------------------------------}

procedure ListaDadosLicao (nomeCurso, nomeArqCurso: string);
var
    nLicao,qtdLicoes: integer;
begin
    qtdLicoes := strToInt (sintAmbienteArq ('CURSO', 'QUANTIDADELICOES', '',  nomeArqCurso));
    if qtdLicoes = 1 then
        nLicao := 1
    else
        begin
            msgBaixo ('DGTQUALI'); {'Qual o número da lição?'
            mensagem ('DGTDIGDE', -1); {'Digite de '}
            sintetiza ('1 a ' + intToStr(qtdLicoes));
            write (' ' + pegaTextoMensagem('DGTDIGDE') + ' 1 a ' + intToStr(qtdLicoes));
            sintReadInt (nLicao);
            if (nLicao < 1) or (nLicao > qtdLicoes) then
                begin
                    msgBaixo ('DGTDESIST'); {'Desistiu ...'}
                    exit;
                end;
        end;

    mostraDadosLicao (nLicao, 1, nomeCurso, nomeArqCurso);
end;

{-------------------------------------------------------------}
{       Inicializa os arquivos de efeitos de som padrão para o curso
{-------------------------------------------------------------}

procedure     inicializaArqsSons;
begin
    somIniCurso := 'visual';
    somFimCurso := 'escond';
    somIniLicao := 'mod';
    somFimLicao := 'prog';
    somInicioExercicio := 'branco';
    somFimExercicio := 'e-fim';
    somErroExercicio := 'somerro';
    somConcluiuLicao := 'palmas';
end;

{-------------------------------------------------------------}
{       Busca no arquivo do curso o nome dos arquivos de som
{-------------------------------------------------------------}

procedure carregaArqsSons (nomeArqCurso: string);
var s: string;
begin
    s := sintAmbienteArq ('CURSO', 'SOMNOMECURSO', '', nomeArqCurso);
    if s <> '' then somNomeCurso := s;
    s := sintAmbienteArq ('CURSO', 'SOMAPRESENTACAO', '', nomeArqCurso);
    if s <> '' then somApresentacao := s;
    s := sintAmbienteArq ('CURSO', 'SOMINSTRUCAO', '', nomeArqCurso);
    if s <> '' then somInstrucao := s;
    s := sintAmbienteArq ('CURSO', 'SOMINICURSO', '', nomeArqCurso);
    if s <> '' then somIniCurso := s;
    s := sintAmbienteArq ('CURSO', 'SOMFIMCURSO', '', nomeArqCurso);
    if s <> '' then somFimCurso := s;
    s := sintAmbienteArq ('CURSO', 'SOMINILICAO', '', nomeArqCurso);
    if s <> '' then somIniLicao := s;
    s := sintAmbienteArq ('CURSO', 'SOMFIMLICAO', '', nomeArqCurso);
    if s <> '' then somFimLicao := s;
    s := sintAmbienteArq ('CURSO', 'SOMINICIOEXERCICIO', '', nomeArqCurso);
    if s <> '' then somInicioExercicio := s;
    s := sintAmbienteArq ('CURSO', 'SOMFIMEXERCICIO', '', nomeArqCurso);
    if s <> '' then somFimExercicio := s;
    s := sintAmbienteArq ('CURSO', 'SOMERROEXERCICIO', '', nomeArqCurso);
    if s <> '' then somErroExercicio := s;
    s := sintAmbienteArq ('CURSO', 'SOMCONCLUIULICAO', '', nomeArqCurso);
    if s <> '' then somConcluiuLicao := s;
end;

{-------------------------------------------------------------}
{       Tratamento das mensagens do fim da lição
{-------------------------------------------------------------}

function trataFimLicao (nLicao, quantidadeLicoes: integer; concluiuLicao: boolean): integer;
begin
    if concluiuLicao and (nLicao = quantidadeLicoes) then
        begin
            tocaEfeito (somConcluiuLicao);
            msgBaixo     ('DGTCURCON'); {'Parabéns! Concluiu o curso.'}
            inc (nLicao);
        end
    else
    if concluiuLicao then
        begin
            inc (nLicao);
            msgBaixo ('DGTPRXLI'); {'Tecle Enter para começar a lição'}
//            if comEfeitos then sintclek;
            sintWrite (' ' + intToStr(nLicao));
        end
    else
        begin
            msgBaixo ('DGTREPLI'); {'Tecle Enter para repetir a lição'}
//            if comEfeitos then sintclek;
            sintWrite (' ' + intToStr(nLicao));
        end;

    result := nLicao;
end;

{-------------------------------------------------------------}
{       Retorna o número da lição do curso a fazer
{-------------------------------------------------------------}

function licaoAFazer (quantidadeLicoes: integer; nomeArqCurso: string): integer;
var
    s: string;
    aFazer: integer;
begin
    s := sintAmbienteArq (retiraNomeDir(nomeArqCurso), 'ULTIMACONCLUIDA', '0', nomeArqUsuario);
    if trim(s) = '' then
        begin
            sintGravaAmbienteArq (retiraNomeDir(nomeArqCurso), 'ULTIMACONCLUIDA', '', nomeArqUsuario);
            aFazer := 1;
        end
    else
        aFazer := strToInt (s) + 1;
    if aFazer < 1 then aFazer := 1;
    if aFazer > quantidadeLicoes then aFazer := quantidadeLicoes;
    result := aFazer;
end;

{-------------------------------------------------------------}
{       Lista das lições de um curso
{-------------------------------------------------------------}

procedure inicializaListaLicoes  (quantidadeLicoes: integer; nomeArqCurso: string; var aFazer: integer);
var
    i: integer;
    s: string;
begin
    aFazer := licaoAFazer (quantidadeLicoes, nomeArqCurso);
    folheiaCria (1, 4, 80, 17);
    for i :=  1 to aFazer do
        begin
            s := 'Lição ' + intToStr(i);
            s := copy (s + BRANCOS, 1, 15);
            folheiaAdicionaEspecial (s, false, 'Lição ' + intToStr(i));
        end;
end;

{-------------------------------------------------------------}

procedure listaLicoesCurso (divisorTempo: integer; nomeArqCurso: string);
var
    c, c2: char;
    podeFalar, concluiuLicao: boolean;
    nLicao, aFazer, quantidadeLicoes: integer;
    nomeCurso: string;

begin
    inicializaArqsSons; // Assumi padrão se o arquivo do curso não tiver especificado os sons.
    carregaArqsSons (nomeArqCurso);
    nomeCurso := sintAmbienteArq ('CURSO', 'NOMECURSO', '', nomeArqCurso);
    telaListaLicoes (nomeCurso);
    tocaEfeito (somIniCurso);

    quantidadeLicoes := strToInt(sintAmbienteArq ('CURSO', 'QUANTIDADELICOES', '', nomeArqCurso));
    aFazer := licaoAFazer (quantidadeLicoes, nomeArqCurso);
    if aFazer = 1 then
        begin
            writeln;
            falaApresentacaoOuInstrucao (true, 'CURSO', nomeArqCurso);
            falaApresentacaoOuInstrucao (false, 'CURSO', nomeArqCurso);
        end;
    limpaBufTec;

    mensagem ('DGTLICUR', -1); {'Lições do curso'}
    if not tocaEfeito (somNomeCurso) then
        sintetiza (nomeCurso);
    mensagem ('DGTUSESET', -1);        {'Use as setas para selecionar, depois tecle sua opção. F1 ajuda'}
    nLicao := aFazer;
    podeFalar := true;

    limpaBufTec;
    repeat
        telaListaLicoes (nomeCurso);
        limpaBufTec;
        inicializaListaLicoes (quantidadeLicoes, nomeArqCurso, aFazer);
        folheiaCorDoMeio (1, 60, CYAN);

        limpaBufTec;
        folheiaExecuta (nLicao, nLicao, c, c2, podeFalar);
        if nLicao < 1 then nLicao := 1;
        if nLicao > aFazer then nLicao := aFazer;
        sintPara;

        gotoxy (1, 19);
        if (c = #0) and (c2 = F9) then
            c := selSetasListaLicoes (nomeCurso, c2);

        if c = #0 then
            begin
                case c2 of
                    ESQ:    begin
                                mensagem ('DGTLICAO', -1); {'Lição'}
                                sintetiza (intToStr(nLicao));
                                if comEfeitos then sintclek;
                                falaApresentacaoOuInstrucao (true, 'LICAO' + intToStr(nLicao), nomeArqCurso);
                            end;

                    DIR:    falaApresentacaoOuInstrucao (false, 'LICAO' + intToStr(nLicao), nomeArqCurso);
                    F1:     ajudaListaLicoes (nomeCurso);
                    F4:     desligarFalarTecla;
                    F8:     falaHora;
                    CTLF8:  falaDia;
                    F12: begin {Não faz nada, continua folheando}
                            textBackGround (MAGENTA);
                            msgBaixo ('DGTSELESC');  {'Continue selecionando ou tecle ESC para sair'}
                            textBackGround (BLACK);
                            writeln;
                         end;
                end;
            end
        else
            begin
                c := upcase (c);
                case c of
                    'A': falaApresentacaoOuInstrucao (true, 'CURSO', nomeArqCurso);
                    'I': falaApresentacaoOuInstrucao (false, 'CURSO', nomeArqCurso);
                    'L': sintetiza (intToStr(quantidadeLicoes));
                    'U': sintetiza (nomeUsuario);
                    'N': sintetiza (nomeCurso);
                    'T': falaDivisorTempo (divisorTempo);
                    'E': falaExerLicao (nLicao, nomeArqCurso);
                    'Q': falaQualItemDoTotal  (nLicao, aFazer, false);

                    'D':   begin
                                folheiaDestroi;
                                mostraDadosLicao (nLicao, divisorTempo, nomeCurso, nomeArqCurso);
                                limpaBufTec;
                            end;

                    ENTER, CTLENTER: if not licaoValida (nLicao, nomeArqCurso) then
                            begin
                                msgBaixo ('DGTLIPRO'); {'Esta lição está com problema.'}
                                c := F12;
                                if comEfeitos then sintbip;
                            end
                        else
                            begin
                                folheiaDestroi;
                                tocaEfeito (somIniLicao);
                                concluiuLicao := praticarLicao (nLicao, quantidadeLicoes, divisorTempo, nomeCurso, nomeArqCurso, c = CTLENTER);
                                limpaBufTec;
                                tocaEfeito (somFimLicao);
                                nLicao := trataFimLicao (nLicao, quantidadeLicoes, concluiuLicao);
                                if nLicao > quantidadeLicoes then c := ESC;
                            end;

                    ESC: ;

                else
                    if c <> ESC then
                        msgBaixo ('DGTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}
                end;

                if not (upcase(c) in [ENTER, CTLENTER, ESC, 'Q', 'T', 'E', 'N', 'L', 'U']) then
                    msgBaixo ('DGTSELESC');  {'Continue selecionando ou tecle ESC  para sair'}
            end;

        if (upCase(c) in[ENTER, CTLENTER, 'Q', 'T', 'E', 'L', 'N', 'U', 'C']) or
            (c2 in [ESQ, DIR, F4, f8, CTLF8]) then
                podeFalar := false
        else
                podeFalar := true;

        if not (upcase (c) in ['D', ENTER, CTLENTER]) then
                folheiaDestroi;

    until c = #$1b;

    tocaEfeito (somFimCurso);
    msgBaixo('DGTVOLICU'); {'Voltando a lista de cursos ...'}
end;

{-------------------------------------------------------------}

begin
end.
