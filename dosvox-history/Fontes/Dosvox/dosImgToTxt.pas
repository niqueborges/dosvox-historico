{----------------------------------------------------------------}
{
{    Gerador de txt passando OCR em imagem
{
{    Autor: Neno Henrique da Cunha Albernaz
{    Em 20/10/2018
{
{----------------------------------------------------------------}

unit dosImgToTxt;

interface

uses
    dvcrt,
    dvWin,
    windows,
    sysutils,
    classes,
    dvexec,
    dvArq, dosmsg, dosVars;

function podePassarOcr (nomeArq: string): boolean;
function converterImgToTxt (nomeArq: string): boolean;
//function passarOcr (i: integer): boolean;

implementation

{--------------------------------------------------------}
{       Testa se a extensão do arquivo é imagem para passar OCR
{--------------------------------------------------------}

function podePassarOcr (nomeArq: string): boolean;
var ext: string;
begin
    podePassarOcr := false;
    ext := ansiUpperCase(extractFileExt(nomeArq));
    delete (ext, 1, 1);
    if (ext = 'JPG') or
       (ext = 'JPEG') or
       (ext = 'TIF') or
       (ext = 'TIFF') or
       (ext = 'GIF') or
       (ext = 'PNG') or
       (ext = 'BMP') then
          podePassarOcr := true;
end;

{--------------------------------------------------------}
{       Pega o caminho do Abbyy.FineReader 11 a 15, verifica se ele existe no computador.
{--------------------------------------------------------}

function pegarCaminhoFineReader: string;
var
    nomeProg: string;
label gravarCaminho, fim;
begin
    pegarCaminhoFineReader := '';
    nomeProg := sintAmbiente ('DOSVOX', 'EXEC_FINEREADER');
    if (pos('\', nomeProg) = 0) and (upcase((nomeProg + 'S')[1]) = 'N') then   exit; //Força não usar o FineReader
    if (nomeProg <> '') and fileExists (nomeProg) then goto fim;
    nomeProg :=  'c:\Program Files (x86)\ABBYY FineReader 11\FineCmd.exe';
    sintGravaAmbiente('DOSVOX', 'EXEC_FINEREADER', nomeProg);
    if fileExists (nomeProg) then goto fim;
    nomeProg :=  'c:\Program Files\ABBYY FineReader 11\FineCmd.exe';
    if fileExists (nomeProg) then goto gravarCaminho;
    nomeProg :=  'c:\Arquivos de Programas\ABBYY FineReader 11\FineCmd.exe';
    if fileExists (nomeProg) then goto gravarCaminho;
    nomeProg :=  'c:\Program Files (x86)\ABBYY FineReader 12\FineCmd.exe';
    if fileExists (nomeProg) then goto gravarCaminho;
    nomeProg :=  'c:\Program Files\ABBYY FineReader 12\FineCmd.exe';
    if fileExists (nomeProg) then goto gravarCaminho;
    nomeProg :=  'c:\Arquivos de Programas\ABBYY FineReader 12\FineCmd.exe';
    if fileExists (nomeProg) then goto gravarCaminho;
    nomeProg :=  'c:\Program Files (x86)\ABBYY FineReader 14\FineCmd.exe';
    if fileExists (nomeProg) then goto gravarCaminho;
    nomeProg :=  'c:\Program Files\ABBYY FineReader 14\FineCmd.exe';
    if fileExists (nomeProg) then goto gravarCaminho;
    nomeProg :=  'c:\Program Files (x86)\ABBYY FineReader 15\FineCmd.exe';
    if fileExists (nomeProg) then goto gravarCaminho;
    nomeProg :=  'c:\Program Files\ABBYY FineReader 15\FineCmd.exe';
    if fileExists (nomeProg) then goto gravarCaminho
    else exit;

gravarCaminho:
    sintGravaAmbiente('DOSVOX', 'EXEC_FINEREADER', nomeProg);
fim:
    pegarCaminhoFineReader := nomeProg;
end;

{--------------------------------------------------------}
{       Pega o caminho do Tesseracte, verifica se ele existe no computador.
{--------------------------------------------------------}

function pegarCaminhoTesseract: string;
var nomeProg: string;
begin
    pegarCaminhoTesseract := '';
    nomeProg := sintAmbiente ('DOSVOX', 'EXEC_TESSERACT');
    if nomeProg = '' then
        begin
            nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\Scripts\OCR\tesseract-ocr\tesseract.exe';
            sintGravaAmbiente('DOSVOX', 'EXEC_TESSERACT', nomeProg);
        end;
    if not fileExists (nomeProg) then
        begin
            nomeProg := 'c:\Winvox\Tesseract-ocr\tesseract.exe';
            if not fileExists (nomeProg) then
                begin
                    mensagem ('DV_PRGNAOENC', 0); {'Programa não encontrado.'}
                    sintWriteln (' Tesseract.exe');
                    exit;
                end
            else
                sintGravaAmbiente('DOSVOX', 'EXEC_TESSERACT', nomeProg);
        end;
    pegarCaminhoTesseract := nomeProg;
end;

{--------------------------------------------------------}
{       Grava conteúdo da área de transferência em arquivo txt
{--------------------------------------------------------}

procedure GravaAreaTransfNoArq (nomeArq: string);
var
    i: integer;
    s: string;
    buf: PChar;
    hmem: THandle;
    arq: text;

label fim;
Begin
    if not openClipboard (crtWindow) then exit;
    hmem := getClipboardData (CF_TEXT);
    if hmem = 0 then
        begin
            closeClipboard;
            exit;
        end;

    assign (arq, nomeArq);
    {$i-} rewrite (arq); {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('DV_ERRWAR', 1);{'Erro de escrita do arquivo'}
            closeClipboard;
            exit;
        end;

    buf := globalLock (hmem);
    for i := 0 to 65000-1 do
        begin
            if buf[i] = #0 then
                begin
                    {$i-} writeln (arq, strPas(buf)); {$I+}
                    if ioresult <> 0 then;
                    goto fim;
                end
            else
            if (buf[i] = #$0d) or (buf[i] = #$0a) then break;
        end;

    i := 0;
    while buf[i] <> #$0 do
        begin
            s := '';
            while (buf[i] <> #$0a) and (buf[i] <> #$0) do
                begin
                    if buf[i] <> #$0d then
                        s := s + buf[i];
                    i := i + 1;
                    if (buf[i] = #$0d) or (buf[i] = #$0a) then break;
                end;

            if buf[i] <> #$0 then
                i := i + 1;

            {$i-} writeln (arq, strPas(buf)); {$I+}
            if ioresult <> 0 then;
            if (buf[i] = #$0d) or (buf[i] = #$0a) then break;
        end;

fim:
    {$I-} close (arq); {$I+}
    if ioresult <> 0 then;
    globalUnlock (hmem);
    closeClipboard;
end;

{-------------------------------------------------------------}
{       Gera txt a partir de um arquivo de imagem passando OCR
{-------------------------------------------------------------}

function converterImgToTxt (nomeArq: string): boolean;
var
    nomeProg, dirProg, dirArq, nomeArqTxt, s: string;
    txtNaAreaDeTransferencia: boolean;
    tempoEsperarFineReader, erro: integer;
begin
    converterImgToTxt := false;
    txtNaAreaDeTransferencia := false;
    dirArq := ExtractFileDir (nomeArq);

    nomeProg := pegarCaminhoFineReader;
    if nomeProg <> '' then
        begin
            nomeProg := '"' + nomeProg + '"';
            if (pos ('14\FINECMD.EXE"', uppercase(nomeProg)) <> 0) or (pos ('15\FINECMD.EXE"', uppercase(nomeProg)) <> 0) then
                begin
                    txtNaAreaDeTransferencia := true;
                    s := sintAmbiente ('DOSVOX', 'TEMPOESPERARFINEREADER', '3000'); ////Solução temporária, janela fecha antes do texto na área de transferência
                    val (s, tempoEsperarFineReader, erro);
                    if erro <> 0 then tempoEsperarFineReader := 3000;
                    nomeArqTxt := ChangeFileExt(nomeArq, '.txt');
                    nomeArq := '"' + nomeArq + '" /send Clipboard /quit';
                end
            else
                nomeArq := '"' + nomeArq + '" /out "' + ChangeFileExt(nomeArq, '.txt') + '" /quit';
            dirProg := dirArq;
        end
    else
        begin
            NomeProg := pegarCaminhoTesseract;
            if nomeProg= '' then exit;
            dirProg := ExtractFileDir (nomeProg);
            //Versão velha: cmd /C c:\winvox\Tesseract-ocr\tesseract.exe "d:\t\phototest.tif" "d:\t\phototest" --tessdata-dir=c:\winvox\tesseract-ocr -l por
            //cmd /C c:\winvox\Tesseract-ocr\tesseract.exe "d:\t\phototest.tif" "d:\t\phototest" -l por
            nomeArq := '/C ' + nomeProg + ' "' + nomeArq + '" "' + ChangeFileExt(nomeArq, '') + '" -l por';
            nomeProg := 'cmd';
        end;

    if executaProg (nomeProg, dirprog, nomeArq) >= 32 then
        begin
            esperaProgVoltar;
            while sintFalando do waitMessage;
            if txtNaAreaDeTransferencia then
                begin
                    if tempoEsperarFineReader > 0 then delay (tempoEsperarFineReader)
                    else //Se o tempo for 0 pede tecla.
                        begin
                            mensagem ( 'DV_TECLECCONT', 0);  {'Aperte a tecla C para continuar'}
                            readkey;
                            limpaBufTec;
                        end;

                    GravaAreaTransfNoArq (nomeArqTxt);
                end;
            converterImgToTxt := true;
        end
    else
        begin
            mensagem ( 'DV_ERROPRGEXE', 0); {'Erro na execução do programa '}
            sintSoletra ('OCR');
            writeln ('OCR.');
        end;
end;

{--------------------------------------------------------}
{       Chama a geração de txt com o OCR passando a posição do arquivo
{--------------------------------------------------------}

function passarOcr (i: integer): boolean;
var
    dirAtual, nomeArq: string;
begin
    passarOcr := false;
    nomeArq := PMySearchRec(listArquivos[i]).sr.FindData.cFileName;
    if podePassarOcr (nomeArq) then
        begin
            getdir (0, dirAtual);
            if dirAtual [length(dirAtual)] <> '\' then dirAtual := dirAtual + '\';
            mensagem ('DV_UMMOMENTO', 1);  {'Um momento...'}
            sintclek;
            if converterImgToTxt (dirAtual + nomeArq) then
                passarOcr := true;
            mensagem ('DV_OK', -1); {'Ok!'}

        end
    else
        begin
            sintbip;
            mensagem ('DV_ERRNAO', 0); {'Este arquivo não pode ser processado: '}
            delay (50);
            sintWriteLn (ExtractFileName(nomeArq));
            delay (50);
        end;
end;

{-------------------------------------------------------------}

begin
end.
