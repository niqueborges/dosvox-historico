{-------------------------------------------------------------}
{
{    Programa de Transferência Remota de Arquivos
{
{    Rotinas de acesso à rede
{
{    Autor: Jose' Antonio Borges
{
{    Em 21/04/98
{
{-------------------------------------------------------------}

unit ftpRede;
interface

uses dvCrt, dvWin, sysUtils, winsock, winprocs,
     ftpVars, ftpMsg;

function abreConexao: boolean;
procedure fechaConexao;
procedure processaRede;
function abreConexaoArq: boolean;
procedure fechaConexaoArq;
procedure aceitaCanalArq;
procedure recebeCanalArq;
procedure enviaCanalArq;
function processaTransf (var ev: integer): boolean;
function checaEventoRede: integer;
procedure mostraTransmitidos;


implementation

{-------------------------------------------------------------}
{                     abre o socket de dialogo
{-------------------------------------------------------------}

function abreConexao: boolean;
var
    localAddr,                           { descricao dos endereços }
    remoteAddr: sockaddr_in;
    hip: phostent;		         { retorna o endereco IP do soquete }
    wsaData: TWSAData;
    s, s1: string;
    nomeLocal: array [0..80] of char;
    tamLocal: integer;
    portaLoc: word;

begin
    abreConexao := false;

    writeln;
    mensagem ('FTCONEC', 1);  {'Conectando '}

    {************ Inicializa biblioteca WinSock ***********}

    if WSAStartup ($0101, wsaData) <> 0 then
        begin
            mensagem ('FTERRBIB', 1);  {'Não consegui conexão com a rotina de comunicações'}
            exit;
        end
    else
        with wsadata do
            begin
                writebuf (szDescription, strlen (szDescription));      writeln;
                writebuf (szsystemStatus, strlen (szsystemstatus));    writeln;
            end;

    {************ Cria soquete ***********}

    sock := socket (AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (sock = -1) then
        begin
            mensagem ('FTERRSOQ', 1);  {'Não consegui criar soquete'}
            exit;
        end;

    {************ Aloca uma porta para o processamento ***********}

    fillchar (localAddr, sizeof (localAddr), 0);
    with localAddr do
        begin
            sin_family := AF_INET ;
            sin_addr.s_addr := htonl (INADDR_ANY);
            sin_port := htons (0);
        end;

    if bind (sock, localAddr, sizeof(localAddr)) = -1 then
        begin
            mensagem ('FTERBIND', 1);  {'Não consegui alocar porta (bind)'}
            exit;
        end;

    {************ Descobre endereco IP do computador ***********}

//    nomeHost := nomeHost + #$0;
    if (nomeHost[1] >= '0') and (nomeHost[1] <= '9')  then
        enderHost := inet_addr (@nomeHost[1])
    else
        begin
            hip := gethostbyname (@nomeHost[1]);
            if (hip = NIL)  then
                begin
                    while keypressed do readkey;
    	            mensagem ('FTERCOMP', 1);  {'Não consegui achar este computador pelo nome'}
                    exit;
                end
            else
                move (hip^.h_addr_list^^, enderHost, 4);
        end;

    {************ Conecta computador ***********}

    fillchar (remoteAddr, sizeof (remoteAddr), 0);
    with remoteAddr do
        begin
            sin_family := AF_INET;
            move (enderHost, sin_addr, 4);
            sin_port := htons (porta);
        end;

    if (connect (sock, remoteAddr, sizeof (remoteAddr)) = -1) then
        begin
            while keypressed do readkey;
            writeln;
            textColor (RED);
            mensagem ('FTNAOCON', 1);  {'Não consegui realizar a conexao'}
            textColor (WHITE);
            exit;
        end;

    with remoteAddr.sin_addr do
        begin
            msgWrite ('FTENDRED', 0); {'Endereço de rede: '}
            s := '';
            writeln (inet_ntoa (in_addr(S_addr)));
        end;

    {************ informações locais ***********}

    getsockname (sock, localAddr, tamLocal);
    portaLoc := htons (localAddr.sin_port);
    msgWrite ('FTPOLOC', 0);  {'Porta local: '}
    writeln (portaLoc);

    gethostname (nomeLocal, 80);
    msgWrite ('FTNOMELO', 0); {'Nome local: '}
    write (strPas (nomeLocal));
    hip := gethostbyname (nomeLocal);
    move (hip^.h_addr_list^^, enderLocal, 4);

    s := '';
    str (enderLocal and $ff, s1);            s := s + s1 + '.';
    str ((enderLocal shr 8) and $ff, s1);    s := s + s1 + '.';
    str ((enderLocal shr 16) and $ff, s1);   s := s + s1 + '.';
    str ((enderLocal shr 24)and $ff, s1);    s := s + s1;
    writeln (' (' , s, ')');

    abreConexao := true;
    writeln;
end;

{-------------------------------------------------------------}
{		     fecha o soquete
{-------------------------------------------------------------}

procedure fechaConexao;
begin
    fechaConexaoArq;
    closeSocket (sock);
    wsaCleanup;
end;

{-------------------------------------------------------------}
{                 processa dado vindo da rede
{-------------------------------------------------------------}

procedure processaRede;
var
    i, lidos: integer;

begin
    keypressed;
    lidos := recv (sock, buf, BUFSIZE, 0);
    if (lidos <= 0) then
        begin
            writeln;
	    processando := false;
            exit;
        end
    else
        begin
            for i := 0 to lidos-1 do
                 begin
                     if (buf[i] = #$0d) then
                         begin
                             new (bufLinhas [pins]);
                             bufLinhas [pins]^ := linhaParcial;
                             pins := (pins + 1) mod MAXLINHAS;
                             linhaParcial := '';
                         end
                     else
                         if buf[i] <> #$0a then
                             linhaParcial := linhaParcial + buf[i];
    		  end;
        end;
end;

{-------------------------------------------------------------}
{       abre o socket de controle da conexao de arquivo
{-------------------------------------------------------------}

function abreConexaoArq: boolean;
var
    localAddr,                           { descricao dos endereços }
    remoteAddr: sockaddr_in;

begin
    abreConexaoArq := false;

    {************ Cria soquete ***********}

    sockArq := socket (AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (sockArq = -1) then
        begin
            mensagem ('FTERRSOQ', 1);  {'Não consegui criar soquete'}
            exit;
        end;

    sockCanal := -1;

    {************ Aloca uma porta para o processamento ***********}

    fillchar (localAddr, sizeof (localAddr), 0);
    with localAddr do
        begin
            sin_family := AF_INET ;
            if modoPassivo then
                begin
                    sin_addr.s_addr := htonl (INADDR_ANY);
                    sin_port := htons (0);
                end
            else
                begin
                    sin_addr.s_addr := enderLocal;
                    sin_port := htons (portaLocal);
                end;
        end;

    if bind (sockArq, localAddr, sizeof(localAddr)) = -1 then
        begin
            mensagem ('FTERBNDD', 1);  {'Não consegui alocar porta para dados (bind)'}
            exit;
        end;

    {************ se não passiva, aceita conexoes ***********}

    if not modoPassivo then
        begin
            if listen (sockArq, 1) = -1 then
                begin
                    mensagem ('FTERLSTN', 1);  {'Não consegui executar listen'}
                    exit;
                end;
                escutando := true;
            end
    else
        begin
            sockCanal := sockArq;
            sockArq := -1;

            fillchar (remoteAddr, sizeof (remoteAddr), 0);
            with remoteAddr do
                begin
                    sin_family := AF_INET;
                    move (enderHost, sin_addr, 4);
                    sin_port := htons (portaPassiva);
                end;

            if (connect (sockCanal, remoteAddr, sizeof (remoteAddr)) = -1) then
                begin
                    while keypressed do readkey;
                    writeln;
                    textColor (RED);
                    mensagem ('FTNAOCON', 1);  {'Não consegui realizar a conexao'}
                    textColor (WHITE);
                    exit;
                end
            else
                canalAberto := true;
        end;

    abreConexaoArq := true;
end;

{-------------------------------------------------------------}
{             fecha conexao para envio de arquivos
{-------------------------------------------------------------}

procedure fechaConexaoArq;
begin
    if sockArq   <> -1 then  closeSocket (sockArq);
    sockArq := -1;
    if sockCanal <> -1 then  closeSocket (sockCanal);
    sockCanal := -1;
    canalAberto := false;
end;

{-------------------------------------------------------------}
{                 accept para transferência de arquivo
{-------------------------------------------------------------}

procedure aceitaCanalArq;
var
    tamStruc: integer;
    remDataAddr: sockaddr_in;
begin
    canalAberto := true;

    tamStruc := sizeof (sockaddr_in);
    sockCanal := accept (sockArq, @remDataAddr, @tamStruc);
    if sockCanal = -1 then
        begin
            canalAberto := false;
            mensagem ('FTACECON', 0);  {'Não consegui aceitar conexao: erro '}
            sintWriteInt (WSAGetLastError);
            writeln;
            exit;
        end;
end;

{-------------------------------------------------------------}
{                     recebe dado vindo da rede
{-------------------------------------------------------------}

procedure recebeCanalArq;
var
    bufArq: array [0..BUFSIZE-1] of char;
    i, lidos: integer;
begin
    lidos := recv (sockCanal, bufArq, BUFSIZE, 0);
    totalTransmitido := totalTransmitido + lidos;

    if (lidos > 0) then
        begin
            blockwrite (arqLocal, bufArq, lidos);
            if debug then
                 for i := 0 to lidos-1 do
                      write (bufArq[i]);
        end
    else
        begin
            close (arqLocal);
            canalAberto := false;
            escutando := false;
            fechaConexaoArq;
        end;
end;

{-------------------------------------------------------------}
{                     envia canal arq
{-------------------------------------------------------------}

procedure enviaCanalArq;
var bufarq: array [0..BUFSIZE-1] of char;
    lidosArq, aEnviar, total, escritos: integer;
    p: pointer;
label fim;
begin
    blockRead (arqLocal, bufArq, BUFSIZE, lidosArq);
    if lidosArq = 0 then
        goto fim;

    total := 0;
    repeat
        aEnviar := lidosArq - total;
        if aEnviar > BUFSIZE then aEnviar := bufSize;
        p := @bufarq[total];
        escritos := send (sockCanal, p^, aEnviar, 0);
        totalTransmitido := totalTransmitido + escritos;

        total := total + escritos;
        if escritos = 0 then
            begin
                 textColor (RED);
                 mensagem ('FTCOMCAI', 1);  {'Comunicacao Caiu'}
                 textColor (WHITE);
                 goto fim;
            end;
    until total = lidosArq;
    exit;

fim:
    close (arqLocal);
    canalAberto := false;
    escutando := false;
    fechaConexaoArq;
end;

{-------------------------------------------------------------}
{          mostra quantos caracteres foram transmitidos
{-------------------------------------------------------------}

procedure mostraTransmitidos;
var s: string;
begin
    if sintFalarTudo then
        mensagem ('FTTRANS', 0);  {'Transmitidos '}
    str ((totalTransmitido+1023) div 1024, s);
    sintWriteln (s + ' K ' + nomeArqHost);
end;

{-------------------------------------------------------------}
{                       espera canal fechar
{-------------------------------------------------------------}

function processaTransf (var ev: integer): boolean;
begin
    processaTransf := true;

    ev := checaEventoRede;
    if ev = -1 then exit;

    if ev = CHEGOU_PEDCONEXAO then
        begin
            aceitaCanalArq;
            processaTransf := canalAberto;
        end
    else
    if ev = CHEGOU_CANALARQ then
        begin
            recebeCanalArq;
            processaTransf := canalAberto;
        end
    else
    if ev = CHEGOU_REDE then
        processaRede;
end;

{-------------------------------------------------------------}
{                     espera chegar um evento
{-------------------------------------------------------------}

function checaEventoRede: integer;
var
    entradas: TFDset;
    tempoZero: timeVal;
    qualEvento: integer;

const
    tabEvento: array [-1..3] of string [10] = (
        '', '', 'REDE', 'PEDCONEXAO', 'CANALARQ');

begin
    qualEvento := -1;

    FD_ZERO (entradas);	 { monitora soquetes }

    FD_SET (sock, entradas);
    if escutando then
        FD_SET (sockArq, entradas);
    if canalAberto then
        FD_SET (sockCanal, entradas);

    with tempoZero do
        begin  tv_sec := 0;  tv_usec := 0;  end;

    select (0, @entradas, NIL, NIL, @tempoZero);

    if escutando and FD_ISSET (sockArq, entradas)    then   qualEvento := CHEGOU_PEDCONEXAO
    else
    if FD_ISSET (sock, entradas)       then   qualEvento := CHEGOU_REDE
    else
    if canalAberto and FD_ISSET (sockCanal, entradas)  then   qualEvento := CHEGOU_CANALARQ
    else
        ;

    checaEventoRede := qualEvento;

    if debug and (qualevento <> -1) then
        writeln ('----------------------------------------> evento ', tabevento [qualEvento]);
end;

end.
