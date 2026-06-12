{-------------------------------------------------------------}
{
{    Webvox - Mini FTP
{
{    Autor: Jose' Antonio Borges
{
{    Em 07/01/2000
{
{-------------------------------------------------------------}

unit webftp;
interface
uses dvcrt, dvwin, dvinet, winSock, winProcs, winTypes, webMsg, webVars, Windows;

const
    FTP_OK = 0;
    FTP_ERROCRIARARQ = 1;
    FTP_NAOCONECTOU = 2;
    FTP_CONEXAOCAIU = 3;
    FTP_NAOATIVO = 4;
    FTP_ERROCONTA = 5;
    FTP_ERROSENHA = 6;
    FTP_ERROPORTADADOS = 7;
    FTP_ERROCONEXAODADOS = 8;
    FTP_CANCELADO = 9;
    FTP_ERRODISCO = 10;
    FTP_ERROFECHAMENTO = 11;
    FTP_ARQNAOEXISTE = 12;

function FTP (nomeComput, conta, senha, nomeArqRemoto, nomeArqLocal: string): integer;
procedure miniFTP (nomeComput, nomeArqRemoto: string);

var
    msgFtp: string;

implementation

const
    PORTA_FTP = 21;
    MAXBUF = 4096;
    ESC = #$1b;
    debug = true;

var sock, sockDados, sockEscuta: integer;
    arq: file;
    pbr: PBufRede;
    buffer: array[0..MAXBUF-1] of char;
    endLocal: longint;
    gravaDados: boolean;

{--------------------------------------------------------}
{                    bipa no speaker
{--------------------------------------------------------}

procedure bipSpeaker (pitch: integer);
begin
    windows.Beep (pitch, 80);
end;

{-------------------------------------------------------------}
{                  rotina de debug
{-------------------------------------------------------------}

function writelnRede (sock: integer; s: string): boolean;
begin
    if debug then
        writeln (s);
    writelnRede := dvinet.writelnRede (sock, s)
end;

{-------------------------------------------------------------}
{                    interpreta resposta do servidor
{-------------------------------------------------------------}

function esperaRespFTP: integer;
var codigo, erro: integer;
    s: string;
begin
    codigo := 0;
    esperaRespFtp := 500;

    repeat
        msgFtp := '';
        if keypressed then
            if readkey = ESC then exit;

        if temDadoBufRede (pbr) then
            begin
                if not readlnBufRede (pbr, msgFtp, 30) then exit;
                if debug then
                    writeln (msgFtp);

                if gravaDados then
                    begin
                        s := copy (msgFtp, 5, length (msgFtp)-4) + #$0d + #$0a;
                        blockWrite (arq, s[1], length (s));
                    end;

                if codigo = 0 then
                    val (copy (msgFtp, 1, pos (' ', msgFtp)-1), codigo, erro);
            end;

        if ((length(msgFtp) >= 4) and (msgFtp[4] = '-')) or
           ((msgFtp <> '') and  (msgFtp[1] = ' ')) then msgFtp := '';
    until msgFtp <> '';

    esperaRespFtp := codigo;
end;

{-------------------------------------------------------------}
{                 seleciona porta para dados
{-------------------------------------------------------------}

function selecPortaDados: boolean;
var s, s1: string;
    ntent: integer;
begin
    selecPortaDados := false;
    portaLocalFTP := 1040;

    ntent := 0;
    repeat
        ntent := ntent + 1;
        if ntent > 10 then exit;
        portaLocalFTP := portaLocalFTP + 1;
        sockEscuta := escutaConexao (portaLocalFTP);
    until sockEscuta > 0;

    s := 'PORT ';
    str (endLocal and $ff, s1);                 s := s + s1 + ',';
    str ((endLocal shr 8) and $ff, s1);         s := s + s1 + ',';
    str ((endLocal shr 16) and $ff, s1);        s := s + s1 + ',';
    str ((endLocal shr 24)and $ff, s1);         s := s + s1 + ',';
    str (portaLocalFTP shr 8, s1);              s := s + s1 + ',';
    str (portaLocalFTP and $ff, s1);            s := s + s1;

    if not writelnRede (sock, s) then exit;

    selecPortaDados := esperaRespFtp = 200;
end;

{-------------------------------------------------------------}
{              transferencia remota de arquivo
{-------------------------------------------------------------}

function FTP (nomeComput, conta, senha, nomeArqRemoto, nomeArqLocal: string): integer;
var resposta: integer;
    lidos: integer;
    total: longint;
    speakerAtivo: boolean;
    c: char;
label fechaTudo;
begin
    Ftp := FTP_CONEXAOCAIU;
    sock := -1;
    sockEscuta := -1;
    sockDados := -1;
    gravaDados := false;

    assign (arq, nomeArqLocal);
    {$I-} rewrite (arq, 1);  {$I+}
    if ioresult <> 0 then
        begin
            Ftp := FTP_ERROCRIARARQ;
            exit;
        end;

    sock := abreConexao (nomeComput, PORTA_FTP);
    if sock < 0 then
        begin
            Ftp := FTP_NAOCONECTOU;
            close (arq);
            exit;
        end;

    endLocal := enderLocal;

    pbr := inicBufRede (sock);
    resposta := esperaRespFtp;
    if resposta <> 220 then
        begin
            Ftp := FTP_NAOATIVO;
            goto fechaTudo;
        end;

    if not writelnRede (sock, 'USER ' + conta) then goto fechaTudo;
    resposta := esperaRespFtp;
    if (resposta = 530) or (resposta = 500) or (resposta = 501) or (resposta = 421) then
        begin
            Ftp := FTP_ERROCONTA;
            goto fechaTudo;
        end;

    if resposta = 331 then
        begin
            if not writelnRede (sock, 'PASS ' + senha) then goto fechaTudo;
            resposta := esperaRespFtp;
            if (resposta = 530) or (resposta = 500) or (resposta = 501) or (resposta = 421) then
                begin
                    Ftp := FTP_ERROSENHA;
                    goto fechaTudo;
                end;
        end;

    if not selecPortaDados then
        begin
            Ftp := FTP_ERROPORTADADOS;
            goto fechaTudo;
        end;

    if not writelnRede (sock, 'TYPE I') then goto fechaTudo;
    esperaRespFtp;

    if nomeArqRemoto [length (nomeArqRemoto)] = '/' then
        begin
            if not writelnRede (sock, 'CWD ' + nomeArqRemoto) then goto fechaTudo;
            gravaDados := true;
            resposta := esperaRespFtp;
            gravaDados := false;
            if resposta = 250 then
                if not writelnRede (sock, 'LIST') then goto fechaTudo;
        end
    else
            if not writelnRede (sock, 'RETR ' + nomeArqRemoto) then goto fechaTudo;
    resposta := esperaRespFtp;

    if (resposta = 550) then
        begin
            Ftp := FTP_ARQNAOEXISTE;
            goto fechaTudo;
        end;

    if (resposta <> 125) and (resposta <> 150) then
        begin
            Ftp := FTP_ERROCONEXAODADOS;
            goto fechaTudo;
        end;

    repeat
        delay (100);
        if keypressed then
             if readkey = ESC then
                 begin
                     Ftp := FTP_CANCELADO;
                     goto fechaTudo;
                 end;
    until chegouRede (sockEscuta);
    sockDados := aceitaConexao (sockEscuta);
    fechaConexao (sockEscuta);
    sockEscuta := -1;

    total := 0;
    speakerAtivo := true;

    repeat
         if keypressed then
             begin
                 c := readkey;
                 if c = ' ' then
                     speakerAtivo := not speakerAtivo
                 else
                 if c = ESC then
                     begin
                         Ftp := FTP_CANCELADO;
                         goto fechaTudo;
                     end
                 else
                     begin
                         sintWriteint (total);
                         write (#$0d);
                     end;
             end;

         lidos := -1;
         if not chegouRede (sockDados) then
              delay (200)
         else
             begin
                 lidos := recv (sockDados, buffer, MAXBUF, 0);
                 total := total + lidos;
                 if speakerAtivo then
                     bipSpeaker (200);
                 write (total, #$0d);

                 if lidos > 0 then
                     begin
                         {$I-}   blockWrite (arq, buffer, lidos);   {$I+}
                         if ioresult <> 0 then
                             begin
                                 Ftp := FTP_ERRODISCO;
                                 goto fechaTudo;
                             end;
                     end;
             end
    until lidos = 0;
    fechaConexao (sockDados);
    sockDados := -1;

    resposta := esperaRespFtp;
    if (resposta <> 226) and (resposta = 250) then
        begin
            Ftp := FTP_ERROFECHAMENTO;
            goto fechaTudo;
        end;

    if not writelnRede (sock, 'QUIT') then goto fechaTudo;
    esperaRespFtp;
    Ftp := FTP_OK;

fechaTudo:
    if sockDados <> -1 then
        fechaConexao (sockDados);
    if sockEscuta <> -1 then
        fechaConexao (sockEscuta);
    if sock <> -1 then
        fechaConexao (sock);
end;

{-------------------------------------------------------------}
{                         Mini ftp
{-------------------------------------------------------------}

procedure miniFTP (nomeComput, nomeArqRemoto: string);
var conta, senha, nomeArq: string;
    p: integer;
    status: integer;
begin
    writeln;
    textBackGround (RED);
    mensagem ('WBMINFTP', 0);   {'Mini FTP ativado'}
    textBackGround (BLACK);
    writeln; writeln;

    conta := 'anonymous';
    senha := sintAmbiente ('CARTAVOX', 'ENDERUSUARIO');

    p := pos ('@', nomeComput);
    if p <> 0 then
        begin
            conta := copy (nomeComput, 1, p-1);
            delete (nomeComput, 1, p);
            p := pos (':', conta);
            if p <> 0 then
                begin
                    senha := copy (conta, p+1, length (conta)-p);
                    delete (conta, p,length (conta)-p+1);
                end;
        end;

    if senha = '' then
        senha := 'anonymous@caec.nce.ufrj.br';

    mensagem ('WBCNTFTP', 0);   {'Contactando servidor de ftp em '}
    sintWriteln (nomeComput);
    if nomeArqRemoto [length(nomeArqRemoto)] = '/' then
        mensagem ('WBDIRFTP', 0)    {'Recebendo diretório remoto de '}
    else
        mensagem ('WBRECFTP', 0);   {'Recebendo arquivo '}
    sintWriteln (nomeArqRemoto);

    mensagem ('WBSELLOC', 1);   {'Selecionando arquivo local'}

    mensagem ('WBEDINOM', 1);   {'Editore o nome, tecle ENTER para confirmar ou ESC para cancelar: '}

    nomeArq := nomeArqRemoto;
    repeat
         p := pos ('/', nomeArq);
         if p <> 0 then delete (nomeArq, 1, p);
    until p = 0;

    sintWrite (nomeArq);
    gotoxy (1, wherey);
    if sintEdita (nomeArq, wherex, wherey, 80, true) = ESC then
                exit;
    if (nomeArq = '') or (nomeArq[1] = ' ') then exit;

    status := FTP (nomeComput, conta, senha, nomeArqRemoto, nomeArq);
    case status of
        FTP_OK:
                mensagem ('WBOK', 2);      {'Ok'}

        FTP_ERRODISCO,
        FTP_ERROCRIARARQ:
                mensagem ('WBERRGRD', 2);  {'Problemas para gravar arquivo no disco'}

        FTP_NAOCONECTOU,
        FTP_CONEXAOCAIU,
        FTP_NAOATIVO,
        FTP_ERROCONTA,
        FTP_ERROSENHA,
        FTP_ERROPORTADADOS,
        FTP_ERROCONEXAODADOS:
                begin
                    mensagem ('WBNAOCON', 1);  {'Não consegui realizar a conexao'}
                    mensagem ('WBMSGSRV', 1);  {'Mensagem do servidor'}
                    sintWriteln (msgFtp);
                    writeln;
                end;

        FTP_ERROFECHAMENTO,
        FTP_CANCELADO:
                mensagem ('WBRECINT', 2);  {'Recepção interrompida'}
    end;

end;

end.
