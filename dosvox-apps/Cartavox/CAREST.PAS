{-------------------------------------------------------------}
{
{           Cartavox - Rotinas que montam a Estrutura da carta
{
{-------------------------------------------------------------}

unit carEst;

interface

uses
    classes,
    dvcrt,
    dvForm,
    dvwin,
    sysutils,
    windows,
    cardecod,
    carMsg,
    carUtil,
    carVars;

procedure zeraPCarta(carta: PCarta);
function inicializaPCarta: PCarta;
function inicializaPEstrutura: PEstrutura;
procedure preencheCartaPrincipal (aCarta: PEstrutura);
function carregaArqPreencheCabPrin (nCar: integer): boolean;
procedure adicionaUmRegCarta(nomeArq: string; tamanho, data: longInt; totalRegistros, posServ: integer);

procedure criaIndicePartes;
procedure destroiIndicePartes ;
procedure montaTudo (aCarta: PEstrutura);
procedure desmontaTudo (aCarta: PEstrutura);

implementation

{-------------------------------------------------------------}
{       Inicialização dos ponteiros PEstrutura, PCarta e PParte
{-------------------------------------------------------------}

procedure zeraPCarta(carta: PCarta);
begin
    with carta^ do
        begin
            preenchido := FALSE;
            nomArqCarta := '';
            nomArqCartaEnviar := '';
            fileName:= '';
            aux := '';
            auxLongInt := 0;
            mime_version := '';
            date := '';
            disposition_Notification_To := '';
            subject := '';
            from := '';
            to_ := '';
            cc := '';
            bcc := '';
            delivered_to := '';
            reply_to := '';
            tamanho := 0;
            references_ := '';
            in_reply_to_ := '';
            message_id := '';
        end;
end;

function inicializaPCarta: PCarta;
var carta: PCarta;
begin
    new (carta);
    zeraPCarta(carta);
    carta^.datahora := 0;
    carta^.partesCarta := Tlist.Create;
    inicializaPCarta := carta;
end;

{-------------------------------------------------------------}

function inicializaPParte: PParte;
var parte: PParte;
begin
    new (parte);
    with parte^ do
        begin
            filename := '';
            content_description := '';
            content_ID := '';

            subCarta := NIL;
        end;

    inicializaPParte := parte;
end;

{-------------------------------------------------------------}

function inicializaPEstrutura: PEstrutura;
var estrutura: PEstrutura;
begin
    new (estrutura);
    with estrutura^ do
        begin
        numero := '';
        linhaInicialCab := 0;
        linhaInicial := 0;
        linhaFinal := 0;
        selecionado := FALSE;
        posServ := 0;
        removido := FALSE;
        boundary := '';
        contemAnexos := false;
        charset := '';
        content_disposition := '';
        content_transfer_encoding := '';
        content_type := '';
        type_ := '';

        parte := NIL;
        carta := NIL;
        ptPai := NIL;
        end;

    inicializaPEstrutura := estrutura;
end;

{-------------------------------------------------------------}
{       Cria o TList das partes que será preenchido na montagem da
{       estrutura da carta na memória. Esta lista será usada no folheamento das partes.
{-------------------------------------------------------------}

procedure criaIndicePartes;
begin
    listaDePartes := Tlist.Create;
end;

{-------------------------------------------------------------}
{       Destroi o tlist com as partes da carta
{-------------------------------------------------------------}

procedure destroiIndicePartes ;
var i, totalPartes: integer;
begin
    totalPartes := listaDePartes.count;
    for i := (totalPartes - 1) downto 0 do
        listaDePartes.Delete(i);
end;

{-------------------------------------------------------------}
{       Remove uma parte da carta
{-------------------------------------------------------------}

procedure removeParteCarta (carta: PEstrutura; n: integer);
var
    parteARemover: PEstrutura;
begin
    parteARemover := carta^.carta^.partesCarta [n];
    dispose (parteARemover^.parte);
    dispose (parteARemover);
    carta^.carta^.partesCarta.Delete(n);
end;

{-------------------------------------------------------------}
{       Remove a estrutura da carta da memória
{-------------------------------------------------------------}

procedure desmontaTudo (aCarta: PEstrutura);
var
    i, totalPartes: integer;
    parte: PEstrutura;
begin
    totalPartes := aCarta^.carta^.partesCarta.count;
    for i := (totalPartes - 1) downto 0 do
        begin
            parte := aCarta^.carta^.partesCarta[i];
            if parte^.parte^.subCarta <> NIL then
                desmontaTudo (parte^.parte^.subCarta);
            removeParteCarta (aCarta, i);
        end;

    if not aCarta^.carta^.preenchido then //A carta principal vai ter sempre TRUE.
        begin
            aCarta^.carta^.partesCarta.free;
            dispose (aCarta^.carta);
            dispose (aCarta);
        end;
end;

{-------------------------------------------------------------}
{       Busca boundary até lFim, começando da linha inicial, retorna true ou false se achou e retorna o número da linha final, a linha de boundary
{-------------------------------------------------------------}

function buscaProximoBoundary (lIni, lFim: integer; boundary: string): integer;
var i: integer;
begin
    buscaProximoBoundary := 0;
    if lIni < lFim then
        for i := lIni to lFim do
            if (linhasArquivo[i] <> '') and (pos (boundary, linhasArquivo[i]) <> 0) then
                begin
                    buscaProximoBoundary := i;
                    break;
                end;
end;

{-------------------------------------------------------------}
{       retorna o número da linha onde se encontra a palavra no texto
{-------------------------------------------------------------}

function retorna_numero_linha (lIni, lFim: integer; busca: string): integer;
var i: integer;
begin
    retorna_numero_linha := lIni;
    if lIni < lFim then
        for i := lIni to lFim do
            if (linhasArquivo[i] <> '') and (maiuscansi(copy(linhasArquivo[i], 1, length(busca))) = maiuscansi(busca)) then
                begin
                    retorna_numero_linha := i;
                    break;
                end;
end;

{-------------------------------------------------------------}
{       Separa Content-Type, type, boundary ou name e charset da mesma linha
{-------------------------------------------------------------}

function pegaContent_Type (s: string; var type_, boundary, name, charset: string): string;
var content_type, s2: string;
begin
    content_type := trim (copy (s, 14, (pos(';', s)-14)));
    delete (s, 1, pos (';', s));
    s := trim(s);

    type_ := '';
    boundary := '';
    name := '';
    charset := '';
    s2 := s + 'a';
    while (s <> '') and (s <> s2) do
        begin
            s2 := s;

            if maiuscansi(copy(s,1,5)) = 'TYPE=' then
                begin
                    type_ := copy (s, 6, (pos(';', s)-6));
                    deletaAspas (type_);
                end
            else
            if maiuscansi(copy(s, 1, 5)) = 'NAME=' then
                begin
                    name := copy (s, 6, (pos(';', s)-6));
                    deletaAspas (name);
                    decodificarString (name);
                end
            else
            if maiuscansi(copy(s, 1, 6)) = 'NAME*=' then
                begin
                    name := copy (s, 7, (pos(';', s)-7));
                    deletaAspas (name);
                    decodificarString (name);
                end
            else
            if maiuscansi (copy(s, 1, 8)) = 'BOUNDARY' then
                begin
                    boundary := copy (s, pos('=', s)+1, (pos(';', s)- (pos ('=', s)+1)));
                    deletaAspas (boundary);
                    if (boundary[1] <> '-') and (pos ('-', boundary) <> 0) then
                        delete (boundary, 1, pos ('-', boundary)-1);
                end
            else
            if (maiuscansi(copy(s, 1, 7)) = 'CHARSET') then
                begin
                    charset := copy (s, pos('=', s) + 1, (pos(';', s)-(pos ('=', s) + 1)));
                    deletaAspas (charset);
                end;
            delete (s, 1, pos(';', s));
            s := trim(s);
        end;

    pegaContent_Type := content_type;
end;

{-------------------------------------------------------------}
{       Busca a linha no texto da carta na memória
{-------------------------------------------------------------}

function buscaLinhaNoTexto (lIni, lFim: integer; var proxima: integer): string;
var
    busca, aux: string;
    decodificar: boolean;
begin
    buscaLinhaNoTexto := '';
    decodificar := false;
    if (linhasArquivo.Count = 0) or (lIni >= linhasArquivo.count) then
        exit;

    busca := linhasArquivo[lIni];
    if trim (busca) <> '' then
        begin
            if (maiuscansi (copy (busca, 1, 3)) = 'TO:') or
               (maiuscansi (copy (busca, 1, 5)) = 'FROM:') or
               (maiuscansi (copy (busca, 1, 16)) = 'X-ORIGINAL-FROM:') or
               (maiuscansi (copy (busca, 1, 9)) = 'REPLY-TO:') or
               (maiuscansi (copy (busca, 1, 8)) = 'SUBJECT:') or
               (maiuscansi (copy (busca, 1, 28)) = 'DISPOSITION-NOTIFICATION-TO:') then
                decodificar := true;

            lIni := lIni + 1;
            if lIni >= linhasArquivo.count then
                exit;
            aux := linhasArquivo[lIni];
            while (aux <> '') and ((aux[1] = ' ') or (aux[1] = TAB)) and (lIni <= lFim) do
                begin
                    if aux[1] in [TAB, ' '] then aux := trim (aux); // Entrou o ' '

                    busca := busca + aux;
                    lIni := lIni + 1;
                    if lIni >= linhasArquivo.count then
                        exit;
                    aux := linhasArquivo[lIni];
                end;
        end
    else
        lIni := lIni + 1;

    proxima := lIni;
    if decodificar then
        decodificarString (busca);
    buscaLinhaNoTexto := busca;
end;

{-------------------------------------------------------------}
{       Preenche os campos  da carta a partir da analise do texto
{-------------------------------------------------------------}

procedure preenchePEstrutura (aCarta: PEstrutura);
var
    s, bccAux: string;
    lAux, lIni, lFim: integer;

    {       Remove os e-mails CC do BCC, tira duplicidade}
    procedure removeCCdoBCC;
    var
        bcc,ccTo, aux, email: string;
    begin
        if trim (aCarta^.carta^.bcc) = '' then exit;
        ccTo := '';
        if trim (aCarta^.carta^.to_) <> '' then
            ccTo := aCarta^.carta^.to_;
        if trim (aCarta^.carta^.cc) <> '' then
            ccTo := ccTo + ' ' + aCarta^.carta^.cc;
        if ccTo = '' then exit;

        bcc := '';
        aux := trim (aCarta^.carta^.bcc);
        while trim (aux) <> '' do
            begin
                email := copy (aux, 1, pos (',', aux)-1);
                if pos (email, ccTo) = 0 then
                    bcc := bcc + email + ',';
                delete (aux, 1, pos (',', aux));
            end;

        if trim (bcc) <> '' then
            delete (bcc, length (bcc), 1);
        aCarta^.carta^.bcc := bcc;
    end;

begin
    with aCarta^ do
        begin
            linhaInicial := linhaInicialCab;
            lIni := linhaInicial;
            lFim := linhaFinal;
            lAux := lIni;
        bccAux := '';
            s := buscaLinhaNoTexto (lAux, lFim, lAux);
            if (s <> '') and (s[length(s)] <> ';') then s := s + ';';
            while (s <> '') and (lAux < lFim) do
                begin
                    if maiuscansi(copy(s, 1, 13)) = 'DELIVERED-TO:' then
                        carta^.delivered_To := trim (copy (s, 14, length(s)-14))
                    else
                    if (carta^.from = '') and (maiuscansi(copy(s, 1, 5)) = 'FROM:') then
                        carta^.from := trim (copy (s, 6, length(s)-6))
                    else
                    if maiuscansi(copy(s, 1, 16)) = 'X-ORIGINAL-FROM:' then
                        carta^.from := trim (copy (s, 17, length(s)-17))
                    else
                    if maiuscansi(copy(s, 1, 3)) = 'TO:' then
                        carta^.to_ := trim (copy (s, 4, length(s)-4))
                    else
                    if maiuscansi(copy(s, 1, 8)) = 'SUBJECT:' then
                    begin
                        s := trim (copy (s, 9, length(s)-9));
                        carta^.subject := s;
                    end
                    else
                    if maiuscansi(copy(s, 1, 9)) = 'REPLY-TO:' then
                        carta^.reply_to := trim (copy (s, 10, length(s)-10))
                    else
                    if maiuscansi(copy(s, 1, 5)) = 'DATE:' then
                        carta^.date := trim (copy (s, 6, length(s)-6))
                    else
                    if maiuscansi(copy(s, 1, 13)) = 'MIME-VERSION:' then
                        carta^.mime_version := trim (copy (s, 14, length(s)-14))
                    else
                    if maiuscansi(copy(s, 1, 13)) = 'CONTENT-TYPE:' then
                        content_type := pegaContent_Type (s, type_, boundary, carta^.fileName, charset)
                    else
                    if maiuscansi(copy(s, 1, 20)) = 'CONTENT-DISPOSITION:' then
                        content_disposition := trim (copy (s, 21, length(s)-21))
                    else
                    if maiuscansi(copy(s, 1, 26)) = 'CONTENT-TRANSFER-ENCODING:' then
                        content_transfer_encoding := trim (copy (s, 27, length(s)-27))
                    else
                    if maiuscansi(copy(s, 1, 3)) = 'CC:' then
                        carta^.cc := trim (copy (s, 4, length(s)-4))
                    else
                    if maiuscansi(copy(s, 1, 8)) = 'RCPT TO:' then //BCC
                        bccAux := bccAux + trim(copy (s, 10, length(s)-11)) + ','
                    else
                    if maiuscansi(copy(s, 1, 11)) = 'MESSAGE-ID:' then
                        carta^.message_id := trim (copy (s, 12, length(s)-12))
                    else
                    if maiuscansi(copy(s, 1, 11)) = 'REFERENCES:' then
                        carta^.references_ := trim (copy (s, 12, length(s)-12))
                    else
                    if maiuscansi(copy(s, 1, 12)) = 'IN-REPLY-TO:' then
                        carta^.in_reply_to_ := trim (copy (s, 13, length(s)-13))
                    else
                    if maiuscansi(copy(s, 1, 28)) = 'DISPOSITION-NOTIFICATION-TO:' then
                        carta^.disposition_notification_to := trim (copy (s, 29, length(s)-29))
                    else
                    if (maiuscansi(copy(s, 1, 13)) = 'X-SOURCE-DIR:') then
                        lAux := retorna_numero_linha (lAux, lFim, 'X-Virus-Status: ')
                    else
                    if (maiuscansi(copy(s, 1, 13)) = 'X-HAM-REPORT:') or
                      (maiuscansi(copy(s, 1, 14)) = 'X-SPAM-REPORT:') then
                        lAux := retorna_numero_linha (lAux, lFim, 'X-Spam-Flag: ');

                    s := buscaLinhaNoTexto (lAux, lFim, lAux);
                    if (s <> '') and (s[length(s)] <> ';') then s := s + ';';
                end;

            carta^.bcc := bccAux;
            if boundary <> '' then
                begin
                    linhaInicial := buscaProximoBoundary (lAux, lFim , boundary) + 1;
                    if linhaInicial <= 1 then linhaInicial := lAux;
                    linhaFinal := buscaProximoBoundary (laux, lFim, boundary+'--') - 1;
                    if linhaFinal < 0 then linhaFinal := lFim;
                end
            else
                begin
                    linhaInicial := lAux;
                    linhaFinal := lFim;
                end;
        end;

    removeCCdoBCC;
end;

{-------------------------------------------------------------}
{       Preenche a carta principal
{-------------------------------------------------------------}

procedure preencheCartaPrincipal (aCarta: PEstrutura);
begin
    aCarta^.linhaFinal := linhasArquivo.count-1;
    preenchePEstrutura (aCarta);

    with aCarta^ do
        begin
            numero := '1';
            carta^.preenchido := TRUE;
        end;
end;

{-------------------------------------------------------------}
{       Carrega o arquivo, preenche a carta principal e descarrega o arquivo.
{-------------------------------------------------------------}

function carregaArqPreencheCabPrin (nCar: integer): boolean;
var
    s: string;
    arq: text;
begin
    carregaArqPreencheCabPrin := true;
    if regLido[ncar]^.carta^.preenchido then exit;
    assign (arq, regLido[ncar]^.carta^.nomArqCarta);
    {$i-} reset (arq); {$i+}
    if ioresult <> 0 then
        begin
            msgBaixo ('CTCARSUM');  {'Erro no disco: carta sumiu'}
            carregaArqPreencheCabPrin := false;
        end
    else
        begin
            linhasArquivo := TStringList.create;
            repeat
                {$i-} readln (arq, s); {$i+}
                if ioresult = 0 then
                    linhasArquivo.add (s);
                  if (maiuscansi(copy(s, 1, 13)) = 'X-HAM-REPORT:') or
                     (maiuscansi(copy(s, 1, 14)) = 'X-SPAM-REPORT:') then
                    repeat
                        {$i-} readln (arq, s); {$i+}
                        if ioresult = 0 then
                            linhasArquivo.add (s);
                    until (eof (arq)) or (maiuscansi(copy(s, 1, 16)) = 'X-VIRUS-STATUS: ') or
                      (maiuscansi(copy(s, 1, 13)) = 'X-SPAM-FLAG: ');

            until (eof (arq)) or (s = '');

            linhasArquivo.add (s);
            {$i-} close (arq); {$i+}
            if ioresult <> 0 then;
            preencheCartaPrincipal (regLido[ncar]);
            destroiLinhasArquivo;
            regLido[ncar]^.carta^.preenchido := false;
        end;
end;

{-------------------------------------------------------------}
{   Adiciona um registro de nova carta
{-------------------------------------------------------------}

procedure adicionaUmRegCarta(nomeArq: string; tamanho, data: longInt; totalRegistros, posServ: integer);
begin
    numRegs := totalRegistros;
    regLido [numRegs] := inicializaPEstrutura;
    regLido [numRegs]^.carta := inicializaPCarta;
    regLido [numRegs]^.carta^.nomArqCarta := nomeArq;
    regLido [numRegs]^.carta^.dataHora := data;
    regLido [numRegs]^.carta^.tamanho := tamanho;
    regLido [numRegs]^.posServ := posServ;
    regLido[numRegs]^.carta^.preenchido := false;
end;

{-------------------------------------------------------------}
{       Cria uma subcarta do tipo tEstrutura.
{-------------------------------------------------------------}

function criaSubCarta (lIni, lFim: integer; nomeArq: string): PEstrutura;
var carta: PEstrutura;
begin
    carta := inicializaPEstrutura;
    carta^.carta := inicializaPCarta;
    with carta^ do
        begin
            carta^.nomArqCarta := nomeArq;
            linhaInicialCab := lIni;
            linhaFinal := lFim;
        end;

    preenchePEstrutura (carta);
    criaSubCarta := carta;
end;

{-------------------------------------------------------------}
{       Cria uma parte da carta, retorna true se houver mais partes.
{-------------------------------------------------------------}

function criaParteCarta (aCarta: PEstrutura; lIni, lFim: integer): boolean;
var
    umaParte: PEstrutura;
    s: string;
    lAux: integer;
begin
    criaParteCarta := true; //Quando a carta tem mais partes.
    umaParte := inicializaPEstrutura;
    umaParte^.parte := inicializaPParte;
    with umaParte^ do
        begin
            linhaInicialCab := lIni;
            lAux := lIni;
            s := buscaLinhaNoTexto (lAux, lFim, lAux);
            if (s <> '') and (s[length(s)] <> ';') then s := s + ';';

            while (s <> '') and (lAux < lFim) do
                begin
                    if maiuscansi(copy(s, 1, 13)) = 'CONTENT-TYPE:' then
                        content_type := pegaContent_Type (s, type_, boundary, parte^.fileName, charset)
                    else
                    if maiuscansi(copy(s, 1, 20)) = 'CONTENT-DESCRIPTION:' then
                        parte^.Content_Description := trim (copy (s, 21, length(s)-21))
                    else
                    if maiuscansi(copy(s, 1, 11)) = 'CONTENT-ID:' then
                        parte^.Content_ID := trim (copy (s, 12, length(s)-12))
                    else
                    if maiuscansi(copy(s, 1, 26)) = 'CONTENT-TRANSFER-ENCODING:' then
                        content_transfer_encoding := trim (copy (s, 27, length(s)-27))
                    else
                    if maiuscansi(copy(s, 1, 20)) = 'CONTENT-DISPOSITION:' then
                        begin
                            content_disposition := trim (copy (s, 21, pos(';',s)-21));
                            delete (s, 1, pos (';', s));
                            s := trim(s);
                            if (s <> '') and (((parte^.filename = '') or
                              (pos('.', parte^.filename) = 0)) and
                              (maiuscansi(copy(s, 1, 9)) = 'FILENAME=')) then
                                begin
                                    parte^.filename := copy (s, 10, length(s)-10);
                                    deletaAspas (parte^.filename);
                                    decodificarString (parte^.filename);
                                end
                            else
                            if (s <> '') and (((parte^.filename = '') or
                              (pos('.', parte^.filename) = 0)) and
                              (maiuscansi(copy(s, 1, 10)) = 'FILENAME*=')) then
                                begin
                                    parte^.filename := copy (s, 11, length(s)-11);
                                    deletaAspas (parte^.filename);
                                    decodificarString (parte^.filename);
                                end
                        end;

                    s := buscaLinhaNoTexto (lAux, lFim, lAux);
                    if (s <> '') and (s[length(s)] <> ';') then s := s + ';';
                end;

            linhaInicial := lAux;
        end;

    if aCarta^.carta^.preenchido then //Carta principal é sempre TRUE.
        umaParte^.numero := intToStr (aCarta^.carta^.partescarta.count+1)
    else
        umaParte^.numero := aCarta^.numero + '.' + intToStr (aCarta^.carta^.partescarta.count+1);

    umaParte^.linhaFinal := buscaProximoBoundary (lAux, lFim , aCarta^.boundary) -1;
    if umaParte^.linhaFinal > 0 then
        begin
            if linhasArquivo[umaParte^.linhaFinal+1] = aCarta^.boundary + '--' then
                criaParteCarta := false; //Quando não Tem mais partes essa carta.
        end
    else
        begin
            umaParte^.linhaFinal := lFim;
            criaParteCarta := false; //Quando não Tem mais partes essa carta.
        end;

    umaParte^.ptPai := aCarta;
    aCarta^.Carta^.partesCarta.Add(umaParte);
end;

{-------------------------------------------------------------}
{       Copia os campos da parte para a subCarta
{-------------------------------------------------------------}

procedure copiaParteParasubCarta (parte, subCarta: PEstrutura);
begin
    if trim (subCarta^.charset) = '' then
        subCarta^.charset := parte^.charset;
if trim (subCarta^.content_disposition) = '' then
        subCarta^.content_disposition := parte^.content_disposition;
if trim (subCarta^.content_transfer_encoding) = '' then
        subCarta^.content_transfer_encoding := parte^.content_transfer_encoding;
end;

{-------------------------------------------------------------}
{       Monta as partes de uma carta ou subcarta
{-------------------------------------------------------------}

function montaPartesDaCarta (aCarta: PEstrutura): boolean;
var
    parte: PEstrutura;
    lIni, lFim: integer;
    i: integer;
begin
    if aCarta^.boundary = '' then
        begin
            montaPartesDaCarta := false;
            exit;
        end;

    montaPartesDaCarta := true;

    lIni :=aCarta^.linhaInicial;
    lFim := aCarta^.linhaFinal;
    i := 0;
    while criaParteCarta (aCarta, lIni, lFim) do
        begin
            parte := aCarta^.carta^.partesCarta[i];

            lIni :=parte^.linhaFinal + 2;
            if lIni >= aCarta^.linhaFinal then exit;
            i := i + 1;
        end;

end;

{-------------------------------------------------------------}
{       Monta toda a estrutura da carta, alocando todas as partes, subcartas e suas partes
{-------------------------------------------------------------}

procedure montaTudo (aCarta: PEstrutura);
var
    aParte: PEstrutura;
    i, totalPartes, lIniCab: integer;
    tipo, extensao: string;
begin
    if montaPartesDaCarta (aCarta) then
        begin
            totalPartes := aCarta^.carta^.partescarta.count;
            for i := 0 to (totalPartes - 1) do
                begin
                    aParte := aCarta^.carta^.partescarta[i];
                    extensao := maiuscAnsi (aParte^.parte^.filename);
                    extensao := copy ( extensao, length (extensao)-3, 4);
                    tipo := maiuscAnsi (aParte^.content_type);
                    if tipo = '' then tipo := 'a';
                    if (aParte^.boundary <> '') or
                       (pos ('RFC822',  tipo) <> 0) or
                       (extensao = '.EML') then
                        begin
                            if (aParte^.boundary <> '') and
                              (pos('MULTIPART/', maiuscansi(aParte^.content_type)) <> 0) then
                                lIniCab := aParte^.linhaInicialCab
                            else
                                lIniCab := aParte^.linhaInicial;
                                while (lIniCab < linhasArquivo.count) and (trim (linhasArquivo[lIniCab]) = '') do
                                    lIniCab := lIniCab + 1;

                            aParte^.parte^.subCarta := criaSubCarta (lIniCab, aParte^.linhaFinal, '');
                            aParte^.parte^.subCarta^.numero := aParte^.numero;
                            aParte^.parte^.subCarta^.ptPai := aParte;

                            if (aParte^.boundary <> '') and
                               (aParte^.parte^.subCarta^.boundary = '') then
                                aParte^.parte^.subCarta^.boundary := aParte^.boundary;

                            if (aParte^.parte^.subCarta^.linhaInicialCab + 1) = aParte^.parte^.subCarta^.linhaInicial then
                                copiaParteParasubCarta (aParte, aParte^.parte^.subCarta);
                            montaTudo (aParte^.parte^.subCarta);
                        end
                    else
                        listaDePartes.Add(aParte);
                end;
        end
    else
        listaDePartes.Add(aCarta);

end;

{-------------------------------------------------------------}
begin
end.
