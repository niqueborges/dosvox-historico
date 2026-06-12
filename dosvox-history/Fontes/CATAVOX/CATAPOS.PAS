{--------------------------------------------------------}
{
{    Programa Cata Palavras - Módulo gerador de tabuleiro
{
{    Autor: Jose' Antonio Borges
{
{    Em 02/05/98
{
{--------------------------------------------------------}

unit cataPos;
interface
uses dvCrt, dvWin, cataVars, cataMsg;

procedure posicPalavras;

implementation

var
    maxTent: integer;

{--------------------------------------------------------}
{           posiciona palavras num tabuleiro
{--------------------------------------------------------}
{
{ Níveis do jogo
{
{ 1 - horizontais para direita
{ 2 - horizontais para direita e esquerda
{ 3 - horizontais para direita e verticais para baixo
{ 4 - horizontais para direita e esquerda e verticais para baixo
{ 5 - horizontais para direita e esquerda e verticais para cima e baixo
{ 6 - horiz dir esq,  vert cima baixo, diagonal dir/baixo
{ 7 - horiz dir esq, vert cima baixo, diagonal dir/baixo esq/baixo
{ 8 - horiz dir esq, vert cima baixo, diagonal dir/baixo, dir/cima,
{       esq/baixo, esq/cima
}
const
    maxNivel = 8;

    vetDirNivel: array [1..8] of string [MAXNIVEL] =
       ('1', '15', '17', '157', '1357', '13578', '135678', '12345678');

{ Direções
{
{    4  3  2
{     \ | /
{      \|/
{  5 ------- 1
{      /|\
{     / | \
{    6  7  8
}
const
    dxDir: array [1..8] of integer = (1, 1, 0, -1, -1, -1, 0, 1);
    dyDir: array [1..8] of integer = (0, -1, -1, -1, 0, 1, 1, 1);

{--------------------------------------------------------}
{                  zera o tabuleiro
{--------------------------------------------------------}

procedure zeraTabuleiro;
var
    i: integer;
begin
    fillchar (tabul, sizeof (tabul), '.');
    for i := 0 to DIM+1 do
        begin
            tabul [0, i] := '@';
            tabul [DIM+1, i] := '@';
            tabul [i, 0] := '@';
            tabul [i, DIM+1] := '@';
        end;

    maxTent := DIM * DIM * length (vetDirNivel [nivel]);
end;

{-------------------------------------------------------------}
{           gera posicao e direcao randomicos
{-------------------------------------------------------------}

procedure geraPosDir (var x, y, dir: integer);
var dDir: integer;
begin
    x := random (DIM) + 1;
    y := random (DIM) + 1;
    dDir := random (length (vetDirNivel[nivel])) + 1;
    dir := ord (vetDirNivel [nivel][dDir]) - ord ('0');
end;

{-------------------------------------------------------------}

procedure geraPos (var x, y: integer);
begin
    x := random (DIM) + 1;
    y := random (DIM) + 1;
end;

{-------------------------------------------------------------}
{                 carimba palavra no tabuleiro
{-------------------------------------------------------------}

function carimbaPalavra (qualPal, x, y, dir: integer; var contAnterior: strDIM): boolean;
var
    xx, yy, i, j: integer;
    pal: string;
begin
    contAnterior := '';
    xx := x;
    yy := y;
    pal := tabPal [qualPal];
    for i := 1 to length (pal) do
         begin
             if (tabul [x, y] = '.') or (tabul [x, y] = pal [i]) then
                 begin
                     contAnterior := contAnterior + tabul [x, y];
                     tabul [x, y] := pal [i];
                     x := x + dxDir [dir];
                     y := y + dyDir [dir];
                 end
             else
                 begin
                     x := xx;
                     y := yy;
                     for j := 1 to i-1 do
                         begin
                             tabul [x, y] := contAnterior [j];
                             x := x + dxDir [dir];
                             y := y + dyDir [dir];
                         end;
                     carimbaPalavra := false;
                     exit;
                 end;
         end;

    carimbaPalavra := true;
end;

{-------------------------------------------------------------}
{                 descarimba palavra do tabuleiro
{-------------------------------------------------------------}

procedure descarimbaPalavra (x, y, dir: integer; var contAnterior: strDIM);
var j: integer;
begin
    for j := 1 to length (contAnterior) do
        begin
            tabul [x, y] := contAnterior [j];
            x := x + dxDir [dir];
            y := y + dyDir [dir];
        end;
end;

{--------------------------------------------------------}
{                  mostra tabuleiro
{--------------------------------------------------------}

procedure mostraTab;
var x, y: integer;
begin
    gotoxy (1, 1);
    for y := 1 to DIM do
        begin
            for x := 1 to DIM do
                write (tabul [x, y], ' ');
            writeln;
        end;
end;

{--------------------------------------------------------}
{         tenta encaixar uma palavra (recursiva)
{--------------------------------------------------------}

function encaixaPalavra (qualPal: integer): boolean;
var ntent: integer;
    x, y, dir: integer;
    contAnterior: strDIM;
begin
    encaixaPalavra := true;
    if qualPal > npal then exit;

    ntent := 1;
    geraPosDir (x, y, dir);
    repeat
        if carimbaPalavra (qualPal, x, y, dir, contAnterior) then
            begin
                if encaixaPalavra (qualPal+1) then
                    exit;        { excelente, encaixou !!! }
                descarimbaPalavra (x, y, dir, contAnterior);
            end;
        geraPos (x, y);     { mantém a direção para nova posição }
        ntent := ntent + 1;
    until ntent > maxTent;

    encaixaPalavra := false;
end;

{--------------------------------------------------------}
{                 posiciona as palavras
{--------------------------------------------------------}

procedure posicPalavras;
begin
    randomize;
    zeraTabuleiro;
    if not encaixaPalavra (1) then
        begin
            mensagem ('Problemas no gerador de tabuleiro, tecle Enter');
            readln;
            doneWinCrt;
        end;

    { mostraTab; }
end;

end.