{--------------------------------------------------------}
{                                                        }
{    Jogo aterrisagem lunar                              }
{                                                        }
{    Módulo de declaração de constantes e variáveis      }
{                                                        }
{    Autor: Diego Costa Pontes                           }
{                                                        }
{    Em agosto/2006                                      }
{                                                        }
{--------------------------------------------------------}

unit plvars;

interface


{-------------------------------------------------------------}
{                     tipos globais                           }
{-------------------------------------------------------------}

type
    TScore = Record
            nome: String;
            pontos: integer;
    end; {TScore}

{-------------------------------------------------------------}
{                      variáveis globais                      }
{-------------------------------------------------------------}

var
    intervalo: real;       // intervalo de tempo em segundos entre cada
                           // interacao com o usuario.
    marcacaoBasica: integer;   // distância entre bips

    t : real;       // tempo final.
    t0 : integer;       // tempo inicial.


    nivel : integer;        // recebe a dificuldade escolhida.

    contador: integer;
    num : integer;
    vetpalavras : array[1..200] of shortstring;

    dificuldade      : textfile;
    lido             : string;
    tenta            : string; //recebe a palavra digitada
    c                : char;

    scores : array [1..10] of TScore;
    nScores: integer;
    scoreTemp: integer;
    marcacao: integer;
    comIntuicao: boolean;

implementation

end.
