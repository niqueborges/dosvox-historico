{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Módulo de baixar
{
{    Autores: José Antonio Borges
{             Lidiane Figueira Silva
{             Bernard Condorcet
{             Marcolino Nascimento
{
{    Em Junho/2015
{
{--------------------------------------------------------}

unit jobaixa;

interface

uses
    sysutils,
    dvwin,
    dvcrt,
    dvform,
    dvinet,
    synacode,
    classes,
    jomsg,
    jovars,
    joUtil,
    dvexec,
    Windows;

procedure selCategoria;
procedure Cabecalho;
function baixaJogo(categoria:string): boolean;

implementation

{--------------------------------------------------------}
{               Faz o download de um arquivo
{--------------------------------------------------------}

function baixaArquivo (url, arquivoABaixar: string; aceitaErro: boolean): boolean;

const
    CRLF = #$0d + #$0a;

var
    statusUltIO: integer;

{--------------------------------------------------------}
{                  Traduz a url
{--------------------------------------------------------}

function traduzURL (url: string; out protocolo, nomeComput: string;
                                 out porta: integer;
                                 out recurso: string): boolean;
var
    i: integer;
    erro: integer;
    s: string;

begin
    traduzURL := false;

    url := trim(url);
    i := pos('://' , url);

    if i = 0 then
        protocolo := 'http'
    else
    begin
        protocolo := copy(url, 1, (i-1));
        url := copy(url, (i+3), 999);
    end;
        protocolo := upperCase(protocolo);

        i := pos('/', url);
        if i = 0 then
            i := pos('?', url);

        if i = 0 then
            begin
                recurso := '';
                nomeComput := url;
            end
        else
            begin
                nomeComput := copy(url, 1, (i-1));
                recurso := copy(url, i, 999);
                if copy(recurso, 1,1) = '?' then
                    recurso := '/' + recurso;
            end;

        i := pos(':', nomeComput);
        if i <> 0 then
            begin
                s := copy(nomeComput, (i+1), 999);
                nomeComput := copy(nomeComput, 1, i-1);
                val (s, porta, erro);
                if erro <> 0 then
                    exit;
            end
        else
            if protocolo = 'HTTPS' then
                porta := 443
            else
                porta := 80;

        if recurso = '' then
            recurso := '/';

        i := pos('?', recurso);
        if i <> 0 then
            recurso := copy(recurso, 1,i) + copy(recurso, i+1,999);

        traduzURL := true;
end;


{--------------------------------------------------------}
{                  Pega o cabeçalho
{--------------------------------------------------------}

function pegaHeader (protocolo, nomeComput: string; porta: integer; recurso: string;
                         out codRetorno: integer;
                         out novaUrl: string;
                         out pbuf: PbufRede;
                         out soquete: integer): boolean;

var s: string;
    i: integer;
    header: TStringList;
    aEnviar: string;

begin
    pegaHeader := false;
    codRetorno := 500;
    novaUrl := '';

    if ansiUpperCase(protocolo) = 'HTTPS' then
        soquete := abreConexaoSSL (nomeComput, porta)
    else
        soquete := abreConexao (nomeComput, porta);

    if soquete < 0 then
       begin
           exit;
       end;

    aEnviar :=
        'GET ' + recurso + ' HTTP/1.0' + CRLF +
        'UA-CPU: x86' + CRLF +
        'Connection: Close' + CRLF +
        'Accept-Language: pt-br' + CRLF +
        'User-Agent: Webvox 2.4' + CRLF +
        'Host: ' + nomeComput + CRLF +
        CRLF;

    statusUltIO := ord (writeRede(soquete, aEnviar));

    pBuf := inicBufRede (soquete);

    header := TStringList.Create;
    repeat
        statusUltIO := ord (not readlnBufRede (pbuf, s, 30));
        header.add(s);
    until (statusUltIO <> 0) or (s = '');

    if copy(header[0], 1,4) <> 'HTTP' then   // erro no servidor
        begin
                sintWriteln ('Erro no servidor');
                header.Free;
                fechaConexao(soquete);
                fimBufRede(pbuf);
                pbuf := NIL;
                exit;
            end;

        s := header[0];
        i := pos(' ', s);
        codRetorno := StrToInt(copy(s, i+1, 3));

        if (codRetorno div 100) = 3  then  // relocators
            begin
                // pega o location
                for i := 0 to (header.Count-1) do
                    begin
                        if pos('LOCATION:', upperCase(header[i])) = 1 then
                            novaUrl := trim(copy(header[i], 10 , 999));
                    end;
                fimBufRede (pbuf);
                fechaConexao(soquete);
            end;

        header.Free;
        pegaHeader := true;
    end;

{--------------------------------------------------------}
{                  abre a url
{--------------------------------------------------------}

function abreUrl(url: string; out pBuf: pbufrede; out soquete: integer): boolean;
var
    protocolo, nomeComput, recurso: string;
    porta: integer;
    novaUrl: string;
    codRetorno: integer;

begin
    abreUrl := false;
    novaUrl := url;

    codRetorno := 300;
    while (codRetorno div 100) = 3  do
        begin
            if not traduzURL (novaUrl, protocolo, nomeComput, porta, recurso) then
                exit;

            if not pegaHeader (protocolo, nomeComput, porta, recurso,
                                   codRetorno, novaUrl, pbuf, soquete) then
                    exit;
       end;

    abreUrl := true;
end;

{--------------------------------------------------------}
{          Copia conteúdo da url para um arquivo
{--------------------------------------------------------}

function copiaURLparaArquivo (pbuf: PbufRede; soquete: integer;
                              nomeArqBaixar: string): boolean;
const
    TAMBUF = 8192;
var
    arq: file;
    lidoOk, clecando: boolean;
    buf: packed array [0..TAMBUF-1] of char;
    ncbuf: integer;
    c: char;
    escritos: integer;
begin
     copiaURLparaArquivo := false;
     statusUltIO := 0;
     ncbuf := 0;
     clecando := True;

     assign (arq, nomeArqBaixar);
     {$I-}  rewrite (arq, 1);  {$I+}
     if ioresult <> 0 then
         begin
             statusUltIO := 1;
             mensagem('JOERROES', 1); // Erro de escrita
             exit;
         end;
    repeat
        lidoOk := leCaracBufRede(pbuf, c);
        if lidoOk then
            begin
                buf[ncbuf] := c;
                ncbuf := ncbuf + 1;
            end;

        if ncbuf >= TAMBUF then
            begin
                if clecando then
                    sintClek;
                if keypressed then
                    if readkey = ' ' then clecando := not clecando;
                escritos := 0;
                blockWrite (arq, buf, ncbuf, escritos);
                if escritos <> ncbuf then
                    begin
                        mensagem('JOERROES', 1); // Erro de escrita
                        statusUltIO := 1;
                        lidoOk := false;
                    end;
                ncbuf := 0;
            end;
    until not lidoOk;

    limpaBufTec;
    if ncbuf <> 0 then
        begin
            blockWrite (arq, buf, ncbuf, escritos);
            if escritos <> ncbuf then
                begin
                    mensagem('JOERROES', 1); // Erro de escrita
                    statusUltIO := 1;
                end;
        end;

    closeFile (arq);
    copiaURLparaArquivo := true;
end;

{--------------------------------------------------------}

var
    pbuf: PbufRede;
    soquete: integer;

label erro;
begin
    result := false;

    if abreUrl(url, pbuf, soquete) then
        begin
          if copiaURLparaArquivo (pbuf, soquete, arquivoABaixar) or aceitaErro then
                result := true;
          fimBufRede(pbuf);
          fechaConexao(soquete);
        end;
end;

{--------------------------------------------------------}
{               Faz o download na forma de lista
{--------------------------------------------------------}

function baixaHtml(url: string; listaHtml: TStringList): boolean;
var
    arqTemp: string;
begin
    result := true;

    abreWinSock;
    arqTemp := dirBaseJogos+'\jogos.$$$';

    if not baixaArquivo (url, arqTemp, false) then
        begin
            mensagem('JOBAERRO', 1); //'Erro ao tentar baixar o Jogo.'
            result := false;
            exit;
        end;

    listaHtml.loadFromFile(arqTemp);
    deleteFile(pchar(arqTemp));
    fechaWinSock;
end;

{---------------------------------------------------------------}
{               Ajusta exibição de uma linha trocando caracteres
{---------------------------------------------------------------}

function ajustaParaExibir(linha: string; trocaSublinhado: boolean; trocaAcento: boolean): string;
begin
    if trocaSublinhado then
        linha := stringReplace(linha, '_', ' ', [rfReplaceAll, rfIgnoreCase]);
    linha := decodeUrl(linha);
    if trocaAcento then   //Jogos enviados usando o script de upload já vem com a acentuação correta
        linha := utf8ToAnsi(linha);
    result := linha;
end;

{---------------------------------------------------------------}
{               Ajusta uma linha da lista retirando tags HTML
{---------------------------------------------------------------}

function substitui(linha: string): string;
var i: integer;
begin
    for i := 1 to 7 do
        delete (linha, 1, pos('"', linha));
    delete (linha, pos('"', linha), 9999);
    delete (linha, pos('/', linha), 1);   //Caracter barra ao final da linha no caso de diretórios de usuários
    result := linha;
end;

{---------------------------------------------------------------------}
{               Transforma diretório do servidor em uma lista de nomes
{---------------------------------------------------------------------}

procedure obterLista(dirDownload: string; lista: TStringList);
var
    listaDownload: TStringList;
    i: integer;
    linha: string;

begin
    listaDownload := TStringList.Create;
    baixaHtml(dirDownload, listaDownload);

    lista.Clear;
    for i := 11 to listaDownload.Count-5 do
        begin
            linha := substitui (listaDownload[i]);
            if (pos ('.php', linha) = 0) and
                (pos('.txt', linha) = 0) and
                (pos('.jpg', linha) = 0) then
                    lista.add (linha);
        end;

    listaDownload.Free;
end;

{--------------------------------------------------------}
{               Obtém lista de usuários
{--------------------------------------------------------}

procedure obterListaUsuarios(dirDownload: string; listaDeUsuarios: TStringList);
begin
    obterLista(dirDOwnload, listaDeUsuarios);
end;

{------------------------------------------------------------------------}
{          Obtém uma lista de jogos a partir do diretório do servidor
{------------------------------------------------------------------------}

procedure obterListaJogos(dirDownload: string; listaDeJogos: TStringList);
begin
    obterLista(dirDownload, listaDeJogos);
end;

{--------------------------------------------------------}
{               Seleciona um item de uma lista
{--------------------------------------------------------}

function escolhe(lista: TStringList; normalizarAcento: boolean): string;
var
    opcao: integer;
    tam, i: integer;
begin
    result := '';

    garanteEspacoTela (7);
    tam:=60;
    popupMenuCria(wherex, wherey, tam, 26-wherey, RED);

    for i := 0 to lista.Count-1 do
        popupMenuAdiciona('', ajustaParaExibir(lista[i], true, normalizarAcento));

    opcao := popupMenuSeleciona;
    if opcao >= 1 then
        result := lista[opcao-1];   //TStringList é baseada em 0
end;

{--------------------------------------------------------}
{                 Descomprimir o arquivo zip
{--------------------------------------------------------}

procedure descompacta(arquivo:string);
var
    extrator: String;
begin
    extrator := '"' + obtemDirDosvox + '\unzip.exe" -o';
    executaProgEX (extrator, '.', '"'+arquivo+'"', SW_SHOWMINIMIZED);
    delay(1000);
    esperaProgVoltar;
end;

{--------------------------------------------------------}
{               Faz o download de um jogo
{--------------------------------------------------------}

procedure fazDownloadJogo(dirDownload, nomeJogo: string);
var
    url: string;
    nomeArqGravar, caminhoArq: string;

begin
    abreWinSock;
    nomeArqGravar := nomeJogo;
    nomeArqGravar := ajustaParaExibir(nomeArqGravar, false, false);   //Mantém nome íntegro
    mensagem ('JOBABXND', 0);   //'Baixando o jogo: '
    sintWriteln(nomeArqGravar);

    //IMPORTANTE!
    //A variável nomeJogo gerada nesta rotina é enviada para a function baixaArquivo já convertida para url
    //não sendo necessária posterior conversão
    //Certificar-se de que o nome do jogo venha exatamente do html e não seja processado antes
    //Qualquer processamento realizado é apenas para exibição para os usuários
    url := dirDownload+nomeJogo;
    caminhoArq := dirBaseJogos+'\'+nomeArqGravar;

    if not baixaArquivo (url, caminhoArq, false) then
        mensagem ('JOBAERRO', 1) // 'Erro ao tentar baixar o Jogo. Por favor, tente novamente.'
    else
        begin
            mensagem ('JOEXTARQ', 1); //'Extraindo o arquivo'
            descompacta(nomeArqGravar);   //Garante abrir arquivos com espaço em branco no nome
            mensagem ('JOBA_BXD', 1); //'O seu jogo foi baixado com sucesso.'
    deleteFile(PChar(caminhoArq));
        end;

    fechaWinSock;
end;

{--------------------------------------------------------}
{                 Escolhe categoria do jogo
{--------------------------------------------------------}

procedure selCategoria;
var
    c: char;
    n: integer;
    opcao:string;
begin
    Cabecalho;
    gotoxy (1, 4);

    c := pergunta ('JOBACATE', 0, BLUE);  {'Opção: Olimpo, Gaia, Caos? '}

    if c = ESC then
        begin
            mensagem('JODESIST',3);  {'Desistiu'}
            exit;
        end;
    if c = #0 then
        begin
            popupMenuCria (wherex, wherey, 12, 3, MAGENTA);
            MenuAdiciona('JOOLIMPO'); // 'olimpo'
            MenuAdiciona('JOGAIA');   // 'gaia'
            MenuAdiciona('JOCAOS');   // 'caos'
            limpaBufTec;

            n := popupMenuSeleciona;

            case n of
                1:  opcao := pegaTextoMensagem('JOOLIMPO'); // 'olimpo'
                2:  opcao := pegaTextoMensagem('JOGAIA');   // 'gaia'
                3:  opcao := pegaTextoMensagem('JOCAOS');   // 'caos'
            else
                mensagem('JODESIST',3);  {'Desistiu'}
                exit;
            end;
        end

      else
        begin
            case upcase(c) of
                'O':  opcao := pegaTextoMensagem('JOOLIMPO');   // 'olimpo'
                'G':  opcao := pegaTextoMensagem('JOGAIA');     // 'gaia'
                'C':  opcao := pegaTextoMensagem('JOCAOS');     // 'caos'
            else
                mensagem('JODESIST',3);  {'Desistiu'}
                exit;
            end;
        end;
     baixaJogo(opcao);
end;

{--------------------------------------------------------}
{                 Cabecalho do programa
{--------------------------------------------------------}

procedure Cabecalho;
begin
    clrscr;
    setWindowTitle('Jogavox');
    textBackground (BLUE);
    limpaBufTec;

    write(pegaTextoMensagem('JOINIC'));     {'Jogavox - editor de jogos educacionais'}
    write (' - ');
    write(pegaTextoMensagem('JOVERSAO'));   {'Versão '}
    writeln (versao);
    textBackground (BLACK);
    writeln;
end;

{--------------------------------------------------------}
{                 Controle geral do download
{--------------------------------------------------------}

function baixaJogo(categoria:string): boolean;
var
    dirDownload: string;
    usuario: string;
    listaDeJogos, listaDeUsuarios:TStringList;
    jogoABaixar: string;

begin
    baixaJogo := true;
    dirDownload := url_jogos+categoria + '/';
    if categoria = 'Caos' then   //Processa usuários somente na categoria Caos
        begin
            listaDeUsuarios := TStringList.Create;
            obterListaUsuarios(dirDownload, listaDeUsuarios);

            mensagem ('JOESCUSE', 1);  {'Escolha um dos seguintes usuários com as setas'}
            usuario := escolhe(listaDeUsuarios, false);   //Não é necessário ajustar acentos aqui
            listaDeUsuarios.Free;
            writeln(usuario);
            if usuario = '' then
                begin
                    mensagem('JODESIST',3);  {'Desistiu'}
                    exit;
                end;
            dirDownload := dirDownload + usuario + '/';
        end;

    //Prepara e exibe a lista de jogos independente de haver ou não usuário
    listaDeJogos := TStringList.Create;
    obterListaJogos(dirDownload, listaDeJogos);

    mensagem ('JOESCJOG', 1);  {'Escolha um dos seguintes jogos com as setas'}
    if usuario = '' then   //Acerta acentos caso não venha usuário
        jogoABaixar := escolhe(listaDeJogos, true)
    else   //Não é necessário ajustar acentos se haver usuário
        jogoABaixar := escolhe(listaDeJogos, false);
            if jogoABaixar = '' then
                begin
                    mensagem('JODESIST',3);  {'Desistiu'}
                    exit;
                end;
    listaDeJogos.Free;

    //Baixa o jogo selecionado
    fazDownloadJogo(dirDownload, jogoABaixar);
end;

end.
