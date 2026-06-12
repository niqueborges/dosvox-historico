{
    VoxTube - utilitário de acessibilização do YouTube  ;

Funções auxiliares;

    Autores:
        Antonio Borges,
        Fabiano Ferreira,
        Glauco Constantino,
        Neno Albernaz,
        Patrick Barbosa;

    Versão 1.0 em Fevereiro de 2013;

    Versão 6.0 em Março de 2024;
}

unit vt_aux;

interface
function myFileSize(fileName: string): integer;
function subsCaracInvalidos (s: string) : string;
function linkReal (adescobrir: string) : string;
function GetDefaultBrowser: string;
procedure editarLerArquivo (nomearq: string; opcao: integer; paramExtra: string);
function GetTempFile: String;
function executaPrograma (nomeProg, nomeDir, nomeArq: string; visibJanela: integer): boolean;

implementation
uses
dvcrt,
dvwin,
dvexec,
sysutils,
windows,
shellapi,
pipe,
vt_msg;

function myFileSize(fileName: string): integer;
var
    arq: File;
begin
    assign (arq, filename);
    {$I-} reset (arq, 1); {$I+}
    if ioresult <> 0 then
         result := -1
    else
         result := filesize(arq);
    close (arq);
end;

function subsCaracInvalidos(s: string) : string;
begin
    s := stringReplace(s,'*','-',[rfreplaceall]);
    s := stringReplace(s,'/','-',[rfreplaceall]);
    s := stringReplace(s,':',' ',[rfreplaceall]);
    s := stringReplace(s,'"','''',[rfreplaceall]);
    s := stringReplace(s,'?',' ',[rfreplaceall]);
    s := stringReplace(s,'<',' ',[rfreplaceall]);
    s := stringReplace(s,'>',' ',[rfreplaceall]);
    s := stringReplace(s,'|',' ',[rfreplaceall]);
    result := trim(s);
end;

{--------------------------------------------------------}
{         pega o link de download do youtube
{--------------------------------------------------------}

function linkReal (adescobrir: string) : string;
var
    url : string;
    arqresult : text;
    nomearq : string;
    yt_dlp: string;
begin
    url := '';
    nomearq   := sintambiente('DOSVOX','PGMDOSVOX')+'\vturl';
    yt_dlp := sintambiente('DOSVOX','PGMDOSVOX')+'\yt-dlp.exe -f mp4 -g ';

    assignfile(arqresult,nomearq);

    shellexecute(hwnd(0),
            pchar('open'),pchar('cmd'),
            pchar('/c '+yt_dlp+'"' +
            adescobrir +'" >'+nomearq+' 2>&1'),
            pchar(''),sw_hide);
while processexists('cmd.exe') do delay(500);
            reset(arqresult);
            readln(arqresult, url);
                    closefile(arqresult);
    erase (arqresult);
    linkreal := url;
end;

function executaPrograma (nomeProg, nomeDir, nomeArq: string; visibJanela: integer): boolean;
var erro: integer;
begin
    executaPrograma := true;
    erro := executaProgEx (nomeProg, nomeDir, nomeArq, visibJanela);
    limpaBufTec;
    if erro < 32 then
        begin
            if erro = 2 then
                mensagem ('DV_PRGNAOENC', 0)        { 'Programa não encontrado.' }
            else
                begin
                    mensagem ('DV_ERROPRGCOD', 0);  { 'Erro na execução do programa: código ' }
                    sintWriteInt (erro);
                end;
            writeln;
            executaPrograma := false;
        end;
end;

function GetDefaultBrowser: string;
var
    tmp : PChar;
    res : PChar;
begin
    tmp := StrAlloc(255);
    res := StrAlloc(255);
    try
        GetTempPath(255,tmp);
        FileCreate(tmp+'htmpl.htm');
        FindExecutable('htmpl.htm',tmp,Res);
        Result := ExtractFilePath(res) + ExtractFileName(res);
        SysUtils.DeleteFile(tmp+'htmpl.htm');
    finally
        StrDispose(tmp);
        StrDispose(res);
    end;
end;

procedure editarLerArquivo (nomearq: string; opcao: integer; paramExtra: string);   { 0: Editar --- 1: Ler }
var
    nomeProg, nomeDir: string;

begin
    if opcao = 0 then
        begin
            nomeProg := sintAmbiente ('DOSVOX', 'EDITOR');
            if nomeProg = '' then nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\EDIVOX.EXE';
        end
    else
    if opcao = 1 then
        begin
            nomeProg := sintAmbiente ('DOSVOX', 'LEITOR');
            if nomeProg = '' then nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\LEVOX.EXE';
        end
    else
    if opcao = 2 then
        begin
            nomeProg := sintAmbiente ('DOSVOX', 'MINIED');
            if nomeProg = '' then nomeProg := '"' + sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\MINIED.EXE"';
        end;

    getdir (0, nomeDir);

    if pos (' ', nomeArq) <> 0 then
        nomeArq := '"' + nomeArq + '"';

    if paramExtra <> '' then
        nomeArq := nomeArq + ' ' + paramExtra;

    if opcao = 2 then nomeArq := '/d ' + nomeArq;
    if executaPrograma (nomeProg, nomeDir, nomeArq, SW_SHOWNORMAL) then
        esperaProgVoltar;
end;

function GetTempFile: String;
var
    tempFileName, tempPath: array[0..255] of Char;

begin
    getTempPath (255, tempPath);
    getTempFileName(tempPath, '$$$', 0, tempFileName);
    result := strPas (tempFileName);
end;

end.
