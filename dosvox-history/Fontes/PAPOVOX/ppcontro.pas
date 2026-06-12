{-------------------------------------------------------------}
{                papovox - interacao via teclado
{-------------------------------------------------------------}

unit ppcontro;

interface

uses dvWin, dvCrt, dvExec, dvInet, dvForm, dvArq, dvWav, dvGrav, videovox,
     dvDic, dvSapi4,
     mmsystem, winSock, winprocs, wintypes, sysUtils,
     ppVars, ppMsg, ppSom, ppRede, ppArq, ppUrgent, ppSnomes, ppDic, ppConv;

procedure poeNoClipboard;
function maiusc (s: string): string;
procedure alteraFala;
procedure batePapo;
procedure escolheComando;
procedure carregaComandos;
procedure escolheEfeito;
procedure verificaEfeito;
procedure carregaEfeitos;
procedure leArquivo;

implementation
const
    MAXEFEITOS = 1000;

var
    horaConec, minConec: word;
    naoQueroOuvir, semEfeito, pulaEntSai: boolean;
    meuEfeito, efeitoParceiro: string;
    nikName: string;
    arqGrava: text;
    gravandoArq: boolean;
    modoPapovox: boolean;
    comBip, protegido, quemSalas: boolean;
    comandoSaci: array [1..50] of string;
    numDeComandos: integer;
    somDeEfeito: array [1..MAXEFEITOS] of string;
    numDeEfeitos: integer;
    esperaNiks: boolean;
    contNiks: integer;
    nikEspecial: array [1..5] of string;
    liga: string[8];

{--------------------------------------------------------}

function semAcentos (s: string): string;
const
    tabMaiuscPC: array [#$80..#$ff] of char = (

    'C','U','E','A','A','A','A','C','E','E','E','I','I','I','A','A',
    'E','þ','þ','O','O','O','U','U','Y','O','U','þ','þ','þ','þ','þ',
    'A','I','O','U','N','N','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ',
    'þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ',
    'A','A','A','A','A','A','‘','C','E','E','E','E','I','I','I','I',
    'þ','N','O','O','O','O','O','X','þ','U','U','U','U','Y','þ','þ',
    'A','A','A','A','A','A','‘','C','E','E','E','E','I','I','I','I',
    'þ','N','O','O','O','O','O','X','þ','U','U','U','U','Y','þ','þ');

var
    s2: string;
    i: integer;

begin
    s2 := s;
    for i := 1 to length (s2) do
        if s2[i] in ['a'..'z'] then
            s2[i] := upcase (s2[i])
        else
        if s2[i] >= #$80 then
            s2[i] := tabMaiuscPC [s2[i]];

    semAcentos := s2;
end;

{--------------------------------------------------------}

procedure poeNoClipboard;
var p: pchar;
    pos: word;
    nb, linha, coluna: integer;
    c: char;
    arq: text;
label achouNB;
begin

    assign (arq, sintDirAmbiente + '\papovox.$$$');
    rewrite (arq);

    getmem (p, 65000);
    pos := 0;

    for linha := 1 to wherey-1 do
        begin
            for nb := 80 downto 2 do
                begin
                    c := getScreenChar (nb, linha);
                    if c <> ' ' then
                        goto achouNB;
                end;
            nb := 1;
achouNB:
            for coluna := 1 to nb do
                begin
                    p[pos] := getScreenChar (coluna, linha);
                    pos := pos + 1;
                end;
            p[pos]   := #$0d;
            p[pos+1] := #$0a;
            pos := pos + 2;
        end;

    p[pos] := #$0;
    putClipboard (p);

    write (arq, p);
    close (arq);

    freemem (p, 65000);

    sintBip;

end;

{-------------------------------------------------------------}

function maiusc (s: string): string;
var s2: string;
    i: integer;
begin
    s2 := s;
    for i := 1 to length (s) do
        s2 [i] := upcase (s[i]);
    maiusc := s2;
end;

{--------------------------------------------------------}
{              altera parâmetros de fala
{--------------------------------------------------------}

procedure alteraFala;
var c, c2: char;
    dir: string;
begin

     mensagem ('PPQVELOC', 0);   {'Qual a velocidade de fala, de 1 a 4 ? '}
     sintLeTecla (c, c2);
     writeln;
     if c in ['1'..'5'] then
         begin
             sintFim;
             dir :=  sintambiente ('PAPOVOX', 'DIRPAPOVOX');
             if dir = '' then
                 dir := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\papovox';
             sintInic (ord(c) - ord('0'), dir);
         end;

     mensagem ('PPSOLET', 0);    {'Soletra digitação ? '}
     sintLeTecla (c, c2);
     writeln;
     soletrando := upcase(c) <> 'N';

     mensagem ('PPPONTUA', 0);    {'Fala pontuação? '}
     sintLeTecla (c, c2);
     writeln;
     sintFalaPont:= upcase(c) <> 'N';

     mensagem ('PPACELER', 0);    {'Modo acelerado? '}
     sintLeTecla (c, c2);
     writeln;
     modoAcelerado:= upcase(c) <> 'N';

end;

{--------------------------------------------------------}
{               informa tempo de conexão
{--------------------------------------------------------}

procedure informaTempos;
var
    hora, min, seg, cent: word;
begin
    mensagem ('PPHORA', 0);     {'A hora atual é '}
    dvcrt.gettime (hora, min, seg, cent);
    sintWriteInt (hora);
    mensagem ('PPXHORAS', 0);   {' horas '}
    if min <> 0 then
        begin
            sintWriteInt (min);
            mensagem ('PPXMINUT', 1);   {' minutos'}
        end;

    mensagem ('PPHCONE', 0);     {'Hora da conexão com o parceiro:'}

    sintWriteInt (horaConec);
    mensagem ('PPXHORAS', 0);   {horas}
    if min <> 0 then
        begin
            sintWriteInt (minConec);
            mensagem ('PPXMINUT', 1);   {minutos}
        end;
end;

{--------------------------------------------------------}
{              ajuda comandos de teclado
{--------------------------------------------------------}

procedure ajudaTeclado;
begin
    mensagem ('PPAJUT0', 1);     {'Os comandos são os seguintes'}
    mensagem ('PPAJUT1', 1);     {'F1 ajuda'}
    mensagem ('PPAJUT2', 1);     {'F2 transmite um arquivo'}
    mensagem ('PPAJUT3', 1);     {'F3 cancela recebimento de arquivo'}
    mensagem ('PPAJUT4', 1);     {'F4 altera fala'}
    mensagem ('PPAJUT5', 1);     {'F5 mensagem urgente'}
    mensagem ('PPAJUT6', 1);     {'F6 informa ip desta conexão'}
    mensagem ('PPAJUT7', 1);     {'F7 repete fala'}
    mensagem ('PPAJUT8', 1);     {'F8 informa tempo de conexão'}
    mensagem ('PPAJUT9', 1);     {'F9 Conhecer outras opções'}
end;

{--------------------------------------------------------}
{       seleciona a opção com as setas
{--------------------------------------------------------}

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

{--------------------------------------------------------}
{       seleciona a função com as setas - F1 ... F9
{--------------------------------------------------------}

function selSetasFolheiaFun: char;
var
    n:integer;

const
    numOp = 15;
    tabPapo: string [numOp] = F1+ F2+ F3 +F4+ F5+ F6+ F7+ F8+
                              CTLF3+ CTLF4+ CTLF5+ CTLF6+ CTLF7 +CTLF8+
                              ENTER;
begin

    popupMenuCria (18, 9, 52, numOp, RED);
    menuAdiciona ('PPAJUT1');     {'F1 ajuda'}
    menuAdiciona ('PPAJUT2');     {'F2 transmite um arquivo'}
    menuAdiciona ('PPAJUT3');     {'F3 cancela recebimento de arquivo'}
    menuAdiciona ('PPAJUT4');     {'F4 altera fala'}
    menuAdiciona ('PPAJUT5');     {'F5 menuAdiciona urgente'}
    menuAdiciona ('PPAJUT6');     {'F6 informa ip desta conexão'}
    menuAdiciona ('PPAJUT7');     {'F7 repete fala'}
    menuAdiciona ('PPAJUT8');     {'F8 informa tempo de conexão'}
    menuAdiciona ('PPAJUT10');     {'CTRL+F3 grava conversação'}
    menuAdiciona ('PPAJUT11');     {'CTRL+F4 inibe síntese'}
    menuAdiciona ('PPAJUT12');     {'CTRL+F5 envia apenas para um parceiro'}
    menuAdiciona ('PPAJUT13');     {'CTRL+F6 inibe menuAdiciona de entrada e saída nessa sala'}
    menuAdiciona ('PPAJUTC7');     {'CTRL+F7 repete sua última mensagem enviada'}
    menuAdiciona ('PPAJUT14');     {'CTRL+F8 inibe sons de efeito'}
    menuAdiciona ('PPOUT');        {'ENTER outras opções'}

    n := popupMenuSeleciona;

    if (n > 0) and (n <= numOp) then
        selSetasFolheiaFun := tabPapo[n]
    else
        selSetasFolheiaFun := ESC;

end;

{--------------------------------------------------------}
{       seleciona a função com as setas - ^B .. ^z
{--------------------------------------------------------}

function selSetasFolheiaCom: char;
var
    n:integer;

const
    numOp = 11;
    tabPapo: string [numOp] = ^B+ ^C+ ^E+ ^K+ ^P+ ^Q+ ^S+ ^T+ ^W+ ^X+ ^Z;

begin

    popupMenuCria (13, 13, 50, numOp, RED);
    menuAdiciona ('PPAJUT15');     {'CTRL+B ativa ou desativa o bip'}
    menuAdiciona ('PPAJUT23');     {'CTRL+C seleciona um comando da sala de conversação'}
    menuAdiciona ('PPAJUT16');     {'CTRL+E ativa ou desativa modo de espera'}
    menuAdiciona ('PPAJUT26');     {'CTRL+K ativa ou desativa conexão por voz'}
    menuAdiciona ('PPAJUT17');     {'CTRL+P ativa ou desativa modo de proteção'}
    menuAdiciona ('PPAJUT24');     {'CTRL+Q Ativa ou desativa o comando QUEM'}
    menuAdiciona ('PPAJUT18');     {'CTRL+S seleciona um efeito'}
    menuAdiciona ('PPAJUT19');     {'CTRL+T ativa ou desativa modo TELNET'}
    menuAdiciona ('PPAJUT25');     {'CTRL+W Pede para conversar pelo microfone'}
    menuAdiciona ('PPAJUT20');     {'CTRL+X resgata mensagens da tela para o editor'}
    menuAdiciona ('PPAJUT21');     {'CTRL+Z limpa a tela e aguarda tecla pressionada'}

    n := popupMenuSeleciona;

    if (n > 0) and (n <= numOp) then
        selSetasFolheiaCom := tabPapo[n]
    else
        selSetasFolheiaCom := ESC;

end;

{--------------------------------------------------------}
{                 executa fala pendente
{--------------------------------------------------------}

procedure falaDaFila;
label fim;

       {--------------------------------------------------------}

        procedure checaOsNiks;
        var cn: integer;
        begin
            for cn := 1 to 5 do
               begin
                  contNiks := cn;
                  if NikEspecial[contNiks] = '' then
                      break
                  else
                      if copy(maiusc(ultMsgParceiro), 1, pos(' ', ultMsgParceiro)-1) =
                                             maiusc(nikEspecial[contNiks]) then
                          begin
                              esperaNiks:= false;
                              bufTec:= sintAmbiente ('PAPOVOX', 'MSGAUTOMATICA');
                              if bufTec <> '' then
                              begin
                                  bufTec:= ('+' + (nikEspecial[contNiks]) + ' ' + (bufTec));
                                  ultMsgMinha := bufTec;
//                                  delay (100);
                                  if not enviaRede (DADOTECLADO, @bufTec[1], length (bufTec)) then
                                      exit
                                  else
                                      mensagem ('PPMSGAUT', 0); {'ok, mensagem automática enviada para '}
                                      sintWriteln (nikEspecial[contNiks]);
                                  bufTec:= '';
                              end;
                              liga := sintAmbiente ('PAPOVOX', 'SOMRECEBE');
                              if liga = '' then
                                  liga:= 'RING';
                              repeat
                                  sintsom (liga);
                                  delay (2000);
                              until keyPressed;
                              while keyPressed do readkey;
                              sintSom ('PPESPDES'); {'espera desativada'}
                              break;
                          end;
               end;

        end;

        {--------------------------------------------------------}

begin
    if ffilaFala <> rfilaFala then
        begin
            ultMsgParceiro := filaFala [ffilaFala];
            ffilaFala := (ffilaFala + 1) mod maxFilaFala;

            if not modoAcelerado then delay (250);

            //OBS: O tratamento das mensagens visa o Chat Saci

            //Verifica se é um pedido para conversa por voz
            if copy (ultMsgParceiro, pos ('(', ultMsgParceiro), 4) = '(pvt' then
                if copy (ultMsgParceiro, pos ('.', ultMsgParceiro), 7) = '. $MIC>' then
                begin
                    nikPedeMic:= copy (ultMsgParceiro, 1, (pos ('(', ultMsgParceiro) -1));
                    if conversaPorVoz then
                    begin
                        delete (nikPedeMic, 1, 1);
                        bufTec:= ('+' + nikPedeMic + ' Parceiro ocupado');
                        if enviaRede (DADOTECLADO, @bufTec[1], length (bufTec)) then
                            bufTec:= '';
                        exit;
                    end;
                    ipPedeMic:= copy (ultMsgParceiro, (pos ('>', ultMsgParceiro) +1), length(ultMsgParceiro));
                    aceitaConexao;
                    exit;
                end;

            //Grava log independente do que chega
            if gravandoArq then
                begin
                    writeln (arqGrava, ultMsgParceiro);
                    delay (250);
                end;

            //Não informa mensagens de entrada e saída
            if pulaEntSai then
                if (ultMsgParceiro[1] = '.') or (ultMsgParceiro[1] = '*') then
                    exit;

            //Ativa o efeito do pvt
            if not semEfeito then
                if copy (ultMsgParceiro, pos ('(', ultMsgParceiro), 4) = '(pvt' then
                    begin
                        if copy (maiusc(trim( ultMsgParceiro)), 1, pos ('(', trim(ultMsgParceiro)) - 1) =
                        maiusc (trim(nikName)) then
                            sintSom ('ICQ')
                        else
                            sintSom ('PVT');
                    end;

            //Verifica efeitos especiais
            if pos ('#', ultMsgParceiro) <> 0 then
                if not semEfeito then
                    efeitoParceiro:= copy (ultMsgParceiro, pos ('#', ultMsgParceiro) + 1, length(ultMsgParceiro));
                delete (ultMsgParceiro, pos ('#', ultMsgParceiro), length(ultMsgParceiro));

            //Espera na sala por alguns niks
            if esperaNiks then
                begin
                    if copy (ultMsgParceiro, pos ('(', ultMsgParceiro), 4) = '(pvt' then
                        begin
                            writeln;
                            writeln ('Mensagem privativa / Modo de espera ativado');
                            sintWriteln (ultMsgParceiro);
                            writeln ('-------------------------------------------');
                            writeln;
                            goto fim;
                        end;
                    delete (ultMsgParceiro, 1, 1);

                    checaOsNiks;
                    if esperaNiks then goto fim;
                end;

            if modoAcelerado then
                if copy (ultMsgParceiro, 1, 3) = ' / ' then
                    delete (ultMsgParceiro, 1, 3);

            gotoxy (1, wherey);
            clreol;
            textColor (WHITE);

            if naoQueroOuvir then
                begin
                    sintClek;
                    writeln (ultMsgParceiro);
                end
            else
                begin

                    if comBip then
                        sintBip;

                    while sintFalando do waitMessage;
                    sintWriteln (ultMsgParceiro);

                end;

            textColor (LIGHTGRAY);

            fim:
            if not modoAcelerado then delay (250);
            if efeitoParceiro <> '' then
                if not semEfeito then
                    verificaEfeito;
            if quemSalas then
                if (ultMsgParceiro = 'Tecle / para próxima sala') or (ultMsgParceiro = 'Tecle / para mais') then
                begin
                    bufTec:= '/';
                    ultMsgMinha := bufTec;
//                    delay (100);
                    if not enviaRede (DADOTECLADO, @bufTec[1], length (bufTec)) then;
                    bufTec:= '';
                end;
        end;

end;

{--------------------------------------------------------}
{               processa dados da rede
{--------------------------------------------------------}

function procDadosRede: boolean;
var b0, b1, b2: byte;
    bufao:   array [0..512] of char;
    lidos, aler, lidosAgora: integer;
    p: pointer;
begin
    procDadosRede := false;

    lidosAgora := recv (sock, b0, 1, 0);
    if lidosAgora = 0 then exit;
    lidosAgora := recv (sock, b1, 1, 0);
    if lidosAgora = 0 then exit;
    lidosAgora := recv (sock, b2, 1, 0);
    if lidosAgora = 0 then exit;

    aler := b1 or (b2 shl 8);

    lidos := 0;
    while aler > 0 do
        begin
            p := @bufao[lidos];
            if aler > 512 then
                lidosAgora := recv (sock, p^, 512, 0)
            else
                lidosAgora := recv (sock, p^, aLer, 0);
            if lidosAgora <= 0 then
                exit;

            lidos := lidos + lidosAgora;
            aler := aler - lidosAgora;
        end;
    bufao [lidos] := #$0;
    procDadosRede := true;

    case b0 of
        DADOTECLADO:   begin
                           if modoPapovox then
                               bipSpeaker (47);
                           filaFala [rfilaFala] := strPas (bufao);
                           rfilaFala := (rfilaFala + 1) mod MAXFILAFALA;
                       end;

        INICIOSOM:     trataInicioSom;
        DADOSOM:       trataRecebeSom (bufao, lidos);
        FIMSOM:        trataFimSom;

        INICIOARQENVIA:   trataInicioRecebe (bufao);
        FIMARQENVIA:      begin
                              trataFimRecebe;
                              if wherex <> 1 then writeln;
                          end;
        DADOENVIA:        trataArqRecebe (bufao, lidos);
        CANCARQENVIA:     begin
                              trataCancArqRecebe;
                              if wherex <> 1 then writeln;
                          end;

        PODEMANDAR:       trataInicioTransm;
        CANCELAMANDAR:    trataCancTransm;
    end;
end;

{--------------------------------------------------------}
{           processa teclas comuns
{--------------------------------------------------------}

procedure processaTeclasComuns (c: char);
var confSaida, opcao: char;
    l: integer;

    procedure escreveBufTec;
    begin
        if length (bufTec) < 80 then
            begin
                gotoxy (1, wherey);
                write (buftec);
            end
        else
            begin
                gotoxy (1, wherey);
                write (copy (buftec, length(buftec)-78, 79));
            end;
        clreol;
    end;

begin
    if c = ^b then
        begin
            comBip := not comBip;
            if not comBip then
                sintSom ('PPSEMBIP') {'sem bip'}
            else
                sintsom ('PPCOMBIP') {'com bip'}
        end
    else
    if c = ^c then
        escolheComando
    else
    if c = ^e then
        begin
            esperaNiks:= not esperaNiks;
            if not esperaNiks then
                sintSom ('PPESPDES') {'espera desativada'}
            else
                begin
                    if nikEspecial[1] <> '' then
                        begin
                            mensagem ('PPMESLIS', 0); {'Deseja manter a mesma lista de apelidos ? '}
                            opcao:= sintReadkey;
                            writeln (opcao);
                            if upcase(opcao) = 'S' then
                                exit;
                        end;
                    contNiks:= 0;
                    mensagem ('PPINFAL', 1); {'Informe os apelidos desejados, pressione ENTER para finalizar'}
                    repeat
                        contNiks:= contNiks + 1;
                        sintBip;
                        sintReadln (nikEspecial[contNiks]);
                    until (nikEspecial[contNiks] = '') or (contNiks = 5);
                    sintSom ('PPESPATI'); {'espera ativada'}
                    bufTec:= ' /modo 3';
                    if enviaRede (DADOTECLADO, @bufTec[1], length (bufTec)) then
                                    sintSom ('PPVERSAL'); {'verificando em todas as salas'}
                    bufTec:= '';
                end;
        end
    else
    if c = ^k then
        begin
            desconecta;
            conversaPorVoz:= not conversaPorVoz;
            if not conversaPorVoz then
                mensagem ('PPABRVOZ', 1)   {'Aberta a conexão por voz, poderei enviar ou receber pedidos'}
            else
                mensagem ('PPFECVOZ', 1);  {'Fechada a conexão por voz, não poderei enviar ou receber pedidos'}
        end
    else
    if c = ^p then
        begin
            protegido:= not protegido;
            if not protegido then
                sintSom ('PPSEMPRO') {'sem proteção'}
            else
                sintSom ('PPCOMPRO'); {'com proteção'}
        end
    else
    if c = ^t then
        begin
            modoPapovox:= not modoPapovox;
            if not modoPapovox then
                begin
                    modoAcelerado:= true;
                    sintSom ('PPMODTEL'); {'modo telnet'}
                end
            else
                sintSom ('PPMODPAP'); {'('modo papovox'}
        end
    else
    if c = ^s then
        escolheEfeito
    else
    if c = ^x then
        begin
            poeNoClipboard;
            delay (500);
            if executaProg (dirDosvox + '\edivox.exe', '', dirDosvox + '\papovox.$$$') < 32 then;
                esperaProgVoltar;
            delay (1000);
            sintSom ('FILEDONE');
        end
    else
    if c = ^w then
        pedeConexao
    else
    if c = ^z then
        begin
            poeNoClipboard;
            clrScr;
            while keyPressed do readkey;
            repeat
                delay (100);
            until keyPressed;
        end
    else
    if c = ^q then
        begin
            quemSalas:= not quemSalas;
            if not quemSalas then
                sintSom ('PPQUEDES') {'comando ?quem desativado'}
            else
            begin
                sintSom ('PPQUEATI'); {'comando ?quem ativado'}
                bufTec:= '/';
                ultMsgMinha := bufTec;
//                delay (100);
                if not enviaRede (DADOTECLADO, @bufTec[1], length (bufTec)) then;
                bufTec:= '';
            end;
        end
    else
    if c = ESC then begin
        mensagem ('PPCONSAI', 0);  {'Confirma a saída do bate-papo? S ou N: '}
        confSaida:= sintReadkey;
        writeln;
        if upcase(confSaida) = 'S' then
            begin
                conversando := false;
                while keyPressed do readKey;
                exit;
            end;
    end
    else
    if c = ENTER then
        begin
            sintClek;
            if (bufTec = '') and (meuEfeito = '') then
                begin
                    sintSom ('PPEDIT'); {'editando'}
                    sintEditaDic(bufTec, wherex, wherey, 250, 80, true);
                end;
            if nikName <> '' then
                bufTec:= ('+' + (nikName) + ' ' + (bufTec));
            if meuEfeito <> '' then
                begin
                    bufTec:= (bufTec + meuEfeito);
                    meuEfeito:= '';
                end;
            ultMsgMinha := bufTec;

            l := length (bufTec);
            if l = 0 then bufTec := ' ';
            if not enviaRede (DADOTECLADO, @bufTec[1], l) then
                 conversando := false;

            gotoxy (1, wherey);
            writeln (copy (bufTec, 1, 79));
            bufTec := '';
        end

    else
    if c = ^Y then
       begin
           gotoxy (1, wherey);
           clreol;
           sintSom ('_CPOAPA');
           bufTec := '';
       end

    else
    if c = BS then
        begin
            if bufTec <> '' then
                begin
                     sintSom ('_DEL');
                     sintCarac (bufTec [length(bufTec)]);
                     delete (bufTec, length(bufTec), 1);
                end;
            escreveBufTec;
        end
    else
        begin
            if length (bufTec) > maxtec-1 then
                sintBip
            else
                begin
                    bufTec := bufTec + c;
                    escreveBuftec;
                    if soletrando then
                        sintCarac (c);
                end;
        end;

end;

{--------------------------------------------------------}
{            tratamento das teclas de função
{--------------------------------------------------------}

procedure processaFuncoesDeTeclado (c: char);
var
    xc, yc: integer;
begin

    if c = F9 then
    begin
        c := selSetasFolheiaFun;
        if c = ESC then exit;
        if c = ENTER then
        begin
            c := selSetasFolheiaCom;
            if c <> ESC then
                processaTeclasComuns (c);
            exit;
        end;
    end;

    if (c in [F2, F3, F5]) and (wherex <> 1) then processaTeclasComuns (ENTER);

    case c of
        F1:  ajudaTeclado;
     CTLF1:  if buftec = '' then
                 sintetiza (ultMsgMinha)
             else
                 sintetiza (buftec);
        F2: begin
           if (selecionado <> 'chat.saci.org.br') and (selecionado <> '143.107.250.203') then
               transmiteArq
           else
               mensagem ('PPSACI', 1);   {'O chat da Rede Saci não suporta essa operação, desculpe'}
           end;
     CTLF2: leArquivo;
        F3: begin
           if (selecionado <> 'chat.saci.org.br') and (selecionado <> '143.107.250.203') then
               cancelaRecepcao
           else
               mensagem ('PPSACI', 1);   {'O chat da Rede Saci não suporta essa operação, desculpe'}
           end;
     CTLF3: begin
           if not gravandoArq then
               begin
                   assign (arqGrava, nomeArqLog);
                   {$i-} append (arqGrava); {$i+}
                   if IOresult <> 0  then
                       {$i-} rewrite (arqGrava); {$i+}
                   writeln (arqGrava, '--- Iniciando a gravação ---');
                   mensagem ('PPGRMSG', 1);  {'Irei gravar as mensagens'}
                   gravandoArq:= true;
               end
               else
                   begin
                       {$i-} close (arqGrava); {$i+}
                       if IOresult <> 0  then;
                       mensagem ('PPNGRMSG', 1);  {'Não irei gravar as mensagens'}
                       gravandoArq:= false;
                   end;
     end;
        F4:  alteraFala;
     CTLF4: begin
           naoQueroOuvir:= not naoQueroOuvir;
           if naoQueroOuvir then
               sintSom ('PPSEMSIN') {'Sem síntese de voz'}
           else
               sintSom ('PPCOMSIN'); {'Com síntese de voz'}
           end;
        F5:  enviaMsgUrgente;
     CTLF5: begin
           if nikName <> '' then
           begin
               nikName:= '';
               writeln;
               mensagem ('PPENVTOD', 1);  {'Enviando para todos'}
           end
           else
               begin
                   writeln;
                   mensagem ('PPINFAPE', 0);  {'Informe o apelido desejado: '}
                   sintReadln (nikName);
                   if nikName = '' then
                       exit;
                   mensagem ('PPENVAPE', 0);  {'Ok, enviando apenas para '}
                   sintWriteln (nikName);
               end;
     end;
        F6:  informaIp;
     CTLF6: begin
           pulaEntSai:= not pulaEntSai;
           if pulaEntSai then
               mensagem ('PPMSGINB', 1)   {'Mensagens de entrada e saída estão inibidas'}
           else
               mensagem ('PPMSNINB', 1);  {'Mensagens de entrada e saída não estão inibidas'};
     end;
     F7:  sintetiza (ultMsgParceiro);
     CTLF7:  sintetiza (ultMsgMinha);
     F8:  informaTempos;
     CTLF8: begin
           semEfeito:= not semEfeito;
           if semEfeito then
               mensagem ('PPEFEINB', 1)   {'Os sons de efeito estão inibidos'}
           else
               mensagem ('PPEFNINB', 1); {'Os sons de efeito não estão inibidos'}
     end;
     CTLF9:  begin
                 sintBip; sintBip;
                 xc := wherex;
                 yc := wherey;
                 window (1, 1, 80, 25);
                 gotoxy (xc, yc);
                 leitorDeTela;
                 window (1, 1, 80, 24);
                 gotoxy (xc, yc);
     end;
     CTLF11: begin
                 comDic:= not comDic;
                 if not comDic then
                 begin
                        fechaDic;
                        sintSom ('PPDD'); {'dicionário desativado'}
                 end;
                 if comDic then
                        if carregaDic (nomeArqDic, nomeArqSufixos, nomeArqInexist, nomeArqNomes, nomeArqSugTroca) = 0 then
                            sintSom ('PPDA') {'Dicionário ativado'}
                        else
                            sintSom ('PPNCD'); {'Não pude carregar o dicionário'}
                 end;
     BAIX: sintClek;
     cima: leitorDeTela;

    else
        mensagem ('PPAPTF1', 1);   {Aperte F1 para ajuda}
    end;
end;

{--------------------------------------------------------}
{                  realiza o bate papo
{--------------------------------------------------------}

procedure batePapo;
var
    inibate, fimbate: string;
    c: char;
    lidosDisco: integer;
    seg, centSeg: word;
    i: integer;

const podeEnviarSom = false;

label comunicCaiu, fecha, fimEnvioSom;

    {--------------------------------------------------------}

    procedure economizaCPU;
    begin

        if temMsgUrgente or enviandoSom or enviandoArq or
           chegouRede (sock) then
                 exit;

        if ffilaFala <> rfilaFala then
           if (not modoPapovox) or (wherex = 1) then
                 exit;

        if podeEnviarSom then
           if (((getkeystate (vk_shift) shr 15) and 1) <> 0) and
              (((getkeystate (vk_control) shr 15) and 1) <> 0) then
                    exit;

        delay (30);
    end;

    {--------------------------------------------------------}

begin
    while keypressed do readkey;

    dvcrt.gettime (horaConec, minConec, seg, centSeg);

    window (1,1,80,25);
    clrScr;

    inibate := sintAmbiente ('PAPOVOX', 'SOMINIBATE');
    sintsom (inibate);
    logonUsuario (enderUsuario, 'talking');

    mensagem ('PPINIPAP', 1);  {Iniciando bate papo}

    textBackground (BLUE);
    gotoxy (1, 25);
    mensagem ('PPESCTRM', 0);   {Tecle ESC para desligar, F1 para ajuda}
    textBackground (BLACK);
    window (1,1,80,24);
    gotoxy (1, 4);

    bufTec := '';
    enviandoSom := false;
    enviouTodoSom := true;

    ffilaFala := 0;
    rfilaFala := 0;

    autorEnvioPendente := false;
    enviandoArq := false;
    recebendoArq := false;

    ultMsgParceiro := '';
    ultMsgMinha := '';

    meuEfeito:= '';
    efeitoParceiro:= '';
    nikName:= '';
    modoPapovox:= true;
    conversaPorVoz:= true; //Proteção: simula que está conversando

    carregaEfeitos;
    carregaComandos;

    conversando := true;
    while conversando do
        begin
            {--- processamento do teclado ---}

            while keypressed do
                begin
                   c := readkey;
                   if c <> #$0 then
                       processaTeclasComuns (c)
                   else
                       begin
                           c := readkey;
                           processaFuncoesDeTeclado (c);
                       end;
                end;

            if not modoPapovox then
                falaDaFila
            else
                begin
                    if wherex = 1 then
                        falaDaFila;
                end;

            {--- processamento de mensagem urgente ---}

            if not protegido then
                begin
                    if temMsgUrgente then
                        begin
                            if wherex <> 1 then writeln;
                                recebeMsgUrgente;
                        end;
                end;  //Relativo ao modo protegido

            {--- processamento da chegada de rede ---}

            if chegouRede (sock) then
                 if not procDadosRede then
                     conversando := false;

            {--- processamento da bufferizacao do som ---}

            if not podeEnviarSom then goto fimEnvioSom;

            if (((getkeystate (vk_shift)   shr 15) and 1) <> 0) and
               (((getkeystate (vk_control) shr 15) and 1) <> 0) then
                begin
                    if (not enviandoSom) and enviouTodoSom then
                        inicioEnvioSom;
                    monitoraBuffersSom;
                end
            else
                begin
                   if enviandoSom then
                       begin
                           terminaGravacao;
                           reset (arqGravador, 1);   { para poder continuar lendo }
                           enviandoSom := false;
                       end;
                end;

            if (not enviandoSom) and (not enviouTodoSom) then
                if tamSomEnviado < tamGravado then
                    monitoraBuffersSom
                else
                    terminaEnvioSom;
fimEnvioSom:
            {--- processamento do envio do arquivo ---}

            if enviandoArq and (not autorEnvioPendente) then
                begin
                    if eof (arqEnvia) then
                        begin
                            close (arqEnvia);
                            if not enviaRede (FIMARQENVIA, NIL, 0) then
                                 goto comunicCaiu;
                            mensagem ('PPBEMTRA', 1);   {Arquivo bem transmitido}
                            enviandoArq := false;
                            autorEnvioPendente := false;
                        end
                    else
                        begin
                            {$I-}  blockRead (arqEnvia, bufEnvia, 512, lidosDisco);   {$I+}
                            if ioresult <> 0 then
                                begin
                                    mensagem ('PPPROTRA', 1);   {Problemas na transmissão do arquivo}
                                    if not enviaRede (CANCELAMANDAR, NIL, 0) then
                                         goto comunicCaiu;
                                end
                            else
                            if not enviaRede (DADOENVIA, @bufEnvia, lidosDisco) then
                                 goto comunicCaiu;

                            contaSpeaker := contaSpeaker + 1;
                            if contaSpeaker > 8 then
                                begin
                                    bipSpeaker (44);
                                    contaSpeaker := 0;
                                end;
                        end;
                end;

            economizaCPU;
        end;

fecha:
    window (1, 1, 80, 25);
    gotoxy (1, 25);
    clreol;
    writeln;

    fechaConexao (sock);

    if gravandoArq then
        begin
            {$i-} close (arqGrava); {$i+}
            if IOresult <> 0  then;
            gravandoArq:= false;
        end;

    esperaNiks:= false;
    for i := 1 to 5 do
        nikEspecial [i]:= '';
    contNiks:= 0;

    conversaPorVoz:= true;

    fimbate:= sintAmbiente ('PAPOVOX', 'SOMFIMBATE');
    sintsom (fimbate);
    mensagem ('PPFIMPAP', 1);  {Fim do bate papo}

    logonUsuario (enderUsuario, 'endtalk');
    exit;

comunicCaiu:
    mensagem ('PPERRCOM', 1);   {Erro de comunicação na Internet}
    goto fecha;
end;

{--------------------------------------------------------}
{      Escolhe com as setas o comando a ser executado
{--------------------------------------------------------}

procedure escolheComando;
var c1, c2: char;
    contComandos: integer;
    comando, nome, msg: string;
    processando: boolean;
label executa;
begin

    if numDeComandos = 0 then
        begin
            mensagem ('PPERRCM1', 1);   {'Não existe nenhum comando relacionado em sua lista'}
            mensagem ('PPERRCM2', 1);   {O arquivo comsaci.ini está vazio ou foi danificado'}
            mensagem ('PPERREF3', 1);   {Por favor, consulte o manual'}
            exit;
        end;

    comando:= '';
    contComandos:= 0;

    processando := true;
    mensagem ('PPESCSET', 1);  {'Escolha com as setas'}
    writeln;

    while (processando)  do
       begin

           sintLeTecla (c1, c2);

           if (c1 = #0) and (c2 = CIMA) then
                begin
                    contComandos:= contComandos - 1;
                    if contComandos < 1 then
                        begin
                            contComandos:= 0;
                            sintBip;
                        end
                    else
                        sintWriteln (copy (comandoSaci[contComandos], 1,
                        pos ('=', comandoSaci[contComandos]) - 1 ));
                end
           else
           if (c1 = #0) and (c2 = BAIX) then
                begin
                    contComandos:= contComandos + 1;
                    if contComandos > numDeComandos then
                        begin
                            contComandos:= numDeComandos + 1;
                            sintBip;
                        end
                    else
                        sintWriteln (copy (comandoSaci[contComandos], 1,
                        pos ('=', comandoSaci[contComandos]) - 1 ));
                end
           else
           if (c1 = #0) and (c2 = HOME) then
                begin
                contComandos:= 1;
                        sintWriteln (copy (comandoSaci[contComandos], 1,
                        pos ('=', comandoSaci[contComandos]) - 1 ));
                end
           else
           if (c1 = #0) and (c2 = TEND) then
                begin
                contComandos:= numDeComandos;
                        sintWriteln (copy (comandoSaci[contComandos], 1,
                        pos ('=', comandoSaci[contComandos]) - 1 ));
                end
           else
           if (c1 = #0) and (c2 = PGUP) then
               begin
                   contComandos:= contComandos - 5;
                   if contComandos < 1 then
                       contComandos:= 1;
                   sintWriteln (copy (comandoSaci[contComandos], 1,
                        pos ('=', comandoSaci[contComandos]) - 1 ));
               end
           else
           if (c1 = #0) and (c2 = PGDN) then
               begin
                   contComandos:= contComandos + 5;
                   if contComandos > numDeComandos then
                       contComandos:= numDeComandos;
                   sintWriteln (copy (comandoSaci[contComandos], 1,
                        pos ('=', comandoSaci[contComandos]) - 1 ));
               end
           else
           if (c1 = #0) and (c2 = F1) then
               begin
                   mensagem ('PPENV0', 1);  {'Para enviar tecle ENTER e para desistir tecle ESC'}
                   mensagem ('PPENV3', 1);  {'PGUP, anda 5 na fila'}
                   mensagem ('PPENV4', 1);  {'PGDN, volta 5 na fila'}
                   mensagem ('PPENV5', 1);  {'HOME, vai para o início da fila'}
                   mensagem ('PPENV6', 1);  {'END, vai para o final da fila'}
               end
           else
executa:
               case upcase(c1) of

                    ENTER: begin
                        if (contComandos = 0) or (contComandos = numDeComandos + 1) then
                        begin sintClek; exit; end;
                       processando:= false;
                   end;
                   ESC: begin sintClek;  exit; end;
               else
                   mensagem ('PPAPTF1', 1);  {'Opção inválida, aperte F1 para ajuda'}
               end;
       end;

    comando := comandoSaci[contComandos];
    comando := copy(comando, pos ('=', comando) + 1, length(comando));
    if comando = '' then
        exit;

    if pos('*', comando) <> 0 then
    begin
        writeln;
        mensagem ('PPINFASS', 0);     {'Informe o apelido, a sala ou a senha: '}
        sintReadln (nome);
        writeln;
        if nome = '' then
            exit;
        insert ((nome), comando, pos ('*', comando));
        delete (comando, pos ('*', comando), 1);
    end;

    if pos('@', comando) <> 0 then
    begin
        writeln;
        mensagem ('PPINFMSG', 0);     {'Informe a mensagem a enviar: '}
        sintEditaDic(msg, wherex, wherey, 250, 80, true);
        writeln;
        if msg = '' then
            exit;
        insert ((msg), comando, pos ('@', comando));
        delete (comando, pos ('@', comando), 1);
    end;

    bufTec := comando;
    ultMsgMinha := bufTec;
    if enviaRede (DADOTECLADO, @bufTec[1], length (bufTec)) then
    bufTec:= '';
    sintSom ('PPOK'); {'ok'}

end;

{--------------------------------------------------------}
{      busca trecho à esquerda do sinal de igual
{--------------------------------------------------------}

function esqDoIgual (som: string): string;
begin
    result := copy (som, 1, pos ('=', som) - 1);
end;

{--------------------------------------------------------}
{      Escolhe com as setas o efeito a ser tocado
{--------------------------------------------------------}

procedure escolheEfeito;
var c1, c2: char;
    contEfeitos: integer;
    p: char;
    processando: boolean;
    constaLetra: boolean;
    ef: string;

label executa, de_novo;
begin

    if numDeEfeitos = 0 then
        begin
            mensagem ('PPERREF1', 1);   {'Não existe nenhum efeito relacionado em sua lista'}
            mensagem ('PPERREF2', 1);   {O arquivo sompapo.ini está vazio ou foi danificado'}
            mensagem ('PPERREF3', 1);   {Por favor, consulte o manual'}
            exit;
        end;

    meuEfeito:= '';
    contEfeitos:= 0;
    constaLetra:= false;
    p:= '-';

    processando := true;
    mensagem ('PPESCSET', 1);  {'Escolha com as setas'}
    writeln;

    while (processando)  do
       begin

           sintLeTecla (c1, c2);

           de_novo:

           if upcase(c1) in ['A'..'Z'] then
           begin
                   contEfeitos:= contEfeitos + 1;
                   for contEfeitos:= contEfeitos to numDeEfeitos do
                   begin
                       if semAcentos(upcase(c1)) = semAcentos(
                                             maiusc(copy (somDeEfeito[contEfeitos], 1, 1))) then
                       begin
                           constaLetra:= true;
                           p:= c1; //Atender CTLF5, anteriormente implementada
                           sintWriteln (esqDoIgual (somDeEfeito[contEfeitos]));
                           break;
                       end
                       else
                           constaLetra:= false;
                   end; //Final do FOR
           if p = '-' then
           begin
               mensagem ('PPNAOINI', 1); {'Não consta arquivo com essa inicial'}
               exit;
           end;
           if (not constaLetra) or (numDeEfeitos < contEfeitos) then
           begin
               contEfeitos:= 0;
               p:= '-';
               goto de_novo;
           end;
           end
           else
           if (c1 = #0) and (c2 = CIMA) then
                begin
                    contEfeitos:= contEfeitos - 1;
                    if contEfeitos < 1 then
                        begin
                            contEfeitos:= 0;
                            sintBip;
                        end
                    else
                        sintWriteln (esqDoIgual (somDeEfeito[contEfeitos]));
                end
           else
           if (c1 = #0) and (c2 = BAIX) then
                begin
                    contEfeitos:= contEfeitos + 1;
                    if contEfeitos > numDeEfeitos then
                        begin
                            contEfeitos:= numDeEfeitos + 1;
                            sintBip;
                        end
                    else
                        sintWriteln (esqDoIgual (somDeEfeito[contEfeitos]));
                end
           else
           if (c1 = #0) and (c2 = HOME) then
                begin
                    contEfeitos:= 1;
                    sintWriteln (esqDoIgual (somDeEfeito[contEfeitos]));
                end
           else
           if (c1 = #0) and (c2 = TEND) then
                begin
                contEfeitos:= numDeEfeitos;
                        sintWriteln (esqDoIgual (somDeEfeito[contEfeitos]));
                end
           else
           if (c1 = #0) and (c2 = PGUP) then
               begin
                   contEfeitos:= contEfeitos - 5;
                   if contEfeitos < 1 then
                       contEfeitos:= 1;
                   sintWriteln (esqDoIgual (somDeEfeito[contEfeitos]));
               end
           else
           if (c1 = #0) and (c2 = PGDN) then
               begin
                   contEfeitos:= contEfeitos + 5;
                   if contEfeitos > numDeEfeitos then
                       contEfeitos:= numDeEfeitos;
                   sintWriteln (esqDoIgual (somDeEfeito[contEfeitos]));
               end
           else
           if (c1 = #0) and (c2 = DEL) then
                   begin
                       if somDeEfeito[contEfeitos][1] <> '-' then
                           begin
                               somDeEfeito[contEfeitos]:= '-' + somDeEfeito[contEfeitos];
                               sintSom ('PPREMLIS'); {'Removido da lista'}
                               end;
                   end
           else
           if (c1 = #0) and (c2 = INS) then
                   begin
                       if somDeEfeito[contEfeitos][1] = '-' then
                           begin
                               delete (somDeEfeito[contEfeitos], 1, 1);
                               sintSom ('PPRECLIS'); {'Recuperado na lista'}
                           end;
                   end
           else
           if (c1 = #0) and (c2 = F1) then
               begin
                   mensagem ('PPENV0', 1);  {'Para enviar tecle ENTER e para desistir tecle ESC'}
                   mensagem ('PPENV1', 1);  {'F5, busca efeito'}
                   mensagem ('PPENV2', 1);  {'CTRL+F5, busca de novo'}
                   mensagem ('PPENV3', 1);  {'PGUP, anda 5 na fila'}
                   mensagem ('PPENV4', 1);  {'PGDN, volta 5 na fila'}
                   mensagem ('PPENV5', 1);  {'HOME, vai para o início da fila'}
                   mensagem ('PPENV6', 1);  {'END, vai para o final da fila'}
                   mensagem ('PPENV7', 1);  {'DEL, remove da lista'}
                   mensagem ('PPENV8', 1);  {'INS, recupera na lista'}
               end
           else
           if (c1 = #0) and (c2 = F5) then
               begin
                   writeln;
                   mensagem ('PPBUSEFE', 0);   {'Digite uma letra: '}
                   p := upcase(sintReadkey);
                   if not (p in ['A'..'Z']) then exit;

                   for contEfeitos:= 1 to numDeEfeitos do
                       begin
                           ef := somDeEfeito[contEfeitos];
                           if semAcentos(p) = semAcentos(maiusc(copy (ef, 1, 1))) then
                               break;
                       end;
                   sintWriteln (copy (ef, 1, pos ('=', ef) - 1 ));
               end
           else
           if (c1 = #0) and (c2 = CTLF5) then
               begin
                   if p = '-' then
                       exit;
                   contEfeitos:= contEfeitos + 1;
                   for contEfeitos:= contEfeitos to numDeEfeitos do
                       if semAcentos(upcase(p)) = semAcentos(maiusc(copy (somDeEfeito[contEfeitos], 1, 1))) then
                           break;
                   sintWriteln (esqDoIgual (somDeEfeito[contEfeitos]));
               end
           else
executa:
               case upcase(c1) of
                   ENTER: begin
                       if (contEfeitos = 0) or (contEfeitos = numDeEfeitos + 1) then
                           begin
                               sintClek;
                               exit;
                           end;
                       meuEfeito:= (esqDoIgual (somDeEfeito[contEfeitos]));
                       processando:= false;
                   end;
                   ESC: begin
                       sintClek;
                       exit;
                   end;
               else
                   mensagem ('PPAPTF1', 1);  {'Opção inválida, aperte F1 para ajuda'}
               end;
       end;

    meuEfeito:= ' #' + meuEfeito;
    processaTeclasComuns (ENTER);

end;

{--------------------------------------------------------}
{           Identifica o efeito a ser tocado
{--------------------------------------------------------}

procedure verificaEfeito;
var i: integer;
    podeTocar: boolean;
    salva: boolean;
    dirSons: string;
label sair;
begin

    if keyPressed then
        goto sair;

    efeitoParceiro:= maiusc(efeitoParceiro);

    podeTocar:= false;
    for i:= 1 to numDeEfeitos do
        if efeitoParceiro = maiusc (esqDoIgual (somDeEfeito[i])) then
            begin
                podeTocar:= true;
                break;
            end;

    if (efeitoParceiro[1] = '-') or (not podeTocar) then
        begin
            writeln ('          Não posso tocar ---' + (efeitoParceiro) + '---');
            sintSom ('INVALIDO');
            goto sair;
        end;

    salva := compactWaves;
    compactWaves := false;
    while sintFalando do waitMessage;

    dirSons :=  sintambiente ('PAPOVOX', 'DIRPAPOVOX');
    if dirSons = '' then
        dirSons := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\papovox';

    wavePlayFile (dirSons + '\EFEITOS\' +
                  maiusc (copy (somDeEfeito[i], pos ('=', somDeEfeito[i]) + 1,
                  length (somDeEfeito[i]))) + '.WAV');
    while waveIsPlaying do;
    compactWaves := salva;

sair:
    efeitoParceiro:= '';
    delay (250);

end;

{--------------------------------------------------------}
{     Carrega num vetor os comandos do chat Saci
{--------------------------------------------------------}

procedure carregaComandos;
var arqComandos: text;
    s: string;
begin

    numDeComandos:= 0;

    assign (arqComandos, nomeArqComandos);
    {$i-} reset (arqComandos); {$i+}
    if ioResult <> 0 then
        exit;

    while (not eof(arqComandos)) or (numDeComandos = 49) do
        begin
            readln (arqComandos, s);
            if s[1] <> ';' then
                begin
                    numDeComandos:= numDeComandos + 1;
                    comandoSaci[numDeComandos]:= s;
                end;
        end;
    close (arqComandos);

end;

{--------------------------------------------------------}
{     Carrega num vetor o nome dos arquivos de efeito
{--------------------------------------------------------}

procedure carregaEfeitos;
var arqEfeitos: text;
    s: string;
    i, j: integer;
begin

    numDeEfeitos:= 0;

    assign (arqEfeitos, nomeArqEfeitos);
    {$i-} reset (arqEfeitos); {$i+}
    if ioResult <> 0 then
        exit;

    while not eof(arqEfeitos) do
        begin
            readln (arqEfeitos, s);
            if (s[1] <> ';') and (numDeEfeitos < MAXEFEITOS) then
                begin
                    numDeEfeitos:= numDeEfeitos + 1;
                    somDeEfeito[numDeEfeitos]:= s;
                end;
        end;
    close (arqEfeitos);

    if numDeEfeitos > 2 then
        begin
                for i:= 1 to numDeEfeitos - 1 do
                for j:= i + 1 to numDeEfeitos do
                    if semAcentos(somDeEfeito[i]) > semAcentos(somDeEfeito[j]) then
                        begin
                            s:= somDeEfeito[i];
                            somDeEfeito[i]:= somDeEfeito[j];
                            somDeEfeito[j]:= s;
                        end;
        end;

end;

{--------------------------------------------------------}
{              Lê conteúdo de um arquivo
{--------------------------------------------------------}

procedure leArquivo;
var arqPronto: text;
    nomeDoArq: string;
    passaBatido: boolean;
    opcao: char;
label fazNada, fim;
begin

    mensagem ('PPIARQE', 1);  {'Informe o nome completo do arquivo a enviar: '}
    garanteEspacoTela (10);
    nomeDoArq:= obtemNomeArq (10);
    writeln (nomeDoArq);
    if nomeDoArq = '' then
        exit;

    assign (arqPronto, nomeDoArq);
    {$i-} reset (arqPronto); {$i+}
    if IOresult <> 0  then
        begin
            mensagem ('PPANAOEX', 1); {'Arquivo não existe'}
            nomeDoArq:= 'envia.$$$';
            if executaProg (dirDosvox + '\edivox.exe', '', nomeDoArq) < 32 then;
            esperaProgVoltar;
            delay (1000);
            assign (arqPronto, nomeDoArq);
            {$i-} reset (arqPronto); {$i+}
            if IOresult <> 0  then
                exit;
        end;

    nikName:= '';
    mensagem ('PPINFNOP', 0);  {'Informe o parceiro que irá receber, ENTER para todos: '}
    sintReadln (nikName);
    if nikName = '' then
        mensagem ('PPENVTOD', 1)  {'Enviando para todos os presentes'}
    else
        begin
            mensagem ('PPENVAPN', 0);  {'Enviando apenas para '}
            sintWriteln (nikName);
        end;

    mensagem ('PPPRESTC', 1); {'Pressione ESC para sair, ENTER para enviar a linha ou CTRL+ENTER para todo arquivo'}
    delay (1000);
    opcao := ' ';
    passaBatido:= false;

    while not eof (arqPronto) do
        begin
            readln (arqPronto, bufTec);
            if bufTec = '' then goto fazNada;  // nunca envia linhas em branco

            if nikName <> '' then
                bufTec:= ('+' + (nikName) + ' ' + (bufTec));
            ultMsgMinha := bufTec;

            sintWriteln (ultMsgMinha);
            sintBip;

            if not passaBatido then
                begin
                    opcao:= readKey;
                    if opcao = #0 then
                        opcao:= readKey;
                end;

            if opcao = #10 then
                begin
                    passaBatido:= true;
//                    delay (3000);
                    if not enviaRede (DADOTECLADO, @bufTec[1], length (bufTec)) then
                        goto fim;
                end;

            if opcao = #27 then
                goto fim;

            if opcao = #13 then
                if not enviaRede (DADOTECLADO, @bufTec[1], length (bufTec)) then
                    goto fim;

            fazNada:
        end;

fim:
    close (arqPronto);
    if nomeDoArq = 'envia.$$$' then
        erase (arqPronto);
    bufTec:= '';
    while keyPressed do readKey;

    sintBip;
    mensagem ('PPFIMTRS', 1);  {'Fim da transmissão'}

    if nikName <> '' then
        begin
            nikName:= '';
            sintBip; sintBip;
            mensagem ('PPVOLENV', 1);  {'Voltei a enviar para todos os presentes'}
        end;

end;

end.
