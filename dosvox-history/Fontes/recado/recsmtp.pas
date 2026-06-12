{--------------------------------------------------------}
{                                                        }
{    Programa de envio e recepção de recados             }
{                                                        }
{    Módulo de envio de recados por SMTP                 }
{                                                        }
{    Autor: José Antonio Borges                          }
{                                                        }
{    Em novembro/2014                                    }
{                                                        }
{--------------------------------------------------------}

unit recsmtp;

interface

uses dvcrt, dvwin, dvInet, dvSSL, dvForm,
     recvars, recmsg, recMime64,
     windows, classes, sysutils, dateUtils;

function pegaNomeArqTemp (ext: string): string;
function enviaSMTP (arqSMTP: string): boolean;
function enviaRecadoSMTP (nomeArqTempTexto, nomeArqTempSom, destinatario: string): boolean;

implementation
var
    sockSMTP: integer;
    b_sockSMTP: PbufRede;
    computLocal: string;
    respServidor: string;

{-------------------------------------------------------------}

function geraChaveMime: string;
var i, n: integer;
    s: string;
    chaveMime: string;
begin
    chaveMime := '';             { gera chave Mime randomica }
    for i := 1 to 10 do
         begin
             n := random (255);
             str (n, s);
             chaveMime := chaveMime + s;
         end;
    result := chaveMime;
end;

{--------------------------------------------------------}

function pegaNomeArqTemp (ext: string): string;
var
    tempPath: array [0..144] of char;
    tempFileName: array [0..144] of char;
    s: string;
begin
    getTempPath (144, tempPath);
    getTempFileName(tempPath, 'REC', 0, tempFileName);
    DeleteFile(tempFileName);

    s := strPas (tempFileName);
    delete (s, length(s)-3, 4);
    s := s + '.' + ext;
    strPCopy (tempFileName, s);
    result := strPas (tempFileName);
end;

{--------------------------------------------------------}

function quotedPrintable (s: string): string;
const
    tabhexa: array [0..15] of char =
           ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
var
    i: integer;
    c: char;
