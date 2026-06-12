{-----------------------------------------------------------------------
{
{       Digitavox - Tratamento das telas
{
{       Autor: Neno Henrique da Cunha Albernaz
{              neno@intervox.nce.ufrj.br
{       Em 05 de Outubro de 2019
{
{----------------------------------------------------------------------}

unit dgtTela;

interface

uses
    classes,
    dvcrt,
    dvForm,
    dvwin,
    sysUtils,
    windows,
    dgtMsg,
    dgtvars;

function centralizaFrase (frase: string): string;
procedure telaPrincipal;
procedure telaListaCursos (numCursos: integer);
procedure telaListaLicoes (nomeCurso: string);
procedure telaCursoLicao (nLicao: integer; nomeCurso: string);
procedure telaPraticaExercicio (rep, repeticoesExer: integer; exer: string; p, nLicao: integer; nomeCurso: string);
procedure telaListaLicoesEstatisticas (nomeCurso: string);
procedure mostraAtividade;

implementation

{-------------------------------------------------------------}
{       Retorna uma string centralizada
{-------------------------------------------------------------}

function centralizaFrase (frase: string): string;
var t, i: integer;
begin
    frase := trim (frase);
    t := length (frase);
    if t < 80 then
        begin
            t := (80 - t) div 2;
            for i := 1 to t do frase := ' ' + frase;
            while length (frase) < 80 do frase := frase + ' ';
        end;

    centralizaFrase := frase;
end;

{-------------------------------------------------------------}
{       Cabeçalho da tela principal
{-------------------------------------------------------------}

procedure telaPrincipal;
begin
    clrscr;
    textBACKGROUND (BLUE);
    textColor (WHITE);
    write (pegaTextoMensagem ('DGTINIC'));  {'Digitavox - Cursos de digitação - Versão '}
    write (VERSAO + TIPOVERSAO);
    textBackground (BLACK);
    writeln; writeln;
end;

{----------------------------------------------------------------------}
{       Cabeçalho da tela de lista de cursos
{----------------------------------------------------------------------}

procedure telaListaCursos (numCursos: integer);
var s: string;
begin
    clrscr;
    textBackGround (BLUE);
    s := pegaTextoMensagem ('DGTLISCUR'); {'Lista dos cursos de digitação'}
    s := s + ' - ' + intToStr(numCursos) + ' cursos';
    write (centralizaFrase (s));
    textBackGround (MAGENTA);
    writeln (centralizaFrase(pegaTextoMensagem ('DGTUSESET')));  {'Use as setas para selecionar, depois tecle sua opção. F1 ajuda'}
    textBackground (BLACK);
    writeln;
end;

{----------------------------------------------------------------------}
{       Cabeçalho da tela de lista das lições de um curso
{----------------------------------------------------------------------}

procedure telaListaLicoes (nomeCurso: string);
var s: string;
begin
    clrscr;
    s := pegaTextoMensagem ('DGTLISLIC'); {'Lista das lições do curso'}
    s := s + ': ' + nomeCurso;
    if length (s) > 80 then s := copy (s, 1, 77) + '...';
    textBackGround (MAGENTA);
    write (centralizaFrase (s));
    textBackground (BLACK);
    writeln (centralizaFrase(pegaTextoMensagem ('DGTUSESET')));  {'Use as setas para selecionar, depois tecle sua opção. F1 ajuda'}
    writeln;
end;

{----------------------------------------------------------------------}
{       Cabeçalho da tela com nome do curso e lição
{----------------------------------------------------------------------}

procedure telaCursoLicao (nLicao: integer; nomeCurso: string);
begin
    clrscr;
    if length (nomeCurso) > 63 then nomeCurso := copy (nomeCurso, 1, 60) + '...';
    nomeCurso := nomeCurso + ' - Lição ' + intToStr(nLicao);
    textBackGround (MAGENTA);
    write (centralizaFrase (nomeCurso));
    textBackground (BLACK);
    writeln;
end;

{-------------------------------------------------------------}
{          mostra atividade a executar na linha inferior
{-------------------------------------------------------------}

procedure mostraAtividade;
var salvay: integer;
begin
    salvay := wherey;
    gotoxy (1, 25);       // macete para deixar a atividade na última linha
    clreol;
    textBackground(RED);
    ultimaLinhaInstrucao := copy (ultimalinhaInstrucao, 1, 80);
    gotoxy ((81-length(ultimaLinhaInstrucao)) div 2, 25);
    write (ultimaLinhaInstrucao);
    textBackground(BLACK);
    gotoxy (1, salvay);
end;

{----------------------------------------------------------------------}
{       Tela da pratica do ecercício
{----------------------------------------------------------------------}

procedure telaPraticaExercicio (rep, repeticoesExer: integer; exer: string; p, nLicao: integer; nomeCurso: string);
var i, t: integer;
begin
    telaCursoLicao (nLicao, nomeCurso);
    writeln (centralizaFrase('Repetições: ' + intToStr(rep) + ' de ' + intToStr(repeticoesExer)));
    writeln;
    t := length (exer);
    if t < 80 then
        t := (80 - t) div 2;
    for i := 1 to t do write (' ');
    if p > 1 then write(copy(exer, 1, p - 1));

    textBackground (RED);
    write (exer[p]);
    textBackground (BLACK);
    writeln(copy(exer, p + 1, length (exer)));

    writeln;
    writeln;
    for i := 1 to t do write (' ');
    if p > 1 then write (copy(exer, 1, p-1));

    mostraAtividade;
end;

{-------------------------------------------------------------}
{       Tela da listagem de lições com estatisticas de um curso
{-------------------------------------------------------------}

procedure telaListaLicoesEstatisticas (nomeCurso: string);
var s: string;
begin
    clrscr;
    s := pegaTextoMensagem ('DGTLCEST'); {'Estatísticas do curso'}
    s := s + ': ' + nomeCurso;
    if length (s) > 80 then s := copy (s, 1, 77) + '...';
    textBackGround (MAGENTA);
    write (centralizaFrase (s));
    textBackground (BLACK);
    writeln (centralizaFrase(pegaTextoMensagem ('DGTSTENES')));  {'selecione com as setas verticais, tecle Enter para ver as estatísticas. F1 ajuda.'}
end;

{----------------------------------------------------------------------}

begin
end.
