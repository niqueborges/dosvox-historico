{------------------------------------------------------------------------------}
{
{                                  SCB.PAS
{
{    Script Beautifier - Conversor de Scripts
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Autor:      Oswaldo Vernet
{    Data:       21/08/2015
{    Alterações: 29/03/2016
{
{------------------------------------------------------------------------------}

program scb;

uses
    sysUtils, classes, windows, dvwin, dvcrt, interp;

{--------------------------------------------------------}
{            Variáveis globais
{--------------------------------------------------------}

label
    usage;

var
    quiet      : boolean;
    script     : string;
    nconverted : integer;

{--------------------------------------------------------}
{            Escreve ou fala as mensagens
{--------------------------------------------------------}

procedure issue (msg : string);
var
    sameline : boolean;
begin
    sameline := msg[length(msg)] in ['?', ':'];

    if quiet then
        if sameline then
            write (msg + ' ')
        else
            writeln (msg)
    else
        if sameline then
            sintWrite (msg + ' ')
        else
            sintWriteln (msg)
end;

{--------------------------------------------------------}
{            Converte um script
{--------------------------------------------------------}

procedure convert (src, dst : string);
label
    finish;
var
    s                        : integer;
    answer, nameSrc, nameDst : string;
begin
    nameSrc := ExtractFileName (src);
    nameDst := ExtractFileName (dst);

    writeln ('Convertendo ' + nameSrc + ' para ' + nameDst);

    s := loadScript (src);

    if s < 0 then
    begin
        issue ('Script ' + nameSrc + ' não encontrado');
        exit
    end;

    if FileExists (dst) then
    begin
        issue ('O script ' + nameDst + ' já existe. Sobrescreve?');

        if quiet then
            readln (answer)
        else
            sintReadln (answer);

        answer := LowerCase (answer);

        if not (answer[1] in ['s', 'y']) then
            goto finish
    end;

    beautifyScript (s, dst);
    INC (nconverted);

finish:
    freeScript (s)
end;

{--------------------------------------------------------}
{            Percorre uma subárvore
{--------------------------------------------------------}

procedure explore (src, dst : string);
var
    s : TSearchRec;
begin
    if not DirectoryExists (dst) then
        mkdir (dst);

    if FindFirst (src + '\*.*', faDirectory, s) = 0 then
    begin
        repeat
            if (s.name <> '.') and (s.name <> '..') then
            begin
                if (s.Attr and faDirectory) <> 0 then
                    explore (src + '\' + s.name, dst + '\' + s.name)
                else if copy (s.name, length (s.name) - 3, 4) = '.cmd' then
                    convert (src + '\' + s.name, dst + '\' + copy (s.name, 1, length (s.name) - 4) + '.pro')
            end
        until FindNext (s) <> 0
    end
end;

{--------------------------------------------------------}
{            Realiza o processamento
{--------------------------------------------------------}

procedure process (path : string);
var
    answer   : string;
    dir      : boolean;
    src, dst : string;
begin
    src := ''; dst := ''; dir := false;

    path := ExpandFileName (path);

    if DirectoryExists (path) then
    begin
        dir := true;
        src := path;
        dst := path + '-PRO'
    end
    else if FileExists (path) then
    begin
        if copy (path, length (path) - 3, 4) = '.cmd' then
        begin
            src := path;
            dst := copy (path, 1, length (path) - 4) + '.pro'
        end
        else begin
            issue ('O arquivo dado NÃO tem extensão .cmd')
        end
    end
    else if copy (path, length (path) - 4, 4) = '.cmd' then
    begin
        issue ('O arquivo ' + path +  ' NÃO existe')
    end
    else if FileExists (path + '.cmd') then
    begin
        src := path + '.cmd';
        dst := path + '.pro'
    end
    else begin
        issue ('O arquivo ' + ExtractFileName (path) + ' NÃO existe');
        issue ('Fim do programa. Tecle ENTER.');
        readln;
        exit
    end;

    nconverted := 0;

    if dir then
    begin
        issue ('Diretório fonte: '   + ExtractFileName (src));
        issue ('Diretório destino: ' + ExtractFileName (dst));

        issue ('Realiza a conversão?');

        if quiet then
            readln (answer)
        else
            sintReadln (answer);

        answer := LowerCase (answer);

        if answer[1] in ['s', 'y'] then
            explore (src, dst)
    end
    else begin
        convert (src, dst)
    end;

    if nconverted > 0 then
        issue (intToStr (nconverted) + ' arquivos convertidos. Tecle ENTER para finalizar.')
    else
        issue ('Nenhuma conversão realizada. Tecle ENTER para finalizar.');
    readln
end;

{--------------------------------------------------------}
{       Programa Principal do Script Beautifier
{--------------------------------------------------------}

begin
    sintInic (0, sintAmbiente ('SCRIPVOX', 'DIRSCRIPVOX'));

    clrscr; setWindowText (crtWindow, 'SCB');
    sintWriteln ('Script Beautifier - Conversor de Scripts');
    writeln;

    quiet := false;

    case ParamCount of
        0:      begin
                    issue ('Nome do arquivo .CMD ou diretório a converter:');
                    sintReadln (script);
                    process (script)
                end;
        1:      begin
                    process (ParamStr (1))
                end;
        2:      begin
                    if LowerCase (ParamStr (1)) = 'mudo' then
                    begin
                        quiet := true;
                        process (ParamStr (2))
                    end
                    else goto usage
                end
        else    goto usage
    end;

    exit;

usage:
    sintWriteln ('Programa SCB - Conversor de Scripts CMD para PRO.');
    sintWriteln ('Modo de usar: scb script ou diretório.');
    sintWriteln ('Se não quiser ouvir as mensagens: scb MUDO script ou diretório.');
    sintWriteln ('Tecle ENTER para fechar a janela.');
    readln
end.
