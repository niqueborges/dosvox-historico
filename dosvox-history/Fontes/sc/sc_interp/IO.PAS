{------------------------------------------------------------------------------}
{
{                                  IO.PAS
{
{    Processamento dos Comandos de Entrada e Saída do Interpretador ScriptVox
{    Este arquivo é incluído em COMMAND.PAS
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Autor:      Oswaldo Vernet
{    Data:       21/08/2015
{    Alterações: 31/03/2016, 06/04/2016, 07/08/2017, 25/09/2018
{
{------------------------------------------------------------------------------}

unit io;

interface
uses
    dvwin, dvcrt, dvmidi, dvmacro, dvexec, dvinet, dvcomm, dvmsaa, dvform, dvjpeg, dvdigitexto,
    classes, windows, winsock, math, messages, mmsystem, strUtils, synacode, sysUtils,
    pngImage, graphics, jpeg,
    screen, lex, symboltable, low, expr, compile;

type
    ImageType           = (NONE, BMP, JPG, PNG);

function getFileDescriptor : integer;
function processaAbre : boolean;
function processaInternet : boolean;
function processaConecta : boolean;
function processaServe : boolean;
function processaAceita : boolean;
function processaSerial : boolean;
function processaObserva : boolean;
function processaCheca : boolean;
function processaFecha : boolean;
function processaEscreve : boolean;
function processaFala : boolean;
function processaSoletra : boolean;
function processaBipa : boolean;
function processaCor : boolean;
function processaFundo : boolean;
function processaTela : boolean;
function processaLe : boolean;
function processaEspera : boolean;
function processaDigita : boolean;
function processaAciona : boolean;
function processaClica : boolean;
function processaTransfere : boolean;
function processaJanela : boolean;
function processaCaptura : boolean;
procedure sendMCIString (s: string; var retMCI : string); overload;
procedure sendMCIString (s: string); overload;
function processaToca : boolean;
function processaMci : boolean;
function processaBusca : boolean;
function processaRenomeia : boolean;
function processaReplica : boolean;
function processaRemove : boolean;
function processaMouse : boolean;
function processaDir : boolean;
function processaIP : boolean;
function processaMenu : boolean;
function getTmpFilePath (ext : string) : string;
function getImageType (path : string) : ImageType;
function processaImagem : boolean;
function processaSensor : boolean;
function processaMSAA : boolean;
function processaExecuta : boolean;
function processaCursor : boolean;
function processaBaixa : boolean;
function processaSprite : boolean;

var
    BMPGlobal : TBitmap;
    searchAttrib: word;

implementation

{--------------------------------------------------------}
{       definições locais ao processamento de E/S
{--------------------------------------------------------}

const
    basepr              = $378;    // 378 ou 278

type
    MciStr              = array [0..255] of char;
    TInp32              = function  (PortAddress: word) : byte;         stdcall;
    TOut32              = procedure (PortAddress: word; data: byte);    stdcall;

var
    itemInic            : integer;

    dirInfo             : TSearchRec;

    sensorAtivo         : boolean;

    Inp32               : TInp32;
    Out32               : TOut32;
    HInpOut32           : THandle;
    mascChaves          : byte;
    vetChaves           : array[1..32] of boolean;
    internetPronta      : boolean = false;

{--------------------------------------------------------}
{           analisa um descritor de arquivo
{--------------------------------------------------------}

function getFileDescriptor : integer;
var
    exp : Operand;
begin
    getFileDescriptor := -1;

    if token.typeof <> T_SUS then
    begin
        errorMsg ('Esperava um descritor de arquivo');
        exit
    end;

    nextToken;
    evalExpr (exp, E_INTEGER);

    if (exp.typeof <> E_INTEGER) or not (exp.int in [0 .. MAXFILES-1]) then
    begin
        freeExpr (exp);
        errorMsg ('Descritor de arquivo inválido');
        exit
    end;

    getFileDescriptor := exp.int
end;

{--------------------------------------------------------}
{                  comando ABRE
{--------------------------------------------------------}

function processaAbre : boolean;
label
    out;
var
    fd       : integer;
    w, quiet : boolean;
    exp      : Operand;
begin
    processaAbre := false;

    quiet := false;
    if tokenIsID ('MUDO') then
    begin
        quiet := true;
        nextToken;
    end;

    fd := getFileDescriptor;
    if fd < 0 then exit;

    evalExpr (exp);

    if (exp.typeof <> E_STRING) or (exp.pobj^.str = '') then
    begin
        errorMsg ('Esperava um nome de arquivo');
        goto out
    end;

    w := false;
    if token.typeof = T_AMP then
    begin
        w := true;
        nextToken
    end;

    with files[fd] do
    begin
        if isOpen then
        begin
            errorMsg ('O descritor #' + intToStr (fd) + ' já está aberto');
            goto out
        end;

        assign (filefd, exp.pobj^.str);
{$I-}
        if w then
        begin
            append (filefd);

            if ioresult <> 0 then
                rewrite (filefd)
        end
        else begin
            reset (filefd)
        end;
{$I+}
        if IoResult = 0 then
        begin
            setIOStatus (CS, 0);

            isOpen       := true;
            typeof       := F_FILE;
            processaAbre := true
        end
        else begin
            setIOStatus (CS, 1);

            if quiet then
                processaAbre := true
            else
                errorMsg ('Erro na abertura do arquivo ' + exp.pobj^.str)
        end
    end;

out:
    freeExpr (exp)
end;

{--------------------------------------------------------}
{                  comando INTERNET
{--------------------------------------------------------}

function processaInternet : boolean;
begin
    processaInternet := false;

    if token.typeof <> T_ID then exit;

    if token.id = 'INICIA' then
    begin
        abreWinSock;
        internetPronta := true
    end
    else if token.id = 'TERMINA' then
    begin
        fechaWinSock;
        internetPronta := false
    end
    else
        exit;

    nextToken;

    processaInternet := true
end;

{--------------------------------------------------------}
{                  comando CONECTA
{--------------------------------------------------------}

function processaConecta : boolean;
label
    out;
var
    fd               : integer;
    expName, expPort : Operand;
    ssl, quiet       : boolean;
begin
    processaConecta  := false;

    ssl := false;
    if tokenIsID ('SSL') then
    begin
        ssl := true;
        nextToken
    end;

    quiet := false;
    if tokenIsID ('MUDO') then
    begin
        quiet := true;
        nextToken
    end;

    fd := getFileDescriptor;
    if fd < 0 then exit;

    evalExpr (expName, E_STRING);
    evalExpr (expPort, E_INTEGER);

    if (expName.typeof <> E_STRING) or (expName.pobj^.str = '') then
    begin
        errorMsg ('Esperava cadeia com endereço do servidor');
        goto out
    end;

    if (expPort.typeof <> E_INTEGER) or (expPort.int < 1) or (expPort.int > 65535) then
    begin
        errorMsg ('Esperava número da porta');
        goto out
    end;

    with files[fd] do
    begin
        if isOpen then
        begin
            errorMsg ('O descritor #' + intToStr (fd) + ' já está aberto');
            exit
        end;

        if not internetPronta then
        begin
            abreWinSock;
            internetPronta := true
        end;

        if ssl then
            sockfd := abreConexaoSSL (expName.pobj^.str, expPort.int)
        else
            sockfd := abreConexao    (expName.pobj^.str, expPort.int);

        if sockfd < 0 then
        begin
            setIOStatus (CS, 1);

            if quiet then
                processaConecta := true
            else
                errorMsg ('Erro ao tentar conexão TCP')
        end
        else begin
            setIOStatus (CS, 0);

            pBuf            := inicBufRede (sockfd);
            typeof          := F_NET;
            isOpen          := true;
            processaConecta := true
        end
    end;

out:
    freeExpr (expName);
    freeExpr (expPort)
end;

{--------------------------------------------------------}
{                  comando SERVE
{--------------------------------------------------------}

function processaServe : boolean;
label
    out;
var
    expPort         : Operand;
    fd, soq         : integer;
    blocking, quiet : boolean;
begin
    processaServe := false;

    quiet := false;
    if tokenIsID ('MUDO') then
    begin
        quiet := true;
        nextToken
    end;

    fd := getFileDescriptor;
    if fd < 0 then exit;

    evalExpr (expPort, E_INTEGER);

    if (expPort.typeof <> E_INTEGER) or (expPort.int < 1) or (expPort.int > 65535) then
    begin
        errorMsg ('Esperava número da porta');
        freeExpr (expPort);
        exit
    end;

    blocking := true;
    if token.typeof = T_AMP then
    begin
        blocking := false;
        nextToken
    end;

    with files[fd] do
    begin
        if isOpen then
        begin
            errorMsg ('O descritor #' + intToStr (fd) + ' já está aberto');
            exit
        end;

        if not internetPronta then
        begin
            abreWinSock;
            internetPronta := true
        end;

        if blocking then
        begin
            soq := escutaConexao (expPort.int);
            if soq < 0 then goto out;

            sockfd := aceitaConexao (soq);
            fechaConexao (soq);
            if sockfd < 0 then goto out;
            pBuf := inicBufRede (sockfd);
        end
        else begin
            sockfd := escutaConexao (expPort.int);
            if sockfd < 0 then goto out;
            pBuf := NIL
        end;

        typeof   := F_NET;
        isOpen   := true
    end;

    setIOStatus (CS, 0);
    processaServe := true;
    exit;

out:
    setIOStatus (CS, 1);
    if quiet then
    begin
        processaServe := true
    end
    else begin
        errorMsg ('Erro ao servir a porta ' + IntToStr (expPort.int));
        processaServe := false
    end
end;

{--------------------------------------------------------}
{                  comando ACEITA
{--------------------------------------------------------}

function processaAceita : boolean;
label
    out;
var
    listenfd, fd : integer;
    quiet        : boolean;
begin
    processaAceita := false;

    quiet := false;
    if tokenIsID ('MUDO') then
    begin
        quiet := true;
        nextToken
    end;

    listenfd := getFileDescriptor;
    if listenfd < 0 then goto out;

    fd := getFileDescriptor;
    if fd < 0 then goto out;

    with files[fd] do
    begin
        if isOpen then
        begin
            errorMsg ('O descritor #' + intToStr (fd) + ' já está aberto');
            exit
        end;

        sockfd := aceitaConexao (files[listenfd].sockfd);
        if sockfd < 0 then goto out;

        pBuf     := inicBufRede (sockfd);
        typeof   := F_NET;
        isOpen   := true
    end;

    setIOStatus (CS, 0);
    processaAceita := true;
    exit;

out:
    setIOStatus (CS, 1);
    if quiet then
    begin
        processaAceita := true
    end
    else begin
        errorMsg ('Erro ao aceitar conexão');
        processaAceita := false
    end
end;

{--------------------------------------------------------}
{                  comando SERIAL
{--------------------------------------------------------}

function processaSerial : boolean;
label
    out;
var
    fd, status                   : integer;
    expPort, expSpeed, expNbits,
    expNstop, expParity          : Operand;
begin
    processaSerial := false;

    fd := getFileDescriptor;
    if fd < 0 then exit;

    evalExpr (expPort, E_INTEGER);

    if (expPort.typeof <> E_INTEGER) or (expPort.int < 1) or (expPort.int > 65535) then
    begin
        errorMsg ('Esperava número da porta serial');
        freeExpr (expPort);
        exit
    end;

    if token.typeof = T_EOL then
    begin
        initExpr (expSpeed, 9600);
        initExpr (expNbits, 8);
        initExpr (expNstop, 1);
        initExpr (expParity, 0)
    end
    else begin
        evalExpr (expSpeed, E_INTEGER);
        evalExpr (expNbits, E_INTEGER);
        evalExpr (expNstop, E_INTEGER);
        evalExpr (expParity, E_INTEGER);

        if (expSpeed.typeof <> E_INTEGER) or (expNbits.typeof <> E_INTEGER) or
           (expNstop.typeof <> E_INTEGER) or (expParity.typeof <> E_INTEGER) then
        begin
            errorMsg ('Esperava quatro inteiros: velocidade, número de bits, número de bits de parada e paridade');
            goto out
        end
    end;

    status := ord (inicLink (expPort.int, expSpeed.int, expNbits.int, expNstop.int, expParity.int));

    if status = 0 then
    begin
        with files[fd] do
        begin
            isOpen := true;
            typeof := F_SER;
            sleep (1500)    // espera conexão se estabilizar
        end
    end;

    setIOStatus (CS, status);

    processaSerial := true;

out:
    freeExpr (expPort);
    freeExpr (expSpeed);
    freeExpr (expNbits);
    freeExpr (expNstop);
    freeExpr (expParity)
end;

{--------------------------------------------------------}
{                  comando OBSERVA
{--------------------------------------------------------}

function processaObserva : boolean;
var
    fd     : integer;
    lvalue : LvalueRec;
    exp    : Operand;
    s      : integer;
begin
    processaObserva := false;

    if tokenIsID ('TECLADO') then
    begin
        fd := -1;
        nextToken
    end
    else begin
        fd := getFileDescriptor;
        if fd < 0 then exit
    end;

    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    s := 0;

    with files[fd] do
    begin
        case typeof of
            F_KEY:  s := ord (keyPressed);
            F_NET:  s := ord (chegouRede (sockfd) or temDadoBufRede (pbuf));
            F_SER:  s := ord (chegouLink);
            F_FILE: if not isOpen then s := 0
        end
    end;

    initExpr (exp, s);
    doAssignment (lvalue, exp);

    freeLvalue (lvalue);
    freeExpr (exp);

    processaObserva := true
end;

{--------------------------------------------------------}
{                  comando CHECA
{--------------------------------------------------------}

function processaCheca : boolean;
var
    lvalue : LvalueRec;
    exp    : Operand;
begin
    processaCheca := false;

    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    initExpr (exp, getIOStatus (CS));
    doAssignment (lvalue, exp);

    freeLvalue (lvalue);
    freeExpr (exp);

    processaCheca := true
end;

{--------------------------------------------------------}
{                  comando FECHA
{--------------------------------------------------------}

function processaFecha : boolean;
var
    fd : integer;
begin
    processaFecha := false;

    fd := getFileDescriptor;
    if fd < 0 then exit;

    with files[fd] do
    begin
{$I-}
        if isOpen then
        begin
            case typeof of
                F_NET:  begin
                            if pbuf <> NIL then fimBufRede (pbuf);
                            pbuf := NIL;
                            fechaConexao (sockfd)
                        end;
                F_SER:  finalLink;
                F_FILE: close (filefd)
            end;
            
            isOpen := false
        end
{$I+}
    end;

    if ioresult <> 0 then
    begin
        errorMsg ('Erro no fechamento do arquivo #' + intToStr (fd));
        exit
    end;

    processaFecha := true
end;

{--------------------------------------------------------}
{                  comando ESCREVE
{--------------------------------------------------------}

function processaEscreve : boolean;
label
    out;
var
    newLine, quiet : boolean;
    fd, i          : integer;
    final, s, sep  : string;
    exp, fmt       : Operand;

    function writeFile (s: string): boolean;
    label
        error;
    var
        i, status : integer;
    begin
        writeFile := false;

        with files[fd] do
        begin
            if not isOpen then goto error;

            status := 0;

            case typeof of
                F_KEY:  begin
                            if newLine   then
                            begin
                                writeln (s);
                                scLogln (s)
                            end
                            else begin
                                write (s);
                                scLog (s)
                            end;
                            if not quiet then sintetiza (s)
                        end;
                F_NET:  begin
                            if newLine   then
                                status := ord (writelnRede(sockfd, s))
                            else
                                status := ord (writeRede (sockfd, s))
                        end;
                F_SER:  begin
                            if newLine   then s := s + CR + LF;

                            for i := 1 to length(s) do
                                escLink (s[i]);

                            status := ord (erroLink);
                        end;
                F_FILE:  begin
{$I-}
                            if newLine   then writeln (filefd, s) else write (filefd, s);
                            status := ioresult
{$I+}
                        end
                end;

                setIOStatus (CS, status)
        end;

        writeFile := true;
        exit;

error:
        errorMsg ('Erro no processamento do arquivo #' + intToStr (fd))
    end;

begin
    setIOStatus (CS, 0);

    invalidateExpr (exp);
    invalidateExpr (fmt);

    processaEscreve := false;
    quiet           := false;
    fd              := -1;

    if token.typeof = T_SUS then
    begin
        fd := getFileDescriptor;
        if fd < 0 then exit
    end
    else if tokenIsID ('MUDO') then
    begin
        quiet := true;
        nextToken
    end;

    if tokenIsID ('LISTA') then
    begin
        nextToken;
        evalExpr (exp);

        if exp.typeof <> E_LIST then
        begin
            errorMsg ('Esperava uma lista para ser escrita');
            goto out
        end;

        newLine := true;
        sep := '';

        if (token.typeof <> T_EOL) then
        begin
            evalExpr (fmt);

            if fmt.typeof <> E_STRING then
            begin
                errorMsg ('Esperava uma cadeia como separador');
                goto out
            end;

            sep := fmt.pobj^.str;
        end;

        if sep <> '' then newLine := false;

        with exp.pobj^ do
        begin
            for i := 0 to list.count - 1 do
            begin
                if list.Items[i] = NIL then
                    s := '?'
                else
                    s := formatExpr (POperand (list.Items[i])^);

                if i < list.count - 1 then
                    writeFile (s + sep)
                else
                    writeFile (s)
            end
        end;

        if not newLine then
        begin
            newLine := true;
            writeFile ('')
        end;

        processaEscreve := true;
        goto out
    end;

    final := '';

    while not (token.typeof in [T_EOL, T_AMP]) do
    begin
        evalExpr (exp);

        invalidateExpr (fmt);
        if token.typeof = T_CL then
        begin
            nextToken;
            evalExpr (fmt)
        end;

        s := formatExpr (exp);

        if (convertToInteger (fmt) = E_INTEGER) then
            s := justifyString (s, fmt.int);

        final := final + s;

        freeExpr (exp);
        freeExpr (fmt);

        if token.typeof = T_VG then
        begin
            final := final + ' ';
            nextToken
        end
    end;

    newLine := true;
    if token.typeof = T_AMP then
    begin
        newLine := false;
        nextToken
    end;

    writeFile (final);

    processaEscreve := true;

out:
    freeExpr (exp);
    freeExpr (fmt);

    while sintFalando do;
end;

{--------------------------------------------------------}
{                  comando FALA
{--------------------------------------------------------}

function processaFala : boolean;
var
    waiting : boolean;
    exp     : Operand;
    final   : string;
begin
    waiting := true;

    final := '';
    while not (token.typeof in [T_EOL,T_AMP]) do
    begin
        evalExpr (exp);

        if token.typeof = T_VG then
        begin
            final := final + ' ';
            nextToken
        end;

        if exp.typeof = E_INVAL then
        begin
            errorMsg ('Expressão inválida para o comando FALA');
            skipToEOL
        end
        else begin
            final := final + formatExpr (exp);
            freeExpr (exp)
        end
    end;

    if token.typeof = T_AMP then
    begin
        waiting := false;
        nextToken
    end;

    if final = '' then
        sintPara
    else
        sintetiza (final);

    if waiting then
        while sintFalando do waitMessage;

    processaFala := true
end;

{--------------------------------------------------------}
{                  comando SOLETRA
{--------------------------------------------------------}

function processaSoletra : boolean;
var
    waiting : boolean;
    exp     : Operand;
    final   : string;
begin
    waiting := true;

    final := '';
    while not (token.typeof in [T_EOL,T_AMP]) do
    begin
        evalExpr (exp);

        if token.typeof = T_VG then
        begin
            final := final + ' ';
            nextToken
        end;

        if exp.typeof = E_INVAL then
        begin
            errorMsg ('Expressão inválida para o comando FALA');
            skipToEOL
        end
        else begin
            final := final + formatExpr (exp);
            freeExpr (exp)
        end
    end;

    if token.typeof = T_AMP then
    begin
        waiting := false;
        nextToken
    end;

    if final = '' then
        sintPara
    else
        sintSoletra (final);

    if waiting then
        while sintFalando do waitMessage;

    processaSoletra := true
end;

{--------------------------------------------------------}
{                  comando BIPA
{--------------------------------------------------------}

function processaBipa : boolean;
var
    clek : string;
    exp  : Operand;
begin
    if token.typeof = T_EOL then
    begin
        clek := '0'
    end
    else begin
        evalExpr (exp);
        clek := formatExpr (exp);
        freeExpr (exp)
    end;

    if clek = '1' then
        sintClek
    else
        sintBip;

    processaBipa := true
end;

{--------------------------------------------------------}
{                  comando COR
{--------------------------------------------------------}

function processaCor : boolean;
var
    exp : Operand;
begin
    processaCor := false;

    evalExpr (exp, E_INTEGER);

    if exp.typeof <> E_INTEGER then
    begin
        errorMsg ('Esperava o número da COR');
        freeExpr (exp);
        exit
    end;

    textColor (exp.int);

    processaCor := true
end;

{--------------------------------------------------------}
{                  comando FUNDO
{--------------------------------------------------------}

function processaFundo : boolean;
var
    exp : Operand;
begin
    processaFundo := false;

    evalExpr (exp, E_INTEGER);

    if exp.typeof <> E_INTEGER then
    begin
        errorMsg ('Esperava o número da COR DE FUNDO');
        freeExpr (exp);
        exit
    end;

    textBackground (exp.int);

    processaFundo := true
end;

{--------------------------------------------------------}
{                     comando TELA
{--------------------------------------------------------}

function processaTela : boolean;
type
    ScreenCmd   = (S_NOP, S_CLEAR, S_MINIMIZE, S_NORMAL, S_SIZE, S_GETCHAR, S_GETATTRIB, S_XY);
var
    cmd         : ScreenCmd;
    exp         : Operand;
    expx, expy  : Operand;
    x, y        : integer;
    lvaluenlin  : LvalueRec;
    lvaluencol  : LvalueRec;
    lvaluechar  : LvalueRec;

    function getCmd (s : string; var x, y : integer) : ScreenCmd;
    var
        sx, sy : string;
        p, error : integer;
    begin
        getCmd := S_NOP;

        if s = 'LIMPA' then
        begin
            getCmd := S_CLEAR
        end
        else if s = 'MINIMIZADA' then
        begin
            getCmd := S_MINIMIZE
        end
        else if s = 'NORMAL' then
        begin
            getCmd := S_NORMAL
        end
        else if s = 'TAMANHO' then
        begin
            getCmd := S_SIZE
        end
        else if s = 'CARACTERE' then
        begin
            getCmd := S_GETCHAR
        end
        else if s = 'ATRIBUTO' then
        begin
            getCmd := S_GETATTRIB
        end
        else if s[1] = '@' then
        begin
            delete (s, 1, 1);
            p := pos (',', s);

            if p <= 0 then
            begin
                p := pos (' ', s);
                if p <= 0 then exit
            end;

            sx := copy (s, 1, p-1);
            sx := trim (sx);

            delete (s, 1, p);
            sy := trim (s);

            val (sx, x, error);
            if error <> 0 then exit;
            val (sy, y, error);
            if error <> 0 then exit;

            getCmd := S_XY
        end
    end;

    function getXY (var xy : integer; c : char) : boolean;
    var
        exp : Operand;
    begin
        evalExpr (exp, E_INTEGER);

        if exp.typeof <> E_INTEGER then
        begin
            errorMsg ('Esperava um valor numérico para a coordenada ' + c + ' no comando TELA');
            freeExpr (exp);
            getXY := false;
            exit
        end;

        xy := exp.int;
        getXY := true
    end;

    procedure clearLines (y1, y2 : integer);
    var
        x, y, i : integer;
    begin
        x := WhereX; Y := WhereY;

        y1 := Max (1, Min (y1, ScreenSize.Y));
        y2 := Max (1, Min (y2, ScreenSize.Y));

        if y2 >= y1 then
        begin
            for i := y1 to y2 do
            begin
                GotoXY (1, i);
                ClrEOL
            end
        end
        else begin
            for i := y1 downto y2 do
            begin
                GotoXY (1, i);
                ClrEOL
            end
        end;

        GotoXY (x, y)
    end;

begin
    processaTela := false;
    cmd := S_NOP;

    if token.typeof = T_ID then
    begin
        cmd := getCmd (token.id, x, y);

        if cmd = S_NOP then
        begin
            evalExpr (exp);

            if exp.typeof = E_STRING then
                cmd := getCmd (exp.pobj^.str, x, y);

            freeExpr (exp)
        end
        else begin
            nextToken
        end
    end
    else if token.typeof = T_ROT then        { @25,80 é percebido como T_ROT, T_COMMA, expr }
    begin
        token.next := token.start + 1;       { Volta atrás, pulando o @ }
        nextToken;

        if not getXY (x, 'X') then exit;
        if token.typeof = T_VG then nextToken;
        if not getXY (y, 'Y') then exit;
        cmd := S_XY
    end;

    case cmd of
        S_NOP:      begin
                        errorMsg ('Modificadores inválidos para o comando TELA');
                        exit
                    end;
        S_CLEAR:    begin
                        if token.typeof = T_EOL then
                        begin
                            clrscr
                        end
                        else begin
                            evalExpr (expx, E_INTEGER);
                            if token.typeof = T_VG then nextToken;
                            evalExpr (expy, E_INTEGER);
                            clearLines (expx.int, expy.int)
                        end
                    end;
        S_MINIMIZE: showWindow (crtWindow, SW_HIDE);
        S_NORMAL:   begin
                        showWindow (crtWindow, SW_RESTORE);
                        bringWindowToTop (crtWindow);
                    end;
        S_SIZE:     begin
                        getLvalue (lvaluenlin);
                        if token.typeof = T_VG then nextToken;
                        getLvalue (lvaluencol);

                        if (lvaluenlin.id = NIL) or (lvaluencol.id = NIL) then
                        begin
                            errorMsg ('Esperava duas variáveis')
                        end
                        else begin
                            initExpr (exp, ScreenSize.X);
                            doAssignment (lvaluenlin, exp);
                            initExpr (exp, ScreenSize.Y);
                            doAssignment (lvaluencol, exp);
                            freeLvalue (lvaluencol);
                            freeLvalue (lvaluenlin)
                        end
                     end;
        S_GETCHAR:   begin
                        getLvalue (lvaluechar);
                        if token.typeof = T_VG then nextToken;
                        evalExpr (expx, E_INTEGER);
                        if token.typeof = T_VG then nextToken;
                        evalExpr (expy, E_INTEGER);

                        if (expx.typeof = E_INTEGER) and (expy.typeof = E_INTEGER) then
                        begin
                            if (expx.int > 0) and (expx.int <= ScreenSize.X) and
                               (expy.int > 0) and (expy.int <= ScreenSize.Y) then
                                initExpr (exp, getScreenChar (expx.int, expy.int))
                            else
                                initExpr (exp, '');

                            doAssignment (lvaluechar, exp)
                        end;

                        freeLvalue (lvaluechar);
                        freeExpr (expx);
                        freeExpr (expy);
                        freeExpr (exp)
                     end;
        S_GETATTRIB: begin
                        getLvalue (lvaluechar);
                        if token.typeof = T_VG then nextToken;
                        evalExpr (expx, E_INTEGER);
                        if token.typeof = T_VG then nextToken;
                        evalExpr (expy, E_INTEGER);

                        if (expx.typeof = E_INTEGER) and (expy.typeof = E_INTEGER) then
                        begin
                            if (expx.int > 0) and (expx.int <= ScreenSize.X) and
                               (expy.int > 0) and (expy.int <= ScreenSize.Y) then
                                initExpr (exp, getScreenAttrib (expx.int, expy.int))
                            else
                                initExpr (exp, -1);

                            doAssignment (lvaluechar, exp)
                        end;

                        freeLvalue (lvaluechar);
                        freeExpr (expx);
                        freeExpr (expy);
                        freeExpr (exp)
                    end;
        S_XY:       gotoxy (x, y)
    end;

    processaTela := true
end;

{--------------------------------------------------------}
{                      comando LE
{--------------------------------------------------------}

function processaLe : boolean;
var
    s, term, prompt : string;
    mode            : (M_PAUSE, M_LINE, M_CHAR, M_LIST, M_JSON);
    modif           : set of (M_EDIT, M_QUIET, M_PASSWD, M_MAIUSC, M_INTEGER);
    fd, i, error    : integer;
    lvalue          : LvalueRec;
    exp             : Operand;
    list            : TStringList;

    {--------------------------------------------------------}
    {      analisa os modificadores e argumentos
    {--------------------------------------------------------}

    function getOptions : boolean;
    var
        termExp    : Operand;
    begin
        modif      := [];
        list       := NIL;    initExpr (termExp, E_UNDEF);
        term       := #0;
        fd         := -1;                                { O default é ler do teclado }
        mode       := M_LINE;
        lvalue.id  := NIL;
        prompt     := '';

        getOptions := false;

        if token.typeof = T_EOL then                      { Comando LE puro, sem argumentos: apenas pausa }
        begin
            mode := M_PAUSE;
            getOptions := true;
            exit
        end;

        processaLe := false;

        if token.typeof = T_STR then                      { Comando LE com prompt }
        begin
            prompt := token.id;
            nextToken
        end
        else if token.typeof = T_SUS then
        begin
            fd := getFileDescriptor;                      { Obtém o descritor }
            if fd < 0 then exit;

            if not files[fd].isOpen then
            begin
                errorMsg ('Não há arquivo aberto associado ao descritor #' + intToStr (fd));
                exit
            end
        end;

        while token.typeof = T_ID do                      { Processa os modificadores }
        begin
            if token.id = 'EDITA' then
                modif := modif + [M_EDIT]
            else if token.id = 'MUDO' then
                modif := modif + [M_QUIET]
            else if token.id = 'SENHA' then
                modif := modif + [M_QUIET,M_PASSWD]
            else if (token.id = 'MAIUSC') or (token.id = 'MAIUSCULA') then
                modif := modif + [M_MAIUSC]
            else if token.id = 'INTEIRO' then
                modif := modif + [M_INTEGER]
            else if token.id = 'LISTA' then
                mode := M_LIST
            else if token.id = 'JSON' then
            begin
                mode := M_JSON
            end
            else begin
                getLvalue (lvalue);
                if lvalue.id = NIL then exit;

                if (mode = M_LIST) and (token.typeof <> T_EOL) and (token.typeof <> T_AMP) then
                begin
                    evalExpr (termExp, E_STRING);
                    term := termExp.pobj^.str;
                    freeExpr (termExp)
                end;

                break
            end;

            nextToken
        end;

        if token.typeof = T_AMP then
        begin
            mode := M_CHAR;
            nextToken
        end;

        if lvalue.id = NIL then
        begin
            errorMsg ('Faltou a variável para leitura');
            exit
        end;

        if ord (M_INTEGER in modif) + ord (mode = M_LIST) + ord (mode = M_JSON) > 1 then
        begin
            if      (M_INTEGER in modif) and (mode = M_LIST)                     then s := 'INTEIRO e LISTA'
            else if (M_INTEGER in modif) and (mode = M_JSON)                     then s := 'INTEIRO e DICIONARIO'
            else if                          (mode = M_LIST) and (mode = M_JSON) then s := 'LISTA e DICIONARIO'
            else if (M_INTEGER in modif) and (mode = M_LIST) and (mode = M_JSON) then s := 'INTEIRO, LISTA e DICIONARIO';
            errorMsg ('Modificadores ' + s + ' conflitantes para o comando Lê');
            exit
        end;

        if (fd >= 0) and (([M_QUIET,M_PASSWD,M_EDIT] * modif) <> []) then
        begin
            errorMsg ('Os modificadores MUDO, SENHA ou EDITA só se aplicam à leitura do teclado');
            exit
        end;

        getOptions := true
    end;

    {--------------------------------------------------------}
    {      converte um caractere lido para uma sequência     }
    {--------------------------------------------------------}

    function charToString (c : char) : String;
    var
        s : string;
    begin
        if (c >= ' ') then
        begin
            s := c
        end
        else if c = #$0 then
        begin
            if (M_QUIET in modif) then c := readKey else c := sintReadkey;
            str (ord(c), s);
            s := '#0#' + s
        end
        else begin
            str (ord(c), s);
            s := '#' + s
        end;

        charToString := s
    end;

    {--------------------------------------------------------}
    {      processa a leitura a partir do teclado            }
    {--------------------------------------------------------}

    function readFromKeyboard : boolean;
    var
        saveColor : word;
        verbose   : boolean;
        c         : char;
    begin
        verbose := not (M_QUIET in modif);

        case mode of
            M_LIST: begin
                        if verbose then scWrite ('Leitura de lista pelo teclado. ');

                        if term = #0 then
                        begin
                            if verbose then scWriteln ('Termine com uma linha vazia.');
                            term := ''
                        end
                        else begin
                            if verbose then scWriteln ('Termine com uma linha contendo ' + term)
                        end;

                        repeat
                            scReadln (s);
                            if s = term then break;
                            if M_MAIUSC in modif then s := maiuscAnsi (s);
                            list.Add (s)
                        until false;

                        if verbose then scWriteln ('Fim da leitura da lista')
                    end;
            M_CHAR: begin
                        if verbose then c := sintReadkey else c := readKey;
                        s := charToString (c); scLog (s)
                    end;
            M_LINE: begin
                        saveColor := textAttr;

                        if M_PASSWD in modif then textAttr := 0;

                        if not verbose then
                        begin
                            readln (s); scLog (s)
                        end
                        else if M_EDIT in modif then
                        begin
                            evalLvalue (lvalue, exp);
                            s := formatExpr (exp);
                            c := sintEdita (s, wherex, wherey, 255, true);
                            if c = ESC then s := '' else scLogln (s)
                        end
                        else begin
                            if prompt <> '' then scWrite (prompt);
                            scReadln (s)
                        end;

                        textAttr := saveColor
                    end
        end;

        readFromKeyboard := true
    end;

    {--------------------------------------------------------}
    {   processa a leitura a partir de uma conexão de rede   }
    {--------------------------------------------------------}

    function readFromNetwork : boolean;
    var
        iostatus : integer;
        c        : char;
    begin
        with files[fd] do
        begin
            case mode of
                M_LIST: begin
                            repeat
                                iostatus := ord (not readlnBufRede (pbuf, s, 30));
                                if (iostatus <> 0) or (term = s) then break;
                                if M_MAIUSC in modif then s := maiuscAnsi (s);
                                list.Add(s)
                            until false
                        end;
                M_CHAR: begin
                            setIOStatus (CS, ord (not leCaracBufRede (pbuf, c)));
                            s := charToString (c)
                        end;
                M_LINE: begin
                            setIOStatus (CS, ord (not readlnBufRede (pbuf, s, 30)))
                        end
            end
        end;

        readFromNetwork := true
    end;

    {--------------------------------------------------------}
    {       processa a leitura a partir de um arquivo        }
    {--------------------------------------------------------}

    function readFromFile : boolean;
    var
        c  : char;
    begin
        with files[fd] do
        begin
            case mode of
                M_LIST: begin
                            while not eof (filefd) do
                            begin
                                {$I-} readln (filefd, s); {$I+}
                                if term = s then break;
                                if M_MAIUSC in modif then s := maiuscAnsi (s);
                                list.Add (s)
                            end
                        end;
                M_CHAR: begin
                            if eof (filefd) then
                            begin
                                setIOStatus (CS, 1)
                            end
                            else begin
                                {$I-} read (filefd, c); {$I+}
                                s := charToString(c);
                                setIOStatus (CS, ioresult)
                            end
                        end;
                M_LINE: begin
                            if eof (filefd) then
                            begin
                                setIOStatus (CS, 1)
                            end
                            else begin
                                {$I-} readln (filefd, s); {$I+}
                                setIOStatus (CS, ioresult)
                            end
                        end
            end
        end;

        readFromFile := true
    end;

    {--------------------------------------------------------}
    {         lê uma linha a partir da porta serial          }
    {--------------------------------------------------------}

    function readLineFromSerialPort : string;
    var
        c : char;
        s : string;
        iostatus : integer;
    begin
        s := '';

        repeat
            leLink (c);
            iostatus := erroLink;
            if (iostatus <> 0) or (c = LF) then break;
            s := s + c
        until false;

        if (length(s) <> 0) and (s[length(s)] = CR) then
            delete (s, length(s), 1);

        setIOStatus (CS, iostatus);
        readLineFromSerialPort := s
    end;

    {--------------------------------------------------------}
    {       processa a leitura a partir da porta serial      }
    {--------------------------------------------------------}

    function readFromSerialLine : boolean;
    var
        c  : char;
    begin
        case mode of
            M_LIST: begin
                        repeat
                            s := readLineFromSerialPort;
                            if s = term then break;
                            if M_MAIUSC in modif then s := maiuscAnsi (s);
                            list.Add (s)
                        until s = term
                    end;
            M_CHAR: begin
                        if errolink <> 0 then
                        begin
                            setIOStatus (CS, 1)
                        end
                        else begin
                            leLink (c); s := charToString(c);
                            setIOStatus (CS, ord (erroLink))
                        end
                    end;
            M_LINE: begin
                        s := readLineFromSerialPort
                    end
        end;

        readFromSerialLine := true
    end;

begin
    setIOStatus (CS, 0);

    if not getOptions then
    begin
        processaLe := false;
        exit;
    end;

    if mode = M_PAUSE then
    begin
        readln;
        processaLe := true;
        exit
    end;

    if mode = M_JSON then
    begin
        readJSON (fd, exp)
    end
    else begin
        if mode = M_LIST then
            list := TStringList.Create;

        with files[fd] do
        begin
            case typeof of
                F_KEY:  processaLe := readFromKeyboard;
                F_NET:  processaLe := readFromNetwork;
                F_SER:  processaLe := readFromSerialLine;
                F_FILE: processaLe := readFromFile
            end
        end;

        if mode = M_LIST then
        begin
            initExpr (exp, list);
            list.free
        end
        else begin
            if M_MAIUSC in modif then s := maiuscAnsi (s);

            if M_INTEGER in modif then
            begin
                val (s, i, error);
                if error = 0 then
                    initExpr (exp, i)
                else
                    initExpr (exp, s)
            end
            else begin
                initExpr (exp, s)
            end
        end
    end;

    if exp.typeof = E_INVAL then
        errorMsg ('Erro de leitura; a variável "' + formatLvalue (lvalue, NIL) + '" não foi alterada')
    else
        doAssignment (lvalue, exp);

    freeLvalue (lvalue);
    freeExpr (exp);

    processaLe := true;
    exit;

    errorMsg ('Erro no processamento do arquivo #' + intToStr (fd))
end;

{--------------------------------------------------------}
{                  Comando ESPERA
{--------------------------------------------------------}

function processaEspera : boolean;
var
    i, n      : integer;
    name      : string;
    title     : array [0..250] of char;
    time, win : Operand;
begin
    processaEspera := false;

    setIOStatus (CS, 0);

    evalExpr (time, E_INTEGER);

    if (time.typeof <> E_INTEGER) or (time.int <= 0) then
    begin
        errorMsg ('Esperava o número de segundos');
        freeExpr (time);
        exit
    end;

    if tokenIsID ('MS') then
    begin
        DELAY (time.int);
        nextToken
    end
    else if token.typeof = T_EOL then
    begin
        for i := 1 to time.int do
            DELAY (1000)
    end
    else begin
        evalExpr (win);

        if (convertToString (win) <> E_STRING) or (win.pobj^.str = '') then
        begin
            errorMsg ('Esperava o nome da janela');
            freeExpr (win);
            exit
        end;

        name := maiuscAnsi (win.pobj^.str);

        freeExpr (win);

        n := time.int * 2;
        setIOStatus (CS, 1);

        for i := 1 to n do
        begin
            getWindowText (getForegroundWindow, title, 250);

            if pos (name, maiuscAnsi (strPas (title))) <> 0 then
            begin
                setIOStatus (CS, 0);     { Chegou! }
                break
            end;

            DELAY (500)
        end
    end;

    processaEspera := true
end;

{--------------------------------------------------------}
{                  Comando DIGITA
{--------------------------------------------------------}

function processaDigita : boolean;
var
    exp : Operand;
begin
    processaDigita := false;

    while not (token.typeof in [T_EOL,T_AMP]) do
    begin
        evalExpr (exp, E_STRING);

        if exp.typeof <> E_STRING then
        begin
            errorMsg ('Esperava uma cadeia');
            freeExpr (exp);
            exit
        end;

        keyboardString (exp.pobj^.str, 100);

        freeExpr (exp)
    end;

    if token.typeof = T_AMP then
        nextToken
    else
        keyboardVirtKey (VK_RETURN, false, false, false, 100);

    processaDigita := true
end;

{--------------------------------------------------------}
{                  Comando ACIONA
{--------------------------------------------------------}

function processaAciona : boolean;
type
    ModType   = ( CTRL, SHIFT, ALT );
var
    s, t      : string;
    letter    : char;
    error     : integer;
    modifier  : array[ModType] of boolean;
    value     : integer;
    exp       : Operand;

    {----------------------------------------------------}
    {  Obtém o valor numérico a partir do nome da tecla
    {----------------------------------------------------}

    function getKeyValue (key : string) : integer;
    type
        KeyEntry  = record
                        name : string[10];
                        value : integer
                    end;
    const
        NKEYS           = 32;
        keytable        : array [1 .. NKEYS] of KeyEntry =
        (
            ( name: 'UP';        value: VK_UP       ),
            ( name: 'DOWN';      value: VK_DOWN     ),
            ( name: 'LEFT';      value: VK_LEFT     ),
            ( name: 'RIGHT';     value: VK_RIGHT    ),
            ( name: 'ESCAPE';    value: VK_ESCAPE   ),
            ( name: 'ESC';       value: VK_ESCAPE   ),
            ( name: 'ENTER';     value: VK_RETURN   ),
            ( name: 'RETURN';    value: VK_RETURN   ),
            ( name: 'BACKSPACE'; value: VK_BACK     ),
            ( name: 'TAB';       value: VK_TAB      ),
            ( name: 'F1';        value: VK_F1       ),
            ( name: 'F2';        value: VK_F2       ),
            ( name: 'F3';        value: VK_F3       ),
            ( name: 'F4';        value: VK_F4       ),
            ( name: 'F5';        value: VK_F5       ),
            ( name: 'F6';        value: VK_F6       ),
            ( name: 'F7';        value: VK_F7       ),
            ( name: 'F8';        value: VK_F8       ),
            ( name: 'F9';        value: VK_F9       ),
            ( name: 'F10';       value: VK_F10      ),
            ( name: 'F11';       value: VK_F11      ),
            ( name: 'F12';       value: VK_F12      ),
            ( name: 'INS';       value: VK_INSERT   ),
            ( name: 'HOME';      value: VK_HOME     ),
            ( name: 'DEL';       value: VK_DELETE   ),
            ( name: 'DELETE';    value: VK_DELETE   ),
            ( name: 'END';       value: VK_END      ),
            ( name: 'PAGEUP';    value: VK_PRIOR    ),
            ( name: 'PAGEDN';    value: VK_NEXT     ),
            ( name: 'PRIOR';     value: VK_PRIOR    ),
            ( name: 'NEXT';      value: VK_NEXT     ),
            ( name: 'SNAPSHOT';  value: VK_SNAPSHOT )
        );
    var
        k : integer;
    begin
        for k := 1 to NKEYS do
        begin
            if keytable[k].name = key then
            begin
                getKeyValue := keytable[k].value;
                exit
            end
        end;

        getKeyValue := 0
    end;

    {----------------------------------------------------}
    {              Extrai os modificadores
    {----------------------------------------------------}

    procedure extractModifiers;
    const
        modkeys : array[ModType] of string[7] = ( 'CTRL+', 'SHIFT+', 'ALT+' );
    var
        m       : ModType;
        found   : boolean;
    begin
        for m := CTRL to ALT do modifier[m] := false;

        repeat
            found := false;

            for m := CTRL to ALT do
            begin
                t := modkeys[m];

                if copy (s, 1, length(t)) = t then
                begin
                    modifier[m] := true;
                    delete (s, 1, length(t));
                    found := true
                end
            end
        until not found or (s = '')
    end;
begin
    processaAciona := false;

    evalExpr (exp);

    if (exp.typeof <> E_STRING) or (exp.pobj^.str = '') then
    begin
        errorMsg ('Esperava o nome de uma tecla');
        freeExpr (exp);
        exit
    end;

    s := exp.pobj^.str;
    freeExpr (exp);

    if length (s) = 1 then
    begin
        keyboardClick (s[1])
    end
    else begin
        s := maiuscAnsi (s);

        extractModifiers;

        if s = '' then exit;

        value := getKeyValue (s);

        if value = 0 then
        begin
            letter := upcase(s[1]);
            value := ord (letter);
            delete (s, 1, 1);

            if letter = '#' then
            begin
                val (s, value, error);
                if error <> 0 then exit
            end
            else if s <> '' then exit
        end;

        keyboardVirtKey (value, modifier[CTRL], modifier[SHIFT], modifier[ALT], 100)
    end;

    processaAciona := true
end;

{--------------------------------------------------------}
{                  Comando CLICA
{--------------------------------------------------------}

function processaClica : boolean;
label
    out;
var
    clickType  : (C_SIMPLE, C_DOUBLE, C_RIGHT, C_NULL);
    tela       : boolean;
    rect       : TRect;
    expx, expy : Operand;
begin
    processaClica := false;
    clickType     := C_SIMPLE;

    if token.typeof = T_ID then
    begin
        if token.id = 'DUPLO' then
        begin
            clickType := C_DOUBLE;
            nextToken
        end
        else if token.id = 'DIREITA' then
        begin
            clickType := C_RIGHT;
            nextToken
        end
        else if token.id = 'NULO' then
        begin
            clickType := C_NULL;
            nextToken
        end
    end;

    tela := false;
    if tokenIsID ('TELA') then
    begin
        tela := true;
        nextToken
    end;

    evalExpr (expx, E_INTEGER);

    if token.typeof = T_VG then
        nextToken;

    evalExpr (expy, E_INTEGER);

    if (expx.typeof <> E_INTEGER) or (expy.typeof <> E_INTEGER) then
    begin
        errorMsg ('Esperava expressões numéricas para as coordenadas X e Y');
        goto out
    end;

    if not tela then
    begin
        getWindowRect (getForegroundWindow, rect);
        expx.int := expx.int + rect.left + getSystemMetrics (SM_CXFRAME);
        expy.int := expy.int + rect.top  + SM_CYCAPTION
    end;

    case clickType of
        C_SIMPLE: mouseClick (expx.int, expy.int);
        C_DOUBLE: mouseDoubleClick (expx.int, expy.int);
        C_RIGHT:  mouseRightClick (expx.int, expy.int);
        C_NULL:   mouseMove (expx.int, expy.int);
    end;

    processaClica := true;

out:
    freeExpr (expx);
    freeExpr (expy)
end;

{--------------------------------------------------------}
{                  Comando TRANSFERE
{--------------------------------------------------------}

function processaTransfere : boolean;
label
    out;
const
    MiB    = 1024 * 1024;
var
    p      : PChar;
    from   : boolean;
    lvalue : LvalueRec;
    exp    : Operand;
    len    : integer;
begin
    processaTransfere := false;

    if token.typeof <> T_ID then
    begin
        errorMsg ('Esperava DE ou PARA como opção para o comando TRANSFERE');
        exit
    end;

    if token.id = 'DE' then
        from := true
    else if token.id = 'PARA' then
        from := false
    else begin
        errorMsg ('Esperava DE ou PARA como opção para o comando TRANSFERE');
        exit
    end;

    nextToken;

    if from then
    begin
        evalExpr (exp, E_STRING);

        if exp.typeof <> E_STRING then
        begin
            errorMsg ('Esperava uma cadeia como texto a TRANSFERIR');
            goto out
        end;

        if exp.pobj^.str = '' then
            exp.pobj^.str := ' ';

        len := length (exp.pobj^.str);

        if len > MiB then
        begin
            errorMsg ('Tamanho excessivo: ' + IntToStr (len) + ' bytes')
        end
        else begin
            try GetMem (p, len + 1) except p := NIL end;

            if p = NIL then
            begin
                errorMsg ('Erro ao tentar alocar ' + IntToStr (len + 1) + ' bytes')
            end else
            begin
                StrPCopy (p, copy (exp.pobj^.str, 1, len));

                if not putClipBoard (p, len) then
                   errorMsg ('Não pude copiar para a área de transferência do Windows');

                FreeMem (p);
            end
        end
    end
    else begin
        getLvalue (lvalue);
        if lvalue.id = NIL then exit;

        try GetMem (p, MiB) except p := NIL end;

        if p = NIL then
        begin
            initExpr (exp, '')
        end
        else begin
            getClipBoard (p, MiB);
            initExpr (exp, strPas (p));
            FreeMem (p)
        end;

        doAssignment (lvalue, exp);
        freeLvalue (lvalue)
    end;

    processaTransfere := true;

out:
    freeExpr (exp)
end;

{--------------------------------------------------------}
{                  Comando JANELA
{--------------------------------------------------------}

function processaJanela : boolean;
label
    next, found;
var
    currWnd          : hwnd;
    txt              : array [0..144] of char;
    p                : integer;
    option, title, s : string;
    atStart, atEnd,
    visible, iconic  : boolean;
    exp              : Operand;
begin
    processaJanela := false;
    setIOStatus (CS, 0);

    if token.typeof <> T_ID then
    begin
        errorMsg ('Esperava a opção para o comando JANELA');
        exit
    end;

    option := token.id;

    nextToken;

    evalExpr (exp, E_STRING);

    if exp.typeof <> E_STRING then
    begin
        errorMsg ('Esperava uma cadeia com o título da janela');
        freeExpr (exp);
        exit
    end;

    s := maiuscAnsi (exp.pobj^.str);

    freeExpr (exp);

    currWnd := GetWindow (crtWindow, GW_HWNDFIRST);

    atStart := false;
    atEnd   := false;

    if (s <> '') and (s[1] = '*') then
    begin
        atStart := true;
        delete (s, 1, 1)
    end;

    if (s <> '') and (s[length(s)] = '*') then
    begin
        atEnd := true;
        delete (s, length (s), 1)
    end;

    while currWnd <> 0 do
    begin
        if isWindowEnabled (currWnd) then
        begin
            GetWindowText (CurrWnd, txt, 144);

            visible := isWindowVisible (currWnd);
            iconic  := isIconic (currWnd);
            title   := maiuscAnsi (strPas (txt));

            if ((visible or iconic) and (length (title) <> 0)) then
            begin
                p := pos (s, title);
                if (p = 0) or ((p <> 1) and atStart) or
                   ((p <> (length (title) - length (s) + 1)) and atEnd) then
                    goto next;
                goto found;
            end;
        end;
next:
        currWnd := GetWindow (currWnd, GW_HWNDNEXT)
    end;

    processaJanela := true;
    setIOStatus (CS, 1);
    exit;   { não achou }

found:
    if option = 'FECHA' then
    begin
        sendMessage (currWnd, WM_CLOSE, 0, 0)
    end
    else if option = 'NORMAL' then
    begin
        ShowWindow (currWnd, SW_SHOWNORMAL);
        setActiveWindow (currWnd);
    end
    else if option = 'MAXIMIZA' then
    begin
        ShowWindow (currWnd, SW_MAXIMIZE);
        setActiveWindow (currWnd);
    end
    else if option = 'MINIMIZA' then
    begin
        ShowWindow (currWnd, SW_MINIMIZE)
    end
    else begin
        errorMsg ('Opção inválida para o comando JANELA: ' + option);
        exit
    end;

    processaJanela := true
end;

{--------------------------------------------------------}
{                  Comando CAPTURA
{--------------------------------------------------------}

function processaCaptura : boolean;
label
    out;
var
    p      : array [0..255] of char;
    option : string;
    lvalue : LvalueRec;
    exp    : Operand;
begin
    processaCaptura := false;

    if token.typeof <> T_ID then
    begin
        errorMsg ('Esperava uma opção para o comando CAPTURA');
        exit
    end;

    option := token.id;

    nextToken;
    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    invalidateExpr (exp);

    if (option = 'TITULO') or (option = 'ATIVA') then
    begin
        getWindowText (getForegroundWindow, p, 255)
    end
    else if (option = 'FOCO') then
    begin
        strcopy (p, '');

        if getFocus <> 0 then
            getWindowText (getFocus, p, 255)
    end
    else if (option = 'CAMPO') then
    begin
        keyboardVirtKey (VK_HOME,   false, false, false, 100);
        keyboardVirtKey (VK_END,    false, true,  false, 100);
        keyboardVirtKey (VK_INSERT, true,  false, false, 100);
        getClipBoard (p, 255)
    end
    else begin
        errorMsg ('Opção inválida para o comando CAPTURA: ' + option);
        goto out
    end;

    initExpr (exp, strPas (p));
    doAssignment (lvalue, exp);

    processaCaptura := true;

out:
    freeLvalue (lvalue);
    freeExpr (exp)
end;

{--------------------------------------------------------}
{                  comando TOCA
{--------------------------------------------------------}

procedure sendMCIString (s: string; var retMCI : string); overload;
var
    p, q : MciStr;
begin
    strPcopy (p, s);
    mciSendString (p, q, 255, 0);
    retMCI := strPas (q)
end;

procedure sendMCIString (s: string); overload;
var
    p, q : MciStr;
begin
    strPcopy (p, s);
    mciSendString (p, q, 255, 0)
end;

function processaToca : boolean;
var
    retMCI     : string;
    background : boolean;
    exp        : Operand;

    procedure play (path : string; background : boolean);
    begin
        if background then
        begin
            sendMCIString ('play ' + path)
        end
        else begin
            sendMCIString ('open "' + path + '" alias myfile');
            sendMCIString ('play myfile');
            repeat
                delay (100);
                sendMCIString ('status myfile mode', retMCI);
            until keypressed or (retMCI <> 'playing');
            while keypressed do readkey;

            sendMCIString ('stop myfile');
            sendMCIString ('close myfile');
        end
    end;

begin
    processaToca := false;
    background   := false;

    evalExpr (exp);

    if exp.typeof <> E_STRING then
    begin
        errorMsg ('Esperava um nome de arquivo como argumento para o comando TOCA');
        freeExpr (exp);
        exit
    end;

    if token.typeof = T_AMP then
    begin
        background := true;
        nextToken
    end;

    play (exp.pobj^.str, background);

    freeExpr (exp);

    processaToca := true
end;

{--------------------------------------------------------}
{                  comando MCI
{--------------------------------------------------------}

function processaMci : boolean;
var
    retMCI : string;
    lvalue : LvalueRec;
    exp    : Operand;
    save   : TokenRec;
begin
    processaMci := false;

    save := token;

    evalExpr (exp);

    if token.typeof <> T_EOL then
    begin
        token := save;
        getLvalue (lvalue);
        if lvalue.id = NIL then exit;

        evalExpr (exp)
    end
    else begin
        lvalue.id := NIL
    end;

    if (exp.typeof <> E_STRING) or (exp.pobj^.str = '') then
    begin
        errorMsg ('Esperava uma cadeia com o comando MCI');

        if lvalue.id <> NIL then
            freeLvalue (lvalue);

        freeExpr (exp);
        exit
    end;

    sendMCIString (exp.pobj^.str, retMCI);

    exp.pobj^.str := retMCI;

    if lvalue.id <> NIL then
    begin
        doAssignment (lvalue, exp);
        freeLvalue (lvalue)
    end
    else begin
        scWriteln (exp.pobj^.str)
    end;

    freeExpr (exp);

    processaMci := true
end;

{--------------------------------------------------------}
{                  Comando BUSCA
{--------------------------------------------------------}

function processaBusca : boolean;
var
    lvalue : LvalueRec;
    exp    : Operand;
    name   : string;
begin
    processaBusca := false;
    name := '';

    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    if tokenIsId ('PROXIMO') then
    begin
        nextToken;

        if searchAttrib = 0 then
        begin
            errorMsg ('Uso indevido do modificador PRÓXIMO');
            exit
        end;

        while true do
        begin
            if FindNext (dirInfo) <> 0 then     { Acabou a busca }
            begin
                FindClose (dirInfo);
                searchAttrib := 0;
                break
            end;

            if dirInfo.attr and searchAttrib <> 0 then
            begin
                name := dirInfo.FindData.cFileName;
                break;
            end
        end
    end
    else if token.typeof = T_EOL then
    begin
        GetDir (0, name)
    end
    else begin
        if searchAttrib <> 0 then   { Houve busca antes? }
            FindClose (dirInfo);

        searchAttrib := faArchive;

        if tokenIsID ('DIR') then
        begin
            searchAttrib := faDirectory;
            nextToken
        end;

        evalExpr (exp);

        if exp.typeof <> E_STRING then
        begin
            errorMsg ('Esperava cadeia com padrão de busca');
            freeLvalue (lvalue);
            freeExpr (exp);
            exit
        end;

        if FindFirst (exp.pobj^.str, searchAttrib, dirInfo) = 0 then
        begin
            if dirInfo.attr and searchAttrib <> 0 then
                name := dirInfo.FindData.cFileName
        end;

        freeExpr (exp)
    end;

    initExpr (exp, trim (name));
    doAssignment (lvalue, exp);

    freeLvalue (lvalue);
    freeExpr (exp);

    processaBusca := true
end;

{--------------------------------------------------------}
{                  Comando RENOMEIA
{--------------------------------------------------------}

function processaRenomeia : boolean;
label
    out;
var
    ignore         : boolean;
    srcExp, dstExp : Operand;
    f              : text;
begin
    processaRenomeia := false;

    evalExpr (srcExp);
    evalExpr (dstExp);

    if (srcExp.typeof <> E_STRING) or (srcExp.pobj^.str = '') or (dstExp.typeof <> E_STRING) or (dstExp.pobj^.str = '') then
    begin
        errorMsg ('Esperava dois nomes de arquivos para o comando RENOMEIA');
        goto out
    end;

    ignore := false;
    if token.typeof = T_AMP then
    begin
        ignore := true;
        nextToken
    end;

    assign (f, srcExp.pobj^.str);
    {$I-} rename (f, dstExp.pobj^.str);  {$I+}

    processaRenomeia := (ioresult = 0) or ignore;

out:
    freeExpr (srcExp);
    freeExpr (dstExp)
end;

{--------------------------------------------------------}
{                  Comando REPLICA
{--------------------------------------------------------}

function processaReplica : boolean;
label
    out;
type
    pvet30k         = ^vet30k;
    vet30k          = array [0..29999] of byte;
var
    ignore          : boolean;
    f1, f2          : file;
    buf             : pvet30k;
    nRead, nWritten : integer;
    srcExp, dstExp  : Operand;
begin
    processaReplica := false;

    evalExpr (srcExp);
    evalExpr (dstExp);

    buf := NIL;

    if (srcExp.typeof <> E_STRING) or (srcExp.pobj^.str = '') or (dstExp.typeof <> E_STRING) or (dstExp.pobj^.str = '') then
    begin
        errorMsg ('Esperava nomes de arquivos para o comando REPLICA');
        goto out
    end;

    ignore := false;
    if token.typeof = T_AMP then
    begin
        ignore := true;
        nextToken
    end;

    try NEW (buf) except buf := NIL end;

    if buf = NIL then goto out;

    assign (f1, srcExp.pobj^.str);
    assign (f2, dstExp.pobj^.str);
    {$I-} reset (f1, 1);  {$I+}
    if (ioresult <> 0) and (not ignore) then goto out;
    {$I-} rewrite (f2, 1);  {$I+}
    if (ioresult <> 0) and (not ignore) then goto out;

    while not eof (f1) do
    begin
{$I-}   blockRead (f1, buf^, sizeof (buf^), nRead);   {$I+}
        if (ioresult <> 0) and (not ignore) then
        begin
            errorMsg ('Erro na leitura do arquivo ' + srcExp.pobj^.str);
            goto out
        end;

{$I-}   blockWrite (f2, buf^, nRead, nWritten);      {$I+}
        if (nWritten <> nRead) and (not ignore) then
        begin
            errorMsg ('Erro na escrita do arquivo ' + dstExp.pobj^.str);
            goto out
        end
    end;

    processaReplica := true;

out:
    if buf <> NIL then DISPOSE (buf);
    {$I-}  close (f1); close (f2);  {$I+}
    freeExpr (srcExp);
    freeExpr (dstExp)
end;

{--------------------------------------------------------}
{                  comando REMOVE
{--------------------------------------------------------}

function processaRemove : boolean;
label
    out;
var
    f      : file;
    ignore : boolean;
    exp    : Operand;
begin
    processaRemove := false;

    evalExpr (exp);

    if exp.typeof <> E_STRING then
    begin
        errorMsg ('Esperava um nome de arquivo');
        goto out
    end;

    if token.typeof = T_AMP then
    begin
        ignore := true;
        nextToken
    end
    else begin
        ignore := false
    end;

{$I-}
    assign (f, exp.pobj^.str);
    erase (f);
    if (ioresult <> 0) and not ignore then
    begin
        errorMsg ('Erro no apagamento do arquivo ' + exp.pobj^.str);
        goto out
    end;
{$I+}

    processaRemove := true;

out:
    freeExpr (exp)
end;

{--------------------------------------------------------}
{                  Comando MOUSE
{--------------------------------------------------------}

function processaMouse : boolean;
label
    out;
var
    mode               : set of (M_POS, M_CLICK, M_DOUBLE, M_RIGHT);
    pt                 : TPOINT;
    rect               : TRECT;
    xorig, yorig, x, y : integer;
    lvalue             : LvalueRec;
    exp                : Operand;
begin
    processaMouse := false;

    mode := [];
    if tokenIsID ('CAPTURA') then
    begin
        mode := mode + [M_POS];
        nextToken
    end;

    if tokenIsID ('CLICA') then
    begin
        mode := mode + [M_CLICK];
        nextToken;

        if (token.typeof = T_ID) then
        begin
            if (token.id = 'DUPLO') then
            begin
                mode := mode + [M_DOUBLE];
                nextToken
            end
            else if (token.id = 'DIREITA') then
            begin
                mode := mode + [M_RIGHT];
                nextToken
            end
        end
    end;

    if tokenIsID ('TELA') then
    begin
        xorig := 0;
        yorig := 0;
        nextToken
    end
    else begin
        getWindowRect (getForegroundWindow, rect);
        xorig := rect.left + getSystemMetrics (SM_CXFRAME);
        yorig := rect.top + SM_CYCAPTION
    end;

    if M_POS in mode then
    begin
        GetCursorPos(pt);

        getLvalue (lvalue);
        initExpr (exp, pt.x - xorig);
        doAssignment (lvalue, exp);

        getLvalue (lvalue);
        initExpr (exp, pt.y - yorig);
        doAssignment (lvalue, exp)
    end
    else begin
        lvalue.id := NIL;

        evalExpr (exp, E_INTEGER);

        if exp.typeof <> E_INTEGER then
        begin
            errorMsg ('Esperava um valor inteiro');
            goto out
        end;

        x := exp.int;
        freeExpr (exp);

        evalExpr (exp, E_INTEGER);

        if exp.typeof <> E_INTEGER then
        begin
            errorMsg ('Esperava um valor inteiro');
            goto out
        end;

        y := exp.int;
        freeExpr (exp);

        if not (M_CLICK in mode) then
        begin
            mouseMove (x - xorig, y - yorig)
        end
        else begin
            if M_DOUBLE in mode then
                 mouseDoubleClick (x - xorig, y - yorig)
            else if M_RIGHT in mode then
                 mouseDoubleClick (x - xorig, y - yorig)
            else
                 mouseMove (x - xorig, y - yorig)
        end
    end;

    processaMouse := true;

out:
    freeLvalue (lvalue);
    freeExpr (exp)
end;

{--------------------------------------------------------}
{                  Comando DIR
{--------------------------------------------------------}

function processaDir : boolean;
label
    out;
var
    op      : (O_CREATE, O_REMOVE, O_CHANGE);
    ignore  : boolean;
    exp     : Operand;
begin
    processaDir := false;

    if token.typeof <> T_ID then
        token.id := '';

    if token.id = 'CRIA' then
        op := O_CREATE
    else if token.id = 'REMOVE' then
        op := O_REMOVE
    else if token.id = 'TROCA' then
        op := O_CHANGE
    else begin
        errorMsg ('Esperava CRIA, REMOVE ou TROCA');
        exit
    end;

    nextToken;
    evalExpr (exp);

    if (exp.typeof <> E_STRING) or (exp.pobj^.str = '') then
    begin
        errorMsg ('Esperava um nome');
        goto out
    end;

    ignore := false;
    if token.typeof = T_AMP then
    begin
        ignore := true;
        nextToken
    end;

{$I-}
    case op of
         O_CREATE: mkdir (exp.pobj^.str);
         O_REMOVE: rmdir (exp.pobj^.str);
         O_CHANGE: chdir (exp.pobj^.str);
    end;
{$I+}

    if (ioresult <> 0) and (not ignore) then
    begin
        errorMsg ('Erro no processamento do diretório ' + exp.pobj^.str);
        goto out
    end;

    processaDir := true;

out:
    freeExpr (exp)
end;

{--------------------------------------------------------}
{                    Comando IP
{--------------------------------------------------------}

function processaIP : boolean;
label
    out;
var
    ipaddr  : sockaddr_in;
    local   : boolean;
    fd      : integer;
    size    : integer;
    lvalue  : LvalueRec;
    exp     : Operand;
begin
    processaIP := false;

    if token.typeof = T_ID then
    begin
        if token.id = 'LOCAL' then
            local := true
        else if token.id = 'REMOTO' then
            local := false
        else
            exit
    end
    else begin
        exit
    end;

    nextToken;
    fd := getFileDescriptor;
    if fd < 0 then exit;

    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    with files[fd] do
    begin
        if not isOpen or (typeof <> F_NET) or (sockfd < 0) then goto out;

        size := sizeof (sockaddr_in);

        if local then
            getSockName (sockfd, ipaddr, size)
        else
            getpeername (sockfd, ipaddr, size);

        initExpr (exp, strPas (inet_ntoa (TInAddr (ipaddr.sin_addr.S_addr))));
        doAssignment (lvalue, exp);
        freeExpr (exp)
    end;

    processaIP := true;

out:
    freeLvalue (lvalue)
end;

{--------------------------------------------------------}
{                    Comando MENU
{--------------------------------------------------------}

function processaMenu : boolean;
var
    xmin, ymin, xmax, ymax, exp : Operand;
    lvalue1, lvalue2, lvalue3   : LvalueRec;
    s                           : string;
    c1, c2                      : char;
    n                           : integer;
    selec                       : boolean;
begin
    processaMenu := false;

    if token.typeof <> T_ID then
    begin
        errorMsg ('Esperava uma opção para o comando MENU');
        exit
    end;

    if token.id = 'CRIA' then
    begin
        nextToken;
        evalExpr (xmin, E_INTEGER);
        evalExpr (ymin, E_INTEGER);
        evalExpr (xmax, E_INTEGER);
        evalExpr (ymax, E_INTEGER);

        if (xmin.typeof <> E_INTEGER) or (ymin.typeof <> E_INTEGER) or (xmax.typeof <> E_INTEGER) or (ymax.typeof <> E_INTEGER) then
        begin
            errorMsg ('Esperava quatro expressões numéricas para o comando MENU CRIA');
            freeExpr (xmin);
            freeExpr (ymin);
            freeExpr (xmax);
            freeExpr (ymax);
            exit
        end;

        folheiaCria (xmin.int, ymin.int, xmax.int, ymax.int);
        itemInic := 1
    end
    else if token.id = 'ADICIONA' then
    begin
        nextToken;
        evalExpr (exp, E_STRING);

        if exp.typeof <> E_STRING then
        begin
            errorMsg ('Esperava uma cadeia');
            freeExpr (exp);
            exit
        end;

        folheiaAdiciona (exp.pobj^.str);
        freeExpr (exp)
    end
    else if token.id = 'TERMINA' then
    begin
        nextToken;
        folheiaLimpa;
        folheiaDestroi
    end
    else if token.id = 'EXECUTA' then
    begin
        nextToken;

        getLvalue (lvalue1);  if lvalue1.id = NIL then exit;
        getLvalue (lvalue2);  if lvalue2.id = NIL then exit;
        getLvalue (lvalue3);  if lvalue3.id = NIL then exit;

        evalLvalue (lvalue1, exp, E_INTEGER);

        if exp.typeof <> E_INTEGER then
        begin
            freeExpr (exp);
            initExpr (exp, 1)
        end;

        repeat
            itemInic := exp.int;
            if itemInic <= 0 then
                itemInic := 1;
            folheiaExecuta (itemInic, n, c1, c2, true)
        until (c1 <> #0) or (c2 in [F1..F12]);

        initExpr (exp, n);
        doAssignment (lvalue1, exp);
        freeExpr (exp);

        if c1 >= ' ' then
            s := c1
        else if (c1 = #0) and (c2 in [F1..F12]) then
            s := '#0#' + intToStr (ord (c2) - ord (F1) + 59)
        else begin
            str (ord (c1), s);
            s := '#' + s
        end;

        initExpr (exp, s);
        doAssignment (lvalue2, exp);
        freeExpr (exp);

        folheiaObtemItem (n, s, selec);

        initExpr (exp, s);
        doAssignment (lvalue3, exp);
        freeExpr (exp);

        freeLvalue (lvalue1);
        freeLvalue (lvalue2);
        freeLvalue (lvalue3)
    end
    else begin
        errorMsg ('Opção inválida para o comando MENU: ' + token.id);
        exit
    end;

    processaMenu := true
end;

{--------------------------------------------------------}
{        Obtém um caminho temporário para o arquivo
{--------------------------------------------------------}

function getTmpFilePath (ext : string) : string;
var
    tmpFileName, tmpPath : array[0..255] of char;
    tmpExt               : array[0..16]  of char;
begin
    strPCopy (tmpExt, ext);

    getTempPath (255, tmpPath);
    getTempFileName (tmpPath, tmpExt, 0, tmpFileName);

    getTmpFilePath := strPas (tmpFileName)
end;

{--------------------------------------------------------}
{        Obtém o tipo da imagem
{--------------------------------------------------------}

function getImageType (path : string) : ImageType;
var
    ext : string;
begin
    ext := AnsiUpperCase (ExtractFileExt (path));

    if     (ext = '.JPG') or (ext = '.JPEG') then getImageType := JPG
    else if ext = '.BMP'                     then getImageType := BMP
    else if ext = '.PNG'                     then getImageType := PNG
    else                                          getImageType := NONE
end;

{--------------------------------------------------------}
{                    Comando IMAGEM
{--------------------------------------------------------}

function processaImagem : boolean;
var
    path       : string;
    ignore     : boolean;
    expPath    : Operand;
    it         : ImageType;
    expx, expy : Operand;
    x, y       : integer; 
    tmpPath    : String;
    colando    : boolean;
    pngImage   : TPNGObject;
    bmpImage   : TBitmap;
begin
    processaImagem := false;

    if token.typeof = T_EOL then
    begin
        closeBMP;
        processaImagem := true;
        exit
    end;

    evalExpr (expPath);

    if (expPath.typeof <> E_STRING) or (expPath.pobj^.str = '') then
    begin
        errorMsg ('Esperava nome de arquivo');
        freeExpr (expPath);
        exit
    end;

    path := expPath.pobj^.str;
    freeExpr (expPath);

    it := getImageType (path);
    if it = NONE then
    begin
        errorMsg ('Extensão do arquivo não reconhecida');
        exit
    end;

    x := 0;
    y := 0;

    if (token.typeof <> T_EOL) and (token.typeof <> T_AMP) then
    begin
        evalExpr (expx, E_INTEGER);
        if token.typeof = T_VG then nextToken;
        evalExpr (expy, E_INTEGER);

        if (expx.typeof <> E_INTEGER) or (expy.typeof <> E_INTEGER) then
        begin
            errorMsg ('Esperava expressões numéricas para as coordenadas X e Y');
            freeExpr (expx);
            freeExpr (expy);
            exit
        end;

        x := expx.int;  freeExpr (expx);
        y := expx.int;  freeExpr (expy)
    end;

    colando := false;
    if token.id = 'COLA' then
    begin
        nextToken;
        colando := true
    end;

    ignore := false;
    if token.typeof = T_AMP then
    begin
        ignore := true;
        nextToken
    end;

    if colando then freeBMP else closeBMP;

    tmpPath := '';

    case it of
        BMP:      ;
        JPG:      begin
                      tmpPath := getTmpFilePath ('BMP');
                      CopyJpegToBmp (path, tmpPath);
                      path := tmpPath
                  end;
        PNG:      begin
                      tmpPath := getTmpFilePath ('PNG');
                      pngImage := TPNGObject.Create;
                      pngImage.LoadFromFile (path);
                      bmpImage := TBitmap.Create;
                      bmpImage.assign (pngImage);
                      bmpImage.saveToFile (tmpPath);
                      path := tmpPath
                  end
    end;

    if not openBMP (path) then
    begin
        if not ignore then
        begin
            errorMsg ('Imagem inválida ou não encontrada');
            exit
        end
    end
    else begin
        paintBMP (x, y)
    end;

    if path = tmpPath then
        DeleteFile (tmpPath);

    processaImagem := true
end;

{--------------------------------------------------------}
{                    Comando SENSOR
{--------------------------------------------------------}

procedure initKeys;
begin
    if hInpOut32 <> 0 then exit;

    hInpOut32 := LoadLibrary ('inpout32.dll');

    if hInpOut32 = 0 then
    begin
        beep;
        errorMsg ('Biblioteca "inpout32.dll" não disponível');
        exit
    end;

     inp32 := GetProcAddress (HInpOut32, 'Inp32');
     out32 := GetProcAddress (HInpOut32, 'Out32');

     out32 ($37A, $FF);
     sleep (1);
     out32 ($378, 1);
     sleep (1);
     mascChaves := inp32 ($379);
end;

procedure getKeys;
var
    x, i : integer;
begin
    if hInpOut32 = 0 then exit;

    for i := 0 to 7 do
    begin
        out32 ($37A, $FF);
        sleep (1);
        out32 ($378, not ($80 shr i));
        sleep (1);

        x := inp32 ($379) xor mascChaves;

        vetChaves[i*4+1] := (x and $80) <> 0;
        vetChaves[i*4+2] := (x and $40) <> 0;
        vetChaves[i*4+3] := (x and $20) <> 0;
        vetChaves[i*4+4] := (x and $10) <> 0;
    end
end;

function processaSensor : boolean;
var
    n, v    : integer;
    lvalue  : LvalueRec;
    exp     : Operand;
begin
    processaSensor := false;
    if not sensorAtivo then initKeys;

    getLvalue (lvalue);
    if lvalue.id = NIL then exit;

    getKeys;

    v := 0;

    for n := 1 to 32 do
    begin
        if vetChaves[n] then
        begin
            v := n;
            break
        end
    end;

    initExpr (exp, v);
    doAssignment (lvalue, exp);

    freeLvalue (lvalue);
    freeExpr (exp);

    processaSensor := true
end;

{--------------------------------------------------------}
{                    Comando MSAA
{--------------------------------------------------------}

function processaMSAA : boolean;
var
    expx,    expy,    expdx,    expdy    : Operand;
    lvaluex, lvaluey, lvaluedx, lvaluedy : LvalueRec;

    function assign (val : integer) : boolean; overload;
    var
        lvalue : LvalueRec;
        exp    : Operand;
    begin
        assign := false;

        nextToken;
        getLvalue (lvalue);     if lvalue.id = NIL then exit;

        initExpr (exp, val);
        doAssignment (lvalue, exp);

        freeLvalue (lvalue);
        freeExpr (exp);

        assign := true
    end;

    function assign (val : string) : boolean; overload;
    var
        lvalue : LvalueRec;
        exp    : Operand;
    begin
        assign := false;

        nextToken;
        getLvalue (lvalue);     if lvalue.id = NIL then exit;

        initExpr (exp, val);
        doAssignment (lvalue, exp);

        freeLvalue (lvalue);
        freeExpr (exp);

        assign := true
    end;

begin
    processaMSAA := false;

    if token.typeof <> T_ID then
    begin
        errorMsg ('Esperava um modificador');
        exit
    end;

    if token.id = 'MONITORA' then
    begin
        MSAAMonitora (true);
        nextToken
    end
    else if token.id = 'FIM' then
    begin
        MSAAMonitora (false);
        nextToken
    end
    else if token.id = 'CHECA' then
    begin
        if not assign (ord (MSAAPegaEvento)) then exit
    end
    else if token.id = 'CAPTURA' then
    begin
        nextToken;
        evalExpr (expx, E_INTEGER);
        evalExpr (expy, E_INTEGER);

        if (expx.typeof <> E_INTEGER) or (expy.typeof <> E_INTEGER) then
        begin
            freeExpr (expx);
            freeExpr (expy);
            exit
        end;

        MSAAPegaPonto (expx.int, expy.int)
    end
    else if token.id = 'AREA' then
    begin
        nextToken;
        getLvalue (lvaluex);    if lvaluex.id  = NIL then exit;
        getLvalue (lvaluey);    if lvaluey.id  = NIL then exit;
        getLvalue (lvaluedx);   if lvaluedx.id = NIL then exit;
        getLvalue (lvaluedy);   if lvaluedy.id = NIL then exit;

        initExpr (expx, E_INTEGER);
        initExpr (expy, E_INTEGER);
        initExpr (expdx, E_INTEGER);
        initExpr (expdy, E_INTEGER);

        MSAACoord (expx.int, expy.int, expdx.int, expdy.int);

        doAssignment (lvaluex,  expx);
        doAssignment (lvaluey,  expy);
        doAssignment (lvaluedx, expdx);
        doAssignment (lvaluedy, expdy);

        freeLvalue (lvaluex);    freeExpr (expx);
        freeLvalue (lvaluey);    freeExpr (expy);
        freeLvalue (lvaluedx);   freeExpr (expdx);
        freeLvalue (lvaluedy);   freeExpr (expdy)
    end
    else if token.id = 'NOME' then
    begin
        if not assign (MSAANome) then exit
    end
    else if token.id = 'CODIGO' then
    begin
        if not assign (MSAACodTipo) then exit
    end
    else if token.id = 'TIPO' then
    begin
        if not assign (MSAATipo) then exit
    end
    else if token.id = 'ESTADO' then
    begin
        if not assign (MSAAStatus) then exit
    end
    else
    if token.id = 'VALOR' then
    begin
        if not assign (MSAAValor) then exit
    end
    else begin
        errorMsg ('Modificador inválido: "' + token.id + '" para o comando MSAA');
        exit
    end;

    processaMSAA := true
end;

{--------------------------------------------------------}
{                  Comando EXECUTA
{--------------------------------------------------------}

function processaExecuta : boolean;
var
    cmd, arg, dir : string;
    wait          : boolean;
    i             : integer;
    exp           : Operand;
begin
    processaExecuta := false;

    evalExpr (exp);

    if (exp.typeof <> E_STRING) or (exp.pobj^.str = '') then
    begin
        errorMsg ('Esperava um comando');
        freeExpr (exp);
        exit
    end;

    wait := true;
    if token.typeof = T_AMP then
    begin
        wait := false;
        nextToken
    end;

    cmd := exp.pobj^.str;

    freeExpr (exp);

    if (cmd <> '') and (cmd[1] = '"') then
    begin
        delete (cmd, 1, 1);
        i := pos ('"', cmd);

        if i = 0 then
        begin
            arg := ''
        end
        else begin
            arg := copy (cmd, i+1, 999);
            arg := trim (arg);
            cmd := copy (cmd, 1, i-1)
        end
    end
    else begin
        i := pos (' ', cmd);

        if i = 0 then
        begin
            arg := ''
        end
        else begin
            arg := copy (cmd, i+1, 999);
            delete (cmd, i, 999)
        end
    end;

    getdir (0, dir);
    while sintFalando do;

    if executaProgEx (cmd, dir, arg, SW_SHOWMINIMIZED) >= 32 then
    begin
        if wait then
            esperaProgVoltar
    end
    else begin
        exit
    end;

    processaExecuta := true
end;

{--------------------------------------------------------}
{               comando CURSOR
{--------------------------------------------------------}

function processaCursor : boolean;
label
    out;
var
    x, y   : LvalueRec;
    wx, wy : Operand;
begin
    processaCursor := false;

    if token.id = 'CAPTURA' then
    begin
        nextToken;

        getLvalue (x);  initExpr (wx, whereX);

        if token.typeof = T_VG then nextToken;

        getLvalue (y);  initExpr (wy, whereY);

        doAssignment (x, wx);  freeLvalue (x);
        doAssignment (y, wy);  freeLvalue (y)
    end
    else begin
        evalExpr (wx, E_INTEGER);

        if token.typeof = T_VG then nextToken;

        evalExpr (wy, E_INTEGER);

        if (wx.typeof <> E_INTEGER) or (wy.typeof <> E_INTEGER)  then
        begin
            errorMsg ('Esperava valores inteiros para x e y');
            goto out
        end;

        gotoxy (wx.int, wy.int)
    end;

    processaCursor := true;

out:
    freeExpr (wx);
    freeExpr (wy)
end;

{--------------------------------------------------------}
{               comando BAIXA
{--------------------------------------------------------}

function processaBaixa : boolean;
label
    out;
const
    CRLF                    = CR + LF;
var
    lvalue                  : LvalueRec;
    exp, expURL, expPath    : Operand;
    ignore, quiet           : boolean;
    protocol, addr, res, ret,
    redir, typeof, encoding : string;
    port, fd, status        : integer;
    size                    : longint;
    buf                     : PBufRede;

    {----------------------------------------------------}
    {               decompõe a URL dada
    {----------------------------------------------------}

    function analyzeURL (url : string) : boolean;
    var
        i, error : integer;
    begin
        analyzeURL := false;

        i := pos ('://', url);

        if i = 0 then
        begin
            protocol := 'HTTP'
        end
        else begin
            protocol := maiuscAnsi (copy (url, 1, i - 1));
            delete (url, 1, i + 2)
        end;

        i := pos ('/', url);

        if i = 0 then
            i := pos ('?', url);

        if i = 0 then
        begin
            res  := '';
            addr := url;
        end
        else begin
            addr := copy (url, 1, i - 1);
            res  := copy (url, i, 999);

            if res[1] = '?' then
                res := '/' + res;
        end;

        i := pos (':', addr);

        if i <> 0 then
        begin
            addr := copy (addr, 1, i - 1);
            val (copy (addr, i + 1, 999), port, error);
            if error <> 0 then exit
        end
        else begin
            if protocol = 'HTTPS' then
                port := 443
            else
                port := 80
        end;

        if res = '' then
            res := '/';

        i := pos ('?', res);

        if i <> 0 then
            res := copy (res, 1, i) + copy (res, i + 1, 999);

        analyzeURL := true
    end;

    {----------------------------------------------------}
    {     tenta fazer acesso à URL, lendo o cabeçalho
    {----------------------------------------------------}

    function getHeader : boolean;
    var
        comandoHTTP, s : string;
    begin
        getHeader := false;

        repeat
            { writeln ('Conectando: endereco = ' + endereco + ', porta = ' +
                        intToStr (porta) + ', recurso = ' + recurso); }

            if protocol = 'HTTPS' then
                fd := abreConexaoSSL (addr, port)
            else
                fd := abreConexao (addr, port);

            if fd < 0 then
            begin
                if not ignore then
                    errorMsg ('Não foi possível estabelecer conexão');
                exit
            end;

            comandoHTTP := 'GET ' + EncodeURL (res) + ' HTTP/1.0' + CRLF +
                           'Connection: Close' + CRLF +
                           'Host: ' + addr + CRLF +
                           CRLF;

            buf := inicBufRede (fd);

            status := ord (writeRede (fd, comandoHTTP));

            redir := ''; ret := ''; typeof := '???'; encoding := '???'; size := -1;

            repeat
                status := ord (not readlnBufRede (buf, s, 30));

                if copy (s, 1, 4) = 'HTTP' then
                begin
                    ret := copy (s, pos (' ', s) + 1, 3)
                end
                else if maiuscAnsi (copy (s, 1, 13)) = 'CONTENT-TYPE:' then
                begin
                    typeof := trim (copy (s, 14, 999))
                end
                else if maiuscAnsi (copy (s, 1, 26)) = 'CONTENT-TRANSFER-ENCODING:' then
                begin
                    encoding := trim (copy (s, 28, 999))
                end
                else if maiuscAnsi (copy (s, 1, 15)) = 'CONTENT-LENGTH:' then
                begin
                    size := strToInt (trim (copy (s, 16, 999)))
                end
                else if maiuscAnsi (copy (s, 1, 9)) = 'LOCATION:' then
                begin
                    redir := trim (copy (s, 10, 999))
                end
            until (status <> 0) or (s = '');

            if (ret[1] <> '3') or (redir = '') then
                break;

            { Processa o redirecionamento }

            fechaConexao (fd);
            fimBufRede (buf);
            analyzeURL (redir)
        until false;

        getHeader := true
    end;

    {----------------------------------------------------}
    {     copia o conteúdo para o arquivo
    {----------------------------------------------------}

    function downloadContent (nomearq : string) : boolean;
    label
        out;
    const
        BUFSIZE     = 4096;
    var
        f           : file;
        fbuf        : array[0 .. BUFSIZE-1] of byte;
        p, nWritten : integer;
        c           : char;
        ok          : boolean;
        total       : longint;
    begin
{$I-}
        AssignFile (f, nomearq);
        Rewrite (f, 1);

        if IoResult <> 0 then
        begin
            if not ignore then
                errorMsg ('Erro na criação do arquivo ' + nomearq);
            ok := false;
            goto out
        end;
{$I+}
        p := 0; total := 0;

        ok := leCaracBufRede (buf, c);
        while ok do
        begin
            fbuf[p] := ord (c);  INC (p);

            if p >= BUFSIZE then
            begin
                nWritten := 0;
                blockWrite (f, fbuf, p, nWritten);

                if nWritten <> p then
                begin
                    if not ignore then
                        errorMsg ('Erro de escrita no arquivo');
                    ok := false;
                    goto out
                end;

                INC (total, p); p := 0
            end;

            ok := leCaracBufRede (buf, c)
        end;

        ok := true;

        if p > 0 then
        begin
            nWritten := 0;
            blockWrite (f, fbuf, p, nWritten);

            if nWritten <> p then
            begin
                if not ignore then
                    errorMsg ('Erro de escrita no arquivo');
                ok := false;
                goto out
            end;

            INC (total, p)
        end;

        if size >= 0 then
        begin
            if not ignore and (total <> size) then
                errorMsg ('Tamanho previsto = ' + intToStr (size) + '; tamanho baixado = ' + intToStr (total));

            ok := total = size
        end;
    out:
        {$I-} CloseFile (f); {$I+}

        if not ok then
            DeleteFile (nomearq);

        downloadContent := ok;
        setIOStatus (CS, ord (not ok));

        fechaConexao (fd);
        fimBufRede (buf)
    end;

begin
    processaBaixa := false;

    quiet := false;
    if tokenIsID ('MUDO') then
    begin
        quiet := true;
        nextToken
    end;

    evalExpr (expURL);
    evalExpr (expPath);
    invalidateLvalue  (lvalue);

    if (expURL.typeof <> E_STRING) or (expPath.typeof <> E_STRING) then
    begin
        errorMsg ('Esperava duas cadeias: a URL e o arquivo');
        goto out
    end;

    if not (token.typeof in [T_EOL, T_AMP]) then
    begin
        getLvalue (lvalue);
        if lvalue.id = NIL then goto out;
    end;

    ignore := false;
    if token.typeof = T_AMP then
    begin
        ignore := true;
        nextToken
    end;

    if not internetPronta then
    begin
        abreWinSock;
        internetPronta := true
    end;

    if not analyzeURL (expURL.pobj^.str) then goto out;
    if not getHeader then goto out;

    if not quiet and (size > 0) then
        scWriteln ('Baixando ' + intToStr (size) + ' bytes, conteúdo = ' + typeof);

    if not downloadContent (expPath.pobj^.str) then goto out;

    if not quiet then
        scWriteln ('Conteúdo baixado e guardado em ' + expPath.pobj^.str);

    if lvalue.id <> NIL then
    begin
        initExpr (exp, typeof);         { Se foi dada a variável, guarda o tipo }
        doAssignment (lvalue, exp);
        freeExpr (exp)
    end;

    processaBaixa := true;

out:
    freeLvalue (lvalue);
    freeExpr (expURL);
    freeExpr (expPath)
end;

{--------------------------------------------------------}
{               comando SPRITE
{--------------------------------------------------------}

function processaSprite : boolean;
var
    modifier    : string;
    expPath     : Operand;
    path        : string;
    typeofImage : ImageType;
    expx, expy  : Operand;
    x, y        : integer;
    pngImage    : TPNGObject;
    jpgImage    : TJPEGImage;
    bmpImage    : TBitmap;
begin
    processaSprite := false;

    if token.typeof <> T_ID then
    begin
        errorMsg ('Esperava modificador');
        exit
    end;

    modifier := token.id;

    if modifier = 'LIMPA' then
    begin
        nextToken;
        if BMPGlobal <> NIL then
        begin
            BMPGlobal.Free;
            BMPGlobal := NIL
        end;
        processaSprite := true;
        exit
    end;

    nextToken;
    evalExpr (expPath);

    if (expPath.typeof <> E_STRING) or (expPath.pobj^.str = '') then
    begin
        errorMsg ('Esperava o nome do arquivo contendo a imagem');
        freeExpr (expPath);
        exit
    end;

    path := expPath.pobj^.str;
    freeExpr (expPath);

    typeofImage := getImageType (path);
    if typeofImage = NONE then
    begin
        errorMsg ('Extensão de arquivo não reconhecida');
        exit
    end;

    if modifier = 'CRIA' then
    begin
        if not FileExists (path) then
        begin
            errorMsg ('Arquivo inexistente');
            exit
        end;

        if BMPGlobal <> NIL then BMPGlobal.Free;
        BMPGlobal := TBitmap.Create;

        try
            case typeofImage of
                BMP:  BMPGlobal.LoadFromFile (path);
                JPG:  begin
                          jpgImage := TJPEGImage.Create;
                          jpgImage.LoadFromFile (path);
                          BMPGlobal.Assign (jpgImage);
                          jpgImage.Free
                      end;
                PNG:  begin
                          pngImage := TPNGObject.Create;
                          pngImage.LoadFromFile (path);
                          BMPGlobal.Assign (pngImage);
                          pngImage.Free;
                      end
            end
        except
            errorMsg ('Erro ao processar a imagem')
        end
    end
    else if modifier = 'COLA' then
    begin
        if not Assigned (BMPGlobal) then
        begin
            errorMsg ('O comando SPRITE CRIA deveria ter sido usado antes');
            exit
        end;

        if not FileExists (path) then
        begin
            errorMsg ('Arquivo inexistente');
            exit
        end;

        x := 0;
        y := 0;

        if token.typeof <> T_EOL then
        begin
            evalExpr (expx, E_INTEGER);
            if token.typeof = T_VG then nextToken;
            evalExpr (expy, E_INTEGER);

            if (expx.typeof <> E_INTEGER) or (expy.typeof <> E_INTEGER) then
            begin
                errorMsg ('Esperava expressões numéricas para as coordenadas X e Y');
                freeExpr (expx);
                freeExpr (expy);
                exit
            end;

            x := expx.int;  freeExpr (expx);
            y := expy.int;  freeExpr (expy)
        end;

        try
            case typeofImage of
                BMP:  begin
                          bmpImage := TBitMap.Create;
                          bmpImage.LoadFromFile (path);
                          BMPGlobal.Canvas.Draw (x, y, bmpImage);
                          bmpImage.free
                      end;
                JPG:  begin
                          jpgImage := TJPEGImage.Create;
                          jpgImage.LoadFromFile (path);
                          BMPGlobal.Canvas.Draw (x, y, jpgImage);
                          jpgImage.Free
                      end;
                PNG:  begin
                          pngImage := TPNGObject.Create;
                          pngImage.LoadFromFile (path);
                          BMPGlobal.Canvas.Draw (x, y, pngImage);
                          pngImage.Free
                      end
            end
        except
            errorMsg ('Erro ao processar a imagem')
        end
    end
    else if modifier = 'GRAVA' then
    begin
        try
            case typeofImage of
                BMP:  BMPGlobal.SaveToFile (path);
                JPG:  begin
                          jpgImage := TJPEGImage.Create;
                          jpgImage.Assign (BMPGlobal);
                          jpgImage.SaveToFile (path);
                          jpgImage.Free
                      end;
                PNG:  begin
                          pngImage := TPNGObject.Create;
                          pngImage.Assign (BMPGlobal);
                          pngImage.SaveToFile (path);
                          pngImage.Free
                      end
            end
        except
            errorMsg ('Erro ao gravar a imagem')
        end
    end;

    processaSprite := true
end;

end.

