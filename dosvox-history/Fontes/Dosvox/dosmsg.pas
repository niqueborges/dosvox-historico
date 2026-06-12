unit dosmsg;
interface

uses
    windows, dvcrt, dvWin, dvLenum, sysutils,  dosVars;

procedure mensagem (nomeArq: string; nlf: integer);
function pegaTextoMensagem (nomeArq: string): string;
procedure soletra(s: string; nlf: integer);
procedure sintetFala (s: string; nlf: integer);
procedure inicFala;
procedure limpaBaixo (y: integer);
function  mensErroArquivo (codigo: integer): string;
function pegaDirDosvox: string;

const
    tabNomesDias: array [1..7] of string =
        ('Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado');

    falaNativa: string = 'Fala nativa';

const
    DV_AUT_01 = '    Projeto DOSVOX:                ';
    DV_AUT_02 = 'http://intervox.nce.ufrj.br/dosvox ';
    DV_AUT_03 = '    Dúvidas técnicas:              ';
    DV_AUT_04 = '(021)3938-3198 - CAEC - UFRJ       ';
    DV_AUT_05 = '    Responsável técnico:           ';
    DV_AUT_06 = 'Prof. Dr. Antonio Borges           ';
    DV_AUT_07 = '                                   (021)3938-3339 - antonio2@nce.ufrj.br';
    DV_AUT_08 = '    Autores: Versão 1.0 (1993)     ';
    DV_AUT_08A=                                    'Antonio Borges e Marcelo Pimentel';
    DV_AUT_09 = '             Versão 6.1 (2021)     ';
    DV_AUT_09A=                                    'Antonio Borges, Neno Albernaz,';
    DV_AUT_10 = '                                   Júlio Silveira, Bruna Lima e Patrick Barboza';

var
    dirSons: string;