begin
    if (s = '.') then
        begin
            result := '=' +
                      tabhexa [ord ('.') shr 4] +
                      tabhexa [ord ('.') and $f];
            exit;
        end;

    result := '';
    for i := 1 to length(s) do
        begin
             if (s[i] = '=') or (s[i] > #$7e) or (s[i] < #$20) then
                 begin
                     c := s[i];
                     result := result + '=' +
                                tabhexa [ord (c) shr 4] +
                                tabhexa [ord (c) and $f];
                 end
             else
                 result := result + s[i]
        end;
end;

{--------------------------------------------------------}

function montaMensagem (nomeArqTempTexto, nomeArqTempSom, destinatario: string): string;
const
    tabMes: array [1..12] of string [3] = (
       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
var
    nomeArqMsg, nomeArqTempMime64: string;
    arqEnv: textFile;
    i1, i2: integer;
    s: string;
    ender, fromAddr: string;
    chaveMime: string;
    Year, Month, Day, DayOfWeek: Word;
    Hour, Minute, Second, Sec100: Word;
    arqTexto: TextFile;
    nome: string;

        function d2 (x: integer): string;
        begin
            result := intToStr(x);
            if length(result) = 1 then result := '0' + result;
        end;

        function limpaNome (nome: string): string;
        var p: integer;
        begin
            p := pos ('<', nome);
            if p <> 0 then
                nome := trim (copy (nome, 1, p-1));
            if copy (nome, 1, 1) = '"' then
                begin
                    delete (nome, 1, 1);
                    delete (nome, length(nome), 1);
                end;
            result := trim(nome);
        end;

begin
    getDate(Year, Month, Day, DayOfWeek);
    dvcrt.getTime (Hour, Minute, Second, Sec100);

    nome := limpaNome (destinatario);
    nomeArqMsg := nome + ' em ' +
                      d2(Day) + '-' + d2(Month) + '-' + intToStr(Year) + ' - ' +
                      d2(Hour) + '.' + d2(Minute) + '.CPR';

    result := nomeArqMsg;

    assignFile (arqEnv, nomeArqMsg);
    rewrite (arqEnv);

    // cabeçalho SMTP

    ender := enderUsuario;
    i1 := pos ('<', ender);
    if i1 <> 0 then
        begin
            i2 := pos ('>', ender);
            ender := copy (ender, i1+1, i2-i1);
        end;
    writeln (arqEnv, 'MAIL FROM:<', ender, '>');
    fromAddr := ender;

    ender := destinatario;
    i1 := pos ('<', ender);
    if i1 <> 0 then
        begin
            i2 := pos ('>', ender);
            ender := copy (ender, i1, i2-i1+1);
            writeln (arqEnv, 'RCPT TO:', ender)
        end
    else
        writeln (arqEnv, 'RCPT TO:<', ender, '>');

    writeln (arqEnv, 'DATA');

    // cabeçalho da mensagem

    writeln (arqEnv, 'MIME-Version: 1.0');

    write (arqEnv, 'Date: ', Day, ' ', tabMes [Month], ' ', Year);
    writeln (arqEnv,  ' ', Hour, ':', Minute, ':', Second, ' -0300');

    writeln (arqEnv,'X-Mailer: Recado v.1.0');

    writeln (arqEnv, 'Subject: ' + codificaAssuntoMime64 (
                      'Recado de ' + nomeUsuario + ' em ' +
                      d2(Day) + '/' + d2(Month) + '/' + intToStr(Year) + ' - ' +
                      d2(Hour) + ':' + d2(Minute)));

    writeln (arqEnv, 'From: ' + nomeUsuario + ' <' + fromAddr + '>');
    writeln (arqEnv, 'To: ', destinatario);

    chaveMime := geraChaveMime;
    writeln (arqEnv, 'Content-Type: multipart/mixed; boundary=' + chavemime);
    writeln (arqEnv);

    // texto do recado

    writeln (arqEnv, '--' + chaveMime);
    writeln (arqEnv, 'Content-Type: text/plain; charset=ISO-8859-1');
    writeln (arqEnv, 'Content-Transfer-Encoding: quoted-printable');
    writeln (arqEnv);
    writeln (arqEnv, 'Recado de ' + nomeUsuario + ' em ' +
                     d2(Day) + '/' + d2(Month) + '/' + intToStr(Year) + ' - ' +
                     d2(Hour) + ':' + d2(Minute));
    if nomeArqTempTexto <> '' then
        begin
            assign (arqTexto, nomeArqTempTexto);
            reset (arqTexto);
            while not eof (arqTexto) do
                begin
                    readln (arqTexto, s);
                    writeln (arqEnv, quotedPrintable(s));
                end;
            closeFile (arqTexto);
        end;

    // áudio do recado

    if nomeArqTempSom <> '' then
        begin
            writeln (arqEnv, '--' + chaveMime);
            writeln (arqEnv, 'Content-Type: audio/mpeg; name="recado.mp3"');
            writeln (arqEnv, 'Content-Disposition: attachment; filename="recado.mp3"');
            writeln (arqEnv, 'Content-Transfer-Encoding: base64');
            writeln (arqEnv);

            nomeArqTempMime64 := pegaNomeArqTemp('txt');
            CodifMime64(nomeArqTempSom, nomeArqTempMime64);

            assign (arqTexto, nomeArqTempMime64);
            reset (arqTexto);
            while not eof (arqTexto) do
                begin
                    readln (arqTexto, s);
                    writeln (arqEnv, s);
                end;
            closeFile (arqTexto);

            DeleteFile(nomeArqTempMime64);
    end;

    // marca final

    writeln (arqEnv, '--' + chaveMime + '--');
    closeFile (arqEnv);
end;

{-------------------------------------------------------------}

function abreConexaoSmtp: boolean;
begin
    abreConexaoSmtp := false;
    if smtpComSSL then
        sockSMTP := abreConexaoSSL(hostSMTP, portaSMTP)
    else
        sockSMTP := abreConexao(hostSMTP, portaSMTP);
    if sockSMTP = -1 then exit;

    b_sockSMTP := inicBufRede(sockSMTP);
    repeat
        readlnBufRede (b_sockSMTP, respServidor, 10);
    until copy (respServidor, 1, 4) <> '220-';

    if copy (respServidor, 1, 3) = '220' then
        abreConexaoSmtp := true;
end;

{-------------------------------------------------------------}

function sendAndRec (s: string; respOk: string): boolean;
begin
    writelnRede (sockSMTP, s);
    if debug then
        writeln ('>>>', s);
    repeat
        readlnBufRede (b_sockSMTP, respServidor, 10);
    if debug then
        writeln ('<<<', respServidor);
    until copy (respServidor, 4, 1) <> '-';

    sendAndRec := copy (respServidor, 1, 3) = respOk;
end;

{-------------------------------------------------------------}


{-------------------------------------------------------------}
{       abre smtp com ou sem senha
{-------------------------------------------------------------}

function loginSmtp: boolean;
label erro;
begin
    loginSmtp := true;

    if smtpComTLS then
        begin
            if not sendAndRec ('HELO '+ semAcentos(computLocal), '250') then goto erro;
            if not sendAndRec ('STARTTLS', '220') then goto erro;
            if not conectaSSL (sockSMTP, hostSMTP) then
                begin
                    respServidor := '500 TLS error';
                    goto erro;
                end;
        end;

    if smtpComSenha or smtpComTLS then
        begin
            if not sendAndRec ('EHLO ' + semAcentos(computLocal), '250') then goto erro;
            if not sendAndRec ('AUTH LOGIN', '334') then goto erro;
            if not sendAndRec (codFraseMime64 (contaUsuario), '334') then goto erro;
            if not sendAndRec(codFraseMime64 (senhaUsuario), '235') then goto erro;
        end
    else
        if not sendAndRec ('HELO '+ semAcentos(computLocal), '250') then goto erro;

    exit;

erro:
    mensagem ('CTSRVNGO', 1);  {'Servidor não gostou dessa conexão, ele mandou esta mensagem'}
    textBackGround (BLACK);
    sintWriteln (respServidor);
    loginSmtp := false;
end;

{--------------------------------------------------------}

procedure fechaSmtp;
begin
    writelnRede (sockSMTP, 'QUIT');
    readlnBufRede (b_sockSMTP, respServidor, 10);
    fimBufRede(b_sockSMTP);
    fechaConexao (sockSMTP);
end;

{--------------------------------------------------------}

function enviaSMTP (arqSMTP: string): boolean;
var arq: textFile;
    aEnviar: string;
    s: string;
begin
    result := false;

    if not abreConexaoSmtp then
        begin
             mensagem ('RCERRCON', 1);  {'Erro de conexão com servidor'}
             exit;
        end;

    if not loginSmtp then
        begin
             mensagem ('RCERRLGN', 1);  {'Erro no login com o servidor'}
             exit;
        end;

    assignFile (arq, arqSMTP);
    reset(arq);
    repeat
        readln (arq, aEnviar);
        writelnRede (sockSMTP, aEnviar);
        if debug then
            writeln ('>>>', aEnviar);
        readlnBufRede (b_sockSMTP, respServidor, 10);
        if debug then
            writeln ('<<<', respServidor);
        if respServidor = '<desconectado>' then break;
    until aEnviar = 'DATA';
    
    if copy (respServidor, 1, 3) <> '354' then
        begin
             mensagem ('RCERRLGN', 1);  {'Erro no login com o servidor'}
             exit;
        end;

    s := '';
    while not eof (arq) do
        begin
            readln (arq, aEnviar);
            s := s + aEnviar + ^m^j;
            if length(s) > 800 then
                begin
                    if not writeRede (sockSMTP, s) then break;
                    s := '';
                end;
        end;

    if s <> '' then
        writeRede(sockSmtp, s);

    sendAndRec ('.', '250');
    fechaSmtp;

    closeFile(arq);
    result := true;
end;

{--------------------------------------------------------}

function enviaRecadoSMTP (nomeArqTempTexto, nomeArqTempSom, destinatario: string): boolean;
var c: char;
    nomeArqSMTP: string;
begin
    result := false;
    computLocal := 'UFRJ';

    mensagem ('RCCNFENV', 0);    {'Confirma envio? '}
    c := popupMenuPorLetra('SN');
    writeln;
    if upcase(c) <> 'S' then
        begin
            mensagem ('RCDESIST', 1);   {'Desistiu...'}
            exit;
        end;

    mensagem ('RCENVIAN', 1);   {'Enviando...'}

    nomeArqSMTP := montaMensagem (nomeArqTempTexto, nomeArqTempSom, destinatario);

    result := enviaSMTP (nomeArqSMTP);
    if not result then
        begin
            mensagem ('RCAPTENT', 1);
            readln;
        end;

    deleteFile (nomeArqTempTexto);
    deleteFile (nomeArqTempSom);

    renameFile (nomeArqSMTP, copy (nomeArqSMTP, 1, length(nomeArqSMTP)-3) + 'ENV');
end;

end.

