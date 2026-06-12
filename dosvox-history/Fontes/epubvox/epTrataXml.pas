unit epTrataXml;
interface

uses

    DvCrt,
    DvWin,
    Dvexec,
    Dvform,
    STRUTILS,
    windows,
    LibXmlParser,
    Classes,
    SysUtils,
    LZExpand,
    epmsg,
    epvars,
    epTrataHTML;

procedure carregaOPF;
procedure processaEPUB(endereco: string);

var
    destino: string;
implementation

{--------------------------------------------------------}
{            Descobre diretório de trabalho
{--------------------------------------------------------}

function GetTempDir: string;
var
  Buffer: array[0..512] of Char;
  saida: string;

begin
    GetTempPath(512,Buffer);
    saida := StrPas(Buffer);
    if saida[length(saida)] <>'\' then saida := saida+'\';
    Result := saida;
end;

{--------------------------------------------------------}
{       Descompacta arquivo .ZIP
{--------------------------------------------------------}

procedure copiaImagens (imgDir: string);
var
    i: integer;
    b: string;
begin
    for i:=0 to length(manifest)-1 do
        begin
            if pos('IMAGE',trim(uppercase(manifest[i].media_type)))>0 then
            begin
                b := imgDir+'\'+ExtractFileName(manifest[i].href);
                try
                    CopyFile(pchar(dirConteiner+manifest[i].href),pchar(b),false);
                except
                end;
            end;
        end;
end;

{--------------------------------------------------------}
{        Encontra o caminho do content.opf
{--------------------------------------------------------}

procedure carregaRootFile;
var
    Parser : TXmlParser;

begin
    oebps := false;

    Parser := TXmlParser.Create;
    Parser.Normalize := TRUE;
    Parser.LoadFromFile (destino+'\META-INF\container.xml');
    Parser.StartScan;

    while Parser.Scan DO
        begin
            if parser.curName ='rootfile' then
                container_rootfile  := Parser.CurAttr.Value('full-path');
        end;

    if container_rootfile[1] <> '\' then
        container_rootfile := '\'+container_rootfile;

    container_rootfile := trocaBarra(destino+container_rootfile);
    dirConteiner := ansiUpperCase(ExtractFilePath(container_rootfile));
    Parser.Free;
end;

{--------------------------------------------------------}
{       Descompacta arquivo .ZIP
{--------------------------------------------------------}

function descompactaZip (nomeZip: string): boolean;
var
    dirDosvox: string;
    extrator: String;
begin
    result := false;

    dirDosvox := sintAmbiente ('DOSVOX', 'PGMDOSVOX');
    if dirDosvox = '' then
        dirDosvox := 'c:\winvox';
    extrator := '"' + dirDosvox + '\unzip.exe" -o';
    destino := GetTempDir+nomeCurLivro;

    if not DirectoryExists(GetTempDir+nomeCurLivro) then
            ForceDirectories(GetTempDir+nomeCurLivro);

    sintClek;

    if executaProgEX (extrator,destino, nomeZip, SW_SHOWMINIMIZED) > 32 then {> 32 significa execução bem sucedida.}
        begin
            esperaProgAtivar;
            esperaProgVoltar;
            result := true;

        end
    else
        mensagem('EPERRODC',1); {   Descompactador não pôde ser executado.   }

end;

{--------------------------------------------------------}
{       Renomeia Epub para zip
{--------------------------------------------------------}

function renomeiaEPUB(s: string): boolean;
var
    Arq : TextFile;
    p: string;

begin
    result := true;
    p := GetTempDir+nomeCurLivro+'.zip';
    if copy(p,0,1) <> '"' then p := '"'+p;
    if copy(p,length(p)-1,length(p)) <> '"' then p := p+'"';

    AssignFile(Arq,s) ;

    if ansiuppercase(extCurLivro) = '.EPUB' then
        begin
            if CopyFile(pchar(s), pchar(GetTempDir+nomeCurLivro+'.zip'), false) then
                begin
                    if not descompactaZip(p) then
                    begin
                        mensagem('EPERRORZ',2); {  'Erro na extração do arquivo'  }
                        result := false;
                    end;
                    if descompactaZip(p) then
                        DeleteFile(Pchar(GetTempDir+nomeCurLivro+'.zip'));
                end
            else
                begin
                    mensagem('EPERRORC',2); {    'Erro ao copiar dados do arquivo'  }
                    result := false;
                end;
        end
    else
        begin
            mensagem('EPERRORE',2); {    'Tipo de arquivo não suportado'  }
            result := false;
        end;
end;

{--------------------------------------------------------}
{                        Abre opf
{--------------------------------------------------------}

procedure carregaOPF;
var
    Parser : TXmlParser;
    i, j, k: integer;

begin
    Parser := TXmlParser.Create;

    Parser.Normalize := TRUE;

    Parser.LoadFromFile (container_rootfile);

    Parser.StartScan;

    i := 0;
    j := 0;
    k := 0;
    status := FECHADA;
    while Parser.Scan DO
        begin
/// carrega tag package
            if ansiupPercase(parser.curName) ='PACKAGE' then
                begin
                    with Parser.CurAttr do
                        begin
                            PPackage.xmlns := Value('xmlns');
                            PPackage.unique_identifier := Value('unique-identifier');
                            PPackage.version := Value('version');
                        end;
                end;
///  carrega tag metadata
            if ansiupPercase(parser.curName) ='META' then
                begin
                    with Parser.CurAttr do
                        begin
                            PMeta.name := Value('name');
                            PMeta.content := Value('content');
                        end;
                end;
///  carrega tag manifest
            if ansiupPercase(parser.curName) ='ITEM' then
                begin
                    SetLength(manifest,i+1);
                    with Parser.CurAttr do
                        begin
                            PItem.href := trocaBarra(Value('href'));
                            PItem.id := Value('id');
                            PItem.media_type := Value('media-type');
                            manifest[i]:=PItem;
                        end;
                        i := i+1;
                end;
///  carrega tag spine
            if ansiupPercase(parser.curName) ='ITEMREF' then
                begin
                    SetLength(spine,j+1);
                    with Parser.CurAttr do
                        begin
                            PItemref.ordem := inttostr(j);
                            PItemref.idref := Value('idref');
                            spine[j]:=PItemRef;
                        end;
                        j := j+1;
                end;
///  carrega tag guide
            if ansiupPercase(parser.curName) ='REFERENCE' then
                begin
                    SetLength(guide,k+1);
                    with Parser.CurAttr do
                        begin
                            PReference.href := trocaBarra(Value('href')) ;
                            PReference.title := Value('title');
                            PReference.type_ := Value('type');
                            guide[k]:=PReference;
                        end;
                        k := k+1;
                end;

        end;

    Parser.Free;
end;

{--------------------------------------------------------}
{              Descobre qual html do tipo toc
{--------------------------------------------------------}

procedure descobreToc;
var
    i: integer;
begin
    for i:=0 to length(guide)-1 do
        if guide[i].type_ = 'toc' then
                hrefToc := guide[i].href;

    if Pos('#',hrefToc)>0 then
        hrefToc := copy(hrefToc,1,pos('#',hrefToc)-1);
end;
{--------------------------------------------------------}
{                       Abre NCX
{--------------------------------------------------------}

procedure carregaNCX;
var
    Parser : TXmlParser;
    i,j: integer;
    docTitleAberto, navpointAberto: boolean;

begin
    docTitleAberto := false; // false = fechado
    navpointAberto := false;

    Parser := TXmlParser.Create;

    Parser.Normalize := TRUE;

    Parser.LoadFromFile (ExtractFilePath(container_rootfile)+'\toc.ncx');

    Parser.StartScan;
    i := 0;
    j := 0;
    while Parser.Scan DO
        begin

            if ansiupPercase(parser.curName) = 'DOCTITLE' then
                docTitleAberto := not docTitleAberto;

            if ansiupPercase(parser.curName) = 'NAVPOINT' then
                navpointAberto := not navpointAberto;

/// carrega tag ncx
            if ansiupPercase(parser.curName) = 'META' then
                begin
                    with Parser.CurAttr do
                        begin
                            SetLength(head,i+1);
                            PDTB.content := Value('content');
                            PDTB.name := Value('name');
                            head[i] := PDTB;
                        end;
                        i := i+1;
                end;

/// carrega tag NAVPOINT
            if (ansiupPercase(parser.curName) = 'NAVPOINT') AND (Parser.CurPartType <> ptendTag) then
                begin
                    SetLength(navmap,j+1);
                    with Parser.CurAttr do
                        begin
                            PNavPoint.class_ := Value('class');
                            PNavPoint.id := Value('id');
                            PNavPoint.playorder := Value('playOrder');
                            navMap[j] := PNavPoint;
                        end;
                end;

/// carrega tag text em doctitte ou navMap
            if (ansiupPercase(parser.curName) = 'TEXT') AND (Parser.CurPartType = ptContent) then
                begin
                    if docTitleAberto then 
                                title := Parser.CurContent
                    else
                        begin
                            PNavPoint.navLabel := Parser.CurContent;
                            navMap[j] := PNavPoint;
                        end;
                end;

            if ansiupPercase(parser.curName) = 'CONTENT' then
                begin
                    with Parser.CurAttr do
                        PNavPoint.content_src := Value('src');
                    navMap[j] := PNavPoint;
                    j := j+1;
                end;
        end;
    Parser.Free;
end;

{--------------------------------------------------------}
{               Deletar diretório
{--------------------------------------------------------}

procedure DeleteFolder(DirName: TFileName);
var
    Error: Integer;
    FileSearch: TSearchRec;
begin
    if DirName[Length(DirName)] <> '\' then DirName := DirName + '\';
    Error := FindFirst(DirName + ' . ', faAnyFile, FileSearch);
    try
        with FileSearch do
        while (Error = 0) do
            begin
                if (DirName + Name <> '.') and (DirName + Name <> '..') then
                    SysUtils.DeleteFile(DirName + Name);
                Error := FindNext(FileSearch);
            end;
    finally
        FindClose(FileSearch);
end;
    RemoveDir(DirName);
end;

{--------------------------------------------------------}
{         Organiza o carregamento de dados
{--------------------------------------------------------}

procedure processaEPUB(endereco: string);
var
   imgDir, tempDir: string;
label ignoraImagens;
begin
    mensagem('EPPROCES',2); { Extraindo arquivo EPUB  }
    if renomeiaEPUB(endereco) then
        begin
            carregaRootFile;
            carregaOPF;

            if processaImagem then
                begin
                    mensagem('EPEXTIMG',2); { Extraindo as imagens  }
                    imgDir := ExtractFilePath(localSaida)+'IMAGEM_'+novoNomeLivro;
                    if not DirectoryExists(imgDir) then
                        begin
                             {$I-} mkdir(imgDir);  {$I+}
                             if ioresult <> 0 then
                                 begin
                                    {$I-} ForceDirectories(imgDir); {$I+}
                                    if ioresult <> 0 then
                                        goto ignoraImagens;
                                 end;
                        end;

                    copiaImagens (imgDir);
                end;

ignoraImagens:
            tempDir := getTempDir+nomeCurLivro;
            if copy(tempDir,0,1) <> '"' then tempDir := '"'+tempDir;
            if copy(tempDir,length(tempDir)-1,length(tempDir)) <> '"' then tempDir := tempDir+'"';

            DeleteFolder(tempDir);
            descobreToc;
            carregaNCX;
            criaTXT(caminhoCurLivro);

            mensagem('EPLOCALS',1); { 'Livro salvo em: ' }
            sintwriteln(localSaida);
            writeln;
            mensagem('EPFPROCE',2); { Fim da extração }
    end;
end;

end.
