{--------------------------------------------------------}
{
{    I Ching-VOX - Variáveis globais
{
{    Autor: José Antonio Borges
{
{    Em 24/06/97
{
{    Ajustes em 15/10/2021
{
{--------------------------------------------------------}

unit ichVars;
interface

const
    versao = '1.2';

{--------------------------------------------------------}
{                   nomes dos hexagramas
{--------------------------------------------------------}

const
    nomeHexagrama: array [1..64] of string[50] = (
         {1} 'CH''IEN / O CRIATIVO',
         {2} 'K''UN / O RECEPTIVO',
         {3} 'CHUN / DIFICULDADE INICIAL',
         {4} 'MENG / A INSENSATEZ JUVENIL',
         {5} 'HSU /A ESPERA (NUTRICAO)',
         {6} 'SUNG / CONFLITO',
         {7} 'SHIH / O EXÉRCITO',
         {8} 'PI / MANTER-SE UNIDO (SOLIDARIEDADE)',
         {9} 'HSIAO CH''U / O PODER DE DOMAR DO PEQUENO',
        {10} 'LU / A CONDUTA (TRILHAR)',
        {11} 'T''AI /PAZ',
        {12} 'PI / ESTAGNAÇÃO',
        {13} 'TUNG JEN / COMUNIDADE COM OS HOMENS',
        {14} 'TA YU / GRANDES POSSES',
        {15} 'CH''IEN / MODÉSTIA',
        {16} 'YU / ENTUSIASMO',
        {17} 'SUI / SEGUIR',
        {18} 'KU / TRABALHO SOBRE O QUE SE DETERIOROU',
        {19} 'LIN / APROXIMAÇÃO',
        {20} 'KUAN / CONTEMPLAÇÃO (A VISTA)',
        {21} 'SHIH HO / MORDER',
        {22} 'PI / GRACIOSIDADE (BELEZA)',
        {23} 'PO / DESINTEGRAÇÃO',
        {24} 'FU / RETORNO (O PONTO DE TRANSIÇÃO)',
        {25} 'WU WANG / INOCÊNCIA (O INESPERADO)',
        {26} 'TA CH''U / O PODER DE DOMAR DO GRANDE',
        {27} 'I / AS BORDAS DA BOCA (PROVER ALIMENTO)',
        {28} 'TA KUO / PREPONDERÂNCIA DO GRANDE',
        {29} 'K''AN / O ABISMAL (AGUA)',
        {30} 'LI / ADERIR (FOGO)',
        {31} 'HSIEN /A INFLUÊNCIA (CORTEJAR)',
        {32} 'HENG / DURAÇÃO',
        {33} 'TUN / A RETIRADA',
        {34} 'TA CHUANG /O PODER DO GRANDE',
        {35} 'CHIN /PROGRESSO',
        {36} 'MING I / OBSCURECIMENTO DA LUZ',
        {37} 'CHIA JEN / A FAMÍLIA',
        {38} 'K''UEI / OPOSIÇÃO',
        {39} 'CHIEN / OBSTRUÇÃO',
        {40} 'HSIEH / LIBERAÇÃO',
        {41} 'SUN / DIMINUIÇÃO',
        {42} 'I / AUMENTO',
        {43} 'KUAI/ IRROMPER (A DETERMINAÇÃO)',
        {44} 'KOU / VIR AO ENCONTRO',
        {45} 'TS''UI / REUNIÃO',
        {46} 'SHENG / ASCENSÃO',
        {47} 'K''UN / OPRESSÃO (A EXAUSTÃO)',
        {48} 'CHING / O POÇO',
        {49} 'KO / REVOLUÇÃO',
        {50} 'TING /O CALDEIRÃO',
        {51} 'CHEN / O INCITAR (COMOÇÃO, TROVÃO)',
        {52} 'KEN / A QUIETUDE (MONTANHA)',
        {53} 'CHIEN / DESENVOLVIMENTO (PROGRESSO GRADUAL)',
        {54} 'KUEI MEI / A JOVEM QUE SE CASA',
        {55} 'FENG / ABUNDANCIA (PLENITUDE)',
        {56} 'LU /O VIAJANTE',
        {57} 'SUN / A SUAVIDADE (O PENETRANTE, VENTO)',
        {58} 'TUI /ALEGRIA (LAGO)',
        {59} 'HUAN / DISPERSAO (DISSOLUÇÃO)',
        {60} 'CHIEH / LIMITAÇÃO',
        {61} 'CHUNG FU / VERDADE INTERIOR',
        {62} 'HSIAO KUO / A PREPONDERÂNCIA DO PEQUENO',
        {63} 'CHI CHI / APÓS A CONCLUSÃO',
        {64} 'WEI CHI / ANTES DA CONCLUSÃO'
    );

{--------------------------------------------------------}
{                 nome dos personagens
{--------------------------------------------------------}

const
    nomePers: array [0..7] of string [50] = (
        '(CH''IEN, O CRIATIVO,  CEU)',
        '(K''UN,   O RECEPTIVO, TERRA)',
        '(CHEN,    O INCITAR,   TROVÃO)',
        '(K''AN,   O ABISMAL,   AGUA)',
        '(KEN,     A QUIETUDE,  MONTANHA)',
        '(SUN,     A SUAVIDADE, VENTO ou MADEIRA)',
        '(LI,      O ADERIR,    FOGO)',
        '(TUI,     A ALEGRIA,   LAGO)'
    );

{--------------------------------------------------------}
{            constantes e variaveis gerais
{--------------------------------------------------------}

const
    simbologia: array [6..9] of char = ('Q', 'C', 'Q', 'C');

    desenho: array [6..9] of string [8] = (
        '---  ---',
        '--------',
        '---  ---',
        '--------' );

    tabHexagramas: array [0..63] of byte =
        ( 1,11,34, 5,26, 9,14,43,
         12, 2,16, 8,23,20,35,45,
         25,24,51, 3,27,42,21,17,
          6, 7,40,29, 4,59,64,47,
         33,15,62,39,52,53,56,31,
         44,46,32,48,18,57,50,28,
         13,36,55,63,22,37,30,49,
         10,19,54,60,41,61,38,58);

const
    ordinal: array [1..6] of string[8] = (
        'primeira', 'segunda', 'terceira', 'quarta', 'quinta', 'sexta'
    );

    tabOrdem: array [1..6] of string [8] = (
            'ICPRIMEI', 'ICSEGUND', 'ICTERCEI',
            'ICQUARTA', 'ICQUINTA', 'ICSEXTA' );

type str3 = string[3];

type
    LINHAS = array [1..6] of integer;

var
    pergunta: string;                         { pergunta }

    nMoedas: integer;                         { numero de moedas jogadas }
    regMoedas: array [1..18] of integer;      { e seus valores }

    linDiag, linProg: LINHAS;                 { valores das linhas }

    codBaixoDiag, codCimaDiag,                { codificacao do trigrama }
    codBaixoProg, codCimaProg: str3;

    indBaixoDiag, indCimaDiag,                { indices dos trigramas }
    indBaixoProg, indCimaProg: integer;

    hexaProg, hexaDiag: byte;                 { numeros dos hexagramas }

    tipoMutacao: (MUTACAO_USUAL, MUTACAO_TOTAL, MUTACAO_FIXA);

    nomeHexaProg, nomeHexaDiag: string[50];   { numeros dos hexagramas }

    nomeLeitor: string[8];                    { nome do programa leitor }

    arq: text;                                { arquivo de gravacao }

    dirTextos: string;                        { diretorio dos textos }

    outraConsulta: boolean;                   { mais uma consulta... }

implementation
end.