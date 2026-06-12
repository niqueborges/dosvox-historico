{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Módulo de mensagens
{
{    Autores: José Antonio Borges
{             Lidiane Figueira Silva
{             Bernard Condorcet
{
{    Em Janeiro/2009
{
{--------------------------------------------------------}

unit jomsg;

interface

uses
    dvcrt, dvWin, dvform, sysUtils, windows, joVars;

function pegaTextoMensagem (nomeArq: string): string;
procedure msgMuda (nomeArq: string; nlf: integer);
procedure mensagem (nomeArq: string; nlf: integer);
procedure tocaOuSintetiza (msg: string);
procedure limpaMensagens;
function strbool (b: boolean): string;
function pergunta (msg: string; npula: integer; cor: integer): char;
procedure campo (nomeArqSom: string;
                 var valor: shortstring; tamanho: integer);
procedure campoLista (nomeArqSom: string;
                 var valor: shortstring; tamanho: integer; listaSepPtvg: string);
procedure menuAdiciona (cod: string);

const
    diasDaSemana: array [0..6] of string =
        ('Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado');

implementation

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'JOINIC'     then s := 'Jogavox - editor de jogos educacionais'
    else
    if nomeArq = 'JOVERSAO'   then s := 'Versão '
    else
    if nomeArq = 'JOFIM'      then s := 'Fim do Jogavox'
    else
    if nomeArq = 'JOJOGCRIB'   then s := 'Opção: Jogar, Criar, Editar ou Baixar? '
    else
    if nomeArq = 'JOJOGAR'    then s := 'Jogar'
    else
    if nomeArq = 'JOCRIAR'    then s := 'Criar'
    else
    if nomeArq = 'JOEDITAR'   then s := 'Editar'
    else
    if nomeArq = 'JOBAIXAR'   then s := 'Baixar'
    else
    if nomeArq = 'JONOMJOG'   then s := 'Informe o nome do jogo ou use as setas'
    else
    if nomeArq = 'JONOMNOV'   then s := 'Informe o novo nome deste jogo:'
    else
    if nomeArq = 'JONOMNOV'   then s := 'Informe o nome do novo jogo'
    else
    if nomeArq = 'JOASSMES'   then s := 'Assumido o mesmo do diretório'
    else
    if nomeArq = 'JODESTRU'   then s := 'Posso destruir o jogo existente? '
    else
    if nomeArq = 'JODESIST'   then s := 'Desistiu'
    else
    if nomeArq = 'JOERRCRI'   then s := 'Erro ao criar o arquivo'
    else
    if nomeArq = 'JOARQOK'    then s := 'Arquivo gravado'
    else
    if nomeArq = 'JONAOGRV'   then s := 'Ok, as modificações não foram gravadas'
    else
    if nomeArq = 'JONAOTEM'   then s := 'Este diretório não tem arquivos .JOG'
    else
    if nomeArq = 'JODIRNAO'   then s := 'Diretório de jogos não foi encontrado'
    else
    if nomeArq = 'JOESCPAS'   then s := 'Escolha uma pasta de jogos com as setas'
    else
    if nomeArq = 'JODIRATU'   then s := 'Foi assumido o diretório atual para as pastas de jogos'
    else
    if nomeArq = 'JODIRACR'   then s := 'Informe o nome do diretório a criar para o jogo'
    else
    if nomeArq = 'JOERCONEC'   then s := 'Não foi possível conectar com o servidor de upload'
    else
    if nomeArq = 'JOERARQ'   then s := 'Arquivo a enviar foi apagado ou não existe'
    else
    if nomeArq = 'JOPRENV'   then s := 'Preparando jogo para envio. Por favor, aguarde.'
    else
    if nomeArq = 'JOPRENV2'   then s := 'Jogo pronto para envio'
    else
    if nomeArq = 'JOINFCONTA'   then s := 'Informe o nome de sua conta. Teclando enter, assumo conta pública'
    else
    if nomeArq = 'JOINFSENHA'   then s := 'Informe sua senha:'
    else
    if nomeArq = 'JOENVIANDO'   then s := 'Enviando jogo, por favor, aguarde.'
    else
    if nomeArq = 'JOESCUSE'   then s := 'Escolha um dos seguintes usuários com as setas'
    else
    if nomeArq = 'JOENVIADO'   then s := 'Jogo enviado com sucesso!'
    else
    if nomeArq = 'JOERROENV1'   then s := 'Erro ao enviar o jogo'
    else
    if nomeArq = 'JOERROENV2'   then s := 'Mensagem do servidor:'
    else
    if nomeArq = 'JOCNAOENC'   then s := 'Programa zip.exe não foi encontrado'
    else
    if nomeArq = 'JODIREXI'   then s := 'Diretório já existia, posso reusar? '
    else
    if nomeArq = 'JOERCRIA'   then s := 'Erro ao criar o diretório'
    else
    if nomeArq = 'JOERACED'   then s := 'Erro ao acessar o diretório criado'

    else
    if nomeArq = 'JOOPPRIN'   then s := 'Editando o jogo'
    else
    if nomeArq = 'JOOPCAO'    then s := 'Jogavox - qual sua opção? '
    else
    if nomeArq = 'JOOPSET'    then s := 'Escolha a opção com as setas.'
    else
    if nomeArq = 'JOAJP_R2'   then s := 'R - Roteiro do jogo'
    else
    if nomeArq = 'JOAJP_D'    then s := 'D - editar dados gerais.'
    else
    if nomeArq = 'JOAJP_C'    then s := 'C - configurar apresentação.'
    else
    if nomeArq = 'JOAJP_E'    then s := 'E - Editar os lugares do jogo.'
    else
    if nomeArq = 'JOAJP_P'    then s := 'P - Programação avançada.'
    else
    if nomeArq = 'JOAJP_S'    then s := 'S - Salvar o projeto.'
    else
    if nomeArq = 'JOAJP_N'    then s := 'N - Salvar com outro nome.'
    else
    if nomeArq = 'JOAJP_I'    then s := 'I - Importar mídias para o jogo.'
    else
    if nomeArq = 'JOAJP_G'    then s := 'G - Gerar um roteiro a partir do jogo'
    else
    if nomeArq = 'JOAJP_X'    then s := 'X - Executar o jogo.'
    else
    if nomeArq = 'JOAJP_U'    then s := 'U - Publicar o jogo.'
    else
    if nomeArq = 'JOAJP_A'    then s := 'A - Abandonar sem gravar.'
    else
    if nomeArq = 'JOAJP_ES'   then s := 'ESC - Terminar'
    else
    if nomeArq = 'JOCONFAL'   then s := 'Confirma as alterações? '

    else
    if nomeArq = 'JOERRARQ'   then s := 'Erro ao ler o arquivo do jogo'
    else
    if nomeArq = 'JOLINHA'    then s := 'O problema está na linha '
    else
    if nomeArq = 'JOCONTEU'   then s := 'Conteúdo lido:'
    else
    if nomeArq = 'JOLSLINV'   then s := 'Lugar do slide inválido'
    else
    if nomeArq = 'JOEDILOC'   then s := 'Editando os lugares do jogo'
    else
    if nomeArq = 'JOEDISET'   then s := 'Escolha o lugar com as setas, depois tecle F9.'
    else
    if nomeArq = 'JOF1F9'     then s := 'Aperte F9 para menu, F1 para ajuda.'
    else
    if nomeArq = 'JOOPCOES'   then s := 'As opções são:'
    else
    if nomeArq = 'JOAJU_I'    then s := 'I - inserir novo lugar'
    else
    if nomeArq = 'JOAJU_E'    then s := 'E - editar características do lugar'
    else
    if nomeArq = 'JOAJU_M'    then s := 'M - mover'
    else
    if nomeArq = 'JOAJU_R'    then s := 'R - remover lugar'
    else
    if nomeArq = 'JOAJU_V'    then s := 'V - visualizar'
    else
    if nomeArq = 'JOAJU_S'    then s := 'S - editar os slides'
    else
    if nomeArq = 'JOAJU_PX'   then s := 'P - programação extra'
    else
    if nomeArq = 'JOAJU_X'    then s := 'X - executar a partir daqui'
    else
    if nomeArq = 'JOOPINV'    then s := 'Opção inválida'
    else
    if nomeArq = 'JOTITLUG'   then s := 'Informe o nome do lugar:'
    else
    if nomeArq = 'JOANTDEP'   then s := 'Insere antes ou depois daqui? '

    else
    if nomeArq = 'JOSEMSLD'   then s := 'Este lugar ainda não tem nenhum slide.'
    else
    if nomeArq = 'JOCRIAUT'   then s := 'Posso criar automaticamente? '
    else
    if nomeArq = 'JOEDISLI'   then s := 'Editando os slides do jogo'
    else
    if nomeArq = 'JOSLISET'   then s := 'Escolha o slide com as setas, tecle F9 para opções'
    else
    if nomeArq = 'JOAJS_I'    then s := 'I - inserir novo slide'
    else
    if nomeArq = 'JOAJS_M'    then s := 'M - mover slide'
    else
    if nomeArq = 'JOAJS_R'    then s := 'R - remover slide'
    else
    if nomeArq = 'JOAJS_E'    then s := 'E - editar slide'
    else
    if nomeArq = 'JOAJS_D'    then s := 'D - duplicar slide'
    else
    if nomeArq = 'JOAJS_V'    then s := 'V - visualizar slide'

    else
    if nomeArq = 'JOEDSLID'   then s := 'Editore o slide, ESC termina'
    else
    if nomeArq = 'JOLUGINV'   then s := 'Lugar inválido'
    else
    if nomeArq = 'JOCONREM'   then s := 'Confirma a remoção? '
    else
    if nomeArq = 'JONAOIMP'   then s := 'Não implementado'
    else
    if nomeArq = 'JOEDNLUG'   then s := 'Editando lugar'
    else
    if nomeArq = 'JOSLDINV'   then s := 'Slide inválido'
    else
    if nomeArq = 'JOTITSLD'   then s := 'Informe o título do slide'

    else
    if nomeArq = 'JONAOEXI'   then s := 'Arquivo não existe.'
    else
    if nomeArq = 'JOQUERCR'   then s := 'Quer editar um novo jogo?'

    else
    if nomeArq = 'JOINFMOV'   then s := 'Informe o lugar para o qual vai mover'
    else
    if nomeArq = 'JOSLDMAX'   then s := 'Excedido o máximo de slides do lugar'
    else
    if nomeArq = 'JOCNFFIM'   then s := 'Confirma fim? '
    else
    if nomeArq = 'JOCNFABN'   then s := 'Confirma abandono sem gravar? '
    else
    if nomeArq = 'JOAPTENT'   then s := 'Aperte enter'

    else
    if nomeArq = 'JOAUTOR'    then s := 'Autor: '
    else
    if nomeArq = 'JOVERSAO'   then s := 'Versão: '

    else
    if nomeArq = 'JO_NOME'    then s := 'Nome do Jogo'
    else
    if nomeArq = 'JO_AUTOR'   then s := 'Autor'
    else
    if nomeArq = 'JO_CRIAC'   then s := 'Data de Criação'
    else
    if nomeArq = 'JO_VERS'    then s := 'Versão'
    else
    if nomeArq = 'JO_DATA'    then s := 'Data da versão'
    else
    if nomeArq = 'JO_COMEN1'   then s := 'Comentários: 1'
    else
    if nomeArq = 'JO_COMEN2'   then s := '2'
    else
    if nomeArq = 'JO_COMEN3'   then s := '3'
    else
    if nomeArq = 'JO_COMEN4'   then s := '4'
    else
    if nomeArq = 'JO_COMEN5'   then s := '5'

    else
    if nomeArq = 'JO_IMG'     then s := 'Imagem de fundo'
    else
    if nomeArq = 'JO_FONTE'   then s := 'Fonte do texto'
    else
    if nomeArq = 'JO_TFONT'   then s := 'Tamanho'
    else
    if nomeArq = 'JO_NEGRI'   then s := 'Negrito'
    else
    if nomeArq = 'JO_ALEAT'   then s := 'Aleatório'
    else
    if nomeArq = 'JO_NARRA'   then s := 'Narrando'

    else
    if nomeArq = 'JOC_NOME'   then s := 'Nome'
    else
    if nomeArq = 'JOC_CATE'   then s := 'Categoria'
    else
    if nomeArq = 'JOC_RESP'   then s := 'Resposta esperada'
    else
    if nomeArq = 'JOC_LUOK'   then s := 'Se OK, que lugar?'
    else
    if nomeArq = 'JOC_LERR'   then s := 'Erro, que lugar?'
    else
    if nomeArq = 'JOC_JOGT'   then s := 'Jogo termina aqui?'
    else
    if nomeArq = 'JOC_PONT'   then s := 'Pontos ganhos ao chegar'
    else
    if nomeArq = 'JOC_MID'    then s := 'Mídia de fundo'
    else
    if nomeArq = 'JOC_CFND'   then s := 'Cor do Fundo'
    else
    if nomeArq = 'JOC_CLET'   then s := 'Cor da Letra'
    else
    if nomeArq = 'JOG_IMGF'   then s := 'Imagem de fundo'    //******************
    else
    if nomeArq = 'JOC_MEMR'   then s := 'Memória da resposta'
    else
    if nomeArq = 'JOC_SCIN'   then s := 'Script de entrada'
    else
    if nomeArq = 'JOC_SCOUT'  then s := 'Script de saída'

    else
    if nomeArq = 'JOSL_TIT'   then s := 'Título'
    else
    if nomeArq = 'JOSL_FIG'   then s := 'Figura'             //******************
    else
    if nomeArq = 'JOSL_PFG'   then s := 'Posiçao da figura'
    else
    if nomeArq = 'JOSL_MID'   then s := 'Mídia a tocar'
    else
    if nomeArq = 'JOSL_ESP'   then s := 'Espera a mídia'
    else
    if nomeArq = 'JOSL_AVN'   then s := 'Avanço automático'
    else
    if nomeArq = 'JOSL_EFT'   then s := 'Efeito'
    else
    if nomeArq = 'JOSL_FAL'   then s := 'Fala Texto'
    else
    if nomeArq = 'JOSL_PTX'   then s := 'Posição do texto'
    else
    if nomeArq = 'JOSL_T1'    then s := 'Texto 1'
    else
    if nomeArq = 'JOSL_T2'    then s := 'Texto 2'
    else
    if nomeArq = 'JOSL_T3'    then s := 'Texto 3'
    else
    if nomeArq = 'JOSL_T4'    then s := 'Texto 4'
    else
    if nomeArq = 'JOSL_T5'    then s := 'Texto 5'
    else
    if nomeArq = 'JOSL_T6'    then s := 'Texto 6'
    else
    if nomeArq = 'JOSL_T7'    then s := 'Texto 7'
    else
    if nomeArq = 'JOSL_T8'    then s := 'Texto 8'
    else
    if nomeArq = 'JOSL_T9'    then s := 'Texto 9'
    else
    if nomeArq = 'JOSL_T10'   then s := 'Texto 10'

    else
    if nomeArq = 'JOCHAEDI'   then s := 'Chamando editor'
    else
    if nomeArq = 'JOERREDI'   then s := 'Erro na edição do arquivo de programa'

    else
    if nomeArq = 'JOPROAVN'   then s := 'Programação avançada'
    else
    if nomeArq = 'JOOPPROG'   then s := 'Escolha com as setas a opção de programação, ESC cancela'
    else

    if nomeArq = 'JOAUTOPG'   then s := 'Gerar a programação global automaticamente'
    else
    if nomeArq = 'JOEDITPG'   then s := 'Editar programação de controle global'
    else
    if nomeArq = 'JOATIVPG'   then s := 'Ativar esta programação'
    else
    if nomeArq = 'JODESAPG'   then s := 'Desativar esta programação'
    else

    if nomeArq = 'JOPRGNSL'   then s := 'Programa não está selecionado.'
    else
    if nomeArq = 'JONOMPRG'   then s := 'Editore o nome do programa'
    else
    if nomeArq = 'JOPRGNAO'   then s := 'Programa não pôde ser criado'

    else
    if nomeArq = 'JOARQJAX'   then s := 'Arquivo já existe, quer destruir? '       
    else
    if nomeArq = 'JOSETPRG'   then s := 'Use as setas para escolher o programa'
    else
    if nomeArq = 'JOPRGINB'   then s := 'Programa inibido.'
    else
    if nomeArq = 'JOERRESC'   then s := 'Erro de escrita do programa...'       
    else
    if nomeArq = 'JOPROAVN'   then s := 'Programação avançada'        
    else
    if nomeArq = 'JOOPPROG'   then s := 'Escolha com as setas a opção de programação, ESC cancela'
    else
    if nomeArq = 'JOPGMNEX'   then s := 'Programa ainda não existe, executando a programação simples.'
    else
    if nomeArq = 'JOAPROVT'   then s := 'Transcreve também a programação simples pré-existente? '

    else
    if nomeArq = 'JOPRGINB'   then s := 'Programa inibido no teste de lugar.'
    else
    if nomeArq = 'JOERRPGM'   then s := 'Erro de execução no programa '
    else
    if nomeArq = 'JOCATEXC'   then s := 'Número de categorias esgotada, aperte enter'
    else
    if nomeArq = 'JOERCONT'   then s := 'Erro no contador de categorias, aperte enter'
    else
    if nomeArq = 'JOFIMJOG'   then s := 'Fim do Jogo'
    else
    if nomeArq = 'JOOK'       then s := 'Ok'

    else
    if nomeArq = 'JOIMPORT'   then s := 'Importando Mídias para o jogo'
    else
    if nomeArq = 'JOMIDNAO'   then s := 'Diretório de mídias não foi encontrado'
    else
    if nomeArq = 'JOERSELP'   then s := 'Erro ao selecionar o diretório de mídias'
    else
    if nomeArq = 'JOPASMID'   then s := 'Escolha uma pasta de mídias com as setas'
    else
    if nomeArq = 'JONEXIST'   then s := 'Esta pasta não existe'
    else
    if nomeArq = 'JOSMAIS'    then s := 'Use as setas e a tecla + para selecionar os arquivos.'
    else
    if nomeArq = 'JOF9TOCA'   then s := 'F9 exibe o arquivo.'
    else
    if nomeArq = 'JOFINENT'   then s := 'Depois tecle Enter para iniciar a cópia.'
    else
    if nomeArq = 'JOCOP'      then s := ' copiado.'
    else
    if nomeArq = 'JOREESCR'   then s := 'Aperte N para não reescrever o arquivo '
    else
    if nomeArq = 'JOERRCOP'   then s := 'Erro ao copiar o arquivo '
    else
    if nomeArq = 'JOCNTSEL'   then s := 'Continue selecionando'
    else
    if nomeArq = 'JONARQCP'   then s := ' arquivos copiados.'

    else
    if nomeArq = 'JOINFROT'   then s := 'Informe o nome do roteiro .TXT'
    else
    if nomeArq = 'JOINFRTS'   then s := 'Informe o nome do roteiro .TXT ou use as setas'
    else
    if nomeArq = 'JOASSUMR'   then s := 'Assumido roteiro.txt'
    else
    if nomeArq = 'JONAOROT'   then s := 'Este não parece ser um arquivo de roteiro.'
    else
    if nomeArq = 'JOCONMAN'   then s := 'Consulte o manual para maiores detalhes.'
    else
    if nomeArq = 'JODGNALT'   then s := 'Dados gerais não foram alterados.'
    else
    if nomeArq = 'JOARNACE'   then s := 'Arquivo não está acessível.'
    else
    if nomeArq = 'JOGERALT'   then s := 'Dados gerais serão alterados, confira.'
    else
    if nomeArq = 'JOROTCRG'   then s := 'Roteiro carregado.'
    else
    if nomeArq = 'JODADIGN'   then s := 'Dados ignorados no lugar: '
    else
    if nomeArq = 'JOPRGINC'   then s := 'Programação de desvio incorreto no lugar: '
    else
    if nomeArq = 'JOERESCR'   then s := 'Erro de escritano arquivo.'

    else
    if nomeArq = 'JOROTEXI'   then s := 'Sobrescrevendo roteiro.  Confirma? '
    else
    if nomeArq = 'JOROTCRI'   then s := 'Roteiro equivalente criado.'
    else
    if nomeArq = 'JOCATEXC'   then s := 'Número de categorias esgotada, aperte enter'
    else
    if nomeArq = 'JOCATNEX'   then s := 'Categoria inexistente, aperte enter'

    else
    if nomeArq = 'JOAUTPRG'   then s := 'Gerar a programação automaticamente'
    else
    if nomeArq = 'JOCRIPRG'   then s := 'Criar e editar programa novo'
    else
    if nomeArq = 'JOEDIPRG'   then s := 'Editar programa atual'
    else
    if nomeArq = 'JOASSPRG'   then s := 'Ativar o programa'
    else
    if nomeArq = 'JOINBPRG'   then s := 'Desativar o programa'

    else
    if nomeArq = 'JOOPROT'    then s := 'Escolha com as setas a opção de roteiro, ESC cancela'
    else
    if nomeArq = 'JOAJR_C'    then s := 'C - Criar novo roteiro.'
    else
    if nomeArq = 'JOAJR_I'    then s := 'I - Importar um roteiro.'
    else
    if nomeArq = 'JOAJR_E'    then s := 'E - Editar um roteiro.'
    else
    if nomeArq = 'JOAJR_G'    then s := 'G - Gerar um roteiro a partir do jogo'

    else
    if nomeArq = 'JONUMQST'    then s := 'Número total de questões: '
    else
    if nomeArq = 'JONUMQSP'    then s := 'Número de questões a sortear para cada jogo: '
    else
    if nomeArq = 'JONUMLUG'    then s := 'Número total de lugares: '
    else
    if nomeArq = 'JOMODNAO'    then s := 'Modelo não foi encontrado: '

    else
    if nomeArq = 'JOTIPROT'    then s := 'Escolha com as setas o tipo de roteiro'
    else
    if nomeArq = 'JOTIP_PR'    then s := 'P - Perguntas e respostas com ordem fixa.'
    else
    if nomeArq = 'JOTIP_PS'    then s := 'S - Perguntas e respostas com sorteio.'
    else
    if nomeArq = 'JOTIP_EX'    then s := 'E - Exploração de lugares.'
    else
    if nomeArq = 'JOTIP_GA'    then s := 'G - Galeria da fama.'
    else
    if nomeArq = 'JOTIP_VZ'    then s := 'V - Jogo vazio.'
    else

    if nomeArq = 'JODESIMP'    then s := 'Deseja importar o roteiro editado? '
    else
    if nomeArq = 'JOEXEMPL'    then s := 'Gerarei um exemplo para você se basear.'
    else
    if nomeArq = 'JOQUETXT'    then s := 'Qual o texto a buscar: '

    else
    if nomeArq = 'JOCNFPRO'    then s := 'Confirma programação? '
    else
//    if nomeArq = 'JOPROAPG'    then s := 'Programação apagada'
//    else
    if nomeArq = 'JOPROIGN'    then s := 'Programação ignorada'
    else
    if nomeArq = 'JOLEGADO'    then s := 'Foi encontrado um script externo para este lugar'
    else
    if nomeArq = 'JOVOUIMP'    then s := 'Vou importar, confirma (s/n)? '
    else
    if nomeArq = 'JOCRISCR'    then s := 'Criando script '

    else
    if nomeArq = 'JOPROREG'    then s := 'Programação registrada'

    else
    if nomeArq = 'JOEROTEI'    then s := 'Erro no roteiro:'
    else
    if nomeArq = 'JOLGNAOR'    then s := 'O nome "LUGAR" não deve ser usado como Memória da Resposta'

    else
    if nomeArq = 'JOMINITE'    then s := 'Seta para a direita: mini visualizador'
    else
    if nomeArq = 'JOIMPFIM'    then s := 'Escolha A para adicionar ou Z para zerar jogo atual: '
    else
    if nomeArq = 'JOERRSCP'    then s := 'Erro no script do lugar: '
    else
    if nomeArq = 'JO_LINHA'    then s := 'Linha '


    else
    if nomeArq = 'JOBABXND'    then s := 'Baixando o jogo: '
    else
    if nomeArq = 'JOBAERRO'    then s := 'Erro ao tentar baixar o Jogo.'
    else
    if nomeArq = 'JOBA_BXD'    then s := 'O seu jogo foi baixado com sucesso.'
    else
    if nomeArq = 'JOBAARQE'    then s := 'Arquivo jogos não foi achado.'
    else
    if nomeArq = 'JOBACATE'    then s := 'Categoria: Olimpo, Gaia, Caos? '
    else
    if nomeArq = 'JOERSERV'    then s := 'Erro no servidor'
    else
    if nomeArq = 'JOERESCR'    then s := 'Erro de escrita'
    else
    if nomeArq = 'JOEXTARQ'    then s := 'Extraindo o arquivo'
    else
    if nomeArq = 'JOOLIMPO'    then s := 'Olimpo'
    else
    if nomeArq = 'JOGAIA'      then s := 'Gaia'
    else
    if nomeArq = 'JOCAOS'      then s := 'Caos'
    else
    if nomeArq = 'JOESCJOG'    then s := 'Escolha um dos seguintes jogos com as setas'

    else
        s := nomeArq;

    //        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{       sintetiza ou le
{--------------------------------------------------------}

procedure tocaOuSintetiza (msg: string);
begin
    if existeArqSom (msg) then
        sintSom (msg)
    else
        sintetiza (pegaTextoMensagem (msg));
end;

{--------------------------------------------------------}
{       dá uma mensagem
{--------------------------------------------------------}

procedure msgMuda (nomeArq: string; nlf: integer);
var i: integer;
    s: string;

begin
    s := pegaTextoMensagem (nomeArq);

    if nlf >= 0 then write (s);
    for i := 1 to nlf do
         writeln;
end;

{--------------------------------------------------------}
{       dá uma mensagem
{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
begin
    msgMuda (nomeArq, nlf);

    if (nomeArq <> '') and (existeArqSom (nomearq)) then
        sintSom (nomearq)
    else
        sintetiza (pegaTextoMensagem(nomeArq));

    while sintFalando do keypressed;
end;

{--------------------------------------------------------}
{       limpa a área de mensagens lateral
{--------------------------------------------------------}

procedure limpaMensagens;
var x, y: integer;
begin
    x := wherex;
    y := wherey;
    window (40, 7, 80, 7+12);
    textBackground (BLACK);
    clrscr;
    window (1, 1, 80, 25);
    gotoxy (x, y);
end;

{--------------------------------------------------------}
{            transforma uma booleana em string
{--------------------------------------------------------}

function strbool (b: boolean): string;
begin
    if b then result := 'SIM' else result := 'NÃO';
end;

{--------------------------------------------------------}
{                faz uma pergunta
{--------------------------------------------------------}

function pergunta (msg: string; npula: integer; cor: integer): char;
var c, c2: char;
    i: integer;
begin
    textBackground (cor);
    mensagem (msg, 0);
    textBackground (BLACK);
    sintLeTecla (c, c2);
    pergunta := upcase(c);

    if c <> #$0 then
        begin
            writeln;
            c := upcase (c);
            for i := 1 to npula do writeln;
        end;
end;

{--------------------------------------------------------}
{             adiciona à lista de campos
{--------------------------------------------------------}

procedure campo (nomeArqSom: string;
                 var valor: shortstring; tamanho: integer);
var nome: string;
begin
    nome := pegaTextoMensagem(nomeArqSom);
    formCampo (nomeArqSom, nome, valor, tamanho);
end;

{--------------------------------------------------------}
{          adiciona campo com lista de opções
{--------------------------------------------------------}

procedure campoLista (nomeArqSom: string;
                 var valor: shortstring; tamanho: integer; listaSepPtvg: string);
var nome: string;
begin
    nome := pegaTextoMensagem(nomeArqSom);
    if listaSepPtvg = '' then
        formCampo (nomeArqSom, nome, valor, tamanho)
    else
        formCampoLista (nomeArqSom, nome, valor, tamanho, listaSepPtvg);
end;

{--------------------------------------------------------}
{       adiciona ao menu (rotina de conveniência)
{--------------------------------------------------------}

procedure menuAdiciona (cod: string);
begin
    popupMenuAdiciona (cod, pegaTextoMensagem(cod));
end;

{--------------------------------------------------------}
{               centra mensagem na janela
{--------------------------------------------------------}

procedure centra (msg: string);
const brancos = '                                        ';
var x: integer;
begin
    x := (80 - length (msg)) div 2;
    msg := copy (brancos, 1, x) + msg;
end;

end.
