{Declaração das variáveis e constantes do FichaVox}

unit fvvars;

interface

{-------------------------------------------------------------}
{                     variaveis globais
{-------------------------------------------------------------}

const
    VERSAO= '1.5a';
    NUMMAXFICHAS= 15000;
    MSG_PROG = 'Programa FichaVox versão '+VERSAO+' - NCE/UFRJ';

    TITULO_FOLHEIA =
'NOME ---------------------------------------------------- Arquivo --- Seleção -';

type
    TFicha= record
                nomeArq: string;
                chave: string;
                original: integer;
                selecionado: boolean;
            end;

    Pficha= ^TFicha;

    TFichario = array [1..NUMMAXFICHAS] of PFicha;

var
    numFichas: integer;
    fichario : TFichario;
    arqFicha, arqIndice, newArq: text;
    caminho, nomeArqIndice, linha: string;
    newNomeArq: string;
    newChave: string;
    c, c2: char;
    achados: integer;
    posAtual, posFolheia: integer;
    opcBusc: char;
    nomeBusc: string;

    tipoOrdenacao: char;

implementation

end.
