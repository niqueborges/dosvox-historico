unit dosgrava;

interface

uses
    windows, sysutils, classes,
    dvcrt, dvwin, dvform,
    dvcdrec, dosmsg,
    dosVars;

procedure gravaMidia;
function DirSize(const ADirName : string; ARecurseDirs: boolean): int64;

implementation

{--------------------------------------------------}

function DirSize(const ADirName : string;
                 ARecurseDirs: boolean): int64;
const FIND_OK = 0;
var
    iResult : integer;

    procedure _RecurseDir(const ADirName : string);
    var sDirName : string;
        rDirInfo : TSearchRec;
        iFindResult : int64;
    begin
        sDirName := IncludeTrailingPathDelimiter(ADirName);
        iFindResult := FindFirst(sDirName + '*.*',faAnyFile,rDirInfo);

        while iFindResult = FIND_OK do
            begin
                if ((rDirInfo.Name <> '.') and (rDirInfo.Name <> '..')) then
                    begin
                        if (rDirInfo.Attr and faDirectory = faDirectory) and
                            ARecurseDirs then
                                _RecurseDir(sDirName + rDirInfo.Name) // Keep Recursing
                        else
                            inc(iResult, rDirInfo.Size);             // Accumulate Sizes
                    end;

                iFindResult := FindNext(rDirInfo);
                if iFindResult <> FIND_OK then FindClose(rDirInfo);
            end;
    end;

begin
    iResult := 0;
    _RecurseDir(ADirName);
    Result := iResult;
end;

{--------------------------------------------------}

procedure gravaMidia;

var i, ndrives, indGrav: integer;
    sl: TStringList;
    dir, nomeDisco, unidsLogs: string;
    c, c2: char;
    unidLogs: shortString;
    tamGrav: integer;

label
    fim, desistiu, problemas;
begin
    writeln;
    mensagem ('DV_GMIDIA', 2);  {'Gravação de mídia'}

    dir := '';
    mensagem ('DV_DIRGCD', 1);  {'Informe o nome do diretorio a gravar (aperte ENTER se for o atual)'}
    c := sintEdita(dir, wherex, wherey, 80, true);
    if dir = '' then
        getDir (0, dir);
    writeln (dir);

    tamGrav := dirSize(dir, true);
    mensagem ('DV_TAMGRM', 0);  {'Tamanho de gravação em MB: '}
    sintWriteInt (tamGrav div (1024*1024));
    writeln;
    mensagem ('DV_CONFIRMA', 0);    {'Confirma? '}
    c := popupMenuPorLetra('SN');
    if (c = ESC) or (upcase(c) = 'N') then
         begin
              mensagem ('DV_DESIST', 1);    {'Desistiu...'}
              exit;
         end;

    if not inicializaCD then
        begin
            mensagem ('DV_PROBLG', 2);  {'Problemas no processo de gravação'}
            exit;
        end;

    { descobrindo drives disponíveis}

    unidsLogs := pegaUnidsCD;
    sl := listaDrivesCD;
    ndrives := sl.count;

    writeln;
    if ndrives = 1 then
        begin
            indgrav := 0;
            mensagem ('DV_UNGRAV', 0);  {'Unidade de gravação (Aperte interrogação para detalhes): '}
            sintSoletra (unidsLogs[1]);
            writeln (unidsLogs[1]);
        end
    else
        begin
            repeat
                mensagem ('DV_LUNGRV', 0);  {'Qual a unidade de gravação? '}
                write ('(', unidsLogs,'): ');
                sintSoletra (unidsLogs);
                sintLeTecla (c, c2);
                writeln;

                if c = '?' then
                    for i:= 0 to sl.count-1 do
                        begin
                            sintSoletra (unidsLogs[i+1]);
                            writeln (unidsLogs[i+1]);
                            sintWriteln ('  '+ sl[i]);
                        end;
            until c <> '?';

            if c = ENTER then
                begin
                    c := unidLogs[0];
                    sintWriteln (c);
                end;
            if c = ESC then goto desistiu;

            writeln;

            indGrav := pos (upcase(c), unidsLogs) - 1;
            if indGrav < 0 then goto desistiu;
        end;

    sl.Free;

    nomeDisco := '';
    mensagem ('DV_NOMECD', 0);  {'Informe o nome do CD a gravar (12 letras): '}
    c := sintEdita(nomeDisco, wherex, wherey, 12, true);
    if c = ESC then goto desistiu;

    writeln;
    mensagem ('DV_TRANSC', 1); {'Transcrevendo arquivos para a área de montagem'}
    mensagem ('DV_DEMORA', 2); {'Esta é uma operação demorada'}
    if not geraDirCD (dir) then
        goto problemas;

    if not criaImagemCD (nomeDisco, indGrav) then
        goto problemas;

    mensagem ('DV_INGRCD', 1);  {'Iniciando a gravação, aperte ENTER após inserir a mídia'}
    mensagem ('DV_CANESC', 0);  {'Para cancelar aperte ESC'}
    sintLetecla (c, c2);
    if c = ESC then goto desistiu;

    writeln;
    mensagem ('DV_GRAVND', 1);  {'Gravando...'}
    if not gravaCd then;
        mensagem ('DV_PROBLG', 1);  {'Problemas no processo de gravação'}

fim:
    finalizaCD;
    exit;

problemas:
    writeln;
    mensagem ('DV_PROBLG', 2);  {'Problemas no processo de gravação'}
    goto fim;

desistiu:
    writeln;
    mensagem ('DV_DESIST', 1);      {'Desistiu...'}
    goto fim;
end;

end.