implementation

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if      nomeArq = 'DV_SISTOP'   then s := 'Sistema DOSVOX'
    else if nomeArq = 'DV_VERSAO'   then s := ' - Versão '
    else if nomeArq = 'DV_NCE'      then s := 'Instituto Tércio Pacitti - NCE/UFRJ'
    else if nomeArq = 'DV_BOMDIA'   then s := 'Bom dia ! '
    else if nomeArq = 'DV_BOATAR'   then s := 'Boa tarde !'
    else if nomeArq = 'DV_BOANOI'   then s := 'Boa noite !'
    else if nomeArq = 'DV_SEF1'     then s := 'Aperte F1 para ajuda.'
    else if nomeArq = 'DV_DOSVOX'   then s := 'DOSVOX - '
    else if nomeArq = 'DV_OQUE'     then s := 'O que você deseja ? '

    else if nomeArq = 'DV_TRAB'     then s := 'Trabalhar com você é sempre bom !'
    else if nomeArq = 'DV_TCHAU'    then s := 'Tchau !'
    else if nomeArq = 'DV_CONFFIM'  then s := 'Confirma o fim do DOSVOX (S/N) ? '

    else if nomeArq = 'DV_OPCINV'   then s := 'Opção inválida.'

    else if nomeArq = 'DV_SUBDIR'   then s := 'Subdiretórios - '
    else if nomeArq = 'DV_DIRATU'   then s := 'O diretório atual é '
    else if nomeArq = 'DV_COMPSDIR' then s := 'Compactar subdiretório'
    else if nomeArq = 'DV_EXECSDIR' then s := 'Executar subdiretório'

    else if nomeArq = 'DV_ABRWEXP'  then s := 'Abrindo diretório no Windows Explorer'

    else if nomeArq = 'DV_OK'       then s := 'Ok ! '

    else if nomeArq = 'DV_INFNDISC' then s := 'Informe novo disco de trabalho: '
    else if nomeArq = 'DV_ERRNDISC' then s := 'Não consegui mudar de disco. Sinto muito.'

    else if nomeArq = 'DV_INFNDIR'  then s := 'Informe o novo diretório de trabalho: '
    else if nomeArq = 'DV_ERRMUD'   then s := 'Desculpe, não consegui mudar para o diretório pedido.'
    else if nomeArq = 'DV_OKMUD'    then s := 'Ok, troquei diretório de trabalho.'

    else if nomeArq = 'DV_DIRCRI'       then s := 'Nome do diretório a criar: '
    else if nomeArq = 'DV_ERRDIRCRI'    then s := 'Desculpe mas não consegui criar o diretório pedido.'
    else if nomeArq = 'DV_OKDIRCRI'     then s := 'Ok, criei o diretório !'

    else if nomeArq = 'DV_ERRREMDIR'    then s := 'Desculpe: não consegui remover o diretório pedido.'
    else if nomeArq = 'DV_OKREMDIR'     then s := 'Ok, apaguei o diretório !'

    else if nomeArq = 'DV_DISCOS'   then s := 'Discos - '
    else if nomeArq = 'DV_TAMANHO'  then s := 'Tamanho: '
    else if nomeArq = 'DV_TAMDSK'   then s := 'Tamanho do disco em K: '
    else if nomeArq = 'DV_LIVDSK'   then s := 'Espaço livre em K: '

    else if nomeArq = 'DV_DRVINV'   then s := 'Unidade inválida.'
    else if nomeArq = 'DV_FORMRAP'  then s := 'Posso usar formatação rápida ? '
    else if nomeArq = 'DV_PROBFORM' then s := 'Problemas na formatação, verifique proteção de escrita.'
    else if nomeArq = 'DV_FORMCANC' then s := 'Formatação cancelada.'

    else if nomeArq = 'DV_SEMSDIR'      then s := 'Não existem subdiretórios aqui.'
    else if nomeArq = 'DV_AJUSDIR1'  then s := 'Subdiretórios: Use as setas para selecionar'
    else if nomeArq = 'DV_AJUSDIR2'  then s := 'Depois tecle sua opção'

    else if nomeArq = 'DV_TECLEFAL'     then s := 'Aperte as teclas e eu falarei.'
    else if nomeArq = 'DV_FIMTECESC'    then s := 'O teste será terminado quando você apertar ESCAPE'

    (***** dostec.pas *********************************************************)
    else if nomeArq = 'DV_TEC_BS'       then s := '<backspace>'
    else if nomeArq = 'DV_TEC_TAB'      then s := '<tab>'
    else if nomeArq = 'DV_TEC_ENTER'    then s := '<enter>'
    else if nomeArq = 'DV_TEC_ESC'      then s := '<escape>'
    else if nomeArq = 'DV_TEC_BRNCO'    then s := '<barra de espaços>'
    else if nomeArq = 'DV_TEC_F1'       then s := 'F1'
    else if nomeArq = 'DV_TEC_F2'       then s := 'F2'
    else if nomeArq = 'DV_TEC_F3'       then s := 'F3'
    else if nomeArq = 'DV_TEC_F4'       then s := 'F4'
    else if nomeArq = 'DV_TEC_F5'       then s := 'F5'
    else if nomeArq = 'DV_TEC_F6'       then s := 'F6'
    else if nomeArq = 'DV_TEC_F7'       then s := 'F7'
    else if nomeArq = 'DV_TEC_F8'       then s := 'F8'
    else if nomeArq = 'DV_TEC_F9'       then s := 'F9'
    else if nomeArq = 'DV_TEC_F10'      then s := 'F10'
    else if nomeArq = 'DV_TEC_F11'      then s := 'F11'
    else if nomeArq = 'DV_TEC_F12'      then s := 'F12'
    else if nomeArq = 'DV_TEC_INS'      then s := '<ins>'
    else if nomeArq = 'DV_TEC_DEL'      then s := '<del>'
    else if nomeArq = 'DV_TEC_HOME'     then s := '<home>'
    else if nomeArq = 'DV_TEC_END'      then s := '<end>'
    else if nomeArq = 'DV_TEC_PGUP'     then s := '<page up>'
    else if nomeArq = 'DV_TEC_PGDN'     then s := '<page down>'
    else if nomeArq = 'DV_TEC_CIMA'     then s := '<cima>'
    else if nomeArq = 'DV_TEC_BAIX'     then s := '<baixo>'
    else if nomeArq = 'DV_TEC_ESQ'      then s := '<esquerda>'
    else if nomeArq = 'DV_TEC_DIR'      then s := '<direita>'
    else if nomeArq = 'DV_TEC_AGU'      then s := '<agudo>'
    else if nomeArq = 'DV_TEC_APOST'    then s := '<apóstrofo>'

    else if nomeArq = 'DV_SHIFT'    then s := '<shift>'
    else if nomeArq = 'DV_CONTRL'   then s := '<control>'
    else if nomeArq = 'DV_NUM'      then s := '<num.lock>'
    else if nomeArq = 'DV_NONUM'    then s := '<sem num.lock>'
    else if nomeArq = 'DV_CAPS'     then s := '<caps lock>'
    else if nomeArq = 'DV_NOCAPS'   then s := '<sem caps lock>'
    else if nomeArq = 'DV_ALT'      then s := '<alt>'
    else if nomeArq = 'DV_CTLALT'   then s := '<control alt>' {Alt GR}
    else if nomeArq = 'DV_CTLALT2'   then s := 'control alt'
    else if nomeArq = 'DV_BLWIN'    then s := '<iniciar>'
    else if nomeArq = 'DV_BRWIN'    then s := '<iniciar>'
    else if nomeArq = 'DV_BRAPPL'   then s := '<aplicações>'
    else if nomeArq = 'DV_BPAUSE'   then s := '<pause>'
    else if nomeArq = 'DV_BSLOCK'   then s := '<scroll lock>'
    else if nomeArq = 'DV_BPRSCR'   then s := '<print screen>'
    else if nomeArq = 'DV_FIMTESTE' then s := 'O teste está encerrado.'

    (***** doscopia.pas - Mensagens de operações com arquivos *****************)
    else if nomeArq = 'DV_ERRARQ_0K'    then s := 'Operação completada.'
    else if nomeArq = 'DV_ERRARQ_NOK'   then s := 'Operação não completada.'
    else if nomeArq = 'DV_ERRARQ_*'     then s := 'Erro genérico de operação com arquivos ou pastas.'
    else if nomeArq = 'DV_ERRARQ_02'    then s := 'Erro: arquivo não encontrado.'
    else if nomeArq = 'DV_ERRARQ_03'    then s := 'Erro: caminho não encontrado.'
    else if nomeArq = 'DV_ERRARQ_05'    then s := 'Erro: acesso negado.'
    else if nomeArq = 'DV_ERRARQ_15'    then s := 'Erro: drive não encontrado.'
    else if nomeArq = 'DV_ERRARQ_17'    then s := 'Erro: arquivo não pode ser movido para outro drive.'
    else if nomeArq = 'DV_ERRARQ_19'    then s := 'Erro: mídia protegida para escrita.'
    else if nomeArq = 'DV_ERRARQ_23'    then s := 'Erro: CRC.'
    else if nomeArq = 'DV_ERRARQ_26'    then s := 'Erro: unidade inacessível.'
    else if nomeArq = 'DV_ERRARQ_29'    then s := 'Erro de escrita no dispositivo.'
    else if nomeArq = 'DV_ERRARQ_30'    then s := 'Erro de leitura no dispositivo.'
    else if nomeArq = 'DV_ERRARQ_39'    then s := 'Erro: disco ou mídia sem espaço.'
    else if nomeArq = 'DV_ERRARQ_80'    then s := 'Erro: arquivo já existente.'
    else if nomeArq = 'DV_ERRARQ_82'    then s := 'Erro: pasta não pode ser criada.'
    else if nomeArq = 'DV_ERRARQ_83'    then s := 'Erro fatal: INT 24.'
    else if nomeArq = 'DV_ERRARQ_108'   then s := 'Erro: disco inacessível.'
    else if nomeArq = 'DV_ERRARQ_110'   then s := 'Erro: arquivo ou dispositivo não pode ser aberto.'
    else if nomeArq = 'DV_ERRARQ_111'   then s := 'Erro: nome de arquivo muito longo.'
    else if nomeArq = 'DV_NOARQMAU'   then s := 'Nome de Arquivo mal formado, sugiro trocar o nome.'
    else if nomeArq = 'DV_COAUNO'   then s := 'Corrijo automaticamente o nome do arquivo?'
    else if nomeArq = 'DV_ERRARQ_112'   then s := 'Erro: disco ou mídia sem espaço.'
    else if nomeArq = 'DV_ERRARQ_123'   then s := 'Erro: nome inválido de arquivo, pasta ou unidade.'
    else if nomeArq = 'DV_ERRARQ_161'   then s := 'Erro: caminho inválido.'
    else if nomeArq = 'DV_ERRARQ_183'   then s := 'Erro: criação de arquivo já existente.'
    else if nomeArq = 'DV_ERRARQ_206'   then s := 'Erro: nome ou extensão de arquivo muito longos.'
    else if nomeArq = 'DV_ERRARQ_267'   then s := 'Erro: nome inválido de pasta.'
    else if nomeArq = 'DV_ERRARQ_1112'  then s := 'Erro: sem mídia na unidade.'
    else if nomeArq = 'DV_ERRARQ_1235'  then s := 'Operação abortada pelo usuário.'

    (***** dosdir.pas *********************************************************)
    else if nomeArq = 'DV_ESCARQ' then s := 'Arquivos - '

    (***** dosarq.pas *********************************************************)
    else if nomeArq = 'DV_ARQ1'   then s := 'Arquivos: use as setas para selecionar.'
    else if nomeArq = 'DV_ARQ2'   then s := 'Depois tecle sua opção.'
    else if nomeArq = 'DV_ALTERAR'then s := 'Alterar'

    (***** dosarq.pas - editaLeUmArquivo *****)
    else if nomeArq = 'DV_ERRNAOED'  then s := 'Este arquivo não pode ser editado.'
    else if nomeArq = 'DV_ERRNAOTXT' then s := 'Este arquivo não pode ser processado textualmente.'
    else if nomeArq = 'DV_ERRZIP'    then s := 'Este é um arquivo compactado. Use a função executar.'

    else if nomeArq = 'DV_OPCAO'    then s := ' opção '
    else if nomeArq = 'DV_PROBDISC' then s := 'Cuidado, houve problemas no disco !'
    else if nomeArq = 'DV_NAOSELEC' then s := 'Não posso fazer: não existe nenhum arquivo selecionado.'

    else if nomeArq = 'DV_DATACRI' then s := 'Data de criação: '
    else if nomeArq = 'DV_HORACRI' then s := 'Hora de criação: '

    else if nomeArq = 'DV_CNF_ARQLIX'   then s := 'Confirma envio para a lixeira de '
    else if nomeArq = 'DV_CNF_ARQEXC'   then s := 'Confirma exclusão definitiva de '
    else if nomeArq = 'DV_SIMNAO'       then s := ' (S/N)? '
    else if nomeArq = 'DV_SNTOD'        then s := 'Sim, não ou todos? '
    else if nomeArq = 'DV_ARQLIX'       then s := 'Arquivo movido para a lixeira.'
    else if nomeArq = 'DV_ARQEXC'       then s := 'Arquivo excluído.'

    else if nomeArq = 'DV_CNFAPA'   then s := 'Confirma remoção de '
    else if nomeArq = 'DV_FOIAPA'   then s := 'Apaguei o arquivo '

    else if nomeArq = 'DV_PROTEG'   then s := 'Arquivo está protegido para regravação'
    else if nomeArq = 'DV_DESPRO'   then s := 'Arquivo está desprotegido'
    else if nomeArq = 'DV_EDITRO'   then s := 'Edite o novo nome'
    else if nomeArq = 'DV_TROCAD'   then s := 'Troquei o nome do arquivo para '

    else if nomeArq = 'DV_MASC'     then s := 'Informe a máscara de seleção, p. ex., *.TXT'
    else if nomeArq = 'DV_MASCSE'   then s := 'Informe a máscara de seleção: '
    else if nomeArq = 'DV_TROCMASC' then s := 'Troquei a máscara de seleção de arquivos para '

    else if nomeArq = 'DV_TIPOCOP'  then s := 'Qual o tipo de cópia ? '

    else if nomeArq = 'DV_TODSEL'   then s := 'Copia todos os selecionados? '
    else if nomeArq = 'DV_INFDEST'  then s := 'Informe o diretório destino: '
    else if nomeArq = 'DV_OPCANCEL' then s := 'Certo, operação foi cancelada'
    else if nomeArq = 'DV_NAOPOD'   then s := 'O arquivo não pode ser copiado sobre si mesmo !'
    else if nomeArq = 'DV_ERRCOPIA' then s := 'Sinto muito, deu erro no disco, portanto não copiei.'
    else if nomeArq = 'DV_MOVIDO'   then s := ' movido.'
    else if nomeArq = 'DV_COPIADO'  then s := ' copiado.'

    else if nomeArq = 'DV_ERROLEIT' then s := 'Houve um erro de leitura no arquivo original.'
    else if nomeArq = 'DV_FALESP'   then s := 'Não existia espaço suficiente para escrever.'
    else if nomeArq = 'DV_NOMECOP'  then s := 'Informe nome do arquivo replica: '
    else if nomeArq = 'DV_CONTSEL'  then s := 'Continue selecionando ou tecle ESC.'
    else if nomeArq = 'DV_NOMEINV'  then s := 'Esse nome que você escolheu não é valido.'
    else if nomeArq = 'DV_FOIREPL'  then s := ' foi replicado.'

    else if nomeArq = 'DV_TECLCMD'  then s := 'Tecle o comando.'

    else if nomeArq = 'DV_COMFBR'   then s := 'Impressão comum, formatada ou braille ? '
    else if nomeArq = 'DV_IMPRCANC' then s := 'A impressão foi cancelada.'

    else if nomeArq = 'DV_ESCVOLTA' then s := 'Tecle ESC para voltar ao DOSVOX.'

    else if nomeArq = 'DV_NOMEAIMP' then s := 'Digite o nome do arquivo a imprimir: '
    else if nomeArq = 'DV_ARQNAOEX' then s := 'Arquivo não existe, sinto muito.'

    else if nomeArq = 'DV_QUERD'    then s := 'Ele vai ser o novo diretório de trabalho '
    else if nomeArq = 'DV_QERSOLET' then s := 'Quer que soletre'

    else if nomeArq = 'DV_TECPGM'   then s := 'Qual a letra do programa ? '
    else if nomeArq = 'DV_TECJOG'   then s := 'Qual a letra do jogo ? '
    else if nomeArq = 'DV_TECRED'   then s := 'Qual a letra do programa de rede ? '
    else if nomeArq = 'DV_TECMUL'   then s := 'Qual a letra do programa de multimídia ? '

    else if nomeArq = 'DV_PRGNAOEX' then s := 'Não existe programa registrado com esta letra.'
    else if nomeArq = 'DV_F1ESC'    then s := 'Tecle F1 para ajuda ou ESC para cancelar.'

    else if nomeArq = 'DV_ERROPRGCOD'   then s := 'Erro na execução do programa: código '
    else if nomeArq = 'DV_ERROPRGEXE'   then s := 'Erro na execução do programa '
    else if nomeArq = 'DV_PRGNAOENC'    then s := 'Programa não encontrado.'

    (***** dosvox.dpr *********************************************************)
    else if nomeArq = 'DV_AJU_OPC'  then s := 'As opções do DOSVOX são:'
    else if nomeArq = 'DV_AJU_T'    then s := '  T - testar o teclado'
    else if nomeArq = 'DV_AJU_E'    then s := '  E - editar texto'
    else if nomeArq = 'DV_AJU_L'    then s := '  L - ler texto'
    else if nomeArq = 'DV_AJU_I'    then s := '  I - imprimir'
    else if nomeArq = 'DV_AJU_A'    then s := '  A - arquivos'
    else if nomeArq = 'DV_AJU_D'    then s := '  D - discos e mídias'
    else if nomeArq = 'DV_AJU_ESC'  then s := '  A tecla ESC é sempre usada para cancelar'
    else if nomeArq = 'DV_AJU_SET'  then s := '  Pode usar as setas para selecionar ou conhecer outras opções'
    else if nomeArq = 'DV_AJU_ENT'  then s := 'Aperte Enter para outras opções'

    else if nomeArq = 'DV_AJU_OUT'  then s := 'Outras opções:'
    else if nomeArq = 'DV_AJU_J'    then s := '  J - jogos'
    else if nomeArq = 'DV_AJU_U'    then s := '  U - utilitários falados'
    else if nomeArq = 'DV_AJU_R'    then s := '  R - acesso à rede e internet'
    else if nomeArq = 'DV_AJU_M'    then s := '  M - multimídia'
    else if nomeArq = 'DV_AJU_P'    then s := '  P - executar um programa do Windows'
    else if nomeArq = 'DV_AJU_S'    then s := '  S - subdiretórios'
    else if nomeArq = 'DV_AJU_Q'    then s := '  Q - informa a quem pertence este DOSVOX'
    else if nomeArq = 'DV_AJU_V'    then s := '  V - vai para outra janela'
    else if nomeArq = 'DV_AJU_C'    then s := '  C - configurar o DOSVOX'

    else if nomeArq = 'DV_AJUTIL'   then s := '  Pode usar as setas para selecionar ou conhecer todas as opções'

    (***** dosarq.pas *********************************************************)
    else if nomeArq = 'DV_NUMARQD'  then s := 'Número de arquivos neste diretório: '
    else if nomeArq = 'DV_NUMARQ'   then s := 'Número de arquivos: '
    else if nomeArq = 'DV_NUMPAST'  then s := 'Número de pastas:   '
    else if nomeArq = 'DV_ERRDIRNA' then s := 'Erro: este diretório não está acessível'
    else if nomeArq = 'DV_PASTAS'   then s := 'Pastas - '

    else if nomeArq = 'DV_AJUA_SET' then s := 'Use as setas para escolher e tecle'
    else if nomeArq = 'DV_AJUA_E'   then s := '  E - editar o arquivo'
    else if nomeArq = 'DV_AJUA_I'   then s := '  I - imprimir'
    else if nomeArq = 'DV_AJUA_L'   then s := '  L - ler'
    else if nomeArq = 'DV_AJUA_R'   then s := '  R - remover'
    else if nomeArq = 'DV_AJUA_X'   then s := '  X - executar o arquivo'
    else if nomeArq = 'DV_AJUA_N'   then s := '  N - trocar o nome'
    else if nomeArq = 'DV_AJUA_C'   then s := '  C - tirar uma cópia'
    else if nomeArq = 'DV_AJUA_D'   then s := '  D - obter dados sobre o arquivo'
    else if nomeArq = 'DV_AJUA_Q'   then s := '  Q - informar qual arquivo do total'
    else if nomeArq = 'DV_AJUA_G'   then s := '  G - exibir um grupo de arquivos'
    else if nomeArq = 'DV_AJUA_T'   then s := '  T - falar o tamanho total dos arquivos'
    else if nomeArq = 'DV_AJUA_P'   then s := '  P - desproteger o arquivo'
    else if nomeArq = 'DV_AJUA_B'   then s := '  B - buscar arquivo contendo texto'
    else if nomeArq = 'DV_AJUA_O'   then s := '  O - ordenar os arquivos'
    else if nomeArq = 'DV_AJUA_M'   then s := '  M - enviar arquivo como email'
    else if nomeArq = 'DV_AJUA_Z'   then s := '  Z - compactar o arquivo'
    else if nomeArq = 'DV_AJUA_F'   then s := '  F - procurar arquivos'
    else if nomeArq = 'DV_AJUA_U'   then s := '   U - converter formatos'

    else if nomeArq = 'DV_AJUA_CTL_B'   then s := '  Ctrl+B - buscar novamente'
    else if nomeArq = 'DV_AJUA_CTL_T'   then s := '  Ctrl+T - falar o tamanho dos selecionados'
    else if nomeArq = 'DV_AJUA_CTL_P'   then s := '  Ctrl+P - proteger o arquivo'
    else if nomeArq = 'DV_AJUA_CTL_C'   then s := '  Ctrl+C - copiar nomes para área de transferência'
    else if nomeArq = 'DV_AJUA_CTL_V'   then s := '  Ctrl+V - copiar arquivos da área de transferência'
    else if nomeArq = 'DV_AJUA_CTL_X'   then s := '  Ctrl+X - mover arquivos para área de transferência'
    else if nomeArq = 'DV_AJUA_CTL_O'   then s := '  Ctrl+O - alterar padrão de ordenação'
    else if nomeArq = 'DV_AJUA_CTL_N'   then s := '  Ctrl+N - jogar os nomes sem incluir diretório'
    else if nomeArq = 'DV_AJUA_CTL_Q'   then s := '  Ctrl+Q - informar quantos selecionados do total'
    else if nomeArq = 'DV_AJUA_CTL_D'   then s := '  Ctrl+D - informar o nome do diretório atual'

    (***** dosdisco.pas *******************************************************)
    else if nomeArq = 'DV_AJUD_OPC' then s := 'As opcoes de manuseio de discos e mídias são:'
    else if nomeArq = 'DV_AJUD_P'   then s := '    P - pastas preferidas'
    else if nomeArq = 'DV_AJUD_T'   then s := '    T - trocar a pasta atual'
    else if nomeArq = 'DV_AJUD_D'   then s := '    D - escolher disco ou mídia atual'
    else if nomeArq = 'DV_AJUD_I'   then s := '    I - informar qual a pasta atual'
    else if nomeArq = 'DV_AJUD_V'   then s := '    V - voltar à pasta anterior'
    else if nomeArq = 'DV_AJUD_B'   then s := '    B - busca de arquivos por nome'
    else if nomeArq = 'DV_AJUD_C'   then s := '    C - criar pasta'
    else if nomeArq = 'DV_AJUD_E'   then s := '    E - espaço livre e tamanho da mídia'
    else if nomeArq = 'DV_AJUD_G'   then s := '    G - gravar mídia'
    else if nomeArq = 'DV_AJUD_R'   then s := '    R - remover mídia'
    else if nomeArq = 'DV_AJUD_N'   then s := '    N - renomear mídia'
    else if nomeArq = 'DV_AJUD_F'   then s := '    F - formatar mídia'
    else if nomeArq = 'DV_AJUD_L'   then s := '    L - esvaziar a lixeira do Dosvox'

    (***** dosBuscaArq.pas ****************************************************)
    else if nomeArq = 'DV_AJUDA_PRMPT'      then s := 'Selecione os parâmetros para a pesquisa de arquivos. Ao final, tecle ESC.'
    else if nomeArq = 'DV_AJUDA_NOME'       then s := 'Nome do arquivo ou máscara'
    else if nomeArq = 'DV_AJUDA_DIRET'      then s := 'Procurar na pasta'
    else if nomeArq = 'DV_AJUDA_SUBDIR'     then s := 'Procurar nas subpastas?'
    else if nomeArq = 'DV_AJUDA_DIRNAO'     then s := 'pasta inexistente ou inacessível.'
    else if nomeArq = 'DV_AJUDA_NENHUM'     then s := 'Nenhum arquivo encontrado.'
    else if nomeArq = 'DV_AJUDA_ARQENC'     then s := 'Arquivos encontrados: '
    else if nomeArq = 'DV_AJUDA_SELEC'      then s := 'Selecione com as setas e tecle opção (ou F9 para menu).'
    else if nomeArq = 'DV_AJUDA_UMARQ'      then s := 'Item selecionado: '
    else if nomeArq = 'DV_AJUDA_MUIARQ'     then s := ' itens selecionados.'
    else if nomeArq = 'DV_AJUDA_SELOPC'     then s := 'Selecione opção: '
    else if nomeArq = 'DV_AJUDA_ERR1ARQ'    then s := 'Esta opção se aplica a apenas um arquivo selecionado.'

    else if nomeArq = 'DV_EDITARQ'  then s := 'Editar arquivo: '
    else if nomeArq = 'DV_LEARQ'    then s := 'Ler arquivo: '
    else if nomeArq = 'DV_EXECARQ'  then s := 'Executar: '
    else if nomeArq = 'DV_MUDADIR'  then s := 'Vai para a pasta: '
    else if nomeArq = 'DV_SELLIX'   then s := 'Mover para lixeira: '
    else if nomeArq = 'DV_SELEXC'   then s := 'Exclusão definitiva: '
    else if nomeArq = 'DV_APLISEL'  then s := 'aplica aos selecionados? '
    else if nomeArq = 'DV_REPBUSCA' then s := 'Repetir busca anterior? '
    else if nomeArq = 'DV_NOVBUSCA' then s := 'Realiza nova busca? '
    else if nomeArq = 'DV_RESTRIBUS'  then s := 'Restrinja sua busca, não é possível mostrar mais de 255000 resultados.'

    (***** dosBuscaArq.pas - selSetasArquivos *****)
        else if nomeArq = 'DV_AJUDA_E'  then s := '  E - editar arquivo selecionado'
        else if nomeArq = 'DV_AJUDA_L'  then s := '  L - ler arquivo selecionado'
        else if nomeArq = 'DV_AJUDA_X'  then s := '  X - executar arquivo selecionado'
        else if nomeArq = 'DV_AJUDA_D'  then s := '  D - dados do arquivo selecionado'
        else if nomeArq = 'DV_AJUDA_T'  then s := '  T - ir para a pasta do arquivo selecionado'
        else if nomeArq = 'DV_AJUDA_R'  then s := '  R - remover arquivos selecionados'
        else if nomeArq = 'DV_AJUDA_C'  then s := '  C - copiar arquivos selecionados'
        else if nomeArq = 'DV_AJUDA_B'  then s := '  B - repetir busca'
        else if nomeArq = 'DV_AJUDA_N'  then s := '  N - nova busca'

    (***** dosdisco.pas - esvaziarLixeira *****)
    else if nomeArq = 'DV_AJUDL_PRMPT'  then s := 'Esvaziar a lixeira do Dosvox. Confirma? '
    else if nomeArq = 'DV_AJUDL_OK'     then s := 'Ok. A lixeira do Dosvox foi esvaziada.'
    else if nomeArq = 'DV_AJUDL_NOK'    then s := 'Erro: a lixeira do Dosvox não foi esvaziada.'
    else if nomeArq = 'DV_LIXEIRAVAZ'    then s := 'Lixeira vazia'

    else if nomeArq = 'DV_AJU_MA'   then s := '  + - folhear mais opções'
    else if nomeArq = 'DV_AJU_F9'   then s := 'Aperte F9 para conhecer outras opções'

    else if nomeArq = 'DV_AJUAC_OPC' then s := 'As opções de cópia de arquivos são:'
    else if nomeArq = 'DV_AJUAC_R'   then s := '  R - criar réplica de um arquivo'
    else if nomeArq = 'DV_AJUAC_D'   then s := '  D - copiar arquivos para outro diretório'
    else if nomeArq = 'DV_AJUAC_M'   then s := '  M - mover arquivos para outro diretório'
    else if nomeArq = 'DV_AJUAC_T'   then s := '  T - copiar todos'

    (***** dosdir.pas *********************************************************)
    else if nomeArq = 'DV_AJUS_OPC'     then s := 'Use as setas, depois acione'
    else if nomeArq = 'DV_AJUS_ENTER'   then s := '  ENTER - seleciona diretório e continua'
    else if nomeArq = 'DV_AJUS_T'       then s := '  T - seleciona e sai'
    else if nomeArq = 'DV_AJUS_S'       then s := '  S - sai indo para o diretório pai'
    else if nomeArq = 'DV_AJUS_C'       then s := '  C - cria novo subdiretório'
    else if nomeArq = 'DV_AJUS_R'       then s := '  R - remove'
    else if nomeArq = 'DV_AJUS_N'       then s := '  N - troca o nome'
    else if nomeArq = 'DV_AJUS_K'       then s := '  K - copia'
    else if nomeArq = 'DV_AJUS_D'       then s := '  D - obtém dados'
    else if nomeArq = 'DV_AJUS_V'       then s := '  V - volta ao penúltimo diretório'
    else if nomeArq = 'DV_AJUS_I'       then s := '  I - informa diretório atual'
    else if nomeArq = 'DV_AJUS_P'       then s := '  P - diretórios preferidos'
    else if nomeArq = 'DV_AJUS_X'       then s := '  X - executar o diretório atual'
    else if nomeArq = 'DV_AJUS_Z'       then s := '  Z - compactar subdiretório'
    else if nomeArq = 'DV_AJUS_G'       then s := '  G - exibir um grupo de subdiretórios'

    else if nomeArq = 'DV_SELJAN'   then s := 'Selecione a nova janela com as setas depois ENTER'

    else if nomeArq = 'DV_TAMMEGA'  then s := 'Tamanho do disco em Mb: '
    else if nomeArq = 'DV_LIVRMEGA' then s := 'Espaço livre em Mb: '

    else if nomeArq = 'DV_SELDIR'   then s := 'Selecione o diretório com as setas'

    else if nomeArq = 'DV_APGSELEC' then s := 'Apaga todos os selecionados? '
    else if nomeArq = 'DV_ARQEXIS1' then s := 'Arquivo destino '
    else if nomeArq = 'DV_ARQEXIS2' then s := ' já existe.  Sobrescreve (S/N/T/ESC)? '
    else if nomeArq = 'DV_DIREXIS'  then s := 'Diretório já existe - '
    else if nomeArq = 'DV_SOBRE_SN' then s := 'Sobrescreve (S/N)? '
    else if nomeArq = 'DV_NAOAPAOR' then s := 'Não pude apagar o arquivo original'

    (***** dosconf.pas ********************************************************)
    else if nomeArq = 'DV_CONF_HEADR' then s := 'DOSVOX - Configuração'
    else if nomeArq = 'DV_CONF_PRMPT' then s := 'Configurações - '
    else if nomeArq = 'DV_AJUC_OPC'   then s := 'As opções de configuração são:'
    else if nomeArq = 'DV_AJUC_P'     then s := '  P - pastas principais'
    else if nomeArq = 'DV_AJUC_D'     then s := '  D - selecionar dispositivo de áudio'
    else if nomeArq = 'DV_AJUC_F'     then s := '  F - fala gravada'
    else if nomeArq = 'DV_AJUC_S'     then s := '  S - fala sintetizada'
    else if nomeArq = 'DV_AJUC_C'     then s := '  C - retorno sonoro em cópias de arquivos'
    else if nomeArq = 'DV_AJUC_A'     then s := '  A - atualização do sistema'
    else if nomeArq = 'DV_AJUC_W'     then s := '  W - iniciar o Dosvox com o Windows'
    else if nomeArq = 'DV_AJUC_I'     then s := '  I - informações sobre o sistema Dosvox'
    else if nomeArq = 'DV_AJUC_B'     then s := '  B - configurações para baixa visão'
    else if nomeArq = 'DV_AJUC_AST'   then s := '  * - configuração avançada'

    else if nomeArq = 'DV_AJUC_IMP'   then s := 'Funcionalidade em fase de implementação'
    else if nomeArq = 'DV_EDITCONF'   then s := 'Editore as configurações, ao final tecle ESC'

    (***** dosconf.pas - definePastaPadraoTrabalho *****)
    else if nomeArq = 'DV_PPADR_MANT' then s := 'Pasta padrão de trabalho mantida. '
    else if nomeArq = 'DV_PPADR_ALT'  then s := 'Ok. Pasta padrão de trabalho alterada para: '
    else if nomeArq = 'DV_PPADR_ALT2' then s := 'Pasta de trabalho também foi alterada.'

    (***** dosconf.pas - leNovaPastaPadraoTrabalho *****)
    else if nomeArq = 'DV_NOVA_PPADR'    then s := 'Informe nome da nova pasta padrão de trabalho:'
    else if nomeArq = 'DV_PASTA_NEX'     then s := 'Pasta não existe. '

    (***** dosconf.pas - configPastaPadraoTrabalho *****)
    else if nomeArq = 'DV_AJUCPT_PRMPT'  then s := 'Escolha a nova pasta padrão: '
    else if nomeArq = 'DV_AJUCPT_PRMPT2' then s := 'Configuração da pasta padrão de trabalho'
    else if nomeArq = 'DV_AJUCPT_CORR'   then s := 'A pasta corrente é: '
    else if nomeArq = 'DV_AJUCPT_PADR'   then s := 'A pasta padrão de trabalho é: '

    else if nomeArq = 'DV_AJUCPT_OPC'    then s := 'As opções de definição da pasta padrão de trabalho são:'
    else if nomeArq = 'DV_AJUCPT_T'      then s := '  T - Treino'
    else if nomeArq = 'DV_AJUCPT_D'      then s := '  D - Meus Documentos'
    else if nomeArq = 'DV_AJUCPT_A'      then s := '  A - pasta de trabalho atual'
    else if nomeArq = 'DV_AJUCPT_O'      then s := '  O - outra pasta'

    else if nomeArq = 'DV_SELITEMREM'    then s := 'Escolha com as setas o item a remover'
    else if nomeArq = 'DV_OPPREF'        then s := 'Folhear, incluir este, remover ou editar?'

    (***** dosconf.pas - configPastas *****)
    else if nomeArq = 'DV_AJUCP_PRMPT' then s := 'Configurações de pastas - '
    else if nomeArq = 'DV_AJUCP_OPC'   then s := 'As opções de configuração de pastas são:'
    else if nomeArq = 'DV_AJUCP_T'     then s := '  T - pasta padrão de trabalho'
    else if nomeArq = 'DV_AJUCP_P'     then s := '  P - configurar pastas preferidas'

    (***** dosconf.pas - selecionaDispAudio *****)
    else if nomeArq = 'DV_AJUCD_PRMPT' then s := 'Selecione o dispositivo de áudio: '
    else if nomeArq = 'DV_AJUCD_SEL'   then s := 'Ok. Selecionado dispositivo de áudio: '

    (***** dosconf.pas - configFalaGravada *****)
    else if nomeArq = 'DV_AJUCF_PRMPT' then s := 'Selecione a velocidade da fala gravada: '
    else if nomeArq = 'DV_AJUCF_OPC'   then s := 'As opções de fala gravada são: '
    else if nomeArq = 'DV_AJUCF_N'     then s := '  N - velocidade normal'
    else if nomeArq = 'DV_AJUCF_R'     then s := '  R - voz mais rápida'
    else if nomeArq = 'DV_AJUCF_B'     then s := '  B - voz de boneca'

    (***** dosconf.pas - configFalaSintetizada *****)
    else if nomeArq = 'DV_AJUCS_PRMPT' then s := 'Configurações de fala sintetizada'
    else if nomeArq = 'DV_SINTET'      then s := 'Sintetizador - use as setas para selecionar'
    else if nomeArq = 'DV_VELOCS'      then s := 'Velocidade: '
    else if nomeArq = 'DV_TONALS'      then s := 'Tonalidade: '
    else if nomeArq = 'DV_AJUCS_V'     then s := 'Velocidade (-10 a 10) '
    else if nomeArq = 'DV_AJUCS_T'     then s := 'Tonalidade (-10 a 10) '
    else if nomeArq = 'DV_AJUCS_NAO'   then s := 'Voz não encontrada'
    else if nomeArq = 'DV_AJUCS_NAT'   then s := 'Fala nativa ativada'
    else if nomeArq = 'DV_AJUCS_SINT'  then s := 'Sintetizador ativado: '

    (***** dosconf.pas - configRetornoCopia *****)
        else if nomeArq = 'DV_AJUCC_PRMPT'      then s := 'Configure o retorno sonoro em cópias de arquivos'
    else if nomeArq = 'DV_AJUCC_RETORNO'    then s := 'Retorno sonoro'
    else if nomeArq = 'DV_AJUCC_INSTRUM'    then s := 'Instrumento (de 1 a 127)'
    else if nomeArq = 'DV_AJUCC_OK'         then s := 'Ok. Retorno sonoro configurado.'

    (***** dosconf.pas - configInicia *****)
        else if nomeArq = 'DV_AJUCW_PRMPT'  then s := 'Selecione opção de iniciar o Dosvox'
    else if nomeArq = 'DV_AJUCW_PRMPT2' then s := 'Iniciar o Dosvox com o Windows'
    else if nomeArq = 'DV_AJUCW_ERR'    then s := 'Erro: Não consegui modificar inicialização automática do Dosvox.'
    else if nomeArq = 'DV_AJUCW_OKS'    then s := 'Ok. O Dosvox será iniciado com o Windows.'
    else if nomeArq = 'DV_AJUCW_OKN'    then s := 'Ok. O Dosvox não será iniciado com o Windows.'

    (***** dosconf.pas - configAtualiza *****)
        else if nomeArq = 'DV_AJUCA_PRMPT' then s := 'Atualização do Dosvox - '
    else if nomeArq = 'DV_AJUCA_OPC'   then s := 'As opções de atualização são:'
        else if nomeArq = 'DV_AJUCA_P'     then s := '  P - Atualizar programa pela Internet'
        else if nomeArq = 'DV_AJUCA_V'     then s := '  V - verificar programas com atualização pendente'
        else if nomeArq = 'DV_AJUCA_B'     then s := '  B - Baixar programa pela Internet'
        else if nomeArq = 'DV_AJUCA_A'     then s := '  A - Atualizar configuração por arquivo .ATU'
        else if nomeArq = 'DV_AJUCA_Z'     then s := '  Z - Atualizar programa por arquivo .ZIP'
        else if nomeArq = 'DV_AJUCA_I'     then s := '  I - Informações sobre os programas instalados'
        else if nomeArq = 'DV_AJUCA_S'     then s := '  S - Atualizar todo o sistema pela Internet'
        else if nomeArq = 'DV_AJUCA_R'     then s := '  R - Remover programa instalado'

    (***** dosconf.pas - configInforma *****)
        else if nomeArq = 'DV_AJUCI_PRMPT' then s := 'Informações do sistema Dosvox - '
    else if nomeArq = 'DV_AJUCI_OPC'   then s := 'As opções de informação do Dosvox são:'
        else if nomeArq = 'DV_AJUCI_D'     then s := '  D - Dados gerais sobre o sistema'
        else if nomeArq = 'DV_AJUCI_Q'     then s := '  Q - Proprietário da versão instalada DOSVOX'

    (***** dosconf.pas - configAvançada *****)
    else if nomeArq = 'DV_CUIDAD'      then s := 'A configuração avançada só deve ser feita por usuários experientes'
    else if nomeArq = 'DV_TECLECCONT'  then s := 'Aperte a tecla C para continuar'
    else if nomeArq = 'DV_CONFG_PRMPT' then s := 'Configuração avançada - '
    else if nomeArq = 'DV_AJUCG_OPC'   then s := 'As opções de configuração avançada são:'
    else if nomeArq = 'DV_AJUCG_E'     then s := '  E - editar uma seção'
    else if nomeArq = 'DV_AJUCG_I'     then s := '  I - incluir item em uma seção'
    else if nomeArq = 'DV_AJUCG_R'     then s := '  R - remover item de uma seção'
    else if nomeArq = 'DV_AJUCG_C'     then s := '  C - criar nova seção'
    else if nomeArq = 'DV_AJUCG_M'     then s := '  M - editar os macrocomandos de F2 a F7'
    else if nomeArq = 'DV_AJUCG_L'     then s := '  L - configurações do legado da versão 4'
    else if nomeArq = 'DV_AJUCG_V'     then s := '  V - aplicar mais velocidade nos programas'
    else if nomeArq = 'DV_AJUCG_P'     then s := '  P - aplicar velocidade padrão nos programas'
    else if nomeArq = 'DV_AJUCG_O'     then s := '  O - retornar as configurações originais'

    (***** dosconf.pas - escolheSecao *****)
    else if nomeArq = 'DV_SELSEC'   then s := 'Selecione com as setas a seção a configurar'

    (***** dosconf.pas - removeItem *****)
    else if nomeArq = 'DV_SELITEMREM'   then s := 'Escolha com as setas o item a remover'
    else if nomeArq = 'DV_CNFREMITEM'   then s := 'Confirma remoção do item '
    else if nomeArq = 'DV_OKREMOV'      then s := 'Ok, removido'

    (***** dosconf.pas - criaNovaSecao *****)
    else if nomeArq = 'DV_NOVASECAO'    then s := 'Informe o nome da nova seção do DOSVOX.INI'

    (***** dosconf.pas - atualizarDosvoxIni *****)
    else if nomeArq = 'DV_REALTERASN'   then s := 'Deseja realterar itens anteriormente criados?'
    else if nomeArq = 'DV_ARQMUDANCA'   then s := 'Informe o nome do arquivo que contém as mudanças'
    else if nomeArq = 'DV_CHAVEINVAL'   then s := 'Chave inválida'

    else if nomeArq = 'DV_OPPREF'       then s := 'Folhear, incluir este ou editar?'
    else if nomeArq = 'DV_NOMEPREF'     then s := 'Que nome este diretório terá na lista de preferidos?'
    else if nomeArq = 'DV_MACNAODEF'    then s := 'Este macrocomando não foi definido'
    else if nomeArq = 'DV_DESIST'       then s := 'Desistiu...'

    else if nomeArq = 'DV_ITEMINC'      then s := 'Nome do item a incluir'
    else if nomeArq = 'DV_CONTITEM'     then s := 'Informe o conteúdo deste item'
    else if nomeArq = 'DV_NUMSDIR'      then s := 'Número de subdiretórios aqui: '

    else if nomeArq = 'DV_DIGPALAV'     then s := 'Digite a palavra ou frase a buscar'
    else if nomeArq = 'DV_DIGPABUS'     then s := 'Digite a palavra a buscar'
    else if nomeArq = 'DV_ACHEI'        then s := 'Achei '
    else if nomeArq = 'DV_NACHEI'       then s := 'Não achei'

    else if nomeArq = 'DV_DARQEXIS'     then s := 'Dados do arquivo existente'
    else if nomeArq = 'DV_DESTINO' then s := 'Destino '
    else if nomeArq = 'DV_DARQNOVO'     then s := 'Dados do novo arquivo'
    else if nomeArq = 'DV_DINDISP'      then s := 'Dado não disponível'

    else if nomeArq = 'DV_TIPORD'       then s := 'Ordena por Nome, Tamanho, Extensão ou Data? '
    else if nomeArq = 'DV_TIPORDSUB'       then s := 'Ordena por Nome, Tamanho ou Data? '
    else if nomeArq = 'DV_TIPORDSUB2'       then s := 'Ordena por Nome ou Data? '
    else if nomeArq = 'DV_SAPINAO'      then s := 'Nenhuma fala SAPI está instalada'

    else if nomeArq = 'DV_EMAILDEST'    then s := 'Email do destinatário'
    else if nomeArq = 'DV_ASSUNTCART'   then s := 'Assunto da carta'
    else if nomeArq = 'DV_VOUENVIAR'    then s := 'Vou enviar '
    else if nomeArq = 'DV_CONFIRMA'     then s := 'Confirma? '
    else if nomeArq = 'DV_CARTPREPVOX'  then s := 'Carta preparada para transmissão pelo Cartavox'
    else if nomeArq = 'DV_ERRCARQENV'   then s := 'Erro ao criar arquivo para envio'

    else if nomeArq = 'DV_CTODSL'       then s := 'Tecle T para todo diretório ou S para selecionados: '
    else if nomeArq = 'DV_NAOCOMPAC'    then s := 'Não consegui acionar o compactador'
    else if nomeArq = 'DV_NOMECOMPAC'   then s := 'Qual o nome do arquivo compacto? '
    else if nomeArq = 'DV_AGUCOMPACT'   then s := 'Um momento, compactando'
    else if nomeArq = 'DV_UMMOMENTO'    then s := 'Um momento...'
    else if nomeArq = 'DV_OKCOMPAC'     then s := 'Ok, compactado'

    else if nomeArq = 'DV_EDITNOVNOME'  then s := 'Editore o novo nome'
    else if nomeArq = 'DV_OKNOMEMUD'    then s := 'OK, nome mudado'
    else if nomeArq = 'DV_ERRNOMEMUD'   then s := 'Não pude mudar o nome'
    else if nomeArq = 'DV_SELEC'        then s := ' selecionado '
    else if nomeArq = 'DV_SELECS'       then s := ' selecionados'
    else if nomeArq = 'DV_DE'           then s := ' de '

    else if nomeArq = 'DV_PERIGO'       then s := 'Atenção, essa operação é irreversível e pode causar imensos danos.'
    else if nomeArq = 'DV_DISCOREMOV'   then s := 'Disco foi removido.'
    else if nomeArq = 'DV_AUDIOCDDETEC' then s := 'Audio CD foi detectado'
    else if nomeArq = 'DV_CDNAODIR'     then s := 'CD de áudio não tem diretórios'

    else if nomeArq = 'DV_INFLDRV'      then s := 'Informe a letra da unidade a formatar: '
    else if nomeArq = 'DV_ROTULOGRAV'   then s := 'Edite o nome do rótulo a gravar (10 letras): '
    else if nomeArq = 'DV_TECENTFORMAT' then s := 'Aperte enter para formatar'
    else if nomeArq = 'DV_UNIFOR'       then s := 'Unidade bem formatada'
    else if nomeArq = 'DV_PROBFR'       then s := 'Problemas na formatação'

    else if nomeArq = 'DV_GMIDIA'        then s := 'Gravação de mídia'
    else if nomeArq = 'DV_TAMGRM'        then s := 'Tamanho de gravação em MB: '
    else if nomeArq = 'DV_PROBLG'       then s := 'Problemas no processo de gravação'
    else if nomeArq = 'DV_LUNGRV'       then s := 'Qual a unidade de gravação? '
    else if nomeArq = 'DV_UNGRAV'       then s := 'Unidade de gravação: '
    else if nomeArq = 'DV_NOMECD'       then s := 'Informe o nome do CD a gravar (12 letras): '
    else if nomeArq = 'DV_DIRGCD'       then s := 'Informe o nome do diretorio a gravar (aperte ENTER se for o atual)'
    else if nomeArq = 'DV_TRANSC'       then s := 'Transcrevendo arquivos para a área de montagem'
    else if nomeArq = 'DV_DEMORA'       then s := 'Esta é uma operação demorada'
    else if nomeArq = 'DV_INGRCD'       then s := 'Iniciando a gravação, aperte ENTER após inserir a mídia'
    else if nomeArq = 'DV_CANESC'       then s := 'Para cancelar aperte ESC'
    else if nomeArq = 'DV_GRAVND'       then s := 'Gravando...'

    else if nomeArq = 'DV_UNIREM'       then s := 'Informe a unidade a remover: '
    else if nomeArq = 'DV_EXSUPC'       then s := 'Remove todo o dispositivo? '
    else if nomeArq = 'DV_UNIRM'        then s := 'Ok, unidade removida.'
    else if nomeArq = 'DV_NAORM'        then s := 'Não foi possível remover.'
    else if nomeArq = 'DV_UNRENO'       then s := 'Informe a unidade a renomear: '
    else if nomeArq = 'DV_NOMERN'       then s := 'Qual o novo nome (12 letras): '
    else if nomeArq = 'DV_OKRENO'       then s := 'Ok, unidade renomeada.'
    else if nomeArq = 'DV_NORENO'       then s := 'Não foi possível renomear.'

    else if nomeArq = 'DV_REMSEG'       then s := 'A mídia pode ser removida com toda segurança'
    else if nomeArq = 'DV_ABERTO'       then s := 'O dispositivo está aberto'
    else if nomeArq = 'DV_USUOUT'       then s := 'O dispositivo está sendo utilizado no momento por outro processo'
    else if nomeArq = 'DV_EJDINT'       then s := 'É impossível ejetar um disco interno!'

    else if nomeArq = 'DV_DISINV'       then s := 'Dispositivo inválido'
    else if nomeArq = 'DV_NAOABV'       then s := 'Não pude abrir o volume'
    else if nomeArq = 'DV_SEMACX'       then s := 'Não pude garantir acesso exclusivo'
    else if nomeArq = 'DV_NDISMO'       then s := 'Não pude desmontar o volume'
    else if nomeArq = 'DV_NTIRPR'       then s := 'Não pude tirar a proteção contra remoção'
    else if nomeArq = 'DV_NAOEJE'       then s := 'Não pude ejetar a mídia'
    else if nomeArq = 'DV_NLIBV'        then s := 'Não pude liberar o acesso da mídia'

    else if nomeArq = 'DV_VARSEL'       then s := 'Vários arquivos estão selecionados, processo todos? '

    else if nomeArq = 'DV_EDDIA'        then s := 'Editore dia e hora, use as setas, ESC termina'
    else if nomeArq = 'DV_HORA'         then s := 'Hora'
    else if nomeArq = 'DV_MINUT'        then s := 'Minuto'
    else if nomeArq = 'DV_DIA'          then s := 'Dia'
    else if nomeArq = 'DV_MES'          then s := 'Mês'
    else if nomeArq = 'DV_ANO'          then s := 'Ano'

    else if nomeArq = 'DV_NOPRV'        then s := 'Para mudar a hora é necessário rodar o Dosvox em modo administrador.'

    else if nomeArq = 'DV_MESTRE'       then s := 'Quer fazer dele o diretório mestre do Dosvox? '
    else if nomeArq = 'DV_MSTMUD'       then s := 'Diretório mestre mudado'

    (***** dosupdat.pas ********************************************************)
    else if nomeArq = 'DV_EXTZIP'       then s := 'Extraindo o arquivo ZIP.'
    else if nomeArq = 'DV_NARQZP'       then s := 'Informe o nome do arquivo .ZIP: '
    else if nomeArq = 'DV_ZIPNEC'       then s := 'Nenhum arquivo .ZIP foi selecionado.'
    else if nomeArq = 'DV_ATUNEC'       then s := 'Nenhum arquivo .ATU foi selecionado.'

    else if nomeArq = 'DV_ERRODC'       then s := 'Descompactador não pôde ser executado.'
    else if nomeArq = 'DV_EXTSCS'       then s := 'Arquivo extraido com sucesso.'
    else if nomeArq = 'DV_NMPROG'       then s := 'Informe o nome do programa ou selecione com as setas:'
    else if nomeArq = 'DV_ATUPRO'       then s := 'Deseja atualizar o programa: '

    else if nomeArq = 'DV_PROGEX'       then s := 'O programa está em execução. Não posso atualizar.'
    else if nomeArq = 'DV_ERRBXR'       then s := 'Erro ao baixar o arquivo.'
    else if nomeArq = 'DV_PEXTE1'       then s := 'O programa está em execução.'
    else if nomeArq = 'DV_PEXTE2'       then s := 'Por favor feche o programa e aperte Enter ou Esc para cancelar.'
    else if nomeArq = 'DV_BAIXND'       then s := 'Baixando...'
    else if nomeArq = 'DV_PROGAT'       then s := 'O programa foi atualizado.'

    else if nomeArq = 'DV_INTOUT'       then s := 'A internet está fora do ar'
    else if nomeArq = 'DV_ACBLOQ'       then s := 'Acesso ao site de atualização do DosVox está bloqueado.'
    else if nomeArq = 'DV_ERRSRV'       then s := 'Erro na comunicação com o site de atualização do DosVox'
    else if nomeArq = 'DV_ERRWAR'       then s := 'Erro de escrita do arquivo'
    else if nomeArq = 'DV_GEROPC'       then s := 'Erro ao gerar a lista de opções.'

    else if nomeArq = 'DV_VER64B'       then s := 'O Sistema Operacional deste computador é de 64 bits'
    else if nomeArq = 'DV_VER32B'       then s := 'O Sistema Operacional deste computador é de 32 bits'
    else if nomeArq = 'DV_BAIXAR'       then s := 'Baixar'
    else if nomeArq = 'DV_NA_PASTA'     then s := 'Na pasta'
    else if nomeArq = 'DV_VERESC'       then s := 'Escolha com as setas a versão do Dosvox a baixar:'
    else if nomeArq = 'DV_SETUPS'       then s := 'Arquivo de Setup foi gravado em: '
    else if nomeArq = 'DV_PORCEN'       then s := ' por cento'
    else if nomeArq = 'DV_CUIDATU'      then s := 'Cuidado! Para atualizar o sistema nenhum programa dele pode estar ativo.'
    else if nomeArq = 'DV_NENHUM'       then s := 'Todos os arquivos estão atualizados.'

    else if nomeArq = 'DV_BAIXAV'       then s := 'Configurações para baixa visão'
    else if nomeArq = 'DV_AJUCB_A'      then s := 'Fator de ampliação'
    else if nomeArq = 'DV_AJUCB_L'      then s := 'Cor da letra'
    else if nomeArq = 'DV_AJUCB_F'      then s := 'Cor do fundo'
    else if nomeArq = 'DV_AJUCB_C'      then s := 'Cor do cursor'

    else if nomeArq = 'DV_ININAO'       then s := 'Dosvox.ini não foi encontrado no diretório "iniOriginal"'
    else if nomeArq = 'DV_CANCEL'       then s := 'Execução do Dosvox foi cancelada, aperte enter.'
    else if nomeArq = 'DV_LEGADO'       then s := 'Aceita as configurações feitas no dosvox versão 4? '
    else if nomeArq = 'DV_APTENT'       then s := 'Aperte enter.'

    else if nomeArq = 'DV_PROGREM'      then s := 'Informe o nome do arquivo a remover ou use as setas: '
    else if nomeArq = 'DV_CONFREMP'     then s := 'Confirma a remoção do programa '
    else if nomeArq = 'DV_REMEXEC'      then s := 'Removendo executável'
    else if nomeArq = 'DV_EXECNREM'     then s := 'Executável não foi removido'
    else if nomeArq = 'DV_REMATU'       then s := 'Removendo atualizador'
    else if nomeArq = 'DV_REMNREM'      then s := 'Atualizador não removido'
    else if nomeArq = 'DV_REMSOM'       then s := 'Removendo o diretório de sons'
    else if nomeArq = 'DV_NAODIRSONS'   then s := 'Não encontrei o diretório de sons'
    else if nomeArq = 'DV_EDIRSONS'     then s := 'Editore o nome do diretório de sons ou tecle ESC'
    else if nomeArq = 'DV_DIRSOMNREM'   then s := 'Erro ao remover o diretório de sons'
    else if nomeArq = 'DV_REMFONTE'     then s := 'Removendo o programa fonte'
    else if nomeArq = 'DV_FONTENAO'     then s := 'Programa fonte não achado em '
    else if nomeArq = 'DV_DIRFONTENREM' then s :=  'Erro ao remover o diretório de fontes.'

    else if nomeArq = 'DV_CONVARQ' then s := 'Conversor de formatos'
    else if nomeArq = 'DV_ERRNAO' then s := 'Este arquivo não pode ser processado: '
    else if nomeArq = 'DV_DICBLB' then s := 'Arquivo blb2txt.dic não foi encontrado'
    else if nomeArq = 'DV_SAPATI' then s :=  'Fala SAPI 5 não está ativada no DOSVOX'
    else if nomeArq = 'DV_DVVELOZ' then s := 'Deseja deixar os programas mais rápidos? '
    else if nomeArq = 'DV_DVPADRAO' then s := 'Deseja deixar os programas na velocidade padrão? ' 
    else if nomeArq = 'DV_DESRECCONF' then s := 'Deseja recuperar a configuração original de instalação? '
    else if nomeArq = 'DV_FIMDV'  then s := 'Fim do DOSVOX.'

    else if nomeArq = 'DV_OPTESTEC'     then s := 'Qual opção: T - conhecer as teclas  H - prova de habilidade: '
    else if nomeArq = 'DV_HABTEC'       then s := 'Dosvox - Habilidade de Teclado'
    else if nomeArq = 'DV_REPTEC'       then s := 'Quantas repetições deseja fazer (entre 1 e 5)? '
    else if nomeArq = 'DV_DIFTEC'       then s := 'Qual o nível de dificuldade (entre 0 e 9)? '
    else if nomeArq = 'DV_INITEC'       then s := 'Iniciando o teste de habilidade'
    else if nomeArq = 'DV_DIAGTEC'      then s := 'Diagnóstico de sua habilidade hoje'
    else if nomeArq = 'DV_DIAGNIVEL'    then s := 'Nível de dificuldade: '
    else if nomeArq = 'DV_DIAGREPET'    then s := 'Repetições de cada teste: '
    else if nomeArq = 'DV_TEMPOTEC'     then s := 'Seu tempo de teclagem: '
    else if nomeArq = 'DV_ERRTESTEC'    then s := 'Número de testes com erro: '
    else if nomeArq = 'DV_CORRTEC'      then s := 'Número de correções: '
    else if nomeArq = 'DV_NAOHABTEC'    then s := 'Não há provas de habilidade registradas'

    else if nomeArq = 'DV_ARQDESTAC'    then s := 'Arquivamento destacado'
    else if nomeArq = 'DV_SUBDESTAC'    then s := 'Subdiretório destacado'
    else if nomeArq = 'DV_DESTACADO'    then s := 'Destacado'
    else if nomeArq = 'DV_FIMDESTAC'    then s := 'Destacamento terminado'
    else if nomeArq = 'DV_DWPAIN'       then s := 'Por favor, faça o download do pacote de instalação'
    else if nomeArq = 'DV_OU'           then s := 'ou'
    else if nomeArq = 'DV_REINIC'       then s := 'Por favor, feche o Dosvox e abra novamente'
    else if nomeArq = 'DV_OUJAEXI'      then s := 'ou já existe'

    else if nomeArq = 'DV_DIADESEJ'     then s := 'Qual o dia desejado? No formato dia/mês/ano '
    else if nomeArq = 'DV_DATAINV'      then s := 'Data inválida.'

    else
         s := '--> Mensagem inválida: ' + nomeArq;

    pegaTextoMensagem := s;
