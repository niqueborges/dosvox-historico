{--------------------------------------------------------}
{                                                        }
{    Jogo aterrisagem lunar                              }
{                                                        }
{    Módulo de tratamento das formulas fisicas           }
{                                                        }
{    Autor: Diego Costa Pontes                           }
{                                                        }
{    Em agosto/2006                                      }
{                                                        }
{--------------------------------------------------------}

unit lufisica;

interface
uses
  luvars,
  lueventos,
  dvcrt,
  dvwin,
  sysutils;

procedure atualizaPosicao;

implementation

{-------------------------------------------------------------}
{                atualiza a posição da nave                   }
{-------------------------------------------------------------}

procedure atualizaPosicao;
begin
    velocFinal := velocInicial + (gravidadeLua * intervalo) - combAplicar * (8/7);
    y := y - (((velocFinal+velocInicial)/ 2) * intervalo);
    comb := comb - combAplicar;
end;

end.
