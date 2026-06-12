{-------------------------------------------------------------}
{
{    Webvox - Módulo de mensagens
{
{    Autor: Jose' Antonio Borges
{
{    Em 14/05/98
{
{-------------------------------------------------------------}

unit mwMsg;

interface
uses dvcrt, dvwin;

procedure mensagem (nomeArq: string; nlf: integer);
procedure erroBrutal (s: string);

const
    SERVER_NAME = 'Server: DOSVOX/miniweb (1.1)';

    MSG_OCUPADO = '<html><h3>Este servidor está sobrecarregado, tente mais tarde</h3></html>';
    MSG_LISTDIR = 'Listagem do diretório';
    CRLF = #$0d + #$0a;

implementation

{-------------------------------------------------------------}
{                          dá uma mensagem
{-------------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;
begin
    if nomeArq = 'MWINIC' then
        s := 'Mini servidor WEB - versão '
    else
    if nomeArq = 'MWDIRNAO' then
        s := 'Diretório para publicar não existe'
    else
    if nomeArq = 'MWPFCONF' then
        s := 'Por favor, configure este servidor.'
    else
    if nomeArq = 'MWDESCNF' then
        s := 'Deseja configurar o servidor ? '
    else
    if nomeArq = 'MWENTACE' then
        s := 'Nas perguntas a seguir aperte ENTER se ok, ou responda novo valor.'
    else
    if nomeArq = 'MWPRGCAN' then
        s := 'Programa cancelado'
    else
    if nomeArq = 'MWCNFSER' then
        s := 'Configurando'
    else
    if nomeArq = 'MWINFDIR' then
        s := 'Informe o diretório para publicar, atualmente'
    else
    if nomeArq = 'MWINFNCN' then
        s := 'Número máximo de clientes a servir, atualmente '
    else
    if nomeArq = 'MWINFPOR' then
        s := 'Informe a porta do servidor (sugiro 80), atualmente '
    else
    if nomeArq = 'MWINFNOM' then
        s := 'Informe seu nome, atualmente'
    else
    if nomeArq = 'MWINFCOR' then
        s := 'Informe o servidor de correio, atualmente'
    else
    if nomeArq = 'MWINFEMA' then
        s := 'Informe sua conta de email, atualmente'
    else
    if nomeArq = 'MWUSASEN' then
        s := 'Seu correio usa senha para envio ? '
    else
    if nomeArq = 'MWDESAVI' then
        s := 'Deseja avisar à comunidade Internet que você está ativo ? '
    else
    if nomeArq = 'MWSERVPR' then
        s := 'Informe o servidor de presença.'
    else
    if nomeArq = 'MWSEPVIR' then
        s := 'Use uma vírgula para separar se quiser mais de um servidor.'
    else
    if nomeArq = 'MWATUALS' then
        s := 'Os servidores atualmente configurados são'
    else
    if nomeArq = 'MWAVICOR' then
        s := 'Deseja avisar por correio eletrônico que este servidor está ativo? '
    else
    if nomeArq = 'MWARQAVI' then
        s := 'Informe o nome do arquivo contendo os e-mails das pessoas a avisar'
    else
    if nomeArq = 'MWDESREG' then
        s := 'Deseja registrar os acessos aos seus arquivos ? '
    else
    if nomeArq = 'MWINFLOG' then
        s := 'Informe o nome desse arquivo de registro, atualmente'
    else
    if nomeArq = 'MWFIMCNF' then
        s := 'Fim da configuração'
    else
    if nomeArq = 'MWINFSEN' then
        s := 'Informe sua senha de correio no servidor '
    else
    if nomeArq = 'MWINFSMW' then
        s := 'Informe a senha Miniweb para sua segurança'
    else
    if nomeArq = 'MWERRLOG' then
        s := 'Erro ao gerar arquivo de registro'
    else
    if nomeArq = 'MWFIMSRV' then
        s := 'Fim do servidor Miniweb'
    else
    if nomeArq = 'MWF1' then
        s := 'As opções do programa são'
    else
    if nomeArq = 'MWF4' then
        s := 'F4 para configurar'
    else
    if nomeArq = 'MWF5' then
        s := 'F5 para saber quantas conexões ativas'
    else
    if nomeArq = 'MWF6' then
        s := 'F6 para saber endereço IP'
    else
    if nomeArq = 'MWESC' then
        s := 'ESC para sair'
    else
    if nomeArq = 'MWPARALI' then
        s := 'Servidor foi paralisado para reconfigurar'
    else
    if nomeArq = 'MWNCLI' then
        s := 'Número de clientes ativos: '
    else
    if nomeArq = 'MWENDIP' then
        s := 'Meu endereço IP é '
    else
    if nomeArq = 'MWCNFFIM' then
        s := 'Confirma fim? '
    else
    if nomeArq = 'MWPORTA' then
        s := ' porta '
    else
    if nomeArq = 'MWERRCOR' then
        s := 'Não consegui enviar todos os proclamas pelo correio'
    else
    if nomeArq = 'MWPROCLA' then
        s := 'Proclamas foram enviados pelo correio'
    else
    if nomeArq = 'MWPARNAO' then
        s := 'Arquivo contendo os endereços dos parceiros não foi achado'
    else
    if nomeArq = 'MWERRUDP' then
        s := 'Erro ao informar dados ao servidor de presença'
    else
    if nomeArq = 'MWPROBCO' then
        s := 'Erro no sistema de correio'

    else
    if nomeArq = 'MWPREFOR' then
        s := 'Preencha o formulário de configuração.  Ao final tecle ESC.'
    else
        s := '--> Mensagem inválida: ' + nomeArq;

    write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom (nomeArq) then
        sintSom (nomeArq)
    else
        sintetiza (s);
end;

{-------------------------------------------------------------}
{                   Erro de alocação de memória
{-------------------------------------------------------------}

procedure erroBrutal (s: string);
begin
    writeln ('******** Erro brutal executando ' + s);
end;

end.
