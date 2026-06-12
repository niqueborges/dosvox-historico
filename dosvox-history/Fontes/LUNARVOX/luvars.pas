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

unit luvars;

interface

const
    G         = 6.67e-11;    // constante gravitacional.
    massaLua  = 1e23;        // massa da lua.
    raioLua   = 1738e3;      // raio da lua

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
    gravidadeLua : real;   // gravidade da Lua

    velocFinal : real;     // velocidade final.
    velocInicial : real;   // velocidade inicial.
    vTemp : real;          // armazena uma velocidade temporária.
    y : real;              // posicao final.
    y0 : real;             // posicao inicial.
    yTemp : real;          // armazena uma altura temporária.
    sTot : real;           // altura acumulada
    intervalo: real;       // intervalo de tempo em segundos entre cada
                           // interacao com o usuario.
    marcacaoBasica: integer;   // distância entre bips

    t : real;       // tempo final.
    t0 : integer;       // tempo inicial.
    comb : integer;     // combustível no tanque
    combTemp : integer; // armazena o combustível temporário.

    foraOrb : boolean;     // diz se a nave saiu de órbita.
    combAplicar : integer; // combustível a aplicar

    nivel : integer;   // variavel usada na escolha das opcoes.
    d : string;        // recebe a dificuldade escolhida.

    contador: integer;

    alturaInicial    : integer;    // posicao inicial.
    combInicial      : integer;    // combustível inicial.
    maxCombAplicar   : integer;    // máximo de combustível a aplicar por rodada.
    velocAterrisagem : integer;    // velocidade maxima de aterrisagem.

    dificuldade      : textfile;
    lido             : string;
    c                : char;

    scores : array [1..10] of TScore;
    nScores: integer;
    scoreTemp: integer;
    marcacao: integer;
    comIntuicao: boolean;

implementation

end.
