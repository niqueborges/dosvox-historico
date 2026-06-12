{-------------------------------------------------------------}
{
{    Traduvox - tradutor de textos usando o Google Translator
{
{    Módulo de controle da tradução
{
{    Autor: José Antonio Borges
{
{    Atualizado por Patrick Barboza
{
{    Em dezembro/2023
{
{    Com a colaboração de Fabiano Ferreira
{
{-------------------------------------------------------------}

unit trtraduz;

interface
uses
    windows,
    classes,
    dvcrt,
    dvwin,
    dvExec,
    dvdigitexto,
    sysUtils,
    trvars,
    trmsg,
    trgoogle,
    trsintet,
    trnet;

procedure traduzFrases (tipoDestino: char; nomeArqDest: string);
procedure traduzArquivo (nomeArqOrig: string; tipoDestino: char; nomeArqDest: string);
procedure traduzClipBoard (tipoDestino: char; nomeArqDest: string);

implementation

const
    MAX_TRADUZIR = 30000;

procedure arquiva (s, nomeArq: string; pulandoLinha: boolean);
var arq: textFile;
begin
    assign (arq, nomeArq);
    try
        if FileExists(nomeArq) then
            append (arq)
        else
            rewrite (arq);
    except
        mensagem ('TRERRARQ', 2);  {'Erro de arquivamento!'}
        exit;
    end;

    if pulandoLinha then
        writeln (arq, s)
    else
        write (arq, s);
    closeFile (arq);
end;

procedure jogaAreaTransf (s2: string);
var textoClip: array [0..65000] of char;
    c, c2: char;
begin
    mensagem ('TRSUBADI', 1);  {'Substitui ou adiciona?'}
    sintLeTecla (c, c2);
    writeln;

    if upcase (c) = 'S' then
        textoClip [0] := #$0
    else
        begin
            getClipBoard(textoClip, 65000-2-length(s2));
            if textoClip[0] <> #$0 then
                s2 := CRLF + s2;
        end;

    strCat (textoClip, pchar(s2));
    putClipBoard(textoClip);

    mensagem ('TRTRANSF', 1);   {'Ok, transferido'}
end;

procedure trocaVoz (tipo: string);
var
    tipoSapi, numVoz: integer;
begin
    obtemVoz (tipo, tipoSapi, numVoz);
    case tipoSapi of
        3: sintReinic (3, true, 3, numVoz, 0, 0);
        4: sintReinic (3, true, 4, numVoz, 140, 80);
        5: sintReinic (3, true, 5, numVoz, 0, 0);
    end;
end;

procedure traduzFraseDireta (tipoDestino: char; s: string);
var
    status: string;
    s2: string;
    dir: string;
    tempPath, tempFile: packed array [0..MAX_PATH] of char;
    nomeTemp: string;
begin
    GetTempPath(sizeof(tempPath), tempPath);
    if GetTempFileName (tempPath, 'tmp', 0, tempFile) = 0 then
        begin
            mensagem ('TRERTRAB', 2);   {'Erro ao criar o arquivo de trabalho'}
            exit;
        end;
    nomeTemp := strPas(tempFile);

    if fileExists(nomeTemp) then
        DeleteFile(nomeTemp);
    nomeTemp := ChangeFileExt(nomeTemp, '.txt');
    if fileExists(nomeTemp) then
        DeleteFile(nomeTemp);

    status := traduzArquivoGoogle (nomeTemp, s, linguaOrig, s2, linguaDest);

    // Solução temporária para excluir três primeiros caracteres que não deveriam existir.
    if uppercase(linguaOrig) = 'AUTO' then
        delete(s2, 1, 3);

    if copy (status, 1, 3)  <> '200' then
        begin
            mensagem ('TRERRO', 1);   {'Erro no Google Translator, código:'}
            sintWriteln (status);
        end
    else
        case tipoDestino of
            'L':
                  begin
                      mensagem ('TREDIT', 1);   {'Editore a resposta'}
                      while sintFalando do delay (500);
                      if sapiPresente then
                          trocaVoz (linguaDest);
                      sintetiza (s2);
                      sintEdita (s2, wherex, wherey, 255, true);
                      if sapiPresente then
                      begin
                          sintFim;
                          dir := sintAmbiente ('TRADUVOX', 'DIRTRADUVOX');
                          if dir = '' then
                              dir := 'c:\winvox\som\traduvox';
                          sintInic (0, dir);
                      end;
                  end;
            'A':  arquiva (s2, nomeArqDest, true);
            'T':  jogaAreaTransf (s2);
        end;

    writeln;
end;

procedure traduzFrases (tipoDestino: char; nomeArqDest: string);
var s: string;
begin
    clrscr;
    textBackground (BLUE);
    write (pegaTextoMensagem ('TRINIC'));    {'TRADUVOX ...'}
    writeln (versao);
    writeln;
    textBackground (BLACK);
    mensagem ('TRINITRD', 2);  {'Iniciando a tradução'}
    mensagem ('TRTECFR1', 1);  {'Tecle cada frase a traduzir.'}
    mensagem ('TRTECFR2', 1);  {'ESC termina.'}
    mensagem ('TRTECFR3', 2);  {'Use as setas para obter os detalhes da tradução.'}

    while true do
        begin
            mensagem ('TRTECFRA', 1);  {'Tecle a frase:'}
            sintReadln (s);
            if s = '' then break;
            traduzFraseDireta (tipoDestino, s);
        end;

end;

procedure traduzArquivo (nomeArqOrig: string; tipoDestino: char; nomeArqDest: string);
var
    nomeArqTrab, status: string;
    tempPath, tempFile: array [0..MAX_PATH] of char;
    textoOriginal, textoDestino, listaResult: TStringList;
    x, y, i: integer;
    qLinhas, qPorcento, linhasTraduzidas: integer;
    aTraduzir, traduzido: string;
    c: char;
    comClek: boolean;

label cancela;
begin
    try
        if FileExists(nomeArqOrig) then
        begin
            textoOriginal := TStringList.Create;
            textoOriginal.LoadFromFile(nomeArqOrig);
            textoDestino := TStringList.Create;
        end
        else
        begin
            mensagem ('TRARQNAO', 2);  {'Arquivo não existe'}
            exit;
        end;
    except
        mensagem ('TRERRABR', 2);  {'Erro ao abrir o arquivo!'}
        exit;
    end;
    if nomeArqDest <> '' then
        nomeArqTrab := nomeArqDest
    else
        begin
            GetTempPath(sizeof(tempPath), tempPath);
            if GetTempFileName (tempPath, 'tmp', 0, tempFile) = 0 then
                begin
                    mensagem ('TRERTRAB', 2);   {'Erro ao criar o arquivo de trabalho'}
                    exit;
                end;
            nomeArqTrab := strPas(tempFile);
        end;
    mensagem ('TRINITRD', 2);  {'Iniciando a tradução'}

    comClek := uppercase(sintAmbiente ('TRADUVOX', 'BIPARNATRADUCAO', 'SIM')[1]) = 'S';
    qLinhas := textoOriginal.count;
    linhasTraduzidas := 0;
    for i := 0 to textoOriginal.Count-1 do
    begin
        aTraduzir := textoOriginal[i];
        status := traduzArquivoGoogle (nomeArqOrig, aTraduzir, linguaOrig, traduzido, linguaDest);
        if (copy (status,1,3)  <> '200') then
        begin
            mensagem ('TRERRO', 1);   // 'Erro no Google Translator, código:'
            sintWriteln (status);
            goto cancela;
            end;
        textoDestino.add(traduzido+#$0D+#$0A);
        linhasTraduzidas := linhasTraduzidas + 1;
        qPorcento := (linhasTraduzidas*100) div qLinhas;
        if keyPressed then
        begin
            c := readKey;
            case c of
                ENTER: begin   {   Enter apenas mostra porcentagem   }
                    sintWriteln(intToStr(qPorcento)+' porcento traduzido');
                end;
                CTLENTER: begin   {   Control enter mostra informações completas da tradução   }
                    sintWriteln ('Traduzida '+intToStr(linhasTraduzidas)+' / '+intToStr(qLinhas)+' linhas ('+intToStr(qPorcento)+'%)');
                end;
                ' ': begin   {   Ativa/desativa clek durante a tradução   }
                    comClek := not comClek;
                    sintBip;
                    end;
                end;
        end;
        if comClek then sintClek;
        setWindowTitle (intToStr((i* 100) div textoOriginal.Count) + '% traduzido - Traduvox');
        end;

    setWindowTitle ('Traduvox');

    // Solução temporária para excluir três primeiros caracteres que não deveriam existir.
    if uppercase(linguaOrig) = 'AUTO' then
        for i := 0 to textoDestino.count-1 do
            textoDestino[i] := copy(textoDestino[i], 4, length(textoDestino[i]));

    traduzido := '';
    for i := 0 to textoDestino.count-1 do
        traduzido := traduzido + textoDestino[i];
    arquiva (traduzido, nomeArqTrab, false);

cancela:
    limpaBufTec;
    if tipoDestino = 'A' then
        begin
            if interativo then mensagem ('TRARQVAD', 1);        // 'Arquivado'
        end
    else
        begin
            listaResult := TStringList.create;
            listaResult.LoadFromFile(nomeArqTrab);

            if tipoDestino = 'L' then
            begin
                x := wherex;
                y := wherey;
                popupDigiTexto (listaResult, false, true, 2, 2, 79, 24, true);
                gotoxy (x,y);
            end
            else
            if tipoDestino = 'T' then
            begin
                    traduzido := listaResult.Text;
                    putClipBoard(pchar(traduzido+#$0));
                    mensagem ('TRTXTTRAD', 1);  {'Texto traduzido'}
                end;

            listaResult.free;
            textoDestino.Free;
            deleteFile (nomeArqTrab);
    end;
end;

procedure traduzClipBoard (tipoDestino: char; nomeArqDest: string);
var data: packed array [0..MAX_TRADUZIR] of char;
    tempPath, tempFile: packed array [0..MAX_PATH] of char;
    nomeTemp: string;
    arqTemp: file;
begin

    getClipBoard(data, MAX_TRADUZIR+1);
    if strLen (data) > MAX_TRADUZIR then
        begin
            mensagem ('TRLIMIT', 2);   {'Truncando! A área de transferência excedeu 64000 letras'}
            data[MAX_TRADUZIR] := #$0;
        end;

    // a tradução multilinha do clipboard está temporariamente bloqueada

    GetTempPath(sizeof(tempPath), tempPath);
    if GetTempFileName (tempPath, 'tmp', 0, tempFile) = 0 then
        begin
            mensagem ('TRERTRAB', 2);   {'Erro ao criar o arquivo de trabalho'}
            exit;
        end;
    nomeTemp := strPas(tempFile);

    if fileExists(nomeTemp) then
        DeleteFile(nomeTemp);
    nomeTemp := ChangeFileExt(nomeTemp, '.txt');
    if fileExists(nomeTemp) then
        DeleteFile(nomeTemp);

    assignFile (arqTemp, nomeTemp);
    rewrite (arqTemp, 1);
    blockWrite (arqTemp, data, strlen(data));
    closeFile (arqTemp);

    traduzArquivo (nomeTemp, tipoDestino, nomeArqDest);

    DeleteFile(nomeTemp);
end;

end.
