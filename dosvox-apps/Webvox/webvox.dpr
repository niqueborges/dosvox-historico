{-------------------------------------------------------------}
{
{    Programa de navegação básica na WEB (HTTP)
{
{    Autores: Jose' Antonio Borges e Bernard Condorcet Porto
{
{    Em 11/04/98
{
{-------------------------------------------------------------}

uses
     windows, shellApi, sysUtils, webutil,
     dvcrt, dvWin, winsock, dvinet, dvForm, dvhora, dvjpeg, dvExec,
     webVars, webUrl, webConf, webGrArq, webleit, webMsg, webTraz, webGrava,
     webBMark, webCarta, webBusca, webCatal, webCook;

{-------------------------------------------------------------}
{                     rotina de inicializacao
{-------------------------------------------------------------}

procedure inicializa (falarAbertura: boolean);
var
    s: string;
    erro: integer;
    dir: string;

begin
    clrscr;
    setWindowText (crtWindow, 'WEBVOX');

    debug := false;
    mudo := false;
    dir := sintambiente ('WEBVOX', 'DIRWEBVOX');
    if dir = '' then
        dir := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\webvox';
    sintInic (obtemInt(sintAmbiente('WEBVOX', 'VELOCIDADE'), 0), dir);

    usaSapi := falandoSapi;
    tipoSapi1 := obtemInt (sintAmbiente ('SERVFALA', 'TIPOSAPI'), 1);
    vozSapi1 := obtemInt (sintAmbiente ('SERVFALA', 'VOZ'), 1);
    velSapi1 := obtemInt (sintAmbiente ('SERVFALA', 'VELOCIDADE'), 220);
    tomSapi1 := obtemInt (sintAmbiente ('SERVFALA', 'TOM'), 110);
    tipoSapi2 := obtemInt (sintAmbiente ('WEBVOX', 'TIPOSAPI'), 1);
    if tipoSapi2 <= 0 then tipoSapi2 := 4;
    vozSapi2 := obtemInt (sintAmbiente ('WEBVOX', 'VOZSAPI'), 1);
    velSapi2 := obtemInt (sintAmbiente ('WEBVOX', 'VELOCSAPI'), 220);
    tomSapi2 := obtemInt (sintAmbiente ('WEBVOX', 'TOMSAPI'), 110);
    modoFala := upcase((sintAmbiente ('WEBVOX', 'MODOFALA') + 'N')[1]);

    arqCookie := sintambiente ('WEBVOX','ARQWEBCOOKIES');
    if arqCookie = '' then
       arqCookie := sintDirAmbiente + '\webcookies.ini';

    nomeWebselec := sintambiente ('WEBVOX','ARQWEBSELEC');
    if nomeWebselec = '' then
       nomeWebselec := sintDirAmbiente + '\webselec.ini';

    nomeWebcatal := sintambiente ('WEBVOX','ARQWEBCATAL');
    if nomeWebcatal = '' then
        nomeWebcatal := sintDirAmbiente + '\webcatal.ini';

    falarCarregamento := upcase( sintAmbiente ('WEBVOX', 'FALARCARREGAMENTO', 'SIM')[1]) = 'S';
    biparEmLinks := upcase( sintAmbiente ('WEBVOX', 'BIPAREMLINKS', 'SIM')[1]) = 'S';

    ultimoLinkLido := '';
    inicCookies;

    write (pegaTextoMensagem('WBINIC'));   {'Leitor de páginas WEB - NCE/UFRJ - v'}
    write (VERSAO);
    writeln (ALFABETA);
    writeln;
    if falarAbertura then
        if sintFalarTudo then
            begin
                mensagem ('WBINIC', -1);   {'Leitor de páginas WEB - NCE/UFRJ - v'}
                sintetiza (VERSAO);
                sintetiza (ALFABETA);
            end
        else
           mensagem ('WBWEBVOX', -1);   {'WEBVOX'}

    if not abreWinSock then
        mensagem ('WBERRCOM', 1);  {'Não consegui ativar o sistema de comunicação do micro'}

    portaHTTP := 80;
    nomeTemp := '';
    nomePagAtual := '';
    topoPilhaPag := 0;
    nlinCabecHTTP := 0;
    ntags := 0;
    linhaAtual := 1;
    nomeBase := '';
    emPortug := true;
    rotuloInicial := '';
    textoBuscado :=  sintambiente ('WEBVOX','TEXTOBUSCADO');
    nSomTags := 0;
    falandoPontuacao := upcase((sintAmbiente('WEBVOX', 'FALANDOPONTUACAO') + 'N')[1]) = 'S';
    portaLocalFTP := 1050;

    ultMsgAutent := '@#$%@';
    ultAutent := '@#$%@';

    new (tagsPagina);
    getMem (dadosPost, 206000);     // preliminar, só transmite até 200 K

    nTagsForms := 0;
    new (tagsForms);

    {Bernard}
    titCatal:= nomeWebSelec;
    carregaBookMarks;

    comProxy := upcase((sintAmbiente ('WEBVOX', 'COMPROXY') + 'N')[1]) = 'S';

    s := sintAmbiente ('WEBVOX', 'ENDERPROXY');
    if s <> '' then
        hostProxy := s
    else
        hostProxy := PROXY_NCE;

    s := sintAmbiente ('WEBVOX', 'PORTAPROXY');
    if s <> '' then
        val (s, portaProxy, erro)
    else
        portaProxy := PORTAPROXY_NCE;

    dirTags := sintAmbiente ('WEBVOX', 'DIRSOMTAGS');
    if dirTags = '' then dirTags := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\somtags';

    case modoFala of
        'T', 'R': s := '';
        'D':  begin
                  s := sintAmbiente ('WEBVOX', 'AMBWEBTAGS2');
                  if s = '' then
                    s := sintDirAmbiente + '\webtags2.ini';
              end;
    else // 'N'
              begin
                  s := sintAmbiente ('WEBVOX', 'AMBWEBTAGS');
                  if s = '' then
                    s := sintDirAmbiente + '\webtags.ini';
              end;
    end;
    prepSonsTags (s);

    dirDownload := sintAmbiente ('WEBVOX', 'DIRDOWNLOAD');
    if uppercase(dirDownload) = '*DOWNLOADS' then
        begin
            dirDownload := getMeusDownloads;
            sintGravaAmbiente( 'WEBVOX', 'DIRDOWNLOAD', dirDownload);
        end;

end;

{-------------------------------------------------------------}
{                 edita pagina com editor de textos
{-------------------------------------------------------------}

procedure chamarEditor;
var nomeArq, nomeEditor: string;
    c: char;
    tempPath, tempFileName: array [0..144] of char;
    geraRef: boolean;
begin
    if nomeTemp = '' then
        begin
            mensagem ('WBNAOCAR', 1);  {'Não existe página carregada'}
            exit;
        end;

    getTempPath (144, tempPath);
    getTempFileName(tempPath, 'wbe', 0, tempFileName);
    nomeArq := strPas (tempFileName);

    mensagem ('WBQUEREF', 0);  {'Deseja referências listadas no texto ? '}
    c := popupMenuPorLetra ('SN' + ESC);
    writeln;
    if c = ESC then
        begin
            mensagem ('WBDESIST', 1); {'Desistiu ...'}
            exit;
        end;
    geraRef := c = 'S';

    if not geraArqTexto (nomeTemp, nomeArq, geraRef) then
        begin
            mensagem ('WBERRTXT', 1);  {'Erro ao gravar o arquivo texto'}
            exit;
        end;

    nomeEditor := sintAmbiente ('WEBVOX', 'EDITOR');
    if nomeEditor = '' then
        nomeEditor := sintAmbiente ('DOSVOX', 'MINIED');
    if nomeEditor = '' then
        nomeEditor := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\minied.exe';
    while sintFalando do waitMessage;

    if sintFalarTudo then mensagem ('WBABREDI', 2);  {'Abrindo editor'}
    if executaProg (nomeEditor, '', nomeArq) > 32 then
        begin
            esperaProgVoltar;
            while sintFalando do waitMessage;
        end
    else
        mensagem ('WBERREDI', 1);    {'Erro ao acionar o editor de textos'}

    {$I-} DeleteFile (nomeArq);  {$I+}
    if ioresult <> 0 then;
end;

{-------------------------------------------------------------}
{                 exportar texto para clipboard
{-------------------------------------------------------------}

procedure exportarPagina;
var
    p: PChar;
    pos, tam: word;
    arq: text;
    nomeArq, texto: string;
    tempPath, tempFileName: array [0..144] of char;
begin
    if nomeTemp = '' then
        begin
            mensagem ('WBNAOCAR', 1);  {'Não existe página carregada'}
            exit;
        end;

    getTempPath (144, tempPath);
    getTempFileName(tempPath, 'web', 0, tempFileName);
    nomeArq := strPas (tempFileName);
    geraArqTexto (nomeTemp, nomeArq, false);

    assign (arq, nomeArq);
    {$I-}  reset (arq);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('WBTRAAPA', 1);  {'Arquivo de trabalho foi apagado'}
            exit;
        end;

    getmem (p, 65000);
    pos := 0;
    while not eof (arq) do
        begin
            readln (arq, texto);
            tam := length (texto);
            if (longint (pos) + tam + 2) > 65000 then
                begin
                    mensagem ('WBCOPTRU', 1);  {'Não cabe na área de transferência'}
                    break;
                end;

            if tam > 0 then
                move (texto[1], p[pos], tam);
            pos := pos + tam;
            p[pos]   := #$0d;
            p[pos+1] := #$0a;
            pos := pos + 2;
        end;
    closefile (arq);

    p[pos] := #$0;
    putClipboard (p);

    mensagem ('WBBLKCPY', 1);  {'Bloco copiado'}
    freemem (p, 65000);
    erase (arq);
end;

{-------------------------------------------------------------}
{                     finaliza o programa
{-------------------------------------------------------------}

procedure finaliza (falarTerminado: boolean);
var arq: file;
begin
    finalizaCookies;
    fechaWinSock;

    dispose (tagsPagina);
    freeMem (dadosPost, 10000);

    while topoPilhaPag > 0 do
        begin
            if pilhaPag [topoPilhaPag]^.podeApagarTemp then
                begin
                    assign (arq, pilhaPag [topoPilhaPag]^.nomeArqTemp);
                    {$I-}  erase (arq);  {$I+}
                    if ioresult <> 0 then;
                end;
            topoPilhaPag := topoPilhaPag - 1;
        end;

    if falarTerminado and sintFalarTudo then
        mensagem ('WBFIM', 1);  {'Acesso à WEB terminado'}
    sintFim;
    doneWinCrt;
end;

{-------------------------------------------------------------}
{                     testa se quer terminar
{-------------------------------------------------------------}

procedure fim;
var c: char;
begin
    mensagem ('WBCNFFIM', 0);  {'Confirma fim (s/n): '}
    c := popupMenuPorLetra ('SN');
    writeln;

    processando := not (c in ['S', ENTER]);
end;

{-------------------------------------------------------------}
{                   guarda página preferida
{-------------------------------------------------------------}

procedure guardaPagPreferida;
var
    pagPreferida: string;
    c: char;
begin
    pagPreferida := nomePagAtual;
    mensagem ('WBEDPREF', 1);       {'Editore o nome da página preferida'}
    c := sintEditaCampo (pagPreferida, wherex, wherey, 255, 80, true);
    writeln ;
    if c = ESC then
        begin
            mensagem ('WBDESIST', 1);  {'Desistiu'}
            exit;
        end;

    sintGravaAmbiente ('WEBVOX', 'PREFERIDA', pagPreferida);
    mensagem ('WBOK', 1);       {'OK'}
end;

{-------------------------------------------------------------}
{                          ajuda
{-------------------------------------------------------------}

procedure ajuda;
begin
   mensagem ('WBAJU01', 1);  {'As opções são:'}
   mensagem ('WBAJU02', 1);  {'  T    trazer página da rede'}
   mensagem ('WBAJU03', 1);  {'  L    ler página'}
   mensagem ('WBAJU04', 1);  {'  V    voltar à última lida'}
   mensagem ('WBAJU05', 1);  {'  S    páginas selecionadas'}
   mensagem ('WBAJU06', 1);  {'  A    trazer a página de um arquivo local'}
   mensagem ('WBAJU07', 1);  {'  G    gravar página'}
   mensagem ('WBAJU08', 1);  {'  O    gravar no formato original'}
   mensagem ('WBAJU09a', 1); {'  X    exportar texto da página para área de transferência'}
   mensagem ('WBAJU10', 1);  {'  C    configurar o programa'}
   mensagem ('WBAJU12', 1);  {'  N    trazer página sem ler'}
   mensagem ('WBAJU13', 1);  {'  R    recarregar esta página'}
   mensagem ('WBAJU14', 1);  {'  P    guarda página preferida'}
   mensagem ('WBAJU15', 1);  {'  E    enviar página por email'}
   mensagem ('WBAJU16', 1);  {'  B    carregar páginas do buscador'}
   mensagem ('WBAJU19', 1);  {'  ESC  terminar o programa'}

   while keypressed do readkey;
end;

{-------------------------------------------------------------}
{               seleciona a opção com as setas
{-------------------------------------------------------------}

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

function selSetasOpcao: char;
var n: integer;
const
    tabLetrasOpcoes: string [14] = 'tlvsagoxcnrpeb';

begin
    popupMenuCria (wherex, wherey, 60, 15, MAGENTA);
    MenuAdiciona ('WBAJU02');  {'  T    trazer página da rede'}
    MenuAdiciona ('WBAJU03');  {'  L    ler página'}
    MenuAdiciona ('WBAJU04');  {'  V    voltar à última lida'}
    MenuAdiciona ('WBAJU05');  {'  S    páginas selecionadas'}
    MenuAdiciona ('WBAJU06');  {'  A    trazer a página de um arquivo local'}
    MenuAdiciona ('WBAJU07');  {'  G    gravar página'}
    MenuAdiciona ('WBAJU08');  {'  O    gravar no formato original'}
    MenuAdiciona ('WBAJU09a'); {'  X    exportar texto da página para área de transferência'}
    MenuAdiciona ('WBAJU10');  {'  C    configurar o programa'}
    MenuAdiciona ('WBAJU12');  {'  N    trazer página sem ler'}
    MenuAdiciona ('WBAJU13');  {'  R    recarregar esta página'}
    MenuAdiciona ('WBAJU14');  {'  P    guarda página preferida'}
    MenuAdiciona ('WBAJU15');  {'  E    envia página por email'}
    MenuAdiciona ('WBAJU16');  {'  B    carregar páginas do buscador'}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpcao := tabLetrasOpcoes[n]
    else
        selSetasOpcao := ENTER;
end;

{-------------------------------------------------------------}
{                     programa principal
{-------------------------------------------------------------}

var c1, c2: char;
    s, nome: string;
    ok, ehArquivo, falarAbertura: boolean;
    voltando: boolean;
    i: integer;

label executa;
begin
    processando := true;
    falarAbertura := true;

    nome := sintAmbiente('WEBVOX', 'PREFERIDA');
    for i := 1 to paramCount do
        if upperCase(paramStr(i)) = '/M' then
            falarAbertura := false
        else
            nome := paramStr(i);

    inicializa (falarAbertura);

    if nome <> '' then
        begin
            ehArquivo := false;
            if nome [1] = '"' then
                begin
                    ehArquivo := true;
                    delete (nome, 1, 1);
                    if copy (nome, length(nome), 1) = '"' then
                        delete (nome, length(nome), 1);
                end
            else
                if (pos ('\', nome) <> 0) or (pos (':', nome) = 2) or (FileExists(nome)) then
                    ehArquivo := true;

            if ehArquivo then
                ok := carregarArquivo (nome)
            else
                begin
                    completaEsquema (nome);
                    ok := trazerPagina (nome, 'G');
                end;

            if ok then
                begin
                    fecharPrograma := false;
                    lerPagina (voltando);
                    if fecharPrograma then finaliza (true);
                end
            else
                mensagem ('WBPAGNAO', 1);  {'Página não achada'}
        end;

    if falarAbertura then processando := true;
    if (not ehArquivo) and (trim(nome) = '') and (upcase(sintAmbiente('WEBVOX', 'PEDIRENDERECONAABERTURA', 'SIM')[1]) = 'S') then
        begin
            c1 := 'T';
            goto executa;
        end;
        c1 := ' ';
    while (processando)  do
        begin
            textBackground (BLUE);
            if c1 <> NOFOCUS then mensagem ('WBQUALOP', 0);  {'Qual sua opção ? '}
            textBackground (BLACK);

            checkFocus := true;
            sintLeTecla (c1, c2);
            checkFocus := false;
            if c1 <> NOFOCUS then writeln;
            fecharPrograma := false;

            if (c1 = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
                begin
                    c1 := selSetasOpcao;
                    goto executa;
                end
            else
            if (c1 = #0) and (c2 = F1) then
                ajuda
            else
            if (c1 = #0) and (c2 = CTLF8) then
                falaDia
            else
executa:
            if c1 = #0 then
                case c2 of
                    F1:  ajuda;

                    F2: begin
                            biparEmLinks := not biparEmLinks;
                            if biparEmLinks then sintBip
                            else sintClek;
                        end;

                    F3: begin
                            if nomePagAtual = '' then
                                mensagem ('WBNAOCAR', 1)   {'Não existe página carregada'}
                            else
                                begin
                                    mensagem ('WBEDIT',1);
                                    s := paginaQueFoiAberta;
                                    c1 := sintEditaCampo (s,wherex,wherey,255,80,true);
                                    if c1 <> ESC then
                                        begin
                                            writeln;
                                            nomePagAtual := s;
                                            if trazerPagina (s, 'G') then
                                                repeat
                                                    lerPagina (voltando);
                                                    if voltando then voltando := voltarPagina;
                                                until not voltando;
                                        end;
                                end;
                            writeln;
                        end;

                    F4:  configura;

                    HOME: begin
                            mensagem ('WBINIC', -1);   {'Leitor de páginas WEB - NCE/UFRJ - v'}
                            sintetiza (VERSAO);
                            sintetiza (ALFABETA);
                        end

                end
            else
                case upcase(c1) of
                    NOFOCUS, GOTFOCUS: ;
                    'C':  configura;
                    'N':  trazerPagina ('', 'G');
                    'R':  recarregaPagina;

                    'L': repeat
                            closeBmp; clrscr;
                            lerPagina (voltando);
                            if voltando then voltando := voltarPagina;
                        until not voltando;

                    'T': if trazerPagina ('', 'G') then
                            repeat
                                closeBmp; clrscr;
                                lerPagina (voltando);
                                if voltando then voltando := voltarPagina;
                            until not voltando;

                    'A':  carregarArquivo ('');
                    'V':  voltarPagina;
                    'S':  preferenciaCatalogo;
                    'O':  gravarOriginal (false);
                    'G':  gravarPagina;
                    'H':  chamarEditor;
                    'X':  exportarPagina;
                    'B':  armazenaVariasPaginas;
                    'D':  debug := not debug;
                    'E':  enviaPagina;
                    'P':  guardaPagPreferida;
                    ^F, ^W: processando := false;

                    ESC:  fim;
                    #$0d: ;
                else
                    mensagem ('WBOPERR', 1);  {'Opção inválida, aperte F1 para ajuda'}
                end;

    if processando then
        processando := not fecharPrograma;
        end;

    finaliza (falarAbertura);
end.
