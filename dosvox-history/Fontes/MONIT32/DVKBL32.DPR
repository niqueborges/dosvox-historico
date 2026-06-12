{$R-}
library dvkbl32;

uses
    windows, messages;

const
    MAXBUF = 30;

var
    JHook: THandle;
    SysModal: Bool;

    bufChar: array [0..MAXBUF-1] of word;
    bufCode: array [0..MAXBUF-1] of longint;
    bufState: array [0..MAXBUF-1] of TKeyboardState;
    pins, pret: integer;

{--------------------------------------------------------}
{             journal record hook procedure
{--------------------------------------------------------}

function JHookProc(Code:integer; wParam: Longint;
                   var EventStrut: TEVENTMSG): Longint;  stdcall;
var
   virtKey, ScanCode: UINT;
   count: integer;
   KeyState: TKeyBoardState;
   aryChar: array [0..3] of char;
   keyName: array[0..20] of char;

label next;

begin
    case code of
        HC_SYSMODALON:   SysModal := True;
        HC_SYSMODALOFF:  SysModal := False;
        HC_ACTION:
            begin
                if sysModal then goto next;

                if EventStrut.message = WM_KEYDOWN then
                    begin
                        bufChar [pins] := LOBYTE(LOWORD(EventStrut.paramL));
                        bufCode [pins] := HIBYTE(LOWORD(EventStrut.paramL));
                        GetKeyboardState(bufState [pins]);
                        pins := (pins + 1) mod MAXBUF;
                    end;
            end;
    end;

next:
    Result := CallNextHookEx (JHook, Code, wParam, Longint(@EventStrut));
end;

{--------------------------------------------------------}

function StartKeyRecording: Boolean; stdcall;
begin
    SysModal := False;
    pins := 0;
    pret := 0;

    if JHook = 0 then
        JHook := SetWindowsHookEx(WH_JOURNALRECORD , @JHookProc, hInstance, 0);
    result := JHook <> 0;
end;

{--------------------------------------------------------}

function StopKeyRecording: boolean; stdcall;
begin
    if JHook <> 0 then
        begin
            UnhookWindowsHookEx(JHook);
            JHook := 0;
            result := true;
            pins := pret;
        end
    else
        result := false;
end;

{--------------------------------------------------------}

procedure getRecordedKey (var char: word;
                          var code: longint;
                          var state: TKeyBoardState); stdcall;
begin
    if pins = pret then
        char := $ffff
    else
        begin
            char := bufChar [pret];
            code := bufCode [pret];
            state := bufState [pret];
            pret := (pret + 1) mod MAXBUF;
        end;
end;

{--------------------------------------------------------}

function keyHasBeenPressed: boolean; stdcall;
begin
    result := pins <> pret;
end;

exports
    StartKeyRecording,
    StopKeyRecording,
    getRecordedKey,
    keyHasBeenPressed;

begin
end.

