{---------------------------------------------------------}
{                                                         }
{    Programa Palavrox                                    }
{                                                         }
{    Módulo de variáveis                                  }
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

unit pvvars;

interface

uses
    windows,
    SysUtils;

{-------------------------------------------------------------}
{                     tipos globais                           }
{-------------------------------------------------------------}

type
    TScore = record
        nome: String;
        pontos: integer;
    end;

    TTempoDeJogo = record
        hor, min, seg, ms:  word;
    end;

{-------------------------------------------------------------}
{                      variáveis globais                      }
{-------------------------------------------------------------}

const
    _Desconhecida = 0;
    _Inexistente  = 1;
    _Valida      = 2;
    _Repetida     = 3;
    _Pequena      = 4;

const
    versao = '1.1a';

    duracaoMaxJogada: TTempoDeJogo = (hor: 0; min: 2; seg: 0; ms: 0 );

var
    nivel : integer;               { nível de dificuldade escolhida }

    tempoLimDaJogada: TDateTime;   { Conversão de duracao máxima para TDateTime }
    inicioDaJogada: TDateTime;     { TDateTime do início da palavra atual }
    tempoDaJogada:  TDateTime;     { Tempo de duração da palavra atual }
    tempoEsgotado:   boolean;      { tempoDaJogada > tempoLimDaJogada }

    quantasAchadas : integer;
    listaDeAchadas : array of shortstring;

    palavraSorteada: string;       { palavra escolhida como raiz de cada partida }
    letrasDisponiveis: string;     { letras que pode usar a cada momento }
    tentativa        : string;     { recebe a palavra durante a digitação }

    nomeArqScores:  string;
    scores : array [1..10] of TScore;
    nScores: integer;
    marcacao: integer;
    pontuacaoTotal: integer;
    pontuacaoExtra: integer;

    winRect:  TRect;
    ambiente: string;

implementation

end.

