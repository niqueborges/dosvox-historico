{------------------------------------------------------------------------------}
{
{                                  SQL.PAS
{
{    Processamento dos Comandos de acesso a banco de dados
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Orientação: Oswaldo Vernet
{    Autor:      Antonio Borges e Patrick Barbosa
{    Data:       14/05/2024
{
{------------------------------------------------------------------------------}

unit sql;
interface
uses
    dvwin, dvcrt, dvmidi, dvmacro, dvexec, dvinet, dvcomm, dvmsaa, dvform, dvjpeg, dvdigitexto,
    classes, windows, winsock, math, messages, mmsystem, strUtils, synacode, sysUtils,
    pngImage, graphics, jpeg,
    screen, lex, symboltable, low, expr, compile, io, sqlite3, sqlite3wrap;

function processaSql: boolean;

implementation

var
    DB: TSQLite3Database;
    prep: array [0..9] of TSQLite3Statement;
    tiposPrep: array [0..9] of string;
    sqlErro: boolean;
    sql_erro: string;   {   Último erro do sqlite   }

{--------------------------------------------------------}
{               comando Sql
{--------------------------------------------------------}

function processaSql: boolean;
var
    exp: Operand;
    primeiraLinha: boolean;
    nomeDB, comandoSQL: string;
    numPrep: integer;
    diagnostico: string;

    sep, linhaDaLista: string;
    errcnv: integer;
    v_int: integer;
    v_dbl: double;
    prepExibe: TSQLite3Statement;

const
    MAXCOLSQL = 30;
var
    nomeia: boolean;
    colsSel: integer;
    tiposSel: array [1..MAXCOLSQL] of integer;

    function execSqlAbre: boolean;
    var
        criaDB: boolean;
    begin
        //SQL ABRE arquivo [&]
        result := false;
        nextToken;
        evalExpr (exp);

        if (exp.typeof <> E_STRING) or (exp.pobj^.str = '') then
        begin
            errorMsg ('Esperava um nome de arquivo');
            exit;
        end;

        nomeDB := exp.pobj^.str;
        criaDB := false;

        if token.typeof = T_AMP then
        begin
            criaDB := true;
            nextToken
        end;

        if criaDB then
            begin
                if FileExists(nomeDB) then
                    deleteFile (nomeDB);
            end
        else
            if not FileExists(nomeDB) then
                begin
                errorMsg('Banco de dados não encontrado');
                exit;
                end;

        if DB <> NIL then DB.Free;
        DB := TSQLite3Database.Create;
        try
            DB.Open(nomeDB);
        except
            DB.Free;
            DB := NIL;
            errorMsg ('Database não pode ser aberto usando ' + nomeDB);
            exit;
        end;

        result := true;
    end;

    {---------------------}
    function execSqlFecha: boolean;
    begin
        //SQL FECHA
        nextToken;
        if DB <> NIL then
            begin
                DB.Free;
                DB := NIL;
            end;
        result := true;
    end;

    {---------------------}
    function execSqlExecuta: boolean;
    var
        exp: Operand;
    begin
        //SQL EXECUTA "comando"
        result := false;
        if DB = NIL then exit;

        nextToken;
        evalExpr (exp);

        if (exp.typeof <> E_STRING) or (exp.pobj^.str = '') then
        begin
            errorMsg ('Esperava um comando SQL');
            exit;
        end;

        comandoSQL := exp.pobj^.str;

        try
            DB.Execute(comandoSQL);
        except
            on E: Exception do
                 begin
                      diagnostico := E.Message;
//                      errorMsg (diagnostico);
//                      exit;
                      sql_erro := diagnostico;
                 end;
        end;

        result := true;
    end;

    {---------------------}
    function execSqlPrepara: boolean;
    var
        exp      : Operand;

    begin
        //SQL PREPARA #1 "INSERT INTO artists (name, born, died) VALUES (?, ?, ?)" "SRR"
        result := false;
        if DB = NIL then exit;

        nextToken;
        numPrep := getFileDescriptor;
        if numPrep < 0 then exit;

        //Após getFileDescriptor não é necessário nextToken
        evalExpr (exp);
        if (exp.typeof <> E_STRING) or (exp.pobj^.str = '') then
        begin
            errorMsg ('Esperava um comando SQL');
            exit;
        end;

        comandoSQL := exp.pobj^.str;

        tiposPrep[numPrep] := '';

        if token.typeof <> T_EOL then
            begin
                evalExpr (exp);
                if (exp.typeof <> E_STRING) or (exp.pobj^.str = '') then
                    begin
                        errorMsg ('Esperava lista de tipos');
                        exit;
                    end;

                    tiposPrep[numPrep] := exp.pobj^.str;
                end;

        try
            prep[numPrep] := DB.Prepare(comandoSql);
        except
            on E: Exception do
                 begin
                      diagnostico := E.Message;
//                      errorMsg (diagnostico);
//                      exit;
                      sql_erro := diagnostico;
                 end;
        end;
        result := true;
    end;

    {---------------------}
    function execSqlLibera: boolean;
    begin
        //SQL LIBERA #1
        result := false;
        if DB = NIL then exit;

        nextToken;
        numPrep := getFileDescriptor;
        if numPrep < 0 then exit;

        //Após getFileDescriptor não é necessário nextToken
        tiposPrep[numPrep] := '';
        prep[numPrep].Free;
        prep[numPrep] := NIL;

        result := true;
    end;

    {---------------------}
    function execSqlInjeta: boolean;
    var
        exp: Operand;
        col: integer;
        x: string;
        fazStep, repetir: boolean;

    label
        erro;
    begin
        //SQL INJETA #1 $nome, $nasc, $morte [&]
        result := false;
        if DB = NIL then exit;
        nextToken;

        fazStep := true;

        numPrep := getFileDescriptor;
        if numPrep < 0 then exit;

        //Após getFileDescriptor não é necessário nextToken
        if prep[numPrep] = NIL then exit;

        col := 1;
        repeat
            evalExpr(exp);

            if (exp.typeof = E_STRING) then
                x := exp.pobj^.str
            else
            if (exp.typeof = E_INTEGER) then
                x := intToStr(exp.int)
            else
                x := intToStr(exp.int); {   Provisório   }

            if col > length(tiposPrep[numPrep]) then goto erro;

            case upcase (tiposPrep[numPrep][col]) of
                    'S', 'T': prep[numPrep].BindText(col, x);
                    'I':     begin
                                 val (x, v_int, errcnv);
                                 if errcnv <> 0 then goto erro;
                                 prep[numPrep].BindInt(col, v_int);
                             end;
                   'F', 'R': begin
                                 val (x, v_dbl, errcnv);
                                 if errcnv <> 0 then goto erro;
                                 prep[numPrep].BindDouble(col, v_dbl);
                             end;
                end;
            col := col + 1;

            repetir := false;
            if token.typeof = T_VG then
               begin
                   nextToken;
                   repetir := true;
               end
            else
            if token.typeof = T_amp then
                begin
                    fazStep := false;
                    nextToken;
                end;
        until not repetir;

        if col <> length(tiposPrep[numPrep])+1 then
            begin
erro:           errorMsg ('Número de parâmetros inconsistente');
                exit;
            end;

        if fazStep then
            prep[numPrep].StepAndReset;

        result := true;
    end;

    {---------------------}
    function execSqlultimoId: boolean;
    var
        lvalue : LvalueRec;
        exp    : Operand;

    begin
        //SQL ULTIMOID x
        result := false;
        if DB = NIL then exit;

        nextToken;
        getLvalue (lvalue);
        if lvalue.id = NIL then exit;

        initExpr (exp, intToStr(DB.LastInsertRowID));
        doAssignment (lvalue, exp);

        freeLvalue (lvalue);
        freeExpr (exp);

        result := true;
    end;

    {---------------------}
    function execSqlCheca: boolean;
    var
        lvalue : LvalueRec;
        exp    : Operand;

    begin
        //SQL CHECA x
        result := false;
        if DB = NIL then exit;

        nextToken;
        getLvalue (lvalue);
        if lvalue.id = NIL then exit;

        initExpr (exp, intToStr(ord(sqlErro)));
        doAssignment (lvalue, exp);

        freeLvalue (lvalue);
        freeExpr (exp);
        result := true;
    end;

    {---------------------}
    function execSqlPega: boolean;
    var
        lvalue: LvalueRec;
        exp: Operand;
        repetir: boolean;
        col: integer;
    begin
        //SQL PEGA #1 $nome1, $nome2...
        result := false;
        if DB = NIL then exit;

        nextToken;

        numPrep := getFileDescriptor;
        if numPrep < 0 then exit;

        //Após getFileDescriptor não é necessário nextToken
        if prep[numPrep] = NIL then exit;

        sqlErro := prep[numPrep].Step <> SQLITE_ROW;
        if sqlErro then
            begin
                skipToEOL;
                result := true;
                exit
            end;

        colsSel := prep[numPrep].ColumnCount;
        if colsSel > MAXCOLSQL then colsSel := MAXCOLSQL;
        for col := 1 to colsSel do
            tiposSel[col] := prep[NumPrep].ColumnType(col-1);

        col := 1;

        repeat
            getLvalue (lvalue);
            if lvalue.id = NIL then exit;

            case tiposSel[col] of
                 0:  initExpr (exp,  '');
                 1:  initExpr (exp, intToStr(prep[numPrep].ColumnInt(col-1)));
                 2:  initExpr (exp,
                      FloatToStr(prep[numPrep].ColumnDouble(col-1)));
                 3:  initExpr (exp, prep[numPrep].ColumnText(col-1));
                 4:  ;  // Blob
            end;

            doAssignment (lvalue, exp);

            freeLvalue (lvalue);
            freeExpr (exp);

            col := col + 1;

            repetir := false;
            if token.typeof = T_VG then
               begin
                   nextToken;
                   repetir := true;
               end;
        until not repetir;
        result := true;
    end;

    {---------------------}
    function execSqlLista: boolean;
    var
        lvalue: LvalueRec;
        sqlist: TStringList;
        s: string;
        col: integer;

    begin
        //SQL LISTA #1 lista separador
        result := false;
        if DB = NIL then exit;

        nextToken;
        numPrep := getFileDescriptor;
        if numPrep < 0 then exit;

        // checa se foi definido um prepare prévio
        if prep[numPrep] = NIL then exit;

        //Após getFileDescriptor não é necessário nextToken
        getLvalue (lvalue);
        if lvalue.id = NIL then exit;

        evalExpr(exp);
        if (exp.typeof = E_STRING) and (exp.pobj^.str <> '') then
            sep := exp.pobj^.str
        else
            sep := ';';

        sqlist := TStringList.create;

        while prep[numPrep].Step = SQLITE_ROW do
            begin
                colsSel := prep[numPrep].ColumnCount;
                if colsSel > MAXCOLSQL then colsSel := MAXCOLSQL;
                s := '';
                for col := 1 to colsSel do
                    begin
                        tiposSel[col] := prep[NumPrep].ColumnType(col-1);
                        if col <> 1 then
                            s := s + sep;
                        case tiposSel[col] of
                            1:  s := s + intToStr(prep[numPrep].ColumnInt(col-1));
                            2:  s := s + FloatToStr(prep[numPrep].ColumnDouble(col-1));
                            3:  s := s + prep[numPrep].ColumnText(col-1);
                        end;
                    end;
                sqlist.add (s);
            end;

        initExpr (exp, sqlist);
        doAssignment (lvalue, exp);

        sqlist.Free;
        result := true;
    end;

    {---------------------}
    function execSqlExibe: boolean;
    var
        exp: operand;
        col: integer;
        x: string;

    begin
        //SQL EXIBE "comando sql" separador
        result := false;
        if DB = NIL then
            begin
               skipToEol;
               exit;
            end;

        nextToken;
        nomeia := false;

        if tokenIsId ('NOMEIA') then
            begin
                 nomeia := true;
                 nextToken;
            end;

        //Pega comando SQL
        evalExpr (exp);
        if (exp.typeof <> E_STRING) or (exp.pobj^.str = '') then
        begin
            errorMsg ('Esperava um comando SQL');
            exit;
        end;

        comandoSQL := exp.pobj^.str;

        //Pega separador (se não vier assume ponto e vírgula)
        evalExpr(exp);
        if (exp.typeof = E_STRING) and (exp.pobj^.str <> '') then
            sep := exp.pobj^.str
        else
            sep := ';';

        try
            prepExibe := DB.Prepare(comandoSql);
        except
            on E: Exception do
                 begin
                      diagnostico := E.Message;
//                      errorMsg (diagnostico);
//                      exit;
                      sql_erro := diagnostico;
                 end;
        end;

    primeiraLinha := true;
	    while prepExibe.Step = SQLITE_ROW do
        begin
            if primeiraLinha then
                begin
                    linhaDaLista := '';
                    colsSel := prepExibe.ColumnCount;
                    if colsSel > MAXCOLSQL then colsSel := MAXCOLSQL;
                    for col := 1 to colsSel do
                         begin
                             tiposSel[col] := prepExibe.ColumnType(col-1);
                             if col <> 1 then linhaDaLista := linhaDaLista + sep;
                             linhaDaLista := linhaDaLista + prepExibe.ColumnName(col-1);
                        end;
                    if nomeia then
                        sintWriteln (linhaDaLista);
                    primeiraLinha := false;
                end;

            linhaDaLista := '';

            for col := 1 to prepExibe.ColumnCount do
                begin
                     case tiposSel[col] of
                        0:  x := '';
                        1:  x := intToStr(prepExibe.ColumnInt(col-1));
                        2:  x := FloatToStr(prepExibe.ColumnDouble(col-1));
                        3:  x := prepExibe.ColumnText(col-1);
                        4:  ;  // Blob
                    end;
                    if col <> 1 then linhaDaLista := linhaDaLista + sep;
                    linhaDaLista := linhaDaLista + x;
                end;

            sintWriteln(linhaDaLista);
        end;

        result := true;
    end;

    {---------------------}
    function execSqlErro: boolean;
    var
        lvalue : LvalueRec;
        exp    : Operand;

    begin
        //SQL ERRO variavel
        result := false;
        if DB = NIL then exit;

        nextToken;
        getLvalue (lvalue);
        if lvalue.id = NIL then exit;

        initExpr (exp, sql_erro);
        doAssignment (lvalue, exp);

        freeLvalue (lvalue);
        freeExpr (exp);

        sql_erro := '';

        result := true;
    end;

    {---------------------}

begin
    processaSql :=  false;

    if token.typeof = T_EOL then
        begin
            errorMsg('Esperava mais parâmetros');
            exit;
        end;

    if token.typeof = T_STR then
        begin
            backToken;
            processaSql := execSqlLista;
        end
    else
    if tokenIsID ('ABRE') then processaSql := execSqlAbre
    else
    if tokenIsID ('FECHA') then processaSql := execSqlFecha
    else
    if tokenIsID ('EXECUTA') then processaSql := execSqlExecuta
    else
    if tokenIsID ('PREPARA') then processaSql := execSqlPrepara
    else
    if tokenIsID ('LIBERA') then processaSql := execSqlLibera
    else
    if tokenIsID ('INJETA') then processaSql := execSqlInjeta
    else
    if tokenIsID ('ULTIMOID') then processaSql := execSqlultimoId
    else
    if tokenIsID ('CHECA') then processaSql := execSqlCheca
    else
    if tokenIsID ('PEGA') then processaSql := execSqlPega
    else
    if tokenIsID ('LISTA') then processaSql := execSqlLista
    else
    if tokenIsID ('EXIBE') then processaSql := execSqlExibe
    else
    if tokenIsID ('ERRO') then processaSql := execSqlErro
    else
        begin
            errorMsg('Comando sql não reconhecido');
            exit;
        end;
end;

end.

