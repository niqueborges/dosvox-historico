{------------------------------------------------------------------------------}
{
{                                  FLOW.PAS
{
{    Processamento dos Comandos de Fluxo do Interpretador ScriptVox
{    Este arquivo é incluído em COMMAND.PAS
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Autor:      Oswaldo Vernet
{    Data:       21/08/2015
{    Alterações: 31/03/2016, 25/09/2018
{
{------------------------------------------------------------------------------}

unit flow;

interface
uses
    dvwin, dvcrt, dvmidi, dvmacro, dvexec, dvinet, dvcomm, dvmsaa, dvform, dvjpeg, dvdigitexto,
    classes, windows, winsock, math, messages, mmsystem, strUtils, synacode, sysUtils,
    pngImage, graphics, jpeg,
    screen, lex, symboltable, low, expr, compile, arithmetic;

function processaImporta : boolean;
function processaCmd : boolean;
function processaFuncao : boolean;
function processaLocal : boolean;
function processaRetorna : boolean;
function conditionIsTrue : boolean;
function processaSeUnitario : boolean;
function processaSe : boolean;
function processaEnquanto : boolean;
function processaSenao : boolean;
function processaRepete : boolean;
function processaPara : boolean;
function processaQuebra : boolean;
function processaContinua : boolean;
function processaFim : boolean;
function processaDesviaOuChama (var script : string; var line : integer; var neww : integer) : boolean;
function processaDesvia : boolean;
function processaChama : boolean;
function processaTermina : boolean;

implementation

{--------------------------------------------------------}
{                 comando importa
{--------------------------------------------------------}

function processaImporta : boolean;
begin
    skipToEol;              { O comando IMPORTA é tratado na pré-compilação }
    processaImporta := true
end;

{--------------------------------------------------------}
{                  comando cmd
{--------------------------------------------------------}

function processaCmd : boolean;
var
    exp : Operand;
    cmd : string;
    ok  : boolean;
begin
    processaCmd := false;

    evalExpr (exp, E_STRING);

    if (exp.typeof <> E_STRING) or (exp.pobj^.str = '') then
    begin
        errorMsg ('Esperava uma cadeia contendo o comando a executar');
        freeExpr (exp)
    end
    else begin
        cmd := exp.pobj^.str;
        freeExpr (exp);

        if token.typeof = T_EOL then
        begin
            low.appendExtraLine (CS, cmd);
            ok := low.execLine (CS, 0);
            processaCmd := ok
        end
    end
end;

{--------------------------------------------------------}
{                    comando Função
{--------------------------------------------------------}

function processaFuncao : boolean;
label
    out;
var
    param, local, savebp : integer;
    exp                  : Operand;
begin
    processaFuncao := false;

    if SP = 0 then                      { Ninguém chamou: pula a função }
    begin
        setnPC (getFollowing (CS, getGoTo (getPC)));

        skipToEOL;

        processaFuncao := true;
        exit
    end;

    savebp := BP;

    CF := symboltable.getSymbol (CS, NIL, token.id, false);

    param := -1;

    nextToken;

    if token.typeof = T_LP then
    begin
        repeat
            nextToken;

            if token.typeof in [T_CL,T_RP,T_EOL] then
                break;

            if token.typeof = T_ID then
            begin
                symboltable.defineLocalVariable (CS, CF, token.id, param);
                DEC (param)
            end
        until false;

        if token.typeof = T_RP then
        begin
            nextToken
        end
        else begin
            errorMsg ('Já que abriu, favor fechar o parênteses');
            goto out
        end
    end;

    local := 0;

    if token.typeof = T_CL then
    begin
        nextToken;

        while token.typeof = T_ID do
        begin
            if not incSP then goto out;

            INC (local);
            symboltable.defineLocalVariable (CS, CF, token.id, SP - BP);

            nextToken;

            if (token.typeof = T_AT) or ((token.typeof = T_OP) and (token.op = C_EQ)) then
            begin
                nextToken;
                evalExpr (exp)
            end
            else begin
                initExpr (exp, E_UNDEF)
            end;

            stack[SP].typeof   := P_VAR;
            stack[SP].val.iter := -1;
            stack[SP].val.exp  := exp;

            if token.typeof = T_EOL then
                break;

            if token.typeof = T_VG then
                nextToken
        end
    end;

    CF^.local := local;      { Guarda o número de variáveis locais já declaradas }

    processaFuncao := true;
    exit;

out:
    skipToEOL;

    BP := savebp
end;

{--------------------------------------------------------}
{                  comando Local
{--------------------------------------------------------}

function processaLocal : boolean;
label
    out;
var
    local, savebp : integer;
    exp           : Operand;
begin
    processaLocal := false;

    if CF = NIL then
    begin
        scWriteln ('O comando LOCAL só é válido no corpo de uma função');
        skipToEOL;
        exit
    end;

    savebp := BP;
    local  := CF^.local;

    while token.typeof = T_ID do
    begin
        if not incSP then goto out;

        INC (local);
        symboltable.defineLocalVariable (CS, CF, token.id, SP - BP);

        nextToken;

        if (token.typeof = T_AT) or ((token.typeof = T_OP) and (token.op = C_EQ)) then
        begin
            nextToken;
            evalExpr (exp)
        end
        else begin
            initExpr (exp, E_UNDEF)
        end;

        stack[SP].typeof   := P_VAR;
        stack[SP].val.iter := -1;
        stack[SP].val.exp  := exp;

        if token.typeof = T_EOL then
            break;

        if token.typeof = T_VG then
            nextToken
    end;

    CF^.local := local;      { Guarda o número de variáveis locais já declaradas }

    processaLocal := true;
    exit;

out:
    skipToEOL;
    BP := savebp
end;

{--------------------------------------------------------}
{                  Comando Retorna
{--------------------------------------------------------}

function processaRetorna : boolean;
var
    exp : Operand;
begin
    processaRetorna := false;

    initExpr (exp, E_UNDEF);

    if tokenIsID ('FUNCAO') then
        nextToken                           { O comando FIM FUNÇÃO equivale a RETORNA INDEFINIDO }
    else if token.typeof <> T_EOL then
        evalExpr (exp);

    if CF = NIL then
    begin                                                       { Comando "chama" }
        freeExpr (exp);

        while (SP > 0) and (stack[SP].typeof <> P_RET) do       { Aqui não temos o BP! }
            DEC (SP);

        if SP <= 0 then
        begin
            setTerminated (CS, true);
            setSilent (CS, true);
            processaRetorna := true;
            exit
        end;

        setCS (stack[SP].script);

        setPC (stack[SP].opc);
        setnPC (getFollowing (CS, getPC));

        DEC (SP)
    end
    else begin                                                  { Chamada regular de função }
        if (BP < 0) or (stack[BP].typeof <> P_RET) then
        begin
            errorMsg ('Pilha corrompida, RET não encontrado');
            exit
        end;

        stack[BP].val.iter := -1;
        stack[BP].val.exp  := exp;          { Guarda o valor retornado }

        setReturn (CS, true)              { Liga o indicador avisando que o comando RETORNA foi executado }
    end;

    processaRetorna := true
end;

{--------------------------------------------------------}
{          testa se uma condição é verdadeira
{--------------------------------------------------------}

function conditionIsTrue : boolean;
var
    exp : Operand;
begin
    conditionIsTrue := false;

    evalExpr (exp);

    case exp.typeof of
        E_INTEGER:  conditionIsTrue := exp.int <> 0;
        E_STRING:   conditionIsTrue := exp.pobj^.str <> '';
        E_DIC:      conditionIsTrue := exp.pobj^.dic.card <> 0;
        E_LIST:     conditionIsTrue := exp.pobj^.list.Count <> 0;
    end;

    freeExpr (exp)
end;

{--------------------------------------------------------}
{            Comando se de uma só linha
{--------------------------------------------------------}

function processaSeUnitario : boolean;
var
    ok, missing, trueCond : boolean;
    P                     : PSymtbEntry;
begin
    ok := true; missing := false;

    trueCond := conditionIsTrue;

    if tokenIsID ('ENTAO') then
        nextToken;

    markToken;

    if trueCond then
    begin
        if token.typeof = T_ID then
        begin
            p := symboltable.getSymbol (CS, NIL, token.id, false);

            nextToken;

            if (p = NIL) or (p^.typeof in [S_VAR,S_MOD,S_NFUNC,S_UFUNC]) then
                ok := processaAtrib
            else if p^.typeof in [S_COMM,S_BREAK,S_CONT] then
                ok := p^.exec
            else
                missing := true
        end
        else begin
            missing := true
        end
    end
    else begin
        skipToEOL
    end;

    if missing then
    begin
        errorMsg ('Esperava um comando simples na mesma linha do comando SE');
        ok := false
    end;

    processaSeUnitario := ok
end;

{--------------------------------------------------------}
{                  Comando se
{--------------------------------------------------------}

function processaSe : boolean;
begin
    if CS = 0 then                       { No script interativo, apenas o SE unitário é aceito }
    begin
        processaSe := processaSeUnitario;
        exit
    end;

    if not conditionIsTrue then       { A condição não foi satisfeita... }
        setnPC (getGoTo (getPC));           { ... pula para o SENÃO ou para o FIM SE }

    if tokenIsID ('ENTAO') then
        nextToken;

    processaSe := true
end;

{--------------------------------------------------------}
{                  Comando enquanto
{--------------------------------------------------------}

function processaEnquanto : boolean;
begin
    if not conditionIsTrue then
        setnPC (getFollowing (CS, getGoTo (getPC)));       { Pula para a linha seguinte ao FIM ENQUANTO }

    if tokenIsID ('FACA') then
        nextToken;

    processaEnquanto := true
end;

{--------------------------------------------------------}
{                  Comando senão
{--------------------------------------------------------}

function processaSenao : boolean;
begin
    processaSenao := true;

    if tokenIsID ('SE') then
    begin
        nextToken;
        processaSenao := processaSe
    end
end;

{--------------------------------------------------------}
{                 Comando Repete
{--------------------------------------------------------}

function processaRepete : boolean;
label
    out;
var
    lvalue   : LvalueRec;
    exp, ctl : Operand;
begin
    processaRepete := false;

    initExpr (exp, E_UNDEF);

    getLvalue (lvalue);
    if lvalue.id = NIL then goto out;

    evalExpr (exp, E_INTEGER);

    if exp.typeof <> E_INTEGER then
    begin
        errorMsg ('Limite superior para o comando REPETE deve ser inteiro');
        goto out
    end;

    initExpr (ctl, 1);               { Faz a atribuição à variável de controle }
    doAssignment (lvalue, ctl);

    if exp.int <= 0 then               { Se o limite é 0 ou negativo... }
        setnPC (getFollowing (CS, getGoTo (getPC)));         { ... pula para a linha seguinte ao FIM REPETE }

    processaRepete := true;

out:
    freeLvalue (lvalue);
    freeExpr (exp)
end;

{--------------------------------------------------------}
{                 Comando para
{--------------------------------------------------------}

function processaPara : boolean;
label
    out;
var
    lvalue      : LvalueRec;
    exp, exp1   : Operand;
    jump, card  : integer;
    q           : PValueRec;
    l           : TList;
    ascending   : boolean;
begin
    processaPara := false;

    jump := getGoTo (getPC);

    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    if not simpleLvalue (lvalue) then
    begin
        errorMsg ('Um iterador deve ser uma váriável simples, sem índices');
        exit
    end;

    initExpr (exp,  E_UNDEF);
    initExpr (exp1, E_UNDEF);

    ascending := true;

    if tokenIsID ('EM') then
    begin
        nextToken;
        evalExpr (exp, E_RANGE);

        if (exp.typeof = E_RANGE) and (exp.low > exp.high) then
            ascending := false
    end
    else begin
        if tokenIsID ('DE') then
            nextToken;

        evalExpr (exp, E_INTEGER);

        if ((token.typeof = T_OP) and (token.op = C_TO)) or ((token.typeof = T_ID) and ((token.id = 'ATE') or (token.id = 'A'))) then
            nextToken;

        evalExpr (exp1, E_INTEGER);

        if (exp.typeof <> E_INTEGER) or (exp1.typeof <> E_INTEGER) then
        begin
            errorMsg ('Limites para a variável de controle devem ser INTEIROS');
            goto out
        end;

        if tokenIsID ('CRESCENDO') then
        begin
            nextToken
        end
        else if tokenIsID ('DECRESCENDO') then
        begin
            ascending := false;
            nextToken
        end;

        exp.low    := exp.int;
        exp.high   := exp1.int;
        exp.typeof := E_RANGE
    end;

    if tokenIsID ('FACA') then
        nextToken;

    case exp.typeof of
        E_INTEGER:  begin
                        exp.low    := exp.int;
                        exp.high   := exp.low;
                        exp.typeof := E_RANGE;
                        card     := 1
                    end;
        E_RANGE:    if ascending then
                    begin
                        if exp.low > exp.high then
                            card := 0
                        else
                            card := exp.high - exp.low + 1
                    end
                    else begin
                        if exp.low < exp.high then
                            card := 0
                        else
                            card := exp.low - exp.high + 1
                    end;
        E_STRING:   card := length (exp.pobj^.str);
        E_DIC:      begin
                        l := dicKeys (exp.pobj^.dic);
                        freeExpr (exp);
                        initExpr (exp, l);
                        card := l.Count
                    end;
        E_LIST:     card := exp.pobj^.list.Count;
        else        begin
                        errorMsg ('Domínio inválido para um iterador');
                        card := 0
                    end
    end;

    q := getVarAddress (lvalue.id);

    freeExpr (q^.exp);

    if card = 0 then
    begin
        initExpr (q^.exp, E_UNDEF);
        setnPC (getFollowing (CS, jump))
    end
    else begin
        q^.iter := 0;
        copyExpr (q^.exp, exp)
    end;

    processaPara := true;

out:
    freeExpr (exp);
    freeExpr (exp1);
    freeLvalue (lvalue)
end;

{--------------------------------------------------------}
{                    comando quebra
{--------------------------------------------------------}

function processaQuebra : boolean;
label
    out;
var
    jump   : integer;
    lvalue : LvalueRec;
    q      : PValueRec;
begin
    jump := getGoTo (getPC);      { Linha inicial do bloco de iteração }

    setCurrentLine (CS, jump);

    nextToken;

    if tokenIsID ('PARA') then
    begin
        nextToken;
        getLvalue (lvalue);
        if lvalue.id = NIL then goto out;

        q := getVarAddress (lvalue.id);

        q^.iter := -1;                    { A variável de controle deixa de ser um iterador }
        freeExpr (q^.exp);                { Libera o domínio }
        initExpr (q^.exp, E_UNDEF);       { Seu valor torna-se INDEFINIDO }

        freeLvalue (lvalue)
    end;

out:
    skipToEOL;
    setnPC (getFollowing (CS, getGoTo (jump)));
    processaQuebra := true
end;

{--------------------------------------------------------}
{                   comando continua
{--------------------------------------------------------}

function processaContinua : boolean;
begin
    setnPC (getGoTo (getGoTo (getPC)));
    processaContinua := true
end;

{--------------------------------------------------------}
{                    comando fim
{--------------------------------------------------------}

function processaFim : boolean;
label
    out;
var
    jump      : integer;
    lvalue    : LvalueRec;
    exp, ctl  : Operand;
    card      : integer;
    q         : PValueRec;
begin
    processaFim := false;

    invalidateLvalue (lvalue);
    invalidateExpr (exp);
    invalidateExpr (ctl);

    jump := getGoTo (getPC);      { Linha inicial do bloco de iteração }

    if token.id = 'REPETE' then
    begin
        setCurrentLine (CS, jump);

        nextToken;    { Pula o 'REPETE' }

        nextToken;
        getLvalue (lvalue);
        if lvalue.id = NIL then goto out;

        evalExpr (exp, E_INTEGER);

        if exp.typeof <> E_INTEGER then
        begin
            errorMsg ('Limite superior para o comando REPETE deve ser inteiro');
            goto out
        end;

        evalLvalue (lvalue, ctl, E_INTEGER);

        if ctl.typeof <> E_INTEGER then
        begin
            errorMsg ('A variável de controle do comando REPETE não contém um valor inteiro');
            goto out
        end;

        if ctl.int < exp.int then
        begin
            INC (ctl.int);
            doAssignment (lvalue, ctl);
            setnPC (getFollowing (CS, jump))
        end
    end
    else if token.id = 'PARA' then
    begin
        setCurrentLine (CS, jump);

        nextToken;    { Pula o 'PARA' }

        nextToken;
        getLvalue (lvalue);
        if lvalue.id = NIL then goto out;

        q := getVarAddress (lvalue.id);

        if (q^.iter < 0) or not simpleLvalue (lvalue) then
        begin
            errorMsg ('A variável ' + lvalue.id^.id + ' não é um iterador');
            goto out
        end;

        card := 0;

        case q^.exp.typeof of
            E_RANGE:    card := Abs (q^.exp.high - q^.exp.low) + 1;
            E_STRING:   card := length (q^.exp.pobj^.str);
            E_LIST:     card := q^.exp.pobj^.list.Count
        end;

        if q^.iter >= card - 1 then             { Chegou ao fim do percurso? }
        begin
            q^.iter := -1;                      { A variável de controle deixa de ser um iterador }
            freeExpr (q^.exp);                { Libera o domínio }
            initExpr (q^.exp, E_UNDEF)    { Seu valor torna-se INDEFINIDO }
        end
        else begin
            INC (q^.iter);                      { Próximo elemento do domínio }
            setnPC (getFollowing (CS, jump))
        end
    end
    else if token.id = 'SE' then
    begin
                                { Não precisa fazer nada }
    end
    else begin
        setnPC (jump)           { Só pode ser ENQUANTO }
    end;

    processaFim := true;

out:
    skipToEOL;
    freeExpr (exp);
    freeExpr (ctl);
    freeLvalue (lvalue)
end;

{--------------------------------------------------------}
{         código comum aos comandos Desvia e Chama
{--------------------------------------------------------}

function processaDesviaOuChama (var script : string; var line : integer; var neww : integer) : boolean;
var
    exp  : Operand;
    lab  : string;
begin
    processaDesviaOuChama := false;

    script := '';
    line   := -1;
    neww   := CS;

    { Verifica se um novo script foi especificado }

    if tokenIsID ('SCRIPT') then
    begin
        nextToken;
        evalExpr (exp, E_STRING);

        if (exp.typeof <> E_STRING) or (exp.pobj^.str = '') then
        begin
            freeExpr (exp);
            errorMsg ('Esperava o nome de um script');
            exit
        end;

        script := exp.pobj^.str;
        freeExpr (exp)
    end;

    { Analisa o rótulo ou a expressão cuja avaliação constituirá o rótulo }

    lab := '';

    if token.typeof = T_EOL then
    begin
        if script = '' then
        begin
            errorMsg ('Esperava um rótulo');
            exit
        end
    end
    else if token.typeof = T_ROT then
    begin
        lab := token.id;
        nextToken
    end
    else begin
        evalExpr (exp);

        if (exp.typeof = E_STRING) and (exp.pobj^.str <> '') then
        begin
            lab := normalize (exp.pobj^.str);
            freeExpr (exp)
        end
        else begin
            errorMsg ('Esperava um rótulo');
            freeExpr (exp);
            exit
        end
    end;

    { Se foi mencionado, carrega e pré-compila o novo script }

    if script <> '' then
    begin
        neww := low.loadScript (script);

        if neww < 0 then
        begin
            errorMsg ('Erro na leitura do script "' + script + '"');
            exit
        end;

        if not compile.preCompile (neww) then
        begin
            errorMsg ('O script "' + script + '" possui erros sintáticos');
            freeScript (neww);
            exit
        end
    end;

    if lab = '' then
    begin
        line := 1;            { O desvio será para o início de um novo script }

        if getScope (neww, line) <> NIL then
        begin
            errorMsg ('Não será possível desviar remotamente para a linha, devido ao escopo');
            exit
        end
    end
    else begin
        if neww = CS then
            line := getLabel (neww, CF, lab)
        else
            line := getLabel (neww, NIL, lab);

        if line < 0 then
        begin
            errorMsg ('Rótulo ' + lab + ' não foi definido ou não tem o escopo correto');
            exit
        end
    end;

    processaDesviaOuChama := true
end;

{--------------------------------------------------------}
{                  Comando desvia
{--------------------------------------------------------}

function processaDesvia : boolean;
var
    script     : string;
    line, neww : integer;
begin
    processaDesvia := false;

    if not processaDesviaOuChama (script, line, neww) then exit;

    if CS = neww then
    begin
        if neww = 0 then
        begin
            errorMsg ('O comando DESVIA NÃO é permitido no modo interativo');
            skipToEOL;
            exit
        end;

        setnPC (line)
    end
    else begin
        execScript (neww, line)
    end;

    processaDesvia := true
end;

{--------------------------------------------------------}
{                  Comando chama
{--------------------------------------------------------}

function processaChama : boolean;
var
    script, ret : string;
    line, neww  : integer;
    exp         : Operand;
    lvalue      : LvalueRec;
    rotina      : ExternalFunc;
begin
    processaChama := false;

    if tokenIsID ('REMOTO') then
    begin
        nextToken;
        evalExpr (exp, E_STRING);

        rotina := low.getExternalFunc (CS);

        if @rotina = NIL then
        begin
            errorMsg ('Rotina externa não foi definida');
            ret := ''
        end
        else begin
            ret := rotina (exp.pobj^.str)      { Chama a rotina externa, usando a cadeia dada como parâmetro }
        end;

        freeExpr (exp);

        if token.typeof <> T_EOL then
        begin
            initExpr (exp, ret);
            getLvalue (lvalue);

            if lvalue.id <> NIL then
                doAssignment (lvalue, exp);

            freeLvalue (lvalue);
            freeExpr (exp)
        end;

        processaChama := true;
        exit
    end;

    if not processaDesviaOuChama (script, line, neww) then exit;

    if CS = 0 then          { o script 0 é o interativo }
    begin
        if neww = CS then
        begin
            errorMsg ('O comando CHAMA no modo interativo deve especificar um novo script');
            exit
        end;

        execScript (neww, line);
        setCS (0)
    end
    else begin
        if not incSP then exit;

        with stack[SP] do
        begin
            typeof := P_RET;
            script := CS;
            opc    := getPC
        end;

        setCS (neww);
        setnPC (neww, line)
    end;

    processaChama := true
end;

{--------------------------------------------------------}
{                  comando Termina
{--------------------------------------------------------}

function processaTermina : boolean;
var
    exp   : Operand;
    msg   : string;
    pause : boolean;
begin
    processaTermina := true;

    setTerminated (CS, true);

    if tokenIsID ('MUDO') then
    begin
        setSilent (CS, true);
        nextToken
    end
    else begin
        setSilent (CS, true);

        pause := false; msg := '';

        if tokenIsID ('PAUSA') then
        begin
            pause := true;
            nextToken
        end;

        if token.typeof <> T_EOL then
        begin
            evalExpr (exp, E_STRING);

            if exp.typeof = E_STRING then
                msg := exp.pobj^.str;

            freeExpr (exp)
        end;

        if msg <> '' then
            scWriteln (msg);

        if pause then
        begin
            scWrite ('Tecle ENTER para encerrar o script');
            readln
        end
        else begin
{$IfDef VIDENTE}
            delay (2000);
{$EndIf}
        end
    end;

    { O término do script dentro de uma função é tratado como uma Exception,
      capturada em execScript (DVSCRIPT.PAS) }

    if CF <> NIL then
        raise Exception.Create ('')
end;

end.

