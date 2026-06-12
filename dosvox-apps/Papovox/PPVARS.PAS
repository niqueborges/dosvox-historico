{-------------------------------------------------------------}
{                   papovox - variaveis globais
{-------------------------------------------------------------}

unit ppvars;

interface
uses dvinet;

const
    VERSAO = '3.3C';
    ALFABETA = '';
    PORTA_PAPOVOX = 1963;
    PORTA_URGENTE = 1964;
    SERV_DEFAULT = 'caec.nce.ufrj.br';
    PORTA_NOMES = 1956;
    MAXFILAFALA = 20;

const
    DADOTECLADO     = 1;
    INICIOSOM       = 2;
    FIMSOM          = 3;
    DADOSOM         = 4;
    INICIOARQENVIA  = 5;
    FIMARQENVIA     = 6;
    DADOENVIA       = 7;
    CANCARQENVIA    = 8;
    PODEMANDAR      = 9;
    CANCELAMANDAR   = 10;

var
    sock: integer;            { soquete principal de comunicação }

    bufSock: pBufRede;        { Buffer do soquete sock }

    servnomes: shortString;        { Nome do servidor}
    nomeUsuario: shortString;      { nome do usuário }
    enderUsuario: shortString;     { endereço eletronico do usuario }
    selecionado: shortString;      { email selecionado }
    soletra: shortString; {Soletra a digitação}
    pontua: shortString; {Fala pontuação}
    acelerado: shortString;      {Modo acelerado na chegada das mensagens}
    dicion: shortString; {Carrega dicionário}
    entDir: shortString; {Conexão direta ao servidor}
    modoAcelerado: boolean;
    comDic: boolean;

    bufTec: string;
    maxTec: integer;          { numero máximo de teclagens }

    arqSom, arqRecebe, arqEnvia: file;
    bufSom: array [0..511] of byte;
    bufEnvia: array [0..511] of byte;
    tamSomEnviado: longint;

    ultMsgParceiro, ultMsgMinha: string;
    ultMsgUrgente: string;    { última mensagem urgente recebida }

    enviandoSom, enviouTodoSom: boolean;
    autorEnvioPendente, enviandoArq, recebendoArq: boolean;
    recebendoSom: boolean;
    conversando: boolean;
    soletrando: boolean;
    contaSpeaker: integer;
    anonimo: boolean;

    ffilaFala, rfilaFala: integer;
    filaFala: array [0..MAXFILAFALA-1] of string[255];

    nomeArqEfeitos, nomeArqComandos, nomeArqLog: string;
    nomeArqDic, nomeArqSufixos, nomeArqInexist, nomeArqNomes, nomeArqSugTroca: string;

    dirDosvox: string;

    nikPedeMic, ipPedeMic: string;
    conversaPorVoz: boolean;

implementation
end.
