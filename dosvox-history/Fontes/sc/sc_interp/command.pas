{------------------------------------------------------------------------------}
{
{                                  COMMAND.PAS
{
{    Processamento dos Comandos Básicos do Interpretador ScriptVox
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Autor:      Oswaldo Vernet
{    Data:       28/08/2015
{    Alterações: 30/03/2016, 20/09/2018
{
{------------------------------------------------------------------------------}

unit COMMAND;

{------------------------------------------------------------------------------}
{                             I N T E R F A C E
{------------------------------------------------------------------------------}

interface

uses
    dvwin, dvcrt, dvmidi, dvmacro, dvexec, dvinet, dvcomm, dvmsaa, dvform, dvjpeg, dvdigitexto,
    classes, windows, winsock, math, messages, mmsystem, strUtils, synacode, sysUtils,
    pngImage, graphics, jpeg,
    screen, lex, symboltable, low, expr, compile,
    others, arithmetic, io, flow,
    sql, sqlite3, sqlite3Wrap;

{------------------------------------------------------------------------------}
{                           I M P L E M E N T A Ç Ã O
{------------------------------------------------------------------------------}

implementation

const
    NUM_COMMANDS = 82;

    commands : array [1..NUM_COMMANDS] of SymtbEntry =
    (
        ( id : 'ABRE';         typeof: S_COMM;     exec: processaAbre ),
        ( id : 'ACEITA';       typeof: S_COMM;     exec: processaAceita ),
        ( id : 'ACIONA';       typeof: S_COMM;     exec: processaAciona ),
        ( id : 'AJUDA';        typeof: S_COMM;     exec: processaAjuda ),
        ( id : 'ANEXA';        typeof: S_COMM;     exec: processaAnexa ),
        ( id : 'BAIXA';        typeof: S_COMM;     exec: processaBaixa ),
        ( id : 'BIPA';         typeof: S_COMM;     exec: processaBipa ),
        ( id : 'BUSCA';        typeof: S_COMM;     exec: processaBusca ),
        ( id : 'CAPTURA';      typeof: S_COMM;     exec: processaCaptura ),
        ( id : 'CHAMA';        typeof: S_COMM;     exec: processaChama ),
        ( id : 'CHECA';        typeof: S_COMM;     exec: processaCheca ),
        ( id : 'CLICA';        typeof: S_COMM;     exec: processaClica ),
        ( id : 'CMD';          typeof: S_COMM;     exec: processaCmd ),
        ( id : 'CONCATENA';    typeof: S_COMM;     exec: processaConcatena ),
        ( id : 'CONECTA';      typeof: S_COMM;     exec: processaConecta ),
        ( id : 'CONTINUA';     typeof: S_CONT;     exec: processaContinua ),
        ( id : 'CONVERTE';     typeof: S_COMM;     exec: processaConverte ),
        ( id : 'COPIA';        typeof: S_COMM;     exec: processaCopia ),
        ( id : 'COR';          typeof: S_COMM;     exec: processaCor ),
        ( id : 'CURSOR';       typeof: S_COMM;     exec: processaCursor ),
        ( id : 'DEBUG';        typeof: S_COMM;     exec: processaDebug ),
        ( id : 'DESTROI';      typeof: S_COMM;     exec: processaDestroi ),
        ( id : 'DESVIA';       typeof: S_COMM;     exec: processaDesvia ),
        ( id : 'DIGITA';       typeof: S_COMM;     exec: processaDigita ),
        ( id : 'DIR';          typeof: S_COMM;     exec: processaDir ),
        ( id : 'DIVIDE';       typeof: S_COMM;     exec: processaDivisao ),
        ( id : 'ENQUANTO';     typeof: S_LOOP;     exec: processaEnquanto ),
        ( id : 'ESCREVE';      typeof: S_COMM;     exec: processaEscreve ),
        ( id : 'ESPERA';       typeof: S_COMM;     exec: processaEspera ),
        ( id : 'EXECUTA';      typeof: S_COMM;     exec: processaExecuta ),
        ( id : 'FALA';         typeof: S_COMM;     exec: processaFala ),
        ( id : 'FECHA';        typeof: S_COMM;     exec: processaFecha ),
        ( id : 'FIM';          typeof: S_END;      exec: processaFim ),
        ( id : 'FORM';         typeof: S_COMM;     exec: processaForm ),
        ( id : 'FUNCAO';       typeof: S_CFUNC;    exec: processaFuncao ),
        ( id : 'FUNDO';        typeof: S_COMM;     exec: processaFundo ),
        ( id : 'HELP';         typeof: S_COMM;     exec: processaAjuda ),
        ( id : 'IMAGEM';       typeof: S_COMM;     exec: processaImagem ),
        ( id : 'IMPORTA';      typeof: S_COMM;     exec: processaImporta ),
        ( id : 'INTERNET';     typeof: S_COMM;     exec: processaInternet ),
        ( id : 'IP';           typeof: S_COMM;     exec: processaIp ),
        ( id : 'JANELA';       typeof: S_COMM;     exec: processaJanela ),
        ( id : 'LE';           typeof: S_COMM;     exec: processaLe ),
        ( id : 'LOCAL';        typeof: S_COMM;     exec: processaLocal ),
        ( id : 'MCI';          typeof: S_COMM;     exec: processaMci ),
        ( id : 'MENU';         typeof: S_COMM;     exec: processaMENU ),
        ( id : 'MIDI';         typeof: S_COMM;     exec: processaMIDI ),
        ( id : 'MOUSE';        typeof: S_COMM;     exec: processaMouse ),
        ( id : 'MSAA';         typeof: S_COMM;     exec: processaMSAA ),
        ( id : 'MULTIPLICA';   typeof: S_COMM;     exec: processaMultiplicacao ),
        ( id : 'OBSERVA';      typeof: S_COMM;     exec: processaObserva ),
        ( id : 'ORDENA';       typeof: S_COMM;     exec: processaCmdOrdena ),
        ( id : 'PARA';         typeof: S_LOOP;     exec: processaPara ),
        ( id : 'PROCURA';      typeof: S_COMM;     exec: processaProcura ),
        ( id : 'QUEBRA';       typeof: S_BREAK;    exec: processaQuebra ),
        ( id : 'RANDOMIZA';    typeof: S_COMM;     exec: processaRandomiza ),
        ( id : 'RATO';         typeof: S_COMM;     exec: processaMouse ),
        ( id : 'REMOVE';       typeof: S_COMM;     exec: processaRemove ),
        ( id : 'RENOMEIA';     typeof: S_COMM;     exec: processaRenomeia ),
        ( id : 'REPETE';       typeof: S_LOOP;     exec: processaRepete ),
        ( id : 'REPLICA';      typeof: S_COMM;     exec: processaReplica ),
        ( id : 'RETORNA';      typeof: S_COMM;     exec: processaRetorna ),
        ( id : 'SE';           typeof: S_IF;       exec: processaSe ),
        ( id : 'SEJA';         typeof: S_COMM;     exec: processaSeja ),
        ( id : 'SENAO';        typeof: S_ELSE;     exec: processaSenao ),
        ( id : 'SENSOR';       typeof: S_COMM;     exec: processaSensor ),
        ( id : 'SEPARA';       typeof: S_COMM;     exec: processaSepara ),
        ( id : 'SERIAL';       typeof: S_COMM;     exec: processaSerial ),
        ( id : 'SERVE';        typeof: S_COMM;     exec: processaServe ),
        ( id : 'SIMBOLOS';     typeof: S_COMM;     exec: processaSimbolos ),
        ( id : 'SOLETRA';      typeof: S_COMM;     exec: processaSoletra ),
        ( id : 'SOMA';         typeof: S_COMM;     exec: processaSoma ),
        ( id : 'SPRITE';       typeof: S_COMM;     exec: processaSprite ),
        ( id : 'SQL';          typeof: S_COMM;     exec: processaSql ),
        ( id : 'SUBSTITUI';    typeof: S_COMM;     exec: processaSubstitui ),
        ( id : 'SUBTRAI';      typeof: S_COMM;     exec: processaSubtracao ),
        ( id : 'TELA';         typeof: S_COMM;     exec: processaTela ),
        ( id : 'TERMINA';      typeof: S_COMM;     exec: processaTermina ),
        ( id : 'TOCA';         typeof: S_COMM;     exec: processaToca ),
        ( id : 'TRANSFERE';    typeof: S_COMM;     exec: processaTransfere ),
        ( id : 'TROCA';        typeof: S_COMM;     exec: processaTroca ),
        ( id : 'VERSAO';       typeof: S_COMM;     exec: processaVersao )
    );

    unitaryIF  : SymtbEntry = (typeof: S_UIF;      exec: processaSeUnitario );
    assignment : SymtbEntry = (typeof: S_COMM;     exec: processaAtrib );
    evaluation : SymtbEntry = (typeof: S_COMM;     exec: processaAvaliacao );


{--------------------------------------------------------}
{   instala os comandos e as funções nativas na tabela
{--------------------------------------------------------}

procedure defineCommands;
var
    i : integer;
begin
    { Instala os comandos }

    for i := 1 to NUM_COMMANDS do
        symboltable.defineStaticSymbol (@commands[i]);

    UnitaryIfPtr  := @unitaryIF;
    AssignmentPtr := @assignment;
    EvaluationPtr := @evaluation;

    ReturnCmdPtr  := symboltable.getCommand ('RETORNA')
end;

begin
    defineCommands;
    searchAttrib := 0   { O comando BUSCA ainda não foi usado }
end.
