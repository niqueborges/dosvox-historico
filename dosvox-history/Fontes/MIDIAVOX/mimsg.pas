{--------------------------------------------------------}
{
{    MIDIAVOX -  Acionador Multimídia
{
{    Módulo de mensagens
{
{    Autores: José Antonio Borges
{             Marcolino Nascimento
{
{    Em Julho/2015
{
{--------------------------------------------------------}

unit mimsg;
interface

uses
    dvcrt, dvWin, dvLenum, dvForm;

procedure mensagem (nomeArq: string; nlf: integer);
function pegaTextoMensagem (nomeArq: string): string;
procedure soletra(s: string; nlf: integer);
procedure limpaBaixo (y: integer);
procedure menuAdiciona (cod: string);
function pergunta (msg: string; npula: integer; cor: integer): char;
procedure msgMuda (nomeArq: string; nlf: integer);

implementation

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
   if      nomeArq = 'MIDIAVOX' then s := 'MIDIAVOX - Versão '
   else if nomeArq = 'MIQOPCAO' then s := 'Selecione a opção com as setas: '
   else if nomeArq = 'MIMENU_A' then s := 'A - Abrir um arquivo multimídia'
   else if nomeArq = 'MIMENU_L' then s := 'L - Abrir uma lista de reprodução'
   else if nomeArq = 'MIMENU_S' then s := 'S - Selecionar um diretório de mídias'
   else if nomeArq = 'MIMENU_R' then s := 'R - Acionar o reprodutor de CD ou de DVD'
   else if nomeArq = 'MIMENU_T' then s := 'T - Playlist da área de transferencia'
   else if nomeArq = 'MIMENU_X' then s := 'X - eXecutar a playlist atual'
   else if nomeArq = 'MIMENU_C' then s := 'C - Configurações do midiavox'

   else if nomeArq = 'MIMODOSIL'    then s := 'Modo Silencioso'
   else if nomeArq = 'MICONFIG'     then s := 'Configuração do midiavox'
   else if nomeArq = 'MIEDCONF'     then s := 'Editore as configurações, ao final tecle ESC'
   else if nomeArq = 'MICONFSA'     then s := 'Configurações salvas'

   else if nomeArq = 'MIDESIST' then s := 'Desistiu...'
   else if nomeArq = 'MIFIMMIV' then s := 'Fim do Midiavox.'
   else if nomeArq = 'MICONFIR' then s := 'Confirma o fim do Midiavox? '

   else if nomeArq = 'MINARQLR' then s := 'Informe o nome do arquivo .m3u: '
   else if nomeArq = 'MIM3UNEC' then s := 'Nenhum arquivo .m3u foi selecionado.'

   else if nomeArq = 'MINARQMM' then s := 'Informe o nome do arquivo: '
   else if nomeArq = 'MIMMNENC' then s := 'Nenhum arquivo multimídia foi selecionado.'

   else if nomeArq = 'MINMEDIR' then s := 'Informe o diretório: '  
   else if nomeArq = 'MIDIRNFE' then s := 'O diretório não existe.'

   else if nomeArq = 'MILOADMM' then s := ' Arquivo carregado. '
   else if nomeArq = 'MILOADPL' then s := ' Playlist carregada.'
   else if nomeArq = 'MITOTMID' then s := 'Total de mídias: '
   else if nomeArq = 'MILOADCD' then s := 'Carregado'
   else if nomeArq = 'MITOCAND' then s := 'Tocando'
   else if nomeArq = 'MIPAUSAD' then s := 'Pausado'
   else if nomeArq = 'MIPARADO' then s := 'Parado'
   else if nomeArq = 'MIREPET'  then s := 'Repetir'
   else if nomeArq = 'MINREPET' then s := 'Não repetir'

   else if nomeArq = 'MIERPLAY' then s := 'Erro ao tocar '
   else if nomeArq = 'MIEROPEN' then s := 'Erro ao abrir '

   else if nomeArq = 'MIREPRPL' then s := 'Reproduzindo a lista: '
   else if nomeArq = 'MIEABRIR' then s := 'Erro ao abrir a lista de reprodução.'
   else if nomeArq = 'MIERRARQ' then s := 'Arquivo não pode ser carregado.'
   else if nomeArq = 'MIERLOAD' then s := 'Lista de reprodução está vazia.'
   else if nomeArq = 'MIERRARM' then s := 'Mídia não pode ser encontrada.'
   else if nomeArq = 'MIFIMRPL' then s := 'Execução interrompida'

   else if nomeArq = 'MIOPCSMM'         then s := 'As opções são:'
   else if nomeArq = 'MI_PL_EXECUTAR'   then s := 'ENTER - Executar a lista'
   else if nomeArq = 'MI_PL_ALEATORIO'  then s := 'Control Enter - Execução Aleatória' 
   else if nomeArq = 'MI_PL_ADICIONAR'  then s := '  A - Adicionar mídia à lista'
   else if nomeArq = 'MI_PL_REMOVER'    then s := '  R - Remover mídia'
   else if nomeArq = 'MI_PL_GRAVAR'     then s := '  G - Gravar lista'
   else if nomeArq = 'MI_PL_TROCADIR'   then s := '  T - Trocar diretório'
   else if nomeArq = 'MI_PL_PARAR'      then s := 'ESC - Terminar'

   else if nomeArq = 'MI_MM_TOCAR'      then s := '    T  - Tocar mídia do início'
   else if nomeArq = 'MI_MM_PAUSAR'     then s := '    P  - Pausar mídia'
   else if nomeArq = 'MI_MM_REPETIR'    then s := '    R  - Repetir ou não a mídia atual'
   else if nomeArq = 'MI_MM_EXIBIR'     then s := '    L  - Exibir lista de reprodução'
   else if nomeArq = 'MI_MM_INFORMA'    then s := '    I  - Informações de tempo e duração'
   else if nomeArq = 'MI_MM_ANTERIOR'   then s := '   CIMA  - Mídia anterior'
   else if nomeArq = 'MI_MM_AVANCAR'    then s := '   BAIXO - Próxima mídia'
   else if nomeArq = 'MI_MM_AUMDIMVOL'  then s := ' ''+''/''-'' - Ajusta volume'

   else if nomeArq = 'MI_MM_AUMENTAVOL' then s := '   ''+''   - Aumenta volume'
   else if nomeArq = 'MI_MM_DIMINUIVOL' then s := '   ''-''   - Diminui volume'

   else if nomeArq = 'MI_MM_FINALIZAR'  then s := '    F    - Interromper execução'
   else if nomeArq = 'MI_MM_FIMMIDIA'  then s := '    END    - Ir para o final da mídia'

   else if nomeArq = 'MI_CTLEXE'        then s := 'Controles de execução:'
   else if nomeArq = 'MI_ESPACO'        then s := '    Espaço     - Pausa/retoma reprodução'
   else if nomeArq = 'MI_INFORMA'       then s := '    I          - Informa tempo/duração'
   else if nomeArq = 'MI_DIRESQ'        then s := '    DIR/ESQ    - Avança/Recua'
   else if nomeArq = 'MI_CIMBAI'        then s := '    CIMA/BAIXO - Mídia anterior/seguinte'
   else if nomeArq = 'MI_MAIMEN'        then s := '    ''+''/''-''    - Aumenta/Diminui volume'
   else if nomeArq = 'MI_TAB'           then s := '    Tab        - Salta para frente '
   else if nomeArq = 'MI_SHTAB'         then s := '    Shift+Tab  - Salta para trás'

   else if nomeArq = 'MI_CD_ABRIR'     then s := 'E - abre gaveta do CD'
   else if nomeArq = 'MI_CD_FECHA'     then s := 'F - fecha gaveta do CD'
   else if nomeArq = 'MI_CD_LIGAR'     then s := 'L - Liga o CD-Player'
   else if nomeArq = 'MI_CD_DESLI'     then s := 'D - Desliga o CD-Player'
   else if nomeArq = 'MI_CD_SOBRE'     then s := 'I - Informações sobre a trilha'
   else if nomeArq = 'MI_CD_REPET'     then s := 'R - Repetir trilha'
   else if nomeArq = 'MI_CD_VOLTA'     then s := 'CIMA - Volta trilha'
   else if nomeArq = 'MI_CD_AVANC'     then s := 'BAIXO - Avança trilha'
   else if nomeArq = 'MI_CD_ESCOL'     then s := 'F5 - escolher trilha'

   else if nomeArq = 'MIPORTAA' then s := 'A porta está aberta'
   else if nomeArq = 'MINUMTLH' then s := 'Número de trilhas: '
   else if nomeArq = 'MITATUAL' then s := 'Trilha corrente: '
   else if nomeArq = 'MIDURACA' then s := 'Duração: '
   else if nomeArq = 'MINTRACK' then s := 'Informe o número da trilha : '
   else if nomeArq = 'MINAOACH' then s := 'O CD-Player não está preparado.'
   else if nomeArq = 'MI_TRACK' then s := 'Trilha '

   else if nomeArq = 'MISELECM' then s := 'Escolha a mídia e tecle sua opção. F9 mostra menu.'
   else if nomeArq = 'MISELECD' then s := 'Seta para direita executa parte da mídia.'

   else if nomeArq = 'MIAJU001' then s := 'As principais opções do MIDIAVOX são:'
   else if nomeArq = 'MIAJU002' then s := '    A tecla ESC é sempre usada para cancelar'
   else if nomeArq = 'MIAJU003' then s := '    Use as setas para selecionar ou conhecer todas as opções'

   else if nomeArq = 'MISELTAG' then s := 'Qual marcador a apagar? '

   else if nomeArq = 'MI_NOMEM3U'  then s := 'Entre com o nome do arquivo .m3u a gravar: '
   else if nomeArq = 'MI_DESIST'   then s := 'Desistiu.'
   else if nomeArq = 'MI_SOBRESC'  then s := 'Sobrescreve arquivo já existente? (S/N) '
   else if nomeArq = 'MI_OK'       then s := 'OK'
   else if nomeArq = 'MI_NAOGRAV'  then s := 'Não consegui gravar.'

   else if nomeArq = 'MINOMDIR'    then s := 'Informe o diretório:'
   else if nomeArq = 'MIINVAL'     then s := 'Inválido'

   // informações
   else if nomeArq = 'MIINFONO'  then s := 'Nome do arquivo: '
   else if nomeArq = 'MIINFOSI'  then s := 'Tamanho do arquivo: '
   else if nomeArq = 'MIERRPRO'  then s := 'Arquivo está protegido para regravação'
   else if nomeArq = 'MIINFODT'  then s := 'Data de criação: '
   else if nomeArq = 'MIINFOCT'  then s := 'Conteúdo: '
   else if nomeArq = 'MIERRDSC'  then s := 'Desconhecido: '   
   // informações sobre wav
   else if nomeArq = 'MIERRMP3'  then s := 'Arquivo não é um WAV legítimo'
   else if nomeArq = 'MINOINFO'  then s := 'Informações da música não estão disponíveis'
   else if nomeArq = 'MIINFOVE'  then s := 'Velocidade: '
   else if nomeArq = 'MIINFOBI'  then s := 'Bits por Amostra: '
   else if nomeArq = 'MIINFOCA'  then s := 'Canais: '
   // informações sobre mp3
   else if nomeArq = 'MIINFOTI'  then s := 'Título: '
   else if nomeArq = 'MIINFOAR'  then s := 'Artista: '
   else if nomeArq = 'MIINFOAL'  then s := 'Álbum: '
   else if nomeArq = 'MIINFOAN'  then s := 'Ano: '
   else if nomeArq = 'MIINFOGE'  then s := 'Gênero: '
   else if nomeArq = 'MIERRGEN'  then s := 'Gênero: desconhecido'
   else if nomeArq = 'MIINFOCO'  then s := 'Comentários: '

   else if nomeArq = 'MIDIGPED'  then s := 'Digite o pedaço do nome: '

//Neno: Gravar as 3 mensagens abaixo:
   else if nomeArq = 'MISELECI'  then s := 'selecionado'
   else if nomeArq = 'MISELECS'  then s := 'selecionados'
   else if nomeArq = 'MIDE'  then s := 'de'

   else
        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{              dá uma mensagem sem falar
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
{              dá uma mensagem falando
{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;

begin
    s := pegaTextoMensagem (nomeArq);

    if nlf >= 0 then write (s);
    for i := 1 to nlf do
         writeln;

    if (nomeArq <> '') and (existeArqSom (nomearq)) then
        sintSom (nomearq)
    else
        sintetiza (s);

    while sintFalando do keypressed;
end;

{--------------------------------------------------------}
{               Soletra uma string
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
{             Limpa as linhas que estao abaixo
{--------------------------------------------------------}

procedure limpaBaixo (y: integer);
var i: integer;
begin
    for i := y to currentWindow.Bottom+1 do
        begin
            gotoxy (1, i);
            clreol;
        end;
    gotoxy (1, y);
end;

{--------------------------------------------------------}
{       adiciona ao menu (rotina de conveniência)
{--------------------------------------------------------}

procedure menuAdiciona (cod: string);
begin
    popupMenuAdiciona (cod, pegaTextoMensagem(cod));
end;

{--------------------------------------------------------}
{                faz uma pergunta
{--------------------------------------------------------}

function pergunta (msg: string; npula: integer; cor: integer): char;
var c, c2: char;
begin
    textBackground (cor);
    mensagem (msg, 0);
    textBackground (BLACK);
    sintLeTecla (c, c2);
    pergunta := upcase(c);

    if c <> #$0 then
        begin
            c := upcase (c);
            gotoxy(wherex, wherey);
            ClrEol;
        end;
    gotoxy(wherex, wherey);
end;

end.
