unit cdDir;

interface

uses dvCrt, dvWin, dvArq,
    windows, sysUtils, classes, shellapi,
    cdMsg;

procedure infTamDir (dir: string);

implementation

{--------------------------------------------------------}

function GetDirSize(dir: string; subdir: Boolean; var numSub, numArq: integer): int64;
var
    rec: TSearchRec;
    found: int64;
begin

    Result := 0;

    if dir[Length(dir)] <> '\' then dir := dir + '\';

    found := FindFirst(dir + '*.*', faAnyFile, rec);
    while found = 0 do
        begin
            Inc(Result, rec.Size);
            if (rec.Attr and faDirectory > 0) and (rec.Name[1] <> '.') and (subdir = True) then
                begin
                    inc (numSub, 1);
                    Inc(Result, GetDirSize(dir + rec.Name, True, numSub, numArq));
                end
            else
            if  rec.Name[1] <> '.' then
                inc (numArq, 1);
            found := FindNext(rec);
        end;
    FindClose(rec);
end;

{--------------------------------------------------------}

procedure infTamDir(dir: string);
var
    numSubDir, numArq: longInt;
    tamanho: int64;
    medida: string;
    decimal: longint;
begin

    numSubDir := 0;
    numArq := 0;

    tamanho:= GetDirSize(dir, true, numSubDir, numArq);
    medida:= '';

    if tamanho >= 65536 then
        begin
            medida := 'K';
            decimal := tamanho mod 1024;
            tamanho := tamanho div 1024;
            if decimal > 512 then tamanho := tamanho + 1;
        end;
    if tamanho >= 65536 then
        begin
            medida := 'MB';
            decimal := tamanho mod 1024;
            tamanho := tamanho div 1024;
            if decimal > 512 then tamanho := tamanho + 1;
        end;
    if tamanho = 0 then
    begin
        sintCarac ('0');    // corrige erro no sintetizador L&H
        writeln ('0');
    end
    else
        begin
            sintWriteInt (tamanho);
            write (' ');
            sintWriteln ( medida);
        end;

    if medida = 'MB' then
        if tamanho > 702 then
        begin
            sintBip; sintBip; sintBip;
            mensagem ('CDATEESG', 1); {'Atenção! A capacidade para midia de CD está esgotada'}
        end;

    delay (200);
    mensagem ('CDNUMARQ', 0); {'Número de arquivos --- ')}
    sintWriteInt (numArq);
    writeln;

    delay (200);
    mensagem ('CDNUMSUB', 0); {'Número de subdiretórios --- ')}
    sintWriteInt (numSubDir);
    writeln;

end;

end.
