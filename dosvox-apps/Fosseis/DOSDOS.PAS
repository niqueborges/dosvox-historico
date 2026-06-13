unit dosdos;
interface
uses windows, sysutils,
     dvcrt, dvwin, dvForm, dvExec,
     dosproc, dosgeral, dosmsg, dosed;

procedure chamaProg;
procedure macroComando (c: char);

implementation

{--------------------------------------------------------}
{              nomeia um arquivo temporário
{--------------------------------------------------------}

function GetTempFile: String;
var
    tempFileName, tempPath: array[0..255] of Char;

begin
    getTempPath (255, tempPath);
    getTempFileName(tempPath, '$$$', 0, tempFileName);
    result := strPas (tempFileName);
end;

{--------------------------------------------------------}
{              opcao de chamada de programa
{--------------------------------------------------------}

procedure executa (comando: string);
var
    param, s: string;
    nomedir: string;
    temporario: string;
    arq: text;
    modoDOS: boolean;
    modoTela: integer;
    p: integer;
    temCoisa: boolean;
    infoSistOp: _OSVERSIONINFO;

begin
    while (comando <> '') and (comando [1] = ' ') do
        delete (comando, 1, 1);
    p := pos (' ', comando);
    if p = 0 then p := length (comando)+1;
    param := copy (comando, p+1, length (comando)-p);
    comando := copy (comando, 1, p-1);

    getdir (0, nomeDir);
    while sintFalando do waitMessage;
    modoTela := SW_SHOWNORMAL;

    modoDOS := false;
    if maiuscAnsi(comando) = 'DOS' then
        begin
            modoDOS := true;
            temporario := GetTempFile;
            assignFile (arq, temporario);

            s := maiuscAnsi(param);
            if (s = 'DATE') or (s = 'TIME') then
                begin
                    param := param + ' /T';  // data sem modificação
                    s := s + ' ';
                end;

            if (copy (s, 1, 5) = 'DATE ') or
               (copy (s, 1, 5) = 'TIME ') or
               (copy (s, 1, 5) = 'COPY ') or
               (copy (s, 1, 5) = 'TYPE ') or
               (copy (s, 1, 4) = 'DEL ') or
               (copy (s, 1, 6) = 'ERASE ') or
               (copy (s, 1, 7) = 'RENAME ') or
               (copy (s, 1, 4) = 'REN ') then
                       modoTela := SW_SHOWMINIMIZED;

            param := trim(param);

            infoSistOp.dwOSVersionInfoSize := sizeof(infoSistOp);
            GetVersionEx(infoSistOp);
            if infoSistop.dwMajorVersion >= 5 then
                 comando := 'cmd'
            else
                 comando := 'command';
            param := '/c ' + param + ' > ' + temporario + ' 2>&1';
            // Duas linhas abaixo podem substituir a linha acima para  usar a tabela de caracteres do Windows ocidental (cp-1252).
            //param := '/C chcp 1252 >nul 2>&1 && ' + comando + ' /C ' + param;
            //param := param + ' > ' + temporario + ' 2>&1';
        end;

    if executaPrograma (comando, nomeDir, param, modoTela) then
        esperaProgVoltar;

    while keypressed do readkey;
    while sintFalando do waitMessage;

    if modoDOS then
        begin
            temCoisa := false;

            assignFile (arq, temporario);
            {$I-}  reset (arq);   {$I+}
            if ioresult = 0 then
                begin
                    while (not eof (arq)) and (not temCoisa) do
                        begin
                            readln (arq, s);
                            temCoisa := temCoisa or (s <> '');
                        end;
                    closeFile (arq);
                end
            else
                 mensagem ('DV_PRGNAOENC', 2);  { 'Programa não encontrado.' }

            if temCoisa then
                begin
                    mensagem ('DV_ESCVOLTA', 1);    { 'Tecle ESC para voltar ao DOSVOX.' }
                    while sintFalando do waitMessage;
                    editarLerArquivo (temporario, 2, '');
                end
            else
                sintBip;
        end;

    if modoDos then
        begin
            {$I-}  erase (arq);  {$I-}
            if ioresult <> 0 then;   { ignora }
        end;
end;

{--------------------------------------------------------}
{                 chama um programa
{--------------------------------------------------------}

procedure chamaProg;
var comando: string;
    c: char;
begin
    mensagem ('DV_TECLCMD', 1);     { 'Tecle o comando.' }
    comando := '';
    c := pegaUltimosComandos (comando, 'DOSVOX', 'CP');

    if (c <> ESC) and (comando <> '') then
        executa (comando);
    writeln;
end;

{--------------------------------------------------------}
{                    macro comando
{--------------------------------------------------------}

procedure macroComando (c: char);
const
     tabTeclas: array [F2..F7] of string[2] = ('F2', 'F3', 'F4', 'F5', 'F6', 'F7');

var
    comando: string;
    apertouShift: boolean;
label erro;
begin
    apertouShift := GetKeyState(VK_SHIFT) < 0;
    writeln;
    if (c = ^C) and apertouShift  then
        begin
            falaAreaTransf;
            exit;
        end
    else
    if (c >= ^a) and (c <= ^z) then
        comando := sintAmbiente ('MACROCOMANDOS', 'CTRL+' + chr(ord(c) or $40))
    else
    if (c >= F2) and (c <= F7) then
        comando := sintAmbiente ('MACROCOMANDOS', tabTeclas[c])
    else
        goto erro;

    if comando = '' then
         begin
erro:
             mensagem ('DV_MACNAODEF', 1);      {'Este macrocomando não foi definido'}
             exit;
         end;

    executa (comando);
end;

end.
