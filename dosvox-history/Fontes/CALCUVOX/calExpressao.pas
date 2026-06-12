{--------------------------------------------------------}
{
{    Calculadora Vocal - versao 4.0
{
{    Módulo de Cálculo de Função
{
{    Autor: Jose' Antonio Borges
{           Mara Lucia Caldeira
{           Julio Tadeu Carvalho da Silveira
{
{    Versão 4.0 em maio/2019
{
{--------------------------------------------------------}

unit calExpressao;

interface
uses dvwin, dvcrt, dvForm, sysutils, calvars, calmsg, caltela, calajuda, formulaCalc;

procedure ExecutaExpressao;

implementation

var ultExpressao: string;
    formCalc: TFormCalc;

procedure operacaoInvalida;
begin
    writeln;
    writeln;
    textBackground(RED);
    mensagem ('CA_OPINV', 1);
    textBackground(BLACK);

    delay (1000);
    numVisor   := 0;
end;

procedure guardaExpressao (Expressao: string);
var i: integer;
begin
    if ultimasExpressoes.Count = 0 then
        begin
            ultimasExpressoes.Add(Expressao);
            exit;
        end;

    Expressao := trim(Expressao);
    for i := 0 to ultimasExpressoes.Count-1 do
        if Expressao = ultimasExpressoes[i] then
            exit;

    ultimasExpressoes.Insert(0, Expressao);
end;

function mostraUltimasExpressoes: integer;
var i: integer;
begin
    popupMenuCria(wherex, wherey, 80-wherex, 25-wherey, MAGENTA);
    for i := 0 to ultimasExpressoes.Count-1 do
        popupMenuAdiciona('', ultimasExpressoes[i]);
    result := popupMenuSeleciona;
end;

procedure ExecutaExpressao;
var Expressao: string;
    c, v: char;
    y: extended;
    n, p: integer;
    varDest: integer;
    salvaExpressao, vs: string;
    args: array [0..25] of extended; // array of arguments - variable values

label deNovo, fim;
begin
    window (45, 3, 80, 14);
    clrscr;

    Expressao := ultExpressao;

    textBackground(BLUE);
    mensagem ('CA_DIGEXPR', 1);        { 'Editore a expressão' }
    textBackground(BLACK);

deNovo:
    c := sintEditaCampo (Expressao, wherex, wherey, 80, 35, true);
    writeln (Expressao);

    if c = BAIX then
        begin
            n := mostraUltimasExpressoes;
            if n <= 0 then
                c := ESC
            else
                begin
                    Expressao := ultimasExpressoes[n-1];
                    window (45, 3, 80, 25);  clreol;
                    mensagem ('CA_ALTENT', 1);      {'Altere ou tecle enter'}
                    goto deNovo;
                end;
        end;

    if (c = ESC) or (trim(Expressao) = '') then
        begin
            sintBip;
            goto fim;
        end;

    salvaExpressao := Expressao;

    p := pos ('=', Expressao);
    if p = 0 then
        varDest := -1
    else
        begin
            vs := trim (copy (Expressao, 1, p-1));
            delete (Expressao, 1, p);
            if (length(vs) <> 1) or (not (upcase(vs[1]) in ['0'..'9', 'A'..'Z'])) then
                begin
                    operacaoInvalida;
                    goto fim;
                end;
            if vs[1] in ['0'..'9'] then
                varDest := ord(vs[1]) - ord('0')
            else
                varDest := ord(upcase(vs[1])) - ord('A') + 10;
                // as variaveis ficam 10 posições depois das memórias numéricas
        end;

    formCalc.Variables.Clear;
    for v := 'a' to 'z' do
        begin
            formCalc.Variables.Add(v);
            args[ord(v)-ord('a')] := memoria[ord(v)-ord('a')+10];
        end;

    formCalc.Formula := Expressao;
    y := formCalc.calc(args);

    if formCalc.Err then
        operacaoInvalida
    else
        begin
            numVisor := y;
            if varDest <> -1 then
                memoria[varDest] :=y;
        end;

    guardaExpressao (salvaExpressao);
    ultExpressao := salvaExpressao;

fim:
    window (1, 1, 80, 25);
    clrscr;

    exibeCalculadora(false);
    mostraCalc;
    exibeUnidadeAngular (False);
    exibeFita;
    exibeMemorias;
end;

begin
    formCalc := TFormCalc.Create;
end.

