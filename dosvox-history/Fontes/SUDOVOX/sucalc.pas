unit sucalc;

interface
uses dvcrt, dvwin, susolve, sumsg, suvars;

function calculaSolucao: boolean;

implementation

{---------------------------------------------------------------}
{                    calcula a solução                          }
{---------------------------------------------------------------}

function calculaSolucao: boolean;
var input, output: string;
    x, y, nc: integer;
    c, c2: char;
begin
    calculaSolucao := false;

    mensagem ('SUQUERCA', 0);  {'Quer mesmo que eu calcule?'}
    sintLeTecla (c, c2);
    writeln;
    if upcase (c) <> 'S' then exit;

    input := '';
    for y := 0 to 8 do
        for x := 0 to 8 do
             input := input + chr (sudoku[x, y] + ord('0'));
    solve (input, output);

    if length (output) < 81 then
        begin
            gotoxy (50, 5);
            mensagem ('SUIMPOSS', 2);  {'Solução impossível'};
            exit;
        end;

    nc := 1;
    for y := 0 to 8 do
        for x := 0 to 8 do
            begin
                sudoku[x, y] := ord (output [nc]) - ord ('0');
                nc := nc + 1;
            end;

    calculaSolucao := true;
end;

end.
