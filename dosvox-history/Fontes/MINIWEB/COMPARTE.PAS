{-------------------------------------------------------------}
{
{     Registro dos sites Miniweb ativos para sites não Miniweb
{
{     Autor: José Antonio Borges
{
{     Em 21/4/2001
{
{-------------------------------------------------------------}

program comparte;
uses dvcrt, dvinet, winsock, strings, windos;

{-------------------------------------------------------------}
{               traduz um byte para caracteres
{-------------------------------------------------------------}

const
    tabint: array [0..9] of char = ('0','1','2','3','4','5','6','7','8','9');
    tabsem: array [0..6]  of string[3] = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
    tabmes: array [1..12] of string[3] = ('Jan','Feb','Mar','Apr','May','Jun',
                                          'Jul','Aug','Sep','Oct','Nov','Dec');

function int2 (x: byte): string;
begin
    int2 := tabint [x div 10] + tabint [x mod 10];
end;

{-------------------------------------------------------------}
{              traduz um inteiro para caracteres
{-------------------------------------------------------------}

function int2str (v: longint): string;
var s: string;
begin
    s := '';
    while v <> 0 do
         begin
             s := tabint [v mod 10] + s;
             v := v div 10;
         end;
    if s = '' then
        int2Str := '0'
    else
        int2Str := s;
end;

{-------------------------------------------------------------}
{           traduz uma data e hora para caracteres
{-------------------------------------------------------------}

function dateTime2Str (time: longint): string;
var dt: TDateTime;
    s: string;
begin
    unpackTime (time, dt);
    with dt do
        s := int2 (day) + '/' + int2 (month) + '/' + int2str (year) + ' ' +
                        int2 (hour) + ':' + int2 (min);
    dateTime2Str := s;
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
{            avisa que está vivo pelo correio
{-------------------------------------------------------------}

const PORTASMTP = 25;

procedure avisaCorreio (nomeDef: string);
var
    sock: SOCKET;
    resp: array [0..4096] of char;
    Year, Month, Day, DayOfWeek, Hour, Minute, Second, Sec100: word;
    localAddr: sockaddr_in;
    tam: integer;
    nc: longint;
    s: string;

label erro;

    function correioReclamou: boolean;
    begin
        correioReclamou := (strlcomp (resp, '250', 3) <> 0) and
                           (strlcomp (resp, '251', 3) <> 0) and
                           (strlcomp (resp, '354', 3) <> 0) and
                           (strlcomp (resp, '503', 3) <> 0);
    end;

begin
    nc := 0;
    sock := abreConexao ('caec.nce.ufrj.br', PORTASMTP);
    if sock <= 0 then goto erro;

    nc := recv (sock, resp, sizeof(resp), 0);
    if (nc <= 0) or (strLComp (resp, '220', 3) <> 0) then goto erro;

    writelnRede (sock, 'MAIL FROM: fulano@caec.nce.ufrj.br');
    nc := recv (sock, resp, sizeof(resp), 0);
    if (nc <= 0) or correioReclamou then goto erro;

    writelnRede (sock, 'RCPT TO: miniweb@caec.nce.ufrj.br');
    nc := recv (sock, resp, sizeof(resp), 0);
    if (nc <= 0) or correioReclamou then goto erro;

    writelnRede (sock, 'DATA');
    nc := recv (sock, resp, sizeof(resp), 0);
    if (nc <= 0) or correioReclamou then goto erro;

    getDate(Year, Month, Day, DayOfWeek);
    getTime (Hour, Minute, Second, Sec100);
    writelnRede (sock,
                 'Date: ' + int2Str(Day) + ' ' + tabMes [Month] + ' ' + int2Str (Year) +
                 ' ' + int2(Hour) + ':' + int2(Minute) + ':' + int2(Second));

    writelnRede (sock, 'From: <fulano@caec.nce.ufrj.br>');
    writelnRede (sock, 'To: <miniweb@caec.nce.ufrj.br>');

    tam := sizeof (localAddr);
    getSockName (sock, localAddr, tam);
    s := 'Subject: ' + 'MINIWEB ' + strPas (inet_ntoa (localAddr.sin_addr.s_addr));
    s := s + ' ' + nomeDef;

    writelnRede (sock, s);
    writelnRede (sock, '');

    writelnRede (sock, '.');
    closeSocket (sock);

    writeln ('Proclamas foram enviados pelo correio');
    delay (1000);
    fechaConexao (sock);
    exit;

erro:
    writeln (#$7, #$7, #$7, 'Não consegui enviar os proclamas pelo correio');
    if nc <> 0 then
        begin
            if nc > 80 then nc := 80;
            resp[nc] := #$0;
            writeln (strPas (resp));
            readkey;
        end;
    fechaConexao (sock);
end;

var nome: string;
    i: integer;
begin
    screensize.y := 6;
    writeln ('Compartilhador de arquivos com a comunidade DOSVOX');
    writeln;
    nome := '';
    for i := 1 to paramCount do
        nome := nome + ' ' + paramstr(i);
    delete (nome, 1, 1);
    if nome = '' then
        begin
            writeln ('Informe seu nome (é anti-ético usar nome-fantasia)');
            readln (nome);
        end;
    trim (nome);

    abreWinSock;
    avisaCorreio (nome);
    doneWinCrt;
end.
