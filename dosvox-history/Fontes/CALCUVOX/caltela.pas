{--------------------------------------------------------}
{
{    Calculadora Vocal - versao 4.0
{
{    Módulo de exibição na tela
{
{    Autor: Jose' Antonio Borges
{           Mara Lucia Caldeira
{           Julio Tadeu Carvalho da Silveira
{
{    Versão 4.0 em maio/2019
{
{--------------------------------------------------------}

unit caltela;

interface
uses
    calvars, calajuda, calfala,
    dvcrt, dvwin, dvAmplia,
    windows, math, SysUtils;

const
    xIniFita =   6;
    yIniFita =   4;
    xFimFita =  39;
    yFimFita =  17;
    dyFita   =  yFimFita-yIniFita+1;

    tamValorFita = 28;

    xPainel =   1;
    yPainel =  18;

    xVisor   = 17;
    yVisor   = 19;
    tamVisor = maxDigitos;

    brancosVisor: string[tamVisor] = '                  ';
    xUnidAng =  5;
    yUnidAng = 19;

    xMens = 45;
    yMens = 25;

procedure exibeValor  (valor: Numerico; tamCampo, precisao: integer; fala: boolean);
procedure mostraValor (x, y: integer; valor: Numerico; tamCampo, precisao: integer);

procedure exibeCalculadora (fala: boolean);
procedure exibeVisor (valor: Numerico);
procedure exibeMemorias;
procedure exibeMens (cod, mensagem: string);
procedure exibeFita;
procedure exibeUnidadeAngular (fala: boolean);

procedure testaTela;
procedure mostraResult;

implementation

uses calfita;


{--------------------------------------------------------}

procedure exibeValor (valor: Numerico; tamCampo, precisao: integer; fala: boolean);
begin
    if tamanhoCampo (valor, precisao) > tamVisor then
    begin
        write ('E':tamCampo);
        if fala then
            sintetiza ('CA_ERRO');  { 'Erro' }
    end
    else
       write (valor:tamCampo:precisao);
end;

{--------------------------------------------------------}

procedure mostraValor (x, y: integer; valor: Numerico; tamCampo, precisao: integer);
begin
    gotoxy (x, y);
    exibeValor (valor, tamCampo, precisao, false);
    amplCampo (FloatToStrF(valor, ffNumber, tamcampo, precisao),1);
end;

{--------------------------------------------------------}

procedure exibeFita;
var i: integer;
begin
    gotoxy (1, yIniFita);
    TextColor(Yellow);

    {   Fita:

                 '         1         2         3         4'
                 '1234567890123456789012345678901234567890'
                 '    |                                  |'
    }
    for i := yIniFita to yFimFita do    { desenha fita }
        writeln ('    |                                  |');

    TextColor(White);
    for i := posFita-dyFita+1 to posFita do
        begin
            if i > 0 then
            begin
                gotoxy (7, yIniFita+i-(posFita-dyFita+1));
                if opFita[i] = '' then
                    write ('                                 ')
                else
                if opFita[i] = '(' then
                    write ('':tamValorFita, ' ', opFita[i])
                else
                if isNan (valorFita[i]) then
                    write ('                        Erro', ' ', opFita[i])
                else
                    write (valorFita[i]:tamValorFita:ndecimais, ' ', opFita[i]);
            end;
                /////////////// melhorar se números grandes ////////////////////
        end;
end;

{--------------------------------------------------------}

procedure exibeVisor (valor: Numerico);
begin
    mostraValor (xVisor, yVisor, valor, tamVisor, ndecimais);
end;

{--------------------------------------------------------}

procedure exibeUnidadeAngular (fala: boolean);
begin
    gotoxy (xUnidAng, yUnidAng);
    textBackground (MAGENTA);
    textColor (WHITE);
    if angulosEmGraus then
        write (' GRAU ')
    else
        write (' RAD  ');
    textBackground (BLACK);
    textColor (WHITE);
    if fala then
        falaUnidadeAngular;
end;

{--------------------------------------------------------}

procedure exibeCalculadora (fala: boolean);
begin
    textBackground (black);
    clrscr;

    textBackground (DarkGray);
    textColor (Yellow);

    gotoxy (xPainel, yPainel);
    writeln (' +---------------------------------------+ ');
    writeln (' |                                       | ');
    writeln ('++---------------------------------------++');
    writeln ('|    7    8    9       +    =    (    )   |');
    writeln ('|    4    5    6       -    \    C    BS  |');
    writeln ('|    1    2    3       *    %    F    T   |');
    writeln ('|    .    0    ,       /    R    M... ESC |');
    write   ('+-----------------------------------------+');
    textColor (WHITE);
    textBackground (BLACK);

    gotoxy (41, 1);
    textBackGround (BLUE);
    ClrEol;
    gotoxy (47, 1);
    write ('Calculadora Vocal - ', versao);
    textBackGround (BLACK);

    mostraCalc;
    exibeUnidadeAngular (False);
    exibeFita;
    exibeMemorias;

    if fala then
        sintSom ('CA_INIC');    { 'Calculadora vocal' }

    delay (1000);
    exibeVisor (numVisor);
end;

{--------------------------------------------------------}

procedure exibeMemorias;
var i: integer;
    lin: integer;
begin
    textColor (YELLOW);
    gotoxy (45, 15);
    write ('Memórias: ');
    clreol;

    lin := 0;
    for i := 0 to 9+26 do
        if memoria[i] <> 0 then
            begin
                gotoxy (55, lin+15);
                if i < 10 then
                    write (i, ': ')
                else
                    write (chr(i-10+ord('A')), ': ');
                exibeValor (memoria[i], 0, nDecimais, false);
                lin := lin + 1;
                if lin = 10 then break;
            end;

    for i := lin to 9 do
        begin
            gotoxy (55, i+15);
            clreol;
        end;

    textColor (WHITE);
    if lin = 0 then
        begin
            gotoxy (55, 15);
            writeln ('Todas zeradas');
        end;
end;

{--------------------------------------------------------}

procedure mostraResult;
begin
    insFita ('#', numVisor);
    insFita ('', 0);
    exibeFita;
end;

{--------------------------------------------------------}

procedure exibeMens (cod, mensagem: string);
begin
    TextBackground (RED);
    textColor (WHITE);
    gotoxy (xMens, yMens);
    write (' ' + mensagem + ' ');

    TextBackground(BLACK);
    textColor (WHITE);
    if existeArqSom (cod) then
        sintSom (cod)
    else
        sintetiza (mensagem);

    delay (200);
    while sintFalando do
        WaitMessage;

    gotoxy (xMens, yMens);
    ClrEol;
end;

{--------------------------------------------------------}

procedure testaTela;
begin
    exibeCalculadora (false);

    insFita(' ', 3);
    exibeFita;
    insFita('+', 2);
    exibeFita;
    insFita('expo', NaN);
    exibeFita;
    insFita('cos', -479834794798057894755245.4982134708213947);
    exibeFita;
    insFita('=', 5);
    exibeFita;
end;

end.
