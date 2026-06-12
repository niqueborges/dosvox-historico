{--------------------------------------------------------}
{
{    Variaveis globais do EDIVOX
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit edVars;

interface
uses Classes;

const
    VERSAO = '8.1b';
    ALFABETA = '';
    LETRAS_DE_PALAVRA: set of char =
        ['A'..'Z', 'Á', 'É', 'Í', 'Ó', 'Ú',
         'À', 'Ã', 'Ô', 'Â', 'Ê', 'Ü', 'Ç', 'Ñ', 'Õ', 'È', 'Î', 'Ö',
         'a'..'z', 'á', 'é', 'í', 'ó', 'ú',
         'à', 'ã', 'ô', 'â', 'ê', 'ü', 'ç', 'ñ', 'õ', 'è', 'î', 'ö',
         '-', ''''];

type
    Frase = string;
    TipoTexto = TStringList;
    TCodif = (C_ANSI, C_UTF8, C_UNICODE, C_UNICODE_BIG);

var
    Texto : TipoTexto;          { o texto em si }
    maxLinhas: integer;         { quantas linhas preenchidas }

    posx, posy: integer;         { posicao do cursor no texto }
    margesq, margdir: integer;   { margens }
    inibloco, fimbloco: integer; { posicao do bloco marcado }

    mudo,                        { totalmente calado }
    soletrando,                  { soletragem acionada }
    falandoPalavra,                  { falar palavra acionada }
    enterInsLinha,               { enter insere linha }
    quebraAuto,                  { quebra automatica ao fim da linha }
    falaPontuacao,               { fala pontuação }
    falaEspacos ,                { fala número de espaços na frente}
    rapidinho: boolean;          { fala sintetica rapida }
    autoFala: boolean;           { ao mudar de linha, fala }
    lendoMat: boolean;       {   Patrick. True caso sonoraMat esteja ativo   }
    extPadrao: string;           { extensão padrão do arquivo}

    nomeArq : string;            { nome do arquivo editado }
    buscado : string;            { texto em busca }
    linhaRemovida: string;       { ultima linha removida }
    statusTecControle: word;     { status das teclas shift, control, etc }

    deslocEsqTela: integer;      { deslocamento durante a escrita }
    tamMaxLinha: integer;        { tamanho da linha para certa resolucao }
    corLetra, corFundo: integer; { cores de tracado }

    salvaCurx,                   { posicao salva do cursor }
    salvaCury: integer;

    ntabs: integer;              { numero de tabulacoes marcadas }
    tabs: array [1..30] of integer; { tabulacoes }

    dirSomEdivox: string;        { diretorio de mensagens do Edivox }

    dicCarregado: boolean;       { dicionário está carregado }
    nomeArqDic,                  { arquivo do dicionário }
    nomeArqSufixos,              { sufixos }
    nomeArqInexist,              { palavras forçadas como erradas }
    nomeArqNomes,                { nomes próprios e siglas }
    nomeArqSugTroca: string;     { sugestões de troca }

    dicionarioAtivado: boolean;  { dicionario online ativado}
    corrigirTodoTexto: boolean;  {Corrige todo o texto no CTRL w}
    retomarNaLinha: boolean;
    iniMarca, fimMarca: integer; { trecho marcado na linha }
    somenteLeitura: boolean;     { já inicia lendo, nem pergunta se grava }
    perguntaAoSair: boolean;     {Pergunta se deseja sair do Edivox}
    sairMudo: boolean;     {Sair sem falar "Fim do Edivox"}
    informaCarga: boolean;       { informa ou não se arquivo carregado }
    veioDoDos: boolean;          { arquivo veio com opção /D }

    escreveApenasTexto: boolean;
    modoFalaFormatacao: char;
    comSapi: boolean;
    ansiUtfUnicode: TCodif;

    fatorAmpl: integer;          { fator de ampliação para baixa visão }

{--------------------------------------------------------}

const
    CONTROL = 4;

implementation
end.
