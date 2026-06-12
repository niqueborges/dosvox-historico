{-------------------------------------------------------------}
{
{     Registro dos sites Miniweb ativos
{
{     Autor: José Antonio Borges
{
{     Em 21/4/2001
{
{-------------------------------------------------------------}

uses dvwin, dvcrt, dvinet, winsock, sysUtils, windows;

const
    SERVER_NAME = 'Server: DOSVOX/Listasit (1.1)';

    PORTADEF = 1958;
    TAM_BUFFER = 4096;
    MAXSENHAS = 5000;
    MAXSITES = 1000;

type
    PSite = ^TSite;
    TSite = record
        horaReg: longint;
        ip: longint;
        porta: integer;
        senha: string[12];
        nome: string[40];
    end;

    PSenha = ^TSenha;
    TSenha = record
        senha: string[12];
        nome: string[40];
    end;

var
    nsites: integer;
    listaSites: array [1..MAXSITES] of PSite;
    nsenhas: integer;
    listaSenhas: array [1..MAXSENHAS] of PSenha;

    sockListen: Tsocket;
    sockRegistro: Tsocket;
    sockPedido: Tsocket;

    caracVivo: integer;

{-------------------------------------------------------------}
{             transforma de hora para longint
{-------------------------------------------------------------}

function horaParaLongint (ano, mes, dia, hora, min, seg: word): longint;
begin
    horaParaLongint := ((((((longint(ano)-1980)*12)+mes*31)+dia*24)+hora)*60+min)*60+seg;
end;

{-------------------------------------------------------------}
{                   pega hora atual em longint
{-------------------------------------------------------------}

function horaAtual: longint;
var ano, mes, dia, hora, min, seg: word;
    sem, cent: word;
begin
    getDate (ano, mes, dia, sem);
    getTime (hora, min, seg, cent);
    horaAtual := horaParaLongint (ano, mes, dia, hora, min, seg);
end;

{-------------------------------------------------------------}
{                 faz um desenhinho na tela
{-------------------------------------------------------------}

procedure mostraQueEstaVivo;
const
    tabVivo: array [0..3] of char = ('-', '\', '|', '/');
begin
    caracVivo := (caracVivo + 1) mod 4;
    write (tabVivo [caracVivo]);
    gotoxy (1, wherey);
    keypressed;
end;

{-------------------------------------------------------------}
{                  informa meu endereço IP
{-------------------------------------------------------------}

procedure informaMeuIp;
var
    localAddr: sockaddr_in;
    tam: integer;
    sock: TSOCKET;
begin
    tam := sizeof (localAddr);
    sock := abreConexao ('www.ufrj.edu.br', 80);
    if sock = -1 then
        sock := abreConexao ('www.ufrj.br', 80);

    sintWrite ('Meu endereço IP é ');

    if sock >= 0 then
        begin
            getSockName (sock, localAddr, tam);
            write (strPas (inet_ntoa (in_addr(localAddr.sin_addr.s_addr))));
            sintSoletra (strPas (inet_ntoa (in_addr(localAddr.sin_addr.s_addr))));
            sintWrite (' porta ');
            sintWriteint (portaDef);
            while sintFalando do;
            writeln;
            writeln;
        end
    else
        sintWriteln ('127.0.0.1');

    fechaConexao (sock);
end;

{-------------------------------------------------------------}
{        remove brancos ao início e fim de uma cadeia
{-------------------------------------------------------------}

procedure trim (var s: string);
begin
    while (s <> '') and (s[1] = ' ') do delete (s, 1, 1);
    while (s <> '') and (s[length(s)] = ' ') do delete (s, length (s), 1);
end;

{-------------------------------------------------------------}
{                 pega uma palavra de uma cadeia
{-------------------------------------------------------------}

function pegaPalavra (var s: string): string;
var p: integer;
begin
     trim (s);
     p := pos (' ', s);
     if p = 0 then
         begin
             pegaPalavra := s;
             s := '';
         end
     else
         begin
             pegaPalavra := copy (s, 1, p-1);
             delete (s, 1, p);
             trim (s);
         end;
end;

{-------------------------------------------------------------}
{                  pega senhas do arquivo
{-------------------------------------------------------------}

procedure pegaSenhas;
var
    arqSenhas: text;
    s, s2: string;
    nomeArqSenhas: string;
    sz: array [0..255] of char;
    p: integer;

begin
    nomeArqSenhas := sintAmbiente ('LISTASIT', 'ARQSENHAS');
    if nomeArqSenhas = '' then
        begin
            nomeArqSenhas := 'c:\winvox\listasit.amb';
            strPCopy (sz, nomeArqSenhas);
            sintGravaAmbiente('LISTASIT', 'ARQSENHAS', sz, 'DOSVOX.INI');
        end;

    nsenhas := 0;
    assign (arqSenhas, nomeArqSenhas);
    {$I-} reset (arqSenhas);  {$I+}
    if ioresult <> 0 then exit;

    while not eof (arqSenhas) do
        begin
            readln (arqSenhas, s);
            if nsenhas >= MAXSENHAS then break;

            nsenhas := nsenhas + 1;
            new (listaSenhas[nsenhas]);
            with listaSenhas[nsenhas]^ do
                begin
                    p := pos ('=', s);
                    s2 := copy (s, 1, p-1);
                    trim (s2);
                    nome := s2;

                    delete (s, 1, p);
                    trim (s);
                    senha := s;
                end;
        end;
    close (arqSenhas);
end;

{-------------------------------------------------------------}
{                      trata o teclado
{-------------------------------------------------------------}

function trataTeclado: boolean;
var c: char;
    i: integer;
begin
    c := readkey;
    if c = #$0 then c := readkey;

    if c = F1 then
        begin
            sintWriteln ('As opções do programa são');
            sintWriteln ('F5 para saber Miniweb estão ativos');
            sintWriteln ('F6 para saber os nomes destas conexões');
            sintWriteln ('ESC para sair');
        end
    else
    if c = F5 then
        begin
            sintWrite ('Número de sites ativos: ');
            sintWriteint (nsites);
            writeln;
        end
    else
    if c = F6 then
        begin
            if nsites = 0 then
                sintWrite ('Nenhum site ativo')
            else
            for i := 1 to nsites do
                begin
                    clreol;
                    writeln;
                    sintWrite (listaSites[i]^.nome);
                end;
            writeln;
        end;

    trataTeclado := c <> ESC;
end;

{-------------------------------------------------------------}
{                     inicializacao
{-------------------------------------------------------------}

procedure inicializa;
var
    jan: hWnd;
begin
    sintInic (0, sintAmbiente ('MINIWEB', 'DIRLISTASIT'));
    sintFalaPont := false;

    jan := findWindow ('dvwincrt', 'LISTASIT');    { Evita 2 listasit rodando }
    if jan <> 0 then
        begin
            setFocus (jan);
            halt;
        end;

    clrscr;
    setWindowText (crtWindow, 'LISTASIT');

{---}

    sintWriteln ('Servidor para Lista de Miniwebs Ativos');
    writeln;
    writeln ('"Os autores deste programa advertem que servir à Internet');
    writeln ('é uma atividade de risco.  Os autores, distribuidores e a UFRJ');
    writeln ('não assumem nenhuma responsabilidade sobre qualquer perda');
    writeln ('que possa advir, direta ou indiretamente, pelo uso deste programa,');
    writeln ('mesmo que causada por falhas de programação."');
    writeln;

    while keypressed do readkey;

    nsites := 0;

    abreWinSock;
    informaMeuIp;

    sockListen := escutaConexao (PORTADEF);
    sockRegistro := escutaConexaoUDP (PORTADEF);
end;

{-------------------------------------------------------------}
{               traduz um byte para caracteres
{-------------------------------------------------------------}

const
    tabint: array [0..9] of char = ('0','1','2','3','4','5','6','7','8','9');

function int2 (x: byte): string;
begin
    int2 := tabint [x div 10] + tabint [x mod 10];
end;

{-------------------------------------------------------------}
{              traduz um inteiro para caracteres
{-------------------------------------------------------------}

function intTostr (v: longint): string;
var s: string;
begin
    s := '';
    while v <> 0 do
         begin
             s := tabint [v mod 10] + s;
             v := v div 10;
         end;
    if s = '' then
        intToStr := '0'
    else
        intToStr := s;
end;

{-------------------------------------------------------------}
{                  envia o cabeçalho HTTP
{-------------------------------------------------------------}

procedure enviaCabecalhoHTTP (sock: TSocket);
var
    bufTxt: array [0..TAM_BUFFER] of char;
    data: string;
    ano, mes, dia, semana, hora, min, seg, cent: word;

const
    tabsem: array [0..6]  of string[3] = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
    tabmes: array [1..12] of string[3] = ('Jan','Feb','Mar','Apr','May','Jun',
                                          'Jul','Aug','Sep','Oct','Nov','Dec');
    CRLF = #$0d + #$0a;

begin
    keypressed;   { prestigia o scheduler do Windows }


    getDate (ano, mes, dia, semana);
    getTime (hora, min, seg, cent);
    data := 'Date: ' + tabsem[semana] + ', ' +
                       int2 (dia) + ' ' + tabmes[mes] + ' ' + intTostr (ano) + ' ' +
                       int2 (hora) + ':' + int2 (min) + ':' + int2 (seg) + ' GMT' + #$0;

    bufTxt [0] := #$0;

    strCat (bufTxt, 'HTTP/1.0 200 Diretório se segue' + CRLF);
    strCat (bufTxt, @data[1]);
    strCat (bufTxt, CRLF);
    strCat (bufTxt, SERVER_NAME + CRLF);
    strCat (bufTxt, 'Content-Type: text/html' + CRLF);
    strCat (bufTxt, CRLF);
    send (sock, bufTxt, strlen (bufTxt), 0);
end;

{-------------------------------------------------------------}
{                  registra acesso
{-------------------------------------------------------------}

procedure registra (sock: TSocket);
var
    localAddr: sockaddr_in;
    tam: integer;
    Year, Month, Day, DayOfWeek: word;
    Hour, Minute, Second, Sec100: word;
    data, cliente: string;

    nomeArqLog: string;
    arqlog: text;

begin
    nomeArqLog := sintAmbiente ('LISTASIT', 'ARQREGISTRO');
    if nomeArqLog = '' then exit;

    getPeerName (sock, localAddr, tam);
    cliente := strPas (inet_ntoa (in_addr(localAddr.sin_addr.s_addr)));
    getDate(Year, Month, Day, DayOfWeek);
    getTime (Hour, Minute, Second, Sec100);

    data := intToStr(Day) + '/' + intToStr(Month) + '/' + intToStr (Year) +
                     ' ' + int2(Hour) + ':' + int2(Minute) + ':' + int2(Second);

    assign (arqLog, nomeArqLog);
    {$I-} append (arqLog);  {$I+}
    if ioresult <> 0 then
        begin
            {$I-} rewrite (arqLog);  {$I+}
            if ioresult <> 0 then
                begin
                    sintWriteln ('Erro ao gerar arquivo de registro');
                    nomeArqLog := '';
                    exit;
                end;
        end;

    {$I-}  writeln (arqlog, data, ' ', cliente);  {$I+}
    if ioresult <> 0 then
         begin
             sintWriteln ('Erro ao gerar arquivo de registro');
             nomeArqLog := '';
         end;

    close (arqLog);
end;

{-------------------------------------------------------------}
{                  envia a lista de sites
{-------------------------------------------------------------}

procedure enviaPagina (sock: integer);
var i: integer;
    s: string;
    pedido: string;

    meuBuf: pBufRede;       { buffer do soquete sock }

begin
    keypressed;   {prestigia o scheduler do Windows}
    meuBuf := inicBufRede (sock);

    registra (sock);

    keypressed;
    if readlnBufRede (meuBuf, pedido, 1) then;   {só para constar...}

    enviaCabecalhoHTTP (sock);
    writelnRede (sock, '');

    keypressed;
    if nsites = 0 then
        writelnRede (sock, '<html><h3>Nenhum site MINIWEB ativo</H3></html>')
    else
        begin
             writelnRede (sock, '<html>');
             writelnRede (sock, '<head><title>Lista de sites Miniweb</title></head>');
             writelnRede (sock, '<h3>Sites Miniweb Ativos</H3><hr>');
        end;

    for i := 1 to nsites do
        with listaSites[i]^ do
            begin
                keypressed;
                s := strPas (inet_ntoa(in_addr(ip)));
                if porta <> 80 then
                    s := s + ':' + intToStr (porta);
                writelnRede (sock, '<a href="http://' + s + '">' + nome + '</a><br>');
            end;

    writelnRede (sock, '</html>');

    fimBufRede (meuBuf);
    keypressed;
    delay (1000);
    fechaConexao (sock);
end;

{-------------------------------------------------------------}
{             consistência de pedido de registro
{-------------------------------------------------------------}

function consiste (novoSite: TSite; ipOrigem: longint): boolean;
var s, s2: string;
begin
    consiste := false;

    with novoSite do
        begin
            if ip <> ipOrigem then
                begin
                    s := strPas (inet_ntoa(in_addr(ip)));
                    s2 := strPas (inet_ntoa(in_addr(ipOrigem)));

                    if porta <> 80 then
                        s := s + ':' + intToStr (porta);
                    sintWriteln ('Tentativa de enganar de ' + s + ' fingindo ser ' + s2);
                    exit;
                end;

            { consistir ip, porta, senhaReg, nome }
            { verificar senha errada }
            { verificar acessos estranhos }
        end;

    consiste := true;
end;

{-------------------------------------------------------------}
{                verifica se senha está válida
{-------------------------------------------------------------}

function senhaValida (novosite: TSite): boolean;
var i: integer;
begin
    senhaValida := false;
    for i := 1 to nsenhas do
        begin
            if (maiuscAnsi (novoSite.nome) =
                 maiuscAnsi (listaSenhas[i]^.nome) ) and
               (maiuscAnsi (novoSite.senha) =
                 maiuscAnsi (listaSenhas[i]^.senha) ) then
                   begin
                       senhaValida := true;
                       exit;
                   end;
        end;
end;

{-------------------------------------------------------------}
{       checa se site está duplicado, atualizando registro
{-------------------------------------------------------------}

function siteDuplicado (novoSite: TSite): boolean;
var i: integer;
begin
    for i := 1 to nsites do
        begin
            if (novoSite.ip = listaSites[i]^.ip) and
               (novoSite.porta = listaSites[i]^.porta) then
                   begin
                       listaSites[i]^ := novoSite;
                       siteDuplicado := true;
                       exit;
                   end;
        end;
    siteDuplicado := false;
end;

{-------------------------------------------------------------}
{                  remove um site registrado
{-------------------------------------------------------------}

procedure removeSite (novoSite: TSite);
var i, j: integer;
begin
    for i := 1 to nsites do
        begin
            if (novoSite.ip = listaSites[i]^.ip) and
               (novoSite.porta = listaSites[i]^.porta) then
                   begin
                       dispose (listaSites[i]);
                       for j := i to nsites-1 do
                           listaSites[j] := listaSites[j+1];
                       nsites := nsites - 1;
                       exit;
                   end;
        end;
end;

{-------------------------------------------------------------}
{                     registra um pedido
{-------------------------------------------------------------}

procedure registraPedido (sockRegistro: integer);
var
    buf: array [0..255] of char;
    lido, fun, s: string;
    recebidos: integer;
    novoSite: TSite;

    ano, mes, dia, sem: word;
    hora, min, seg, cent: word;
    ipOrigem: longint;
    incluir: boolean;
    cp: array [0..100] of char;

begin
    recebidos := recebeUDP (sockRegistro, buf, 255, ipOrigem);
    buf[recebidos] := #$0;
    incluir := false;

    if recebidos <> 0 then
        begin
            lido := strPas (buf);
            with novoSite do
                begin
                    fun := pegaPalavra (lido);
                    if fun = 'MINIWEB' then
                        incluir := true
                    else
                    if fun = 'MINIEND' then
                        incluir := false
                    else
                        begin
                             s := strPas (inet_ntoa (in_addr(ip)));
                             sintWriteln ('Função ' + fun + ' inválida pedida por ' + s);
                             exit;
                        end;

                    getDate (ano, mes, dia, sem);
                    getTime (hora, min, seg, cent);
                    horaReg := horaParaLongint (ano, mes, dia, hora, min, seg);

                    s := pegaPalavra (lido);
                    ip := inet_addr (strPCopy (cp, s));
                    porta := strToInt (pegaPalavra (lido));
                    senha := pegaPalavra (lido);
                    nome := lido;
                end;
        end;

    if consiste (novoSite, ipOrigem) then
        begin
            if nsites > 5000 then exit;

            if not senhaValida (novoSite) then
                novoSite.nome := '(?) ' + novoSite.nome;

            if incluir then
                begin
                    if siteDuplicado (novoSite) then
                         exit;
                    nsites := nsites + 1;
                    new (listaSites[nsites]);
                    listaSites[nsites]^ := novoSite;
                end
            else
                removeSite (novoSite);
        end;
end;

{-------------------------------------------------------------}
{    elimina sites com mais de 3 minutos sem confirmação
{-------------------------------------------------------------}

procedure eliminaSitesVelhos;
var e, ns: integer;
begin
    for ns := nsites downto 1 do
        with listaSites[ns]^ do
            if horaAtual - horaReg > 180 then
                 begin
                     dispose (listaSites[ns]);
                     for e := ns to nsites-1 do
                         listaSites [e] := listaSites [e+1];
                     nsites := nsites - 1;
                 end;
end;

{-------------------------------------------------------------}
{                   exibe os sites registrados
{-------------------------------------------------------------}

procedure exibeSites;
begin

end;

{-------------------------------------------------------------}
{                  publica lista de sites
{-------------------------------------------------------------}

begin
    inicializa;
    pegaSenhas;

    repeat
        delay (200);
        mostraQueEstaVivo;

        if keypressed then
            if not trataTeclado then break;

        if chegouRede (sockRegistro) then
            begin
                eliminaSitesVelhos;
                registraPedido (sockRegistro);
                exibeSites;
            end;

        if chegouRede (sockListen) then
            begin
                eliminaSitesVelhos;
                sockPedido := aceitaConexao (sockListen);
                if sockPedido >= 0 then
                    enviaPagina (sockPedido);
            end;

    until false;

    fechaConexao (sockRegistro);
    fechaConexao (sockListen);
    fechaWinSock;

    sintWriteln ('Fim do Servidor de Presença');
    doneWincrt;
end.
