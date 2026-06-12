{-------------------------------------------------------------}
{                papovox - mensagem urgente
{-------------------------------------------------------------}

unit ppurgent;

interface
uses dvwin, dvcrt, winsock, dvinet,
     ppvars, ppmsg, ppSNomes;

procedure inicMsgUrgente;
procedure finalMsgUrgente;
function temMsgUrgente: boolean;
procedure recebeMsgUrgente;
procedure enviaMsgUrgente;

implementation

var
    sockEscutaUrgente: integer;    { socket para listem de comunicacoes urgentes }
    sockUrgente: integer;          { soquete para comunicacoes urgentes }
    meuBufUrgente: pBufRede;       { buffer do soquete sock }

{--------------------------------------------------------}
{
{--------------------------------------------------------}

procedure inicMsgUrgente;
begin
    sockEscutaUrgente := escutaConexao (PORTA_URGENTE);
    ultMsgUrgente := '';
end;

{--------------------------------------------------------}
{
{--------------------------------------------------------}

procedure finalMsgUrgente;
begin
    closeSocket (sockEscutaUrgente);
end;

{--------------------------------------------------------}
{
{--------------------------------------------------------}

function temMsgUrgente: boolean;
begin
    temMsgUrgente := chegouRede (sockEscutaUrgente);
end;

{--------------------------------------------------------}
{                recebe uma mensagem urgente
{--------------------------------------------------------}

procedure recebeMsgUrgente;
var
    nome, msg, selUrgente: string;
    i, j: integer;
label sai;
begin
    for j := 1 to 3 do
        for i := 40 to 45 do
            bipSpeaker (i);

    msg := '';
    sockUrgente := aceitaConexao (sockEscutaUrgente);
    meuBufUrgente := inicBufRede (sockUrgente);

    if not readlnBufRede (meuBufUrgente, nome, 15)        then goto sai;
    selUrgente:= selecionado;
    if not readlnBufRede (meuBufUrgente, selUrgente, 15) then goto sai;
    if not readlnBufRede (meuBufUrgente, msg, 15)         then goto sai;

    writelnRede (sockUrgente, '+OK');

    textColor (YELLOW);
    mensagem ('PPMSGURG', 0);
    sintWriteln (nome);

    sintWriteln (msg);
    ultMsgUrgente := msg;
    textColor (LIGHTGRAY);

sai:
    closeSocket (sockUrgente);
    fimBufRede (meuBufUrgente);
    sintBip; sintBip;
end;

{--------------------------------------------------------}
{             envia uma mensagem urgente
{--------------------------------------------------------}

procedure enviaMsgUrgente;
var
    endip: string;
    msg: string;
    c, c2: char;
    s: array [0..5] of char;
    i: integer;

label chegou, pegouEnder, erro;

begin
    if selecionado <> '' then
        begin
            mensagem ('PPPOSSO', 0);   {Posso conectar '}
            sintWrite (selecionado);
            write (' ? ');
            sintLeTecla (c, c2);
            writeln;
            if upcase(c) <> 'N' then
                begin
                    endIp := selecionado;
                    goto pegouEnder;
                end;
        end;

    mensagem ('PPQUALIP', 1);  {Qual o endereço a conectar}
    sintReadln (endip);
    if endip = '' then exit;

pegouEnder:
    selecionado := endip;

    writeln;
    textColor (RED);
    mensagem ('PPINFMSG', 1);     {Informe a mensagem a enviar}
    textColor (LIGHTGRAY);

    sintReadln (msg);
    if msg = '' then exit;

    if pos ('@', endip) <> 0 then
        begin
            descobreIp (endip, endip);
            if endip = '' then exit;
        end;

    mensagem ('PPESPLIG', 1);  {'Tentando estabelecer ligação'}

    finalMsgUrgente;
    sockUrgente := abreConexao (endip, PORTA_URGENTE);
    if sockUrgente < 0 then goto erro;

    if not writelnRede (sockUrgente, nomeUsuario)  then goto erro;
    if not writelnRede (sockUrgente, enderUsuario) then goto erro;
    if not writelnRede (sockUrgente, msg)          then goto erro;

    for i := 1 to 100 do
       begin
           if chegouRede (sockUrgente) then goto chegou;
           delay (100);
       end;
   goto erro;

chegou:
    recv (sockUrgente, s, 5, 0);
    fechaConexao (sockUrgente);
    inicMsgUrgente;

    textColor (RED);
    mensagem ('PPMSGENV', 1);     {Mensagem foi enviada}
    textColor (LIGHTGRAY);
    exit;

erro:
    if sockUrgente >= 0 then
        closeSocket (sockUrgente);
    inicMsgUrgente;
    mensagem ('PPERCON', 1);  {Não consegui realizar a conexão}
    exit;
end;

end.