end;

{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;

begin
    s := pegaTextoMensagem (nomeArq);

    if nlf >= 0 then write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom ('EF_' + nomeArq) then
        sintSom ('EF_' + nomeArq);

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}

procedure soletra(s: string; nlf: integer);
var i: integer;
begin
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
     write (s);
     for i := 1 to nlf do
         writeln;

    if length (s) > 0 then
        sintetiza (s);
end;

{--------------------------------------------------------}

procedure inicFala;
begin
    dirSons := sintAmbiente ('DOSVOX', 'DIRDOSVOX50');
    if dirSons = '' then
        dirSons := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\dosvox50';
    sintinic (0, dirSons);
end;

{--------------------------------------------------------}

procedure limpaBaixo (y: integer);
var i: integer;
begin
    for i := y to 25 do
        begin
            gotoxy (1, i);
            clreol;
        end;
    gotoxy (1, y);
end;

{--------------------------------------------------------}

function mensErroArquivo (codigo: integer): string;
begin
    case codigo of
        ERROR_SUCCESS:                  { The operation completed successfully. }
            result := 'DV_ERRARQ_0K';   { 'Oreração completada.' }

        ERROR_FILE_NOT_FOUND:           { The system cannot find the file specified. }
            result := 'DV_ERRARQ_02';   { 'Erro: arquivo não encontrado.' }

        ERROR_PATH_NOT_FOUND:           { The system cannot find the path specified. }
            result := 'DV_ERRARQ_03';   { 'Erro: caminho não encontrado.' }

        ERROR_ACCESS_DENIED:            { Access is denied. }
            result := 'DV_ERRARQ_05';   { 'Erro: acesso negado.' }

        ERROR_INVALID_DRIVE:            { The system cannot find the drive specified. }
            result := 'DV_ERRARQ_15';   { 'Erro: drive não encontrado.' }

        ERROR_NOT_SAME_DEVICE:          { The system cannot move the file to a different disk drive. }
            result := 'DV_ERRARQ_17';   { 'Erro: arquivo não pode ser movido para outro drive.' }

        ERROR_WRITE_PROTECT:            { The media is write protected. }
            result := 'DV_ERRARQ_19';   { 'Erro: mídia protegida para escrita.' }

        ERROR_CRC:                      { Data error (cyclic redundancy check) }
            result := 'DV_ERRARQ_23';   { 'Erro: CRC.' }

        ERROR_NOT_DOS_DISK:             { The specified disk or diskette cannot be accessed. }
            result := 'DV_ERRARQ_26';   { 'Erro: unidade inacessível.' }

        ERROR_WRITE_FAULT:              { The system cannot write to the specified device. }
            result := 'DV_ERRARQ_29';   { 'Erro de escrita no dispositivo.' }

        ERROR_READ_FAULT:               { The system cannot read from the specified device. }
            result := 'DV_ERRARQ_30';   { 'Erro de leitura no dispositivo.' }

        ERROR_HANDLE_DISK_FULL:         { The disk is full. }
            result := 'DV_ERRARQ_39';   { 'Erro: disco ou mídia sem espaço.' }

        ERROR_FILE_EXISTS:              { The file exists. }
            result := 'DV_ERRARQ_80';   { 'Erro: arquivo já existente.' }

        ERROR_CANNOT_MAKE:              { The directory or file cannot be created. }
            result := 'DV_ERRARQ_82';   { 'Erro: pasta não pode ser criada.' }

        ERROR_FAIL_I24:                 { Fail on INT 24 }
            result := 'DV_ERRARQ_83';   { 'Erro fatal: INT 24.' }

        ERROR_DRIVE_LOCKED:             { The disk is in use or locked by another process. }
            result := 'DV_ERRARQ_108';  { 'Erro: disco inacessível.' }

        ERROR_OPEN_FAILED:              { The system cannot open the device or file specified. }
            result := 'DV_ERRARQ_110';  { 'Erro: arquivo ou dispositivo não pode ser aberto.' }

        ERROR_BUFFER_OVERFLOW:          { The file name is too long. }
            result := 'DV_ERRARQ_111';  { 'Erro: nome de arquivo muito longo.' }

        ERROR_DISK_FULL:                { There is not enough space on the disk. }
            result := 'DV_ERRARQ_112';  { 'Erro: disco ou mídia sem espaço.' }

        ERROR_INVALID_NAME:             { The filename, directory name, or volume label syntax is incorrect. }
            result := 'DV_ERRARQ_123';  { 'Erro: nome inválido de arquivo, pasta ou unidade.' }

        ERROR_BAD_PATHNAME:             { The specified path is invalid. }
            result := 'DV_ERRARQ_161';  { 'Erro: caminho inválido.' }

        ERROR_ALREADY_EXISTS:           { Cannot create a file when that file already exists. }
            result := 'DV_ERRARQ_183';  { 'Erro: criação de arquivo já existente.' }

        ERROR_FILENAME_EXCED_RANGE:     { The filename or extension is too long. }
            result := 'DV_ERRARQ_206';  { 'Erro: nome ou extensão de arquivo muito longos.' }

        ERROR_DIRECTORY:                { The directory name is invalid. }
            result := 'DV_ERRARQ_267';  { 'Erro: nome inválido de pasta.' }

        ERROR_NO_MEDIA_IN_DRIVE:        { No media in drive. }
            result := 'DV_ERRARQ_1112'; { 'Erro: sem mídia na unidade.' }

        ERROR_REQUEST_ABORTED:          { The request was aborted. }
            result := 'DV_ERRARQ_1235'; { 'Operação abortada pelo usuário.' }
    else
            result := 'DV_ERRARQ_*';    { 'Erro genérico de operação com arquivos ou pastas.' }
    end;
end;

{--------------------------------------------------------}
{                  Retorna o diretório de instalação do Dosvox
{--------------------------------------------------------}

function pegaDirDosvox: string;
var dirDosvox: string;
begin
    dirDosvox := sintAmbiente ('DOSVOX', 'PGMDOSVOX');
    if dirDosvox = '' then
        dirDosvox := 'c:\winvox';
    if dirDosvox[length(dirDosvox)] <> '\' then
        dirDosvox := dirDosvox + '\';

    result := dirDosvox;
end;

{--------------------------------------------------------}

begin
end.
