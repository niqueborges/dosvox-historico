{--------------------------------------------------------}
{
{     Monitvox - módulo de controle das "hot keys"
{     Autor: Antonio Borges
{     Em 23/3/2003
{
{--------------------------------------------------------}

unit mvhotkey;

interface

uses dvCrt, dvWin, windows, messages, sysUtils, dvMacro,
     mvTeclas, mvEdita, mvPiolho, mvVars, mvMsg;

procedure localWinProc(Window: HWnd; Message: UINT;
                 WParam: WPARAM; LParam: LPARAM;
                 var resultx: LRESULT); far;
procedure inicHotKey;
procedure finalHotkey;

implementation

var soOcupado: boolean;
    mouseSimulado: boolean;

const
    HK_SIMOUSE = $fcc0;
    HK_NOMOUSE = $fcc1;
    HK_LMOUSE  = $fcc2;
    HK_RMOUSE  = $fcc3;
    HK_DMOUSE  = $fcc4;
    HK_PMOUSE  = $fcc5;

    HK_UP      = $fcc6;
    HK_DOWN    = $fcc7;
    HK_LEFT    = $fcc8;
    HK_RIGHT   = $fcc9;

    HK_F1      = $fcd1;
    HK_F2      = $fcd2;
    HK_F3      = $fcd3;
    HK_F4      = $fcd4;

    HK_F5      = $fcd5;
    HK_F6      = $fcd6;
    HK_F7      = $fcd7;
    HK_F8      = $fcd8;

    HK_F9      = $fcd9;
    HK_F10     = $fcda;

    HK_SPACE   = $fce0;
    HK_ENTER   = $fce1;
    HK_HOME    = $fce2;
    HK_END     = $fce3;
    HK_BACK    = $fce4;
    HK_INSERT  = $fce5;
    HK_NEXT    = $fce6;
    HK_PRIOR   = $fce7;

{--------------------------------------------------------}
{              inicializa as Hot Keys
{--------------------------------------------------------}

procedure registraTeclasMouse;
begin
    if mouseSimulado then exit;

    RegisterHotKey(crtWindow, HK_UP, 0, VK_UP);
    RegisterHotKey(crtWindow, HK_DOWN, 0, VK_DOWN);
    RegisterHotKey(crtWindow, HK_LEFT, 0, VK_LEFT);
    RegisterHotKey(crtWindow, HK_RIGHT, 0, VK_RIGHT);

    RegisterHotKey(crtWindow, HK_LMOUSE, 0, VK_INSERT);
    RegisterHotKey(crtWindow, HK_RMOUSE, 0, VK_HOME);
    RegisterHotKey(crtWindow, HK_DMOUSE, 0, VK_PRIOR);
    RegisterHotKey(crtWindow, HK_PMOUSE, 0, VK_END);

    mouseSimulado := true;
end;

{--------------------------------------------------------}

procedure inicHotKey;
begin
    soOcupado := false;

    RegisterHotKey(crtWindow, HK_F1, MOD_ALT+MOD_CONTROL, VK_F1);
    RegisterHotKey(crtWindow, HK_F2, MOD_ALT+MOD_CONTROL, VK_F2);
    RegisterHotKey(crtWindow, HK_F3, MOD_ALT+MOD_CONTROL, VK_F3);
    RegisterHotKey(crtWindow, HK_F4, MOD_ALT+MOD_CONTROL, VK_F4);
    RegisterHotKey(crtWindow, HK_F5, MOD_ALT+MOD_CONTROL, VK_F5);
    RegisterHotKey(crtWindow, HK_F6, MOD_ALT+MOD_CONTROL, VK_F6);
    RegisterHotKey(crtWindow, HK_F7, MOD_ALT+MOD_CONTROL, VK_F7);
    RegisterHotKey(crtWindow, HK_F8, MOD_ALT+MOD_CONTROL, VK_F8);
    RegisterHotKey(crtWindow, HK_F9, MOD_ALT+MOD_CONTROL, VK_F9);
    RegisterHotKey(crtWindow, HK_F10, MOD_ALT+MOD_CONTROL, VK_F10);

    RegisterHotKey(crtWindow, HK_SIMOUSE, MOD_ALT+MOD_CONTROL, VK_UP);
    RegisterHotKey(crtWindow, HK_NOMOUSE, MOD_ALT+MOD_CONTROL, VK_DOWN);

    RegisterHotKey(crtWindow, HK_SPACE,  MOD_ALT+MOD_CONTROL, VK_SPACE);
    RegisterHotKey(crtWindow, HK_BACK,   MOD_ALT+MOD_CONTROL, VK_BACK);
    RegisterHotKey(crtWindow, HK_ENTER,  MOD_ALT+MOD_CONTROL, VK_RETURN);
    RegisterHotKey(crtWindow, HK_INSERT, MOD_ALT+MOD_CONTROL, VK_INSERT);

    RegisterHotKey(crtWindow, HK_HOME,   MOD_ALT+MOD_CONTROL, VK_HOME);
    RegisterHotKey(crtWindow, HK_END,    MOD_ALT+MOD_CONTROL, VK_END);
    RegisterHotKey(crtWindow, HK_NEXT,   MOD_ALT+MOD_CONTROL, VK_NEXT);
    RegisterHotKey(crtWindow, HK_PRIOR,  MOD_ALT+MOD_CONTROL, VK_PRIOR);
end;

{--------------------------------------------------------}
{              finaliza as Hot Keys
{--------------------------------------------------------}

procedure desregistraTeclasMouse;
begin
    if not mouseSimulado then exit;

    unRegisterHotKey(crtWindow, HK_UP);
    unRegisterHotKey(crtWindow, HK_DOWN);
    unRegisterHotKey(crtWindow, HK_LEFT);
    unRegisterHotKey(crtWindow, HK_RIGHT);

    unRegisterHotKey(crtWindow, HK_LMOUSE);
    unRegisterHotKey(crtWindow, HK_RMOUSE);
    unRegisterHotKey(crtWindow, HK_DMOUSE);
    unRegisterHotKey(crtWindow, HK_PMOUSE);

    mouseSimulado := false;
end;

{--------------------------------------------------------}

procedure finalHotkey;
begin
    unRegisterHotKey(crtWindow, HK_F1);
    unRegisterHotKey(crtWindow, HK_F2);
    unRegisterHotKey(crtWindow, HK_F3);
    unRegisterHotKey(crtWindow, HK_F4);
    unRegisterHotKey(crtWindow, HK_F5);
    unRegisterHotKey(crtWindow, HK_F6);
    unRegisterHotKey(crtWindow, HK_F7);
    unRegisterHotKey(crtWindow, HK_F8);
    unRegisterHotKey(crtWindow, HK_F9);
    unRegisterHotKey(crtWindow, HK_F10);

    unRegisterHotKey(crtWindow, HK_SPACE);
    unRegisterHotKey(crtWindow, HK_BACK);
    unRegisterHotKey(crtWindow, HK_ENTER);
    unRegisterHotKey(crtWindow, HK_INSERT);

    unRegisterHotKey(crtWindow, HK_SIMOUSE);
    unRegisterHotKey(crtWindow, HK_NOMOUSE);

    unRegisterHotKey(crtWindow, HK_HOME);
    unRegisterHotKey(crtWindow, HK_END);
    unRegisterHotKey(crtWindow, HK_NEXT);
    unRegisterHotKey(crtWindow, HK_PRIOR);

    desregistraTeclasMouse;
end;

{--------------------------------------------------------}
{                    fala hora atual
{--------------------------------------------------------}

procedure falaHoraAtual;
var
    hora, minuto, segundo, cent: word;
begin
    dvcrt.gettime (hora, minuto, segundo, cent);
    sintetiza (intToStr (hora) + ' e ' + intToStr (minuto));
end;

{--------------------------------------------------------}
{              trata dos comandos de teclado
{--------------------------------------------------------}

procedure localWinProc(Window: HWnd; Message: UINT;
                 WParam: WPARAM; LParam: LPARAM;
                 var resultx: LRESULT); far;

    procedure moveCursor (dx, dy: integer);
    var p: TPoint;
    begin
        if soOcupado then exit;
        soOcupado := true;
        getCursorPos (p);
        SetCursorPos(p.X+dx, p.Y+dy);
        soOcupado := false;
    end;

    procedure mouseLeft;
    var p: TPoint;
    begin
        if soOcupado then exit;
        getCursorPos (p);
        soOcupado := true;       // evita reentrância
        mouseClick (p.x, p.y);
        soOcupado := false;
    end;

    procedure mouseDouble;
    var p: TPoint;
    begin
        if soOcupado then exit;
        getCursorPos (p);
        soOcupado := true;
        mouseDoubleClick (p.x, p.y);
        soOcupado := false;
    end;

    procedure mouseRight;
    var p: TPoint;
    begin
        if soOcupado then exit;
        getCursorPos (p);
        soOcupado := true;
        mouseRightClick (p.x, p.y);
        soOcupado := false;
    end;

    procedure infoMouse;
    var p: TPoint;
    begin
        getCursorPos (p);
        sintWriteln (intToStr (p.x) + ' ' + intToStr (p.y));
    end;

begin
    resultx := 0;
    if message = WM_HOTKEY then
        begin
            sintPara;

            case wparam of
                HK_SIMOUSE:  begin    {control-alt-cima}
                                 registraTeclasMouse;
                                 mensagem ('MOTECMOU', 1); {'Mouse pelas setas'}
                                 lendoMouse := true;
                                 mouseAnt.x := -100;
                             end;
                HK_NOMOUSE:  begin    {control-alt-baixo}
                                 desregistraTeclasMouse;
                                 mensagem ('MOSETNOR', 1);  {'Setas normais'}
                                 lendoMouse := false;
                             end;

                HK_UP:       moveCursor (0, -10);
                HK_DOWN:     moveCursor (0, 10);
                HK_LEFT:     moveCursor (-10, 0);
                HK_RIGHT:    moveCursor (10, 0);
                HK_LMOUSE:   mouseLeft;
                HK_RMOUSE:   mouseRight;
                HK_DMOUSE:   mouseDouble;
                HK_PMOUSE:   infoMouse;

                HK_F1:  lerClipBoard := true;
                HK_F2:  begin
                            getCursorPos (salvaMouse);
                            sintBip; sintBip;
                        end;
                HK_F3:  begin
                            setCursorPos (salvaMouse.X, salvaMouse.Y);
                            sintBip;
                        end;

                HK_F4:  ;

                HK_F5:  posicionarRapido := true;
                HK_F6:  registrarNome := true;
                HK_F7:  ;
                HK_F8:  falaHoraAtual;

                HK_F9:  begin
                            setCursorPos (xob, yob);
                            if sintFalando then
                                begin
                                    sintPara;
                                    delay (200);
                                end;
                            sintWriteln (nome);
                        end;

                HK_F10: lerStatus := true;

                HK_INSERT:   begin
                                 if monitorando then
                                     begin
                                         monitorando := false;
                                         desregistraTeclasMouse;
                                     end;
                                 suspenso := not suspenso;
                             end;

                HK_SPACE:  begin
                            monitorando := false;
                            lendoMouse := false;
                            suspenso := false;
                            PostMessage (crtWindow, WM_CHAR, 0, 0);   // para parar de falar
                            setForegroundWindow (crtWindow);
                        end;

                HK_ENTER:
                    begin
                        editorando := true;
                        monitorando := false;
                        alterandoLinha := true;
                    end;

                HK_HOME:  mostrarInfo := 0;            // título da janela

                HK_END:   begin
                               sintetiza (nomeAnt);
                               setCursorPos (xob, yob);
                          end;

                HK_NEXT:  ;

                HK_BACK:  PostMessage (crtWindow, WM_CHAR, 0, 0);   // para parar de falar

            else
                resultx :=1;
            end;
        end;
end;

end.
