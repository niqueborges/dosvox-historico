{-------------------------------------------------------------}
{
{    Webvox - Módulo de correio eletrônico
{
{    Autor: Jose' Antonio Borges
{           Bernard Condorcet Porto
{           Glauco Férius Constantino
{
{    Versão original de 18/12/99
{    Versão atualizada pelo Glauco em fev/2004
{
{-------------------------------------------------------------}

unit webMail;

interface

uses dvcrt, dvWin, dvInet, dvssl, dvExec, dvForm,
     windows, sysutils, winsock,
     webVars, webMsg, webutil;

procedure transmiteCarta (enderElet, meuEnder, assunto, nomeArq: string);
procedure miniCorreio (enderElet: string);

implementation

{-------------------------------------------------------------}
{                     transmite a carta
{-------------------------------------------------------------}

procedure transmiteCarta (enderElet, meuEnder, assunto, nomeArq: string);
const
    tabMes: array [1..12] of string [3] = (
       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
var
    arq: text;
    bufEnvia1, bufRecebe1: array [0..BUFSIZE-1] of char;
    lidos: integer;
    sockSMTP: integer;
    s, hostSMTP: string;

    {-------------------------------------------------------------}

    function strg (i: integer): string;
    var s: string;
    begin
        str (i, s);
        strg := s;
    end;

    {-------------------------------------------------------------}

    function enviar (frase: string): boolean;
    var ok: boolean;
    begin
        StrPCopy (bufEnvia1, frase + CRLF);
        ok := sendBuf (sockSMTP, bufEnvia1, strlen (bufEnvia1), 0) <> 0;
        if not ok then
            strCopy (bufRecebe1, 'Conexão caiu');
        enviar := ok;
    end;

    {-------------------------------------------------------------}

    function sendAndRec (s: string; r: pchar): boolean;
    begin
        delay (500);
        if s <> '' then
            begin
                while chegouRede (sockSMTP) do
                    begin
                        lidos := receiveBuf (sockSMTP, bufRecebe, BUFSIZE, 0);
                        delay (200);
                    end;

                StrPCopy (bufEnvia1, s + CRLF);
                sendbuf (sockSMTP, bufEnvia1, strlen (bufEnvia1), 0);
                netDebug (bufEnvia1, strlen (bufEnvia1));
            end;

        lidos := receiveBuf (sockSMTP, bufRecebe1, BUFSIZE, 0);
        bufRecebe1 [lidos] := #$0;
        netDebug (bufRecebe1, lidos);

        sendAndRec := strlcomp (bufRecebe1, r, 3) = 0;
    end;

    {-------------------------------------------------------------}

    function resposta2xx: boolean;
    begin
        resposta2xx := false;
        strCopy (bufRecebe1, 'Conexão caiu');
        lidos := receiveBuf (sockSMTP, bufRecebe1, BUFSIZE, 0);
        if lidos <= 0 then
            exit;
        bufRecebe1 [lidos] := #$0;
        if debug then
            write (bufRecebe1);
        resposta2xx := bufRecebe1[0] = '2';
    end;

    {-------------------------------------------------------------}

label fim, erro, erroSemFechar;

var
    i1, i2, portaSMTP, erroConv: integer;
    n1, n2, s1: string;
    meuNome, meuEndereco: string;
    smtpComSenha: boolean;
    usandoSSL, smtpComTls: boolean;
    senhaUsuario: string;
    contaUsuario: string;
    salvaCor: word;
    Year, Month, Day, DayOfWeek: Word;
    Hour, Minute, Second, Sec100: Word;

begin
    assign (arq, nomeArq);
    {$I-} reset (arq); {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('WBCARNAO', 1);   {'Erro no disco, carta não foi enviada'}
            exit;
        end;

    mensagem ('WBENVCAR', 1);  {'Enviando a carta'}
    writeln;

    bufRecebe1 [0] := #$0;
    hostSMTP := sintAmbiente ('CARTAVOX', 'SERVIDORSMTP');
    if hostSMTP = '' then goto erro;

    val (sintAmbiente ('CARTAVOX', 'PORTASMTP'), portaSMTP, erroConv);
    if erroConv <> 0 then portaSMTP := 587;
    usandoSSL  := ansiUpperCase (copy (sintAmbiente ('CARTAVOX', 'USASSL'), 1, 1)) = 'S';
    smtpComTls := ansiUpperCase (copy (sintAmbiente ('CARTAVOX', 'SMTPCOMTLS'), 1, 1)) = 'S';

    if usandoSSL and (not smtpComTLS) then
        sockSMTP := abreConexaoSSL (hostSMTP, portaSSLSMTP)
    else
        sockSMTP := abreConexao (hostSMTP, portaSMTP);
    if sockSMTP = -1 then goto erroSemFechar;

    textColor (GREEN);

    if not sendAndRec ('', '220') then
        begin
            textColor (LIGHTGRAY);
            textBackGround (RED);
            mensagem ('WBSRVNAO', 0);  {'Servidor não aceitou conexão, diagnóstico '}
            textBackGround (BLACK);
            writeln;
            sintWriteln (strPas (bufRecebe1));
            goto erro;
        end;

    gethostname (bufRecebe1, 80);
    computLocal := strPas (bufRecebe1);
    smtpComSenha := sintAmbiente ('CARTAVOX','SMTPCOMSENHA') = 'SIM';
    if smtpComSenha then
        begin
            contaUsuario := sintAmbiente ('CARTAVOX','CONTAUSUARIO');
            senhaUsuario := decodFraseMime64 (sintAmbiente ('CARTAVOX', 'SCCV'));
            if senhaUsuario = '' then
                begin
                    sintWrite ('Password: ');
                    salvacor := textAttr;
                    textColor (black);
                    readln (senhaUsuario);
                    writeln;
                    textAttr := salvacor;
                end;

            if not sendAndRec ('EHLO ' + computLocal, '250') then goto erro;

            if smtpComTLS then
                begin
                    if not sendAndRec ('STARTTLS', '220') then goto erro;
                    if not conectaSSL (sockSMTP, hostSMTP) then
                        begin
                            strcopy (bufRecebe, '500 TLS error');
                            goto erro;
                        end;
                    if not sendAndRec ('EHLO ' + computLocal, '250') then goto erro;
                end;

            if not sendAndRec ('AUTH LOGIN', '334') then goto erro;
            if not sendAndRec (codFraseMime64 (contaUsuario), '334') then goto erro;
            if not sendAndRec(codFraseMime64 (senhaUsuario), '235') then goto erro;
        end
    else
        begin
            if not sendAndRec ('HELO '+ computLocal, '250') then goto erro;
        end;

    s := 'MAIL FROM: <' + meuEnder + '>';
    if not enviar (s) then goto erro;
    if not resposta2xx then goto erro;

    s1 := enderElet;
    i1 := pos ('<', s1);
    if i1 <> 0 then
        begin
            i2 := pos ('>', s1);
            s1 := copy (s1, i1, i2-i1+1);
        end;
    s := 'RCPT TO: <' + s1 + '>';
    if not enviar (s) then goto erro;
    if not resposta2xx then goto erro;

    s := 'DATA';
    if not enviar (s) then goto erro;
    resposta2xx;  {na verdade 3xx, mas a verificação é supérflua}

    getDate(Year, Month, Day, DayOfWeek);
    dvcrt.getTime (Hour, Minute, Second, Sec100);
    s := 'Date: ' + intToStr(Day) + ' ' + tabMes [Month] + ' ' + intToStr(Year) +
         ' ' + intToStr(Hour) + ':' + intToStr(Minute) + ':' + intToStr(Second) + ' -0300';
    enviar (s);

    meuNome := sintAmbiente ('CARTAVOX', 'NOMEUSUARIO');
    meuEndereco := sintAmbiente ('CARTAVOX', 'ENDERUSUARIO');
    n1 := meuNome;
    n2 := meuEndereco;
    meuEnder := ('"' + n1 + '"' + ' ' + '<' + n2 + '>');

    enviar ('From: ' + meuEnder);
    enviar ('To: ' + enderElet);
    enviar ('Subject: ' + assunto);
    enviar ('Reply-To: ' + meuEnder);

    if enviandoPaginaHtml then
        begin
            enviar ('MIME-Version: 1.0');
            enviar ('Content-Type: text/html');
        end;
    enviar ('');

    while not eof (arq) do
        begin
            readln (arq, s);
            if s = '.' then s := ' .';
            if not enviar (s) then break;
        end;

    if not enviar ('.') then goto erro;
    if not resposta2xx then goto erro;

    if not enviar ('QUIT') then goto erro;
    if not resposta2xx then goto erro;

    textColor (LIGHTGRAY);
    mensagem ('WBFIMENV', 1);   {'Fim do envio'}

    close (arq);
    fechaConexao (sockSMTP);
    exit;

erro:
    fechaConexao (sockSMTP);

erroSemFechar:
    close (arq);
    {$I-} erase (arq);  {$I+}
    if ioresult <> 0 then;

    textColor (LIGHTGRAY);
    while keypressed do readkey;
    mensagem ('WBERRENV', 1);  {'Erro de comunicação ao enviar a carta'}
    sintWriteln (strPas (bufRecebe1));
end;

{-------------------------------------------------------------}
{                  prepara carta e envia
{-------------------------------------------------------------}

procedure miniCorreio (enderElet: string);
var
    meuEnder, assunto, nomeEditor, nomeArq: string;
    n1, n2: string;
    meuNome, meuEndereco: string;
    tempPath, TempFileName: array [0..144] of char;
    c: char;
begin
    textBackground (BLUE);
    mensagem ('WBABREDI', 0);  {'Abrindo editor'}
    textBackground (BLACK);
    writeln;

    getTempPath (144, tempPath);
    GetTempFileName(tempPath, 'WEB', 0, TempFileName);
    nomeArq := strPas (TempFileName);

    nomeEditor := sintAmbiente ('CARTAVOX', 'EDITOR');
    if nomeEditor = '' then
         nomeEditor := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\minied.exe';

    while sintFalando do waitMessage;
    if executaProg (nomeEditor, '', nomeArq) > 32 then
        begin
            esperaProgVoltar;
            while sintFalando do waitMessage;
            sintBip;
        end
    else
        begin
            mensagem ('WBERREDI', 1);    {'Erro ao acionar o editor de textos'}
            exit;
        end;

    mensagem ('WBASSCAR', 1);  {'Qual o assunto da carta ? '}
    sintReadln (assunto);
    if assunto = '' then
         assunto := nomePagAtual;

    mensagem ('WBSEUEND', 1);  {'Seu endereço eletrônico é'}
    meuNome := sintAmbiente ('CARTAVOX', 'NOMEUSUARIO');
    meuEndereco := sintAmbiente ('CARTAVOX', 'ENDERUSUARIO');
    n1 := meuNome;
    n2 := meuEndereco;
    meuEnder := ('"' + n1 + '"' + ' ' + '<' + n2 + '>');
//    writeln (meuEndereco);
    sintWriteln (meuEnder);

    while keypressed do readkey;
    mensagem ('WBCNFENV', 0);    {'Confirma envio (s/n) ?'}
    c := popupMenuPorLetra ('SN');
    writeln;
    if c <> 'S' then exit;

    transmiteCarta (enderElet, meuEndereco, assunto, nomeArq);

    while keypressed do readkey;
end;

end.
