unit ftpvars;

interface

{-------------------------------------------------------------}
{                     variaveis globais
{-------------------------------------------------------------}

const
    VERSAO = '2.3';
    TIPOVERSAO = '';

    CHEGOU_TECLA      = 0;              { indicadores de eventos }
    CHEGOU_REDE       = 1;
    CHEGOU_PEDCONEXAO = 2;
    CHEGOU_CANALARQ   = 3;

    BUFSIZE = 8192;                     { tamanho do buffer de rede }
    MAXLINHAS = 100;                    { maximo de linhas no buffer circular }

var
    sock, sockArq,
    sockCanal: integer;                 { descritores dos soquetes }
    processando: boolean;               { desligado quando se quer terminar }

    escutando,                          { executou "listen" para canal de dados }
    fimProg: boolean;                   { usuario pediu para terminar }
    canalAberto: boolean;               { canal de arquivos aberto }
    verboso: boolean;                   { verborragico ou nao }
    modoPassivo: boolean;               { abertura de comunicações sempre feita pelo cliente }

    nomeHost: string;                   { nome do host }
    enderHost: longint;                 { endereco IP do host }
    enderLocal: longint;                { nome deste host }
    buf: array [0..BUFSIZE-1] of char;  { buffer de recepcao de mensagens }
    porta, portaLocal: word;            { portas de comunicação }
    portaPassiva: word;                 { porta em modo passivo }

    conta, senha: string;               { conta e senha de acesso }

    nomeArqHost,                        { nomes dos arquivos envolvidos }
    nomeArqLocal: string;
    nomeArqDir: string;                 { arquivo temporario que recebe o diretorio }
    totalTransmitido: longint;          { numero de bytes transmitidos }

    arqLocal: file;                     { arquivo sendo enviado ou transmitido }

    bufLinhas: array [0..MAXLINHAS] of ^string;    { buffer circular de linhas }
    pins, pret: integer;
    linhaParcial: string;               { linha para montagem do buffer circular }

    debug: boolean;                     { em debug }

implementation
end.
