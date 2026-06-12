unit suconfig;

interface
uses
    dvcrt, dvwin, dvarq, windows,
    sudesen, sumsg, suvars;

procedure instrucoes;
procedure inicializa;
procedure finaliza;

implementation

{---------------------------------------------------------------}
{                           instruções                          }
{---------------------------------------------------------------}

procedure instrucoes;
begin
    inicTela;
    mensagem ('SUINSTR1', 0);
    limpaBufTec;
    mensagem ('SUAPTENT', 0);
    readln;
    sintPara;
    inicTela;
    mensagem ('SUINSTR2', 0);
    limpaBufTec;
    mensagem ('SUAPTENT', 0);
    readln;
    sintPara;
    inicTela;
end;

{---------------------------------------------------------------}
{                   inicializa o programa                       }
{---------------------------------------------------------------}

procedure inicializa;
var c, c2: char;
    nomeDirSudoku: string;
    s: string;
    arqSudoku, arqTrab: textFile;
    dir: string;
begin
    inicTela;
    dir := sintAmbiente ('SUDOVOX', 'DIRSUDOVOX');
    if dir = '' then
        dir := 'c:\winvox\som\sudovox';
    sintInic (0, dir);

    nomeArqTrab := sintAmbiente ('SUDOVOX', 'ARQTRAB');
    if nomeArqTrab = '' then
        nomeArqTrab := arqDefault;

    gotoxy (1, 3);
    mensagem ('GONG', 0);
    mensagem ('SUINIC', 0);    {'Benvindo ao jogo de Sudoku VOX, versão '}
    sintWriteln (versao);

    gotoxy (1, 5);
    textBackground (BLUE);
    mensagem ('SUDESEJA', 0);  {'Deseja Instruções? '}
    textBackground (BLACK);
    sintLeTecla (c, c2);
    writeln; writeln;

    if upcase(c) = 'S' then
        instrucoes;

     mensagem ('SUQUERCT', 0);   {'Quer continuar jogo anteriormente iniciado? '}
     sintLeTecla (c, c2);
     writeln; writeln;
     if upcase(c) = 'S' then
         exit;

     mensagem ('SUNIVEL', 0);  {'Qual o nível: fácil, médio ou difícil?'}
     sintLeTecla (c, c2);
     writeln;

     c := upcase (c);
     nomeArqSudoku := '';
     if not (c in ['F', 'M', 'D']) then c := 'F';
     case c of
         'F': nomeDirSudoku := sintAmbiente ('SUDOVOX', 'DIRFACIL');
         'M': nomeDirSudoku := sintAmbiente ('SUDOVOX', 'DIRMEDIO');
         'D': nomeDirSudoku := sintAmbiente ('SUDOVOX', 'DIRDIFICIL');
     end;

     if nomeDirSudoku <> '' then
         begin
             {$I-} chdir (nomeDirSudoku);  {$I-}
             if ioresult <> 0 then ;
         end;

     limpaBufTec;
     writeln;
     textBackground (BLUE);
     mensagem ('SUESCSET', 1);  {'Escolha com as setas o sudoku desejado'}
     textBackground (BLACK);
     nomeArqSudoku := obtemNomeArqMasc(10, '*.SUD');
     writeln (nomeArqSudoku);

     if nomeArqSudoku = '' then
          nomeArqSudoku := 'exemplo.sud';

     assign (arqSudoku, nomeArqSudoku);
     assign (arqTrab, nomeArqTrab);
     try
         reset (arqSudoku);
         rewrite (arqTrab);
         while not eof (arqSudoku) do
             begin
                 readln (arqSudoku, s);
                 writeln (arqTrab, s);
             end;
     finally
         closeFile (arqSudoku);
         closeFile (arqTrab);
     end;
end;

{---------------------------------------------------------------}
{                   finaliza o programa                         }
{---------------------------------------------------------------}

procedure finaliza;
begin
    gotoxy (1, 25); clreol;
    mensagem ('SUFIM', 0);   {'Fim do jogo Sudovox'}
    while sintFalando do waitMessage;
    delay (1000);
    sintFim;
end;

end.
