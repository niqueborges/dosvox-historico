{-------------------------------------------------------------}
{           cartaVox - cliente SMTP
{-------------------------------------------------------------}

unit carSMTP;

interface

uses
    dvarq,
    dvcrt,
    dvform,
    dvWin,
    sysUtils,
    uuenc,
    windows,
    carArq,
    carCC,
    carCopia,
    caremudo,
    carEst,
    carDecod,
    carGerat,
    carList,
    carMsg,
    carRede,
    winSock, //Declarar depois de carRede
    carUtil,
    carVars,
    classes;

procedure desalocaAttachments;
procedure geraChaveMime;
function geraTextoSMTP (nomeArq, nomeDest, assunto: string;
                        pCC, pBCC:                          pListaCC;
                        encaminhar, confReceb, mudo: boolean; nCar: integer;
                        in_reply_to_: string; adicionarCarbono: boolean): string;
function anexaAssinatura (nomeArq: string; arqVazio: boolean; var cancelar: char): string;
procedure transmitirCartas (doFolheamento: boolean; tipoFolheamento: char; mudo: boolean);
function  transmitirPreparadas: boolean;
function transmitirCartasGrupoContas: integer;
procedure atachaArquivos (nomeArq: string);
function enviarUmaCarta (nomeArq: string; mudo: boolean): boolean;

var mensagemSaudacao: string;

implementation

var
    mudo: boolean;
    quantosEnviado, tamanhoCarta: longint;
    numeroDaCarta, totalDeCartas: integer;
    listaArq: TStringList;

{-------------------------------------------------------------}
{       prepara arquivo em formato original
{-------------------------------------------------------------}

function enviaOriginal (codificando: boolean): boolean;
const tabhexa: array [0..15] of char =
           ('0','1','2','3','4','5','6','7','8','9',
            'A','B','C','D','E','F');
var i: integer;
    c: char;
    s: string;

    {-------------------------------------------------------------}
    function escreveNoArq: boolean;
    begin
        escreveNoArq := true;

        if codificando then
            begin
                i := 1;
                while i <= length (s) do
                    begin
                         if (s[i] = '=') or (s[i] > #$7e) or (s[i] < #$20) then
                             begin
                                 c := s[i];
                                 s [i] := '=';
                                 insert (tabhexa [ord (c) shr 4], s, i+1);
                                 insert (tabhexa [ord (c) and $f], s, i+2);
                                 i := i + 2;
                             end;

                         i := i + 1;
                    end;

            end;

        {$I-}  writeln (arqEnv, s);  {$I+}
        if ioresult <> 0 then
            escreveNoArq := false;
    end;

label erro;
begin
    enviaOriginal := true;

    if mensagemSaudacao <> '' then
        begin
            s := mensagemSaudacao;
            if not escreveNoArq then goto erro;
        end;

    if eof (arqOrig) then
        begin
            {$I-}  writeln (arqEnv, '');  {$I+}
            if ioresult <> 0 then;
        end
    else
    while not eof (arqOrig) do
        begin
            readln (arqOrig, s);
            if (s = '.') then s := ' .';

            if not escreveNoArq then goto erro;
        end;

    {$I-} close (arqOrig); {$I+}
    if ioresult <> 0 then;
    exit;

erro:
    enviaOriginal := false;
    {$I-} close (arqOrig); {$I+}
    if ioresult <> 0 then;
end;

{-------------------------------------------------------------}
{       Desaloca a lista de anexos da memória
{-------------------------------------------------------------}

procedure desalocaAttachments;
var i: integer;
begin
    for i :=  narqMime downto 1 do
        dispose (tabArqMime [i]);
end;

{-------------------------------------------------------------}
{       gera chave de acesso Mime
{-------------------------------------------------------------}

procedure geraChaveMime;
var i, n: integer;
    s: string;
begin
    chaveMime := '----=_NextPart_';             { gera chave Mime randomica }
    for i := 1 to 10 do
        begin
            n := random (255);
            str (n, s);
            chaveMime := chaveMime + s;
        end;
end;

{-------------------------------------------------------------}
{       prepara os arquivos atachados
{-------------------------------------------------------------}

procedure enviaAttachments (nomeArq, chaveMime: string;
                            encaminhar: boolean; nCar: integer; mudo: boolean);
var
    i, k: integer;
    nome, tipoAplic: string;
    parte: pestrutura;
label proximo;

    {----------------------------------------------------------------}
    function simplifica (nomeOrig: string): string;
    var nome: string;
    begin
        nome := nomeOrig;
        while (pos ('\', nome) <> 0) and (trim(nome) <> '') do
            delete (nome, 1, pos ('\', nome) );
        while (pos ('/', nome) <> 0) and (trim(nome) <> '') do
            delete (nome, 1, pos ('/', nome) );
        if nome = '' then nome := 'x.dat';
        simplifica := nome;
    end;

    {----------------------------------------------------------------}
    function compatibilidadeOutlook (nome: string): string;
    begin
        if maiuscansi (copy (nome, length(nome)-3, 4)) = '.CAR' then
            compatibilidadeOutlook := copy(nome, 1, length(nome)-3)+'eml'
        else
            compatibilidadeOutlook := nome;
    end;

    {----------------------------------------------------------------}
    procedure escreveNoArquivo (lIni, lFim: integer);
    var
        s: string;
        houveErro: boolean;
    begin
    houveErro := false;
        while (not houveErro) and (lIni <= lFim) and
              (lIni >= 0) and (lFim < linhasArquivo.count) do
            begin
                s := linhasArquivo[LIni];
                {$I-} writeln (arqEnv, s); {$I+}
                if ioresult <> 0 then
                    begin
                        msgBaixo ('CTERRDSK');   {'Erro de escrita no disco'}
                        houveErro := true;
                    end;
                lIni := lIni + 1;
            end;
    end;

    {----------------------------------------------------------------}
    procedure escreverNomeAnexo (itemCabecalho, nome: string; colocarPontoeVirgula: boolean);
    begin
        if length (nome) < 21 then
            write (arqEnv, itemCabecalho, '"', codificarString (nome))
        else
            begin
                writeln (arqEnv, itemCabecalho);
                write (arqEnv, '        "', codificarString (copy (nome, 1, 40)));
                delete (nome, 1, 40);
                repeat
                    writeln (arqEnv);
                    write (arqEnv, ' ' + codificarString (copy (nome, 1, 40)));
                    delete (nome, 1, 40);
                until trim (nome) = '';
            end;
        if colocarPontoeVirgula then
            writeln (arqEnv, '";')
        else
            writeln (arqEnv, '"');
    end;

begin
    if chaveMime <> '' then
        writeln (arqEnv, '--', chaveMime);

    nome := simplifica (nomearq);
    tipoAplic := geraTipoAplic (nome);
    if tipoAplic = 'Unknown' then
        tipoAplic := 'text/plain';  //Primeira parte da carta é TXT
    write   (arqEnv, 'Content-Type: ' + tipoAplic + '; ');
    writeln (arqEnv, 'charset="iso-8859-1"');
    writeln (arqEnv, 'Content-Transfer-Encoding: quoted-printable');
    writeln   (arqEnv, 'X-MIME-Autoconverted: from 8bit to quoted-printable');
    writeln (arqEnv);
    enviaOriginal (true);

    if (encaminhar) and (trim(regLido[nCar]^.boundary) = '') and
       (maiuscAnsi(regLido[ncar]^.content_type) = 'TEXT/HTML') and
       ( carregaLinhasArquivo (regLido[ncar]^.carta^.nomArqCarta)) then
        begin
            writeln (arqEnv, '--'+chaveMime);
            write   (arqEnv, 'Content-Type: ' + regLido[ncar]^.content_type + '; ');
            writeln (arqEnv, 'charset="' + regLido[ncar]^.charset + '"');
            writeln (arqEnv, 'Content-Transfer-Encoding: ' + regLido[ncar]^.Content_Transfer_Encoding);
            writeln (arqEnv);
            escreveNoArquivo (regLido [nCar]^.linhaInicial,
                              regLido [nCar]^.linhaFinal);
            destroiLinhasArquivo;
        end
    else
    if (nCar > 0) and (trim(regLido[nCar]^.boundary) <> '') and (encaminhar) and
       ( carregaLinhasArquivo (regLido[ncar]^.carta^.nomArqCarta)) then
        begin
            criaIndicePartes;
            montaTudo (regLido[nCar]);
            if (maiuscAnsi(typeOuContent_type (listaDePartes[0])) = 'TEXT/PLAIN') or
((not encaminhar) and                (maiuscAnsi(typeOuContent_type (listaDePartes[0])) = 'TEXT/HTML')) then
                k := 1
            else
                k:= 0;
            for i := k to (listaDePartes.count - 1) do
                begin
                    parte := listaDePartes[i];
                    linhasArquivo[parte^.linhaInicialCab - 1] := '--'+chaveMime;
                    escreveNoArquivo (parte^.linhaInicialCab - 1, parte^.linhaFinal);
                end;
            destroiIndicePartes;
            desmontaTudo (regLido[ncar]);
            destroiLinhasArquivo;
        end;

    if not mudo then
        msgBaixo ('CTMOMENT');  {'Um momento...'}
    for i := 1 to narqMime do
        begin
            writeln (arqEnv, '--', chaveMime);
            nome := simplifica (tabArqMime [i]^);
            tipoAplic := geraTipoAplic (nome);
            if tipoAplic = 'message/rfc822' then
                begin
                    nome := compatibilidadeOutlook (nome);
                    //compatibilidadeOutlook Muda extensao car para eml
                    tipoConvMime [i] := 'N';
                end;

            case tipoConvMime [i] of       { tenta abrir o arquivo }
                'N', 'I':
                        begin
                            assign (arqOrig, tabArqMime [i]^);
                            {$I-} reset (arqOrig); {$I+}
                        end;

                'U', 'M':
                        begin
                            assign (arqBin, tabArqMime [i]^);
                            {$I-} reset (arqBin, 1); {$I+}
                        end;
            end;

            if ioresult <> 0 then
                begin
                    msgBaixo ('CTERRLEI');  {'Erro de leitura do arquivo'}
                    sintWriteln (tabArqMime [i]^);
                    goto proximo;
                end;

            case  tipoConvMime [i] of   { gera cabecalho e manda }

                'N':
                    begin
                        write   (arqEnv, 'Content-Type: ' + tipoAplic + '; ');
                        escreverNomeAnexo ('name=', nome, true); 
                        writeln (arqEnv, '    charset="us-ascii"');
                        write   (arqEnv, 'Content-Disposition: attachment; ');
                        escreverNomeAnexo ('filename=', nome, false);
                        writeln (arqEnv);
                        enviaOriginal (false);
                    end;

                'I':
                    begin
                        write   (arqEnv, 'Content-Type: ' + tipoAplic + '; ');
                        escreverNomeAnexo ('name=', nome, true);
                        writeln (arqEnv, '    charset="iso-8859-1"');
                        writeln (arqEnv, 'Content-Transfer-Encoding: quoted-printable');
                        write   (arqEnv, 'Content-Disposition: attachment; ');
                        escreverNomeAnexo ('filename=', nome, false);
                        write   (arqEnv, 'X-MIME-Autoconverted: from 8bit to quoted-printable ');
                        writeln (arqEnv, 'by intervox.nce.ufrj.br id dosvox');
                        writeln (arqEnv);
                        enviaOriginal (true);
                    end;

                'U':
                    begin
                        write   (arqEnv, 'Content-Type: ' + tipoAplic + '; ');
                        escreverNomeAnexo ('name=', nome, false); 
                        writeln (arqEnv, 'Content-Transfer-Encoding: x-uuencode');
                        write   (arqEnv, 'Content-Disposition: attachment; ');
                        escreverNomeAnexo ('filename=', nome, false);
                        writeln (arqEnv);
                        uuencode (tabArqMime [i]^, 'c:\$.$');
                        assign (arqOrig, 'c:\$.$');
                        {$I-} reset (arqOrig); {$I+}
                        if ioresult = 0 then
                            enviaOriginal (false);
                        {$I-} erase (arqOrig); {$I+}
                        if ioresult = 0 then;
                    end;

                'M':
                    begin
                        write   (arqEnv, 'Content-Type: ' + tipoAplic + '; ');
                        escreverNomeAnexo ('name=', nome, false);
                        writeln (arqEnv, 'Content-Transfer-Encoding: base64');
                        write   (arqEnv, 'Content-Disposition: attachment; ');
                        escreverNomeAnexo ('filename=', nome, false); 
                        writeln (arqEnv);
                        codifMime64;
                        close (arqBin);
                        while sintFalando do waitMessage;
                    end;
            end;

proximo:
        end;

    if chaveMime <> '' then
        writeln (arqEnv, '--', chaveMime, '--');
end;

{-------------------------------------------------------------}
{       prepara formato SMTP para envio
{-------------------------------------------------------------}

function geraTextoSMTP (nomeArq, nomeDest, assunto: string;
                        pCC, pBCC:                          pListaCC;
                        encaminhar, confReceb, mudo: boolean; nCar: integer;
                        in_reply_to_: string; adicionarCarbono: boolean): string;
var
    nomeArqEnviar, references_: string;
    Year, Month, Day, DayOfWeek: Word;
    Hour, Minute, Second, Sec100: Word;
    i1, i2: integer;
const
    tabMes: array [1..12] of string [3] = (
       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
label erro;

begin
    geraTextoSMTP := '';
    nomeArqEnviar := novoNomeCarta (nbaseEnvia, dirEnvia, '.CPR');
    if nomeArqEnviar = '' then
        begin
            msgBaixo ('CTERRCNF');  {'Este programa está configurado com erro !'}
erro:
            msgBaixo('CTERRGER');  {'Não consegui gerar carta para envio'}
            msgBaixo ('CTNAOMAN');  {'Carta não será mandada'}
            exit;
        end;

    assign (arqOrig, nomeArq);
    {$I-}  reset (arqOrig);  {$I+}
    if ioresult <> 0 then
        begin
            msgBaixo ('CTARQSUM');  {'Arquivo a enviar sumiu !'}
            msgBaixo ('CTNAOMAN');  {'Carta não será mandada'}
            exit;
        end;

    assign (arqEnv, nomeArqEnviar);
    {$I-}  rewrite (arqEnv);  {$I+}
    if ioresult <> 0 then goto erro;

    i1 := pos ('<', enderUsuario);
    if i1 <> 0 then
        begin
            i2 := pos ('>', enderUsuario);
            enderUsuario := copy (enderUsuario, i1, i2-i1+1);
            writeln (arqEnv, 'MAIL FROM:', enderUsuario)
        end
    else
        writeln (arqEnv, 'MAIL FROM:<', enderUsuario, '>');

    if (nomeDest <> '') and (nomeDest <> '<Undisclosed-Recipient:;>') then
        begin
            i1 := pos ('<', nomeDest);
            if i1 <> 0 then
                begin
                    i2 := pos ('>', nomeDest);
                    nomeDest := copy (nomeDest, i1, i2-i1+1);
                    writeln (arqEnv, 'RCPT TO:', nomeDest)
                end
            else
                writeln (arqEnv, 'RCPT TO:<', nomeDest, '>');
        end;
    if adicionarCarbono then
        geraRCPTCC;

    writeln (arqEnv, 'DATA');
    getDate(Year, Month, Day, DayOfWeek);
    write (arqEnv, 'Date: ', Day, ' ', tabMes [Month], ' ', Year);
    dvcrt.getTime (Hour, Minute, Second, Sec100);
    writeln (arqEnv,  ' ', Hour, ':', Minute, ':', Second, ' -0300');

    if enderResposta <> '' then
        writeln (arqEnv, 'Reply-To: ', enderResposta);

    //Pega a identificação para o "fio da discussão" na resposta a uma carta
    if (not encaminhar or ((not folheiaRecebidas) and (not folheiaTransmitidas))) and
       (in_reply_to_ <> '') and (nCar > 0) then
        begin
            if trim(regLido[nCar]^.carta^.references_) <> '' then
                references_ := trim(regLido[nCar]^.carta^.references_)
            else
            if trim(regLido[nCar]^.carta^.in_reply_to_) <> '' then
                references_ := trim(regLido[nCar]^.carta^.in_reply_to_)
            else
                references_ := in_reply_to_;
            writeln (arqEnv, 'References: ' + references_);
            writeln (arqEnv, 'In-Reply-To: ' + in_reply_to_);
        end;
    writeln (arqEnv, 'Message-ID: ' + geraChaveId);

    if nomeUsuario <> '' then
        writeln (arqEnv, 'From: "', codificarString (nomeUsuario), '" <', enderUsuario, '>')
    else
        writeln (arqEnv, 'From: <', enderUsuario, '>');

    if nomeDest = '' then
        writeln (arqEnv, 'To: <Undisclosed-Recipient:;>')
    else
        writeln (arqEnv, 'To: ', nomeDest);

    if confReceb then
        writeln(arqEnv, 'Disposition-Notification-To:' + enderUsuario);

    writeln (arqEnv, 'Subject: ', codificarString (copy (assunto, 1, 34)));
    delete (assunto, 1, 34);
    while trim (assunto) <> '' do
        begin
            writeln (arqEnv, ' '+ codificarString (copy (assunto, 1, 34)));
            delete (assunto, 1, 34);
        end;

    if (adicionarCarbono ) and ((pCC <> NIL) or (pBCC <> NIL)) then
        gravaCC;

    writeln (arqEnv, 'Mime-Version: 1.0');
    if chaveMime <> '' then
        begin
            writeln   (arqEnv, 'Content-Type: multipart/mixed;');
            write   (arqEnv, '        boundary=');
            writeln (arqEnv, '"', chaveMime, '"');
        end;

    if chaveMime <> '' then
    writeln (arqEnv);

    enviaAttachments (nomeArq, chaveMime, encaminhar, nCar, mudo);

    {$I-}  writeln (arqEnv, '.');  {$I+}
    if ioresult <> 0 then
        begin
            {$I-} close (arqOrig);  {$I+}
            if ioresult <> 0 then;
            close (arqEnv);
            goto erro;
        end;

    close (arqEnv);
    while keypressed do readkey;
    if not mudo then
        msgBaixo ('CTCARPRP');  {'Carta preparada para envio'}

    geraTextoSMTP := nomeArqEnviar;
end;

{-------------------------------------------------------------}
{       atacha arquivos a carta
{-------------------------------------------------------------}

procedure atachaArquivos(nomeArq: string);
var
    c: char;
    nomeArqAttach, dirAtual: string;
    i, posBarra, primElem: integer;
    contemDir: boolean;

begin
    getDir (0, dirAtual);
    if (dirAtual[length(dirAtual)] <> '\') and (dirAtual[length(dirAtual)] <> '/') then
        dirAtual := dirAtual + '\';
    if trim (chaveMime) = '' then
        geraChaveMime;

    if trim (nomeArq) <> '' then
        begin
            if existeArq (nomeArq) then
                begin
                    narqMime := narqMime + 1;
                    new (tabArqMime [narqMime]);
                    tabArqMime [narqMime]^ := nomeArq;
                    tipoConvMime [narqMime] := 'M'; {Mime64}
                end;
        end
    else
    repeat
        mensagem ('CTNOMATA', 1);     {'Nome do arquivo a enviar: '}
        garanteEspacoTela (10);
        nomeArqAttach := obtemNomeArqMascAnexo (10, '*.*');
        posBarra := pos('|', nomeArqAttach);
        if posBarra = 1 then
            begin
                writeln;
                contemDir := true;
                primElem := 1;
            end
        else
            begin
                contemDir := false;
                primElem := 0;
            end;
        listaArq := TStringList.Create;
        split('|', nomeArqAttach, listaArq);
        for i := primElem to listaArq.count-1 do
            begin
                writeln (listaArq[i]);
            end;

        if trim (nomeArqAttach) = '' then
            begin
                sintbip;
                exit;
            end
        else
            begin
                for i := primElem to listaArq.count-1 do
                    begin
                        if contemDir then
                            nomeArqAttach := listaArq[0] + listaArq[i]
                        else if (pos ('\', listaArq[i]) = 0) and (pos ('/', listaArq[i]) = 0) then
                            nomeArqAttach := dirAtual + listaArq[i];
                        if not existeArq(nomeArqAttach) then
                            begin
                                msgBaixo ('CTATAINV');   {'Nome de arquivo inválido'}
                                break;
                            end;
                        if i = primElem then
                            repeat
                                mensagem ('CTCNVPAD', 0);  {'Posso usar a conversão padrao (s/n) ? '}
                                c := upcase(popupMenuPorLetra ('SN'));
                                writeln;
                            until c in ['S', 'N', 'M', 'I', 'U', ENTER];

                        narqMime := narqMime + 1;
                        new (tabArqMime [narqMime]);
                        tabArqMime [narqMime]^ := nomeArqAttach;

                        if c = 'N' then
                            repeat
                                mensagem ('CTTIPMIM', 0);  {'Tipo de conversao:}
                                {Mime, Nenhuma, Iso-latin ou Uuencode ? '}
                                c := upcase(popupMenuPorLetra ('MNIU'));
                                writeln;
                            until c in ['M', 'N', 'I', 'U']
                        else
                            if maiuscansi (copy (nomeArqAttach, length (nomeArqAttach)-3, 4)) = '.TXT' then
                                c := 'I';

                        case c of
                            'N':  tipoConvMime [narqMime] := 'N';  { nenhuma }
                            'I':  tipoConvMime [narqMime] := 'I';  { conversão ISO }
                            'U':  tipoConvMime [narqMime] := 'U';  { uuencode }
                        else
                            tipoConvMime [narqMime] := 'M';  { mime64 }
                        end;
                   end;
            end;

        mensagem ('CTMAISAR', 0);     {'Mais arquivos (s/n) ?'}
        c := upcase(popupMenuPorLetra ('SN'));
        writeln;
    until c in ['N', ENTER, ESC];

end;

{-------------------------------------------------------------}
{       anexa assinatura a texto criado
{-------------------------------------------------------------}

function anexaAssinatura (nomeArq: string; arqVazio: boolean; var cancelar: char): string;
var
    arqAssina, arqNovo: text;
     nomeArqNovo, s: string;
    c: char;
    i: integer;
begin
    cancelar := 'N';
    anexaAssinatura := nomeArq;
    if nomeAssinatura = '' then exit;
    if nomeArq = '' then exit;

    if inserirAssinatura then
        c := 'S'
    else
    repeat
        textBackGround (MAGENTA);
        mensagem ('CTADIASS', 0);   {'Adiciona sua assinatura ? '}
        c := upcase(popupMenuPorLetra ('SN'));
        textBackGround (BLACK);
        writeln;
    until c in ['S', 'N', ENTER, ESC];
    if c in ['N', ENTER] then exit;
    if c = ESC then
        begin
            cancelar := 'S';
            exit;
        end;

    nomeArqNovo := dirEnvia+ '\$.$';

    if arqVazio then
        begin
            assign (arqNovo, nomeArqNovo);
            {$I-} rewrite (arqNovo); {$I+}
            if ioresult <> 0 then
                begin
                    msgBaixo ('CTERRDSK');   {'Erro de escrita no disco'}
                    exit;
                end;
        end
    else
    if not arqVazio and carregaLinhasArquivo (nomeArq) then
        begin
            assign (arqNovo, nomeArqNovo);
            {$I-} rewrite (arqNovo); {$I+}
            if ioresult <> 0 then
                msgBaixo ('CTERRDSK')   {'Erro de escrita no disco'}
            else
            if linhasArquivo.count < 1 then
                arqVazio := true
            else
            for i := 0 to (linhasArquivo.count-1) do
                begin
                    {$I-}  writeln (arqNovo, linhasArquivo[i]);   {$I+}
                    if ioresult <> 0 then
                        begin
                            msgBaixo ('CTERRDSK');   {'Erro de escrita no disco'}
                            break;
                        end;
                end;
            destroiLinhasArquivo;
        end
    else
        exit;

    if arqVazio then
        begin
            {$I-}  writeln (arqNovo, '');   {$I+}
            if ioresult <> 0 then;
        end;

    assign (arqAssina, nomeAssinatura);
    {$I-}  reset (arqAssina);  {$I+}
    if ioresult = 0 then
    while not eof (arqAssina) do
        begin
            {$I-}  readln (arqAssina, s);  {$I+}
            if ioresult = 0 then
                begin
                    {$I-}  writeln (arqNovo, s);   {$I+}
                    if ioresult <> 0 then
                        begin
                            msgBaixo ('CTERRDSK');   {'Erro de escrita no disco'}
                            break;
                        end;
                end;
        end;

    {$I-} close (arqNovo); {$I+}
    if ioresult <> 0 then;
    {$I-} close (arqAssina); {$I+}
    if ioresult <> 0 then;

    anexaAssinatura := nomeArqNovo;
end;

{-------------------------------------------------------------}
{       transmitir uma carta
{-------------------------------------------------------------}

const
    SMTP_OK   = 1;
    SMTP_ERRO = -1;
    SMTP_CAIU = -2;
    SMTP_CANCELOU= 0;

function enviaUmaCartaSMTP (nomeArq: string): integer;
var
    arq: text;
    i, ncb, lidos: integer;
    s: string;
    dandoErros, ok, cancelou: boolean;
    pbenv: pchar;
    r1 : char;

label caiu, inicio;


    function descarrega: boolean;
    var
        i, n: integer;
        tam: longint;
        c: char;
    begin
        write ('*');
        if keypressed then     { cancelamento }
            begin
                c := readkey;
                if c = #$1b then
                    begin
                        cancelou := true;
                        descarrega := false;
                        exit;
                    end
                else
                if c = ' ' then
                    begin
                        mudo := not mudo;
                        limpaBufTec;
                    end
                else
                    begin
                        limpaBufTec;
                        write (#$0d);  clreol;
                        mensagem ('CTCARTA', 0); {' Carta '}
                        sintwrite (' '+ intToStr(numeroDaCarta) + '/'+ intToStr (totalDeCartas)+ ' ');
                        if tamanhoCarta > 0 then
                            begin
                                tam :=(quantosEnviado *100) div tamanhoCarta;
                                if tam >= 0 then
                                    sintWriteln (intToStr(tam) + '% de ' +
                                      formataTamanhoArq (tamanhoCarta));
                            end;
                    end;
            end;

        if not mudo then
            if bipaNoSpeaker then bipSpeaker (220)
                             else sintClek;

        i := 0;
        repeat
        pbenv := @bufEnvia [i];
        n := sendBuf (sockSMTP, pbenv, ncb, 0);
        if n <= 0 then
            begin
                close (arq);
                descarrega := false;
                exit;
            end
        else
            begin
                i := i + n;
                quantosEnviado := quantosEnviado + i;
                ncb := ncb - n;
            end;
        until ncb = 0;
        descarrega := true;
    end;

begin
    enviaUmaCartaSMTP := SMTP_OK;

    assign (arq, nomeArq);
    {$I-}  reset (arq);  {$I+}
    if ioresult <> 0 then
        begin
            msgBaixo ('CTPROENV');  {'Problema de arquivo ao enviar a carta '}
            sintetiza (nomeArq);
            enviaUmaCartaSMTP := SMTP_ERRO;
            exit;
        end;

    s := '';
    i := 0;
    while s <> 'DATA' do
        begin
            readln (arq, s);
            StrPCopy (bufEnvia, s + CRLF);
            sendbuf (sockSMTP, bufEnvia, strlen (bufEnvia), 0);
            netDebug (bufEnvia, strlen (bufEnvia));

            i := i + 1;

            lidos := receive (sockSMTP, bufRecebe, BUFSIZE, 0);
            if lidos <= 0 then
                goto caiu;
            bufRecebe [lidos] := #$0;
            netDebug (bufRecebe, strlen (bufRecebe));

            ok := (strlcomp (bufRecebe, '250', 3) = 0) or
                  (strlcomp (bufRecebe, '251', 3) = 0) or
                  (strlcomp (bufRecebe, '354', 3) = 0) or
                  (strlcomp (bufRecebe, '503', 3) = 0);

            if not ok then
                begin
//                    senhaSalva := '';
                    textBackGround (RED);
                    mensagem ('CTERENVC', 0);  {'Erro ao enviar a carta.  Servidor reclamou de '}
                    textBackGround (BLACK);
                    writeln;
                    if copy (s, 1, 10) = 'MAIL FROM:' then delete (s, 1, 10);
                    if copy (s, 1, 10) = 'RCPT TO:' then delete (s, 1, 8);
                    sintWriteln (s);

                    mensagem ('CTVEJMEN', 0);  {'Veja mensagem do servidor:'}
                    textBackGround (BLACK);
                    clreol;
                    writeln;

                    repeat
                         sintWrite (strPas (bufRecebe));
                         delay (1000);
                         dandoErros := temDadoSock (sockSMTP);
                         if dandoErros then
                             begin
                                  lidos := receive (sockSMTP, bufRecebe, BUFSIZE, 0);
                                  bufRecebe [lidos] := #$0;
                             end;
                    until not dandoErros or (lidos = 0);

                    if i < 3 then   { MAIL FROM e RCPT TO do principal }
                        begin
                            enviaUmaCartaSMTP := SMTP_ERRO;
                            {$I-} close (arq); {$I+}
                            if ioresult <> 0 then ;
                            exit;
                        end;
                end;
        end;

    ncb := 0;
    while not eof (arq) do
        begin
            readln (arq, s);
            s := s + crlf;
            for i := 1 to length (s) do
                begin
                    bufEnvia [ncb] := s[i];
                    ncb := ncb + 1;
                end;

            if ncb > (BUFSIZE - 255) then
                begin
                inicio:
                    cancelou := false;
                    if not descarrega then goto caiu;
                end;
        end;

    if ncb > 0 then
        if not descarrega then goto caiu;

    {$I-} close (arq); {$I+}
    if ioresult <> 0 then ;

    lidos := receive (sockSMTP, bufRecebe, BUFSIZE, 0);
    if lidos <= 0 then goto caiu;
    bufRecebe [lidos] := #$0;
    netDebug (bufRecebe, strlen (bufRecebe));

    ok := (strlcomp (bufRecebe, '2', 1) = 0);
    if not ok then
        enviaUmaCartaSMTP := SMTP_ERRO;

    exit;

caiu:
    if cancelou then
        begin
            repeat
                writeln;
                mensagem ('CTCANTRA', 0); {'Deseja cancelar a transmissão das cartas?:'}
                r1 := upcase(popupMenuPorLetra ('SN'));
            until r1 in ['S', 'N', ENTER, ESC];
            if r1 in ['N', ESC] then
                goto inicio;
        end;

    {$I-} close (arq); {$I+}
    if ioresult <> 0 then ;
    if not cancelou then
        begin
            msgBaixo ('CTCONCAI');  {'Conexão de dados caiu'}
        enviaUmaCartaSMTP := SMTP_CAIU;
        end
    else
        enviaUmaCartaSMTP := SMTP_CANCELOU;
end;

{-------------------------------------------------------------}
{       abre smtp com ou sem senha
{-------------------------------------------------------------}

function abreSmtp: boolean;
var lidos: integer;
    senhaUsuario: string;
    salvaAttr: word;
    c1: char;
label erro, desistiu;

        function sendAndRec (s: string; r: pchar): boolean;
        begin
            sendAndRec := false;

// Trecho comentado abaixo saiu para entrar a contribuição do Fabiano .
(*//Neno            delay (500);
            if temDadoSock (sockSMTP) then
                begin
                    delay (500);
                    lidos := receive (sockSMTP, bufRecebe, BUFSIZE, 0);
                end;
*)//Neno

// Abaixo trecho do Fabiano que substituiu o acima.
            while temDadoSock (sockSMTP) do
                begin
                    lidos := receive (sockSMTP, bufRecebe, BUFSIZE, 0);
            netDebug (bufRecebe, lidos);
                end;

            StrPCopy (bufEnvia, s + CRLF);
            sendbuf (sockSMTP, bufEnvia, strlen (bufEnvia), 0);
            netDebug (bufEnvia, strlen (bufEnvia));

            lidos := receive (sockSMTP, bufRecebe, BUFSIZE, 0);
            if lidos <= 0 then
                begin
                    senhaSalva := '';
                    exit;
                end;
            bufRecebe [lidos] := #$0;
            netDebug (bufRecebe, lidos);

            sendAndRec := strlcomp (bufRecebe, r, 3) = 0;
        end;

begin
    abreSmtp := true;
    if smtpComSenha then
        begin
            if trim (senhaSalva) = '' then
                begin
                    mensagem ('CTINFSEN', 1);  {'Informe sua senha'}
                    salvaAttr := textAttr;
                    textColor (black);
                    senhaUsuario  := '';
                    c1 := sintEditaCampoMudo (senhaUsuario, 1, wherey, 255, 80, true);
                    writeln;
                    textAttr := salvaAttr;
                    if trim (senhaUsuario) <> '' then senhaSalva := senhaUsuario;
                    if (c1 = ESC) or (senhaUsuario = '') then goto desistiu;
                end
            else
                senhaUsuario:= senhaSalva;

            if not sendAndRec ('EHLO ' + semAcentos(computLocal), '250') then goto erro;
            if smtpComTLS then
                begin
                    if not sendAndRec ('STARTTLS', '220') then goto erro;
                    if not ativaSSL (sockSMTP) then
                        begin
                            strcopy (bufRecebe, '500 TLS error');
                            goto erro;
                        end;
                    if not sendAndRec ('EHLO ' + semAcentos(computLocal), '250') then goto erro;
                end;

            if not sendAndRec ('AUTH LOGIN', '334') then goto erro;
            if not sendAndRec (codFraseMime64 (contaUsuario), '334') then goto erro;
            if not sendAndRec(codFraseMime64 (senhaUsuario), '235') then goto erro;
        end
    else
        begin
            if not sendAndRec ('HELO '+ semAcentos(computLocal), '250') then goto erro;
        end;

    exit;

erro:
    senhaSalva := '';
    if lidos <= 0 then
        strcopy (bufRecebe, MSG_CONEXAOCANC);
    textBackGround (RED);
    mensagem ('CTSRVNGO', 1);  {'Servidor não gostou dessa conexão, ele mandou esta mensagem'}
    textBackGround (BLACK);
    sintWriteln (strPas (bufRecebe));

desistiu:
    abreSmtp := false;
end;

{-------------------------------------------------------------}
{       conecta para transmitir cartas via SMTP
{-------------------------------------------------------------}

function abreConexaoSmtp (mudo: boolean): boolean;
var lidos: integer;

begin
    abreConexaoSmtp := false;
    sockSMTP := abreConexao (hostSMTP, portaSMTP, mudo);
    if sockSMTP = -1 then exit;

    if smtpComSSL then
        if not ativaSSL(sockSMTP) then
            begin
                mensagem ('CTSSLNAO', 2);   {'Segurança SSL não pode ser ativada'}
                fechaConexao (sockSMTP);
                exit;
            end;

    lidos := receive (sockSMTP, bufRecebe, BUFSIZE, 0);
    if (lidos <= 0) then exit;
    bufRecebe [lidos] := #$0;
    netDebug (bufRecebe, lidos);

    if strlcomp (bufRecebe, '220', 3) <> 0 then
        begin
            textBackGround (RED);
            mensagem ('CTSRVNAO', 1);  {'Servidor não quer conversa, ele mandou esta mensagem'}
            textBackGround (BLACK);
            sintWriteln (strPas (bufRecebe));
            exit;
        end
    else
        netDebug (bufRecebe, lidos);
    abreConexaoSmtp := true;
end;

{-------------------------------------------------------------}

function fechaSmtp: boolean;
var lidos: integer;
begin
    fechaSmtp := false;
    StrPCopy (bufEnvia, 'QUIT '+ semAcentos(computLocal) + CRLF);
    sendbuf (sockSMTP, bufEnvia, strlen (bufEnvia), 0);
    netDebug (bufEnvia, strlen (bufEnvia));

    lidos := receive (sockSMTP, bufRecebe, BUFSIZE, 0);
    if (lidos <= 0) then exit;

    bufRecebe [lidos] := #$0;
    netDebug (bufRecebe, lidos);

    fechaConexao (sockSMTP);
    fechaSmtp := true;
end;

{-------------------------------------------------------------}

procedure trataMudo;
var s: string;
begin
    s := sintAmbiente ('CARTAVOX', 'CLEK');
    if trim (s) = '' then
        mudo := false
    else
        mudo := copy (s, 1, 1) = 'N';
end;

{-------------------------------------------------------------}

procedure transmitirCartas (doFolheamento: boolean; tipoFolheamento: char; mudo: boolean);
var
    i: integer;

    function enviarTodas: boolean;
    var
        dirAtual: string;
        dirInfo: TSearchRec;
        dosError: integer;
        arqApaga: file;
        tipoErro: integer;
        c: char;
    label erro;
    begin
        getDir (0, dirAtual);
        {$I-}  chdir (dirEnvia);  {$I+}
        if ioresult <> 0 then
            begin
                msgBaixo ('CTDIRSUM');  {'O diretorio de cartas sumiu !'}
                goto erro;
            end;
        fillChar (dirInfo, 0, sizeof (dirInfo));
        numeroDaCarta := 1;
        dosError := findFirst ('*.CPR', faArchive, dirInfo);
        while dosError = 0 do
            begin
                write (dirInfo.name, ' ');
                quantosEnviado := 0;
                tamanhoCarta := (dirInfo.size);
                setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Transmitindo... ' + intToStr(numeroDaCarta) + ' de ' +intToStr(totalDeCartas));
                tipoErro := enviaUmaCartaSMTP (dirInfo.name);
                case tipoErro of
                    SMTP_CAIU, SMTP_CANCELOU:  goto erro;
                    SMTP_OK:
                        begin
                            if guardaEnviadas then
                                tiraCopia (dirInfo.name);
                            assign (arqApaga, dirInfo.name);
                            {$I-}  erase (arqApaga);  {$I+}
                        end;
                else
                    mensagem ('CTCNFAPC', 0);    {'Posso apagar esta carta com erro ? '}
                    c := upcase(popupMenuPorLetra ('SN'));
                    writeln;
                    if c = 'S' then
                        begin
                            assign (arqApaga, dirInfo.name);
                            {$I-}  erase (arqApaga);  {$I+}
                        end;
                end;

                numeroDaCarta := numeroDaCarta + 1;
                dosError := findNext (dirInfo);

                if (esperaSMTP >= 0) and ((numeroDaCarta mod quantasEnviar) = 0) and (dosError = 0) then
                    begin
                        if not fechaSmtp then goto erro;
                        delay (esperaSMTP);
                        if not abreConexaoSmtp (true) then goto erro;
                        if not abreSmtp then goto erro;
                    end;
                writeln;
            end;
        {$I-}  chDir (dirAtual);   {$I+}
        if ioresult <> 0 then ;
        if not fechaSmtp then goto erro;
        enviarTodas := true;
        exit;
    erro:
        enviarTodas := false;
    end;

    function enviarDoFolheamento(selecionadas: boolean): boolean;
    var
        nomeArq: string;
        arqApaga: file;
        tipoErro: integer;
        c: char;
        n: integer;
    label erro;
    begin
        numeroDaCarta := 0;
        for n := 1 to numRegs do
            begin
                if ( selecionadas) and (not regLido[n]^.selecionado) then
                    continue;
                nomeArq := regLido[n]^.carta^.nomArqCarta;
                write (nomeArq, ' ');
                quantosEnviado := 0;
                tamanhoCarta := (regLido [n]^.carta^.tamanho);
                numeroDaCarta := numeroDaCarta + 1;
                setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Transmitindo... ' + intToStr(numeroDaCarta) + ' de ' +intToStr(totalDeCartas));
                tipoErro := enviaUmaCartaSMTP (nomeArq);
                case tipoErro of
                    SMTP_CAIU, SMTP_CANCELOU: goto erro;
                    SMTP_OK:
                        begin
                            if guardaEnviadas then
                                tiraCopia (nomeArq);
                            assign (arqApaga, nomeArq);
                            {$I-}  erase (arqApaga);  {$I+}
                        end;
                else
                    mensagem ('CTCNFAPC', 0);    {'Posso apagar esta carta com erro ? '}
                    c := upcase(popupMenuPorLetra ('SN'));
                    writeln;
                    if c = 'S' then
                        begin
                            assign (arqApaga, nomeArq);
                            {$I-}  erase (arqApaga);  {$I+}
                        end;
                end;

                if (esperaSMTP >= 0) and ((numeroDaCarta mod quantasEnviar) = 0) and (numeroDaCarta < numRegs) then
                    begin
                        if not fechaSmtp then goto erro;
                        delay (esperaSMTP);
                        if not abreConexaoSmtp (true) then goto erro;
                        if not abreSmtp then goto erro;
                    end;
                writeln;
            end;

        if not fechaSmtp then goto erro;
        enviarDoFolheamento := true;
        exit;
    erro:
        enviarDoFolheamento := false;
    end;


label erro;

begin
    trataMudo;

    if doFolheamento then
        begin
            if temItemSelecionado then
                begin
                    totalDeCartas := 0;
                    for i := 1 to numRegs do
                        if regLido[i]^.selecionado then totalDeCartas := totalDeCartas + 1;
                end
            else
                totalDeCartas := numRegs;
        end
    else
        totalDeCartas := numeroDeCartas (dirEnvia, 'P');

    if totalDeCartas < 1 then
        begin
            msgBaixo ('CTTODENV');  {'Todas as cartas já foram enviadas'}
            exit;
        end;

    setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Transmitindo...');
    if not mudo then
        if totalDeCartas > 1 then
            begin
                msgBaixo ('CTCONTSV'); {'Contactando servidor para transmitir cartas'}
                sintetiza (intToStr(totalDeCartas));
            end
        else
            msgBaixo ('CTCONTSC');  {'Contactando servidor para transmitir carta'}

    if not abreConexaoSmtp (mudo) then goto erro;
    if not mudo then
        if totalDeCartas > 1 then
            msgBaixo ('CTENVCAR')  {'Enviando as cartas'}
        else
            msgBaixo ('CTENVACA');  {'Enviando carta'}
    if not abreSmtp then goto erro;

    if doFolheamento then
        begin
            if not enviarDoFolheamento (temItemSelecionado) then
                goto erro;
        end
    else
        if not enviarTodas then goto erro;

    if not mudo then
        msgBaixo ('CTFIMENV')  {'Fim de envio'}
    else
        msgBaixo ('CTOK');  {'Ok'}
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
    exit;

erro:
    fechaConexao (sockSMTP);
    writeln;
    msgBaixo ('CTCONCAN');  {'Conexao com servidor foi cancelada'}
    msgBaixo ('CTCARTAP');  {'Cartas permanecem prontas para ser enviadas'}
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
end;

{-------------------------------------------------------------}
{   Verifica se existe cartas preparadas e pergunta se deseja transmitir
{-------------------------------------------------------------}

function  transmitirPreparadas: boolean;
var
    c, c2: char;
    nCarPreparadas: integer;
    teclouESC: boolean;
begin
    teclouESC := false;
    nCarPreparadas := numeroDeCartas (dirEnvia, 'P');
    if nCarPreparadas > 0 then
        repeat
            msgBaixo ('CTEXTCAR');   {'Atenção: ainda existem cartas a serem enviadas'}
            sintetiza (intToStr (nCarPreparadas));
            if nCarPreparadas > 1 then
                mensagem ('CTCARTAS', -1) {'Cartas'}
            else
                mensagem ('CTCARTA', -1); {'Carta'}
            msgBaixo ('CTENVAGO'); {'Deseja transmitir agora?'}
            sintletecla (c, c2);
            if upcase (c) in ['S', ENTER] then
                begin
                    transmitirCartas (false, 'P', false);
                    nCarPreparadas := numeroDeCartas (dirEnvia, 'P');
                    if nCarPreparadas > 0 then c := 'A';
                end
            else
            if c = ESC then teclouESC := true;
        until (upcase (c) in ['S', 'N', ENTER, ESC]) or
        ((c = #0) and (c2 = BAIX));
    transmitirPreparadas := teclouESC;
end;

{-------------------------------------------------------------}
{     transmite as cartas preparadas do grupo de contas
{-------------------------------------------------------------}

function transmitirCartasGrupoContas: integer;

    function enviarTodas: boolean;
    var
        dirAtual, nomeConfigCar, nomeConfigAtual: string;
        dirInfo: TSearchRec;
        dosError, tam: integer;
        arqApaga: file;
        tipoErro, j: integer;
        c: char;
    label erro;
    begin
        getDir (0, dirAtual);
        {$I-}  chdir (dirEnvia);  {$I+}
        if ioresult <> 0 then
            begin
                msgBaixo ('CTDIRSUM');  {'O diretorio de cartas sumiu !'}
                goto erro;
            end;
        fillChar (dirInfo, 0, sizeof (dirInfo));
        numeroDaCarta := 1;
        dosError := findFirst ('*.CPR', faArchive, dirInfo);
        while dosError = 0 do
            begin
                nomeConfigCar := AnsiUpperCase(dirInfo.name);
                tam := length (nomeConfigCar);
                while tam > 0 do
                    begin
                        if copy (nomeConfigCar, tam, 1) <> '_' then
                            begin
                                nomeConfigCar := copy (nomeConfigCar, 1, tam-1);
                                tam := tam - 1;
                            end
                        else
                            begin
                                nomeConfigCar := copy (nomeConfigCar, 1, tam-1);
                                break;
                        end;
                    end;

                nomeConfigAtual := '';
                for j :=  length(nomeConfiguracao) downto 1 do
                    if nomeConfiguracao [j] in ['-', '_', 'A'..'Z', 'a'..'z', '0'..'9'] then
                        nomeConfigAtual := nomeConfiguracao[j] + nomeConfigAtual;

                if nomeConfigCar = nomeConfigAtual then
                    begin
                        write (dirInfo.name, ' ');
                        quantosEnviado := 0;
                        tamanhoCarta := (dirInfo.size);
                        tipoErro := enviaUmaCartaSMTP (dirInfo.name);
                        case tipoErro of
                            SMTP_CAIU, SMTP_CANCELOU:  goto erro;
                            SMTP_OK:
                                begin
                                    if guardaEnviadas then
                                        tiraCopia (dirInfo.name);
                                    assign (arqApaga, dirInfo.name);
                                    {$I-}  erase (arqApaga);  {$I+}
                                end;
                        else
                            mensagem ('CTCNFAPC', 0);    {'Posso apagar esta carta com erro ? '}
                            c := upcase(popupMenuPorLetra ('SN'));
                            writeln;
                            if c = 'S' then
                                begin
                                    assign (arqApaga, dirInfo.name);
                                    {$I-}  erase (arqApaga);  {$I+}
                                end;
                        end;

                        numeroDaCarta := numeroDaCarta + 1;
                        dosError := findNext (dirInfo);

                        if (esperaSMTP >= 0) and ((numeroDaCarta mod quantasEnviar) = 0) and (dosError = 0) then
                            begin
                                if not fechaSmtp then goto erro;
                                delay (esperaSMTP);
                                if not abreConexaoSmtp (true) then goto erro;
                                if not abreSmtp then goto erro;
                            end;
                        writeln;
                    end
                else
                    dosError := findNext (dirInfo);
            end;
        {$I-}  chDir (dirAtual);   {$I+}
        if ioresult <> 0 then ;
        if not fechaSmtp then goto erro;
        enviarTodas := true;
        exit;
    erro:
        enviarTodas := false;
    end;

label erro1, erro2;

begin
    transmitirCartasGrupoContas := 0;
    trataMudo;

    totalDeCartas := numeroDeCartasGrupoContas ('P');

    if totalDeCartas = -1 then goto erro2;
    if totalDeCartas < 1 then
        begin
            mensagem ('CTNAECTR', 0); {'Não existem cartas a serem transmitidas na conta '}
            sintWriteln (nomeConfiguracao);
            exit;
        end;
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Transmitindo...');

    mensagem ('CTCOSECO', 0); {'Contactando servidor para transmitir cartas da conta '}
    sintWriteln (nomeConfiguracao);
    sintetiza (intToStr(totalDeCartas));
    if not abreConexaoSmtp (false) then goto erro1;
    if totalDeCartas > 1 then
        msgBaixo ('CTENVCAR')  {'Enviando as cartas'}
    else
        msgBaixo ('CTENVACA');  {'Enviando carta'}
    if not abreSmtp then goto erro1;
    if not enviarTodas then goto erro1;
    msgBaixo ('CTFIMENV');  {'Fim de envio'}
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
    exit;

erro1:
    transmitirCartasGrupoContas := -1;
    fechaConexao (sockSMTP);
    writeln;
    msgBaixo ('CTCONCAN');  {'Conexao com servidor foi cancelada'}
    msgBaixo ('CTCARTAP');  {'Cartas permanecem prontas para ser enviadas'}
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
    exit;

erro2:
    transmitirCartasGrupoContas := -1;
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
end;

{-------------------------------------------------------------}
{       Enviar uma carta a partir do nome do arquivo da carta
{-------------------------------------------------------------}

function enviarUmaCarta (nomeArq: string; mudo: boolean): boolean;
var
    dirAtual: string;
    tipoErro: integer;
    arqApaga: file;
    c: char;
label erro;
begin
    trataMudo;
    getDir (0, dirAtual);
    {$I-}  chdir (dirEnvia);  {$I+}
    if ioresult <> 0 then
        begin
            msgBaixo ('CTDIRSUM');  {'O diretorio de cartas sumiu !'}
            goto erro;
        end;
    if not mudo then
        msgBaixo ('CTCONTSC');  {'Contactando servidor para transmitir carta'}
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao + ' - Transmitindo... 1 de 1');
    if not abreConexaoSmtp (mudo) then goto erro;
    if not mudo then
        msgBaixo ('CTENVACA');  {'Enviando carta'}
    if not abreSmtp then goto erro;
    tipoErro := enviaUmaCartaSMTP (nomeArq);
    case tipoErro of
        SMTP_CAIU, SMTP_CANCELOU:  goto erro;
        SMTP_OK:
            begin
                if (guardaEnviadas) and (copy(nomeArq, length(nomeArq)-2, 3) <> 'ENV') then
                    tiraCopia (nomeArq);
                if  copy(nomeArq, length(nomeArq)-2, 3) <> 'ENV' then
                    begin
                        assign (arqApaga, nomeArq);
                        {$I-}  erase (arqApaga);  {$I+}
                        if ioResult = 0 then;
                    end;
            end;
    else
        mensagem ('CTCNFAPC', 0);    {'Posso apagar esta carta com erro ? '}
        c := upcase(popupMenuPorLetra ('SN'));
        writeln;
        if c = 'S' then
            begin
                assign (arqApaga, nomeArq);
                {$I-}  erase (arqApaga);  {$I+}
            end;
    end;
    writeln;
    {$I-}  chDir (dirAtual);   {$I+}
    if ioresult <> 0 then ;
    if not fechaSmtp then goto erro;
    enviarUmaCarta := true;
    if not mudo then
        msgBaixo ('CTFIMENV');  {'Fim de envio'}
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
    exit;
erro:
    enviarUmaCarta := false;
end;

begin
end.
