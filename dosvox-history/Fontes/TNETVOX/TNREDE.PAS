{-------------------------------------------------------------}
{
{    Telnet Falado
{
{    Rotinas de conexão e negociação
{
{    Autor: Jose' Antonio Borges
{
{    Em 24/04/98
{
{-------------------------------------------------------------}

unit tnrede;

interface

uses windows, dvcrt, sysutils, dvWin, winsock, tnVars, tnMsg, dvcomm;

function abreConexao: boolean;
procedure fechaConexao;

procedure preNegociaOpcoes;

function portaSerial (nomeComput: string): boolean;
function abreConexaoSerial (nomeComput: string): boolean;

procedure lelink (var c: char);
procedure esclink (c: char);
procedure escLetras (s: string);
procedure escBuf (c: char);
function chegouLink: boolean;
procedure breakLink;

procedure flushBuf;

const
    TAMBUF = 20000;
    TAMBUFTRANS = 1024;
var
    bufLink: array [0..TAMBUF-1] of char;
    pins, pret: integer;
    bufTrans: array [0..TAMBUFTRANS-1] of char;
    ptrans: integer;

implementation

var
    emPortaSerial: boolean;

{-------------------------------------------------------------}
{        Ve se é e prepara parametros para porta serial
{-------------------------------------------------------------}

function portaSerial (nomeComput: string): boolean;
begin
    nomeComput := trim (nomeComput);     // busca COMx:veloc,parid,nbits,nstops
    emPortaSerial := false;
    result := emPortaSerial;
    if nomeComput = '' then exit;
    if (maiuscAnsi (copy (nomeComput, 1, 3)) <> 'COM') then exit;
    if pos (':', nomeComput) = 0 then exit;
    if pos (',', nomeComput) = 0 then exit;
    if not (nomeComput[4] in ['1'..'9']) then exit;

    emPortaSerial := true;
    result := emPortaSerial;
end;

{-------------------------------------------------------------}
{                     abre conexão serial
{-------------------------------------------------------------}

function abreConexaoSerial (nomeComput: string): boolean;
var dcb: TDCB;
    nome: array [0..200] of char;
    porta, veloc, parid, nbits, nstops: integer;

begin
    result := false;
    strPCopy (nome, nomeComput);
    if not BuildCommDCB (nome, dcb) then exit;

    porta := ord (nomeComput[4]) - ord('0');
    veloc := dcb.BaudRate;
    parid := dcb.Parity;
    nbits := dcb.ByteSize;
    if dcb.StopBits = 0 then nstops := 1 else nstops := 2;

    if dvcomm.inicLink (porta, veloc, nbits, nstops, parid) = 0 then
        result := true;
end;

{-------------------------------------------------------------}
{                     Erro na rede
{-------------------------------------------------------------}

procedure erroRede;
begin
    emulando := false;

    window (1, 1, 80, numLinhasTerm+1);
    textColor (WHITE);
    gotoxy (1, numLinhasTerm+1);
    clreol;
    textBackGround (RED);
    mensagem ('TNCONCAI', 0);  {'Conexao remota caiu'}
    textBackGround (BLACK);
    clreol;
    writeln;
end;

{-------------------------------------------------------------}
{                     abre a conexao
{-------------------------------------------------------------}

function abreConexao: boolean;
var
    localAddr,                          { descricao dos endereços local e remoto }
    remoteAddr: sockaddr_in;
    enderHost: longint;
    hip: phostent;		        { retorna o endereco IP do soquete }
    ret: integer;
    wsaData: TWSAData;
    s: string;

begin
    abreConexao := false;

    ret := WSAStartup ($0101, wsaData);
    with wsadata do
        begin
            writeln;
            writeln ('Versão da biblioteca: ', wVersion shr 8 , '.', wVersion and $ff);
            writebuf (szDescription, strlen (szDescription));      writeln;
            writebuf (szsystemStatus, strlen (szsystemstatus));    writeln;
        end;

    if ret <> 0 then
        begin
            mensagem ('TNERRCOM', 1);  {'Não consegui ativar o sistema de comunicações do micro'}
            exit;
        end;

    {************ Cria soquete ***********}

    sock := socket (AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (sock = -1) then
        begin
            mensagem ('TNNAOSOQ', 1);  {'Não consegui criar soquete'}
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

    ret := bind (sock, localAddr, sizeof(localAddr));
    if (ret = -1)  then
        begin
            mensagem ('TNERBIND', 1);  {'Não consegui alocar porta (bind)'}
            exit;
        end;

    {************ Descobre endereco IP do computador ***********}

    if (nomeHost[0] >= '0') and (nomeHost[0] <= '9')  then
        enderHost := inet_addr (nomeHost)
    else
        begin
            hip := gethostbyname (nomeHost);    {92A40304 intervox}
            if (hip = NIL)  then
                begin
                    while keypressed do readkey;
    	            mensagem ('TNSEMSRV', 1);  {'Não consegui achar um servidor com este nome'}
                    exit;
                end;
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

    with remoteAddr.sin_addr do
        begin
            s := 'Conectando com ';
            write (s);
            writeln (inet_ntoa (in_addr(enderHost)));
        end;

    if (connect (sock, remoteAddr, sizeof (remoteAddr)) = -1) then
        begin
            while keypressed do readkey;
            mensagem ('TNNAOCON', 1);  {'Não consegui realizar a conexao'}
            exit;
        end;

    writeln;
    mensagem ('TNCONOK', 1);  {'Conexão realizada'}

    abreConexao := true;
end;

{-------------------------------------------------------------}
{		     fecha o soquete
{-------------------------------------------------------------}

procedure fechaConexao;
begin
    if emPortaSerial then
        begin
            dvcomm.finalLink;
            exit;
        end;

    closeSocket (sock);
    wsaCleanup;
end;

{-------------------------------------------------------------}
{                     espera chegar um evento
{-------------------------------------------------------------}

function checaEvento: integer;
var
    entradas: TFDset;
    tempoZero: timeVal;

begin
    with tempoZero do
        begin
            tv_sec := 0;
            tv_usec := 0;
        end;

    if keypressed then
        begin
            checaEvento := CHEGOU_TECLA;
            exit;
        end;

    FD_ZERO (entradas);	 { monitora soquete }
    FD_SET (sock, entradas);
    select (sock+1, @entradas, NIL, NIL, @tempoZero);

    if FD_ISSET (sock, entradas) then
        checaEvento := CHEGOU_REDE
    else
        checaEvento := NADA_CHEGOU;
end;

{-------------------------------------------------------------}
{		  envia uma sequencia de negociacao
{-------------------------------------------------------------}

procedure sendIAC (c1, c2: char);
var
    buf: array [0..2] of char;
begin
    buf[0] := IAC;
    buf[1] := c1;
    buf[2] := c2;
    send (sock, buf, 3, 0);
end;

{-------------------------------------------------------------}
{                     negocia as primeiras opcoes
{-------------------------------------------------------------}

procedure procTermType (tipo: TTYPE);
var
    vetResp: array [0..30] of char;
    i: integer;
    tipoTerm: string;
begin
    tipoTerm := sintAmbiente ('TNETVOX', 'TERMINAL');
    if tipoTerm = '' then
        tipoTerm := 'vt100';

    vetResp [0] := IAC;
    vetResp [1] := SUBNEG;
    vetResp [2] := TERMTYPE;
    vetResp [3] := TT_IS;
    for i := 1 to length (tipoTerm) do
        vetResp [3+i] := tipoTerm [i];
    i := 4 + length (tipoTerm);
    vetResp [i] := IAC;     i := i + 1;
    vetResp [i] := SUBEND;  i := i + 1;
    send (sock, vetResp, i, 0);
end;

{-------------------------------------------------------------}

procedure preNegociaOpcoes;
begin
    sendIAC (DOTEL, ECHO);
end;

{-------------------------------------------------------------}
{                     processa dado vindo da rede
{-------------------------------------------------------------}

procedure processaRede;
var
    p: pChar;
    i, lidos: integer;

begin
    lidos := recv (sock, buf, BUFSIZE, 0);
    if (lidos <= 0) then
        begin
            erroRede;
            exit;
        end;

	{ simplificando: assumindo que nao chegam negociacoes em blocos separados }

	p := buf;
        i := 0;
        while i < lidos do
            begin
	        if (p^ <> IAC) then
                    begin
                        bufLink [pins] := p^;
                        pins := (pins + 1) mod TAMBUF;
                    end
	        else
                    begin
                        p := p + 1;
                        i := i + 1;

		        case p^ of    { so negocia eco ! }
		             #255:
                                    begin   { realmente um caractere }
                                        bufLink [pins] := p^;
                                        pins := (pins + 1) mod TAMBUF;
                                    end;

		             DOTEL:
                                    begin
                                        p := p + 1;
                                        i := i + 1;
                                        if (p^ = ECHO) or (p^ = TERMTYPE) then
                                            sendIAC (WILLTEL,p^)
                                        else
                                            sendIAC (WONTTEL,p^);
                                    end;

		             DONTTEL, WILLTEL, WONTTEL:
                                            begin
                                                p := p + 1;
                                                i := i + 1;
				            end;

                             SUBNEG:
                                 begin
                                     p := p + 4;
                                     i := i + 4;
                                     procTermType (tipoTerm);
                                 end;
                        end;
	            end;

                p := p + 1;
                i := i + 1;
	    end;
end;

{-------------------------------------------------------------}
{                tira um caractere do buffer
{-------------------------------------------------------------}

procedure lelink (var c: char);
begin
    repeat until chegouLink;
    if emPortaSerial then
        dvComm.leLink(c)
    else
        begin
            c := bufLink [pret];
            pret := (pret + 1) mod TAMBUF;
        end;
end;

{-------------------------------------------------------------}
{                ve se chegou dado para ser lido
{-------------------------------------------------------------}

function chegouLink: boolean;
begin
    if emPortaSerial then
        begin
            chegouLink := dvComm.chegouLink;
            exit;
        end;

    if pins = pret then
        if checaEvento = CHEGOU_REDE then
             processaRede;

    chegouLink := pins <> pret;
end;

{-------------------------------------------------------------}
{                escreve um dado direto no link
{-------------------------------------------------------------}

procedure esclink (c: char);
begin
    if emPortaSerial then
        begin
            dvcomm.escLink (c);
            exit;
        end;

    keypressed;  { ativa windows }

    if send (sock, c, 1, 0) <> 1 then
       erroRede;
end;

{-------------------------------------------------------------}
{                escreve uma cadeia direto no link
{-------------------------------------------------------------}

procedure escLetras (s: string);
var p: array [0..100] of char;
    i: integer;
begin
    if emPortaSerial then
        begin
            for i := 1 to length (s) do
                dvcomm.escLink (s[i]);
            exit;
        end;

    keypressed;  { ativa windows }

    strPcopy (p, s);
    if send (sock, p, length(s), 0) <> length(s) then
        erroRede;
end;

{-------------------------------------------------------------}
{          escreve um dado no buffer de transmissão
{-------------------------------------------------------------}

procedure escBuf (c: char);
begin
    bufTrans [ptrans] := c;
    ptrans := ptrans + 1;
    if ptrans >= TAMBUFTRANS then
        flushBuf;
end;

{-------------------------------------------------------------}
{                  descarrega buffer de escrita
{-------------------------------------------------------------}

procedure flushBuf;
var i, transm: integer;
    p: pointer;
begin
    if emPortaSerial then
        begin
            for i := 0 to ptrans-1 do
                 dvcomm.escLink (bufTrans[i]);
            ptrans := 0;
        end;

    if ptrans = 0 then exit;

    i := 0;
    while i < ptrans do
        begin
            keypressed;  { ativa windows }

            p := @bufTrans[i];
            transm := send (sock, p^, ptrans-i, 0);
            if transm = 0 then
                 begin
                     erroRede;
                     ptrans := 0;
                     exit;
                 end;
            i := i + transm;

            sintClek;
        end;

    ptrans := 0;
end;

{-------------------------------------------------------------}
{                       faz um break
{-------------------------------------------------------------}

procedure breakLink;
var p: pchar;
begin
    if emPortaSerial then
        begin
            SetCommBreak(comId);
            delay (100);
            ClearCommBreak(comId);
        end
    else
        begin
            bufTrans [0] := #255;
            bufTrans [1] := #243;
            p := bufTrans;
            send (sock, p^, 2, 0);
        end;
    ptrans := 0;
end;

{-------------------------------------------------------------}
{                       inicialização
{-------------------------------------------------------------}

begin
    pins := 0;
    pret := 0;
    ptrans := 0;
end.
