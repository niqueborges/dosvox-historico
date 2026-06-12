{------------------------------------------------------------------------------}
{
{                                  INTERP.PAS
{
{    Módulo Principal
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Autor:      Oswaldo Vernet
{    Data:       28/09/2015
{    Alterações: 30/03/2016
{
{------------------------------------------------------------------------------}

unit INTERP;

{------------------------------------------------------------------------------}
{                             I N T E R F A C E
{------------------------------------------------------------------------------}

interface

uses
    screen, lex, symboltable, low, expr, compile,
    command, native, 
    dvwin, dvcrt, dvinet,
    windows, classes, sysUtils;

const
    SCRIPTVOX_VERSION    = low.SCRIPTVOX_VERSION;
    SCRIPTVOX_SUBVERSION = low.SCRIPTVOX_SUBVERSION;

procedure initInterpreter;

function  loadScript         (script : TStringList) : integer; overload;
function  loadScript         (path : string) : integer; overload;
procedure freeScript         (s : integer);

function  execExtraLine      (cmd : string) : boolean;
function  execScript         (s : integer; start : integer) : boolean;

function  findLabel          (s : integer; id : string): integer;
function  preCompile         (s : integer) : boolean;
function  beautifyScript     (s : integer; pro : string) : integer;
procedure setExternalFunc    (s : integer; rot : ExternalFunc);
procedure getTermStatus      (s : integer; var silent : boolean; var terminated : boolean);
procedure getLastLine        (s : integer; var n : integer; var l : string);

function  evaluateExpression (expr: string) : string;

{------------------------------------------------------------------------------}
{                           I M P L E M E N T A Ç Ã O
{------------------------------------------------------------------------------}

implementation

{--------------------------------------------------------}
{      carrega as DLLs com os novos comandos
{--------------------------------------------------------}

procedure scWriteAdapter (p : PChar; ln : integer);
var
    s : string;
begin
    s := strpas (p);

    if ln = 0 then
        scWrite (s)
    else
        scWriteln (s)
end;

procedure formataLvalue (var v : LvalueRec; var s : shortstring);
begin
    s := expr.formatVar (v)
end;

procedure errorMessage (s : PChar);
begin
    errorMsg (strpas (s))
end;

procedure execCmd (s : PChar);
begin
    execExtraLine (s)
end;

function loadPlugins : integer;
type
    PluginMessage    = array [1..32] of pointer;
    PluginEntryPoint = function (msg : PluginMessage) : integer; stdcall;
var
    pluginHandle     : cardinal;
    entryPoint       : PluginEntryPoint;
    msg              : PluginMessage;
    nLoaded          : integer;
    rec              : TSearchRec;
    dllName          : string;
begin
    nLoaded := 0;

    msg[ 1] := @symboltable.defineStaticSymbol;
    msg[ 2] := @scWriteAdapter;
    msg[ 3] := NIL;
    msg[ 4] := @errorMessage;
    msg[ 5] := @nextToken;
    msg[ 6] := @skiptTokenIf;
    msg[ 7] := @skipToEOL;
    msg[ 8] := @token;
    msg[ 9] := @invalidateExpr;
    msg[10] := @evalExpr;
    msg[11] := @formatExpr;
    msg[12] := @freeExpr;
    msg[13] := @getLvalue;
    msg[14] := @formatVar;
    msg[15] := @doAssignment;
    msg[16] := @execCmd;

    if FindFirst ('plugin*.dll', faAnyFile, rec) = 0 then
    begin
        repeat
            dllName      := rec.name + #0;
            pluginHandle := LoadLibrary (@dllName[1]);

            if pluginHandle <> 0 then
            begin
                @entryPoint := GetProcAddress (pluginHandle, 'pluginEntryPoint');

                if Assigned (@entryPoint) then
                    INC (nLoaded, entryPoint (msg))
            end
        until FindNext (rec) <> 0;
    end;

    loadPlugins := nLoaded
end;

{--------------------------------------------------------}
{           inicializa o Interpretador
{--------------------------------------------------------}

procedure initInterpreter;
begin;
    low.initInterpreter;
    nNewCommands := 0
{   nNewCommands := loadPlugins }  { Somente na versão 7.0 }
end;

{--------------------------------------------------------}
{           avalia uma expressão
{--------------------------------------------------------}

function evaluateExpression (expr : string): string;
var
    p   : PSymtbEntry;
    exp : Operand;
    v   : boolean;
begin
    evaluateExpression := '';

    v := low.verbose; low.verbose := false;

    low.execExtraLine ('$_ := ' + expr);

    low.verbose := v;

    p := symboltable.getSymbol (0, NIL, '$_', false);

    if (p = NIL) or (p^.typeof <> S_VAR) then exit;

    getVarValue (p, exp);
    convertToString (exp);

    if exp.typeof = E_STRING then
        evaluateExpression := exp.pobj^.str
    else
        evaluateExpression := '';

    freeExpr (exp)
end;

{--------------------------------------------------------}
{       Chamadas diretas para o nível inferior           }
{--------------------------------------------------------}

function execExtraLine (cmd : string) : boolean;
begin
    execExtraLine := low.execExtraLine (cmd)
end;

function execScript (s : integer; start : integer) : boolean;
begin
    execScript := low.execScript (s, start)
end;

function loadScript (script : TStringList) : integer;
begin
    loadScript := low.loadScript (script)
end;

function loadScript (path : string) : integer;
begin
    loadScript := low.loadScript (path)
end;

procedure freeScript (s : integer);
begin
    low.freeScript (s)
end;

function preCompile (s : integer) : boolean;
begin
    preCompile := compile.preCompile (s)
end;

function beautifyScript (s : integer; pro : string) : integer;
begin
    beautifyScript := compile.beautifyScript (s, pro)
end;

function findLabel (s : integer; id : string): integer;
begin
    findLabel := symboltable.getLabel (s, NIL, id)
end;

procedure setExternalFunc (s : integer; rot : ExternalFunc);
begin
    low.setExternalFunc (s, rot)
end;

procedure getTermStatus (s : integer; var silent : boolean; var terminated : boolean);
begin
    silent     := low.getSilent (s);
    terminated := low.isTerminated (s)
end;

procedure getLastLine (s : integer; var n : integer; var l : string);
begin
    n := low.getPC (s);
    l := low.getLine (s, n)
end;

begin
end.
