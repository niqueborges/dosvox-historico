{--------------------------------------------------------}
{           envia uma informacao para a rede
{--------------------------------------------------------}

unit pprede;
interface
uses dvwin, dvcrt, winsock, dvinet, mmsystem,
     winprocs, wintypes, dvgrav, sysUtils,
     ppvars, ppmsg;

function enviaRede (tipoInfo: byte; buffer: pchar; tam: word): boolean;
function descobreIP: string;
procedure informaIp;

implementation

{--------------------------------------------------------}
{               envia um buffer para a rede
{--------------------------------------------------------}

function enviaRede (tipoInfo: byte; buffer: pchar; tam: word): boolean;
var
    posic, enviados, porTransm: word;
    p: pointer;
    bufinho: array [0..2] of byte;
begin
    bufinho [0] := tipoInfo;
    bufinho [1] := tam and $ff;
    bufinho [2] := (tam shr 8) and $ff;

    enviados := send (sock, bufinho, 3, 0);
    if enviados < 3 then
        begin
            enviaRede := false;
            exit;
        end;

    porTransm := tam;
    posic := 0;
    while porTransm > 0 do
         begin
             p := @buffer[posic];
             enviados := send (sock, p^, porTransm, 0);

             if enviados < 1 then
                 begin
                     enviaRede := false;
                     exit;
                 end;
             porTransm := porTransm - enviados;
             posic := posic + enviados;
         end;

    enviaRede := true;
end;

{--------------------------------------------------------}
{               descobre o ip desta conexao
{--------------------------------------------------------}

function descobreIP: string;
var
    localAddr: sockaddr_in;
    tam: integer;
begin
    fillchar (localAddr, sizeof (localAddr), 0);
    tam := sizeof (localAddr);
    getSockName (sock, localAddr, tam);
    result := strpas (inet_ntoa (in_addr(localAddr.sin_addr.s_addr)));
end;

{--------------------------------------------------------}
{               informa o ip desta conexao
{--------------------------------------------------------}

procedure informaIp;
var s: string;
begin
    s := descobreIp;
    mensagem ('PPNUMIP', 1);   {Número IP desta conexão}
    sintWriteln (s);
end;

end.
