{--------------------------------------------------------}
{
{           cartaVox - rotinas para tratamento de Spam
{
{--------------------------------------------------------}

unit carSpam;

interface

uses
    dvinet,
    dvssl,
    winsock,
    classes,
    dvarq,
    dvcrt,
    dvexec,
    dvForm,
    dvWin,
    sysutils,
    windows,
    carMsg,
    carUtil,
    carEst,
    CARLIST,
    carbloque,
    careMudo,
    CarCopia,
    CarDecod,
    carVars;

function mataSpam (mudo: boolean): integer;
procedure adicionaNoMataSpam (nCar: integer; bloquear: boolean);
function matarSpansNaoLidas(contaAtual, mudo: boolean): integer;

implementation

{-------------------------------------------------------------}
{       Cria o arquivo de bloqueados padrão
{-------------------------------------------------------------}

procedure criaArqBloqueados (nomeArq: string);
var
    arq: text;
begin
    assign (arq, nomeArq);
    {$i-} rewrite (arq); {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('MSERRESC', 1); {'Erro de escrita no arquivo'}
            exit;
        end;

    {$i-} writeln (arq, '.SCR'); {$I+}
    if ioresult <> 0 then
        mensagem ('MSERRESC', 1) {'Erro de escrita no arquivo'}
    else
        begin
            writeln (arq, '+[VOXTEC]');
            writeln (arq, '+[DOSVOX-L]');
            writeln (arq, 'KOI8-R');
            writeln (arq, 'ISO-2022-JP');
            writeln (arq, '.EXE');
            writeln (arq, '!.ZIP');
            writeln (arq, 'DISCOUNT');
            writeln (arq, 'INCREASE');
            writeln (arq, 'CURRENT');
            writeln (arq, 'EMAGRECA-DORMINDO');
            writeln (arq, 'EMAGRECER-DORMINDO');
            writeln (arq, 'THE "');
            writeln (arq, 'THAT "');
            writeln (arq, 'THAT "');
            writeln (arq, 'WILL "');
            writeln (arq, 'DEBT "');
            writeln (arq, 'PILLS');
            writeln (arq, 'ENLARGEMENT');
            writeln (arq, 'ONLINE CASINO');
            writeln (arq, '.CHARGES');
            writeln (arq, 'CLIQUE AQUI');
            writeln (arq, 'MEDICATION');
        end;

    {$i-} close (arq); {$I+}
    if ioresult <> 0 then;
end;

{-------------------------------------------------------------}
{       Adiciona um ou os selecionados no arquivo do Mata Spam, bloqueando ou desbloqueando.
{-------------------------------------------------------------}

procedure adicionaNoMataSpam (nCar: integer; bloquear: boolean);
var
    c: char;
    i: integer;
    selecionados, selecionado: boolean;
    remetente, nomeArq: string;
    sl: TStringList;

    function carregaArquivo(nomeArq: string): boolean;
    begin
        carregaArquivo := true;
        sl := TStringList.Create;
        try
            sl.LoadFromFile(nomeArq);
        except
            carregaArquivo := false;
            msgBaixo('CTERRLEI'); {'Erro de leitura do arquivo'}
            sl.Free;
        end;
    end;

    procedure escreveNoArqMataSpam(s: string; bloquear: boolean );
    var i, k: integer;
    begin
        k := sl.Count -1;
        for i := k downto 0 do
            if (sl[i] = s) or (sl[i] = ('+' + s)) then
                sl.Delete(i);

        if not bloquear then s := '+' + s;
        sl.add(s);
    end;

    function salvaDescarregaArquivo(nomeArq: string): boolean;
    begin
        salvaDescarregaArquivo := true;
        try
            sl.SaveToFile(nomeArq);
            sl.Free;
        except
            salvaDescarregaArquivo := false;
            msgBaixo('CTERRDSK'); {'Erro de escrita no disco'}
        end;
    end;

begin
    //Pega o nome do arquivo e associa a variável do tipo text
    nomeArq := sintAmbiente('MATASPAM', 'ARQBLOQUEADOS');
    if (nomeArq = '') or (pos('@\', nomeArq) <> 0) then
        nomeArq := sintDirAmbiente + '\msbloque.ini';

    if not existeArq (nomearq) then criaArqBloqueados (nomeArq);

    //Para saber se adiciona os itens selecionados
    if temItemSelecionado then
        begin
            repeat
                if bloquear then
                    msgBaixo ('CTADBSEL') {'Deseja bloquear todos os selecionados? '}
                else
                    msgBaixo ('CTADLSEL'); {'Deseja liberar todos os selecionados? '}
                c := upcase(popupMenuPorLetra ('SN'));
            until c in ['S', 'N', ESC];
            if c = ESC then
                begin
                    msgBaixo ('CTDESIST');   {'Desistiu'}
                    exit;
                end;
            selecionados := c = 'S';
        end
    else
        selecionados := false;

    //Adiciona no arquivo
    if selecionados then
        begin
            if carregaArquivo(nomeArq) then
                begin
                    for i := 1 to numRegs do
                        begin
                            if (i mod 500) = 0 then sintclek;
                            if not regLido [i]^.selecionado then continue;
                            if not regLido [i]^.carta^.preenchido then
                                begin
                                    selecionado := regLido [i]^.selecionado;
                                    carregaArqPreencheCabPrin ( i);
                                    regLido [i]^.selecionado := selecionado;
                                end;
                            remetente := retornaEMail (regLido [i]^.carta^.from);
                            if (remetente = '') or (pos('@', remetente) = 0) then continue;
                            escreveNoArqMataSpam(remetente, bloquear);
                        end;
                    if salvaDescarregaArquivo(nomeArq) then
                        msgBaixo ('CTOK');   {'Ok'}
                end;
        end
    else
        begin
            remetente := regLido [nCar]^.carta^.from;
            repeat
                sintbip;
                if bloquear then
                    mensagem ('CTBLOQUE', -1) {'Bloquear'}
                else
                    mensagem ('CTLIBERA', -1); {'Liberar'}
                sintbip;
                sintetiza(remetente);
                if bloquear then
                    msgBaixo ('CTBLOREM') {'Deseja bloquear este remetente no Mata Spam?'}
                else
                    msgBaixo ('CTLIBREM'); {'Deseja liberar este remetente no Mata Spam?'}
                c := upcase(popupMenuPorLetra ('SN'));
            until c in ['S', 'N', ESC];
            if c <> 'S' then
                begin
                    msgBaixo ('CTDESIST');   {'Desistiu'}
                    exit;
                end;
            remetente := retornaEMail (remetente);
            if (remetente = '') or (pos('@', remetente) = 0) then
                msgBaixo('CTERRCAB') {'Erro no cabeçalho da carta '}
            else
            if carregaArquivo(nomeArq) then
                begin
                    escreveNoArqMataSpam(remetente, bloquear);
                    if salvaDescarregaArquivo(nomeArq) then
                        msgBaixo ('CTOK');   {'Ok'}
                end;
        end;
end;

{-------------------------------------------------------------}
{       Mata Spans das cartas não lidas da configuração atual
{-------------------------------------------------------------}

function matarSpansNaoLidas(contaAtual, mudo: boolean): integer;
var
    c: char;
    i, nspans: integer;
    dirAtual, s: string;
    bipPermitido: boolean;
    statusLinha, statusSpam: integer;

label fim;
begin
    matarSpansNaoLidas := 0;
    getDir (0, dirAtual);
    {$I-}  chdir (dirRecebe);  {$I+}
    if ioresult <> 0 then ;

    if contaAtual then
        montaListaDeCartas ('CAR', ^N)
    else
        montaListaDeCartas ('CAR', 'N');

    if numRegs = 0 then
        begin
            if not mudo then msgBaixo('CTNAOLID'); {'Não lidas'}
            if not mudo then msgBaixo ('CTSEMCAR');  {'Não tem carta neste diretório'}
            exit;
        end;

    if not carregaArqProibidas then goto fim;
    if not mudo then
        begin
            mensagem ('CTMATSPA', 0); {'Matando spans'}
            sintWriteInt (numRegs); write(' ');
            if numRegs > 1 then
                mensagem ('CTCARTAS', 1) {'Cartas'}
            else
                mensagem ('CTCARTA', 1); {'Carta'}
        end;

    bipPermitido := uppercase(( sintAmbiente('CARTAVOX', 'CLEK') + 'S')[1]) = 'S';
    nspans := 0;
    for i := 1 to numRegs do
        begin
            if keypressed then
                begin
                    while keypressed do c := readkey;
                    if c = #$1b then break;
                    if c = ' ' then
                        bipPermitido := not bipPermitido
                    else
                        begin
                            writeln;
                            write (' ');
                            sintWriteInt (i);
                            mensagem ('CTDE', 0);{' de '}
                            sintWriteInt (numRegs);
                        end;
                end;
            if (bipPermitido) and ((i mod 200) = 0) then sintClek;

            carregaArqPreencheCabPrin (i);
            s := regLido [i]^.carta^.from + ' ' + regLido [i]^.carta^.subject;
            statusSpam := 0; // 0 = não achou  1 = achou  2 = força aceitação
            statusLinha := buscaProibidas (s);
            if statusLinha <> 0 then statusSpam := statusLinha;

            if statusSpam = 1 then
                begin
                    write ('S');
                    nspans := nspans + 1;
                    moveParaDirSpam (i);
                    if bipPermitido then sintBip;
                end
            else
                begin
                    write ('N');
                end;
        end;

    matarSpansNaoLidas := nspans;
    if nspans > 0 then
//        mensagem ('CTNENSPA', 1){'Não encontrou Spam'}
//    else
        begin
            mensagem ('CTENSPVI', 0); {'Número de spans e vírus encontrados: '}
            sintWriteint (nspans);
            if not mudo then
                begin
                    mensagem ('CTCARAPR', 0); {'Cartas aprovadas: '}
                    sintWriteInt (numRegs- nspans);
                end;
        end;

    destroiLinhasArquivoBloque;
fim:
    desmontaListaDeCartas;
    {$I-}  chdir (dirAtual);  {$I+}
    if ioresult <> 0 then;
end;

{-------------------------------------------------------------}
{       Constantes e variáveis utilizadas na conexão de rede do Mata Spam
{-------------------------------------------------------------}

const
    CRLF = #$0d + #$0a;

var
    sock: integer;
    pbuf: pbufRede;

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

function mataSpansServidor (mudo: boolean): integer;
var
    s, s2, aux: string;
    i, j, n: integer;
    statusLinha, statusSpam: integer;
    nspans: integer;
    c: char;
    bipPermitido: boolean;

label erro, testarLinha;

begin
    mataSpansServidor := 0;
    bipPermitido := clek;
    limpaBufTec;
    if not mudo then
        mensagem ('CTMATSPM', 1) {'Matando spans'}
    else
        writeln (pegaTextoMensagem('CTMATSPM')); {'Matando spans'}
    n := mostraNumCartas;
    if n < 1 then
        begin
            mensagem ('CTNAOEXS', 1); {'Não existem cartas no servidor.'}
            exit;
        end;
    if not mudo then
        begin
            sintWriteInt (n);
            if n > 1 then mensagem ('CTCARTAS', 1) {'Cartas'}
            else mensagem ('CTCARTA', 1); {'Carta'}
        end;

    nspans := 0;

    for i := 1 to n do
        begin
            if keypressed then
                begin
                    while keypressed do c := readkey;
                    if c = #$1b then break;
                    if c = ' ' then
                        bipPermitido := not bipPermitido
                    else
                        begin
                            writeln;
                            write (' ');
                            sintWriteInt (i); write (' ');
                            mensagem ('CTDE', 0); {'de'}
                            sintWriteInt (n); writeln;
                        end;
                end;

            writelnRede (sock, 'TOP ' + intToStr (i) + ' 50');
            if not readlnBufRede(pbuf, s, 10) then goto erro;
            if (s <> '') and (s[1] = '-') then
                begin
                    sintWriteln (s);
                    goto erro;
                end;

(*NenoNeno            statusSpam := 0; // 0 = não achou  1 = achou  2 = força aceitação
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
NenoNeno*)

            statusLinha := 0;
            s2 := '';
            for j := 1 to 1000 do
                begin
                    testarLinha:
                    if s = '.' then break;
                    if maiuscansi (copy (s, 1, 5)) = 'FROM:' then
                        begin
                            statusLinha := statusLinha + 1;
                            decodificarString (s);
                            s2 := s2 + ' ' + s;
                        end
                    else
                    if maiuscansi (copy (s, 1, 8)) = 'SUBJECT:' then
                        begin
                            statusLinha := statusLinha + 1;
                            if not readlnBufRede(pbuf, aux, 10) then goto erro;
                            while (aux <> '') and ((aux[1] = ' ') or (aux[1] = TAB)) do
                                begin
                                    if aux[1] in [TAB, ' '] then aux := trim (aux);
                                    s := s + aux;
                                    if not readlnBufRede(pbuf, aux, 10) then goto erro;
                                end;
                            decodificarString (s);
                            s2 := s2 + ' ' + s;
                            s := aux;
                            goto testarLinha;
                        end;
                    if statusLinha > 2 then break;
                    if not readlnBufRede(pbuf, s, 10) then goto erro;
                end;

            statusSpam := buscaProibidas (s2);
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
    if not mudo then
        if nspans = 0 then
            mensagem ('CTNENSPA', 1){'Não encontrou Spam'}
        else
            begin
                mensagem ('CTENSPVI', 0); {'Número de spans e vírus encontrados: '}
                sintWriteInt (nspans); writeln;
                mensagem ('CTCARAPR', 0); {'Cartas aprovadas: '}
                sintWriteInt (n - nspans); writeln;
            end;

    mataSpansServidor := nspans;
    exit;

erro:
    mensagem ('CTCONCAN', 1); {'Conexao com servidor foi cancelada'}
end;

{-------------------------------------------------------------}
{           Faz a abertura da conta
{-------------------------------------------------------------}

function abreConta (mudo: boolean): boolean;
var s: string;
begin
    abreConta := false;
    readlnBufRede(pbuf, s, 10);
    if not mudo then
        mensagem ('CTCONOK', 1); {'Conexão realizada'}

    writelnRede (sock, 'USER ' + contaUsuario);
    readlnBufRede(pbuf, s, 10);
    if (s <> '') and (s[1] <> '+') then exit;

    writelnRede (sock, 'PASS ' + senhaSalva);
    readlnBufRede(pbuf, s, 10);
    if (s <> '') and (s[1] <> '+') then exit;

    abreConta := true;
end;

{-------------------------------------------------------------}
{       Mata Spam direto no servidor
{-------------------------------------------------------------}

function mataSpam (mudo: boolean): integer;
var
    s, senha: string;
    c1: char;
    salvaAttr: word;
    wsaData: TWSADATA;
begin
    mataSpam := 0;
    if trim (senhaSalva) = '' then
        begin
            senha := '';
            salvaAttr := textattr;
            textBackground (RED);
            mensagem ('CTINFSEN', 1);  {'Informe sua senha'}
            textBackground (BLACK);
            textColor (BLACK);
            c1 := sintEditaCampoMudo (senha, 1, wherey, 255, 80, true);
            writeln;
            textAttr := salvaAttr;
            if (c1 = ESC) or (trim(senha) = '') then
                begin
                    mensagem ('CTDESIST', -1); {'Desistiu'}
                    exit;
                end;
            senhaSalva := senha;
        end;

//    if not mudo then
//        mensagem ('CTMATASP', 1); {'Matador de spans'}
    if not carregaArqProibidas then exit;
    if WSAStartup ($0101, wsaData) <> 0 then
        mensagem ('CTERRCOM', 1) {'Não consegui ativar o sistema de comunicações do micro'}
    else
        begin
            if usaSSL then
                sock := abreConexaoSSL(hostPOP3, portaPOP3)
            else
                sock := abreConexao(hostPOP3, 110);

            if sock >= 0 then
                begin
                    pbuf := inicBufRede (sock);
                    if abreConta (mudo) then
                         mataSpam := mataSpansServidor (mudo)
                    else
                        mensagem ('CTERCONX', 1); {'Erro na conexão com o correio'}
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
    limpaBuftec;
    destroiLinhasArquivoBloque;
end;

{--------------------------------------------------------}
begin
end.
