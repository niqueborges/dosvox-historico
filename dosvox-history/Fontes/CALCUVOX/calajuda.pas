{--------------------------------------------------------}
{
{    Calculadora Vocal - versao 4.0
{
{    Módulo de exibição da ajuda
{
{    Autor: Jose' Antonio Borges
{           Mara Lucia Caldeira
{           Julio Tadeu Carvalho da Silveira
{
{    Versão 4.0 em maio/2019
{
{--------------------------------------------------------}

unit calajuda;

interface
uses dvcrt, dvwin, dvform, calvars, calmsg;

procedure mostraCalc;
procedure mostraFuncoes;
procedure mostraTrigonom;

function  menuCalc: char;
function  menuFuncoes: char;
procedure menuTrigonom (var c, c2: char);

implementation

uses caltela;

{--------------------------------------------------------}

procedure mostraCalc;
begin
    window (45, 3, 80, 25);
    clrscr;

    window (1, 1, 80, 25);
    gotoxy (45, 3);
    writeln ('Funções básicas: +-*/ % \ ( ) =');
    gotoxy (45, 5);
    writeln ('F  Funções matemáticas');
    gotoxy (45, 6);
    writeln ('T  Funções trigonométricas');
    gotoxy (45, 7);
    writeln ('X  Calcula expressão');

    gotoxy (45, 9);
    writeln ('BS apaga dígito');
    gotoxy (45, 10);
    writeln ('C  limpa conta');
    gotoxy (45, 11);
    writeln ('D  número de casas decimais');
    gotoxy (45, 12);
    writeln ('P  põe  na memória (0..9, A..Z)');
    gotoxy (45, 13);
    writeln ('M  traz da memória (0..9, A..Z)');
    window (1, 1, 80, 25);
end;

{--------------------------------------------------------}

procedure mostraFuncoes;
label inicia;
begin
inicia:
    window (45, 3, 80, 25);
    clrscr;

    window (47, 3, 80, 25);
    clrscr;
    writeln ('FUNÇÕES MATEMÁTICAS');
    writeln;
    writeln ('  R = resto');
    writeln ('  I = inverso');
    writeln ('  O = oposto');
    writeln ('  T = truncar');
    writeln ('  A = arredondar');
    writeln ('  F = fracionária');
    writeln;
    writeln ('  P = número pi');
    writeln ('  E = número de Neper');
    writeln ('  L = log');
    writeln ('  N = log neperiano');
    writeln ('  ! = fatorial');
    writeln ('  ^ = elevado a');
    writeln ('  \ = raiz enésima');

    window (1, 1, 80, 25);
end;

{--------------------------------------------------------}

procedure mostraTrigonom;
begin
    window (45, 3, 80, 25);
    clrscr;

    window (47, 3, 80, 25);
    writeln ('FUNÇÕES TRIGONOMÉTRICAS');
    writeln;
    writeln ('  S  = sin');
    writeln ('  C  = cos');
    writeln ('  T  = tan');
    writeln ('  G  = ângulos em graus');
    writeln ('  R  = ângulos em radianos');    //grau para radiano');
    writeln ('  AS = arcsin');
    writeln ('  AC = arccos');
    writeln ('  AT = arctan');
    writeln ('  HS = sinh');
    writeln ('  HC = cosh');
    writeln ('  HT = tanh');
    writeln ('  IS = sinh -1');
    writeln ('  IC = cosh -1');
    writeln ('  IT = tanh -1');

    window (1, 1, 80, 25);
end;

{--------------------------------------------------------}

procedure menuAdiciona (f: string);
begin
    popupMenuAdiciona (f, pegaTextoMensagem (f));
end;

{--------------------------------------------------------}

function menuCalc: char;
var
    n: integer;
const
    tabLetras: string =  '+-*/%\=' + ^8 + 'CDFTX()PM';
begin
    popupMenuCria (xmens, 4, 80-xmens-2, length(tabLetras), RED);
    menuAdiciona ('CA_OP_SOMAR');     {'+   somar'}
    menuAdiciona ('CA_OP_SUBTR');     {'-   subtrair'}
    menuAdiciona ('CA_OP_MULTIP');    {'*   multiplicar'}
    menuAdiciona ('CA_OP_DIVIDIR');   {'/   dividir'}
    menuAdiciona ('CA_OP_PERCENT');   {'%   porcentagem'}
    menuAdiciona ('CA_OP_RAIZ_2');    {'\   raiz quadrada'}
    menuAdiciona ('CA_OP_IGUAL');     {'=   igual'}
    menuAdiciona ('CA_OP_LIMPDIG');   {'backspace  limpa dígito'}
    menuAdiciona ('CA_OP_LIMPCONT');  {'C   limpa conta'}
    menuAdiciona ('CA_OP_NUM_CDEC');  {'D   número de casas decimais'}
    menuAdiciona ('CA_OP_FUNC_M');    {'F   Funções matemáticas'}
    menuAdiciona ('CA_OP_FUNC_T');    {'T   Funções trigonométricas'}
    menuAdiciona ('CA_OP_FUNC_X');    {'X   Calcula expressão'}
    menuAdiciona ('CA_OP_ABRESUB');   {'(   abre sub-expressão'}
    menuAdiciona ('CA_OP_FECHASUB');  {')   fecha sub-expressão'}
    menuAdiciona ('CA_OP_POEMEMO');   {'P   põe na memória'}
    menuAdiciona ('CA_OP_RECMEMO');   {'M   recupera da memória'}

    n := popupMenuSeleciona;
    if (n <= 0) or (n > length(tabLetras)) then
        result := ' '
    else
        result := tabLetras[n];
end;

{--------------------------------------------------------}

function menuFuncoes: char;
var n: integer;
const
    tabLetras: string = 'RIOTAFPELN!^\';
begin
    popupMenuCria (xmens, 4, 80-xmens-2, length(tabLetras), RED);
    menuAdiciona ('CA_OP_RESTO');     {'R  resto'}
    menuAdiciona ('CA_OP_INVERSO');   {'I  inverso'}
    menuAdiciona ('CA_OP_OPOSTO');    {'O  oposto'}
    menuAdiciona ('CA_OP_TRUNCAR');   {'T  truncar'}
    menuAdiciona ('CA_OP_ARREND');    {'A  arredondar'}
    menuAdiciona ('CA_OP_P_FRAC');    {'F  parte fracionária'}
    menuAdiciona ('CA_OP_NUM_PI');    {'P  número pi'}
    menuAdiciona ('CA_OP_NUM_E');     {'E  número de Neper'}
    menuAdiciona ('CA_OP_LOG');       {'L  logaritmo decimal'}
    menuAdiciona ('CA_OP_LOG_E');     {'N  logaritmo neperiano'}
    menuAdiciona ('CA_OP_FATORIAL');  {'!  fatorial'}
    menuAdiciona ('CA_OP_ELEV_A');    {'^  elevado a'}
    menuAdiciona ('CA_OP_RAIZ_N');    {'\  raiz enésima'}

    n := popupMenuSeleciona;
    if (n <= 0) or (n > length(tabLetras)) then
        result := ' '
    else
        result  := tabLetras[n];
end;

{--------------------------------------------------------}

procedure menuTrigonom (var c, c2: char);
var 
    n: integer;
const
    tabLetras:  string = 'SCTGRAAAHHHIII';
    tabLetras2: string = '     SCTSCHSCT';
begin
    popupMenuCria (xmens, 4, 80-xmens-2, length(tabLetras), RED);
    menuAdiciona ('CA_OP_SEN');    {'S   seno'}
    menuAdiciona ('CA_OP_COS');    {'C   cossseno'}
    menuAdiciona ('CA_OP_TAN');    {'T   tangente'}
    menuAdiciona ('CA_OP_GRAU');   {'G   ângulos em graus'}
    menuAdiciona ('CA_OP_RAD');    {'R   ângulos em radianos'}
    menuAdiciona ('CA_OP_ASEN');   {'AS  arco seno'}
    menuAdiciona ('CA_OP_ACOS');   {'AC  arco cosseno'}
    menuAdiciona ('CA_OP_ATAN');   {'AT  arco tangente'}
    menuAdiciona ('CA_OP_SENH');   {'HS  seno hiperbólico'}
    menuAdiciona ('CA_OP_COSH');   {'HC  cosseno hiperbólico'}
    menuAdiciona ('CA_OP_TANH');   {'HT  tangente hiperbólico'}
    menuAdiciona ('CA_OP_ASINH');  {'IS  arco seno hiperbólico'}
    menuAdiciona ('CA_OP_ACOSH');  {'IC  arco cossseno hiperbólico'}
    menuAdiciona ('CA_OP_ATANH');  {'IT  arco tangente hiperbólico'}

    n := popupMenuSeleciona;
    if (n <= 0) or (n > length(tabLetras)) then
        begin
            c := ' ';
            c2 := ' ';
        end
    else
        begin
            c  := tabLetras[n];
            c2 := tabLetras2[n];
        end;
end;

end.

