{--------------------------------------------------------}
{
{     Rotinas de atualização do DOSVOX
{
{     Autores:  José Antonio Borges
{               Júlio Tadeu Carvalho da Silveira
{               Marcolino Matheus de Souza Nascimento
{
{     Em junho/julho de 2015
{
{    Atualizado por Neno Albernaz e Patrick Barboza
{
{    Em Agosto/2021
{
{    Atualizado novamente por Patrick Barboza
{
{    Em Novembro/2024
{
{--------------------------------------------------------}

unit dosupdat;

interface
uses
    windows, sysUtils, classes,
    dvcrt, dvwin,
    dvexec, dvinet, dvForm, dvarq,
    dosVars, dosgeral, dosmsg,
    DOSPROC,
    synacode,
    minireg;

procedure configAtualiza;
function mudaArrobas (s, dirOriginal: string): string;
procedure atualizaAtu (nomeArq: string; perguntaSeSobrescreve: boolean);

implementation

uses
    dosCopia;

const
    CRLF = #$0d + #$0a;

const
    SearchTree    = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\';
    URL_UPGRADE   = 'https://intervox.nce.ufrj.br/upgrade';
    URL_PROGRAMAS = 'https://intervox.nce.ufrj.br/upgrade/programas.htm';

var
    statusUltIO: integer;
    pbuf: PbufRede;
    soquete: integer;
    atualizandoDosvox, naoDescompactarZip: boolean;

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
            recurso := copy(recurso, 1,i) + EncodeURL(copy(recurso, i+1,999));

        traduzURL := true;
end;

{--------------------------------------------------------}
{                  Pega o cabeçalho
{--------------------------------------------------------}

function pegaHeader (protocolo, nomeComput: string; porta: integer; recurso: string;
                         out codRetorno: integer;
                         out novaUrl: string;
                         out pbuf: PbufRede;
                         out soquete, tamArq: integer): boolean;

var s,aux: string;
    i, l: integer;
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
        'GET ' + EncodeURL(recurso) + ' HTTP/1.0' + CRLF +
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
                mensagem('DV_ERRSRV',1); {'Erro na comunicação com o site de atualização do DosVox'}
                header.Free;
                fechaConexao(soquete);
                fimBufRede(pbuf);
                pbuf := NIL;
                exit;
            end;

        s := header[0];
        i := pos(' ', s);
        codRetorno := StrToInt(copy(s, i+1, 3));

        tamArq :=0;
        if codRetorno = 200 then
            begin
                for l := 1 to header.Count-1 do
                    if copy (trim(ansiUpperCase(header[l])), 1, 14) = 'CONTENT-LENGTH' then
                        begin
                            aux := header[l];
                            delete(aux,1,pos(':',aux));
                            aux := trim(aux);
                            tamArq := strToInt(aux);
                            break;
                        end;
            end;

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

function abreUrl(url: string; out pBuf: pbufrede; out soquete, tamArq: integer): boolean;
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
                                   codRetorno, novaUrl, pbuf, soquete, tamArq) then
                    exit;
       end;

    abreUrl := codRetorno = 200;
end;

{--------------------------------------------------------}
{          Copia conteúdo da url para um arquivo
{--------------------------------------------------------}

function copiaURLparaArquivo (pbuf: PbufRede; soquete: integer;
                              nomeArqBaixar: string; tamArq: Integer): boolean;
const
    TAMBUF = 8192;
var
    arq: file;
    lidoOk: boolean;
    buf: packed array [0..TAMBUF-1] of char;
    ncbuf: integer;
    c: char;
    escritos, totalEscritos: integer;
label cancela;
begin
     copiaURLparaArquivo := false;
     statusUltIO := 0;
     ncbuf := 0;
     totalEscritos := 0;

     assign (arq, nomeArqBaixar);
     {$I-}  rewrite (arq, 1);  {$I+}
     if ioresult <> 0 then
         begin
             statusUltIO := 1;
             mensagem('DV_ERRWAR',1); {'Erro de escrita do arquivo'}
             exit;
         end;

    inicializaProgresso (35, 20, 500, copiaFazSintclek, instrumentoEmCopiaDeArquivo);
    repeat
        lidoOk := leCaracBufRede(pbuf, c);
        if lidoOk then
            begin
                buf[ncbuf] := c;
                ncbuf := ncbuf + 1;
            end;

        if ncbuf >= TAMBUF then
            begin
                if not mostraProgresso (totalEscritos, tamArq) then
                    begin
                        finalizaProgresso;
                        goto cancela;
                    end;
                escritos := 0;
                blockWrite (arq, buf, ncbuf, escritos);
                if escritos <> ncbuf then
                    begin
                        mensagem('DV_ERRWAR',1); {'Erro de escrita do arquivo'}
                        statusUltIO := 1;
                        lidoOk := false;
                    end;
                ncbuf := 0;
                totalEscritos := totalEscritos + escritos;
            end;
    until not lidoOk;
    finalizaProgresso;

    limpaBuf;
    if ncbuf <> 0 then
        begin
            blockWrite (arq, buf, ncbuf, escritos);
            if escritos <> ncbuf then
                begin
                    mensagem('DV_ERRWAR',1); {'Erro de escrita do arquivo'}
                    statusUltIO := 1;
                end;
        end;

    closeFile (arq);
    copiaURLparaArquivo := true;
    exit;

cancela:
    mensagem ('DV_DESIST', 2);   {Desistiu}
    closeFile (arq);
    {$I-} DeleteFile(nomeArqBaixar); {$I+}
    ioresult;
end;

{--------------------------------------------------------}
{               Faz o download de um arquivo
{--------------------------------------------------------}

function baixaArquivo (url, arquivoABaixar: string; aceitaErro: boolean): boolean;
var
    tamArq: integer;

label erro;
begin
    result := false;

   if not abreWinSock then
        begin
            mensagem('DV_INTOUT',1); { A internet está fora do ar}
            exit;
        end;

    if abreUrl(url, pbuf, soquete, tamArq) then
        begin
          if copiaURLparaArquivo (pbuf, soquete, arquivoABaixar, tamArq) or aceitaErro then
            begin
                result := true;
            end;
          fimBufRede(pbuf);
          fechaConexao(soquete);
        end;

    fechaWinSock;
end;

{--------------------------------------------------------}
{            Descobre diretório de trabalho
{--------------------------------------------------------}

function GetTempDir: string;
var
  Buffer: array[0..512] of Char;

begin
    GetTempPath(512,Buffer);
    Result := StrPas(Buffer);
end;

{--------------------------------------------------------}
{            Faz download da pagina de upgrades
{--------------------------------------------------------}

function fazDownloadHtml: boolean;
var url: string;
begin
    url := sintAmbiente ('DOSVOX', 'URL_PROGRAMAS', URL_PROGRAMAS);

    if baixaArquivo (url, gettempdir+'lista.txt', false) then
        result := true
    else
        begin
            mensagem('DV_ACBLOQ',1); {'Acesso ao site de atualização do DosVox está bloqueado.'}
            result := false;
        end
end;

{--------------------------------------------------------}
{       Descompacta arquivo .ZIP
{--------------------------------------------------------}

function descompactaZip (nomeZip: string; apagaAoFinal: boolean): boolean;
var
    extrator: String;
    dirDosvox,dirAtual: string;
label
    descompactou;
begin
    result := false;  // por prevenção, assumimos uma probabilidade alta de erro

    dirDosvox := pegaDirDosvox;

    if pos('\',nomeZip)=0 then
        begin
            getDir(0, dirAtual);
            if dirAtual[length(dirAtual)] ='\' then
                delete(dirAtual,length(dirAtual),1);
            nomeZip := dirAtual+'\'+nomeZip;
        end;

    if ansiUpperCase(extractFileExt(nomeZip)) <> '.ZIP' then
        begin
            mensagem('DV_ZIPNEC', 1);   {'Nenhum arquivo .ZIP foi selecionado.'}
            exit;
        end;

    if not FileExists(nomeZip) then
        begin
            mensagem('DV_ARQNAOEX', 1);   {'Arquivo não existe, sinto muito.'}
            exit;
        end;

    limpabuf;
    mensagem ('DV_UMMOMENTO', 1);    {'Um momento...'}

    extrator := '"' + dirdosvox + 'unzip.exe" -o';
    if executaProgEx (extrator, dirdosvox, nomeZip, SW_SHOWMINIMIZED) > 32 then {> 32 significa execução bem sucedida.}
        goto descompactou;

    if executaProgEx ('"unzip.exe" -o', dirdosvox, nomeZip, SW_SHOWMINIMIZED) > 32 then {> 32 significa execução bem sucedida.}
        goto descompactou;

    mensagem('DV_ERRODC',1); {Descompactador não pôde ser executado.}
    exit;

descompactou:
    esperaProgAtivar;
    esperaProgVoltar;
    limpabuf;
    mensagem('DV_EXTSCS', 1);   {'Arquivo extraido com sucesso.'}
    result := true;

    if apagaAoFinal then
        DeleteFile(Pchar(nomeZip));
end;

{--------------------------------------------------------}
{                  Limpa tags html do arquivo
{--------------------------------------------------------}

function substitui(linha: string): string;
begin
    linha := StringReplace(linha, '</tr>', ^m^j, [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, '</td>', '' , [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, '<tr><td valign="top"><img src=', '', [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, '<tr>', '', [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, '&nbsp;', '', [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, '<td>', '', [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, '<td align="right">', '', [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, '<tr><td valign="top">', '', [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, '<a href=', '', [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, '<img src=', '', [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, 'alt="[   ]">', '', [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, '</a>', '', [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, '<th colspan="5"><hr></th>', '', [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, '</body></html>', '', [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, '<a href=', '', [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, '<hr>', '', [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, '<p>', '', [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, '<b>', '', [rfReplaceAll, rfIgnoreCase]);
    linha := StringReplace(linha, '</b>', '', [rfReplaceAll, rfIgnoreCase]);

    result := linha;
end;

{--------------------------------------------------------}
{       Quebra a palavra quando '">' for encontrado
{--------------------------------------------------------}

procedure quebra(palavra:string; var url,nomeProg:String);
var
    p:integer;
begin
    p := pos('>',palavra);
    url := copy(palavra,2,p-3);
    nomeProg := copy(palavra,p+1,999);
end;

{--------------------------------------------------------}
{                  Abre o arquivo txt
{--------------------------------------------------------}

function abreArquivo(endereco:string):TStringList;
var
    linha: string;
    arquivo: text;
    lista: TStringList;

begin
    AssignFile(arquivo,endereco);
    {$I-}
    Reset(arquivo);
    {$I+}

    if ioresult <> 0 then
        begin
            mensagem('DV_GEROPC',1); {'Erro ao gerar a lista de opções.'}
            halt;
        end;

    lista := TStringList.Create;
    while (not eof(arquivo)) do
         begin
           readln(arquivo,linha);
           linha := trim(linha);
           if linha = '<table border=1>' then
                break;
         end;

    while (not eof(arquivo)) do
         begin
           readln(arquivo,linha);
           linha := trim(linha);
           if linha = '</tr>' then
                break;

         end;

    while (not eof(arquivo)) do
         begin
           readln(arquivo,linha);
           linha := trim(substitui (linha));

                if (linha = 'OK') or (linha = 'Obsoleto')
                or (linha = 'sem gravação') or (linha = 'OK - sem gravação')
                or (linha = 'Preliminar') or (linha = 'Beta 3') then
                    begin
                        lista.add (linha);
                        lista.add('');
                        continue;
                    end;

                if linha = '' then
                    continue;
                if linha = '</table>' then
                    break
                else
                    lista.add (linha);
         end;


    closefile(arquivo);
    result:=lista;

end;

{--------------------------------------------------------}
{       Abre arquivo de txt sem limpar
{--------------------------------------------------------}

procedure abreTXT(endereco:string; var lista: TStringList);
var
    linha: string;
    arquivo: text;

begin
    AssignFile(arquivo,endereco);
    {$I-}
    Reset(arquivo);
    {$I+}

    if ioresult <> 0 then
        begin
            mensagem('DV_GEROPC',1); {'Erro ao gerar a lista de opções.'}
            halt;
        end;

    while (not eof(arquivo)) do
         begin
           readln(arquivo,linha);
           linha := trim(linha);
           lista.add (linha);
         end;

    closefile(arquivo);
end;

{--------------------------------------------------------}
{                  Cria lista.txt
{--------------------------------------------------------}

procedure ajustaLista(lista:TStringList);

begin
    lista.SaveToFile(gettempdir+'\lista.txt');
    lista.LoadFromFile(gettempdir+'\lista.txt');
end;

{--------------------------------------------------------}
{ Verifica se existe alguma janela referente ao programa
{--------------------------------------------------------}

function buscaProgAtivo(nomeProg: String):boolean;
var
    currWnd: hwnd;
    txt: array [0..144] of char;
    titulo: string;

begin
    CurrWnd := GetWindow(crtWindow, GW_HWNDFIRST);
    result := False;

    While CurrWnd <> 0 do
        begin
            if IsWindowEnabled (currWnd) and
               IsWindowVisible (currWnd) then
            begin
                GetWindowText(CurrWnd, txt, 144);
                titulo := strPas (txt);

                if (pos(upperCase('\'+nomeProg+'.EXE'), upperCase(titulo)) <> 0) or
                   (pos(upperCase(' '+nomeProg+' '), upperCase(' '+titulo+' ')) <> 0) then
                begin
                    result := True;
                    exit;
                end;
            end;
            CurrWnd := GetWindow(CurrWnd, GW_HWNDNEXT);
        end;
end;

{--------------------------------------------------------}
{               Renomeia o dosvox.exe para dosvox_antigo.exe ou o contrário
{--------------------------------------------------------}

function renomeiaDosvoxExe (dirDosvox: string; paraAntigo: boolean): boolean;
var
    nomeProg, mudarPara: string;
    arq: file;
begin
    if dirDosvox[length(dirDosvox)]=  '\' then delete(dirDosvox, length(dirDosvox), 1);

    if paraAntigo then
        begin
            deleteFile (dirDosvox + '\dosvox_antigo.exe');
            nomeProg := dirDosvox + '\dosvox.exe';
            mudarPara := dirDosvox + '\dosvox_antigo.exe';
        end
    else
        begin
            nomeProg := dirDosvox + '\dosvox_antigo.exe';
            mudarPara := dirDosvox + '\dosvox.exe';
    end;

    assignFile (arq, nomeProg);
    {$I-} rename (arq, mudarPara);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('DV_PROTEG', 0);      { 'Arquivo está protegido para regravação' }
            write ('; ');
            mensagem ('DV_OU', 1); {'ou'}
            mensagem ('DV_ARQNAOEX', 1);      {'Arquivo não existe, sinto muito.'}
            result := false;
        end
    else
        result := true;
end;

{--------------------------------------------------------}
{               Executa o script ligaDosvox.pro para reiniciar o Dosvox
{--------------------------------------------------------}

procedure executaDosvoxNovo (dirDosvox: string);
begin
    if dirDosvox[length(dirDosvox)]=  '\' then delete(dirDosvox, length(dirDosvox), 1);

    if (not FileExists(dirDosvox+'\LigaDosvox.pro')) or (not FileExists(dirDosvox+'\sc.exe')) then
        mensagem ('DV_REINIC', 1)  {'Por favor, feche o Dosvox e abra novamente'}
    else
    if executaProg(dirDosvox + '\sc.exe', dirdosvox, dirDosvox + '\ligaDosvox.pro') > 32 then {> 32 significa execução bem sucedida.}
        begin
            SintFim;
            ReleaseMutex (hMutex);
            doneWinCrt;
        end;
end;

{--------------------------------------------------------}
{       Testa se dosvox.exe existe, caso negativo retorna o dosvox_antigo.exe para dosvox.exe
{--------------------------------------------------------}

procedure reiniciaDosvoxOuRetrornaAntigo (dirDosvox: string);
begin
    if not FileExists(dirDosvox + 'dosvox.exe') then
        begin
            renomeiaDosvoxExe (dirDosvox, false); //Troca dosvox_antigo.exe para dosvox.exe
            mensagem ('DV_ERRARQ_02', 0);    {'Erro: arquivo não encontrado.'}
            write (' ');
            sintWriteln (dirDosvox + 'dosvox.exe');
        end
    else
        executaDosvoxNovo (dirDosvox);
end;

{--------------------------------------------------------}
{               Faz o download da atualização
{--------------------------------------------------------}

function fazDownload(arqBaixar,nomeProg: String): boolean;
var
    url, arquivoAGravar: string;
    dirDosvox: string;
    c:char;

begin
    result := false;  // por prevenção, assumimos uma probabilidade alta de erro

    dirDosvox := pegaDirDosvox;

    url := sintAmbiente ('DOSVOX', 'URL_UPGRADE', URL_UPGRADE);
    url := url + '/' + arqBaixar;

    arquivoAGravar := dirdosvox + nomeProg + '.zip';

    atualizandoDosvox := pos('DOSVOX', uppercase(nomeProg)) <> 0;

    if (not atualizandoDosvox) and (not naoDescompactarZip) and buscaProgAtivo(nomeProg) then
        begin
            mensagem('DV_PROGEX',1); {'O programa está em execução. Não posso atualizar' }
            exit;
        end;

    mensagem('DV_BAIXND',1); {'Baixando...'  }
    if not baixaArquivo (url, arquivoAGravar, false) then
        begin
            mensagem('DV_ERRBXR',1); {'Erro ao baixar o arquivo.'}
            exit
        end
    else
        begin
            if (not atualizandoDosvox) and (not naoDescompactarZip) and buscaProgAtivo(nomeProg) then
                begin
                    mensagem('DV_PEXTE1',1); {'O programa está em execução.'}
                    mensagem('DV_PEXTE2',1); {'Por favor feche o programa e aperte Enter ou Esc para cancelar.'}
                    repeat
                        c := readkey;
                    until (c = #13) or (C = #27);
                    exit;
                end
            else
            if naoDescompactarZip then
                begin
                    mensagem('DV_OK',1); {'Ok'}
                    result := true;
                end
            else
                begin
                    if atualizandoDosvox and
                       (not renomeiaDosvoxExe (dirDosvox, true)) then // Renomeia dosvox.exe para dosvox_antigo.exe
                        exit;
                    if descompactaZip(dirDosVox+nomeProg+'.zip',True) then
                        begin
                            limpaBufTec;
                            mensagem('DV_PROGAT',1); {'O programa foi atualizado.'}
                            if sintFalando then waitMessage;
                            if atualizandoDosvox then reiniciaDosvoxOuRetrornaAntigo (dirDosvox);
                            result := true;
                        end
                    else //Não descompactou
                        if atualizandoDosvox then
                            renomeiaDosvoxExe (dirDosvox, false); // Renomeia dosvox_antigo.exe para dosvox.exe
                end;
        end;
end;

{--------------------------------------------------------}
{       Gera lista de arquivos.
{--------------------------------------------------------}

function geraListArq: TStringList;
type
    TArqInfo = record
        nome: string;
        data: string;
        tamanho: string;
    end;
var
    arqRes: TSearchRec;
    listArq: TStringList;
    dirDosvox: String;

begin
    dirDosvox := pegaDirDosvox;

    listArq := TStringList.Create;
    if FindFirst(dirdosvox+'\*.exe', faAnyFile, arqRes) = 0 then
    begin
        repeat
            listArq.Add(arqRes.Name);
            listArq.Add(DateTimeToStr(FileDateToDateTime(arqRes.time)));
            listArq.Add(inttoStr(arqRes.Size));
        until FindNext(arqRes) <> 0;
    Sysutils.FindClose(arqRes);
    end;
    result :=listArq;
end;

{--------------------------------------------------------}
{        Garante o alinhamento do folheamento
{--------------------------------------------------------}

function alinhaCampos(nomeArq: String): String;
var
    i:integer;
begin
    i := length(nomeArq);
    while i<15 do
        begin
            nomeArq := nomeArq+' ';
            i := i+1;
        end;
    result := nomeArq;
end;

{--------------------------------------------------------}
{        Baixa o programa a partir do nome
{--------------------------------------------------------}

procedure baixaProg (nomeProg: string);
var
    c: char;
    arqBaixar: String;
begin
    limpaBaixo(5);
    nomeProg := trim (nomeProg);

    if not naoDescompactarZip then
        begin
            mensagem('DV_ATUPRO',0);     {'Deseja atualizar o programa: '}
            sintwrite(nomeProg);
            mensagem('DV_SIMNAO',0);    { ' (S/N)? ' }

            c := popupMenuPorLetra('SN');

            if c <> 'S' then
                begin
                    mensagem ('DV_DESIST', 2);     {'Desistiu...'}
                    exit;
                end;
        end;

    writeln;
    arqBaixar := 'download/'+nomeProg+'.zip';
    fazDownload(arqBaixar,nomeProg);
end;

{--------------------------------------------------------}
{   pega o nome do programa do site de atualizações
{--------------------------------------------------------}

function pegaDaInternetPelasSetas: string;
var
    i, n2:integer;
    arqBaixar, nomeProg: String;
    lista: TStringList;

begin
    result := '';   { pessimista, não retornou nada }
    fazDownloadHtml;

    lista:= abreArquivo(gettempdir + 'lista.txt');
    ajustaLista(lista);

    popupMenuCria(wherex, wherey, 40, 23-wherey, BLACK);
    i := 0;
    while i < lista.Count do
        begin
            quebra(lista[i],arqBaixar,nomeProg);
            popupMenuAdiciona('', alinhaCampos(nomeProg)+'- Em: '+lista[i+3]);
            i := i+6;
        end;

    n2 := popupMenuSeleciona;
    if n2 > 0 then
        begin
            limpaBaixo (5);
            quebra(lista[(n2-1)*6],arqBaixar,nomeProg);
            result := lowercase(NomeProg);
        end;

    lista.Free;
end;

{--------------------------------------------------------}
{   pega o nome do programa desatualizado pelas setas
{--------------------------------------------------------}

function pegaDesatualizadoPelasSetas: string;

var
    n2, i, j, p:integer;
    lista, listArq,listaDesatualizados: TStringList;
    dataLocal, dataServidor, url, nomeArqLocal, nomeArqServidor: string;
    nomeProg: String;

begin

    result := '';   { pessimista, não retornou nada }

    fazDownloadHtml;
    lista:= abreArquivo(gettempdir + 'lista.txt');
    ajustaLista(lista);

    listArq := geraListArq;

    popupMenuCria (wherex, wherey, 80, 23-wherey, BLACK);

    listaDesatualizados := TStringList.Create;
    i := 0;
    while i < lista.Count do
        begin
            j := 0;
            while j < listArq.Count do
                begin
                    p := pos('.',listArq[j]);
                    nomeArqLocal := copy(listArq[j],0,p-1);

                    quebra(lista[i],url,nomeArqServidor);

                    if ansiUpperCase(nomeArqLocal) = ansiUpperCase(nomeArqServidor) then
                        begin
                            p := pos(':',listArq[j+1]);
                            dataLocal := trim(copy(listArq[j+1],0,p-3));
                            dataServidor := trim(lista[i+3]);

                            if (StrToDate(dataLocal) < StrToDate(dataServidor)) then
                                begin
                                    listaDesatualizados.add(nomeArqLocal);
                                    popupMenuAdiciona('', alinhaCampos(nomeArqLocal)+
                                         '- Em: '+dataLocal+' [Atualização:'+dataServidor+']' );
                                end;
                        end;
                    j := j+3
                end;
            i :=i+6
        end;

    if listaDesatualizados.Count = 0 then
        begin
            mensagem ('DV_NENHUM',2);  { 'Todos os arquivos estão atualizados.' }
            result := '';
        end
    else
        begin
            n2  := popupMenuSeleciona;
            if n2 > 0 then
                begin
                    limpaBaixo (5);
                    nomeProg := listaDesatualizados[n2-1];
                    result := ansiLowerCase(nomeProg);
                end;
        end;

    lista.Free;

end;

{--------------------------------------------------------}
{     pega o nome do programa a atualizar pelas setas
{--------------------------------------------------------}

function pegaInstaladoPelasSetas: string;

var
    listArq: TStringList;
    n2, i, p: integer;
    nomeProg,dataLocal: String;

begin
    result := '';   { pessimista, não retornou nada }

    listArq := geraListArq;

    popupMenuCria (wherex, wherey, 80, 23-wherey, BLACK);


    i := 0;
    while i < listArq.Count do
        begin
            p := pos('.',listArq[i]);
            nomeProg := copy(listArq[i],0,p-1);
            p := pos(':',listArq[i+1]);
            dataLocal := trim(copy(listArq[i+1],0,p-3));

            popupMenuAdiciona('', alinhaCampos(nomeProg)+'- Em: '+dataLocal);

            i := i+3;
        end;

    limpaBuf;

    n2 := popupMenuSeleciona;
    if n2 > 0 then
        begin
            p := pos('.',listArq[(n2-1)*3]);
            nomeProg := copy(listArq[(n2-1)*3],0,p-1);
            result := lowercase(nomeProg);
        end;
end;

{--------------------------------------------------------}
{       Interface para download por folheamento
{--------------------------------------------------------}

procedure baixaFolheados(Opcao: integer);
var
    c:char;
    nomeProg: String;

begin
    nomeProg := '';
    TextBackground(BLUE);
    mensagem('DV_NMPROG',1);  {'Informe o nome do programa ou selecione com as setas:'}
    TextBackground(BLACK);

    c := sintEdita(nomeProg, wherex, wherey, 255, true);

    if (c = CIMA) or (c = BAIX) then
        begin
            if opcao = 1 then
                nomeProg := pegaDaInternetPelasSetas
            else
            if opcao = 2 then
                begin
                    nomeProg := pegaDesatualizadoPelasSetas;
                    if nomeProg = '' then exit;
                end
            else
            if opcao = 3 then
                nomeProg := pegaInstaladoPelasSetas;
        end
    else
        if c <> ENTER then
            nomeProg := '';

    if nomeProg <> '' then
        begin
            limpaBaixo(5);
            baixaProg(NomeProg);
        end
    else
        begin
            limpaBaixo (5);
            mensagem ('DV_DESIST', 2);  {'Desistiu...'}
            exit;
        end;
end;

{--------------------------------------------------------}
{       Atualizar configuração por arquivo .ZIP
{--------------------------------------------------------}

procedure atualizaZip;
var
    nomeArq, dirDosvox: string;
begin
    mensagem('DV_NARQZP',1);     {'Informe o nome do arquivo .ZIP:'}
    nomeArq := obtemNomeArqMasc (10, '*.ZIP');

    if nomeArq = '' then
        begin
            writeln;
            mensagem ('DV_ZIPNEC', 1);   {'Nenhum arquivo .ZIP foi selecionado.'}
        end
    else
        begin
            writeln(nomeArq);

            dirDosvox := pegaDirDosvox;
            atualizandoDosvox := pos('DOSVOX', uppercase(nomeArq)) <> 0;

            if atualizandoDosvox and
               (not renomeiaDosvoxExe (dirDosvox, true)) then // Renomeia dosvox.exe para dosvox_antigo.exe
                exit;
            if descompactaZip (nomeArq, false)then
                begin
                    limpaBufTec;
                    mensagem('DV_PROGAT',1); {'O programa foi atualizado.'}
                    if sintFalando then waitMessage;
                    if atualizandoDosvox then reiniciaDosvoxOuRetrornaAntigo (dirDosvox);
                end
            else //Não descompactou
                if atualizandoDosvox then
                    renomeiaDosvoxExe (dirDosvox, false); // Renomeia dosvox_antigo.exe para dosvox.exe
        end;
end;

{--------------------------------------------------------}
{      atualiza DOSVOX.INI a partir de um arquivo
{--------------------------------------------------------}

function mudaArrobas (s, dirOriginal: string): string;
var p: integer;
begin
     p := pos ('@@', s);
     if p <> 0 then
         begin
             delete (s, p, 2);
             insert (sintDirAmbiente, s, p);
         end;

     p := pos ('=@', s);
     if p <> 0 then
         begin
             delete (s, p+1, 1);
             insert (dirOriginal, s, p+1);
         end;

     p := pos ('@\', s);
     if p <> 0 then
         begin
             delete (s, p, 1);
             insert (dirOriginal, s, p);
         end;

     result := s;
end;

{--------------------------------------------------------}
{      atualiza DOSVOX.INI a partir de um arquivo
{--------------------------------------------------------}

procedure atualizaAtu (nomeArq: string; perguntaSeSobrescreve: boolean);
var
    c: char;
    realtera: boolean;
    secao, item, valor, s: string;
    arq: text;
    p: integer;
    dirOriginal: string;

    function existeChave (secao, item: string): boolean;
    begin
        existeChave := sintAmbiente (secao, item) <> '';
    end;

begin
    if nomeArq = '' then
        begin
            mensagem ('DV_ARQMUDANCA', 1);     {'Informe o nome do arquivo que contém as mudanças'}
            nomeArq := obtemNomeArqMasc (10, '*.ATU');
    end;

    if nomeArq = '' then
        begin
            writeln;
            mensagem ('DV_ATUNEC', 1);   {'Nenhum arquivo .ATU foi selecionado.'}
            exit;
        end;

    assign (arq, nomeArq);
    {$I-} reset (arq);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('DV_ARQNAOEX', 1);   { 'Arquivo não existe, sinto muito.' }
            exit;
        end;

    if perguntaSeSobrescreve then
        begin
            mensagem ('DV_REALTERASN', 0);     { 'Deseja realterar itens anteriormente criados?' }
            c := popupMenuPorLetra('SN');
        end
    else
        c := 'S';

    if c = ESC then
        begin
            {$I-} close (arq);  {$I+}
            if ioresult <> 0 then;
            exit;
        end;
    realtera := upcase (c) = 'S';

     dirOriginal := sintAmbiente ('DOSVOX', 'PGMDOSVOX');

     secao := '';
     while not eof (arq) do
         begin
             readln (arq, s);
             if (s <> '') and (s[1] <> ';') and (s[1] <> '*') then
                 begin
                     if s[1] = '[' then
                          begin
                              delete (s, 1, 1);
                              delete (s, length(s), 1);
                              secao := s;
                          end
                     else
                          begin
                              p := pos ('=', s);
                              if p > 1 then
                                  begin
                                      s := mudaArrobas(s, dirOriginal);
                                      item := copy (s, 1, p-1);
                                      valor := copy (s, p+1, length(s));
                                      if realtera or (not existeChave (secao, item)) then
                                          begin
                                              sintGravaAmbiente (secao, item, valor);
                                              if dvWin.sintAceitaLegado then
                                                  sintGravaAmbienteArq (secao, item, valor, 'dosvox.ini');
                                          end;
                                  end
                              else
                                  begin
                                      mensagem ('DV_CHAVEINVAL', 1);    { 'Chave inválida' }
                                      sintWriteln (s);
                                  end;
                          end;
                 end;
         end;

     close (arq);
     mensagem ('DV_OK', 1);         { 'Ok ! '}
end;

{--------------------------------------------------------}
{       Pega o endereço completo do desktop
{--------------------------------------------------------}

function pegaNomeDesktop: string;
var dir: string;
begin
    regGetString (HKEY_CURRENT_USER, SearchTree+'Desktop', dir);
    result := dir;
end;

function Is64BitWindows: boolean;
type
  TIsWow64Process = function(hProcess: THandle; var Wow64Process: BOOL): BOOL;
    stdcall;
var
  DLLHandle: THandle;
  pIsWow64Process: TIsWow64Process;
  IsWow64: BOOL;
begin
  Result := False;
  DllHandle := LoadLibrary('kernel32.dll');
  if DLLHandle <> 0 then begin
    pIsWow64Process := GetProcAddress(DLLHandle, 'IsWow64Process');
    Result := Assigned(pIsWow64Process)
      and pIsWow64Process(GetCurrentProcess, IsWow64) and IsWow64;
    FreeLibrary(DLLHandle);
  end;
end;

{--------------------------------------------------------}
{              remover programa instalado
{--------------------------------------------------------}

procedure removerProgInstalado;
var dirDosvox, dirAnt, dirFonte, dirSons: string;
    nomeArq: string;
    nome: string;
    c: char;
    arq: TSearchRec;

label desistiu, removeFonte;

begin
    textBackground (BLUE);
    mensagem ('DV_PROGREM', 1);  {'Escolha com as setas o arquivo a remover'}
    textBackground (BLACK);

    getDir (0, dirAnt);
    dirDosvox := pegaDirDosvox;
    chDir (dirDosvox);

    nomeArq := obtemNomeArqMasc (10, '*.EXE');
    writeln (nomeArq);
    if nomeArq = '' then goto desistiu;

    nome := ExtractFileName(nomeArq);
    delete (nome, lastDelimiter('.', nome), 999);

    mensagem ('DV_CONFREMP', 0 );   {'Confirma a remoção do programa '}
    sintWrite (nome);
    mensagem ('DV_SIMNAO', 0);   {'{S/N) ?'}
    c := popupMenuPorLetra('SN');

    if c <> 'S' then goto desistiu;

    writeln;
    textBackground (RED);
    mensagem ('DV_PERIGO' , 1);     {'Atenção, essa operação é irreversível e pode causar imensos danos.'}
    textBackground (BLACK);
    mensagem ('DV_TECLECCONT', 1);  {'Aperte a tecla C para continuar'}
    c := popupMenuPorLetra ('CN');
    writeln;
    if upcase (c) <> 'C' then goto desistiu;

    mensagem ('DV_REMEXEC', 1);       {'Removendo executável'}
    if not deleteFile (nomeArq) then
        mensagem ('DV_EXECNREM', 2)   {'Executável não foi removido'}
    else
        mensagem ('DV_OKREMOV', 2);    {'Ok, removido'}

    if FileExists(nome+'.atu') then
        begin
            mensagem ('DV_REMATU', 1);        {'Removendo atualizador'}
            if not deleteFile (nome+'.atu') then
                mensagem ('DV_REMNREM', 2)    {'Atualizador não removido'}
            else
                mensagem ('DV_OKREMOV', 2)    {'Ok, removido'}
        end;

    dirSons := sintAmbiente (nome, 'DIR' + upperCase(nome));
    if dirSons = '' then
        dirSons := dirDosvox + 'som\'+nome;

    mensagem ('DV_REMSOM', 1);        {'Removendo diretório de sons'}
    while not DirectoryExists(dirSons) do
        begin
            mensagem ('DV_NAODIRSONS', 1);   {'Não encontrei o diretório de sons'}
            mensagem ('DV_EDIRSONS', 1);     {'Editore o nome do diretório de sons ou tecle ESC'}
            c := sintEdita(dirsons, wherex, wherey, 144, true);
            writeln (dirSons);
            if c = ESC then
                 begin
                     writeln;
                     goto removeFonte;
                 end;
        end;

    chdir (dirSons);
    if FindFirst('*.*', faAnyFile, arq) = 0 then
        repeat
            deleteFile (arq.Name);
        until FindNext(arq) <> 0;
    FindClose(arq);

    chdir ('..');
    {$I-}  rmdir (dirSons);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('DV_DIRSOMNREM', 2);     {'Erro ao remover o diretório de sons'}
            sintWriteln (dirSons);
        end
    else
        mensagem ('DV_OKREMOV', 2);    {'Ok, removido'}

removeFonte:
    mensagem ('DV_REMFONTE', 1);     {'Removendo o programa fonte'}
    dirFonte := dirDosvox + 'fontes\' + nome;
    if not DirectoryExists(dirFonte) then
        begin
            mensagem ('DV_FONTENAO', 1);       {'Programa fonte não achado em '}
            sintWriteln (dirFonte);
        end
    else
        begin
            chdir (dirFonte);
            if FindFirst('*.*', faAnyFile, arq) = 0 then
                repeat
                    deleteFile (arq.Name);
                until FindNext(arq) <> 0;
            FindClose(arq);
        end;

    chdir ('..');
    {$I-}  rmdir (dirFonte);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('DV_DIRFONTENREM', 1);     {'Erro ao remover o diretório de fontes.'}
            sintWriteln (dirFonte);
            writeln;
        end
    else
        mensagem ('DV_OKREMOV', 2);    {'Ok, removido'}

    chDir (dirAnt);
    exit;

desistiu:
    mensagem ('DV_DESIST', 2);    {'Desistiu...'}
    chDir (dirAnt);
end;

{--------------------------------------------------------}
{           atualizar todo sistema pela Internet
{--------------------------------------------------------}

procedure atualizarTodoSistema;
var
    resp: char;
    arquivoAGravar, url, nomeProg,verLocal, dirSaida: String;
    url_versoes: TStringList;

    function removerUrl (s: string): string;
    begin
        while (s <> '') and (pos('/', s) <> 0) do delete (s, 1, pos('/', s));

        result := s;
    end;

    function obterUrlSetupDV: string;
    var i, n: integer;
    begin
        if Is64BitWindows then
            mensagem ('DV_VER64B', 2)   { 'O Sistema Operacional deste computador é de 64 bits' }
        else
            mensagem ('DV_VER32B', 2);  { 'O Sistema Operacional deste computador é de 32 bits' }

        mensagem ('DV_VERESC', 1);      {'Escolha com as setas a versão do Dosvox a baixar:' }
        popupMenuCria(whereX,whereY,30,url_versoes.Count,MAGENTA);
        for i := 0 to (url_versoes.Count - 1) do
            popupMenuAdiciona('', removerUrl(url_versoes[i]));
        n := popupMenuSeleciona;
        if (n < 1) or (n > url_versoes.Count) then n := 1;

        result := url_versoes[n - 1];
    end;

begin
    url := sintAmbiente ('DOSVOX', 'URL_UPGRADE', URL_UPGRADE);
    if url[length(url)] <> '/' then
        url := url + '/';
    url := url + 'versoes.txt';

    verLocal := gettempdir + 'versoes.txt';
    if not baixaArquivo (url, verLocal, false) then
        begin
            mensagem('DV_ERRSRV',1); { 'Erro na comunicação com o site de atualização do DosVox' }
            exit;
        end;

    url_versoes := TStringList.Create;
    abreTXT(verLocal, url_versoes);
    if url_versoes.Count = 0 then
        begin
            mensagem('DV_ERROLEIT', 1); {'Houve um erro de leitura no arquivo original.'}
            url_versoes.Free;
            exit;
        end
    else if url_versoes.count = 1 then
        url := url_versoes[0]
    else
        url := obterUrlSetupDV;

    url_versoes.Free;

    nomeProg := removerUrl (url);
    dirSaida := pegaNomeDesktop; //Guarda integro para mostrar na confirmação de download.
    arquivoAGravar := dirSaida;
    if arquivoAGravar[length(arquivoAGravar)] <> '\' then arquivoAGravar := arquivoAGravar + '\';
    arquivoAGravar := arquivoAGravar + nomeProg;

    mensagem('DV_BAIXAR',0); {'Baixar'  }
    write (': ');
    sintWriteln(nomeProg);
    mensagem('DV_NA_PASTA',0); {'Na pasta'  }
    write (': ');
    sintWriteln(dirSaida);
    writeln;
    mensagem ('DV_CONFIRMA', 0);    {'Confirma? '}
    mensagem ('DV_SIMNAO', 0);   { ' (S/N)? ' }
    resp := popupMenuPorLetra ('SN');
    if upcase(resp) <> 'S' then
        begin
            mensagem ('DV_DESIST', 2);      {'Desistiu...'}
            exit;
        end;

    mensagem('DV_BAIXND',2); {'Baixando...'  }
    if baixaArquivo (url, arquivoAGravar, false) then
        begin
            mensagem('DV_SETUPS',0); {'Arquivo de Setup foi gravado em:'}
            sintWriteln(' ' + dirSaida);
            writeln;
            sintBip;
            mensagem('DV_CUIDATU',2); {'Cuidado! Para atualizar o sistema nenhum programa dele pode estar ativo.'}
        end
    else
        begin
            mensagem('DV_ERRBXR',2); {'Erro ao baixar o arquivo.'}
            exit;
        end;
end;

{--------------------------------------------------------}
{             ajuda da atualização do sistema
{--------------------------------------------------------}

procedure ajudaAtualiza;
begin
    writeln;
    mensagem ('DV_AJUCA_OPC', 1);   { 'As opções de atualização são:' }
    mensagem ('DV_AJUCA_P', 1);     { '  P - Atualizar programa pela Internet' }
    mensagem ('DV_AJUCA_V', 1);     { '  V - verificar programas com atualização pendente' }
    mensagem ('DV_AJUCA_B', 1);     { '  B - Baixar programa pela Internet sem atualizar' }
    mensagem ('DV_AJUCA_A', 1);     { '  C - Atualizar configuração por arquivo .ATU' }
    mensagem ('DV_AJUCA_Z', 1);     { '  A - Atualizar programa por arquivo .ZIP' }
    mensagem ('DV_AJUCA_I', 1);     { '  I - Informações sobre os programas instalados' }
    mensagem ('DV_AJUCA_S', 1);     { '  S - Atualizar todo o sistema pela Internet' }
    mensagem ('DV_AJUCA_R', 1);     { '  R - Remover programa instalado' }

    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}
{            seleciona a opção de Atualização do Sistema
{--------------------------------------------------------}

{--------------------------------------------------------}
function selSetasAtualiza: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var n: integer;

const
    nOpAtualiza = 8;
    tabLetrasAtualiza: string [nOpAtualiza] = 'PVBAZISR';

begin
    salvaXY;
    writeln;
    garanteEspacoTela (nOpAtualiza);
    popupMenuCria (wherex, wherey, 55, nOpAtualiza, MAGENTA);

    MenuAdiciona ('DV_AJUCA_P');    { '  P - Atualizar programa pela Internet' }
    MenuAdiciona ('DV_AJUCA_V');    { '  V - verificar programas com atualização pendente' }
    MenuAdiciona ('DV_AJUCA_B');    { '  B - Baixar programa pela Internet sem atualizar' }
    MenuAdiciona ('DV_AJUCA_A');    { '  C - Atualizar configuração por arquivo .ATU' }
    MenuAdiciona ('DV_AJUCA_Z');    { '  A - Atualizar programa por arquivo .ZIP' }
    MenuAdiciona ('DV_AJUCA_I');    { '  I - Informações sobre os programas instalados' }
    MenuAdiciona ('DV_AJUCA_S');    { '  S - Atualizar todo o sistema pela Internet' }
    MenuAdiciona ('DV_AJUCA_R');    { '  R - Remover programa instalado' }

    n := popupMenuSeleciona;
    if (n > 0) and (n <= nOpAtualiza) then
        selSetasAtualiza := tabLetrasAtualiza[n]
    else
        selSetasAtualiza := ESC;
    restauraXY;
end;

{--------------------------------------------------------}
{           configuração de Atualização do sistema
{--------------------------------------------------------}

procedure configAtualiza;
var c, c2: char;
    tratandoAtualiza: boolean;

label fim;

begin
    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('DV_CONF_HEADR'));   {'DOSVOX - Configuração'}
    textBackground (BLACK);

    limpaBuf;

    tratandoAtualiza := true;
    while tratandoAtualiza do
        begin
            limpaBaixo(2);
            writeln;
            textBackground (RED);
            mensagem ('DV_AJUCA_PRMPT', 0);     { 'Atualização do Dosvox - ' }
            mensagem ('DV_OQUE', 0);            { 'O que você deseja ? ' }
            textBackground (BLACK);

            pegaTeclado (c, c2);
            if (c = #0) and ((c2 = CIMA) or (c2 = BAIX) or (c2 = F9)) then
                begin
                    c := selSetasAtualiza;
                end;

            if c = ESC then
                begin
                    writeln;
                    mensagem ('DV_OK', 1);      { 'Ok ! '}
                    limpaBaixo(2);
                    goto fim;
                end;

            if (c = GOTFOCUS) or (c = NOFOCUS) then
            else
            if (c = #0) and (c2 = F1) then
                 ajudaAtualiza
            else
                 begin
                     if sintEcoarOpcao then
                         soletra (c, 1);
                     writeln;
                     tratandoAtualiza := false;
                     c := upcase(c);
                     naoDescompactarZip := c in ['B', ^P]; //- somente baixa o pacote zip

                     case c of
                        'P','B', ^P: baixaFolheados(1);      {'  P - Atualizar programa pela Internet'}
                        'V': baixaFolheados(2);      {'  V - verificar programas com atualização pendente'}
                        'A': atualizaAtu ('', true); {'  C - Atualizar configuração por arquivo .ATU'}
                        'Z': atualizaZip;            {'  A - Atualizar programa por arquivo .ZIP'}
                        'I': baixaFolheados(3);      {'  I - Informações sobre os programas instalados'}
                        'S': atualizarTodoSistema;   {'  S - Atualizar todo o sistema pela Internet'}
                        'R': removerProgInstalado;   {'  R - Remover programa instalado'}
                     else
                         mensagem ('DV_OPCINV', 1);     { 'Opção inválida.' }
                         tratandoAtualiza := true;
                     end;
                 end;
        end;
fim:
end;

end.
