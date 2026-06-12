{-------------------------------------------------------------}
{
{       Digitavox - variáveis globais
{
{       Autor: Neno Henrique da Cunha Albernaz
{              neno@intervox.nce.ufrj.br
{       Em 05 de Outubro de 2019
{
{-------------------------------------------------------------}

unit dgtVars;

interface

uses
    classes;

const
    VERSAO = '2.0';
    TIPOVERSAO = '';
    BRANCOS = '                                                                                ';

var
    listaArqCursos: TStringList;
    nomeUsuario: string;
    nomeArqUsuario: string;
    dirCursos: string;
    dirUsuarios: string;
    dirRelatorios: string;
    comEfeitos: boolean;
    falarTecla: boolean;
    modoTesteAtivo: boolean;
    ultimaLinhaInstrucao: string;

    somNomeCurso: string;
    somApresentacao: string;
    somInstrucao: string;
    somIniCurso: string;
    somFimCurso: string;
    somIniLicao: string;
    somFimLicao: string;
    somInicioExercicio: string;
    somFimExercicio: string;
    somErroExercicio: string;
    somConcluiuLicao: string;

implementation

{-------------------------------------------------------------}

begin
end.
