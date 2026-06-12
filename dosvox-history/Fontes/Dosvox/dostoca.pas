unit dostoca;

interface
uses windows, mmsystem, sysUtils,
     dvcrt, dvwin;

procedure tocarMidia (nomeArq: string);

implementation

var tocando: boolean;

{--------------------------------------------------------}
{                  opção de tocar mídia
{--------------------------------------------------------}

procedure myMCICallback (Window: HWnd; WParam: WPARAM; LParam: LPARAM);
begin
    tocando := false;
end;

{--------------------------------------------------------}

function enviaComandoMCI (s: string): integer;
var p, retorno: array [0..255] of char;
    erro: integer;
begin
    strPcopy (p, s);
    erro := mciSendString (p, retorno, 255, crtWindow);
    result := erro;
end;

{--------------------------------------------------------}

procedure iniciaMciDosvox (nomeArq: string);
var dir, ext: string;
begin
    nomeArq := trim(nomeArq);
    ext := upperCase(ExtractFileExt(nomeArq));

    if pos ('\', nomeArq) = 0 then
        begin
            getDir (0, dir);
            if dir [length(dir)] <> '\' then dir := dir + '\';
            nomeArq := dir + nomeArq;
        end;

    if pos (' ', nomeArq) <> 0 then
         nomeArq := '"' + nomeArq + '"';

    if enviaComandoMci ('open ' + nomeArq + ' alias midiaDosvox') = 0 then
        begin
            MCICallback := myMciCallback;
            tocando := true;
            hasMCICallback := true;

            if enviaComandoMci ('play midiaDosvox notify') <> 0 then
                tocando := false;
        end
    else
        tocando := false;
end;

{--------------------------------------------------------}

procedure terminaMciDosvox;
begin
    tocando := false;
    hasMCICallback := false;
    enviaComandoMci ('stop midiaDosvox');
    enviaComandoMci ('close midiaDosvox');
end;

{--------------------------------------------------------}

function tocandoMciDosvox: boolean;
begin
    result := tocando;
end;

{--------------------------------------------------------}

procedure tocarMidia (nomeArq: string);
var nomeDir: string;
begin
    getdir (0, nomeDir);
    if copy (nomeDir, length(nomeDir), 1) <> '\' then
        nomeDir := nomeDir + '\';
    iniciaMciDosvox (nomeDir + nomeArq);
    while tocandoMciDosvox do
        begin
            delay (500);
            if keypressed then
                if readkey = ESC then break;
        end;

    terminaMciDosvox;
end;

end.


