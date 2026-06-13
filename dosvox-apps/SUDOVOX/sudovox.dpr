{-------------------------------------------------------------------}
{                                                                   }
{   Programa para jogar e solucionar Sudoku                         }
{                                                                   }
{   Solução do sudoku: baseada em                                   }
{       http://magictour.free.fr/suexco.txt                         }
{                                                                   }
{   Autor: Antonio Borges                                           }
{                                                                   }
{   Em abril/2007                                                   }
{                                                                   }
{-------------------------------------------------------------------}

program sudovox;
uses
  dvcrt,
  dvwin,
  sysutils,
  suvars,
  sudesen,
  suconfig,
  sumsg,
  sujoga,
  suarq,
  sucalc,
  susolve;

begin
    inicializa;

    if carregaJogo (nomeArqTrab) then
        joga;

    finaliza;

    doneWinCrt;
end.


