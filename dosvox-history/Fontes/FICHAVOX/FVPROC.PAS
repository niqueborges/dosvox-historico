unit fvProc;

interface
uses dvCrt, dvWin,      windows, fvMsg,
     sysUtils, shellApi, dvHora;

function executaProg (nomeProg, nomeDir, nomeArq: string; showCmd: integer): boolean;
procedure esperaProgVoltar;
procedure pegaTeclado (var c1, c2: char);
function compacta (nome: string): string;

implementation

var
    meuNome: array [0..101] of char;

{---------------------------------------------------------------------}

function executaProg (nomeProg, nomeDir, nomeArq: string; showCmd: integer): boolean;
var
    pprog, pdir, pparam: array [0..145] of char;
    erro: tHandle;
begin
    executaProg := true;
    strPcopy (pprog, nomeProg);
    strPCopy (pdir, nomeDir);
    strPcopy (pparam, nomeArq);

    while sintFalando do;
    GetWindowText(crtWindow, meuNome, 100);

    erro := ShellExecute(crtWindow, 'open', pprog, pparam, pdir, showCmd);

    if erro < 32 then
        begin
            if erro = 2 then
                mensagem ('FVPRGNAO', 0)
            else
                begin
                    mensagem ('FVERRPRG', 0);
                    sintWriteInt (erro);
                end;
            writeln;
            executaProg := false;
        end;
end;

{--------------------------------------------------------}
{        espera o titulo da janela ficar o mesmo
{--------------------------------------------------------}

procedure esperaProgVoltar;
var
    nomeNovo: array [0..100] of char;
    i: integer;
begin
    i := 0;
    repeat
        GetWindowText (getFocus, nomeNovo, 100);
        i := i + 1;
    until (strComp (meuNome, nomeNovo) <> 0) or (i > 5);

    repeat
        delay (500);
        GetWindowText (getFocus, nomeNovo, 100);
    until strComp (meuNome, nomeNovo) = 0;
    while sintFalando do;
    delay (500);
end;

{--------------------------------------------------------}
{              pega um dado do teclado sem ecoar
{--------------------------------------------------------}

procedure pegaTeclado (var c1, c2: char);
begin
    repeat
        while (not keypressed) or sintFalando do;
        c2 := ' ';
        c1 := readkey;
        if c1 = #0 then c2 := readkey;
    until c1 <> NOFOCUS;

    if (c1 = #0) and (c2 = F8) then
        begin
            falaHora;
            pegaTeclado (c1, c2);
        end
    else
    if (c1 = #0) and (c2 = CTLF8) then
        begin
            falaDia;
            pegaTeclado (c1, c2);
        end;
end;

{--------------------------------------------------------}
{     tira brancos do inicio e do fim de uma cadeia
{--------------------------------------------------------}

function compacta (nome: string): string;
var s: string;
    i: integer;
begin
    s := nome;
    for i := 1 to length (s) do
        s[i] := upcase(s[i]);

    s := s + '*';
    while s[1] = ' ' do
        s := copy (s, 2, length(s)-1);
    s := copy (s, 1, length(s)-1);

    s := '*' + s;
    while s[length(s)] = ' ' do
        s := copy (s, 1, length(s)-1);
    s := copy (s, 2, length(s)-1);
    compacta := s;
end;

{---------------------------------------------------------------------}

end.
