{--------------------------------------------------------}
{
{    I Ching-VOX - Cálculo dos hexagramas
{
{    Autor: José Antonio Borges
{
{    Em 24/06/97
{
{--------------------------------------------------------}

unit ichCalc;

interface
uses dvCrt, dvWin, ichVars, ichTela;

procedure pedePergunta;
procedure realizaJogada;
procedure calculaDiagnostico;
procedure fazMutacao;
procedure calculaPrognostico;

implementation

{--------------------------------------------------------}
{                    joga uma moeda
{--------------------------------------------------------}

function jogaMoeda: integer;
var i, n: integer;
    c: char;
begin
    i := random (2);
    repeat
        i := (i + 1) mod 2;
    until keypressed;
    c := readkey;

    if c = #$1b then     { cancelamento prematuro }
        begin
            sintSom ('ICFINAL');
            delay (2000);
            sintFim;
            doneWinCrt;
        end;

    if odd(i) then   n := 3
              else   n := 2;

    nMoedas := nMoedas + 1;
    regMoedas [nMoedas] := n;

    write (n, ' ');
    if n = 2 then
        sintSom ('iccara')
    else
        sintSom ('iccoroa');

    jogaMoeda := n;
end;

{--------------------------------------------------------}
{             calcula o indice dos trigramas
{--------------------------------------------------------}

procedure calculaIndices (cod: str3; var ind: integer);
begin
    if       cod = 'CCC' then ind  := 0
    else  if cod = 'QQQ' then ind  := 1
    else  if cod = 'CQQ' then ind  := 2
    else  if cod = 'QCQ' then ind  := 3
    else  if cod = 'QQC' then ind  := 4
    else  if cod = 'QCC' then ind  := 5
    else  if cod = 'CQC' then ind  := 6
    else  if cod = 'CCQ' then ind  := 7;
end;

{--------------------------------------------------------}
{                    pede a pergunta
{--------------------------------------------------------}

procedure pedePergunta;
begin
    gotoxy (1, 23);
    TextBackGround (RED);
    writeln ('Mergulhe nas suas dúvidas e tecle Enter:');
    sintSom ('ICFORMU');
    TextBackGround (BLACK);
    sintReadln (pergunta);

    TextBackGround (RED);
    gotoxy (1, 3);   writeln (pergunta);
    TextBackGround (BLACK);
    gotoxy (1, 23);  clreol;
    gotoxy (1, 24);  clreol;
end;

{--------------------------------------------------------}
{                    joga as moedas
{--------------------------------------------------------}

procedure realizaJogada;
var i: integer;
begin
    gotoxy (1, 24);
    TextBackGround (RED);
    writeln ('Aperte uma tecla para jogar uma moeda');
    sintSom ('ICMOEDA');
    TextBackGround (BLACK);

    nMoedas := 0;

    for i := 1 to 6 do
        begin
            gotoxy (1, 11-i);
            write ('Linha ', i, '  ');

            linDiag[i] := jogaMoeda + jogaMoeda + jogaMoeda;
            write ('= ', linDiag[i], '   ', desenho[linDiag[i]]);
            if (linDiag[i] = 6) or (linDiag[i] = 9) then write (' => ');

            if (linDiag [i] = 6) or (linDiag [i] = 8) then
                sintSom ('ICYIN')
            else
                sintSom ('ICYANG');
        end;
end;

{--------------------------------------------------------}
{                     calcula o diagnostico
{--------------------------------------------------------}

procedure calculaDiagnostico;
begin
    codBaixoDiag := simbologia [linDiag[1]] +
                    simbologia [linDiag[2]] +
                    simbologia [linDiag[3]];
    calculaIndices (codBaixoDiag, indBaixoDiag);

    codCimaDiag  := simbologia [linDiag[4]] +
                    simbologia [linDiag[5]] +
                    simbologia [linDiag[6]];
    calculaIndices (codCimaDiag, indCimaDiag);

    hexaDiag := tabHexagramas [indBaixoDiag * 8 + indCimaDiag];
end;

{--------------------------------------------------------}
{                    faz a mutacao
{--------------------------------------------------------}

procedure fazMutacao;
var i: integer;
begin
    tipoMutacao := MUTACAO_FIXA;

    for i := 1 to 6 do
        begin
            linProg [i] := linDiag [i];

            if linDiag[i] = 6 then
                 begin
                     linProg[i] := 7;
                     tipoMutacao := MUTACAO_USUAL;
                 end;

            if linDiag[i] = 9 then
                 begin
                     linProg[i] := 8;
                     tipoMutacao := MUTACAO_USUAL;
                 end;

            gotoxy (33, 11-i);
            write (' ', desenho[linProg[i]]);
        end;

    if ((linDiag[1] = 6) and (linDiag[2] = 6) and (linDiag[3] = 6) and
        (linDiag[4] = 6) and (linDiag[5] = 6) and (linDiag[6] = 6))
                       or
       ((linDiag[1] = 9) and (linDiag[2] = 9) and (linDiag[3] = 9) and
        (linDiag[4] = 9) and (linDiag[5] = 9) and (linDiag[6] = 9))  then
             tipoMutacao := MUTACAO_TOTAL;
end;

{--------------------------------------------------------}
{                   calcula o prognostico
{--------------------------------------------------------}

procedure calculaPrognostico;
begin
    codBaixoProg := simbologia [linProg[1]] +
                    simbologia [linProg[2]] +
                    simbologia [linProg[3]];
    calculaIndices (codBaixoProg, indBaixoProg);

    codCimaProg  := simbologia [linProg[4]] +
                    simbologia [linProg[5]] +
                    simbologia [linProg[6]];
    calculaIndices (codCimaProg, indCimaProg);

    hexaProg := tabHexagramas [indBaixoProg * 8 + indCimaProg];
end;

end.