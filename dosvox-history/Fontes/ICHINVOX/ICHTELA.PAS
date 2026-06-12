{--------------------------------------------------------}
{
{    I Ching-VOX - rotinas de tela
{
{    Autor: José Antonio Borges
{
{    Em 24/06/97
{
{--------------------------------------------------------}

unit ichTela;
interface
    uses dvcrt, dvWin, ichVars;

procedure sintNum (n: integer);
procedure telaBasica;
procedure exibeResumo (falando: boolean);
procedure exibeTelaResumo;

implementation

{--------------------------------------------------------}
{             sintetiza um numero de 0 a 9
{--------------------------------------------------------}

procedure sintNum (n: integer);
var s: string;
begin
    str (n, s);
    sintetiza (s);
end;

{--------------------------------------------------------}
{                limpa tela e poe cabecalho
{--------------------------------------------------------}

procedure telaBasica;
begin
    clrscr;
    TextBackGround (BLUE);
    writeln ('Projeto DOSVOX - I CHING simplificado - v ', versao);
    TextBackGround (BLACK);
    writeln;
    TextBackGround (RED);
    gotoxy (1, 3);   writeln (pergunta);
    TextBackGround (BLACK);
end;

{--------------------------------------------------------}
{                     exibe o resumo
{--------------------------------------------------------}

procedure exibeResumo (falando: boolean);
var i: integer;
    s: string;

begin
    while keypressed do readkey;

    gotoxy (1, 13);
    TextBackGround (BLUE);   write ('Hexagrama diagnóstico: ', hexaDiag);
    TextBackGround (BLACK);  write (' - ');
    TextBackGround (RED);    write (nomeHexagrama [hexaDiag]);
    TextBackGround (BLACK);
    writeln;
    writeln ('    Abaixo:  ', nomePers [indBaixoDiag]);
    writeln ('    Acima :  ', nomePers [indCimaDiag]);

    gotoxy (54, 4);
    TextBackGround (BLUE);
    writeln ('Linhas móveis:');
    TextBackGround (BLACK);
    window (58, 5, 80, 21);

    case tipoMutacao of
        MUTACAO_TOTAL:   begin
                             writeln ('Todas: caso especial');
                             writeln ('   (hexagrama em movimento)');
                         end;

        MUTACAO_FIXA:    writeln ('Nenhuma');

    else
        begin
             for i := 1 to 6 do
                  begin
                      if (linDiag[i] = 6) or (linDiag[i] = 9) then
                            writeln (linDiag[i] ,' na ', ordinal [i], ' posicao');
                  end;
        end;
    end;

    window (1, 1, 80, 25);

    gotoxy (1, 17);
    TextBackGround (BLUE);   write ('Hexagrama prognóstico: ', hexaProg);
    TextBackGround (BLACK);  write (' - ');
    TextBackGround (RED);    write (nomeHexagrama [hexaProg]);
    TextBackGround (BLACK);
    writeln;
    writeln ('    Abaixo:  ', nomePers [indBaixoProg]);
    writeln ('    Acima :  ', nomePers [indCimaProg]);

    gotoxy (1, 24);
    clreol;

    if not falando then
        exit;

{--- fala da tela ---}

    delay (1000);

    while keypressed do readkey;

    sintsom ('ICJOGADA');
    for i := 1 to 6 do
        begin
            if not keypressed then delay (300);
            sintNum (linDiag [i]);
        end;

    sintsom ('ICTLIN');
    if not keypressed then delay (1000);

    sintSom ('ICDIAG');
    sintSom ('ICHEXAG');
    sintNum (hexaDiag);
    str (hexaDiag, s);
    if not keypressed then delay (800);
    sintSom ('ICHEX' + s);

    sintSom ('ICFORM');
    sintSom ('ICABAIXO');
    sintSom ('ICPER' + chr (indBaixoDiag + ord('0')));
    sintSom ('ICACIMA');
    sintSom ('ICPER' + chr (indCimaDiag + ord('0')));

    if not keypressed then delay (1000);

    for i := 1 to 6 do
        begin
            if (linDiag [i] = 6) or (linDiag [i] = 8) then
                 sintSom('ICYIN')
            else
                 sintSom('ICYANG');
        end;

    if not keypressed then delay (1000);
    sintSom ('ICPROG');
    sintSom ('ICHEXAG');
    sintNum (hexaProg);
    str (hexaProg, s);
    if not keypressed then delay (800);
    sintSom ('ICHEX' + s);

    sintSom ('ICFORM');
    sintSom ('ICABAIXO');
    sintSom ('ICPER' + chr (indBaixoProg + ord('0')));
    sintSom ('ICACIMA');
    sintSom ('ICPER' + chr (indCimaProg + ord('0')));

    if not keypressed then delay (1000);
    for i := 1 to 6 do
        begin
            if (linProg [i] = 6) or (linProg [i] = 8) then
                sintSom('ICYIN')
            else
                sintSom('ICYANG');
        end;

    if not keypressed then delay (1000);
    sintSom ('ICLINMOV');
    case tipoMutacao of
        MUTACAO_TOTAL:  sintSom ('ICTODAS');
        MUTACAO_FIXA:   sintSom ('ICNENHUM');
    else
        begin
             for i := 1 to 6 do
                  begin
                      if (linDiag[i] = 6) or (linDiag[i] = 9) then
                          begin
                               if not keypressed then delay (500);
                               sintSom (tabOrdem[i]);
                          end;
                  end;
        end;
    end;

    if not keypressed then delay (1000);
end;

{--------------------------------------------------------}
{               exibe toda a tela de resumo
{--------------------------------------------------------}

procedure exibeTelaResumo;
var i, n: integer;
begin
    telaBasica;

    n := 1;
    for i := 1 to 6 do
        begin
            gotoxy (1, 11-i);
            write ('Linha ', i, '  ');

            write (regMoedas [n], ' ', regMoedas [n+1], ' ', regMoedas [n+2], ' ');
            n := n + 3;
            write ('= ', linDiag[i], '   ', desenho[linDiag[i]]);

            if (linDiag[i] = 6) or (linDiag[i] = 9) then write (' => ');

            gotoxy (33, 11-i);
            write (' ', desenho[linProg[i]]);
        end;

    exibeResumo (true);
end;

end.