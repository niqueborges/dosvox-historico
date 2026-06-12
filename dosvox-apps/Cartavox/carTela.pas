{-----------------------------------------------------------------------
{
{           Cartavox - Tratamento das telas
{
{----------------------------------------------------------------------}

unit carTela;

interface

uses
    classes,
    dvcrt,
    dvForm,
    dvwin,
    sysUtils,
    windows,
    carEst,
    carMsg,
    carUtil,
    carvars;

function centralizaFrase (frase: string): string;
procedure telaPrincipal;
procedure telaFolheiaApelidos (numApelidos: integer);
procedure telaFolheiaRegras (numRegras : integer);
procedure telaFolheiaPastas (numPastas : integer);
procedure telaFolheiaCarbono (numCarbonos: integer);
procedure telaFolheamentoCartas;
procedure telaFolheamentoPartes (ncar, totalPartes: integer);

procedure mostraItensCarta (carta: PEstrutura);
procedure mostraItensParte (parte: PEstrutura);

implementation

const
    TITULOFOLHEIA =
    'Apelido         = Nome                 < E-Mail                                >';
    TITULOFOLHEIACARBONO =
    '   Lista de endereços de copias carbono';
    TITULOFOLHEIAREGRAS =
    '   Lista de Regras';
    TITULOFOLHEIAPASTAS =
    '   Lista de Pastas de Regras';

{-------------------------------------------------------------}
{       Retorna uma string centralizada
{-------------------------------------------------------------}

function centralizaFrase (frase: string): string;
var t, i: integer;
begin
    frase := trim (frase);
    t := length (frase);
    if t < 80 then
        begin
            t := (80 - t) div 2;
            for i := 1 to t do frase := ' ' + frase;
            while length (frase) < 80 do frase := frase + ' ';
        end;

    centralizaFrase := frase;
end;

{-------------------------------------------------------------}
{       Cabeçalho da tela principal
{-------------------------------------------------------------}

procedure telaPrincipal;
begin
    clrscr;
    textBACKGROUND (BLUE);
    textColor (WHITE);
    write (pegaTextoMensagem ('CTINIC'));  {'CARTAVOX - Correio Eletrônico - NCE/UFRJ - v.'}
    write (VERSAO);
    textBackground (BLACK);
    writeln; writeln;
end;

{-------------------------------------------------------------}
{       Tela de folheamento de apelidos
{-------------------------------------------------------------}

procedure telaFolheiaApelidos (numApelidos: integer);
var s: string;
begin
    clrscr;
    textBackGround (MAGENTA);
    s := pegaTextoMensagem ('CTFOLAPE'); {'Folheamento dos apelidos'}
    s := s + ' - ' + intToStr(numApelidos) + ' ';
    s := s + pegaTextoMensagem('CTAPELSO'); {' Apelidos'}
    write (centralizaFrase (s));
    textBackground (BLACK);
    writeln;
    writeln;
    textColor (Cyan);
    write (TITULOFOLHEIA);
    textColor (LightGray);
    writeln;
    gotoxy (1,5); clreol;
end;


{-------------------------------------------------------------}
{       Tela de folheamento de regras
{-------------------------------------------------------------}

procedure telaFolheiaRegras (numRegras: integer);
var s: string;
begin
    clrscr;
    textBackGround (MAGENTA);
    s := pegaTextoMensagem ('CTFOLREG'); {'Folheamento das regras'}
    s := s + ' - ' + intToStr(numRegras) + ' ';
    s := s + pegaTextoMensagem('CTREGINI'); {' Regras'}
    write (centralizaFrase (s));
    textBackground (BLACK);
    writeln;
    writeln;
    textColor (Cyan);
    write (TITULOFOLHEIAREGRAS);
    textColor (LightGray);
    writeln;
    gotoxy (1,5); clreol;
end;

{-------------------------------------------------------------}
{       Tela de folheamento de pastas
{-------------------------------------------------------------}

procedure telaFolheiaPastas (numPastas: integer);
var s: string;
begin
    clrscr;
    textBackGround (MAGENTA);
    s := pegaTextoMensagem ('CTFOLPAS'); {'Folheamento das pastas de regras'}
    s := s + ' - ' + intToStr(numPastas) + ' ';
    s := s + pegaTextoMensagem('CTPASTAS'); {' Regras'}
    write (centralizaFrase (s));
    textBackground (BLACK);
    writeln;
    writeln;
    textColor (Cyan);
    write (TITULOFOLHEIAPASTAS);
    textColor (LightGray);
    writeln;
    gotoxy (1,5); clreol;
end;

{-------------------------------------------------------------}
{       Tela de folheamento de copias carbono
{-------------------------------------------------------------}

procedure telaFolheiaCarbono (numCarbonos: integer);
var s: string;
begin
    clrscr;
    textBackGround (MAGENTA);
    s := pegaTextoMensagem ('CTFOLCAR'); {'Folheamento dos carbonos'}
    s := s + ' - ' + intToStr(numCarbonos) + ' ';
    s := s + pegaTextoMensagem('CTCOPCAR'); {'  Copias carbono'}
    write (centralizaFrase (s));
    textBackground (BLACK);
    writeln;
    writeln;
    textColor (Cyan);
    write (TITULOFOLHEIACARBONO);
    textColor (LightGray);
    writeln;
    gotoxy (1,5); clreol;
end;

{----------------------------------------------------------------------}
{       Cabeçalho da tela do folheamento das cartas
{       Tipos de folheamento:
{           F - Todas recebidas
{           L - todas recebidas  lidas
{           N - Todas recebidas não lidas
{           T - Todas transmitidas
{           P - Todas preparadas para transmitir
{----------------------------------------------------------------------}

procedure telaFolheamentoCartas;
var s: string;
begin
    clrscr;
    textBackGround (MAGENTA);
    case tipoFolheGlobal of
        'F', ^F: s := pegaTextoMensagem ('CTFORETO'); {'Folheamento de cartas recebidas'}
        'L', ^L: s := pegaTextoMensagem ('CTFORELI'); {'Folheamento de cartas recebidas lidas'}
        'N', ^N: s := pegaTextoMensagem ('CTFORENA'); {'Folheamento de cartas recebidas não lidas'}
        'T', ^T: s := pegaTextoMensagem ('CTFOCATA'); {'Folheamento de cartas transmitidas'}
        'P', ^P: s := pegaTextoMensagem ('CTFOCAPR'); {'Folheamento de cartas preparadas para transmissão'}
    end;

    s := s + ' - ' + intToStr(numRegs) + ' ';
    if numRegs > 1 then
         s := s  + pegaTextoMensagem('CTCARTAS') {'Cartas'}
    else
                  s := s  + pegaTextoMensagem('CTCARTA'); {'Carta'}
    write (centralizaFrase (s));
    textBackground (BLACK);
    writeln (centralizaFrase(pegaTextoMensagem ('CTUSESET')));  {'Folheando: use as setas, depois tecle sua opção'}
end;

{----------------------------------------------------------------------}
{       Cabeçalho da tela do folheamento das partes
{----------------------------------------------------------------------}

procedure telaFolheamentoPartes (ncar, totalPartes: integer);
begin
    telaFolheamentoCartas;
    writeln (regLido[ncar]^.carta^.from);
    writeln (regLido[ncar]^.carta^.Subject);

    textBackGround (MAGENTA);
    write (centralizaFrase(pegaTextoMensagem('CTFOPACA'))); {'Folheamento das partes da carta'}
    textBackground (BLACK);
    writeln; writeln;
    write (pegaTextoMensagem ('CTNARQM')); {'Número de partes inclusas: '}
    writeln (intToStr (totalPartes));
    writeln;
    textBackGround (MAGENTA);
    write (centralizaFrase(pegaTextoMensagem ('CTQPARTE'))); {'Qual a parte desejada? (use as setas, f1 ajuda)'}
    textBackground (BLACK);
    writeln;
end;

{---------------------------------}
{       Mostra os campos preenchidos da estrutura da carta
{---------------------------------}

procedure mostraItensCarta (carta: PEstrutura);
var
    nItem: integer;
    item: string;
    c, c2: char;
    selecionado: boolean;
begin
    telaPrincipal;
    textBackGround (MAGENTA);
    mensagem ('CTITFOCA', 1); {'Folheie os itens do cabeçalho desta parte com as setas, tecle ESC para sair'}
    textBackground (BLACK);
    writeln;
    garanteEspacoTela (17);
    folheiaCria (wherex, wherey, 79, 23);
    with carta^ do
        begin
//            folheiaAdiciona ('Número carta             :' + numero);
//            folheiaAdiciona ('Linha inicial cabeçalho  :' + intToStr(linhaInicialCab + 1));
//            folheiaAdiciona ('Linha inicial            :' + intToStr(linhaInicial + 1));
//            folheiaAdiciona ('Linha final              :' + intToStr(linhaFinal + 1));
            if posServ <> 0 then
                folheiaAdiciona ('Posição no servidor:' + intToStr(posServ));
            if trim (carta^.subject) <> '' then
                folheiaAdiciona ('Subject                    :' + carta^.subject);
            if trim (carta^.from) <> '' then
                folheiaAdiciona ('From                       :' + carta^.from);
            if trim (carta^.to_) <> '' then
                folheiaAdiciona ('To                         :' + carta^.to_);
            if trim (carta^.disposition_Notification_To) <> '' then
                folheiaAdiciona ('Disposition-Notification-To:' + carta^.disposition_Notification_To);
            if trim (carta^.cc) <> '' then
                folheiaAdiciona ('Cc                         :' + carta^.cc);
              if trim (carta^.bcc) <> '' then
                folheiaAdiciona ('BCc                        :' + carta^.bcc);
            if trim (carta^.date) <> '' then
                folheiaAdiciona ('Date                       :' + converteData (carta^.date, true));
            if trim (content_type) <> '' then
                folheiaAdiciona ('Content type               :' + content_type);
            if trim (type_) <> '' then
                folheiaAdiciona ('Type                       :' + type_);
            if trim (carta^.fileName) <> '' then
                folheiaAdiciona ('File name                  :' + carta^.fileName);
            if trim (charset) <> '' then
                folheiaAdiciona ('Charset                    :' + charset);
            if trim (content_transfer_encoding) <> '' then
                folheiaAdiciona ('Content transfer encoding  :'+ content_transfer_encoding);
            if trim (content_disposition) <> '' then
                folheiaAdiciona ('Content Disposition        :' + content_disposition);
            if trim (carta^.mime_version) <> '' then
                folheiaAdiciona ('Mime version               :' + carta^.mime_version);
            if trim (carta^.delivered_to) <> '' then
                folheiaAdiciona ('Delivered to               :' + carta^.delivered_to);
            if trim (carta^.reply_to) <> '' then
                folheiaAdiciona ('Reply to                   :' + carta^.reply_to);
            if trim (carta^.nomArqCarta) <> '' then
                folheiaAdiciona ('Arquivo Carta              :' + carta^.nomArqCarta);
            if carta^.tamanho > 0 then
                folheiaAdiciona ('Tamanho                    :' + intToStr(carta^.tamanho));
            if carta^.datahora > 0 then
                folheiaAdiciona ('Data do arquivo            :' + dateToStr (fileDateToDateTime (carta^.datahora)) + ' ' + timeToStr(FileDateToDateTime(carta^.datahora)));
            if trim (carta^.references_) <> '' then
                folheiaAdiciona ('References                 :' + carta^.references_);
            if trim (carta^.in_reply_to_) <> '' then
                folheiaAdiciona ('In-Reply-To                :' + carta^.in_reply_to_);
            if trim (carta^.message_iD) <> '' then
                folheiaAdiciona ('Message-ID                 :' + carta^.message_id);
            if trim (boundary) <> '' then
                folheiaAdiciona ('Boundary                   :' + boundary);
        end;

    nItem := 1;
    repeat
        folheiaExecuta (nItem, nItem, c, c2, true);
        folheiaObtemItem (nItem, item, selecionado);
        item := trim (copy (item, pos(':', item)+1, length (item)));

        if upcase (c) = ^C then
            begin
                putClipBoard(@item[1]);
                sintclek; sintclek;
            end
        else
        if upcase (c) <> ESC then
            c := sintEditaCampo (item, 1, 25, 255, 80, true);
    until upcase(c) = ESC;
    folheiaDestroi;
end;

{---------------------------------}
{       Mostra os campos preenchidos da estrutura da parte da carta
{---------------------------------}

procedure mostraItensParte (parte: PEstrutura);
var
    nItem: integer;
    item: string;
    c, c2: char;
    selecionado: boolean;
begin
    nItem := 1;
        mensagem ('CTITFOCA', -1); {'Folheie os itens do cabeçalho desta parte com as setas, tecle ESC para sair'}
    repeat
        telaPrincipal;
        textBackGround (MAGENTA);
        write (pegaTextoMensagem('CTITFOCA')); {'Folheie os itens do cabeçalho desta parte com as setas, tecle ESC para sair'}
        textBackground (BLACK);
        writeln; writeln;
        garanteEspacoTela (14);
        folheiaCria (wherex, wherey, 79, 13);
        with parte^ do
            begin
                folheiaAdiciona ('Número Parte             :' + numero);
                if trim (parte^.filename) <> '' then
                    folheiaAdiciona ('Filename                 :' + parte^.fileName)
                else
                    folheiaAdiciona ('Filename                 :Não definido');
                if trim (content_type) <> '' then
                    folheiaAdiciona ('Content type             :' + content_type);
//                folheiaAdiciona ('Linha inicial cabeçalho  :' + intToStr(linhaInicialCab + 1));
//                folheiaAdiciona ('Linha inicial            :' + intToStr(linhaInicial + 1));
//                folheiaAdiciona ('Linha final              :' + intToStr(linhaFinal + 1));
                if trim (type_) <> '' then
                    folheiaAdiciona ('Type                     :' + type_);
                if trim (content_transfer_encoding) <> '' then
                    folheiaAdiciona ('Content transfer encoding:'+ content_transfer_encoding);
                if trim (charset) <> '' then
                    folheiaAdiciona ('Charset                  :' + charset);
                if trim (parte^.content_description) <> '' then
                    folheiaAdiciona ('Content-description      :' + parte^.content_description);
                if trim (content_disposition) <> '' then
                    folheiaAdiciona ('Content-disposition      :' + content_disposition);
                if trim (parte^.content_id) <> '' then
                    folheiaAdiciona ('Content-Id               :' + parte^.content_id);
                if trim (boundary) <> '' then
                    folheiaAdiciona ('Boundary                 :' + boundary);
            end;

        folheiaExecuta (nItem, nItem, c, c2, true);
        folheiaObtemItem (nItem, item, selecionado);
        item := copy (item, pos(':', item)+1, length (item));

        if upcase (c) = ^C then
            begin
                putClipBoard(@item[1]);
                sintclek; sintclek;
            end
        else
        if upcase (c) <> ESC then
            begin
                c := sintEditaCampo (item, 1, 25, 255, 80, true);
                if nItem = 2 then
                    parte^.parte^.fileName := item;
            end;
    until upcase(c) = ESC;
    folheiaDestroi;
end;

{----------------------------------------------------------------------}
begin
end.
