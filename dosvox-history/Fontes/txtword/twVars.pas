{--------------------------------------------------------}
{
{    Variaveis globais do TXTWord
{
{    Autor: Neno Henrique da Cunha Albernaz
{
{    Em 25/03/2007
{
{--------------------------------------------------------}

Unit twVars;

interface

uses
//  sysutils,
  classes;
//  comobj,
//  activex;

Const
    versao = '1.3';

    wdAlignParagraphLeft = 0;
    wdAlignParagraphCenter = 1;
    wdAlignParagraphRight = 2;
    wdAlignParagraphJustify = 3;

    wdAuto = 0;
    wdBlack = 1;
    wdBlue = 2;
    wdTurquoise = 3;
    wdBrightGreen = 4;
    wdPink = 5;
    wdRed = 6;
    wdYellow = 7;
    wdWhite = 8;
    wdDarkBlue = 9;
    wdTeal = 10;
    wdGreen = 11;
    wdViolet = 12;
    wdDarkRed = 13;
    wdDarkYellow = 14;
    wdGray50 = 15;
    wdGray25 = 16;

{--------------------------------------------------------}

Var
    nomeArq: string;
    aplicWord, docWord: variant;
    texto: TStringList;


implementation

end.
