{-------------------------------------------------------------}
{
{    Webvox - Módulo de mensagens
{
{    Autor: Jose' Antonio Borges
{
{    Em 14/05/98
{
{-------------------------------------------------------------}

unit webMsg;

interface

uses dvcrt, dvWin, dvWav,
    windows, sysUtils,
     WebVars;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure prepSonsTags (nomeAmb: string);
procedure somTag (tag: string);
procedure falaTamanhoArq (tam: longint);

const
    TXTTITULO = '*** Título da Página: ';
    TXTFIMTITULO = ' ***';
    TXTFRAMES = 'Partes divisórias desta página (frames)';
    TXTTRANSCRITA = 'Transcrita em ';
    TXREFERENCIAS = 'Referências desta página';
    MAPACLICAVEL = 'Mapa clicável';
    FIGCLICAVEL = 'Figura clicável';
    TXTSUBMIT = 'Botão Enviar';
    TXTRESET = 'Botão Limpar';
    TXTSELECT = 'Selecionar opção';
    TXTSELECMULT = 'Selecionar múltiplos';
    TXTMETAACESSO = 'Acesso alternativo a esta página';
    TXTPORCENTO = ' por cento lido';

    TXTTEXT = 'Campo de entrada';
    TXTPASSWORD = 'Campo de senha';
    TXTRADIO = 'Botão de rádio';
    TXTLIGADO = ' - Marcado';
    TXTDESLIGADO = ' - Desmarcado';
    TXTCHECKBOX = 'Botão de escolha';

    TXTNENHUMA = 'Nenhuma';

    TXTFIMPAG = '*** Fim da Página ***';

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'WBINIC' then
        s := 'WEBVOX - NCE/UFRJ - v.'
    else
    if nomeArq = 'WBWEBVOX' then
        s := 'WEBVOX'
    else
    if nomeArq = 'WBCONTAC' then
        s := 'Contactando...  '
    else
    if nomeArq = 'WBERRCOM' then
        s := 'Não consegui ativar o sistema de comunicações do micro'
    else
    if nomeArq = 'WBNAOCON' then
        s := 'Não consegui realizar a conexao'
    else
    if nomeArq = 'WBPAGNAO' then
        s := 'Página não achada'
    else
    if nomeArq = 'WBCONOK' then
        s := 'Conexão realizada'
    else
    if nomeArq = 'WBCNFFIM' then
        s := 'Confirma fim (s/n): '
    else
    if nomeArq ='WBERRDSK' then
        s := 'Problemas para gravar texto no disco'
    else
    if nomeArq ='WBRECINT' then
        s := 'Recepção interrompida'
    else
    if nomeArq = 'WBNAOPAG' then
        s := 'Página não foi trazida'
    else
    if nomeArq = 'WBMSGSRV' then
        s := 'Mensagem do servidor'
    else
    if nomeArq ='WBINFARQ' then
        s := 'Informe o nome do arquivo a carregar'
    else
    if nomeArq ='WBARQNAO' then
        s := 'Este arquivo não existe'
    else
    if nomeArq ='WBOK' then
        s := 'OK'
    else
    if nomeArq ='WBTRAAPA' then
        s := 'Arquivo de trabalho foi apagado'
    else
    if nomeArq ='WBAJU101' then
        s := 'Tecle um nome no formato usual da web, por exemplo:'
    else
    if nomeArq ='WBAJU102' then
        s := 'http://www.nomedaempresa.com.br'
    else
    if nomeArq ='WBAJU103' then
        s := 'Para acessar a página do DOSVOX tecle'
    else
    if nomeArq ='WBAJU104' then
        s := 'http://caec.nce.ufrj.br'
    else
    if nomeArq ='WBCOMCAN' then
        s := 'Comunicação cancelada'
    else
    if nomeArq ='WBPAGTRA' then
        s := 'Informe o nome da página a trazer (? ajuda)'
    else
    if nomeArq ='WBSEMPAG' then
        s := 'Não tenho página na memória'
    else
    if nomeArq ='WBPAGINC' then
        s := 'Nome de página incompatível com este programa'
    else
    if nomeArq ='WBSOHTTP' then
        s := 'Este programa só aceita páginas HTTP ou FTP'
    else
    if nomeArq ='WBNAOCAR' then
        s := 'Não existe página carregada'
    else
    if nomeArq ='WBPAGALT' then
        s := 'Buscando página alternativa'
    else
    if nomeArq ='WBARQTXT' then
        s := 'Arquivando pagina em formato texto'
    else
    if nomeArq ='WBNOMGRV' then
        s := 'Qual o nome do arquivo a gravar ? '
    else
    if nomeArq = 'WBEDINOM' then
        s := 'Editore o nome, tecle ENTER para confirmar ou ESC para cancelar: '
    else
    if nomeArq ='WBREGRAV' then
        s := 'Arquivo existente.  Opções: limpar, adicionar ou desistir ? '
    else
    if nomeArq ='WBERRTXT' then
        s := 'Erro ao gravar o arquivo texto'
    else
    if nomeArq ='WBARQHTM' then
        s := 'Arquivando pagina no formato original'
    else
    if nomeArq ='WBERRGRD' then
        s := 'Problemas para gravar arquivo no disco'
    else
    if nomeArq ='WBCOPTRU' then
        s := 'Não coube na área de transferência, foi truncado'
    else
    if nomeArq ='WBBLKCPY' then
        s := 'Bloco copiado'
    else
    if nomeArq ='WBFIM' then
        s := 'Acesso à WEB terminado'
    else
    if nomeArq ='WBQUALOP' then
        s := 'Qual sua opção ? '
    else
    if nomeArq ='WBOPERR' then
        s := 'Opção inválida, aperte F1 para ajuda'
    else
    if nomeArq ='WBNAOLEV' then
        s := 'Erro ao executar o programa leitor'
    else
    if nomeArq ='WBQUEREF' then
        s := 'Deseja referências listadas no texto ? '
    else
    if nomeArq ='WBFIMLEI' then
        s := 'Escolha: S - Sair, V - voltar para pagina anterior'
    else
    if nomeArq = 'WBAJU01' then
        s := 'As opções são:'
    else
    if nomeArq = 'WBAJU02' then
        s := '  T    trazer página da rede'
    else
    if nomeArq = 'WBAJU03' then
        s := '  L    ler página'
    else
    if nomeArq = 'WBAJU04' then
        s := '  V    voltar à última página lida'
    else
    if nomeArq = 'WBAJU05' then
        s := '  S    páginas selecionadas'
    else
    if nomeArq = 'WBAJU06' then
        s := '  A    trazer a página de um arquivo local'
    else
    if nomeArq = 'WBAJU07' then
        s := '  G    gravar página em texto'
    else
    if nomeArq = 'WBAJU08' then
        s := '  O    gravar no formato original'
    else
    if nomeArq = 'WBAJU09a' then
        s := '  X    exportar texto da página para área de transferência'
    else
    if nomeArq = 'WBAJU10' then
        s := '  C    configurar o programa'
    else
    if nomeArq = 'WBAJU11' then
        s := '  I    falar em outra língua'
    else
    if nomeArq = 'WBAJU12' then
        s := '  N    trazer página sem ler'
    else
    if nomeArq = 'WBAJU13' then
        s := '  R    recarregar esta página'
    else
    if nomeArq = 'WBAJU14' then
        s := '  P    guardar página preferida'
    else
    if nomeArq = 'WBAJU15' then
        s := '  E    enviar página por email'
    else
    if nomeArq = 'WBAJU16' then
        s := '  B    carregar páginas do buscador'
    else
    if nomeArq = 'WBAJU19' then
        s := '  ESC  terminar o programa'
    else
    if nomeArq ='WBINITXT' then
        s := 'Voltei ao início do texto'
    else
    if nomeArq ='WBFIMTXT' then
        s := 'Fui para o fim do texto'
    else
    if nomeArq ='WVAJUN1' then
        s := 'Os comandos são:'
    else
    if nomeArq ='WVAJUN2' then
        s := 'CIMA e BAIXO  caminham e leem o texto'
    else
    if nomeArq = 'WVAJUN3' then
        s := 'DIREITA       avança para o próximo texto ou elo'
    else
    if nomeArq ='WVAJUN4' then
        s := 'Espaço/CTLF1  leitura contínua'
    else
    if nomeArq ='WVAJUN5' then
        s := 'ENTER         entra neste elo da página'
    else
    if nomeArq ='WVAJUN6' then
        s := 'TAB           pula para ler o próximo elo'
    else
    if nomeArq ='WVAJUN7' then
        s := 'BS            pula para ler o elo anterior'
    else
    if nomeArq ='WVAJUN8' then
        s := 'PGUP e PGDN   pula parágrafo'
    else
    if nomeArq ='WVAJUN9' then
        s := 'CTL PGUP      início e fim da página'
    else
    if nomeArq ='WVAJUN10' then
        s := 'CTL PGDN      início e fim da página'
    else
    if nomeArq ='WVAJUN11' then
        s := 'HOME          detalha cláusula de HTML'
    else
    if nomeArq = 'WVAJUN12' then
        s := 'F3            Le nome da página atual'
    else
    if nomeArq = 'WVAJUN13' then
        s := 'F4            Configura'
    else
    if nomeArq = 'WVAJUN14' then
        s := 'F5            Busca texto (control F5 busca de novo)'
    else
    if nomeArq = 'WVAJUN15' then
        s := 'F6            Informa percentual lido da página'
    else
    if nomeArq ='WVAJUN19' then
        s := 'ESC           termina leitura'
    else
    if nomeArq ='WBVOLPAG' then
        s := 'Voltando à pagina anterior'
    else
    if nomeArq ='WBNAOVOL' then
        s := 'Não posso, estou na primeira página lida'
    else
    if nomeArq = 'WBCOMBMK' then
        s := 'Digite um comentário para esta seleção'
    else
    if nomeArq = 'WBUSESET' then
        s := 'Use setas, depois comande trazer, informação ou apagar'
    else
    if nomeArq = 'WBSETLER' then
        s := 'Use setas para ler, F1 ajuda'
    else
    if nomeArq = 'WBSEMBMK' then
        s := 'Não foram registradas páginas seletas'
    else
    if nomeArq = 'WBBMKREM' then
        s := 'Removido'
    else
    if nomeArq = 'WBDESIST' then
        s := 'Desistiu...'
    else
    if nomeArq = 'WBFOLADI' then
        s := 'Folhear ou adicionar ? '
    else
    if nomeArq = 'WBDIGPAG' then
        s := 'Qual o nome da página desejada ?'
    else
    if nomeArq = 'WBCMDINV' then
        s := 'Comando inválido, F1 ajuda'
    else
    if nomeArq = 'WBNAOLNK' then
        s := 'Não há mais referencias nesta página'
    else
    if nomeArq = 'WBTIPO' then
        s := 'Tipo de Controle: '
    else
    if nomeArq = 'WBSOLET' then
        s := 'Soletre ou edite com as setas, ESC termina'
    else
    if nomeArq = 'WBTRAPAG' then
        s := 'Trazendo página'
    else
    if nomeArq = 'WBTIPNAO' then
        s := 'Tipo não processavel, para armazenar use a funcao O'
    else
    if nomeArq = 'WBNAOEXE' then
        s := 'Execução do programa trazido não foi possível'
    else
    if nomeArq = 'WBINTEXT' then
        s := 'Campo de entrada, pode editar, valor atual'
    else
    if nomeArq = 'WBCHKBOX' then
        s := 'Ítem múltiplo de seleçao: '
    else
    if nomeArq = 'WBRADIO' then
        s := 'Ítem único de seleção: '
    else
    if nomeArq = 'WBPMARCA' then
        s := 'Deixa essa marca ? '
    else
    if nomeArq = 'WBLIGADO' then
        s := ' ligado. '
    else
    if nomeArq = 'WBDESLIG' then
        s := ' desligado. '
    else
    if nomeArq = 'WBLIGA' then
        s := 'Devo ligar ? '
    else
    if nomeArq = 'WBINPASS' then
        s := 'Campo de senha, pode digitar'
    else
    if nomeArq = 'WBINSUBM' then
        s := 'Botão de envio, aperte S para submeter'
    else
    if nomeArq = 'WBINRSET' then
        s := 'Botão para limpar formulario, aperte S para limpar'
    else
    if nomeArq = 'WBRESTAD' then
        s := 'Formulário recriado'
    else
    if nomeArq = 'WMSUBMET' then
        s := 'Submetendo formulário'
    else
    if nomeArq = 'WBCAMPOD' then
        s := 'Campo de digitação, tecle ENTER para editar'
    else
    if nomeArq = 'WBPODEDI' then
        s := 'Pode editar, use ESC para sair'
    else
    if nomeArq = 'WBLINREM' then
        s := 'Linha removida'
    else
    if nomeArq = 'WBSELSET' then
        s := 'Selecione a opção desejada com as setas depois ENTER ou ESC'
    else
    if nomeArq = 'WBSEMULT' then
        s := 'Você pode marcar mais de uma seleção'
    else
    if nomeArq = 'WBFIMPAG' then
        s := 'Fim da pagina'
    else
    if nomeArq = 'WBNAODSP' then
        s := 'Operação não disponível'
    else
    if nomeArq = 'WBCARNAO' then
        s := 'Erro no disco, carta não foi enviada'
    else
    if nomeArq = 'WBENVCAR' then
        s := 'Enviando a carta'
    else
    if nomeArq = 'WBSRVNAO' then
        s := 'Servidor não aceitou conexão, diagnóstico'
    else
    if nomeArq = 'WBFIMENV' then
        s := 'Fim do envio'
    else
    if nomeArq = 'WBERRENV' then
        s := 'Erro de comunicação ao enviar a carta'
    else
    if nomeArq = 'WBABREDI' then
        s := 'Abrindo editor'
    else
    if nomeArq = 'WBERREDI' then
        s := 'Erro ao acionar o editor de textos'
    else
    if nomeArq = 'WBASSCAR' then
        s := 'Qual o assunto da carta ? '
    else
    if nomeArq = 'WBCNFENV' then
        s := 'Confirma envio ?'
    else
    if nomeArq = 'WBQUALTX' then
        s := 'Qual o texto a buscar ? '
    else
    if nomeArq = 'WBNAOACH' then
        s := 'Texto não encontrado após esta posição'
    else
    if nomeArq = 'WBPGSEGU' then
        s := 'Página segura, vou tentar processar sem segurança'
    else
    if nomeArq = 'WBFRAMES' then
        s := '--- Partes divisórias desta página ---'
    else
    if nomeArq = 'WBINIFRM' then
        s := '--- Início do Formulário ---'
    else
    if nomeArq = 'WBFIMFRM' then
       s := '--- Fim do Formulário ---'
    else
    if nomeArq = 'WBMARK' then
        s := ' marcado'
    else
    if nomeArq = 'WBDMARK' then
        s := ' desmarcado'
    else
    if nomeArq = 'WBJAVA' then
        s := 'Simulando Java Script'
    else
    if nomeArq = 'WBMINFTP' then
        s := 'Mini FTP ativado'
    else
    if nomeArq = 'WBCNTFTP' then
        s := 'Contactando servidor de FTP em '
    else
    if nomeArq = 'WBDIRFTP' then
        s := 'Recebendo diretório remoto de '
    else
    if nomeArq = 'WBRECFTP' then
        s := 'Recebendo arquivo '
    else
    if nomeArq = 'WBSELLOC' then
        s := 'Selecionando arquivo local'
    else
    if nomeArq = 'WBAUTENT' then
        s := 'Servidor solicitou autenticação'
    else
    if nomeArq = 'WBCONTA' then
        s := 'Informe sua conta  '
    else
    if nomeArq = 'WBSENHA' then
        s := 'Informe sua senha  '
    else
    if nomeArq = 'WBERRAUT' then
        s := 'Autenticação não foi aceita'
    else

    if nomeArq = 'WBEDIT' then
       s := 'Editore o nome da página atual'
    else
    if nomeArq = 'WBINFILE' then
         s := 'Campo de entrada, informe o nome do arquivo'
    else
    if nomeArq = 'WBJAEXI1' then
        s := 'O arquivo destino '
    else
    if nomeArq = 'WBJAEXI2' then
        s := ' já existe.  Sobrescreve (S/N)? '

    else
    if nomeArq = 'WBSETCNF' then
        s := 'Use as setas, editore as configurações e depois tecle ESC'
    else
    if nomeArq = 'WBVELFAL' then
        s := 'Velocidade de fala, de 1 a 5'
    else
    if nomeArq = 'WBFALAPT' then
       s := 'Fala pontuação ? '
    else
    if nomeArq = 'WBNIVINF' then
        s := 'Nível textual, resumido, normal ou detalhado '
    else
    if nomeArq = 'WBSONREC' then
        s := 'Sonorizar no download'
    else
    if nomeArq = 'WBSAPALT' then
        s := 'Voz sapi da língua alternativa'
    else
    if nomeArq = 'WBVELALT' then
        s := 'Velocidade da língua alternativa'
    else
    if nomeArq = 'WBTOMALT' then
        s := 'Tonalidade da língua alternativa'
    else
    if nomeArq = 'WBLEALT' then
        s := 'Lendo com a síntese alternativa'
    else
    if nomeArq = 'WBLEORIG' then
        s := 'Lendo com síntese original'

    else
    if nomeArq = 'WBENHTLM' then
        s := 'Ok, irei enviar em formato html'
    else
    if nomeArq = 'WVCNVPDR' then
        s := 'Deseja usar a conversão padrão ? (S/N): '
    else
    if nomeArq = 'WBMANTPD' then
        s := 'Não existe nenhum item relacionado, terei de manter o padrão'
    else
    if nomeArq = 'WBDIGOT' then
        s := 'Digite O para enviar em formato original ou T para texto: '
    else
    if nomeArq = 'WBPQUEM' then
        s := 'Para quem você deseja enviar esta página ? '
    else
    if nomeArq = 'WBOPCANC' then
        s := 'Operação cancelada'
    else
    if nomeArq = 'WBDESEDI' then
        s := 'Deseja editar o arquivo ? '
    else
    if nomeArq = 'WBCNFASU' then
        s := 'Confirma como assunto : '
    else
    if nomeArq = 'WBSN' then
        s := ' (S/N) : '
    else
    if nomeArq = 'WBDIGNVA' then
        s := 'Então digite um novo assunto: '
    else
    if nomeArq = 'WBSEUEND' then
        s := 'Seu endereço é: '
    else
    if nomeArq = 'WBDIGNVE' then
        s := 'Digite então o novo endereço: '

    else
    if nomeArq = 'WBOPCAT0' then
        s := 'Opções nas teclas:'
    else
    if nomeArq = 'WBOPCAT1' then
        s := 'A  Apaga Catálogo'
    else
    if nomeArq = 'WBOPCAT2' then
        s := 'C  Cria Catálogo'
    else
    if nomeArq = 'WBOPCAT3' then
        s := 'T  Totaliza Catálogos'
    else
    if nomeArq = 'WBOPCAT8' then
        s := 'ENTER  Carrega o Catálogo Selecionado'
    else
    if nomeArq = 'WBOPCAT9' then
        s := 'SETAS  Caminham entre os Catálogos Existentes'

    else
    if nomeArq = 'WBNOMCAT' then
        s := 'Qual será o nome deste novo catálogo ? '
    else
    if nomeArq = 'WBCATCRI' then
        s := ' foi criado'
    else
    if nomeArq = 'WBCNFEXC' then
        s := 'Confirma a exclusão de '
    else
    if nomeArq = 'WBFOIEXC' then
        s := ' foi excluído'
    else
    if nomeArq = 'WBCATVAZ' then
        s := 'Seu catálogo está vazio, F1 ajuda'
    else
    if nomeArq = 'WBESCCAT' then
        s := 'Escolha o catálogo de sua preferência com as setas, F1 ajuda'
    else
    if nomeArq = 'WBCATULT' then
        s := 'último'
    else
    if nomeArq = 'WBCATPRM' then
        s := 'primeiro'
    else
    if nomeArq = 'WBSEMCAT' then
        s := 'Não posso, não existe nenhum catálogo selecionado'
    else
    if nomeArq = 'WBNCRCAT' then
        s := 'Não posso criar mais catálogos, o número máximo é 25'
    else
    if nomeArq = 'WBCATEXI' then
        s := 'Existem '
    else
    if nomeArq = 'WBCATLIS' then
        s := ' catálogos a serem listados'
    else
    if nomeArq = 'WBCATNSL' then
        s := 'Não posso, não existe nenhum catálogo selecionado'
    else
    if nomeArq = 'WBOPINVS' then
        s := 'Opção inválida, use as setas, F1 ajuda'
    else
    if nomeArq = 'WBCNTSEL' then
        s := 'Continue selecionando ou tecle ESC para sair'

    else
    if nomeArq = 'WBEDPREF' then
        s := 'Editore o nome da página preferida'

    else
    if nomeArq = 'WBERRGPG' then
        s := 'Erro ao guardar referência da página'
    else
    if nomeArq = 'WBGZIP' then
        s := 'Descomprimindo com GZIP'
    else
    if nomeArq = 'WBGZIPNO' then
        s := 'GZIP não está instalado'
    else
    if nomeArq = 'WBCANCEL' then
        s := 'Confirma o cancelamento? (S/N): '
    else
    if nomeArq = 'WBOPCA2' then
        s := 'E  Edita Catálogo'
    else
    if nomeArq = 'WBEXECAT' then
        s := 'Executor ativado'

    else
    if nomeArq = 'WBBUSGRV' then
        s := 'Vou tentar buscar e gravar '
    else
    if nomeArq = 'WBOKGRAV' then
        s := 'Ok, já gravei '
    else
    if nomeArq = 'WBVCNCRI' then
        s := 'Você não criou o arquivo de busca automática (buscador.ini)'
    else
    if nomeArq = 'WBORITXT' then
        s := 'Digite O para formato original ou T para texto'
    else
    if nomeArq = 'WBJACONS' then
        s := 'Ok, as páginas já constam no diretório especificado'
    else
    if nomeArq = 'WBNAOGRA' then
        s := 'Não gravei página alguma'
    else
    if nomeArq = 'WBTIPSAP' then
        s := 'Tipo SAPI (4 ou 5) da língua alternativa'

    else
    if nomeArq = 'WBCOMPXY' then
        s := 'Sua conexão utiliza um proxy?'
    else
    if nomeArq = 'WBENDPXY' then
        s := 'Endereço do Proxy'
    else
    if nomeArq = 'WBPORPSY' then
        s := 'Porta do Proxy'
    else
    if nomeArq = 'WBEXCPXY' then
        s := 'Arquivo de excessões de proxy'
    else
    if nomeArq = 'WBEDITOR' then
        s := 'Editor de textos'
    else
    if nomeArq = 'WBCARQBU' then
        s := 'Arquivo de páginas do Buscador'
    else
    if nomeArq = 'WBCDIRBU' then
        s := 'Diretório do Buscador'
    else
    if nomeArq = 'WBCDIRDW' then
        s := 'Diretório de downloads'
    else
    if nomeArq = 'WBCOBLOQ' then
        s := 'Conteúdo do site está bloqueado.'
    else
    if nomeArq = 'WBAPTENT' then
        s := 'Aperte enter'

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

{-------------------------------------------------------------}
{               prepara os sons dos tags
{-------------------------------------------------------------}

procedure prepSonsTags (nomeAmb: string);
var arq: text;
    s: string;
    i, p: integer;
begin
    for i := 1 to nSomTags do
        dispose (tabSomTags [i]);

    nSomTags := 0;

    if nomeAmb = '' then exit;

    assign (arq, nomeAmb);
    {$I-} reset (arq); {$I+}
    if ioresult <> 0 then exit;

    while not eof (arq) do
        begin
            readln (arq, s);
            if (s <> '') and (upcase(s[1]) in ['A'..'Z', '/']) then
                begin
                    p := pos ('=', s);
                    if p <> 0 then
                        begin
                            nSomTags := nSomTags + 1;
                            new (tabSomTags [nSomTags]);
                            with tabSomTags [nSomTags]^ do
                                begin
                                    nomeTag := copy (s, 1, p-1);
                                    while (nomeTag <> '') and (nomeTag[1] = ' ') do
                                        delete (nomeTag, 1, 1);
                                    while (nomeTag <> '') and (nomeTag[length(nomeTag)] = ' ') do
                                        delete (nomeTag, length(nomeTag), 1);
                                    for i := 1 to length (nomeTag) do
                                         nomeTag [i] := upcase (nomeTag[i]);
                                    somTag := copy (s, p+1, length (s)-p);
                                    while (somTag <> '') and (somTag[1] = ' ') do
                                        delete (somTag, 1, 1);
                                end
                        end
                    else
                        begin
                            write ('Erro em ', nomeAmb, ' ');
                            writeln (s);
                        end;

                end;
        end;

    close (arq);
end;

{-------------------------------------------------------------}
{                  executa o som do tag
{-------------------------------------------------------------}

procedure somtag (tag: string);
var i: integer;
begin
    if keypressed then exit;

    for i := 1 to nSomTags do
        with tabSomTags [i]^ do
            if nomeTag = tag then
                begin
                  if somTag <> '' then
                     begin
                         while sintFalando do waitMessage;      { interrompe com keypressed }
                         if keypressed then exit;
                         wavePlayFile (dirTags+'\'+somTag+'.WAV');
                     end;
                end;
end;

{--------------------------------------------------------}
{       Fala o tamanho do arquivo
{--------------------------------------------------------}

procedure falaTamanhoArq (tam: longint);
var
    medida: char;
    decimal: integer;
begin
    medida := ' ';
    if tam >= 65536 then
        begin
            medida := 'K';
            decimal := tam mod 1024;
            tam := tam div 1024;
            if decimal > 512 then tam := tam + 1;
        end;

    sintWrite (intToStr (tam) + medida);
end;

end.
