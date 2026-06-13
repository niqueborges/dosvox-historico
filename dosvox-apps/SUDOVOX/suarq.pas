unit suarq;

interface
uses
    dvcrt, dvwin,
    sudesen, sumsg, suvars;

procedure salvaJogo (nomeArq: string);
function carregaJogo (nomeArq: string): boolean;

implementation

{---------------------------------------------------------------}
{                   salva o jogo num arquivo                    }
{---------------------------------------------------------------}

procedure salvaJogo (nomeArq: string);
var
    arq: textFile;
    xc, yc: integer;
begin
    assign(arq, nomeArq);
    {$I-}  rewrite(arq);  {$I+}
    if ioresult <> 0 then
        begin
            gotoxy (50, 5);  clreol;
            sintBip;
            mensagem ('SUERRGRV', 1);    {'Erro de gravação'}
            exit;
        end;

    for yc := 0 to 8 do
        for xc := 0 to 8 do
            write (arq, sudoku [xc, yc]);
    writeln (arq);

    closefile (arq);
    mensagem ('SUSALVO', 0);   {'Ok, salvo'}
end;

{---------------------------------------------------------------}
{                 carrega o jogo de um arquivo                  }
{---------------------------------------------------------------}

function carregaJogo (nomeArq: string): boolean;
var
    arq: textFile;
    xc, yc: integer;
    c: char;
begin
    carregaJogo := false;
    assign (arq, nomeArq);
    {$I-}  reset(arq);  {$I+}
    if ioresult <> 0 then
        begin
            sintBip;
            mensagem ('SUARQNAO', 1);    {'Arquivo com o jogo não existe'}
            exit;
        end;

    for yc := 0 to 8 do
        for xc := 0 to 8 do
            begin
                repeat
                    read (arq, c);
                    if (c = '.') or (c = '-') or(c = '*') then
                        c := '0';
                until (c <> #$0d) and (c <> #$0a);
                sudoku[xc, yc] := ord(c) - ord ('0');
                fixo [xc, yc] := c <> '0';
            end;

    closefile (arq);
    carregaJogo := true;

    sintClek; sintClek; sintClek;
end;

end.



