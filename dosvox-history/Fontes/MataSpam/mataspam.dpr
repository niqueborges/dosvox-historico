{-------------------------------------------------------------}
{
{     Matador de arquivos spam
{
{     Autor: José Antonio Borges
{
{     Em Janeiro de 2007
{
{-------------------------------------------------------------}

uses
    dvwin, dvcrt, dvinet, dvssl, winsock, sysUtils, windows,
    msmsg, msbloque;

const
    CRLF = #$0d + #$0a;

var
    sock: integer;
    servidor, conta, senha: string;
    usaSSL: boolean;
    bipPermitido: boolean;
    pbuf: pbufRede;

{-------------------------------------------------------------}
{       Inicializa, pede informações da conta
{-------------------------------------------------------------}

function inicializa: boolean;
var
    salva: integer;
    c: char;

label desistiu;

begin
    setWindowTitle ('MataSpam');
    usaSSL := false;
    if paramCount >= 1 then
        servidor := paramStr(1)
    else
        begin
            mensagem ('MSSERPOP', 1);{'Qual o servidor POP3? '}
            c := sintEditaCampo (servidor, 1, wherey, 255, 80, true);
            writeln;
            if c = ESC then goto desistiu;
            if servidor = '' then
                begin
                    servidor := sintAmbiente ('CARTAVOX', 'SERVIDORPOP3');
                    if servidor = '' then
                        servidor := '127.0.0.1';
                end;
        end;

    if paramCount >= 2 then
        conta := paramStr(2)
    else
        begin
            mensagem ('MSQUACON', 1);{'Qual a conta? '}
            c := sintEditaCampo (conta, 1, wherey, 255, 80, true);
            writeln;
            if c = ESC then goto desistiu;
            if conta = '' then
                begin
                    conta := sintAmbiente ('CARTAVOX', 'CONTAUSUARIO');
                    if conta = '' then
                        conta := 'fulano';
                end;
        end;
    setWindowTitle ('MataSpam - ' + conta);

    if paramCount >= 3 then
        usaSSL := ansiUpperCase (copy (paramStr(3), 1, 1)) = 'S'
    else
        begin
            mensagem ('MSSSL', 1);  {'Este servidor usa segurança SSL? '}
            c := sintReadkey;
            writeln (c);
            if c = ESC then goto desistiu;
            usaSSL := upcase (c) = 'S';
        end;

    if paramCount >= 4 then
        senha := paramStr(4)
    else
        begin
            mensagem ('MSQUASEN', 1);{'Qual a senha? '}
            salva := textAttr;
            textAttr := (textAttr and $f) or ((textAttr shl 4) and $f0);
            readln (senha);
            textAttr := salva;
            if senha = '' then goto desistiu;
        end;

    bipPermitido := paramCount < 5;
    inicializa := true;
    exit;

desistiu:
    mensagem ('MSDESIST', 1);{'Desistiu'}
    inicializa := false;
end;

{-------------------------------------------------------------}
{       Retorna o número de cartas no servidor
{-------------------------------------------------------------}

function mostraNumCartas: integer;
var s, x: string;
begin
    writelnRede (sock, 'STAT');
    readlnBufRede(pbuf, s, 10);
    writeln (s);
    while (s <> '') and (not (s[1] in ['0'..'9'])) do
        delete (s, 1, 1);

    x := '';
    while (s <> '') and (s[1] in ['0'..'9']) do
        begin
            x := x + s[1];
            delete (s, 1, 1);
        end;
    if x = '' then
        mostraNumCartas := 0
    else
        mostraNumCartas := strToInt (x);
end;

{-------------------------------------------------------------}
{       Procedimento que mata os spans
{-------------------------------------------------------------}

procedure mataSpans;
var s: string;
    i, j, n: integer;
    statusLinha, statusSpam: integer;
    nspans: integer;
    c: char;

label erro;

begin
    limpaBufTec;
    mensagem ('MSMATSDE', 0); {'Matando spans de '}
    sintWriteln (conta);
    n := mostraNumCartas;
    if n < 1 then
        begin
            mensagem ('MSNCASER', 1); {'Não há cartas no servidor.'}
            exit;
        end;
    falaNum (n, 0);
    mensagem ('MSCARTAS', 1); {' cartas'}

    nspans := 0;

    for i := 1 to n do
        begin
            if keypressed then
                begin
                    c := readkey;
                    if c = #$1b then break;

                    if c = ' ' then
                        bipPermitido := not bipPermitido
                    else
                        begin
                            writeln;
                            write (' ');
                            falaNum (i, 0);
                            mensagem ('MSDE', 0);{' de '}
                            falaNum (n, 1);
                        end;
                end;

            writelnRede (sock, 'TOP ' + intToStr (i) + ' 50');
            if not readlnBufRede(pbuf, s, 10) then goto erro;
            if (s <> '') and (s[1] = '-') then
                begin
                    sintWriteln (s);
                    goto erro;
                end;

            statusSpam := 0; // 0 = não achou  1 = achou  2 = força aceitação
            for j := 1 to 1000 do
                begin
                    if s = '.' then break;
                    if j <> 1 then
                         if not readlnBufRede(pbuf, s, 10) then goto erro;
                    if statusSpam = 2 then
                        continue;

                    statusLinha := buscaProibidas (s);
                    if statusLinha <> 0 then statusSpam := statusLinha;

                    // não pode dar break, tem que esperar limpar o buffer
                end;

            if statusSpam = 1 then
                 begin
                     write ('S');
                     nspans := nspans + 1;
                     writelnRede (sock, 'DELE ' + intToStr (i));
                     if not readlnBufRede(pbuf, s, 10) then goto erro;
                     if bipPermitido then sintBip;
                 end
            else
                 begin
                     write ('N');
                     if bipPermitido then sintClek;
                 end;
        end;

    writeln;
    if nspans = 0 then
        mensagem ('MSNENSPA', 1){'Não encontrou Spam'}
    else
        begin
            mensagem ('MSENSPVI', 0); {'Número de spans e vírus encontrados: '}
            falaNum (nspans, 1);
            mensagem ('MSCARAPR', 0); {'Cartas aprovadas: '}
            falaNum (n - nspans, 1);
        end;
    exit;

erro:
    mensagem ('MSSERCAI', 1); {'Servidor parece ter caido'}
end;

{-------------------------------------------------------------}
{           Faz a abertura da conta
{-------------------------------------------------------------}

function abreConta: boolean;
var s: string;
begin
    abreConta := false;
    readlnBufRede(pbuf, s, 10);
    mensagem ('MSCONREA', 1); {'Conexão realizada'}

    writelnRede (sock, 'USER ' + conta);
    readlnBufRede(pbuf, s, 10);
    if (s <> '') and (s[1] <> '+') then exit;

    writelnRede (sock, 'PASS ' + senha);
    readlnBufRede(pbuf, s, 10);
    if (s <> '') and (s[1] <> '+') then exit;

    abreConta := true;
end;

{-------------------------------------------------------------}
{       Corpo principal
{-------------------------------------------------------------}

label fim;
var
    wsaData: TWSADATA;
    s: string;
    dir: string;
begin
    dir := sintambiente ('MATASPAM', 'DIRMATASPAM');
    if dir = '' then
        dir := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\mataspam';
    sintInic (0, dir);
    mensagem ('MSMATASP', 1); {'Matador de spans'}

    if not inicializa then goto fim;
    if not carregaArqProibidas then goto fim;

    if WSAStartup ($0101, wsaData) <> 0 then
        mensagem ('MSNSICOM', 1) {'Não consegui ativar o sistema de comunicações do micro'}
    else
        begin
            if usaSSL then
                sock := abreConexaoSSL(servidor, portaSSLPOP3)
            else
                sock := abreConexao(servidor, 110);

            if sock >= 0 then
                begin
                    pbuf := inicBufRede (sock);
                    if abreConta then
                         mataSpans
                    else
                         mensagem ('MSERROCO', 1); {'Erro ao abrir a conta'}
                end;
        end;

    if sock >= 0 then
        begin
            writelnRede (sock, 'QUIT');
            readlnBufRede(pbuf, s, 10);          // espera resposta, pelo menos
            writeln (s);
            fimBufRede (pbuf);
            fechaConexao (sock);
        end;
    WSACleanup;

    mensagem ('MSFIM', 1); {'Fim'}
    destroiLinhasArquivo;
fim:

    sintFim;
    doneWinCrt;
end.
