unit brlpt;

interface

uses Windows, Messages, SysUtils;

function abreLpt (lpt: string): boolean;
function escreveLpt (s: string): boolean;
procedure fechaLpt;

implementation

var lptId: THandle;

function abreLpt (lpt: string): boolean;
begin
    abreLpt := false;

    lptId := CreateFile (pchar(lpt), GENERIC_WRITE, 0, NIL,
          OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if lptId = INVALID_HANDLE_VALUE then exit;

    abreLpt := true;
end;

function escreveLpt (s: string): boolean;
var nescritos: DWORD;
    p: array [0..144] of char;
begin
    strPCopy (p, s);
    WriteFile (lptId, p, length(s), nescritos, NIL);
    escreveLpt := true;
end;

procedure fechaLpt;
begin
    closeHandle (lptId);
end;

end.

