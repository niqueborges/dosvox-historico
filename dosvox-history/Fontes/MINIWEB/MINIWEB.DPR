{-------------------------------------------------------------}
{
{     Mini Servidor Web
{
{     Autor: José Antonio Borges
{
{     Em 8/4/2001
{
{-------------------------------------------------------------}

program miniWeb;

uses windows, dvcrt, dvwin, dvinet, winsock, sysUtils, dvForm, mwmsg;

const
    versao = '1.3';
    MAXSOCK = 50;
    TAM_CABEC = 4096;
    TAM_BUFFER = 4096;
    PORTA_MINIWEB = 1958;

    booleanToStr: array[boolean] of string = ( 'NAO', 'SIM' );

type
    PCLIENTE = ^TCLIENTE;
    TCLIENTE = record
        sock: integer;
        nomeArq, especial: shortString;
        arq: file;
        status: integer;
        cabecPedido: array[0..TAM_CABEC] of char;
        nc: integer;
        tipoResposta: integer;
        tamArq: longint;
        tipoMime: string[100];
        bloqueado: boolean;
    end;

var
    debug: boolean;               { em debug }
    maxClientes: integer;         { máximo de conexões deste servidor }
    dirDef: shortString;               { diretório default }
    portaDef: integer;            { porta default do servidor (80) }
    correioDef: shortString;           { estação de correio do gerenciador de web }
    emailDef: shortString;             { email do disponibilizador }
    nomeDef: shortString;              { nome do dono deste site }
    maxBufTcp: integer;           { máximo de caracteres a enviar por vez: max=TAM_BUFFER }
    descansoEntreMsg: integer;    { descanso entre mensagens para não sobrecarregar }
    nomeArqLog: shortString;           { nome do arquivo de registro }

    comSenha: boolean;            { servidor de correio usa senha }
    keepAlive: boolean;           { faz keep-alive }
    avisaParceiros: boolean;      { avisa parceiros por email }
    nomeArqParceiros: shortString;     { nome do arquivo que contém os emails }
    registraAcesso: boolean;      { registra acesso }
    listaServPresenca: shortString;    { lista de servidores de presença }

    senhaEmail: shortString;           { senha de email }
    senhaMiniweb: shortString;         { senha de miniweb }
    sockListen: integer;          { soquete para escutar }

    clientes: array [0..MAXSOCK] of PCLIENTE;
                                  { nota: o cliente 0 é usado para respostas inválidas }
    resp: array [0..TAM_BUFFER] of char;

    nclientes, clienteAtual: integer;
    nbloqueados: integer;
    processando: boolean;
    caracVivo: integer;
    ultMin: integer;
    meuIp: longint;
    computLocal: string;

const
    TIPO_NAOSEI    = 0;    { tipo da mensagem enviada ou recebida }
    TIPO_GET       = 1;
    TIPO_POST      = 2;
    TIPO_CANCELADO = 3;
    TIPO_NOFILE    = 4;
    TIPO_DIR       = 5;
    TIPO_OCUPADO   = 6;

    ESPERANDO_PEDIDO  = 0;       { estado daquele soquete }
    ENVIANDO_CABEC    = 1;
    ENVIANDO_ARQUIVO  = 2;
    INICIANDO_DIR     = 3;
    ENVIANDO_DIR      = 4;
    TERMINADO_OK      = 5;
    CANCELADO         = 9;

    PORTASMTP = 25;

const
    tabsem: array [0..6]  of string[3] = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
    tabmes: array [1..12] of string[3] = ('Jan','Feb','Mar','Apr','May','Jun',
                                          'Jul','Aug','Sep','Oct','Nov','Dec');

{-------------------------------------------------------------}
{                 traduz um número para hexa
{-------------------------------------------------------------}

function hexa (c: char): string;
const tabhexa: array [0..15] of char = (
   '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
begin
    hexa := tabHexa[ord(c) shr 4] + tabHexa[ord(c) and $f];
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
{        remove brancos ao início e fim de uma cadeia
{-------------------------------------------------------------}

procedure trim (var s: string);
begin
    while (s <> '') and (s[1] = ' ') do delete (s, 1, 1);
    while (s <> '') and (s[length(s)] = ' ') do delete (s, length (s), 1);
end;

{-------------------------------------------------------------}
{                      inicialização
{-------------------------------------------------------------}

procedure inicializa;
var
    s: string;
    erro: integer;
    jan: hwnd;
    dir: string;
begin
    dir := sintAmbiente ('MINIWEB', 'DIRMINIWEB');
    if dir = '' then
        dir := 'c:\winvox\som\miniweb';
    sintInic (0, dir);
    sintFalaPont := false;

    jan := findWindow ('dvwincrt', 'MINIWEB');    { Evita 2 miniWebs rodando }
    if jan <> 0 then
        begin
            setFocus (jan);
            halt;
        end;

    clrscr;
    setWindowText (crtWindow, 'MINIWEB');

    textBackground (BLUE);
    mensagem ('MWINIC', 0);   {'Mini servidor WEB - versão beta '}
    write (versao);
    textBackground (BLACK);
    sintSoletra (versao);
    writeln;
    writeln;

    writeln ('"Os autores deste programa advertem que servir à Internet');
    writeln ('é uma atividade de risco.  Os autores, distribuidores e a UFRJ');
    writeln ('não assumem nenhuma responsabilidade sobre qualquer perda');
    writeln ('que possa advir, direta ou indiretamente, pelo uso deste programa,');
    writeln ('mesmo que causada por falhas de programação."');
    writeln;

    while sintFalando do;

    dirDef := sintAmbiente ('MINIWEB', 'DIR');
    if dirDef = '' then
        getdir (0, dirDef);

    {$I-} chdir (dirDef);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('MWDIRNAO', 1);   {'Diretório para publicar não existe'}
            sintWriteln (dirDef);
        end;
    getDir (0, dirDef);
    if dirDef [length(dirDef)] = '\' then delete (dirDef, length(dirDef), 1);

    maxClientes := 3;
    s := sintAmbiente ('MINIWEB', 'MAXCLIENTES');
    trim (s);
    if s <> '' then
        val (s, maxClientes, erro);

    portaDef := 80;
    s := sintAmbiente ('MINIWEB', 'PORTA');
    trim (s);
    if s <> '' then
        val (s, portaDef, erro);

    nomeDef := sintAmbiente ('MINIWEB', 'NOME');
    if nomeDef = '' then
        nomeDef := 'Fulano de Tal';

    correioDef := sintAmbiente ('MINIWEB', 'CORREIO');
    if correioDef = '' then
        correioDef := 'caec.nce.ufrj.br';

    emailDef := sintAmbiente ('MINIWEB', 'EMAIL');
    if emailDef = '' then
        emailDef := 'fulano@servidor.com.br';

    s := sintAmbiente ('MINIWEB', 'SMTPCOMSENHA');
    comSenha := (s <> '') and (upcase(s[1]) = 'S');

    s := sintAmbiente ('MINIWEB', 'KEEPALIVE');
    keepAlive := (s <> '') and (upcase(s[1]) = 'S');

    s := sintAmbiente ('MINIWEB', 'AVISAPARCEIROS');
    avisaParceiros := (s <> '') and (upcase(s[1]) = 'S');

    nomeArqParceiros := sintAmbiente ('MINIWEB', 'ARQPARCEIROS');
    if nomeArqParceiros = '' then
        nomeArqParceiros := 'c:\winvox\parceiro.amb';

    listaServPresenca := sintAmbiente ('MINIWEB', 'SERVPRESENCA');
    if listaServPresenca = '' then
        listaServPresenca := 'intervox.nce.ufrj.br';

    s := sintAmbiente ('MINIWEB', 'REGISTRAACESSO');
    registraAcesso := (s <> '') and (upcase(s[1]) = 'S');

    nomeArqLog := sintAmbiente ('MINIWEB', 'ARQLOG');
    if nomeArqLog = '' then
        nomeArqLog := 'c:\miniweb.log';

    maxBufTcp := 4096{512};
    s := sintAmbiente ('MINIWEB', 'MAXBUFTCP');
    trim (s);
    if s <> '' then
        val (s, maxBufTCP, erro);

    descansoEntreMsg := 100;
    s := sintAmbiente ('MINIWEB', 'DESCANSOENTREMSG');
    trim (s);
    if s <> '' then
        val (s, descansoEntreMsg, erro);

    nclientes := 0;
    clienteAtual := 0;
    caracVivo := 0;
    nbloqueados := 0;
    ultMin := 99;
end;

{-------------------------------------------------------------}
{                       configuração
{-------------------------------------------------------------}

procedure configura;
var
    c, c2: char;
begin
    if nomeDef = 'Fulano de Tal' then
        mensagem ('MWPFCONF', 1)   {'Por favor configure este servidor.'}
    else
        if (paramStr(1) = '-C') or (paramStr(1) = '-c') then
            exit
        else
            begin
                mensagem ('MWDESCNF', 0);   {'Deseja configurar o servidor ? '}
                sintLeTecla (c, c2);
                writeln;
                if (upcase (c) = 'N') or (c = #$0d) then
                    exit
                else
                    mensagem ('MWCNFSER', 2);   {'Configurando'}
            end;

    clrscr;
    writeln ('MINIWEB');
    mensagem ('MWPREFOR', 2);   {'Preencha o formulário de configuração.  Ao final tecle ESC.'}
    while keypressed do readkey;

    formCria;
    formCampo     ('MWINFDI2', 'Diretório a publicar', dirDef, 80);
    formCampoInt  ('MWINFNC2', 'Número máximo de clientes', maxClientes);
    formCampoInt  ('MWINFPO2', 'Porta (sugiro 80)', portaDef);
    formCampo     ('MWINFNO2', 'Seu nome', nomeDef, 80);
    formCampo     ('MWINFEM2', 'Sua conta de email', emailDef, 80);
    formCampo     ('MWINFCO2', 'Servidor de correio', correioDef, 80);
    formCampoBool ('MWUSASE2', 'Correio usa senha?', comSenha);
    formCampoBool ('MWDESAV2', 'Usa servidor de presença? ', keepAlive);
    formCampo     ('MWSERVP2', 'Nome do servidor', listaservpresenca, 256);
    formCampoBool ('MWAVICO2', 'Envia e-mails ao ativar? ', avisaParceiros);
    formCampo     ('MWARQAV2', 'Arquivo com os e-mails', nomeArqParceiros, 80);
    formCampoBool ('MWDESRE2', 'Registra os acessos? ', registraAcesso);
    formCampo     ('MWINFLO2', 'Nome do arquivo de registro', nomeArqLog, 80);
    formEdita (true);

    sintGravaAmbiente ('MINIWEB', 'DIR',              dirDef);
    sintGravaAmbiente ('MINIWEB', 'MAXCLIENTES',      intToStr (maxClientes));
    sintGravaAmbiente ('MINIWEB', 'PORTA',            intToStr(portaDef));
    sintGravaAmbiente ('MINIWEB', 'NOME',             nomeDef);
    sintGravaAmbiente ('MINIWEB', 'CORREIO',          intToStr(maxClientes));
    sintGravaAmbiente ('MINIWEB', 'EMAIL',            emailDef);
    sintGravaAmbiente ('MINIWEB', 'SMTPCOMSENHA',     booleanToStr[comSenha]);
    sintGravaAmbiente ('MINIWEB', 'KEEPALIVE',        booleanToStr[keepAlive]);
    sintGravaAmbiente ('MINIWEB', 'REGISTRAACESSO',   booleanToStr[registraAcesso]);
    sintGravaAmbiente ('MINIWEB', 'AVISAPARCEIROS',   booleanToStr[avisaParceiros]);
    sintGravaAmbiente ('MINIWEB', 'ARQPARCEIROS',     nomeArqParceiros);
    sintGravaAmbiente ('MINIWEB', 'SERVPRESENCA',     listaServPresenca);
    sintGravaAmbiente ('MINIWEB', 'REGISTRAACESSO',   booleanToStr[registraAcesso]);
    sintGravaAmbiente ('MINIWEB', 'ARQLOG',           nomeArqLog);

    sintGravaAmbiente ('MINIWEB', 'MAXBUFTCP',        intToStr(maxBufTcp));
    sintGravaAmbiente ('MINIWEB', 'DESCANSOENTREMSG', intToStr(descansoEntreMsg));


    while keypressed do readkey;
    textBackground (BLUE);
    mensagem ('MWFIMCNF', 0);   {'Fim da configuração'}
    textBackground (BLACK);
    writeln;
    writeln;

    {$I-} chdir (dirDef);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('MWDIRNAO', 1);   {'Diretório para publicar não existe'}
            sintFalaPont := true;
            sintWriteln (dirDef);
            sintFalaPont := false;
            mensagem ('MWPRGCAN', 1);   {'Programa cancelado'}
            delay (2000);
            sintFim;
            doneWinCrt;
        end;
end;

{-------------------------------------------------------------}
{                     Pede senha
{-------------------------------------------------------------}

procedure pedeSenha;
var salva: word;
begin
    if (paramStr(1) = '-C') or (paramStr(1) = '-c') then exit;

    if keepAlive then
        repeat
            mensagem ('MWINFSMW', 1);   {'Informe a senha Miniweb para sua segurança'}
            salva := textAttr;
            textColor (BLACK);
            readln (senhaMiniweb);
            textAttr := salva;
        until (senhaMiniweb <> '') and (pos (' ', senhaMiniweb) = 0);
end;

{-------------------------------------------------------------}
{                     inicializa rede
{-------------------------------------------------------------}

procedure inicEscuta;
begin
    sockListen := escutaConexao (portaDef);
end;

{-------------------------------------------------------------}
{                    finaliza servidor
{-------------------------------------------------------------}

procedure finaliza;
begin
    fechaConexao (sockListen);
    fechaWinSock;

    mensagem ('MWFIMSRV', 1);   {'Fim do servidor Miniweb'}
    sintFim;
    delay (2000);
    doneWinCrt;
end;

{-------------------------------------------------------------}
{                  informa meu endereço IP
{-------------------------------------------------------------}

procedure informaMeuIp;
var
    HEnt: pHostEnt;
    HName: array [0..100] of char;
    IPAddr: string;
    i: integer;
begin
    if GetHostName(HName, SizeOf(HName)) = 0 then
        begin
            HEnt := GetHostByName(HName);
            for i := 0 to HEnt^.h_length - 1 do
                 IPaddr := Concat(IPaddr, IntToStr(Ord(HEnt^.h_addr_list^[i])) + '.');
            delete (IPaddr, Length(IPaddr), 1);

            mensagem ('MWENDIP', 0);  {'Meu endereço IP é '}
            sintWrite (IPaddr);
          end
      else
          sintWrite ('127.0.0.1');

      mensagem ('MWPORTA', 0);   {' porta '}
      sintWriteint (portaDef);
      writeln;
end;

{-------------------------------------------------------------}
{                processamento de teclado
{-------------------------------------------------------------}

procedure processaTeclado;
var
    i: integer;
    salva: word;
    c, c2: char;
label teclou;
begin
    if not keypressed then exit;

    case upcase (readkey) of
        #$0: case readkey of
                 F1:  begin
                          mensagem ('MWF1', 1);   {'As opções do programa são'}
                          mensagem ('MWF4', 1);   {'F4 para configurar'}
                          mensagem ('MWF5', 1);   {'F5 para saber quantas conexões ativas'}
                          mensagem ('MWF6', 1);   {'F6 para saber endereço IP'}
                          mensagem ('MWESC', 1);  {'ESC para sair'}
                      end;

                 F4:  begin
                          salva := textAttr;
                          textBackground (RED);
                          mensagem ('MWPARALI', 0);   {'Servidor foi paralisado para reconfigurar'}
                          textAttr := salva;
                          writeln; writeln;
                          configura;
                          pedeSenha;
                      end;

                 F5:  begin
                         salva := textAttr;
                         textColor (YELLOW);
                         mensagem ('MWNCLI', 0);   {'Número de clientes ativos: '}
                         sintWriteint (nclientes);
                         textColor (salva);
                         writeln;
                         for i := 1 to nclientes do
                             writeln (clientes[i]^.nomearq);
                      end;

                 F6:  informaMeuIP;
             end;

        ESC: begin
                 if nclientes <> 0 then
                     begin
                         mensagem ('MWNCLI', 0);   {'Número de clientes ativos: '}
                         sintWriteint (nclientes);
                         writeln;
                     end;

                 mensagem ('MWCNFFIM', 0);    {'Confirma fim? }
                 for i := 1 to 50 do
                     begin
                         if keypressed then goto teclou;
                         delay (100);
                     end;
                 writeln;
                 exit;

             teclou:
                 sintLeTecla (c, c2);
                 writeln;
                 if upcase(c) = 'S' then processando := false;
             end;
    end;
end;

{-------------------------------------------------------------}
{                     descobre Mime Type
{-------------------------------------------------------------}

function descobreMimeType (nomeArq: string): string;
var p: integer;
    tipo: string;
begin
    descobreMimeType := 'application/image';

    p := length (nomeArq);
    while (p > 0) and (nomeArq[p] <> '.') do
        p := p - 1;
    if p = 0 then
        exit;

    tipo := maiuscAnsi (copy (nomeArq, p+1, 999));

    if (tipo = 'HTM') or (tipo = 'HTML') then descobreMimeType := 'text/html'
    else
    if (tipo = 'MID') or (tipo = 'MIDI') then descobreMimeType := 'audio/midi'
    else
    if tipo = 'MPG' then descobreMimeType := 'video/mpeg'
    else
    if tipo = 'TXT' then descobreMimeType := 'text/plain'
    else
    if tipo = 'CAR' then descobreMimeType := 'text/plain'
    else
    if tipo = 'WAV' then descobreMimeType := 'audio/basic'
    else
    if tipo = 'MP3' then descobreMimeType := 'audio/mpeg'
    else
    if tipo = 'RM'  then descobreMimeType := 'application/streamingmedia'
    else
    if tipo = 'RAM' then descobreMimeType := 'application/streamingmedia'
    else
    if tipo = 'GIF' then descobreMimeType := 'image/gif'
    else
    if tipo = 'BMP' then descobreMimeType := 'image/bitmap'
    else
    if tipo = 'JPG' then descobreMimeType := 'image/jpeg'
    else
    if tipo = 'PNG' then descobreMimeType := 'image/png'
    else
    if tipo = 'MPG' then descobreMimeType := 'video/mpeg'
end;

{-------------------------------------------------------------}
{               envia cabeçalho do texto HTTP
{-------------------------------------------------------------}

procedure enviaCabecalhoHTTP (qualCliente: integer);
var
    bufTxt: array [0..TAM_BUFFER] of char;
    data: string;
    ano, mes, dia, semana, hora, min, seg, cent: word;
    pch: array [0..1024] of char;

begin
    keypressed;   { prestigia o scheduler do Windows }

    if qualCliente > nclientes then
        begin
            erroBrutal ('enviaCabecalhoHTTP');
            exit;
        end;

    bufTxt [0] := #$0;

    dvcrt.getDate (ano, mes, dia, semana);
    dvcrt.getTime (hora, min, seg, cent);
    data := 'Date: ' + tabsem[semana] + ', ' +
                       int2 (dia) + ' ' + tabmes[mes] + ' ' + int2str (ano) + ' ' +
                       int2 (hora) + ':' + int2 (min) + ':' + int2 (seg) + ' GMT' + #$0;

    with clientes [qualCliente]^ do
        case tipoResposta of
            TIPO_OCUPADO:
                begin
                    strCat (bufTxt, 'HTTP/1.0 200 Server overload' + CRLF);
                    strCat (bufTxt, @data[1]);
                    strCat (bufTxt, CRLF);
                    strCat (bufTxt, SERVER_NAME + CRLF);
                    strCat (bufTxt, 'Content-Type: text/html' + CRLF);
                    strCat (bufTxt, CRLF);
                    send (sock, bufTxt, strlen (bufTxt), 0);
                end;

            TIPO_POST,
            TIPO_GET:
                begin
                    strCat (bufTxt, 'HTTP/1.0 200 Arquivo vai ser enviado' + CRLF);
                    strCat (bufTxt, @data[1]);
                    strCat (bufTxt, CRLF);
                    strCat (bufTxt, SERVER_NAME + CRLF);
                    strCat (bufTxt, 'Content-Type: ');
                                     strPCopy (pch, tipoMime + CRLF);
                                     strCat (bufTxt,  pch);
                    strCat (bufTxt, 'Accept-ranges: bytes' + CRLF);
                    strCat (bufTxt, 'Content-Length: ');
                                     strPCopy (pch, int2Str(tamArq)+ CRLF);
                                     strCat (bufTxt,  pch);
                    strCat (bufTxt, CRLF);
                    send (sock, bufTxt, strlen (bufTxt), 0);
                end;

            TIPO_NOFILE:
                begin
                    strCat (bufTxt, 'HTTP/1.0 404 Arquivo não achado neste servidor' + CRLF);
                    strCat (bufTxt, @data[1]);
                    strCat (bufTxt, CRLF);
                    strCat (bufTxt, SERVER_NAME + CRLF);
                    strCat (bufTxt, 'Content-Type: text/html' + CRLF);
                    strCat (bufTxt, CRLF);
                    send (sock, bufTxt, strlen (bufTxt), 0);
                end;

            TIPO_DIR:
                begin
                    strCat (bufTxt, 'HTTP/1.0 200 Diretório se segue' + CRLF);
                    strCat (bufTxt, @data[1]);
                    strCat (bufTxt, CRLF);
                    strCat (bufTxt, SERVER_NAME + CRLF);
                    strCat (bufTxt, 'Content-Type: text/html' + CRLF);
                    strCat (bufTxt, CRLF);
                    send (sock, bufTxt, strlen (bufTxt), 0);
                end;
        end;
end;

{-------------------------------------------------------------}
{                   envia uma mensagem
{-------------------------------------------------------------}

procedure enviaMensagemHTTP (sock: integer; msg: string);
var bufTxt: array [0..TAM_BUFFER] of char;
begin
    keypressed;   { prestigia o scheduler do Windows }

    strPCopy (bufTxt, msg);
    send (sock, bufTxt, length (msg), 0);
end;

{-------------------------------------------------------------}
{               converte cadeia para o formato uri
{-------------------------------------------------------------}

function convURI (s: string): string;
var s2: string;
    i: integer;
    d1, d2: integer;
const hexa: array[0..15] of char = ('0','1','2','3','4','5','6','7','8','9',
                                    'a','b','c','d','e','f');
begin
    s2 := '';
    for i := 1 to length (s) do
        begin
            if s[i] in ['0'..'9', 'A'..'Z', '.', 'a'..'z', '/', '\'] then
                s2 := s2 + s[i]
            else
                begin
                    d1 := ord (s[i]) shr 4 and $f;
                    d2 := ord (s[i]) and $f;
                    s2 := s2 + '%' + hexa[d1] + hexa[d2];
                end;
        end;
    convURI := s2;
end;

{-------------------------------------------------------------}
{               converte cadeia para o formato uri
{-------------------------------------------------------------}

function desconvURI (s: string): string;
var s2: string;
    i: integer;
    c1, c2: integer;
begin
    s2 := '';
    i := 1;
    while i <= length(s) do
        begin
            if s[i] <> '%' then
                s2 := s2 + s[i]
            else
                begin
                   i := i + 1;
                   c1 := ord (upcase(s[i])) - ord('0');
                   if c1 > 10 then c1 := c1 - 7;
                   i := i + 1;
                   c2 := ord (upcase(s[i])) - ord('0');
                   if c2 > 10 then c2 := c2 - 7;
                   s2 := s2 + chr (c1 shl 4 or c2);
                end;
            i := i + 1;
        end;
    desconvURI := s2;
end;

{-------------------------------------------------------------}
{                   processa novas conexoes
{-------------------------------------------------------------}

procedure processaNovasConexoes;
var bufTxt: array [0..TAM_BUFFER] of char;
begin
    if not chegouRede (sockListen) then
        exit;

    if nclientes >= maxClientes then
        begin
            new (clientes [0]);
            with clientes[0]^ do
                begin
                    sock := aceitaConexao (sockListen);
                    if sock >= 0 then
                        begin
                            if chegouRede (sock) then
                                recv (sock, buftxt, TAM_BUFFER, 0);
                            tipoResposta := TIPO_OCUPADO;
                            enviaCabecalhoHTTP (0);
                            enviaMensagemHTTP (sock, MSG_OCUPADO + CRLF);
                            delay (100);
                            fechaConexao (sock);
                        end;
                end;
            dispose (clientes [0]);
            exit;
        end;

    nclientes := nclientes + 1;
    new (clientes [nclientes]);
    with clientes [nclientes]^ do
        begin
            sock := aceitaConexao (sockListen);
            status := ESPERANDO_PEDIDO;
            nc := 0;
            tipoResposta := TIPO_NAOSEI;
            bloqueado := false;
        end;
end;

{-------------------------------------------------------------}
{                     remove cliente
{-------------------------------------------------------------}

procedure removeCliente (qualCliente: integer);
var i: integer;
begin
    if (qualCliente < 1) or (qualCliente > nclientes) then
        begin
            erroBrutal ('removeCliente');
            exit;
        end;

    dispose (clientes [qualCliente]);

    for i := qualCliente to nClientes-1 do
        clientes[i] := clientes[i+1];

    nclientes := nclientes - 1;
end;

{-------------------------------------------------------------}
{            acumula o cabeçalho chegado até 2 crlf
{-------------------------------------------------------------}

function acumulaCabec (qualCliente: integer): boolean;
var maxLer, lidos: integer;
    p: pointer;
    i: integer;
begin
    acumulaCabec := false;

    if (qualCliente < 1) or (qualCliente > nclientes) then
        begin
            erroBrutal ('acumulaCabec');
            exit;
        end;

    with clientes[qualCliente]^ do
        begin
            if chegouRede (sock) then
                begin
                    maxLer := TAM_CABEC - nc - 1;
                    p := @cabecPedido[nc];
                    lidos := recv (sock, p^, maxLer, 0);

                    if debug then
                        for i := 0 to lidos-1 do
                            write (cabecPedido[nc+i]);

                    nc := nc + lidos;
                    if lidos = 0 then
                        begin
                            strPCopy (cabecPedido, #$0d + #$0a + #$0d + #$0a);
                            nc := 4;
                            tipoResposta := TIPO_CANCELADO;
                        end;
                end;

            if (nc >= 4) and
               (cabecPedido[nc-4] = #$0d) and (cabecPedido[nc-3] = #$0a) and
               (cabecPedido[nc-2] = #$0d) and (cabecPedido[nc-1] = #$0a) then
                   acumulaCabec := true;
        end;
end;

{-------------------------------------------------------------}
{            mostra o pedido feito pelo usuário
{-------------------------------------------------------------}

procedure mostraPedido (qualCliente: integer);
var
    localAddr: sockaddr_in;
    tam: integer;
    s, saida: string;
    Year, Month, Day, DayOfWeek, Hour, Minute, Second, Sec100: word;
    arqLog: text;
begin
    if (qualCliente < 1) or (qualCliente > nclientes) then
        begin
            erroBrutal ('mostraPedido');
            exit;
        end;

    tam := sizeof (localAddr);
    with clientes[qualCliente]^ do
        getPeerName (sock, localAddr, tam);
    s := strPas (inet_ntoa (in_addr(localAddr.sin_addr.s_addr)));

    repeat
        s := s + ' ';
    until length (s) >= 12;
    with clientes[qualCliente]^ do
        begin
            dvcrt.getDate(Year, Month, Day, DayOfWeek);
            dvcrt.getTime (Hour, Minute, Second, Sec100);

            saida := int2Str(Day) + '/' + int2Str(Month) + '/' + int2Str (Year) +
                     ' ' + int2(Hour) + ':' + int2(Minute) + ':' + int2(Second) +
                     ' ' + s + ' ' + nomearq;
            if especial <> '' then
                saida := saida + '?' + especial;

            writeln (desconvUri (saida));

            if nomeArqLog <> '' then
                begin
                    assign (arqLog, nomeArqLog);
                    {$I-} append (arqLog);  {$I+}
                    if ioresult <> 0 then
                        begin
                            {$I-} rewrite (arqLog);  {$I+}
                            if ioresult <> 0 then
                                begin
                                    mensagem ('MWERRLOG', 1);  {'Erro ao gerar arquivo de registro'}
                                    nomeArqLog := '';
                                    exit;
                                end;
                        end;

                    {$I-}  writeln (arqlog, desconvUri (saida));  {$I+}
                    if ioresult <> 0 then
                        begin
                            mensagem ('MWERRLOG', 1);  {'Erro ao gerar arquivo de registro'}
                            nomeArqLog := '';
                        end;

                    close (arqLog);
                end;
        end;
end;

{-------------------------------------------------------------}
{          interpreta o pedido HTTP (simplificado)
{-------------------------------------------------------------}

procedure interpretaPedido (qualCliente: integer);
var
    cmd, uri: string;
    p: pchar;
    n: integer;
    arqTeste: file of byte;
    salvaDir: string;

    {-------------------------------------------------------------}

    procedure separaComandoUri;
    var i: integer;
    begin
        cmd := '';
        uri := '';

        with clientes[qualCliente]^ do
            begin
                p := cabecPedido;
                cmd := '';
                while (p^ <> ' ') and (p^ <> #$0a) do
                    begin
                        cmd := cmd + p^;
                        p := p + 1;
                    end;

                while p^ = ' ' do p := p + 1;

                uri := '';
                while (p^ <> ' ') and (p^ <> #$0a) do
                    begin
                        uri := uri + p^;
                        p := p + 1;
                    end;

                n := pos ('?', uri);
                if n = 0 then n := length (uri) + 1;

                nomeArq  := copy (uri, 1, n-1);
                especial := copy (uri, n+1, 999);

                if pos ('..', nomeArq) <> 0 then   { evita fraudes }
                     uri := '/';

                for i := 1 to length (nomeArq) do
                    if nomeArq[i] = '/' then
                        nomeArq[i] := '\';
            end;

    end;

    {-------------------------------------------------------------}

begin
    if (qualCliente < 1) or (qualCliente > nclientes) then
        begin
            erroBrutal ('interpretaPedido');
            exit;
        end;

    separaComandoUri;
    mostraPedido (qualCliente);

    with clientes[qualCliente]^ do
        begin
            if cmd = '' then
                tipoResposta := TIPO_CANCELADO
            else
            if (cmd = 'GET') or (cmd = 'POST') then
                begin
                    getDir (0, salvaDir);
                    tipoResposta := TIPO_GET;
                    if cmd = 'POST' then
                        tipoResposta := TIPO_POST;

                    {$I-} chdir (desconvUri (salvaDir + nomeArq)); {$I+}
                    if ioresult = 0 then
                        begin
                            nomeArq := salvaDir + nomeArq;
                            chdir (salvaDir);
                            tipoResposta := TIPO_DIR;
                        end
                    else
                        begin
                            assign (arqTeste, desconvUri(salvaDir + nomeArq));
                            {$I-} reset (arqTeste); {$I+}
                            if ioresult <> 0 then
                                tipoResposta := TIPO_NOFILE
                            else
                                begin
                                    tamArq := filesize (arqTeste);
                                    close (arqTeste);
                                    tipoMime := descobreMimeType (nomeArq);
                                end;
                        end;
                end

            else
                tipoResposta := TIPO_NAOSEI;
        end;
end;

{-------------------------------------------------------------}
{               ve se chegou dado ou conexao
{-------------------------------------------------------------}

function redeLivre (sock: integer): boolean;
var
    saidas: TFDSET;
    tempoZero: timeVal;
begin
    with tempoZero do
        begin
            tv_sec := 0;
            tv_usec := 0;
        end;

    FD_ZERO (saidas);         { monitora soquete }
    FD_SET (sock, saidas);
    select (sock+1, NIL, @saidas, NIL, @tempoZero);

    keypressed;
    redeLivre := FD_ISSET (sock, saidas);
end;

{-------------------------------------------------------------}
{               processa envio para uma conexao
{-------------------------------------------------------------}

procedure processaEnvio;
type
    PListaDir = ^TListaDir;
    PSearchRec = ^TSearchRec;
    TListaDir = array [1..5000] of PSearchRec;

var
    bufTCP: array [0..TAM_BUFFER] of char;
    bufTrab: array [0..255] of char;
    lidos, escritos, falta: integer;
    i, n: integer;
    s, salvadir: string;
    DirInfo: TSearchRec;
    listaArq: PListaDir;
    l, l2, nlista: integer;
    templ: PSearchRec;
    posarq: longint;
    atransm, ptransm: integer;
    dosError: integer;
    pt: pointer;
    strData: string;

label prox, erroComunic;

    procedure cat (p: pchar; s: string);
    var p2: array [0..256] of char;
    begin
        strPCopy (p2, s);
        strCat (p, p2);
    end;

begin
    keypressed;    { prestigia o scheduler do Windows }

    if nClientes = 0 then
        exit;

    clienteAtual := clienteAtual + 1;
    if clienteAtual > nClientes then
        clienteAtual := 1;

    with clientes [clienteAtual]^ do
        case status of
            ESPERANDO_PEDIDO:
                if chegouRede (sock) then
                    if acumulaCabec (clienteAtual) then
                        status := ENVIANDO_CABEC;

            ENVIANDO_CABEC:
                begin
                    if tipoResposta <> TIPO_CANCELADO then
                        begin
                            interpretaPedido (clienteAtual);
                            enviaCabecalhoHTTP (clienteAtual);
                        end;

                    case tipoResposta of
                        TIPO_GET,
                        TIPO_POST:       begin
                                             status := ENVIANDO_ARQUIVO;
                                             assign (arq, dirDef+desconvUri(nomeArq));
                                             {$I-} reset (arq, 1);  {$I+}
                                             if ioresult <> 0 then
                                                 status := CANCELADO;
                                         end;

                        TIPO_DIR:        status := INICIANDO_DIR;

                    else
                        status := CANCELADO;
                    end;
                end;

            ENVIANDO_ARQUIVO:
                if (nclientes > 1) and (not redeLivre (sock)) then
                    begin
                        if not bloqueado then
                            begin
                                nbloqueados := nbloqueados + 1;
                                bloqueado := true;
                            end;
                    end
                else
                    begin
                        if bloqueado then
                            begin
                                bloqueado := false;
                                nbloqueados := nbloqueados - 1;
                            end;

                        if eof (arq) then
                            begin
                                close (arq);
                                status := TERMINADO_OK;
                            end
                        else
                            begin
                                blockread (arq, bufTCP, maxBufTcp, lidos);
                                falta := lidos;

                                escritos := send (sock, bufTCP, lidos, 0);
                                if escritos <= 0 then
                                    begin
                                        status := CANCELADO;
                                        close (arq);
                                        exit;
                                    end;

                                falta := falta - escritos;
                                if falta <> 0 then
                                    begin
                                        posarq := filepos (arq);
                                        seek (arq, posarq + escritos);
                                    end;
                            end;
                    end;

            INICIANDO_DIR:
                begin
                    bufTcp [0] := #0;
                    cat (bufTcp, '<html><head><title>' + MSG_LISTDIR + '</title></head>' + CRLF);
                    s := nomeArq;
                    delete (s, 1, length (dirDef));

                    cat (bufTcp, '<h3>' + MSG_LISTDIR + ' ' + desconvUri(s) + '</h3>' + CRLF);
                    cat (bufTcp, '<PRE>'+ CRLF);
                    escritos := send (sock, bufTcp, strlen (bufTcp), 0);
                    if escritos > 0 then
                        status := ENVIANDO_DIR
                    else
                        status := CANCELADO;
                end;

            ENVIANDO_DIR:
                begin
                    bufTcp [0] := #0;
                    getdir (0, salvaDir);
                    if pos ('..', nomeArq) <> 0 then nomeArq := '@@@@@@@';
                    {$I-} chdir (desconvUri (nomeArq));  {$I-}
                    if ioresult <> 0 then
                        begin
                            status := TERMINADO_OK;
                            exit;
                        end;

                    nLista := 0;
                    new (listaArq);
                    DosError := FindFirst('*.*', FaAnyFile, DirInfo); { Same as DIR *.PAS }
                    while DosError = 0 do
                        begin
                            s := DirInfo.FindData.cFileName;
                            if s = '.' then goto prox;
                            if s = '..' then goto prox;
                            if nLista < 5000 then
                                begin
                                    nLista := nLista + 1;
                                    new (listaArq^[nlista]);
                                    listaArq^[nlista]^ := dirInfo;
                                end;
                        prox:
                            DosError := FindNext(DirInfo);
                        end;

                    for l := 1 to nlista-1 do
                        for l2 := l+1 to nlista do
                            if listaArq^[l]^.name > listaArq^[l2]^.name then
                                begin
                                    templ := listaArq^[l];
                                    listaArq^[l] := listaArq^[l2];
                                    listaArq^[l2] := templ;
                                end;

                    for l := 1 to nlista do
                        begin
                            dirInfo := listaArq^[l]^;
                            s := DirInfo.FindData.cFileName;
                            dispose (listaArq^[l]);
                            listaArq^[l] := NIL;

                            bufTrab [0] := #$0;

                            if (dirInfo.attr and faDirectory) = faDirectory then
                                s := s + '/';
                            cat (bufTrab, '<a href="' + convUri(s) + '">');
                            cat (bufTrab, s);
                            cat (bufTrab, '</a>');

                            n := 25-length (s);
                            s := '';
                            for i := 1 to n do s := s + ' ';
                            cat (bufTrab, s+' ');

                            if (dirInfo.attr and faDirectory) = faDirectory then
                                cat (bufTrab, '  (dir)')
                            else
                                begin
                                    s := int2Str (DirInfo.Size);
                                    while length(s) < 15 do s := ' ' + s;
                                    cat (bufTrab, s + ' em ');
                                    strData := dateTimeToStr (fileDateToDateTime(dirInfo.time));
                                    if strData[2] = '/' then strData := '0' + strData;
                                    if strData[5] = '/' then insert ('0', strData, 4);
                                    cat (bufTrab, strData);
                                end;

                            cat (bufTrab, CRLF);

                            if strLen (bufTrab) + strLen (bufTcp) >= TAM_BUFFER then
                                begin
                                    atransm := strlen (bufTcp);
                                    ptransm := 0;
                                    while atransm <> 0 do
                                        begin
                                            pt := @bufTcp[ptransm];
                                            escritos := send (sock, pt^, atransm, 0);
                                            if escritos  <= 0 then
                                                begin
                                                    goto erroComunic;
                                                end;
                                            atransm := atransm - escritos;
                                            ptransm := ptransm + escritos;
                                        end;

                                    bufTcp[0] := #0;
                                end;

                            strCat (bufTcp, bufTrab);
                        end;

                    {$I-} chdir (salvaDir);  {$I+}
                    if ioresult <> 0 then;

                    status := TERMINADO_OK;

                    atransm := strlen (bufTcp);
                    if atransm <> 0 then
                        begin
                            ptransm := 0;
                            while atransm <> 0 do
                                begin
                                    pt := @bufTcp[ptransm];
                                    escritos := send (sock, pt^, atransm, 0);
                                    if escritos  <= 0 then
                                        goto erroComunic;
                                    atransm := atransm - escritos;
                                    ptransm := ptransm + escritos;
                                end;
                        end;
                    exit;

erroComunic:
                                status := CANCELADO;
                                {$I-} chdir (salvaDir);  {$I+}
                                if ioresult <> 0 then;
                                for l := 1 to nlista do
                                    if listaArq^[l] <> NIL then
                                        dispose (listaArq^[l]);
                                dispose (listaArq);
                                exit;

                end;

            TERMINADO_OK, CANCELADO:
                begin
                    delay (100);
                    fechaConexao (sock);
                    removeCliente (clienteAtual);
                end;
        end;
end;

{-------------------------------------------------------------}
{                        avisa presença
{-------------------------------------------------------------}

procedure avisaServPresenca (ativo: boolean);
var
    sock: integer;
    ipDestino: longint;
    nome, nomes, s: string;
    p: integer;
    buf: array [0..255] of char;

begin
    if not keepAlive then exit;

    sock := abreConexaoUDP;
    if sock < 0 then
        begin
            mensagem ('MWERRUDP', 1);  {'Erro ao informar dados ao servidor de presença'}
            exit;
        end;

    nomes := listaServPresenca;
    while nomes <> '' do
        begin
            trim (nomes);
            p := pos (',', nomes);
            if p = 0 then
               p := length (nomes) + 1;
            nome := copy (nomes, 1, p-1);
            trim (nome);
            delete (nomes, 1, p);

            ipDestino := nomeParaIp (nome);
            if ativo then s := 'MINIWEB '
                     else s := 'MINIEND ';

            strPCopy (buf, s + strPas (inet_ntoa (in_addr(meuIp))) +
                   ' ' + int2str (portaDef) + ' ' + senhaMiniweb + ' ' + nomeDef);
            enviaUDP (sock,  buf, strlen (buf), ipDestino, PORTA_MINIWEB);
        end;

    fechaConexao (sock);
end;

{-------------------------------------------------------------}
{                 faz um desenhinho na tela
{-------------------------------------------------------------}

procedure mostraQueEstaVivo;
const
    tabVivo: array [0..3] of char = ('-', '\', '|', '/');
var
    hora, min, seg, seg100: Word;
begin
    caracVivo := (caracVivo + 1) mod 4;
    write (tabVivo [caracVivo], ' ', nclientes:3);
    gotoxy (1, wherey);
    keypressed;

    dvcrt.getTime (hora, min, seg, seg100);
    if min <> ultMin then
        begin
            ultMin := min;
            avisaServPresenca (true);
        end;
end;

{-------------------------------------------------------------}
{                  codifica uma frase em mime64
{-------------------------------------------------------------}

const
    MIME64: array [0..63] of char =
       'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

function codFraseMime64 (bloco: string): string;
var
   s: string;
   lidos, guarda: integer;
   byteEnt: byte;
   noBloco, indBloco: integer;

begin
   lidos := 0;
   s := '';
   noBloco := length (bloco);
   indBloco := 1;
   guarda := 0;

   while noBloco <> 0 do
       begin
           byteEnt := ord(bloco [indBloco]);
           indBloco := indBloco + 1;
           noBloco := noBloco - 1;

           case lidos of
               0: begin
                      s := s + MIME64[byteEnt shr 2];
                      guarda := (byteEnt and 3) shl 4;
                  end;
               1: begin
                      s := s + MIME64[((byteEnt shr 4) and $f) or guarda];
                      guarda := (byteEnt and $f) shl 2;
                  end;
               2: begin
                      s := s + MIME64[((byteEnt shr 6) and $3) or guarda];
                      guarda := byteEnt and $3f;
                      s := s + MIME64[guarda];
                  end;
           end;
           lidos := (lidos + 1) mod 3;
       end;

   if lidos <> 0 then
       s := s + MIME64[guarda];

    while (length (s) mod 4) <> 0 do
        s := s + '=';

    codFraseMime64 := s;
end;

{-------------------------------------------------------------}
{                avisa aos amigos pelo correio
{-------------------------------------------------------------}

procedure avisaCorreio;
var
    sock: integer;
    Year, Month, Day, DayOfWeek, Hour, Minute, Second, Sec100: word;
    localAddr: sockaddr_in;
    tam: integer;
    nc: longint;
    s: string;
    email: string;

label erro;

        function correioReclamou: boolean;
        begin
            correioReclamou := (strlcomp (resp, '250', 3) <> 0) and
                               (strlcomp (resp, '251', 3) <> 0) and
                               (strlcomp (resp, '354', 3) <> 0) and
                               (strlcomp (resp, '503', 3) <> 0);
        end;

    {-------------------------------------------------------------}

        function sendAndRec (s: string; r: pchar): boolean;
        begin
            sendAndRec := false;
            writelnRede (sock, s);
            nc := recv (sock, resp, sizeof(resp), 0);
            resp [nc] := #$0;
            if strlcomp (resp, r, strlen(r)) = 0 then
                sendAndRec := true;
        end;

    {-------------------------------------------------------------}

        function login: boolean;
        label erro;
        var contaEmail: string;
            p: integer;
            salva: word;
        begin
            login := true;
            if comSenha then
                begin
                    mensagem ('MWINFSEN', 1); {'Informe sua senha de correio no servidor'}

                    salva := textAttr;
                    textColor (black);
                    readln (senhaEmail);
                    textAttr := salva;

                    contaEmail := emailDef;
                    p := pos ('@', emailDef);
                    if p <> 0 then delete (emailDef, p, 999);

                    if not sendAndRec ('EHLO ' + computLocal, '250') then goto erro;
                    if not sendAndRec ('AUTH LOGIN', '334') then goto erro;
                    if not sendAndRec (codFraseMime64 (contaEmail), '334') then goto erro;
                    if not sendAndRec (codFraseMime64 (senhaEmail), '235') then goto erro;
                end
            else
                begin
                    if not sendAndRec ('HELO '+ computLocal, '250') then goto erro;
                end;

            exit;

        erro:
            mensagem ('MWPROBCO', 1);   {'Erro no sistema de correio'}
            sintWriteln (strPas (resp));
            login := false;
        end;

var arq: text;

begin
    if not avisaParceiros then exit;

    assign (arq, nomeArqParceiros);
    {$I-}  reset (arq);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('MWPARNAO', 1);  {'Arquivo contendo os endereços dos parceiros não foi achado' }
            exit;
        end;

    nc := 0;

    sock := abreConexao (correioDef, PORTASMTP);
    if sock <= 0 then goto erro;

    nc := recv (sock, resp, sizeof(resp), 0);
    if (nc <= 0) or (strLComp (resp, '220', 3) <> 0) then goto erro;

    if not login then goto erro;

    while not eof (arq) do
        begin
            readln (arq, email);

            writelnRede (sock, 'MAIL FROM:' + emailDef);
            nc := recv (sock, resp, sizeof(resp), 0);
            if (nc <= 0) or correioReclamou then goto erro;

            writelnRede (sock, 'RCPT TO:' + email);
            nc := recv (sock, resp, sizeof(resp), 0);
            if (nc <= 0) or correioReclamou then goto erro;

            writelnRede (sock, 'DATA');
            nc := recv (sock, resp, sizeof(resp), 0);
            if (nc <= 0) or correioReclamou then goto erro;

            dvcrt.getDate(Year, Month, Day, DayOfWeek);
            dvcrt.getTime (Hour, Minute, Second, Sec100);
            writelnRede (sock,
                         'Date: ' + int2Str(Day) + ' ' + tabMes [Month] + ' ' + int2Str (Year) +
                         ' ' + int2(Hour) + ':' + int2(Minute) + ':' + int2(Second));

            writelnRede (sock, 'From: <' + emailDef + '>');
            writelnRede (sock, 'To: <' + email + '>');

            tam := sizeof (localAddr);
            getSockName (sock, localAddr, tam);
            s := 'Subject: ' + 'MINIWEB ' + strPas (inet_ntoa (in_addr(localAddr.sin_addr.s_addr)));
            if portaDef <> 80 then
                s := s + ':' + int2str (portaDef);
            s := s + ' ' + nomeDef;

            writelnRede (sock, s);
            writelnRede (sock, '');

            writelnRede (sock, '.');
            nc := recv (sock, resp, sizeof(resp), 0);
            if nc <= 0 then goto erro;

            resp[nc] := #$0;
            if copy (strPas (resp), 1, 3) <> '250' then
                begin
                    sintWriteln (email);
                    sintWriteln (strPas (resp));
                end;
        end;

    closeSocket (sock);

    mensagem ('MWPROCLA', 1);    {'Proclamas foram enviados pelo correio'}
    fechaConexao (sock);
    exit;

erro:
    close (arq);

    mensagem ('MWERRCOR', 1);   {'Não consegui enviar todos os proclamas pelo correio'}
    if nc <> 0 then
        begin
            if nc > 80 then nc := 80;
            resp[nc] := #$0;
            sintWriteln (strPas (resp));
        end;
    fechaConexao (sock);
end;

{-------------------------------------------------------------}
{                   programa principal
{-------------------------------------------------------------}

begin
    debug := false;
    inicializa;
    configura;
    pedeSenha;

    abreWinSock;
    avisaCorreio;
    inicEscuta;

    informaMeuIp;
    writeln;

    if maxClientes <= 0 then maxClientes := 3;   {para evitar problemas...}

    EnableMenuItem(GetSystemMenu(CrtWindow, False), sc_Close, mf_Disabled);
    checkBreak := false;

    processando := true;
    while processando do
        begin
            if not debug then
                mostraQueEstaVivo;

            processaTeclado;
            processaNovasConexoes;
            processaEnvio;

            if nclientes = 0 then
                delay (200)
            else
            if nbloqueados = nclientes then
                delay (descansoEntreMsg);
        end;

    avisaServPresenca (false);

    finaliza;
end.
