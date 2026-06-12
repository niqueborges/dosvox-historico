{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Módulo de importação de mídias e roteitos
{
{    Autores: José Antonio Borges
{             Lidiane Figueira Silva
{             Bernard Condorcet
{
{    Em Janeiro/2009
{
{--------------------------------------------------------}

unit joimport;

interface
uses dvwin, dvcrt, dvarq, dvForm, jovars, joMsg, joMci, jpeg, PNGImage,
     windows,graphics, sysutils, classes;

procedure importarMidias;

implementation
 uses joexibe;

{--------------------------------------------------------}
{                obtem as pastas de mídias
{--------------------------------------------------------}

function obtemPastasDeMidias: boolean;
var
    sr: TSearchRec;
    FileAttrs: Integer;
begin
    {$I-} chdir (dirBaseMidias);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('JOMIDNAO', 2);  {'Diretório que contém as mídias não foi encontrado'}
            sintWriteln (dirBaseMidias);
            result := false;
            exit;
        end;

    listaDirMidias.clear;
    FileAttrs := faDirectory;
    if FindFirst(dirBaseMidias+'\*.*', FileAttrs, sr) = 0 then
        begin
            repeat
                if (sr.Name = '.') or (sr.Name = '..') then
                    continue;
                if (sr.Attr and FileAttrs) <> 0 then
                    listaDirMidias.add (sr.Name);
            until FindNext(sr) <> 0;
            FindClose(sr);
        end;

    result := true;
end;

{--------------------------------------------------------}
{                 escolhe a pasta de mídias
{--------------------------------------------------------}

function escolhePastaDeMidias: string;
var i, tam: integer;
    qualPasta: string;
    c: char;
begin
    escolhePastaDeMidias := '';
    limpaBufTec;
    if not obtemPastasDeMidias then exit;

    writeln;
    mensagem ('JOPASMID', 1);  {'Escolha uma pasta de mídias com as setas'}

    qualPasta := '';
    c := sintEdita(qualPasta, wherex, wherey, 144, true);
    if c = ESC then
        begin
            mensagem ('JODESIST', 1);  {'Desistiu'}
            exit;
        end;

    if qualPasta = '' then
        begin
            garanteEspacoTela (7);
            tam := 20;
            for i := 1 to listaDirMidias.count do
                if length(listaDirMidias[i-1]) > tam then
                    tam := length(listaDirMidias[i-1]);
            popupMenuCria(wherex, wherey, tam, 26-wherey, RED);
            for i := 1 to listaDirMidias.count do
                popupMenuAdiciona('', listaDirMidias[i-1]);
            limpaBufTec;
            if popupMenuSeleciona < 1 then
                begin
                    mensagem ('JODESIST', 1);  {'Desistiu'}
                    exit;
                end;
            qualPasta := dirBaseMidias + '\' + opcoesItemSelecionado;
        end;

    writeln (qualPasta);

    {$I+}  chdir (qualPasta);  {$i-}
    if ioresult <> 0 then
        begin
            mensagem ('JOERSELP', 2);   {'Erro ao selecionar o diretório de mídias'}
            qualPasta := '';
        end;

    escolhePastaDeMidias := qualPasta;
end;

{--------------------------------------------------------}
{              importa mídias para o jogo
{--------------------------------------------------------}

function copiaArquivo (dirImport, nomeArqImport: string): boolean;
var
    nomeArqOrig, nomeArqDest: string;
    arqOrig, arqDest: file;
    buffer: array[0..1023] of byte;
    nlidos: integer;
    c, c2: char;
begin
    result := true;
    nomeArqOrig := dirImport + '\' + nomeArqImport;
    nomeArqDest := dirJogo + '\' + nomeArqImport;

    assignFile (arqOrig, nomeArqOrig);
    assignFile (arqDest, nomeArqDest);
    reset (arqOrig, 1);
    {$I-} reset (arqDest); {$i+}
    if ioresult = 0 then
        begin
            close (arqDest);
            mensagem ('JOREESCR', 0);   {'Aperte N para não reescrever o arquivo '}
            sintWrite (nomeArqImport + '  ');
            sintLeTecla (c, c2);
            writeln;
            if upcase (c) = 'N' then exit;
        end;

    try
        rewrite (arqDest, 1);
        while not eof (arqOrig) do
            begin
                blockRead (arqOrig, buffer, 1024, nlidos);
                blockWrite (arqDest, buffer, nlidos);
            end;
    except
        mensagem ('JOERRCOP', 0);    {'Erro ao copiar o arquivo '}
        sintWriteln (nomeArqImport);
        result := false;
    end;

    closeFile (arqOrig);
    closeFile (arqDest);
end;

{--------------------------------------------------------}
{                  exibe uma figura JPEG
{--------------------------------------------------------}

procedure exibeFigura (nomeArq: string);
var
    FJpeg    : TJpegImage;
    FPng     : TPNGObject;
    FBmp     : TBitmap;
    FTela    : TBitmap;

    crtDc, MemDc: HDC;
    lpRect: TRect; // adicionado

begin
    gotoxy (1, 25);
    textBackground (BLACK);
    clrscr;

    FTela := TBitmap.Create;
    GetWindowRect(crtWindow, lpRect);     // adicionado
    FTela.Width := lpRect.Right - lpRect.Left;   // adicionado
    FTela.Height := lpRect.bottom - lpRect.top;  // adicionado
    FTela.PixelFormat := pf24bit;             // opcional
    FTela.Canvas.Brush.Style := bsSolid;      // opcional
    FTela.Canvas.Brush.Color := colorNumber (0);  // opcional
    
    FTela.Canvas.FillRect(rect(0,0,Ftela.Width, Ftela.Height)); // adicionado por necessidade
    
    if extIS (nomeArq, 'JPG') or extIS (nomeArq, 'JPEG') then
        begin
            FJpeg := TJPEGImage.Create;
            FJpeg.LoadFromFile (nomeArq);
            FTela.Canvas.Draw(0, 0, FJpeg);
            FJpeg.Free;
        end
    else
    if extIS (nomeArq, 'PNG') then
        begin
            FPng := TPngObject.Create;
            FPng.LoadFromFile (nomeArq);
            FTela.Canvas.Draw(0, 0, FPng);
            FPng.Free;
        end
    else
    if extIS (nomeArq, 'BMP') then
        begin
            FBmp := TBitmap.Create;
            FBmp.LoadFromFile (nomeArq);
            FTela.Canvas.Draw(0, 0, FBmp);
            FBmp.Free;
        end;

    crtDc := getDc (crtWindow);
    Memdc := CreateCompatibleDC (crtDc);
    SelectObject(MemDC, FTela.Handle);

    BitBlt(crtDC, 0, 0, FTela.Width, FTela.Height, MemDC, 0, 0, SRCCopy);

    SetBkMode(memDc, OPAQUE);
    DeleteDC(MemDC);
    releaseDc (crtWindow, crtDc);

    FTela.Free;
end;

{--------------------------------------------------------}
{                    exibe uma mídia
{--------------------------------------------------------}

procedure exibe (dir, nomeArq: string);
var ext: string;
begin
    limpaBaixo (12);
    textBackground (RED);
    write(nomeArq);
    sleep(500);

    nomeArq := dir + '\' + nomeArq;

    ext := ansiUpperCase (ExtractFileExt (nomeArq));
    if (ext = '.WAV') or (ext = '.WAV') or (ext = '.MID') then
        begin
            enviaComandoMCI ('open "' + nomeArq + '" alias somjogavox');
            enviaComandoMCI ('play somjogavox');
            while not keypressed do waitMessage;
            limpaBufTec;
            enviaComandoMCI ('close somjogavox');
        end
    else
    if (ext = '.JPEG') or (ext = '.JPG') or
       (ext = '.PNG')  or (ext = '.BMP') then
        begin
            exibeFigura (nomeArq);
            while not keypressed do waitMessage;
            limpaBufTec;
            InvalidateRect(crtWindow, NIL, true);
        end
    else
    if (ext = '.MPEG') or (ext = '.MPG') or (ext = '.MP4') or
       (ext = '.WMA')  or (ext = '.AVI') then
        begin
            enviaComandoMCI ('open "' + nomeArq + '" alias filmejogavox');
            enviaComandoMci ('window midiaSlide handle ' + intToStr(crtwindow));
            enviaComandoMci ('put midiaSlide destination');
            enviaComandoMCI ('play filmejogavox');
            textRefreshInhibited := true;
            while not keypressed do waitMessage;
            textRefreshInhibited := false;
            enviaComandoMCI ('close filmejogavox');
            limpaBufTec;
            InvalidateRect(crtWindow, NIL, true);
        end;

    textBackground (BLACK);
    limpaBaixo (12);
end;

{--------------------------------------------------------}
{              importa mídias para o jogo
{--------------------------------------------------------}

procedure importarMidias;
var dirImport: string;
    sr: TSearchRec;
    listArquivos: TList;
    numArqAtual: integer;
    c, c2: char;
    i, ymin, ncop: integer;

begin
    window (1, 1, 80, 25);
    clrScr;
    setWindowTitle('Jogavox ' + nomeArqJogo);

    TextBackground(BLUE);
    mensagem ('JOIMPORT', 2);      {'Importando Mídias para o jogo'}
    TextBackground (BLACK);

    dirImport := escolhePastaDeMidias;
    if DirImport = '' then
        begin
            mensagem ('JODESIST', 1);   {'Desistiu'}
            chdir (dirJogo);
            exit;
        end;

    {$I-} chdir (dirImport); {$I+}
    if ioresult <> 0 then
        begin
             mensagem ('JONEXIST', 1);   {'Esta pasta não existe'}
             chdir (dirJogo);
             exit;
        end;

    listArquivos := criaListArq ('*.*', faArchive);
    ordenaListArq(0);
    limpaBufTec;
    numArqAtual := 0;

    writeln;
    mensagem ('JOSMAIS', 1);   {'Use as setas e a tecla + para selecionar os arquivos.'}
    mensagem ('JOFINENT', 2);  {'Depois tecle Enter para iniciar a cópia.  Esc cancela.'}
    mensagem ('JOF9TOCA', 1);  {'F9 exibe o arquivo.'}

    chdir (dirJogo);
    
    repeat
        ymin := 25-listArquivos.count+1;
        if ymin < 1 then ymin := 1;

        preparaTelaArq (51, ymin, 79, 25);
        salvaTelaArq;
        escolheFuncaoListArq (numArqAtual, c, c2);
        recuperaTelaArq;

        if c = ESC then break;

        ncop := 0;
        if (c = #$0) and (c2 = F9) and (numArqAtual >= 0) then
            exibe (dirImport, PMySearchRec(listArquivos[numArqAtual]).sr.name)
        else
        if c = ENTER then
            begin
                for i := listArquivos.count-1 downto 0 do
                    begin
                        if PMySearchRec(listArquivos[i]).marcado then
                            begin
                                sr := PMySearchRec(listArquivos[i]).sr;
                                if copiaArquivo (dirImport, sr.Name) then
                                    ncop := ncop + 1;
                                PMySearchRec(listArquivos[i]).marcado := false;
                            end;
                    end;

                gotoxy (1, 11);
                sintWriteInt (ncop);
                mensagem ('JONARQCP', 1);    {' arquivos copiados.'}
                mensagem ('JOCNTSEL', 1);    {'Continue selecionando...'}
            end;

    until false;

    liberaListArq;
    chdir (dirJogo);
end;

end.

