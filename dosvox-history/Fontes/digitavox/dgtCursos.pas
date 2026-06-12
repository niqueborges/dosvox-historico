{-------------------------------------------------------------}
{
{       Digitavox - Tratamento dos cursos
{
{       Autor: Neno Henrique da Cunha Albernaz
{              neno@intervox.nce.ufrj.br
{       Em 05 de Outubro de 2019
{
{-------------------------------------------------------------}

unit dgtCursos;

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
    dgtLicoes,
    dgtUtil,
    dgtEstatistica,
    dgtAjuda;

function montarListaCursos: boolean;
procedure desmontarListaCursos;
procedure listarCursos;

implementation

{-------------------------------------------------------------}
{       Verifica se o arquivo de curso é válido.
{-------------------------------------------------------------}

function cursoValido (nomeArqCurso: string): boolean;
begin
    if  (sintAmbienteArq ('CURSO', 'NOMECURSO', '', nomeArqCurso) <> '') and
        (sintAmbienteArq ('CURSO', 'APT1', '', nomeArqCurso) <> '') and
        (sintAmbienteArq ('CURSO', 'IST1', '', nomeArqCurso) <> '') and
        (sintAmbienteArq ('CURSO', 'QUANTIDADELICOES', '', nomeArqCurso) <> '') and
        (strToInt(sintAmbienteArq ('CURSO', 'QUANTIDADELICOES', '', nomeArqCurso))  > 0) then
            result := true
    else
            result := false;
end;

{-------------------------------------------------------------}
{       Busca os arquivos dos cursos na pasta de cursos
{-------------------------------------------------------------}

function montarListaCursos: boolean;
var
    DirInfo: TSearchRec;
    ext: array [0..10] of char;
    dosError: integer;
    nomeArq, dirAtual: string;

label proximoArq;

begin
    result := false;
    getDir (0, dirAtual);
{$I-}  chdir (dirCursos);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('DGTNPCUR', 1);  {'Erro: pasta de Cursos não encontrada.'}
            exit;
        end;

    listaArqCursos := TStringList.create;
    strPcopy (ext, '*.ini');
    dosError := FindFirst (ext, FaArchive, DirInfo);
    while DosError = 0 do
        begin
            nomeArq := dirCursos + '\' + trim(dirInfo.name);
            if cursoValido (nomeArq) then
                listaArqCursos.add (nomeArq);
            dosError := FindNext (DirInfo);
        end;

    {$I-}  chdir (dirAtual);  {$I+}
    if ioresult <> 0 then;
    if listaArqCursos.count > 0 then
        result := true
    else
        begin
            mensagem ('DGTNEARQ', 0); {'Erro: não existe arquivo de curso válido na pasta '}
            sintWriteln (dirCursos);
        end;
end;

{-------------------------------------------------------------}
{       Desmonta a lista de cursos.
{-------------------------------------------------------------}

procedure desmontarListaCursos;
begin
    listaArqCursos.free;
end;

{-------------------------------------------------------------}
{       Seleciona o divisor do tempo para desafio
{-------------------------------------------------------------}

function selecDivisorTempo (var divisorTempo: integer; var c2: char): char;
begin
    telaListaCursos (listaArqCursos.count);
    mensagem ('DGTDESAF', 1); {'Desafio'}
    mensagem ('DGTNUMDE', 0); {'Digite um número maior que 1 para dividir o tempo: '}
    sintReadInt (divisorTempo);
    writeln;
    if divisorTempo < 2 then
        begin
            mensagem ('DGTDESIST', 1); {'Desistiu ...'}
            divisorTempo := 1;
            c2 := F12;
            result := #0;
            exit;
        end;

    mensagem ('DGTDIVTEM', 0); {'Divisor do tempo '}
    sintWriteInt (divisorTempo);
    result := ENTER;
end;

{-------------------------------------------------------------}
{       Gera o relatório das estatísticas de todas as lições realizadas no curso, a partir da listagem dos cursos.
{-------------------------------------------------------------}

procedure geraRelatorioCursos (nomeArqUsuario, nomeArqCurso: string);
var
    c: char;
    i, primeiroSelec: integer;
    s: string;
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
    msgBaixo ('DGTRETOCU'); {'Gerando relatório ...'}

    if not selecionado then
        begin
            if not geraRelatorioCurso (nomeArqUsuario, nomeArqCurso) then
                exit;
        end
    else
    for i := primeiroSelec to folheiaNumItens do
        begin
            folheiaObtemItem (i, s, selecionado);
            if not selecionado then continue;
            geraRelatorioCurso (nomeArqUsuario, listaArqCursos[i - 1]);
        end;

    msgBaixo ('DGTOK'); {'Ok'}
    msgBaixo ('DGTRELGER'); {'Relatório gerado'}
end;

{-------------------------------------------------------------}
{       Lista de cursos
{-------------------------------------------------------------}

procedure inicializaListaCursos;
var
    i: integer;
    s, s2, somNomeCurso: string;
begin
    folheiaCria (1, 4, 80, 23);
    FolheiaTocandoArqSom := true;
    for i :=  0 to (listaArqCursos.count -1) do
        begin
            s2 := sintAmbienteArq ('CURSO', 'NOMECURSO', '', listaArqCursos[i]);
            s := copy (s2 + BRANCOS, 1, 60) + ' --> N. lições: ' + sintAmbienteArq ('CURSO', 'QUANTIDADELICOES', '', listaArqCursos[i]);
            somNomeCurso := sintAmbienteArq ('CURSO', 'SOMNOMECURSO', '', listaArqCursos[i]);
            if not existeArqSom (somNomeCurso) then somNomeCurso := s2;
            folheiaAdicionaEspecial (s, false, somNomeCurso);
        end;
end;

{-------------------------------------------------------------}

procedure listarCursos;
var
    c, c2: char;
    podeFalar: boolean;
    nCurso, divisorTempo: integer;

begin
    telaListaCursos (listaArqCursos.count);
    mensagem ('DGTCURDIG', -1);  {'Cursos de digitação'}
    mensagem ('DGTUSESET', -1);  {'Use as setas para selecionar, depois tecle sua opção. F1 ajuda'}

    nCurso := 0;
    podeFalar := true;
    c := 'N'; // Nada faz, apenas para passar no teste para inicializaListaCursos
    repeat
        divisorTempo := 1;
        telaListaCursos (listaArqCursos.count);
        if not (c in ['Q', ^Q, 'V']) then
            inicializaListaCursos;

        folheiaExecuta (nCurso, nCurso, c, c2, podeFalar);
        if nCurso < 1 then nCurso := 1;
        if nCurso > listaArqCursos.count then nCurso := listaArqCursos.count;
        sintPara;
        gotoxy (1, 19);

        if c in ['0', '2' .. '9'] then
            begin
                divisorTempo := strToInt (c);
                if divisorTempo = 0 then divisorTempo := 10;
                msgBaixo ('DGTDESAF'); {'Desafio'}
                msgBaixo ('DGTDIVTEM'); {'Divisor do tempo '}
                sintWriteInt (divisorTempo);
                c := ENTER;
            end;

        if c2 = F9 then
            c := selSetasListaCursos (c2);

        if upcase(c) = 'T' then
            c := selecDivisorTempo (divisorTempo, c2);

        if c = #0 then
            begin
                case c2 of
                    ESQ:    falaApresentacaoOuInstrucao (true, 'CURSO', listaArqCursos[nCurso - 1]);
                    DIR:    falaApresentacaoOuInstrucao (false, 'CURSO', listaArqCursos[nCurso - 1]);
                    F1:     ajudaListaCursos;
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
                    'L': sintetiza (sintAmbienteArq ('CURSO', 'QUANTIDADELICOES', '', listaArqCursos[nCurso - 1]));
                    'C': falaUltimaConcluida (listaArqCursos[nCurso - 1]);
                    'U': sintetiza (nomeUsuario);
                    ^U:  sintSoletra (nomeUsuario);
                    'N': sintetiza (listaArqCursos[nCurso - 1]);
                    'E': listaEstatisticasCurso (nomeArqUsuario, listaArqCursos[nCurso - 1]);
                    'G': geraRelatorioCursos (nomeArqUsuario, listaArqCursos[nCurso - 1]);
                    'Q', ^Q: falaQualItemDoTotal  (nCurso, listaArqCursos.count, c = ^Q);

                    'D':   begin
                                folheiaDestroi;
                                ListaDadosLicao (sintAmbienteArq ('CURSO', 'NOMECURSO', '', listaArqCursos[nCurso - 1]), listaArqCursos[nCurso - 1]);
                                limpaBufTec;
                            end;

                    'V':   if modoTesteAtivo then
                                validarLicoes (listaArqCursos[nCurso - 1])
                            else
                                msgBaixo ('DGTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}

                    ENTER: begin
                                folheiaDestroi;
                                listaLicoesCurso (divisorTempo, listaArqCursos[nCurso - 1]);
                            end;

                    ESC:;
                else
                    if c <> ESC then
                        msgBaixo ('DGTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}
                end;

                if not (upcase(c) in [ESC, 'Q', 'N', 'L', 'U', 'C', 'V']) then
                    msgBaixo ('DGTSELESC');  {'Continue selecionando ou tecle ESC  para sair'}
            end;

        if (upCase(c) in[ENTER, 'Q', 'L', 'N', 'U', 'C']) or
            (c2 in [ESQ, DIR, F4, f8, CTLF8]) then
                podeFalar := false
        else
                podeFalar := true;

        if not (upcase (c) in ['Q', ^Q, 'V', 'D', ENTER]) then
                folheiaDestroi;

    until c = #$1b;

end;

{-------------------------------------------------------------}

begin
end.
