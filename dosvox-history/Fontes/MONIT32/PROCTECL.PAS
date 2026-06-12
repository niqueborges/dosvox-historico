{--------------------------------------------------------}
{
{     Monitvox - módulo de monitoração de teclado
{     Autor: Antonio Borges
{     Em janeiro/2005
{
{--------------------------------------------------------}

unit procCompletoTeclas;

interface
uses dvwin, dvcrt, sysUtils, classes, windows, messages, mvVars;


var
    exibindoTeclado: boolean;

procedure inicMonitTeclado;
procedure fimMonitTeclado;
procedure exibeMonitTeclado;

implementation

var
    filaTec: TStringList;
    sysModal: boolean;
    JHook: THandle;

Function MatchCode(Code: Integer): string;
begin
    case Code of
        VK_ESCAPE:   Result := '{Esc}';
        VK_TAB:      Result := '{Tab}';
        VK_CAPITAL:  Result := '{Caps Lock}';
        VK_SHIFT:    Result := '{Shift}';
        VK_LSHIFT:   Result := '{Left Shift}';
        VK_RSHIFT:   Result := '{Right Shift}';
        VK_CONTROL:  Result := '{Ctrl}';
        VK_LCONTROL: Result := '{Left Ctrl}';
        VK_RCONTROL: Result := '{Right Ctrl}';
        VK_MENU:     Result := '{Alt}';
        VK_LMENU:    Result := '{Left Alt}';
        VK_RMENU:    Result := '{Right Alt}';
        VK_LWIN:     Result := '{Left Win}';
        VK_RWIN:     Result := '{Right Win}';
        VK_BACK:     Result := '{Backspace}';
        VK_RETURN:   Result := '{Enter}';
        VK_SPACE:    Result := '{Space}';
        VK_SNAPSHOT: Result := '{Print Screen}';
        VK_SCROLL:   Result := '{Scroll Lock}';
        VK_PAUSE:    Result := '{Pause}';
        VK_INSERT:   Result := '{Ins}';
        VK_DELETE:   Result := '{Del}';
        VK_HOME:     Result := '{Home}';
        VK_END:      Result := '{End}';
        VK_PRIOR:    Result := '{Page Up}';
        VK_NEXT:     Result := '{Page Down}';
        VK_LEFT:     Result := '{Left}';
        VK_UP:       Result := '{Up}';
        VK_RIGHT:    Result := '{Right}';
        VK_DOWN:     Result := '{Down}';
        VK_NUMLOCK:  Result := '{Num Lock}';
        VK_HELP:     Result := '{Help}';
        VK_APPS:     Result := '{App}';
        VK_CLEAR:    Result := '{Clear}';
        VK_SELECT:   Result := '{Select}';
        VK_PRINT:    Result := '{Print}';
        VK_EXECUTE:  Result := '{Execute}';
        VK_F1 .. VK_F24:
            Result := '{F' + IntToStr(Code - VK_F1 + 1) + '}';
        else
            Result := '{' + IntToStr(Code) + '}';
    end;
end;

{--------------------------------------------------------}
{               hook procedure de teclado
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

                    if EventStrut.message = WM_KEYUP then
                        begin
                            VirtKey := LOBYTE(LOWORD(EventStrut.paramL));
                            ScanCode := HIBYTE(LOWORD(EventStrut.paramL));
                            GetKeyboardState(KeyState);
                            Count := ToAscii(VirtKey,ScanCode, KeyState, AryChar, 0);
                            if Count = 1 then
                                begin
                                   if (AryChar[0] > #$20) and (AryChar[0] <= #$7f) then
                                       filaTec.Add(AryChar[0])
                                   else
                                       if GetKeyNameText(ScanCode shl 16, keyName,SizeOf(keyName)) > 0 then
                                           filaTec.Add(strPas(keyName));
                                end
                            else
                                begin
                                    filaTec.Add (matchCode (virtKey));
                                    sintBip;
                                    postMessage (crtWindow, ACORDA, 0, 0);
                                end;
                        end;
            end;
    end;

next:
    Result := CallNextHookEx (JHook, Code, wParam, Longint(@EventStrut));
end;

{--------------------------------------------------------}
{             inicia hook procedure de teclado
{--------------------------------------------------------}

procedure inicMonitTeclado;
begin
    if JHook = 0 then
        JHook := SetWindowsHookEx(WH_JOURNALRECORD , @JHookProc, hInstance, 0);
    if JHook > 0 then
        exibindoTeclado := true;
end;

{--------------------------------------------------------}
{           finaliza hook procedure de teclado
{--------------------------------------------------------}

procedure fimMonitTeclado;
begin
    if JHook <> 0 then
        begin
            UnhookWindowsHookEx(JHook);

            JHook := 0;
            exibindoTeclado := false;
            filaTec.clear;
        end;
end;

{--------------------------------------------------------}
{           exibe monitoração de teclado
{--------------------------------------------------------}

procedure exibeMonitTeclado;
var s: string;
begin
    if filaTec.count <> 0 then
        begin
            s := filaTec[0];
            filaTec.Delete(0);
            sintPara;
            if length (s) = 1 then
                sintSoletra (s[1])
            else
                sintetiza (s);
        end;
end;

begin
    filaTec := TStringList.create;
    JHook := 0;
    sysModal := false;
end.

