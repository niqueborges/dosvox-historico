{-------------------------------------------------------------}
{          papovox - comunicacao com o servidor de nomes
{-------------------------------------------------------------}

unit ppsnomes;

interface
uses dvwin, dvcrt, dvform, winsock, dvinet, sysUtils, windows,
     ppvars, ppmsg;

procedure logonUsuario (ender: string; tipoLogon: string);
procedure descobreIp (ender: string; var ip: string);
procedure registraUsuario (nome, ender, nomeArq: string);
procedure pesquisaUsuarios;

implementation
uses ppUrgent;

const
    debug = false;
type
    pstring = ^string;
    listaNomes = array [1..10000] of pstring;
    plistaNomes = ^listaNomes;
var
    sockNomes: integer;
    bufSockNomes: pbufRede;

{--------------------------------------------------------}
{                conecta com servidor
{--------------------------------------------------------}

function conectaServidor: boolean;
var s: string;
begin
    bufSockNomes := NIL;
    conectaServidor := false;

    servNomes := sintAmbiente ('PAPOVOX', 'SERVNOMES');
    if servNomes = '' then
        servNomes := SERV_DEFAULT;

    sockNomes := abreConexao (servNomes, PORTA_NOMES);
    if sockNomes < 0 then
        begin
            mensagem ('PPERCON', 1);  {Não consegui realizar a conexão}
            exit;
        end;

    bufSockNomes:= inicBufRede (sockNomes);
    if not readlnBufRede (bufSockNomes, s, 30) then exit;
    writeln (s);

    conectaServidor := true;
end;

{--------------------------------------------------------}
{        registro do usuário no servidor de nomes
{--------------------------------------------------------}

procedure logonUsuario (ender: string; tipoLogon: string);
var
    s: string;

label naoConec;

begin
    if anonimo then exit;

    if tipoLogon = 'logon' then
        mensagem ('PPLOGON', 1)    {Registrando presença no servidor de nomes}
    else
    if tipoLogon = 'logoff' then
        mensagem ('PPLOGOFF', 1);  {Registrando saída no servidor de nomes}

    if not conectaServidor then goto naoConec;

    if tipoLogon <> 'logoff' then
        s := 'LOGON ' + ender + ' ' + tipoLogon
    else
        s := 'LOGOFF ' + ender;
    if debug then writeln (s);
    writelnRede (sockNomes, s);
    if not readlnBufRede (bufSockNomes, s, 15) then goto naoConec;
    if debug then writeln (s);

    if s[1] = '-' then
        begin
            mensagem ('PPRECUEM', 1); {Servidor desconheceu seu e-mail}
            mensagem ('PPXCADAS', 1); {Execute o procedimento de configuração}
            sintWriteln (s);
        end;

    s := 'QUIT';
    writelnRede (sockNomes, s);
    if debug then writeln (s);
    readlnBufRede (bufSockNomes, s, 15);
    if debug then writeln (s);

    fimBufRede (bufSockNomes);
    fechaConexao (sockNomes);
    if tipoLogon = 'logon' then
        begin
             mensagem ('PPREGOK', 1);  {Presença registrada}
             writeln ('IP: ', strpas (inet_ntoa (in_addr(enderLocal))));
        end;
    exit;

naoConec:
    if bufSockNomes <> NIL then
        fimBufRede (bufSockNomes);

    if sockNomes >= 0 then
        begin
            fechaConexao (sockNomes);
            mensagem ('PPNAOCON', 2);  {Não consegui registrar conexão}
        end;
end;

{--------------------------------------------------------}
{                  Descobre IP do usuário
{--------------------------------------------------------}

procedure descobreIp (ender: string; var ip: string);
var
    s: string;

label naoConec;

begin
    ip := '';
    mensagem ('PPPEGAIP', 1);   {Consultando o servidor de nomes}

    if not conectaServidor then goto naoConec;

    s := 'IP ' + ender;
    writeln (s);
    writelnRede (sockNomes, s);
    if not readlnBufRede (bufSockNomes, s, 15) then goto naoConec;
    writeln (s);

    if s[1] = '-' then
        begin
            mensagem ('PPNCONH', 1); {Servidor não conhece este usuário}
            ip := '';
        end
    else
        ip := copy (s, 5, length (s)-4);

    writelnRede (sockNomes, 'QUIT');
    readlnBufRede (bufSockNomes, s, 15);
    writeln (s);

    fimBufRede (bufSockNomes);
    fechaConexao (sockNomes);
    exit;

naoConec:
    if bufSockNomes <> NIL then
        fimBufRede (bufSockNomes);
    fechaConexao (sockNomes);
    mensagem ('PPERRSRV', 1); {Não consegui acionar servidor de nomes}
end;

{--------------------------------------------------------}
{                Registra usuário na rede
{--------------------------------------------------------}

procedure registraUsuario (nome, ender, nomeArq: string);
var i: integer;
    s: string;
    arq: text;
label fim, naoConec;

begin
    mensagem ('PPLOGON', 1);    {Registrando presença no servidor de nomes}

    if not conectaServidor then goto naoConec;

    if nome = '' then
        begin
            s := 'REMOVE ' + ender;
            writelnRede (sockNomes, s);
            if not readlnBufRede (bufSockNomes, s, 15) then goto naoConec;
            writeln (s);
            if s[1] = '-' then goto naoConec;
            goto fim;
        end;

    s := 'REGISTER ' + ender;
    writeln (s);
    writelnRede (sockNomes, s);
    if not readlnBufRede (bufSockNomes, s, 15) then goto naoConec;
    writeln (s);

    if s[1] = '-' then goto naoConec;

    writeln (nome);
    writelnRede (sockNomes, nome);
    if not readlnBufRede (bufSockNomes, s, 15) then goto naoConec;
    writeln (s);

    if s[1] = '-' then goto naoConec;

    if nomeArq <> '' then
        begin
            assign (arq, nomeArq);
            {$I-} reset (arq);  {$I+}
            if ioresult = 0 then
                begin
                    for i := 1 to 10 do
                        if not eof (arq) then
                            begin
                                readln (arq, s);
                                writeln (s);
                                writelnRede (sockNomes, s);
                            end;
                    close (arq);
                end;
        end;

    writelnRede (sockNomes, '.');
    readlnBufRede (bufSockNomes, s, 15);

fim:
    writelnRede (sockNomes, 'QUIT');
    readlnBufRede (bufSockNomes, s, 15);
    writeln (s);

    fimBufRede (bufSockNomes);
    fechaConexao (sockNomes);
    mensagem ('PPREGOK', 2);    {'Presença registrada'}
    exit;

naoConec:
    if bufSockNomes <> NIL then
        fimBufRede (bufSockNomes);
    fechaConexao (sockNomes);
    mensagem ('PPERRREG', 2); {Não consegui registrar no servidor de nomes}
end;

{--------------------------------------------------------}
{      extrai e-mail e nome da informação do servidor
{--------------------------------------------------------}

procedure extraiInfo (s: string; var email, nome: string);
begin
    email := '';
    nome := '';

    while (s <> '') and (s[1] <> ' ') do
        begin
            email := email + s[1];
            delete (s, 1, 1);
        end;
    delete (s, 1, 1);

    if (s <> '') and (s[length(s)] in ['0'..'9']) then
        while (s <> '') and (s[length(s)] <> ' ') do
            delete (s, length (s), 1);

    delete (s, length (s), 1);
    nome := s;
end;

{--------------------------------------------------------}
{        extrai a data da informação do servidor
{--------------------------------------------------------}

function extraiDataInfo (s: string): string;
var s1: string;
    dia: string [3];
begin
    s1 := '';
    while (s <> '') and (s[1] <> ' ') do
        begin
            s1 := s1 + s[1];
            delete (s, 1, 1);
        end;

    s1 := s1 + s[1];
    delete (s, 1, 1);

    dia := copy (s, 1, 3);
    delete (s, 1, 4);
    if dia = 'Sun' then s1 := s1 + 'Domingo' else
    if dia = 'Mon' then s1 := s1 + 'Segunda' else
    if dia = 'Tue' then s1 := s1 + 'Terça'   else
    if dia = 'Wed' then s1 := s1 + 'Quarta'  else
    if dia = 'Thu' then s1 := s1 + 'Quinta'  else
    if dia = 'Fry' then s1 := s1 + 'Sexta'   else
    if dia = 'Sat' then s1 := s1 + 'Sábado'  else
                        s1 := s1 + dia;

    repeat
        delete (s, 1, 1);
    until (s = '') or (s[1] = ' ');

    repeat
        s1 := s1 + s[1];
        delete (s, 1, 1);
    until (s = '') or (s[1] = ':');

    repeat
        s1 := s1 + s[1];
        delete (s, 1, 1);
    until (s = '') or (s[1] = ':');

    extraiDataInfo := s1;
end;

{--------------------------------------------------------}
{          emite informações sobre este usuário
{--------------------------------------------------------}

function mostraInfoUsuario (email: string): boolean;
var s: string;
label naoConec;

begin
    mostraInfoUsuario := true;

    s := 'GET ' + email;
    writelnRede (sockNomes, s);
    if not readlnBufRede (bufSockNomes, s, 15) then goto naoConec;
    writeln (s);

    if s[1] = '-' then
        mensagem ('PPNINGUE', 1)  {Ninguém foi encontrado}
    else
        begin
            if not readlnBufRede (bufSockNomes, s, 15) then goto naoConec;   {nome}
            if not readlnBufRede (bufSockNomes, s, 15) then goto naoConec;   {ip}

            mensagem ('PPDATULT', 0);  {Última informação registrada:}
            if not readlnBufRede (bufSockNomes, s, 15) then goto naoConec;
            s := extraiDataInfo (s);
            sintWriteln (s);

            if s = '0.0.0.0' then
                mensagem ('PPNAOLOG', 1);   {Não está logado no servidor}

            if not keypressed then
                begin
                    mensagem ('PPENDELE', 0);       {correio eletrônico}
                    sintWriteln (email);
                end;

            if not readlnBufRede (bufSockNomes, s, 15) then goto naoConec;

            if not keypressed then
                 mensagem ('PPINFPES', 1);  {Informações pessoais:}

            if s = '.' then
                mensagem ('PPNENHUM', 1)
            else
                begin
                    if not keypressed then sintWriteln (s);
                    while s <> '.' do
                        begin
                             if not readlnBufRede (bufSockNomes, s, 15) then goto naoConec;
                             if s <> '.' then
                                 if not keypressed then sintWriteln (s);
                        end;
                end;
        end;

        while keypressed do readkey;
    exit;

naoConec:
    mostraInfoUsuario := false;
end;

{--------------------------------------------------------}
{          seleciona usuário para futura conexão
{--------------------------------------------------------}

procedure selecUsuario (s: string);
var email, nome: string;
begin
    extraiInfo (s, email, nome);
    selecionado := email;
end;

{--------------------------------------------------------}
{                  Folheia os usuários
{--------------------------------------------------------}

procedure folheiaNomes (numRegs: integer; plNomes: plistaNomes);
var
    c: char;
    nusu: integer;
    email, nome: string;
    s: string;

    procedure ultimoNome;
    begin
        textBackGround (MAGENTA);
        mensagem ('PPULTNOM', 0);  {'Ultimo nome...'}
        textBackGround (BLACK);
        writeln;
    end;

begin
    mensagem ('PPUSESET', 0);  {'Folheando: use as setas, depois tecle sua opção'}
    textBackground (BLACK);
    writeln;
    nusu := 0;
    selecionado := '';

    repeat
        while not keypressed do
            begin
                waitMessage;
                if temMsgUrgente then exit;
            end;

        c := readkey;
        if c = #0 then
            begin
                c := readkey;
                case c of
                    BAIX:   begin
                                nusu := nusu + 1;
                                if nusu > numRegs then
                                    begin
                                        nusu := numRegs + 1;
                                        ultimoNome;
                                    end
                                else
                                    begin
                                        extraiInfo (plNomes^[nusu]^, email, nome);
                                        sintWriteln (nome);
                                    end;
                            end;

                    CIMA:   begin
                                nusu := nusu - 1;
                                if nusu < 1 then
                                    begin
                                        nusu := 0;
                                        ultimoNome;
                                    end
                                else
                                    begin
                                        extraiInfo (plNomes^[nusu]^, email, nome);
                                        sintWriteln (nome);
                                    end;
                            end;

                    ESQ:   if (nusu > 0) and (nusu <= numRegs) then
                                begin
                                    extraiInfo (plNomes^[nusu]^, email, nome);
                                    sintSoletra (email);
                                end;

                    DIR:   if (nusu > 0) and (nusu <= numRegs) then
                                begin
                                    extraiInfo (plNomes^[nusu]^, email, nome);
                                    sintetiza (email);
                                end;

                    PGUP:   begin
                                nusu := nusu - 5;
                                if nusu < 1 then
                                    begin
                                        nusu := 0;
                                        ultimoNome;
                                    end;
                            end;

                    PGDN:   begin
                                nusu := nusu + 5;
                                if nusu > numRegs then
                                    begin
                                        nusu := numRegs + 1;
                                        ultimoNome;
                                    end;
                            end;

                    F1: mensagem ('PPAJSEL', 1);
                          {'I-informações   ENTER-seleciona  ESC-termina'}
                end;
            end
        else
            begin
                if (nusu > 0) and (nusu <= numRegs) then
                    case upcase(c) of

                        'I'  : begin
                                   extraiInfo (plNomes^[nusu]^, email, nome);
                                   mostraInfoUsuario (email);
                               end;

                        'M'  : begin
                                   extraiInfo (plNomes^[nusu]^, email, nome);
                                   selecionado := email;
                                   fimBufRede (bufSockNomes);
                                   fechaConexao (sockNomes);

                                   enviaMsgUrgente;

                                   if not conectaServidor then exit;
                               end;

                        'L', ENTER: begin
                                   extraiInfo (plNomes^[nusu]^, email, nome);
                                   selecionado := email;
                                   textBackground (RED);
                                   mensagem ('PPUSUSEL', 0);  {Usuário selecionado}
                                   textBackground (BLACK);
                                   writeln;
                                   c := ENTER;
                               end;

                        ^Y:   {ocultamento de si próprio}
                               begin
                                   extraiInfo (plNomes^[nusu]^, email, nome);
                                   s := 'logoff ' + email;
                                   writelnRede (sockNomes, s);
                                   writeln (s);
                                   readlnBufRede (bufSockNomes, s, 15);
                                   writeln (s);
                               end;

                    else
                        if c <> ESC then mensagem ('PPOPINV', 1);    {Opção inválida, F1 ajuda}
                    end;

                if (c <> ESC) and (c <> ENTER) then
                    begin
                        textBackGround (MAGENTA);
                        mensagem ('PPCNTFOL', 0);  {'Continue folheando ou tecle ESC'}
                        textBackGround (BLACK);
                        writeln;
                    end;
            end;

    until (c = ESC) or (c = ENTER);
    if c = ESC then
        selecionado := '';
end;

{--------------------------------------------------------}
{              Pesquisas sobre os usuários
{--------------------------------------------------------}

procedure pesquisa (nomePesq: string);
var s: string;
    plNomes: plistaNomes;
    nNomes: integer;
label naoConec;

begin
    nNomes := 0;
    new (plNomes);

    if not conectaServidor then goto naoConec;

    s := 'FIND ' + nomePesq;
    writeln (s);
    writelnRede (sockNomes, s);
    if not readlnBufRede (bufSockNomes, s, 15) then goto naoConec;

    if s[1] = '-' then
        mensagem ('PPNINGUE', 1)  {Ninguém foi encontrado}
    else
        repeat
            if not readlnBufRede (bufSockNomes, s, 15) then goto naoConec;
            if s <> '.' then
                begin
                    nNomes := nNomes + 1;
                    new (plNomes^[nNomes]);
                    plNomes^[nNomes] ^:= s;
                end;
        until s = '.';

    folheiaNomes (nNomes, plNomes);

    writelnRede (sockNomes, 'QUIT');
    readlnBufRede (bufSockNomes, s, 15);
    writeln (s);

    fimBufRede (bufSockNomes);
    fechaConexao (sockNomes);
    exit;

naoConec:
    if bufSockNomes <> NIL then
        fimBufRede (bufSockNomes);
    fechaConexao (sockNomes);
    mensagem ('PPERRSRV', 2); {Não consegui acionar servidor de nomes}
end;

{--------------------------------------------------------}
{              Pesquisas sobre os usuários
{--------------------------------------------------------}

procedure pesqNomes;
var s: string;
begin
    mensagem ('PPNOMBUS', 1);    {Informe parte do nome a buscar}
    sintReadln (s);
    if s <> '' then pesquisa (s);
end;

{--------------------------------------------------------}
{              Pesquisas sobre os usuários
{--------------------------------------------------------}

procedure pesqCartao;
var s: string;
label naoConec;
begin
    mensagem ('PPINFEND', 1);   {Informe endereço eletrônico:'}
    sintReadln (s);
    if s = '' then exit;

    if not conectaServidor then goto naoConec;

    if not mostraInfoUsuario (s) then goto naoConec;

    writelnRede (sockNomes, 'QUIT');
    readlnBufRede (bufSockNomes, s, 15);
    writeln (s);

    fimBufRede (bufSockNomes);
    fechaConexao (sockNomes);
    exit;

naoConec:
    if bufSockNomes <> NIL then
        fimBufRede (bufSockNomes);
    fechaConexao (sockNomes);
    mensagem ('PPERRSRV', 2); {Não consegui acionar servidor de nomes}
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

function selSetasOpcao: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var n: integer;
const
    tabLetrasOpcoes: string [4] = 'tanc';

begin
    garanteEspacoTela(5);
    popupMenuCria (wherex, wherey, 60, 4, MAGENTA);
    MenuAdiciona ('PPAJUPQ2');  {T - todos os nomes cadastrados}
    MenuAdiciona ('PPAJUPQ3');  {A - apenas os ativos na rede}
    MenuAdiciona ('PPAJUPQ4');  {N - busca por nome}
    MenuAdiciona ('PPAJUPQ5');  {C - cartão de visita de um endereço eletrônico}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpcao := tabLetrasOpcoes[n]
    else
        selSetasOpcao := #0;
end;

{--------------------------------------------------------}
{              Pesquisas sobre os usuários
{--------------------------------------------------------}

        procedure ajuda;
            begin
                mensagem ('PPAJUPQ1', 1);  {As opções de pesquisa são:}
                mensagem ('PPAJUPQ2', 1);  {T - todos os nomes cadastrados}
                mensagem ('PPAJUPQ3', 1);  {A - apenas os ativos na rede}
                mensagem ('PPAJUPQ4', 1);  {N - busca por nome}
                mensagem ('PPAJUPQ5', 1);  {C - cartão de visita de um endereço eletrônico}
            end;

procedure pesquisaUsuarios;
var c, c2: char;
label executa;
begin
    selecionado := '';

    repeat
        mensagem ('PPTIPPSQ', 0);   {Qual o tipo de pesquisa (F1 ajuda):}
        while not keypressed do
            if temMsgUrgente then exit;

        sintLeTecla (c, c2);
        writeln;
        if c = #$0 then
            case c2 of
                F1:  ajuda;
                CIMA, BAIX:
                    begin
                        c := selSetasOpcao;
                        goto executa;
                    end;
            end;
    until c <> #0;

executa:
    case upcase(c) of
        'T': pesquisa ('');
        'A': pesquisa ('+');
        'N': pesqNomes;
        'C': pesqCartao;
        ESC: ;
    else
        mensagem ('PPOPINEX', 1);   {Opção inexistente}
    end;
end;

end.
