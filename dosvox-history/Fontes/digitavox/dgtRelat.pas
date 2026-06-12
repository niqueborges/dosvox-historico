{-------------------------------------------------------------}
{
{       Digitavox - Gerador de relatório em arquivo csv
{
{       Autor: Neno Henrique da Cunha Albernaz
{              neno@intervox.nce.ufrj.br
{       Em 26 de Outubro de 2019
{
{-------------------------------------------------------------}

unit dgtRelat;

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
    dgtAjuda;

procedure gravarEstatisticaNoArq (nLicao, nLetrasacertou, nLetrasErrou, nPalavrasAcertou, nPalavrasErrou, percentualAcerto, percentualPalavrasCorretas: integer;
                        tempoTotalLicao, tempoPraticaLicao: longInt;  divisorTempo, repeticoesExer,totalLetrasLicao, totalPalavrasLicao: integer;
                        nomeCurso, nomeArqUsuario, nomeArqCurso, concluiu, data, hora: string; listaLetrasErrou: TStringList);

implementation

{-------------------------------------------------------------}
{       Abre o arquivo do relatório, se não existir cria
{-------------------------------------------------------------}

function abreArqRelatorio (nomeArqUsuario: string; var arq: text): boolean;
const
    COLUNAS: string = 'Aluno;Curso;Lição;Data;Hora;DivisorTempo;TempoTotal;TempoPratica;EfetividadeTempo%;' +
                      'NuLetNaSeq;NuLetDisNaSeq;NuLetCorr;NuRepSeq;NuLetLicao;NuLetDig;NuLetDigCorr;NuLetDigErro;' +
                      'NuPalLicao;NuPalDig;NuPalDigCorr;NuPalDigErro;LetPorMin;PalPorMin;' +
                      'EficiênciaLet%;EfetividadeLet%;EfetividadeLetGer%;EficiênciaPal%;EfetividadePalGer%'; //Média;DPadrão;ErroSP';
var
    s, s2: string;
begin
    if dirRelatorios[length(dirRelatorios)] = '\' then delete(dirRelatorios, length(dirRelatorios), 1);
    s := retiraNomeDir(nomeArqUsuario);
    delete (s, pos('.', s), length(s));
    s2 := diaMesAno (true) ;
    s := dirRelatorios + '\' + 'Relatorio_' + s + '_' + s2 + '.csv';
    assign (arq, s);
    {$I-} append (arq);  {$i+}
    if ioresult <> 0 then
        begin
            {$I-} rewrite (arq); {$I+}
            if ioresult <> 0 then
                begin
                    msgBaixo ('DGTERRREL'); {'Erro ao criar o arquivo do relatório.'}
                    result := false;
                end
            else
                begin
                    {$I-} writeln (arq, COLUNAS);  {$I+}
                    if ioresult <> 0 then
                        begin
                            msgBaixo ('DGTERESDI');  {'Erro de escrita no disco'}
                            result := false;
                        end
                    else
                        result := true;
                end;
        end
    else
        result := true;
end;

{-------------------------------------------------------------}
{       Grava o relatório das estatísticas no arquivo csv
{-------------------------------------------------------------}

procedure gravarEstatisticaNoArq (nLicao, nLetrasacertou, nLetrasErrou, nPalavrasAcertou, nPalavrasErrou, percentualAcerto, percentualPalavrasCorretas: integer;
                        tempoTotalLicao, tempoPraticaLicao: longInt;  divisorTempo, repeticoesExer,totalLetrasLicao, totalPalavrasLicao: integer;
                        nomeCurso, nomeArqUsuario, nomeArqCurso, concluiu, data, hora: string; listaLetrasErrou: TStringList);
var
    i, nuLetDisNaSeq: integer;
    s, s2: string;
    arq: text;

    function escreveNoArq (item: string; nlf: integer): boolean;
    var i: integer;
    begin
        {$I-} write (arq, item);  {$I+}
        if ioresult <> 0 then
            begin
                msgBaixo ('DGTERESDI');  {'Erro de escrita no disco'}
                result := false;
            end
        else
            result := true;
    
        if result and (nlf <= 0) then
            begin
                {$I-} write (arq, ';');  {$I+}
                if ioresult <> 0 then;
            end;

        for i := 1 to nlf do
            begin
                {$I-} writeln (arq, '');  {$I+}
                if ioresult <> 0 then;
            end;
    end;

label fim;
begin
    if not abreArqRelatorio (nomeArqUsuario, arq) then goto fim;

    if not escreveNoArq (nomeUsuario, 0) then goto fim; // Aluno
    if not escreveNoArq (nomeCurso, 0) then goto fim; // Curso
    if not escreveNoArq (intToStr(nLicao), 0) then goto fim; // Lição
    if not escreveNoArq (data, 0) then goto fim; // Data
    if not escreveNoArq (hora, 0) then goto fim; // Hora
    if not escreveNoArq (intToStr(divisorTempo), 0) then goto fim; // DivisorTempo
    if not escreveNoArq (formataTempo (tempoTotalLicao), 0) then goto fim; // TempoTotal
    if not escreveNoArq (formataTempo(tempoPraticaLicao), 0) then goto fim; // TempoPratica

    if tempoTotalLicao > 0 then i := (tempoPraticaLicao *100) div tempoTotalLicao
    else i := 0;
    if not escreveNoArq (intToStr(i), 0) then goto fim; // EfetividadeTempo%

    if repeticoesExer <= 0 then  repeticoesExer := 1;
    if not escreveNoArq (intToStr(totalLetrasLicao div repeticoesExer), 0) then goto fim; // NuLetNaSeq
    nuLetDisNaSeq := quantidadeLetrasDistintasLicao (nLicao, nomeArqCurso);
    if not escreveNoArq (intToStr(nuLetDisNaSeq), 0) then goto fim; // NuLetDisNaSeq
    if not escreveNoArq (intToStr(nuLetDisNaSeq - listaLetrasErrou.count), 0) then goto fim; //  NuLetCorr
    if not escreveNoArq (intToStr(repeticoesExer), 0) then goto fim; // NuRepSeq
    if not escreveNoArq (intToStr(totalLetrasLicao), 0) then goto fim; // NuLetLicao
    if not escreveNoArq (intToStr(nLetrasacertou + nLetrasErrou), 0) then goto fim; // NuLetDig
    if not escreveNoArq (intToStr(nLetrasacertou), 0) then goto fim; // NuLetDigCorr
    if not escreveNoArq (intToStr(nLetrasErrou), 0) then goto fim; // NuLetDigErro
    if not escreveNoArq (intToStr(totalPalavrasLicao), 0) then goto fim; // NuPalLicao
    if not escreveNoArq (intToStr(nPalavrasAcertou + nPalavrasErrou), 0) then goto fim; // NuPalDig
    if not escreveNoArq (intToStr(nPalavrasAcertou), 0) then goto fim; // NuPalDigCorr
    if not escreveNoArq (intToStr(nPalavrasErrou), 0) then goto fim; // NuPalDigErro

    if tempoPraticaLicao > 0 then
        begin
            s := intToStr((nLetrasAcertou * 6000) div tempoPraticaLicao);
            s2 := intToStr((nPalavrasAcertou * 6000) div tempoPraticaLicao);
        end
    else
        begin
            s := '0';
            s2 := '0';
        end;
    if not escreveNoArq (s, 0) then goto fim; // LetPorMin
    if not escreveNoArq (s2, 0) then goto fim; // PalPorMin
    if not escreveNoArq (intToStr(((nLetrasacertou + nLetrasErrou) * 100) div totalLetrasLicao), 0) then goto fim; // EficiênciaLet%
    if not escreveNoArq (intToStr(((nuLetDisNaSeq - listaLetrasErrou.count) * 100) div nuLetDisNaSeq), 0) then goto fim; // EfetividadeLet%
    if not escreveNoArq (intToStr(percentualAcerto), 0) then goto fim; // EfetividadeLetGer%

    if totalPalavrasLicao > 0 then s := intToStr(((nPalavrasAcertou + nPalavrasErrou) * 100) div totalPalavrasLicao)
    else s:= '0';
    if not escreveNoArq (s, 0) then goto fim; // EficiênciaPal%
    if not escreveNoArq (intToStr(percentualPalavrasCorretas), 1) then goto fim; // EfetividadePalGer%

// Média;DPadrão;ErroSP

fim:
    {$I-} close (arq); {$I+}
    if  ioresult <> 0 then;
end;

{-------------------------------------------------------------}

begin
end.
