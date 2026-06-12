{-------------------------------------------------------------}
{
{           cartaVox - leitor Mime
{
{-------------------------------------------------------------}

unit carLeit;

interface

uses
    dvcrt,
    dvWin,
    dvHora,
    dvform,
    sysutils,
    windows,
    carArq,
    carCopia,
    carEst,
    carDecod,
    carMsg,
    carTela,
    carUtil,
    carVars,
    carSMTP,
    carAjuda,
    uuenc,
    dvexec;

function gravaParteDecodificada (parte: PEstrutura; nomeArq: string): string;
procedure editaArquivo (nomeArq: string);
procedure leCarta (ncar: integer; lerSempre, lerPrimeiraParte, listarPartesCarta: boolean);
function gravarTodosAnexos (nCar: integer): integer;
function primeiraParteTxtOuHtml (nCar: integer): boolean;

var executarForaDosvoxGlobal: boolean = false;

implementation

var
    tipoGravacaoSimplificada: boolean;
    totalPartesFolhe: integer;
    gravacaoForcada: boolean;

{-------------------------------------------------------------}
{       Grava o arquivo da carta sem os anexos apagados.
{-------------------------------------------------------------}

procedure  checaPaiSemFilhos (umPai: PEstrutura);
var
    tenhoFilhos: boolean;
    i: integer;
    parte: PEstrutura;
begin
    tenhoFilhos := false;
    if umPai^.carta <> NIL then
        for i := 0 to (umPai^.carta^.partescarta.count-1) do
            begin
                parte := umPai^.carta^.partescarta[i];
                if not parte^.removido then
                    begin
                        tenhoFilhos := true;
                        break
                    end;
            end;

    if not tenhoFilhos then
        begin
            umPai^.removido := true;
            if umPai^.ptPai <> NIL then
                checaPaiSemFilhos (umpai^.ptPai);
        end;
end;

    {---------------------------------------------------------}

procedure selecionarRemovidos;
var
    i: integer;
    parte: PEstrutura;
begin
    for i := 0 to (listaDePartes.count-1) do
        begin
            parte := listaDePartes[i];
            if parte^.removido then
                checaPaiSemFilhos (parte^.ptPai);
        end;
end;

    {---------------------------------------------------------}

function gravarAlteracoesNoArquivo (nomeArq: string; nCar: integer): boolean;
var
    i: integer;
    parte: PEstrutura;
    arq: text;
    houveErro: boolean;
    boundary: string;

    {---------------------------------------------------------}
    procedure escreveNoArquivo (lIni, lFim: integer);
    var
        s: string;
    begin
        while (not houveErro) and (lIni <= lFim) and
             (lIni >= 0) and (lIni < linhasArquivo.count) do   // programação defensiva
            begin
                s := linhasArquivo[LIni];
                {$I-} writeln (arq, s); {$I+}
                if ioresult <> 0 then
                    begin
                        msgBaixo ('CTERRDSK');   {'Erro de escrita no disco'}
                        houveErro := true;
                    end;
                lIni := lIni + 1;
            end;
    end;

    {---------------------------------------------------------}
    procedure gravarOriginal (aCarta: PEstrutura);
    var
        i: integer;
        umaParte: PEstrutura;
    begin
        if aCarta^.removido then exit;
        if aCarta^.boundary <> '' then
            escreveNoArquivo (aCarta^.linhaInicialCab, aCarta^.linhaInicial - 2)
        else
            escreveNoArquivo (aCarta^.linhaInicialCab, aCarta^.linhaInicial - 1);

        for i := 0 to (aCarta^.carta^.partescarta.count - 1) do
            begin
                umaParte := aCarta^.carta^.partescarta[i];
                if umaParte^.removido then continue;
                escreveNoArquivo (umaParte^.linhaInicialCab-1, umaParte^.linhaInicial-1);
                if umaParte^.parte^.subCarta <> NIL then
                    begin
                        gravarOriginal (umaParte^.parte^.subCarta);
                    end
                else
                    escreveNoArquivo (umaParte^.linhaInicial, umaParte^.linhaFinal);
            end;

        if aCarta^.boundary <> '' then
            escreveNoArquivo (aCarta^.linhaFinal+1, aCarta^.linhaFinal+1);
    end;

begin
    gravarAlteracoesNoArquivo := false;
    assign (arq, nomeArq);
    {$I-}  rewrite (arq);   {$I+}
    if ioresult <> 0 then
        begin
            msgBaixo ('CTERRDSK'); {'Erro de escrita no disco'}
            exit;
        end;

    houveErro := false;
    if tipoGravacaoSimplificada then
        begin
            boundary := regLido[ncar]^.boundary;
            escreveNoArquivo (0, regLido [nCar]^.linhaInicial - 2);
            for i := 0 to (listaDePartes.count - 1) do
                begin
                    parte := listaDePartes[i];
                    if not parte^.removido then
                        begin
                            {$I-} writeln (arq, '--'+boundary); {$I+}
                            if ioresult <> 0 then
                                begin
                                    msgBaixo ('CTERRDSK');   {'Erro de escrita no disco'}
                                    houveErro := true;
                                    break;
                                end;
                            escreveNoArquivo (parte^.linhaInicialCab, parte^.linhaFinal);
                        end;
                end;

            {$I-} writeln (arq, '--'+ boundary + '--'); {$I+}
            if ioresult <> 0 then;
        end
    else
        begin
            selecionarRemovidos;
            gravarOriginal (regLido[nCar]);
        end;

    if tipoFolheGlobal in ['P', 'T', ^P, ^T] then
        begin
            {$I-} writeln (arq, '.'); {$I+}
            if ioresult <> 0 then;
        end;
    {$I-} close (arq); {$I+}
    if (ioresult = 0) and (not houveErro) then
        begin
            msgBaixo ('CTARQGRA'); {'Arquivo gravado'}
            gravarAlteracoesNoArquivo := true;
        end;
end;

{-------------------------------------------------------------}
{       Regrava o arquivo sem as partes apagadas
{-------------------------------------------------------------}

procedure gravarAlteracoes (nCar: integer);
var
    c: char;
    nomeArq: string;

label outroNomeArq, desistiu;
begin
    if not gravacaoForcada then
       if (totalPartesFolhe = listaDePartes.count) or
          (totalPartesFolhe < 1) then exit;

    repeat
        limpaParteTela (20, 25);
        textBackground (RED);
        mensagem ('CTGRAALT', 0); {'Deseja gravar as alterações na carta?'}
        c := upcase(popupMenuPorLetra ('SN'));
        textBackground (BLACK);
        writeln;
    until c in ['S', 'N', ENTER, ESC];
    if c in ['N', ESC] then goto desistiu;

    tipoGravacaoSimplificada := true;

outroNomeArq:
    limpaParteTela (24, 25);
    textBackground (RED);
    mensagem ('CTEDENSO', 0); {'Edite o nome do arquivo ou tecle ENTER para sobrescrever'}
    textBackground (BLACK);
    writeln;
    nomeArq := regLido [nCar]^.carta^.nomArqCarta;
    sintetiza (nomeArq);
    c := sintEditaCampo (nomeArq, 1, wherey, 255, 80, true);
    if (c = ESC) or (trim (nomeArq) = '') or
       (pos ('.', nomeArq) = 0) then
        msgBaixo ('CTDESIST') {'Desistiu'}
    else
    if (trim (nomeArq) <> trim (regLido [nCar]^.carta^.nomArqCarta)) and
       existeArq (nomeArq) then
        begin
            repeat
                limpaParteTela (24, 25);
                textBackground (RED);
                mensagem ('CTJAEXI1', 0); {'O arquivo destino'}
                writeln (' ');
                delay (100);
                sintWrite (nomeArq);
                delay (100);
                mensagem ('CTJAEXI2', 0); {'já existe.  Sobrescreve (S/N/ESC)? '}
                c := popupMenuPorLetra ('SN' + ESC);
                write (c);
                textBackground (BLACK);
                writeln;
            until c in ['S', 'N', ENTER, ESC];

            if c = 'N' then
                goTo outroNomeArq
            else
            if c = ESC then
                goto desistiu
            else
                gravarAlteracoesNoArquivo (nomeArq, nCar);
        end
    else
        gravarAlteracoesNoArquivo (nomeArq, nCar);
    regLido[nCar]^.carta^.tamanho := pegaTamanhoArq(regLido [nCar]^.carta^.nomArqCarta);

    exit;
desistiu:
    msgBaixo ('CTDESIST') {'Desistiu'}
end;

{-------------------------------------------------------------}
{       Edita o arquivo
{-------------------------------------------------------------}

procedure editaArquivo (nomeArq: string);
var
    nomeProg, nomeDir: string;
begin
    while sintFalando do waitMessage;
    nomeProg := sintAmbiente ('CARTAVOX', 'EDITOR');

    if tipoFolheGlobal in ['P', 'T', ^P, ^T] then
        nomeDir := dirEnvia
    else
        nomeDir := dirRecebe;

    nomeArq := trim (nomeArq);
    if pos (' ', nomeArq) <> 0 then
        if nomeArq [1] <> '"' then
            nomeArq := '"' + nomeArq + '"';
    if executaProg (nomeProg, nomeDir, nomeArq) >= 32 then
        esperaProgVoltar;
    while sintFalando do waitMessage;
end;

{-------------------------------------------------------------}
{       Fala o tipo da parte
{-------------------------------------------------------------}

procedure falaTipoDaParte (nParte: integer);
var
    s: string;
begin
    s := typeOuContent_Type (listaDePartes[nParte]);
    if trim (s) = '' then s := pegaTextoMensagem ('CTNAODEF'); {'Não definido'}
    sintetiza (s);
    delay (200);
end;

{-------------------------------------------------------------}
{       Retorna o nome do arquivo da parte.
{-------------------------------------------------------------}

function pegaNomeDoArquivoDaParte (parte: PEstrutura): string;
begin
    if parte^.carta <> NIL then
        result := subsCaracInvalidos (parte^.carta^.fileName)
    else
        result := subsCaracInvalidos(parte^.parte^.filename);
end;

procedure falaNomeDoArquivoDaParte (nParte: integer);
var
    parte: PEstrutura;
    arq: string;
begin
    parte := listaDePartes[nParte];
    if parte^.carta <> NIL then
        arq := parte^.carta^.nomArqCarta
    else
        arq := parte^.parte^.filename;
    if trim (arq) = '' then
        arq := pegaTextoMensagem ('CTNAODEF'); {'Não definido'}

    sintetiza (arq);
    delay (200);
end;

{-------------------------------------------------------------}
{       Apaga uma parte ou as selecionadas
{-------------------------------------------------------------}

procedure apagaParte (nFolhe: integer);
var
    c: char;
    i: integer;
    item: string;
    selecionado: boolean;
    parte: PEstrutura;

    procedure apagaUmaParte (i: integer);
    begin
        folheiaObtemItem (i, item, selecionado);
        repeat
            msgBaixo ('CTDEAPPA'); {'Deseja apagar essa parte? '}
            sintetiza (copy (item, 6, 999));
            c := popupMenuPorLetra ('SN');
        until c in ['S', 'N', ENTER, ESC];

        if c in ['N', ESC] then
            msgBaixo ('CTDESIST') {'Desistiu'}
        else
            begin
                folheiaRemoveItem (i);
                totalPartesFolhe := folheiaNumItens;
                Parte := listaDePartes[strToInt(trim(copy(item, 1, 5)))-1];
                parte^.removido := TRUE;
                msgBaixo ('CTPARAPA'); {'Parte apagada'}
            end;
    end;

begin
    if temItemSelecionado then
        begin
            repeat
                msgBaixo ('CTDEAPSE'); {'Deseja apagar as partes selecionadas?'}
                c := popupMenuPorLetra ('SN');
            until c in ['S', 'N', ENTER, ESC];

            if c = ESC then
                    msgBaixo ('CTDESIST') {'Desistiu'}
            else
            if c = 'N' then
                apagaUmaParte (nFolhe)
            else
                begin
                    i := folheiaNumItens;
                    while i >= 0 do
                        begin
                            folheiaObtemItem (i, item, selecionado);
                            if selecionado then
                                begin
                                    folheiaRemoveItem (i);
                                    totalPartesFolhe := folheiaNumItens;
                                    Parte := listaDePartes[strToInt(trim(copy(item, 1, 5)))-1];
                                    parte^.removido := TRUE;
                                end;

                            i := i - 1;
                        end;
                    msgBaixo ('CTPASAPS'); {'Partes apagadas'}
                end;
        end
    else
        apagaUmaParte (nFolhe)
end;

{-------------------------------------------------------------}
{       Grava a parte no arquivo temporário já decodificado
{-------------------------------------------------------------}

function gravaParteDecodificada (parte: PEstrutura; nomeArq: string): string;
var
    arqTemp: text;
    tempPath, tempFileName: array [0..144] of char;
    houveErro, usaTempFilename, juntarLinha: boolean;
    s: string;
    tipoCodif, tipoCharset: char;
    i: integer;
begin
    gravaParteDecodificada := '';
    if nomeArq = '' then
        begin
            usaTempFileName := TRUE;
            getTempPath (144, tempPath);
            GetTempFileName(tempPath, 'CAR', 0, TempFileName);
            nomeArq := strPas(TempFileName);
        end
    else
        usaTempFileName := false;

    assign (arqTemp, nomeArq);
    {$I-}  rewrite (arqTemp);   {$I+}
    if ioresult <> 0 then
        begin
            msgBaixo ('CTERRTMP');  {'Problemas no arquivo temporário'}
            exit;
        end;

    s := trim (maiuscAnsi (parte^.content_transfer_encoding));

    if s = 'QUOTED-PRINTABLE' then        tipoCodif := 'Q'
    else if s = 'X-UUENCODE' then         tipoCodif := 'X'
    else if s = 'BASE64' then             tipoCodif := 'B'
    else tipoCodif := 'N';

    s := trim (maiuscAnsi (parte^.charset));
    if copy (s, 1, 3) = 'UTF' then tipoCharset := 'U'
    else if copy (s, 1, 3) = 'ISO' then tipoCharset := 'I'
    else tipoCharset := 'N';

    houveErro := false;
    i := parte^.linhaInicial;
    while (not houveErro) and (i <= parte^.linhaFinal) do
        begin
            s := linhasArquivo[i];
            if (i = parte^.linhaFinal ) and (s = '.') then break;
            if (trim(s) <> '') and (s [length(s)] = '=') then
                juntarLinha := true
            else
                juntarLinha := false;

            case tipoCodif of
                'Q':
                    begin
                        while copy(s, length(s), 1) = '=' do
                            begin
                                delete (s, length(s), 1);
                                i := i + 1;
                                if i > parte^.linhaFinal  then break
                                else s := s + linhasArquivo[i];
                                juntarLinha := false; //Neste ponto já juntou
                                if (i = parte^.linhaFinal ) and (linhasArquivo[i] = '.') then break
                            end;
                        s := convQuotedPrintable (s);
                    end;
                'B': if usaTempFileName then
                        s := DecodFraseMime64 (s);
                'N':; //nada faz
            end;
            case tipoCharset of
                'U': s := utfToAnsi (s);
                'I': decodificarString (s);
                'N':;//nada faz
            end;

            if not juntarLinha then
                {$I-} writeln (arqTemp, s) {$I+}
            else
                {$I-} write (arqTemp, s); {$I+}
            if ioresult <> 0 then
                begin
                    msgBaixo ('CTERRDSK');   {'Erro de escrita no disco'}
                    houveErro := true;
                end;
            i := i + 1;
        end;
    {$I-} close (arqtemp); {$I+}
    if ioresult = 0 then
        if tipoCodif = 'X' then
            if uudecode (nomeArq) <> 0 then
                     msgBaixo ('CTERRDSK'); {'Erro de escrita no disco'}

    if not houveErro then
        gravaParteDecodificada := nomeArq;
end;

{-------------------------------------------------------------}
{     Testa se o arquivo existe, se existir pede outro nome.
{-------------------------------------------------------------}

var sobrescreverTodosArq: boolean;

function testaRetornaNomeArq (nomeArq, diretorio, tipoDaParte: string): string;
var
    c: char;
    editaNomeArq: boolean;
begin
    if diretorio = '' then editaNomeArq := TRUE
    else editaNomeArq := false;
    c := 'S';
    repeat
        if editaNomeArq then
            begin
                repeat
                    limpaParteTela (20, 25);
                    textBackground (RED);
                    mensagem ('CTVOUGRV', 1);   {'Pretendo gravar '}
                    sintWriteln (nomeArq);
                    mensagem ('CTEDINOM', 0);   {'Editore o nome, tecle ENTER para confirmar
                                                            ou ESC para cancelar: '}
                    textBackground (BLACK);
                    writeln;
                    c := sintEdita (nomeArq, 1, wherey, 255, true);
                    writeln;
                until c in [ENTER, ESC];
            end
        else
        if trim (nomeArq) = '' then {Arquivo sem nome, pede o nome.}
            begin
                repeat
                    limpaParteTela (20, 25);
                    textBackground (RED);
                    mensagem ('CTAPATIP', 0); {'A parte do tipo '}
                    sintWriteln (tipoDaParte);
                    mensagem ('CTNTEMNO', 1); {'Não tem nome para o arquivo destino.'}
                    mensagem ('CTINFDST', 0); {'Informe o nome completo do arquivo destino:'}
                    textBackground (BLACK);
                    writeln;
                    c := sintEdita (nomeArq, 1, wherey, 255, true);
                    writeln;
                until upcase (c) in [ENTER, ESC];
            end;
        if (c = ESC) or (trim (nomeArq) = '') then
            begin
                msgBaixo ('CTDESIST'); {'Desistiu'}
                testaRetornaNomeArq := '';
                exit;
            end;

        if (pos ('\', nomeArq) = 0) and (pos ('/', nomeArq) = 0) and
           (diretorio = '') and (dirAnexo <> '') then
            nomeArq := dirAnexo + '\' + nomeArq
        else
        if (pos ('\', nomeArq) = 0) and (pos ('/', nomeArq) = 0) and
           (diretorio <> '') then
            nomeArq := diretorio + '\' + nomeArq;

        if (not sobrescreverTodosArq) and (existeArq (nomeArq)) then
            begin
                repeat
                    limpaParteTela (20, 25);
                    textBackground (RED);
                    mensagem ('CTJAEXI1', 0); {'O arquivo destino'}
                    writeln (' ');
                    delay (100);
                    sintWrite (nomeArq);
                    delay (100);
                    mensagem ('CTJAEXI2', 0); {'já existe.  Sobrescreve (S/N/T/ESC)? '}
                    c := upcase(popupMenuPorLetra ('SNT'));
                    textBackground (BLACK);
                    writeln;
                until c in ['S', 'N', ENTER, ESC, 'T'];
                if c = 'T' then sobrescreverTodosArq := true;
                if c in ['S', 'T', ENTER] then
                    testaRetornaNomeArq := nomeArq
                else
                if c = ESC then
                    begin
                        msgBaixo ('CTDESIST'); {'Desistiu'}
                        testaRetornaNomeArq := '';
                    end
                else
                    editaNomeArq := TRUE;
            end
        else
            testaRetornaNomeArq := nomeArq;
    until upcase (c) in ['S', 'T', ENTER, ESC];
end;

{-------------------------------------------------------------}
{       Joga a parte da carta no editor ou no brouse, arquivo temporário.
{-------------------------------------------------------------}

procedure LeituraParteCarta (parte: PEstrutura; lerComEditor, executarForaDosvox: boolean);
var
    nomeProg, nomeDir, nomeArq, s: string;
    arqTemp: text;
    Doc_ou_rtf: boolean;
    i: integer;

begin
    nomeArq := pegaNomeDoArquivoDaParte (parte);
    while fileExists (nomeArq) do nomeArq := '$' + nomeArq; //Para não apagar arquivo já existente na pasta após sair da leitura.
    s := trim (maiuscAnsi (parte^.content_transfer_encoding));

    if (maiuscAnsi (copy (nomeArq, length (nomeArq)-3, 4)) = '.DOC') or
      (maiuscAnsi (copy (nomeArq, length (nomeArq)-4, 5)) = '.DOCX') or
      (maiuscAnsi (copy (nomeArq, length (nomeArq)-3, 4)) = '.RTF') then
        begin
            if (maiuscAnsi (copy (nomeArq, length (nomeArq)-4, 5)) = '.DOCX') then
                nomeArq := '$.docx'
            else
                nomeArq := '$' + copy (nomeArq, length (nomeArq)-3, 4);

            if s <> 'BASE64' then
                gravaParteDecodificada (parte, nomeArq)
            else
                begin
                    gravaParteDecodificada (parte, '$.$');
                    decodMime64 ('$.$', nomeArq);
                end;
            doc_ou_rtf := TRUE;
        end
    else
        begin
            if maiuscAnsi (typeOuContent_type (parte)) = 'TEXT/HTML' then
                nomeArq := '$.html'
            else
            if maiuscAnsi (typeOuContent_type (parte)) = 'TEXT/HTM' then
                nomeArq := '$.htm'
            else
            if maiuscAnsi (typeOuContent_type (parte)) = 'APPLICATION/XML' then
                nomeArq := '$.xml';

            if s <> 'BASE64' then
            nomeArq := gravaParteDecodificada (parte, nomeArq)
            else
                begin
                    gravaParteDecodificada (parte, '$.$');
                    if trim (nomeArq) = '' then
                        nomeArq := '$2.$';
                    decodMime64 ('$.$', nomeArq);
                end;
            doc_ou_rtf := false;
        end;

    s := trim (maiuscAnsi (parte^.charset));
    if s = 'UTF-8' then
        decodArqUtfToAnsi (nomeArq);

    if tipoFolheGlobal in ['P', 'T', ^P, ^T] then
        nomeDir := dirEnvia
    else
        nomeDir := dirRecebe;
    if (pos (' ', nomeDir) <> 0) and (nomeDir [1] <> '"') then
        nomeDir := '"' + nomeDir+ '"';

    if executarForaDosvox then
        begin
            if (pos (':\', nomeArq) <> 0) or (pos('/', nomeArq) <> 0) then
                nomeProg := nomeArq
            else
            if tipoFolheGlobal in ['P', 'T', ^P, ^T] then
                nomeProg := dirEnvia + '\'+nomeArq
            else
                nomeProg := dirRecebe+'\'+nomeArq;
            s := nomeArq;
            nomeArq := '';
        end
    else
    if (maiuscAnsi (typeOuContent_type (parte)) = 'TEXT/HTML') or
      (maiuscAnsi (typeOuContent_type (parte)) = 'TEXT/HTM') or
      (maiuscAnsi (typeOuContent_type (parte)) = 'APPLICATION/XML') then
        begin
            if tipoFolheGlobal in ['P', 'T', ^P, ^T] then
                nomeArq := dirEnvia + '\' + nomeArq
            else
                nomeArq := dirRecebe + '\' + nomeArq;
            nomeProg := sintAmbiente ('CARTAVOX', 'LEITORHTML');
        end
    else
    if lerComEditor or doc_Ou_Rtf then
        begin
            nomeProg := sintAmbiente ('CARTAVOX', 'EDITOR');
            if nomeProg = '' then
                nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\Edivox.exe';
            if pos ('EDIVOX.EXE', uppercase(nomeProg)) <> 0 then
                nomeProg := '"'+ nomeProg+ '"' + ' /L';
        end
    else
        nomeProg := sintAmbiente ('CARTAVOX', 'LEITOR');

    nomeArq := trim (nomeArq);
    if (nomeArq <> '') and (pos (' ', nomeArq) <> 0) then
        if nomeArq [1] <> '"' then
            nomeArq := '"' + nomeArq + '"';

    i := executaProg (nomeProg, nomeDir, nomeArq);
    if i >= 32 then
        esperaProgVoltar
    else
    if i in [5, 31] then
        begin
            msgBaixo ('CTNAOEXE'); {'Não foi possível executar o arquivo, erro #'}
            msgBaixo (inttostr(i));
            delay(500);
        end
    else
        msgBaixo ('CTCARSUM');  {'Erro no disco: carta sumiu'}
    while sintFalando do waitMessage;

    if nomeArq = '' then nomeArq := s;
    deletaAspas (nomeArq);
    assign (arqTemp, nomearq);
    if (maiuscAnsi (typeOuContent_type (parte)) <> 'TEXT/HTML') and
       (maiuscAnsi (typeOuContent_type (parte)) <> 'TEXT/HTM') then
        begin
            {$I-}  erase (arqTemp);  {$I+}
            if ioresult <> 0 then;
        end;
    if doc_ou_rtf then
        begin
            assign (arqTemp, '$.txt');
            {$I-}  erase (arqTemp);  {$I+}
            if ioresult <> 0 then;
        end;
    assign (arqTemp, '$.$');
    {$I-}  erase (arqTemp);  {$I+}
    if ioresult <> 0 then;
end;

{-------------------------------------------------------------}
{       leitura Mime64
{-------------------------------------------------------------}

procedure leituraMime64 (parte: pEstrutura; executa, executarForaDosvox: boolean);
var
    toca: boolean;
    c: char;
    extensao: string;
    nomeProg, nomeDir, nomeArq, s: string;
    arqNovo: file;
    i: integer;

label erro;

begin
    nomeArq := pegaNomeDoArquivoDaParte (parte);
    if trim (nomeArq) <> '' then
        while fileExists (nomeArq) do nomeArq := '$' + nomeArq; //Para não apagar arquivo já existente na pasta após sair da leitura.

    toca := false;
    extensao := maiuscAnsi (retornaExtensao (nomeArq));

    if (not executarForaDosvox) and
      ((extensao = 'MID') or (extensao = 'WAV') or (extensao = 'MP3')) then
        begin
//          se for wav, mp3 ou mid, pergunta se quer tocar
            repeat
                limpaParteTela (23, 25);
                textBackground (RED);
                mensagem ('CTTOCAR', 0);   {'Arquivo é sonoro, quer tocar (s/n) ? '}
                c := upcase(popupMenuPorLetra ('SN'));
                textBackground (BLACK);
                writeln;
            until c in ['S', 'N', ENTER, ESC];

            if c = 'S' then
                begin
                    toca := true;
                    nomeArq := '$' + copy (nomeArq, length (nomeArq)-3, 4);
                end
            else
            if c = ESC then
                begin
                    msgBaixo ('CTDESIST'); {'Desistiu'}
                    exit;
                end;
        end
    else
    if executa or executarForaDosvox then
        begin
//          Executa a parte da carta
            repeat
                limpaParteTela (23, 25);
                textBackground (RED);
                mensagem ('CTARQVIR', 1);   {Esse arquivo pode ser um VÍRUS, tome muito cuidado!'}
                mensagem ('CTDESEXE', 0);   {'Deseja executar esse arquivo?'}
                c := upcase(popupMenuPorLetra ('SN'));
                textBackground (BLACK);
                writeln;
            until c in ['S', 'N', ENTER, ESC];
            if c <> 'S' then
                begin
                    msgBaixo ('CTDESIST'); {'Desistiu'}
                    exit;
                end;
        end;

    if (not toca) and (not executa) then
        begin
            sobrescreverTodosArq := false;
            nomeArq := testaRetornaNomeArq (nomeArq, '', TypeOuContent_Type(parte));
            if trim (nomeArq) = '' then exit;
        end;

    s := trim (maiuscAnsi (parte^.content_transfer_encoding));
    msgBaixo ('CTMOMENT');  {'Um momento...'}
    if s <> 'BASE64' then
        gravaParteDecodificada (parte, nomeArq)
    else
        begin
            gravaParteDecodificada (parte, '$.$');
            if not decodMime64 ('$.$', nomeArq) then goto erro;

            assignFile (arqNovo, '$.$');
            {$I-} erase (arqNovo);  {$I+}
            if ioresult <> 0 then goto ERRO;
        end;
    while sintFalando do waitMessage;

    assignFile (arqNovo, nomeArq);
    if tipoFolheGlobal in ['P', 'T', ^P , ^T] then
        nomeDir := dirEnvia
    else
        nomeDir := dirRecebe;

    if toca then
        begin
            nomeProg := sintAmbiente ('CARTAVOX', 'TOCADOR');
            if nomeProg = '' then
                nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\Midiavox.exe';
            while sintFalando do waitMessage;
            nomeArq := trim (nomeArq);
            if pos (' ', nomeArq) <> 0 then
                if nomeArq [1] <> '"' then
                    nomeArq := '"' + nomeArq + '"';
            if executaProg (nomeProg, nomeDir, nomeArq) >= 32 then
                esperaProgVoltar;
            {$I-} erase (arqNovo);  {$I+}
            if ioresult <> 0 then;
        end
    else
    if (extensao = '') and executa then
        begin
            LeituraParteCarta (parte, TRUE, executarForaDosvox);
            {$I-} erase (arqNovo);  {$I+}
            if ioresult <> 0 then;
        end
    else
    if executa then
        begin
            if (extensao = 'EXE') or (extensao = 'COM')  or
              executarForaDosvox then
                begin
                    if tipoFolheGlobal in ['P', 'T', ^P, ^T] then
                        nomeProg := dirEnvia + '\'+nomeArq
                    else
                        nomeProg := dirRecebe+'\'+nomeArq;
                    nomeArq := '';
                end
            else
                begin
                    nomeProg := sintAmbiente ('DOSVOX', 'PROG.' + extensao);
                    while sintFalando do waitMessage;
                    nomeArq := trim (nomeArq);
                    if pos (' ', nomeArq) <> 0 then
                        if nomeArq [1] <> '"' then
                            nomeArq := '"' + nomeArq + '"';

                    if nomeProg = '' then
                        begin
                            nomeProg := nomeArq;
                            nomeArq := '';
                        end;
                end;

            i := executaProg (nomeProg, nomeDir, nomeArq);
            if i >= 32 then
                esperaProgVoltar
            else
            if i in [5, 31] then
                begin
                    msgBaixo ('CTNAOEXE'); {'Não foi possível executar o arquivo, erro #'}
                    msgBaixo (inttostr(i));
                    delay(500);
                end
            else
                msgBaixo ('CTCARSUM');  {'Erro no disco: carta sumiu'}

            while sintFalando do waitMessage;

            {$I-} erase (arqNovo);  {$I+}
            if ioresult <> 0 then;
        end
    else
        msgBaixo ('CTOK');    {'OK'}
    exit;

erro:
    msgBaixo ('CTERRDSK');    {'Erro de escrita no disco'}
    if ioresult <> 0 then;
end;

{-------------------------------------------------------------}
{       Grava a(s) parte(s) em disco, pede o diretório.
{-------------------------------------------------------------}

procedure gravaParteDisco (nParte: integer; gravarTodosComNome: boolean);
var
    diretorio, nomeArq, item: string;
    arqTemp: text;
    i: integer;
    c: char;
    gravarSelecionadas: boolean;
    parte: PEstrutura;
label erro, desistiu, semDiretorio;

begin
    sobrescreverTodosArq := false;
    limpaParteTela (20, 25);
    diretorio := dirAnexo;
    if not selecDirDest (diretorio) then
        goto semDiretorio;

    diretorio := trim (diretorio);
    if diretorio [length (diretorio)] in ['\','/'] then delete (diretorio, length (diretorio), 1);

    if temItemSelecionado and (not gravarTodosComNome) then
    begin
            repeat
                limpaParteTela (23, 25);
                textBackground (RED);
                mensagem ('CTGRASEL', 0); {'Deseja gravar as partes selecionadas?'}
                c := upcase(popupMenuPorLetra ('SN'));
                textBackground (BLACK);
                writeln;
            until c in ['S', 'N', ESC, ENTER];
            if c = ESC then goto desistiu;
            gravarSelecionadas := c in ['S', ENTER];
        end
    else
        gravarSelecionadas := false;

    if gravarSelecionadas or gravarTodosComNome then
        begin
            msgBaixo ('CTMOMENT');  {'Um momento...'}
            for i := 1 to folheiaNumItens do
                begin
                    folheiaObtemItem (i, item, gravarSelecionadas);
                    if (not gravarSelecionadas) and (not gravarTodosComNome) then continue;
                    parte := listaDePartes [strToInt (trim (copy (item, 1, 5))) - 1];
                    nomeArq := pegaNomeDoArquivoDaParte (parte);
                    if (trim (nomeArq) = '') and gravarTodosComNome then continue;

                    nomeArq := testaRetornaNomeArq (nomeArq, diretorio, TypeOuContent_Type (parte));
                    if trim (nomeArq) = '' then
                        begin
                            repeat
                                limpaParteTela (24, 25);
                                textBackground (RED);
                                mensagem ('CTCGRAPS', 0); {'Deseja continuar a gravação das partes selecionadas?'}
                                c := upcase(popupMenuPorLetra ('SN'));
                                textBackground (BLACK);
                                writeln;
                            until c in ['S', 'N', ENTER, ESC];
                            if c in ['N', ESC] then
                                goto desistiu
                            else
                            if i < folheiaNumItens then
                                msgBaixo ('CTOK'); {'OK'}
                        end
                    else
                        begin
                            limpaParteTela (20, 25);
                            textBackground (RED);
                            mensagem ('CTGRAVPA', 0); {'Gravando parte '}
                            sintwrite (parte^.numero);
                            textBackground (BLACK);
                            writeln;

                            item := trim (maiuscAnsi (parte^.content_transfer_encoding));
                            if item <> 'BASE64' then
                                begin
                                    gravaParteDecodificada (parte, nomeArq);
                                end
                            else
                                begin
                                    gravaParteDecodificada (parte, '$.$');
                                    if not decodMime64 ('$.$', nomeArq) then
                                        goto erro;

                                    assignFile (arqTemp, '$.$');
                                    {$I-} erase (arqTemp);  {$I+}
                                    if ioresult <> 0 then goto erro;
                                end;
                            while sintFalando do waitMessage;
                        end;
                end;
        end
    else
        begin
            parte := listaDePartes [nParte];
            nomeArq := pegaNomeDoArquivoDaParte (parte);
            nomeArq := testaRetornaNomeArq (nomeArq, diretorio, TypeOuContent_Type (parte));
            if trim (nomeArq) = '' then goto erro;
            msgBaixo ('CTMOMENT');  {'Um momento...'}

            item := trim (maiuscAnsi (parte^.content_transfer_encoding));
            if item <> 'BASE64' then
                begin
                    gravaParteDecodificada (parte, nomeArq);
                end
            else
                begin
                    gravaParteDecodificada (parte, '$.$');
                    if not decodMime64 ('$.$', nomeArq) then
                        goto erro;
                    assignFile (arqTemp, '$.$');
                    {$I-} erase (arqTemp);  {$I+}
                    if ioresult <> 0 then
                        goto erro;
                end;
            while sintFalando do waitMessage;
        end;

    msgBaixo ('CTOK'); {'OK'}
    exit;
desistiu:
    msgBaixo ('CTDESIST'); {'Desistiu'}
    exit;
erro:
    msgBaixo ('CTERRDSK');    {'Erro de escrita no disco'}
semDiretorio:
end;

{-------------------------------------------------------------}
{       Executa ou grava a parte
{-------------------------------------------------------------}

procedure leOuGravaParte (parte: pEstrutura; lerSempre:boolean);
var
    tipo: string;
begin
    tipo := trim (maiuscAnsi (typeOuContent_type (parte)));
    if (tipo = 'TEXT/HTML') or (tipo = 'TEXT/PLAIN') or
       (tipo = 'APPLICATION/XML') or
       ((parte^.carta <> nil) and (tipo = '')) or lerSempre then
        LeituraParteCarta (parte, false, executarForaDosvoxGlobal)
    else
        leituraMime64 (parte, false, executarForaDosvoxGlobal);
end;

{-------------------------------------------------------------}
{       inicializa o folheamento das partes da carta
{-------------------------------------------------------------}

procedure inicializaFolheamento;
var
    totalPartes, i: integer;
    tipo, nomeArq: string;
    parte: PEstrutura;
begin
    totalPartes := listaDePartes.count;

    folheiaCria (1, 6, 80, 17);
    for i :=  0 to (totalPartes - 1) do
        begin
            parte := listaDePartes[i];
            if not parte^.removido then
                begin
                    tipo := typeOuContent_type (parte);
                    if trim (tipo) = '' then tipo := pegaTextoMensagem ('CTNAODEF'); {'Não definido'}
                    nomeArq := pegaNomeDoArquivoDaParte (parte);
                    nomeArq := copy (nomeArq + BRANCOS, 1, 54);
                    folheiaAdicionaEspecial (copy (intToStr(i+1)+BRANCOS, 1, 5) +
                                    copy (parte^.numero+BRANCOS, 1, 10) +
                                    copy (tipo+BRANCOS, 1, 20)+
                                    copy (nomeArq+BRANCOS, 1, 39),
                                    parte^.selecionado, parte^.numero+
                                    ' '+nomeArq+' '+tipo);
                end;
        end;
    totalPartesFolhe := folheiaNumItens;
end;

{-------------------------------------------------------------}
{                     folheamento das partes
{-------------------------------------------------------------}

procedure folheamentoDasPartes (ncar: integer; lerPrimeiraParte, listarPartesCarta: boolean);
var
    c, c2: char;
    nParte, nFolhe: integer;
    item: string;
    selecionado: boolean;
    parte: PEstrutura;
    primeiraVez, podeFalar: boolean;

begin
    inicializaFolheamento;
    regLido[ncar]^.contemAnexos := true;
    primeiraVez := true;
    nFolhe := 1;
    podeFalar := true;
    executarForaDosvoxGlobal := false;

    if lerPrimeiraParte then
        begin
            sintclek;
            leOuGravaParte (listaDePartes[0], false);
        end;

    parte := listaDePartes[1];
    if not (lerPrimeiraParte and (parte^.parte^.filename = '') and
      (parte^.content_type = 'text/html')) and listarPartesCarta then
        repeat
            telaFolheamentoPartes (ncar, folheiaNumItens);
            if primeiraVez then
                begin
                    mensagem ('CTNARQM', -1); {'Número de partes inclusas: '}
                    sintetiza (intToStr (folheiaNumItens));
                    mensagem ('CTQPARTE', -1); {'Qual a parte desejada? (use as setas, f1 ajuda)'}
                    primeiraVez := false;
                end;
            folheiaCorDoMeio (1, 35, CYAN);
            folheiaExecuta (nFolhe, nFolhe, c, c2, podeFalar);

            if nFolhe < 1 then NFolhe := 1;
            if nfolhe > folheiaNumItens then nFolhe := folheiaNumItens;
            for nParte := 1 to folheiaNumItens do
                begin
                    folheiaObtemItem (nParte, item, selecionado);
                    parte := listaDePartes[strToInt (trim (copy (item, 1, 5))) - 1];
                    parte^.selecionado := selecionado;
                end;
            folheiaObtemItem (nFolhe, item, selecionado);
            nParte := strToInt (trim (copy (item, 1, 5))) - 1;
            sintPara;
            parte := listaDePartes[nParte];

            if c2 = F9 then
                c := selSetasFolheiaPartes (c2);

            if c = #0 then
                begin
                    case c2 of
                        ESQ:    falaNomeDoArquivoDaParte (nParte);
                        DIR:    falaTipoDaParte (nParte);
                        F1:     ajudaFolhearPartes;
                        F7:     apagaParte (nFolhe);
                        F8:     falaHora;
                        CTLF8:  falaDia;
                    end;
            end
            else
                begin
                        case upcase(c) of
                            ENTER, 'L': leOuGravaParte (listaDePartes[nParte], false);
                            'E': LeituraParteCarta (parte, TRUE, false);
                            'G', ^G: gravaParteDisco (nParte, c = ^G);
                            'A': apagaParte (nFolhe);
                            'S': falaAssunto (nCar, true, true, false);
                            'Q', ^Q: falaQualItemDeQuantos (nFolhe, folheiaNumItens, c = ^Q);
                            'X', CTLENTER: leituraMime64 (listaDePartes [nParte], true, c = CTLENTER);
                            ' ':selecionaOuNaoUmItem (nFolhe);
                            '+', '-': folheiaSeleciona (nFolhe, c = '+');
                            '*', '/': selecionaTodosItens (c = '*');

                            ^P, 'P':
                                begin
                                    folheiaDestroi;
                                    if parte^.carta = NIL then
                                        mostraItensParte (parte)
                                    else
                                        mostraItensCarta (parte);
                                    inicializaFolheamento;
                                end;

                            ^F: //Grava a carta e sai do folheamento
                                begin
                                    gravacaoForcada := true;
                                    c := ESC;
                                end;

                            ^W: c:= ESC;

                        else
                            if c <> ESC then msgBaixo ('CTOPVINV'); {'Opção inválida, aperte F1 para ajuda'}
                        end;
                end;

            if folheiaNumItens < 1 then
                msgBaixo ('CTDESIST') {'Desistiu'}
            else
            if upcase(c) in [ENTER, 'L', 'E', 'G', 'A', 'P'] then
                mensagem ('CTQPARTE', -1); {'Qual a parte desejada? (use as setas, f1 ajuda)'}
    
            if (upCase(c) in['S', 'Q', ^Q]) or (c2 in [ESQ, DIR, f8, CTLF8]) then
                podeFalar := false
            else
                podeFalar := true;

        until (c = ESC) or (folheiaNumItens < 1);

    folheiaDestroi;
end;

{-------------------------------------------------------------}
{       Prepara resposta automática
{-------------------------------------------------------------}

procedure criarRespostaAutomatica(nCar: integer);
var
    nomeArq, s, sData, sHora, dataAux , in_reply_to_: string;
    arqAux : textfile;
    c : char;
    pCc : PListaCC;
    Year, Month, Day, DayOfWeek: Word;
    Hour, Minute, Second, Sec100: Word;
begin
    repeat
            mensagem('CTRESCON',0); {'O remetente pediu confirmação de leitura. Posso confirmar?'}
            c := upcase(popupMenuPorLetra ('SN'));
            writeln;
            if c = 'S' then
            begin
                getDate(Year, Month, Day, DayOfWeek);
                str (Day, sData);
                if length(sData) < 2 then sData := '0' + sData;
                sData := sData + '/';
                str (Month, s);
                if length(s) < 2 then s := '0' + s;
                sData := sData + s;
                str(Year, s);
                sData := sData + '/' + s;

                dvcrt.getTime (Hour, Minute, Second, Sec100);
                str(Hour, sHora);
                if length(sHora) < 2 then sHora := '0' + sHora;
                sHora := sHora + ':';
                str(Minute, s);
                if length(s) < 2 then s := '0' + s;
                sHora := sHora + s;

                dataAux := regLido[ncar]^.carta^.date;
                if pos(',', dataAux) > 0 then
                    dataAux := copy(dataAux, pos(',', dataAux) + 2, length(dataAux));
                if pos('-0', dataAux) > 0 then
                    dataAux := copy(dataAux, 1, pos('-0', dataAux) - 1);

                nomeArq := dirRecebe + '\' + 'Conf_receb' + IntToStr(Year) +
                           IntToStr(Month)  + IntToStr(Second) + IntToStr(Hour) +
                           IntToStr(Minute) + IntToStr(Second) + '.txt';
                assignFile(arqAux, nomeArq);
                {$I-} rewrite(arqAux); {$I+}
                if ioresult = 0 then
                    begin
                        writeln(arqAux, 'Esta é uma confirmação de leitura do email que você enviou para');
                        writeln(arqAux, regLido[ncar]^.carta^.to_);
                        writeln(arqAux, 'no dia ' + dataAux);
                        writeln(arqAux, 'com o assunto:  ' + regLido[ncar]^.carta^.subject);
                        writeln(arqAux, '');
                        writeln(arqAux, 'Esta confirmação informa que a carta foi aberta pelo destinatário');
                        writeln(arqAux, 'dia ' + sData + ' às ' + sHora + '.');
                        {$I-} closeFile(arqAux); {$I+}
                        if ioresult <> 0 then;
                        pcc := nil;
                        //Pega o ID da carta de origem
                        if trim(regLido[nCar]^.carta^.message_id) <> '' then
                            in_reply_to_ := trim(regLido[nCar]^.carta^.message_id)
                        else
                            in_reply_to_ := '';

                        geraTextoSmtp(nomeArq, regLido[nCar]^.carta^.from,
                                      'Confirmação de Recebimento: ' +
regLido[nCar]^.carta^.subject,
                                      pCc, pcc, false, false, false, nCar, in_reply_to_, true)
                    end;
            end;
    until c in ['S', 'N', ESC];
end;

{-------------------------------------------------------------}
{       Escolhe o tipo de leitura, carta simples ou multipart
{-------------------------------------------------------------}

procedure leCarta (nCar: integer; lerSempre,lerPrimeiraParte, listarPartesCarta: boolean);
begin
    gravacaoForcada := false;
    if not carregaLinhasArquivo (regLido[ncar]^.carta^.nomArqCarta) then//Aloca o arquivo da carta
        begin
            msgBaixo ('CTCARSUM');  {'Erro no disco: carta sumiu'}
            exit;
        end;

    preencheCartaPrincipal (regLido[ncar]);//preenche o cabeçalho principal da carta

    //verifica se pede confirmação de recebimento e se a carta ainda não foi lida
    if perguntarCriarRespostaAutomatica and
       (regLido[ncar]^.carta^.disposition_notification_to <> '') and
       (pos ('M.', regLido[nCar]^.carta^.nomArqCarta) = 0) and
       (pos ('.CPR', regLido[nCar]^.carta^.nomArqCarta) = 0) and
       (pos ('.ENV', regLido[nCar]^.carta^.nomArqCarta) = 0)  then
          criarRespostaAutomatica(nCar);

    if trim (regLido[ncar]^.boundary) = '' then  //Não tem anexos
        leOuGravaParte (regLido [nCar], lerSempre)
    else  //Se tiver anexos
        begin
            criaIndicePartes;   //Cria o TList das partes que é preenchido no montatudo
            montaTudo (regLido[ncar]);   //Cria a estrutura da carta na memória
            if listaDePartes.count = 1 then  //Apenas uma parte
                leOuGravaParte (listaDePartes[0], false)
            else  //Mais de uma parte
                begin
                    folheamentoDasPartes (ncar,lerPrimeiraParte, listarPartesCarta);//Exibe a lista das partes com opções
                    gravarAlteracoes (ncar); //Grava se deletou parte
                end;
            desmontaTudo (regLido[ncar]); //Desaloca a estrutura da carta
            destroiIndicePartes; //Destroi o TList com o indice das partes.
        end;

    destroiLinhasArquivo;//Desaloca o arquivo da carta
end;

{-------------------------------------------------------------}
{       Grava os abnexos com nome de uma carta ou das selecionadas em um diretório
{-------------------------------------------------------------}

function gravarTodosAnexos (nCar: integer): integer;
var
    c: char;
    nParte, nCartaInicial, nCartaFinal, totalCartasSelecionadas: integer;
    diretorio, nomeArq: string;
    arqTemp: text;
    parte: PEstrutura;
    gravarSelecionadas, sobrescreverTodosArqs, naoSobrescreverTodosArqs: boolean;
label ERRO, desistiu;

begin
    gravarTodosAnexos := nCar;
    telaFolheamentoCartas;
    mensagem ('CTGRPANO', 2); {'Gravar partes que tem nome'}
    totalCartasSelecionadas := totalDeItensSelecionados;
    folheiaDestroi;
    diretorio := dirAnexo;
    if not selecDirDest (diretorio) then exit;
    diretorio := trim (diretorio);
    if diretorio [length (diretorio)] in ['\','/'] then delete (diretorio, length (diretorio), 1);

    nCartaInicial := nCar;
    nCartaFinal := nCar;
    gravarSelecionadas := false;
    sobrescreverTodosArqs := false;
    naoSobrescreverTodosArqs := false;
    if totalCartasSelecionadas > 0 then
    begin
            repeat
                textBackground (RED);
                mensagem ('CTGRCASE', 0); {'Deseja gravar as partes das cartas selecionadas?'}
                c := upcase(popupMenuPorLetra ('SN'));
                textBackground (BLACK);
                writeln;
            until c in ['S', 'N', ESC, ENTER];
            if c = ESC then goto desistiu;
            if c in ['S', ENTER] then //Processar as selecionadas
                begin
                    nCartaInicial := 1;
                    nCartaFinal := numRegs;
                    gravarSelecionadas := true;
                end;
        end;
    if totalCartasSelecionadas = 0 then totalCartasSelecionadas := 1; //Para não dá erro no calculo do percentual

    mensagem ('CTMOMENT', 1);  {'Um momento...'}
    for nCar := nCartaInicial to nCartaFinal do
        begin
            if gravarSelecionadas and (not regLido [nCar]^.selecionado) then continue;
            if not carregaLinhasArquivo (regLido[ncar]^.carta^.nomArqCarta) then//Aloca o arquivo da carta
                begin
                    msgBaixo ('CTCARSUM');  {'Erro no disco: carta sumiu'}
                    gravarTodosAnexos := nCar;
                    exit;
                end;

            preencheCartaPrincipal (regLido[ncar]);//preenche o cabeçalho principal da carta
            if keypressed then
                begin
                    while keypressed do c := upcase(readkey);
                    case c of
                        F1: ajudaGravarTodosAnexos;
                        'C', ESQ, DIR: begin
                                if c = DIR then falaAssunto (nCar, true, false, true);
                                falaRemetente (nCar);
                                                                if c <> DIR then falaAssunto (nCar, true, false, true);
                            end;
                        ESC: begin
                                destroiLinhasArquivo;
                                goto desistiu;
                            end;
                    else
                        begin
                            falaQualItemDeQuantos (nCar, totalCartasSelecionadas, false);
                            sintetiza (intToStr((nCar * 100) div totalCartasSelecionadas) + ' %');
                        end;
                    end;
                end;

            if trim (regLido[ncar]^.boundary) = '' then
                begin
                    destroiLinhasArquivo;
                    continue;
                end;

            criaIndicePartes;   //Cria o TList das partes que é preenchido no montatudo
            montaTudo (regLido[ncar]);   //Cria a estrutura da carta na memória
            if listaDePartes.count = 1 then  //Apenas uma parte
                begin
                    desmontaTudo (regLido[ncar]); //Desaloca a estrutura da carta
                    destroiIndicePartes; //Destroi o TList com o indice das partes.
                    destroiLinhasArquivo;//Desaloca o arquivo da carta
                    continue;
                end;

            for nParte := 0 to (listaDePartes.count - 1) do
                begin
                    parte := listaDePartes [nParte];
                    nomeArq := pegaNomeDoArquivoDaParte (parte);
                    if trim (nomeArq) = '' then continue;
                    nomeArq := diretorio + '\' + nomeArq;

                    if (not sobrescreverTodosArqs) and (not naoSobrescreverTodosArqs) and existeArq (nomeArq) then
                        begin
                            repeat
                                limpaParteTela (24, 25);
                                textBackground (RED);
                                mensagem ('CTJAEXI1', 0); {'O arquivo destino'}
                                writeln (' ');
                                delay (100);
                                sintWrite (nomeArq);
                                delay (100);
                                mensagem ('CTJAEXI2', 0); {'já existe.  Sobrescreve (S/N/ESC)? '}
                                c := upcase(popupMenuPorLetra ('SNTP'));
                                write (c);
                                textBackground (BLACK);
                                writeln;
                                if not (c in ['S', 'N', 'T', 'P', ENTER, ESC]) then
                                    mensagem ('CTSETOPC', 1); {'Use as setas para conhecer outras opções'}
                            until c in ['S', 'N', 'T', 'P', ENTER, ESC];
                            if c = 'T' then sobrescreverTodosArqs := true
                            else
                            if c = 'P' then naoSobrescreverTodosArqs := true
                            else
                            if c ='N' then continue
                            else
                            if c = ESC then
                                begin
                                    desmontaTudo (regLido[ncar]); //Desaloca a estrutura da carta
                                    destroiIndicePartes; //Destroi o TList com o indice das partes.
                                    destroiLinhasArquivo;//Desaloca o arquivo da carta
                                    goto desistiu;
                                end;
                        end;
                    if  naoSobrescreverTodosArqs and existeArq (nomeArq) then continue;

                    if trim (maiuscAnsi (parte^.content_transfer_encoding)) <> 'BASE64' then
                        gravaParteDecodificada (parte, nomeArq)
                    else
                        begin
                            gravaParteDecodificada (parte, '$.$');
                            if not decodMime64 ('$.$', nomeArq) then
                                goto erro;
                            assignFile (arqTemp, '$.$');
                            {$I-} erase (arqTemp);  {$I+}
                            if ioresult <> 0 then goto ERRO;
                        end;
                    while sintFalando do waitMessage;
                end;

            desmontaTudo (regLido[ncar]); //Desaloca a estrutura da carta
            destroiIndicePartes; //Destroi o TList com o indice das partes.
            destroiLinhasArquivo;//Desaloca o arquivo da carta
        end;

    msgBaixo ('CTOK'); {'OK'}
    exit;
desistiu:
    msgBaixo ('CTDESIST'); {'Desistiu'}
    gravarTodosAnexos := nCar;
    exit;
ERRO:
    msgBaixo ('CTERRDSK');    {'Erro de escrita no disco'}
    desmontaTudo (regLido[ncar]); //Desaloca a estrutura da carta
    destroiIndicePartes; //Destroi o TList com o indice das partes.
    destroiLinhasArquivo;//Desaloca o arquivo da carta
    gravarTodosAnexos := nCar;
end;

{-------------------------------------------------------------}
{       Retorna se a primeira parte da carta é txt ou html
{-------------------------------------------------------------}

function primeiraParteTxtOuHtml (nCar: integer): boolean;
var
    tipo: string;
    parte: PEstrutura;

begin
    primeiraParteTxtOuHtml := false;
    if not carregaLinhasArquivo (regLido[ncar]^.carta^.nomArqCarta) then exit;
    preencheCartaPrincipal (regLido[ncar]);//preenche o cabeçalho principal da carta
    if trim (regLido[ncar]^.boundary) = '' then
        tipo := trim (maiuscAnsi (typeOuContent_type (regLido[ncar])))
    else
        begin
            criaIndicePartes;   //Cria o TList das partes que é preenchido no montatudo
            montaTudo (regLido[ncar]);   //Cria a estrutura da carta na memória
            parte := listaDePartes [0];
            tipo := trim (maiuscAnsi (typeOuContent_type (parte)));
            desmontaTudo (regLido[ncar]); //Desaloca a estrutura da carta
            destroiIndicePartes; //Destroi o TList com o indice das partes.
        end;
    destroiLinhasArquivo;//Desaloca o arquivo da carta
    if (tipo = 'TEXT/HTML') or (tipo = 'TEXT/PLAIN') then
        primeiraParteTxtOuHtml := true;
end;

{-------------------------------------------------------------}
begin
end.
