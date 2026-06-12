{--------------------------------------------------------}
{                  papovox - mensagens
{--------------------------------------------------------}

unit ppMsg;
interface
uses dvCrt, dvWin, winprocs, wintypes;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure bipSpeaker (pitch: integer);

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    s := '';
    if nomeArq = 'PPINIC' then
        s := 'Papovox - v'
    else
    if nomeArq = 'PPOPCAO' then
        s := 'Qual sua opção: '
    else
    if nomeArq = 'PPCNFFIM' then
        s := 'Confirma fim ? '
    else
    if nomeArq = 'PPFIM' then
        s := 'Até a próxima'
    else
    if nomeArq = 'PPAPTF1' then
        s := 'Opção inválida, aperte F1 para ajuda'
    else
    if nomeArq = 'PPAJUD0' then
        s := 'As opções são as seguintes:'
    else
    if nomeArq = 'PPAJUD1' then
        s := 'P - pesquisa usuários no servidor de nomes'
    else
    if nomeArq = 'PPAJUD2' then
        s := 'C - configura o programa'
    else
    if nomeArq = 'PPAJUD3' then
        s := 'E - Espera que alguém inicie uma conexão com este programa'
    else
    if nomeArq = 'PPAJUD4' then
        s := 'L - Inicia uma ligação com outro usuário'
    else
    if nomeArq = 'PPAJUD5' then
        s := 'M - Envia mensagem urgente para outro usuário'
    else
    if nomeArq = 'PPAJUD6' then
        s := 'ESC - termina o programa'
    else
    if nomeArq = 'PPQUALIP' then
        s := 'Qual o endereço eletrônico a conectar ? '
    else
    if nomeArq = 'PPERCON' then
        s := 'Não consegui realizar a conexão'
    else
    if nomeArq = 'PPNAODSP' then
        s := 'Parceiro não disponível'
    else
    if nomeArq = 'PPRECUSA' then
        s := 'Parceiro recusou conexão, veja mensagem'
    else
    if nomeArq = 'PPWSOCK' then
        s := 'Acesso a Internet não habilitado'
    else
    if nomeArq = 'PPESPERA' then
        s := 'Esperando parceiro'
    else
    if nomeArq = 'PPESPLIG' then
        s := 'Tentando estabelecer ligação'
    else
    if nomeArq = 'PPCONPED' then
        s := 'Conexão pedida por '
    else
    if nomeArq = 'PPACEITA' then
        s := 'Aceita ? '
    else
    if nomeArq = 'PPCONREC' then
        s := 'Recusei a conexão'
    else
    if nomeArq = 'PPOTIMO' then
        s := 'Ótimo'
    else
    if nomeArq = 'PPESPCAN' then
        s := 'Espera cancelada'
    else
    if nomeArq = 'PPINIPAP' then
        s := 'Iniciando bate papo'
    else
    if nomeArq = 'PPFIMPAP' then
        s := 'Fim do bate papo'
    else
    if nomeArq = 'PPESCTRM' then
        s := 'Tecle ESC para desligar, F1 para ajuda'
    else
    if nomeArq = 'PPLOGON' then
        s := 'Registrando presença no servidor de nomes'
    else
    if nomeArq = 'PPLOGOFF' then
        s := 'Registrando saída'
    else
    if nomeArq = 'PPNAOCON'then
        s := 'Não consegui registrar conexão'
    else
    if nomeArq = 'PPXCADAS' then
        s := 'Execute cadastro'
    else
    if nomeArq = 'PPREGOK' then
        s := 'Presença registrada'
    else
    if nomeArq = 'PPPEGAIP' then
        s := 'Consultando servidor de nomes'
    else
    if nomeArq = 'PPNOMUSU' then
        s := 'Qual o seu nome ?'
    else
    if nomeArq = 'PPENDUSU' then
        s := 'Qual o seu endereço eletrônico ?'
    else
    if nomeArq = 'PPNCONH' then
        s := 'Servidor não conhece este usuário'
    else
    if nomeArq = 'PPPROVAV' then
        s := 'Parceiro provavelmente em '
    else
    if nomeArq = 'PPERRSRV' then
        s := 'Não consegui acionar servidor de nomes'
    else
    if nomeArq = 'PPVOCEST' then
        s := 'Seu IP é '
    else
    if nomeArq = 'PPERRGRV' then
        s := 'Erro no módulo de som, verifique espaço em disco'
    else
    if nomeArq = 'PPPODSER' then
        s := 'Pode ser ? '
    else
    if nomeArq = 'PPSERV' then
        s := 'Seu servidor está configurado como'
    else
    if nomeArq = 'PPSNOME' then
        s := 'Seu nome está configurado como'
    else
    if nomeArq = 'PPSEND' then
        s := 'Seu endereço eletrônico está configurado como'
    else
    if nomeArq = 'PPQNARQ' then
        s := 'Informe o nome do arquivo que contém suas informações (até 10 linhas)'
    else
    if nomeArq = 'PPCARNAO' then
        s := 'Arquivo não existe, cartão de visitas não será criado.'
    else
    if nomeArq = 'PPARQNAO' then
        s := 'Arquivo não existe'
    else
    if nomeArq = 'PPCNFREG' then
        s := 'Confirma registro ? '
    else
    if nomeArq = 'PPTIPPSQ' then
        s := 'Qual o tipo de pesquisa (F1 ajuda): '
    else
    if nomeArq = 'PPOPINEX' then
        s := 'Opção inexistente'
    else
    if nomeArq = 'PPINFEND' then
        s := 'Informe endereço eletrônico desejado'
    else
    if nomeArq = 'PPAJUPQ1' then
        s := 'As opções de pesquisa são:'
    else
    if nomeArq = 'PPAJUPQ2' then
        s := 'T - todos aqueles cadastrados'
    else
    if nomeArq = 'PPAJUPQ3' then
        s := 'A - apenas os ativos'
    else
    if nomeArq = 'PPAJUPQ4' then
        s := 'N - busca por nome'
    else
    if nomeArq = 'PPAJUPQ5' then
        s := 'C - cartões de visita'
    else
    if nomeArq = 'PPNAOLOG' then
        s := 'Não está logado no servidor'
    else
    if nomeArq = 'PPENDELE' then
        s := 'Correio eletrônico: '
    else
    if nomeArq = 'PPDATULT' then
        s := 'Última informação registrada: '
    else
    if nomeArq = 'PPAJSEL' then
        s := 'I-informações   ENTER-seleciona  ESC-termina'
    else
    if nomeArq = 'PPOPINV' then
        s := 'Opção inválida, F1 ajuda'
    else
    if nomeArq = 'PPULTNOM' then
        s := 'Este foi o último nome'
    else
    if nomeArq = 'PPPOSSO' then
        s := 'Posso chamar '
    else
    if nomeArq = 'PPCNTFOL' then
        s := 'Continue folheando ou tecle ESC'
    else
    if nomeArq = 'PPUSESET' then
        s := 'Folheando: use as setas, depois tecle sua opção'
    else
    if nomeArq = 'PPUSUSEL' then
        s := 'Usuário selecionado'
    else
    if nomeArq = 'PPINFPES' then
        s := 'Informações pessoais:'
    else
    if nomeArq = 'PPNENHUM' then
        s := 'Nenhuma informação registrada'
    else
    if nomeArq = 'PPNOMTRA' then
        s := 'Informe o nome do arquivo a transmitir ?'
    else
    if nomeArq = 'PPARQN' then
        s := 'Arquivo não existe'
    else
    if nomeArq = 'PPINITRA' then
        s := 'Iniciando transmissão do arquivo'
    else
    if nomeArq = 'PPBEMTRA' then
        s := 'Arquivo bem transmitido'
    else
    if nomeArq = 'PPPROTRA' then
        s := 'Problemas na transmissão do arquivo'
    else
    if nomeArq = 'PPTRACAN' then
        s := 'Transmissão de arquivo cancelada'
    else
    if nomeArq = 'PPNOMREC' then
        s := 'Qual o nome do arquivo a receber ?'
    else
    if nomeArq = 'PPNAOCRI' then
        s := 'Não consegui criar o arquivo'
    else
    if nomeArq = 'PPINIREC' then
        s := 'Iniciando recepção de arquivo'
    else
    if nomeArq = 'PPBEMREC' then
        s := 'Arquivo bem recebido'
    else
    if nomeArq = 'PPPROREC' then
        s := 'Problemas na recepção do arquivo'
    else
    if nomeArq = 'PPRECCAN' then
        s := 'Recepção de arquivo cancelada'
    else
    if nomeArq = 'PPQVELOC' then
        s := 'Qual a velocidade de fala, de 1 a 4 ? '
    else
    if nomeArq = 'PPSOLET' then
        s := 'Soletra digitação ? '
    else
    if nomeArq = 'PPPONTUA' then
        s := 'Fala pontuação? '
    else
    if nomeArq = 'PPACELER' then
        s := 'Modo acelerado ? '
    else
    if nomeArq = 'PPNAOPEN' then
        s := 'Não há ninguém querendo falar com você'
    else
    if nomeArq = 'PPHORA' then
        s := 'A hora atual é '
    else
    if nomeArq = 'PPHCONE' then
        s := 'Hora de conexão: '
    else
    if nomeArq = 'PPXMINUT' then
        s := ' minutos '
    else
    if nomeArq = 'PPXHORAS' then
        s := ' horas '
    else
    if nomeArq = 'PPAJUT0' then
        s := 'Os comandos são os seguintes'
    else
    if nomeArq = 'PPAJUT1' then
        s := 'F1 ajuda'
    else
    if nomeArq = 'PPAJUT2' then
        s := 'F2 transmite um arquivo'
    else
    if nomeArq = 'PPAJUT3' then
        s := 'F3 recebe um arquivo'
    else
    if nomeArq = 'PPAJUT4' then
        s := 'F4 altera fala'
    else
    if nomeArq = 'PPAJUT5' then
        s := 'F5 envia mensagem urgente para outro usuário'
    else
    if nomeArq = 'PPAJUT6' then
        s := 'F6 informa ip desta conexão'
    else
    if nomeArq = 'PPAJUT7' then
        s := 'F7 repete fala'
    else
    if nomeArq = 'PPAJUT8' then
        s := 'F8 informa tempo de conexão'
    else
    if nomeArq = 'PPAJUT9' then
        s := 'F9 conhecer outras opções com as setas'
    else
    if nomeArq = 'PPAJUT10' then
        s:= 'CTRL+F3 grava conversação'
    else
    if nomeArq = 'PPAJUT11' then
        s:= 'CTRL+F4 inibe síntese'
    else
    if nomeArq = 'PPAJUT12' then
        s:= 'CTRL+F5 envia apenas para um parceiro'
    else
    if nomeArq = 'PPAJUT13' then
        s:= 'CTRL+F6 inibe mensagem de entrada e saída nessa sala'
    else
    if nomeArq = 'PPAJUTC7' then
        s:= 'CTRL+F7 repete sua última mensagem enviada'
    else
    if nomeArq = 'PPAJUT14' then
        s:= 'CTRL+F8 inibe sons de efeito'
    else
    if nomeArq = 'PPAJUT15' then
        s:= 'CTRL+B ativa ou desativa o bip'
    else
    if nomeArq = 'PPAJUT16' then
        s:= 'CTRL+E ativa ou desativa modo de espera'
    else
    if nomeArq = 'PPAJUT17' then
        s:= 'CTRL+P ativa ou desativa modo de proteção'
    else
    if nomeArq = 'PPAJUT18' then
        s:= 'CTRL+S seleciona um efeito'
    else
    if nomeArq = 'PPAJUT19' then
        s:= 'CTRL+T ativa ou desativa modo TELNET'
    else
    if nomeArq = 'PPAJUT20' then
        s:= 'CTRL+X resgata mensagens da tela para o editor'
    else
    if nomeArq = 'PPAJUT21' then
        s:= 'CTRL+Z limpa a tela e aguarda tecla pressionada'
    else
    if nomeArq = 'PPAJUT22' then
        s:= 'ENTER edita campo'
    else
    if nomeArq = 'PPAJUT23' then
        s:= 'CTRL+C seleciona um comando da sala de conversação'
    else
    if nomeArq = 'PPAJUT24' then
        s:= 'CTRL+Q Ativa ou desativa o comando QUEM'
    else
    if nomeArq = 'PPAPTF1' then
        s := 'Aperte F1 para ajuda'
    else
    if nomeArq = 'PPQUERGV' then
        s := 'Parceiro deseja enviar '
    else
    if nomeArq = 'PPERRCOM' then
        s := 'Erro de comunicação na Internet'
    else
    if nomeArq = 'PPSOPRO' then
        s := 'Somente disponível na versão PRO'
    else
    if nomeArq = 'PPNOMSER' then
        s := 'Qual o seu servidor ?'
    else
    if nomeArq = 'PPRECUEM' then
        s := 'Servidor desconheceu seu e-mail'
    else
    if nomeArq = 'PPNINGUE' then
        s := 'Ninguém foi encontrado'
    else
    if nomeArq = 'PPNOMBUS' then
        s := 'Informe parte do nome a buscar'
    else
    if nomeArq = 'PPINFMSG' then
        s := 'Informe a mensagem a enviar'
    else
    if nomeArq = 'PPMSGENV' then
        s := 'Mensagem foi enviada'
    else
    if nomeArq = 'PPMSGURG' then
        s := 'Mensagem urgente de '
    else
    if nomeArq = 'PPIDSECR' then
        s := 'Deseja manter sua real identidade em segredo ? '
    else
    if nomeArq = 'PPNOMFAN' then
        s := 'Informe então seus dados de fantasia'
    else
    if nomeArq = 'PPERRREG' then
        s := 'Não consegui registrar no servidor de nomes'
    else
    if nomeArq = 'PPNUMIP' then
        s := 'Número IP desta conexão'
    else
    if nomeArq = 'PPGRMSG' then
        s := 'Irei gravar as mensagens'
    else
    if nomeArq = 'PPNGRMSG' then
        s := 'Não irei gravar as mensagens'
    else
    if nomeArq = 'PPENVTOD' then
        s := 'Enviando para todos'
    else
    if nomeArq = 'PPINFAPE' then
        s := 'Informe o apelido desejado: '
    else
    if nomeArq = 'PPENVAPE' then
        s := 'Ok, enviando apenas para '
    else
    if nomeArq = 'PPMSGINB' then
        s := 'Mensagens de entrada e saída estão inibidas'
    else
    if nomeArq = 'PPMSNINB' then
        s := 'Mensagens de entrada e saída não estão inibidas'
    else
    if nomeArq = 'PPEFEINB' then
        s := 'Os sons de efeito estão inibidos'
    else
    if nomeArq = 'PPEFNINB' then
        s := 'Os sons de efeito não estão inibidos'
    else
    if nomeArq = 'PPESCSET' then
        s := 'Escolha com as setas'
    else
    if nomeArq = 'PPERREF1' then
        s := 'Não existe nenhum efeito relacionado em sua lista'
    else
    if nomeArq = 'PPERREF2' then
        s := 'O arquivo sompapo.ini está vazio ou foi danificado'
    else
    if nomeArq = 'PPERRCM1' then
        s := 'Não existe nenhum comando relacionado em sua lista'
    else
    if nomeArq = 'PPERRCM2' then
        s := 'O arquivo comsaci.ini está vazio ou foi danificado'
    else
    if nomeArq = 'PPERREF3' then
        s := 'Por favor, consulte o manual'
    else
    if nomeArq = 'PPIARQE' then
        s := 'Informe o nome completo do arquivo a enviar: '
    else
    if nomeArq = 'PPINFNOP' then
        s := 'Informe o parceiro que irá receber, ENTER para todos: '
    else
    if nomeArq = 'PPENVTOD' then
        s := 'Enviando para todos os presentes'
    else
    if nomeArq = 'PPENVAPN' then
        s := 'Enviando apenas para '
    else
    if nomeArq = 'PPITEMPO' then
        s := 'Informe o tempo entre uma linha e outra: '
    else
    if nomeArq = 'PPFIMTRS' then
        s := 'Fim da transmissão'
    else
    if nomeArq = 'PPVOLENV' then
        s := 'Voltei a enviar para todos os presentes'
    else
    if nomeArq = 'PPENV0' then
        s := 'Para enviar tecle ENTER e para desistir tecle ESC'
    else
    if nomeArq = 'PPENV1' then
        s := 'F5, busca efeito'
    else
    if nomeArq = 'PPENV2' then
        s := 'CTRL+F5, busca de novo'
    else
    if nomeArq = 'PPENV3' then
        s := 'PGUP, anda 5 na fila'
    else
    if nomeArq = 'PPENV4' then
        s := 'PGDN, volta 5 na fila'
    else
    if nomeArq = 'PPENV5' then
        s := 'HOME, vai para o início da fila'
    else
    if nomeArq = 'PPENV6' then
        s := 'END, vai para o final da fila'
    else
    if nomeArq = 'PPENV7' then
        s := 'DEL, remove da lista'
    else
    if nomeArq = 'PPENV8' then
        s := 'INS, recupera na lista'
    else
    if nomeArq = 'PPCONSAI' then
        s := 'Confirma a saída do bate-papo? S ou N: '
    else
    if nomeArq = 'PPBUSEFE' then
        s := 'Digite uma letra: '
    else
    if nomeArq = 'PPINFASS' then
        s := 'Informe o apelido, a sala ou a senha: '
    else
    if nomeArq = 'PPUSES' then
        s := 'Painel de configuração'
    else
    if nomeArq = 'PPS' then
        s := 'Servidor: '
    else
    if nomeArq = 'PPN' then
        s := 'Nome: '
    else
    if nomeArq = 'PPE' then
        s := 'Endereço eletrônico: '
    else
    if nomeArq = 'PPA' then
        s := 'Arquivo pessoal: '
    else
    if nomeArq = 'PPD' then
        s := 'Ouvir digitação: '
    else
    if nomeArq = 'PPP' then
        s := 'Ouvir pontuação: '
    else
    if nomeArq = 'PPMA' then
        s := 'Modo acelerado: '
    else
    if nomeArq = 'PPCD' then
        s := 'Com dicionário: '
    else
    if nomeArq = 'PPRS' then
        s := 'Registro no servidor: '
    else
    if nomeArq = 'PPOUT' then
        s := 'outras opções'
    else
    if nomeArq = 'PPSACI' then
        s := 'O chat da Rede Saci não suporta essa operação, desculpe'
    else
    if nomeArq = 'PPMSGAUT' then
        s:= 'ok, mensagem automática enviada para '
    else
    if nomeArq = 'PPMESLIS' then
        s:= 'Deseja manter a mesma lista de apelidos ? '
    else
    if nomeArq = 'ppinfal' then
        s:= 'Informe os apelidos desejados, pressione ENTER para finalizar'
    else
    if nomeArq = 'PPNAOINI' then
        s:= 'Não consta arquivo com essa inicial'
    else
    if nomeArq = 'PPANAOEX' then
        s:= 'Arquivo não existe'
    else
    if nomeArq = 'PPPRESTC' then
        s:= 'Pressione ESC para sair, ENTER para enviar a linha ou CTRL+ENTER para todo arquivo'
    else
    if nomeArq = 'PPAJUT25' then
        s:= 'CTRL+W Pede para conversar pelo microfone'
    else
    if nomeArq = 'PPPARCON' then
        s:= 'Informe o apelido do parceiro com quem você deseja conversar : '
    else
    if nomeArq = 'PPAGUDIS' then
        s:= 'Aguarde, irei ativar o dispositivo'
    else
    if nomeArq = 'PPENVPED' then
        s:= 'OK, enviei o pedido para '
    else
    if nomeArq = 'PPCONMIC' then
        s:= 'pede para conversar por voz'
    else
    if nomeArq = 'PPVOCACE' then
        s:= 'Você aceita ? '
    else
    if nomeArq = 'PPRESPOS' then
        s:= 'OK, respondi positivamente'
    else
    if nomeArq = 'PPJACONT' then
        s:= 'Você já possui uma conexão por voz'
    else
    if nomeArq = 'PPDADINV' then
        s:= 'Dados inválidos, operação cancelada'
    else
    if nomeArq = 'PPRECUS' then
        s:= 'OK, recusei'

    else
    if nomeArq = 'PPAJUT26' then
        s:= 'CTRL+K ativa ou desativa conexão por voz'
    else
    if nomeArq = 'PPABRVOZ' then
        s := 'Aberta a conexão por voz, poderei enviar ou receber pedidos'
    else
    if nomeArq = 'PPFECVOZ' then
        s := 'Fechada a conexão por voz, não poderei enviar nem receber pedidos'
    else
    if nomeArq = 'PPDESATV' then
        s := 'Aguarde, irei desativar o dispositivo'

    else
        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{                    dá uma mensagem
{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;

begin
    s := pegaTextoMensagem (nomeArq);

    if nlf >= 0 then write (s);
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
    speakerSound (20);
    delay (100);
    speakerNoSound;
end;

end.
