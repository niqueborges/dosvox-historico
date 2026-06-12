{--------------------------------------------------------}
{
{    Manual interativo do Dosvox
{
{    Programa principal
{
{    Autores: Otávio Moreira Meirelles
{
{    Em Maio de 2011
{
{--------------------------------------------------------}

program manvox;

uses
  dvcrt,
  dvwin,
  dvform,
  sysutils,
  mnMsg,
  mnLeInst,
  mnAudio,
  mnCateg,
  mnLstAlf;

{--------------------------------------------------------}
{              seleção interativa de opções
{--------------------------------------------------------}

function selInterativa: char;
var n: integer;
    c: char;
const
    cod: array  [0..5] of char = (ESC, 'L', 'C', 'M', 'P', ESC);
begin
    popupMenuCria (wherex, wherey, 50, 6, red);
    MenuAdiciona ('MNOPLER');      // 'Ler as instruções básicas do sistema
    MenuAdiciona ('MNOPCURS');     // 'Curso do dosvox gravado em áudio
    MenuAdiciona ('MNLECAT');      // 'Ler manuais por categoria
    MenuAdiciona ('MNMANPRG');     // 'Ler o manual de um certo programa
    MenuAdiciona ('MNFIM');        // 'ESC - Finalizar o programa
    limpaBufTec;
    n := popupMenuSeleciona;

    c := cod[n];

    if c <> #$1b then writeln (c);
    writeln;
    selInterativa := c;
end;

procedure naoImplementado;
begin
    mensagem ('MNNAOIMP', 1);    {'Ainda não foi implementado'}
end;

{--------------------------------------------------------}
{              seleção interativa de opções
{--------------------------------------------------------}

var op, c1, c2: char;
    dir: string;
begin
    dir := SintAmbiente ('MANVOX', 'DIRMANVOX');
    if dir = '' then dir := 'c:\winvox\som\manvox';
    sintInic (0, dir);

    repeat
        clrscr;

        textBackground (BLUE);
        mensagem ('MNINIC', 1);             {'Manual eletrônico do Dosvox'}
        textBackground (BLACK);
        writeln;

        mensagem ('MNSETENT', 2);           {'Selecione a opção com as setas e aperte Enter'}

        op := selInterativa;
        writeln;

        case op of
            'L': ler_instr_basicas;
            'C': curso_em_audio;
            'M': manuais_por_categoria;
            'P': manual_de_programa;
            ESC: break;
        end;

        writeln;
        mensagem ('MNOUTROS', 0);           {'Deseja ler outros manuais? '}
        sintLeTecla (c1, c2);
        writeln;

    until upcase(c1) <> 'S';

    writeln;
    mensagem ('MNFIMPRG', 1);               {'Fim do programa'}
end.
