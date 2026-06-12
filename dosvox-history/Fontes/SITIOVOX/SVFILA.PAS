{--------------------------------------------------------}
{      sitiovox - tratamento da fila de mensagens
{--------------------------------------------------------}

unit svFila;
interface
uses dvCrt, dvWin, winprocs, wintypes,
     svvars, svMsg;

function temMsgFila: boolean;
procedure insereFilaMsg (env, dest, msg: string);
procedure removeFilaMsg (var env, dest, msg: string);

implementation

{--------------------------------------------------------}
{              ve se tem mensagem na fila
{--------------------------------------------------------}

function temMsgFila: boolean;
begin
    temMsgFila := ffila <> rfila;
end;

{--------------------------------------------------------}
{              insere uma mensagem na fila
{--------------------------------------------------------}

procedure insereFilaMsg (env, dest, msg: string);
begin
    if (rfila + 1) mod MAXMSG = ffila then
        mensagem ('SVOVFLOW', 1);    {Estouro na fila de mensagens}
        { deixa fila se ferrar }

    with filaEnviar [rfila]^ do
        begin
            enviador := env;
            destino := dest;
            mensagem := msg;
        end;

    rfila := (rfila + 1) mod MAXMSG;

    if fazLog and (dest = '*') then
        begin
            {$I-}   writeln (arqlog, env,'>',dest,':', msg);   {$I+}
            if ioresult <> 0 then
                fazLog := false;
        end;
end;

{--------------------------------------------------------}
{              remove uma mensagem na fila
{--------------------------------------------------------}

procedure removeFilaMsg (var env, dest, msg: string);
begin
    with filaEnviar [ffila]^ do
        begin
            env := enviador;
            dest := destino;
            msg := mensagem;
        end;

    ffila := (ffila + 1) mod MAXMSG;
end;

end.