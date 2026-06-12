{------------------------------------------------------------------------------}
{
{                               SYMBOLTABLE.PAS
{
{    Gerência da Tabela de Símbolos
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Autor:      Oswaldo Vernet
{    Data:       21/08/2015
{    Alterações:
{
{------------------------------------------------------------------------------}

unit SYMBOLTABLE;

{------------------------------------------------------------------------------}
{                             I N T E R F A C E
{------------------------------------------------------------------------------}

interface

uses
    lex, sysUtils;

{**************************** A Tabela de Símbolos ****************************}

type
    PSymtbEntry         = ^SymtbEntry;

    SymbolType          = (
                                S_UNDEF,                                        { Indefinido }
                                S_COMM,                                         { Comando }
                                S_IF, S_UIF, S_ELSE, S_ELIF,                    { Comandos SE, SENÃO e SENÃO SE }
                                S_CFUNC,                                        { Comando FUNÇÃO }
                                S_LOOP,                                         { Comandos iterativos }
                                S_BREAK, S_CONT,                                { Comandos QUEBRA e CONTINUA }
                                S_END,                                          { Comando FIM }
                                S_ROT,                                          { Rótulo }
                                S_VAR,                                          { Variável }
                                S_MOD,                                          { Descritor de módulo }
                                S_NFUNC,                                        { Função nativa }
                                S_UFUNC                                         { Função definida pelo usuário }
                          );

    SymbolTypeSet       = set of SymbolType;
    FunExcep            = ( FE_SUS, FE_VARARG );
    ExecuteCmd          = function : boolean;
    ExecuteFun          = function (exp : pointer; arg : pointer) : boolean;

    SymtbEntry          = record
                              id        : string;                               { Identificador }

                              script    : integer;                              { Escopo }
                              scope     : PSymtbEntry;

                              snext     : PSymtbEntry;                          { Próximo  na lista de símbolos }
                              hnext     : PSymtbEntry;                          { Próximo  na cadeia de colisões }
                              hprev     : PSymtbEntry;                          { Anterior na cadeia de colisões }

                              case typeof : SymbolType of                       { Tipo do símbolo }
                                  S_COMM,
                                  S_IF, S_UIF, S_ELSE, S_ELIF,
                                  S_CFUNC,
                                  S_LOOP,
                                  S_BREAK, S_CONT,
                                  S_END:        ( exec     : ExecuteCmd );      { Processamento do comando }
                                  S_ROT:        ( line     : integer );         { Linha em que foi definido o rótulo }
                                  S_VAR, S_MOD: ( val      : pointer;           { Valor (só para variáveis globais) }
                                                  offset   : integer );         { Deslocamento (para variáveis na pilha) }
                                  S_NFUNC:      ( fexec    : ExecuteCmd;        { Processamento da função nativa }
                                                  narg     : integer;           { Número de argumentos }
                                                  excep    : set of FunExcep ); { Exceções }
                                  S_UFUNC:      ( start,                        { Linha inicial }
                                                  finish,                       { Linha final }
                                                  nargs,                        { Número de argumentos }
                                                  local    : integer );         { Número de variáveis locais }
                          end;

const
    SymbolTypeToStr     : array [SymbolType] of string[20] =                    { Nome de cada um dos tipos de símbolos }
                          (
                                'indefinido', 'comando', 'comando',  'comando',
                                'comando',    'comando', 'comando',  'comando',
                                'comando',    'comando', 'comando',  'rótulo',
                                'variável',   'referência a módulo', 'função nativa',
                                'função'
                          );

var
    UnitaryIfPtr        : PSymtbEntry;                                          { Referência para o comando SE unitário }
    AssignmentPtr       : PSymtbEntry;                                          { Referência para o comando := }
    EvaluationPtr       : PSymtbEntry;                                          { Referência para o comando := }
    ReturnCmdPtr        : PSymtbEntry;                                          { Referência para o comando RETORNA }

procedure defineStaticSymbol         (q : PSymtbEntry);
function  defineLocalVariable        (s : integer; sc : PSymtbEntry; id : string; offset : integer) : PSymtbEntry;
function  defineLabel                (s : integer; sc : PSymtbEntry; id : string; line : integer) : boolean;
function  getVariable                (s : integer; sc : PSymtbEntry; id : string) : PSymtbEntry;
function  getSymbol                  (s : integer; sc : PSymtbEntry; id : string; define : boolean) : PSymtbEntry;
function  getLabel                   (s : integer; sc : PSymtbEntry; id : string): integer;
function  getCommand                 (id : string) : PSymtbEntry;
procedure removeAllSymbols           (s : integer);
function  sizeOfLargestCollisionList () : integer;
function  getFirstSymbol             () : PSymtbEntry;
function  getNextSymbol              (p : PSymtbEntry) : PSymtbEntry;

{------------------------------------------------------------------------------}
{                           I M P L E M E N T A Ç Ã O
{------------------------------------------------------------------------------}

implementation

const
    HASH_SIZE     = 4001;             { Número primo bem grande }

type
    HASH_RANGE    = 0 .. HASH_SIZE - 1;
    HashTableType = array [HASH_RANGE] of PSymtbEntry;

var
    hashTable     : HashTableType;    { Tabela "hash" }

    firstSymbol   : SymtbEntry;       { Início e fim da tabela de símbolos }
    lastSymbol    : PSymtbEntry;

{------------------------------------------------------------------------------}
{      calcula o "hash" de um identificador
{------------------------------------------------------------------------------}

function hash (id : string) : HASH_RANGE;
var
    i, len  : integer;
    sum     : int64;
begin
    len := length (id);
    sum := 0;

    for i := 1 to len do
        sum := (sum shl 1) xor ord (id[i]);

    hash := Abs (sum) mod HASH_SIZE
end;

{------------------------------------------------------------------------------}
{      define um símbolo estático
{------------------------------------------------------------------------------}

procedure defineStaticSymbol (q : PSymtbEntry);
var
    p : ^PSymtbEntry;                 { Ponteiro duplo! }
begin
    { Símbolos estáticos são inseridos apenas na tabela hash.
      O nó já vem pronto, não é preciso criar! }

    p         := @hashTable[hash (q^.id)];

    q^.script := -1;                  { São independentes de script }
    q^.scope  := NIL;
    q^.snext  := NIL;
    q^.hnext  := p^;                  { Insere no início da lista de colisão }
    q^.hprev  := NIL;

    if p^ <> NIL then
        p^^.hprev := q;

    p^ := q
end;

{------------------------------------------------------------------------------}
{      busca uma variável (ou função)
{------------------------------------------------------------------------------}

function getVariable (s : integer; sc : PSymtbEntry; id : string) : PSymtbEntry;
var
    local, global, p : PSymtbEntry;
begin
    local := NIL; global := NIL;

    p := hashTable[hash (id)];        { Início da lista de colisão }

    while p <> NIL do                 { Percorre toda a lista de colisões }
    begin
        if (p^.id = id) and ((p^.script < 0) or (p^.script = s)) then
        begin
            if p^.scope = NIL then
                global := p
            else if p^.scope = sc then
                local := p
        end;

        p := p^.hnext
    end;

    if local = NIL then local := global;

    getVariable := local
end;

{------------------------------------------------------------------------------}
{      busca um símbolo, definindo-o se requerido
{------------------------------------------------------------------------------}

function getSymbol (s : integer; sc : PSymtbEntry; id : string; define : boolean) : PSymtbEntry;
var
    h           : integer;
    p, q, ant   : PSymtbEntry;
begin
    h := hash (id);

    ant := NIL;
    p   := hashTable[h];              { Busca na lista de colisões }

    while p <> NIL do
    begin
        if (p^.id = id) and ((p^.typeof in [S_COMM..S_END,S_NFUNC]) or (((p^.script < 0) or (p^.script = s)) and (p^.scope = sc))) then
        begin
            getSymbol := p;           { Achou! }
            exit
        end;

        ant := p;                     { Colidiu: tenta o próximo }
        p   := p^.hnext
    end;

    q := NIL;                         { Prepara o retorno }

    if define then                    { O símbolo é novo e deve ser definido }
    begin
        try NEW (q) except end;

        if q <> NIL then
        begin
            if (sc = NIL) and (id[1] = '$') then
                q^.script := -1       { Superglobal }
            else
                q^.script := s;

            q^.id     := id;
            q^.scope  := sc;
            q^.snext  := NIL;
            q^.typeof := S_UNDEF;     { Inicialmente não sabemos o tipo }

            q^.val    := NIL;         { ... tampouco o valor }

            q^.hnext  := p;           { Insere na lista de colisões }
            q^.hprev  := ant;

            if p <> NIL then
                p^.hprev      := q;

            if ant = NIL then
                hashTable[h]  := q
            else
                ant^.hnext    := q;

            lastSymbol^.snext := q;   { Insere também na lista de símbolos }
            lastSymbol        := q
        end
        else begin
            errorMessage ('Memória insuficiente')
        end
    end;

    getSymbol := q
end;

{------------------------------------------------------------------------------}
{      define uma variável local (ou parâmetro)
{------------------------------------------------------------------------------}

function defineLocalVariable (s : integer; sc : PSymtbEntry; id : string; offset : integer) : PSymtbEntry;
var
    p : PSymtbEntry;
begin
    p := getSymbol (s, sc, id, true);

    if not (p^.typeof in [S_VAR,S_UNDEF]) then
    begin
        errorMessage ('"' + id + '" é identificador de ' + SymbolTypeToStr[p^.typeof] + ', não pode ser uma variável local ou parâmetro');
        defineLocalVariable := NIL;
        exit
    end;

    p^.typeof := S_VAR;
    p^.offset := offset;

{   scWriteln ('Variável local: ' + id + ', desloc = ' + intToStr (desloc)); }

    defineLocalVariable := p;
end;

{------------------------------------------------------------------------------}
{      define um rótulo
{------------------------------------------------------------------------------}

function defineLabel (s : integer; sc : PSymtbEntry; id : string; line : integer) : boolean;
var
    p : PSymtbEntry;
begin
    defineLabel := false;

    p := getSymbol (s, sc, id, true);

    if p = NIL then exit;

    if p^.typeof = S_UNDEF then
    begin
        p^.typeof     := S_ROT;       { Define o rótulo }
        p^.line       := line;
        defineLabel   := true
    end
    else if p^.typeof = S_ROT then
    begin
        errorMessage ('Rótulo "' + id + '" já foi definido na linha ' + intToStr (p^.line))
    end
end;

{------------------------------------------------------------------------------}
{      busca um rótulo
{------------------------------------------------------------------------------}

function getLabel (s : integer; sc : PSymtbEntry; id : string): integer;
var
    p : PSymtbEntry;
begin
    if (length (id) = 0) or (id[1] <> '@') then
        id := '@' + id;

    p := getSymbol (s, sc, lex.normalize (id), false);

    if (p = NIL) or (p^.typeof <> S_ROT) then
        getLabel := -1
    else
        getLabel := p^.line
end;

{------------------------------------------------------------------------------}
{      busca um comando
{------------------------------------------------------------------------------}

function getCommand (id : string) : PSymtbEntry;
var
    p : PSymtbEntry;
begin
    p := hashTable[hash (id)];        { Início da lista de colisão }

    while p <> NIL do                 { Busca na lista de colisões }
    begin
        if (p^.id = id) and (p^.typeof in [S_COMM..S_END]) then
            break;

        p := p^.hnext
    end;

    getCommand := p
end;

{------------------------------------------------------------------------------}
{      apaga os símbolos de um script
{------------------------------------------------------------------------------}

procedure removeAllSymbols (s : integer);
var
    ant, p  : PSymtbEntry;
    h       : integer;
begin
    ant := @firstSymbol; p := ant^.snext;

    while p <> NIL do
    begin
        if p^.script = s then
        begin
            if p^.typeof = S_VAR then
            begin
                if (p^.scope = NIL) and (p^.offset = 0) then
                    // liberaExpr (p^.val.exp)
            end;

            h := hash (p^.id);

            if p^.hprev = NIL then
                hashTable[h] := p^.snext
            else
                p^.hprev^.hnext := p^.hnext;

            if p^.hnext <> NIL then
                p^.hnext^.hprev := p^.hprev;

            ant^.snext := p^.snext;
            p := ant^.snext
        end
        else begin
            ant := p;
            p := p^.snext
        end
    end
end;

{------------------------------------------------------------------------------}
{      fornece acesso ao primeiro símbolo
{------------------------------------------------------------------------------}

function getFirstSymbol : PSymtbEntry;
begin
    getFirstSymbol := firstSymbol.snext
end;

{------------------------------------------------------------------------------}
{      fornece acesso ao símbolo seguinte
{------------------------------------------------------------------------------}

function getNextSymbol (p : PSymtbEntry) : PSymtbEntry;
begin
    if p = NIL then
        getNextSymbol := NIL
    else
        getNextSymbol := p^.snext
end;

{------------------------------------------------------------------------------}
{      retorna o tamanho da maior lista de colisões
{------------------------------------------------------------------------------}

function sizeOfLargestCollisionList : integer;
var
    n, h, m : integer;
    p       : PSymtbEntry;
begin
    m := -1;

    for h := 0 to HASH_SIZE - 1 do
    begin
        n := 0;
        p := hashTable[h];

        while p <> NIL do
        begin
            INC (n);
            p := p^.hnext
        end;

        if n > m then m := n
    end;

    sizeOfLargestCollisionList := m
end;

{------------------------------------------------------------------------------}
{               inicializa a tabela hash
{------------------------------------------------------------------------------}

procedure initHashTable;
var
    i : integer;
begin
    for i := 0 to HASH_SIZE - 1 do
        hashTable[i] := NIL
end;

{------------------------------------------------------------------------------}
{             inicializa a tabela de símbolos
{------------------------------------------------------------------------------}

procedure inicializaTabelaDeSimbolos;
begin
    firstSymbol.snext := NIL;         { O primeiro nó não contém informação }
    lastSymbol        := @firstSymbol
end;

begin
    initHashTable;
    inicializaTabelaDeSimbolos
end.




