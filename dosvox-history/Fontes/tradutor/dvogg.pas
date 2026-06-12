{ Interface simplificada para reprodução de arquivos OGG
{ Por Thiago
{ Em 27/10/2018
{--------------------}
unit dvogg;

interface
uses
    dvcrt, dvWin, sysutils;

procedure sintTocaOgg(nomeArq: string);

implementation

const DLL = 'blastbay_oggdec.dll';

function Oggdec_OpenSession(fileName: pChar): tHandle; stdcall; external DLL;
function Oggdec_Decode(session: tHandle; buffer: pointer; size: longInt): integer; stdcall; external DLL;
function Oggdec_GetStreamLength(session: tHandle): longInt; stdcall; external DLL;
function Oggdec_GetSampleRate(session_: tHandle): integer; stdcall; external DLL;
function Oggdec_GetNumberOfChannels(session: tHandle): integer; stdcall; external DLL;
function Oggdec_CloseSession(session: tHandle): integer; stdcall; external DLL;

function sintTocaOgg(nomeArq: string); boolean;
var
    sessao: tHandle;
    buffer: pChar;
    tamanho, total: longInt;
    canais, veloc: integer;
    r, i: integer;
    p: pointer;

begin
    result := false;
    sessao := Oggdec_OpenSession(pChar(nomeArq));
    if sessao = 0 then exit;

    canais := Oggdec_GetNumberOfChannels(sessao);
    tamanho := Oggdec_GetStreamLength(sessao);
    veloc := Oggdec_GetSampleRate(sessao);
    total := tamanho * canais * sizeof(word);
    getMem(buffer, (44 + total));

    // Decodifica o arquivo
    i := 44;
    repeat
        p := @buffer[i];
        r := Oggdec_Decode(sessao, p, tamanho);
        KeyPressed;
        if r < 0 then
            begin
                freeMem(buffer, (44 + total));
                sintBip; sintBip;
                exit;   // 'Erro na decodificação do arquivo ogg'
            end;
        inc(i, (r * canais));
    until r = 0;

    // O arquivo OGG foi decodificado sem erros, gera cabeçlho wav no início
    Oggdec_CloseSession(sessao);

    geraCabWav(pChar(buffer), total, veloc, 16, canais);
    sintMem(buffer);
    while sintFalando do waitMessage;
    freeMem(buffer, (44 + total));
    result := true;
end;

end.
