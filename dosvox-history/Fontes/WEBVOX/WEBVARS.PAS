{-------------------------------------------------------------}
{
{    Webvox - Variáveis globais
{
{    Autor: Jose' Antonio Borges
{
{    Em 14/05/98
{
{-------------------------------------------------------------}

unit webvars;

interface

uses classes;

{-------------------------------------------------------------}
{                     variaveis globais
{-------------------------------------------------------------}

const
    MAXVETBYTE = 206000;

type
    PVETBYTE = ^VETBYTE;
//Neno28/01/2025   VETBYTE = array [0..MAXVETBYTE] of byte;
    VETBYTE = packed array [0..MAXVETBYTE] of byte;

const
    VERSAO = '6.1b';
    ALFABETA = '';

    PROXY_NCE = '192.0.0.1';                    { proxy }
    PORTAPROXY_NCE = 80;

    MAXPILHA = 40;                              { máximo de páginas a voltar }
    MAXLINCABHTTP = 300;                        { maximo de linhas do cabecalho HTTP }
    MAXBOOKMARK = 5000;                         { máximo de páginas selecionadas }
    BUFSIZE = 4096;                             { tamanho do buffer de rede }
    CRLF: string = #$0d+#$0a;                   { fim de linha }

    booleanToStr: array[boolean] of string = ( 'NAO', 'SIM' );

type
    pstring = ^shortstring;

    PPagLida = ^TPagLida;

    TCookie = record
        comentario: string;
        dominio: string;
        path: string;
        tempo: string;
        versao: string;
        seguranca: string;
        nome: string;
    end;

    TPagLida = record
         nomePagina: string;             { nome desta pagina }
         nomeArqTemp: string[80];        { nome do arquivo temporario }
         podeApagarTemp: boolean;        { temporario pode ser apagado depois de lido }
         posicao: integer;               { posicao em que a leitura foi interrompida }
         posFormPreenc: integer;         { indice do registro de formularios preenchidos }
         jaCompilado: boolean;           { ja tinha sido compilado }
         contType: string[80];           { tipo do envio de formulário }
         charSet: string[20];            { charset usado na página }
         tituloPagPilha: string[80];     { título da página }
         usaSSLPilha: boolean;           { utiliza SSL na leitura }
    end;

    PSomTag = ^TSomTag;
    TSomTag = record
        nomeTag: string [10];
        somTag:  string [40];
    end;

    pTags = ^vetTags;
    vetTags = array of string;

var
    ArquivoDeCookies: TStrings;
    arqCookie: string;

    debug: boolean;                             { em modo debug }

    sockHTTP: integer;                          { descritor dos soquetes }
    hostProxy: string;                          { nome dos hosts }
    hostHTTP: string;
    portaProxy: integer;                        { portas dos servidores }
    portaHTTP: integer;
    portaLocalFTP: integer;
    comProxy: boolean;
    arqExcProxy: string;                        { arquivo de excessões ao uso de proxy }

    dirRecebe: string;                          { diretorios de envio e recepcao }
    computLocal: string;                        { nome do computador local }

    pegandoTitulo: boolean;
    tituloJan: string;                          { título desta janela }

    topoPilhaPag: integer;
    pilhaPag: array [1..MAXPILHA] of PPagLida;  { pilha de últimas paginas }

    bufEnvia:  array [0..BUFSIZE-1] of char;        { buffer de envio de mensagens }
    bufRecebe: array [0..BUFSIZE-1] of char;        { buffer de recepcao de mensagens }
    lidosBufRecebe: integer;                    { lidos no buffer de recepção }
    posBufRecebe: integer;                      { posição processada no buffer de recepção }

    nomeTemp: string;                           { nome do arquivo temporario corrente }
    nomePagAtual: string;                       { nome desta pagina }
    nomeBase: string;                           { nome base para URLs relativas }
    linhaAtual: longint;                        { posição atual de processamento da página }
    rotuloInicial: string;                      { rótulo de início de leitura }
    cookie: string;                             { cookie associado a esta página }

    processando: boolean;                       { programa ativo }
    submeteu: boolean;                          { apertou botao de submissao }
    modoFala: char;                             { modo de fala atual }

    nlinCabecHTTP: integer;                     { numero de linhas do cabec. HTTP }
    cabecHTTP: array [1..MAXLINCABHTTP] of string;

    ntags: integer;
    tagsPagina: pTags;                          { a pagina html descompilada }

    ntagsForms: integer;
    tagsForms: pTags;                           { os formularios preenchidos }
    formContentType: string;                    { tipo do formulário atual }
    dadosPost: PVETBYTE;                        { dados para envio via post }
    tamDadosPost: integer;
    chaveMime: string;                          { separador mime na transmissão }

    dirTags: string;
    tabSomTags: array [1..100] of PSomTag;
    nSomTags: integer;

    nBookMarks: integer;                        { bookmarks }
    bookMark: array [1..MAXBOOKMARK] of pstring;
    comentBmark: array [1..MAXBOOKMARK] of pstring;

    emPortug: boolean;                           { usa servidor DDE }
    falandoPontuacao: boolean;                   { fala a pontuação }

    ultMsgAutent: string;                        { mensagem de autenticação HTTP }
    ultAutent: string;                           { autenticação HTTP enviada }

    textoBuscado: string;                        { texto buscado }
    enviandoPaginaHtml: boolean;
    titCatal: string;                            { título do catálogo selecionado }
    nomeWebSelec: string;                        { nome do arquivo webselec }
    nomeWebCatal: string;                        { nome do arquivo webcatal }

    nomeArqDownload: string;                     { nome do arquivo em download }

    usaSapi: boolean;
    tipoSapi1, vozSapi1, velSapi1, tomSapi1: integer;
    tipoSapi2, vozSapi2, velSapi2, tomSapi2: integer;

    mudo: boolean;
    falarCarregamento: boolean;
    biparEmLinks : boolean;
    dirDownload: shortString;           {Diretório gravar downloads}

    paginaQueFoiAberta: string;
    charsetAtual: string[30];                     { charset da página lida }
    ultimoLinkLido: string;                       { último lido (para control-c }
    tipoCodificacao: string;                      { tipo de codificação da página }
    usaSSL: boolean;                              { comunicação com segurança }
    fecharPrograma: boolean;

implementation
end.
