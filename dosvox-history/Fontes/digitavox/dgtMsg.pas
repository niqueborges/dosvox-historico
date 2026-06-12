{--------------------------------------------------------}
{
{           Digitavox - mensagens
{
{       Autor: Neno Henrique da Cunha Albernaz
{       neno'intervox.nce.ufrj.br
{       Em 05 de Outubro de 2019
{
{--------------------------------------------------------}

unit dgtMsg;

interface

uses
    dvcrt,
    dvWin,
    dvLenum,
    sysUtils,
    windows,
    dgtVars;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure msgBaixo (nomeArq: string);
procedure soletra(s: string; nlf: integer);
procedure sintetFala (s: string; nlf: integer);
function tocaEfeito (nomeArqEfeito: string): boolean;

implementation

{--------------------------------------------------------}
{       descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if      nomeArq = 'DGTINIC'        then s := 'Digitavox - Cursos de digitação - Versão '
    else if nomeArq = 'DGTDIGVER'      then s := 'Digitavox Versão'
    else if nomeArq = 'DGTCURDIG'      then s := 'Cursos de digitação'
    else if nomeArq = 'DGTVERSAO'      then s := ' - Versão '
    else if nomeArq = 'DGTNPCUR'       then s := 'Erro: pasta de Cursos não encontrada.'
    else if nomeArq = 'DGRTNPUSU'      then s := 'Erro: pasta de usuários não encontrada.'
    else if nomeArq = 'DGTERRPRE'      then s := 'Erro: pasta de relatórios não encontrada.'
    else if nomeArq = 'DGTERRREL'      then s := 'Erro ao criar o arquivo do relatório.'
    else if nomeArq = 'DGTRETOCU'      then s := 'Gerando relatório ...'
    else if nomeArq = 'DGTGERESE'      then s := 'Gera relatório dos selecionados?'
    else if nomeArq = 'DGTRELGER'      then s := 'Relatório gerado'
    else if nomeArq = 'DGTERESDI'      then s := 'Erro de escrita no disco'
    else if nomeArq = 'DGTNEARQ'       then s := 'Erro: não existe arquivo de curso válido na pasta '
    else if nomeArq = 'DGTERRUSU'      then s := 'Erro ao carregar o arquivo do usuário'
    else if nomeArq = 'DGTCONSAI'      then s := 'Confirma saída do Digitavox?'
    else if nomeArq = 'DGTDESIST'      then s := 'Desistiu ...'
    else if nomeArq = 'DGTFIM'         then s := 'Fim do Digitavox'
    else if nomeArq = 'DGTQUAOPC'      then s:= 'Qual sua opção? F1 ajuda'
    else if nomeArq = 'DGTSELSET'      then s:= 'Selecione a opção com as setas verticais e tecle Enter na desejada'

    else if nomeArq = 'DGTAJCU_R'      then s := '     R        - Reconhecimento de teclado'
    else if nomeArq = 'DGTAJCU_CU'     then s := '     C        - Cursos de digitação'
    else if nomeArq = 'DGTAJCU_U'      then s := '     U        - Usuário logado'
    else if nomeArq = 'DGTAJCU_TE'      then s := '     T        - Alterar teclagem'
    else if nomeArq = 'DGTAJCU_AST'      then s := '     *        - Configurar'
    else if nomeArq = 'DGTAJCU_SDD'    then s := '     ESC      - Sair do Digitavox'

    else if nomeArq = 'DGTAPEFAL'      then s := 'Aperte as teclas e eu falarei.'
    else if nomeArq = 'DGTRECTER'      then s := 'O reconhecimento será terminado quando você apertar ESCAPE'
    else if nomeArq = 'DGTRECENC'      then s := 'O reconhecimento está encerrado.'
    else if nomeArq = 'DGTSHIFT'       then s := '<shift>'
    else if nomeArq = 'DGTNUM'         then s := '<num.lock>'
    else if nomeArq = 'DGTNONUM'       then s := '<sem num.lock>'
    else if nomeArq = 'DGTCAPS'        then s := '<caps lock>'
    else if nomeArq = 'DGTNOCAPS'      then s := '<sem caps lock>'
    else if nomeArq = 'DGTCTLALT'      then s := '<control alt>'
    else if nomeArq = 'DGTCONTRL'      then s := '<control>'
    else if nomeArq = 'DGTALT'         then s := '<alt>'
    else if nomeArq = 'DGTBLWIN'       then s := '<iniciar>'
    else if nomeArq = 'DGTBRWIN'       then s := '<iniciar>'
    else if nomeArq = 'DGTBRAPPL'      then s := '<aplicações>'
    else if nomeArq = 'DGTBPAUSE'      then s := '<pause>'
    else if nomeArq = 'DGTBSLOCK'      then s := '<scroll lock>'
    else if nomeArq = 'DGTBPRSCR'      then s := '<print screen>'
    else if nomeArq = 'DGTTEC_BS'      then s := '<backspace>'
    else if nomeArq = 'DGTTEC_TAB'     then s := '<tab>'
    else if nomeArq = 'DGTTEC_AGU'     then s := '<agudo>'
    else if nomeArq = 'DGTTEC_APOST'   then s := '<apóstrofo>'
    else if nomeArq = 'DGTTEC_BRNCO'   then s := '<barra de espaços>'
    else if nomeArq = 'DGTTEC_ENTER'   then s := '<enter>'
    else if nomeArq = 'DGTTEC_ESC'     then s := '<escape>'
    else if nomeArq = 'DGTTEC_F1'      then s := '<F1>'
    else if nomeArq = 'DGTTEC_F2'      then s := '<F2>'
    else if nomeArq = 'DGTTEC_F3'      then s := '<F3>'
    else if nomeArq = 'DGTTEC_F4'      then s := '<F4>'
    else if nomeArq = 'DGTTEC_F5'      then s := '<F5>'
    else if nomeArq = 'DGTTEC_F6'      then s := '<F6>'
    else if nomeArq = 'DGTTEC_F7'      then s := '<F7>'
    else if nomeArq = 'DGTTEC_F8'      then s := '<F8>'
    else if nomeArq = 'DGTTEC_F9'      then s := '<F9>'
    else if nomeArq = 'DGTTEC_F10'     then s := '<F10>'
    else if nomeArq = 'DGTTEC_F11'     then s := '<F11>'
    else if nomeArq = 'DGTTEC_F12'     then s := '<F12>'
    else if nomeArq = 'DGTTEC_INS'     then s := '<ins>'
    else if nomeArq = 'DGTTEC_DEL'     then s := '<del>'
    else if nomeArq = 'DGTTEC_HOME'    then s := '<home>'
    else if nomeArq = 'DGTTEC_END'     then s := '<end>'
    else if nomeArq = 'DGTTEC_PGUP'    then s := '<page up>'
    else if nomeArq = 'DGTTEC_PGDN'    then s := '<page down>'
    else if nomeArq = 'DGTTEC_CIMA'    then s := '<cima>'
    else if nomeArq = 'DGTTEC_BAIX'    then s := '<baixo>'
    else if nomeArq = 'DGTTEC_ESQ'     then s := '<esquerda>'
    else if nomeArq = 'DGTTEC_DIR'     then s := '<direita>'

    else if nomeArq = 'DGTLISCUR'      then s := 'Lista de cursos de digitação'
    else if nomeArq = 'DGTUSESET'      then s := 'Use as setas para selecionar, depois tecle sua opção. F1 ajuda'
    else if nomeArq = 'DGTSELESC'      then s := 'Continue selecionando ou tecle ESC para sair'
    else if nomeArq = 'DGTOPVINV'      then s := 'Opção inválida, aperte F1 para ajuda'
    else if nomeArq = 'DGTSAIDIGI'     then s := 'Gostaria de realmente sair do Digitavox? '
    else if nomeArq = 'DGTSELEC'       then s := 'selecionado'
    else if nomeArq = 'DGTSELECS'      then s := 'selecionados'
    else if nomeArq = 'DGTDE'          then s := 'de'
    else if nomeArq = 'DGTAJUOPC'      then s := 'As opções são'
    else if nomeArq = 'DGTAJU_F9'      then s := 'Aperte F9 para conhecer outras opções'
    else if nomeArq = 'DGTOK'          then s := 'Ok'
    else if nomeArq = 'DGTTECACI'      then s := 'Teclagem acionada'
    else if nomeArq = 'DGTTECDES'      then s := 'Teclagem desligada'

    else if nomeArq = 'DGTAJCU_SE'     then s := 'Seta esquerda - Fala a apresentação'
    else if nomeArq = 'DGTAJCU_SD'     then s := 'Seta direita  - Fala a instrução'
    else if nomeArq = 'DGTAJCU_EN'     then s := '     Enter    - Entrar no curso'
    else if nomeArq = 'DGTAJCU_L'      then s := '     L        - Total de lições do curso'
    else if nomeArq = 'DGTAJCU_C'      then s := '     C        - Ultima lição concluída'
    else if nomeArq = 'DGTAJCU_N'      then s := '     N        - Nome do arquivo do curso'
    else if nomeArq = 'DGTAJCU_Q'      then s := '     Q        - Informa qual o curso do total'
    else if nomeArq = 'DGTAJCU_D'      then s := '     D        - Dados sobre lição'
    else if nomeArq = 'DGTAJCU_T'      then s := '     T        - Desafio do tempo'
    else if nomeArq = 'DGTAJCU_E'      then s := '     E        - Estatísticas do curso'
    else if nomeArq = 'DGTAJCU_G'      then s := '     G        - Gerar relatório'

    else if nomeArq = 'DGTDIGNOM'      then s := 'Digite seu nome para identificação, depois tecle Enter para entrar.'
    else if nomeArq = 'DGTUSUANO'      then s := 'Sem nome, deseja entrar como anônimo?'
    else if nomeArq = 'DGTNAUIN'       then s := 'Erro: nome de usuário inválido, por favor digite letras.'
    else if nomeArq = 'DGTTUSUARI'     then s := 'Usuário '
    else if nomeArq = 'DGTNAOCAD'      then s := ' não cadastrado.'
    else if nomeArq = 'DGTDECAUS'      then s := 'Deseja cadastrá-lo agora? '
    else if nomeArq = 'DGTERCRARQ'     then s := 'Não foi possível cadastrar este nome, por favor tente outro.'
    else if nomeArq = 'DGTBEMVIN'      then s := 'Bem-vindo, '
    else if nomeArq = 'DGTDEHAB'       then s := 'O Digitavox vai te ajudar a desenvolver habilidades no teclado do computador.'
    else if nomeArq = 'DGTDESAF'       then s := 'Desafio'
    else if nomeArq = 'DGTNUMDE'       then s := 'Digite um número maior que 1 para dividir o tempo: '
    else if nomeArq = 'DGTDIVTEM'      then s := 'Divisor do tempo '
    else if nomeArq = 'DGTESSEDT'      then s := 'Escolha com as setas o divisor do tempo desejado e tecle Enter'

    else if nomeArq = 'DGTVOLICU'      then s := 'Voltando a lista de cursos ...'
    else if nomeArq = 'DGTLICAO'       then s := 'Lição'
    else if nomeArq = 'DGTLIPRO'       then s := 'Esta lição está com problema ...'
    else if nomeArq = 'DGTNELICU'      then s := 'Nenhuma lição deste curso foi concluída'
    else if nomeArq = 'DGTLISLIC'      then s := 'Lições do curso'
    else if nomeArq = 'DGTLICUR'       then s := 'Lições do curso'
    else if nomeArq = 'DGTAJLI_EN'     then s := '     Enter    - Entra na lição'
    else if nomeArq = 'DGTAJLI_N'      then s := '     N        - Fala o nome do curso'
    else if nomeArq = 'DGTAJLI_Q'      then s := '     Q        - Informa qual a lição do total disponível'
    else if nomeArq = 'DGTAJLI_E'      then s := '     E        - Fala exercícios da lição'
    else if nomeArq = 'DGTAJLI_A'      then s := '     A        - Fala apresentação do curso'
    else if nomeArq = 'DGTAJLI_I'      then s := '     I        - Fala instrução do curso'
    else if nomeArq = 'DGTAJLI_T'      then s := '     T        - Fala o desafio do tempo'

    else if nomeArq = 'DGTQUALI'       then s := 'Qual o número da lição?'
    else if nomeArq = 'DGTDIGDE'       then s := 'Digite de '
    else if nomeArq = 'DGTDADLI'       then s := 'Leia os dados da lição com as setas verticais, tecle ESC para sair'
    else if nomeArq = 'DGTPRXLI'       then s := 'Tecle Enter para começar a lição'
    else if nomeArq = 'DGTCURCON'      then s := 'Parabéns! Concluiu o curso.'
    else if nomeArq = 'DGTREPLI'       then s := 'Tecle Enter para repetir a lição'
    else if nomeArq = 'DGTPOUREP'      then s := 'Poucas repetições'
    else if nomeArq = 'DGTEXERC'       then s := 'Exercício'

    else if nomeArq = 'DGTMINESQ'      then s := 'Mínimo esquerdo'
    else if nomeArq = 'DGTANEESQ'      then s := 'Anelar esquerdo'
    else if nomeArq = 'DGTMEDESQ'      then s := 'Médio esquerdo'
    else if nomeArq = 'DGTINDESQ'      then s := 'Indicador esquerdo'
    else if nomeArq = 'DGTMINDIR'      then s := 'Mínimo direito'
    else if nomeArq = 'DGTANEDIR'      then s := 'Anelar direito'
    else if nomeArq = 'DGTMEDDIR'      then s := 'Médio direito'
    else if nomeArq = 'DGTINDDIR'      then s := 'Indicador direito'
    else if nomeArq = 'DGTPOLEGAR'     then s := 'Polegar'

    else if nomeArq = 'DGTEXPBKP'      then s := 'Apaga um caracter a esquerda em um texto.' // backspace
    else if nomeArq = 'DGTEXPTAB'      then s := 'Salta nos objetos de uma janela e tabula textos.' // Tab
    else if nomeArq = 'DGTEXPBSP'      then s := 'Insere espaço em branco em um texto, aciona um botão e marca um item.'
    else if nomeArq = 'DGTEXPENT'      then s := 'Executa um item em uma lista e insere uma nova linha em um texto.'
    else if nomeArq = 'DGTEXPBAR'      then s := 'Operador de divisão em uma conta.'
    else if nomeArq = 'DGTEXPAST'      then s := 'Operador de multiplicação em uma conta.'
    else if nomeArq = 'DGTEXPINF'      then s := 'Operador de subtração em uma conta'
    else if nomeArq = 'DGTEXPMAI'      then s := 'Operador de adição em uma conta.'
    else if nomeArq = 'DGTEXPFND'      then s := 'Função operacional, atalho em programas.'
    else if nomeArq = 'DGTEXPF1'       then s := 'Ajuda dos programas.'
    else if nomeArq = 'DGTEXPHOM'      then s := 'Posiciona  no início da linha em um texto e primeiro item em uma lista.'
    else if nomeArq = 'DGTEXPEND'      then s := 'Posiciona no fim da linha em um texto e último item em uma lista.'
    else if nomeArq = 'DGTEXPDEL'      then s := 'Apaga um caracter a direita em um texto e um item em uma lista.'
    else if nomeArq = 'DGTEXPINS'      then s := 'Combina com outras para atalhos em programas, como em leitores de tela.'
    else if nomeArq = 'DGTEXPPGD'      then s := 'Avança 15 itens em uma lista e algumas linhas em um texto.'
    else if nomeArq = 'DGTEXPPGU'      then s := 'Recua 15 itens em uma lista e algumas linhas em um texto.'
    else if nomeArq = 'DGTEXPBAI'      then s := 'Posiciona no próximo item em uma lista e proxima linha em um texto.'
    else if nomeArq = 'DGTEXPCIM'      then s := 'Posiciona no item anterior em uma lista e  na linha anterior em um texto.'
    else if nomeArq = 'DGTEXPDIR'      then s := 'Salta um caracter a direita em um texto. Ctrl seta para direita avança uma palavra.'
    else if nomeArq = 'DGTEXPESQ'      then s := 'Salta um caracter para a esquerda em um texto. Ctrl seta para esquerda recua uma palavra.'
    else if nomeArq = 'DGTEXPSHIFT'    then s := 'Colocar letras em maiúsculo ou acessar a segunda função de uma tecla.'
    else if nomeArq = 'DGTEXPCAPS'     then s := 'Ativa ou desativa caixa alta.'
    else if nomeArq = 'DGTEXPNUMLO'    then s := ' Alternar entre as duas funções das teclas do teclado numérico.'
    else if nomeArq = 'DGTEXPALTGR'    then s := 'Combina com outras teclas como atalho para acessar programas. É também utilizada para acessar a terceira função de algumas teclas.'
    else if nomeArq = 'DGTEXPCTRL'     then s := 'Combinada com outras teclas vira atalhos, como Ctrl C que é copiar e Ctrl V que é colar.'
    else if nomeArq = 'DGTEXPALT'      then s := 'Acessa menu dos sistemas, conbinada com outras teclas vira atalhos.'
    else if nomeArq = 'DGTEXPBINIW'    then s := 'Abre menu de acesso aos aplicativos do Windows, é também utilizada como atalho quando combinada com outras teclas.'
    else if nomeArq = 'DGTEXPAPLIC'    then s := 'Exibe lista de opções em janelas de alguns aplicativos.'
    else if nomeArq = 'DGTEXPPAUSA'    then s := 'Parar o processamento atual, funciona mais em MS-DOS para pausar as telas.'
    else if nomeArq = 'DGTEXPSCROLL'   then s := 'Tecla modificadora das setas, deixando-as com praticamente a mesma função do botão de rolagem dos mouses'
    else if nomeArq = 'DGTEXPPRINT'    then s := 'Copia a imagem da tela para a área de transferência.'

    else if nomeArq = 'DGTAJPRA_SE'    then s := 'Seta esquerda - Fala a repetição atual  e o total'
    else if nomeArq = 'DGTAJPRA_SD'    then s := 'Seta direita  - Fala o restante do exercício'
    else if nomeArq = 'DGTAJPRA_CSD'   then s := 'Ctrl direita  - Soletra o restante do exercício'
    else if nomeArq = 'DGTAJPRA_SB'    then s := 'Seta baixo    - Fala a próxima letra a digitar e com qual dedo'
    else if nomeArq = 'DGTAJPRA_SC'    then s := 'Seta cima     - Fala o exercício atual'
    else if nomeArq = 'DGTAJPRA_CSE'   then s := 'Ctrl esquerda - Fala percentual de acertos'
    else if nomeArq = 'DGTAJPRA_CSC'   then s := 'Ctrl cima     - Fala a apresentação'
    else if nomeArq = 'DGTAJPRA_CSB'   then s := 'Ctrl baixo    - Fala a instrução'
    else if nomeArq = 'DGTAJPRA_F2'    then s := '     F2       - Fala a próxima letra a digitar e com qual dedo'
    else if nomeArq = 'DGTAJPRA_F3'    then s := '     F3       - Soletra o restante do exercício'
    else if nomeArq = 'DGTAJPRA_F4'    then s := '     F4       - Fala o restante do exercício'
    else if nomeArq = 'DGTAJPRA_F5'    then s := '     F5       - Fala o exercício atual'
    else if nomeArq = 'DGTAJPRA_F6'    then s := '     F6       - Fala a lição e repete a apresentação'
    else if nomeArq = 'DGTAJPRA_F7'    then s := '     F7       - Repete a instrução da lição'
    else if nomeArq = 'DGTAJPRA_F8'    then s := '     F8       - Fala a hora'
    else if nomeArq = 'DGTAJPRA_F12'   then s := '     F12      - Fala o tempo decorrido, o total e o percentual gasto'
    else if nomeArq = 'DGTAJPRA_ESC'   then s := '     ESC      - Cancela a prática da lição'

    else if nomeArq = 'DGTTECIN'       then s := 'Tecla Invalida, retornando ao exercício ...'
    else if nomeArq = 'DGTEXCERR'      then s := 'Excesso de erro, tecle F1 para ajuda.'
    else if nomeArq = 'DGTPARABE'      then s := 'Parabéns! Lição concluída.'
    else if nomeArq = 'DGTMEIN'        then s := 'Percentual de acerto insuficiente, por favor refaça a lição.'
    else if nomeArq = 'DGTTMPESG'      then s := 'Tempo esgotado'
    else if nomeArq = 'DGTTPDECO'      then s := 'Tempo decorrido:'
    else if nomeArq = 'DGTTPTOT'       then s := 'Tempo total:'
    else if nomeArq = 'DGTPERGAS'      then s := 'Percentual gasto'
    else if nomeArq = 'DGTESTLI'       then s := 'Leia as estatísticas da lição com as setas verticais, tecle ESC para sair'
    else if nomeArq = 'DGTNAOEST'      then s := 'Não existe estatísticas para o curso'
    else if nomeArq = 'DGTLCEST'       then s := 'Estatísticas do curso'
    else if nomeArq = 'DGTSTENES'      then s := 'selecione com as setas verticais, tecle Enter para ver as estatísticas. F1 ajuda.'
    else if nomeArq = 'DGTNAOCON'      then s := 'Não concluída'
    else if nomeArq = 'DGTCHEFIM'      then s := 'Chegou no fim'
    else if nomeArq = 'DGTNCHFIM'      then s := 'Não chegou no fim'
    else if nomeArq = 'DGTSELFIL'      then s := 'Selecione o filtro com as setas e tecle Enter'
    else if nomeArq = 'DGTMESLI'       then s := 'Mesma lição'
    else if nomeArq = 'DGTCONCLU'      then s := 'Concluídas'
    else if nomeArq = 'DGTNAOCOS'      then s := 'Não concluídas'
    else if nomeArq = 'DGTCOMAPE'      then s := 'Concluídas com maior performance'
    else if nomeArq = 'DGTCOMEPE'      then s := 'Concluídas com menor performance'
    else if nomeArq = 'DGTDESPRA'      then s := 'Desistiu da prática'
    else if nomeArq = 'DGTNAESTE'      then s := 'Não esgotou tempo'
    else if nomeArq = 'DGTMEDETE'      then s := 'Mesmo desafio de tempo'
    else if nomeArq = 'DGTDIDETE'      then s := 'Escolher desafio de tempo'
    else if nomeArq = 'DGTMESDA'       then s := 'Mesma data'
    else if nomeArq = 'DGTFILAPL'      then s := 'Filtro aplicado'
    else if nomeArq = 'DGTLIVAZ'       then s := 'Listagem vazia'

    else if nomeArq = 'DGTAJES_SE'     then s := 'Seta esquerda - Fala se foi concluída'
    else if nomeArq = 'DGTAJES_SD'     then s := 'Seta direita  - Fala se chegou no fim'
    else if nomeArq = 'DGTAJES_EN'     then s := '     Enter    - exibe estatísticas da lição'
    else if nomeArq = 'DGTAJES_Q'      then s := '     Q        - Informa qual item da lista do total'
    else if nomeArq = 'DGTAJES_F5'     then s := '     F5       - Filtrar a lista'
    else if nomeArq = 'DGTAJ_ESC'      then s := '     ESC      - Sair'

    else if nomeArq = 'DGTCONFAV'      then s := 'Digitavox - Configuração avançada'
    else if nomeArq = 'DGTVELFAL'      then s := 'Velocidade de fala, de 3 a 5'
    else if nomeArq = 'DGTCOMEFE'      then s := 'Com efeito'
    else if nomeArq = 'DGTFALTEC'      then s := 'Falar teclagem'
    else if nomeArq = 'DGTFIMCFG'      then s := 'Fim da configuração'

    else if nomeArq = 'DGTAJUCF_OPC'   then s := 'As opções de fala gravada são: '
    else if nomeArq = 'DGTAJUCF_N'     then s := '  N - velocidade normal'
    else if nomeArq = 'DGTAJUCF_R'     then s := '  R - voz mais rápida'
    else if nomeArq = 'DGTAJUCF_B'     then s := '  B - voz de boneca'
    else if nomeArq = 'DGTCONF'        then s := 'Digitavox - Configuração'
    else if nomeArq = 'DGTSEFGRA'      then s := 'Selecione a velocidade da fala gravada: '
    else if nomeArq = 'DGTUMMOME'      then s := 'Um momento...'
    else if nomeArq = 'DGTSINTET'      then s := 'Sintetizador, use as setas para selecionar'
    else if nomeArq = 'DGTVELOCS'      then s := 'Velocidade '
    else if nomeArq = 'DGTTONALS'      then s := 'Tonalidade '
    else if nomeArq = 'DGTAJUCS_V'     then s := 'Velocidade (-10 a 10) '
    else if nomeArq = 'DGTAJUCS_T'     then s := 'Tonalidade (-10 a 10) '
    else if nomeArq = 'DGTAJUCS_SINT'  then s := 'Sintetizador ativado: '
    else if nomeArq = 'DGTAJUCS_NAO'   then s := 'Voz não encontrada'
    else if nomeArq = 'DGTAJUCS_SIN'   then s := 'Configurações de fala sintetizada'
    else if nomeArq = 'DGTAJUCS_NAT'   then s := 'Fala nativa ativada'
    else if nomeArq = 'DGTCONFIRMA'    then s := 'Confirma? '
    else if nomeArq = 'DGTSIMNAO'      then s := ' (S/N)? '
    else if nomeArq = 'DGTDESRECCONF'  then s := 'Deseja recuperar a configuração original de instalação?'
    else if nomeArq = 'DGTAJUTIL'      then s := '  Pode usar as setas para selecionar ou conhecer todas as opções'
    else if nomeArq = 'DGTAJUC_OPC'    then s := 'As opções de configuração são:'
    else if nomeArq = 'DGTAJUC_F'      then s := '  F - Fala gravada'
    else if nomeArq = 'DGTAJUC_S'      then s := '  S - Fala sintetizada'
    else if nomeArq = 'DGTAJUC_O'      then s := '  O - outras configurações'
    else if nomeArq = 'DGTAJUC_R'      then s := '  R - recuperar configuração original'
    else if nomeArq = 'DGTCONFIG'      then s := 'Configurações - '
    else if nomeArq = 'DGTOQUE'        then s := 'O que você deseja? '

    else
        s := '--> Mensagem inválida: ' + nomeArq;

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

procedure soletra(s: string; nlf: integer);
var i: integer;
begin
    if nlf >= 0 then
         write (s);
     for i := 1 to nlf do
         writeln;
     for i := 1 to length (s) do
         sintSoletra (s[i]);
end;

{--------------------------------------------------------}

procedure sintetFala (s: string; nlf: integer);
var i: integer;
begin
    if nlf >= 0 then
         write (s);
     for i := 1 to nlf do
         writeln;

    if length (s) > 0 then
        sintetiza (s);
end;

{--------------------------------------------------------}

function tocaEfeito (nomeArqEfeito: string): boolean;
begin
    result := true;
    if comEfeitos and existeArqSom ('Efeitos\' + nomeArqEfeito) then
        sintSom ('Efeitos\' + nomeArqEfeito)
    else
    result := false;
end;

{--------------------------------------------------------}

begin
end.
