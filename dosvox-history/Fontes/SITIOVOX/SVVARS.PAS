{-------------------------------------------------------------}
{                   sitiovox - variaveis globais
{-------------------------------------------------------------}

unit svvars;

interface
uses dvinet;

const
    VERSAO = '1.7';
    ALFABETA = '';
    PORTA_SITIOVOX = 1963;
    SERV_DEFAULT = 'caec.nce.ufrj.br';
    PORTA_NOMES = 1956;

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

const
    MAXMSG = 100;
    MAXCONEX = 50;

type
    PMensagem = ^TMensagem;
    TMensagem = record
        enviador, destino: string [12];
        mensagem: string [255];
    end;

    PConexao = ^TConexao;
    TConexao = record
        sock:        integer;            { soquetes de comunicação }
        horaInicio:  longint;
        meuBuf:      pBufRede;           { Buffer do soquete sock }
        nome:        string;             { nome fornecido }
        apelido:     string[12];         { apelido (12 letras) }
        ativo:       boolean;            { já forneceu todos os dados }
    end;

var
    servnomes: string;          { Nome do servidor}

    nomeSitio: string;          { nome fantasia do sítio }
    enderSitio: string;         { endereco eletronico do sitio }
    portaSitio: word;           { porta internet de acesso do sitio }

    sockEscuta:  integer;       { socket de espera }

    nusuarios: integer;                      { usuários conectados }
    conexao: array [1..MAXCONEX] of PConexao;

    ffila, rfila: integer;                   { fila de mensagens }
    filaEnviar: array [0..MAXMSG-1] of PMensagem;

    fazLog: boolean;             { se faz registro de mensagens }
    nomeArqLog: string;          { nome do arquivo de registro }
    arqLog: text;                { arquivo de registro }
    msgBoasVindas: string;       { mensagem de boas vindas }

    comCachorro: boolean;        { cachorrinho ativo }
    senhaObrigatoria: boolean;   { so' entra se tiver senha }

    nomeConf: string;            { nome do arquivo de configuração }
    senha: string;               { senha remota para operações privilegiadas }

    numDitados: integer;         { número de ditados }
    ditado: array [0..1000] of ^string;   { ditados }

implementation
end.
