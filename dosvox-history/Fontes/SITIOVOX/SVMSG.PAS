{--------------------------------------------------------}
{                  sitiovox - mensagens
{--------------------------------------------------------}

unit svMsg;
interface
uses dvCrt, dvWin, winprocs, wintypes;

procedure mensagem (nomeArq: string; nlf: integer);
procedure bipSpeaker (pitch: integer);

const
    MSGDIGAPELIDO = 'Digite seu apelido até 12 letras';
    MSGAPELIDOINV = 'Apelido inválido';
    MSGAPELIDODUPLIC = 'Apelido não foi aceito pois outro usuário já o utiliza';
    MSGSENHAINCORRETA = 'Senha incorreta';
    MSGDIGEMAIL = 'Digite seu e-mail';
    MSGENTRA = 'Entrando na conversação';
    MSGCAIU = 'Usuário caiu: ';
    MSGUSUINEX = ' - Usuário destino inexistente';
    MSGATIVOS = 'Pessoas ativas neste sítio: ';
    MSGAJUDA = 'Iniciando bate-papo.  Tecle ? para dicas.';
    MSGINVALIDA = 'Esta operação não é suportada neste sítio';
    MSGEXCEDIDO =  '-ERRO Excedido número de conexões';
    MSGSAINDO = '*** Sítio saindo do ar por um instante ***';
    MSGNAOPODE = 'Você não pode fazer isso assim !';
    MSGOK = 'Operação realizada';

    DICA1 = 'Tecle normalmente termine suas frases com enter.';
    DICA2 = 'Essas frases são enviadas para todos do bate-papo.';
    DICA3 = 'Se quiser saber quem são os usuários tecle ?quem';
    DICA4 = 'Se quiser saber quantos são os usuários tecle ?quantos';
    DICA5 = 'Para mandar uma mensagem privativa tecle + seguido do apelido e a mensagem';
    DICA6 = 'Para sair do bate-papo tecle ESC.';

implementation

{--------------------------------------------------------}
{                     mensagens
{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;
begin
    if nomeArq = 'SVINIC' then
        s := 'Sítiovox - v'
    else
    if nomeArq = 'SVWSOCK' then
        s := 'Acesso a Internet não habilitado'
    else
    if nomeArq = 'SVCNFFIM' then
        s := 'Confirma fim ? '
    else
    if nomeArq = 'SVCNFNAO' then
        s := 'Arquivo de configuração não existe'
    else
    if nomeArq = 'SVVOUCRI' then
        s := 'Vou criar o arquivo '
    else
    if nomeArq = 'SVPODSER' then
        s := 'Pode ser ? '
    else
    if nomeArq = 'SVNAOCRI' then
        s := 'Não consegui criar o arquivo de configuração'
    else
    if nomeArq = 'SVPEDNOM' then
        s := 'Informe o nome-fantasia deste sítio, por exemplo, Sítio Cantinho da Mamãe'
    else
    if nomeArq = 'SVPEDEND' then
        s := 'Informe o endereço deste sitio, por exemplo, sitio.fulano@servidor.com.br'
    else
    if nomeArq = 'SVMSGINI' then
        s := 'Qual a mensagem de boas vindas a dar aos usuários ?'
    else
    if nomeArq = 'SVNOMLOG' then
        s := 'Nome do arquivo de registro da conversação ou enter se não quer'
    else
    if nomeArq = 'SVLOGNAO' then
        s := 'Erro na criação do arquivo de registro da conversação'
    else
    if nomeArq = 'SVPROCAN' then
        s := 'Servidor cancelado'
    else
    if nomeArq = 'SVERCON' then
        s := 'Não consegui realizar a conexão'
    else
    if nomeArq = 'SVLOGOFF' then
        s := 'Registrando fim do servidor'
    else
    if nomeArq = 'SVDESREG' then
        s := 'Servidor desconheceu registro'
    else
    if nomeArq = 'SVNAOCON' then
        s := 'Não consegui registrar saida'
    else
    if nomeArq = 'SVLOGON' then
        s := 'Registrando início do servidor'
    else
    if nomeArq = 'SVREGOK' then
        s := 'Registro ok'
    else
    if nomeArq = 'SVERRSRV' then
        s := 'Não consegui acionar servidor de nomes'
    else
    if nomeArq = 'SVAPTESC' then
        s := 'Aperte ESC para terminar'
    else
    if nomeArq = 'SVFIM' then
        s := 'Fim do servidor Sitiovox'
    else
    if nomeArq = 'SVSVATIV' then
        s := 'Servidor ativo, aceitando conexões'
    else
    if nomeArq = 'SVPORDES' then
        s := 'Porta de escuta desabilitada ou já usada'
    else
    if nomeArq = 'SVINFSEN' then
        s := 'Informe a senha do sítio'
    else
    if nomeArq = 'SVREINIC' then
        s := 'Reiniciando o sítio'
    else
    if nomeArq = 'SVCNFREI' then
        s := 'Confirma reinício do sítio ? '
    else
    if nomeArq = 'SVNUMCNC' then
        s := 'Número da sessão a cancelar  '
    else
    if nomeArq = 'SVOPCOES' then
        s := 'Opções: Q-mostra usuários  C-cancela usuário  r-reinicia sítio  ESC-fim'
    else
    if nomeArq = 'SVOVFLOW' then
        s := 'Estouro na fila de mensagens'
    else
    if nomeArq = 'SVNINGUE' then
        s := 'Ninguém ativo'
    else
    if nomeArq = 'SVLISUSU' then
        s := 'Lista de usuários ativos'
    else
    if nomeArq = 'SVENDIP' then
        s := 'O endereço IP deste sítio é '
    else
        s := '--> Mensagem inválida: ' + nomeArq;

    write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}
{                    bipa no speaker
{--------------------------------------------------------}

procedure bipSpeaker (pitch: integer);
begin
    SpeakerSound (pitch);
    delay (50);
    SpeakerNoSound;
end;

end.
