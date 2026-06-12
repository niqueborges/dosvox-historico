{--------------------------------------------------------}
{
{    DOSVOX - Programa de autalização do dosvox.exe
{
{    Autor: Júlio Tadeu C. Silveira
{
{    Em Março/2016
{
{--------------------------------------------------------}
program AtuDosvox;

uses
    dvCrt, dvWin,
    Windows, SysUtils, TlHelp32;
var
    procId:   Cardinal;
    dirAtual,
    dirDosvox, pgmDosvox,
    oldDosvox, newDosvox: string;

{--------------------------------------------------------}
procedure inicializa;
begin
    GetDir (0, dirAtual);
    dirDosvox := sintAmbiente ('DOSVOX', 'PGMDOSVOX');
    if dirDosvox = '' then
        dirDosvox := 'c:\winvox';
    sintInic (0, '');
    sintwriteln ('Atualizador automático do Dosvox - versão 1.0');
end;

{--------------------------------------------------------}
function tecleAlgo (s: string): char;
begin
    if s <> '' then
        s := s + ' ';
    sintWriteln (s + ' Tecle algo...');
    result := readkey;
    limpaBufTec;
end;

{--------------------------------------------------------}
procedure finaliza;
begin
    sintWriteln ('Fim do programa.');
    sintFim;
    halt;
end;

{--------------------------------------------------------}
function encontraProcesso (nome: string; out procId: Cardinal): boolean;
var
    hand: THandle;
    data: TProcessEntry32;

    {----------------------------------------------------}
    function GetName: string;
    var i:integer;
    begin
        Result := '';
        i := 0;
        while data.szExeFile[i] <> '' do
        begin
            Result := Result + data.szExeFile[i];
            Inc(i);
        end;
    end;
    {----------------------------------------------------}

begin
    result := False;
    nome := UpperCase (nome);

    data.dwSize := sizeof (TProcessEntry32);
    hand := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
    if Process32First(hand, data) then
        repeat
            if nome = UpperCase (GetName) then
            begin
                procID := data.th32ProcessID;
                result := True;
                exit;
            end;
        until not Process32Next(hand, data);
end;

{--------------------------------------------------------}
procedure erroAtualiza;
begin
    sintWriteln ('Atualização do dosvox abortada!');
end;

{--------------------------------------------------------}
function preparaArquivos: boolean;
begin
    result := False;
    pgmDosvox := dirDosvox + '\dosvox.exe';
    oldDosvox := dirDosvox + '\dosvox.~exe';
    newDosvox := dirDosvox + '\dosvox.$$$';
    if not fileExists (newDosvox) then
    begin
        sintWriteln ('Nova versão do dosvox não encontrada.');
        erroAtualiza;
        exit;
    end;
    if not fileExists (pgmDosvox) then
    begin
        sintWriteln ('Programa dosvox não encontrado: ' + pgmDosvox + '.');
        erroAtualiza;
        exit;
    end;
    if fileExists (oldDosvox) and not DeleteFile (oldDosvox) then
    begin
        sintWriteln ('Erro na remoção de arquivo temporário para atualização.');
        erroAtualiza;
        exit;
    end;
    result := True;
end;

{--------------------------------------------------------}
function atualizaDosvox: boolean;
begin
    result := False;
    if tecleAlgo ('Vou renomear o dosvox antigo para $$$.') = ESC then
        finaliza;
    if not RenameFile (pgmDosvox, oldDosvox) then
    begin
        sintWriteln ('Não conseguir remover o dosvox antigo: ' + pgmDosvox + '.');
        erroAtualiza;
        finaliza;
    end;
    sintWriteln ('Vou criar o novo dosvox.');
    if RenameFile (newDosvox, pgmDosvox) then
        begin
            {$I-} DeleteFile (oldDosvox); {$I+}
            result := True;
        end
    else
    begin
        sintWriteln ('Não conseguir criar o novo arquivo do dosvox.exe.');
        erroAtualiza;
        if not RenameFile (oldDosvox, pgmDosvox) then
            sintWriteln ('Atenção: o arquivo executável do dosvox foi perdido.');
    end;
end;

{--------------------------------------------------------}
begin
    inicializa;
    if not preparaArquivos then
    begin
        finaliza;
        exit;
    end;
    if encontraProcesso ('DOSVOX.EXE', procId) then
    begin
        if tecleAlgo ('Processo dosvox será finalizado.') = ESC then
            finaliza;

        if not TerminateProcess (OpenProcess (PROCESS_TERMINATE, False, procId), 0) then
        begin
            writeln ('O Dosvox ainda executando: não consegui matar o processo.');
            erroAtualiza;
            finaliza;
        end;
    end;
    if atualizaDosvox then
        begin
            sintWriteln ('O programa dosvox foi atualizado e será executado agora.');
            while sintFalando do
                WaitMessage;
            WinExec(PChar(pgmDosvox), SW_SHOWNORMAL);
        end;
    finaliza;
end.

