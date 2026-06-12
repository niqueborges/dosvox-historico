{------------------------------------------------------------------------------}
{
{                                  NATIVE.PAS
{
{    Processamento das Funções Nativas do Interpretador ScriptVox
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Autor:      Oswaldo Vernet
{    Data:       21/08/2015
{    Alterações: 23/03/2016, 02/10/2018
{
{------------------------------------------------------------------------------}

unit NATIVE;

{------------------------------------------------------------------------------}
{                             I N T E R F A C E
{------------------------------------------------------------------------------}

interface

uses
    lex, symboltable, low, expr,
    dvinet, dvcomm, dvwin, dvcrt,
    sysutils, classes, math, strutils, messages;

{------------------------------------------------------------------------------}
{                           I M P L E M E N T A Ç Ã O
{------------------------------------------------------------------------------}

implementation

{--------------------------------------------------------}
{               formata tempos e horas
{--------------------------------------------------------}

function formatTime (a, b, c : word; sep : char) : string;
var
    s, ret : string;
begin
    str (a, s);
    if length (s) = 1 then s := '0' + s;
    ret := s;
    str (b, s);
    if length (s) = 1 then s := '0' + s;
    ret := ret + sep + s;
    str (c, s);
    if length (s) = 1 then s := '0' + s;

    formatTime := ret + sep + s
end;

{--------------------------------------------------------}
{         processa a função "data"
{--------------------------------------------------------}

function processaData : boolean;
var
    y, m, d, w : word;
begin
    getDate (y, m, d, w);
    initExpr (stack[BP].val.exp, formatTime (d, m, y, '/'));
    processaData := true
end;

{--------------------------------------------------------}
{         processa a função "dia"
{--------------------------------------------------------}

function processaDia : boolean;
const
    tabSemana   : array [0..6] of string[7] =
                  (
                    'Domingo', 'Segunda', 'Terça', 'Quarta',
                    'Quinta',  'Sexta',   'Sábado'
                  );
var
    y, m, d, w : word;
begin
    getDate (y, m, d, w);
    initExpr (stack[BP].val.exp, tabSemana[w]);
    processaDia := true
end;

{--------------------------------------------------------}
{         processa a função "false"
{--------------------------------------------------------}

function processaFalso : boolean;
begin
    initExpr (stack[BP].val.exp, 0);
    processaFalso := true
end;

{--------------------------------------------------------}
{         processa a função "hora"
{--------------------------------------------------------}

function processaHora : boolean;
var
    h, m, s, c : word;
begin
    gettime (h, m, s, c);
    initExpr (stack[BP].val.exp, formatTime (h, m, s, ':'));
    processaHora := true
end;

{--------------------------------------------------------}
{         processa a função "indefinido"
{--------------------------------------------------------}

function processaIndef : boolean;
begin
    initExpr (stack[BP].val.exp, E_UNDEF);
    processaIndef := true
end;

{--------------------------------------------------------}
{         processa a função "tempo"
{--------------------------------------------------------}

function processaTempo : boolean;
var
    y, m, d, w  : word;
    h, mi, s, c : word;
    nd, t       : integer;
begin
    getDate (y, m, d, w);
    gettime (h, mi, s, c);

    nd := w - week0;
    if nd < 0 then nd := nd + 7;

    h := h + nd * 24;
    t := ((h * 60 + mi) * 60 + s) * 100 + c;
    t := t - time0;

    initExpr (stack[BP].val.exp, IntToStr (t));

    processaTempo := true
end;

{--------------------------------------------------------}
{         processa a função "verdadeiro"
{--------------------------------------------------------}

function processaVerdadeiro : boolean;
begin
    initExpr (stack[BP].val.exp, 1);
    processaVerdadeiro := true
end;

{--------------------------------------------------------}
{         processa a função "chaves"
{--------------------------------------------------------}

function processaChaves : boolean;
var
    pexp : POperand;
begin
    pexp := @stack[BP-1].val.exp;

    if pexp^.typeof <> E_DIC then
        initExpr (stack[BP].val.exp, E_UNDEF)
    else
        initExpr (stack[BP].val.exp, dicKeys (pexp^.pobj^.dic));

    processaChaves := true
end;

{--------------------------------------------------------}
{         processa a função "chr"
{--------------------------------------------------------}

function processaChr : boolean;
var
    pexp : POperand;
begin
    pexp := @stack[BP-1].val.exp;

    if convertToInteger (pexp^) = E_INTEGER then
        initExpr (stack[BP].val.exp, '' + Chr (pexp^.int))
    else
        initExpr (stack[BP].val.exp, E_UNDEF);

    processaChr := true
end;

{--------------------------------------------------------}
{         processa a função "ord"
{--------------------------------------------------------}

function processaOrd : boolean;
var
    pexp : POperand;
begin
    pexp := @stack[BP-1].val.exp;

    if (pexp^.typeof = E_STRING) and (length (pexp^.pobj^.str) > 0) then
        initExpr (stack[BP].val.exp, Ord (pexp^.pobj^.str[1]))
    else
        initExpr (stack[BP].val.exp, E_UNDEF);

    processaOrd := true
end;

{--------------------------------------------------------}
{         processa a função "conteudo"
{--------------------------------------------------------}

function processaConteudo : boolean;
var
    l           : TList;
    f           : text;
    exp         : Operand;
    line, name  : string;
    status      : integer;
    modo        : (LISTA, JSON);
    pexp, parg  : POperand;
begin
    processaConteudo := false;

    pexp := @stack[BP-1].val.exp;
    parg := @stack[BP-2].val.exp;

    if pexp^.typeof <> E_STRING then exit;

    name := pexp^.pobj^.str;

    modo := LISTA;

    if parg^.typeof = E_STRING then
    begin
        if MaiuscAnsi (parg^.pobj^.str) = 'JSON' then
            modo := JSON
        else if MaiuscAnsi (parg^.pobj^.str) = 'LISTA' then
            modo := LISTA
        else begin
            initExpr (stack[BP].val.exp, E_UNDEF);
            exit
        end
    end;

{$I-}
    if modo = LISTA then
    begin
        l := TList.Create;

        assign (f, name);
        reset (f);

        status := ioresult;
        setIOStatus (CS, status);

        if status = 0 then
        begin
            while not eof (f) do
            begin
                readln (f, line);
                initExpr (exp, line);
                modifyList (l, exp);
                freeExpr (exp)
            end;

            initExpr (stack[BP].val.exp, l);
            close (f)
        end
    end
    else begin
        with files[MAXFILES - 1] do
        begin
            assign (filefd, name);
            reset (filefd);

            status := ioresult;
            setIOStatus (CS, status);

            if status = 0 then
            begin
                isOpen := true;
                typeof := F_FILE;

                readJSON (MAXFILES - 1, stack[BP].val.exp);

                isOpen := false;
                close (filefd)
            end;
        end;
    end;
{$I+}

   if status <> 0 then
       initExpr (stack[BP].val.exp, E_UNDEF);

    processaConteudo := true
end;

{--------------------------------------------------------}
{         processa a função "dir"
{--------------------------------------------------------}

function processaDiretorio : boolean;
var
    dir, s     : string;
    exp        : Operand;
    sr         : TSearchRec;
    attrib     : word;
    pexp, parg : POperand;
begin
    processaDiretorio := false;
    pexp := @stack[BP-1].val.exp;
    parg := @stack[BP-2].val.exp;

    if pexp^.typeof <> E_STRING then exit;

    dir := pexp^.pobj^.str;

    attrib := faAnyFile;

    if (parg^.typeof = E_STRING) then
    begin
        s := MaiuscAnsi (parg^.pobj^.str);

        if s = 'DIR' then
            attrib := faDirectory
        else if s = 'ARQ' then
            attrib := faArchive
        else if s = 'TUDO' then
            attrib := faAnyFile
        else
            errorMsg ('Argumento inválido para a função DIRETÓRIO: ' + s)
    end;

    initExpr (stack[BP].val.exp, E_LIST);

    if FindFirst (dir + '\*.*', attrib, sr) = 0 then
    begin
        repeat
            if ((sr.Attr and attrib) <> 0) and (sr.name <> '.') and (sr.name <> '..') then
            begin
                initExpr (exp, sr.FindData.cFileName);
                modifyList (stack[BP].val.exp.pobj^.list, exp);
                freeExpr (exp)
            end
        until FindNext (sr) <> 0
    end;

    FindClose (sr);

    processaDiretorio := true
end;

{--------------------------------------------------------}
{         processa a função "duplica"
{--------------------------------------------------------}

function processaDuplica : boolean;
var
    pexp : POperand;
begin
    processaDuplica := false;
    pexp := @stack[BP-1].val.exp;

    if not (pexp^.typeof in [E_STRING,E_DIC,E_LIST]) then exit;

    duplicateExpr (stack[BP].val.exp, pexp^);

    processaDuplica := true
end;

{--------------------------------------------------------}
{         processa a função "abrearq"
{--------------------------------------------------------}

function processaAbrearq : boolean;
var
    m                  : string;
    pexp, parg2, parg3 : POperand;
    status             : integer;
begin
    processaAbrearq := false;

    pexp  := @stack[BP-1].val.exp;
    parg2 := @stack[BP-2].val.exp;
    parg3 := @stack[BP-3].val.exp;

    setIOStatus (CS, 0);

    if (pexp^.typeof <> E_INTEGER) or not (pexp^.int in [0..MAXFILES-1]) then exit;

    if (parg2^.typeof <> E_STRING) or (parg3^.typeof <> E_STRING) then exit;

    m := maiuscAnsi (parg3^.pobj^.str);

    if (length (m) <> 1) or not (m[1] in ['L', 'E', 'A']) then exit;

    with files[pexp^.int] do
    begin
        if isOpen then
        begin
            setIOStatus (CS, 1);
            status     := 0
        end
        else begin
            assign (filefd, parg2^.pobj^.str);
{$I-}
            if      m = 'A' then append  (filefd)
            else if m = 'E' then rewrite (filefd)
            else                 reset   (filefd);
{$I+}
            if ioresult <> 0 then
            begin
                setIOStatus (CS, 1);
                status := 0
            end
            else begin
                setIOStatus (CS, 0);

                status := 1;
                isOpen := true;
                typeof := F_FILE
            end
        end
    end;

    initExpr (stack[BP].val.exp, status);

    processaAbrearq := true
end;

{--------------------------------------------------------}
{         processa a função "fimarq" ("fda")
{--------------------------------------------------------}

function processaEof : boolean;
var
    pexp : POperand;
begin
    processaEof := false;
    pexp := @stack[BP-1].val.exp;

    if (pexp^.typeof <> E_INTEGER) or not (pexp^.int in [0..MAXFILES-1]) then exit;

    with files[pexp^.int] do
        initExpr (stack[BP].val.exp, Ord ((typeof = F_FILE) and eof (filefd)));

    processaEof := true
end;

{--------------------------------------------------------}
{         processa a função "inteiro"
{--------------------------------------------------------}

function processaInteiro : boolean;
var
    pexp : POperand;
begin
    pexp := @stack[BP-1].val.exp;

    if convertToInteger (pexp^) = E_INTEGER then
        initExpr (stack[BP].val.exp, pexp^.int)
    else
        initExpr (stack[BP].val.exp, E_UNDEF);

    processaInteiro := true
end;

{--------------------------------------------------------}
{         processa a função "não"
{--------------------------------------------------------}

function processaNao : boolean;
var
    pexp : POperand;
begin
    processaNao := false;
    pexp := @stack[BP-1].val.exp;

    if convertToInteger (pexp^) <> E_INTEGER then exit;

    initExpr (stack[BP].val.exp, Ord (pexp^.int = 0));

    processaNao := true
end;

{--------------------------------------------------------}
{         processa a função "rand"
{--------------------------------------------------------}

function processaRand : boolean;
var
    pexp : POperand;
begin
    processaRand := false;
    pexp := @stack[BP-1].val.exp;

    if convertToInteger (pexp^) <> E_INTEGER then exit;

    initExpr (stack[BP].val.exp, random (Abs (pexp^.int)));

    processaRand := true
end;

{--------------------------------------------------------}
{         processa a função "tamanho"
{--------------------------------------------------------}

function processaTamanho : boolean;
var
    pexp : POperand;
begin
    pexp := @stack[BP-1].val.exp;
    doSIZE (pexp^);
    initExpr (stack[BP].val.exp, pexp^.int);
    processaTamanho := true
end;

{--------------------------------------------------------}
{         processa a função "trim"
{--------------------------------------------------------}

function processaTrim : boolean;
var
    s    : string;
    pexp : POperand;
begin
    processaTrim := false;
    pexp := @stack[BP-1].val.exp;

    if convertToString (pexp^) <> E_STRING then exit;

    s := trim (pexp^.pobj^.str);

    initExpr (stack[BP].val.exp, s);

    processaTrim := true
end;

{--------------------------------------------------------}
{         processa a função "tipo"
{--------------------------------------------------------}

function processaTipo : boolean;
var
    s    : string;
    pexp : POperand;
begin
    pexp := @stack[BP-1].val.exp;
    s := OperandTypeToString[pexp^.typeof];
    initExpr (stack[BP].val.exp, s);
    processaTipo := true
end;

{--------------------------------------------------------}
{         processa a função "maiusc"
{--------------------------------------------------------}

function processaMaiusc : boolean;
var
    s    : string;
    pexp : POperand;
begin
    processaMaiusc := false;
    pexp := @stack[BP-1].val.exp;

    if convertToString (pexp^) <> E_STRING then exit;

    s := maiuscAnsi (pexp^.pobj^.str);

    initExpr (stack[BP].val.exp, s);

    processaMaiusc := true
end;

{--------------------------------------------------------}
{         processa a função "map"
{--------------------------------------------------------}

function processaMap : boolean;
var
    func        : PSymtbEntry;
    i           : integer;
    ret, transf : Operand;
    pexp, parg  : POperand;
    args        : ARGVET;
begin
    processaMap := false;
    pexp := @stack[BP-1].val.exp;
    parg := @stack[BP-2].val.exp;

    if (pexp^.typeof <> E_STRING) or (parg^.typeof <> E_LIST) then exit;

    func := symboltable.getSymbol (CS, CF, normalize (pexp^.pobj^.str), false);

    if (func = NIL) or not (func^.typeof in [S_NFUNC,S_UFUNC]) or (func^.narg <> 1) then exit;

    initExpr (ret, E_LIST);

    with parg^.pobj^.list do
    begin
        for i := 0 to Count - 1 do
        begin
            if Items[i] = NIL then
            begin
                initExpr (transf, E_UNDEF)
            end
            else begin
                duplicateExpr (args[0], POperand (Items[i])^);
                callFunction (func^.id, func, transf, args, 1)  { freeExpr (args[0]) }
            end;

            modifyList (ret.pobj^.list, transf);
            freeExpr (transf);
        end
    end;

    stack[BP].val.exp := ret;     { copyExpr (stack[BP].val.exp, ret); freeExpr (ret); }

    processaMap := true
end;

{--------------------------------------------------------}
{         processa a função "pos"
{--------------------------------------------------------}

function processaPos : boolean;
var
    res        : Operand;
    pexp, parg : POperand;
begin
    processaPos := false;
    pexp := @stack[BP-1].val.exp;
    parg := @stack[BP-2].val.exp;

    if parg^.typeof = E_LIST then
    begin
        initExpr (res, searchList (parg^.pobj^.list, 0, pexp^));
    end
    else begin
        if (convertToString (pexp^) <> E_STRING) or (parg^.typeof <> E_STRING) then
            exit;

        initExpr (res, pos (pexp^.pobj^.str, parg^.pobj^.str));
    end;

    stack[BP].val.exp := res;      { copyExpr (stack[BP].val.exp, res); freeExpr (res); }

    processaPos := true
end;

{--------------------------------------------------------}
{         processa a função "palavra"
{--------------------------------------------------------}

function processaPalavra : boolean;
var
    l          : TList;
    pexp, parg : POperand;
begin
    processaPalavra := false;
    pexp := @stack[BP-1].val.exp;
    parg := @stack[BP-2].val.exp;

    if (convertToInteger (pexp^) <> E_INTEGER) or (parg^.typeof <> E_STRING) then exit;

    l := splitString (parg^.pobj^.str);

    if (pexp^.int > 0) and (pexp^.int <= l.Count) then
    begin
        copyExpr (stack[BP].val.exp, POperand (l.Items[pexp^.int - 1])^)
    end
    else begin
        initExpr (stack[BP].val.exp, E_UNDEF)
    end;

    emptyList (l);

    processaPalavra := true
end;

{--------------------------------------------------------}
{         processa a função "insere"
{--------------------------------------------------------}

function processaInsere : boolean;
var
    i                  : integer;
    pexp, parg2, parg3 : POperand;
begin
    processaInsere := true;
    pexp  := @stack[BP-1].val.exp;
    parg2 := @stack[BP-2].val.exp;
    parg3 := @stack[BP-3].val.exp;

    if (pexp^.typeof = E_LIST) and (convertToInteger (parg2^) = E_INTEGER) and (parg3^.typeof <> E_INVAL) then
    begin
        i := ord (insertList (pexp^.pobj^.list, parg2^.int, parg3^));
        initExpr (stack[BP].val.exp, i)
    end
    else if (pexp^.typeof = E_DIC) and (parg2^.typeof in [E_INTEGER,E_STRING]) and (parg3^.typeof <> E_INVAL) then
    begin
        modifyDic (pexp^.pobj^.dic, parg2^, parg3^);
        initExpr (stack[BP].val.exp, 1)
    end
    else begin
        processaInsere := false
    end
end;

{--------------------------------------------------------}
{         processa a função "retira"
{--------------------------------------------------------}

function processaRetira : boolean;
var
    aux        : Operand;
    pexp, parg : POperand;
begin
    processaRetira := true;
    pexp := @stack[BP-1].val.exp;
    parg := @stack[BP-2].val.exp;

    if (pexp^.typeof = E_LIST) and (convertToInteger (parg^) = E_INTEGER) then
    begin
        removeList (pexp^.pobj^.list, parg^.int, aux);

        if aux.typeof = E_INVAL then
            initExpr (stack[BP].val.exp, E_UNDEF)
        else
            stack[BP].val.exp := aux       { copyExpr (stack[BP].val.exp, aux); freeExpr (aux); }
    end
    else if (pexp^.typeof = E_DIC) and (parg^.typeof in [E_INTEGER,E_STRING]) then
    begin
        removeDic (pexp^.pobj^.dic, parg^, aux);

        if aux.typeof = E_INVAL then
            initExpr (stack[BP].val.exp, E_UNDEF)
        else
            stack[BP].val.exp := aux       { copyExpr (stack[BP].val.exp, aux); freeExpr (aux); }
    end
    else begin
        processaRetira := false
    end
end;

{--------------------------------------------------------}
{      instala as funções na tabela de símbolos
{--------------------------------------------------------}

const
    NFUNC = 31;

    func : array [1..NFUNC] of SymtbEntry =
    (
        ( id : 'ABREARQ';      typeof: S_NFUNC;   fexec: processaAbrearq;     narg:  3;    excep: [FE_SUS] ),
        ( id : 'CHAVES';       typeof: S_NFUNC;   fexec: processaChaves;      narg:  1;    excep: [] ),
        ( id : 'CHR';          typeof: S_NFUNC;   fexec: processaChr;         narg:  1;    excep: [] ),
        ( id : 'CONTEUDO';     typeof: S_NFUNC;   fexec: processaConteudo;    narg:  2;    excep: [FE_VARARG] ),
        ( id : 'DATA';         typeof: S_NFUNC;   fexec: processaData;        narg:  0;    excep: [] ),
        ( id : 'DIA';          typeof: S_NFUNC;   fexec: processaDia;         narg:  0;    excep: [] ),
        ( id : 'DIRETORIO';    typeof: S_NFUNC;   fexec: processaDiretorio;   narg:  2;    excep: [FE_VARARG] ),
        ( id : 'DUPLICA';      typeof: S_NFUNC;   fexec: processaDuplica;     narg:  1;    excep: [] ),
        ( id : 'FALSE';        typeof: S_NFUNC;   fexec: processaFalso;       narg:  0;    excep: [] ),
        ( id : 'FALSO';        typeof: S_NFUNC;   fexec: processaFalso;       narg:  0;    excep: [] ),
        ( id : 'FIMARQ';       typeof: S_NFUNC;   fexec: processaEof;         narg:  1;    excep: [FE_SUS] ),
        ( id : 'FDA';          typeof: S_NFUNC;   fexec: processaEof;         narg:  1;    excep: [FE_SUS] ),
        ( id : 'HORA';         typeof: S_NFUNC;   fexec: processaHora;        narg:  0;    excep: [] ),
        ( id : 'INDEFINIDO';   typeof: S_NFUNC;   fexec: processaIndef;       narg:  0;    excep: [] ),
        ( id : 'INSERE';       typeof: S_NFUNC;   fexec: processaInsere;      narg:  3;    excep: [] ),
        ( id : 'INTEIRO';      typeof: S_NFUNC;   fexec: processaInteiro;     narg:  1;    excep: [] ),
        ( id : 'MAIUSC';       typeof: S_NFUNC;   fexec: processaMaiusc;      narg:  1;    excep: [] ),
        ( id : 'MAP';          typeof: S_NFUNC;   fexec: processaMap;         narg:  2;    excep: [] ),
        ( id : 'NAO';          typeof: S_NFUNC;   fexec: processaNao;         narg:  1;    excep: [] ),
        ( id : 'NULL';         typeof: S_NFUNC;   fexec: processaIndef;       narg:  0;    excep: [] ),
        ( id : 'ORD';          typeof: S_NFUNC;   fexec: processaOrd;         narg:  1;    excep: [] ),
        ( id : 'PALAVRA';      typeof: S_NFUNC;   fexec: processaPalavra;     narg:  2;    excep: [] ),
        ( id : 'POS';          typeof: S_NFUNC;   fexec: processaPos;         narg:  2;    excep: [] ),
        ( id : 'RAND';         typeof: S_NFUNC;   fexec: processaRand;        narg:  1;    excep: [] ),
        ( id : 'RETIRA';       typeof: S_NFUNC;   fexec: processaRetira;      narg:  2;    excep: [] ),
        ( id : 'TAMANHO';      typeof: S_NFUNC;   fexec: processaTamanho;     narg:  1;    excep: [] ),
        ( id : 'TEMPO';        typeof: S_NFUNC;   fexec: processaTempo;       narg:  0;    excep: [] ),
        ( id : 'TIPO';         typeof: S_NFUNC;   fexec: processaTipo;        narg:  1;    excep: [] ),
        ( id : 'TRIM';         typeof: S_NFUNC;   fexec: processaTrim;        narg:  1;    excep: [] ),
        ( id : 'TRUE';         typeof: S_NFUNC;   fexec: processaVerdadeiro;  narg:  0;    excep: [] ),
        ( id : 'VERDADEIRO';   typeof: S_NFUNC;   fexec: processaVerdadeiro;  narg:  0;    excep: [] )
    );

procedure installNativeFunctions;
var
    i : integer;
begin
    for i := 1 to NFUNC do
        symboltable.defineStaticSymbol (@func[i])
end;

begin
    installNativeFunctions
end.

