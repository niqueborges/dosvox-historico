unit dosed;
interface
uses
    windows, sysUtils,
    dvcrt, dvwin, dvExec,
    dosproc, dosmsg, dosgeral;

procedure editarSom (nomeArq: string);
procedure editarLerArquivo (nomearq: string; opcao: integer; paramExtra: string);

implementation

{--------------------------------------------------------}
{                  opção de edição de som
{--------------------------------------------------------}

procedure editarSom (nomeArq: string);
var
    nomeProg, nomeDir: string;

begin
    nomeProg := sintAmbiente ('DOSVOX', 'GRAVADOR');
    if nomeProg = '' then nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\MINIGRAV.EXE';

    getdir (0, nomeDir);

    if pos (' ', nomeArq) <> 0 then
        nomeArq := '"' + nomeArq + '"';

    if executaPrograma (nomeProg, nomeDir, nomeArq, SW_SHOWNORMAL) then
        esperaProgVoltar;
end;

{--------------------------------------------------------}
{                  opcao de edicao
{--------------------------------------------------------}

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

end.
