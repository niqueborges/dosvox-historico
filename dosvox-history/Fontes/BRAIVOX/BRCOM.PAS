unit brcom;

interface

uses Windows, Messages, SysUtils;

function abreCom (com: string): boolean;
function escreveCom (s: string): boolean;
procedure fechaCom;

implementation

var
    comId: THandle;

{ constantes, tipos e variaveis }

function abreCom (com: string): boolean;
var
    modemDCB: TDCB;              { controles da comunicacao }

begin
    abreCom := false;

    comId := CreateFile (pchar(com), GENERIC_READ OR GENERIC_WRITE, 0, NIL,
          OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if comId = INVALID_HANDLE_VALUE then exit;

    GetCommState(comID, modemDCB);
    modemDCB.BaudRate := 9600;
    modemDCB.ByteSize := 8;
    modemDCB.Parity := NOPARITY;
    modemDCB.StopBits := ONESTOPBIT;
    setCommState (comId, modemDCB);

    abreCom := true;
end;

function imprBloq: boolean;
var
    modemStat: DWORD;
begin
    GetCommModemStatus(comId, modemStat);
    imprBloq := ((modemStat and MS_CTS_ON) = 0) or
                ((modemStat and MS_DSR_ON) = 0);
end;

function escreveCom (s: string): boolean;
var nescritos: DWORD;
    p: array [0..144] of char;
begin
    while imprBloq do
        begin
            sleep (500);
            beep;
        end;

    strpCopy (p, s);
    WriteFile (comId, p, length(s), nescritos, NIL);
    escreveCom := true;    {tratamento de desbloqueio ainda não implementado}
end;

procedure fechaCom;
begin
    closeHandle (comID);
end;

end.
