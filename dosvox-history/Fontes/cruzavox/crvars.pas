{--------------------------------------------------------}
{                                                        }
{    Programa de palavras cruzadas                       }
{                                                        }
{    Módulo de variáveis                                 }
{                                                        }
{    Autores: José Antonio Borges                        }
{             Jorge Carlos dos Santos                    }
{                                                        }
{    Em agosto/2010                                      }
{                                                        }
{--------------------------------------------------------}

unit crvars;

interface
uses classes;

const
    versao = '1.0';
    MAXDIM = 15;

type
    TDirecao = (HORIZ, VERT, INDEFINIDA);

    TModelo = array [1..MAXDIM] of string;

var
    modelo,                      // tabuleiro durante a edição
    tabuleiro: TModelo;          // tabuleiro durante o jogo
    nx, ny: integer;             // tamanho do tabuleiro
    legendasHoriz,               // strings das legendas para cada posição do modelo
    legendasVert:  array [1..MAXDIM, 1..MAXDIM] of string;

    listaDirJogos: TStringList;
    dirBaseJogos: string;
    dirAtual, nomeArq: string;

    titulo, tema, autor, dataCriacao: shortstring;    // informações gerais sobre o jogo
    comentario, jogador, data: string;
    tempo: integer;
    xatu, yatu: integer;
    numDicas: integer;

    horaInicial: TDateTime;

    alterou: boolean;		 // durante a edição algo foi alterado

implementation

end.
