{-------------------------------------------------------------}
{
{           CartaVox - Interface para Secure Sockets Layer
{
{-------------------------------------------------------------}

unit carssl;

interface

uses
    dvcrt,
    dvWin,
    sysutils,
    windows,
    winSock,
    syssllib,
    carMsg,
    carVars;

function inicializa_ctx_SSL: boolean;
function conectaSSL (sock: integer): boolean;
procedure fechaSSL;
function recebeSSL (buf: PChar; len: integer): integer;
function enviaSSL (buf: PChar; len: integer): integer;
function temDadoSsl: boolean;

const
    portaSSLPOP3 = 995;
    portaSSLSMTP = 465;

var
    meth: PSSL_METHOD;                          { método SSL V23 }
    SSLctx: PSSL_CTX;                           { contexto SSL }
    ssl: PSSL;                                  { soquete SSL }

implementation

var
    SSLActive: boolean;                         { bibliotecas SSL já ativadas }


function inicializa_ctx_SSL: boolean;
begin
    inicializa_ctx_SSL := true;   // versão preliminar: sempre ok

    if not SSLActive then
        begin
            SSLLibraryInit;
            SSLLoadErrorStrings;
            meth := SslMethodV23;
            SSLActive := true;
        end;

    SSLctx := SslCtxNew(meth);
end;


function conectaSSL (sock: integer): boolean;
begin
    ssl := SSLnew(SSLctx);
    SslSetFd(ssl, sock);

    conectaSSL := SSLconnect(ssl) > 0;
end;


procedure fechaSSL;
begin
    SSLshutdown(ssl);
    SSLfree(ssl);
    SSLCtxFree(SSLctx);
end;


function recebeSSL (buf: PChar; len: integer): integer;
var
    readBlocked: boolean;
    r, e: integer;

begin
    repeat
        readBlocked := false;
        r := SSLread (ssl, buf, len);

        e := SSLgetError (ssl, r);
        case e of

            SSL_ERROR_NONE:
                begin
                    buf[r] := #$0;
                    break;
                end;

            SSL_ERROR_SYSCALL,      (* Retornado pelo gmail *)
            SSL_ERROR_ZERO_RETURN:  (* End of data *)
                begin
                    r := -1;
                    break;
                end;

            SSL_ERROR_WANT_READ:    readBlocked := true;
            SSL_ERROR_WANT_WRITE:   ;

        else
            r := -1;
            break;
        end;

        delay (100);

    until not readBlocked;

    recebeSSL := r;
end;

function enviaSSL (buf: PChar; len: integer): integer;
var
    writeBlocked: boolean;
    r, e: integer;

begin
    repeat
        writeBlocked := false;

        r := SslWrite(ssl, buf, len);
        e := SSLgetError (ssl, r);
        case e of

            SSL_ERROR_NONE:
                    break;

            SSL_ERROR_SYSCALL,      (* Retornado pelo gmail *)
            SSL_ERROR_ZERO_RETURN:  (* End of data *)
                begin
                    r := -1;
                    break;
                end;

            SSL_ERROR_WANT_READ:    ;
            SSL_ERROR_WANT_WRITE:   writeBlocked := true;

        else
            r := -1;
            break;
        end;

        delay (100);

    until not writeBlocked;

    enviaSSL := r;
end;

function temDadoSsl: boolean;
begin
    temDadoSSL := SSLPending (ssl) <> 0;
end;

end.
