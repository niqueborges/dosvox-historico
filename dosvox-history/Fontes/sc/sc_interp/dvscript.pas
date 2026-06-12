{------------------------------------------------------------------------------}
{
{                               DVSCRIPT.PAS
{
{    Interface para uso do ScriptVox como biblioteca
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Autor:      Oswaldo Vernet
{    Data:       28/09/2015
{    Alterações: 30/03/2016, 30/06/2016, 01/10/2018
{
{------------------------------------------------------------------------------}

unit DVSCRIPT;

{--------------------------------------------------------}
{                    I N T E R F A C E
{--------------------------------------------------------}

interface

uses
    screen, lex, interp,
    dvwin, dvcrt, dvmacro, dvexec, dvinet, dvmsaa, dvform, dvjpeg,
    winsock, windows, classes, messages, sysUtils, mmsystem;

const
    SCRIPTVOX_VERSION    = interp.SCRIPTVOX_VERSION;
    SCRIPTVOX_SUBVERSION = interp.SCRIPTVOX_SUBVERSION;

type
    RESULTADO_SCRIPT = ( SCR_OK, SCR_ERROEXEC, SCR_SEMARQUIVO, SCR_ROTULOINVALIDO, SCR_ERROSINTAXE );
    RotinaExterna    = function (str : string) : string;

procedure zeraVarScript;

function  executaLinha                 (cmd : string) : boolean;
function  terminouScript               (var mudo : boolean) : boolean;

function  executaScript                (nomeArq, rotulo : string; var numUltLinha : integer; var ultLinha : string): RESULTADO_SCRIPT;
function  executaScriptList            (scriptOriginal : TStringList; rotulo: string; var numUltLinha : integer; var ultLinha : string): RESULTADO_SCRIPT;
function  executaScriptControlador     (nomeArq : string; rotina : RotinaExterna; var numUltLinha : integer; var ultLinha : string) : RESULTADO_SCRIPT;
function  executaScriptControladorList (scriptOriginal : TStringList; rotina : RotinaExterna; var numUltLinha : integer; var ultLinha : string) : RESULTADO_SCRIPT;

function  calculaExpressao             (expr : string) : string;

{ Legados }

function  extraiValor (var lido : string; var valor : string): boolean;
function  guardaValor (var lido : string;     valor : string): boolean;

{--------------------------------------------------------}
{               I M P L E M E N T A Ç Ã O
{--------------------------------------------------------}

implementation

{--------------------------------------------------------}
{              executa uma linha avulsa
{--------------------------------------------------------}

function executaLinha (cmd : string) : boolean;
begin
    try
        executaLinha := interp.execExtraLine (cmd)
    except
        on e : Exception do
        begin
            executaLinha := true;
            scWriteln (e.Message)
        end
    end
end;

{--------------------------------------------------------}
{   verifica se o script 0 executou o comando TERMINA
{--------------------------------------------------------}

function terminouScript (var mudo : boolean) : boolean;
var
    b : boolean;
begin
    interp.getTermStatus (0, mudo, b);
    terminouScript := b
end;

{--------------------------------------------------------}
{                   executa um script
{--------------------------------------------------------}

function execScript (s : integer; rotulo : string; libera : boolean; var numUltLinha: integer;
                     var ultLinha : string; rotina : RotinaExterna) : RESULTADO_SCRIPT;
label
    fim;
var
    linha           : integer;
    mudo            : boolean;
    executouTermina : boolean;
begin
    numUltLinha     := 0;
    ultLinha        := 'Erro na leitura do script';

    if s < 0 then
    begin
        execScript  := SCR_SEMARQUIVO;
        exit
    end;

    if not interp.preCompile (s) then
    begin
        interp.getLastLine (s, numUltLinha, ultLinha);
        execScript  := SCR_ERROSINTAXE;
        goto fim
    end;

    if (rotulo = '') then
    begin
        linha := 1
    end
    else begin                                  { Foi dado um rótulo como Ponto de Entrada }
        linha := interp.findLabel (s, rotulo);

        if linha <= 0 then
        begin
            execScript := SCR_ROTULOINVALIDO;
            goto fim
        end
    end;

    interp.setExternalFunc (s, rotina);

    try
        if interp.execScript (s, linha) then
            execScript := SCR_OK
        else
            execScript := SCR_ERROEXEC
    except
        on e : Exception do
        begin
            interp.getTermStatus (s, mudo, executouTermina);

            if not mudo and (e.Message <> '') then
                scWriteln (e.Message);

            execScript := SCR_OK
        end
    end;

    interp.getLastLine (s, numUltLinha, ultLinha);

fim:
    if libera then
        interp.freeScript (s)
end;

function executaScript (nomeArq, rotulo: string; var numUltLinha: integer; var ultLinha : string) : RESULTADO_SCRIPT;
begin
    executaScript := execScript (interp.loadScript (nomeArq), rotulo, false, numUltLinha, ultLinha, NIL)
end;

function executaScriptList (scriptOriginal: TStringList; rotulo: string; var numUltLinha: integer; var ultLinha: string): RESULTADO_SCRIPT;
begin
    executaScriptList := execScript (interp.loadScript (scriptOriginal), rotulo, true, numUltLinha, ultLinha, NIL)
end;

function executaScriptControlador (nomeArq : string; rotina : RotinaExterna; var numUltLinha: integer; var ultLinha : string) : RESULTADO_SCRIPT;
begin
    executaScriptControlador := execScript (interp.loadScript (nomeArq), '', false, numUltLinha, ultLinha, rotina)
end;

function executaScriptControladorList (scriptOriginal: TStringList; rotina : RotinaExterna; var numUltLinha: integer; var ultLinha : string) : RESULTADO_SCRIPT;
begin
    executaScriptControladorList := execScript (interp.loadScript (scriptOriginal), '', true, numUltLinha, ultLinha, rotina)
end;

{--------------------------------------------------------}
{             obtém o valor de uma variável
{--------------------------------------------------------}

function extraiValor (var lido: string; var valor: string): boolean; overload;
var
    nomevar : string;
begin
    nomevar := lido;
    if nomevar[1] <> '$' then nomevar := '$' + nomevar;

    valor := interp.evaluateExpression (nomevar);

    extraiValor := true;
    lido := ''
end;

{--------------------------------------------------------}
{            modifica o valor de uma variável
{--------------------------------------------------------}

function guardaValor (var lido: string; valor: string): boolean;
var
    nomevar : string;
    strvalor : string;
begin
    nomevar := lido;
    if nomevar[1] <> '$' then nomevar := '$' + nomevar;

    strvalor := valor;

    if strvalor = '' then
        strvalor := '""'
    else if strvalor[1] <> '"' then
        strvalor := '"' + strvalor;

    if strvalor[length(strvalor)] <> '"' then
        strvalor := strvalor + '"';

    executaLinha (nomevar + ' := ' + strvalor);

    lido := '';
    guardaValor := true
end;

{--------------------------------------------------------}
{             avalia uma expressão
{--------------------------------------------------------}

function calculaExpressao (expr: string) : string;
begin
    calculaExpressao := interp.evaluateExpression (expr)
end;

{--------------------------------------------------------}
{     inicializa variáveis globais do interpretador
{--------------------------------------------------------}

procedure zeraVarScript;
begin
    interp.initInterpreter
end;

begin
    zeraVarScript
end.


