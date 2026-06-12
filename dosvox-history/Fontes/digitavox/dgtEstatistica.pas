{-------------------------------------------------------------}
{
{       Digitavox - Tratamento das estatísticas da lição
{
{       Autor: Neno Henrique da Cunha Albernaz
{              neno@intervox.nce.ufrj.br
{       Em 05 de Outubro de 2019
{
{-------------------------------------------------------------}

unit dgtEstatistica;

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
    dgtUtil,
    dgtVars,
    dgtRelat,
    dgtAjuda;

procedure inicializaListaLetrasErrou;
procedure addListaLetrasErrou (c: char);
procedure finalizaListaLetrasErrou;
procedure mostraEstatisticasLicao (nLicao, nLetrasacertou, nLetrasErrou, nPalavrasAcertou, nPalavrasErrou, percentualAcerto, percentualPalavrasCorretas: integer;
                                   tempoTotalLicao, tempoPraticaLicao: longint; totalLetrasLicao, totalPalavrasLicao: integer; nomeCurso, concluiu: string);
procedure gravaEstatisticasLicao (nLicao, nLetrasacertou, nLetrasErrou, nPalavrasAcertou, nPalavrasErrou, percentualAcerto, percentualPalavrasCorretas: integer;
                                  tempoTotalLicao, tempoPraticaLicao: longint; divisorTempo, repeticoesExer, totalLetrasLicao, totalPalavrasLicao: integer;
                                  chegouNoFim, concluiu,nomeArqUsuario, nomeArqCurso: string);
procedure listaEstatisticasCurso (nomeArqUsuario, nomeArqCurso: string);
function geraRelatorioCurso (nomeArqUsuario, nomeArqCurso: string): boolean;

implementation

var
    listaEst, listaLetrasErrou: TStringList;

{-------------------------------------------------------------}
{       Inicia a variável listaLetrasErrou
{-------------------------------------------------------------}

procedure inicializaListaLetrasErrou;
begin
    listaLetrasErrou := TStringList.create;
end;

{-------------------------------------------------------------}
{       Adiciona um item na TStringList listaLetrasErrou
{-------------------------------------------------------------}

procedure addListaLetrasErrou (c: char);
var
    i, k: integer;
    s: string;
    adicionou: boolean;
begin
    adicionou := false;
    for i := 0 to (listaLetrasErrou.count - 1) do
        if (listaLetrasErrou[i] <> '') and (listaLetrasErrou[i][1] = c) then
        begin
            s := listaLetrasErrou[i];
            delete (s, 1, 2);
            k := strToInt (s) + 1;
            listaLetrasErrou[i] := c + '=' + intToStr(k);
            adicionou := true;
            break;
        end;

    if not adicionou  then
        listaLetrasErrou.add (c + '=1');
end;

{-------------------------------------------------------------}
{       Desaloca a variável listaLetrasErrou
{-------------------------------------------------------------}

procedure finalizaListaLetrasErrou;
begin
    listaLetrasErrou.free;
end;

{---------------------------------}
{       Mostra as estatísticas
{---------------------------------}

procedure mostraEstatisticasLicao (nLicao, nLetrasacertou, nLetrasErrou, nPalavrasAcertou, nPalavrasErrou, percentualAcerto, percentualPalavrasCorretas: integer;
                                   tempoTotalLicao, tempoPraticaLicao: longint; totalLetrasLicao, totalPalavrasLicao: integer; nomeCurso, concluiu: string);
var
    s, s2: string;
    linhas, i: integer;
begin
    if totalPalavrasLicao > 0 then
        linhas := 16
    else
        linhas := 11;
    linhas := linhas + listaLetrasErrou.count;

    limpaBufTec;
    clrscr;
    TextBackground(BLUE);
    sintWriteln ('Curso: ' + nomeCurso);
    mensagem ('DGTESTLI', 2); {'Leia as estatísticas da lição com as setas verticais, tecle ESC para sair'}
    TextBackground(BLACK);
    if comEfeitos then sintclek;

    popupMenuCria (wherex, wherey, 79-wherex, linhas, BLACK);

    s := 'Lição: ' + intToStr(nLicao);
    popupMenuAdiciona ('', s);
    s := 'Concluída: ' + concluiu;
    popupMenuAdiciona ('', s);
    s := 'Percentual de acertos: ' + intToStr(percentualAcerto) + ' %';
    popupMenuAdiciona ('', s);

    if tempoPraticaLicao > 0 then
        s := 'Letras por minuto: ' + intToStr((nLetrasAcertou * 6000) div tempoPraticaLicao)
    else
        s := 'Letras por minuto: 0';
    popupMenuAdiciona ('', s);

    if totalPalavrasLicao > 0 then
        begin
            if tempoPraticaLicao > 0 then
                s := 'Palavras por minuto: ' + intToStr((nPalavrasAcertou * 6000) div tempoPraticaLicao)
            else
                s := 'Palavras por minuto: 0';
            popupMenuAdiciona ('', s);
        end;

    s:= 'Tempo para terminar a lição: ' + formataTempo (tempoTotalLicao);
    popupMenuAdiciona ('', s);
    s := 'Tempo de digitação: ' + formataTempo (tempoPraticaLicao);
    popupMenuAdiciona ('', s);

    if tempoTotalLicao > 0 then
        i := (tempoPraticaLicao * 100) div tempoTotalLicao
    else
        i := 0;
    if i > 100 then s := '100'
    else s := intToStr(i);
    s:= 'Percentual de tempo gasto: ' + s + ' %';
    popupMenuAdiciona ('', s);

    s := 'Total de caracteres na lição: ' + intToStr(totalLetrasLicao);
    popupMenuAdiciona ('', s);
    s := 'Total de caracteres digitados: ' + intToStr(nLetrasAcertou + nLetrasErrou);
    popupMenuAdiciona ('', s);
    s := 'Total de caracteres digitados corretos: ' + intToStr(nLetrasAcertou);
    popupMenuAdiciona ('', s);
//    s := 'Total de caracteres digitados errados: ' + intToStr(nLetrasErrou);
//    popupMenuAdiciona ('', s);

    if totalPalavrasLicao > 0 then
        begin
            s := 'Total de palavras na lição: ' + intToStr(totalPalavrasLicao);
            popupMenuAdiciona ('', s);
            s := 'Total de palavras digitadas: ' + intToStr(nPalavrasAcertou + nPalavrasErrou);
            popupMenuAdiciona ('', s);
            s := 'Total de palavras digitadas corretas: ' + intToStr(nPalavrasAcertou);
            popupMenuAdiciona ('', s);
//            s := 'Total de palavras digitadas erradas: ' + intToStr(nPalavrasErrou);
//            popupMenuAdiciona ('', s);
            s := 'Percentual de palavras corretas: ' + intToStr(percentualPalavrasCorretas) + ' %';
            popupMenuAdiciona ('', s);
        end;

    for i := 0 to (listaLetrasErrou.count -1) do
        begin
            s := listaLetrasErrou[i];
            s2 := copy (s, 1, 1);
            if s2 = ' ' then s2 := 'Barra de espaço';
            s := 'Erros em ' + s2 + ': ' + copy (s, 3, length(s));
            popupMenuAdiciona ('', s);
        end;

    popupMenuSeleciona;
end;

{-------------------------------------------------------------}
{       Grava o resultado da prática
{-------------------------------------------------------------}

procedure gravaEstatisticasLicao (nLicao, nLetrasacertou, nLetrasErrou, nPalavrasAcertou, nPalavrasErrou, percentualAcerto, percentualPalavrasCorretas: integer;
                                  tempoTotalLicao, tempoPraticaLicao: longint; divisorTempo, repeticoesExer, totalLetrasLicao, totalPalavrasLicao: integer;
                                  chegouNoFim, concluiu,nomeArqUsuario, nomeArqCurso: string);
var
    licao, nArqCurso, s: string;
    i: integer;
begin
    licao:= 'LICAO' + intToStr(nLicao) + '-' + diaMesAno(false) + '--' + horaMinutoSegundo + '_';
    nArqCurso := retiraNomeDir (nomeArqCurso);

    sintGravaAmbienteArq (nArqCurso, licao + 'CHEGOUNOFIM', chegouNoFim, nomeArqUsuario);
    sintGravaAmbienteArq (nArqCurso, licao + 'CONCLUIU', concluiu, nomeArqUsuario);
    sintGravaAmbienteArq (nArqCurso, licao + 'PERCENTUALACERTO', intToStr(PERCENTUALACERTO), nomeArqUsuario);
    sintGravaAmbienteArq (nArqCurso, licao + 'TOTALLETRASLICAO',intToStr(totalLetrasLicao), nomeArqUsuario);
    sintGravaAmbienteArq (nArqCurso, licao + 'NLETRASACERTOU', intToStr(nLetrasacertou), nomeArqUsuario);
    sintGravaAmbienteArq (nArqCurso, licao + 'NLETRASERROU', intToStr(nLetrasErrou), nomeArqUsuario);
    sintGravaAmbienteArq (nArqCurso, licao + 'PERCENTUALPALAVRASCORRETAS', intToStr(percentualPalavrasCorretas), nomeArqUsuario);
    sintGravaAmbienteArq (nArqCurso, licao + 'TOTALPALAVRASLICAO', intToStr(totalPalavrasLicao), nomeArqUsuario);
    sintGravaAmbienteArq (nArqCurso, licao + 'NPALAVRASACERTOU', intToStr(nPalavrasAcertou), nomeArqUsuario);
    sintGravaAmbienteArq (nArqCurso, licao + 'NPALAVRASERROU', intToStr(nPalavrasErrou), nomeArqUsuario);
    sintGravaAmbienteArq (nArqCurso, licao + 'DIVISORTEMPO', intToStr(divisorTempo), nomeArqUsuario);
    sintGravaAmbienteArq (nArqCurso, licao + 'REPETICOESEXER', intToStr(repeticoesExer), nomeArqUsuario);
    sintGravaAmbienteArq (nArqCurso, licao + 'TEMPOTOTALLICAO', intToStr(tempoTotalLicao), nomeArqUsuario);
    sintGravaAmbienteArq (nArqCurso, licao + 'TEMPOPRATICALICAO', intToStr(tempoPraticaLicao), nomeArqUsuario);

    for i := 0 to (listaLetrasErrou.count - 1) do
        begin
            s := copy(listaLetrasErrou[i], 1, 1);
            if s = ' ' then s := 'ESP'; //Barra de espaço
            sintGravaAmbienteArq (nArqCurso, licao + 'ERROSEM_' + s, copy(listaLetrasErrou[i], 3, length(listaLetrasErrou[i])), nomeArqUsuario);
        end;
end;

{-------------------------------------------------------------}
{       Carrega as linhas da seção nomeArqCurso do arquivo nomeArqUsuario em uma TStringList, se tem estatísticas retorna true
{-------------------------------------------------------------}

function carregaLinhasEstatisticas (nomeArqCurso, nomeArqUsuario: string): boolean;
var
    i, k: integer;
begin
    listaEst := TStringList.create;
    try
        listaEst.loadFromFile (nomeArqUsuario);
    except
        msgBaixo ('DGTERRUSU'); {'Erro ao carregar o arquivo do usuário'}
        result := false;
        exit;
    end;

//  Deixa na TStringList somente as linhas da seção do curso.
    i := 0;
    while (i < (listaEst.count -1)) and (listaEst[i] <> ('[' + nomeArqCurso + ']')) do inc (i);
    for k := i downto 0 do listaEst.Delete(k);
    i := 1;
    while (i < (listaEst.count -1)) and ((listaEst[i] + 'S')[1] <> '[') do inc (i);
    if i < (listaEst.count - 1) then
        for k := (listaEst.count - 1) downto i do listaEst.Delete(k);

//  Limpa as linhas deixando somente as das estatísticas das lições, as chaves.
    for i := (listaEst.count - 1) downto 0 do
        if (trim(listaEst[i]) <> '') and (pos('=', listaEst[i]) <> 0) and (copy(listaEst[i], 1, 5) = 'LICAO')then
            listaEst[i] := copy(listaEst[i], 1, (pos('=', listaEst[i]) -1))
        else
            listaEst.Delete (i);

    if listaEst.count > 5 then result := true
    else result := false;
end;

{-------------------------------------------------------------}
{       A partir da lição e data hora, recupera os itens da estatísticas e mostra
{-------------------------------------------------------------}

procedure estatisticasLicao (item, nomeArqUsuario, nomeArqCurso: string; gravarRelatorio: boolean);
var
    nLicao, nLetrasacertou, nLetrasErrou, nPalavrasAcertou, nPalavrasErrou, percentualAcerto, percentualPalavrasCorretas: integer;
    tempoTotalLicao, tempoPraticaLicao: longint;
    divisorTempo, repeticoesExer, totalLetrasLicao, totalPalavrasLicao: integer;
    nArqCurso, nomeCurso, data, hora, s, s2, concluiu: string;
    i: integer;
begin
    data := copy (item,(pos('-', item) + 1), ((pos('--', item) - 1) - (pos('-', item))));
    hora := copy (item, (pos('--', item) + 2), length(item));
    s := item;
    delete (s, 1, 5);
    delete (s, pos('-', s), length(s));
    nLicao := strToInt (s);
    nArqCurso := retiraNomeDir (nomeArqCurso);
    nomeCurso :=  sintAmbienteArq ('CURSO', 'NOMECURSO', '', nomeArqCurso);
    item := item + '_';

//    chegouNoFim := sintAmbienteArq (nArqCurso, item + 'CHEGOUNOFIM', '', nomeArqUsuario);
    concluiu := sintAmbienteArq (nArqCurso, item + 'CONCLUIU', '', nomeArqUsuario);
    s := sintAmbienteArq (nArqCurso, item + 'PERCENTUALACERTO', '', nomeArqUsuario);
    if s = '' then s := '0';
    PERCENTUALACERTO := strToInt(s);
    s := sintAmbienteArq (nArqCurso, item + 'TOTALLETRASLICAO','', nomeArqUsuario);
    if s = '' then s := '0';
    totalLetrasLicao := strToInt (s);
    s:= sintAmbienteArq (nArqCurso, item + 'NLETRASACERTOU', '', nomeArqUsuario);
    if s = '' then s := '0';
    nLetrasacertou := strToInt (s);
    s := sintAmbienteArq (nArqCurso, item + 'NLETRASERROU', '', nomeArqUsuario);
    if s = '' then s := '0';
    nLetrasErrou :=  strToInt (s);
    s := sintAmbienteArq (nArqCurso, item + 'PERCENTUALPALAVRASCORRETAS', '', nomeArqUsuario);
    if s = '' then s := '0';
    percentualPalavrasCorretas := strToInt (s);
    s := sintAmbienteArq (nArqCurso, item + 'TOTALPALAVRASLICAO', '', nomeArqUsuario);
    if s = '' then s := '0';
    totalPalavrasLicao :=  strToInt (s);
    s := sintAmbienteArq (nArqCurso, item + 'NPALAVRASACERTOU', '', nomeArqUsuario);
    if s = '' then s := '0';
    nPalavrasAcertou :=  strToInt (s);
    s := sintAmbienteArq (nArqCurso, item + 'NPALAVRASERROU', '', nomeArqUsuario);
    if s = '' then s := '0';
    nPalavrasErrou :=  strToInt (s);
    s := sintAmbienteArq (nArqCurso, item + 'DIVISORTEMPO', '', nomeArqUsuario);
    if s = '' then s := '1';
    divisorTempo :=  strToInt (s);
    s := sintAmbienteArq (nArqCurso, item + 'REPETICOESEXER', '', nomeArqUsuario);
    if s = '' then s := '1';
    repeticoesExer :=  strToInt (s);
    s := sintAmbienteArq (nArqCurso, item + 'TEMPOTOTALLICAO', '', nomeArqUsuario);
    if s = '' then s := '0';
    tempoTotalLicao :=  strToInt (s);
    s := sintAmbienteArq (nArqCurso, item + 'TEMPOPRATICALICAO', '', nomeArqUsuario);
    if s = '' then s := '0';
    tempoPraticaLicao :=  strToInt (s);

    inicializaListaLetrasErrou;
    item := item + 'ERROSEM_';
    for i := 0 to (listaEst.count - 1) do
        if copy (listaEst[i], 1, length(item)) = item then
            begin
                s := listaEst[i];
                s2 := sintAmbienteArq (nArqCurso, s, '', nomeArqUsuario);
                delete(s, 1, length(item));
                if copy(s, 1, 3) = 'ESP' then s := ' ';
                listaLetrasErrou.add (s + '=' + s2);
            end;

    if gravarRelatorio then
        gravarEstatisticaNoArq (nLicao, nLetrasacertou, nLetrasErrou, nPalavrasAcertou, nPalavrasErrou, percentualAcerto, percentualPalavrasCorretas,
                        tempoTotalLicao, tempoPraticaLicao, divisorTempo, repeticoesExer, totalLetrasLicao, totalPalavrasLicao,
                        nomeCurso, nomeArqUsuario, nomeArqCurso, concluiu, data, hora, listaLetrasErrou)
    else
        mostraEstatisticasLicao (nLicao, nLetrasacertou, nLetrasErrou, nPalavrasAcertou, nPalavrasErrou, percentualAcerto, percentualPalavrasCorretas,
                                 tempoTotalLicao, tempoPraticaLicao, totalLetrasLicao, totalPalavrasLicao, nomeCurso, concluiu);

    finalizaListaLetrasErrou;
end;

{-------------------------------------------------------------}
{       Fala se concluiu a lição, se atingiu o percentual de acerto configurado na lição do curso
{-------------------------------------------------------------}

procedure falaSeConcluiu (chave, nomeArqCurso, nomeArqUsuario: string);
var s: string;
begin
    s := sintAmbienteArq (retiraNomeDir(nomeArqCurso),  chave, '', nomeArqUsuario);
    if upcase((s + 'N')[1]) = 'S' then
        mensagem ('DGTPARABE', -1) {'Parabéns! Lição concluida.'}
    else
        mensagem('DGTNAOCON', -1); {'Não concluida'}
end;

{-------------------------------------------------------------}
{       Fala se chegou no fim da lição
{-------------------------------------------------------------}

procedure falaSeChegouNoFim (chave, nomeArqCurso, nomeArqUsuario: string);
var s: string;
begin
    s := sintAmbienteArq (retiraNomeDir(nomeArqCurso),  chave, '', nomeArqUsuario);
    if upcase((s + 'N')[1]) = 'S' then
        mensagem ('DGTCHEFIM', -1) {'Chegou no fim'}
    else
        mensagem ('DGTNCHFIM', -1); {'Não chegou no fim'}
end;

{-------------------------------------------------------------}
{       Retorna o item do folheamento no formato do prefixo da chave pronto para ser completado
{-------------------------------------------------------------}

function prefixoChave (i: integer): string;
var
    k: integer;
    selecionado: boolean;
    item: string;
begin
    folheiaObtemItem (i, item, selecionado);
    item := 'LICAO' + copy(item, 7, length(item) - 6);
    for k := 1 to length(item) do if item[k] = ' ' then item[k] := '-';
    result := item;
end;

{-------------------------------------------------------------}
{       Deixa no folheamento somente as concluidas ou não concluidas
{-------------------------------------------------------------}

procedure deletaFolheamentoConcluidas (numItens: integer; nArqCurso, nomeArqUsuario: string; concluida: boolean);
var
    i: integer;
    s: string;
begin
    for i := numItens  downto 1 do
        begin
            s := prefixoChave (i);
            s := sintAmbienteArq (nArqCurso,  s + '_CONCLUIU', '', nomeArqUsuario);
            if (not concluida) and (( s + 'N')[1] = 'N') then folheiaRemoveItem (i)
            else if (concluida) and ((s + 'S')[1] = 'S') then folheiaRemoveItem (i);
        end;
end;

{-------------------------------------------------------------}
{       Deixa no folheamento somente as que chegou no fim ou as que não chegou no fim
{-------------------------------------------------------------}

procedure deletaFolheamentoChegouNoFim (numItens: integer;  nArqCurso, nomeArqUsuario: string; chegouNoFim: boolean);
var
    i: integer;
    s: string;
begin
    for i := numItens  downto 1 do
        begin
            s := prefixoChave (i);
            s := sintAmbienteArq (nArqCurso,  s + '_CHEGOUNOFIM', '', nomeArqUsuario);
            if (not chegouNoFim) and ((s + 'N')[1] = 'N') then folheiaRemoveItem (i)
            else if (chegouNoFim) and ((s + 'S')[1] = 'S') then folheiaRemoveItem (i);
        end;
end;

{-------------------------------------------------------------}
{       Deixa no folheamento somente as com tempo esgotado ou não
{-------------------------------------------------------------}

procedure deletaFolheamentoTempoEsgotado (numItens: integer; nArqCurso, nomeArqUsuario: string; tempoEsgotado: boolean);
var
    i: integer;
    tempoTotalLicao, tempoPraticaLicao: longint;
    s, item: string;
begin
    for i := numItens  downto 1 do
        begin
            item := prefixoChave (i);
            s := sintAmbienteArq (nArqCurso,  item + '_TEMPOTOTALLICAO', '', nomeArqUsuario);
            if s <> '' then tempoTotalLicao := strToInt(s)
            else tempoTotalLicao := 2;
            s := sintAmbienteArq (nArqCurso,  item + '_TEMPOPRATICALICAO', '', nomeArqUsuario);
            if s <> '' then tempoPraticaLicao := strToInt(s)
            else tempoPraticaLicao := 1;

            if (not tempoEsgotado) and (tempoTotalLicao > tempoPraticaLicao) then folheiaRemoveItem (i)
            else if (tempoEsgotado) and (tempoTotalLicao <= tempoPraticaLicao) then folheiaRemoveItem (i);
        end;
end;

{-------------------------------------------------------------}
{       Possibilita escolher com as setas os divisores de tempo já praticados no curso
{-------------------------------------------------------------}

function selecDivisorTempoFolheamento (numItens: integer; nArqCurso, nomeArqUsuario: string): string;
var
    i: integer;
    s: string;
    listaDivTempo: TStringList;
begin
    listaDivTempo := TStringList.create;
    for i := 1 to numItens do
        begin
            s := prefixoChave (i);
            s := sintAmbienteArq (nArqCurso,  s + '_DIVISORTEMPO', '', nomeArqUsuario);
            if not  estaNaLista (s,  listaDivTempo) then
                listaDivTempo.add (s);
        end;

    mensagem ('DGTESSEDT', 1); {'Escolha com as setas o divisor do tempo desejado e tecle Enter'}
    if comEfeitos then sintclek;
    popupMenuCria (wherex, wherey, 79-wherex, listaDivTempo.count, MAGENTA);
    for i := 0 to (listaDivTempo.count - 1) do
        popupMenuAdiciona ('', listaDivTempo[i]);

    i := popupMenuSeleciona;

    if i = 0 then result := ''
    else result := listaDivTempo[i - 1];

    listaDivTempo.free;
end;

{-------------------------------------------------------------}
{       Deixa no folheamento somente as que tem o mesmo divisorTempo
{-------------------------------------------------------------}

function deletaFolheamentoDivisorTempo (itemAtual, numItens: integer; nArqCurso, nomeArqUsuario: string; selecionaDivTempo: boolean): boolean;
var
    i: integer;
    s, divisorTempo: string;
begin
    if selecionaDivTempo then
        divisorTempo := selecDivisorTempoFolheamento (numItens, nArqCurso, nomeArqUsuario)
    else
        begin
            s := prefixoChave (itemAtual);
            divisorTempo := sintAmbienteArq (nArqCurso,  s + '_DIVISORTEMPO', '', nomeArqUsuario);
        end;

    if divisorTempo = '' then
        begin
            msgBaixo ('DGTDESIST'); {'Desistiu ...'}
            result := false;
            exit;
        end;
    mensagem ('DGTDIVTEM', 0);      {'Divisor do tempo '}
    sintWrite (divisorTempo);

    for i := numItens  downto 1 do
        begin
            s := prefixoChave (i);
            s := sintAmbienteArq (nArqCurso,  s + '_DIVISORTEMPO', '', nomeArqUsuario);
            if s <> divisorTempo then folheiaRemoveItem (i);
        end;

    result := true;
end;

{-------------------------------------------------------------}
{       Deixa no folheamento somente as com a mesma data
{-------------------------------------------------------------}

procedure deletaFolheamentoOutrasDatas (nItem, numItens: integer; nArqCurso, nomeArqUsuario: string);
var
    i: integer;
    data: string;
begin
    data := prefixoChave (nItem);
    data := copy (data,(pos('-', data) + 1), ((pos('--', data) - 1) - (pos('-', data))));
    for i := numItens  downto 1 do
        if pos(data, prefixoChave (i)) <= 0 then
            folheiaRemoveItem (i);
end;

{-------------------------------------------------------------}
{       Deixa no folheamento somente as com a mesma lição
{-------------------------------------------------------------}

procedure deletaFolheamentoOutrasLicoes (nItem, numItens: integer; nArqCurso, nomeArqUsuario: string);
var
    i: integer;
    licao: string;
begin
    licao := prefixoChave (nitem);
    licao := copy (licao, 1, pos('-', licao));
    for i := numItens  downto 1 do
        if pos(licao, prefixoChave (i)) <= 0 then
            folheiaRemoveItem (i);
end;

{-------------------------------------------------------------}
{       Retorna o maior item da estatística das práticas
{-------------------------------------------------------------}

function maiorPercentualAcerto (nLicao, numItens: integer;  nArqCurso, nomeArqUsuario: string; maior: boolean): integer;
var
    i, perLetra, perPalavra, media: integer;
    s, licao: string;
begin
    licao := 'LICAO' + intToStr(nLicao) + '-';
    if maior then media := 0
    else media := 200;

    for i := numItens  downto 1 do
        begin
            s := prefixoChave (i);
            if copy(s, 1, length(licao)) <> licao then continue;
            s := sintAmbienteArq (nArqCurso,  s + '_PERCENTUALACERTO', '', nomeArqUsuario);
            if s = '' then s := '0';
            perLetra := strToInt(s);
            s := sintAmbienteArq (nArqCurso,  s + '_PERCENTUALPALAVRASCORRETAS', '', nomeArqUsuario);
            if s = '' then s := '0';
            perPalavra := strToInt(s);

            if (maior) and ((perLetra + perPalavra) > media) then media := perLetra + perpalavra
            else if (not maior) and ((perLetra + perPalavra) < media) then media := perLetra + perpalavra;
        end;
    result := media;
end;

{-------------------------------------------------------------}
{       Retorna o menor tempo da prática
{-------------------------------------------------------------}

function menorTempoPratica (nLicao, numItens: integer;  nArqCurso, nomeArqUsuario: string; menor: boolean): integer;
var
    i: integer;
    t, tempo: longInt;
    s, licao: string;
begin
    licao := 'LICAO' + intToStr(nLicao) + '-';

    if menor then tempo := 9999999
    else tempo := 0;
    for i := numItens  downto 1 do
        begin
            s := prefixoChave (i);
            if copy(s, 1, length(licao)) <> licao then continue;
            s := sintAmbienteArq (nArqCurso,  s + '_TEMPOPRATICALICAO', '', nomeArqUsuario);
            if s = '' then s := '0';
            t := strToInt(s);

            if (menor) and (t < tempo) then tempo := t
            else if (not menor) and (t > tempo ) then tempo := t;
        end;
    result := tempo;
end;

{-------------------------------------------------------------}
{       Deixa no folheamento as lições concluídas com maiores notas
{-------------------------------------------------------------}

procedure  concluidasMaioresPerformance  (numItens: integer; nArqCurso, nomeArqUsuario: string; maior: boolean);
var
    i , j, ultimaConcluida, perLetra, perPalavra, media: integer;
    tp, mtp: longInt;
    licao, s: string;
begin
    s := sintAmbienteArq (nArqCurso, 'ULTIMACONCLUIDA', '', nomeArqUsuario);
    if trim(s) = '' then
        begin
            msgBaixo ('DGTNELICU'); {'Nenhuma lição deste curso foi concluida'}
            exit;
        end;
    ultimaConcluida := strToInt (s);

    deletaFolheamentoConcluidas (numItens, nArqCurso, nomeArqUsuario, false);

    for i := 1 to ultimaConcluida do
        begin
            media := maiorPercentualAcerto (i, numItens,  nArqCurso, nomeArqUsuario, maior);
            licao := 'LICAO' + intToStr(i) + '-';
            for j := numItens downto 1 do
                    begin
                        s := prefixoChave (j);
                        if copy(s, 1, length(licao)) <> licao then continue;

                        s := sintAmbienteArq (nArqCurso,  s + '_PERCENTUALACERTO', '', nomeArqUsuario);
                        if s = '' then s := '0';
                        perLetra := strToInt(s);
                        s := sintAmbienteArq (nArqCurso,  s + '_PERCENTUALPALAVRASCORRETAS', '', nomeArqUsuario);
                        if s = '' then s := '0';
                        perPalavra := strToInt(s);

            if (maior) and ((perLetra + perPalavra) < media) then folheiaRemoveItem (j)
            else if (not maior) and ((perLetra + perPalavra) > media) then folheiaRemoveItem (j);
                    end;
            numItens := folheiaNumItens;
        end;

    for i := 1 to ultimaConcluida do
        begin
            mtp := menorTempoPratica (i, numItens,  nArqCurso, nomeArqUsuario, maior);
            licao := 'LICAO' + intToStr(i) + '-';
            for j := numItens downto 1 do
                    begin
                        s := prefixoChave (j);
                        if copy(s, 1, length(licao)) <> licao then continue;
                        s := sintAmbienteArq (nArqCurso,  s + '_TEMPOPRATICALICAO', '', nomeArqUsuario);
                        if s = '' then s := '0';
                        tp := strToInt(s);

            if (maior) and (tp > mtp) then folheiaRemoveItem (j)
            else if (not maior) and (tp <  mtp) then folheiaRemoveItem (j);
                    end;
            numItens := folheiaNumItens;
        end;

end;

{-------------------------------------------------------------}
{       Filtra as estatísticas deixando somente a opção escolhida
{-------------------------------------------------------------}

function filtraEstatisticas (itemAtual, numItens: integer; nomeArqUsuario, nomeArqCurso: string): integer;
var
    n: integer;
    s, nArqCurso: string;
label desistiu;
begin
    s := sintAmbienteArq ('CURSO', 'NOMECURSO', '', nomeArqCurso);
    n := selSetasFiltroEstatisticas (s);
    nArqCurso := retiraNomeDir(nomeArqCurso);

    if n = 1 then
        deletaFolheamentoOutrasLicoes (itemAtual, numItens, nArqCurso, nomeArqUsuario)
    else
    if (n = 2) or (n = 3) then
        deletaFolheamentoConcluidas (numItens, nArqCurso, nomeArqUsuario, (n = 3))
    else
    if (n = 4) or (n = 5) then
        concluidasMaioresPerformance (numItens, nArqCurso, nomeArqUsuario, n = 4)
    else
    if (n = 6) or (n = 7) then
        deletaFolheamentoChegouNoFim (numItens, nArqCurso, nomeArqUsuario, (n = 7))
    else
    if (n = 8) or (n = 9) then
        deletaFolheamentoTempoEsgotado (numItens, nArqCurso, nomeArqUsuario, (n = 9))
    else
    if (n = 10) or (n = 11) then
        begin
            if not deletaFolheamentoDivisorTempo (itemAtual, numItens, nArqCurso, nomeArqUsuario, n = 11) then
                goto desistiu;
        end
    else
    if n = 12 then
        deletaFolheamentoOutrasDatas (itemAtual, numItens, nArqCurso, nomeArqUsuario)
    else
        begin
            msgBaixo ('DGTDESIST'); {'Desistiu ...'}
            goto desistiu;
        end;

    if comEfeitos then sintclek;
    if folheiaNumItens <= 0 then
        msgBaixo ('DGTLIVAZ') {'Listagem vazia'}
    else
    msgBaixo ('DGTFILAPL'); {'Filtro aplicado'}

desistiu:
    result := folheiaNumItens;
end;

{-------------------------------------------------------------}
{       Gera o relatório das estatísticas de um curso a partir da listagem das estatísticas
{-------------------------------------------------------------}

procedure geraRelatorioLicoes (item, nomeArqUsuario, nomeArqCurso: string);
var
    c: char;
    i, primeiroSelec: integer;
    selecionado: boolean;
begin
    if folheiaNumSelec (primeiroSelec) > 0 then
        repeat
            msgBaixo ('DGTGERESE'); {'Gera relatório dos selecionados?'}
            c := upcase(popupMenuPorLetra ('SN'));
            if c = ESC then
                begin
                    msgBaixo ('DGTDESIST'); {'Desistiu ...'}
                    exit;
                end;
            selecionado := c = 'S';
    until c in ['S', 'N', ESC]
    else
        selecionado := false;

    if not selecionado then
        estatisticasLicao (item, nomeArqUsuario, nomeArqCurso, true)
    else
    for i := 1 to folheiaNumItens do
        begin
            folheiaObtemItem (i, item, selecionado);
            if not selecionado then continue;
            item := prefixoChave (i);
            estatisticasLicao (item, nomeArqUsuario, nomeArqCurso, true)
        end;

    msgBaixo ('DGTOK'); {'Ok'}
    msgBaixo ('DGTRELGER'); {'Relatório gerado'}
end;

{-------------------------------------------------------------}
{       Lista as lições do curso com as datas que foram realizadas
{-------------------------------------------------------------}

procedure listaEstatisticasCurso (nomeArqUsuario, nomeArqCurso: string);
var
    i, k, nItem , numItens, nLicao: integer;
    c, c2: char;
    s, item, nomeCurso: string;
    podeFalar: boolean;
begin
    nomeCurso := sintAmbienteArq ('CURSO', 'NOMECURSO', '', nomeArqCurso);
    telaListaLicoesEstatisticas (nomeCurso);
    if not carregaLinhasEstatisticas (retiraNomeDir(nomeArqCurso), nomeArqUsuario) then
        begin
            listaEst.free;
            mensagem ('DGTNAOEST', 1); {'Não existe estatísticas para este curso.'}
            exit
        end;

    mensagem ('DGTLCEST', -1); {'Estatísticas do curso'}
    mensagem ('DGTSTENES', -1); {'selecione com as setas verticais, tecle Enter para ver as estatísticas. F1 ajuda.'}

    folheiaCria (wherex, wherey, 79, 23);
    for i := 1 to (listaEst.count - 1) do
        if (copy (listaEst[i], 1, 5) = 'LICAO') and (pos ('_CONCLUIU' , listaEst[i]) <> 0) then
            begin
                s := copy (listaEst[i], 1, pos('_', listaEst[i]) -1);
                s := 'Lição ' + copy(s, 6, (length(s) - 5));
                for k := 1 to length(s) do if s[k] = '-' then s[k] := ' ';
                folheiaAdicionaEspecial (s, false, s);
            end;

    numItens := folheiaNumItens;
    podeFalar := true;
    repeat
        telaListaLicoesEstatisticas (nomeCurso);

        folheiaExecuta (nItem, nItem, c, c2, podeFalar);
        if nItem < 1 then nItem := 1;
        if nItem > numItens then nItem := numItens;
        sintPara;
        item := prefixoChave (nItem);
        s := item;
        delete (s, 1, 5);
        delete (s, pos('-', s), length(s));
        nLicao := strToInt(s);

        if c2 = F9 then
            c := selSetasListaEstatisticasCurso (nLicao, nomeCurso, c2);

        if c = #0 then
            begin
                case c2 of
                    ESQ  : falaSeConcluiu (item + '_CONCLUIU', nomeArqCurso, nomeArqUsuario);
                    DIR : falaSeChegouNoFim (item + '_CHEGOUNOFIM', nomeArqCurso, nomeArqUsuario);
                    F1   : ajudaListaEstatisticasCurso(nomeCurso);
                    F5: numItens := filtraEstatisticas (nItem, numItens, nomeArqUsuario, nomeArqCurso);
                    F8   : falaHora;
                    CTLF8: falaDia;
                    F12: begin {Não faz nada, continua folheando}
                            textBackGround (MAGENTA);
                            msgBaixo ('DGTSELESC');  {'Continue selecionando ou tecle ESC para sair'}
                            textBackGround (BLACK);
                            writeln;
                         end;
                else
                    msgBaixo ('DGTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}
                end;
            end
        else
            begin
                case upcase(c) of
                    ENTER: estatisticasLicao (item, nomeArqUsuario, nomeArqCurso, false);
                    'G': geraRelatorioLicoes (item, nomeArqUsuario, nomeArqCurso);
                    'T': falaDivisorTempo (strToInt(sintAmbienteArq (retiraNomeDir(nomeArqCurso),  item + '_DIVISORTEMPO', '', nomeArqUsuario)));
                    'E': falaExerLicao (nLicao, nomeArqCurso);
                    'L': sintetiza (sintAmbienteArq ('CURSO', 'QUANTIDADELICOES', '', nomeArqCurso));
                    'C': falaUltimaConcluida (nomeArqCurso);
                    'U': sintetiza (nomeUsuario);
                    'Q', ^Q: falaQualItemDoTotal (nItem, numItens, c = ^Q);
                    'N': sintetiza (nomeCurso);
                else
                    if c <> ESC then msgBaixo ('DGTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}
                end;
            end;

        if numItens <= 0 then break;

        if (not(upcase(c) in ['Q', 'T', 'L', 'C', 'U', 'N', 'E', ESC])) and
           (not (c2 in [DIR, ESQ, F8, CTLF8, F12])) then
                msgBaixo ('DGTSELESC');  {'Continue selecionando ou tecle ESC  para sair'}

if c = ENTER then
        podeFalar := true
else
        podeFalar := false;

    until upcase(c) = ESC;

    if comEfeitos then sintclek;
    msgBaixo('DGTVOLICU'); {'Voltando a lista de cursos ...'}
    listaEst.free;
    folheiaDestroi;
end;

{-------------------------------------------------------------}
{       Gera o relatório com as estatísticas de todas as lições realizadas do curso
{-------------------------------------------------------------}

function geraRelatorioCurso (nomeArqUsuario, nomeArqCurso: string): boolean;
var
    i: integer;
    s: string;
begin
    if not carregaLinhasEstatisticas (retiraNomeDir(nomeArqCurso), nomeArqUsuario) then
        begin
            listaEst.free;
            if comEfeitos then sintclek;
            msgBaixo ('DGTNAOEST'); {'Não existe estatísticas para o curso.'}
            sintetiza (sintAmbienteArq ('CURSO', 'NOMECURSO', '', nomeArqCurso));
            result := false;
            exit
        end;

    for i := 1 to (listaEst.count - 1) do
        if (copy (listaEst[i], 1, 5) = 'LICAO') and (pos ('_CONCLUIU' , listaEst[i]) <> 0) then
            begin
                s := copy (listaEst[i], 1, pos('_', listaEst[i]) -1);
                estatisticasLicao (s, nomeArqUsuario, nomeArqCurso, true);
            end;
    listaEst.free;

    result := true;
end;

{-------------------------------------------------------------}

begin
end.
