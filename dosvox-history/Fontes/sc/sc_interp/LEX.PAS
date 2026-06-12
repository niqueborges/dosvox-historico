{------------------------------------------------------------------------------}
{
{                                  LEX.PAS
{
{    Analisador Léxico
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Autor:      Oswaldo Vernet
{    Data:       28/09/2015
{    Alterações: 01/10/2018
{
{------------------------------------------------------------------------------}

unit LEX;

{------------------------------------------------------------------------------}
{                             I N T E R F A C E
{------------------------------------------------------------------------------}

interface

uses
    screen, dvwin, sysUtils;

{************** Tabela de Conversão para o Analisador Léxico ******************}

const
    LF                  = #$0A;
    TAB                 = #$09;
    CR                  = #$0D;
    BLNK                = #$20;
    INVL                = #$00;

    CANONIC             : array[char] of char =
    (
        INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, BLNK, LF,   INVL, INVL, BLNK, INVL, INVL,
        INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL,
        BLNK, #$21, #$22, #$23, #$24, #$25, #$26, #$27, #$28, #$29, #$2A, #$2B, #$2C, #$2D, #$2E, #$2F,
        #$30, #$31, #$32, #$33, #$34, #$35, #$36, #$37, #$38, #$39, #$3A, #$3B, #$3C, #$3D, #$3E, #$3F,

        #$40, #$41, #$42, #$43, #$44, #$45, #$46, #$47, #$48, #$49, #$4A, #$4B, #$4C, #$4D, #$4E, #$4F,
        #$50, #$51, #$52, #$53, #$54, #$55, #$56, #$57, #$58, #$59, #$5A, #$5B, #$5C, #$5D, #$5E, #$5F,
        #$60, #$41, #$42, #$43, #$44, #$45, #$46, #$47, #$48, #$49, #$4A, #$4B, #$4C, #$4D, #$4E, #$4F,
        #$50, #$51, #$52, #$53, #$54, #$55, #$56, #$57, #$58, #$59, #$5A, #$7B, #$7C, #$7D, #$7E, INVL,

        INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL,
        INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL,
        INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL,
        INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL, INVL,

        #$41, #$41, #$41, #$41, #$41, #$41, INVL, #$43, #$45, #$45, #$45, #$45, #$49, #$49, #$49, #$49,
        #$44, #$4E, #$4F, #$4F, #$4F, #$4F, #$4F, INVL, INVL, #$55, #$55, #$55, #$55, #$59, #$50, #$53,
        #$41, #$41, #$41, #$41, #$41, #$41, INVL, #$43, #$45, #$45, #$45, #$45, #$49, #$49, #$49, #$49,
        INVL, #$4E, #$4F, #$4F, #$4F, #$4F, #$4F, INVL, INVL, #$55, #$55, #$55, #$55, #$59, #$50, #$59
    );

{************************* Estrutura de um Lexema *****************************}

type
    TokenType           = (                                                     { Os diversos lexemas da linguagem }
                            T_EOL, T_ID, T_ROT, T_INT, T_STR, T_OP,
                            T_PT, T_VG, T_AT, T_CL, T_LP, T_RP, T_LB,
                            T_RB, T_LC, T_RC, T_SUS, T_AMP
                          );

    OperatorType        = (                                                     { Os diversos operadores da linguagem }
                            C_NOP,
                            C_EQ, C_NE, C_GT, C_GE, C_LT, C_LE,
                            C_SEQS, C_EQS, C_SEQ,
                            C_ADD, C_SUB,
                            C_MULT, C_DIV, C_MOD,
                            C_POT,
                            C_OR, C_AND,
                            C_TO, C_SIZE
                          );

    TokenRec            = record
                            lineNumber  : integer;                              { Informações sobre a linha atual }
                            line        : PChar;
                            mark,
                            next,
                            endLine     : PChar;

                            typeof      : TokenType;                            { Informações sobre o lexema atual }
                            start       : PChar;
                            id, rid     : string;
                            int         : integer;
                            op          : OperatorType
                          end;

var
    token               : TokenRec;

procedure errorMessage    (msg : string);
procedure setLine         (num : integer; line : PChar; size : integer);
procedure backToken;
procedure markToken;
procedure backToMarkedToken;
function  nextToken       () : TokenType;
procedure skiptTokenIf    (s : shortstring);
procedure skipToEOL;
function  normalize       (s : string) : string;
function  tokenIsID       (s : string) : boolean;

{------------------------------------------------------------------------------}
{                           I M P L E M E N T A Ç Ã O
{------------------------------------------------------------------------------}

implementation

{--------------------------------------------------------}
{                  mensagens de erro
{--------------------------------------------------------}

procedure errorMessage (msg : string);
begin
    scWriteln ('Erro na linha ' + IntToStr (token.lineNumber) + ': ' + msg)
end;

{--------------------------------------------------------}
{        estabelece uma linha como a atual
{--------------------------------------------------------}

procedure setLine (num : integer; line : PChar; size : integer);
begin
    token.lineNumber := num;
    token.line       := line;
    token.endLine    := token.line + size;
    token.mark       := NIL;
    token.start      := NIL;

    if (size > 0) and (line[0] in ['*', ';', '/', '&']) then
        token.next    := token.endLine
    else
        token.next    := token.line
end;

{--------------------------------------------------------}
{             volta um token
{--------------------------------------------------------}

procedure backToken;
begin
    token.next := token.start;
    nextToken
end;

{--------------------------------------------------------}
{             marca o token corrente
{--------------------------------------------------------}

procedure markToken;
begin
    token.mark := token.start
end;

{--------------------------------------------------------}
{             recua para o primeiro token
{--------------------------------------------------------}

procedure backToMarkedToken;
begin
    if token.mark <> NIL then
    begin
        token.next := token.mark;
        nextToken
    end
end;

{--------------------------------------------------------}
{             obtém o próximo token
{--------------------------------------------------------}

function nextToken : TokenType;
var
    c  : char;
    pt : PChar;

    {----------------------------------------------------}
    {             devolve um token simples
    {----------------------------------------------------}

    procedure simple (t : TokenType);
    begin
        INC (pt);
        token.typeof := t
    end;

    {----------------------------------------------------}
    {             devolve um operador
    {----------------------------------------------------}

    procedure operator (o : OperatorType);
    begin
        INC (pt);
        token.typeof := T_OP;
        token.op     := o
    end;

begin
    nextToken    := T_EOL;
    token.typeof := T_EOL;
    token.op     := C_NOP;

    { Pula os separadores e caracteres inválidos; a linha é arrematada com LF }

    pt := token.next; c := CANONIC[pt^];

    while c in [INVL,BLNK] do
    begin
        if c = INVL then
            errorMessage ('Caractere inválido (#' + IntToStr (ord (pt^)) + ')');

        INC (pt); c := CANONIC[pt^]
    end;

    token.next  := pt;
    token.start := token.next;
    token.id    := '';
    token.rid   := '';

    { Analisa o caractere inicial do token }

    case c of
        LF:     begin
                    token.rid := 'EOL';
                    exit
                end;
        'A'..'Z',
        '$', '_', '@':
                begin
                    repeat
                        token.id  := token.id  + c;     { normalizado }
                        token.rid := token.rid + pt^;   { de verdade }
                        INC (pt); c := CANONIC[pt^]
                    until not (c in ['A'..'Z', '$', '_', '0'..'9']);

                    if token.id[1] = '@' then
                        token.typeof := T_ROT
                    else
                        token.typeof := T_ID
               end;
        '0'..'9':
                begin
                    token.int := 0;
                    repeat
                        token.int := token.int * 10 + (ord (c) - ord ('0'));
                        INC (pt); c := pt^
                    until not (c in ['0'..'9']);

                    if (c = '.') and ((pt + 1)^ in ['0'..'9', 'E', 'e']) then
                    begin
                        repeat
                            INC (pt)
                        until not (pt^ in ['0'..'9']);

                        if pt^ in ['e', 'E'] then
                        begin
                            INC (pt);
                            if pt^ in ['+', '-'] then INC (pt);
                            while pt^ in ['0'..'9'] do INC (pt)
                        end;

                        token.id := Copy (token.line, token.start - token.line + 1, pt - token.start);
                        token.typeof := T_STR
                    end
                    else begin
                        token.typeof := T_INT
                    end
                end;
        '"', '''':
                begin
                    token.id := '';                     { Observe que c não é alterado e armazena " ou ' }

                    repeat
                        INC (pt);

                        if pt >= token.endLine then
                        begin
                            pt := token.endLine - 1;
                            errorMessage ('Faltou delimitar o fim da cadeia');
                            break
                        end;

                        if pt^ = c then
                        begin
                            if (pt > (token.endLine - 1)) or ((pt + 1)^ <> c) then
                                break;

                            token.id := token.id + c;
                            INC (pt)
                        end
                        else begin
                            token.id := token.id + pt^
                        end
                    until false;

                    INC (pt);
                    token.typeof := T_STR
                end;
        ';':    begin
                    pt := token.endLine; token.start := pt; token.rid := ';';
                    token.typeof := T_EOL
                end;
        '+':    operator (C_ADD);
        '-':    operator (C_SUB);
        '^':    operator (C_POT);
        '|':    operator (C_SIZE);
        '%':    operator (C_MOD);
        ',':    simple (T_VG);
        '(':    simple (T_LP);
        ')':    simple (T_RP);
        '[':    simple (T_LB);
        ']':    simple (T_RB);
        '{':    simple (T_LC);
        '}':    simple (T_RC);
        '&':    simple (T_AMP);
        '#':    simple (T_SUS);
        ':':    begin
                    INC (pt);
                    if pt^ = '=' then
                    begin
                        INC (pt);
                        token.typeof := T_AT
                    end
                    else begin
                        token.typeof := T_CL
                    end
                end;
        '/':    begin
                    INC (pt);
                    if pt^ = '/' then
                    begin
                        pt := token.endLine; token.start := pt; token.rid := '//';
                        token.typeof := T_EOL
                    end
                    else begin
                        token.typeof := T_OP;
                        token.op   := C_DIV
                    end
                end;
        '=':    begin
                    token.op := C_EQ;
                    INC (pt);
                    case pt^ of
                        '*':    begin
                                    INC (pt);
                                    token.op := C_EQS
                                end
                    end;
                    token.typeof := T_OP
                end;
        '<':    begin
                    token.op := C_LT;
                    INC (pt);
                    case pt^ of
                        '=':    begin
                                    INC (pt);
                                    token.op := C_LE
                                end;
                        '>':    begin
                                    INC (pt);
                                    token.op := C_NE
                                end
                    end;
                    token.typeof := T_OP
                end;
        '>':    begin
                    token.op := C_GT;
                    INC (pt);
                    if pt^ = '=' then
                    begin
                        INC (pt);
                        token.op := C_GE
                    end;
                    token.typeof := T_OP
                end;
        '*':    begin
                    token.op := C_MULT;
                    INC (pt);
                    if pt^ = '=' then
                    begin
                        INC (pt);
                        if pt^ = '*' then
                        begin
                            INC (pt);
                            token.op := C_SEQS
                        end
                        else begin
                            token.op := C_SEQ
                        end
                    end;
                    token.typeof := T_OP
                end;
        '.':    begin
                    INC (pt);
                    if pt^ = '.' then
                        operator (C_TO)
                    else
                        token.typeof := T_PT
                end
    end;

    { token.rid (significa real id) contém uma cópia do token recém extraído }

    if token.rid = '' then
        token.rid := Copy (token.line, token.start - token.line + 1, pt - token.start);

    token.next := pt;
    nextToken  := token.typeof
end;

{--------------------------------------------------------}
{        pula o próximo token se for um dado
{--------------------------------------------------------}

procedure skiptTokenIf (s : shortstring);
begin
    if (token.typeof = T_ID) and (token.id = s) or (token.rid = s) then
        nextToken
end;

{--------------------------------------------------------}
{           descarta tokens até o fim da linha
{--------------------------------------------------------}

procedure skipToEOL;
begin
    token.next   := token.endLine;
    token.start  := token.endLine;
    token.typeof := T_EOL;
    token.op     := C_NOP;
    token.rid    := ''
end;

{--------------------------------------------------------}
{   verifica se o token atual é um dado identificador
{--------------------------------------------------------}

function tokenIsID (s : string) : boolean;
begin
    tokenIsID := (token.typeof = T_ID) and (token.id = s)
end;

{--------------------------------------------------------}
{                normaliza uma cadeia
{--------------------------------------------------------}

function normalize (s : string) : string;
var
    i   : integer;
    ret : string;
begin
    ret := '';

    for i := 1 to length (s) do
        ret := ret + CANONIC[s[i]];

    normalize := ret
end;

begin
end.
