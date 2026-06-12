unit miparam;
interface

Uses
    Classes,
    mivars,
    miplaylist,
    SysUtils;

procedure trataParametros;
procedure varreDiretorio(dir: String);

implementation

{--------------------------------------------------------}
{ Varre diretório procurando por arquivos de multimidia
{--------------------------------------------------------}

procedure varreDiretorio(dir: String);
var
    arqRes: TSearchRec;
    i: integer;

begin
    if FindFirst(dir+'\*.M3U', faAnyFile, arqRes) = 0 then
    begin
        repeat
            abreplaylist(dir+'\'+arqRes.Name);
        until FindNext(arqRes) <> 0;
        FindClose(arqRes);
    end;

    for i := 0 to extensoes.count-1 do
        begin
            if FindFirst(dir+'\*'+extensoes[i], faAnyFile, arqRes) = 0 then
            begin
                repeat
                    playlist.add(dir+'\'+arqRes.Name);
                until FindNext(arqRes) <> 0;
                FindClose(arqRes);
            end;
        end;
end;

{--------------------------------------------------------}
{                   Trata o parametro
{--------------------------------------------------------}

procedure trataParametros;
var
    i,p: integer;
    dir, parametro:String;
    ext: String;

begin
    getdir(0,dir);
    if dir[length(dir)] = '\' then
        delete(dir, length(dir),1);

    playlist.Clear;
    for i:= 1 to paramCount do
        begin
            parametro:= paramStr(i);

            if pos('\',parametro) = 0 then
                parametro := dir + '\' + parametro;

            if DirectoryExists(parametro) then
                varreDiretorio(parametro)
            else
                begin
                    p := LastDelimiter('.',parametro);
                    ext := copy(parametro, p, length(parametro));
                end;

            if UpperCase(ext) = '.M3U' then
                abreplaylist(parametro)
            else
            if UpperCase(ext) <> '' then
                playlist.add(parametro);
        end;
end;

end.
