{--------------------------------------------------------}
{
{     Monitvox - módulo de monitoração de teclado
{     Autor: Antonio Borges
{     Em janeiro/2005
{
{--------------------------------------------------------}

unit mvteclas;

interface
uses dvwin, dvcrt, sysUtils, classes, windows, messages;

procedure inicMonitTeclado;
procedure fimMonitTeclado;
procedure exibeMonitTeclado;
procedure limpaMonitTeclado;

function StartKeyRecording: Boolean; stdcall;
function StopKeyRecording: boolean; stdcall;
procedure getRecordedKey (var char: word;
                          var code: longint;
                          var state: TKeyBoardState); stdcall;
function keyHasBeenPressed: boolean; stdcall;

var
    tecladoMonitorado: boolean;

implementation

function StartKeyRecording: Boolean; stdcall;
    external 'dvkbl32.dll' Name 'StartKeyRecording';

function StopKeyRecording: boolean; stdcall;
    external 'dvkbl32.dll' Name 'StopKeyRecording';

procedure getRecordedKey (var char: word;
                          var code: longint;
                          var state: TKeyBoardState); stdcall;
    external 'dvkbl32.dll' Name 'getRecordedKey';

function keyHasBeenPressed: boolean; stdcall;
    external 'dvkbl32.dll' Name 'keyHasBeenPressed';

procedure inicMonitTeclado;
begin
    tecladoMonitorado := startKeyRecording;
end;

procedure fimMonitTeclado;
begin
    StopKeyRecording;
    tecladoMonitorado := false;
end;

procedure exibeMonitTeclado;
var
   virtKey: word;
   ScanCode: longint;
   KeyState: TKeyBoardState;
   aryChar: array [0..3] of char;

begin
    while keyHasBeenPressed do
        begin
            getRecordedKey (virtKey, ScanCode, KeyState);
            ToAscii(VirtKey, ScanCode, KeyState, AryChar, 0);
            if VirtKey > 20 then
                begin
                    sintCarac (arychar[0]);
                end;
        end;
end;

procedure limpaMonitTeclado;
var
    virtKey: word;
    ScanCode: longint;
    KeyState: TKeyBoardState;
begin
    while keyHasBeenPressed do
        getRecordedKey (virtKey, ScanCode, KeyState);
end;

end.

