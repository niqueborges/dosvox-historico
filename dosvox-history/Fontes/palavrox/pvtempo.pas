{---------------------------------------------------------}
{                                                         }
{    Programa Palavrox                                    }
{                                                         }
{    Módulo de controle do tempo                          }
{                                                         }
{    Autor: João Marcelo de Andrade & João Pedro Souza    }
{                                                         }
{    Em Outubro/2018                                      }
{                                                         }
{    Revisão: Júlio Silveira e Antonio Borges             }
{                                                         }
{    Em Dezembro/2018                                     }
{                                                         }
{---------------------------------------------------------}

unit pvtempo;

interface
uses
  sysutils,
  windows,
  classes,
  dvcrt,
  dvwin,
  dvWav,
  pvvars,
  pvmsg,
  pvBanner;

procedure displayTempo (falando: boolean);
procedure resetTempoDaJogada;
function verificaTempos: boolean;

implementation

{--------------------------------------------------------}
{                 Fala o tempo de jogo.                  }
{--------------------------------------------------------}

procedure displayTempo (falando: boolean);
var
    h, m, s, ms: word;
    salvay: integer;
begin
    verificaTempos;
    DecodeTime (tempoDaJogada, h, m, s, ms);

    salvay := wherey;
    limpabaixo(25);

    if falando then
        begin
            mensagem  ('PVTEMPOP', 0);   {'Tempo: '}
            sintWrite (intToStr(m) + ' minutos e '+  intToStr(s) + ' segundos. ');
        end
    else
        write (pegaTextoMensagem('PVTEMPOP') + intToStr(m) + ' minutos '
                                             + intToStr(s), '  segundos. ');
    gotoxy (1, salvay);
end;

{--------------------------------------------------------}
{               Inicialização de tempos.                 }
{--------------------------------------------------------}

procedure resetTempoDaJogada;
begin
    inicioDaJogada := Now;
    tempoDaJogada  := 0;
    tempoEsgotado  := False;
end;

{--------------------------------------------------------}
{       Verificação de estouro nos tempos de jogo.       }
{--------------------------------------------------------}

function verificaTempos: boolean;
begin
    tempoDaJogada := Now - inicioDaJogada;
    tempoEsgotado := (tempoDaJogada > tempoLimDaJogada);

    result := not tempoEsgotado;
end;

end.
