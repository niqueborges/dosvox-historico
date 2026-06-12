{--------------------------------------------------------}
{
{    Controle da Fala
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit edMensag;

interface
uses
    DVcrt, DVWin, sysutils,
    edvars;

function textoAjuda (f: string): string;
function txtmsg (f: string): string;
Procedure FalaSeguinte (f: String);
Procedure Fala (f: String);
function leTeclaMaiusc(var c2:char): char;
procedure falaVersao;

{--------------------------------------------------------}

implementation

function textoAjuda (f: string): string;
begin
    if f = 'EDAJIN1' then textoAjuda := 'Sao os seguintes:'
    else
    if f = 'EDAJIN2' then textoAjuda := '  C - comandos de cursor'
    else
    if f = 'EDAJIN3' then textoAjuda := '  L - linha'
    else
    if f = 'EDAJIN4' then textoAjuda := '  P - procura de textos'
    else
    if f = 'EDAJIN5' then textoAjuda := '  M - margem'
    else
    if f = 'EDAJIN6' then textoAjuda := '  A - arquivos'
    else
    if f = 'EDAJIN7' then textoAjuda := '  B - blocos de linhas'
    else
    if f = 'EDAJIN8' then textoAjuda := '  F - acionamento da fala'
    else
    if f = 'EDAJIN9' then textoAjuda := '  I - instalacao'
    else
    if f = 'EDAJIN10' then textoAjuda := '  E - letras especiais'
    else
    if f = 'EDAJIN11' then textoAjuda := '  W - tratamento Word'
    else
    if f = 'EDAJIN12' then textoAjuda := '  R - tocar radio'
    else
    if f = 'EDAJIN13' then textoAjuda := '  H - opções diretas'
    else

    if f = 'EDAJFW1' then textoAjuda := 'Os comandos de tratamento Word são'
    else
    if f = 'EDAJFW2' then textoAjuda := '  F - insere marcas de formatação'
    else
    if f = 'EDAJFW3' then textoAjuda := '  I - informa formatação no cursor'
    else
    if f = 'EDAJFW4' then textoAjuda := '  G - gera arquivo DOC'
    else
    if f = 'EDAJFW5' then textoAjuda := '  O - Ocultar formatação na tela'
    else
    if f = 'EDAJFW6' then textoAjuda := '  M - Modos de falar formatação'
    else
    if f = 'EDAJFW7' then textoAjuda := '  L - Limpar formatação'
    else

    if f = 'EDAJFR1' then textoAjuda := 'Os comandos de tocar rádio são'
    else
    if f = 'EDAJFR2' then textoAjuda := '  R - Tocador interno'
    else
    if f = 'EDAJFR3' then textoAjuda := '  E - Tocador externo'
    else

    if f = 'EDAJLI1' then textoAjuda := 'Os comandos de linha são:'
    else
    if f = 'EDAJLI2' then textoAjuda := '  I - insere uma linha acima'
    else
    if f = 'EDAJLI3' then textoAjuda := '  A - insere uma linha abaixo'
    else
    if f = 'EDAJLI4' then textoAjuda := '  R - remove linha'
    else
    if f = 'EDAJLI5' then textoAjuda := '  V - volta linha removida'
    else
    if f = 'EDAJLI6' then textoAjuda := '  Q - quebra linha em duas'
    else
    if f = 'EDAJLI7' then textoAjuda := '  J - junta duas linhas'
    else
    if f = 'EDAJLI8' then textoAjuda := '  E - exclui linhas com o texto'
    else
    if f = 'EDAJLI9' then textoAjuda := '  S - insere no início da linha'
    else
    if f = 'EDAJLI10' then textoAjuda := '  D - insere no fim da linha'
    else
    if f = 'EDAJLI11' then textoAjuda := '  Ctrl + S -remove o início da linha'
    else
    if f = 'EDAJLI12' then textoAjuda := '  Ctrl + D - remove o fim da linha'
    else
    if f = 'EDAJLI13' then textoAjuda := '  H - remove hifenização'
    else
    if f = 'EDAJLI14' then textoAjuda := '  U - remove linhas iguais'
    else
    if f = 'EDAJLI15' then textoAjuda := '  Ctrl + U - mostra linhas iguais'
    else
    if f = 'EDAJLI16' then textoAjuda := '  P - remove números de páginas'
    else

    if f = 'EDAJCU1' then textoAjuda := 'Os comandos de cursor são:'
    else
    if f = 'EDAJCU2' then textoAjuda := '  - - inicio do texto'
    else
    if f = 'EDAJCU3' then textoAjuda := '  + - fim do texto'
    else
    if f = 'EDAJCU4' then textoAjuda := '  A - avança paragrafo'
    else
    if f = 'EDAJCU5' then textoAjuda := '  R - recua paragrafo'
    else
    if f = 'EDAJCU6' then textoAjuda := '  P - posiciona em certa linha'
    else
    if f = 'EDAJCU7' then textoAjuda := '  I - apaga inicio da linha'
    else
    if f = 'EDAJCU8' then textoAjuda := '  F - apaga fim da linha'
    else
    if f = 'EDAJCU9' then textoAjuda := '  L - informa linha'
    else
    if f = 'EDAJCU10' then textoAjuda := '  C - informa coluna'
    else
    if f = 'EDAJCU11' then textoAjuda := '  M - memoriza posição do cursor'
    else
    if f = 'EDAJCU12' then textoAjuda := '  V - volta cursor à posição memorizada'
    else
    if f = 'EDAJCU13' then textoAjuda := '  N - avança para linha em branco'
    else
    if f = 'EDAJCU14' then textoAjuda := '  E - recua para linha em branco'

    else if f = 'EDAJBL1'  then textoAjuda := 'Os comandos de bloco são:'
    else if f = 'EDAJBL2'  then textoAjuda := '  I        - inicio do bloco'
    else if f = 'EDAJBL3'  then textoAjuda := '  F        - fim do bloco'
    else if f = 'EDAJBL4'  then textoAjuda := '  M        - move o bloco'
    else if f = 'EDAJBL5'  then textoAjuda := '  C        - copia o bloco'
    else if f = 'EDAJBL6'  then textoAjuda := '  A        - adiciona bloco a um arquivo'
    else if f = 'EDAJBL7'  then textoAjuda := '  O        - ordena o bloco'
    else if f = 'EDAJBL8'  then textoAjuda := '  R        - remove o bloco'
    else if f = 'EDAJBL9'  then textoAjuda := '  D        - desmarca o bloco'
    else if f = 'EDAJBL10' then textoAjuda := '  L        - le arquivo gerando bloco'
    else if f = 'EDAJBL11' then textoAjuda := '  G        - grava o bloco em arquivo'
    else if f = 'EDAJBL12' then textoAjuda := '  E        - embeleza o bloco'
    else if f = 'EDAJBL13' then textoAjuda := '  P        - paragrafo vira bloco'
    else if f = 'EDAJBL14' then textoAjuda := '  J        - justifica paragrafo do cursor'
    else if f = 'EDAJBL15' then textoAjuda := '  S        - linha vira bloco'
    else if f = 'EDAJBL16' then textoAjuda := '  V        - verificação ortográfica'
    else if f = 'EDAJBL17' then textoAjuda := '  X        - decodificação'
    else if f = 'EDAJBL18' then textoAjuda := '  U        - converte bloco'
    else if f = 'EDAJBL19' then textoAjuda := '  B        - remove linhas em branco'
    else if f = 'EDAJBL20' then textoAjuda := '  W        - transferência no formato do Word'
    else if f = 'EDAJBL21' then textoAjuda := '  T        - seleciona Todo o texto'
    else if f = 'EDAJBL22' then textoAjuda := '  Ctrl + B - remove linhas vazias deixando uma'
    else if f = 'EDAJBL23' then textoAjuda := '  Q        - quebra linhas do texto'
    else if f = 'EDAJBL24' then textoAjuda := '  Ctrl + I - marca bloco até o fim'
    else if f = 'EDAJBL25' then textoAjuda := '  Ctrl + F - marca bloco até o início'
    else if f = 'EDAJBL26' then textoAjuda := '  Y        - traduz bloco direto'
    else if f = 'EDAJBL27' then textoAjuda := '  Ctrl + Y - traduz bloco'
    else if f = 'EDAJBL28' then textoAjuda := '  N        - abre navegador com bloco mat'
    else if f = 'EDAJBL29' then textoAjuda := '  CTRL + N - salva bloco mat'
    else if f = 'EDAJBL30' then textoAjuda := '  CTRL + L - lê arquivo adicionando'
    else

    if f = 'EDAJMA1' then textoAjuda := 'Os comandos de margem são:'
    else
    if f = 'EDAJMA2' then textoAjuda := '  M - informa margens'
    else
    if f = 'EDAJMA3' then textoAjuda := '  T - nova coluna de tabulacao'
    else
    if f = 'EDAJMA4' then textoAjuda := '  R - remove todas tabulacoes'
    else

    if f = 'EDAJAR1' then textoAjuda := 'Os comandos de arquivos são:'
    else
    if f = 'EDAJAR2' then textoAjuda := '  I - informa nome do arquivo'
    else
    if f = 'EDAJAR3' then textoAjuda := '  S - salva arquivo e continua'
    else
    if f = 'EDAJAR4' then textoAjuda := '  N - edita um novo arquivo'
    else
    if f = 'EDAJAR5' then textoAjuda := '  C - salva como outro arquivo'
    else
    if f = 'EDAJAR6' then textoAjuda := '  F - salva e fim'
    else
    if f = 'EDAJAR7' then textoAjuda := '  A - abandona sem gravar'
    else
    if f = 'EDAJAR8' then textoAjuda := '  X - exporta formato IBM'
    else
    if f = 'EDAJAR9' then textoAjuda := '  T - fala tipo codificação'
    else
    if f = 'EDAJAR10' then textoAjuda := '  G - salva como escolhendo codificação'
    else

    if f = 'EDAJBU1' then textoAjuda := 'Os comandos de busca são:'
    else
    if f = 'EDAJBU2' then textoAjuda := '  P - procura texto'
    else
    if f = 'EDAJBU3' then textoAjuda := '  N - busca de novo'
    else
    if f = 'EDAJBU4' then textoAjuda := '  T - troca palavras por outras'
    else
    if f = 'EDAJBU5' then textoAjuda := '  B - troca Tab por 8 espaços'
    else
    if f = 'EDAJBU6' then textoAjuda := '  C - fala quantas ocorrências na busca'
    else

    if f = 'EDAJFA1' then textoAjuda := 'Os comandos de fala são:'
    else
    if f = 'EDAJFA2' then textoAjuda := '  I - fala inicio da linha'
    else
    if f = 'EDAJFA3' then textoAjuda := '  L - fala resto da linha'
    else
    if f = 'EDAJFA4' then textoAjuda := '  T - fala resto do texto'
    else

    if f = 'EDAJCF1' then textoAjuda := 'Os comandos de configuração são:'
    else
    if f = 'EDAJCF2' then textoAjuda := '  F - fala'
    else
    if f = 'EDAJCF3' then textoAjuda := '  I - insercao com Enter'
    else
    if f = 'EDAJCF4' then textoAjuda := '  S - soletragem'
    else
    if f = 'EDAJCF5' then textoAjuda := '  Q - quebra de linha automatica'
    else
    if f = 'EDAJCF6' then textoAjuda := '  V - velocidade'
    else

    if f = 'EDAJEM1' then textoAjuda := 'Os comandos de embelezamento são:'
    else
    if f = 'EDAJEM2' then textoAjuda := '  C - centra bloco'
    else
    if f = 'EDAJEM3' then textoAjuda := '  M - acerta margens'
    else
    if f = 'EDAJEM4' then textoAjuda := '  A - alinha com as margens'
    else
    if f = 'EDAJEM5' then textoAjuda := '  T - tabula pela esquerda o bloco'
    else
    if f = 'EDAJEM6' then textoAjuda := '  I - indenta o bloco'
    else
    if f = 'EDAJEM7' then textoAjuda := '  Q - quebra linhas do bloco'
    else
    if f = 'EDAJEM8' then textoAjuda := '  E - remove espaços entre palavras'
    else
    if f = 'EDAJEM9' then textoAjuda := '  O - acerta margens em 80 colunas'
    else
    if f = 'EDAJEM10' then textoAjuda := '  P - acerta margens no padrão'
    else

    if f = 'EDAJCV1' then textoAjuda := 'As conversões são:'
    else
    if f = 'EDAJCV2' then textoAjuda := '  a minúsculo - alqueire do norte para metros quadrados'
    else
    if f = 'EDAJCV3' then textoAjuda := '  A maiúsculo - alqueire mineiro para metros quadrados'
    else
    if f = 'EDAJCV4' then textoAjuda := '  b minúsculo - alqueire paulista para metros quadrados'
    else
    if f = 'EDAJCV5' then textoAjuda := '  B maiúsculo - centímetros para pés'
    else
    if f = 'EDAJCV6' then textoAjuda := '  c minúsculo - centímetros para  polegadas'
    else
    if f = 'EDAJCV7' then textoAjuda := '  C maiúsculo - centímetros quadrados para pés quadrados'
    else
    if f = 'EDAJCV8' then textoAjuda := '  d minúsculo - galões para centímetros cúbicos'
    else
    if f = 'EDAJCV9' then textoAjuda := '  D maiúsculo - galões para litros'
    else
    if f = 'EDAJCV10' then textoAjuda := '  e minúsculo - gramas para libras'
    else
    if f = 'EDAJCV11' then textoAjuda := '  E maiúsculo - gramas para onças'
    else
    if f = 'EDAJCV12' then textoAjuda := '  f minúsculo - hectare para metros quadrados'
    else
    if f = 'EDAJCV13' then textoAjuda := '  F maiúsculo - jardas para centímetros'
    else
    if f = 'EDAJCV14' then textoAjuda := '  g minúsculo - jardas para metros'
    else
    if f = 'EDAJCV15' then textoAjuda := '  G maiúsculo - jardas quadradas para metros quadrados'
    else
    if f = 'EDAJCV16' then textoAjuda := '  h minúsculo - libras para gramas'
    else
    if f = 'EDAJCV17' then textoAjuda := '  H maiúsculo - libras para quilogramas'
    else
    if f = 'EDAJCV18' then textoAjuda := '  i minúsculo - litros para quartos'
    else
    if f = 'EDAJCV19' then textoAjuda := '  I maiúsculo - metros para jardas'
    else
    if f = 'EDAJCV20' then textoAjuda := '  j minúsculo - metros para pés'
    else
    if f = 'EDAJCV21' then textoAjuda := '  J maiúsculo - metros para polegadas'
    else
    if f = 'EDAJCV22' then textoAjuda := '  k minúsculo - metros quadrados para jardas quadradas'
    else
    if f = 'EDAJCV23' then textoAjuda := '  K maiúsculo - metros quadrados para pés quadrados'
    else
    if f = 'EDAJCV24' then textoAjuda := '  l minúsculo - metros por minuto para centímetros por segundo'
    else
    if f = 'EDAJCV25' then textoAjuda := '  L maiúsculo - metros por minuto para pés por segundo'
    else
    if f = 'EDAJCV26' then textoAjuda := '  m minúsculo - milhas para quilômetros'
    else
    if f = 'EDAJCV27' then textoAjuda := '  M maiúsculo - milhas para nós'
    else
    if f = 'EDAJCV28' then textoAjuda := '  n minúsculo - milhas quadradas para quilômetros quadrados'
    else
    if f = 'EDAJCV29' then textoAjuda := '  N maiúsculo - milhas por hora para metros por segundo'
    else
    if f = 'EDAJCV30' then textoAjuda := '  o minúsculo - milhas por hora para quilômetros por hora'
    else
    if f = 'EDAJCV31' then textoAjuda := '  O maiúsculo - nós para quilômetros por hora'
    else
    if f = 'EDAJCV32' then textoAjuda := '  p minúsculo - onças para gramas'
    else
    if f = 'EDAJCV33' then textoAjuda := '  P maiúsculo - onças para quilogramas'
    else
    if f = 'EDAJCV34' then textoAjuda := '  q minúsculo - pés para centímetros'
    else
    if f = 'EDAJCV35' then textoAjuda := '  Q maiúsculo - pés por minuto para centímetros por segundo'
    else
    if f = 'EDAJCV36' then textoAjuda := '  r minúsculo - polegadas para centímetros'
    else
    if f = 'EDAJCV37' then textoAjuda := '  R maiúsculo - polegadas para pés'
    else
    if f = 'EDAJCV38' then textoAjuda := '  s minúsculo - quartos para litros'
    else
    if f = 'EDAJCV39' then textoAjuda := '  S maiúsculo - quilogramas para libras'
    else
    if f = 'EDAJCV40' then textoAjuda := '  t minúsculo - quilômetros para milhas'
    else
    if f = 'EDAJCV41' then textoAjuda := '  T maiúsculo - quilômetros para pés'
    else
    if f = 'EDAJCV42' then textoAjuda := '  u minúsculo - quilômetros quadrados para jardas quadradas'
    else
    if f = 'EDAJCV43' then textoAjuda := '  U maiúsculo - quilômetros quadrados para milhas quadradas'
    else
    if f = 'EDAJCV44' then textoAjuda := '  v minúsculo - quilômetros por hora para milhas por hora'
    else
    if f = 'EDAJCV45' then textoAjuda := '  V maiúsculo - quilômetros por hora para pés por minuto'
    else
    if f = 'EDAJCV46' then textoAjuda := '  w minúsculo - Fahrenheit para Celsius'
    else
    if f = 'EDAJCV47' then textoAjuda := '  W maiúsculo - Celsius para Fahrenheit'
    else
    if f = 'EDAJCV48' then textoAjuda := '  x minúsculo - Potenciação'
    else
    if f = 'EDAJCV49' then textoAjuda := '  X maiúsculo - Comprimento da circunferência'
    else
    if f = 'EDAJCV50' then textoAjuda := '  y minúsculo - Área do círculo'
    else
    if f = 'EDAJCV51' then textoAjuda := '  Y maiúsculo - Volume da esfera'
    else
    if f = 'EDAJCV52' then textoAjuda := '  z minúsculo - Logarítmo em qualquer base'
    else
    if f = 'EDAJCV53' then textoAjuda := '  á minúsculo agudo - Seno'
    else
    if f = 'EDAJCV54' then textoAjuda := '  Á maiúsculo agudo - Cosseno'
    else
    if f = 'EDAJCV55' then textoAjuda := '  é minúsculo agudo - Tangente'
    else
    if f = 'EDAJCV56' then textoAjuda := '  É maiúsculo agudo - Cotangente'
    else
    if f = 'EDAJCV57' then textoAjuda := '  í minúsculo agudo - Secante'
    else
    if f = 'EDAJCV58' then textoAjuda := '  Í maiúsculo agudo - Cossecante'
    else
    if f = 'EDAJCV59' then textoAjuda := '  ó minúsculo agudo - Logarítmo Neperiano'
    else
    if f = 'EDAJCV60' then textoAjuda := '  Ó maiúsculo agudo - Logarítmo na base 10'
    else
    if f = 'EDAJCV61' then textoAjuda := '  ú minúsculo agudo - Logarítmo na base 2'
    else
    if f = 'EDAJCV62' then textoAjuda := '  Use as setas para selecionar.'
    else

    if f = 'EDAJDA1' then textoAjuda := '  J - justificar'
    else
    if f ='EDAJDA2' then textoAjuda := '  C - centralizar'
    else
    if f ='EDAJDA3' then textoAjuda := '  D - alinhar a direita'
    else
    if f ='EDAJDA4' then textoAjuda := '  E - alinhar a esquerda'
    else

    if f ='EDAJF01' then textoAjuda := '  F - nome da fonte'
    else
    if f ='EDAJF02' then textoAjuda := '  T - tamanho da fonte'
    else
    if f ='EDAJF03' then textoAjuda := '  C - cor da fonte'
    else
    if f ='EDAJF04' then textoAjuda := '  N - início de negrito'
    else
    if f ='EDAJF05' then textoAjuda := '  CONTROL + N - fim de negrito'
    else
    if f ='EDAJF06' then textoAjuda := '  I - início de itálico'
    else
    if f ='EDAJF07' then textoAjuda := '  CONTROL + I - fim de itálico'
    else
    if f ='EDAJF08' then textoAjuda := '  S - início de sublinhado'
    else
    if f ='EDAJF09' then textoAjuda := '  CONTROL + S - fim de sublinhado'
    else

    if f ='EDAJMF1' then textoAjuda := '  F - fonte'
    else
    if f ='EDAJMF2' then textoAjuda := '  A - alinhamento'
    else

    if f ='EDAJMM1' then textoAjuda := 'Os comandos de maiúsculas e minusculas são:'
    else
    if f ='EDAJMM2' then textoAjuda := '  A - maiúscula'
    else
    if f ='EDAJMM3' then textoAjuda := '  I - minúscula'
    else
    if f ='EDAJMM4' then textoAjuda := '  P - Primeira letra maiúscula'
    else
    if f ='EDAJMM5' then textoAjuda := '  U - converter para UTF-8'
    else
    if f ='EDAJMM6' then textoAjuda := '  C - contar palavras'
    else
    if f ='EDAJMM7' then textoAjuda := '  T - contar palavras jogando na área de transferência'
    else
    if f ='EDAJMM8' then textoAjuda := '  R - mostrar repetições de palavras'
    else

    if f ='EDAUTOMA' then textoAjuda := 'Automática'
    else
    if f ='EDPRETO' then textoAjuda := 'Preto'
    else
    if f ='EDAZUL' then textoAjuda := 'Azul'
    else
    if f ='EDTURQUE' then textoAjuda := 'Turquesa'
    else
    if f ='EDVERCLA' then textoAjuda := 'Verde claro'
    else
    if f ='EDROSA' then textoAjuda := 'Rosa'
    else
    if f ='EDVERMEL' then textoAjuda := 'Vermelho'
    else
    if f ='EDAMAREL' then textoAjuda := 'Amarelo'
    else
    if f ='EDBRANCO' then textoAjuda := 'Branco'
    else
    if f ='EDAZUESC' then textoAjuda := 'Azul escuro'
    else
    if f ='EDCERCET' then textoAjuda := 'Cerceta'
    else
    if f ='EDVERDE' then textoAjuda := 'Verde'
    else
    if f ='EDVIOLET' then textoAjuda := 'Violeta'
    else
    if f ='EDVERESC' then textoAjuda := 'Vermelho escuro'
    else
    if f ='EDAMAESC' then textoAjuda := 'Amarelo escuro'
    else
    if f ='EDCINZ50' then textoAjuda := 'Cinza 50'
    else
    if f ='EDCINZ25' then textoAjuda := 'Cinza 25'
    else

    if f = 'EDAJFF1' then textoAjuda := 'Os modos de falar a formatação são:'
    else
    if f = 'EDAJFF2' then textoAjuda := '  N - natural'
    else
    if f = 'EDAJFF3' then textoAjuda := '  F - formatação'
    else
    if f = 'EDAJFF4' then textoAjuda := '  B - bips'
    else
    if f = 'EDAJFF5' then textoAjuda := '  M - mudo'

    //   Opções diretas
    else if f = 'EDAJDIP1'    then textoAjuda := '  Arquivo'
    else if f = 'EDAJDIP2'    then textoAjuda := '  Leitura de texto'
    else if f = 'EDAJDIP3'    then textoAjuda := '  Localizar e substituir'
    else if f = 'EDAJDIP4'    then textoAjuda := '  Selecionar texto'
    else if f = 'EDAJDIP5'    then textoAjuda := '  Remover e desfazer'
    else if f = 'EDAJDIP6'    then textoAjuda := '  Posicionar cursor'
    else if f = 'EDAJDIP7'    then textoAjuda := '  Ortografia e dicionários'
    else if f = 'EDAJDIP8'    then textoAjuda := '  Mais comandos'
    else if f = 'EDAJDIP9'    then textoAjuda := '  Tratamento Word'
    else if f = 'EDAJDIP10'   then textoAjuda := '  Configurações'
    //   Arquivo
    else if f = 'EDAJDIA1'    then textoAjuda := '  F2               - salvar'
    else if f = 'EDAJDIA2'    then textoAjuda := '  Shift + F2       - salvar trocando codificação'
    else if f = 'EDAJDIA3'    then textoAjuda := '  Ctrl + F2        - salvar como'
    else if f = 'EDAJDIA4'    then textoAjuda := '  Ctrl + Shift + F2- trocando codificação'
    else if f = 'EDAJDIA5'    then textoAjuda := '  F3               - Trocar de arquivo'
    else if f = 'EDAJDIA6'    then textoAjuda := '  Ctrl + F3        - Abrir outro'
    else if f = 'EDAJDIA7'    then textoAjuda := '  Ctrl + N         - falar nome completo'
    else if f = 'EDAJDIA8'    then textoAjuda := '  Ctrl + Shift + N - falar nome'
    else if f = 'EDAJDIA9'    then textoAjuda := '  Ctrl + P         - imprimir'
    else if f = 'EDAJDIA10'   then textoAjuda := '  Alt + X         - gravar e sair'
    else if f = 'EDAJDIA11'   then textoAjuda := '  Alt + F4         - Sair'
    //   Leitura de texto
    else if f = 'EDAJDILT1'   then textoAjuda := '  F1                - ler palavra à direita'
    else if f = 'EDAJDILT2'   then textoAjuda := '  Ctrl + F1         - ler resto linha'
    else if f = 'EDAJDILT3'   then textoAjuda := '  Ctrl + Shift + F1 - soletrar resto linha'
    else if f = 'EDAJDILT4'   then textoAjuda := '  Alt + F1          - ler resto texto'
    else if f = 'EDAJDILT5'   then textoAjuda := '  Alt + Shift + F1  - soletrar resto texto'
    else if f = 'EDAJDILT6'   then textoAjuda := '  Baixo             - ler linha para baixo'
    else if f = 'EDAJDILT7'   then textoAjuda := '  Cima              - ler linha para cima'
    else if f = 'EDAJDILT8'   then textoAjuda := '  Ctrl + L          - falar número da linha'
    else if f = 'EDAJDILT9'   then textoAjuda := '  Ctrl + K          - falar número da coluna'
    else if f = 'EDAJDILT10'  then textoAjuda := '  Ctrl + Shift + L  - número da página'
    else if f = 'EDAJDILT11'  then textoAjuda := '  Direita           - ler um caractere à direita'
    else if f = 'EDAJDILT12'  then textoAjuda := '  Alt + direita     - ler com alfabeto fonético'
    else if f = 'EDAJDILT13'  then textoAjuda := '  Ctrl + direita    - palavra à direita'
    else if f = 'EDAJDILT14'  then textoAjuda := '  Esquerda          - ler um caractere à esquerda'
    else if f = 'EDAJDILT15'  then textoAjuda := '  Ctrl + esquerda   - palavra à esquerda'
    else if f = 'EDAJDILT16'  then textoAjuda := '  Ctrl + F          - ler até pontuação'
    else if f = 'EDAJDILT17'  then textoAjuda := '  Ctrl + Shift + F  - soletrar até pontuação'
    else if f = 'EDAJDILT18'  then textoAjuda := '  Shift + Enter     - ler texto do bloco'
    else if f = 'EDAJDILT19'  then textoAjuda := '  Ctrl + Shift + C  - ler área transferência'
    else if f = 'EDAJDILT20'  then textoAjuda := '  Ctrl + Shift + B  - ler bloco selecionado'
    else if f = 'EDAJDILT21'  then textoAjuda := '  Alt + H           - Sonoramat, abre sintMat'
    //   Localizar e substituir
    else if f = 'EDAJDILS1'   then textoAjuda := '  F5                - buscar'
    else if f = 'EDAJDILS2'   then textoAjuda := '  Ctrl + F5         - repetir busca'
    else if f = 'EDAJDILS3'   then textoAjuda := '  Alt + F5          - repetir de forma cíclica'
    else if f = 'EDAJDILS4'   then textoAjuda := '  Shift + F5        - buscar para traz'
    else if f = 'EDAJDILS5'   then textoAjuda := '  Ctrl + Shift + F5 - repetir busca para traz'
    else if f = 'EDAJDILS6'   then textoAjuda := '  F6                - Substituir'
    else if f = 'EDAJDILS7'   then textoAjuda := '  Ctrl + Shift + F6 - Troca Tab por espaços'
    else if f = 'EDAJDILS8'   then textoAjuda := '  Alt + F6          - Quantas ocorrências na busca'
    else if f = 'EDAJDILS9'   then textoAjuda := '  Ctrl + F9         - limpar texto'
    else if f = 'EDAJDILS10'   then textoAjuda := '  Ctrl + Shift + F9 - Portugal para BR'
    //   Selecionar texto
    else if f = 'EDAJDIST1'   then textoAjuda := '  Ctrl + T                - todo texto'
    else if f = 'EDAJDIST2'   then textoAjuda := '  Shift + baixo           - linha para baixo'
    else if f = 'EDAJDIST3'   then textoAjuda := '  Shift + cima            - linha para cima'
    else if f = 'EDAJDIST4'   then textoAjuda := '  Shift + Home            - até início da linha'
    else if f = 'EDAJDIST5'   then textoAjuda := '  Shift + End             - até fim da linha'
    else if f = 'EDAJDIST6'   then textoAjuda := '  Ctrl + Shift + Home     - até início do texto'
    else if f = 'EDAJDIST7'   then textoAjuda := '  Ctrl + Shift + End      - até fim do texto'
    else if f = 'EDAJDIST8'   then textoAjuda := '  Shift + PageUp          - 15 linhas para cima'
    else if f = 'EDAJDIST9'   then textoAjuda := '  Ctrl + Shift + PageUp   - página a cima'
    else if f = 'EDAJDIST10'  then textoAjuda := '  Shift + PageDown        - 15 linhas para baixo'
    else if f = 'EDAJDIST11'  then textoAjuda := '  Ctrl + Shift + PageDown - página a baixo'
    else if f = 'EDAJDIST12'  then textoAjuda := '  Shift + direita         - caractere à direita'
    else if f = 'EDAJDIST13'  then textoAjuda := '  Ctrl + Shift + Direita  - palavra à direita'
    else if f = 'EDAJDIST14'  then textoAjuda := '  Shift + esquerda        - caractere à esquerda'
    else if f = 'EDAJDIST15'  then textoAjuda := '  Ctrl + Shift + esquerda - palavra à esquerda'
    else if f = 'EDAJDIST16'  then textoAjuda := '  Ctrl + Shift + P        - parágrafo vira bloco'
    //   Remover e desfazer
    else if f = 'EDAJDIRD1'   then textoAjuda := '  Delete                - caractere à direita'
    else if f = 'EDAJDIRD2'   then textoAjuda := '  Ctrl + Delete         - remover linha'
    else if f = 'EDAJDIRD3'   then textoAjuda := '  Ctrl + Shift + Delete - remover bloco'
    else if f = 'EDAJDIRD4'   then textoAjuda := '  Backspace             - caractere à esquerda'
    else if f = 'EDAJDIRD5'   then textoAjuda := '  Ctrl + backspace      - palavra à esquerda'
    else if f = 'EDAJDIRD6'   then textoAjuda := '  Ctrl + D              - apaga a direita da linha'
    else if f = 'EDAJDIRD7'   then textoAjuda := '  Ctrl + S              - apaga a esquerda da linha'
    else if f = 'EDAJDIRD8'   then textoAjuda := '  F7                    - remover linha'
    else if f = 'EDAJDIRD9'   then textoAjuda := '  Ctrl + Y              - remover linha'
    else if f = 'EDAJDIRD10'  then textoAjuda := '  Ctrl + Shift + y      - colar linha removida'
    else if f = 'EDAJDIRD11'  then textoAjuda := '  Ctrl + Z              - desfazer'
    else if f = 'EDAJDIRD12'  then textoAjuda := '  Ctrl + Shift + Z      - refazer'
    //   Posicionar cursor
    else if f = 'EDAJDIPC1'   then textoAjuda := '  Alt + F2             - memorizar linha'
    else if f = 'EDAJDIPC2'   then textoAjuda := '  Alt + F3             - ir para posição memorizada'
    else if f = 'EDAJDIPC3'   then textoAjuda := '  Ctrl + A             - avançar para linha vazia'
    else if f = 'EDAJDIPC4'   then textoAjuda := '  Ctrl + Shift + A     - avançar e falar total'
    else if f = 'EDAJDIPC5'   then textoAjuda := '  Ctrl + R             - recuar para linha vazia'
    else if f = 'EDAJDIPC6'   then textoAjuda := '  Ctrl + Shift + R     - recuar e falar total'
    else if f = 'EDAJDIPC7'   then textoAjuda := '  Ctrl + G             - ir para linha'
    else if f = 'EDAJDIPC8'   then textoAjuda := '  Ctrl + Shift + G     - ir para página'
    else if f = 'EDAJDIPC9'   then textoAjuda := '  Home                 - ir para início da linha'
    else if f = 'EDAJDIPC10'  then textoAjuda := '  End                  - ir para fim da linha'
    else if f = 'EDAJDIPC11'  then textoAjuda := '  Ctrl + Home          - ir para início do texto'
    else if f = 'EDAJDIPC12'  then textoAjuda := '  Ctrl + End           - ir para fim do texto'
    else if f = 'EDAJDIPC13'  then textoAjuda := '  PageUp               - 15 linhas para cima'
    else if f = 'EDAJDIPC14'  then textoAjuda := '  PageDown             - 15 linhas para baixo'
    else if f = 'EDAJDIPC15'  then textoAjuda := '  Ctrl + PageUp        - uma página para cima'
    else if f = 'EDAJDIPC16'  then textoAjuda := '  Ctrl + PageDown      - uma página para baixo'
    else if f = 'EDAJDIPC17'  then textoAjuda := '  Ctrl + baixo         - mesma coluna de baixo'
    else if f = 'EDAJDIPC18'  then textoAjuda := '  Ctrl + Shift + baixo - falando até fim'
    else if f = 'EDAJDIPC19'  then textoAjuda := '  Ctrl + cima          - mesma coluna de cima'
    else if f = 'EDAJDIPC20'  then textoAjuda := '  Ctrl + Shift + cima  - falando até fim'
    //   Ortografia e dicionários
    else if f = 'EDAJDIOD1'   then textoAjuda := '  Ctrl + U         - próxima palavra errada'
    else if f = 'EDAJDIOD2'   then textoAjuda := '  Ctrl + Shift + U - palavra anterior errada'
    else if f = 'EDAJDIOD3'   then textoAjuda := '  Ctrl + W         - listar sugestões'
    else if f = 'EDAJDIOD4'   then textoAjuda := '  Ctrl + Shift + W - repetições de palavras'
    else if f = 'EDAJDIOD5'   then textoAjuda := '  Ctrl + Shift + D - consultar dicionários'
    else if f = 'EDAJDIOD6'   then textoAjuda := '  Ctrl + Shift + O - dicionário on line'
    else if f = 'EDAJDIOD7'   then textoAjuda := '  F11              - ativar/desativar corretor'
    else if f = 'EDAJDIOD8'   then textoAjuda := '  Shift + F11      - recarregar corretor'
    else if f = 'EDAJDIOD9'   then textoAjuda := '  Alt + Y          - traduzir bloco direto'
    else if f = 'EDAJDIOD10'  then textoAjuda := '  Alt + Shift + Y  - traduzir bloco'
    //   Mais comandos
    else if f = 'EDAJDIMO1'   then textoAjuda := '  Ctrl + C         - copiar para área de transferência'
    else if f = 'EDAJDIMO2'   then textoAjuda := '  Ctrl + V         - colar da área de transferência'
    else if f = 'EDAJDIMO3'   then textoAjuda := '  Ctrl + F6        - cálculos e conversões'
    else if f = 'EDAJDIMO4'   then textoAjuda := '  F12              - abrir link'
    else if f = 'EDAJDIMO5'   then textoAjuda := '  Shift + F12      - abrir por fora'
    else if f = 'EDAJDIMO6'   then textoAjuda := '  Ctrl + e         - acionar letras especiais'
    else if f = 'EDAJDIMO7'   then textoAjuda := '  Ctrl + B         - comandos de bloco'
    else if f = 'EDAJDIMO8'   then textoAjuda := '  Ctrl + Q         - quebrar linha, se no fim junta'
    else if f = 'EDAJDIMO9'   then textoAjuda := '  Ctrl + J         - inserir linha'
    else if f = 'EDAJDIMO10'  then textoAjuda := '  Tab              - inserir tabular'
    else if f = 'EDAJDIMO11'  then textoAjuda := '  Shift + Tab      - inserir caractere Tab'
    else if f = 'EDAJDIMO12'  then textoAjuda := '  Ctrl + Shift + T - Tabular'
    else if f = 'EDAJDIMO13'  then textoAjuda := '  Ctrl + O         - falar espaços no início'
    else if f = 'EDAJDIMO14'  then textoAjuda := '  Ctrl + \         - discar para número'
    else if f = 'EDAJDIMO15'  then textoAjuda := '  F8               - falar hora'
    else if f = 'EDAJDIMO16'  then textoAjuda := '  Ctrl + F8        - falar data'
    //   Tratamento Word
    else if f = 'EDAJDITW1'   then textoAjuda := '  Alt + F - menu inserir formatação'
    else if f = 'EDAJDITW2'   then textoAjuda := '  Alt + G - gerador de arquivo DOCX'
    else if f = 'EDAJDITW3'   then textoAjuda := '  Alt + D - gera arquivo DOCX'
    else if f = 'EDAJDITW4'   then textoAjuda := '  Alt + S - sair para o Word'
    else if f = 'EDAJDITW5'   then textoAjuda := '  Alt + P - imprimi arquivo DOCX'
    else if f = 'EDAJDITW6'   then textoAjuda := '  Alt + I - falar formatação no cursor'
    else if f = 'EDAJDITW7'   then textoAjuda := '  Alt + M - modos de falar formatação'
    else if f = 'EDAJDITW8'   then textoAjuda := '  Alt + O - ocultar visualização'
    //   Configurações
    else if f = 'EDAJDIC1'    then textoAjuda := '  Ctrl + F4         - configurar'
    else if f = 'EDAJDIC2'    then textoAjuda := '  F4                - desligar/ligar soletrar'
    else if f = 'EDAJDIC3'    then textoAjuda := '  Ctrl + Shift + F4 - modos de fala'
    else if f = 'EDAJDIC4'    then textoAjuda := '  F10               - alterar margens'
    else if f = 'EDAJDIC5'    then textoAjuda := '  Insert            - alterar Enter insere linha'
    else if f = 'EDAJDIC6'    then textoAjuda := '  Alt + 0           - ligar voz nativa'
    else if f = 'EDAJDIC7'    then textoAjuda := '  Alt + 1           - ligar voz posição 1 memória'
    else if f = 'EDAJDIC8'    then textoAjuda := '  Alt + 2           - ligar voz posição 2 memória'
    else if f = 'EDAJDIC9'    then textoAjuda := '  Alt + 3           - ligar voz posição 3 memória'
    else if f = 'EDAJDIC10'    then textoAjuda := '  Alt + 4           - ligar voz posição 4 memória'
    else if f = 'EDAJDIC11'    then textoAjuda := '  Alt + 5           - ligar voz posição 5 memória'
    else if f = 'EDAJDIC12'    then textoAjuda := '  Alt + 6           - ligar voz posição 6 memória'
    else if f = 'EDAJDIC13'    then textoAjuda := '  Alt + 7           - ligar voz posição 7 memória'
    else if f = 'EDAJDIC14'    then textoAjuda := '  Alt + 8           - ligar voz posição 8 memória'
    else if f = 'EDAJDIC15'    then textoAjuda := '  Alt + 9           - ligar voz posição 9 memória'
    else if f = 'EDAJDIC16'   then textoAjuda := '  Ctrl + F7         - ampliar tamanho da tela'
    else if f = 'EDAJDIC17'   then textoAjuda := '  Ctrl + F12        - falar versão'

    else if f = 'EDAJTC1'     then textoAjuda := 'Os tipos de codificação são:'
    else if f = 'EDAJTC2'     then textoAjuda := '  A - ANSI'
    else if f = 'EDAJTC3'     then textoAjuda := '  U - UTF-8'
    else if f = 'EDAJTC4'     then textoAjuda := '  N - Unicode'
    else if f = 'EDAJTC5'     then textoAjuda := '  B - Unicode Big'

    else if f = 'EDAJLE1'  then textoAjuda := 'Os comandos de letras especiais são:'
    else if f = 'EDAJLE2'  then textoAjuda := '  A - a sobrescrito'
    else if f = 'EDAJLE3'  then textoAjuda := '  O - o sobrescrito'
    else if f = 'EDAJLE4'  then textoAjuda := '  G - grau'
    else if f = 'EDAJLE5'  then textoAjuda := '  D - data de hoje'
    else if f = 'EDAJLE6'  then textoAjuda := '  I - data invertida'
    else if f = 'EDAJLE7'  then textoAjuda := '  S - dia data hora'
    else if f = 'EDAJLE8'  then textoAjuda := '  H - hora'
    else if f = 'EDAJLE9'  then textoAjuda := '  P - parágrafo'
    else if f = 'EDAJLE10' then textoAjuda := '  Q - barra'
    else if f = 'EDAJLE11' then textoAjuda := '  W - interrogação'
    else if f = 'EDAJLE12' then textoAjuda := '  R - quebra de página'
    else if f = 'EDAJLE13' then textoAjuda := '  E - Euro'
    else if f = 'EDAJLE14' then textoAjuda := '  T - Tab'
    else if f = 'EDAJLE15' then textoAjuda := '  X - travessão'
    else if f = 'EDAJLE16' then textoAjuda := '  Z - traço'
    else if f = 'EDAJLE17' then textoAjuda := '  ? - interrogação reversa'
    else if f = 'EDAJLE18' then textoAjuda := '  ! - exclamação reversa'
    else if f = 'EDAJLE19' then textoAjuda := '  B - bolinha'
    else if f = 'EDAJLE20' then textoAjuda := '  C - copyright'
    else if f = 'EDAJLE21' then textoAjuda := '  M - marca registrada'
    else if f = 'EDAJLE22' then textoAjuda := '  L - libra'
    else if f = 'EDAJLE23' then textoAjuda := '  + - mais ou menos'
    else if f = 'EDAJLE24' then textoAjuda := '  1 - um sobrescrito'
    else if f = 'EDAJLE25' then textoAjuda := '  2 - dois sobrescrito'
    else if f = 'EDAJLE26' then textoAjuda := '  3 - três sobrescrito'
    else if f = 'EDAJLE27' then textoAjuda := '  4 - um quarto'
    else if f = 'EDAJLE28' then textoAjuda := '  5 - um meio'
    else if f = 'EDAJLE29' then textoAjuda := '  6 -  três quartos'
    else if f = 'EDAJLE30' then textoAjuda := '  * - vezes'
    else if f = 'EDAJLE31' then textoAjuda := '  / - dividido por'
    else if f = 'EDAJLE32' then textoAjuda := '  . - reticências'
    else if f = 'EDAJLE33' then textoAjuda := '  '' - apóstrofo'
    else if f = 'EDAJLE34' then textoAjuda := '  < - abre aspas'
    else if f = 'EDAJLE35' then textoAjuda := '  > - fecha aspas'

;
end;

{--------------------------------------------------------}

function txtmsg (f: string): string;
begin
    if f = 'EDMSGINI' then txtmsg := 'EDIVOX - v.' + VERSAO + ' ' + ALFABETA + ^m+^j+
                                'Autor: Marcelo Pimentel'
    else
    if f = 'EDSEMTRD' then txtmsg := 'Erro no diretório do tradutor'
    else
    if f = 'EDQUERSV' then txtmsg := 'Quer salvar o arquivo (s/n) ? '
    else
    if f = 'EDFIMPRC' then txtmsg := 'Fim do EDIVOX - Autor: Marcelo Pimentel'
    else
    if f = 'EDDIGNOM' then txtmsg := 'Qual o nome do Arquivo? '
    else
    if f = 'EDREESCR' then txtmsg := 'Arquivo já existe, reescreve (s/n) ?'
    else
    if f = 'EDARQGRV' then txtmsg := 'Arquivo gravado'
    else
    if f = 'EDARTRUN' then txtmsg := 'Arquivo enorme foi truncado'
    else
    if f = 'EDARQNOV' then txtmsg := 'Arquivo novo'
    else
    if f = 'EDARQCRG' then txtmsg := 'Arquivo carregado'
    else
    if f = 'EDQUERSN' then txtmsg := 'Quer salvar este texto (s/n)'
    else
    if f = 'EDERRESC' then txtmsg := 'Erro de escrita no arquivo'
    else
    if f = 'EDERRLEI' then txtmsg := 'Erro de leitura no arquivo'
    else
    if f = 'EDOPRINV' then txtmsg := 'Operação inválida'
    else
    if f = 'EDLINHA'  then txtmsg := 'Linha: '
    else
    if f = 'EDLINHAS'  then txtmsg := 'Linhas'
    else
    if f = 'EDCOLUNA' then txtmsg := 'Coluna: '
    else
    if f = 'EDDEL'    then txtmsg := 'DEL'
    else
    if f = 'EDFALDLG' then txtmsg := 'Fala desligada'
    else
    if f = 'EDFALACI' then txtmsg := 'Fala acionada'
    else
    if f = 'EDLINREM' then txtmsg := 'Linha removida'
    else
    if f = 'EDCNFSAI' then txtmsg := 'Confirma saida (s/n) ? '
    else
    if f = 'EDDIGMD'  then txtmsg := 'Informe a margem direita: '
    else
    if f = 'EDDIGME'  then txtmsg := 'Informe a margem esquerda: '
    else
    if f = 'EDMARINV' then txtmsg := 'Margem invalida'
    else
    if f = 'EDMARACI' then txtmsg := 'Margem acionada'
    else
    if f = 'EDACENT'  then txtmsg := 'Acentuacao acionada'
    else
    if f = 'EDNACENT' then txtmsg := 'Acentuacao desligada'
    else
    if f = 'EDINITEX' then txtmsg := 'Inicio do texto'
    else
    if f = 'EDFIMTEX' then txtmsg := 'Fim do texto'
    else
    if f = 'EDBLKMOV' then txtmsg := 'Bloco movido'
    else
    if f = 'EDBLKCPY' then txtmsg := 'Bloco copiado'
    else
    if f = 'EDBLKCRG' then txtmsg := 'Bloco carregado'
    else
    if f = 'EDBLKADC' then txtmsg := 'Bloco adicionado'
    else
    if f = 'EDBLKORD' then txtmsg := 'Bloco ordenado'
    else
    if f = 'EDBLKCNT' then txtmsg := 'Bloco centrado'
    else
    if f = 'EDBLKTAB' then txtmsg := 'Bloco tabulado'
    else
    if f = 'EDBLKMRG' then txtmsg := 'Bloco margeado'
    else
    if f = 'EDBLKALI' then txtmsg := 'Bloco alinhado'
    else
    if f = 'EDBLKPAR' then txtmsg := 'Bloco parágrafo'
    else
    if f = 'EDBLKLIN' then txtmsg := 'Bloco linha'
    else
    if f = 'EDBLKINV' then txtmsg := 'Bloco invalido'
    else

    if f = 'EDBLKREM' then txtmsg := 'Bloco removido'
    else
    if f = 'EDCMDBLK' then txtmsg := 'Comando de bloco: '
    else
    if f = 'EDBLKMAR' then txtmsg := 'Bloco marcado'
    else
    if f = 'EDINCOMP' then txtmsg := 'Bloco incompleto'
    else
    if f = 'EDINIBLK' then txtmsg := 'Inicio do bloco'
    else
    if f = 'EDFIMBLK' then txtmsg := 'Fim do bloco'
    else
    if f = 'EDJUSTIF' then txtmsg := 'Trecho justificado'
    else
    if f = 'EDPOSINV' then txtmsg := 'Posição de bloco invalida'
    else
    if f = 'EDBLKDSM' then txtmsg := 'Bloco desmarcado'
    else
    if f = 'EDLINQUE' then txtmsg := 'Linha quebrada'
    else
    if f = 'EDAPAINI' then txtmsg := 'Apagado a esquerda'
    else
    if f = 'EDAPAFIM' then txtmsg := 'Apagado a direita'
    else
    if f = 'EDLINSER' then txtmsg := 'Linha nova'
    else
    if f = 'EDLGRAND' then txtmsg := 'Linha excederia 250 letras, não juntei'
    else
    if f = 'EDLINJUN' then txtmsg := 'Linhas juntadas'
    else
    if f = 'EDTXTPRC' then txtmsg := 'Qual o texto ? '
    else
    if f = 'EDTXTENC' then txtmsg := 'Texto encontrado'
    else
    if f = 'EDTXNENC' then txtmsg := 'Texto não encontrado'
    else
    if f = 'EDTXTTRC' then txtmsg := 'Texto trocado'
    else
    if f = 'EDRETHIF' then txtmsg := 'Retirando hifenização ...'

    else
    if f = 'EDQUATRE' then txtmsg := 'Qual o texto nas linhas a excluir?'
    else
    if f = 'EDQPEXCLU' then txtmsg := 'Qual o texto da posição a excluir? '

    else
    if f = 'EDARQNAO' then txtmsg := 'Arquivo não existe'
    else
    if f = 'EDNOME'   then txtmsg := 'Nome deste arquivo: '
    else
    if f = 'EDFORTXT' then txtmsg := 'Usa acentuacao internacional (s/n) '

    else
    if f = 'EDLINGRA' then txtmsg := 'Linhas grandes foram divididas'
    else
    if f = 'EDNOMGRV' then txtmsg := 'Nome do arquivo a gravar: '
    else
    if f = 'EDESCCAN' then txtmsg := 'Gravacao de arquivo cancelada'
    else
    if f = 'EDDGNLIN' then txtmsg := 'Digite o numero da linha: '
    else
    if f = 'EDLINAO'  then txtmsg := 'Linha não existe'
    else
    if f = 'EDVELOC'  then txtmsg := 'Qual a velocidade, de 1 a 5? '
    else
    if f = 'EDCOLMAR' then txtmsg := 'Informe a coluna da esquerda: '
    else
    if f = 'EDNCLIND' then txtmsg := 'Numero de colunas a indentar: '
    else
    if f = 'EDDESIST' then txtmsg := 'Desistiu... '
    else
    if f = 'EDTABINS' then txtmsg := 'Tabulacao inserida'
    else
    if f = 'EDTABCAN' then txtmsg := 'Tabulacoes canceladas'
    else
    if f = 'EDENTINS' then txtmsg := 'Enter vai inserir linha'
    else
    if f = 'EDENTNIN' then txtmsg := 'Enter não vai inserir linha'
    else
    if f = 'EDSOLETR' then txtmsg := 'Soletragem acionada'
    else
    if f = 'EDNSOLET' then txtmsg := 'Soletragem desligada'
    else
    if f = 'EDMEMPEQ' then txtmsg := 'Memoria muito reduzida.  Tecle ENTER.'
    else
    if f = 'EDINFTXT' then txtmsg := 'Informe o novo texto: '
    else
    if f = 'EDTODBLK' then txtmsg := 'Todo texto (T) ou bloco (B): '
    else
    if f = 'EDCOMAND' then txtmsg := 'Qual comando? '
    else
    if f = 'EDOPCAO'  then txtmsg := 'Qual opcao? '
    else
    if f = 'EDQAUTO'  then txtmsg := 'Quebra automatica ligada'
    else
    if f = 'EDNQAUTO' then txtmsg := 'Quebra automatica desligada'

    else
    if f = 'EDNUM'    then txtmsg := 'Num Lock ligado'
    else
    if f = 'EDNONUM'  then txtmsg := 'Num Lock desligado'
    else
    if f = 'EDCAPS'   then txtmsg := 'Caps Lock ligado'
    else
    if f = 'EDNOCAPS' then txtmsg := 'Caps Lock desligado'
    else
    if f = 'EDERRSRV' then txtmsg := 'Erro no servidor'
    else
    if f = 'EDGRANDE' then txtmsg := 'Bloco muito grande'

    else
    if f = 'EDCOPTRU' then txtmsg := 'Bloco não pode ser transcrito por tem mais de 65000 letras'
    else
    if f = 'EDBLKTRN' then txtmsg := 'Bloco trazido foi truncado por ser muito grande'
    else
    if f = 'EDDICNAO' then txtmsg := 'Dicionário não foi achado'
    else
    if f = 'EDUTF8'   then txtmsg := 'Escolha q para quoted-printable, u para utf-8, g para yahoogroups ou O para Oem'
    else
    if f = 'EDAGUARD' then txtmsg := 'Aguarde ...'
    else
    if f = 'EDDESCON' then txtmsg := 'Deseja tentar converter o arquivo para TXT? '
    else
    if f = 'EDMAIUSC' then txtmsg := 'Deseja converter o bloco para maiúscula? '
    else
    if f = 'EDPUTF8' then txtmsg := 'Deseja codificar o bloco para UTF-8'
    else
    if f = 'EDDECODI' then txtmsg := 'Deseja decodificar o texto?'
    else
    if f = 'EDDICIOA' then txtmsg := 'Dicionário ativado'
    else
    if f = 'EDDICIOD' then txtmsg := 'Dicionário desativado'
    else
    if f = 'EDPALCOR' then txtmsg := 'Palavra correta'
    else
    if f = 'EDPALADI' then txtmsg := 'Palavra adicionada'

    else
    if f = 'EDCONVER' then txtmsg := 'Conversões. Tecle F1 para ajuda.'
    else
    if f = 'EDINFPOT' then txtmsg := 'Qual a potência?'

    else
    if f = 'EDSEMSUG' then txtmsg := 'Sem sugestões'
    else
    if f = 'EDALTERN' then txtmsg := 'Use as setas para alternativas'
    else
    if f = 'EDOK'     then txtmsg := 'OK'
    else
    if f = 'EDPAICON' then txtmsg := 'Painel de configuração'
    else
    if f = 'EDMARDIR' then txtmsg := 'Margem direita: '
    else
    if f = 'EDDICATI' then txtmsg := 'O dicionário será ativado'
    else
    if f = 'EDAGUARC' then txtmsg := 'Aguarde, configurando'
    else
    if f = 'EDCARDIC' then txtmsg := 'Carregando dicionário'
    else
    if f = 'EDREFORM' then txtmsg := 'Junta linhas para exportar? '

    else
    if f = 'EDNEXEC' then txtmsg := 'Não pude executar'

    else
    if f = 'EDINFVAL' then txtmsg := 'Informe o valor '
    else
    if f = 'EDFONTES' then txtmsg := 'Fontes'
    else
    if f = 'EDDE' then txtmsg := ' de '
    else
    if f = 'EDLIDO' then txtmsg := ' lido '
    else
    if f = 'EDTXTNEX' then txtmsg := 'Falta o arquivo txtword.exe'
    else
    if f = 'EDDIGTAM' then txtmsg := 'Digite o tamanho da fonte'
    else
    if f = 'EDOPCINV' then txtmsg := 'Opção inválida'
    else
    if f = 'EDINSFOR' then txtmsg := 'Inserir marcas de formatação'

    else
    if f ='EDAUTOMA' then txtmsg := 'Automática'
    else
    if f ='EDPRETO' then txtmsg := 'Preto'
    else
    if f ='EDAZUL' then txtmsg := 'Azul'
    else
    if f ='EDTURQUE' then txtmsg := 'Turquesa'
    else
    if f ='EDVERCLA' then txtmsg := 'Verde claro'
    else
    if f ='EDROSA' then txtmsg := 'Rosa'
    else
    if f ='EDVERMEL' then txtmsg := 'Vermelho'
    else
    if f ='EDAMAREL' then txtmsg := 'Amarelo'
    else
    if f ='EDBRANCO' then txtmsg := 'Branco'
    else
    if f ='EDAZUESC' then txtmsg := 'Azul escuro'
    else
    if f ='EDCERCET' then txtmsg := 'Cerceta'
    else
    if f ='EDVERDE' then txtmsg := 'Verde'
    else
    if f ='EDVIOLET' then txtmsg := 'Violeta'
    else
    if f ='EDVERESC' then txtmsg := 'Vermelho escuro'
    else
    if f ='EDAMAESC' then txtmsg := 'Amarelo escuro'
    else
    if f ='EDCINZ50' then txtmsg := 'Cinza 50'
    else
    if f ='EDCINZ25' then txtmsg := 'Cinza 25'

    else
    if f = 'EDFONTE' then txtmsg := 'Fonte'
    else
    if f = 'EDTAMANH' then txtmsg := 'Tamanho'
    else
    if f = 'EDALIJUS' then txtmsg := 'Alinhamento justificado'
    else
    if f = 'EDALICEN' then txtmsg := 'Alinhamento centralizado'
    else
    if f = 'EDALIESQ' then txtmsg := 'Alinhamento à esquerda'
    else
    if f = 'EDALIDIR' then txtmsg := 'Alinhamento à direita'
    else
    if f = 'EDININEG' then txtmsg := 'Início de negrito'
    else
    if f = 'EDFIMNEG' then txtmsg := 'Fim de negrito'
    else
    if f = 'EDINIITA' then txtmsg := 'Início de itálico'
    else
    if f = 'EDFIMITA' then txtmsg := 'Fim de itálico'
    else
    if f = 'EDINISUB' then txtmsg :=  'Início de sublinhado'
    else
    if f = 'EDFIMSUB' then txtmsg :=  'Fim de sublinhado'
    else
    if f = 'EDNEGRIT' then txtmsg := 'Negrito'
    else
    if f = 'EDITALIC' then txtmsg := 'Itálico'
    else
    if f = 'EDSUBLIN' then txtmsg := 'Sublinhado'
    else
    if f = 'EDMINUSC' then txtmsg := 'Deseja converter o bloco para minúscula?'
    else
    if f = 'EDPRIMAI' then txtmsg := 'Deseja converter primeira letra de todo bloco para maiúscula?'
    else
    if f = 'EDPALAVR' then txtmsg := 'palavras'
    else
    if f = 'EDLETPAL' then txtmsg := 'letras e palavras'
    else
    if f = 'EDLETRAS' then txtmsg := 'letras'
    else
    if f = 'EDSOMLEI' then txtmsg := 'Este arquivo é somente leitura, provavelmente não será gravado'
    else
    if f = 'EDFOROCU' then txtmsg := 'Formatação oculta na tela'
    else
    if f = 'EDFORAPA' then txtmsg := 'Formatação aparente na tela'
    else
    if f = 'EDMOFAFO' then txtmsg := 'Modos de falar formatação'
    else
    if f = 'EDRETOMA' then txtmsg := 'Retomando na linha '
    else
    if f = 'EDRECUST' then txtmsg := 'Edições recentes, use as setas.'
    else
    if f = 'EDPDFNEX' then txtmsg := 'Falta instalar o conversor de PDF para TXT, pdftotext'
    else
    if f = 'EDEPUNAO' then txtmsg := 'Conversor de formato EPUB não pode ser ativado'
    else
    if f = 'EDBLBNAO' then txtmsg := 'Conversor Blb2txt não foi encontrado'
    else
    if f = 'EDDICBLB' then txtmsg := 'Arquivo blb2txt.dic não foi encontrado'

    else
    if f = 'EDCFVEL'  then txtmsg := 'Use as setas para selecionar.'
    else
    if f = 'EDVELC'   then txtmsg := 'Velocidade: '
    else
    if f = 'EDINSLIN' then txtmsg := 'ENTER insere linha: '
    else
    if f = 'EDQUEAUT' then txtmsg := 'Quebrar linhas: '
    else
    if f = 'EDFALPON' then txtmsg := 'Falar pontuação: '
    else
    if f = 'EDFALLET' then txtmsg := 'Falar letras: '
    else
    if f = 'EDFALPAL' then txtmsg := 'Falar palavras: '
    else
    if f = 'EDFALAUT' then txtmsg := 'Fala automática: '
    else
    if f = 'EDCOMDIC' then txtmsg := 'Com dicionário: '
    else
    if f = 'EDCORRTD' then txtmsg := '  Corrigir tudo: '
    else
    if f = 'EDMODFOR' then txtmsg := 'Modo formatação (N, F, B ou M): '
    else
    if f = 'EDCOMSAP' then txtmsg := 'Com SAPI: '
    else
    if f = 'EDNUMSAP' then txtmsg := 'Número SAPI: '
    else
    if f = 'EDVEL'    then txtmsg := 'Velocidade SAPI: '
    else
    if f = 'EDTOM'    then txtmsg := 'Tonalidade SAPI: '
    else
    if f = 'EDTIPSAP' then txtmsg := 'Tipo SAPI (3, 4 ou 5): '
    else
    if f = 'EDTIPSPX' then txtmsg := 'Tipo SAPI (3, 4, 5 ou 54): '

    else
    if f = 'EDDGNUPA' then txtmsg := 'Digite o numero da página: '
    else
    if f = 'EDPAGNAO' then txtmsg := 'Página não existe.'

    else if f = 'EDPROANT' then txtmsg := 'Procurar anterior'
    else if f = 'EDPROPRO' then txtmsg := 'Procurar próxima'
    else if f = 'EDMEMORI' then txtmsg := 'memorizada'
    else if f = 'EDPTPBR'  then txtmsg := 'Traduzindo de Pt para Br ...'
    else if f = 'EDBRPPT'  then txtmsg := 'Traduzindo de Br para Pt ...'
    else if f = 'EDLIMTXT' then txtmsg := 'Limpando o texto ...'
    else if f = 'EDPAGINA' then txtmsg := 'Página '

    else if f = 'EDUSESET' then txtmsg := 'Use as setas.'
    else if f = 'EDDESSEL' then txtmsg := 'deselecionado'
    else if f = 'EDSELECI' then txtmsg := 'Selecionado'
    else if f = 'EDDESFEI' then txtmsg := 'desfeito'
    else if f = 'EDREFEIT' then txtmsg := 'Refeito'

    else if f = 'EDPRONEN' then txtmsg := 'Programa não encontrado'
    else if f = 'EDDICION' then txtmsg := 'Dicionários - use as setas para selecionar.'
    else if f = 'EDAJDP1'  then txtmsg := 'Português'
    else if f = 'EDAJDP2'  then txtmsg := 'Vocabulário Ortográfico da Língua Portuguesa (VOLP)'
    else if f = 'EDAJDP3'  then txtmsg := 'Webster'
    else if f = 'EDAJDP4'  then txtmsg := 'Oxford'
    else if f = 'EDAJDP5'  then txtmsg := 'Espanhol - Espanhol'
    else if f = 'EDAJDP6'  then txtmsg := 'Informática'
    else if f = 'EDAJDP7'  then txtmsg := 'Jurídico Brasileiro'
    else if f = 'EDAJDP8'  then txtmsg := 'Psicologia'
    else if f = 'EDAJDP9'  then txtmsg := 'Filosofia'
    else if f = 'EDAJDP10' then txtmsg := 'Sociologia'
    else if f = 'EDAJDP11' then txtmsg := 'Química'
    else if f = 'EDAJDP12' then txtmsg := 'Significados'
    else if f = 'EDAJDT1'  then txtmsg := 'Inglês - Português - Inglês'
    else if f = 'EDAJDT2'  then txtmsg := 'Português - Inglês - Português'
    else if f = 'EDAJDT3'  then txtmsg := 'Espanhol - Português - Espanhol'
    else if f = 'EDAJDT4'  then txtmsg := 'Português - Espanhol - Português'
    else if f = 'EDAJDT5'  then txtmsg := 'Italiano - Português - Italiano'
    else if f = 'EDAJDT6'  then txtmsg := 'Português - Italiano - Português'
    else if f = 'EDAJDT7'  then txtmsg := 'Francês - Português - Francês'
    else if f = 'EDAJDT8'  then txtmsg := 'Alemão - Português'
    else if f = 'EDAJDT9'  then txtmsg := 'Esperanto - Português'
    else if f = 'EDAJDT10' then txtmsg := 'Latim - Inglês - Latim'
    else if f = 'EDAJDT11' then txtmsg := 'Inglês - Latim - Inglês'
    else if f = 'EDAJDT12' then txtmsg := 'Inglês - Espanhol'
    else if f = 'EDAJDO1'  then txtmsg := 'Significado e origem dos nomes'
    else if f = 'EDAJDO2'  then txtmsg := 'Origem da Palavra'
    else if f = 'EDAJDO3'  then txtmsg := 'Origem da Palavra 2'
    else if f = 'EDAJDO4'  then txtmsg := 'Etimológico - Origem das Palavras'
    else if f = 'EDAJDO5'  then txtmsg := 'Jurídico de Latim'
    else if f = 'EDAJDO6'  then txtmsg := 'Bíblia de Almeida'
    else if f = 'EDAJDO7'  then txtmsg := 'Eletrônica em espanhol'
    else if f = 'EDAJDO8'  then txtmsg := 'Grego em português com Concordância em grego nas informações'
    else if f = 'EDAJDO9'  then txtmsg := 'Grego com Concordância em grego nas informações'
    else if f = 'EDAJDO10' then txtmsg := 'Hebraico em português com Concordância em hebraico nas informações'
    else if f = 'EDAJDO11' then txtmsg := 'Hebraico com Concordância em hebraico nas informações'
    else if f = 'EDAJDO12' then txtmsg := 'Bíblico da Torre de Vigia'

    else if f = 'EDQUACOD' then txtmsg := 'Qual codificação desejada? '

    else if f = 'EDCOANSI' then txtmsg := 'ANSI'
    else if f = 'EDCOUTF8' then txtmsg := 'UTF-8'
    else if f = 'EDCOUNIC' then txtmsg := 'Unicode'
    else if f = 'EDCOUNIB' then txtmsg := 'Unicode Big'

    else if f = 'EDNRECON' then txtmsg := 'Não consegui realizar a conexão'
    else if f = 'EDPANEN'  then txtmsg := 'Palavra não encontrada'

    //      Mensagens do edTraduvox.pas
    else if f = 'EDNPTRMA'    then txtmsg := 'não pode ter mais de '
    else if f = 'EDLINDST'    then txtmsg := 'Selecione a língua destino com as setas: '
    else if f = 'EDINGLES'    then txtmsg := 'Inglês'
    else if f = 'EDPORTUG'    then txtmsg := 'Português'
    else if f = 'EDESPAN'     then txtmsg := 'Espanhol'
    else if f = 'EDFRANC'     then txtmsg := 'Francês'
    else if f = 'EDITALI'     then txtmsg := 'Italiano'
    else if f = 'EDALEMAO'    then txtmsg := 'Alemão'
    else if f = 'EDESPERANTO' then txtmsg := 'Esperanto'

    else if f = 'EDREMLRE'    then txtmsg := 'Removendo linhas repetidas'
    else if f = 'EDRENUPA'    then txtmsg := 'Removendo números das páginas'
    else if f = 'EDDATAIN'    then txtmsg := 'Data inválida'
    else if f = 'EDNAOTRP'    then txtmsg := 'Não tem repetições'
    else if f = 'EDAESQUERDA'  then txtmsg := 'a esquerda'
    else if f = 'EDEDITENT'  then txtmsg := 'Editore e tecle Enter'

    else if f = 'EDSOLNOR' then txtmsg := 'Soletração normal'
    else if f = 'EDSOLBRL' then txtmsg := 'Soletração braille'
    else if f = 'EDSOLAMB' then txtmsg := 'Soletração American Braille Code'

    else
        txtmsg := '----- erro de mensagem ???? ----';
end;

{--------------------------------------------------------}

Procedure FalaSeguinte (f: String);
var s: string;
begin
    s := txtmsg (f);
    write (s);
    textBackground (BLACK);
    clreol;

    if existeArqSom ('EF_' + f) then
        sintSom ('EF_' + f);

    if existeArqSom (f) then
        sintSom (f)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}

Procedure Fala (f: String);
begin
    gotoxy (1, 9);
    textBackground (BLUE);
    falaSeguinte (f);
end;

{--------------------------------------------------------}

function leTeclaMaiusc (var c2:char): char;
var c: char;
begin
    sintLeTecla (c, c2);
    result := upcase (c);
end;

{--------------------------------------------------------}

procedure falaVersao;
begin
    sintSom('EDMSGINI');
    sintSoletra(trim (VERSAO));
    sintetiza (ALFABETA);
end;

{--------------------------------------------------------}

begin
end.
