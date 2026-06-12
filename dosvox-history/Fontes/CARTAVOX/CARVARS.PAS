{-------------------------------------------------------------}
{
{           cartaVox - variáveis globais
{
{-------------------------------------------------------------}

unit carvars;

interface

uses
    classes;

const
    VERSAO = '6.3';
    BUFSIZE = 16384; //4096;                    { tamanho do buffer de rede }
    CRLF: string = #$0d + #$0a;                 { fim de linha }
    MAXCARTAS = 60000;
    BRANCOS = '                                                                                 ';

type
    PNOMARQ = ^NOMARQ;
    NOMARQ = string;


    PCarta = ^TCarta;
    PParte = ^TParte;
    PEstrutura = ^TEstrutura;

    TCarta = record
        preenchido: boolean;
        nomArqCarta: string;           { nome do arquivo da carta }
        nomArqCartaEnviar: string;     { nome do arquivo da carta preparada para envio}
        fileName: string;              { nome do arquivo do conteudo da carta }
        datahora: longint;
        aux: string;
        auxLongInt: longInt;
        mime_version: string;          { se a carta for mime guarda a versão }
        date: string;
        subject: string;
        from: string;
        to_: string;
        cc: string;
        bcc: string;
        delivered_to: string;
        reply_to: string;
        tamanho: longint;
        references_: string;
        in_reply_to_: string;
        message_id: string;
        disposition_notification_to: string;

        partesCarta: TList;
    end;

    TParte = record
        filename: string;
        content_description: string;
        content_ID: string;

        subCarta: PEstrutura;
    end;

    TEstrutura = record
        numero: string;
        linhaInicialCab: integer;  { Linha inicial do cabeçalho }
        linhaInicial: integer;
        linhaFinal: integer;
        selecionado: boolean;      { Usado para selecionar a carta }
        posServ: integer; {Usado para guardar a posição da carta no servidor}
        removido: boolean;         { Usado para marcar as partes removidas }
        boundary: string;          { fronteira, separador das partes }
        contemAnexos: boolean; //true se existir mais de uma parte na carta
        charset: string;
        content_disposition: string;
        content_transfer_encoding: string;
        content_type: string;
        type_: string;

        parte: PParte;
        carta: PCarta;
        ptPai: PEstrutura;
    end;


    pListaCC = ^listaCC;
    listaCC = record
        nome: string[80];
        prox: pListaCC;
    end;

var
    cartavoxConfigs: string;                    { Nome do arquivo de config }
    nomeConfiguracao: shortstring;              { Nome da configuração ativa}
    sockSMTP, sockPOP3: integer;                { descritor dos soquetes }
    hostSMTP, hostPOP3, hostIMAP: shortstring;  { nome dos hosts }
    portaSMTP, portaPOP3, portaImap: integer;   { portas dos servidores }
    esperaPOP3, quantasReceber: integer;        {Tempo entre fechar e abrir, de quanto em quanto receber}
    esperaSMTP, quantasEnviar: integer;         {Tempo entre fechar e abrir, de quanto em quanto einviar}
    dirRecebe, dirEnvia: shortstring;           { diretorios de envio e recepcao }
    nomeUsuario: shortstring;                   { nome do usuário }
    enderResposta: shortstring;                 { endereço eletrônico para resposta}
    enderUsuario: shortstring;                  { endereço eletrônico do usuário }
    contaUsuario: shortstring;                  { nome da conta do usuário }
    meuNome: array [0..100] of char;            { título desta janela }
    nbaseRecebe, nbaseEnvia: longint;           { numero base das cartas recebidas e enviadas }
    nbaseCopia: longint;                        { numero base das copias das cartas enviadas }
    computLocal: string;                        { nome do computador local }
    smtpComSenha: boolean;                      { servidor smtp exige senha }
    smtpComSSL: boolean;                        { servidor smtp utiliza SSL}
    smtpComTLS: boolean;                        { servidor smtp utiliza TLS }
    perguntaAoSair,                             {Pergunta se sai do Cartavox}
    perguntaAoSairFolhe: boolean;               { pergunta se sai do folheamento}
    perguntarCriarRespostaAutomatica: boolean;  {Perguntar se cria resposta automática}

    bufRecebe: array [0..BUFSIZE] of char;      { buffer de recepcao de mensagens }
    bufEnvia:  array [0..BUFSIZE] of char;      { buffer de envio de mensagens }
    primeiraCartaPop3: integer;                 { número da primeira carta a buscar}
    numCartasPOP3: integer;                     { número de cartas a buscar e tamanho }
    numBytesPOP3: int64;                      { tamanho em bytes }
    interativoPOP3: boolean;                    { traz cartas perguntando antes }

    arqOrig, arqEnv: text;                      { arquivos de leitura e envio }
    arqBin: file;                               { arquivo binario }
    nomeArqApelidos: shortstring;               { nome do arquivo de apelidos }
    dirAnexo: shortstring;                      { Nome do diretório para gravar os anexos}
    dirLixeira: shortstring;                    { Nome do diretório da lixeira}
    dirSpam: shortstring;                    { Nome do diretório de cartas  Spam}
    antigoNomeArq: boolean;                     { Nome do arquivo da carta apenas um inteiro}
    ordenarDataEnvio: boolean;                  { Ordena pela data de envio}
    ordemInversa: boolean;                      {Ordem inversa das cartas no folheamento}
    maxTamAuto: longint;                        { tamanho maximo para trazer automaticamente }
    nomeAssinatura: shortstring;                { nome do arquivo de assinatura }
    guardaEnviadas: boolean;                    { guarda cartas após transmiti-las }
    guardaSenha: boolean;                       { guarda a senha}
    adicionaOriginal: boolean;                  { Gravar o texto como original}
    opcoesBasicas: boolean;                      { Ativa somente as opções básicas do Cartavox}
    bipaNoSpeaker: boolean;                     { Sonoriza no speaker na recepção e transmissão}
    clek: boolean; {Sonoriza na recepção e transmissão}

    debug: boolean;                             { se depurando... }

    numRegs: integer;                           { registros do folheamento }
    regLido: array [1..MAXCARTAS] of PEstrutura;
    pCC, pBCC: pListaCC;                        { listas de copias carbono }

    narqMime: integer;                          { número de arquivos Mime a enviar }
    tabArqMime: array [1..30] of PNOMARQ;       { nome desses arquivos }
    tipoConvMime: array [1..30] of char;        { tipo de conversao }

    npartesCarta: integer;                      { numero de partes MIME presentes }
    chaveMime: string;                          { chave básica para separacao de arquivos mime }
    listaDePartes: TList;                       { Lista das partes de uma carta para o folheamento.}
    senhaSalva: string;                         { Guarda a última senha digitada}

    aplicRegras: boolean;                       { Guarda se aplica regras ou não }
    inserirAssinatura : boolean;                { Guarda se assina a carta sem perguntar }
    inserirConfRec: boolean;                    { Guarda se insere confirmação de leitura automática }
    tempoRemonitorar: integer;                  { Guarda o tempo que vai remonitorar }
    avisaNovasMonitorar: boolean;               { Avisa se chegou carta nova no monitoramento }
    receberaAutMonitorar: boolean;              { Receber cartas automaticamente no monitoramento }

    tipoFolheGlobal: char;                      { Guarda o tipo de folheamento }
    folheiaTransmitidas,
    folheiaRecebidas,
    folheiaServidor: boolean;

    usaSSL: boolean;                            { POP3 utiliza SSL }
    IMAPUsaSSL: boolean;                        { IMAP utiliza SSL }
    sslAtivado: boolean;                        { SSL foi ativado }
    agruparPorAssunto: boolean;                 { agrupar por assunto }
    autoEnviaDuplicadasLixeira: boolean;        { auto Envia Duplicadas para Lixeira }
    matarSpamAutomaticamente: boolean;        {Passa o mata spam nas não lidas assim que receberr}
    cabecalhoResumido: boolean;
    falaNomePrimeiro: boolean;
    falaraposLeituraCarta: boolean;

    SOWindows: boolean;                         { rodando no ambiente Windows nativo }

    arqRespAut: string;                         { guarda o nome do arquivo que fica o texto da resposta automática }
    assRespAut: string;                         { guarda o assunto da resposta automática }
    sigRespAut: boolean;                        { guarda se a resposta automática tem assinatura ou não}
    grupoContas: boolean;                       { guarda se uma conta está ou não no grupo de contas}

implementation

end.
