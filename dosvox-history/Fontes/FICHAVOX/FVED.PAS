unit fvEd;
interface
uses windows, dvcrt, dvwin, sysUtils,
     fvProc, fvMsg;

procedure editarLerArquivo (nomearq: string; opcao: integer);

implementation

{--------------------------------------------------------}
{                  opcao de edicao
{--------------------------------------------------------}

procedure editarLerArquivo (nomearq: string; opcao: integer);
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
            if nomeProg = '' then nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\MINIED.EXE';
        end;

    getdir (0, nomeDir);

    if executaProg (nomeProg, nomeDir, nomeArq, SW_SHOWNORMAL) then
        esperaProgVoltar;
end;

end.
