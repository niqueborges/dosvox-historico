{------------------------------------------------------------------------------}
{
{                               ARITHMETIC.PAS
{
{    Processamento dos Comandos Aritméticos do Interpretador ScriptVox
{    Este arquivo é incluído em COMMAND.PAS
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Autor:      Oswaldo Vernet
{    Data:       21/08/2015
{    Alterações:
{
{------------------------------------------------------------------------------}

unit arithmetic;
interface
uses
    dvwin, dvcrt, dvmidi, dvmacro, dvexec, dvinet, dvcomm, dvmsaa, dvform, dvjpeg, dvdigitexto,
    classes, windows, winsock, math, messages, mmsystem, strUtils, synacode, sysUtils,
    pngImage, graphics, jpeg,
    screen, lex, symboltable, low, expr, compile;

function processaAtrib : boolean;
function processaAvaliacao : boolean;
function processaSeja : boolean;
function processaDestroi : boolean;
function processaContas (operador: char; cmd : string): boolean;
function processaSoma : boolean;
function processaSubtracao : boolean;
function processaMultiplicacao : boolean;
function processaDivisao : boolean;
function processaResto : boolean;
function processaConcatena : boolean;
function processaCopia : boolean;
function processaSubstitui : boolean;
function processaTroca : boolean;
function processaSepara : boolean;
function processaAnexa : boolean;
function processaProcura : boolean;
function processaCmdOrdena : boolean;

implementation

{--------------------------------------------------------}
{               comando de atribuição
{--------------------------------------------------------}

function processaAtrib : boolean;
label
    out;
var
    lvalue  : LvalueRec;
    exp     : Operand;
begin
    processaAtrib := false;

    backToMarkedToken;

    invalidateExpr (exp);

    getLvalue (lvalue, true);
    if lvalue.id = NIL then exit;

    if lvalue.id^.typeof in [S_NFUNC,S_UFUNC] then        { Chamada de função }
    begin
        backToMarkedToken;
        evalExpr (exp);

        if token.typeof <> T_EOL then
        begin
            errorMsg ('"' + lvalue.id^.id + '" é um identificador de ' + SymbolTypeToStr[lvalue.id^.typeof] + ', não pode ser usado como variável');
            skipToEOL;
            goto out
        end;

        if exp.typeof = E_INVAL then
        begin
            errorMsg ('Chamada inválida da função ' + lvalue.id^.id)
        end
        else begin
            if (CS = 0) and (exp.typeof <> E_UNDEF) then
                scWriteln (formatExpr (exp));
            processaAtrib := true;
        end;

        goto out
    end;

    if (token.typeof <> T_AT) and ((token.typeof <> T_OP) or (token.op <> C_EQ)) then
    begin
        if CS <> 0 then goto out;

        backToMarkedToken;
        evalExpr (exp);
        scWriteln (formatExpr (exp));
        processaAtrib := true;
        goto out
    end;

    nextToken;

    evalExpr (exp);

    if exp.typeof = E_INVAL then
    begin
        errorMsg ('Expressão inválida; a variável "' + formatLvalue (lvalue, NIL) + '" não foi modificada')
    end
    else begin
        doAssignment (lvalue, exp);
        processaAtrib := true
    end;

out:
    freeLvalue (lvalue);
    freeExpr (exp)
end;

{--------------------------------------------------------}
{         comando de avaliação de expressões
{--------------------------------------------------------}

function processaAvaliacao : boolean;
var
    exp : Operand;
begin
    backToMarkedToken;

    if CS = 0 then
    begin
        evalExpr (exp);
        scWriteln (formatExpr (exp));
        freeExpr (exp);
        processaAvaliacao := true
    end
    else begin
        processaAvaliacao := false
    end
end;

{--------------------------------------------------------}
{               comando seja
{--------------------------------------------------------}

function processaSeja : boolean;
var
    lvalue  : LvalueRec;
    exp     : Operand;
begin
    processaSeja := false;

    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    if token.typeof = T_EOL then
    begin
        if lvalue.ind.pobj^.dic.card = 0 then   { Não foram dados indexadores: ERRO }
        begin
            errorMsg ('Esperava uma expressão para atribuir a "' + lvalue.id^.id + '"');
            exit
        end;

        { O último indexador é, na verdade, a expressão do lado direito. Ex: SEJA l[2] [1,2,3] }

        removeLastIndexer (exp, lvalue.ind.pobj^.dic)
    end
    else begin
        if (token.typeof = T_AT) or ((token.typeof = T_OP) and (token.op = C_EQ)) then
            nextToken;

        evalExpr (exp)
    end;

    if exp.typeof = E_INVAL then
    begin
        errorMsg ('Expressão inválida; a variável "' + formatLvalue (lvalue, NIL) + '" não foi modificada');
    end
    else begin
        doAssignment (lvalue, exp);
        processaSeja := true
    end;

    freeLvalue (lvalue);
    freeExpr (exp)
end;

{--------------------------------------------------------}
{               comando destroi
{--------------------------------------------------------}

function processaDestroi : boolean;
var
    lvalue : LvalueRec;
    exp    : Operand;
begin
    getLvalue (lvalue);

    if lvalue.id = NIL then
    begin
        processaDestroi := false;
        exit
    end;

    initExpr (exp, E_UNDEF);
    doAssignment (lvalue, exp);

    freeLvalue (lvalue);
    freeExpr (exp);

    processaDestroi := true
end;

{--------------------------------------------------------}
{   comandos soma, subtrai, multiplica, divide, resto
{--------------------------------------------------------}

function processaContas (operador: char; cmd : string): boolean;
label
    out, next;
var
    lvalue              : LvalueRec;
    exp, exp1           : Operand;
    sz, dig, vum, sig   : integer;
    save                : String;
begin
    processaContas := false;

    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    evalLvalue (lvalue, exp);
    evalExpr (exp1, E_INTEGER);

    if exp1.typeof <> E_INTEGER then
    begin
        errorMsg ('O segundo operando do comando ' + cmd + ' deve ser inteiro');
        goto out
    end;

    if exp.typeof = E_STRING then
    begin
        save := exp.pobj^.str;

        if (convertToInteger (exp) = E_INTEGER) then
            goto next;

        if operador = '+' then
        begin
            if exp1.int < 0 then
            begin
                sig := -1;
                exp1.int := -exp1.int
            end
            else begin
                sig := 1
            end
        end
        else if operador = '-' then
        begin
            if exp1.int < 0 then
            begin
                sig := 1;
                exp1.int := -exp1.int
            end
            else begin
                sig := -1
            end
        end
        else begin
            errorMsg ('O primeiro operando do comando ' + cmd + ' não é inteiro');
            goto out
        end;

        sz  := length (save);
        vum := 0;

        { exp1.int é garantidamente não negativo }

        while (sz > 0) and (save[sz] in ['0'..'9']) and ((exp1.int <> 0) or (vum <> 0)) do
        begin
            dig := ord (save[sz]) - ord ('0') + sig * ((exp1.int mod 10) + vum);

            if dig > 9 then
            begin
                vum := 1;
                DEC (dig, 10)
            end
            else if dig < 0 then
            begin
                vum := 1;
                INC (dig, 10)
            end
            else begin
                vum := 0
            end;

            save[sz] := chr (dig + ord ('0'));

            exp1.int := exp1.int div 10;
            DEC (sz)
        end;

        initExpr (exp, save);
        processaContas := true;
        doAssignment (lvalue, exp);
        goto out
    end;

    if exp.typeof <> E_INTEGER then
    begin
        errorMsg ('O primeiro operando do comando ' + cmd + ' não é inteiro');
        goto out
    end;

next:
    case operador of
         '+':  exp.int := exp.int + exp1.int;
         '-':  exp.int := exp.int - exp1.int;
         '*':  exp.int := exp.int * exp1.int;
         '/':  begin
                   if exp1.int = 0 then
                   begin
                       errorMsg ('Divisão por zero evitada');
                       exp1.int := 1
                   end;
                   exp.int := exp.int div exp1.int
               end;
         '%':  begin
                   if exp1.int = 0 then
                   begin
                       errorMsg ('Divisão por zero evitada');
                       exp1.int := 1
                   end;
                   exp.int := exp.int mod exp1.int
               end;
    end;

    processaContas := true;
    doAssignment (lvalue, exp);

out:
    freeLvalue (lvalue);
    freeExpr (exp);
    freeExpr (exp1)
end;

{--------------------------------------------------------}
{                   comando soma
{--------------------------------------------------------}

function processaSoma : boolean;
begin
    processaSoma := processaContas ('+', 'SOMA')
end;

function processaSubtracao : boolean;
begin
    processaSubtracao := processaContas ('-', 'SUBTRAI')
end;

function processaMultiplicacao : boolean;
begin
    processaMultiplicacao := processaContas ('*', 'MULTIPLICA')
end;

function processaDivisao : boolean;
begin
    processaDivisao := processaContas ('/', 'DIVIDE')
end;

function processaResto : boolean;
begin
    processaResto := processaContas ('%', 'RESTO')
end;

{--------------------------------------------------------}
{                   comando concatena
{--------------------------------------------------------}

function processaConcatena : boolean;
label
    out;
var
    lvalue          : LvalueRec;
    q               : PValueRec;
    exp, exp1, exp2 : Operand;
    s, sep          : string;
    i               : integer;
    list            : boolean;
begin
    processaConcatena := false;

    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    list := tokenIsID ('LISTA');

    q := getVarAddress (lvalue.id);

    if not list and (q^.exp.typeof = E_STRING) and simpleLvalue (lvalue) then
    begin
        invalidateExpr (exp);
        evalExpr (exp1, E_STRING);

        if exp1.typeof <> E_STRING then
        begin
            errorMsg ('O comando CONCATENA aplica-se a cadeias');
            goto out
        end;

        q^.exp.pobj^.str := q^.exp.pobj^.str + exp1.pobj^.str
    end
    else begin
        if list then
        begin
            nextToken;
            evalExpr (exp1);

            if exp1.typeof <> E_LIST then
            begin
                errorMsg ('Esperava uma lista para concatenar');
                goto out
            end;

            if token.typeof <> T_EOL then
            begin
                evalExpr (exp2, E_STRING);
                sep := exp2.pobj^.str;
                freeExpr (exp2)
            end
            else begin
                sep := ''
            end;

            with exp1.pobj^.list do
            begin
                if Count = 0 then
                begin
                    s := ''
                end
                else if Count = 1 then
                begin
                    s := formatExpr (POperand (Items[0])^)
                end
                else begin
                    s := '';

                    for i := 0 to Count - 2 do
                    begin
                        if Items[i] <> NIL then
                            s := s + formatExpr (POperand (Items[i])^) + sep
                    end;

                    if Items[Count - 1] <> NIL then
                        s := s + formatExpr (POperand (Items[Count - 1])^)
                end
            end
        end
        else begin
            evalLvalue (lvalue, exp, E_STRING);
            evalExpr (exp1, E_STRING);

            if (exp.typeof <> E_STRING) or (exp1.typeof <> E_STRING) then
            begin
                errorMsg ('O comando CONCATENA aplica-se a cadeias');
                goto out
            end;

            s := exp.pobj^.str + exp1.pobj^.str;
        end;

        freeExpr (exp);
        initExpr (exp, s);

        doAssignment (lvalue, exp)
    end;

    processaConcatena := true;

out:
    freeLvalue (lvalue);
    freeExpr (exp);
    freeExpr (exp1)
end;

{--------------------------------------------------------}
{                  comando copia
{--------------------------------------------------------}

function processaCopia : boolean;
label
    out;
var
    lvalue          : LvalueRec;
    exp, ini, fim   : Operand;
    s               : string;
begin
    processaCopia := false;

    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    evalExpr (exp, E_STRING);
    evalExpr (ini, E_INTEGER);
    evalExpr (fim, E_INTEGER);

    if (exp.typeof <> E_STRING) or (ini.typeof <> E_INTEGER) or (fim.typeof <> E_INTEGER) then
    begin
        errorMsg ('Operandos inválidos para o comando COPIA');
        goto out
    end;

    processaCopia := true;

    s := copy (exp.pobj^.str, ini.int, fim.int - ini.int + 1);

    freeExpr (exp);
    initExpr (exp, s);
    doAssignment (lvalue, exp);

out:
    freeLvalue (lvalue);
    freeExpr (exp);
    freeExpr (ini);
    freeExpr (fim)
end;

{--------------------------------------------------------}
{                  comando substitui
{--------------------------------------------------------}

function processaSubstitui : boolean;
label
    out;
var
    lvalue          : LvalueRec;
    exp, exp1, exp2 : Operand;
    i, len          : integer;
    s, old, neww    : string;
begin
    processaSubstitui := false;

    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    evalLvalue (lvalue, exp, E_STRING);
    evalExpr (exp1, E_STRING);
    evalExpr (exp2, E_STRING);

    if (exp.typeof <> E_STRING) or (exp1.typeof <> E_STRING) or (exp2.typeof <> E_STRING) then
    begin
        errorMsg ('Esperava três cadeias como argumentos para o comando SUBSTITUI');
        goto out
    end;

    s       := exp.pobj^.str;
    old     := exp1.pobj^.str;
    neww    := exp2.pobj^.str;
    len     := length (old);

    for i := length (s) - len + 1 downto 1 do
    begin
        if copy (s, i, len) = old then
        begin
            delete (s, i, len);
            insert (neww, s, i);
        end
    end;

    freeExpr (exp);
    initExpr (exp, s);
    doAssignment (lvalue, exp);

    processaSubstitui := true;

out:
    freeLvalue (lvalue);
    freeExpr (exp);
    freeExpr (exp1);
    freeExpr (exp2)
end;

{--------------------------------------------------------}
{                  comando troca
{--------------------------------------------------------}

function processaTroca : boolean;
label
    out;
var
    lvalue          : LvalueRec;
    exp, exp1,
    exp2, exp3      : Operand;
    ini, fim        : integer;
    s, novo         : string;
begin
    processaTroca := false;

    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    evalLvalue (lvalue, exp, E_STRING);
    evalExpr (exp1, E_STRING);
    evalExpr (exp2, E_INTEGER);
    evalExpr (exp3, E_INTEGER);

    if exp.typeof <> E_STRING then
    begin
        errorMsg ('A variável especificada não contém uma cadeia');
        goto out
    end;

    if exp1.typeof <> E_STRING then
    begin
        errorMsg ('O terceiro argumento deveria ser a nova cadeia');
        goto out
    end;

    if (exp2.typeof <> E_INTEGER) or (exp3.typeof <> E_INTEGER) then
    begin
        errorMsg ('O quarto e quinto argumentos deveriam ser inteiros');
        goto out
    end;

    s       := exp.pobj^.str;
    novo    := exp1.pobj^.str;
    ini     := exp2.int;
    fim     := exp3.int;

    delete (s, ini, fim - ini + 1);
    insert (novo, s, ini);

    freeExpr (exp);
    initExpr (exp, s);
    doAssignment (lvalue, exp);

    processaTroca := true;

out:
    freeLvalue (lvalue);
    freeExpr (exp);
    freeExpr (exp1);
    freeExpr (exp2)
end;

{--------------------------------------------------------}
{                   comando separa
{--------------------------------------------------------}

function processaSepara : boolean;
var
    l           : TList;
    lvalue      : LvalueRec;
    exp, s, sep : Operand;
    noBlanks    : boolean;
    i           : integer;
    pexp        : POperand;
begin
    processaSepara := false;

    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    evalExpr (s,   E_STRING);
    evalExpr (sep, E_STRING);

    noBlanks := false;
    if token.typeof = T_AMP then
    begin
        noBlanks := true;
        nextToken
    end;

    l := splitString (s.pobj^.str, sep.pobj^.str);

    if noBlanks then
    begin
        for i := 0 to l.count - 1 do
        begin
            pexp := POperand (l.Items[i]);
            pexp^.pobj^.str := trim (pexp^.pobj^.str)
        end
    end;

    initExpr (exp, l);
    doAssignment (lvalue, exp);

    freeLvalue (lvalue);
    freeExpr (s);
    freeExpr (sep);
    freeExpr (exp);

    processaSepara := true
end;

{--------------------------------------------------------}
{                   comando anexa
{--------------------------------------------------------}

function processaAnexa : boolean;
label
    out;
var
    l           : TList;
    lvalue      : LvalueRec;
    exp, exp1   : Operand;
begin
    processaAnexa := false;

    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    if token.typeof = T_EOL then
    begin
        if lvalue.ind.pobj^.dic.card = 0 then   { Não foram dados indexadores: ERRO }
        begin
            errorMsg ('O comando ANEXA espera listas como argumentos');
            goto out
        end;

        { O último indexador é, na verdade, a lista a anexar. Ex: ANEXA l [1,2,3] }

        removeLastIndexer (exp1, lvalue.ind.pobj^.dic)
    end
    else begin
        if token.typeof = T_VG then
            nextToken;

        evalExpr (exp1)
    end;

    evalLvalue (lvalue, exp);

    if (exp.typeof <> E_LIST) or (exp1.typeof <> E_LIST) then
    begin
        errorMsg ('O comando ANEXA espera listas como argumentos');
        goto out
    end;

    concatLists (l, exp.pobj^.list, exp1.pobj^.list);

    freeExpr (exp);
    initExpr (exp, l);
    doAssignment (lvalue, exp);

    processaAnexa := true;

out:
    freeLvalue (lvalue);
    freeExpr (exp);
    freeExpr (exp1)
end;

{--------------------------------------------------------}
{                   comando procura
{--------------------------------------------------------}

function processaProcura : boolean;
label
    out;
var
    lvalue             : LvalueRec;
    exp, lis, ini, val : Operand;
    partial, upper     : boolean;
    pos                : integer;
begin
    processaProcura := false;

    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    invalidateExpr (exp);
    invalidateExpr (ini);
    invalidateExpr (val);

    evalExpr (lis);

    if (lis.typeof <> E_LIST) then
    begin
        errorMsg ('O segundo argumento deveria ser uma LISTA');
        goto out
    end;

    evalExpr (ini, E_INTEGER);

    if (ini.typeof <> E_INTEGER) then
    begin
        errorMsg ('O terceiro argumento deveria ser a posição na lista');
        goto out
    end;

    evalExpr (val);

    if (val.typeof <> E_INTEGER) and (val.typeof <> E_STRING) then
    begin
        errorMsg ('O comando PROCURA busca apenas inteiros ou cadeias na lista');
        goto out
    end;

    partial := false;
    if tokenIsID ('PARCIAL') then
    begin
        partial := true;
        nextToken
    end;

    upper := false;
    if tokenIsID ('MAIUSC') then
    begin
        upper := true;
        nextToken
    end;

    if (upper or partial) and (val.typeof <> E_STRING) then
    begin
        errorMsg ('Os modificadores PARCIAL ou MAIUSC aplicam-se apenas à busca de cadeias na lista');
        goto out
    end;

    pos := searchList (lis.pobj^.list, ini.int, val, partial, upper);

    if (pos < 0) and (val.typeof = E_STRING) and (convertToInteger (val) = E_INTEGER) then
        pos := searchList (lis.pobj^.list, ini.int, val, partial, upper);

    initExpr (exp, pos);
    doAssignment (lvalue, exp);

    processaProcura := true;

out:
    freeLvalue (lvalue);
    freeExpr (exp);
    freeExpr (lis);
    freeExpr (ini);
    freeExpr (val)
end;

{--------------------------------------------------------}
{                   comando ordena
{--------------------------------------------------------}

{ Estas variáveis, infelizmente, devem ser globais; do contrário,
  a função "compara"  não consegue ter acesso a elas }

var
    global_ascending, global_upper, global_numeric : boolean;

function processaCmdOrdena : boolean;
label
    out;
var
    lvalue : LvalueRec;
    exp    : Operand;

    {----------------------------------------------------}
    {   compara dois itens da lista, usando as globais
    {----------------------------------------------------}

    function compareItems (item1 : Pointer; item2 : Pointer): integer;
    var
        pexp1, pexp2    : POperand;
        s1, s2          : string;
        ret, n1, n2,
        error1, error2  : integer;
        numbers         : boolean;
    begin
        pexp1   := POperand (item1);
        pexp2   := POperand (item2);

        numbers := false; n1 := 0; n2 := 0;  { Para o compilador ficar feliz }

        { Acerta os tipos }

        case JOINTYPES (pexp1^.typeof, pexp2^.typeof) of
            E_INTEGER_INTEGER:      begin
                                        n1 := pexp1^.int;
                                        n2 := pexp2^.int;
                                        numbers := true
                                    end;
            E_INTEGER_STRING:       begin
                                        n1 := pexp1^.int;
                                        s1 := intToStr (n1);
                                        s2 := pexp2^.pobj^.str;

                                        if global_numeric then
                                        begin
                                            val (s2, n2, error1);
                                            numbers := error1 = 0
                                        end
                                    end;
            E_STRING_INTEGER:       begin
                                        s1 := pexp1^.pobj^.str;
                                        n2 := pexp2^.int;
                                        s2 := intToStr (n2);

                                        if global_numeric then
                                        begin
                                            val (s1, n1, error2);
                                            numbers := error2 = 0
                                        end
                                    end;
            E_STRING_STRING:        begin
                                        s1 := pexp1^.pobj^.str;
                                        s2 := pexp2^.pobj^.str;

                                        if global_numeric then
                                        begin
                                            val (s1, n1, error1);
                                            val (s2, n2, error2);

                                            numbers := (error1 = 0) and (error2 = 0)
                                        end
                                    end
            else                    begin
                                        if pexp1^.typeof < pexp2^.typeof then
                                            ret := -1
                                        else if pexp1^.typeof = pexp2^.typeof then
                                            ret := 0
                                        else
                                            ret := -1;

                                        compareItems := ret;
                                        exit
                                    end
        end;

        { Realiza a comparação final }

        if numbers then
        begin
            ret := n1 - n2
        end
        else begin
            if global_upper then
            begin
                s1 := maiuscAnsi (s1);
                s2 := maiuscAnsi (s2)
            end;

            ret := CompareStr (s1, s2)
        end;

        if not global_ascending then
            ret := -ret;

        compareItems := ret
    end;

begin
    processaCmdOrdena := false;

    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    evalLvalue (lvalue, exp);

    if exp.typeof <> E_LIST then
    begin
        errorMsg ('Esperava uma lista para ordenar');
        goto out
    end;

    global_ascending := true;
    if tokenIsID ('DECRESCENTE') then
    begin
        global_ascending := false;
        nextToken
    end;

    global_numeric := false;
    if tokenIsID ('NUMERICO') then
    begin
        global_numeric := true;
        nextToken
    end;

    global_upper := false;
    if tokenIsID ('MAIUSC') then
    begin
        global_upper := true;
        nextToken
    end;

    exp.pobj^.list.Sort (@compareItems);

    processaCmdOrdena := true;
out:
    freeLvalue (lvalue);
    freeExpr (exp)
end;

end.

