{-------------------------------------------------------------}
{
{           Gerador de vários formatos para  txt
{
{       Autor: Neno Henrique da Cunha Albernaz
{
{       Em 09 de Agosto de 2017
{
{-------------------------------------------------------------}

unit edBlbTxt;

interface

uses
    windows,
    dvcrt,
    sysutils,
    dvwin,
    dvexec,
    dvForm,
    edMensag,
    edVars;

function chamaBlb2txt (nomeArq: string): boolean;
function converteArquivoParaTxt (nomeArq: string): string;

implementation

{--------------------------------------------------------}
{       Extrai o diretório do nome de um arquivo
{--------------------------------------------------------}

function retornaDiretorio (nomeArq: string): string;
var p, i: integer;
begin
    retornaDiretorio := '';
    p := length(nomeArq) - 1;
    for i := p downto 1 do
        if (nomeArq[i] = '\') or (nomeArq[i] = '/') then
            begin
                retornaDiretorio := copy (nomeArq, 1, i);
            break;
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
    dirArq := retornaDiretorio(nomeArq);
    dirArq := '"' + dirArq + '"';
    nomeArqTemp := ansiUpperCase (nomeArq);
    nomeArq := '"' + nomeArq + '"';

    nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\blb2txt.exe';
    if not fileExists (nomeProg) then
        begin
            nomeProg := 'c:\Winvox\blb2txt.exe';
            if not fileExists (nomeProg) then
                begin
                    fala ('EDBLBNAO'); {'Conversor Blb2txt não foi encontrado'}
                    exit;
                end;
        end;

    nomeDic := sintDirAmbiente + '\blb2txt.dic';
    if not fileExists (nomeDic) then
        begin
            nomeDic := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\blb2txt.dic';
            if not fileExists (nomeDic) then
                begin
                    nomeDic := 'c:\Winvox\blb2txt.dic';
                    if not fileExists (nomeDic) then
                        begin
                            fala ('EDDICBLB'); {'Arquivo blb2txt.dic não foi encontrado'}
                            nomeDic := '';
                        end;
                end;
        end;

    nomeProg := '"' + nomeProg   + '" -f';
    nomeArq := nomeArq + ' -v ' + dirArq;
    if (copy(nomeArqTemp, length(nomeArqTemp)-4, 5 ) <> '.XLSX') and
       (copy(nomeArqTemp, length(nomeArqTemp)-3, 4 ) <> '.XLS') and
       (copy(nomeArqTemp, length(nomeArqTemp)-4, 5 ) <> '.XLSM') and 
       (copy(nomeArqTemp, length(nomeArqTemp)-3, 4 ) <> '.ODS') then
        nomeArq := nomeArq + ' -rl -rh'
    else
        nomeArq := nomeArq + ' -rh'; //retirado o -rl Eliminar quebras de linha dentro de um parágrafo
    if nomeDic <> '' then
        nomeArq := nomeArq + ' -d ' + nomeDic;
    if executaProgEx (nomeProg, dirArq, nomeArq, SW_SHOWMINIMIZED) >= 32 then // SW_SHOWMINIMIZED não deixa perder o foco no Windows 11.
        begin
            esperaProgVoltar;
            while sintFalando do waitMessage;
            chamaBlb2txt := true;
        end;
    sintBip; sintbip;
end;

{----------------------------------------}
{   Testa se o arquivo é uma das extensões possíveis,  se for transforma em txt
{   São elas: azw, azw3, chm, djvu, doc, docx, ppt, pptx, pps, ppsx, epub, fb2, html, htm, lit, mht, mobi, odt, pdb, pdf, prc, rtf, tcr, wpd, xls, xlsx, xlsm, ods, fb3, fbz, odp e wri.
{----------------------------------------}

function converteArquivoParaTxt (nomeArq: string): string;
var
    nomeArqTemp, ext: string;
    c: char;
begin
    converteArquivoParaTxt := nomeArq;
    ext := ansiUpperCase(extractFileExt(nomeArq));
    delete (ext, 1, 1);
    if (ext <> 'DOCX') and
       (ext <> 'PDF') and
       (ext <> 'PPTX') and
       (ext <> 'PPSX') and
       (ext <> 'DOC') and
       (ext <> 'PPT') and
       (ext <> 'PPS') and
       (ext <> 'EPUB') and
       (ext <> 'HTML') and
       (ext <> 'HTM') and
       (ext <> 'RTF') and
       (ext <> 'XLS') and
       (ext <> 'XLSX') and
       (ext <> 'XLSM') and
       (ext <> 'AZW') and
       (ext <> 'AZW3') and
       (ext <> 'CHM') and
       (ext <> 'DJVU') and
       (ext <> 'FB2') and
       (ext <> 'LIT') and
       (ext <> 'MHT') and
       (ext <> 'MOBI') and
       (ext <> 'ODT') and
       (ext <> 'PDB') and
       (ext <> 'PRC') and
       (ext <> 'TCR') and
       (ext <> 'WPD') and
       (ext <> 'FB3') and
       (ext <> 'FBZ') and
       (ext <> 'ODP') and
       (ext <> 'WRI') and
       (ext <> 'ODS') then exit;

    nomeArqTemp := nomeArq;
    nomeArq := ChangeFileExt(nomeArq, '.txt');
    if fileExists (nomeArq) then
        begin
            repeat
                fala ('EDREESCR'); {'Arquivo já existe, reescreve (s/n) ?'}
                c := popupMenuPorLetra ('SNO');
            until c in ['S', 'N', 'O', ENTER, ESC];
            if c = 'O' then exit; //Abre o arquivo original sem con verter
            if c = 'N' then
                begin
                   converteArquivoParaTxt := nomeArq;
                    exit;
                end;
        end
    else
    if uppercase(sintAmbiente('EDIVOX', 'SEMPRECONVERTERPARATXT', 'NAO')[1]) = 'S' then
        c := 'S'
    else
    repeat
        fala ('EDDESCON'); {'Deseja tentar converter o arquivo para TXT? '}
        c := popupMenuPorLetra ('SNO');
    until c in ['S', 'N', 'O', ENTER, ESC];

    if c = ESC then
        begin
           converteArquivoParaTxt := '';
            exit;
        end;
    if c = 'N' then
        exit;

    fala ('EDAGUARD'); {'Aguarde ...'}

    if chamaBlb2txt (nomeArqTemp)then
        converteArquivoParaTxt := nomeArq
    else
        converteArquivoParaTxt := '';
    limpaBufTec;
end;

{--------------------------------------------------------}
begin
end.
