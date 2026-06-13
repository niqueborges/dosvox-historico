unit sudesen;

interface
uses
  dvcrt, dvwin, sysutils,
  suvars;

procedure inicTela;
procedure inicTelaJogo;
procedure mostraPosCursor;
procedure mostraSudoku;
procedure mostraQuadrinho (x, y: integer);

implementation

const
    ORGX = 3;
    ORGY = 3;

{---------------------------------------------------------------}
{                 mostra a posição do cursor                    }
{---------------------------------------------------------------}

procedure mostraPosCursor;
begin
    gotoxy (50, 3);
    write ('L=', ycur+1, ' C=', xcur+1);
    gotoxy (50, 5);
end;

{---------------------------------------------------------------}
{                   Inicializa tela do jogo                     }
{---------------------------------------------------------------}

procedure inicTela;
begin
    textBackground (BLACK);
    clrscr;
    gotoxy (1, 1);
    textBackground (BLUE);
    writeln ('SUDOKU Vox - v.1.0');
    textBackground (BLACK);
    gotoxy (1, 3);
end;

{---------------------------------------------------------------}
{                   Inicializa tela do jogo                     }
{---------------------------------------------------------------}

procedure inicTelaJogo;
begin
    textBackground (BLACK);
    clrscr;
    gotoxy (1, 1);
    textBackground (BLUE);
    writeln ('SUDOKU Vox - v.1.0');

    gotoxy (1, 25);
    write ('    F1-ajuda     F2-salva      F3-recupera      F9-opções       ESC-termina');
    clreol;

    textBackground (BLACK);

    mostraPosCursor;
end;

{---------------------------------------------------------------}
{                Mostra um quadrinho com número                 }
{---------------------------------------------------------------}

procedure mostraQuadrinho (x, y: integer);
var xt, yt, xs, ys, salva: integer;
begin
    xs := wherex;
    ys := wherey;
    salva := textAttr;

    xt := ORGX + x*5;
    yt := ORGY + y*2 + ((y+2) div 3);

    if odd (x div 3 + y div 3) then
        textBackground (LIGHTGRAY)
    else
        textBackground (DARKGRAY);

    if (y mod 3) = 0 then
        begin
            gotoxy (xt, yt);
            write ('     ');
            yt := yt + 1;
        end;

    if (x = xcur) and (y = ycur) then
        textBackground (WHITE);

    if fixo [x, y] then
        textColor (BLUE)
    else
        textColor (BROWN);

    gotoxy (xt, yt);
    if sudoku [x, y] <> 0 then
        write ('  ' + intToStr(sudoku [x, y]) + '  ')
    else
        write ('  .  ');

    yt := yt + 1;
    gotoxy (xt, yt);
    write ('     ');

    textAttr := salva;
    gotoxy (xs, ys);
end;

{---------------------------------------------------------------}
{                     Mostra todo Sudoku                        }
{---------------------------------------------------------------}

procedure mostraSudoku;
var salva, x, y: integer;
begin
    salva := textAttr;
    textColor (BROWN);
    for y := 0 to 8 do
        for x := 0 to 8 do
            mostraQuadrinho (x, y);

    textAttr := salva;
    mostraPosCursor;
end;

end.
