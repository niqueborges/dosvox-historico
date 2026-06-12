{------------------------------------------------------------------------------}
{
{                                COMPILE.PAS
{
{    Pré-Compilação e Embelezamento de Scripts
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Autor:      Oswaldo Vernet
{    Data:       21/08/2015
{    Alterações:
{
{------------------------------------------------------------------------------}

unit COMPILE;

{------------------------------------------------------------------------------}
{                             I N T E R F A C E
{------------------------------------------------------------------------------}

interface

uses
    lex, symboltable, low, expr,
    sysutils;

function preCompile     (s : integer) : boolean;
function beautifyScript (s : integer; pro : string) : integer;

{------------------------------------------------------------------------------}
{                           I M P L E M E N T A Ç Ã O
{------------------------------------------------------------------------------}

implementation

{--------------------------------------------------------}
{            processa o script corrente
{--------------------------------------------------------}

function preCompile (s : integer) : boolean;
label
    again, error;
const
    NEST_LIMIT    = 8196;
type
    StackRec = record
        typeof    : S_IF .. S_LOOP;
        command   : string;
        line      : integer
    end;
var
    stack         : array [1..NEST_LIMIT] of StackRec;
    nargs         : integer;
    top, final    : integer;
    lin, t, euse  : integer;
    p             : PSymtbEntry;
    saveCompiling,
    saveVerbose   : boolean;
    scope         : PSymtbEntry;
    saveToken     : TokenRec;

    function push (cmd : string) : boolean;
    begin
        if top < NEST_LIMIT then
        begin
            INC (top);
            with stack[top] do
            begin
                typeof  := p^.typeof;
                command := cmd;
                line    := lin
            end;
            push := true
        end
        else begin
            errorMsg ('Mais de ' + intToStr (NEST_LIMIT) + ' comandos aninhados!');
            push := false
        end
    end;

    function isCommand (s : SymbolTypeSet) : PSymtbEntry;
    var
        p : PSymtbEntry;
    begin
        isCommand := NIL;

        if token.typeof = T_ID then
        begin
            p := symboltable.getCommand (token.id);

            if (p <> NIL) and (p^.typeof in s) then
                isCommand := p
        end
    end;

    procedure doesntMatch;
    begin
        errorMsg (lin, 'Comando FIM ' + token.id + ' não corresponde ao comando ' +
                             stack[top].command + ' na linha ' + intToStr (stack[top].line))
    end;

    procedure ImportModule;
    var
        sel, path : string;
        scr       : integer;
        q         : PSymtbEntry;
    begin
        if nextToken <> T_ID then
        begin
        end;

        sel := token.id;

        if nextToken <> T_STR then
        begin
        end;

        path := token.id;

        scr := low.loadScript (path);
        if scr < 0 then
        begin
            errorMsg ('Erro na leitura do script "' + path + '"');
            exit
        end;

        if not preCompile (scr) then
        begin
            errorMsg ('O script "' + path + '" apresenta erros sintáticos');
            exit
        end;

        q := symboltable.getSymbol (s, NIL, sel, true);

        if q <> NIL then
        begin
            q^.typeof := S_MOD;
            q^.offset := scr
        end
    end;

begin
    if s < 0 then
    begin
        preCompile := false;
        exit
    end;

    if isCompiled (s) then
    begin
        preCompile := true;
        exit
    end;

    preCompile     := false;

    saveVerbose    := verbose;      { Salva o estado }
    saveCompiling  := compiling;
    saveToken      := token;

    compiling      := true;         { Avisa que está compilando! }
    verbose        := true;         { Mensagens de erro ativas durante a pre-compilação }

    top            := 0;            { Base da pilha de comandos aninhados }
    scope          := NIL;          { Escopo atual = GLOBAL }

    for lin := 1 to finalLine (s) do
    begin
        setCurrentLine (s, lin);
        setScope       (s, lin, scope);
        setFollowing   (s, lin, lin + 1);

        if nextToken = T_EOL then
            continue;

        if token.typeof = T_ROT then
        begin
            if not symboltable.defineLabel (s, scope, token.id, lin) then
            begin
                errorMsg ('Rótulo "' + token.id + '" desconsiderado');
                goto error
            end;

            if nextToken = T_CL then
                nextToken
        end;

        if token.typeof <> T_ID then
            continue;

        p := symboltable.getCommand (token.id);

        if p = NIL then                     { Atribuição }
            continue;

        setCachedCommand (s, lin, p);       { É um comando! Guarda para evitar consultas ao hash }

again:
        case p^.typeof of
            S_COMM:     begin
                            if p^.id = 'LOCAL' then
                            begin
                                if scope = NIL then
                                begin
                                    errorMsg (lin, 'O comando LOCAL só é válido no corpo de uma função');
                                    goto error
                                end;

                                if top > 1 then
                                begin
                                    errorMsg (lin, 'O comando LOCAL não pode estar no corpo de um comando iterativo');
                                    goto error
                                end
                            end
                            else if p^.id = 'IMPORTA' then
                            begin
                                if scope <> NIL then
                                begin
                                    errorMsg (lin, 'O comando IMPORTA não pode estar no corpo de uma função');
                                    goto error
                                end;

                                if top > 1 then
                                begin
                                    errorMsg (lin, 'O comando IMPORTA não pode estar no corpo de um comando iterativo');
                                    goto error
                                end;

                                ImportModule
                            end
                        end;
            S_CFUNC:    begin
                            if (scope <> NIL) or (top <> 0) then
                            begin
                                errorMsg (lin, 'Funções não podem estar aninhadas em comandos ou em outras funções');
                                goto error
                            end;

                            if nextToken <> T_ID then
                            begin
                                errorMsg (lin, 'Esperava o nome da função');
                                goto error
                            end;

                            scope := symboltable.getSymbol (s, NIL, token.id, false);

                            if scope <> NIL then
                            begin
                                errorMsg (lin, '"' + token.id + '" já é um identificador de ' + SymbolTypeToStr[scope^.typeof] + '; não pode ser nome de função');
                                goto error
                            end;

                            scope         := symboltable.getSymbol (s, NIL, token.id, true);
                            scope^.typeof := S_UFUNC;
                            scope^.start  := lin;

                            setScope (s, lin, scope);

                            if not push ('FUNCAO') then goto error;

                            nargs := 0;

                            if nextToken = T_LP then
                            begin
                                repeat
                                    nextToken;
                                    if token.typeof in [T_CL,T_RP,T_EOL] then
                                        break;
                                    if token.typeof = T_ID then
                                        INC (nargs)
                                until false
                            end;

                            scope^.nargs := nargs;
                            scope^.local := 0
                        end;
            S_IF:       begin
                            nextToken; skipExpr;                   { Pula a expressão }

                            if (token.typeof = T_ID) and (token.id = 'ENTAO') then
                                nextToken;

                            if token.typeof = T_EOL then
                            begin
                                if not push ('SE') then goto error
                            end
                            else begin                                    { Há comando na mesma linha }
                                setCachedCommand (s, lin, UnitaryIfPtr);  { Muda o comando para S_UIF }

                                p := symboltable.getCommand (token.id);

                                if p <> NIL then
                                begin
                                    if p^.id = 'LOCAL' then
                                    begin
                                        errorMsg (lin, 'O comando LOCAL não pode aparecer na mesma linha do comando SE');
                                        goto error
                                    end;
                                    if p^.id = 'IMPORTA' then
                                    begin
                                        errorMsg (lin, 'O comando IMPORTA não pode aparecer na mesma linha do comando SE');
                                        goto error
                                    end;

                                    if not (p^.typeof in [S_VAR,S_MOD,S_NFUNC,S_UFUNC,S_COMM,S_BREAK,S_CONT]) then
                                    begin
                                        errorMsg (lin, 'Esperava um comando simples na mesma linha do comando SE');
                                        goto error
                                    end;

                                    if p^.typeof in [S_BREAK,S_CONT] then goto again
                                end
                            end
                        end;
            S_ELSE:     begin
                            if (top <= 0) or not (stack[top].typeof in [S_IF,S_ELIF]) then
                            begin
                                errorMsg (lin, 'Comando SENÃO sobrando');
                                goto error
                            end;

                            if not push ('SENÃO') then goto error;

                            nextToken;
                            if isCommand ([S_IF]) <> NIL then
                            begin
                                nextToken; skipExpr;               { Pula a expressão }

                                if (token.typeof = T_ID) and (token.id = 'ENTAO') then
                                    nextToken;

                                if token.typeof <> T_EOL then             { Há comando na mesma linha }
                                begin
                                    errorMsg (lin, 'O comando SE de uma linha não é permitido após SENÃO');
                                    goto error
                                end;

                                stack[top].typeof  := S_ELIF;
                                stack[top].command := 'SENÃO SE';
                            end
                            else begin
                                if token.typeof <> T_EOL then goto error
                            end
                        end;
            S_BREAK,
            S_CONT:     begin
                            t := top;
                            while (t > 0) and (stack[t].typeof <> S_LOOP) do
                                DEC (t);

                            if t <= 0 then
                            begin
                                errorMsg (lin, 'Comando ' + p^.id + ' fora de um comando iterativo');
                                goto error
                            end;

                            setGoTo (s, lin, stack[t].line)
                        end;
            S_LOOP:     if not push (token.id) then exit;
            S_END:      begin
                            if top <= 0 then
                            begin
                                errorMsg (lin, 'Comando FIM sobrando');
                                goto error
                            end;

                            nextToken; p := isCommand ([S_IF, S_CFUNC, S_LOOP]);

                            if p = NIL then
                            begin
                                errorMsg (lin, 'Esperava o complemento do comando FIM');
                                goto error
                            end;

                            case p^.typeof of
                                S_CFUNC:    begin
                                                if p^.typeof <> stack[top].typeof then
                                                begin
                                                    doesntMatch;
                                                    goto error
                                                end;

                                                setGoTo          (s, stack[top].line, lin);
                                                setCachedCommand (s, lin, ReturnCmdPtr);   { Troca pelo comando RETORNA }

                                                DEC (top);

                                                scope^.finish := lin;
                                                scope := NIL
                                            end;
                                S_IF:       begin
                                                euse := lin; final := lin; t := top;

                                                while (t > 0) and (stack[t].typeof in [S_ELSE,S_ELIF]) do
                                                begin
                                                    setGoTo      (s, stack[t].line, euse);
                                                    setFollowing (s, stack[t].line - 1, final);
                                                    euse := stack[t].line;
                                                    DEC (t)
                                                end;

                                                if (t <= 0) or (stack[t].typeof <> S_IF) then
                                                begin
                                                    doesntMatch;
                                                    goto error
                                                end;

                                                setGoTo (s, stack[t].line, euse);

                                                DEC (t); top := t;
                                                setGoTo (s, lin, lin + 1)
                                            end;
                                S_LOOP:     begin
                                                if p^.id <> stack[top].command then
                                                begin
                                                    doesntMatch;
                                                    goto error
                                                end;

                                                setGoTo (s, lin, stack[top].line);
                                                setGoTo (s, stack[top].line, lin);
                                                DEC (top)
                                            end
                            end
                        end
            else begin
                { outros comandos: nada a tratar }
            end
        end
    end;

    if top > 0 then
    begin
        DEC (lin);
        errorMsg (lin, 'Faltou finalizar o comando ' + stack[top].command + ', iniciado na linha ' + IntToStr (stack[top].line));
        goto error
    end;

    preCompile := true;
    setCompiled (s, true);

{   printScript (s);
    scWriteln ('Última linha: ', finalLine (s)); readln;  } 

error:
    setPC (s, lin);                { Guarda no PC a última linha processada }

    compiling := saveCompiling;    { Não está mais compilando! }
    verbose   := saveVerbose;
    token     := saveToken
end;

{--------------------------------------------------------}
{            embeleza o script corrente
{--------------------------------------------------------}

function beautifyCMDScript (s : integer; var saida : text) : integer;
var
    lin, level, incr, conv : integer;
    p                      : PSymtbEntry;
    lastCmd, cmd           : SymbolType;
    print                  : boolean;
    euse, line, lastLine   : string;

    procedure putBlanks (n : integer);
    var
        i : integer;
    begin
        for i := 1 to n do
            write (saida, TAB);
    end;

begin
    level := 1; lastLine := ''; conv := 0; lastCmd := S_COMM;

    for lin := 1 to finalLine (s) do
    begin
        setCurrentLine (s, lin);

        line := trim (getLine (s, lin)); nextToken;

        if token.typeof = T_ROT then
        begin
            if lastLine <> '' then
                writeln (saida);
            writeln (saida, line);
            continue
        end;

        if token.typeof <> T_ID then
        begin
            writeln (saida, line);
            continue
        end;

        p := symboltable.getCommand (token.id);

        if p = NIL then
            cmd := S_COMM
        else
            cmd := p^.typeof;

        if (lastCmd = S_ELSE) and (cmd <> S_IF) then
        begin
            putBlanks (level - 1);
            writeln (saida, 'senao')
        end;

        print := true; euse := ''; incr := 0;

        case cmd of
            S_IF:       begin
                            nextToken; skipExpr;

                            if tokenIsID ('ENTAO') then
                                nextToken;

                            if token.typeof = T_EOL then
                            begin
                                if lastCmd = S_ELSE then
                                begin
                                    DEC (level);
                                    euse := 'senao ';
                                    INC (conv)
                                end;
                                incr := 1
                            end
                        end;
            S_ELSE:     begin
                            nextToken;
                            if tokenIsID ('SE') then
                            begin
                                cmd := S_ELIF;
                                DEC (level);
                                incr := 1
                            end
                            else
                            begin
                                print := false
                            end
                        end;
            S_LOOP:     incr := 1;
            S_END:      DEC (level);
            else        ;
        end;

        if print then
        begin
            putBlanks (level);
            writeln (saida, euse + line)
        end;

        level  := level + incr;

        lastCmd := cmd; lastLine := line
    end;

    beautifyCMDScript := conv
end;

function beautifyScript (s : integer; pro : string) : integer;
var
    f : text;
begin
{$I-}
    assign (f, pro);
    rewrite (f);
    if ioresult <> 0 then
    begin
        beautifyScript := -1;
        exit
    end;

    beautifyScript := beautifyCMDScript (s, f);

    close (f)
{$I+}
end;

begin
end.
