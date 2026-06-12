{------------------------------------------------------------------------------}
{
{                                  OTHERS.PAS
{
{    Processamento dos Comandos Soltos do Interpretador ScriptVox
{    Este arquivo é incluído em COMMAND.PAS
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Autor:      Oswaldo Vernet
{    Data:       28/08/2015
{    Alterações: 30/03/2016
{
{------------------------------------------------------------------------------}

unit others;
interface

uses
    dvwin, dvcrt, dvmidi, dvmacro, dvexec, dvinet, dvcomm, dvmsaa, dvform, dvjpeg, dvdigitexto,
    classes, windows, winsock, math, messages, mmsystem, strUtils, synacode, sysUtils,
    pngImage, graphics, jpeg,
    screen, lex, symboltable, low, expr, compile;

function processaVersao : boolean;
function processaDebug : boolean;
function processaRandomiza : boolean;
function processaSimbolos : boolean;
function processaConverte : boolean;
function processaAjuda : boolean;
function processaForm : boolean;
function processaMIDI : boolean;

type
    FormRec   = record
                    lvalue : LvalueRec;
                    value  : shortstring
                end;
const
    MAXFIELDS = 32;
    MAXLENGTH = 256;

var
    formtable : array [0 .. MAXFIELDS-1] of FormRec;
    formcount : integer = -1;

implementation

{--------------------------------------------------------}
{                    Comando Versao
{--------------------------------------------------------}

function processaVersao : boolean;
label
    out;
var
    exp     : Operand;
    version : string;
    dot     : char;
begin
    processaVersao := false;

    evalExpr (exp, E_STRING);

    if (exp.typeof <> E_STRING) or (exp.pobj^.str = '') then
    begin
        errorMsg ('Esperava uma cadeia com o número da versão');
        goto out
    end;

    version := trim (exp.pobj^.str);

    dot := DecimalSeparator; DecimalSeparator := '.';

    try
        if StrToFloat (version) > StrToFloat (SCRIPTVOX_VERSION) then
            errorMsg ('Cuidado: a versão corrente deste interpretador é ' + SCRIPTVOX_VERSION);
    except
        errorMsg (version + ' não é um número válido de versão')
    end;

    DecimalSeparator := dot;

    processaVersao := true;

out:
    freeExpr (exp)
end;

{--------------------------------------------------------}
{                    Comando Debug
{--------------------------------------------------------}

function processaDebug : boolean;
begin
    if (token.typeof = T_OP) and (token.op = C_SUB) or tokenIsID ('N') then
    begin
        setDebug (CS, false);
        scWriteln ('Depuração desligada')
    end
    else begin
        setDebug (CS, true);
        scWriteln ('Depuração ligada')
    end;

    skipToEOL;

    processaDebug := true
end;

{--------------------------------------------------------}
{                   comando randomiza
{--------------------------------------------------------}

function processaRandomiza : boolean;
begin
    randomize;
    skipToEOL;
    processaRandomiza := true
end;

{--------------------------------------------------------}
{               comando símbolos
{--------------------------------------------------------}

function processaSimbolos : boolean;
var
    p                       : PSymtbEntry;
    typ, val, esc, scr, fmt : string;
    q                       : PValueRec;
begin
    p := symboltable.getFirstSymbol;

    if p <> NIL then
    begin
        scWriteln ('---------------------------------------------------------------------');
        scWriteln ('   IDENTIFICADOR      TIPO   SCRIPT      ESCOPO      VALOR');
        scWriteln ('---------------------------------------------------------------------')
    end;

    while p <> NIL do
    begin
        if p^.typeof = S_VAR then
        begin
            if p^.scope = NIL then
            begin
                if p^.script < 0 then
                begin
                    esc := 'SUPERGLOBAL';
                    scr := '*'
                end
                else begin
                    esc := 'GLOBAL';
                    scr := intToStr (p^.script)
                end;

                q   := getVarAddress (p);
                val := formatExpr (q^.exp);
                typ := OperandTypeToString[q^.exp.typeof];

                if q^.exp.typeof = E_STRING then
                    val := '"' + val + '"'
            end
            else begin
                esc := p^.scope^.id;
                val := '?';
                typ := '?'
            end;

            fmt := Format ('%-16.16s%12s%4s         %-12.12s    %s', [p^.id, typ, scr, esc, val]);
            scWriteln (fmt)
        end
        else if p^.typeof = S_MOD then
        begin
            typ := 'MOD';
            esc := 'GLOBAL';
            val := IntToSTr (p^.offset);
            fmt := Format ('%-16.16s%12s%4d         %-12.12s    %s', [p^.id, typ, p^.script, esc, val]);
            scWriteln (fmt)
        end;

        p := symboltable.getNextSymbol (p)
    end;

    scWriteln;
    scWriteln ('Contadores:');
    scWriteln ('   Nós de dicionário:         ' + intToStr (nDicNode));
    scWriteln ('   Nós de Listas:             ' + intToStr (nOperand));
    scWriteln ('   Nós de Objetos:            ' + intToStr (nObjRec));
    scWriteln ('   Comandos Novos:            ' + intToStr (nNewCommands));
    scWriteln ('   sizeof Operand, ObjRec:    ' + intToStr (sizeof (Operand)) + ', ' + intToStr (sizeof (ObjRec)));
    scWriteln ('   Maior Lista de Colisões:   ' + intToStr (sizeOfLargestCollisionList));

    if symboltable.getFirstSymbol <> NIL then
        scWriteln ('---------------------------------------------------------------------');

    processaSimbolos := true
end;

{--------------------------------------------------------}
{               comando converte
{--------------------------------------------------------}

function processaConverte : boolean;
label
    out;
var
    lvalue  : LvalueRec;
    exp     : Operand;
    dir     : (_TO, _FROM);
    code, s : string;
begin
    processaConverte := false;

    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    evalLvalue (lvalue, exp, E_STRING);

    if (token.typeof <> T_ID) then
    begin
        errorMsg ('Esperava DE ou PARA');
        goto out
    end;

    if (token.id = 'DE') then
    begin
        dir := _TO
    end
    else if (token.id = 'PARA') then
    begin
        dir := _FROM
    end
    else begin
        errorMsg ('Esperava DE ou PARA');
        goto out
    end;

    nextToken;

    if token.typeof <> T_ID then
    begin
        errorMsg ('Esperava o código de conversão');
        goto out
    end;

    code := token.id;
    s    := exp.pobj^.str;

    if (code = 'UTF') or (code = 'UTF8') then
    begin
        if dir = _TO then
            s := UTF8Decode(s)
        else
            s := UTF8Encode(s)
    end
    else if code = 'URL' then
    begin
        if dir = _TO then
            s := DecodeURL(s)
        else
            s := EncodeURL(s)
    end
    else if code = 'MIME' then
    begin
        if dir = _TO then
            s := DecodeBase64(s)
        else
            s := EncodeBase64(s)
    end
    else if code = 'QP' then
    begin
        if dir = _TO then
            s := DecodeQuotedPrintable(s)
        else
            s := EncodeQuotedPrintable(s)
    end
    else begin
        errorMsg ('Código de conversão desconhecido: ' + code);
        goto out
    end;

    initExpr (exp, s);
    doAssignment (lvalue, exp);

    nextToken;
    processaConverte := true;

out:
    freeLvalue (lvalue);
    freeExpr (exp)
end;

{--------------------------------------------------------}
{               comando ajuda (help)
{--------------------------------------------------------}

function processaAjuda : boolean;
const
    PREFIX   = '== ';    { Atenção para o branco final }
var
    cmd, manpath : string;
    i            : integer;
    c1, c2       : char;
    help         : TStringList;

    {----------------------------------------------------}
    {           transforma os TABs em brancos
    {----------------------------------------------------}

    function convertTabs (s : string) : string;
    const
        TABSZ = 4;
    var
        t     : string;
        p, i  : integer;
    begin
        t := ''; p := 0;

        for i := 1 to length (s) do
        begin
            if s[i] = TAB then
            begin
                repeat
                    t := t + ' ';
                    INC (p)
                until (p mod TABSZ) = 0
            end
            else begin
                t := t + s[i];
                INC (p)
            end
        end;

        convertTabs := t
    end;

    {----------------------------------------------------}
    {  procura, no manual, o texto referente ao comando
    {----------------------------------------------------}

    function commandHelp (path, cmd : string) : TStringList;
    var
        man                : text;
        help               : TStringList;
        found              : boolean;
        line, upLine, str  : string;
        len                : integer;
    begin
{$I-}   Assign (man, path); Reset (man);

        if IoResult <> 0 then
        begin
            commandHelp := NIL;
            exit
        end;

        help  := TStringList.Create;
        found := false;
        str   := PREFIX + MaiuscAnsi (cmd); len := length (str);

        while not eof (man) do
        begin
            readln (man, line); upLine := MaiuscAnsi (line);

            if found then
            begin
                if copy (upLine, 1, length (PREFIX)) = PREFIX then
                    break;
                help.Add (convertTabs (line))
            end
            else if copy (upLine, 1, len) = str then
            begin
                help.Add (copy (line, len + 2, 999) + ' ' + cmd);
                found := true
            end
        end;

        close (man);   {$I+}

        commandHelp := help
    end;

    procedure clearLines (y1, y2 : integer);
    var
        i : integer;
    begin
        for i := y1 to y2 do
        begin
            gotoxy (1, i);
            clrEol
        end
    end;

    function listCommands (path : string) : TStringList;
    var
        man  : text;
        help : TStringList;
        cmd  : string;
    begin
        listCommands := NIL;
{$I-}
        Assign (man, path); Reset (man);

        if IoResult <> 0 then exit;

        help := TStringList.Create;

        while not eof (man) do
        begin
            readln (man, cmd);

            if MaiuscAnsi (copy (cmd, 1, length (PREFIX))) = PREFIX then
            begin
                delete (cmd, 1, length (PREFIX));
                delete (cmd, pos (' ', cmd), 999);

                cmd := trim (cmd);

                if cmd <> '' then
                    help.Add (cmd)
            end
        end;

        close (man);
{$I+}

        listCommands := help
    end;
begin
    processaAjuda := true;

    manpath := sintAmbiente ('DOSVOX', 'PGMDOSVOX');
    if manpath = '' then manpath := 'c:\winvox';
    manpath := manpath + '\manual\sc.txt';

    if token.typeof = T_EOL then
    begin
        help := listCommands (manpath);

        if help = NIL then
        begin
            errorMsg ('Manual não encontrado');
            exit
        end;

        clrscr;
        scWriteln ('Escolha o item para obter ajuda:');
        textBackground (blue);

        folheiaCria (1, wherey, 12, wherey + 15);

        for i := 0 to help.Count - 1 do
            folheiaAdiciona (help.Strings[i]);

        folheiaExecuta (1, i, c1, c2, false);

        textBackground (black);
        folheiaLimpa;
        folheiaDestroi;

        if (i > help.Count) or (c1 <> ENTER) then exit;

        cmd := help.Strings[i - 1];
        help.Free
    end
    else if (token.typeof = T_ID) or (token.typeof = T_STR) then
    begin
        cmd := token.id;
        nextToken
    end
    else begin
        errorMsg ('Esperava o nome de um comando');
        processaAjuda := false;
        skipToEol;
        exit
    end;

    help := commandHelp (manpath, cmd);

    if help = NIL then
    begin
        errorMsg ('Manual não encontrado')
    end
    else begin
        if help.Count = 0 then
        begin
            errorMsg ('Ajuda não encontrada para o comando ' + cmd)
        end
        else begin
            garanteEspacoTela (20);
            popupDigiTexto (help, false, true, 1, wherey, 80, 16, true)
        end;

        help.Free
    end
end;

{--------------------------------------------------------}
{               comando form
{--------------------------------------------------------}

function processaForm : boolean;
label
    out;
var
    lvalue : LvalueRec;
    exp    : Operand;
    field  : string;
    error  : string;
    value  : shortstring;
    size   : integer;

    {----------------------------------------------------}
    {          limpa as especificações correntes
    {----------------------------------------------------}

    procedure freeAssign;
    var
        i  : integer;
    begin
        if formcount > 0 then
        begin
            for i := 0 to formcount - 1 do
            begin
                initExpr (exp, formtable[i].value);
                doAssignment (formtable[i].lvalue, exp);
                freeLvalue (formtable[i].lvalue);
                formtable[i].value := '';
                freeExpr (exp)
            end
        end;

        formcount := -1;
    end;

    {----------------------------------------------------}
    {          limpa as especificações correntes
    {----------------------------------------------------}

    procedure freeTable;
    var
        i  : integer;
    begin
        if formcount > 0 then
        begin
            for i := 0 to formcount - 1 do
            begin
                formtable[i].value := '';
                freeLvalue (formtable[i].lvalue)
            end
        end;

        formcount := -1;
    end;

begin
    processaForm := false; error := '';

    invalidateExpr (exp);

    if token.typeof <> T_ID then
    begin
        error := 'Esperava CRIA, CAMPO, EDITA ou VISUALIZA';
        goto out
    end;

    if token.id = 'CRIA' then
    begin
        freeTable;
        formCria;
        formcount := 0;
        nextToken
    end
    else if token.id = 'CAMPO' then
    begin
        if formcount < 0 then
        begin
            error := 'É necessário usar o comando FORM CRIA antes';
            goto out
        end;

        if formcount >= MAXFIELDS then
        begin
            error := 'Número excessivo de campos no formulário';
            goto out
        end;

        nextToken;
        evalExpr (exp);

        if exp.typeof <> E_STRING then
        begin
            error := 'Esperava o nome do campo';
            goto out
        end;

        field := exp.pobj^.str;

        freeExpr (exp);

        size := MAXLENGTH;

        if tokenIsID ('TAMANHO') then
        begin
            nextToken;
            evalExpr (exp, E_INTEGER);

            if (exp.typeof = E_INTEGER) and (exp.int > 0) then
            begin
                size := min (size, exp.int)
            end
            else begin
                error := 'Tamanho inválido para o campo ' + field;
                goto out
            end;

            freeExpr (exp)
        end;

        getLvalue (lvalue);
        if lvalue.id = NIL then exit;

        evalLvalue (lvalue, exp);

        if exp.typeof in [E_INVAL, E_UNDEF] then
            value := ''
        else
            value := formatExpr (exp);

        freeExpr (exp);

        formtable[formcount].lvalue := lvalue;
        formtable[formcount].value  := value;

        if token.typeof = T_EOL then
        begin
            formCampo ('', field, formtable[formcount].value, size)
        end
        else if tokenIsID ('LISTA') then
        begin
            freeExpr (exp);

            nextToken;
            evalExpr (exp);

            if exp.typeof <> E_LIST then
            begin
                error := 'Esperava uma lista de opções';
                goto out
            end;

            formCampoLista ('', field, formtable[formcount].value, size, joinList (exp.pobj^.list, '|'))
        end
        else begin
            error := 'Esperava uma lista de opções';
            goto out
        end;

        INC (formcount)
    end
    else if token.id = 'EDITA' then
    begin
        formEdita (true);
        freeAssign;
        nextToken
    end
    else if token.id = 'VISUALIZA' then
    begin
        formEdita (false);
        freeAssign;
        nextToken
    end
    else begin
        error := 'O modificador ' + token.id + ' não é aceito pelo comando FORM';
        goto out
    end;

    processaForm := true;

out:
    skipToEOL;

    freeExpr (exp);

    if error <> '' then
        errorMsg (error)
end;

{--------------------------------------------------------}
{               comando Midi
{--------------------------------------------------------}

function processaMIDI : boolean;
label
    out;
var
    exp                      : Operand;
    octave, pitch, duration  : integer;
begin
    processaMIDI := false;

    invalidateExpr (exp);

    if tokenIsID ('ABRE') then
    begin
        nextToken;
        evalExpr (exp, E_INTEGER);

        if exp.typeof <> E_INTEGER then
        begin
            errorMsg ('Esperava o número do dispositivo');
            goto out
        end;

        abreMidi (exp.int)
    end
    else if tokenIsID ('FECHA') then
    begin
        fechaMidi
    end
    else if tokenIsID ('CANAL') then
    begin
        nextToken;
        evalExpr (exp, E_INTEGER);

        if exp.typeof <> E_INTEGER then
        begin
            errorMsg ('Esperava o número do canal');
            goto out
        end
        else if (exp.int < 1) or (exp.int > 16) then
        begin
            errorMsg ('O canal deve estar entre 1 e 16');
            goto out
        end;

        selCanal (exp.int)
    end
    else if tokenIsID ('INSTRUMENTO') then
    begin
        nextToken;
        evalExpr (exp, E_INTEGER);

        if exp.typeof <> E_INTEGER then
        begin
            errorMsg ('Esperava o número do instrumento');
            goto out
        end
        else if (exp.int < 0) or (exp.int > 255) then
        begin
            errorMsg ('O instrumento deve estar entre 0 e 255');
            goto out
        end;

        selInstrumento (exp.int)
    end
    else if tokenIsID ('INICIA') then
    begin
        nextToken;
        evalExpr (exp, E_INTEGER);
        if exp.typeof <> E_INTEGER then
        begin
            errorMsg ('Esperava o número da escala');
            goto out
        end
        else if (exp.int < -1) or (exp.int > 7) then
        begin
            errorMsg ('A escala deve estar entre -1 e 7');
            goto out
        end;

        octave := exp.int;

        if token.typeof = T_VG then
            nextToken;

        evalExpr (exp, E_INTEGER);
        if exp.typeof <> E_INTEGER then
        begin
            errorMsg ('Esperava o número da nota');
            goto out
        end;

        iniciaNota (octave, exp.int);
    end
    else if tokenIsID ('PARA') then
    begin
        nextToken;
        evalExpr (exp, E_INTEGER);
        if exp.typeof <> E_INTEGER then
        begin
            errorMsg ('Esperava o número da escala');
            goto out
        end
        else if (exp.int < -1) or (exp.int > 7) then
        begin
            errorMsg ('A escala deve estar entre -1 e 7');
            goto out
        end;

        octave := exp.int;

        if token.typeof = T_VG then
            nextToken;

        evalExpr (exp, E_INTEGER);
        if exp.typeof <> E_INTEGER then
        begin
            errorMsg ('Esperava o número da nota');
            goto out
        end;

        paraNota (octave, exp.int);
    end
    else if tokenIsID ('TOCA') then
    begin
        nextToken;
        evalExpr (exp, E_INTEGER);
        if exp.typeof <> E_INTEGER then
        begin
            errorMsg ('Esperava o número da escala');
            goto out
        end;

        octave := exp.int;

        if token.typeof = T_VG then
            nextToken;

        evalExpr (exp, E_INTEGER);
        if exp.typeof <> E_INTEGER then
        begin
            errorMsg ('Esperava o número da nota');
            goto out
        end;

        pitch := exp.int;

        if token.typeof = T_VG then
            nextToken;

        evalExpr (exp, E_INTEGER);
        if exp.typeof <> E_INTEGER then
        begin
            errorMsg ('Esperava a duração em milissegundos');
            goto out
        end;

        duration := exp.int;

        tocaNota (octave, pitch, duration);
    end
    else if tokenIsID ('VOLUME') then
    begin
        nextToken;
        evalExpr (exp, E_INTEGER);

        if exp.typeof <> E_INTEGER then
        begin
            errorMsg ('Esperava o volume');
            goto out
        end;

        volumeNota (exp.int)
    end
    else begin
        errorMsg ('Modificador ' + token.id + ' inválido para o comando MIDI');
        goto out
    end;

    processaMIDI := true;
out:
    skipToEOL;
    freeExpr (exp)
end;

end.


