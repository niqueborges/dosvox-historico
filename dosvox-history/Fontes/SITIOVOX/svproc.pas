{--------------------------------------------------------}
{          sitiovox - processamento geral
{--------------------------------------------------------}

unit svProc;
interface
uses dvCrt, dvWin,
     dvinet, windows, winsock, sysutils,
     svvars, svMsg, svFila, svrede, svdog, svditado;

function iniciaServidor: boolean;
procedure processa;

implementation

var
    quemTestar: integer;
    quemEnviar: integer;
    msgAEnviar, envAEnviar, destAEnviar: string;
    caracVivo: integer;

{--------------------------------------------------------}
{             faz um desenhinho na tela
{--------------------------------------------------------}

procedure mostraQueEstaVivo;
const
    tabVivo: array [0..3] of char = ('-', '\', '|', '/');
begin
    caracVivo := (caracVivo + 1) mod 4;
    write (tabVivo [caracVivo]);
    gotoxy (1, wherey);
    keypressed;
end;

{--------------------------------------------------------}
{            escreve uma mensagem num soquete
{--------------------------------------------------------}

function writeMsgRede (sock: integer; msg: string): boolean;
begin
     writeMsgRede := enviaRede (sock, DADOTECLADO, @msg[1], length (msg));
end;

{--------------------------------------------------------}
{               inicializa escuta no soquete
{--------------------------------------------------------}

function iniciaServidor: boolean;
begin
    sockEscuta := escutaConexao (portaSitio);
    if sockEscuta < 0 then
         begin
             mensagem ('SVPORDES', 1);    {Porta de escuta desabilitada ou já usada}
             mensagem ('SVPROCAN', 1);    {Programa cancelado}
             iniciaServidor := false;
         end
    else
         begin
             mensagem ('SVSVATIV', 1);   {Servidor ativo aceitando conexões}
             iniciaServidor := true;
         end;
end;

{--------------------------------------------------------}
{              escreve data e hora no console
{--------------------------------------------------------}

function strhora: string;
var ano, mes, dia, sem, hora, min, seg, cent: word;

    function doisDig (w: word): string;
    const tabDig: array [0..9] of char = (
         '0','1','2','3','4','5','6','7','8','9');
    begin
        w := w mod 100;
        doisDig := tabDig[w div 10] + tabDig[w mod 10];
    end;

begin
    dvcrt.getDate (ano, mes, dia, sem);
    dvcrt.getTime (hora, min, seg, cent);
    strhora := doisDig(dia) +  '/' + doisDig(mes) + '/' + doisDig(ano) + ' ' +
               doisDig(hora) + ':' + doisDig(min) + ' ';
end;

{--------------------------------------------------------}
{    ve se houve alguma ocorrencia no socket de escuta
{--------------------------------------------------------}

procedure checaNovosUsuarios;
var s: string;
    maxVezes: integer;
    sockLixo: integer;

var endip: TsockAddr;
    tam: integer;

label cancelou;
begin
    if chegouRede (sockEscuta) then
        begin
            if nUsuarios >= MAXCONEX then
                begin
                    sockLixo := aceitaConexao (sockescuta);
                    writelnRede (sockLixo, MSGEXCEDIDO);
                    delay (500);
                    fechaConexao (sockLixo);
                    exit;
                end;

            nusuarios := nusuarios + 1;
            new (conexao [nusuarios]);

            with conexao [nusuarios]^ do
                begin
                    sock := aceitaConexao (sockescuta);
                    horaInicio := getCurrentTime;
                    nome := '';
                    apelido := '';
                    ativo := false;

                    if sock >= 0 then
                        begin
                            tam := sizeof (Tsockaddr);
                            getpeername(sock, endip, tam);

                            if fazLog then
                                begin
                                    {$I-} writeln (arqlog, 'Aceitei conexão de ' +
                                             strPas (inet_ntoa (in_addr (endip.sin_addr.S_addr)))); {$I+}
                                    if ioresult <> 0 then fazLog := false;
                                end;

                            writelnRede (sock, '+OK - entrada registrada de ' +
                                 strPas (inet_ntoa (in_addr(endip.sin_addr.S_addr))));
                            meuBuf := inicBufRede (sock);

                            write (strhora, 'Aceitei conexão de ' +
                                 strPas (inet_ntoa (in_addr(endip.sin_addr.S_addr))), '(', sock, ')');

                            maxVezes := 20;
                            repeat
                                delay (500);
                                maxVezes := maxVezes - 1;
                            until temDadoBufRede (meuBuf) or (maxVezes = 0);
                            if maxVezes <> 0 then
                                readlnBufRede (meuBuf, nome, 15);

                            fimBufRede (meuBuf);
                            if maxVezes = 0 then
                                begin
                                    writeln (' - usuário cancelado');

                                    if fazLog then
                                        begin
                                            {$I-} writeln (arqlog, '== >usuário cancelado'); {$I+}
                                             if ioresult <> 0 then fazLog := false;
                                        end;

                                    goto cancelou;
                                end;

                            writelnRede (sock, '+OK');
                            delay (100);

                            str (nusuarios-1, s);
                            if (nome[1] = '+') or (nome[1] = '-')     then goto cancelou;
                            if not writeMsgRede (sock, msgBoasVindas) then goto cancelou;
                            if not writeMsgRede (sock, MSGATIVOS+s)   then goto cancelou;
                            if not writeMsgRede (sock, MSGDIGAPELIDO) then goto cancelou;

                            writeln (' - ', nome);
                        end
                   else
                       begin
cancelou:
                           fechaConexao (sock);
                           nusuarios := nusuarios - 1;
                       end;
                end;
        end;
end;

{--------------------------------------------------------}
{                trata saida de um usuario
{--------------------------------------------------------}

procedure usuarioCaiu (quem: integer);
var i: integer;
begin
    if (quem <= 0) or (quem > nusuarios) then exit;

    writeln (strHora, MSGCAIU + conexao [quem]^.apelido, '(', conexao [quem]^.sock, ')');
    insereFilaMsg ('*', '*', MSGCAIU + conexao [quem]^.apelido);

    if conexao[quem] <> NIL then
        with conexao [quem]^ do
            begin
                fechaConexao (sock);
                dispose (conexao [quem]);
            end;

    for i := quem to nusuarios-1 do
        conexao [i] := conexao [i+1];
    nusuarios := nusuarios - 1;
    quemTestar := quemTestar - 1;
end;

{--------------------------------------------------------}
{                   checa usuarios zumbi                  s
{--------------------------------------------------------}

procedure checaZumbis;
var i: integer;
    t: longint;
begin
    for i := nusuarios downto 1 do   { tem que ser de tras para diante }
        begin
            mostraQueEstaVivo;
            if not conexao [i]^.ativo then
                begin
                    t := getCurrentTime - conexao [i]^.horaInicio;
                    if (t > 60000) then usuarioCaiu (i);
                end;
        end;
end;

{--------------------------------------------------------}
{          divide cadeia lida em destino/mensagem
{--------------------------------------------------------}

procedure extraiDestino (var s, dest: string);
begin
    if (s <> '') and (s[1] = '+') then
        begin
            dest := '';
            delete (s, 1, 1);
            while (s <> '') and (s[1] <> ' ') do
                begin
                    dest := dest + upcase (s[1]);
                    delete (s, 1, 1);
                end;
            while (s <> '') and (s[1] = ' ') do
                delete (s, 1, 1);
        end
    else
        dest := '*';
end;

{--------------------------------------------------------}
{              busca usuario por apelido
{--------------------------------------------------------}

function buscaApelido (dest: string): integer;
var i, j: integer;
    apel: string;
begin
    for j := 1 to length (dest) do
        dest[j] := upcase (dest[j]);

    for i := 1 to nusuarios do
        with conexao[i]^ do
            begin
                apel := apelido;
                for j := 1 to length (apel) do
                    apel[j] := upcase (apel[j]);

                if apel = dest then
                    begin
                        buscaApelido := i;
                        exit;
                    end;
            end;

    buscaApelido := 9999;
end;

{--------------------------------------------------------}
{                    reinicia o sitio
{--------------------------------------------------------}

procedure reiniciaSitio;
var i: integer;
begin
    mensagem ('SVREINIC', 1); {'Reiniciando o sítio'}
    for i := nusuarios downto 1 do   { tem que ser de tras para diante }
        begin
            if conexao[i] <> NIL then
                writeMsgRede (conexao[i]^.sock, MSGSAINDO);  {'*** Sítio saindo do ar por um instante ***'}
            delay (1000);
            usuarioCaiu (i);
        end;

    nusuarios := 0;  {por via das duvidas...}
    quemTestar := 1;
end;

{--------------------------------------------------------}
{                  comandos locais
{--------------------------------------------------------}

procedure comandosLocais (quem: integer; msg: string);
var i: integer;
    s, nomeReg: string;
    n, posErro: integer;
label naoPode, erro;
begin
    if (quem <= 0) or (quem > nusuarios) or (conexao[quem] = NIL) then exit;

    with conexao [quem]^ do
        begin
            for i := 1 to length (msg) do
                msg [i] := upcase (msg[i]);

            if msg = '?' then
                begin
                    if not writeMsgRede (sock, DICA1) then goto erro;
                    if not writeMsgRede (sock, DICA2) then goto erro;
                    if not writeMsgRede (sock, DICA3) then goto erro;
                    if not writeMsgRede (sock, DICA4) then goto erro;
                    if not writeMsgRede (sock, DICA5) then goto erro;
                    if not writeMsgRede (sock, DICA6) then goto erro;
                end
            else
            if msg = '?QUANTOS' then
                begin
                    str (nusuarios, s);
                    if not writeMsgRede (sock, MSGATIVOS+s) then goto erro;
                end
            else
            if msg = '?QUEM' then
                begin
                    for i := 1 to nusuarios do
                        begin
                             str (i, s);
                             if conexao[i] <> NIL then
                                 if conexao[i]^.apelido = '' then
                                     begin
                                         if not writeMsgRede (sock, s + ' <Usuário entrando>') then
                                              goto erro;
                                     end
                                 else
                                     if not writeMsgRede (sock, s + ' ' + conexao[i]^.apelido) then
                                          goto erro;
                        end;
                end
            else
            if copy (msg, 1, 8) = '?CANCELA' then
                begin
                    delete (msg, 1, 8);
                    while (msg <> '') and (msg[1] = ' ') do delete (msg, 1, 1);
                    if copy (msg, 1, length (senha)) = senha then
                        begin
                            delete (msg, 1, length (senha));
                            while (msg <> '') and (msg[1] = ' ') do delete (msg, 1, 1);
                            val (msg, n, posErro);
                            if posErro = 0 then usuarioCaiu (n);
                        end
                    else
                        goto naoPode;
                end
            else
            if copy (msg, 1, 9) = '?REGISTRA' then
                begin
                    delete (msg, 1, 9);
                    while (msg <> '') and (msg[1] = ' ') do delete (msg, 1, 1);
                    if copy (msg, 1, length (senha)) = senha then
                        begin
                            delete (msg, 1, length (senha));

                            while (msg <> '') and (msg[1] = ' ') do delete (msg, 1, 1);
                            if msg = '' then goto naoPode;

                            nomeReg := '';
                            while (msg <> '') and (msg[1] <> ' ') do
                                begin
                                    nomeReg := nomeReg + msg[1];
                                    delete (msg, 1, 1);
                                end;
                            nomeReg := nomeReg + #$0;

                            while (msg <> '') and (msg[1] = ' ') do delete (msg, 1, 1);
                            if pos(' ', msg) <> 0 then goto naoPode;
                            if nomeConf = '' then goto naoPode;

                            if msg = '' then
                                sintRemoveAmbienteArq ('SENHAS', nomeReg, nomeConf)
                            else
                                sintGravaAmbienteArq ('SENHAS', nomeReg, msg, nomeConf);

                            if not writeMsgRede (sock, MSGOK) then goto erro;
                        end
                    else
                        goto naoPode;
                end
            else
            if msg = '?REINICIA ' + senha then
                reiniciaSitio
            else
                if not writeMsgRede (sock, MSGINVALIDA) then goto erro;
        end;

    exit;

naoPode:
    if conexao[quem] <> NIL then
        with conexao [quem]^ do
            if not writeMsgRede (conexao [quem]^.sock, MSGNAOPODE) then goto erro;
    exit;

erro:
    usuarioCaiu (quem);
    exit;
end;

{--------------------------------------------------------}
{                  compacta um apelido
{--------------------------------------------------------}

function compactaBrancos (s: string): string;
var p: integer;
begin
    repeat
        p := pos (' ', s);
        if p <> 0 then
            delete (s, p, 1);
    until p = 0;

    for p := 1 to length (s) do
        if (s[p] < #$20) then
            s[p] := '#';

    compactaBrancos := s;
end;

{--------------------------------------------------------}
{                    confere senha
{--------------------------------------------------------}

function confereSenha (var apelido: string): boolean;
var
    senhaDada, senha: string;
    n: integer;

begin
    n := pos ('/', apelido);
    if n < 2 then
        if senhaObrigatoria then
            senhaDada := '#$&*#&(#*$&'
        else
            senhaDada := ''
    else
        begin
            senhaDada := copy (apelido, n+1, length (apelido)-n);
            delete (apelido, n, length (apelido)-n+1);
        end;

    senha := sintAmbienteArq ('SENHAS', apelido, '', nomeConf);
    confereSenha := senha = senhaDada;
end;

{--------------------------------------------------------}
{                    trata apelido
{--------------------------------------------------------}

procedure trataApelido (quem: integer; s: string);
begin
    if (quem <= 0) or (quem > nusuarios) or (conexao[quem] = NIL) then exit;

    s := compactaBrancos (s);
    with conexao [quem]^ do
        begin
            if not confereSenha (s) then
                begin
                    writeln (strHora, MSGSENHAINCORRETA, ' ', s);   {'Senha incorreta'}
                    writeMsgRede (sock, MSGSENHAINCORRETA);
                    delay (1000);
                    usuarioCaiu (quem);
                end;

            if s = '' then
                begin
                    writeln (strHora, MSGAPELIDOINV);  {'Apelido inválido'}
                    usuarioCaiu (quem);
                    exit;
                end;

            if buscaApelido (s) <> 9999 then
                begin
                    writeMsgRede (sock, MSGAPELIDODUPLIC);  {'Apelido duplicado'}
                    exit;
                end;

            ativo := true;
            apelido := s;

            writeln (strHora, 'Apelido: ', apelido);

            if comCachorro then
                lateCachorro;

            comandosLocais (quem, '?QUANTOS');
            comandosLocais (quem, '?QUEM');
            insereFilaMsg ('', apelido, MSGAJUDA);
            insereFilaMsg (apelido, '*', MSGENTRA);
        end;
end;

{--------------------------------------------------------}
{            enfileira uma mensagem chegada
{--------------------------------------------------------}

procedure checaMensagemChegada (quem: integer);
var s: string;
    dest: string;
    n: integer;

begin
    if (quem <= 0) or (quem > nusuarios) or (conexao[quem] = NIL) then exit;

    with conexao [quem]^ do
        begin
            if not chegouRede (sock) then
                exit;

            if not leLinhaRede (sock, s) then
                usuarioCaiu (quem)
            else
                begin
                    if (s <> '')  and (s[1] = '?') then
                        begin
                            comandosLocais (quem, s);
                            exit;
                        end;

                    extraiDestino (s, dest);

                    if apelido = '' then    { teste da primeira vez: ele ainda nao tem apelido }
                        begin
                            trataApelido (quem, s);
                            exit;
                        end;

                    if s = '' then exit;

                    if dest = '*' then
                        begin
                           insereFilaMsg (apelido, dest, s);

                           if comCachorro and
                              ((nusuarios <= 1) or (random (100) = 1)) then
                                   lateCachorro;

                           if (numDitados > 0) and
                              ((nusuarios <= 1) or (random (100) = 1)) then
                                   mostraDitado;
                        end
                    else
                        begin
                            n := buscaApelido (dest);     { ve se destino existe }
                            if n = 9999 then
                                insereFilaMsg ('*', apelido, dest+MSGUSUINEX)
                            else
                                insereFilaMsg (apelido, dest, '(pvt) ' + s);
                        end;
                end;
        end;
end;

{--------------------------------------------------------}
{         despacha mensagem para próximo usuário
{--------------------------------------------------------}

procedure despachaUmaMensagem;
begin
    quemEnviar := quemEnviar + 1;
    if quemEnviar > nusuarios then
         begin
             if temMsgFila then
                 begin
                      removeFilaMsg (envAEnviar, destAEnviar, msgAEnviar);

                      if destAEnviar <> '*' then
                           quemEnviar := buscaApelido (destAEnviar)
                      else
                           quemEnviar := 1;
                 end
             else
                 begin
                     quemEnviar := 9999;
                     delay (100);     { dá uma folguinha para a pobre maquina }
                     exit;
                 end;
         end;

    if (quemEnviar > 0) and (quemEnviar <= nusuarios) then
        if (conexao [quemEnviar] <> NIL) and
           (conexao [quemEnviar]^.ativo) and
           (msgAEnviar <> '') then
            if not writeMsgRede (conexao [quemEnviar]^.sock, envAEnviar + '.' + msgAEnviar) then
                usuarioCaiu (quemEnviar);

    if destAEnviar <> '*' then       {envio para um só}
         quemEnviar := 9999;
end;

{--------------------------------------------------------}
{                 mostra usuarios ativos
{--------------------------------------------------------}

procedure mostraAtivos;
const
    brancos = '                  ';
var
    i: integer;
    s: string;
    endip: TsockAddr;
    tam: integer;
begin
    if nusuarios = 0 then
        mensagem ('SVNINGUE', 1)   {'Ninguém ativo'}
    else
        begin
            mensagem ('SVLISUSU', 1);  {'Lista de usuários ativos'}
            for i := 1 to nusuarios do
                with conexao[i]^ do
                    begin
                        str (i:4, s);
                        if apelido = '' then
                             s := s + ' <Alguém entrando> '
                        else
                             s := s + ' ' + copy (apelido+brancos, 1, 18);
                        sintWrite (s);
                        tam := sizeof (Tsockaddr);
                        getpeername(sock, endip, tam);
                        write (sock:5, ' ');
                        write (strPas (inet_ntoa (in_addr(endip.sin_addr.S_addr))), '(', sock, ')'+ '  ');
                        writeln (nome);
                    end;
        end;
end;

{--------------------------------------------------------}
{               ciclo de processamento geral
{--------------------------------------------------------}

procedure processa;
var
    c, c2: char;
    processando: boolean;
    n: integer;

begin
    mensagem ('SVAPTESC', 1);    {'Aperte ESC para terminar'}

    quemTestar := 9999;
    quemEnviar := 9999;
    processando := true;
    while keypressed do readkey;

    while processando do
        begin
             mostraQueEstaVivo;

             if keypressed then
                 begin
                     c := upcase(readkey);
                     if c = #$0 then c2 := readkey;

                     if c = 'C' then
                         begin
                             mensagem ('SVNUMCNC', 0);  {'Número da sessão a cancelar  '}
                             n := 0;
                             sintReadInt (n);
                             if (n >= 1) and (n <= nusuarios) then
                                 usuarioCaiu (n);
                         end
                     else
                     if c = 'R' then
                         begin
                             mensagem ('SVCNFREI', 0); {'Confirma reinício do sítio ? '}
                             sintLeTecla (c, c2);
                             writeln;
                             if upcase (c) = 'S' then reiniciaSitio;
                         end
                     else
                     if c = 'Q' then
                         mostraAtivos
                     else
                     if (c = ESC) or ((c = #$0) and (c2 = F4)) then
                         begin
                             mensagem ('SVCNFFIM', 0);   {'Confirma fim ? '}
                             sintLeTecla (c, c2);
                             writeln;

                             if upcase (c) = 'S' then
                                 processando := false
                         end
                     else
                         begin
                             mensagem ('SVOPCOES', 1);
                               {'Opções: q-mostra usuários  c-cancela usuario  r-reinicia sítio  ESC-fim'}
                         end;
                 end
             else
                 begin
                     checaNovosUsuarios;

                     if nusuarios > 0 then
                         begin
                             quemTestar := quemTestar + 1;
                             if quemTestar > nusuarios then
                                 quemTestar := 1;
                             checaMensagemChegada (quemTestar);
                         end;

                     despachaUmaMensagem;

                     checaZumbis;
                 end;
        end;
end;

end.
