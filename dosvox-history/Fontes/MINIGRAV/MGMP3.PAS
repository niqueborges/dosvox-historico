unit mgmp3;

interface
uses dvcrt, dvwin, mgmsg, mgVars, windows, sysUtils;

function pegarCaminhoffmpeg: string;   //Neno
function decodificaMp3 (nomeArqMP3, nomeArq: string): boolean;
function codificaMp3 (nomeArq, nomeArqMP3: string): boolean;

implementation

{--------------------------------------------------------}
{       Pega o caminho do ffmpeg e verifica se ele existe no computador.
{--------------------------------------------------------}

function pegarCaminhoffmpeg: string;   //Neno
var nomeProg: string;
begin
    pegarCaminhoffmpeg := '';
    nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\ffmpeg.exe';
    if not fileExists (nomeProg) then
        begin
            nomeProg := 'c:\Winvox\ffmpeg.exe';
            if not fileExists (nomeProg) then
                begin
                    mensagem ('MGPGNAOENC', 0); {'Programa não encontrado'}
                    sintWriteln (' ffmpeg.exe');
                    exit;
                end;
        end;
    pegarCaminhoffmpeg := nomeProg;
end;

function codifdecod (formato, nome1, nome2: string): boolean;
var titulo, atual: array [0..255]of char;
    cmd: string;
    i: integer;
label achou;
begin
    GetWindowText (crtWindow, titulo, 255);

    codifdecod := false;
//    cmd := progFfmpeg +' -i "'+nome1+'" -ar 44100 -ac 2 -ab 128000 -f '+formato+' -y "'+nome2+'"';
    cmd := progFfmpeg +' -i "'+nome1+'" -f '+formato+' -y "'+nome2+'"';
    if WinExec(@cmd[1], SW_SHOWMINIMIZED) < 32 then
        exit;

    for i := 1 to 6 do
        begin
            delay (500);
            GetWindowText (getForegroundWindow, atual, 255);
            if strPas (atual) <> strPas (titulo) then goto achou;
        end;

achou:
    repeat
        delay (1000);
        GetWindowText (getForegroundWindow, atual, 255);
        sintClek;
    until strPas (atual) = strPas (titulo);
    codifdecod := true;
end;

function decodificaMp3 (nomeArqMP3, nomeArq: string): boolean;
begin
    result := codifdecod ('wav', nomeArqMP3, nomeArq);
end;

function codificaMp3 (nomeArq, nomeArqMP3: string): boolean;
begin
    result := codifdecod ('mp3', nomeArq, nomeArqMP3);
end;

end.
