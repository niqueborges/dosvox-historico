{--------------------------------------------------------}
{                    módulo de variáveis
{--------------------------------------------------------}

unit brvars;
interface

const
    versao = '4.0';
    beta = false;

    SALTOPAG = #$0c;

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
                  'Ç', 'ç' ]; {cedilha}

    MAIUSCBRL     = ']';
    MAIUSCBRLU    = '{';
    MAIUSCINGLES  = '&';
    MAIUSCINGLESU = '\';
    GRIFOBRL      = '_';
    TRAVESSAOU    = '--';
    GRIFOBRU      = '_';
    GRIFOINGLES   = ']';
    ASPASVARIADASU = '$"';
    RETICENCIASU = '...';

    ABREASPASBRL  = '{';
    ABREASPASBRLU = '"';
    ABREASPASINU  = '"';
    FECHAASPASINU = '}';
    FECHAASPASBRL = '}';
    PONTOBRL      = '.';
    PONTOINU      = '/';
    RETICBRL      = '''''''';
    VIRGDECBRL    = ',';
    PONTODECBRL   = '''';

    PERCENTBRL    = '_}';
    PERCENROMILBRU = '_}}';
    PARAGRAFO     = 'ss';
    SINALNUMERO   = '#';

    BOLABRU       = 'õo';
    ASPASANGBRU   = '\"';
    BARRABRU      = '\,';
    EUROBRU       = '€e';

    ABREPARENTU   = '(.';
    FECHAPARENTU  = '\)';
    ABRECOLCHU    = '[.';
    FECHACOLCHU   = '\]';

    RAIZU         = '~' + '.';
    UMQUARTOU     = '#,d';
    UMMEIOU       = '#,b';
    TRESQUARTOSU  = '#:d';
    BETAU         = '¬b';

    ELEV_2_U      = 'å#b';
    ELEV_3_U      = 'å#c';
    ELEV_1_U      = 'å#a';

var
    arq: file;
    bufArq: array [0..1023] of char;
    pbufArq, lidosBuf: integer;
    fimDoArq: boolean;
    linhasDivididas: boolean;

    nomeArq, nomeSai: string;
    texto, textoCnv: string;

    emTinta: boolean;      { impressão braille em Tinta }
    maxcarac: integer;     { máximo de caracteres por liha }
    maxlin: integer;       { máximo de linhas na página }
    tipoCabec: integer;    { 0 = sem, 1 = frente, 2 = dois lados }
    autoFormata: boolean;  { auto formata juntando linhas }
    frenteVerso: boolean;  { impressão só de um lado do papel }
    veioDoEdit: boolean;   { texto codificado em PC-850 }
    afastaCabecPar: boolean;          { afasta cabecalhos pares }
    tiraBrancasInicioPag: boolean;    { remove linhas brancas no inicio da pagina }
    separaSilabas: boolean;           { separa silabas no fim da linha }

    titulo: shortstring;     { título a imprimir }
    comTitulo: boolean;      { deve colocar títulos e números }
    numeraOrig: boolean;     { adiciona no título número da página no original }
    numInic: integer;        { número a imprimir na primeira página }

    npag: integer;           { numero da pagina atual }
    nlin: integer;           { numero da linha atual }
    paginic: integer;        { primeira página a imprimir }
    pagfinal: integer;       { última página a imprimir }
    ncopias: integer;        { número de cópias desejado }

    centrando: boolean;      { está centrando agora }
    abre_aspas: boolean;     { abriu aspas }
    abre_aspas_inu: boolean; { abriu aspas: braille unificado }
    abriuParentLiterario: boolean;
                             { abriu parênteses literário }

    sobraAnterior: string;   { trecho que sobrou da última saída }
    pagOrig: integer;        { pagina do original }

    margem: integer;         { margem à esquerda }
    margemSoImpar: boolean;  { faz margem só nas paginas impares }
    textoIngles: boolean;    { usa alternativas de maiúsculas e sublinhado }
    cabecIngles: boolean;    { idem no cabecalho }
    linhaNoRascunho: integer;  { equivalencia original-rascunho }

    tempoLinha: integer;       { tempo fixado para impressão de uma linha }
    paginando: boolean;        { faz paginação }
    usaBrailleAntigo: boolean; { usa braille anterior a 2002 }

    tabPrinter: array [#0..#255] of byte;

    nomeAmBCode: string;     { arquivo de codificação do braille antigo }
    nomeAmbCode2: string;    { arquivo de codificação do braille novo }

    adev, adriv, aport: array [0..255] of char;
    adevMode: cardinal;                  { configurações da impressora PRN }

implementation
end.