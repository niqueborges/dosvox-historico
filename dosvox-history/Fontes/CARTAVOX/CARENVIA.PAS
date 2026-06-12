{-------------------------------------------------------------}
{
{             Cartavox - Rotinas de envio de carta
{
{-------------------------------------------------------------}

unit carEnvia;

interface

uses
    dvArq,
    dvCrt,
    dvForm,
    dvHora,
    dvWin,
    sysutils,
    windows,
    carApeli,
    carCC,
    carDecod,
    carEst,
    carLeit,
    carMsg,
    carSMTP,
    carTela,
    carUtil,
    carVars,
    carList,
    carRecad,
    carCopia,
    carResp;

function preencheArqResposta (nCar: integer; perguntaSeAssina, encaminha, encaminharLimpo, adicionarNoArq: boolean; var nomeArq: string): boolean;
procedure prepararCarta (tipo: char; nCar: integer; editaPreparada: boolean; nomeDest, dirAtual: string);
function escolheNomeArq (var editar: boolean; dirAtual: string): string;
function prepararCartaRespAut (nCar: integer; vaiEnviar: boolean): boolean;

var
    confReceb : boolean;

implementation

{-------------------------------------------------------------}
{       Testa se o arquivo está no temporário do Windows
{-------------------------------------------------------------}

function testaArqTemp (nomeArq: string): boolean;
var
    dirWindowsTemp: string;
    tempPath: array [0..144] of char;
begin
    getTempPath (144, tempPath);
    dirWindowsTemp := strPas (tempPath);
    if pos (dirWindowsTemp, nomeArq) <> 0 then
        testaArqTemp := true
    else
        testaArqTemp := false;
end;

{-------------------------------------------------------------}
{       Confirma o destino da carta
{-------------------------------------------------------------}

function confirmaDestino (nomeDest:string): boolean;
var c: char;
begin
    repeat
        textBackground (MAGENTA);
        mensagem ('CTENVPAR', 0);   {'Enviando para: '}
        textBackground (BLACK);   clreol;
        sintWriteln (nomeDest);
        mensagem ('CTCNFDST', 0);  {'Confirma destino {s/n) ? '}
        c := upcase(popupMenuPorLetra ('SN'));
        writeln;
    until c in ['S', 'N', ENTER, ESC];
    confirmaDestino := c in ['S', ENTER];
end;

{-------------------------------------------------------------}
{       Seleciona o destinatário principal da carta
{-------------------------------------------------------------}

function selDestinoPrincipal (destinatario: string; editar, perguntar: boolean): string;
var
    c: char;
    nomeDest: string;
    p: integer;
begin
    repeat
        nomeDest := destinatario;
        if editar then
            begin
                mensagem ('CTEDDEEN', 1); {Edite o nome do destinatário e tecle ENTER.'}
                mensagem ('CTESOUAP', 1); {Setas escolhe outro no caderno de apelidos'}
                sintetiza (destinatario);
            end
        else
            begin
                mensagem ('CTENDDST', 1);  {'Qual o endereço eletrônico do destinatário ? '}
                mensagem ('CTAPELID', 1);  {'Começar por * indica apelido'}
            end;
        c := sintEditaCampo (nomeDest, 1, wherey, 255, 80, true);
        writeln;

        if editar and (c = ESC) then
            begin
                mensagem ('CTDESIST', 2); {'Desistiu'}
                nomeDest := destinatario;
            end
        else
        if (c = ESC) or (upcase(c) = 'N') then
            nomeDest := 'ESC' //Cancela o envio retornando o ESC
        else
        if (c = BAIX) or (c = CIMA) then
            begin
                nomeDest := folhearApelidos (nomeDest);
                if perguntar then
                    if (nomeDest <> '') and (not confirmaDestino (nomeDest)) then
                        nomeDest := 'ESC';
            end
        else
        if (nomeDest <> '') and ( nomeDest [1] = '*') then
            begin
                delete (nomeDest, 1, 1);
                nomeDest := buscaApelido (nomeDest);
                if nomeDest = '' then
                    begin
                        nomeDest := 'ESC';
                        mensagem ('CTAPEINV', 2);   {'Apelido inválido'}
                    end
                else
                    if not confirmaDestino(nomeDest) then nomeDest := 'ESC';
            end;

        p := pos (',', nomeDest);
        if p <> 0 then
            mensagem ('CTSOUMDS', 1);   {'Erro: informe apenas um destinatário principal'}
    until p = 0;

    if editar and (  nomeDest <> destinatario) then
        mensagem ('CTOK', 2); {'OK'}

    selDestinoPrincipal := nomeDest;
end;

{-------------------------------------------------------------}
{       Edita o assunto da carta
{-------------------------------------------------------------}

function editaAssunto (assunto: string; var c: char): string;
var s: string;
begin
    s:= trim(assunto);
    repeat
        textBackground (RED);
        if s = '' then
            mensagem ('CTASSCAR', 0)  {'Qual o assunto da carta ? '}
        else
            begin
                mensagem ('CTEASSUN', 0);  {' Editore o assunto da carta'}
                sintetiza (s);
            end;
        textBackground (BLACK);
        writeln;
        c := sintEditaCampo (s, 1, wherey, 255, 80, true);
        writeln;
    until c in [ENTER, ESC];
    if c = ESC then
        editaAssunto := assunto
    else
        editaAssunto := s;

    if (assunto <> '') and (c = ESC) then
        msgBaixo ('CTDESIST') {'Desistiu'}
    else
    if assunto <> '' then
        msgBaixo ('CTOK'); {'OK'}
end;

{-------------------------------------------------------------}
{       Limpa as listas carbono:
{           O ocultas, C não ocultasou T ambas as listas
{-------------------------------------------------------------}

procedure limparTodasListas;
var c: char;
begin
    if (pCC = nil) and (pBCC = nil) then
        begin
            mensagem ('CTLICAVA', 1); {'Lista de copias carbono vazia.'}
            exit;
        end;

    repeat
        textBackground (RED);
        mensagem ('CTDELICA', 1); {'Deseja limpar a lista de cópias carbono?'}
        mensagem ('CTLISOCT', 1); {'Tecle O para ocultos, C para não ocultos ou T para ambas as listas')}
        c := upcase(popupMenuPorLetra ('OCTN'));
        textBackground (BLACK);
        writeln;
    until c in ['T', 'O', 'C', 'N', ESC];
    case c of
        'C': limpaListaCarbono (pCC);
        'O': limpaListaCarbono (pBCC);
        'T': begin
                limpaListaCarbono (pCC);
                limpaListaCarbono (pBCC);
             end;
    else
        msgBaixo ('CTDESIST'); {'Desistiu'}
    end;
    if not (c in ['N', ESC]) then
        mensagem ('CTOK', 1); {'OK'}
end;

{-------------------------------------------------------------}
{       Verificar listas carbono, pergunta qual a lista vai folhear
{-------------------------------------------------------------}

procedure verificarListasCarbono;
var c: char;
begin
    if (pCC <> nil) and (pBCC <> nil) then
        repeat
            textBackground (RED);
            mensagem ('CTQLDFOL', 1); {'Qual lista carbono deseja folhear?'}
            mensagem ('CTTEOCCS', 1); {'Tecle O para carbono ocultos ou C para não ocultos'}
            c := upcase(popupMenuPorLetra ('OCN'));
            textBackground (BLACK);
            writeln;
        until c in ['O', 'C', 'N', ESC]
    else
    if pCC <> nil then
        c := 'C'
    else
    if pBCC <> nil then
        c := 'O'
    else
        begin
            mensagem ('CTLICAVA', 1); {'Lista de copias carbono vazia.'}
            exit;
        end;

    if c = 'C' then
        mensagem ('CTCOPCAR', 1) {'Copias carbono'}
    else
    if c = 'O' then
        mensagem ('CTCOPCAO', 1); {'Copias carbono ocultas'}

    if not (c in ['N', ESC]) then
        mensagem ('CTUSESET', 1); {'Folheando: use as setas, depois tecle sua opção'}
    case c of
        'C': folheiaCopiasCarbono (pCC);
        'O': folheiaCopiasCarbono ( PBCC);
    else
        msgBaixo ('CTDESIST'); {'Desistiu'}
    end;

    if not (c in ['N', ESC]) then
        msgBaixo ('CTOK'); {'OK'}
end;

{-------------------------------------------------------------}
{       Retorna o nome do arquivo txt a enviar
{-------------------------------------------------------------}

function escolheNomeArq (var editar: boolean; dirAtual: string): string;
var
    c: char;
    nomeArq: string;
    arq: text;
begin
    escolheNomeArq := '';
    editar := true;
repeat
        mensagem ('CTNOMMAN', 1);  {'Qual o nome do arquivo de texto a mandar ? '}
        garanteEspacoTela (10);
        nomeArq := obtemNomeArqMasc (10, '*.txt');
        writeln (nomeArq);
        if (copy(nomeArq, 1, 1) = '\') or (copy(nomeArq, 1, 1) = '/') or
           (copy(nomeArq, 1, 1) = '.') or
           ((pos('\', nomeArq) <> 0) and (copy(nomeArq, 2, 1) <> ':')) or
           ((pos('/', nomeArq) <> 0) and (copy(nomeArq, 2, 1) <> ':')) then
                mensagem ('CTATAINV', 1); {'Nome de arquivo inválido'}
    until ((nomeArq = '') or (maiuscansi(copy(nomeArq, length(nomeArq)-3, 4)) = '.TXT') or (not testaExtensao(nomeArq))) and
          (copy(nomeArq, 1, 1) <> '\') and (copy(nomeArq, 1, 1) <> '/') and (copy(nomeArq, 1, 1) <> '.') and
          not ((pos('\', nomeArq) <> 0) and (copy(nomeArq, 2, 1) <> ':')) and
          not ((pos('/', nomeArq) <> 0) and (copy(nomeArq, 2, 1) <> ':'));

    if (nomeArq = '') or (nomeArq[length(nomeArq)] in ['\', '/']) then
        begin
            nomeArq := dirEnvia + '\$.$';
            assign (arq, nomeArq);
            {$I-} rewrite (arq); {$I+}
            if ioresult <> 0 then
                begin
                    mensagem ('CTERRDSK', 1);  {'Erro de escrita no disco'}
                    exit;
                end;
            {$I-} close (arq); {$I+}
            if ioresult <> 0 then;

            escolheNomeArq := nomeArq;
            if teclaObtemNomeArq = ESC then
                begin
                    editar := false;
                    delay (100);
                    mensagem ('CTSEMTXT', 1);   {'Sem texto'}
                end;
            exit;
        end;

    if not testaExtensao (nomeArq) then
        begin
            if (pos ('\', nomeArq) = 0) and (pos ('/', nomeArq) = 0) then
                begin
                    if (not existeArq (dirAtual + '\' + nomeArq)) and (not existeArq (dirEnvia + '\' + nomeArq)) then
                        nomeArq := nomeArq + '.txt';
                    if not existeArq (dirAtual + '\' + nomeArq) then
                        nomeArq := dirEnvia + '\' + nomeArq
                    else
                        nomeArq := dirAtual + '\' + nomeArq;
                end
            else
                if not existeArq (nomeArq) then
                    nomeArq := nomeArq + '.txt';
        end
    else
        if (pos ('\', nomeArq) = 0) and (pos ('/', nomeArq) = 0) then
            if not existeArq (dirAtual + '\' + nomeArq) then
                nomeArq := dirEnvia + '\' + nomeArq
            else
                nomeArq := dirAtual + '\' + nomeArq;

    if not existeArq (nomeArq) then
        begin
            repeat
                mensagem ('CTQUERTC', 0);  {'Esse arquivo não existe, quer teclar agora ? '}
                c := upcase(popupMenuPorLetra ('SN'));
                writeln;
            until c in ['S', 'N', ENTER, ESC];
            if c in ['N', ESC] then exit;
        end
    else
        begin
            repeat
                mensagem ('CTEDIANT', 0);   {'Quer edita-lo antes de mandar ? '}
                c := upcase(popupMenuPorLetra ('SN'));
                writeln;
            until upcase (c) in ['S', 'N', ENTER, ESC];
            if c = ESC then exit;
            if c in ['N', ENTER] then editar := false;
        end;
    escolheNomeArq := nomeArq;
end;

{-------------------------------------------------------------}
{       Extrai a primeira parte da carta, txt ou html
{-------------------------------------------------------------}

function extraiArqCarta (nCar: integer): string;
var
    nomeArq, s: string;
    parte: PEstrutura;
begin
    extraiArqCarta := '';
    if not carregaLinhasArquivo (regLido[ncar]^.carta^.nomArqCarta) then
        begin
            msgBaixo ('CTCARSUM');  {'Erro no disco: carta sumiu'}
            exit;
        end;

    preencheCartaPrincipal (regLido[ncar]);//preenche o cabeçalho principal da carta
    if trim (regLido[ncar]^.boundary) = '' then
        begin
            if (maiuscAnsi(typeOuContent_type (RegLido[nCar])) = 'TEXT/PLAIN') or
               (maiuscAnsi(typeOuContent_type (RegLido[nCar])) = 'TEXT/HTML') or
               (trim (RegLido[nCar]^.content_type) = '') then
                    begin
                         s := trim (maiuscAnsi (regLido[nCar]^.content_transfer_encoding));
                         if s <> 'BASE64' then
                             begin
                                 nomeArq := gravaParteDecodificada (regLido[nCar], '');
                             end
                         else
                             begin
                                 gravaParteDecodificada (regLido[nCar], '$.$');
                                 if trim (nomeArq) = '' then
                                    nomeArq := '$2.$';
                                 decodMime64 ('$.$', nomeArq);
                             end;
                         s := trim (maiuscAnsi (regLido[nCar]^.charset));
                         if s = 'UTF-8' then
                            decodArqUtfToAnsi (nomeArq);

                         if maiuscAnsi(typeOuContent_type (RegLido[nCar])) = 'TEXT/HTML' then
                              converteArqParaTxt (nomeArq);
                    end;
        end
    else
        begin
            criaIndicePartes;
            montaTudo (regLido[nCar]);

            if (maiuscAnsi(typeOuContent_type (listaDePartes[0])) = 'TEXT/PLAIN') or
               (maiuscAnsi(typeOuContent_type (listaDePartes[0])) = 'TEXT/HTML') then
                    begin
                         parte := listaDePartes[0];
                         s := trim (maiuscAnsi (parte^.content_transfer_encoding));
                         if s <> 'BASE64' then
                             begin
                                 nomeArq := gravaParteDecodificada (listaDePartes[0], '');
                             end
                         else
                             begin
                                 gravaParteDecodificada (listaDePartes[0], '$.$');
                                 if trim (nomeArq) = '' then
                                    nomeArq := '$2.$';
                                 decodMime64 ('$.$', nomeArq);
                             end;
                         s := trim (maiuscAnsi (parte^.charset));
                         if s = 'UTF-8' then
                            decodArqUtfToAnsi (nomeArq);

                         if maiuscAnsi(typeOuContent_type (listaDePartes[0])) = 'TEXT/HTML' then
                              converteArqParaTxt (nomeArq);
                    end;

            destroiIndicePartes;
            desmontaTudo (regLido[ncar]);
        end;
    destroiLinhasArquivo;
    extraiArqCarta := nomeArq;
end;

{-------------------------------------------------------------}
{       Cria o arquivo e coloca a primeira parte da carta, se for text/plain
{-------------------------------------------------------------}

function preencheArqResposta (nCar: integer; perguntaSeAssina, encaminha, encaminharLimpo, adicionarNoArq: boolean; var nomeArq: string): boolean;
var
    arqOut: text;
    arquivoNaMemoria: boolean;
    i: integer;
    cancelar: char;
    s: string;

label fim;
begin
    preencheArqResposta := false;
    arquivoNaMemoria := false;
    nomeArq := extraiArqCarta (nCar);
    if trim (nomeArq) = '' then
        nomeArq := dirEnvia + '\$.$'
    else
        if not carregaLinhasArquivo (nomeArq) then
            begin
                msgBaixo ('CTCARSUM');  {'Erro no disco: carta sumiu'}
                exit;
            end
        else
            begin
                arquivoNaMemoria := true;
                assign (arqOut, nomeArq);
                {$I-} rewrite (arqOut); {$I+}
                if ioresult <> 0 then goto fim;
                {$I-} close (arqOut); {$I+}
                if ioresult <> 0 then goto fim;
            end;

    if (not encaminharLimpo) and (perguntaSeAssina) then
        nomeArq := anexaAssinatura (nomeArq, true, cancelar)
    else
        cancelar := 'N';
    if (cancelar = 'S') or (nomeArq = '') then goto fim;
    assign (arqOut, nomeArq);
    {$I-} append (arqOut);  {$i+}
    if ioresult <> 0 then
        begin
            {$I-} rewrite (arqOut); {$I+}
            if ioresult <> 0 then
                begin
                    msgBaixo ('CTERRLEI');  {'Erro de leitura do arquivo'}
                    exit;
                end;
        end;

    if not encaminharLimpo then
        begin
            {$I-} writeln (arqOut, '');  {$I+}
            if ioresult <> 0 then
                begin
                    mensagem ('CTERRDSK', 1);  {'Erro de escrita no disco'}
                    goto fim;
                end;

            //Em 1 de Janeiro de 2010 16:50, Fulano de Tal
            //<fulano@provedor.com>escreveu:
            if cabecalhoResumido and (not adicionarNoArq) then
                begin
                    s := regLido[nCar]^.carta^.from;
                    i := pos('<', regLido[nCar]^.carta^.from);
                    if i > 0 then s := copy(s, 1, i-1);
                    {$I-} writeln (arqout, 'Em ' + converteData (regLido[nCar]^.carta^.date, true)+ ', ' + s);  {$I+}
                    if ioresult <> 0 then;
                    s := regLido[nCar]^.carta^.from;
                    i := pos('<', regLido[nCar]^.carta^.from);
                    if i > 0 then s := copy(s, i, length(s) - i + 1);
                    {$I-} writeln (arqout, s + ' escreveu:');  {$I+}
                    if ioresult <> 0 then;
                end
            else
                begin
                    if encaminha then
                        {$I-} writeln (arqout, '-----Mensagem encaminhada-----')  {$I+}
                    else
                        {$I-} writeln (arqout, '-----Mensagem original-----');  {$I+}
                    if ioresult <> 0 then;
                    if not adicionarNoArq then
                        {$I-} writeln (arqout, 'De: ' + retornarNome(regLido[nCar]^.carta^.from, false)) {$I+}
                    else
                        {$I-} writeln (arqout, 'De: ' + regLido[nCar]^.carta^.from); {$I+}
                    if ioresult <> 0 then;
                    {$I-} writeln (arqout, 'Enviada em: ' + converteData (regLido[nCar]^.carta^.date, true));  {$I+}
                    if ioresult <> 0 then;
                    if not adicionarNoArq then
                        begin
                            {$I-} writeln (arqout, 'Para: ' + retornarNomes(regLido[nCar]^.carta^.to_)); {$I+}
                            if ioresult <> 0 then;
                        end
                    else
                        begin
                            s := regLido[nCar]^.carta^.to_;
                            {$I-} writeln (arqout, 'Para:');  {$I+}
                            if ioresult <> 0 then;
                            while trim(s) <> '' do
                                begin
                                    i := pos(',', s);
                                    if i > 0 then
                                        {$I-} writeln (arqout, '      ' + trim(copy(s, 1, i-1))) {$I+}
                                    else
                                        {$I-} writeln (arqout, '      ' + trim(s)); {$I+}
                                    if ioresult <> 0 then;
                                    if i > 0 then delete (s, 1, i)
                                    else s := '';
                                end;
                        end;
                    //Adiciona as cópias CC
                    if (not adicionarNoArq) and (regLido[nCar]^.carta^.cc <> '') then
                        begin
                            {$I-} writeln (arqout, 'Cc: ' + retornarNomes(regLido[nCar]^.carta^.cc)); {$I+}
                            if ioresult <> 0 then;
                        end
                    else
                    if (adicionarNoArq) and (regLido[nCar]^.carta^.cc <> '') then
                        begin
                            s := regLido[nCar]^.carta^.cc;
                            {$I-} writeln (arqout, 'Cc:');  {$I+}
                            if ioresult <> 0 then;
                            while trim(s) <> '' do
                                begin
                                    i := pos(',', s);
                                    if i > 0 then
                                        {$I-} writeln (arqout, '    ' + trim(copy(s, 1, i-1))) {$I+}
                                    else
                                        {$I-} writeln (arqout, '    ' + trim(s)); {$I+}
                                    if ioresult <> 0 then;
                                    if i > 0 then delete (s, 1, i)
                                    else s := '';
                                end;
                        end;
                    {$I-} writeln (arqout, 'Assunto: ' + regLido [nCar]^.carta^.subject);  {$I+}
                    if ioresult <> 0 then;
                    {$I-} writeln (arqout, '');  {$I+}
                    if ioresult <> 0 then;
                end;
        end;

    if arquivoNaMemoria then
        for i := 0 to linhasArquivo.count -1 do
            begin
                if cabecalhoResumido then
                    write (arqout, '> ');
                {$I-} writeln (arqout, linhasArquivo[i]);  {$I+}
                if ioresult <> 0 then;
            end;

    preencheArqResposta := true;
fim:
    if arquivoNaMemoria then
        destroiLinhasArquivo;
    {$I-} close (arqOut); {$I+}
    if ioresult <> 0 then;
end;

{-------------------------------------------------------------}
{       Insere ou remove a confirmação de recebimento na carta
{-------------------------------------------------------------}

procedure insereOuRemoveConfirmacaoRecebimento;
begin
    if confReceb then
    begin
        confReceb := false;

        mensagem('CTRECREM', 0); {'Confirmação de recebimento removido '}
    end
    else
    begin
        confReceb := true;
        mensagem('CTRECINC', 0); {'Confirmação de recebimento incluído'}
    end;
end;

{       Divide a carta em várias cartas}

function dividirCarta (nomeArq, nomeDest, assunto: string; pCC, pBCC:                          pListaCC;
                        encaminhar, confReceb, respAut: boolean; nCar: integer;
                        in_reply_to_: string): boolean;
var
    c: char;
    totalCartasGeradas, i: integer;
    auxMensagemSaudacao, espacos: string;
    somenteNome: boolean;

    procedure geraCartaDividida (p: pListaCC);
    begin
        while p <> NIL do
            begin
                if somenteNome then
                    mensagemSaudacao := espacos + retornarNome (p.nome, true) + ','
                else
                if auxMensagemSaudacao <> '' then mensagemSaudacao := auxMensagemSaudacao + ' ' + retornarNome (p.nome, true) + ',';
                geraTextoSMTP (nomeArq, p^.nome, assunto, nil, nil, false, confReceb, true, nCar,
                                in_reply_to_, false);
                totalCartasGeradas := totalCartasGeradas +1;
                p := p^.prox;
            end;
    end;

label desistiu;
begin
    dividirCarta := false;

    if (pCC = nil) and (pBCC = nil) then
        begin
            msgBaixo ('CTLICAVA'); {'Lista de copias carbono vazia.'}
            exit;
        end;

    repeat
        mensagem ('CTDESDIV', 0); {'Deseja gerar uma carta para cada destinatário?'}
        c := upcase(popupMenuPorLetra ('SN'));
        writeln;
    until c in ['S', 'N', ESC];

    if c <> 'S' then goto desistiu;

    repeat
        mensagem ('CTDIGSAU', 1); {'Digite a saudação ou deixe em branco para nenhuma:'}
        auxMensagemSaudacao := '';
        c := sintEditaCampo (auxMensagemSaudacao, 1, wherey, 255, 80, true);
        writeln;
    until c in [ENTER, ESC];

    if c = ESC then goto desistiu;

    mensagemSaudacao := auxMensagemSaudacao;
    espacos := '';
    for i := 1 to  length(auxMensagemSaudacao) do
        if auxMensagemSaudacao[i] = ' ' then espacos := espacos + ' '
        else break;
    if (trim(maiuscansi(auxMensagemSaudacao)) = '[NOME]') or  (trim(maiuscansi(auxMensagemSaudacao)) = '[NOME')then
        somenteNome := true
    else somenteNome := false;

    msgBaixo ('CTLIGERA'); {'Gerando cartas'}
    totalCartasGeradas := 0;
    If (nomeDest <> '') and (pos('Undisclosed-Recipient:;', nomeDest) = 0) then
        begin
            if auxMensagemSaudacao = '[NOME]' then mensagemSaudacao := retornarNome (nomeDest, true) + ','
            else
            if auxMensagemSaudacao <> '' then mensagemSaudacao := auxMensagemSaudacao + ' ' + retornarNome (nomeDest, true) + ',';
            geraTextoSMTP (nomeArq, nomeDest, assunto, nil, nil, false,
                           confReceb, true, nCar, in_reply_to_, false);
    totalCartasGeradas := totalCartasGeradas + 1;
        end;
    if pCC <> nil then geraCartaDividida (pCC);
    if pBCC <> nil then geraCartaDividida (pBCC);

    mensagemSaudacao := ''; //Zera a variável de carSMTP.pas já utilizada
    dividirCarta := true;
    mensagem ('CTOK', 1); {'Ok'}
    sintWriteInt (totalCartasGeradas); write ('  ');
    mensagem ('CTCARTAS', 1); {'Cartas'}
    exit;

desistiu:
    msgBaixo ('CTDESIST'); {'Desistiu...'}
end;

{-------------------------------------------------------------}
{       Ajuda das opções do preparo de carta
{-------------------------------------------------------------}

procedure ajudaOpcEnvio (tipo: char);
begin
    if tipo in ['P', 'T', ^P] then
        telaPrincipal
    else
        telaFolheamentoCartas;
    textBackground (BLUE);
    mensagem ('CTAJUD01', 0); {'As opções são:'}
    textBackground (BLACK);
    writeln;
    mensagem ('CTAJEN01', 1); {'A  Anexar arquivos'}
    mensagem ('CTAJEN02', 1); {'C  Inserir cópias carbono'}
    mensagem ('CTAJEN08', 1); {'O  Inserir cópias carbono ocultas'}
    mensagem ('CTAJEN03', 1); {'S  Editar assunto'}
    mensagem ('CTAJEN04', 1); {'D  Editar destinatário'}
    mensagem ('CTAJEN05', 1); {'E  Reeditar texto'}
    mensagem ('CTAJEN06', 1); {'L  Limpar lista de copias carbono'}
    mensagem ('CTSETOPC', 1);  {'Use as setas para conhecer outras opções'}

    if keypressed and (readkey <> ESC) then
        begin
            limpaBufTec;
            readkey;
        end;
    limpaBufTec;
end;

{-------------------------------------------------------------}
{       Seleciona as opções de envio com as setas
{-------------------------------------------------------------}

function selSetasOpcEnvio: char;
var
    n: integer;
const
    tabOpcEnvio: string [13] = 'ACOSDEFLRGPT'+ESC;
begin
    popupMenuCria (35, wherey, 50, 12, RED);
    MenuAdiciona ('CTAJEN01'); {'A  Anexar arquivos'}
    MenuAdiciona ('CTAJEN02'); {'C  Inserir cópias carbono'}
    MenuAdiciona ('CTAJEN08'); {'O  Inserir cópias carbono ocultas'}
    MenuAdiciona ('CTAJEN03'); {'S  Editar assunto'}
    MenuAdiciona ('CTAJEN04'); {'D  Editar destinatário'}
    MenuAdiciona ('CTAJEN05'); {'E  reeditar texto'}
    MenuAdiciona ('CTAJEN09'); {'F  Folhear listas carbono'}
    MenuAdiciona ('CTAJEN06'); {'L  Limpar lista de copias carbono'}
    MenuAdiciona ('CTAJEN10'); {'R  Inserir ou remover confirmação de recebimento'}
    MenuAdiciona ('CTAJEN12'); {'G  Gravar recado falado'}
    MenuAdiciona ('CTAJEN13'); {'P  Particionar carta em várias'}
    MenuAdiciona ('CTAJEN11'); {'T  Fechar carta e transmitir'}
    MenuAdiciona ('CTAJEN07'); {'ESC  cancelar'}

    n := popupMenuSeleciona;

    if (n > 0) and (n <= 13) then
        selSetasOpcEnvio := tabOpcEnvio[n]
    else
        selSetasOpcEnvio := #0;
end;

{-------------------------------------------------------------}
{   Prepara a carta para o envio
{   Retorna o nome do arquivo da carta se for criado e se não transmitir.
{   Tipos:
{       P  - Prepara a partir do menu principal
{       ^P - Preparo rápido a partir do menu principal
{       T  - Prepara a partir do menu principal e no final transmite
{       ^T - Preparo rápido a partir do menu principal e no final transmite
{       R  - Responde a carta para o endereço do reply-to
{       ^R - Responde a carta para o endereço do From
{       E  - Encaminha a carta abrindo o texto
{      ^E  - Encaminha a carta como anexo
{       Z  - Edita preparada abrindo e fechando direto, troca remetente
{-------------------------------------------------------------}

procedure prepararCarta (tipo: char; nCar: integer; editaPreparada: boolean; nomeDest, dirAtual: string);
var
    c, c2, cancelar: char;
    assunto, nomeArq, nomeArqEnviar, saveDir, nomeArqRecado: string;
    in_reply_to_: string;
    editar, auxBoolean, cartaFoiDividida: boolean;
    arq: text;

label desistiu, fim, desejaCancelar;
begin
    nomeArqRecado := '';
    cartaFoiDividida := false;
    nArqMime := 0;  //Armazena número de arquivos em anexo
    limpaListaCarbono (pCC);
    limpaListaCarbono (pBCC);
    confReceb := false; //Desativa confirmação de recebimento

    if editapreparada then
        begin
            if not primeiraParteTxtOuHtml (nCar) then //Só se primeira parte em txt ou html
                begin
                    mensagem ('CTNPSTXT', -1); {'Não é permitido editar sem texto na primeira parte.'}
                    exit;
                end;
            if tipo <> 'Z' then
                mensagem ('CTEDICAR', 1); {'Editando carta ...'}
            nomeDest := regLido[nCar]^.carta^.to_;
            assunto := regLido[nCar]^.carta^.subject;
            nomeArq := extraiArqCarta (nCar);
            chaveMime := trim(regLido[nCar]^.boundary);
            in_reply_to_ := trim(regLido[nCar]^.carta^.in_reply_to_);
            carregaListaCarbono (regLido[nCar]^.carta^.cc, pCC);
            carregaListaCarbono (regLido[nCar]^.carta^.bcc, pBCC);
            if tipo <> 'Z' then
                begin
                    textBackground (RED);
                    mensagem ('CTQUALOP', 0); {'Qual sua opção? '}
                    textBackground (BLACK);
                end;
        end
    else
        begin
            chaveMime := '';

            //  A baixo pega endereço do destinatário
            if nomeDest <> '' then //e-mail entrou por parametro
                begin
                    if not  confirmaDestino (nomeDest) then
                        nomeDest := 'ESC';
                end
            else
            if tipo in ['P', 'T', ^P, ^T] then
                nomeDest := selDestinoPrincipal ('', false, tipo <> ^P)
            else
            if tipo in ['E', ^E] then
                begin
                    if folheiaTransmitidas then
                        nomeDest := selDestinoPrincipal (regLido[nCar]^.carta^.to_, false, true)
                    else
                        nomeDest := selDestinoPrincipal (regLido [nCar]^.carta^.from, false, true);
                end
            else
            if tipo = ^R then
                begin
                    nomeDest := regLido [nCar]^.carta^.from;
                    if not  confirmaDestino (nomeDest) then
                        nomeDest := 'ESC';
                end
            else //tipo = R
                begin
                    if trim (regLido [nCar]^.carta^.reply_to) <> '' then
                        nomeDest := regLido [nCar]^.carta^.reply_to
                    else
                        nomeDest := regLido [nCar]^.carta^.from;
                    if not  confirmaDestino (nomeDest) then
                        nomeDest := 'ESC';
                end;
            if nomeDest = 'ESC' then
                goto desistiu;
            if (pos ('(', nomeDest) <> 0) and (pos ('(', nomeDest) > pos ('@', nomeDest)) then
                delete (nomeDest, pos('(', nomeDest), length (nomeDest));
            nomedest := trim(nomeDest);

            //  Pega assunto da carta
            if tipo in ['P', 'T', ^T, ^P] then
                assunto := editaAssunto ('', c)
            else
            if tipo in ['R', ^R] then
                assunto := 'Re: ' + limpaAssunto(regLido[nCar]^.carta^.subject)
            else //tipo in ['E', ^E]
                assunto := 'En: ' + limpaAssunto(regLido[nCar]^.carta^.subject);
            if c = ESC then goto desistiu;

            //Pega o ID da carta pai na resposta.
            if (tipo in ['R', ^R]) and
               (nCar > 0) and (regLido [nCar]^.carta^.message_id <> '') then
                in_reply_to_ := regLido [nCar]^.carta^.message_id
            else
                in_reply_to_ := '';

            //  Pega cópias carbono, somente na resposta
            if tipo in ['R', ^R] then
                if not respondeTodosCC (nCar) then
                    goto desistiu; //Cancela o envio

            //  Pega nome do arquivo para envio
            if tipo in [^P, ^T] then
                begin
                    nomeArq := dirEnvia + '\$.$';
                    assign (arq, nomeArq);
                    {$I-} rewrite (arq); {$I+}
                    if ioresult <> 0 then
                        begin
                            mensagem ('CTERRDSK', 1);  {'Erro de escrita no disco'}
                            goto fim;
                        end;
                    {$I-} close (arq); {$I+}
                    if existeArq (dirEnvia + '\ModelosCarta\' + retornaEMail(nomeDest)+ '.txt') then
                        copiaUm (dirEnvia + '\ModelosCarta\' + retornaEMail(nomeDest) + '.txt', nomeArq);
                    editar := true;
                end
            else
            if tipo in ['P', 'T'] then
                nomeArq := escolheNomeArq (editar, dirAtual)
            else
            if tipo in ['R', ^R] then
                begin
                    if (not preencheArqResposta (nCar, true, false, false, false, nomeArq)) and (nomeArq <> '') then goto fim;
                    editar := true;
                end
            else
                begin
                    if (not preencheArqResposta (nCar, tipo = 'E', true, tipo = ^E, false, nomeArq)) and (nomeArq <> '') then goto fim;
                    editar := tipo = 'E';
                end;
            if trim (nomeArq) = '' then
                goto desistiu;

            //  Abre corpo principal da carta para edição
            if editar then
                begin
                    if not (tipo in [^P, ^T]) then
                        mensagem ('CTABREDI', 1);  {'Abrindo editor'}
                    editaArquivo (nomeArq);
                    limpaBufTec;
                    sintBip;
                end;

            //Verifica se o arquivo da carta existe para prosseguir
            if not fileExists (nomeArq) then goto desistiu;

            //  Adiciona arquivo de assinatura, se existir
            if tipo in ['P', 'T', ^P, ^T] then nomeArq := anexaAssinatura (nomeArq, false, cancelar);
            if nomeArq = '' then goto desistiu;
            if cancelar = 'S' then goto desejaCancelar;

            //Insere confirmação de leitura automaticamente
            if inserirConfRec then
                insereOuRemoveConfirmacaoRecebimento;

            if (tipo in ['E', ^E]) and (trim(regLido[nCar]^.boundary) = '') and
               (maiuscAnsi(regLido[ncar]^.content_type) = 'TEXT/HTML') then
                geraChaveMime
            else
            if (tipo in ['E', ^E]) and (trim(regLido[nCar]^.boundary) <> '') then
                chaveMime := trim(regLido[nCar]^.boundary);

        end;

    if tipo <> 'Z' then
        repeat
            writeln;
            textBackground (RED);
            mensagem ('CTENTFEC', 0); {'Tecle ENTER para fechar a carta ou F1 para conhecer outras opções'}
            textBackground (BLACK);
            sintLeTecla (c, c2);
            writeln;

            if c = #0 then
                if c2 = F1 then
                    ajudaOpcEnvio (tipo)
                else
                if c2 in [BAIX, CIMA] then
                    c := selSetasOpcEnvio;

            case upcase (c) of
                'A', 'G':
                    begin
                        getDir (0, saveDir);
                        if saveDir <> dirAtual then trocaDir (dirAtual);
                        if upcase(c) = 'G' then
                            begin
                                if nomeArqRecado = '' then
                                    begin
                                        nomeArqRecado := gravaRecadoFalado;
                                        if nomeArqRecado <> '' then atachaArquivos (nomeArqRecado);
                                    end
                                else
                                        msgBaixo ('CTEXREGR'); {'Já existe recado gravado'}
                            end
                        else
                            atachaArquivos ('');
                        if saveDir <> dirAtual then trocaDir (saveDir);
                    end;
                'C': geraListaCarbono (nomeDest, false);
                'O': geraListaCarbono (nomeDest, true);
                'S': assunto := editaAssunto (assunto, c2);
                'D': nomeDest := selDestinoPrincipal (nomeDest, true, true);
                'E': editaArquivo (nomeArq);
                'F': verificarListasCarbono;
                'L': limparTodasListas;
                'R': insereOuRemoveConfirmacaoRecebimento;
                'P': if dividirCarta (nomeArq, nomeDest, assunto, pCc, pBcc,
                                      tipo in ['E', ^E], confReceb, false, nCar,
                                      in_reply_to_) then
                        begin
                            c:= ENTER;
                            cartaFoiDividida := true;
                        end;

                #0, ENTER, 'T', ^T, CTLENTER:;//Não faz nada.
                ESC: begin
    desejaCancelar:
                        writeln;
                        textBackground (RED);
                        if editaPreparada then
                            mensagem ('CTCAEDCA', 0) {'Deseja realmente cancelar a edição desta carta?'}
                        else
                            mensagem ('CTCAPREC', 0); {'Deseja realmente cancelar o preparo desta carta?'}
                        textBackground (BLACK);
                        c := upcase(popupMenuPorLetra ('SN'));
                        writeln;
                        if c = 'S' then c := ESC
                        else c := #0;
                     end;

            else
                mensagem ('CTOPVINV', 1); {'Opção inválida, aperte F1 para ajuda'}
            end;
            if (c = ENTER) and (trim(nomeDest) = '') and (pCC = nil) and (pBCC = nil) then
                begin
                    Mensagem ('CTSEMDES', 1); {'Carta sem destinatário.'}
                    nomeDest := selDestinoPrincipal (nomeDest, false, true);
                    if nomeDest = 'ESC' then nomeDest := '';
                    c := #0;
                end;

        until upcase (c) in [ENTER, ESC, 'T', ^T, CTLENTER];

    if c <> ESC then
        begin
            if not cartaFoiDividida then
                nomeArqEnviar := geraTextoSMTP (nomeArq, nomeDest, assunto,
                                            pCc, pBcc, tipo in ['E', ^E, 'Z'],
                                            confReceb, false, nCar,
                                            in_reply_to_, true)
            else
            if editaPreparada then
                begin
                    apagaCarta (nCar, true);
                    apagaUmRegs (nCar);
                    nomeArqEnviar := ''
                end;

            desalocaAttachments;
            if nomeArqRecado <> '' then deletaArquivo (nomeArqRecado);
            if tipo in ['T', ^T] then c := 'T';
            if (trim (nomeArqEnviar) <> '') and (upcase (c) in ['T', CTLENTER]) then
                begin
                    if (enviarUmaCarta (nomeArqEnviar, false)) and (editaPreparada) then
                        begin
                            apagaCarta (nCar, false);
                            apagaUmRegs (nCar);
                        end;
                end
            else
            if (editaPreparada) and (trim (nomeArqEnviar) <> '') then
                begin
                    apagaCarta (nCar, false);
                    auxBoolean := regLido[nCar]^.selecionado;
                    zeraPCarta( regLido[nCar]^.carta);
                    regLido[nCar]^.carta^.nomArqCarta := nomeArqEnviar;
                    regLido[nCar]^.carta^.tamanho := pegaTamanhoArq(nomeArqEnviar);
                    carregaArqPreencheCabPrin (nCar);
                    regLido[nCar]^.selecionado := auxBoolean;
                end;
        end
    else
        begin
            if editaPreparada then
                mensagem ('CTEDICAN', 2) {'Edição cancelada'}
            else
                begin
                    mensagem ('CTOK', 0); {'Ok'}
                    write (' ');
                    mensagem ('CTCANCEL', 2); {'cancelado'}
                end;
            if pCC <> nil then
                limpaListaCarbono (pCC);
            if pBCC <> nil then
                limpaListaCarbono (pBCC);
        end;

    goto fim;
desistiu:
    mensagem ('CTDESIST', 2);   {'Desistiu...'}
fim:
            deletaAspas (nomeArq);
            if testaArqTemp (nomeArq) then
                begin
                    assign (arq, nomeArq);
                    {$I-}  erase (arq);  {$I+}
                    if ioresult <> 0 then;
                end;
    assign (arq, dirEnvia+'\$.$');
    {$I-} erase (arq); {$I+}
    if ioresult <> 0 then;
end;

{-------------------------------------------------------------}
{   Prepara a carta da resposta automática para a transmissão
{-------------------------------------------------------------}

function prepararCartaRespAut (nCar: integer; vaiEnviar: boolean): boolean;
var
    tipo: char;
    nomeDest, in_reply_to_: string;
    assunto, nomeArq, nomeArqEnviar, nomArqCarta: string;
    arq: text;

label fim;
begin
    prepararCartaRespAut := false;
    tipo := 'E';
    nArqMime := 0;
    limpaListaCarbono (pCC);
    limpaListaCarbono (pBCC);
    chaveMime := '';
    assunto := '';

    //Pega o endereço de destino da carta
    nomeDest := regLido [nCar]^.carta^.from;
    //Pega o ID da carta Pai
    in_reply_to_ := regLido [nCar]^.carta^.message_id;
    //Pega o nome do arquivo da carta
    nomArqCarta := regLido [nCar]^.carta^.nomArqCarta;
    //Ajusta o nome do assunto da carta
    if assRespAut <> '' then assunto := ' - ' + assRespAut;
            assunto := 'Re: ' + limpaAssuntoLista (regLido [nCar]^.carta^.subject) + assunto;
    //Cria o arquivo inicial da carta
    if (not preencheArqResposta (nCar, false, false, false, false, nomeArq)) and
       (nomeArq <> '') then goto fim;
    if not colocaRespostaCarta(nomeArq) then goto fim;
    nomeArqEnviar := geraTextoSMTP (nomeArq, nomeDest, assunto, pCc, pBcc, tipo = 'E',
                                    confReceb, true, nCar, in_reply_to_, true);
    desalocaAttachments;
    if vaiEnviar then regLido[ncar]^.carta^.nomArqCartaEnviar := nomeArqEnviar;

    prepararCartaRespAut := true;
fim:
    deletaAspas (nomeArq);
    if testaArqTemp (nomeArq) then
        begin
            assign (arq, nomeArq);
            {$I-}  erase (arq);  {$I+}
            if ioresult <> 0 then;
        end;
    assign (arq, dirEnvia+'\$.$');
    {$I-} erase (arq); {$I+}
    if ioresult <> 0 then;
end;

{--------------------------------------------------------}
begin
end.
