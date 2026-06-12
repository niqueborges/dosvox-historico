{-------------------------------------------------------------}
{
{    Webvox - rotinas de gravação dos downloads
{

{    Criada por: Neno Henrique da Cunha Albernaz
{    Códigos retirados da original webvox.dpr
{    Em 30/06/2019

{
{-------------------------------------------------------------}

unit webGrava;

interface

uses
    windows, shellApi, sysUtils, dvexec,
    dvcrt, dvWin, dvForm,
    webMsg, webutil;

procedure gravarPagina;
procedure gravarOriginal (gravarSemPerguntar: boolean);
procedure gravarVideoYoutube (paginaATrazer: string);

implementation

uses webVars, webGrArq;

{-------------------------------------------------------------}
{                 grava Pagina em Texto
{-------------------------------------------------------------}

procedure gravarPagina;
var nomeArq: string;
    c: char;
    geraRef: boolean;
    arq: file;
begin
    if nomeTemp = '' then
        begin
            mensagem ('WBNAOCAR', 1);  {'Não existe página carregada'}
            exit;
        end;

    textBackGround (RED);
    mensagem ('WBARQTXT', 0);  {'Arquivando pagina em formato texto'}
    textBackground (BLACK);
    writeln;
    mensagem ('WBNOMGRV', 1);  {'Qual o nome do arquivo a gravar ? '}
    sintReadln (nomeArq);

    if nomeArq = '' then exit;

    if pos ('.',nomeArq) = 0 then
        nomeArq:= nomeArq + '.TXT';

    assign (arq, nomeArq);
    {$I-}  reset (arq);  {$I+}
    if ioresult = 0 then
        begin
             close (arq);
             mensagem ('WBREGRAV', 0);  {'Arquivo existente.  Opções: limpar, adicionar ou desistir ? '}
             c := popupMenuPorLetra ('LAD');
             writeln;

             if (c = ESC) or (c = 'D') then exit;

             if (c = 'L') then
                 begin
                     {$I-}  erase (arq);  {$I+}
                     if ioresult <> 0 then;
                 end;
        end;

    mensagem ('WBQUEREF', 0);  {'Deseja referências listadas no texto ? '}
    c := popupMenuPorLetra ('SN');
    writeln;
    geraRef := c = 'S';

    if not geraArqTexto (nomeTemp, nomeArq, geraRef) then
        mensagem ('WBERRTXT', 1)  {'Erro ao gravar o arquivo texto'}
    else
        mensagem ('WBOK', 1);  {'OK'}
end;

{-------------------------------------------------------------}
{                 grava Pagina em Formato Original
{-------------------------------------------------------------}

procedure gravarOriginal (gravarSemPerguntar: boolean);
var nomeArq: string;
    arq, arqSai: file;
    buf: array [0..4095] of byte;
    lidos: integer;
    c: char;

label erroDisco;
begin
    if nomeTemp = '' then
        begin
            mensagem ('WBNAOCAR', 1);  {'Não existe página carregada'}
            exit;
        end;

    textBackGround (RED);
    mensagem ('WBARQHTM', 0);  {'Arquivando pagina no formato original'}
    textBackground (BLACK);
    writeln;

    nomeArq := nomeResumido (nomePagAtual);

    if not gravarSemPerguntar then
        begin
            mensagem ('WBEDINOM', 1);   {'Editore o nome, tecle ENTER para confirmar
                                                           ou ESC para cancelar: '}
            sintWrite (nomeArq);
            gotoxy (1, wherey);
            if sintEdita (nomeArq, wherex, wherey, 80, true) = ESC then
                        exit;
            if (nomeArq = '') or (nomeArq[1] = ' ') then exit;
        end;

    writeln;

    if (pos ('\', nomeArq) = 0) and (dirDownload <> '') then
        if dirDownload[length(dirDownload)] = '\' then nomeArq := dirDownload + nomeArq
        else nomeArq := dirDownload + '\' + nomeArq;

    if fileExists (nomeArq) then
        begin
            if gravarSemPerguntar then
                nomeArq := resolverNovoNomeArq (nomeArq)
            else
                repeat
                    mensagem ('WBJAEXI1', 0); {'O arquivo destino '}
                    delay (100);
                    sintWrite (nomeArq);
                    delay (100);
                    mensagem ('WBJAEXI2', 1); {' já existe.  Sobrescreve (S/N)? '}
                    c := upcase(popupMenuPorLetra ('SN'));
                    if not (c in ['S', ENTER]) then
                        begin
                            mensagem ('WBDESIST', 1);
                            exit;
                        end;
                until c in ['S', 'N', ESC, ENTER];
        end;

    pilhaPag[topoPilhaPag]^.podeApagarTemp := true;

    assign (arq, nomeTemp);
    {$I-}  reset (arq, 1);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('WBTRAAPA', 1);  {'Arquivo de trabalho foi apagado'}
            exit;
        end;

    assign (arqSai, nomeArq);
    {$I-}  rewrite (arqSai, 1);  {$I+}
    if ioresult <> 0 then
        begin
erroDisco:
            mensagem ('WBERRGRD', 1);  {'Problemas para gravar arquivo no disco'}
            {$I-}  close (arq);  {$I+}
            if ioresult <> 0 then;
            {$I-}  close (arqSai);  {$I+}
            if ioresult <> 0 then;
            exit;
        end;

    while not eof (arq) do
        begin
            {$I-} blockread (arq, buf, 4096, lidos);  {$I+}
            if lidos = 0 then goto erroDisco;
            if ioresult <> 0 then goto erroDisco;
            {$I-} blockwrite (arqSai, buf, lidos);  {$I+}
            if ioresult <> 0 then goto erroDisco;
        end;

    {$I-}  close (arq);  {$I+}
    if ioresult <> 0 then;
    {$I-}  close (arqSai);  {$I+}
    if ioresult <> 0 then goto erroDisco;
    mensagem ('WBOK', 1);   {'Ok'}
end;

{-------------------------------------------------------------}
{                   Grava um vídeo do Youtube utilizando youtube-dl.exe (em 11/03/2020)
{-------------------------------------------------------------}

procedure gravarVideoYoutube (paginaATrazer: string);
var dirDosvox: shortString;
begin
    if pos ('HTTPS://WWW.YOUTUBE.COM/WATCH', maiuscansi(paginaATrazer)) = 0 then
        mensagem ('WBPAGINC', -1) {'Nome de página incompatível com este programa'}
    else
        begin
            dirDosvox := sintAmbiente('DOSVOX', 'PGMDOSVOX', 'C:\Winvox');
            if  pos(':\', dirDosvox) = 0 then dirDosvox := 'C:\Winvox';
            if not fileExists (dirDosvox + '\yt-dlp.exe') then
                begin
                    mensagem ('WBARQNAO', -1); {'Este arquivo não existe'}
                    sintetiza (dirDosvox + '\yt-dlp.exe');
                    exit;
                end;

            mensagem ('WBRECFTP', -1); {'Recebendo arquivo '}
            if executaProgEx (dirDosvox + '\yt-dlp.exe', dirDownload, '-f mp4 ' + paginaATrazer, SW_SHOWMINIMIZED) > 32 then
                begin
                    esperaProgVoltar;
                    mensagem ('WBOKGRAV', -1); {'Ok, já gravei '}
                end
            else
                mensagem ('WBERRGRD', -1); {'Problemas para gravar arquivo no disco'}
            sintBip;
        end;
end;

{-------------------------------------------------------------}

begin
end.
