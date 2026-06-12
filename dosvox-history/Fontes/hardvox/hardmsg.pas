{-------------------------------------------------------------}
{
{    Mensagens do programa HARDMSG
{
{    Autor: Jose' Antonio Borges
{
{    Em 09/04/2008
{
{-------------------------------------------------------------}

unit hardmsg;

interface
uses dvCrt, dvWin, winprocs, wintypes;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);

procedure limpaBaixo (y: integer = -1);
procedure salvaXY;
procedure restauraXY;

procedure defineNovoTamanhoDeRotulos (novoTamanho: integer);
procedure restauraTamanhoDeRotulos;

implementation

uses
    dvForm;

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'HVINIC' then
        s := 'Hardvox - Versão '
    else
    if nomeArq = 'HVDESIST' then
        s := 'Desistiu...'
    else
    if nomeArq = 'HVOBRIG' then
        s := 'Obrigado por usar o hardvox'
    else
    if nomeArq = 'HVOPCAO' then
        s := 'Hardvox - opção: '
    else
    if nomeArq = 'HVUSESET' then
        s := 'Para selecionar, use as setas'
    else
    if nomeArq = 'HVOPINV' then
        s := 'Opção inválida: aperte F1 para ajuda'
    else
    if nomeArq = 'HVFALHOU' then
        s := 'DFP_GET_VERSION falhou no drive '
    else
    if nomeArq = 'HVSEMHDS' then
        s := 'Nenhum HD identificado '
    else
    if nomeArq = 'HVSEMHDS2' then
        s := 'Execute seu Dosvox como administrador para utilizar esta opção.'
    else
    if nomeArq = 'HVINFISD' then
        s := 'Qual a unidade física de disco (0 a 3)? '
    else
    if nomeArq = 'HVESCDRV' then
        s := 'Escolha o drive com as setas: '
    else
    if nomeArq = 'HVDRVERR' then
        s := 'Drive errado'
    else
    if nomeArq = 'HDESCUNI' then
        s := 'Escolha a unidade com as setas: '
    else
    if nomeArq = 'HVUSERS' then
        s := 'Usuários desta máquina, use as setas para conhecer'
    else
    if nomeArq = 'HVSEMWAV' then
        s := 'Essa máquina não tem dispositivos de áudio'
    else
    if nomeArq = 'HVSEMMID' then
        s := 'Essa máquina não tem dispositivos de midi'
    else
    if nomeArq = 'HVSETWAV' then
        s := 'Áudio - Use as setas para folhear'
    else
    if nomeArq = 'HVSETMID' then
        s := 'Midi - Use as setas para folhear'
    else
    if nomeArq = 'HVSETGRF' then
        s := 'Controladores gráficos - use as setas para folhear'
    else
    if nomeArq = 'HVSETMON' then
        s := 'Monitores - use as setas para folhear'
    else
    if nomeArq = 'HVSETFOL' then
        s := 'Use as setas para folhear'

    else
    if nomeArq = 'HD_CTL0' then
        s := 'Primário mestre'
    else
    if nomeArq = 'HD_CTL1' then
        s := 'Primário escravo'
    else
    if nomeArq = 'HD_CTL2' then
        s := 'Secundário mestre'
    else
    if nomeArq = 'HD_CTL3' then
        s := 'Secundário escravo'
    else
    if nomeArq = 'HD_CTL4' then
        s := 'Terciário mestre'
    else
    if nomeArq = 'HD_CTL5' then
        s := 'Terciário escravo'
    else
    if nomeArq = 'HD_CTL6' then
        s := 'Quaternário mestre'
    else
    if nomeArq = 'HD_CTL7' then
        s := 'Quaternário escravo'

    else
    if nomeArq = 'HV_FAB' then
        s := 'Fabricante: '
    else
    if nomeArq = 'HV_DRV' then
        s := '    Driver: '
    else
    if nomeArq = 'HV_RES' then
        s := '    Resolução máxima: '
    else
    if nomeArq = 'HVMODDSK' then
        s := 'Modelo do disco'
    else
    if nomeArq = 'HVNUMSER' then
        s := 'Número de série'
    else
    if nomeArq = 'HVREVCTL' then
        s := 'Número de revisão do controlador'
    else
    if nomeArq = 'HVBUFINT' then
        s := 'Buffers Internos'
    else
    if nomeArq = 'HVREMOVI' then
        s := 'Removível'
    else
    if nomeArq = 'HVFIXA' then
        s := 'Fixa'
    else
    if nomeArq = 'HVDESCON' then
        s := 'Desconhecido'
    else
    if nomeArq = 'HVTIPOUN' then
        s := 'Tipo de unidade'
    else
    if nomeArq = 'HVCILIND' then
        s := 'Cilindros'
    else
    if nomeArq = 'HVCABECA' then
        s := 'Cabeças'
    else
    if nomeArq = 'HVSPT' then
        s := 'Setores por Trilha'
    else
    if nomeArq = 'HVMEMFIS' then
        s := 'Memória Física total em MB'
    else
    if nomeArq = 'HVMEMDIS' then
        s := 'Memória física disponível'
    else
    if nomeArq = 'HVMEMUSO' then
        s := '% de memória em uso'
    else
    if nomeArq = 'HVARQPAG' then
        s := 'Tamanho do arquivo de paginação'
    else
    if nomeArq = 'HVDISPAG' then
        s := 'Disponível no arquivo de paginação'
    else
    if nomeArq = 'HVENDMB' then
        s := 'Espaço de endereçamento do usuário em MB'
    else
    if nomeArq = 'HVENDDIS' then
        s := 'Disponível no Espaço de endereçamento do usuário'

    else
    if nomeArq = 'HVTIPUNI' then
        s := 'Tipo da Unidade'
    else
    if nomeArq = 'HVMONTAD' then
        s := 'Montado'
    else
    if nomeArq = 'HVPERMIS' then
        s := 'Permissão de escrita'
    else
    if nomeArq = 'HVTAMDSK' then
        s := 'Tamanho do Disco'
    else
    if nomeArq = 'HVESPACL' then
        s := 'Espaço livre'
    else
    if nomeArq = 'HVNUMSER' then
        s := 'Número de Série'
    else
    if nomeArq = 'HVROTULO' then
        s := 'Rótulo do Volume'
    else
    if nomeArq = 'HVTSPIN' then
        s := 'Tempo de Spin Up'
    else
    if nomeArq = 'HVCSTART' then
        s := 'Contador Start/Stop'
    else
    if nomeArq = 'HVCREALO' then
        s := 'Contador de setores realocados'
    else
    if nomeArq = 'HVMARGEL' then
        s := 'Margem do canal de leitura'
    else
    if nomeArq = 'HVERRPOS' then
        s := 'Taxa de erros de posicionamento'
    else
    if nomeArq = 'HVTEMPOS' then
        s := 'Desempenho do tempo de posicionamento'
    else
    if nomeArq = 'HVTLIGAD' then
        s := 'Minutos no estado ligado'
    else
    if nomeArq = 'HVCRETRY' then
        s := 'Contador de Spin Retry'
    else
    if nomeArq = 'HVTENTAR' then
        s := 'Tentativas de Recalibragem'
    else
    if nomeArq = 'HVCDPOWR' then
        s := 'Contador de ciclo de Device Power'
    else
    if nomeArq = 'HVCCARGA' then
        s := 'Contador do ciclo de carga/descarga'
    else
    if nomeArq = 'HVPRTEMP' then
        s := 'Problema de Temperatura'
    else
    if nomeArq = 'HVCEVREA' then
        s := 'Contador do evento de realocação'
    else
    if nomeArq = 'HVCSETPD' then
        s := 'Contador de setores correntes pendentes'
    else
    if nomeArq = 'HVCSETNC' then
        s := 'Contador de setores não corrigíveis'
    else
    if nomeArq = 'HVCERDMA' then
        s := 'Contador de erros UDMA CRC'
    else
    if nomeArq = 'HVCERRES' then
        s := 'Taxa de erros de escrita'

    else
    if nomeArq = 'HVPRONAO32' then
        s := 'Erro na execução do programa HWMonitor_x32'
    else
    if nomeArq = 'HVPRONAO64' then
        s := 'Erro na execução do programa HWMonitor_x64'
    else
    if nomeArq = 'HVPRONAO' then
        s := 'Programa HWMonitor (32 ou 64 bits) não encontrado'
    else
    if nomeArq = 'HVFUNCAN' then
        s := 'Função cancelada'
    else
    if nomeArq = 'HVLESENS' then
        s := 'Lendo sensores, aguarde'
    else
    if nomeArq = 'HVINFNAO' then
        s := 'Informações indisponíveis'
    else
    if nomeArq = 'HVFABRIC' then
        s := 'Fabricante'
    else
    if nomeArq = 'HVMODELO' then
        s := 'Modelo'
    else
    if nomeArq = 'HVCHIPMN' then
        s := 'Chip monitor'
    else
    if nomeArq = 'HVFBCHIP' then
        s := 'Fabricante do Chip'
    else
    if nomeArq = 'HVMDCHIP' then
        s := 'Modelo do Chip'

    else
    if nomeArq = 'HV_TEMP' then
        s := 'Temperatura '
    else
    if nomeArq = 'HV_VOLT' then
        s := 'Voltagem '
    else
    if nomeArq = 'HV_FAN' then
        s := 'RPM do ventilador '

    else
    if nomeArq = 'HVPROCES' then
        s := 'Processador'
    else
    if nomeArq = 'HVVELCPU' then
        s := 'Velocidade em MHz'
    else
    if nomeArq = 'HVFABCPU' then
        s := 'Fabricante'
    else
    if nomeArq = 'HVCPUID' then
        s := 'Identificação'
    else
    if nomeArq = 'HVSTATAT' then
        s := 'Status da atualização'
    else
    if nomeArq = 'HVTIPOPM' then
        s := 'Tipo da Placa Mãe'
    else
    if nomeArq = 'HVBOARDVER' then
        s := 'Versão da Placa Mãe'
    else
    if nomeArq = 'HVFMLY' then
        s := 'Família do produto'
    else
    if nomeArq = 'HVSYSVER' then
        s := 'Versão do Produto'
    else
    if nomeArq = 'HVSYSSKU' then
        s := 'SKU do sistema'
    else
    if nomeArq = 'HVSYSPRDNAME' then
        s := 'Nome do produto'
    else
    if nomeArq = 'HVVBIOS' then
        s := 'Versão da BIOS'
    else
    if nomeArq = 'HVDTBIOS' then
        s := 'Data da BIOS'
    else
    if nomeArq = 'HVDBIOSV' then
        s := 'Data da BIOS de vídeo'
    else
    if nomeArq = 'HVVBIOSV' then
        s := 'Versão da BIOS de vídeo'
    else
    if nomeArq = 'HVNMCOMP' then
        s := 'Nome do Computador'
    else
    if nomeArq = 'HVSISTOP' then
        s := 'Sistema Operacional'
    else
    if nomeArq = 'HVSISTOP2' then
        s := 'Arquitetura do sistema operacional'
    else
    if nomeArq = 'HVSISVER' then
        s := 'Versão atual'
    else
    if nomeArq = 'HVSISVAT' then
        s := 'Versão da Atualização'
    else
    if nomeArq = 'HVPROPRI' then
        s := 'Proprietário'
    else
    if nomeArq = 'HVORGAN' then
        s := 'Organização'
    else
    if nomeArq = 'HVTIPSIS' then
        s := 'Tipo de sistema'
    else
    if nomeArq = 'HVNUMGER' then
        s := 'Número de geração atual'
    else
    if nomeArq = 'HVROOTDI' then
        s := 'Diretório de Root'
    else
    if nomeArq = 'HVDIRECX' then
        s := 'DirectX versão'

    else
    if nomeArq = 'HVSETSNS' then
        s := 'Circuitos sensores da placa mãe - use as setas para selecionar'
    else
    if nomeArq = 'HVPRONAO' then
        s := 'Monitor de hardware não foi encontrado'
    else
    if nomeArq = 'HVSNSSET' then
        s := 'Use as setas para ler os valores dos sensores'
    else
    if nomeArq = 'HVOP_S' then
        s := '  S - informações sobre o Sistema Operacional'
    else
    if nomeArq = 'HVOP_P' then
        s := '  P - placa mãe'
    else
    if nomeArq = 'HVOP_T' then
        s := '  T - temperaturas, voltagens e outros sensores'
    else
    if nomeArq = 'HVOP_C' then
        s := '  C - CPU sob a perspectiva do Windows'
    else
    if nomeArq = 'HVOP_M' then
        s := '  M - memória RAM'
    else
    if nomeArq = 'HVOP_H' then
        s := '  H - informações físicas sobre os HD'
    else
    if nomeArq = 'HVOP_E' then
        s := '  E - espaço nos discos'
    else
    if nomeArq = 'HVOP_A' then
        s := '  A - áudio e midi'
    else
    if nomeArq = 'HVOP_V' then
        s := '  V - monitores de vídeo'
    else
    if nomeArq = 'HVOP_D' then
        s := '  D - diagnostico SMART dos discos'
    else
    if nomeArq = 'HVOP_U' then
        s := '  U - usuários da máquina'
    else
    if nomeArq = 'HVESC' then
        s :='  ESC - termina'
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

procedure limpaBaixo (y: integer = -1);
var
    i: integer;
begin
    if y = -1 then
        y := whereY;

    for i := y to ScreenSize.Y do
        begin
            gotoxy (1, i);
            clreol;
        end;
    gotoxy (1, y);
end;

{--------------------------------------------------------}

var
    xSalva, ySalva: integer;

procedure salvaXY;
begin
    xSalva := whereX;
    ySalva := whereY;
end;

procedure restauraXY;
begin
    gotoXY (xSalva, ySalva);
end;

{--------------------------------------------------------}
var
    salvaTamanhoRotulosForm: integer;

procedure defineNovoTamanhoDeRotulos (novoTamanho: integer);
begin
    salvaTamanhoRotulosForm := tamRotulosForm;
    tamRotulosForm := novoTamanho;
end;

procedure restauraTamanhoDeRotulos;
begin
    tamRotulosForm := salvaTamanhoRotulosForm;
end;

end.
