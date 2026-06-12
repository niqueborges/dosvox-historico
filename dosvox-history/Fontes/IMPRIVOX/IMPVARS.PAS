{--------------------------------------------------------}
{
{    Programa de impressao do DOSVOX
{
{    Variaveis globais
{
{    Autor: Jose' Antonio Borges
{
{    Em marco/1996 - julho/2000
{
{--------------------------------------------------------}

unit impvars;
interface
uses DVcrt, DVWin, windows;

const
    versao = '2.7';
    debug = true;

    NORMAL = 0;
    NEGRITO = 1;
    ITALICO = 2;
    SUBLINHADO = 4;
    SUPERESCRITO = 8;
    SUBESCRITO = 16;
    RODAPE = 32;

    MAIUSCULAS: set of char = ['A'..'Z', #$c0..#$df];   { ANSI apenas }
    MINUSCULAS: set of char = ['a'..'z', #$e0..#$ff];

    VOGAIS     = ['A', 'E', 'I', 'O', 'U', 'a', 'e', 'i', 'o', 'u',
                  {aeiou agudos}
                  'Á', 'É', 'Í', 'Ó', 'Ú', 'á', 'é', 'í', 'ó', 'ú',
                  {aeo circunflexos}
                  'Â','Ê','Ô','â','ê','ô',
                  {ao til}
                  'Ã','Õ','ã','õ',
                  {a grave}
                  'À','à'];

    CONSOANTES = ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'L', 'M',
                  'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'X', 'Z',
                  'b', 'c', 'd', 'f', 'g',{'h',}'j', 'l', 'm',
                  'n', 'p', 'q', 'r', 's', 't', 'v', 'x', 'z',
                  'Ç', 'ç' ];

var
    nomeEntra, nomeSai: string;       { nomes dos arquivos }
    arqEntra  :  file;                { arquivo de entrada }
    arqDebug: text;                   { arquivo de saiva em texto puro }
    acabouArq: boolean;               { arquivo acabou de ser lido }

    primLinha, primCol: integer;      { primeira linha e coluna a imprimir }
    ultLinha, ultCol: integer;        { última linha e coluna a imprimir }
    primColCabec: integer;            { primeira coluna do cabeçalho }
    ultColCabec: integer;             { última coluna do cabeçalho }

    pagInicial, pagFinal: integer;    { página inicial e final a imprimir }
    numInicial: integer;              { número a imprimir na primeira página }
    espacejamento: integer;           { espacejamento (1, 2, 3) }
    autoFormata, alinhaDireita, separaSilabas: boolean;

    ncopias: integer;                 { número de cópias }
    titulando: boolean;               { foi especificado título }
    titulo: string;                   { título da página atual }

    DCimpr: hDC;                      { contexto do dispositivo da impressora}
    fonte: array [0..63] of hFont;    { fontes alocados até o momento }
    tamFonte: integer;                { tamanho do fonte em "pontos de fonte" }
    xfonte, yfonte: integer;          { tamanho do fonte normal em pixels }
    tamFonteRod: integer;             { tamanho do fonte em "pontos de fonte" }
    xfonteRod, yfonteRod: integer;    { tamanho do fonte rodapé em pixels }

    ximpr, yimpr: longint;            { posição atual de impressão }
    limyimpr: longint;                { limite inferior para impressão }
    x0pag, y0pag: longint;            { deslocamentos iniciais na página }
    deltay: longint;                  { intervalo entre linhas }
    deltayRod: longint;               { intervalo entre linhas no rodapé }
    deslocVert: integer;              { deslocamento quando subescrito ou superescrito }

    copiaAtual: integer;              { Número da cópia atual }
    desistiu: boolean;                { Usuário apertou ESC durante o processamento }

    numPag: integer;                  { número da página atual }
    nlinPag: integer;                 { número de linhas impressas na página }
    sobraLinha: string;               { sobra para próxima linha durante a formatação }
    brancosMargem: string;            { brancos da margem esquerda }

{--------------------------------------------------------}
{               variáveis do formatador
{--------------------------------------------------------}

const
    MAXRODAPE = 50;

type
    LETRALIDA = (ESPACO, CARACTERE, ABRECOMANDO, FIMLINHA, FIMARQ);
    COISALIDA = (BRANCOS, LETRAS, COMANDO, FIM);

type
    TAtribLinha = array [0..255] of word;

var
    jaLido: boolean;                     { deve reler última letra }
    ultLetra: char;                      { última letra lida }
    ultCodigo: LETRALIDA;                { último código processado }
    trecho: string;                      { trecho atual }
    tipoTrecho: COISALIDA;               { tipo deste trecho }

    linha, coluna: integer;              { número da linha e coluna atual }
    linhaSaida, resto: string;           { linha processada e a processar }
    atribSaida, atribResto: TAtribLinha; { atributos armazenados }
    tipoLetra: word;                     { tipo da letra atual }
    ultAtrib: word;                      { último atributo }

    processando: boolean;                { está formatando ainda }
    ultimoFoiNL: boolean;                { houve um salto de linha antes desta }
    linhaVazia: boolean;                 { linha de saída está vazia (embora com brancos iniciais) }
    centrando : boolean;                 { está centrando }
    impressaoPermitida: boolean;         { não está pulando páginas iniciais }

    emRodape: boolean;
    salvaPrimCol, salvaUltCol: integer;  { salva primeira e última coluna durante rodapé }
    salvaTipo: integer;                  { salva tipo da letra durante rodapé }

    primRodape, nlRodape: integer;       { filas de linhas e atributos do rodapé }
    txtRodape: array [0..MAXRODAPE-1] of ^string;
    atribRodape: array [0..MAXRODAPE-1] of ^TAtribLinha;

implementation
end.
