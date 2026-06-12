{------------------------------------------------------------------------------}
{
{                                  EXPR.PAS
{
{    Análise e avaliação de expressões
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Autor:      Oswaldo Vernet
{    Data:       28/08/2015
{    Alterações: 20/09/2018, 30/10/2018
{
{------------------------------------------------------------------------------}

unit EXPR;

{------------------------------------------------------------------------------}
{                              I N T E R F A C E
{------------------------------------------------------------------------------}

interface

uses
    screen, lex, symboltable, low,
    dvwin, dvcrt, dvinet, dvcomm,
    sysutils, classes, math, strUtils;

{******************************* Expressões ***********************************}

const
    MAXVARGS            = 32;

type
    PString             = ^string;
    PDicNode            = ^DicNode;
    POperand            = ^Operand;
    PObjRec             = ^ObjRec;
    PValueRec           = ^ValueRec;

    Dic                 = record                                                { Descritor de um dicionário }
                            card      : integer;
                            first     : PDicNode;
                          end;

    OperandType         = ( E_INVAL, E_UNDEF, E_INTEGER, E_RANGE, E_STRING, E_DIC, E_LIST );

    ObjRec              = record                                                { Descritor de um Objeto }
                            nref      : word;                                   {     Número de vezes que é referenciado }
                            str       : string;                                 {         se tipo = E_STRING }
                            dic       : Dic;                                    {         se tipo = E_DIC }
                            list      : TList                                   {         se tipo = E_LIST }
                          end;

    Operand             = record                                                { Descritor de um getOperand }
                            case typeof : OperandType of
                                E_INTEGER:  ( int       : integer );            {     Valor do getOperand inteiro }
                                E_RANGE:    ( low, high : integer );            {     Limites de uma faixa }
                                E_STRING,                                       {     Os valores dos demais tipos são objetos }
                                E_DIC,
                                E_LIST:     ( pobj      : PObjRec )
                          end;

    DicNode             = record                                                { Nó de dicionário }
                            key       : string;                                 {     chave }
                            value     : Operand;                                {     valor }
                            next      : PDicNode                                {     próximo nó }
                          end;

    ValueRec            = record                                                { O Valor de uma variável }
                            iter      : integer;                                {     é um iterador se iter >= 0 }
                            exp       : Operand                                 {     exp é o valor ou o domínio (no caso de iteradores) }
                          end;

    ARGVET              = array[0 .. MAXVARGS-1] of Operand;

{*********************************** Lvalues **********************************}

    LvalueRec           = record
                            id        : PSymtbEntry;                            { A variável }
                            ind       : Operand                                 { A lista de indexadores }
                          end;

{************************* Célula da pilha de execução ************************}

type
    ExecRec             = record
                            typeof    : (P_RET, P_ARG, P_VAR);                  { Tipo do dado }
                            script    : integer;                                { Script ao qual se refere }
                            scope     : PSymtbEntry;                            { Escopo }
                            val       : ValueRec;                               { Valor }
                            obp, opc  : integer                                 { Valores antigos do BP e do SP (quando tipo = P_RET) }
                          end;
var
    stack               : array [1 .. STACK_LIMIT] of ExecRec;                  { Pilha de execução }

{************************* Constantes Auxiliares ******************************}

const
    OperandTypeToString : array [OperandType] of string[10] =                   { Nome de cada um dos tipos de expressões }
                          (
                                'inválido', 'indefinido', 'inteiro', 'faixa',
                                'cadeia',   'dicionário', 'lista'
                          );

    E_UNDEF_UNDEF       = 16 * ord (E_UNDEF)   + ord (E_UNDEF);                 { Tipos combinados (ver função JOINTYPES) }
    E_UNDEF_INTEGER     = 16 * ord (E_UNDEF)   + ord (E_INTEGER);
    E_UNDEF_STRING      = 16 * ord (E_UNDEF)   + ord (E_STRING);
    E_UNDEF_DIC         = 16 * ord (E_UNDEF)   + ord (E_DIC);
    E_UNDEF_LIST        = 16 * ord (E_UNDEF)   + ord (E_LIST);
    E_INTEGER_UNDEF     = 16 * ord (E_INTEGER) + ord (E_UNDEF);
    E_INTEGER_INTEGER   = 16 * ord (E_INTEGER) + ord (E_INTEGER);
    E_INTEGER_STRING    = 16 * ord (E_INTEGER) + ord (E_STRING);
    E_INTEGER_DIC       = 16 * ord (E_INTEGER) + ord (E_DIC);
    E_INTEGER_LIST      = 16 * ord (E_INTEGER) + ord (E_LIST);
    E_STRING_UNDEF      = 16 * ord (E_STRING)  + ord (E_UNDEF);
    E_STRING_INTEGER    = 16 * ord (E_STRING)  + ord (E_INTEGER);
    E_STRING_STRING     = 16 * ord (E_STRING)  + ord (E_STRING);
    E_STRING_DIC        = 16 * ord (E_STRING)  + ord (E_DIC);
    E_STRING_LIST       = 16 * ord (E_STRING)  + ord (E_LIST);
    E_DIC_UNDEF         = 16 * ord (E_DIC)     + ord (E_UNDEF);
    E_DIC_DIC           = 16 * ord (E_DIC)     + ord (E_DIC);
    E_LIST_UNDEF        = 16 * ord (E_LIST)    + ord (E_UNDEF);
    E_LIST_LIST         = 16 * ord (E_LIST)    + ord (E_LIST);

function  JOINTYPES         (s, t : OperandType) : integer;

function  getVarAddress     (p : PSymtbEntry) : PValueRec;
procedure getVarValue       (p : PSymtbEntry; var exp : Operand);

function  callFunction      (id : string; func : PSymtbEntry; var ret : Operand; var args : ARGVET; nargs : integer) : boolean;

procedure invalidateExpr    (var exp : Operand);
procedure initExpr          (var exp : Operand; t : OperandType);  overload;
procedure initExpr          (var exp : Operand; i : integer);  overload;
procedure initExpr          (var exp : Operand; s : string);  overload;
procedure initExpr          (var exp : Operand; l : TList);  overload;
procedure initExpr          (var exp : Operand; l : TStringList);  overload;
procedure initExpr          (var exp : Operand; d : Dic);  overload;
procedure evalExpr          (var exp : Operand); overload;
procedure evalExpr          (var exp : Operand; t : OperandType); overload;
procedure skipExpr          ();
procedure copyExpr          (var from : Operand; _to : Operand);
procedure duplicateExpr     (var from : Operand; _to : Operand);
procedure freeExpr          (var exp : Operand);
function  formatExpr        (exp : Operand) : string;
function  equalExprs        (e, f : Operand) : boolean;

procedure invalidateLvalue  (var lvalue : LvalueRec);
procedure getLvalue         (var lvalue : LvalueRec); overload;
procedure getLvalue         (var lvalue : LvalueRec; func : boolean); overload;
function  simpleLvalue      (lvalue : LValueRec) : boolean;
procedure evalLvalue        (lvalue : LvalueRec; var exp : Operand); overload;
procedure evalLvalue        (lvalue : LvalueRec; var exp : Operand; t : OperandType); overload;
procedure freeLvalue        (var lvalue : LvalueRec);

procedure doAssignment      (lvalue : LvalueRec; exp : Operand);

function  formatVar         (var lvalue : LvalueRec) : string;
function  formatLvalue      (var lvalue : LvalueRec; sel : PDicNode) : string;

procedure removeLastIndexer (var exp : Operand; var d : Dic);

function  convertToInteger  (var exp : Operand) : OperandType;  overload;
function  convertToInteger  (exp : Operand; var nexp : Operand) : OperandType; overload;
function  convertToString   (var exp : Operand) : OperandType;

function  dicKeys           (d : Dic) : TList;

function  searchList        (l : TList; ini : integer; val : Operand) : integer; overload;
function  searchList        (l : TList; ini : integer; val : Operand; partial : boolean; upper : boolean) : integer; overload;

function  insertList        (var l : TList; pos : integer; value : Operand) : boolean;
procedure removeList        (var l : TList; pos : integer; var value : Operand);
procedure modifyList        (var l : TList; pos : integer; value : Operand); overload;
procedure modifyList        (var l : TList;                value : Operand); overload;
procedure modifyList        (var l : TList; key : Operand; value : Operand); overload;
procedure concatLists       (var r : TList; l, m : TList);
procedure emptyList         (var l : TList);

procedure modifyDic         (var d : Dic; key : string;  value : Operand); overload;
procedure modifyDic         (var d : Dic; key : integer; value : Operand); overload;
procedure modifyDic         (var d : Dic; key : Operand; value : Operand); overload;
procedure removeDic         (var d : Dic; key : Operand; var value : Operand);

procedure doSIZE            (var left : Operand);

procedure readJSON          (fd : integer; var d : Operand);
function  joinList          (l : TList; sep : string) : string;
function  splitString       (s : string) : TList; overload;
function  splitString       (s : string; sep : string) : TList; overload;
function  justifyString     (s : string; n : integer) : string;

{------------------------------------------------------------------------------}
{                        I M P L E M E N T A Ç Ã O
{------------------------------------------------------------------------------}

implementation

procedure doNOP   (var left : Operand; right : Operand); forward;
procedure doEQ    (var left : Operand; right : Operand); forward;
procedure doNE    (var left : Operand; right : Operand); forward;
procedure doGT    (var left : Operand; right : Operand); forward;
procedure doGE    (var left : Operand; right : Operand); forward;
procedure doLT    (var left : Operand; right : Operand); forward;
procedure doLE    (var left : Operand; right : Operand); forward;
procedure doSEQS  (var left : Operand; right : Operand); forward;
procedure doEQS   (var left : Operand; right : Operand); forward;
procedure doSEQ   (var left : Operand; right : Operand); forward;
procedure doADD   (var left : Operand; right : Operand); forward;
procedure doSUB   (var left : Operand; right : Operand); forward;
procedure doMUL   (var left : Operand; right : Operand); forward;
procedure doDIV   (var left : Operand; right : Operand); forward;
procedure doMOD   (var left : Operand; right : Operand); forward;
procedure doPOT   (var left : Operand; right : Operand); forward;
procedure doOR    (var left : Operand; right : Operand); forward;
procedure doAND   (var left : Operand; right : Operand); forward;
procedure doTO    (var left : Operand; right : Operand); forward;
procedure doMUN   (var left : Operand); forward;

procedure getOperand       (var exp: Operand); forward;
procedure internalEvalExpr (var left : Operand; precedence : integer); forward;
procedure recAssignment    (lvalue : LvalueRec; addr : POperand; exp : Operand; sel : PDicNode); forward;

procedure dotSelector      (var exp : Operand); forward;
procedure listOfSelectors  (var exp : Operand); forward;
procedure indexString      (s : string; ind : Operand; var v : Operand); forward;
procedure indexDic         (l : Dic;    ind : Operand; var v : Operand); forward;
procedure indexList        (l : TList;  ind : Operand; var v : Operand); forward;

procedure initDic          (var l : Dic); forward;
procedure literalDic       (var exp : Operand); forward;
function  findDicKey       (var l : Dic; key : string;  create : boolean) : POperand; forward; overload;
function  findDicKey       (var l : Dic; key : integer; create : boolean) : POperand; forward; overload;
function  findDicKey       (var l : Dic; key : Operand; create : boolean) : POperand; forward; overload;
procedure emptyDic         (var l : Dic); forward;
procedure queryDic         (var l : Dic; key : string;  var valor : Operand); forward; overload;
procedure queryDic         (var l : Dic; key : integer; var valor : Operand); forward; overload;
procedure queryDic         (var l : Dic; key : Operand; var valor : Operand); forward; overload;
function  equalDics        (l, m : Dic) : boolean; forward;
function  subDic           (l, m : Dic) : boolean; forward;
function  findDicValue     (l : Dic; val : Operand) : PDicNode; forward;
procedure concatDics       (var r : Dic; d, e : Dic); forward;
procedure appendDic        (var v : Dic; aux : Dic); forward;
procedure dicDifference    (var r : Dic; d, e : Dic); forward;
procedure dicIntersection  (var r : Dic; d, e : Dic); forward;

procedure initList         (var l : TList); forward;
procedure literalList      (var exp : Operand); forward;
procedure queryList        (var l : TList; pos : integer; var value : Operand); forward; overload;
procedure queryList        (var l : TList; s   : string;  var value : Operand); forward; overload;
function  equalLists       (l, m : TList) : boolean; forward;
function  subList          (l, m : TList) : integer; forward;
function  suffixList       (l, m : TList) : integer; forward;
procedure sortList         (var l : TList); forward;
procedure appendList       (var r : TList; l : TList); forward;
procedure listDifference   (var r : TList; l, m : TList); forward;
procedure listIntersection (var r : TList; l, m : TList); forward;
procedure combineList      (var exp : Operand; op : OperatorType); forward;

function  allocNode        (typeof : OperandType) : Pointer; forward;
procedure freeNode         (p : Pointer; t : OperandType); forward;
function  allocObjNode     () : PObjRec; forward;
procedure freeObjNode      (p : PObjRec); forward;

type
    OperRec     = record
                    feasible  : set of OperatorType;      { Operadores deste nível  }
                    multiple  : boolean                   { Podem ocorrer consecutivamente }
                  end;

    Operation   = procedure (var left : Operand; right : Operand);

const
    operatorTable : array [0..7] of OperRec =    { Operadores em ordem crescente de precedência }
    (
        ( feasible: [C_TO];                 multiple: false ),     { Faixa           }
        ( feasible: [C_OR];                 multiple: true  ),     { Disjunção       }
        ( feasible: [C_AND];                multiple: true  ),     { Conjunção       }
        ( feasible: [C_EQ..C_SEQ];          multiple: false ),     { Relacionais     }
        ( feasible: [C_ADD,C_SUB];          multiple: true  ),     { Aditivos        }
        ( feasible: [C_MULT,C_DIV,C_MOD];   multiple: true  ),     { Multiplicativos }
        ( feasible: [C_POT];                multiple: true  ),     { Potenciação     }
        ( feasible: [];                     multiple: false )
    );

    operate : array [OperatorType] of Operation =   { Função associada a cada operador }
    (
        doNOP,
        doEQ,   doNE,   doGT,   doGE,   doLT,   doLE,   doSEQS, doEQS,  doSEQ,
        doADD,  doSUB,  doMUL,  doDIV,  doMOD,  doPOT,
        doOR,   doAND,  doTO,
        doNOP
    );

{--------------------------------------------------------}
{                  combina dois tipos
{--------------------------------------------------------}

function JOINTYPES (s, t : OperandType) : integer;
begin
    JOINTYPES := 16 * ord (s) + ord (t)
end;

{--------------------------------------------------------}
{      obtém o endereço para alterar uma variável
{--------------------------------------------------------}

function getVarAddress (p : PSymtbEntry) : PValueRec;
var
    q : PValueRec;
begin
    if p^.scope = NIL then
    begin
        q := PValueRec (p^.val);

        if q = NIL then
        begin
            try NEW (q) except q := NIL end;

            if q = NIL then
                raise Exception.create ('Memória insuficiente');

            p^.val  := q;
            q^.iter := -1;
            invalidateExpr (q^.exp)
        end
    end
    else begin
        q := @stack[BP + p^.offset].val
    end;

    getVarAddress := q
end;

{--------------------------------------------------------}
{          analisa um identificador qualificado
{--------------------------------------------------------}

function qualifiedId (var id : string; create : boolean) : PSymtbEntry;
var
    p : PSymtbEntry;
    s : integer;
begin
    id := token.id; s := CS; p := symboltable.getVariable (s, CF, id);

    while (p <> NIL) and (p^.typeof = S_MOD) do        { Força um novo escopo }
    begin
        s := p^.offset;

        if nextToken = T_PT then
            nextToken;

        if token.typeof <> T_ID then
        begin
            errorMsg ('Esperava um identificador após o ponto');
            qualifiedId := NIL;
            exit
        end;

        id := token.id; p := symboltable.getVariable (s, NIL, id)
    end;

    if (p = NIL) and create then
        p := symboltable.getSymbol (s, NIL, id, true);

    qualifiedId := p
end;

{--------------------------------------------------------}
{                  invoca uma função
{--------------------------------------------------------}

function callFunction (id : string; func : PSymtbEntry; var ret : Operand; var args : ARGVET; nargs : integer) : boolean;
label
    erro, erro1;
var
    salva_topo, i : integer;
    salva_token   : TokenRec;
    ok            : boolean;
begin
    callFunction := false;

    initExpr (ret, E_UNDEF);

    if compiling then
    begin
        callFunction := true;
        exit
    end;

    if func = NIL then
    begin
        errorMsg ('A função "' + id + '" não foi definida');
        exit
    end;

    {***** Empilha os Argumentos ******}
    
    salva_topo := SP;

    for i := nargs - 1 downto 0 do             { Empilha ao contrário }
    begin
        INC (SP);
        with stack[SP] do
        begin
            typeof   := P_ARG;
            script   := CS;
            val.iter := -1;
            val.exp  := args[i]
        end
    end;

    {** Empilha o Contexto de Retorno *}

    INC (SP);
    with stack[SP] do
    begin
        typeof  := P_RET;
        script  := CS;
        scope   := CF;
        opc     := getPC;
        obp     := BP;

        invalidateExpr (val.exp)           { Aqui será armazenado o valor retornado pela função }
    end;

    BP := SP;                            { Estabelece a base do registro de ativação }

    salva_token  := token;               { Salva o estado do analisador léxico }
    setCS (func^.script);
    setCF (func);

    {******* Executa a Função *********}

    if func^.typeof = S_UFUNC then
        ok := execFunction (func)
    else
        ok := func^.fexec;

    if not ok then goto erro1;

    {***** Desempilha Variáveis *******}

    while SP > BP do
    begin
        if stack[SP].typeof = P_VAR then
            freeExpr (stack[SP].val.exp);

        DEC (SP)
    end;

    if stack[SP].typeof <> P_RET then
    begin
        errorMsg ('Pilha Corrompida, RET não achado');
        goto erro1
    end;

    {****** Restaura o Contexto ********}

    with stack[SP] do
    begin
        setCS (script);
        setCF (scope);

        ret := val.exp;                  { Guarda o valor retornado }
        BP  := obp;                      { Restaura o BP }

        setPC (opc);
        setnPC (getFollowing (CS, opc))
    end;

    token := salva_token;                { Recupera o estado do analisador léxico }

    DEC (SP);

    while SP > salva_topo do             { Libera os argumentos }
    begin
        if stack[SP].typeof = P_ARG then
            freeExpr (stack[SP].val.exp)
        else
            errorMsg ('Pilha corrompida');

        DEC (SP)
    end;

    callFunction := true;
    exit;

erro:
    errorMsg ('Estouro na pilha de chamadas');
erro1:
    SP := salva_topo
end;

{--------------------------------------------------------}
{                 coleta os parâmetros
{--------------------------------------------------------}

procedure getParameters (id : string; func : PSymtbEntry; var args : ARGVET; var nargs : integer);
var
    argLimit : integer;
    excep    : set of FunExcep;
    paren    : boolean;
    msg      : string;

    procedure internalEvalExpr;
    var
        aux  : Operand;
    begin
        if compiling then
        begin
            skipExpr
        end
        else begin
            if nargs < MAXVARGS then
            begin
                evalExpr (args[nargs]);

                if args[nargs].typeof = E_INVAL then
                     initExpr (args[nargs], E_UNDEF)
            end
            else begin
                evalExpr (aux);
                freeExpr (aux)
            end
        end;

        INC (nargs)
    end;

begin
    if func = NIL then
    begin
        argLimit      := MAXVARGS;
        excep         := [];
        paren         := true
    end
    else begin
        if func^.typeof = S_UFUNC then
        begin
            argLimit  := func^.nargs;
            excep     := [];
            paren     := true
        end
        else begin
            argLimit  := func^.narg;
            excep     := func^.excep;
            paren     := false;

            if FE_VARARG in excep then
                paren := true
        end
    end;

    nargs := 0;   argLimit := Min (argLimit, MAXVARGS);

    if token.typeof = T_LP then
    begin
        paren := true;
        nextToken
    end
    else if paren then
    begin
        errorMsg ('A função "' + id + '" deve ser invocada com ()');
        exit
    end;

    if (token.typeof = T_SUS) and (FE_SUS in excep) then
        nextToken;

    if paren then
    begin
        while not (token.typeof in [T_RP,T_EOL]) do
        begin
            internalEvalExpr;

            if token.typeof = T_VG then
                nextToken
        end;

        if token.typeof = T_RP then
            nextToken
        else
            errorMsg ('Faltou fechar parênteses na chamada da função "' + id + '"')
    end
    else begin
        while (nargs < argLimit) and not (token.typeof in [T_RP,T_EOL]) do
        begin
            internalEvalExpr;

            if token.typeof = T_VG then
                nextToken
        end
    end;

    if nargs > argLimit then
    begin
        case argLimit of
            0:   msg := 'não requer parâmetros';
            1:   msg := 'requer um parâmetro apenas';
            else msg := 'requer ' + intToStr (argLimit) + ' parâmetros apenas'
        end;

        errorMsg ('A função "' + id + '" ' + msg)
    end
    else begin
        while nargs < argLimit do               { Completa, se foram dados menos argumentos }
        begin
            initExpr (args[nargs], E_UNDEF);
            INC (nargs)
        end
    end
end;

{--------------------------------------------------------}
{               avalia um operando
{--------------------------------------------------------}

procedure getOperand (var exp: Operand);
var
    p             : PSymtbEntry;
    nargs         : integer;
    id            : string;
    ind, v        : Operand;
    invalid_index : boolean;
    op            : OperatorType;
    args          : ARGVET;
begin
    invalidateExpr (exp);

    case token.typeof of
        T_ID:       begin
                        p := qualifiedId (id, false);

                        nextToken;

                        if p = NIL then        { NÃO achou na tabela }
                        begin
                            if token.typeof = T_LP then
                            begin
                                getParameters (id, NIL, args, nargs);
                                callFunction (id, NIL, exp, args, nargs)
                            end
                            else begin
                                errorMsg ('A variável "' + id + '" não foi inicializada')
                            end
                        end
                        else begin             { Achou o identificador na tabela }
                            case p^.typeof of
                                S_NFUNC,
                                S_UFUNC:  begin
                                              getParameters (id, p, args, nargs);
                                              callFunction (id, p, exp, args, nargs)
                                          end;
                                S_VAR:    getVarValue (p, exp);
                                else      begin
                                              errorMsg
                                              (
                                                  '"' + id + '" é um identificador de ' +
                                                  SymbolTypeToStr[p^.typeof] +
                                                  '; não pode ser nome de variável'
                                              );
                                          end
                            end
                        end
                    end;
        T_INT:      begin
                        initExpr (exp, token.int);
                        nextToken;
                        exit
                    end;
        T_STR:      begin
                        initExpr (exp, token.id);
                        nextToken
                    end;
        T_LP:       begin
                        nextToken;
                        internalEvalExpr (exp, 1);

                        if token.typeof <> T_RP then
                            errorMsg ('Faltou fechar parênteses')
                        else
                            nextToken
                    end;
        T_LC:       literalDic (exp);
        T_LB:       literalList (exp);
        T_OP:       begin
                        if token.op = C_SUB then        { menos unário }
                        begin
                            nextToken;
                            getOperand (exp);
                            doMUN (exp)
                        end
                        else if token.op in [C_ADD,C_MULT,C_LT,C_GT] then   { +, *, < e > }
                        begin
                            op := token.op;
                            nextToken;
                            getOperand (exp);
                            if exp.typeof = E_LIST then
                                combineList (exp, op)
                        end
                        else if token.op = C_SIZE then  { operador |x| }
                        begin
                            nextToken;
                            internalEvalExpr (exp, 1);

                            if (token.typeof <> T_OP) or (token.op <> C_SIZE) then
                                errorMsg ('Faltou a barra vertical')
                            else
                                nextToken;

                            doSIZE (exp)
                        end
                        else begin
                            errorMsg ('Operador ' + token.rid + ' inesperado');
                            {nextToken}
                        end
                    end
    end;

    { Somente getOperands dos tipos E_DIC, E_LIST ou E_STRING podem ser indexados }

    invalid_index := false;

    while token.typeof in [T_LB,T_PT] do
    begin
        if token.typeof = T_PT then
            dotSelector (ind)
        else
            listOfSelectors (ind);

        case exp.typeof of
            E_INVAL:    invalidateExpr (v);
            E_STRING:   indexString (exp.pobj^.str,  ind, v);
            E_DIC:      indexDic    (exp.pobj^.dic,  ind, v);
            E_LIST:     indexList   (exp.pobj^.list, ind, v);
            else        begin
                            invalid_index := true;
                            invalidateExpr (v)
                        end
        end;

        freeExpr (ind);
        freeExpr (exp);
        exp := v                { copyExpr (exp, v); freeExpr (v); }
    end;

    if invalid_index then
        freeExpr (exp)          { Volta com tipo = E_INVAL }
end;

{--------------------------------------------------------}
{            obtém o valor de uma variável
{--------------------------------------------------------}

procedure getVarValue (p : PSymtbEntry; var exp : Operand);
var
    q   : PValueRec;
begin
    initExpr (exp, E_UNDEF);

    q := getVarAddress (p);

    if q^.iter < 0 then
    begin
        copyExpr (exp, q^.exp)
    end
    else begin
        case q^.exp.typeof of
            E_RANGE:  if q^.exp.low <= q^.exp.high then
                          initExpr (exp, q^.exp.low + q^.iter)
                      else
                          initExpr (exp, q^.exp.low - q^.iter);
            E_STRING: if q^.iter < length (q^.exp.pobj^.str) then
                          initExpr (exp, q^.exp.pobj^.str[q^.iter+1]);
            E_LIST:   if q^.iter < q^.exp.pobj^.list.Count then
                          copyExpr (exp, POperand (q^.exp.pobj^.list.Items[q^.iter])^)
        end
    end
end;

{--------------------------------------------------------}
{                  indexa uma cadeia
{--------------------------------------------------------}

procedure indexString (s : string; ind : Operand; var v : Operand);
var
    q            : PDicNode;
    r            : string;
    i, len, erro : integer;
    aux          : Operand;
begin
    r   := '';                 { O resultado é sempre uma cadeia }
    len := length (s);

    case ind.typeof of
        E_INVAL,
        E_UNDEF:        ;
        E_INTEGER:      begin
                            i := ind.int;
                            if (i > 0) and (i <= len) then
                                r := s[i]
                        end;
        E_RANGE:        begin
                            if ind.low <= ind.high then                          { Faixa crescente }
                            begin
                                for i := ind.low to ind.high do
                                begin
                                    if (i > 0) and (i <= len) then
                                        r := r + s[i]
                                end
                            end
                            else begin                                          { Faixa decrescente }
                                for i := ind.low downto ind.high do
                                begin
                                    if (i > 0) and (i <= len) then
                                        r := r + s[i]
                                end
                            end
                        end;
        E_STRING:       begin
                            val (ind.pobj^.str, i, erro);
                            if (erro = 0) and (i > 0) and (i <= len) then
                            begin
                                r := s[i]
                            end
                            else begin
                                initExpr (v, POS (ind.pobj^.str, s));
                                exit
                            end
                        end;
        E_DIC:          begin
                            q := ind.pobj^.dic.first;
                            while q <> NIL do
                            begin
                                indexString (s, q^.value, aux);
                                convertToString (aux);
                                r := r + aux.pobj^.str;
                                freeExpr (aux);
                                q := q^.next
                            end
                        end;
        E_LIST:         with ind.pobj^.list do
                        begin
                            if Count = 0 then
                            begin
                                if length(s) > 0 then
                                    r := s[length(s)]
                                else
                                    r := ''
                            end
                            else begin
                                for i := 0 to Count - 1 do
                                begin
                                    if Items[i] <> NIL then
                                    begin
                                        indexString (s, POperand (Items[i])^, aux);
                                        convertToString (aux);
                                        r := r + aux.pobj^.str;
                                        freeExpr (aux)
                                    end
                                end
                            end
                        end
    end;

    initExpr (v, r)
end;

{--------------------------------------------------------}
{                indexa um dicionário
{--------------------------------------------------------}

procedure indexDic (l : Dic; ind : Operand; var v : Operand);
label
    erro;
var
    i   : integer;
    q   : PDicNode;
    aux : Operand;
begin
    case ind.typeof of
        E_INVAL,
        E_UNDEF:        invalidateExpr (v);
        E_INTEGER:      queryDic (l, ind.int, v);
        E_STRING:       queryDic (l, ind.pobj^.str, v);
        E_RANGE:        if ind.low = ind.high then
                        begin
                            queryDic (l, ind.low, v);
                        end
                        else begin
                            initExpr (v, E_DIC);           { O resultado é um dicionário }

                            if ind.low < ind.high then
                            begin
                                for i := ind.low to ind.high do
                                begin
                                    queryDic (l, i, aux);
                                    if aux.typeof = E_INVAL then goto erro;

                                    modifyDic (v.pobj^.dic, i, aux);
                                    freeExpr (aux)
                                end
                            end
                            else begin
                                for i := ind.low downto ind.high do
                                begin
                                    queryDic (l, i, aux);
                                    if aux.typeof = E_INVAL then goto erro;

                                    modifyDic (v.pobj^.dic, i, aux);
                                    freeExpr (aux)
                                end
                            end
                        end;
        E_DIC:          with ind.pobj^.dic do
                        begin
                            if card = 1 then
                            begin
                                indexDic (l, first.value, v);
                                exit
                            end;

                            initExpr (v, E_DIC);           { O resultado é um dicionário }

                            q := first;
                            while q <> NIL do
                            begin
                                indexDic (l, q^.value, aux);
                                if aux.typeof = E_INVAL then goto erro;

                                if aux.typeof = E_DIC then
                                    appendDic  (v.pobj^.dic, aux.pobj^.dic)
                                else
                                    modifyDic (v.pobj^.dic, q^.value, aux);

                                freeExpr (aux);
                                q := q^.next
                            end
                        end;
        E_LIST:         with ind.pobj^.list do
                        begin
                            if Count = 0 then
                            begin
                                initExpr (v, E_UNDEF);
                                exit
                            end;

                            if (Count = 1) and (Items[0] <> NIL) then
                            begin
                                indexDic (l, POperand (Items[0])^, v);
                                exit
                            end;

                            initExpr (v, E_DIC);           { O resultado é um dicionário }

                            for i := 0 to Count - 1 do
                            begin
                                if Items[i] <> NIL then
                                begin
                                    indexDic (l, POperand (Items[i])^, aux);
                                    if aux.typeof = E_INVAL then goto erro;

                                    if aux.typeof = E_DIC then
                                        appendDic  (v.pobj^.dic, aux.pobj^.dic)
                                    else
                                        modifyDic (v.pobj^.dic, POperand (Items[i])^, aux);

                                    freeExpr (aux)
                                end
                            end
                        end
    end;

    exit;

erro:
    freeExpr (v)
end;

{--------------------------------------------------------}
{                  indexa uma lista
{--------------------------------------------------------}

procedure indexList (l : TList; ind : Operand; var v : Operand);
label
    erro;
var
    i, ini, fim : integer;
    q           : PDicNode;
    aux         : Operand;
begin
    case ind.typeof of
        E_INVAL,
        E_UNDEF:        invalidateExpr (v);
        E_INTEGER:      queryList (l, ind.int, v);
        E_STRING:       queryList (l, ind.pobj^.str, v);
        E_RANGE:        if ind.low = ind.high then
                        begin
                            queryList (l, ind.low, v);
                        end
                        else begin
                            initExpr (v, E_LIST);         { O resultado é uma lista }

                            if ind.low < ind.high then
                            begin
                                ini := Max (ind.low, 0);
                                fim := Min (ind.high, l.Count - 1);

                                for i := ini to fim do
                                begin
                                    queryList (l, i, aux);
                                    modifyList (v.pobj^.list, aux);
                                    freeExpr (aux)
                                end
                            end
                            else begin
                                ini := Min (ind.low, l.Count - 1);
                                fim := Max (ind.high, 0);

                                for i := ini downto fim do
                                begin
                                    queryList (l, i, aux);
                                    modifyList (v.pobj^.list, aux);
                                    freeExpr (aux)
                                end
                            end
                        end;
        E_DIC:          with ind.pobj^.dic do
                        begin
                            if card = 1 then
                            begin
                                indexList (l, first.value, v);
                                exit
                            end;

                            initExpr (v, E_LIST);         { O resultado é uma lista }

                            q := first;
                            while q <> NIL do
                            begin
                                indexList (l, q^.value, aux);
                                if aux.typeof = E_INVAL then goto erro;

                                if aux.typeof = E_LIST then
                                    appendList (v.pobj^.list, aux.pobj^.list)
                                else
                                    modifyList (v.pobj^.list, aux);

                                freeExpr (aux);
                                q := q^.next
                            end
                        end;
        E_LIST:         with ind.pobj^.list do
                        begin
                            if Count = 0 then
                            begin
                                queryList (l, l.Count - 1, v);
                                exit
                            end;

                            if (Count = 1) and (Items[0] <> NIL) then
                            begin
                                indexList (l, POperand (Items[0])^, v);
                                exit
                            end;

                            initExpr (v, E_LIST);         { O resultado é uma lista }

                            for i := 0 to Count - 1 do
                            begin
                                if Items[i] <> NIL then
                                begin
                                    indexList (l, POperand (Items[i])^, aux);
                                    if aux.typeof = E_INVAL then goto erro;

                                    if aux.typeof = E_LIST then
                                        appendList (v.pobj^.list, aux.pobj^.list)
                                    else
                                        modifyList (v.pobj^.list, aux);

                                    freeExpr (aux)
                                end
                            end
                        end
    end;

    exit;

erro:
    freeExpr (v)
end;

{--------------------------------------------------------}
{      processa a definição literal de um dicionário
{--------------------------------------------------------}

procedure literalDic (var exp : Operand);
var
    ind, val : Operand;
    seq      : integer;
begin
    initExpr (exp, E_DIC);      { a resposta é um dicionário }

    if nextToken = T_RC then
    begin
        nextToken;
        exit
    end;

    seq := 0;

    while true do
    begin
        internalEvalExpr (val, 1);

        if token.typeof = T_CL then     { Veio ":" }
        begin
            ind := val;

            if ind.typeof = E_INTEGER then
                seq := ind.int + 1;

            nextToken;
            internalEvalExpr (val, 1)
        end
        else begin
            initExpr (ind, seq);
            INC (seq)
        end;

        modifyDic (exp.pobj^.dic, ind, val);

        freeExpr (ind);
        freeExpr (val);

        if token.typeof = T_RC then
        begin
            nextToken;
            exit
        end;

        if token.typeof = T_VG then
        begin
            nextToken
        end
        else begin
            errorMsg (0, token.rid + ' é um token inválido neste contexto');
            while not (token.typeof in [T_EOL,T_RC]) do nextToken;
            if token.typeof = T_RC then nextToken;
            exit
        end
    end
end;

{--------------------------------------------------------}
{      processa a definição literal de uma lista
{--------------------------------------------------------}

procedure literalList (var exp : Operand);
var
    val, fim : Operand;
begin
    initExpr (exp, E_LIST);      { a resposta será uma lista }

    if nextToken = T_RB then
    begin
        nextToken;
        exit
    end;

    while true do
    begin
        internalEvalExpr (val, 1);

        if (token.typeof = T_OP) and (token.op = C_TO) then      { Veio ".." }
        begin
            nextToken;
            internalEvalExpr (fim, 1);

            if (val.typeof <> E_INTEGER) or (fim.typeof <> E_INTEGER) then
            begin
                errorMsg ('Esperava uma faixa de inteiros como elementos da lista');
                freeExpr (val);
                freeExpr (fim)
            end
            else begin
                if val.int <= fim.int then
                begin
                    while val.int <= fim.int do
                    begin
                        modifyList (exp.pobj^.list, val);
                        INC (val.int)
                    end
                end
                else begin
                    while val.int >= fim.int do
                    begin
                        modifyList (exp.pobj^.list, val);
                        DEC (val.int)
                    end
                end
            end
        end
        else begin
            modifyList (exp.pobj^.list, val);
            freeExpr (val)
        end;

        if token.typeof = T_RB then
        begin
            nextToken;
            exit
        end;

        if token.typeof = T_VG then
        begin
            nextToken
        end
        else begin
            errorMsg (0, token.rid + ' não era esperado');
            while not (token.typeof in [T_EOL,T_RB]) do nextToken;
            if token.typeof = T_RB then nextToken;
            exit
        end
    end
end;

{--------------------------------------------------------}
{                processa o seletor "."
{--------------------------------------------------------}

procedure dotSelector (var exp : Operand);
var
    ind : Operand;
begin
    initExpr (exp, E_LIST);      { a resposta é uma lista }

    if nextToken <> T_ID then
    begin
        errorMsg ('Esperava um identificador após o seletor "."');
        exit
    end;

    initExpr (ind, token.rid);

    modifyList (exp.pobj^.list, 0, ind);

    freeExpr (ind);

    nextToken
end;

{--------------------------------------------------------}
{           processa uma lista de seletores
{--------------------------------------------------------}

procedure listOfSelectors (var exp : Operand);
var
    ind : Operand;
begin
    initExpr (exp, E_LIST);      { a resposta é uma lista }

    if nextToken = T_RB then
    begin
        nextToken;
        exit
    end;

    while true do
    begin
        internalEvalExpr (ind, 0);              { Zero significa que o operador ".." deverá ser tratado }

        if ind.typeof <> E_INVAL then
        begin
            modifyList (exp.pobj^.list, ind);   { acrescenta o indexador ao fim da lista }
            freeExpr (ind)
        end;

        if token.typeof = T_RB then
        begin
            nextToken;
            exit
        end;

        if token.typeof = T_VG then
        begin
            nextToken
        end
        else begin
            errorMsg (0, token.rid + ' não era esperado');
            while not (token.typeof in [T_EOL,T_RB]) do nextToken;
            if token.typeof = T_RB then nextToken;
            exit
        end
    end
end;

{--------------------------------------------------------}
{         analisa um Lvalue, mas sem avaliar
{--------------------------------------------------------}

procedure getLvalue (var lvalue : LvalueRec; func : boolean);  overload;
var
    p    : PSymtbEntry;
    ind  : Operand;
    key  : integer;
    id   : string;
begin
    lvalue.id := NIL;
    invalidateExpr (lvalue.ind);

    if token.typeof <> T_ID then
    begin
        errorMsg ('Esperava um identificador');
        exit
    end;

    p := qualifiedId (id, true);

    if p^.typeof = S_UNDEF then
    begin
        p^.typeof := S_VAR;
        invalidateExpr (getVarAddress (p)^.exp)
    end
    else if func and (p^.typeof in [S_NFUNC,S_UFUNC]) then
    begin
        lvalue.id := p;
        exit
    end
    else if p^.typeof <> S_VAR then
    begin
        errorMsg ('"' + token.id + '" é um identificador de ' + SymbolTypeToStr[p^.typeof] + '; não pode ser nome de variável');
        exit
    end;

    lvalue.id := p;

    initExpr (lvalue.ind, E_DIC);      { A lista de indexadores é um dicionário }

    nextToken;

    key := 0;

    while token.typeof in [T_LB,T_PT] do
    begin
        if token.typeof = T_LB then
            listOfSelectors (ind)
        else
            dotSelector (ind);

        modifyDic (lvalue.ind.pobj^.dic, key, ind);

        freeExpr (ind);
        INC (key)
    end
end;

procedure getLvalue (var lvalue : LvalueRec);  overload;
begin
    getLvalue (lvalue, false)
end;

{--------------------------------------------------------}
{            verifica se um Lvalue é simples
{--------------------------------------------------------}

function simpleLvalue (lvalue : LValueRec) : boolean;
begin
    simpleLvalue := (lvalue.id <> NIL) and (lvalue.ind.typeof = E_DIC) and (lvalue.ind.pobj^.dic.card = 0)
end;

{--------------------------------------------------------}
{                  avalia um Lvalue
{--------------------------------------------------------}

procedure evalLvalue (lvalue : LvalueRec; var exp : Operand);
var
    p : PDicNode;
    v : Operand;
begin
    if lvalue.id = NIL then
    begin
        invalidateExpr (exp);
        exit
    end;

    copyExpr (exp, getVarAddress (lvalue.id)^.exp);

    p := lvalue.ind.pobj^.dic.first;

    while p <> NIL do
    begin
        case exp.typeof of
            E_STRING: indexString (exp.pobj^.str, p^.value, v);
            E_DIC:    indexDic    (exp.pobj^.dic,    p^.value, v);
            E_LIST:   indexList   (exp.pobj^.list,  p^.value, v);
            else      invalidateExpr (v)
        end;

        freeExpr (exp);
        exp := v;           { copyExpr (exp, v); freeExpr (v); }

        p := p^.next
    end
end;

procedure evalLvalue (lvalue : LvalueRec; var exp : Operand; t : OperandType);
begin
    evalLvalue (lvalue, exp);

    if (exp.typeof <> E_INVAL) and (exp.typeof <> t) then
    begin
        if t = E_INTEGER then
            convertToInteger (exp)
        else if t = E_STRING then
            convertToString (exp)
    end
end;

{--------------------------------------------------------}
{                  libera um Lvalue
{--------------------------------------------------------}

procedure freeLvalue (var lvalue : LvalueRec);
begin
    if lvalue.id <> NIL then
    begin
        freeExpr (lvalue.ind);
        lvalue.id := NIL
    end
end;

{--------------------------------------------------------}
{                 invalida um Lvalue
{--------------------------------------------------------}

procedure invalidateLvalue (var lvalue : LvalueRec);
begin
    invalidateExpr (lvalue.ind);
    lvalue.id := NIL
end;

{--------------------------------------------------------}
{           formata um Lvalue em uma cadeia
{--------------------------------------------------------}

function formatVar (var lvalue : LvalueRec) : string;
begin
    formatVar := formatLvalue (lvalue, NIL)
end;

function formatLvalue (var lvalue : LvalueRec; sel : PDicNode) : string;
var
    s : string;
    q : PDicNode;
begin
    if lvalue.id = NIL then
    begin
        formatLvalue := '';
        exit
    end;

    s := lvalue.id^.id;

    if lvalue.ind.typeof = E_DIC then
    begin
        q := lvalue.ind.pobj^.dic.first;
        while (q <> NIL) and (q <> sel) do
        begin
            s := s + formatExpr (q^.value);
            q := q^.next
        end
    end;

    formatLvalue := s
end;

{--------------------------------------------------------}
{      processa a atribuição a partes de um dicionário
{--------------------------------------------------------}

function atribuiDic (lvalue : LvalueRec; var l : Dic; key : Operand; exp : Operand; sel : PDicNode) : boolean;
var
    ad          : POperand;
    i, ini, fim : integer;
    aux         : Operand;
    p           : PDicNode;
begin
    atribuiDic := false;

    case key.typeof of
        E_INVAL,
        E_UNDEF:        exit;
        E_INTEGER,
        E_STRING:       begin
                            ad := findDicKey (l, key, sel = NIL);
                            if ad = NIL then exit;
                            recAssignment (lvalue, ad, exp, sel)
                        end;
        E_RANGE:        begin
                            ini := Min (key.low, key.high);
                            fim := Max (key.low, key.high);

                            for i := ini to fim do
                            begin
                                initExpr (aux, i);
                                ad := findDicKey (l, aux, sel = NIL);
                                if ad = NIL then exit;
                                recAssignment (lvalue, ad, exp, sel)
                            end
                        end;
        E_DIC:          begin
                            p := key.pobj^.dic.first;
                            while p <> NIL do
                            begin
                                if not atribuiDic (lvalue, l, p^.value, exp, sel) then
                                    exit;
                                p := p^.next
                            end
                        end;
        E_LIST:        with key.pobj^.list do
                        begin
                            for i := 0 to Count - 1 do
                            begin
                                if Items[i] <> NIL then
                                begin
                                    if not atribuiDic (lvalue, l, POperand (Items[i])^, exp, sel) then
                                        exit
                                end
                            end
                        end
    end;

    atribuiDic := true
end;

{--------------------------------------------------------}
{      processa a atribuição a partes de uma lista
{--------------------------------------------------------}

function atribuiLista (lvalue : LvalueRec; var l : TList; key : Operand; exp : Operand; sel : PDicNode) : boolean;
var
    ad                 : POperand;
    i, j, ini, fim     : integer;
    tam, novofim, erro : integer;
    p                  : PDicNode;

    function achaEndereco (var l : TList; i : integer) : POperand;
    var
        q : POperand;
    begin
        if i < 0 then
        begin
            achaEndereco := NIL
        end
        else begin
            if i >= l.Count then
            begin
                if sel <> NIL then
                begin
                    achaEndereco := NIL;
                end
                else begin
                    q := allocNode (E_LIST);

                    if q <> NIL then
                    begin
                        invalidateExpr (q^);
                        l.Add (q)
                    end;
                    
                    achaEndereco := q
                end
            end
            else begin
                achaEndereco := POperand (l.Items[i])
            end
        end
    end;

begin
    atribuiLista := false;

    case key.typeof of
        E_INVAL,
        E_UNDEF:        exit;
        E_INTEGER:      begin
                            ad := achaEndereco (l, key.int);
                            if ad = NIL then exit;
                            recAssignment (lvalue, ad, exp, sel)
                        end;
        E_STRING:       begin
                            val (key.pobj^.str, i, erro);
                            if erro <> 0 then exit;
                            ad := achaEndereco (l, i);
                            if ad = NIL then exit;
                            recAssignment (lvalue, ad, exp, sel)
                        end;
        E_RANGE:        begin
                            ini := Min (key.low, key.high);
                            fim := Max (key.low, key.high);

                            if (exp.typeof = E_LIST) and (sel = NIL) then
                            begin
                                if (ini < 0) or (ini >= l.Count) then exit;

                                tam     := exp.pobj^.list.Count;
                                novofim := ini + tam;

                                if novofim > l.Count then
                                begin
                                    for j := l.Count to novofim - 1 do
                                        l.Add (NIL)
                                end
                                else begin
                                    if novofim < fim + 1 then       { Tem que retirar elementos }
                                    begin
                                        for j := novofim to Min (fim + 1, l.Count) - 1 do
                                        begin
                                            freeNode (l.Items[novofim], E_LIST);
                                            l.Delete (novofim)
                                        end
                                    end
                                    else if novofim > fim + 1 then  { Tem que acrescentar elementos }
                                    begin
                                        for j := fim + 1 to novofim - 1 do
                                            l.Insert (fim + 1, NIL)
                                    end
                                end;

                                if key.low <= key.high then
                                begin
                                    j := 0;
                                    for i := key.low to key.low + tam - 1 do
                                    begin
                                        if l.Items[i] = NIL then
                                            l.Items[i] := allocNode (E_LIST)
                                        else
                                            freeExpr (POperand (l.Items[i])^);

                                        copyExpr  (POperand (l.Items[i])^, POperand (exp.pobj^.list.Items[j])^);
                                        INC (j)
                                    end
                                end
                                else begin
                                    j := 0;
                                    for i := key.high + tam - 1 downto key.high do
                                    begin
                                        if l.Items[i] = NIL then
                                            l.Items[i] := allocNode (E_LIST)
                                        else
                                            freeExpr (POperand (l.Items[i])^);

                                        copyExpr  (POperand (l.Items[i])^, POperand (exp.pobj^.list.Items[j])^);
                                        INC (j)
                                    end
                                end
                            end
                            else begin
                                for i := ini to fim do
                                begin
                                    ad := achaEndereco (l, i);
                                    if ad = NIL then exit;
                                    recAssignment (lvalue, ad, exp, sel)
                                end
                            end
                        end;
        E_DIC:          begin
                            p := key.pobj^.dic.first;
                            while p <> NIL do
                            begin
                                if not atribuiLista (lvalue, l, p^.value, exp, sel) then
                                    exit;
                                p := p^.next
                            end
                        end;
        E_LIST:         with key.pobj^.list do
                        begin
                            for i := 0 to Count - 1 do
                            begin
                                if Items[i] <> NIL then
                                begin
                                    if not atribuiLista (lvalue, l, POperand (Items[i])^, exp, sel) then
                                        exit
                                end
                            end
                        end
    end;

    atribuiLista := true
end;

{--------------------------------------------------------}
{      processa a atribuição a partes de uma cadeia
{--------------------------------------------------------}

function atribuiCadeia (lvalue : LvalueRec; var s : string; key : Operand; exp : Operand) : boolean;
var
    p                   : PDicNode;
    c                   : char;
    i, tam, ini, fim    : integer;
    sub, bus            : string;
begin
    atribuiCadeia := false;

    if key.typeof = E_DIC then
    begin
        p := key.pobj^.dic.first;
        while p <> NIL do
        begin
            if not atribuiCadeia (lvalue, s, p^.value, exp) then exit;
            p := p^.next
        end;

        atribuiCadeia := true;
        exit
    end;

    if key.typeof = E_LIST then
    begin
        with key.pobj^.list do
        begin
            if Count = 0 then
            begin
                if exp.typeof = E_INTEGER then
                begin
                    if (exp.int >= 0) and (exp.int <= 255) then
                        sub := chr (exp.int)
                    else
                        sub := ' '
                end
                else begin
                    sub := exp.pobj^.str
                end;

                s := s + sub
            end
            else begin
                for i := 0 to Count - 1 do
                begin
                    if Items[i] <> NIL then
                    begin
                        if not atribuiCadeia (lvalue, s, POperand (Items[i])^, exp) then
                            exit
                    end
                end
            end
        end;

        atribuiCadeia := true;
        exit
    end;

    tam := 1;
    i   := -1;

    case key.typeof of
        E_INTEGER:       begin
                            if (key.int >= 1) and (key.int <= length (s)) then
                            begin
                                if exp.typeof = E_INTEGER then
                                begin
                                    if (exp.int >= 0) and (exp.int <= 255) then
                                        sub := chr (exp.int)
                                    else
                                        sub := ' '
                                end
                                else begin
                                    sub := exp.pobj^.str
                                end;

                                i := key.int
                            end
                        end;
        E_RANGE:        begin
                            ini := Min (key.low, key.high);
                            fim := Max (key.low, key.high);

                            if (ini > 0) and (fim <= length (s)) then
                            begin
                                tam := fim - ini + 1;

                                if exp.typeof = E_INTEGER then
                                begin
                                    if (exp.int >= 0) and (exp.int <= 255) then
                                        c := chr (exp.int)
                                    else
                                        c := ' ';

                                    sub := '';
                                    for i := 1 to tam do
                                        sub := sub + c
                                end
                                else begin
                                    sub := exp.pobj^.str;

                                    if key.low > key.high then
                                    begin
                                        bus := '';
                                        for i := 1 to length (sub) do
                                            bus := sub[i] + bus;
                                        sub := bus
                                    end
                                end;

                                i := ini
                            end
                        end
        end;

        if i > 0 then
        begin
            delete (s, i, tam);
            insert (sub, s, i);
            atribuiCadeia := true
        end
end;

{--------------------------------------------------------}
{     percorre recursivamente a cadeia de seletores
{--------------------------------------------------------}

procedure recAssignment (lvalue : LvalueRec; addr : POperand; exp : Operand; sel : PDicNode);
var
    aux : Operand;
    i   : integer;
    ok  : boolean;
begin
    if sel = NIL then
    begin
        if addr <> NIL then                  { AQUI é feita a atribuição final }
        begin
            freeExpr (addr^);
            copyExpr (addr^, exp)
        end
    end
    else begin
        if not (addr^.typeof in [E_STRING, E_LIST, E_DIC]) then
        begin
            errorMsg ('"' + formatLvalue (lvalue, sel) + '" é do tipo "' + OperandTypeToString[addr^.typeof] + '", não é indexável');
            exit
        end;

        if addr^.typeof = E_STRING then
        begin
            if not (exp.typeof in [E_INTEGER,E_STRING]) then
            begin
                errorMsg ('Valor a ser atribuído é incompatível com uma cadeia');
                exit
            end
        end;

        if sel^.value.typeof <> E_LIST then
        begin
            errorMsg ('Algo muito podre acontece aqui, sob seus olhos');
            exit
        end;

        with sel^.value.pobj^.list do
        begin
            if Count = 0 then    { Ex: l[] = 2 }
            begin
                if addr^.typeof = E_LIST then
                begin
                    initExpr (aux, addr^.pobj^.list.Count);
                    atribuiLista (lvalue, addr^.pobj^.list, aux, exp, sel^.next)
                end
                else if addr^.typeof = E_STRING then
                begin
                    atribuiCadeia (lvalue, addr^.pobj^.str, sel^.value, exp)
                end
            end;

            for i := 0 to Count - 1 do
            begin
                if Items[i] <> NIL then
                begin
                    case addr^.typeof of
                        E_STRING: ok := atribuiCadeia (lvalue, addr^.pobj^.str,  POperand (Items[i])^, exp);
                        E_LIST:   ok := atribuiLista  (lvalue, addr^.pobj^.list, POperand (Items[i])^, exp, sel^.next);
                        E_DIC:    ok := atribuiDic    (lvalue, addr^.pobj^.dic,  POperand (Items[i])^, exp, sel^.next);
                        else      ok := false
                    end;

                    if not ok then
                    begin
                        errorMsg ('Índice inválido: "' + formatExpr (sel^.value) + '" para "' + formatLvalue (lvalue, sel) + '"');
                        break
                    end
                end
            end
        end
    end
end;

{--------------------------------------------------------}
{        processa uma atribuição: lvalue := exp
{--------------------------------------------------------}

procedure doAssignment (lvalue : LvalueRec; exp : Operand);
var
    p   : PSymtbEntry;
    q   : PValueRec;
begin
    p := lvalue.id;
    
    q := getVarAddress (p);

    if q^.iter >= 0 then
        errorMsg ('Tentativa de modificar o iterador ' + lvalue.id^.id)
    else
        recAssignment (lvalue, @q^.exp, exp, lvalue.ind.pobj^.dic.first)
end;

{--------------------------------------------------------}
{              não aplica nenhum operador
{--------------------------------------------------------}

procedure doNOP (var left : Operand; right : Operand);
begin
end;

{--------------------------------------------------------}
{           avalia expressão com operador "="
{--------------------------------------------------------}

procedure doEQ (var left : Operand; right : Operand);
var
    erro, orre, res : integer;
    vdir, vesq      : integer;
begin
    case JOINTYPES (left.typeof, right.typeof) of
        E_UNDEF_UNDEF:          res := 1;
        E_UNDEF_INTEGER,
        E_UNDEF_STRING,
        E_UNDEF_LIST,
        E_UNDEF_DIC,
        E_INTEGER_UNDEF,
        E_STRING_UNDEF,
        E_LIST_UNDEF,
        E_DIC_UNDEF:            res := 0;
        E_INTEGER_INTEGER:      res := ord (left.int = right.int);
        E_INTEGER_STRING:       begin
                                    val (right.pobj^.str, vdir, erro);
                                    if erro = 0 then
                                        res := ord (left.int = vdir)
                                    else
                                        res := ord (IntToStr (left.int) = right.pobj^.str)
                                end;
        E_STRING_STRING:        begin
                                    val (left.pobj^.str, vesq, erro);
                                    val (right.pobj^.str, vdir, orre);
                                    if erro + orre = 0 then
                                        res := ord (vesq = vdir)
                                    else
                                        res := ord (left.pobj^.str = right.pobj^.str)
                                end;
        E_STRING_INTEGER:       begin
                                    val (left.pobj^.str, vesq, erro);
                                    if erro = 0 then
                                        res := ord (vesq = right.int)
                                    else
                                        res := ord (left.pobj^.str = IntToStr (right.int))
                                end;
        E_DIC_DIC:              res := ord (equalDics  (left.pobj^.dic,  right.pobj^.dic));
        E_LIST_LIST:            res := ord (equalLists (left.pobj^.list, right.pobj^.list));
        else                    res := -1
    end;

    freeExpr (left);
    freeExpr (right);

    if res >= 0 then
        initExpr (left, res)
end;

{--------------------------------------------------------}
{           avalia expressão com operador "<>"
{--------------------------------------------------------}

procedure doNE (var left : Operand; right : Operand);
var
    erro, orre, res : integer;
    vdir, vesq      : integer;
begin
    case JOINTYPES (left.typeof, right.typeof) of
        E_UNDEF_UNDEF:          res := 0;
        E_UNDEF_INTEGER,
        E_UNDEF_STRING,
        E_UNDEF_LIST,
        E_UNDEF_DIC,
        E_INTEGER_UNDEF,
        E_STRING_UNDEF,
        E_LIST_UNDEF,
        E_DIC_UNDEF:            res := 1;
        E_INTEGER_INTEGER:      res := ord (left.int <> right.int);
        E_INTEGER_STRING:       begin
                                    val (right.pobj^.str, vdir, erro);
                                    if erro = 0 then
                                        res := ord (left.int <> vdir)
                                    else
                                        res := ord (IntToStr (left.int) <> right.pobj^.str)
                                end;
        E_STRING_STRING:        begin
                                    val (left.pobj^.str, vesq, erro);
                                    val (right.pobj^.str, vdir, orre);
                                    if erro + orre = 0 then
                                        res := ord (vesq <> vdir)
                                    else
                                        res := ord (left.pobj^.str <> right.pobj^.str)
                                end;
        E_STRING_INTEGER:       begin
                                    val (left.pobj^.str, vesq, erro);
                                    if erro = 0 then
                                        res := ord (vesq <> right.int)
                                    else
                                        res := ord (left.pobj^.str <> IntToStr (right.int))
                                end;
        E_DIC_DIC:              res := ord (not equalDics  (left.pobj^.dic,  right.pobj^.dic));
        E_LIST_LIST:            res := ord (not equalLists (left.pobj^.list, right.pobj^.list));
        else                    res := -1
    end;

    freeExpr (left);
    freeExpr (right);

    if res >= 0 then
        initExpr (left, res)
end;

{--------------------------------------------------------}
{           avalia expressão com operador ">"
{--------------------------------------------------------}

procedure doGT (var left : Operand; right : Operand);
var
    erro, orre, res : integer;
    vdir, vesq      : integer;
begin
    case JOINTYPES (left.typeof, right.typeof) of
        E_UNDEF_UNDEF,
        E_UNDEF_INTEGER,
        E_UNDEF_STRING,
        E_UNDEF_LIST,
        E_UNDEF_DIC,
        E_INTEGER_UNDEF,
        E_STRING_UNDEF,
        E_LIST_UNDEF,
        E_DIC_UNDEF:            res := 0;
        E_INTEGER_INTEGER:      res := ord (left.int > right.int);
        E_INTEGER_STRING:       begin
                                    val (right.pobj^.str, vdir, erro);
                                    if erro = 0 then
                                        res := ord (left.int > vdir)
                                    else
                                        res := ord (IntToStr (left.int) > right.pobj^.str)
                                end;
        E_STRING_STRING:        begin
                                    val (left.pobj^.str, vesq, erro);
                                    val (right.pobj^.str, vdir, orre);
                                    if erro + orre = 0 then
                                        res := ord (vesq > vdir)
                                    else
                                        res := ord (left.pobj^.str > right.pobj^.str)
                                end;
        E_STRING_INTEGER:       begin
                                    val (left.pobj^.str, vesq, erro);
                                    if erro = 0 then
                                        res := ord (vesq > right.int)
                                    else
                                        res := ord (left.pobj^.str > IntToStr (right.int))
                                end;
        else                    res := -1
    end;

    freeExpr (left);
    freeExpr (right);

    if res >= 0 then
        initExpr (left, res)
end;

{--------------------------------------------------------}
{           avalia expressão com operador ">="
{--------------------------------------------------------}

procedure doGE (var left : Operand; right : Operand);
var
    erro, orre, res : integer;
    vdir, vesq      : integer;
begin
    case JOINTYPES (left.typeof, right.typeof) of
        E_UNDEF_UNDEF:          res := 1;
        E_UNDEF_INTEGER,
        E_UNDEF_STRING,
        E_UNDEF_LIST,
        E_UNDEF_DIC,
        E_INTEGER_UNDEF,
        E_STRING_UNDEF,
        E_LIST_UNDEF,
        E_DIC_UNDEF:            res := 0;
        E_INTEGER_INTEGER:      res := ord (left.int >= right.int);
        E_INTEGER_STRING:       begin
                                    val (right.pobj^.str, vdir, erro);
                                    if erro = 0 then
                                        res := ord (left.int >= vdir)
                                    else
                                        res := ord (IntToStr (left.int) >= right.pobj^.str)
                                end;
        E_STRING_STRING:        begin
                                    val (left.pobj^.str, vesq, erro);
                                    val (right.pobj^.str, vdir, orre);
                                    if erro + orre = 0 then
                                        res := ord (vesq >= vdir)
                                    else
                                        res := ord (left.pobj^.str >= right.pobj^.str)
                                end;
        E_STRING_INTEGER:       begin
                                    val (left.pobj^.str, vesq, erro);
                                    if erro = 0 then
                                        res := ord (vesq >= right.int)
                                    else
                                        res := ord (left.pobj^.str >= IntToStr (right.int))
                                end;
        else                    res := -1
    end;

    freeExpr (left);
    freeExpr (right);

    if res >= 0 then
        initExpr (left, res)
end;

{--------------------------------------------------------}
{           avalia expressão com operador "<"
{--------------------------------------------------------}

procedure doLT (var left : Operand; right : Operand);
var
    erro, orre, res : integer;
    vdir, vesq      : integer;
begin
    case JOINTYPES (left.typeof, right.typeof) of
        E_UNDEF_UNDEF,
        E_UNDEF_INTEGER,
        E_UNDEF_STRING,
        E_UNDEF_LIST,
        E_UNDEF_DIC,
        E_INTEGER_UNDEF,
        E_STRING_UNDEF,
        E_LIST_UNDEF,
        E_DIC_UNDEF:            res := 0;
        E_INTEGER_INTEGER:      res := ord (left.int < right.int);
        E_INTEGER_STRING:       begin
                                    val (right.pobj^.str, vdir, erro);
                                    if erro = 0 then
                                        res := ord (left.int < vdir)
                                    else
                                        res := ord (IntToStr (left.int) < right.pobj^.str)
                                end;
        E_STRING_STRING:        begin
                                    val (left.pobj^.str, vesq, erro);
                                    val (right.pobj^.str, vdir, orre);
                                    if erro + orre = 0 then
                                        res := ord (vesq < vdir)
                                    else
                                        res := ord (left.pobj^.str < right.pobj^.str)
                                end;
        E_STRING_INTEGER:       begin
                                    val (left.pobj^.str, vesq, erro);
                                    if erro = 0 then
                                        res := ord (vesq < right.int)
                                    else
                                        res := ord (left.pobj^.str < IntToStr (right.int))
                                end;
        else                    res := -1
    end;

    freeExpr (left);
    freeExpr (right);

    if res >= 0 then
        initExpr (left, res)
end;

{--------------------------------------------------------}
{           avalia expressão com operador "<="
{--------------------------------------------------------}

procedure doLE (var left : Operand; right : Operand);
var
    erro, orre, res : integer;
    vdir, vesq      : integer;
begin
    case JOINTYPES (left.typeof, right.typeof) of
        E_UNDEF_UNDEF:          res := 1;
        E_UNDEF_INTEGER,
        E_UNDEF_STRING,
        E_UNDEF_LIST,
        E_UNDEF_DIC,
        E_INTEGER_UNDEF,
        E_STRING_UNDEF,
        E_LIST_UNDEF,
        E_DIC_UNDEF:            res := 0;
        E_INTEGER_INTEGER:      res := ord (left.int <= right.int);
        E_INTEGER_STRING:       begin
                                    val (right.pobj^.str, vdir, erro);
                                    if erro = 0 then
                                        res := ord (left.int <= vdir)
                                    else
                                        res := ord (IntToStr (left.int) <= right.pobj^.str)
                                end;
        E_STRING_STRING:        begin
                                    val (left.pobj^.str, vesq, erro);
                                    val (right.pobj^.str, vdir, orre);
                                    if erro + orre = 0 then
                                        res := ord (vesq <= vdir)
                                    else
                                        res := ord (left.pobj^.str <= right.pobj^.str)
                                end;
        E_STRING_INTEGER:       begin
                                    val (left.pobj^.str, vesq, erro);
                                    if erro = 0 then
                                        res := ord (vesq <= right.int)
                                    else
                                        res := ord (left.pobj^.str <= IntToStr (right.int))
                                end;
        else                    res := -1
    end;

    freeExpr (left);
    freeExpr (right);

    if res >= 0 then
        initExpr (left, res)
end;

{--------------------------------------------------------}
{           avalia expressão com operador "*="
{--------------------------------------------------------}

procedure doSEQ (var left : Operand; right : Operand);
var
    res : integer;

    {--------------------------------------------------------}
    {           verifica se "l" é sufixo de "r"
    {--------------------------------------------------------}

    function suffixString (l, r : string) : integer;
    var
        llen, rlen : integer;
    begin
        llen := length (l);
        rlen := length (r);
        suffixString := ord ((llen >= rlen) and (copy (l, llen - rlen + 1, rlen) = r))
    end;
begin
    case JOINTYPES (left.typeof, right.typeof) of
        E_STRING_STRING:  res := ord (suffixString (left.pobj^.str, right.pobj^.str) >= 1);
        E_LIST_LIST:      res := ord (suffixList (right.pobj^.list, left.pobj^.list) >= 0);
        else              res := -1
    end;

    freeExpr (left);
    freeExpr (right);

    if res >= 0 then
        initExpr (left, res)
end;

{--------------------------------------------------------}
{           avalia expressão com operador "=*"
{--------------------------------------------------------}

procedure doEQS (var left : Operand; right : Operand);
var
    res : integer;
begin
    case JOINTYPES (left.typeof, right.typeof) of
        E_STRING_STRING:  res := ord (pos (right.pobj^.str, left.pobj^.str) = 1);
        E_LIST_LIST:      res := ord ((left.pobj^.list.Count >= right.pobj^.list.Count) and (subList (right.pobj^.list, left.pobj^.list) = 0));
        else              res := -1
    end;

    freeExpr (left);
    freeExpr (right);

    if res >= 0 then
        initExpr (left, res)
end;

{--------------------------------------------------------}
{           avalia expressão com operador "*=*"
{--------------------------------------------------------}

procedure doSEQS (var left : Operand; right : Operand);
var
    res : integer;
begin
    case JOINTYPES (left.typeof, right.typeof) of
        E_STRING_STRING:  res := ord (pos (right.pobj^.str, left.pobj^.str) <> 0);
        E_LIST_LIST:      res := ord ((left.pobj^.list.Count >= right.pobj^.list.Count) and (subList (right.pobj^.list, left.pobj^.list) >= 0));
        else              res := -1
    end;

    freeExpr (left);
    freeExpr (right);

    if res >= 0 then
        initExpr (left, res)
end;

{--------------------------------------------------------}
{           avalia expressão com operador "+"
{--------------------------------------------------------}

procedure doADD (var left : Operand; right : Operand);
var
    erro, orre  : integer;
    l           : TList;
    d           : Dic;
    s           : string;
    vesq, vdir  : integer;
begin
    case JOINTYPES (left.typeof, right.typeof) of
        E_INTEGER_INTEGER:      left.int := left.int + right.int;
        E_INTEGER_STRING:       begin
                                    val (right.pobj^.str, vdir, erro);
                                    if erro = 0 then
                                        left.int := left.int + vdir
                                    else
                                        initExpr (left, IntToStr (left.int) + right.pobj^.str)
                                end;
        E_STRING_STRING:        begin
                                    val (left.pobj^.str, vesq, erro);
                                    val (right.pobj^.str, vdir, orre);
                                    if erro + orre = 0 then
                                    begin
                                        freeExpr (left);
                                        initExpr (left, vesq + vdir)
                                    end
                                    else begin
                                        s := left.pobj^.str + right.pobj^.str;
                                        freeExpr (left);
                                        initExpr (left, s)
                                    end
                                end;
        E_STRING_INTEGER:       begin
                                    val (left.pobj^.str, vesq, erro);
                                    if erro = 0 then
                                    begin
                                        freeExpr (left);
                                        initExpr (left, vesq + right.int)
                                    end
                                    else begin
                                        s := left.pobj^.str + IntToStr (right.int);
                                        freeExpr (left);
                                        initExpr (left, s)
                                    end
                                end;
        E_DIC_DIC:              begin
                                    concatDics (d, left.pobj^.dic, right.pobj^.dic);
                                    freeExpr (left);
                                    initExpr (left, d)
                                end;
        E_LIST_LIST:            begin
                                    concatLists (l, left.pobj^.list, right.pobj^.list);
                                    freeExpr (left);
                                    initExpr (left, l)
                                end;
        else                    freeExpr (left);
    end;

    freeExpr (right)
end;

{--------------------------------------------------------}
{           avalia expressão com operador "-"
{--------------------------------------------------------}

procedure doSUB (var left : Operand; right : Operand);
var
    erro, orre  : integer;
    l           : TList;
    d           : Dic;
    vesq, vdir  : integer;
begin
    vesq := left.int; vdir := right.int;

    case JOINTYPES (left.typeof, right.typeof) of
        E_INTEGER_INTEGER:      erro := 0;
        E_INTEGER_STRING:       begin
                                    val (right.pobj^.str, vdir, erro);
                                    freeExpr (right)
                                end;
        E_STRING_STRING:        begin
                                    val (left.pobj^.str, vesq, erro);
                                    val (right.pobj^.str, vdir, orre);
                                    erro := erro + orre;
                                    freeExpr (left);
                                    freeExpr (right)
                                end;
        E_STRING_INTEGER:       begin
                                    val (left.pobj^.str, vesq, erro);
                                    freeExpr (left)
                                end;
        E_DIC_DIC:              begin
                                    dicDifference (d, left.pobj^.dic, right.pobj^.dic);
                                    freeExpr (left);
                                    freeExpr (right);
                                    initExpr (left, d);
                                    exit
                                end;
        E_LIST_LIST:            begin
                                    listDifference (l, left.pobj^.list, right.pobj^.list);
                                    freeExpr (left);
                                    freeExpr (right);
                                    initExpr (left, l);
                                    exit
                                end;
        else                    begin
                                    freeExpr (left);
                                    freeExpr (right);
                                    exit
                                end
    end;

    if erro <> 0 then
        invalidateExpr (left)
    else
        initExpr (left, vesq - vdir)
end;

{--------------------------------------------------------}
{           avalia expressão com operador "*"
{--------------------------------------------------------}

procedure doMUL (var left : Operand; right : Operand);
var
    erro, orre  : integer;
    l           : TList;
    d           : Dic;
    vesq, vdir  : integer;
begin
    vesq := left.int; vdir := right.int;

    case JOINTYPES (left.typeof, right.typeof) of
        E_INTEGER_INTEGER:      erro := 0;
        E_INTEGER_STRING:       begin
                                    val (right.pobj^.str, vdir, erro);
                                    freeExpr (right)
                                end;
        E_STRING_STRING:        begin
                                    val (left.pobj^.str, vesq, erro);
                                    val (right.pobj^.str, vdir, orre);
                                    erro := erro + orre;
                                    freeExpr (left);
                                    freeExpr (right)
                                end;
        E_STRING_INTEGER:       begin
                                    val (left.pobj^.str, vesq, erro);
                                    freeExpr (left)
                                end;
        E_DIC_DIC:              begin
                                    dicIntersection (d, left.pobj^.dic, right.pobj^.dic);
                                    freeExpr (left);
                                    freeExpr (right);
                                    initExpr (left, d);
                                    exit
                                end;
        E_LIST_LIST:            begin
                                    listIntersection (l, left.pobj^.list, right.pobj^.list);
                                    freeExpr (left);
                                    freeExpr (right);
                                    initExpr (left, l);
                                    exit
                                end;
        else                    begin
                                    freeExpr (left);
                                    freeExpr (right);
                                    exit
                                end
    end;

    if erro <> 0 then
        invalidateExpr (left)
    else
        initExpr (left, vesq * vdir)
end;

{--------------------------------------------------------}
{           avalia expressão com operador "/"
{--------------------------------------------------------}

procedure doDIV (var left : Operand; right : Operand);
var
    erro, orre : integer;
    vesq, vdir  : integer;
begin
    vesq := left.int; vdir := right.int;

    case JOINTYPES (left.typeof, right.typeof) of
        E_INTEGER_INTEGER:      erro := 0;
        E_INTEGER_STRING:       begin
                                    val (right.pobj^.str, vdir, erro);
                                    freeExpr (right)
                                end;
        E_STRING_STRING:        begin
                                    val (left.pobj^.str, vesq, erro);
                                    val (right.pobj^.str, vdir, orre);
                                    erro := erro + orre;
                                    freeExpr (left);
                                    freeExpr (right)
                                end;
        E_STRING_INTEGER:       begin
                                    val (left.pobj^.str, vesq, erro);
                                    freeExpr (left)
                                end;
        else                    begin
                                    freeExpr (left);
                                    freeExpr (right);
                                    exit
                                end
    end;

    if erro <> 0 then
    begin
        invalidateExpr (left)
    end
    else begin
        if vdir = 0 then
        begin
            errorMsg ('Divisão por ZERO evitada');
            vdir := 1
        end;

        initExpr (left, vesq div vdir)
    end
end;

{--------------------------------------------------------}
{           avalia expressão com operador "%"
{--------------------------------------------------------}

procedure doMOD (var left : Operand; right : Operand);
var
    erro, orre : integer;
    vesq, vdir  : integer;
begin
    vesq := left.int; vdir := right.int;

    case JOINTYPES (left.typeof, right.typeof) of
        E_INTEGER_INTEGER:      erro := 0;
        E_INTEGER_STRING:       begin
                                    val (right.pobj^.str, vdir, erro);
                                    freeExpr (right)
                                end;
        E_STRING_STRING:        begin
                                    val (left.pobj^.str, vesq, erro);
                                    val (right.pobj^.str, vdir, orre);
                                    erro := erro + orre;
                                    freeExpr (left);
                                    freeExpr (right)
                                end;
        E_STRING_INTEGER:       begin
                                    val (left.pobj^.str, vesq, erro);
                                    freeExpr (left)
                                end;    
        else                    begin
                                    freeExpr (left);
                                    freeExpr (right);
                                    exit
                                end
    end;

    if erro <> 0 then
    begin
        invalidateExpr (left)
    end
    else begin
        if vdir = 0 then
        begin
            errorMsg ('Divisão por ZERO evitada');
            vdir := 1
        end;

        initExpr (left, vesq mod vdir)
    end
end;

{--------------------------------------------------------}
{           avalia expressão com operador "^"
{--------------------------------------------------------}

procedure doPOT (var left : Operand; right : Operand);
var
    erro, orre, i  : integer;
    v              : int64;
    vesq, vdir     : integer;
begin
    vesq := left.int; vdir := right.int;

    case JOINTYPES (left.typeof, right.typeof) of
        E_INTEGER_INTEGER:      erro := 0;
        E_INTEGER_STRING:       begin
                                    val (right.pobj^.str, vdir, erro);
                                    freeExpr (right)
                                end;
        E_STRING_STRING:        begin
                                    val (left.pobj^.str, vesq, erro);
                                    val (right.pobj^.str, vdir, orre);
                                    erro := erro + orre;
                                    freeExpr (left);
                                    freeExpr (right)
                                end;
        E_STRING_INTEGER:       begin
                                    val (left.pobj^.str, vesq, erro);
                                    freeExpr (left)
                                end;
        else                    begin
                                    freeExpr (left);
                                    freeExpr (right);
                                    exit
                                end
    end;

    if erro <> 0 then
    begin
        invalidateExpr (left)
    end
    else begin
        v := 1;
        for i := 1 to vdir do
            v := v * vesq;

        if (v < -2147483648) or (v > 2147483647) then
        begin
            errorMsg ('Estouro durante potenciação');
            invalidateExpr (left)
        end
        else begin
            initExpr (left, Integer (v))
        end
    end
end;

{--------------------------------------------------------}
{         transforma uma expressão em número
{--------------------------------------------------------}

function numberize (exp : Operand) : integer;
var
    val : integer;
begin
    val := 0;

    case exp.typeof of
        E_INTEGER:  val := exp.int;
        E_STRING:   val := length (exp.pobj^.str);
        E_RANGE:    val := Abs (exp.high - exp.low) + 1;
        E_DIC:      val := exp.pobj^.dic.card;
        E_LIST:     val := exp.pobj^.list.Count
    end;

    numberize := ord (val <> 0)
end;

{--------------------------------------------------------}
{           avalia expressão com operador "ou"
{--------------------------------------------------------}

procedure doOR (var left : Operand; right : Operand);
var
    res : integer;
begin
    if (left.typeof = E_INVAL) or (right.typeof = E_INVAL) then
    begin
        freeExpr (right);
        invalidateExpr (left)
    end
    else begin
        res := numberize (left) or numberize (right);

        freeExpr (left);
        freeExpr (right);

        initExpr (left, res)
    end
end;

{--------------------------------------------------------}
{           avalia expressão com operador "e"
{--------------------------------------------------------}

procedure doAND (var left : Operand; right : Operand);
var
    res : integer;
begin
    if (left.typeof = E_INVAL) or (right.typeof = E_INVAL) then
    begin
        freeExpr (right);
        invalidateExpr (left)
    end
    else begin
        res := numberize (left) and numberize (right);

        freeExpr (left);
        freeExpr (right);

        initExpr (left, res)
    end
end;

{--------------------------------------------------------}
{           avalia expressão com operador ".."
{--------------------------------------------------------}

procedure doTO (var left : Operand; right : Operand);
begin
    if (left.typeof = E_INTEGER) and (right.typeof = E_INTEGER) then
    begin
        left.typeof := E_RANGE;
        left.low    := left.int;
        left.high   := right.int
    end
    else begin
        freeExpr (left);
        freeExpr (right)
    end
end;

{--------------------------------------------------------}
{           avalia expressão com operador "||"
{--------------------------------------------------------}

procedure doSIZE (var left : Operand);
var
    res : integer;
begin
    case left.typeof of
        E_INTEGER:  res := abs (left.int);
        E_STRING:   res := length (left.pobj^.str);
        E_DIC:      res := left.pobj^.dic.card;
        E_LIST:     res := left.pobj^.list.count;
        else        res := -1
    end;

    freeExpr (left);

    if res >= 0 then
        initExpr (left, res)
end;

{--------------------------------------------------------}
{       avalia expressão com operador "-" unário
{--------------------------------------------------------}

procedure doMUN (var left : Operand);
var
    s    : string;
    i    : integer;
    aux  : Pointer;
    xau  : Operand;
    v    : real;
    code : integer;
begin
    case left.typeof of
        E_INTEGER:  left.int := -left.int;
        E_STRING:   begin
                        val (left.pobj^.str, v, code); if v = 0 then; //Somente para usar o v

                        if code = 0 then
                        begin
                            s := '-' + left.pobj^.str
                        end
                        else begin
                            s := '';
                            for i := length (left.pobj^.str) downto 1 do
                                s := s + left.pobj^.str[i];
                        end;

                        freeExpr (left);
                        initExpr (left, s)
                    end;
        E_LIST:     begin
                        duplicateExpr (xau, left);
                        freeExpr (left);
                        left := xau;          { copyExpr (left, xau); freeExpr (xau); }

                        with left.pobj^.list do
                        begin
                            for i := 0 to Count div 2 do
                            begin
                                aux := Items[i];
                                Items[i] := Items[Count - i - 1];
                                Items[Count - i - 1] := aux
                            end
                        end
                    end;
        else        freeExpr (left)
    end
end;

{--------------------------------------------------------}
{                obtém o operador
{--------------------------------------------------------}

function obtemOperador (left : Operand) : OperatorType;
begin
    obtemOperador := C_NOP;

    if token.typeof = T_OP then
    begin
        obtemOperador := token.op
    end
    else if (token.typeof = T_ID) and (not verbose or (left.typeof = E_INTEGER) and (left.int in [0,1])) then
    begin
        if      token.id = 'E'  then obtemOperador := C_AND
        else if token.id = 'OU' then obtemOperador := C_OR
    end
end;

{--------------------------------------------------------}
{       avalia uma subexpressão de certa precedência
{--------------------------------------------------------}

procedure internalEvalExpr (var left : Operand; precedence : integer);
var
    stop  : boolean;
    op    : OperatorType;
    right : Operand;
begin
    with operatorTable[precedence] do
    begin
        if feasible = [] then
        begin
            getOperand (left)
        end
        else begin
            internalEvalExpr (left, precedence + 1);

            stop := not multiple;

            repeat
                op := obtemOperador (left);

                if op in feasible then
                begin
                    nextToken;
                    invalidateExpr (right);
                    internalEvalExpr (right, precedence + 1);

                    if compiling then
                    begin
                        freeExpr (right)
                    end
                    else begin
                        operate[op] (left, right)    { "left" := "left" "op" "right" }
                    end
                end
                else begin
                    stop := true
                end
            until stop
        end
    end
end;

{========================================================}
{ ============== FUNÇÕES PARA EXPRESSÕES =============== }
{========================================================}

{--------------------------------------------------------}
{            ignora uma expressão, sem avaliar
{--------------------------------------------------------}

procedure skipExpr;
var
    exp   : Operand;
    salva : boolean;
begin
    salva   := verbose;
    verbose := false;

    invalidateExpr (exp);
    internalEvalExpr (exp, 1);     { Avalia a expressão quietinho, em silêncio }
    freeExpr (exp);

    verbose := salva
end;

procedure evalExpr (var exp : Operand); overload;
begin
    invalidateExpr (exp);
    internalEvalExpr (exp, 1)
end;

{--------------------------------------------------------}
{      avalia uma expressão, convertendo o resultado
{--------------------------------------------------------}

procedure evalExpr (var exp : Operand; t : OperandType); overload;
begin
    invalidateExpr (exp);

    if t = E_RANGE then
    begin
        internalEvalExpr (exp, 0);        { Inclui o operador .. }
        exit
    end;

    internalEvalExpr (exp, 1);

    if (exp.typeof <> E_INVAL) and (exp.typeof <> t) then
    begin
        if t = E_INTEGER then
            convertToInteger (exp)
        else if t = E_STRING then
            convertToString (exp)
    end
end;

{--------------------------------------------------------}
{         inicializa uma expressão, dado o tipo
{--------------------------------------------------------}

procedure initExpr (var exp : Operand; t : OperandType);  overload;
begin
    exp.typeof := t;

    case t of
        E_INTEGER:  exp.int := 0;
        E_STRING,
        E_DIC,
        E_LIST:     begin
                        exp.pobj := allocObjNode;

                        if exp.pobj = NIL then
                        begin
                            invalidateExpr (exp)
                        end
                        else begin
                            if t = E_LIST then
                                initList (exp.pobj^.list)
                            else if t = E_DIC then
                                initDic (exp.pobj^.dic)
                            else
                                exp.pobj^.str := ''
                        end
                    end
    end
end;

{--------------------------------------------------------}
{       inicializa uma expressão com valor inteiro
{--------------------------------------------------------}

procedure initExpr (var exp : Operand; i : integer);  overload;
begin
    exp.typeof := E_INTEGER;
    exp.int    := i
end;

{--------------------------------------------------------}
{       inicializa uma expressão com valor cadeia
{--------------------------------------------------------}

procedure initExpr (var exp : Operand; s : string); overload;
begin
    exp.pobj := allocObjNode;

    if exp.pobj = NIL then
    begin
        invalidateExpr (exp)
    end
    else begin
        exp.typeof    := E_STRING;
        exp.pobj^.str := s
    end
end;

{--------------------------------------------------------}
{       inicializa uma expressão com valor lista
{--------------------------------------------------------}

procedure initExpr (var exp : Operand; l : TList); overload;
begin
    exp.pobj := allocObjNode;

    if exp.pobj = NIL then
    begin
        invalidateExpr (exp)
    end
    else begin
        exp.typeof     := E_LIST;
        exp.pobj^.list := l
    end
end;

procedure initExpr (var exp : Operand; l : TStringList); overload;
var
    i   : integer;
    val : Operand;
begin
    initExpr (exp, E_LIST);

    if exp.typeof = E_LIST then
    begin
        for i := 0 to l.Count - 1 do
        begin
            initExpr (val, l[i]);
            modifyList (exp.pobj^.list, val);
            freeExpr (val)
        end
    end
end;

{--------------------------------------------------------}
{      inicializa uma expressão com valor dicionário
{--------------------------------------------------------}

procedure initExpr (var exp : Operand; d : Dic); overload;
begin
    exp.pobj := allocObjNode;

    if exp.pobj = NIL then
    begin
        invalidateExpr (exp)
    end
    else begin
        exp.typeof    := E_DIC;
        exp.pobj^.dic := d
    end
end;

{--------------------------------------------------------}
{      inicializa uma expressão com tipo inválido
{--------------------------------------------------------}

procedure invalidateExpr (var exp : Operand);
begin
    exp.typeof := E_INVAL
end;

{--------------------------------------------------------}
{                 copia uma expressão
{--------------------------------------------------------}

procedure copyExpr (var from : Operand; _to : Operand);
begin
    from := _to;

    if _to.typeof in [E_STRING,E_DIC,E_LIST] then
    begin
        if _to.pobj = NIL then
            scWriteln ('copyExpr: erro grave (de.pobj = NIL)')
        else
            INC (_to.pobj^.nref)
    end
end;

{--------------------------------------------------------}
{                duplica uma expressão
{--------------------------------------------------------}

procedure duplicateExpr (var from : Operand; _to : Operand);
var
    d : Dic;
    l : TList;

    procedure dupDic (var from : Dic; _to : Dic);
    var
        p        : PDicNode;
        key, aux : Operand;
    begin
        initDic (from);

        p := _to.first;
        while p <> NIL do
        begin
            initExpr (key,  p^.key);
            duplicateExpr (aux, p^.value);
            modifyDic (from, key, aux);
            freeExpr (aux);
            freeExpr (key);
            p := p^.next
        end
    end;

    procedure dupList (var from : TList; _to : TList);
    var
        i    : integer;
        aux  : Operand;
    begin
        initList (from);

        for i := 0 to _to.Count - 1 do
        begin
            if _to.Items[i] <> NIL then
            begin
                duplicateExpr (aux, POperand (_to.Items[i])^);
                modifyList (from, aux);
                freeExpr (aux)
            end
        end
    end;

begin
    case _to.typeof of
        E_STRING:   begin
                        initExpr (from, _to.pobj^.str)
                    end;
        E_DIC:      begin
                        dupDic (d, _to.pobj^.dic);
                        initExpr (from, d)
                    end;
        E_LIST:     begin
                        dupList (l, _to.pobj^.list);
                        initExpr (from, l)
                    end;
        else        begin
                        from := _to
                    end
    end
end;

{--------------------------------------------------------}
{     converte, se possível, uma expressão para inteiro
{--------------------------------------------------------}

function convertToInteger (var exp : Operand) : OperandType;
var
    v, erro : integer;
begin
    if exp.typeof = E_STRING then
    begin
        val (exp.pobj^.str, v, erro);

        freeExpr (exp);

        if erro = 0 then
            initExpr (exp, v)
        else
            invalidateExpr (exp)
    end;

    convertToInteger := exp.typeof
end;

function convertToInteger (exp : Operand; var nexp : Operand) : OperandType; overload;
var
    v, error : integer;
begin
    if exp.typeof = E_STRING then
    begin
        val (exp.pobj^.str, v, error);

        if error = 0 then
            initExpr (nexp, v)
        else
            invalidateExpr (nexp)
    end;

    convertToInteger := nexp.typeof
end;

{--------------------------------------------------------}
{         converte uma expressão para cadeia
{--------------------------------------------------------}

function convertToString (var exp : Operand) : OperandType;
var
    s : string;
begin
    if exp.typeof = E_INVAL then
    begin
        convertToString := E_INVAL;
        exit
    end;
    
    s := formatExpr (exp);

    freeExpr (exp);
    initExpr (exp, s);

    convertToString := exp.typeof
end;

{--------------------------------------------------------}
{               libera uma expressão
{--------------------------------------------------------}

procedure freeExpr (var exp : Operand);
begin
    if exp.typeof in [E_STRING,E_DIC,E_LIST] then
    begin
        if exp.pobj = NIL then
        begin
            scWriteln ('Erro GRAVE: pobj = NIL');
            exit
        end;

        with exp.pobj^ do
        begin
            if nref > 0 then
            begin
                DEC (nref);

                if nref = 0 then
                begin
                    if exp.typeof = E_DIC then
                        emptyDic (dic)
                    else if exp.typeof = E_LIST then
                        emptyList (list)
                    else
                        str := '';

                    freeObjNode (exp.pobj);
                    exp.pobj := NIL
                end
            end
            else begin
                scWriteln ('Erro GRAVE: liberando expressão com nref = 0!');
                readln
            end
        end
    end;

    invalidateExpr (exp)
end;

{--------------------------------------------------------}
{         formata uma expressão em uma cadeia
{--------------------------------------------------------}

function formatExpr (exp : Operand) : string;
var
    p : PDicNode;
    s : string;
    i : integer;

    function formatString (s : string) : string;
    var
        r : string;
        i : integer;
        c : char;
    begin
        r := '';

        for i := 1 to length (s) do
        begin
            c := s[i];
            if (c = '"') then
                r := r + '"';
            r := r + c
        end;

        formatString := r
    end;
begin
    case exp.typeof of
        E_INVAL:        formatExpr := 'inválido';
        E_UNDEF:        formatExpr := 'indefinido';
        E_INTEGER:      formatExpr := IntToStr (exp.int);
        E_STRING:       formatExpr := exp.pobj^.str;
        E_RANGE:        formatExpr := '[' + IntToStr (exp.low) + ':' + IntToStr (exp.high) + ']';
        E_DIC:          begin
                            s := '{';
                            p := exp.pobj^.dic.first;

                            while p <> NIL do
                            begin
                                s := s + '"' + p^.key + '" : ';

                                if p^.value.typeof = E_STRING then
                                    s := s + '"' + formatString (p^.value.pobj^.str) + '"'
                                else
                                    s := s + formatExpr (p^.value);

                                p := p^.next;
                                if p <> NIL then s := s + ', '
                            end;

                            formatExpr := s + '}'
                        end;
        E_LIST:         begin
                            s := '[';

                            with exp.pobj^ do
                            begin
                                for i := 0 to list.count - 1 do
                                begin
                                    if list.Items[i] = NIL then
                                        s := s + '?'
                                    else
                                        s := s + formatExpr (POperand (list.Items[i])^);

                                    if i < list.count - 1 then s := s + ', '
                                end
                            end;

                            formatExpr := s + ']'
                        end
    end
end;

{--------------------------------------------------------}
{       verifica se duas expressões são iguaizinhas
{--------------------------------------------------------}

function equalExprs (e, f : Operand) : boolean;
begin
    equalExprs := false;

    if e.typeof <> f.typeof then exit;

    case e.typeof of
        E_UNDEF:    equalExprs := true;
        E_INTEGER:  equalExprs := e.int = f.int;
        E_STRING:   equalExprs := e.pobj^.str = f.pobj^.str;
        E_RANGE:    equalExprs := (e.low = f.low) and (e.high = f.high);
        E_DIC:      equalExprs := equalDics (e.pobj^.dic, f.pobj^.dic);
        E_LIST:     equalExprs := equalLists (e.pobj^.list, f.pobj^.list)
    end
end;

{========================================================}
{ ============= FUNÇÕES PARA DICIONÁRIOS =============== }
{========================================================}

{--------------------------------------------------------}
{                gera o dicionário vazio
{--------------------------------------------------------}

procedure initDic (var l : Dic);
begin
    l.card := 0;
    l.first := NIL
end;

{--------------------------------------------------------}
{                esvazia um dicionário
{--------------------------------------------------------}

procedure emptyDic (var l : Dic);
var
    p, q : PDicNode;
begin
    p := l.first;

    while p <> NIL do
    begin
        q := p^.next;

        p^.key  := '';
        p^.next := NIL;        { Para evitar rastros espúrios }

        freeExpr (p^.value);

        freeNode (p, E_DIC);
        p := q
    end;

    l.card := 0;
    l.first := NIL
end;

{--------------------------------------------------------}
{   verifica se o dicionário "l" está contido em "m"
{--------------------------------------------------------}

function subDic (l, m : Dic) : boolean;
var
    p    : PDicNode;
    sub  : boolean;
    aux  : Operand;
begin
    sub  := true;

    p    := l.first;

    while sub and (p <> NIL) do
    begin
        queryDic (m, p^.key, aux);

        if aux.typeof <> p^.value.typeof then
        begin
            sub := false
        end
        else begin
            case aux.typeof of
                E_INTEGER:   sub := aux.int = p^.value.int;
                E_STRING:    sub := aux.pobj^.str = p^.value.pobj^.str;
                E_DIC:       sub := equalDics (aux.pobj^.dic, p^.value.pobj^.dic);
                E_LIST:      sub := equalLists (aux.pobj^.list, p^.value.pobj^.list);
                else         sub := false
            end
        end;

        freeExpr (aux);

        p := p^.next
    end;

    subDic := sub
end;

{--------------------------------------------------------}
{       verifica se dois dicionários são iguais
{--------------------------------------------------------}

function equalDics (l, m : Dic) : boolean;
begin
    equalDics := (l.card = m.card) and subDic (l, m)
end;

{--------------------------------------------------------}
{            busca um valor em um dicionário
{--------------------------------------------------------}

function findDicValue (l : Dic; val : Operand) : PDicNode;
var
    p : PDicNode;
begin
    findDicValue := NIL;

    p := l.first;
    while p <> NIL do
    begin
        if equalExprs (p^.value, val) then
        begin
            findDicValue := p;
            exit
        end;

        p := p^.next
    end
end;

{--------------------------------------------------------}
{         consulta o dicionário, dada a chave
{--------------------------------------------------------}

procedure queryDic (var l : Dic; key : string; var valor : Operand); overload;
var
    q : POperand;
begin
    q := findDicKey (l, key, false);

    if q = NIL then
        initExpr (valor, E_UNDEF)
    else
        copyExpr (valor, q^)
end;

procedure queryDic (var l : Dic; key : integer; var valor : Operand); overload;
begin
    queryDic (l, IntToStr (key), valor)
end;

procedure queryDic (var l : Dic; key : Operand; var valor : Operand); overload;
var
    p    : PDicNode;
    aux  : Operand;
    i    : integer;
begin
    case key.typeof of
        E_INVAL,
        E_UNDEF:        invalidateExpr (valor);
        E_INTEGER:      queryDic (l, key.int, valor);
        E_STRING:       queryDic (l, key.pobj^.str, valor);
        E_RANGE:        begin
                            initExpr (valor, E_DIC);

                            if key.low <= key.high then
                            begin
                                for i := key.low to key.high do
                                begin
                                    queryDic (l, i, aux);
                                    modifyDic (valor.pobj^.dic, i, aux);
                                    freeExpr (aux)
                                end
                            end
                            else begin
                                for i := key.low downto key.high do
                                begin
                                    queryDic (l, i, aux);
                                    modifyDic (valor.pobj^.dic, i, aux);
                                    freeExpr (aux)
                                end
                            end
                        end;
        E_DIC:          begin
                            initExpr (valor, E_DIC);

                            p := key.pobj^.dic.first;
                            while p <> NIL do
                            begin
                                queryDic (l, p^.value, aux);
                                modifyDic (valor.pobj^.dic, p^.value, aux);
                                freeExpr (aux);

                                p := p^.next
                            end
                        end;
        E_LIST:         begin
                            initExpr (valor, E_DIC);

                            with key.pobj^ do
                            begin
                                for i := 0 to list.Count - 1 do
                                begin
                                    if list.Items[i] <> NIL then
                                    begin
                                        queryDic (l, POperand (list.Items[i])^, aux);
                                        modifyDic (valor.pobj^.dic, POperand (list.Items[i])^, aux);
                                        freeExpr (aux)
                                    end
                                end
                            end
                        end
    end
end;

{--------------------------------------------------------}
{          pesquisa uma chave em um dicionário
{--------------------------------------------------------}

function findDicKey (var l : Dic; key : string; create : boolean) : POperand; overload;
var
    q  : ^PDicNode;
begin
    q := @l.first;        { Ponteiro duplo! }

    while q^ <> NIL do
    begin
        if key = q^^.key then
        begin
            findDicKey := @q^^.value;
            exit
        end;

        q := @q^^.next
    end;

    if not create then
    begin
        findDicKey := NIL;
        exit
    end;

    { Cria o elemento do dicionário que está faltando, com a chave dada }

    q^ := allocNode (E_DIC);      { O ponteiro q^^.prox já vem com NIL }

    if q^ = NIL then
    begin
        findDicKey := NIL;
        exit
    end;

    INC (l.card);

    q^^.key := key;
    invalidateExpr (q^^.value);

    findDicKey := @q^^.value
end;

function findDicKey (var l : Dic; key : integer; create : boolean) : POperand; overload;
begin
    findDicKey := findDicKey (l, IntToStr (key), create)
end;

function findDicKey (var l : Dic; key : Operand; create : boolean) : POperand; overload;
begin
    if key.typeof = E_STRING then
        findDicKey := findDicKey (l, key.pobj^.str, create)
    else if key.typeof = E_INTEGER then
        findDicKey := findDicKey (l, key.int, create)
    else
        findDicKey := NIL;
end;

{--------------------------------------------------------}
{     modifica o dado correspondente a uma chave
{--------------------------------------------------------}

procedure modifyDic (var d : Dic; key : string; value : Operand); overload;
var
    q : POperand;
begin
    if value.typeof = E_INVAL then exit;

    q := findDicKey (d, key, true);
    if q = NIL then exit;

    freeExpr (q^);
    copyExpr (q^, value)
end;

procedure modifyDic (var d : Dic; key : integer; value : Operand); overload;
begin
    modifyDic (d, IntToStr (key), value)
end;

procedure modifyDic (var d : Dic; key, value : Operand);
var
    p  : PDicNode;
    q  : POperand;
    i  : integer;
begin
    if value.typeof = E_INVAL then exit;

    case key.typeof of
        E_INVAL,
        E_UNDEF:        ;
        E_INTEGER,
        E_STRING:       begin
                            q := findDicKey (d, key, true);
                            if q = NIL then exit;

                            freeExpr (q^);
                            copyExpr (q^, value)
                        end;
        E_RANGE:        begin
                            for i := Min (key.low, key.high) to Max (key.low, key.high) do
                                modifyDic (d, i, value)
                        end;
        E_DIC:          begin
                            p := key.pobj^.dic.first;

                            while p <> NIL do
                            begin
                                modifyDic (d, p^.value, value);
                                p := p^.next
                            end
                        end;
        E_LIST:         with key.pobj^.list do
                        begin
                            for i := 0 to Count - 1 do
                            begin
                                if Items[i] <> NIL then
                                    modifyDic (d, POperand (Items[i])^, value)
                            end
                        end
    end
end;

{--------------------------------------------------------}
{         remove um par do dicionário, dada a chave
{--------------------------------------------------------}

procedure removeDic (var d : Dic; key : Operand; var value : Operand);
var
    q  : ^PDicNode;
    p  : PDicNode;
    s  : string;
begin
    if key.typeof = E_STRING then
        s := key.pobj^.str
    else if key.typeof = E_INTEGER then
        s := IntToStr (key.int)
    else
        exit;

    invalidateExpr (value);

    q  := @d.first;              { Ponteiro duplo! }

    while q^ <> NIL do
    begin
        if s = q^^.key then
            break;

        q := @q^^.next
    end;

    p := q^;

    if p = NIL then exit;

    value := p^.value;           { copyExpr (value, p^.value); freeExpr (p^.value); }

    q^ := q^^.next;
    DEC (d.card);

    freeNode (p, E_DIC)
end;

{--------------------------------------------------------}
{         concatena "d" e "e", gerando "r"
{--------------------------------------------------------}

procedure concatDics (var r : Dic; d, e : Dic);
var
    p : PDicNode;
begin
    initDic (r);

    p := d.first;
    while p <> NIL do
    begin
        modifyDic (r, p^.key, p^.value);
        p := p^.next
    end;

    p := e.first;
    while p <> NIL do
    begin
        modifyDic (r, p^.key, p^.value);
        p := p^.next
    end
end;

{--------------------------------------------------------}
{         incorpora um dicionário a outro
{--------------------------------------------------------}

procedure appendDic (var v : Dic; aux : Dic);
var
    p : PDicNode;
begin
    p := aux.first;
    while p <> NIL do
    begin
        modifyDic (v, p^.key, p^.value);
        p := p^.next
    end
end;

{--------------------------------------------------------}
{      computa a diferença entre dois dicionários
{--------------------------------------------------------}

procedure dicDifference (var r : Dic; d, e : Dic);
var
    p, q : PDicNode;
begin
    initDic (r);

    p := d.first;
    while p <> NIL do
    begin
        q := findDicValue (e, p^.value);
        if (q = NIL) or (p^.key <> q^.key) then
            modifyDic (r, p^.key, p^.value);
        p := p^.next
    end
end;

{--------------------------------------------------------}
{      computa a interseção entre dois dicionários
{--------------------------------------------------------}

procedure dicIntersection (var r : Dic; d, e : Dic);
var
    p, q : PDicNode;
begin
    initDic (r);

    p := d.first;
    while p <> NIL do
    begin
        q := findDicValue (e, p^.value);
        if (q <> NIL) and (p^.key = q^.key) then
            modifyDic (r, p^.key, p^.value);
        p := p^.next
    end
end;

{--------------------------------------------------------}
{         remove o último elemento do dicionário
{--------------------------------------------------------}

procedure removeLastIndexer (var exp : Operand; var d : Dic);
var
    p, q  : PDicNode;
    i     : integer;
begin
    if d.card = 1 then
    begin
        copyExpr (exp, d.first.value);
        emptyDic (d)
    end
    else begin
        p := d.first;

        for i := 0 to d.card - 3 do
            p := p^.next;

        q := p^.next; p^.next := NIL;

        DEC (d.card);

        exp := q^.value;      { copyExpr (exp, q^.value); freeExpr (q^.value); }
        freeNode (q, E_DIC)
    end
end;

{--------------------------------------------------------}
{           coleta as chaves de um dicionário
{--------------------------------------------------------}

function dicKeys (d : Dic) : TList;
var
    l   : TList;
    p   : PDicNode;
    exp : POperand;
begin
    l := TList.Create;

    p := d.first;

    while p <> NIL do
    begin
        exp := allocNode (E_LIST);

        if exp <> NIL then
        begin
            initExpr (exp^, p^.key);
            l.Add (exp)
        end;

        p := p^.next
    end;

    dicKeys := l
end;

{========================================================}
{ =============== FUNÇÕES PARA LISTAS ===================
{========================================================}

{--------------------------------------------------------}
{         inicializa a lista vazia
{--------------------------------------------------------}

procedure initList (var l : TList);
begin
    l := TList.Create
end;

{--------------------------------------------------------}
{         esvazia uma lista
{--------------------------------------------------------}

procedure emptyList (var l : TList);
var
    i : integer;
begin
    for i := 0 to l.Count - 1 do
    begin
        freeExpr (POperand (l.Items[i])^);
        freeNode (l.Items[i], E_LIST);
        l.Items[i] := NIL
    end;

    l.Free
end;

{--------------------------------------------------------}
{          verifica se "l" é sublista de "m"
{--------------------------------------------------------}

function subList (l, m : TList) : integer;
var
    p, i  : integer;
begin
    subList := -1;

    if l.Count > m.Count then exit;

    for p := 0 to m.Count - l.Count do
    begin
        for i := 0 to l.Count - 1 do
        begin
            if (l.Items[i] =  NIL) and (m.Items[p + i] <> NIL) or
               (l.Items[i] <> NIL) and (m.Items[p + i] =  NIL) then
               break;
            if (l.Items[i] <> NIL) and (m.Items[p + i] <> NIL) and
                not equalExprs (POperand (l.Items[i])^, POperand (m.Items[p + i])^) then
                    break
        end;

        if i >= l.Count then
        begin
            subList := p;
            exit
        end
    end
end;

{--------------------------------------------------------}
{          verifica se "l" é sufixo de "m"
{--------------------------------------------------------}

function suffixList (l, m : TList) : integer;
var
    p, i  : integer;
begin
    suffixList := -1;

    if l.Count > m.Count then exit;

    for p := m.Count - l.Count to m.Count - 1 do
    begin
        for i := 0 to l.Count - 1 do
        begin
            if (l.Items[i] =  NIL) and (m.Items[p + i] <> NIL) or
               (l.Items[i] <> NIL) and (m.Items[p + i] =  NIL) then
               break;
            if (l.Items[i] <> NIL) and (m.Items[p + i] <> NIL) and
                not equalExprs (POperand (l.Items[i])^, POperand (m.Items[p + i])^) then
                    break
        end;

        if i >= l.Count then
        begin
            suffixList := p;
            exit
        end
    end
end;

{--------------------------------------------------------}
{          verifica se duas listas são iguais
{--------------------------------------------------------}

function equalLists (l, m : TList) : boolean;
begin
    equalLists := (l.Count = m.Count) and (subList (l, m) = 0)
end;

{--------------------------------------------------------}
{             busca um dado em uma lista
{--------------------------------------------------------}

function searchList (l : TList; ini : integer; val : Operand) : integer; overload;
var
    i : integer;
begin
    searchList := -1;

    if ini < 0 then
        ini := 0
    else if ini >= l.count then
        exit;

    for i := ini to l.count - 1 do
    begin
        if (l.items[i] <> NIL) and equalExprs (POperand (l.Items[i])^, val) then
        begin
            searchList := i;
            exit
        end
    end
end;

function searchList (l : TList; ini : integer; val : Operand; partial : boolean; upper : boolean) : integer; overload;
var
    i, len : integer;
    s, t   : string;
    pexp   : POperand;
begin
    searchList := -1;

    if partial and (val.typeof <> E_STRING) then
        exit;

    if ini < 0 then
        ini := 0
    else if ini >= l.count then
        exit;

    s := val.pobj^.str;

    if upper then
        s := maiuscAnsi (s);

    len := length (val.pobj^.str);

    for i := ini to l.count - 1 do
    begin
        if (l.items[i] = NIL) then
            continue;

        pexp := POperand (l.Items[i]);

        if pexp^.typeof <> E_STRING then
            continue;

        t := pexp^.pobj^.str;

        if not partial and (len <> length (t)) then
            continue;

        if upper then t := maiuscAnsi (t);

        if pos (s, t) > 0 then
        begin
            searchList := i;
            exit
        end
    end
end;

{--------------------------------------------------------}
{     retorna o elemento em uma posição da lista
{--------------------------------------------------------}

procedure queryList (var l : TList; pos : integer; var value : Operand); overload;
begin
    if (pos >= 0) and (pos < l.Count) and (l.Items[pos] <> NIL) then
        copyExpr (value, POperand (l.Items[pos])^)
    else
        initExpr (value, E_UNDEF)
end;

procedure queryList (var l : TList; s : string; var value : Operand); overload;
var
    pos, error : integer;
begin
    val (s, pos, error);

    if (error = 0) and (pos >= 0) and (pos < l.Count) and (l.Items[pos] <> NIL) then
        copyExpr (value, POperand (l.Items[pos])^)
    else
        initExpr (value, E_UNDEF)
end;

{--------------------------------------------------------}
{     modifica o elemento em uma posição da lista
{--------------------------------------------------------}

procedure modifyList (var l : TList; pos : integer; value : Operand); overload;
var
    q  : POperand;
begin
    if pos < 0 then exit;

    q := allocNode (E_LIST);
    if q = NIL then exit;

    copyExpr (q^, value);

    if pos >= l.Count then
    begin
        l.Add (q)
    end
    else begin
        if l.Items[pos] <> NIL then
        begin
            freeExpr (POperand (l.Items[pos])^);
            freeNode (l.Items[pos], E_LIST)
        end;

        l.Items[pos] := q
    end
end;

procedure modifyList (var l : TList; value : Operand); overload;
var
    q  : POperand;
begin
    q := allocNode (E_LIST);
    if q = NIL then exit;

    copyExpr (q^, value);

    l.Add (q)
end;

procedure modifyList (var l : TList; key : Operand; value : Operand); overload;
var
    i, s, e, erro : integer;
    p             : PDicNode;
begin
    if value.typeof = E_INVAL then exit;

    case key.typeof of
        E_INVAL,
        E_UNDEF:        ;
        E_INTEGER:      modifyList (l, key.int, value);
        E_STRING:       begin
                            val (key.pobj^.str, i, erro);

                            if erro = 0 then
                                modifyList (l, i, value)
                        end;
        E_RANGE:        begin
                            s := Min (key.low, key.high);
                            e := Max (key.low, key.high);

                            for i := s to e do
                                modifyList (l, i, value)
                        end;
        E_DIC:          begin
                            p := key.pobj^.dic.first;
                            while p <> NIL do
                            begin
                                modifyList (l, p^.value, value);
                                p := p^.next
                            end
                        end;
        E_LIST:         with key.pobj^.list do
                        begin
                            for i := 0 to Count - 1 do
                            begin
                                if Items[i] <> NIL then
                                    modifyList (l, POperand (Items[i])^, value)
                            end
                        end
        end
end;

{--------------------------------------------------------}
{           acrescenta um elemento à lista
{--------------------------------------------------------}

function insertList (var l : TList; pos : integer; value : Operand) : boolean;
var
    p : POperand;
begin
    insertList := false;

    if pos < 0 then
        pos := 0
    else if pos > l.Count then
        pos := l.Count;

    p := allocNode (E_LIST);
    if p = NIL then exit;

    copyExpr (p^, value);
    l.Insert (pos, p);

    insertList := true
end;

{--------------------------------------------------------}
{           remove um elemento da lista
{--------------------------------------------------------}

procedure removeList (var l : TList; pos : integer; var value : Operand);
begin
    invalidateExpr (value);

    if (pos < 0) or (pos >= l.Count) then exit;

    value := POperand (l.Items[pos])^;   { copyExpr (value, POperand (l.Items[pos])^);
                                           freeExpr (POperand (l.Items[pos])^);        }
    freeNode (l.Items[pos], E_LIST);
    l.Delete (pos)
end;

{--------------------------------------------------------}
{           compara dois itens de uma lista
{--------------------------------------------------------}

function comparaItens (Item1, Item2 : Pointer) : integer;
var
    p, q : POperand;
begin
    p := POperand (Item1);
    q := POperand (Item2);

    if p^.typeof <> q^.typeof then
    begin
        comparaItens := ord (p^.typeof) - ord (q^.typeof);
        exit
    end;

    comparaItens := 0;

    case JOINTYPES (p^.typeof, q^.typeof) of
        E_UNDEF_UNDEF:      comparaItens := 0;
        E_INTEGER_INTEGER:  comparaItens := p^.int - q^.int;
        E_STRING_STRING:    if p^.pobj^.str < q^.pobj^.str then
                                comparaItens := -1
                            else if p^.pobj^.str > q^.pobj^.str then
                                comparaItens := 1;
        E_DIC_DIC:          comparaItens := p^.pobj^.dic.card   - q^.pobj^.dic.card;
        E_LIST_LIST:        comparaItens := p^.pobj^.list.Count - p^.pobj^.list.Count
    end
end;

{--------------------------------------------------------}
{                  ordena a lista
{--------------------------------------------------------}

procedure sortList (var l : TList);
begin
    l.Sort (comparaItens)
end;

{--------------------------------------------------------}
{      concatena as listas "l" e "m", gerando "r"
{--------------------------------------------------------}

procedure concatLists (var r : TList; l, m : TList);
var
    i : integer;
begin
    initList (r);

    for i := 0 to l.Count - 1 do
    begin
        if l.Items[i] <> NIL then
            modifyList (r, POperand (l.Items[i])^)
    end;

    for i := 0 to m.Count - 1 do
    begin
        if m.Items[i] <> NIL then
            modifyList (r, POperand (m.Items[i])^)
    end
end;

{--------------------------------------------------------}
{            incorpora uma lista a outra
{--------------------------------------------------------}

procedure appendList (var r : TList; l : TList);
var
    i : integer;
begin
    for i := 0 to l.Count - 1 do
    begin
        if l.Items[i] <> NIL then
            modifyList (r, POperand (l.Items[i])^)
    end
end;

{--------------------------------------------------------}
{        computa a diferença entre duas listas
{--------------------------------------------------------}

procedure listDifference (var r : TList; l, m : TList);
var
    i   : integer;
begin
    initList (r);

    for i := 0 to l.Count - 1 do
    begin
        if (l.Items[i] <> NIL) and (searchList (m, 0, POperand (l.Items[i])^) < 0) then
            modifyList (r, POperand (l.Items[i])^)
    end
end;

{--------------------------------------------------------}
{        computa a interseção entre duas listas
{--------------------------------------------------------}

procedure listIntersection (var r : TList; l, m : TList);
var
    i   : integer;
begin
    initList (r);

    for i := 0 to l.Count - 1 do
    begin
        if (l.Items[i] <> NIL) and (searchList (m, 0, POperand (l.Items[i])^) >= 0) then
            modifyList (r, POperand (l.Items[i])^)
    end
end;

{--------------------------------------------------------}
{      combina os elementos da lista, gerando um só
{--------------------------------------------------------}

procedure combineList (var exp : Operand; op : OperatorType);
label
    erro;
var
    i    : integer;
    tipo : OperandType;
    res  : Operand;
begin
    with exp.pobj^.list do
    begin
        if Count = 0 then goto erro;

        tipo := POperand (Items[0])^.typeof;

        if not (tipo in [E_INTEGER,E_STRING]) then goto erro;

        for i := 1 to Count - 1 do
        begin
            if (Items[i] = NIL) or (POperand (Items[i])^.typeof <> tipo) then
                goto erro
        end;

        initExpr (res, tipo);         { Inicializa conforme o tipo }

        case op of
            C_ADD:      begin
                            for i := 0 to Count - 1 do
                            begin
                                if tipo = E_INTEGER then
                                    res.int := res.int + POperand (Items[i])^.int
                                else
                                    res.pobj^.str := res.pobj^.str + POperand (Items[i])^.pobj^.str
                            end
                        end;
            C_MULT:     begin
                            if tipo <> E_INTEGER then goto erro;

                            initExpr (res, 1);

                            for i := 0 to Count - 1 do
                                res.int := res.int * POperand (Items[i])^.int
                        end;
            C_LT:       begin
                            if tipo = E_INTEGER then
                                res.int := POperand (Items[0])^.int
                            else
                                res.pobj^.str := POperand (Items[0])^.pobj^.str;

                            for i := 1 to Count - 1 do
                            begin
                                if tipo = E_INTEGER then
                                begin
                                    if POperand (Items[i])^.int < res.int then
                                        res.int := POperand (Items[i])^.int
                                end
                                else begin
                                    if POperand (Items[i])^.pobj^.str < res.pobj^.str then
                                        res.pobj^.str := POperand (Items[i])^.pobj^.str
                                end
                            end
                        end;
            C_GT:       begin
                            if tipo = E_INTEGER then
                                res.int := POperand (Items[0])^.int
                            else
                                res.pobj^.str := POperand (Items[0])^.pobj^.str;

                            for i := 1 to Count - 1 do
                            begin
                                if tipo = E_INTEGER then
                                begin
                                    if POperand (Items[i])^.int > res.int then
                                        res.int := POperand (Items[i])^.int
                                end
                                else begin
                                    if POperand (Items[i])^.pobj^.str > res.pobj^.str then
                                        res.pobj^.str := POperand (Items[i])^.pobj^.str
                                end
                            end
                        end;
        end
    end;

    freeExpr (exp);
    exp := res;         { copyExpr (exp, res); freeExpr (res); }
    exit;

erro:
    invalidateExpr (exp)
end;

{--------------------------------------------------------}
{    transforma uma cadeia em uma lista de "palavras"
{--------------------------------------------------------}

function splitString (s : string) : TList; overload;
var
    i, len  : integer;
    val     : Operand;
    l       : TList;
    v       : string;
begin
    l := TList.Create;

    i := 1;  len := length (s);

    while i <= len do
    begin
        while (i <= len) and ((s[i] = ' ') or (s[i] = TAB)) do
            INC (i);

        v := '';
        while (i <= len) and (s[i] <> ' ') and (s[i] <> TAB) do
        begin
            v := v + s[i];
            INC (i)
        end;

        if v <> '' then
        begin
            initExpr (val, v);
            modifyList (l, val);
            freeExpr (val)
        end
    end;

    splitString := l
end;

function splitString (s : string; sep : string) : TList; overload;
var
    p, len  : integer;
    val     : Operand;
    l       : TList;
    v       : string;
begin
    l := TList.Create;

    len := length (sep); v := s; p := pos (sep, v);

    while p > 0 do
    begin
        initExpr (val, copy (v, 1, p - 1));
        modifyList (l, val);
        freeExpr (val);

        delete (v, 1, p + len - 1);
        p := pos (sep, v)
    end;

    initExpr (val, v);
    modifyList (l, val);
    freeExpr (val);

    splitString := l
end;

{----------------------------------------------------}
{  concatena os elementos de uma lista em uma cadeia
{----------------------------------------------------}

function joinList (l : TList; sep : string) : string;
var
    i  : integer;
    s  : string;
begin
    s := '';

    with l do
    begin
       if Count > 0 then
       begin
           for i := 0 to Count - 2 do
           begin
               if Items[i] <> NIL then
                  s := s + formatExpr (POperand (Items[i])^) + sep
           end;

           if Items[Count - 1] <> NIL then
              s := s + formatExpr (POperand (Items[Count - 1])^)
       end
    end;

    joinList := s
end;

{--------------------------------------------------------}
{            justapõe brancos a uma cadeia
{--------------------------------------------------------}

function justifyString (s : string; n : integer) : string;
var
    t : string;
    i : integer;
begin
    t := s;

    if n < 0 then
    begin
        for i := -n - length (s) downto 1 do
           t := ' ' + t
    end
    else if n > 0 then
    begin
        for i := n - length (s) downto 1 do
           t := t + ' '
    end;

    justifyString := t
end;

{--------------------------------------------------------}
{         aloca um nó (de lista ou dicionário)
{--------------------------------------------------------}

function allocNode (typeof : OperandType) : Pointer;
var
    pdic : PDicNode;
    pexp : POperand;
begin
    if typeof = E_LIST then
    begin
        try NEW (pexp) except pexp := NIL end;

        if pexp <> NIL then
            INC (nOperand);

        allocNode := pexp
    end
    else begin
        try NEW (pdic) except pdic := NIL end;

        if pdic <> NIL then
        begin
            INC (nDicNode);
            pdic^.next := NIL
        end;

        allocNode := pdic
    end
end;

{--------------------------------------------------------}
{         libera um nó (de lista ou dicionário)
{--------------------------------------------------------}

procedure freeNode (p : Pointer; t : OperandType);
begin
    DISPOSE (p);

    if t = E_LIST then
        DEC (nOperand)
    else
        DEC (nDicNode)
end;

{--------------------------------------------------------}
{         aloca um nó descritor de objeto
{--------------------------------------------------------}

function allocObjNode : PObjRec;
var
    pobj : PObjRec;
begin
    try NEW (pobj) except pobj := NIL end;

    if pobj <> NIL then
    begin
        pobj^.nref := 1;
        INC (nObjRec)
    end;

    allocObjNode := pobj
end;

{--------------------------------------------------------}
{         libera um nó descritor de objeto
{--------------------------------------------------------}

procedure freeObjNode (p : PObjRec);
begin
    DISPOSE (p);
    DEC (nObjRec)
end;

{--------------------------------------------------------}
{              lê dados no formato JSON                  }
{--------------------------------------------------------}

procedure readJSON (fd : integer; var d : Operand);
label
    fim;
var
    buflinha, stack : string;
    c, quote        : char;
    salva_token     : TokenRec;
    data, enddata   : PChar;
    indlinha, size  : integer;

    {----------------------------------------------------}
    {      deposita um caractere na área temporária      }
    {----------------------------------------------------}

    function putchar (c : char) : boolean;
    var
        newdata : PChar;
        newsize : integer;
    begin
        if enddata >= data + size then
        begin
            newsize := size * 2;
            newdata := data;

            try ReallocMem (newdata, newsize) except newdata := NIL end;

            if newdata = NIL then
            begin
                putchar := false;
                exit
            end;

            data    := newdata;
            enddata := data + size;
            size    := newsize
        end;

        enddata^ := c;
        INC (enddata);

        putchar := true
    end;

    {----------------------------------------------------}
    {                 lê um caractere                    }
    {----------------------------------------------------}

    function getchar : char;
    var
        c : char;
    begin
        getchar := #0;

        with files[fd] do
        begin
            case typeof of
                F_KEY:  begin
                            if indlinha > length (buflinha) then
                            begin
                                sintReadLn (buflinha);

                                if buflinha = '' then
                                    exit;

                                indlinha := 1
                            end;

                            getchar := buflinha[indlinha];
                            INC (indlinha)
                        end;
                F_FILE: begin
                            if not eof (filefd) then
                            begin
                                read (filefd, c);
                                getchar := c
                            end
                        end;
                F_NET:  begin
                            if leCaracBufRede (pbuf, c) then
                                getchar := c
                        end;
                F_SER:  begin
                            leLink (c);
                            if erroLink = 0 then
                                getchar := c
                        end
            end
        end
    end;

begin
    invalidateExpr (d);

    buflinha := ''; indlinha := 1; stack := ''; quote := ' ';

    size := 1024; try GetMem (data, size) except data := NIL end;

    if data = NIL then
    begin
        scWriteln ('Memória insuficiente');
        goto fim
    end;

    enddata := data;

    if files[fd].typeof = F_KEY then
        scWriteln ('Leitura de JSON. Termine com uma linha em branco.');

    c := getchar;

    while c <> #0 do
    begin
        if c = LF then
            c := ' ';

        if quote = ' ' then
        begin
            if (c = '''') or (c = '"') then
            begin
                quote := c
            end
            else if (c = '{') then
            begin
                stack := stack + '}'
            end
            else if (c = '[') then
            begin
                stack := stack + ']'
            end
            else if (c = '}') or (c = ']') then
            begin
                if (stack = '') or (c <> stack[length(stack)]) then
                begin
                    if stack = '' then
                        scWriteln ('Caractere ' + c + ' inesperado')
                    else
                        scWriteln ('Esperava ' + stack[length(stack)] + ' em vez de ' + c);
                    break
                end;

                delete (stack, length (stack), 1)
            end
        end
        else begin
            if c = quote then
                quote := ' '
        end;

        if not putchar (c) then
        begin
            scWriteln ('Memória insuficiente');
            goto fim
        end;

        c := getchar
    end;

    putchar (LF);

    if files[fd].typeof = F_KEY then
        scWriteln ('Fim da leitura de JSON.');

    if enddata - data <= 1 then goto fim;

    salva_token := token;

    lex.setLine (0, data, enddata - data - 1);

    nextToken;
    evalExpr (d);

    token := salva_token;

fim:
    if data <> NIL then FreeMem (data)
end;

begin
end.
