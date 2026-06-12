{--------------------------------------------------------}
{           envia uma informacao para a rede
{--------------------------------------------------------}

unit svrede;
interface
uses dvwin, dvcrt, winsock, dvinet,
     windows, sysutils,
     svvars, svmsg;

function enviaRede (sock: integer; tipoInfo: byte; buffer: pchar; tam: word): boolean;
function leLinhaRede (sock: integer; var s: string): boolean;

implementation

{$R-}
function enviaRede (sock: integer; tipoInfo: byte; buffer: pchar; tam: word): boolean;
var
    posic, enviados, porTransm: word;
    bufinho: array [0..2] of byte;
    p: pointer;
begin
    if sock <= 0 then exit;

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
{               processa dados da rede
{--------------------------------------------------------}

function leLinhaRede (sock: integer; var s: string): boolean;
var bufinho: array [0..2] of byte;
    bufao:   array [0..512] of char;
    i, lidos, aler, lidosAgora: integer;
    p: pointer;
label chegou;
begin
    { assume que só é chamado se chegouRede, senão poderia bloquear }

    leLinhaRede := false;

    lidosAgora := recv (sock, bufinho, 3, 0);

    if lidosAgora < 1 then
        exit;

    aler := bufinho [1] or (bufinho [2] shl 8);

    if (bufinho[0] >= INICIOARQENVIA) or (aler > 512) then
        exit;

    lidos := 0;
    while aler > 0 do
        begin
            for i := 1 to 100 do    { mensagem toda tem que chegar em 10 segundos }
                begin
                    if chegouRede (sock) then goto chegou;
                    delay (100);
                end;
            exit;
chegou:
            p := @bufao[lidos];
            if aler > 512 then
                lidosAgora := recv (sock, p^, 512, 0)
            else
                lidosAgora := recv (sock, p^, aLer, 0);
            if lidosAgora <= 0 then
                exit;

            lidos := lidos + lidosAgora;
            aler := aler - lidosAgora;
        end;
    bufao [lidos] := #$0;

    leLinhaRede := true;
    if bufinho[0] = DADOTECLADO then
        s := strPas (bufao)
    else
    if bufinho[0] in [INICIOSOM, INICIOARQENVIA] then
        s := '?INVALIDA'
    else
        s := '';
end;

end.