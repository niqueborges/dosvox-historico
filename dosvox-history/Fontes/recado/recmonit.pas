{--------------------------------------------------------}
{                                                        }
{    Programa de envio e recepção de recados             }
{                                                        }
{    Módulo de monitoração de mensagem                   }
{                                                        }
{    Autor: José Antonio Borges                          }
{                                                        }
{    Em novembro/2014                                    }
{                                                        }
{--------------------------------------------------------}

unit recmonit;

interface
uses
    dvcrt, dvwin, dvInet, dvForm, dvssl,
    recvars, recmsg, recMime64,
    windows, classes, sysutils, dateUtils;

var
    respServidor: string;

const
    NOTHING = #$0;

procedure monitorarRecados;

implementation

var
    sockPOP3: integer;
    b_sockPOP3: PbufRede;

{--------------------------------------------------------}

function sendAndRec (s: string): boolean;
begin
    if s <> NOTHING then
        begin
            writelnRede (sockPOP3, s);
            if debug then
                writeln ('>>>', s);
        end;

    readlnBufRede (b_sockPOP3, respServidor, 10);
    if debug then
        writeln ('<<<', respServidor);

    result := copy (respServidor, 1, 1) = '+';

    if not result then
        begin
            mensagem ('RCERRPOP', 1);  {'Problemas no servidor, veja mensagem:'}
            sintWriteln (s);
            sintWriteln (respServidor);
        end;
end;

{--------------------------------------------------------}

function abreConexaoPop3: boolean;
begin
    result := false;

    if pop3UsaSSL then
        sockPOP3 := abreConexaoSSL(hostPOP3, portaPOP3)
    else
        sockPOP3 := abreConexao(hostPOP3, portaPOP3);
    if sockPOP3 = -1 then exit;

    b_sockPOP3 := inicBufRede(sockPOP3);
    result :=  sendAndRec (NOTHING);
end;

{--------------------------------------------------------}

function loginPop3: boolean;
var conta: string;
begin
    result := false;

    if pos ('gmail.com', hostPOP3) <> 0 then
        conta := 'recent:'+contaUsuario
    else
        conta := contaUsuario;

    if not sendAndRec ('USER ' + conta) then exit;
    if not sendAndRec ('PASS ' + senhaUsuario) then exit;
    result := true;
end;

{--------------------------------------------------------}

procedure logoutPop3;
begin
    sendAndRec ('QUIT');
end;

{--------------------------------------------------------}

procedure buscaRecados;
var
    assunto: string;
    achou: boolean;
    s: string;
    i: integer;
    numCartasPOP3: integer;
    numBytesPOP3: integer;
    arqRecado: TextFile;
    nomeEML: string;
    n0: integer;

    function limpa (s: string): string;
    var i: integer;
    begin
         delete (s, 1, length ('Recado de '));
         for i := 1 to length(s) do
             begin
                 if s[i] = '/' then s[i] := '-'
                 else
                 if s[i] = ':' then s[i] := '.';
             end;
         result := s;
    end;

begin
    if not sendAndRec('STAT') then exit;

    s := respServidor + ' 0 0 ';   {sentinela}
    i := 1;
    while not (s[i] in ['0'..'9']) do i := i + 1;
    numCartasPOP3 := 0;
    while s[i] in ['0'..'9'] do
        begin
            numCartasPOP3 := (numCartasPOP3 * 10) + (ord(s[i]) - ord ('0'));
            i := i + 1;
        end;

    while not (s[i] in ['0'..'9']) do i := i + 1 ;
    numBytesPOP3 := 0;
    while s[i] in ['0'..'9'] do
        begin
            numBytesPOP3 := (numBytesPOP3 * 10) + (ord(s[i]) - ord ('0'));
            i := i + 1;
        end;

    writeln (numCartasPOP3);
    if numCartasPOP3 > 30 then
        n0 := numCartasPOP3 - 30
    else
        n0 := 1;
    for i := n0 to numCartasPOP3 do
        begin
            if keypressed then
                break;

            if not sendAndRec ('TOP ' + intToStr(i) + ' 0') then break;

            achou := false;
            repeat
                readlnBufRede (b_sockPOP3, respServidor, 10);
                if copy (respServidor, 1, 16) = 'X-Mailer: Recado' then
                    achou := true;
                if copy (respServidor, 1, 8) = 'Subject:' then
                    begin
                        assunto := trim(copy (respServidor, 9, 999));
                        if copy (assunto, 1, 2) = '=?' then
                             begin
                                 delete (assunto, 1, 2);
                                 delete (assunto, 1, pos('?', assunto));
                                 delete (assunto, 1, pos('?', assunto));
                                 delete (assunto, pos ('?=', assunto), 999);
                             end;
                        assunto := DecodFraseMime64(assunto);
                    end;
            until respServidor = '.';

            if achou then
                begin
                    nomeEML := limpa(assunto) + '.REC';
                    assignFile (arqRecado, dirRecados+'\' + nomeEML);

                    if sendAndRec ('RETR ' + intToStr(i)) then
                        begin
                            rewrite (arqRecado);
                            repeat
                                readlnBufRede (b_sockPOP3, respServidor, 10);
                                writeln (arqRecado, respServidor);
                            until respServidor = '.';
                            closeFile (arqRecado);

                            if not sendAndRec ('DELE ' + intToStr(i)) then break;

                            sintBip; sintBip; sintBip;
                        end;
                end;
        end;
end;

{--------------------------------------------------------}

procedure monitorarRecados;
var
    monitorando: boolean;
    t: integer;

begin
    {$i-} chdir (dirRecados);   {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('RCDIRNAO', 2);    {'Diretório de recados não está configurado ou não existe.'}
            exit;
        end;

    mensagem ('RCMONIT', 2);  {'Monitorando...'}
    monitorando := true;

    while monitorando do
        begin
            if keypressed then break;

            if not abreConexaoPop3 then
                begin
                    mensagem ('RCSRVNAO', 2);  {'Servidor de recados não está operacional'}
                    mensagem ('RCAPTENT', 1);  {'Aperte enter'}
                    readln;
                    exit;
                end;

            if not loginPop3 then
                begin
                    mensagem ('RCERRCNT', 2);  {'Erro ao fazer login na sua conta.'}
                    mensagem ('RCAPTENT', 1);  {'Aperte enter'}
                    readln;
                    exit;
                end;

            if not keypressed then
                buscaRecados;

            logoutPop3;

            t := 0;
            repeat
               delay (200);
               if keypressed then
                   monitorando := false;
               t := t + 200;
            until (not monitorando) or (t >= tempoMonitoracao);
        end;
end;

end.
