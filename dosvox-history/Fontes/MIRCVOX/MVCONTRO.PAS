{-------------------------------------------------------}
{               Mircvox - Controle geral
{-------------------------------------------------------}
 

unit MVContro;
interface
uses dvCrt , dvWin , winprocs , wintypes , mvmsg , mvvars , winsock , dvinet ,
    mmsystem , sysutils, videovox;

Procedure Configura;
Procedure EnviaMsg;
Procedure ProcessaMsg (m:string);
Procedure JCanal (Can:string);
Procedure RegNick;
Procedure Conecta;
Procedure Ajuda;
function temMensagem: boolean;
Procedure ListaCanais;


implementation


{------------------------------------------------------------}
{                  Informa número IP
{------------------------------------------------------------}

procedure informaIp;
var
    localAddr: sockaddr_in;
    tam: integer;
begin
    fillchar (localAddr , sizeof (localAddr) , 0);
    tam := sizeof (localAddr);
    getSockName (sock , localAddr , tam);
    mensagem ('MVNUMIP' , 1);   {Número IP desta conexão}
    sintWriteln (strpas (inet_ntoa (in_addr(localAddr.sin_addr.s_addr))));
end;

{------------------------------------------------------------}
{          Fala uma mensagem da fila de mensagens
{------------------------------------------------------------}


procedure falaDaFila;
begin
    if ffilaFala <> rfilaFala then
        begin
            gotoxy (1 , wherey);
            clreol;
            textColor (WHITE);
            msg := filaFala [ffilaFala];
            ffilaFala := (ffilaFala + 1) mod 255;
            if msg='' then exit;
            ultMsgParceiro := filaFala [ffilaFala];
            sintWriteln (msg);
            delay (10);
            textColor (LIGHTGRAY);
        end;
end;

{------------------------------------------------------------}
{              Altera configurações de fala
{------------------------------------------------------------}


procedure alteraFala;
var c , c2: char;
    dir: string;
begin
    mensagem ('MVQVELOC' , 0);   {'Qual a velocidade de fala , de 1 a 4 ? '}
    sintLeTecla (c , c2);
    writeln;
    if c in ['1'..'5'] then
        begin
            sintFim;
            dir := sintAmbiente ('MIRCVOX' , 'DIRMIRCVOX');
            if dir = '' then
                dir := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\mircvox';
            sintInic (ord(c) - ord('0') , dir);
        end;
    mensagem ('MVSOLET' , 0);    {'Soletra digitação ? '}
    sintLeTecla (c , c2);
    writeln;
    soletrando := upcase(c) <> 'N';
end;

{------------------------------------------------------------}
{              Processamento do teclado
{------------------------------------------------------------}

procedure processaTeclasComuns (c: char);

    procedure escreveBufTec;
    begin
        if length (bufTec) < 80 then
            begin
                gotoxy (1 , wherey);
                write (buftec);
            end
        else
            begin
                gotoxy (1 , wherey);
                write (copy (buftec , length(buftec)-78 , 79));
            end;
        clreol;
    end;

var i, i2, z:integer;
    Transf:pchar;
label fim;
begin
    if c = ESC then
        Begin
            Mensagem ('MVFIM', 0);
            c:=Readkey;
            Sintetiza (c);
            Writeln;
            if (c='S') or (c='s') then
            Begin
                conversando := false;
                writelnrede (sock , 'Part #'+canal);
                delay (40);
                mensagem ('MVFIMC' , 1);
                ClrScr;
                canal:='';
                Exit;
            End;
        End
    else
    if c = ENTER then
        begin
            sintClek;
                if buftec='' then goto fim;
                msg:=buftec;
                while (buftec[2]='/') or (buftec[2]='+') do delete (buftec , 2 , 1);
                if (buftec[1]='/') then
                Begin
                    delete (buftec , 1 , 1);
                    if (uppercase(copy (buftec , 1 , 4))='NOME') or (uppercase(copy(buftec , 1 , 4))='NICK') then
                    Begin
                        delete (buftec , 1 , 5);
                        if pos(' ' , buftec)>0 then
                        Begin
                            aux:=copy (buftec , 1 , pos(' ' , buftec)-1);
                            delete (buftec , 1 , pos(' ' , buftec));
                            if not Writelnrede (sock , 'NICK '+aux) then
                            Begin
                                Mensagem ('MVCAIU' , 1);
                                sock:=0;
                                 Conversando:=false;
                                Exit;
                            End;
                            Writelnrede (sock , 'IDENTIFY '+ buftec);
                        End
                        Else Begin
                            if not Writelnrede (sock , 'NICK '+BUFTEc) then
                            Begin
                                Mensagem ('MVCAIU' , 1);
                                sock:=0;
                                Conversando:=false;
                                Exit;
                            End;
                        End;
                    End
                    Else if uppercase (copy (buftec , 1 , 4))='QUEM' then
                    Begin
                        if not Writelnrede (sock , 'NAMES #'+Canal) then
                        Begin
                            Mensagem ('MVCAIU' , 1);
                            sock:=0;
                            Conversando:=false;
                            Exit;
                        End;
                    End
                    Else if uppercase(copy(buftec, 1, 7))='IGNORAR' then
                    Begin
                        for i:=0 to 127 do
                            if (ignorados[i]='') then
                            Begin
                                delete (buftec, 1, pos(' ', buftec));
                                if pos(' ', buftec)>0 then delete (buftec, pos(' ', buftec), length(buftec));
                                for i2:=0 to 127 do
                                if uppercase(ignorados[i2])=uppercase(buftec) then
                                Begin
                                    filaFala [rfilaFala] :='Apelido '+buftec+' já está sendo ignorado';
                                    rfilaFala := (rfilaFala + 1) mod 255;
                                    Goto fim;
                                End;
                                ignorados[i]:=buftec;
                                filaFala [rfilaFala] :='Apelido ignorado: '+buftec;
                                rfilaFala := (rfilaFala + 1) mod 255;
                                Goto fim;
                            End;
                        End
                    Else if uppercase (copy(buftec, 1, 10))='DESIGNORAR' then
                    Begin
                        delete (buftec, 1, pos(' ', buftec));
                        if pos(' ', buftec)>0 then delete (buftec, pos(' ', buftec), length(buftec));
                        For i:=0 to 127 do
                        If uppercase(buftec)=uppercase(ignorados[i]) then
                        Begin
                            filaFala [rfilaFala] :='Apelido designorado: '+buftec;
                            rfilaFala := (rfilaFala + 1) mod 255;
                            ignorados[i]:='';
                            goto fim;
                        end;
                        filaFala [rfilaFala] :='Apelido '+buftec+' não está sendo ignorado';
                        rfilaFala := (rfilaFala + 1) mod 255;
                        buftec:='';
                    End
                    Else SintWriteln ('Comando inválido');
                End
                Else if (buftec[1]='+') then
                Begin
                    delete (buftec , 1 , 1);
                    if pos(' ' , buftec)=0 then exit;
                    aux:=copy(buftec , 1 , pos(' ' , buftec)-1);
                    Delete (Buftec , 1 , pos(' ' , buftec));
                    if not Writelnrede (sock , 'PRIVMSG '+Aux+' :'+buftec) then
                    Begin
                        Mensagem ('MVCAIU' , 1);
                        sock:=0;
                        Conversando:=false;
                        Exit;
                    End;
                End
                Else
                Begin
                    if not writelnrede (sock , 'PRIVMSG #'+canal+' :'+buftec) Then
                    Begin
                        Mensagem ('MVCAIU' , 1);
                        sock:=0;
                        Conversando:=false;
                        Exit;
                    End;
                    filaFala [rfilaFala] :=Nick+'. '+buftec;
                    rfilaFala := (rfilaFala + 1) mod 255;
                End;
fim:
            Begin
                gotoxy (1 , wherey);
                writeln (copy (msg , 1 , 79));
                bufTec := '';
                msg:='';
            End;
        end
    else
    if c = ^Y then
       begin
           gotoxy (1 , wherey);
           clreol;
           sintSom ('_CPOAPA');
           bufTec := '';
       end
    else
    if c=SHIFTINS then
            Begin
            getmem (transf, 255);
            for z:=0 to 254 do
            transf[z]:=#$0;
            getclipboard (transf, 255);
            for z:=0 to 254 do
            begin
            if (transf[z]<>#$0) and (transf[z]<>#$0D) and (transf[z]<>#$0A) then
                Begin
                buftec:=buftec+transf[z];
                write (transf[z]);
                End;
            end;
            freemem (transf, 255);
            Sintclek;
            End
    else
    if c=CTLINS then
    begin
        getmem (transf, 65000);
        if (ultmsgparceiro[1]=' ') then delete (ultmsgparceiro, 1, 1);
        delete (ultmsgparceiro, 1, pos(' ', ultmsgparceiro));
        for Z:=0 to length (ultmsgparceiro)-1 do
        transf[z]:=ultmsgparceiro[z+1];
        for z:= length(ultmsgparceiro) to 254 do
        transf[z]:=#$0;
        putclipboard (transf);
        freemem (transf, 65000);
        sintclek;
    end
    Else
    if c = BS then
        begin
            if bufTec <> '' then
                begin
                    sintsom ('_del');
                     sintCarac (bufTec [length(bufTec)]);
                     delete (bufTec , length(bufTec) , 1);
                end;
            escreveBufTec;
        end
    else
        begin
            if length (bufTec) > 255 then
                sintBip
            else
                begin
                    If Soletrando then sintsoletra (c);
                    bufTec := bufTec + c;
                    escreveBuftec;
                end;
        end
end;


{------------------------------------------------------------}
{        Processamento do teclado - Teclas de função
{------------------------------------------------------------}

procedure processaFuncoesDeTeclado (c: char);
Var xc, yc, i:integer;
Procedure Ajudateclado;
Begin
Mensagem ('MVAF2', 1); {F2 - Guarda um apelido na memória}
Mensagem ('MVAF3', 1); {F3 - Tira um apelido da memória}
Mensagem ('MVAF4', 1); {F4 - Altera a fala}
Mensagem ('MVAF6', 1); {F6 - Informa número IP}
Mensagem ('MVAF9', 1); {F9 - Ativa leitor de tela}
Mensagem ('MVAESC2', 1); {ESC - Sai do canal}
End;

begin
    if (c in [F2 , F3 , F5]) and (wherex <> 1) then
        processaTeclasComuns (ENTER);

    case c of
        F1: AjudaTeclado;
        F4:  alteraFala;
        F6:  informaIp;
        F7:  begin
             if pont=false then
                Begin
                pont:=true;
                sintfalapont:=true;
                 xc := wherex;
                 yc := wherey;
                 gotoxy (1, 25);
                mensagem ('MVPLIG', 0);
                gotoxy (xc, yc);
                end
             else
                begin
                pont:=false;
                sintfalapont:=false;
                 xc := wherex;
                 yc := wherey;
                gotoxy (1, 25);
                mensagem ('MVPDES', 0);
                gotoxy (xc, yc);
                end;
            end;
        F9:  begin
                 sintBip;
                 xc := wherex;
                 yc := wherey;
                 Window (1 , 1 , 80 , 24);
                 leitorDeTela;
                 gotoxy (xc , yc);
             end;
        F2:begin
            Mensagem ('MVQMEMO', 0);
            Sintreadint (i);
            If i>255 then exit;
            Mensagem ('MVQAPEL', 0);
            SintReadln (memonick[i]);
            Sintclek;
        End;
        F3: Begin
            Mensagem ('MVQMEMO', 0);
            Sintreadint (i);
            if i>255 then exit;
            Buftec:=Buftec+memonick[i]+' ';
            write (memonick[i]+' ');
            Sintclek;
        End;
            CTLINS:processateclascomuns(ctlins);
            SHIFTINS:processateclascomuns(shiftins);

    else
        mensagem ('MVOPINV' , 1);   {Aperte F1 para ajuda}
    end;
end;


{------------------------------------------------------------}
{                  Configura o programa
{------------------------------------------------------------}

Procedure Configura;
Begin
    Mensagem ('MVCONFS' , 1);
    mensagem ('MVSERV' , 0);
    Sintreadln (Servidor);
    Mensagem ('MVNICK' , 0);
    sintreadln (nick);
    Mensagem ('MVSENHA' , 0);
    Readln (senha);
    if fileexists (NomeConf) then
        Deletefile (nomeconf);

    assignfile (ArqConf , NomeConf);
    {$I-} rewrite (arqConf);  {$I+}
    if ioresult <> 0 then
    begin
        Mensagem ('MVNAOC' , 1);
        {$I-} erase (arqConf);  {$I+}
        if ioresult <> 0 then
        exit;
    end;
    writeln (arqconf , '[MircVox]');
    writeln (arqconf , 'Servidor='+servidor);
    writeln (arqconf , 'Nick='+nick);
    writeln (arqconf , 'Senha='+senha);
    close (arqconf);
end;


{------------------------------------------------------------}
{               Envia uma mensagem em pvt
{------------------------------------------------------------}

Procedure EnviaMsg;
Var Apelido:string;
Begin
if sock<1 then
Begin
    Mensagem ('MVNAOCON' , 1);
    Exit;
End;
    Mensagem ('MVDIGAP' , 0);
    SintReadln (Apelido);
    if apelido='' then exit;
    while apelido[1]=' ' do delete (apelido , 1 , 1);
    if apelido='' then exit;
    Mensagem ('MVDIGMSG' , 0);
    SintReadln (Aux);
    if aux='' then exit;
    while aux[1]=' ' do delete (aux , 1 , 1);
    If aux='' then exit;
    if not Writelnrede (sock , 'PRIVMSG '+Apelido+' :'+aux) then
    Begin
        Mensagem ('MVCAIU' , 1);
        sock:=0;
        Exit;
    End;
    Mensagem ('MVMSGENV' , 1);
End;


{------------------------------------------------------------}
{              Processa mensagem que chegou
{------------------------------------------------------------}

Procedure ProcessaMsg (m:string);
Var Posic , ans, i:integer;
Begin
Apelido:='';
msg:=m;
if (msg[1]=':') then delete (msg , 1 , 1);
posic:=pos(' ' , msg);
if (pos('!' , msg)>0) then Apelido:=copy(msg , 1 , pos('!' , msg)-1);
for ans:=1 to length(msg) do
if ord( msg[ans])=003 then
Begin
    delete (msg, ans, 2);
    if (ord (msg[ans])>=48) and (ord(msg[ans])<=57) then delete (msg, ans, 1);
    if (msg[ans]=',') then delete (msg, ans, 2);
    if (ord (msg[ans])>=48) and (ord(msg[ans])<=57) then delete (msg, ans, 1);
End;
for ans:=posic+1 to length(msg)-posic do
if (ord(msg[ans])=002) or (ord(msg[ans])=015) or (ord(msg[ans])=022) or (ord(msg[ans])=031) then
delete (msg, ans, 1);


if (copy (msg , 1 , 4)='PING') then
Begin
    Sintbip;
    Writelnrede (sock , 'PONG ' +meuip);
End
Else If (copy (msg , posic+1 , 3)='353') then
    Begin
        Delete (msg , 1 , pos(':' , msg));
        while pos(' ' , msg)>0 do
        Begin
            filaFala [rfilaFala] := copy (msg , 1 , pos(' ' , msg)-1);
            rfilaFala := (rfilaFala + 1) mod 255;
            delete (msg , 1 , pos(' ' , msg));
            Delay (30);
        end;
    end
    Else if (copy (msg , posic+1 , 4)='JOIN') then
    Begin
        msg:=' Entrou no canal';
        Apelido:='.'+apelido;
        filaFala [rfilaFala] := apelido+msg;
        rfilaFala := (rfilaFala + 1) mod 255;
        Exit;
    End
    Else If (copy (msg , posic+1 , 4)='PART') then
    Begin
        if uppercase(apelido)=uppercase(nick) then exit;
        msg:=' Saiu do canal';
        Apelido:='.'+apelido;
        filaFala [rfilaFala] := apelido+msg;
        rfilaFala := (rfilaFala + 1) mod 255;
    End
    Else If (copy (msg , posic+1 , 4)='QUIT') then
    Begin
        msg:=' Caiu do canal';
        Apelido:='.'+apelido;
        filaFala [rfilaFala] := apelido+msg;
        rfilaFala := (rfilaFala + 1) mod 255;
    End
    Else If (copy (msg , posic+1 , 4)='KICK') then
    Begin
        Delete (msg , 1 , posic+5);
        posic:=pos(' ' , msg);
        Delete (msg , 1 , posic);
        Apelido:=copy (msg , 1 , pos(' ' , msg)-1);
        if uppercase(apelido)=uppercase(nick) then
        Begin
            filaFala [rfilaFala] :='Você foi expulso do canal';
            rfilaFala := (rfilaFala + 1) mod 255;
            Conversando:=false;
            Exit;
        End;
        msg:=' Foi expulso do canal';
        Apelido:='.'+apelido;
        filaFala [rfilaFala] := apelido+msg;
        rfilaFala := (rfilaFala + 1) mod 255;
    End
    Else If (copy (msg , posic+1 , 7)='PRIVMSG') and (msg[posic+9]<>'#') then
    Begin
        for ans:=0 to 127 do
            if uppercase(apelido)=uppercase(ignorados[ans]) then exit;
        delete (msg , 1 , pos(':' , msg));
        If canal='' then
            Sintwriteln (Apelido+'(PVT). '+msg)
        Else
        Begin
            filaFala [rfilaFala] := apelido+'(pvt). '+msg;
            rfilaFala := (rfilaFala + 1) mod 255;
        End;
        Exit;
    End
    Else If (copy (msg , posic+1 , 4)='NICK') then
    Begin
        if (pos (':' , msg)>0) then delete (msg , 1 , pos(':' , msg));
        If uppercase(apelido)=uppercase(nick) then nick:=msg;
        for i:=0 to 127 do
        if uppercase(apelido)=uppercase(ignorados[i]) then
        ignorados[i]:=msg;
        Msg:=' Trocou de nick para '+msg;
        filaFala [rfilaFala] := apelido+msg;
        rfilaFala := (rfilaFala + 1) mod 255;
    End
    Else if (copy (msg , posic+1 , 5)='TOPIC') then
    Begin
        delete (msg , 1 , pos(':' , msg));
        filaFala [rfilaFala] := apelido+' Colocou o tópico: '+msg;
        rfilaFala := (rfilaFala + 1) mod 255;
        Apelido:='';
    End
    Else if (copy (msg , posic+1 , 4)='MODE') then
    Begin
        delete (msg , 1 , posic+6);
        delete (msg , 1 , pos(' ' , msg));
        if (uppercase(copy (msg , 1 , 2))='+B') then
        Begin
            filaFala [rfilaFala] :=apelido+' Baniu '+copy (msg , 4 , pos('!' , msg)-4)+' deste canal';
            rfilaFala := (rfilaFala + 1) mod 255;
            if uppercase(copy (msg , 4 , pos('!' , msg)-4))=uppercase(nick) then conversando:=false;
        End;

    End
    Else If (copy (msg , posic+1 , 7)='PRIVMSG') then
    begin
        For ans:=0 to 127 do
            if uppercase(apelido)=uppercase(ignorados[ans]) then exit;
    if (pos (':' , msg)>0) then delete (msg , 1 , pos(':' , msg));
        filaFala [rfilaFala] := apelido+'. '+msg;
        rfilaFala := (rfilaFala + 1) mod 255;
        Apelido:='';
    End
    else if (uppercase(copy (apelido, 1, 8))='NICKSERV') then
    Begin
        delete (msg, 1, 1);
        delete (msg, 1, pos (':', msg));
        sintwriteln (msg);
    end;

Exit;
End;


{------------------------------------------------------------}
{                  Processamento do canal
{------------------------------------------------------------}

Procedure jcanal (can:string);
Var i2:integer;
    c:char;
Begin
    For i2:=0 to 254 do
        FilaFala[i2]:='';
    Rfilafala:=0;
    Ffilafala:=0;
    Canal:=can;
    window (1, 1, 80, 24);
    ClrScr;
    Mensagem ('MVINICC' , 1);
    If not writelnrede (sock , 'JOIN #'+canal) then
    Begin
        Mensagem ('MVCAIU' , 1);
        sock:=0;
        Exit;
    End;
    if not Readlnbufrede (buf , aux , 15) then
    Begin
        Mensagem ('MVCAIU' , 1);
        sock:=0;
        Exit;
    End;
    Processamsg (aux);
    Conversando:=true;
    while conversando do
    begin
        while keypressed do
        Begin
            c:=readkey;
            if (c<>#$0) then processateclascomuns (c)
            else
            begin
                c := readkey;
                processaFuncoesDeTeclado (c);
            end;
        end;

        if (wherex = 1) and (conversando=true) then
            falaDaFila;

        while Temmensagem do
        Begin
            if not readlnbufrede (buf , msg , 15) then
            Begin
                Mensagem ('MVCAIU' , 1);
                sock:=0;
                Exit;
            End;
            ProcessaMsg (msg);
            Delay (200);
        End;
    end;
end;

{------------------------------------------------------------}
{                 Registro de apelidos
{------------------------------------------------------------}

Procedure RegNick;
var email:string;
Begin
if sock<1 then
Begin
    Mensagem ('MVNAOCON' , 1);
    Exit;
End;
Senha:='';
email:='';
Mensagem ('MVSENHA' , 0);
Readln (senha);
if (senha='') then exit;
Mensagem ('MVEMAIL' , 0);
Sintreadln (email);
if (email='') or  (pos('@' , email)=0) then exit;
if not Writelnrede (sock , 'NICKSERV REGISTER '+Senha+' '+EMAIL) then
Begin
    Mensagem ('MVCAIU' , 1);
    sock:=0;
    Exit;
End;
    readlnbufrede (buf, aux, 15);
    if uppercase (copy (aux, 1, 7))='SINTAXE' then
    begin
if not Writelnrede (sock , 'NICKSERV REGISTER '+EMAIL) then
Begin
    Mensagem ('MVCAIU' , 1);
    sock:=0;
    Exit;
end;
end;
    Mensagem ('MVAPREG' , 1);
End;

{------------------------------------------------------------}
{                  Conecta a um servidor
{------------------------------------------------------------}

Procedure Conecta;
var
    localAddr: sockaddr_in;
    tam: integer;
Begin
    Sock:=0;
    abrewinsock;
    sock:=abreconexao (servidor , porta);
    if sock<1 then
    Begin
        Mensagem ('MVNCONS' , 1);
        sock:=0;
        Exit;
    End;
    Delay (200);
    writelnrede (sock , 'pass '+senha);
    Writelnrede (sock , 'nick '+Nick);
    Writelnrede (sock , 'USER ' +Nick+' MircVox '+Servidor+' :'+Nick+'21');
    WritelnRede (sock , 'IDENTIFY '+senha);
    Writelnrede (sock , 'MandandoComandoInvalido');
    sintbip;
    Buf:=inicbufrede (sock);
    Repeat
        if not readlnbufrede (buf , aux , 30) then
        Begin
            Mensagem ('MVCAIU' , 1);
            sock:=0;
            Exit;
        End;
        if aux[1]=':' then delete (aux , 1 , 1);
        Textcolor (lightgray);
        Writeln (copy(aux , pos(':' , aux)+2 , length(aux)));
        Textcolor (white);
        Delete (aux , 1 , pos(' ' , aux));
    Until (aux[1]='4') and (aux[2]='2') and (aux[3]='1');
    fillchar (localAddr , sizeof (localAddr) , 0);
    tam := sizeof (localAddr);
    getSockName (sock , localAddr , tam);
    Meuip:=strpas (inet_ntoa (in_addr(localAddr.sin_addr.s_addr)));
end;


{------------------------------------------------------------}
{                 Processamento da ajuda
{------------------------------------------------------------}

Procedure Ajuda;
Begin
    Mensagem ('MVAC' , 1); {C - Conectar ao servid,}
    Mensagem ('MVAJ' , 1); {J - Entrar em um canal}
    Mensagem ('MVAL' , 1); {L - Obter lista de canais}
    Mensagem ('MVAM' , 1); {M - Enviar mensagem em pvt}
    mensagem ('MVAO' , 1); {O - Configurar o programa}
    Mensagem ('MVAR' , 1); {R - Registrar  apelido}
    mensagem ('MVAF9', 1); {F9 - Aciona leitor de tela}
    Mensagem ('MVAESC' , 1); {Esc - Sair do programa}
End;


{------------------------------------------------------------}
{               Verifica se chegou mensagem
{------------------------------------------------------------}

function temMensagem: boolean;
begin
    temmensagem := chegouRede (sock);
end;


{------------------------------------------------------------}
{                   Listagem dos canais
{------------------------------------------------------------}

Procedure ListaCanais;
Var Desc , palavra , k:string;
    i , i2 , j:integer;
    c:char;
    posic:integer;
Label Folheia;
Begin
if sock<1 then
Begin
    Mensagem ('MVNAOCON' , 1);
    Exit;
End;
palavra:='';
Mensagem ('MVDIGPAL' , 0);
Sintreadln (palavra);
if palavra<>'' then palavra:='*'+palavra+'*';
if not Writelnrede (sock , 'LIST '+palavra) then
Begin
    Mensagem ('MVCAIU' , 1);
    sock:=0;
    Exit;
End;
Mensagem ('MVPEGLIS' , 1);
For i:=0 to 5000 do
linha[i]:='';
i:=0;
Repeat
str (i , k);
    if (k[length(k)-1]='0') and (k[length(k)]='0') then
    Begin
        Writelnrede (sock , 'PONG '+meuip);
        Sintclek;
    End;

    if not Readlnbufrede (Buf , linha[i] , 15) then
    Begin
        Mensagem ('MVCAIU' , 1);
        sock:=0;
        Exit;
    End;
    posic:=pos (' ' , linha[i]);
    If (Linha[i][posic+1]='3') and (linha[i][posic+2]='2') and (linha[i][posic+3]='2') then Begin
        Delete (linha[i] , 1 , pos('#' , linha[i]));
        Writeln (copy (linha[i] , 1 , pos (' ' , linha[i])));
    End
    Else If (Linha[i][posic+1]='3') and (linha[i][posic+2]='2') and (linha[i][posic+3]='3') then
    Begin
        linha[i]:='';
        goto folheia;
    End
    Else begin
        linha[i]:='';
        i:=i-1;
    end;
    I:=i+1;
    i2:=i;
Until (i=5000);

Sintbip;
fechaconexao (sock);
conecta;

Folheia: Begin
if i2<=0 then begin
Sintwriteln ('Não foi encontrado nenhum canal');
exit;
end;
Mensagem ('MVNUM' , 0);
sintwriteint (i2);
Writeln;
Mensagem ('MVORDAG', 1);
for i:=0 to i2 do
Begin
    k:=linha[i];
    linha[i]:=uppercase(copy(k , 1 , pos(' ' , k)-1))+ copy (k , pos(' ' , k) , length(k));
End;
For i:=0 to i2-1 do
for j:=i+1 to i2 do
if linha[i] > linha[j] then
begin
k:=linha[i];
linha[i] :=linha[j];
linha[j] :=k;
end;
i :=0;
     Mensagem ('MVFOLHE' , 1);
Repeat
    textcolor (white);
    if chegourede (sock) then Begin
        if not readlnbufrede (buf , aux , 15) then
        Begin
            Mensagem ('MVCAIU' , 1);
            sock:=0;
            Exit;
        End;
    if copy (aux , 1 , 4)='PING' then
        Writelnrede (sock , 'PONG '+MeuIp);
        End;
    c:=readkey;
    if c=#$0 then
    Begin
    c:=readkey;
    if c=cima then
    Begin
        if (i>1) then begin
            i:=i-1;
            SintWriteln (copy (linha[i] , 1 , pos(' ' , linha[i])));
        End
        Else
            Mensagem ('MVPRICAN' , 1)
    End
    Else if c=baix then
    Begin
        if (i<i2) then
        Begin
            i:=i+1;
            SintWriteln (copy (linha[i] , 1 , pos(' ' , linha[i])));
        End
        Else
            Mensagem ('MVULTCAN' , 1);
    End
    Else if c=PGup then
    Begin
        i:=i-20;
        if i<0 then
        Begin
            i:=0;
            Mensagem ('MVPRICAN' , 1);
        End
        Else
            SintWriteln (copy (linha[i] , 1 , pos(' ' , linha[i])));
    End
    Else if c=pgdn then
    Begin
        i:=i+20;
        if (i>i2) then
        Begin
            i:=i2;
            Mensagem ('MVULTCAN' , 1);
        End
        Else
            SintWriteln (copy (linha[i] , 1 , pos(' ' , linha[i])));
    End
    Else if C=F1 then
    Begin
        Desc:=copy (linha[i] , pos(' ' , linha[i])+1 , length(linha[i]));
for posic:=1 to length(desc) do
if ord( desc[posic])=003 then
Begin
    delete (desc, posic, 2);
    if (ord (desc[posic])>=48) and (ord(desc[posic])<=57) then delete (desc, posic, 1);
    if (desc[posic]=',') then delete (desc, posic, 2);
    if (ord (desc[posic])>=48) and (ord(desc[posic])<=57) then delete (desc, posic, 1);
End;
for posic:=1 to length(desc) do
if (ord(desc[posic])=002) or (ord(desc[posic])=015) or (ord(desc[posic])=022) or (ord(desc[posic])=031) then
delete (desc, posic, 1);
        Sintwriteln (Desc);
    End
    Else if (c=esq) or (c=dir) then
        SintSoletra (copy(linha[i] , 1 , pos(' ' , linha[i])-1))
    else if c=esc then exit;
    End
    Else if (c=enter) then
    Begin
        jcanal (copy(linha[i] , 1 , pos(' ' , linha[i])-1));
        Textcolor (white);
        Mensagem ('MVFOLHE' , 1);
    End;

Until (c=esc);
End;
End;

end.
