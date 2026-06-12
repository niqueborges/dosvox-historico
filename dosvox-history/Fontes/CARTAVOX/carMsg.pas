{--------------------------------------------------------}
{
{           CartaVox - mensagens
{
{--------------------------------------------------------}

unit carMsg;

interface

uses
    dvcrt,
    dvWin,
    dvLenum,
    sysUtils,
    windows;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure msgBaixo (nomeArq: string);
procedure bipSpeaker (pitch: integer);

const
    MSG_CONEXAOCANC = 'Conexão foi cancelada';
    CONF_CARTAVOX = 'CARTAVOX - Configuração';
    CONFMONIT_CARTAVOX = 'CARTAVOX - Configuração do monitoramento';
    CONFAVAN_CARTAVOX = 'CARTAVOX - Configuração avançada';
    CONFPROCURA_CARTAVOX = 'CARTAVOX - Configuração da procura';

implementation

{--------------------------------------------------------}
{       descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'CTNOMENV' then
        s := 'Qual o nome do arquivo a enviar ? '
    else
    if  nomeArq = 'CTINIC' then
        s := 'CARTAVOX - Correio Eletrônico - NCE/UFRJ - v.'
    else
    if  nomeArq = 'CTCARTAVOX' then
        s := 'CARTAVOX'
    else
    if nomeArq = 'CTAJUD01' then
        s := 'As opções são'
    else
    if nomeArq = 'CTAJUD02' then
        s := 'E - Escrever carta'
    else
    if nomeArq = 'CTAJUD03' then
        s := 'T - Transmitir cartas escritas'
    else
    if nomeArq = 'CTAJUD04' then
        s := 'R - Receber cartas do correio'
    else
    if nomeArq = 'CTAJUD05' then
        s := 'F - Folhear as cartas já recebidas'
    else
    if nomeArq = 'CTAJUD5A' then
        s := 'N - Folhear as cartas não lidas'
    else
    if nomeArq = 'CTAJUD5B' then
        s := 'L - Folhear as cartas lidas'
    else
    if nomeArq = 'CTAJUD5C' then
        s := 'I - Informar configuração atual'
    else
    if nomeArq = 'CTAJUD51' then
        s := 'As opções de cópia de cartas são:'
    else
    if nomeArq = 'CTAJUD06' then
        s := 'C - Configurar o programa'
    else
    if nomeArq = 'CTAJUD6A' then
        s := 'V - Verificar cartas preparadas ou transmitidas'
    else
    if nomeArq = 'CTAJUD07' then
        s := 'A - Editar apelidos'
    else
    if nomeArq = 'CTAJUD08' then
        s := 'M - Monitorar correio'
    else
    if nomeArq = 'CTAJUD09' then
        s := 'Z - Apagar cartas duplicadas não lidas'
    else
    if nomeArq = 'CTAJUD10' then
        s := 'Q - Informar total de cartas'
    else
    if nomeArq = 'CTAJUD11' then
        s := 'S - Mata Spam'
    else
    if nomeArq = 'CTAJUD12' then
        s := 'B - Regras'
    else
    if nomeArq = 'CTAJUD13' then
        s := 'U - Resposta automática'
    else
    if nomeArq = 'CTAJUD14' then
        s := 'J      - Folhear cartas no servidor'
    else
    if nomeArq = 'CTAJUD15' then
        s := 'K - Grupo de contas'
    else
    if nomeArq = 'CTAJUD16' then
        s := 'X - Conexão com IMAPUtil'
    else
    if nomeArq = 'CTAJUD17' then
        s := 'Y - Mata Spam nas cartas não lidas'
    else
    if nomeArq = 'CTSETOPC' then
        s := 'Use as setas para conhecer outras opções'
    else
    if nomeArq = 'CTQUALOP' then
        s := 'Qual sua opção? '
    else
    if nomeArq = 'CTOPVINV' then
        s := 'Opção inválida, aperte F1 para ajuda'
    else
    if nomeArq = 'CTF1AJUD' then
        s := 'F1 ajuda '
    else
    if nomeArq = 'CTFIM' then
        s := 'Fim do Correio'
    else
    if nomeArq = 'CTOKORD' then
        s := 'Ok, cartas ordenadas.'
    else
    if nomeArq = 'CTCARSUM' then
        s := 'Erro no disco: carta sumiu'
    else
    if nomeArq = 'CTAJFL01' then
        s := 'Folheie as cartas com as setas, depois tecle:'
    else
    if nomeArq = 'CTAJFL02' then
        s := 'L ou ENTER - Para ler a carta'
    else
    if nomeArq = 'CTAJFL03' then
        s := 'I - Para obter informações sobre a carta'
    else
    if nomeArq = 'CTAJFL04' then
        s := 'A - Apagar a carta'
    else
    if nomeArq = 'CTAJFL05' then
        s := 'U - Preparar resposta automática'
    else
    if  nomeArq = 'CTAJFL5B' then
        s := 'R - Responder carta'
    else
    if nomeArq = 'CTAJFL5C' then
         s := 'E - Encaminhar carta'
    else
    if nomeArq = 'CTAJFL5D' then
        s := 'Ctrl+E - Encaminhar em anexo'
    else
    if nomeArq = 'CTAJFL5E' then
        s := 'Ctrl+R - Responder para o remetente'
    else
    if nomeArq = 'CTAJFL5F' then
        s := 'E - editar carta'
    else
    if nomeArq = 'CTAJFL5G' then
        s := 'R - trocar remetente da carta'
    else
    if nomeArq = 'CTAJFL06' then
        s := 'C - Copiar'
    else
    if nomeArq = 'CTAJFL07' then
        s := 'ESC - Terminar folheamento'
    else
    if nomeArq = 'CTAJFL08' then
        s := 'T - Transmitir cartas já digitadas'
    else
    if nomeArq = 'CTAJFL8A' then
        s := 'R - Reenviar carta'
    else
    if nomeArq = 'CTAJFL09' then
        s := 'S - Selecionar remetente associando apelido'
    else
    if nomeArq = 'CTAJFL9A' then
        s := 'S - selecionar destinatário associando apelido'
    else
    if nomeArq = 'CTAJFL10' then
        s := 'F5 - Procurar'
    else
    if nomeArq = 'CTAJFL11' then
        s := 'Ctrl+L - Liberar o remetente no MataSpam'
    else
    if nomeArq = 'CTAJFL12' then
        s := 'O - Editar o texto original da carta'
    else
    if nomeArq = 'CTAJFL13' then
        s := 'Q - Informar qual a carta do total'
    else
    if nomeArq = 'CTAJFL14' then
        s := 'Ctrl+B - Bloquear o remetente no MataSpam'
    else
    if nomeArq = 'CTAJFL15' then
        s := 'D - Informar o tamanho da carta'
    else
    if nomeArq = 'CTAJFL16' then
        s := 'N - Informar o nome do arquivo da carta'
    else
    if nomeArq = 'CTAJFL17' then
        s := 'Z - Gravar partes que tem nome'
    else
    if nomeArq = 'CTAJFL18' then
        s := 'M - Marcar ou desmarcar como lida'
    else
    if nomeArq = 'CTAJFL19' then
        s := 'Ctrl+G - Buscar carta pela posição'
    else
    if nomeArq = 'CTAJFL20' then
        s := 'G - Buscar a carta pelo nome do arquivo'
    else
    if nomeArq = 'CTAJFL21' then
        s := 'A - Apagar a carta do servidor'
    else
    if nomeArq = 'CTAJFL22' then
        s := 'R - Receber a carta do servidor'
    else
    if nomeArq = 'CTAJFL23' then
        s := 'Ctrl+R - Receber a carta sem apagá-la do servidor'
    else
    if nomeArq = 'CTAJFL24' then
        s := 'B - Editar apelidos'
    else
    if nomeArq = 'CTAJFL26' then
        s := 'F - Falar remetente da carta'
    else
    if nomeArq = 'CTAJFL27' then
        s := 'Ctrl+F - Falar destinatário da carta'
    else
    if nomeArq = 'CTAJFL28' then
    s := 'Ctrl+D - Informar tamanho de todas as cartas'
    else
    if nomeArq = 'CTAJFL29' then
        s := 'Ctrl+Q - Informa selecionadas do total'
    else
    if nomeArq = 'CTAJFL30' then
        s := 'F6 - procura invertida'
    else
    if nomeArq = 'CTAJFL31' then
        s := 'V - Vai para outro folheamento'
    else
    if nomeArq = 'CTAJFL32' then
        s := 'F3 - Ordenar'
    else
    if nomeArq = 'CTARQUIV' then
        s := 'Arquivo '
    else
    if nomeArq = 'CTASSUNT' then
        s := 'Assunto: '
    else
    if nomeArq = 'CTDATENV' then
        s := 'Data de envio: '
    else
    if nomeArq = 'CTDATCHE' then
        s := 'Data de chegada: '
    else
    if nomeArq = 'CTCNFAPA' then
        s := 'Confirma o apagamento desta carta com assunto'
    else
    if nomeArq = 'CTSIMNAO' then
        s := '(S/N) '
    else
    if nomeArq = 'CTERRDSK' then
        s := 'Erro de escrita no disco'
    else
    if nomeArq = 'CTOKAPA' then
        s := 'Ok, carta apagada'
    else
    if nomeArq = 'CTPOSMAN' then
        s := 'Posso mandar para '
    else
    if nomeArq = 'CTENDDST' then
        s := 'Qual o endereço eletrônico do destinatário? '
    else
    if nomeArq = 'CTDESIST' then
        s := 'Desistiu...'
    else
    if nomeArq = 'CTJOGEDI' then
        s := 'Jogo no editor o texto original (s/n) ? '
    else
    if nomeArq = 'CTERRLEI' then
        s := 'Erro de leitura do arquivo'
    else
    if nomeArq = 'CTCNFENV' then
        s := 'Confirma envio (s/n) ? '
    else
    if nomeArq = 'CTINFDST' then
        s := 'Informe o nome completo do arquivo destino:'
    else
    if nomeArq = 'CTULTARQ' then
        s := 'Ultimo arquivo...'
    else
    if nomeArq = 'CTSEMCAR' then
        s := 'Não tem carta neste diretório'
    else
    if nomeArq = 'CTUSESET' then
        s := 'Folheando: use as setas, depois tecle sua opção'
    else
    if nomeArq = 'CTCNTFOL' then
        s := 'Continue folheando ou tecle ESC'
    else
    if nomeArq = 'CTFOLFIM' then
        s := 'Folheamento terminado'
    else
    if nomeArq = 'CTPROGRV' then
        s := 'Problemas para gravar carta no disco'
    else
    if nomeArq = 'CTPROCON' then
        s := 'Problemas na conexão'
    else
    if nomeArq = 'CTACONT' then
        s := 'A conta '
    else
    if nomeArq = 'CTNAOACE' then
        s := '... não foi aceita, servidor falou assim'
    else
    if nomeArq = 'CTINFSEN' then
        s := 'Informe sua senha: '
    else
    if nomeArq = 'CTASENHA' then
        s := 'A senha '
    else
    if nomeArq = 'CTEXISTE' then
        s := 'Existe no servidor '
    else
    if nomeArq = 'CTEXISTM' then
        s := 'Existem no servidor '
    else
    if nomeArq = 'CTCOMUSO' then
        s := ' com uso de '
    else
    if nomeArq = 'CTSELINT' then
        s := 'Quer selecionar interativamente ? '
    else
    if nomeArq = 'CTERRSRV' then
        s := 'Erro no servidor, veja o que ele disse:'
    else
    if nomeArq = 'CTERRTMP' then
        s := 'Problemas no arquivo temporário'
    else
    if nomeArq = 'CTENVPOR' then
        s := 'Enviada por '
    else
    if nomeArq = 'CTPODSER' then
        s := 'Está correto ? '
    else
    if nomeArq = 'CTCONTAC' then
        s := 'Contactando servidor para receber correspondência'
    else
    if nomeArq = 'CTPEGCOR' then
        s := 'Pegando a correspondência'
    else
    if nomeArq = 'CTCARTA' then
        s := 'Carta'
    else
    if nomeArq = 'CTOKPEG' then
        s := 'Ok, peguei a correspondência'
    else
    if nomeArq = 'CTCONCAN' then
        s := 'Conexão com servidor foi cancelada'
    else
    if nomeArq = 'CTERRCOM' then
        s := 'Não consegui ativar o sistema de comunicações do micro'
    else
    if nomeArq = 'CTNAOSOQ' then
        s := 'Não consegui criar soquete'
    else
    if nomeArq = 'CTERBIND' then
        s := 'Não consegui alocar porta (bind)'
    else
    if nomeArq = 'CTSEMSRV' then
        s := 'Não consegui achar um servidor com este nome'
    else
    if nomeArq = 'CTNAOCON' then
        s := 'Não consegui realizar a conexão'
    else
    if nomeArq = 'CTCONOK' then
        s := 'Conexão realizada'
    else
    if nomeArq = 'CTERRCNF' then
        s := 'Este programa está configurado com erro !'
    else
    if nomeArq = 'CTERRGER' then
        s := 'Não consegui gerar carta para envio'
    else
    if nomeArq = 'CTNAOMAN' then
        s := 'Carta não será mandada'
    else
    if nomeArq = 'CTARQSUM' then
        s := 'Arquivo a enviar sumiu !'
    else
    if nomeArq = 'CTCARPRP' then
        s := 'Carta preparada para envio'
    else
    if nomeArq = 'CTNOMMAN' then
        s := 'Qual o nome do arquivo de texto a mandar ? '
    else
    if nomeArq = 'CTQUERTC' then
        s := 'Esse arquivo não existe, quer teclar agora ? '
    else
    if nomeArq = 'CTABREDI' then
        s := 'Abrindo editor'
    else
    if nomeArq = 'CTPROENV' then
        s := 'Problema de arquivo ao enviar a carta '
    else
    if nomeArq = 'CTERRCAB' then
        s := 'Erro no cabeçalho da carta '
    else
    if nomeArq = 'CTVEJMEN' then
        s := 'Veja mensagem do servidor:'
    else
    if nomeArq = 'CTCONCAI' then
        s := 'Conexão de dados caiu'
    else
    if nomeArq = 'CTCONTSV' then
        s := 'Contactando servidor para transmitir cartas'
    else
    if nomeArq = 'CTCONTSC' then
        s := 'Contactando servidor para transmitir carta'
    else
    if nomeArq = 'CTSRVNAO' then
        s := 'Servidor não quer conversa, ele mandou esta mensagem'
    else
    if nomeArq = 'CTENVCAR' then
        s := 'Enviando as cartas'
    else
    if nomeArq = 'CTENVACA' then
        s := 'Enviando carta'
    else
    if nomeArq = 'CTSRVNGO' then
        s := 'Servidor não gostou dessa conexão, ele mandou esta mensagem'
    else
    if nomeArq = 'CTDIRSUM' then
        s := 'O diretorio de cartas sumiu !'
    else
    if nomeArq = 'CTTODENV' then
        s := 'Todas as cartas já foram enviadas'
    else
    if nomeArq = 'CTFIMENV' then
        s := 'Fim de envio'
    else
    if nomeArq = 'CTCARTAP' then
        s := 'Cartas permanecem prontas para ser enviadas'
    else
    if nomeArq = 'CTCNFAPC' then
        s := 'Posso apagar esta carta com erro ? '
    else
    if nomeArq = 'CTNAOEXE' then
        s := 'Não foi possível executar o arquivo, erro #'
    else
    if nomeArq = 'CTNSSMTP' then
        s := 'Nome do servidor SMTP'
    else
    if nomeArq = 'CTSVPOP3' then
        s := 'Servidor para recepção de cartas - POP3'
    else
    if nomeArq = 'CTNSPOP3' then
        s := 'Nome do servidor POP3'
    else
    if nomeArq = 'CTSEUNOM' then
        s := 'Seu nome esta registrado como'
    else
    if nomeArq = 'CTQSEUNO' then
        s := 'Qual seu nome ?'
    else
    if nomeArq = 'CTENDREM' then
        s := 'Endereço eletrônico do remetente'
    else
    if nomeArq = 'CTENDCMP' then
        s := 'Qual seu endereço completo ?'
    else
    if nomeArq = 'CTCONREG' then
        s := 'Conta no servidor registrada como'
    else
    if nomeArq = 'CTQNOMEC' then
        s := 'Qual o nome de sua conta ?'
    else
    if nomeArq = 'CTDICREC' then
        s := 'Diretório atual para cartas recebidas'
    else
    if nomeArq = 'CTQDIREC' then
        s := 'Qual o diretório para cartas recebidas ?'
    else
    if nomeArq = 'CTDINREC' then
        s := 'Diretório atual para cartas ainda não enviadas'
    else
    if nomeArq = 'CTQDINRC' then
        s := 'Qual o diretório para cartas a enviar?'
    else
    if nomeArq = 'CTTAMMAX' then
        s := 'Tamanho máximo de carta recebida'
    else
    if nomeArq = 'CTQTAMAX' then
        s := 'Qual o tamanho máximo de carta recebida?'
    else
    if nomeArq = 'CTERRDIR' then
        s := 'Diretório inexistente, informe de novo'
    else
    if nomeArq = 'CTQASSUN' then
        s := 'Qual o assunto da carta, enter se só resposta ? '
    else
    if nomeArq = 'CTATACHA' then
        s := 'Quer mandar arquivos junto com esta carta ? '
    else
    if nomeArq = 'CTATAINV' then
        s := 'Nome de arquivo inválido'
    else
    if nomeArq = 'CTNOMATA' then
        s := 'Nome do arquivo a enviar: '
    else
    if nomeArq = 'CTCNVPAD' then
        s := 'Posso usar a conversão padrao (s/n) ? '
    else
    if nomeArq = 'CTTIPMIM' then
        s := 'Qual conversao: Mime64, Nenhuma, Iso-latin ou Uuencode ? '
    else
    if nomeArq = 'CTMAISAR' then
        s := 'Mais arquivos (s/n) ?'
    else
    if nomeArq = 'CTTEMATT' then
        s := 'Contém arquivos inclusos'
    else
    if nomeArq = 'CTNARQM' then
        s := 'Número de partes inclusas: '
    else
    if nomeArq = 'CTLERGRD' then
        s := 'Escolha: ler ou guardar em arquivo ? '
    else
    if nomeArq = 'CTNOMGRD' then
        s := 'Nome do arquivo a guardar: '
    else
    if nomeArq = 'CTOK' then
        s := 'OK'
    else
    if nomeArq = 'CTVOUGRV' then
        s := 'Pretendo gravar '
    else
    if nomeArq = 'CTTOCAR' then
        s := 'Arquivo é sonoro, quer tocar (s/n) ? '
    else
    if nomeArq = 'CTEDINOM' then
        s := 'Use as setas para reeditar, tecle ENTER para confirmar ou ESC para cancelar: '
    else
    if nomeArq = 'CTAPELID' then
        s := '(Comecar por * indica apelido)'
    else
    if nomeArq = 'CTEDIAPE' then
        s := 'Editando arquivo de apelidos'
    else
    if nomeArq = 'CTENVPAR' then
        s := 'Enviando para '
    else
    if nomeArq = 'CTINFAPE' then
        s := 'Informe o apelido: '
    else
    if nomeArq = 'CTINFNOM' then
        s := 'Informe o nome: '
    else
    if nomeArq = 'CTINFEND' then
        s := 'Informe o endereço eletrônico: '
    else
    if nomeArq = 'CTAPEINV' then
        s := 'Apelido inválido'
    else
    if nomeArq = 'CTCNFDST' then
        s := 'Confirma destino (s/n) ? '
    else
    if nomeArq = 'CTASSCAR' then
        s := 'Qual o assunto da carta ?'
    else
    if nomeArq = 'CTMOMENT' then
        s := 'Um momento...  '
    else
    if nomeArq = 'CTPODTRA' then
        s := 'Quer trazer ? '
    else
    if nomeArq = 'CTAPGCAR' then
        s := 'Apago do servidor '
    else
    if nomeArq = 'CTMODNOR' then
        s := 'Modo normal'
    else
    if nomeArq = 'CTMODDEB' then
        s := 'Modo debug: cartas não serão apagadas'
    else
    if nomeArq = 'CTNOMCNF' then
        s := 'Informe o nome da configuração (até 20 letras)'
    else
    if nomeArq = 'CTCNFNAO' then
        s := 'Configuração não achada'
    else
    if nomeArq = 'CTAJCO00' then
        s := 'N - Nova configuração'
    else
    if nomeArq = 'CTAJCO01' then
        s := 'C - configurar'
    else
    if nomeArq = 'CTAJCO01B' then
        s := 'M - configurar monitoramento'
    else
    if nomeArq = 'CTAJCO02' then
        s := 'G - guardar configuração'
    else
    if nomeArq = 'CTAJCO03' then
        s := 'R - recuperar configuração'
    else
    if nomeArq = 'CTAJCO04' then
        s := 'A - apagar configuração'
    else
    if nomeArq = 'CTAJCO05' then
        s := 'O - outras configurações'
    else
    if nomeArq = 'CTAJCO06' then
        s := 'L - recuperar configuração da lixeira'
    else
    if nomeArq = 'CTAJCO10' then
        s := 'S - recuperar configuração Spam'
    else
    if nomeArq = 'CTAJCO07' then
        s := 'P - restaurar configurações padrão'
    else
    if nomeArq = 'CTAJCO08' then
        s := 'F - configurar procura automatizada'
    else
    if nomeArq = 'CTAJCO09' then
        s := 'V - voltar configuração anterior'
    else
    if nomeArq = 'CTOKRM' then
        s := 'Ok, removida'
    else
    if nomeArq = 'CTCONFRM' then
        s := 'Escolha com as setas a configuração a remover'
    else
    if nomeArq = 'CTSETCON' then
        s := 'Escolha com as setas a configuração'
    else
    if nomeArq = 'CTMUDREM' then
        s := 'Mudar remetente'
    else
    if nomeArq = 'CTCNFRMS' then
        s := 'Confirma remoção da configuração '
    else
    if nomeArq = 'CTRECOPA' then
        s := 'Deseja restaurar as configurações padrão? '
    else
    if nomeArq = 'CTRENOCO' then
        s := 'E o arquivo utilizado em novas configurações? '
    else
    if nomeArq = 'CTSALCON' then
        s := 'Deve salvar a configuração para realizar esta operação'
    else
    if nomeArq = 'CTTRCOSE' then
        s := 'Deseja trocar de conta todas as selecionadas? '
    else
    if nomeArq = 'CTEDTIPR' then
        s := 'Editore os tipos de procura, ao final tecle ESC'
    else
    if nomeArq = 'CTOPCINV' then
        s := 'Opção inválida'
    else
    if nomeArq = 'CTMUICAR' then
        s := 'São muitas cartas, quantas trago agora ? '
    else
    if nomeArq = 'CTTAMAN' then
        s := 'Tamanho '
    else
    if nomeArq = 'CTARQASS' then
        s := 'Nome do arquivo de assinatura'
    else
    if nomeArq = 'CTSEMASS' then
        s := '-- Nenhum --'
    else
    if nomeArq = 'CTQARQAS' then
        s := 'Qual o nome completo do arquivo de assinatura?'
    else
    if nomeArq = 'CTEDIANT' then
        s := 'Quer editá-lo antes de mandar ? '
    else
    if nomeArq = 'CTADIASS' then
        s := 'Adiciona sua assinatura ? '
    else
    if nomeArq = 'CTASSNAO' then
        s := 'Arquivo não existe, não esqueça de criá-lo'
    else
    if nomeArq = 'CTQUERLC' then
        s := 'Deseja ler o arquivo original completo ? '
    else
    if nomeArq = 'CTQUEVER' then
        s := 'Verificar preparadas ou transmitidas ? '
    else
    if nomeArq = 'CTORDLIE' then
       s := 'Ordenando a lista de cartas pela data de envio ...'
    else
    if nomeArq = 'CTORDLIC' then
       s := 'Ordenando a lista de cartas pela data de chegada ...'
    else
    if nomeArq = 'CTFIMCNF' then
        s := 'Fim da configuração'
    else
    if nomeArq = 'CTGUENV' then
        s := 'Vou guardar uma cópia de todas as cartas enviadas'
    else
    if nomeArq = 'CTGUASEN' then
        s := 'Vou guardar a senha'
    else
    if nomeArq = 'CTNGUENV' then
        s := 'Armazenagem das cartas já enviadas está inibida'
    else
    if nomeArq = 'CTDATPRP' then
        s := 'Data de preparação: '
    else
    if nomeArq = 'CTQAPELI' then
        s := 'Informe o apelido desejado para '
    else
    if nomeArq = 'CTINFPRO' then
        s := 'Informe o texto a procurar no cabeçalho da carta'
    else
    if nomeArq = 'CTNACHEI' then
        s := 'Não achei'
    else
    if nomeArq = 'CTACHEI' then
        s := 'Achei'
    else
    if nomeArq = 'CTSOUMDS' then
        s := 'Erro: informe apenas um destinatário principal'
    else
    if nomeArq = 'CTENVCC' then
        s := 'Deseja enviar cópias-carbono desta carta ? '
    else
    if nomeArq = 'CTENVBCC' then
        s := 'Deseja enviar cópias não identificadas desta carta ? '
    else
    if nomeArq = 'CTDIGCC' then
        s := 'Digite os endereços eletrônicos para os carbonos'
    else
    if nomeArq = 'CTENTCC' then
        s := 'Tecle ENTER após cada nome e após o último tecle mais um ENTER'
    else
    if nomeArq = 'CTERENVC' then
        s := 'Erro ao enviar a carta.  Servidor reclamou de '
    else
    if nomeArq = 'CTRSPOUT' then
        s := 'A carta a que você está respondendo tinha sido enviada a outras pessoas'
    else
    if nomeArq = 'CTENVIAT' then
        s := 'Quer enviar sua resposta também para elas ? '
    else
    if nomeArq = 'CTLEALTE' then
        s := 'Lendo e alterando carta.'
    else
    if nomeArq = 'CTREESCR' then
        s := 'Arquivo existente, reescreve ? '
    else
    if nomeArq = 'CTDISPON' then
        s := 'Cartas disponíveis: '
    else
    if nomeArq = 'CTINTERV' then
        s := 'Após quantos segundos remonitoro (sugiro 60) ? '
    else
    if nomeArq = 'CTERRSEN' then
        s := 'Senha está errada'
    else
    if nomeArq = 'CTERCONX' then
        s := 'Erro na conexão com o correio'
    else
    if nomeArq = 'CTCARTAS' then
        s := 'Cartas'
    else
    if nomeArq = 'CTAVINOV' then
        s := 'Aviso só quando chegarem cartas novas? '
    else
    if  nomeArq = 'CTERDREC' then
        s := 'Diretório de recepção de cartas inexistente'
    else
    if  nomeArq = 'CTPOSCRI' then
        s := 'Posso criá-lo? '
    else
    if  nomeArq = 'CTDRNCRI' then
        s := 'Diretório de recepção não foi criado.'
    else
    if  nomeArq = 'CTNESQCR' then
        s := 'Não esqueça de criar o diretório antes de receber ou enviar cartas.'
    else
    if  nomeArq = 'CTERDENV' then
        s := 'Diretório para cartas a enviar inexistente'
    else
    if  nomeArq = 'CTDENCRI' then
        s := 'Diretório de envio não foi criado.'
    else
    if  nomeArq = 'CTEDIASS' then
        s := 'Arquivo de assinatura não existe, não se esqueça de editá-lo.'
    else
    if  nomeArq = 'CTEXTCAR' then
        s := 'Atenção: ainda existem cartas a serem enviadas'
    else
    if nomeArq = 'CTAPELSO' then
        s := ' Apelidos'
    else
    if nomeArq = 'CTARQAPL' then
        s := 'Arquivo com a lista de pessoas não existe.'
    else
    if nomeArq = 'CTLISAPL' then
        s := 'Lista de pessoas vazia.'
    else
    if nomeArq = 'CTPALPRO' then
        s := 'Digite a palavra a procurar: '
    else
    if nomeArq = 'CTNOARQL' then
        s := 'Nome do arquivo com a lista de pessoas'
    else
    if nomeArq = 'CTAJAP01' then
        s := 'I - insere um novo apelido'
    else
    if nomeArq = 'CTAJAP02' then
        s := 'E - edita arquivo atual'
    else
    if nomeArq = 'CTAJAP03' then
        s := 'T - troca de arquivo'
    else
    if nomeArq = 'CTAJAP04' then
        s := 'A - arquivo atual'
    else
    if nomeArq = 'CTAPJAEX' then
        s := 'Apelido já existe, se mantiver este, apagará o anterior'
    else
    if nomeArq = 'CTDEESOU' then
        s := 'Deseja escolher outro? '
    else
    if nomeArq = 'CTAPEADI' then
        s := ' apelido adicionado'
    else
    if nomeArq = 'CTAPEADS' then
        s := ' apelidos adicionados'
    else
    if nomeArq ='CTAPNADI' then
        s := ' apelido não adicionado'
    else
    if nomeArq = 'CTAPNADS' then
        s := ' apelidos não adicionados'
    else
    if nomeArq = 'CTLIGERA' then
        s := 'Gerando cartas'
    else
    if nomeArq = 'CTMARCAD' then
        s := 'Marcado'
    else
    if nomeArq = 'CTNMARCA' then
        s := 'Desmarcado'
    else
    if nomeArq = 'CTINFNCA' then
        s := 'Informe o número da carta a procurar de '
    else
    if nomeArq = 'CTTIPPRO' then
        s := 'Qual o tipo de procura?'
    else
    if nomeArq = 'CTCABCAR' then
        s := 'C - Cabeçalho da carta'
    else
    if nomeArq = 'CTTODCAR' then
        s := 'T - Toda carta'
    else
    if nomeArq = 'CTINPROT' then
        s := 'Informe o texto a procurar em toda carta'
    else
    if nomeArq = 'CTPROAER' then
        s := 'Erro na procura automatizada número '
    else
    if nomeArq = 'CTPNCONF' then
        s := 'Tipo de procura não configurado.'
    else
    if nomeArq = 'CTFALESP' then
        s := 'Não existia espaço suficiente para escrever.'
    else
    if nomeArq = 'CTINFDDS' then
        s := 'Informe o diretório destino: '
    else
    if nomeArq = 'CTCANCG' then
        s := 'Certo, operação foi cancelada'
    else
    if nomeArq = 'CTERRODI' then
        s := 'Erro: este diretório não está acessível'
    else
    if nomeArq = 'CTJAEXI1' then
        s := 'O arquivo destino'
    else
    if nomeArq = 'CTJAEXI2' then
        s := ' já existe.  Sobrescreve (S/N/T/ESC)? '
    else
    if nomeArq = 'CTFOICOP' then
        s := ' copiado'
    else
    if nomeArq = 'CTFOIMOV' then
        s := ' movido'
    else
    if nomeArq = 'CTNAOAPO' then
        s := 'Não pude apagar o arquivo original'
    else
    if nomeArq = 'CTTODSEL' then
        s := 'Copia todas lidas? '
    else
    if nomeArq = 'CTAJU52A' then
        s := 'C - Copiar a carta para um arquivo'
    else
    if nomeArq = 'CTAJU53A' then
        s := 'D - Copiar carta para outro diretório'
    else
    if nomeArq ='CTAJU54A' then
        s := 'M - Mover'
    else
    if nomeArq = 'CTAJU55A' then
        s := 'T - Copiar todas'
    else
    if nomeArq = 'CTAJU56A' then
        s := 'A - Adicionar a um arquivo'
    else
    if nomeArq = 'CTAJU57' then
        s := 'Ctrl+A - Adicionar todas a um arquivo'
    else
    if nomeArq = 'CTAJU58' then
        s := 'CTRL+D - copiar carta para outra configuração'
    else
    if nomeArq = 'CTAJU59' then
        s := 'CTRL+M - mover para outra configuração'
    else
    if nomeArq = 'CTAJU60' then
        s := '    CTRL + r - mover para pasta de regra'
    else
    if nomeArq = 'CTTIPCOP' then
        s := 'Qual o tipo de cópia ? '
    else
    if nomeArq = 'CTINARQP' then
        s := 'Informe o nome do arquivo a procurar'
    else
    if nomeArq = 'CTATCLF9' then
        s := 'Tecle F9 para selecionar a opção com as setas'
    else
    if nomeArq = 'CTADICIO' then
        s := ' ou tecle A para Adicionar todos: '
    else
    if nomeArq = 'CTNUMCAR' then
        s := 'Número de cartas neste folheamento: '
    else
    if nomeArq = 'CTARQNDC' then
        s := 'Arquivo não existe, deseja cria-lo? '
    else
    if nomeArq = 'CTCOMONO' then
        s := ' com o nome '
    else
    if nomeArq = 'CTNAOEXS' then
        s := 'Não existem cartas no servidor.'
    else
    if nomeArq = 'CTCARBON' then
        s := 'carbono'
    else
    if nomeArq = 'CTNAOPOD' then
        s := 'O arquivo não pode ser copiado sobre si mesmo !'
    else
    if nomeArq = 'CTORDNOM' then
        s := 'Ordenando a lista de cartas pelo nome...'
    else
    if nomeArq = 'CTORDASS' then
        s := 'Ordenando a lista de cartas pelo assunto...'
    else
    if nomeArq = 'CTCOPSEL' then
        s := 'Copia todas as selecionadas? '
    else
    if nomeArq = 'CTAPATCA' then
        s := 'Deseja apagar todas as cartas? '
    else
    if nomeArq = 'CTAPASEL' then
        s := 'Deseja apagar todas as selecionadas? '
    else
    if nomeArq = 'CTOKAPAS' then
        s := 'Ok, cartas apagadas'
    else
    if nomeArq = 'CTCONFIG' then
        s := 'Configuração'
    else
    if nomeArq = 'CTADISEL' then
        s := 'Deseja adicionar todas as selecionadas? '
    else
    if nomeArq = 'CTEMJAEX' then
        s := 'e-mail já existe.'
    else
    if nomeArq = 'CTAJFP01' then
        s := 'Folheie as partes com as setas, depois tecle:'
    else
    if nomeArq = 'CTAJFP02' then
        s := 'ENTER ou L - Ler ou gravar a parte'
    else
    if nomeArq = 'CTAJFP03' then
        s := 'E - Ler a parte com o editor'
    else
    if nomeArq = 'CTAJFP04' then
        s := 'G - Gravar a parte'
    else
    if nomeArq = 'CTAJFP05' then
        s := 'SETA PARA ESQUERDA - Informa nome do arquivo da parte'
    else
    if nomeArq = 'CTAJFP06' then
        s := 'SETA PARA DIREITA - Informa tipo da parte'
    else
    if nomeArq = 'CTAJFP07' then
        s := 'A - Apagar a parte'
    else
    if nomeArq = 'CTAJFP08' then
        s := 'Q - Informa quantas do total'
    else
    if nomeArq = 'CTAJFP09' then
        s := 'Ctrl+Q - Informa quantas selecionadas do total'
    else
    if nomeArq = 'CTAJFP10' then
        s := 'S - Informa assunto da carta'
    else
    if nomeArq = 'CTAJFP11' then
        s := 'BARRA DE ESPAÇO - Seleciona ou tira seleção'
    else
    if nomeArq = 'CTAJFP12' then
        s := '* - Seleciona tudo'
    else
    if nomeArq = 'CTAJFP13' then
        s := '/ - Tira seleção de tudo'
    else
    if nomeArq = 'CTAJFP14' then
        s := 'P - Lista cabeçalho da parte'
    else
    if nomeArq = 'CTAJFP15' then
        s := 'Ctrl+F - Grava carta e sai'
    else
    if nomeArq = 'CTAJFP16' then
        s := 'CTRL+G - Gravar partes que tem nome'
    else
    if nomeArq = 'CTAJFP17' then
        s := 'ESC - Terminar folheamento das partes'
    else
    if nomeArq = 'CTQPARTE' then
        s := 'Qual a parte desejada? (use setas, F1 ajuda) '
    else
    if nomeArq = 'CTITFOCA' then
        s := 'Folheie os itens do cabeçalho desta parte com as setas, tecle ESC para sair'
    else
    if nomeArq = 'CTNAODEF' then
        s := 'Não definido'
    else
    if nomeArq = 'CTDEAPSE' then
        s := 'Deseja apagar as partes selecionadas?'
    else
    if nomeArq = 'CTPARAPA' then
        s := 'Parte apagada'
    else
    if nomeArq = 'CTDEAPSE' then
        s := 'Deseja apagar as partes selecionadas?'
    else
    if nomeArq = 'CTPASAPS' then
        s := 'Partes apagadas'
    else
    if nomeArq = 'CTDEAPPA' then
        s := 'Deseja apagar essa parte? '
    else
    if nomeArq = 'CTGRAALT' then
        s := 'Deseja gravar as alterações na carta?'
    else
    if nomeArq = 'CTEDENSO' then
        s := 'Edite o nome do arquivo ou tecle ENTER para sobrescrever'
    else
    if nomeArq = 'CTARQGRA' then
        s := 'Arquivo gravado'
    else
    if nomeArq = 'CTGRASEL' then
        s := 'Deseja gravar as partes selecionadas?'
    else
    if nomeArq = 'CTAPATIP' then
        s := 'A parte do tipo '
    else
    if nomeArq = 'CTNTEMNO' then
        s := ' não tem nome para o arquivo destino.'
    else
    if nomeArq = 'CTCGRAPS' then
        s := 'Deseja continuar a gravação das partes selecionadas?'
    else
    if nomeArq = 'CTGRAVPA' then
        s := 'Gravando parte '
    else
    if nomeArq = 'CTGRAVSO' then
        s := 'Qual o tipo de gravação, Simplificada ou Original?'
    else
    if nomeArq = 'CTFORETO' then
        s := 'Folheamento de cartas recebidas'
    else
    if nomeArq = 'CTFORELI' then
        s := 'Folheamento de cartas recebidas lidas'
    else
    if nomeArq = 'CTFORENA' then
        s := 'Folheamento de cartas recebidas não lidas'
    else
    if nomeArq = 'CTFOCATA' then
        s := 'Folheamento de cartas transmitidas'
    else
    if nomeArq = 'CTFOCAPR' then
        s := 'Folheamento de cartas preparadas para transmissão'
    else
    if nomeArq = 'CTFOPACA' then
        s := 'Folheamento das partes da carta'
    else
    if nomeArq = 'CTSELECI' then
        s := 'selecionados'
    else
    if nomeArq = 'CTSELECS' then
        s := 'selecionado'
    else
    if nomeArq = 'CTDE' then
        s := 'de'
    else
    if nomeArq = 'CTCARPRS' then
        s := 'Cartas preparadas para envio'
    else
     if nomeArq = 'CTREESEL' then
        s := 'Deseja reenviar todas as selecionadas? '
    else
    if nomeArq = 'CTREECAR' then
        s := 'Deseja reenviar esta carta? '
    else
    if nomeArq = 'CTEASSUN' then
        s := 'Editore o assunto da carta'
    else
    if nomeArq = 'CTENTFEC' then
        s := 'Tecle ENTER para fechar a carta ou F1 para conhecer outras opções'
    else
    if nomeArq = 'CTEDDEEN' then
        s := 'Edite o nome do destinatário'
    else
    if nomeArq = 'CTESOUAP' then
        s := 'Setas escolhe outro no caderno de apelidos'
    else
    if nomeArq = 'CTDELICA' then
        s := 'Deseja limpar a lista de cópias carbono?'
    else
    if nomeArq = 'CTAJEN01' then
        s := 'A - Anexar arquivos'
    else
    if nomeArq = 'CTAJEN02' then
        s := 'C - Inserir cópias carbono'
    else
    if nomeArq = 'CTAJEN03' then
        s := 'S - Editar assunto'
    else
    if nomeArq = 'CTAJEN04' then
        s := 'D - Editar destinatário'
    else
    if nomeArq = 'CTAJEN05' then
        s := 'E - Reeditar texto'
    else
    if nomeArq = 'CTAJEN06' then
        s := 'L - Limpar lista de cópias carbono'
    else
    if nomeArq = 'CTAJEN07' then
        s := 'ESC - Cancelar'
    else
    if nomeArq = 'CTAJEN08' then
        s := 'O - Inserir cópias carbono ocultas'
    else
    if nomeArq = 'CTAJEN09' then
        s := 'F - Folhear listas carbono'
    else
    if nomeArq = 'CTAJEN10' then
        s := 'R - Inserir ou remover confirmação de recebimento'
    else
    if nomeArq = 'CTAJEN11' then
        s := 'T  Fechar carta e transmitir'
    else
    if nomeArq = 'CTAJEN12' then
        s := 'G  Gravar recado falado'
    else
    if nomeArq = 'CTAJEN13' then
        s := 'P  Particionar carta em varias'
    else
    if nomeArq = 'CTAJIN01' then
        s := 'ENTER ou S - Trazer carta'
    else
    if nomeArq = 'CTAJIN02' then
        s := 'N - Não trazer carta'
    else
    if nomeArq = 'CTAJIN03' then
        s := 'D - Ligar ou desligar modo debug'
    else
    if nomeArq = 'CTAJIN04' then
        s := 'G - Ignorar todas as cartas grandes'
    else
    if nomeArq = 'CTAJIN05' then
        s := 'T - Trazer todas as cartas'
    else
    if nomeArq = 'CTAJIN06' then
        s := 'I - Informações sobre a carta'
    else
    if nomeArq = 'CTFOLAPE' then
        s := 'Folheamento dos apelidos'
    else
    if nomeArq = 'CTEMAIL' then
        s := 'e-mail'
    else
    if nomeArq = 'CTENCPAR' then
        s := 'Encaminhada para'
    else
    if nomeArq = 'CTCOMANE' then
        s := 'Com anexo'
    else
    if nomeArq = 'CTPROINV' then
        s := 'Procura invertida'
    else
    if nomeArq = 'CTAJIN07' then
        s := 'A - Assunto da carta'
    else
    if nomeArq = 'CTAJIN08' then
        s := 'Z - Tamanho da carta'
    else
    if nomeArq = 'CTSEMTXT' then
        s := 'Sem texto'
    else
    if nomeArq = 'CTARQVIR' then
        s := 'Esse arquivo pode ser um VÍRUS, tome muito cuidado!'
    else
    if nomeArq = 'CTDESEXE' then
        s := 'Deseja executar esse arquivo?'
    else
    if nomeArq = 'CTPROCOR' then
        s := 'Informe o texto a procurar no corpo da carta'
    else
    if nomeArq = 'CTCORCAR' then
        s := 'B - Corpo da carta'
    else
    if nomeArq = 'CTPROASS' then
        s := 'A - Assunto desta carta'
    else
    if nomeArq = 'CTPROREM' then
        s := 'R - Remetente desta carta'
    else
    if nomeArq = 'CTPRODES' then
        s := 'D - Destinatário desta carta'
    else
    if nomeArq = 'CTPRODAT' then
        s := 'H - Data de chegada desta carta'
    else
    if nomeArq = 'CTQUAFOL' then
        s := 'Qual o tipo de folheamento (F/N/L/P/T)?'
    else
    if nomeArq = 'CTRECEBI' then
        s := 'Recebidas'
    else
    if nomeArq = 'CTRECEB1' then
        s := 'Recebida'
    else
    if nomeArq = 'CTNAOLID' then
        s := 'Não lidas'
    else
    if nomeArq = 'CTLIDAS' then
        s := 'Lidas'
    else
    if nomeArq = 'CTPREPAR' then
        s := 'Preparadas'
    else
    if nomeArq = 'CTTRANSM' then
        s := 'Transmitidas'
    else
    if nomeArq = 'CTENVAGO' then
        s := 'Deseja transmitir agora?'
    else
    if nomeArq = 'CTORDTAM' then
        s := 'Ordenando a lista de cartas pelo tamanho...'
    else
    if nomeArq = 'CTAJOR00' then
        s := 'Os tipos de ordenação são:'
    else
    if nomeArq = 'CTAJOR01' then
        s := 'C - Data de chegada'
    else
    if nomeArq = 'CTAJOR02' then
        s := 'E - Data de Envio'
    else
    if nomeArq = 'CTAJOR03' then
        s := 'A - Assunto'
    else
    if nomeArq = 'CTAJOR04' then
        s := 'N - Nome'
    else
    if nomeArq = 'CTAJOR05' then
        s := 'T - Tamanho'
    else
    if nomeArq = 'CTAJOR06' then
        s := 'I - Inversa'
    else
    if nomeArq = 'CTQUATOR' then
        s := 'Qual o tipo de ordenação?'
    else
    if nomeArq = 'CTAPCADU' then
        s := 'Apagando cartas duplicadas  não lidas ...'
    else
    if nomeArq = 'CTENAPDU' then
        s := 'Tecle ENTER para apagar as cartas duplicadas não lidas'
    else
    if nomeArq = 'CTCAPREC' then
        s := 'Deseja realmente cancelar o preparo desta carta?'
    else
    if nomeArq = 'CTRECAUT' then
        s := 'Deseja receber as cartas automaticamente: '
    else
    if nomeArq = 'CTDIGBCC' then
        s := 'Digite os endereços eletrônicos para os carbonos ocultos'
    else
    if nomeArq = 'CTOUTPT' then
        s := ' Ou tecle T para todos '
    else
    if nomeArq = 'CTFOLCAR' then
        s := 'Folheamento dos carbonos'
    else
    if nomeArq = 'CTCOPCAR' then
        s := 'Copias carbono'
    else
    if nomeArq = 'CTLISOCT' then
        s := 'Tecle O para carbonos Ocultos, C para não ocultos ou T para ambas as listas'
    else
    if nomeArq = 'CTQLDFOL' then
        s := 'Qual lista carbono deseja folhear?'
    else
    if nomeArq = 'CTTEOCCS' then
        s := 'Tecle O para carbonos ocultos ou C para não ocultos'
    else
    if nomeArq = 'CTLICAVA' then
        s := 'Lista de copias carbono vazia.'
    else
    if nomeArq = 'CTDEREIT' then
        s := 'Deseja remover este item?'
    else
    if nomeArq = 'CTDEREIS' then
        s := 'Deseja remover todos os itens selecionados?'
    else
    if nomeArq = 'CTAJFC01' then
        s := 'Ctrl+A - Apagar'
    else
    if nomeArq = 'CTAJFC02' then
        s := 'Ctrl+Q - Informa quantos do total'
    else
    if nomeArq = 'CTAJFC03' then
        s := 'Ctrl+S - Informa quantos selecionados do total'
    else
    if nomeArq = 'CTAJFA01' then
        s := 'ENTER - Escolhe atual ou selecionados e sai'
    else
    if nomeArq = 'CTEDICAR' then
        s := 'Editando carta ...'
    else
    if nomeArq = 'CTCAEDCA' then
        s := 'Deseja realmente cancelar a edição desta carta?'
    else
    if nomeArq = 'CTCOPCAO' then
        s := 'Copias carbono ocultas'
    else
    if nomeArq = 'CTEDICAN' then
        s := 'Edição cancelada'
    else
    if nomeArq = 'CTCANCEL' then
        s := 'Cancelado'
    else
    if nomeArq = 'CTCONSAI' then
        s := 'Confirma saída do Cartavox?'
    else
    if nomeArq = 'CTSEMDES' then
        s := 'Carta sem destinatário.'
    else
    if nomeArq = 'CTSSLNAO' then
        s := 'Sistema de segurança SSL/TLS não pôde ser ativado'
    else
    if nomeArq = 'CT_SMTP'  then
        s := 'Nome do servidor SMTP'
    else
    if nomeArq = 'CT_SENHA' then
        s := 'SMTP precisa de senha'
    else
    if nomeArq = 'CT_SMSSL' then
        s := 'SMTP com segurança SSL'
    else
    if nomeArq = 'CT_SMTLS'   then
        s := 'SMTP exige segurança TLS'
    else
    if nomeArq = 'CT_PSMTP' then
        s := 'Porta SMTP (0 usa padrão)'
    else
    if nomeArq = 'CT_POP3'  then
        s := 'Nome do servidor POP3'
    else
    if nomeArq = 'CT_SSL'   then
        s := 'POP3 exige segurança'
    else
    if nomeArq = 'CT_PPOP3' then
        s := 'Porta POP3 (0 usa padrão)'
    else
    if nomeArq = 'CT_IMAP' then
        s := 'Nome do servidor IMAP'
    else
    if nomeArq = 'CT_IMAPSSL'   then
        s := 'IMAP exige segurança'
    else
    if nomeArq = 'CT_PIMAP' then
        s := 'Porta IMAP'
    else
    if nomeArq = 'CT_NOME'  then
        s := 'Nome registrado como'
    else
    if nomeArq = 'CT_RESP'  then
        s := 'Endereço para resposta'
    else
    if nomeArq = 'CT_ENDER' then
        s := 'Endereço eletrônico'
    else
    if nomeArq = 'CT_CONTA' then
        s := 'Conta no servidor'
    else
    if nomeArq = 'CT_DIRRC' then
        s := 'Diretório cartas recebidas'
    else
    if nomeArq = 'CT_DIREN' then
        s := 'Diretório cartas a enviar'
    else
    if nomeArq = 'CT_DIRAN' then
        s := 'Diretório para anexos'
    else
    if nomeArq = 'CT_LIMRC' then
        s := 'Limite carta recebida'
    else
    if nomeArq = 'CT_ARQAS' then
        s := 'Arquivo de assinatura'
    else
    if nomeArq = 'CT_ARQAP' then
        s := 'Arquivo de apelidos'
    else
    if nomeArq = 'CT_GUARD' then
        s := 'Guardar cartas enviadas'
    else
    if nomeArq = 'CT_GSENH' then
        s := 'Guardar a senha'
    else
    if nomeArq = 'CTNOVCNF' then
        s := 'Nova configuração do Cartavox'
    else
    if nomeArq = 'CTSETACO' then
        s := 'Use as setas para escolher um dos correios abaixo'
    else
    if nomeArq = 'CTNOME' then
        s := 'Informe seu nome:'
    else
    if nomeArq = 'CTSEUEML' then
        s := 'Qual o seu email neste servidor?'
    else
    if nomeArq = 'CTAPAAPE' then
        s := 'Deseja apagar o apelido? '
    else
    if nomeArq = 'CTOKAPAP' then
        s := 'Ok, apelido apagado'
    else
    if nomeArq = 'CTOKAPES' then
        s := 'Ok, apelidos apagados'
    else
    if nomeArq = 'CTCANREC' then
        s := 'Deseja cancelar o recebimento das cartas? '
    else
    if nomeArq = 'CTCANTRA' then
        s := 'Deseja cancelar a transmissão das cartas? '
    else
    if nomeArq = 'CTREGINI' then
        s := 'Regras'
    else
    if nomeArq = 'CTREGO00' then
        s := 'I - Incluir regra'
    else
    if nomeArq = 'CTREGO01' then
        s := 'A - Aplicar regras nas cartas recebidas'
    else
    if nomeArq = 'CTREG002' then
        s := 'P - Pastas de Regras'
    else
    if nomeArq = 'CTREG003' then
        s := 'R - remover regras'
    else
    if nomeArq = 'CTREGESC' then
        s := 'Digite A para aplicar regra sobre o assunto e R para remetente'
    else
    if nomeArq = 'CTREGAAS' then
        s := 'Digite o assunto sobre o qual deseja aplicar a regra'
    else
    if nomeArq = 'CTREGEXA' then
        s := 'Já existe regra para esse assunto'
    else
    if nomeArq = 'CTREGEXR' then
        s := 'Já existe regra para esse remetente'
    else
    if nomeArq = 'CTREGFAZ' then
        s := 'Tecle P para mover estas cartas para uma pasta ou E para excluir: '
    else
    if nomeArq = 'CTREGPAS' then
        s := 'Para qual pasta você deseja mover essa carta?'
    else
    if nomeArq = 'CTREGAPE' then
        s := 'Deseja aplicar a regra sobre as cartas existentes?'
    else
    if nomeArq = 'CTREGARE' then
        s := 'Digite o email do remetente sobre o qual deseja aplicar a regra.'
    else
    if nomeArq = 'CTREGAPL' then
        s := 'Regras aplicadas'
    else
    if nomeArq = 'CTPASNEN' then
        s := 'Pasta não encontrada'
    else
    if nomeArq = 'CTARQREG' then
        s := 'Arquivo com as regras não existe'
    else
    if nomeArq = 'CTFOLREG' then
        s := 'Folheamento das regras'
    else
    if nomeArq = 'CTFOLPAS' then
        s := 'Folheamento das pastas de regras'
    else
    if nomeArq = 'CTPASTAS' then
        s := ' Pastas'
    else
    if nomeArq = 'CTAPAREG' then
        s := 'Deseja apagar a regra '
    else
    if nomeArq = 'CTREGAPR' then
        s := 'Deseja aplicar as regras sobre as cartas recebidas? '
    else
    if nomeArq = 'CTREGVAZ' then
        s := 'O arquivo de regras está vazio'
    else
    if nomeArq = 'CTREGCAR' then
        s := 'Não existem cartas para aplicar as regras'
    else
    if nomeArq = 'CTCARLIX' then
        s := 'Cartas movidas para a lixeira'
    else
    if nomeArq = 'CTCARPAS' then
        s := 'Cartas movidas para a pasta '
    else
    if nomeArq =  'CT_APREG' then
        s := 'Aplicar regras'
    else
    if nomeArq = 'CTESCPAS' then
        s := 'Escolha com as setas a pasta'
    else
    if nomeArq = 'CT_INASS' then
        s := 'Inserir assinatura'
    else
    if nomeArq = 'CT_INCOR' then
        s := 'Confirmar recebimento'
    else
    if nomeArq = 'CT_FALNP' then
        s := 'Falar nome antes do assunto'
    else
    if nomeArq = 'CT_ORDEN' then
        s := 'Ordenar por data de envio'
    else
    if nomeArq = 'CT_CAORD' then
        s := 'Folhear em ordem decrescente'
    else
    if nomeArq = 'CT_CLEK' then
        s := 'Sonorizar recepção e transmição'
    else
    if nomeArq = 'CT_PERSA' then
        s := 'Perguntar ao sair'
    else
    if nomeArq = 'CT_PERSF' then
        s := 'Perguntar ao sair do folheamento'
    else
    if nomeArq = 'CT_PERCL' then
        s := 'Perguntar confirmação de leitura'
    else
    if nomeArq = 'CT_CABRE' then
        s := 'Cabeçalho resumido na resposta'
    else
    if nomeArq = 'CT_AUDUL' then
        s := 'Enviar duplicadas para lixeira'
    else
    if nomeArq = 'CT_AUTSP' then
        s := 'Matar spam após recebimento'
    else
    if nomeArq = 'CT_ADIOR' then
        s := 'Adicionar original na cópia'
    else
    if nomeArq = 'CT_DIRLI' then
        s := 'Diretório da lixeira'
    else
    if nomeArq = 'CT_DIRSP' then
        s := 'Diretório de Spam'
    else
    if nomeArq = 'CT_ARQCONF' then
        s := 'Arquivo de configurações'
    else
    if nomeArq = 'CT_OPCBA' then
        s := 'Somente opções básicas'
    else
    if nomeArq = 'CTOKRGAP' then
        s := 'Ok, regra apagada'
    else
    if nomeArq = 'CTAJFR01' then
        s := 'Folheie as regras com as setas, depois tecle:'
    else
    if nomeArq = 'CTAJFR02' then
        s := 'A - Apagar regra'
    else
    if nomeArq = 'CTAJFR03' then
        s := 'C - Informar o número de cartas na pasta'
    else
    if nomeArq = 'CTAJFR04' then
        s := 'T - Informar tamanho das cartas na pasta'
    else
    if nomeArq = 'CTAJFR05' then
        s := 'P - Soletrar o nome da pasta'
    else
    if nomeArq = 'CTAJFR06' then
        s := 'R - Soletrar a regra'
    else
    if nomeArq = 'CTAJPA01' then
        s := 'Folheie as pastas com as setas, depois tecle:'
    else
    if nomeArq = 'CTAJPA02' then
        s := 'F - Folhear todas as cartas desta pasta'
    else
    if nomeArq = 'CTCARCNP' then
        s := 'Caracteres /, \, <, >, ", ?, :, * ou | não são permitidos'
    else
    if nomeArq = 'CTMOVCAR' then
        s := 'Deseja mover as cartas desta pasta para o diretório principal?'
    else
    if nomeArq = 'CTMOVCR2' then
        s := 'Se não mover, serão perdidas. '
    else
    if nomeArq = 'CTCARMOV' then
        s := 'Ok, cartas movidas'
        else
    if nomeArq = 'CTRESCON' then
        s := 'O remetente pediu confirmação de leitura. Posso confirmar?'
    else
    if nomeArq = 'CTRECINC' then
        s := 'Confirmação de recebimento incluído'
    else
    if nomeArq = 'CTRECREM' then
        s := 'Confirmação de recebimento removido '
    else
    if nomeArq = 'CTERESPA' then
        s := 'Erro no arquivo da resposta automática'
    else
    if nomeArq = 'CTERFECH' then
        s := 'Erro ao fechar o arquivo'
    else
    if nomeArq = 'CTADBSEL' then
        s := 'Deseja bloquear todos os selecionados? '
    else
    if nomeArq = 'CTADLSEL' then
        s := 'Deseja liberar todos os selecionados? '
    else
    if nomeArq = 'CTBLOREM' then
        s := 'Deseja bloquear este remetente no Mata Spam?'
    else
    if nomeArq = 'CTLIBREM' then
        s := 'Deseja liberar este remetente no Mata Spam?'
    else
    if nomeArq = 'CTLIBERA' then
        s := 'Liberar'
    else
    if nomeArq = 'CTBLOQUE' then
        s := 'Bloquear'
    else
    if nomeArq = 'CTNEIMAP' then
        s := 'Não encontrei o utilitário IMAPUtil.'
    else
    if nomeArq = 'CTSAIFOL' then
        s := 'Deseja sair do folheamento?'
    else
    if nomeArq = 'CTREAUFE' then
        s := 'Resposta automática de férias ativada'
    else
    if nomeArq = 'CTMUQTFO' then
        s := 'São muitas cartas, quantas deseja folhear?'
    else
    if nomeArq = 'CTAJRE01' then
        s := 'E - Escrever Resposta automática'
    else
    if nomeArq = 'CTAJRE02' then
        s := 'A - Ativar Resposta automática de férias'
    else
    if nomeArq = 'CTAJRE03' then
        s := 'A - Editar assunto da resposta automática'
    else
    if nomeArq = 'CTAJRE04' then
        s := 'C - Editar corpo da resposta automática'
    else
    if nomeArq = 'CTEXREAU' then
        s := 'Já existe resposta automática configurada.'
    else
    if nomeArq = 'CTQASSRE' then
        s := 'Qual o assunto da resposta automática?'
    else
    if nomeArq = 'CTATREAU' then
        s := 'Deseja ativar a resposta automática de férias?'
    else
    if nomeArq = 'CTREAUNA' then
        s := 'Resposta automática de férias não foi ativada'
    else
    if nomeArq = 'CTREAUDE' then
        s := 'Resposta automática de férias desativada'
    else
    if nomeArq = 'CTPPREAU' then
        s := 'Preparando resposta automática para '
    else
    if nomeArq = 'CTREAUSE' then
        s := 'Deseja preparar resposta automática para as selecionadas?'
    else
    if nomeArq = 'CTINFSEL' then
        s := 'Tecle C para conhecer as selecionadas.'
    else
    if nomeArq = 'CTREAUPP' then
        s := 'Resposta automática preparada'
    else
    if nomeArq = 'CTMEAUNE' then
        s := 'Resposta automática não foi escrita, deseja escrevê-la agora?'
    else
    if nomeArq = 'CTRESAUT' then
        s := 'Resposta automática'
    else
    if nomeArq = 'CTAJGC01' then
        s := 'A - Adicionar contas ao grupo de contas'
    else
    if nomeArq = 'CTAJGC02' then
        s := 'R - Remover contas do grupo de contas'
    else
    if nomeArq = 'CTFOGRCO' then
        s := 'Folheamento do grupo de contas'
    else
    if nomeArq = 'CTNEXCAD' then
        s := 'Não existem contas a serem adicionadas.'
    else
    if nomeArq = 'CTNEXGRU' then
        s := 'Não existem contas no grupo.'
    else
    if nomeArq = 'CTPAADCO' then
        s := 'Para adicionar a conta '
    else
    if nomeArq = 'CTAOGRCO' then
        s := ' ao grupo de contas, a senha precisa ser gravada. '
    else
    if nomeArq = 'CTDEGRSE' then
        s := 'Deseja gravar a senha desta conta?'
    else
    if nomeArq = 'CTNFAGRC' then
        s := 'não foi adicionada ao grupo de contas'
    else
    if nomeArq = 'CTFOADGR' then
        s := 'Foi adicionada ao grupo de contas'
    else
    if nomeArq = 'CTADGRCO' then
        s := 'Contas adicionadas ao grupo de contas'
    else
    if nomeArq = 'CTREGRCO' then
        s := 'Foi retirada do grupo de contas'
    else
    if nomeArq = 'CTCOREGR' then
        s := 'Contas retiradas do grupo de contas'
    else
    if nomeArq = 'CTSEGRCO' then
        s := 'Seleção do Grupo de contas'
    else
    if nomeArq = 'CTTRCAAU' then
        s := 'Deseja trazer as cartas de todas as contas automaticamente?'
    else
    if nomeArq = 'CTACECON' then
        s := 'Acessando conta '
    else
    if nomeArq = 'CTNECASE' then
        s := 'Não existem cartas nos servidores'
    else
    if nomeArq = 'CTNAECSE' then
        s := 'Não existem contas selecionadas'
    else
    if nomeArq = 'CTAJSE01' then
        s := 'S - Selecionar contas'
    else
    if nomeArq = 'CTAJSE02' then
        s := 'R - Receber cartas das contas selecionadas'
    else
    if nomeArq = 'CTAJSE03' then
        s := 'T - Transmitir cartas das contas selecionadas'
    else
    if nomeArq = 'CTAJSE04' then
        s := 'M - Monitorar contas selecionadas'
    else
    if nomeArq = 'CTAJSE05' then
        s := 'Q - Informar total de cartas das contas selecionadas'
    else
    if nomeArq = 'CTGRDECO' then
        s := 'Grupo de contas'
    else
    if nomeArq = 'CTNAECTR' then
        s := 'Não existem cartas a serem transmitidas na conta '
    else
    if nomeArq = 'CTCOSECO' then
        s := 'Contactando servidor para transmitir cartas da conta '
    else
    if nomeArq = 'CTDETZSE' then
        s := 'Deseja trazer todas as selecionadas?'
    else
    if nomeArq = 'CTDETZAS' then
        s := 'Deseja trazer a carta com o assunto '
    else
    if nomeArq = 'CTOPINSE' then
        s := 'Opção indisponível neste servidor'
    else
    if nomeArq = 'CTMATSPA' then
        s := 'Matando spans'
    else
    if nomeArq = 'CTNENSPA' then
        s := 'Não encontrou Spam'
    else
    if nomeArq = 'CTENSPVI' then
        s := 'Número de spans e vírus encontrados: '
    else
    if nomeArq = 'CTCARAPR' then
        s := 'Cartas aprovadas: '
    else
    if nomeArq = 'CTUTSETA' then
        s := 'Use as setas, tecle ESC para sair'
    else
    if nomeArq = 'CTENTINI' then
        s := 'Aperte Enter para gravar, Enter de novo termina.'
    else
    if nomeArq = 'CTESCUTA' then
        s := 'Quer escutar o recado? '
    else
    if nomeArq = 'CTGRVCAN' then
        s := 'Gravação cancelada.'
    else
    if nomeArq = 'CTPRBMP3' then
        s := 'Problema ao converter para MP3, código: '
    else
    if nomeArq = 'CTANESOM' then
        s := 'Tecle A para anexar ou ESC para cancelar'
    else
    if nomeArq = 'CTEXREGR' then
        s := 'Já existe recado gravado'
    else
    if nomeArq = 'CTDESDIV' then
        s := 'Deseja gerar uma carta para cada destinatário?'
    else
    if nomeArq = 'CTDIGSAU' then
        s := 'Digite a saudação ou deixe em branco para nenhuma:'
else
    if nomeArq = 'CTAJLUOP' then
        s := 'O - outras opções'
    else
    if nomeArq = 'CTAJUD18' then
        s := 'F - outros folheamentos '
    else
    if nomeArq = 'CTAJUD19' then
        s := 'P - preparar carta e transmitir'
    else
    if nomeArq = 'CTAJUD20' then
        s := 'M - mais opções'
    else
    if nomeArq = 'CTAJUD21' then
        s := 'G      - Não lidas agrupando por assunto'
    else
    if nomeArq = 'CTAJUD22' then
        s := 'Ctrl+G - Desta configuração agrupadas por assunto'
    else
    if nomeArq = 'CTAJUD23' then
        s := 'Ctrl+F - Recebidas desta configuração'
    else
    if nomeArq = 'CTAJUD24' then
        s := 'Ctrl+N - Não lidas desta configuração'
    else
    if nomeArq = 'CTAJUD25' then
        s := 'Ctrl+L - Lidas desta configuração'
    else
    if nomeArq = 'CTAJUD26' then
        s := 'Ctrl+J - No servidor sem falar'
    else
    if nomeArq = 'CTAJUD27' then
        s := 'Ctrl+R - receber cartas do correio sem falar'
    else
    if nomeArq = 'CTAJUD28' then
        s := 'Ctrl+S - mata Spam e recebe cartas'
    else
    if nomeArq = 'CTAJUD29' then
        s := 'Ctrl+I - soletrar nome da configuração'
    else
    if nomeArq = 'CTAJUD30' then
        s := 'Ctrl+T - transmitir cartas desta configuração'
    else
    if nomeArq = 'CTAJUD31' then
        s := 'Ctrl+Y - mata Spam nas cartas não lidas desta configuração'
    else
    if nomeArq = 'CTAJUD32' then
        s := 'Ctrl+Z - receber cartas das contas selecionadas'
    else
    if nomeArq = 'CTAJUD33' then
        s := 'Ctrl+X - transmitir cartas das contas selecionadas'
    else
    if nomeArq = 'CTAJUD34' then
        s := 'Ctrl+C - monitorar contas selecionadas'
    else
    if nomeArq = 'CTAJUD35' then
        s := 'Ctrl+Q - informar total de cartas das contas selecionadas'
    else
    if nomeArq = 'CTAJUD36' then
        s := 'D - ativar e desativar modo debug'
    else
    if nomeArq = 'CTAJUD37' then
        s := 'Control + R - ativa e desativa recebimento automático'
else
    if nomeArq = 'CTAJUD38' then
        s := 'ESC - sair do monitoramento'
    else
    if nomeArq = 'CTAJUHORA' then
        s := 'F8 - falar hora'
    else
    if nomeArq = 'CTAJUDATA' then
        s := 'Ctrl+F8 - falar data'
    else
    if nomeArq = 'CTOUTOPC' then
        s := 'Outras opções'
    else
    if nomeArq = 'CTOUFOL' then
        s := 'Outros folheamentos'
    else
    if nomeArq = 'CTMAISOPC' then
        s := 'Mais opções'
    else
    if nomeArq = 'CTAJFL33' then
        s := 'Seta esquerda - Falar conteúdo do assunto'
    else
    if nomeArq = 'CTAJFL34' then
        s := 'Seta direita - Falar assunto completo'
    else
    if nomeArq = 'CTAJFL35' then
        s := 'F7 - Apagar carta'
    else
    if nomeArq = 'CTAJFL36' then
        s := 'J - Alterar entre modo falar primeiro assunto ou nome'
    else
    if nomeArq = 'CTAJFL37' then
        s := 'Ctrl+I - Soletrar nome da configuração'
    else
    if nomeArq = 'CTAJFL38' then
        s := 'P - Mostrar itens do cabeçalho'
    else
    if nomeArq = 'CTAJFL39' then
        s := 'Ctrl+A - Apagar a carta sem mandar para a lixeira'
    else
    if nomeArq = 'CTAJFL40' then
        s := '* ou Ctrl+S - Selecionar todas as cartas'
    else
    if nomeArq = 'CTAJFL41' then
        s := 'Ctrl+P - Próximas cartas agrupadas por assunto'
    else
    if nomeArq = 'CTAJFL42' then
        s := 'Barra de espaços - Selecionar ou tirar seleção'
    else
    if nomeArq = 'CTAJFL43' then
        s := '/ - Tirar a seleção de todas'
    else
    if nomeArq = 'CTAJFL44' then
        s := 'S - Opções de seleção'
    else
    if nomeArq = 'CTAJFL45' then
        s := 'M - Mais opções de informação e procura'
    else
    if nomeArq = 'CTDEMASE' then
        s := 'Deseja marcar as cartas selecionadas?'
    else
    if nomeArq = 'CTDEDESE' then
        s := 'Deseja desmarcar as cartas selecionadas?'
    else
    if nomeArq = 'CTENFONL' then
        s := 'Entre no folheamento de não lidas para usar esta opção.'
    else
    if nomeArq = 'CTFOEMIN' then
        s := 'Formato de e-mail inválido.'
    else
    if nomeArq = 'CTMATSPM' then
        s := 'Matando spams ...'
    else
    if nomeArq = 'CTMATASP' then
        s := 'Matador de spans'
    else
    if nomeArq = 'CTEDDIEM' then
        s := 'Editore o diretório de e-mail ou tecle enter para utilizar o padrão:'
    else
 if nomeArq = 'CTNAOEXT' then
        s := 'Não existem selecionadas'
    else
    if nomeArq = 'CTADICC' then
        s := 'Deseja adicionar os contatos carbono da carta?'
    else
    if nomeArq = 'CTAJLA01' then
        s := 'A ou seta baixo - avançar nas cartas'
    else
    if nomeArq = 'CTAJLA02' then
        s := 'R ou seta cima - recuar nas cartas'
    else
    if nomeArq = 'CTAJLA03' then
        s := 'F - alternar entre listar ou não  anexos'
    else
    if nomeArq = 'CTGRCASE' then
        s := 'Deseja gravar as partes das cartas selecionadas?'
    else
    if nomeArq = 'CTGRPANO' then
        s := 'Gravar partes que tem nome'
    else
    if nomeArq = 'CTAJGP01' then
        s := 'Seta esquerda - fala remetente e assunto'
    else
    if nomeArq = 'CTAJGP02' then
        s := 'Seta direita - fala assunto e remetente'
    else
    if nomeArq = 'CTNPSTXT' then
        s := 'Não é permitido editar sem texto na primeira parte.'
    else
    if nomeArq = 'CTTROCON' then
        s := 'Deve trocar a configuração para realizar esta operação'

    else
        s := nomeArq;
//        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{       dá uma mensagem
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
{       da mensagem na ultima linha
{--------------------------------------------------------}

procedure msgBaixo (nomeArq: string);
var y: integer;
begin
    textBackGround (BLACK);
    if wherey = 25 then
        begin
             clreol;
             writeln;
        end;

    y := wherey;

    gotoxy (1, 25);
    clreol;

    if nomeArq <> '' then
        begin
            textBackground (RED);
            gotoxy (80-length(pegaTextoMensagem (nomeArq)), 25);
            mensagem (nomeArq, 0);
            textBackground (BLACK);
        end;

    gotoxy (0, y);
end;

{--------------------------------------------------------}
{       bipa no speaker
{--------------------------------------------------------}

procedure bipSpeaker (pitch: integer);
begin
    windows.Beep (pitch, 80);
end;

{--------------------------------------------------------}

begin
end.
