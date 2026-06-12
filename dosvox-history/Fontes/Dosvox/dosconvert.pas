{--------------------------------------------------------}
{
{       Converte arquivos para txt ou mp3
{
{       Autor: Neno Henrique da Cunha Albernaz - neno@intervox.nce.ufrj.br
{
{       Em 23/09/2018
{
{--------------------------------------------------------}

unit dosconvert;

interface

uses
    windows, sysutils, classes,
    dvcrt, dvwin, dvexec,
    dvform, dvarq,
    dosvars, dosgeral, dosmsg, dostxtToWav, dosImgToTxt;

function converterArquivo (posListArq: integer; pdf_com_ocr: boolean): boolean;

implementation

var
    mudo: boolean;
    nomeProgBlb2txt, nomeDicBlb2txt, nomeProgffmpeg: string;

{--------------------------------------------------------}
{       Retorna true se existir algum arquivo selecionado
{--------------------------------------------------------}

function temSelecionados: boolean;
var i: integer;
begin
    temSelecionados := false;
    for i := 0 to listArquivos.count-1 do
        if PMySearchRec(listArquivos[i]).marcado then
            begin
                temSelecionados := true;
                exit;
            end;
end;

{--------------------------------------------------------}
{       Pega o caminho do programa Blb2txt e verifica se ele existe no computador
{--------------------------------------------------------}

function pegarCaminhoBlb2txt (var nomeDic: string): string;
var nomeProg: string;
begin
    pegarCaminhoBlb2txt := '';
    nomeDic := '';
    nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\blb2txt.exe';
    if not fileExists (nomeProg) then
        begin
            nomeProg := 'c:\Winvox\blb2txt.exe';
            if not fileExists (nomeProg) then
                begin
                    mensagem ('DV_PRGNAOENC', 0); {'Programa não encontrado.'}
                    sintWriteln (' ' + 'Blb2txt.exe');
                    exit;
                end;
        end;
    pegarCaminhoBlb2txt := nomeProg;

    nomeDic := sintDirAmbiente + '\blb2txt.dic';
    if not fileExists (nomeDic) then
        begin
            nomeDic := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\blb2txt.Dic';
            if not fileExists (nomeDic) then
                begin
                    nomeDic := 'c:\Winvox\blb2txt.dic';
                    if not fileExists (nomeDic) then
                        begin
                            mensagem ('DV_DICBLB', 1); {'Arquivo blb2txt.dic não foi encontrado'}
                            nomeDic := '';
                        end;
                end;
        end;
end;

{--------------------------------------------------------}
{       Chama programa blb2txt que converte para txt.
{--------------------------------------------------------}

function chamaBlb2txt (nomeArq: string): boolean;
var
    nomeProg, nomeDic, dirArq, nomeArqTemp: string;
begin
    chamaBlb2txt := false;
    dirArq := ExtractFileDir (nomeArq);
    dirArq := '"' + dirArq + '"';
    nomeArqTemp := ansiUpperCase (nomeArq);
    nomeArq := '"' + nomeArq + '"';

    nomeProg := nomeProgBlb2txt;
    nomeDic := nomeDicBlb2txt;

    nomeProg := '"' + nomeProg + '" -f';
    nomeArq := nomeArq + ' -v ' + dirArq;
    if (copy(nomeArqTemp, length(nomeArqTemp)-4, 5 ) <> '.XLSX') and
       (copy(nomeArqTemp, length(nomeArqTemp)-4, 5 ) <> '.XLSM') and
       (copy(nomeArqTemp, length(nomeArqTemp)-3, 4 ) <> '.XLS') and
       (copy(nomeArqTemp, length(nomeArqTemp)-3, 4 ) <> '.ODS') then
        nomeArq := nomeArq + ' -rl -rh'
    else
        nomeArq := nomeArq + ' -rh'; //retirado o -rl Eliminar quebras de linha dentro de um parágrafo
    if nomeDic <> '' then
        nomeArq := nomeArq + ' -d ' + nomeDic;
    if executaProgEx (nomeProg, dirArq, nomeArq, SW_HIDE) >= 32 then
        begin
            esperaProgVoltar;
            while sintFalando do waitMessage;
            chamaBlb2txt := true;
        end;
end;

{--------------------------------------------------------}
{       Pega o caminho do ffmpeg e verifica se ele existe no computador.
{--------------------------------------------------------}

function pegarCaminhoffmpeg: string;
var nomeProg: string;
begin
    pegarCaminhoffmpeg := '';
    nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\ffmpeg.exe';
    if not fileExists (nomeProg) then
        begin
            nomeProg := 'c:\Winvox\ffmpeg.exe';
            if not fileExists (nomeProg) then
                begin
                    mensagem ('DV_PRGNAOENC', 0); {'Programa não encontrado.'}
                    sintWriteln (' ffmpeg.exe');
                    exit;
                end;
        end;
    pegarCaminhoffmpeg := nomeProg;
end;

{--------------------------------------------------------}
{       Chama o ffmpeg para converter para MP3 ou wav
{--------------------------------------------------------}

function chmaFfmpeg (nomeArq, nomeArqNovo: string): boolean;
var
    nomeProg, dirArq: string;
begin
    chmaFfmpeg := false;
    dirArq := ExtractFileDir (nomeArq);
    dirArq := '"' + dirArq + '"';

    nomeProg := nomeProgFfmpeg;

    nomeProg := '"' + nomeProg + '"-i';
    nomeArq := '"' + nomeArq + '" -ab 128000 -ac 2 "' + nomeArqNovo + '"';
    if executaProgEx (nomeProg, dirArq, nomeArq, SW_HIDE) >= 32 then
        begin
            esperaProgVoltar;
            while sintFalando do waitMessage;
            chmaFfmpeg := true;
        end;
end;

{----------------------------------------}
{   Testa se o arquivo é uma das extensões possíveis para ser gerado no novo formato
{   Para txt (33): azw, azw3, chm, djvu, doc, docx, ppt, pptx, pps, ppsx, epub, fb2, html, htm, lit, mht, mobi, odt, pdb, pdf, prc, rtf, tcr, wpd, xls, xlsx, xlsm, xlsm, ods, fb3, fbz, md, odp e wri.
{   Para mp3 (17): aac, aax, avi, mkv, webm, mp4, MPG, rm, rmvb, wav, wma, wmv, ogg, opus, mov, 3gp e m4a.
{   Para wav (1): mp3.
{   Para txt  passando OCR (7): jpg, jpeg, tif, tiff, gif, bmp e png.
{----------------------------------------}

function podeGerarNovo (nomeArq: string; var nomeArqNovo: string): boolean;
var
    ext, nomeArqTesta: string;
begin
    podeGerarNovo := false;
    nomeArqNovo := '';
    nomeArqTesta := '';
    ext := ansiUpperCase(extractFileExt(nomeArq));
    delete (ext, 1, 1);

    if (ext = 'DOCX') or
       (ext = 'PDF') or
       (ext = 'PPTX') or
       (ext = 'PPSX') or
       (ext = 'DOC') or
       (ext = 'PPT') or
       (ext = 'PPS') or
       (ext = 'EPUB') or
       (ext = 'HTML') or
       (ext = 'HTM') or
       (ext = 'RTF') or
       (ext = 'XLS') or
       (ext = 'XLSX') or
       (ext = 'XLSM') or
       (ext = 'AZW') or
       (ext = 'AZW3') or
       (ext = 'CHM') or
       (ext = 'DJVU') or
       (ext = 'FB2') or
       (ext = 'LIT') or
       (ext = 'MHT') or
       (ext = 'MOBI') or
       (ext = 'ODT') or
       (ext = 'PDB') or
       (ext = 'PRC') or
       (ext = 'TCR') or
       (ext = 'WPD') or
       (ext = 'FB3') or
       (ext = 'FBZ') or
       (ext = 'MD') or
       (ext = 'ODP') or
       (ext = 'WRI') or
       (ext = 'ODS') then
        nomeArqNovo := ChangeFileExt(nomeArq, '.txt') //Conversão com Blb2txt
    else
    if (ext ='AAC') or
       (ext = 'AAX') or
       (ext = 'AVI') or
       (ext = 'MKV') or
       (ext = 'WEBM') or
       (ext = 'MP4') or
       (ext = 'MPG') or
       (ext = 'RM') or
       (ext = 'RMVB') or
       (ext = 'WAV') or
       (ext = 'WMA') or
       (ext = 'WMV') or
       (ext = 'OGG') or
       (ext = 'OPUS') or
       (ext = 'MOV') or
       (ext = '3GP') or
       (ext = 'M4A') then
        nomeArqNovo := ChangeFileExt(nomeArq, '.mp3') //Conversão com FFMPEG
    else
    if ext = 'MP3' then
        nomeArqNovo := ChangeFileExt(nomeArq, '.wav') //Conversão com FFMPEG
    else
    if (ext = 'TXT') or (ext = 'TM3') or (ext = 'PAR') then
        nomeArqNovo := ChangeFileExt(nomeArq, '.TM3') //Gerar arquivo sintetizado
    else
    if podePassarOcr (nomeArq) then
        begin
            nomeArqNovo := ChangeFileExt(nomeArq, '.img'); //Geração de txt com programa OCR
            nomeArqTesta := ChangeFileExt(nomeArq, '.txt');
        end
    else
        exit;

    if nomeArqTesta = '' then nomeArqTesta := nomeArqNovo;
    if fileExists (nomeArqTesta) then
        begin
            if not mudo then sintBip;
        end
    else
        begin
            if not mudo then sintclek;
            podeGerarNovo := true;
        end;
end;

{--------------------------------------------------------}
{       Chama a rotina de gerar outro arquivo
{--------------------------------------------------------}

function converterUmArquivo (nomeArq: string; pdfToTxt_com_ocr: boolean): boolean;
var
    nomeArqNovo, ext: string;
    arq: text;
begin
    if not podeGerarNovo (nomeArq , nomeArqNovo) then
        begin
            if nomeArqNovo = '' then //extensão não permitida
                begin
                    mensagem ('DV_ERRNAO', 0); {'Este arquivo não pode ser processado: '}
//                    delay (50);
                    sintWriteLn (ExtractFileName(nomeArq));
//                    delay (50);
                    converterUmArquivo := false;
                end
            else //Retornou o nome, extensão permitida, mas arquivo já existe e não vai sobrescrever
                converterUmArquivo := true;
            exit;
        end;

    ext := ansiUpperCase(extractFileExt(nomeArqNovo));
    delete (ext, 1, 1);

    if (pdfToTxt_com_ocr and (ansiUpperCase(extractFileExt(nomeArq)) = '.PDF')) or (ext = 'IMG') then
        converterUmArquivo := converterImgToTxt (nomeArq)
    else
    if ext = 'TXT' then
        converterUmArquivo := chamaBlb2txt (nomeArq)
    else
    if (ext = 'MP3') or (ext = 'WAV') then
        converterUmArquivo := chmaFfmpeg (nomeArq, nomeArqNovo)
    else
    if ext = 'TM3' then
        begin
            nomeArqNovo := ChangeFileExt(nomeArqNovo, '.wav'); // troca de TM3 para WAV.
            if converterTxtToWav (nomeArq) then
                converterUmArquivo := converterUmArquivo (nomeArqNovo, false); //Converter o wav gerado para mp3
            assignFile (arq, nomeArqNovo);
            {$I-} erase (arq);  {$I-} //Apaga o arquivo wav
            if ioresult <> 0 then;
        end
    else
        converterUmArquivo := false;
end;

{--------------------------------------------------------}
{       Tratar tecla no processamento dos selecionados, retornar true para sair
{--------------------------------------------------------}

function tratarTeclaPrecionadaSaida (i, totalSelecionados: integer): boolean;
var c: char;
begin
    tratarTeclaPrecionadaSaida := false;
    if keyPressed then
        begin
            c := readkey;
            case upcase(c) of
                ' ', #$08: mudo := not mudo;
                'Q', ENTER, #0:
                begin
                    limpabuftec;
                    sintetiza (intToStr(i) + ' de ' + intToStr(totalSelecionados));
                end;
                ESC: begin
                        limpabuftec;
                        sintetiza (intToStr(i) + ' de ' + intToStr(totalSelecionados));
                        tratarTeclaPrecionadaSaida := true;
                     end;
            end;
            while sintFalando do waitMessage;
        end;
    limpaBufTec;
end;

{--------------------------------------------------------}
{       Converter um ou os arquivos selecionados
{--------------------------------------------------------}

function converterArquivo (posListArq: integer; pdf_com_ocr: boolean): boolean;
var
    i, totalSelecionados: integer;
    converterSelecionados: boolean;
    c: char;
    dirAtual: string;
begin
    converterArquivo := false;
    converterSelecionados := false;
    mudo := false;
    mensagem ('DV_CONVARQ', 1); {'Conversor de formatos'}
    if temSelecionados then
        begin
            repeat
                if wherex <> 0 then writeln;
                mensagem ('DV_VARSEL', 1); {'Vários arquivos estão selecionados, processo todos? '}
                c := popupMenuPorLetra('SN');
            until c in ['S', 'N', ESC];
            if c = ESC then
                begin
                    mensagem ('DV_OPCANCEL', 2);    { 'Certo, operação foi cancelada' }
                    exit;
                end;
            converterSelecionados := c = 'S';
        end;

    nomeProgBlb2txt := pegarCaminhoBlb2txt (nomeDicBlb2txt);
    nomeProgFfmpeg := pegarCaminhoffmpeg;

    getdir (0, dirAtual);
    if dirAtual [length(dirAtual)] <> '\' then dirAtual := dirAtual + '\';

    mensagem ('DV_UMMOMENTO', 1);  {'Um momento...'}
    if not converterSelecionados then
        begin
            if converterUmArquivo (dirAtual + PMySearchRec(listArquivos[posListArq]).sr.FindData.cFileName, pdf_com_ocr) then
                converterArquivo := true
        end
    else
        begin
            totalSelecionados := totalDeItensSelecionados (listArquivos);
            for i := 0 to listArquivos.count-1 do
                begin
                    if PMySearchRec(listArquivos[i]).marcado then
                        if not converterUmArquivo (dirAtual + PMySearchRec(listArquivos[i]).sr.FindData.cFileName, pdf_com_ocr) then
                            break;
                    if tratarTeclaPrecionadaSaida (i + 1, totalSelecionados) then break;
                    converterArquivo := true
                end;
        end;

    limpabuftec;
    if wherex <> 1 then writeln;
    mensagem ('DV_OK', -1); {'Ok!'}
end;

{--------------------------------------------------------}

begin
end.
