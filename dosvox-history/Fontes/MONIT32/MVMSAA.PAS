{--------------------------------------------------------}
{
{     Monitvox - módulo de tratamento do MSAA
{     Autor: Antonio Borges
{     Em 23/3/2003
{
{--------------------------------------------------------}

unit mvmsaa;

interface

uses dvcrt, dvwin, Windows, messages, activex, oleacc, mvVars, mvmsg, sysutils, variants;

procedure initMSAA;
procedure UnInitMSAA;
function trataEventoMSAA: DWORD;
procedure obtemObjetoMSAA;

const
    ntipos = $3d;
    tabTipos: array [1..ntipos] of string[20] =
        ('TITLEBAR', 'MENUBAR', 'SCROLLBAR', 'GRIP', 'SOUND', 'CURSOR', 'CARET',
         'ALERT', 'WINDOW', 'CLIENT', 'MENUPOPUP', 'MENUITEM', 'TOOLTIP',
         'APPLICATION', 'DOCUMENT', 'PANE', 'CHART', 'DIALOG', 'BORDER',
         'GROUPING', 'SEPARATOR', 'TOOLBAR', 'STATUSBAR', 'TABLE', 'COLUMNHEADER',
         'ROWHEADER', 'COLUMN', 'ROW', 'CELL', 'LINK', 'HELPBALLOON', 'CHARACTER',
         'LIST', 'LISTITEM', 'OUTLINE', 'OUTLINEITEM', 'PAGETAB', 'PROPERTYPAGE',
         'INDICATOR', 'GRAPHIC', 'STATICTEXT', 'TEXT', 'PUSHBUTTON', 'CHECKBUTTON',
         'RADIOBUTTON', 'COMBOBOX', 'DROPLIST', 'PROGRESSBAR', 'DIAL', 'HOTKEYFIELD',
         'SLIDER', 'SPINBUTTON', 'DIAGRAM', 'ANIMATION', 'EQUATION', 'BUTTONDROPDOWN',
         'BUTTONMENU', 'BUTTONDROPDOWNGRID', 'WHITESPACE', 'PAGETABLIST', 'CLOCK');


implementation

{--------------------------------------------------------}
{               interpreta o retorno
{--------------------------------------------------------}

function hrToStr (hr: hresult): string;
begin
    if hr = DISP_E_MEMBERNOTFOUND then
         result := pegaTextoMensagem ('DISP_E_MEMBERNOTFOUND')   {'Membro não encontrado'}
    else
    if hr = E_INVALIDARG then
         result := pegaTextoMensagem ('E_INVALIDARG')  {'Argumento inválido'}
    else
    if hr = E_FAIL then
        result := pegaTextoMensagem ('E_FAIL')         {'Falha'}
    else
    if hr = E_NOTIMPL then
        result := pegaTextoMensagem ('E_NOTIMPL')      {'Não implementado'}
    else
    if hr = E_OUTOFMEMORY then
        result := pegaTextoMensagem ('E_OUTOFMEMORY')  {'Sem memória'}
    else
    if hr = S_FALSE then
        result := pegaTextoMensagem ('S_FALSE')        {'Falso'}
    else
    if hr = S_OK then
        result := pegaTextoMensagem ('S_OK');          {'ok'}
end;

{--------------------------------------------------------}
{              trata os eventos do MSAA
{--------------------------------------------------------}

procedure WinEventProc(hEvent: HWINEVENTHOOK;
                       event: DWORD;
                       hwndMsg: HWND;
                       idObject: DWORD;
                       idChild: DWORD;
                       idThread: DWORD;
                       dwmsEventTime: DWORD);    stdcall;

var p: ^TEvento;
begin
    if (event <> EVENT_SYSTEM_FOREGROUND)  and
//////////  (event <> EVENT_OBJECT_VALUECHANGE) and
       (event <> EVENT_OBJECT_FOCUS) then
            exit;

    if event = EVENT_OBJECT_FOCUS then insertKeyBuf (#1);

    if event = EVENT_SYSTEM_FOREGROUND then
        begin
            pinsEvento := pRetEvento;
            ultJan := hwndMsg;
        end;

    p := @filaEventos [pinsEvento];
    pinsEvento := (pinsEvento + 1) mod 100;

    p^.ev_event := event;
    p^.ev_hwndMsg := hwndMsg;

    p^.ev_idObject := idObject;
    p^.ev_idChild := idChild;
end;

{--------------------------------------------------------}
{              inicializa o MSAA
{--------------------------------------------------------}

procedure initMSAA;
begin
    { Set up event call back }
    hEvHook := SetWinEventHook(
                               EVENT_MIN, EVENT_MAX, // We want all events
                               GetModuleHandle(NIL),   // Use our own module
                               @WinEventProc,          // Our callback function
                               dword(0),               // All processes
                               dword(0),               // All threads
                               WINEVENT_OUTOFCONTEXT   // Receive async events
                              );

    if hEvHook = 0 then
        begin
            mensagem ('MOSEMACC', 1);  {'Acessibililidade não pode ser ativada'}
            halt;
        end;
end;

{--------------------------------------------------------}
{              termina o MSAA
{--------------------------------------------------------}

procedure UnInitMSAA;
begin
    if piacc <> NIL then
        begin
            piacc._Release;
            piacc := NIL;
        end;

    UnhookWinEvent(hEvHook);
end;

{--------------------------------------------------------}
{              obtém um evento da fila
{--------------------------------------------------------}

function trataEventoMSAA: DWORD;
var
    hr: HResult;
    p: ^TEvento;
begin
    trataEventoMSAA := 0;
    if pinsEvento = pretEvento then exit;

    p := @filaEventos [pretEvento];
    pretEvento := (pretEvento + 1) mod 100;

//    if cortaFala then sintPara;

    hwndMsg := p^.ev_hwndMsg;
    idObject := p^.ev_idObject;
    idChild := p^.ev_idChild;

    if piacc <> NIL then
        begin
            piacc._Release;
            piacc := NIL;
        end;

    processWindowsQueue;
    hr := AccessibleObjectFromEvent(hwndMsg, idObject, idChild, pIAcc, vId);
    if hr = S_OK then
        begin
            trataEventoMSAA := p^.ev_event;
            piacc._AddRef;
        end;
end;

{--------------------------------------------------------}
{              obtem dados do último objeto
{--------------------------------------------------------}

procedure obtemObjetoMSAA;
var
    dw: DWORD;
    wc: array [0..65000] of wchar;
    x: integer;
    vRole, vState: Variant;
    pszName, pszInfo: BSTR;

    function umaLinha (valor: string): string;
    begin
        if valor <> '' then
            begin
                x := pos (#$0d, valor);
                if x <> 0 then valor := copy (valor, 1, x-1);
                x := pos (#$0a, valor);
                if x <> 0 then valor := copy (valor, 1, x-1);
                // if length (valor) > 120 then valor := copy (valor, 1, 120);
            end;
        umaLinha := valor;
    end;

begin
    pszName := NIL;
    nome := '';
    tipo := '';
    estado := '';
    valor := '';
    codTipo := 0;

    processWindowsQueue;

    if succeeded (piacc.get_accRole (vId, vRole)) then
        begin
            if varType(vRole) <> 3 then
                codTipo := 8
            else
                begin
                    codTipo := vRole;
                    if codTipo = 0 then exit;
                    getRoleTextW (vRole, wc, 200);
                    tipo := wideCharToString (wc);
                end;
        end;

    xobant := xob;
    yobant := yob;
    processWindowsQueue;
    piacc.accLocation(xob, yob, dxob, dyob, vob);

    processWindowsQueue;
    if succeeded (piacc.get_accName (vId, pszName)) then
            begin
                nome := pszName;
                // nome := umaLinha (nome);
            end;

    if codTipo = 8 then exit;
    if codTipo = 0 then exit;
    if codTipo = ROLE_SYSTEM_TABLE then exit;
    if codTipo = ROLE_SYSTEM_CELL then exit;

    processWindowsQueue;
    if succeeded (piacc.get_accState(vId, vState)) then
        begin
            dw := vState;
            if (dw and STATE_SYSTEM_CHECKED) <> 0 then
                estado := 'marcado';
            if (dw and STATE_SYSTEM_UNAVAILABLE) <> 0 then
                if (vRole <> ROLE_SYSTEM_WINDOW) and
                   (vRole <> ROLE_SYSTEM_SEPARATOR) then
                    estado := 'indisponível';
        end;

    processWindowsQueue;
    if (vRole = ROLE_SYSTEM_PROGRESSBAR) or
       (vRole = ROLE_SYSTEM_SLIDER) or
       (vRole = ROLE_SYSTEM_SPINBUTTON) or
       (vRole = ROLE_SYSTEM_STATICTEXT) or
       (vRole = ROLE_SYSTEM_TEXT) or
       (vRole = ROLE_SYSTEM_COMBOBOX)
       then
           if succeeded (piacc.get_accValue(vId, pszName)) then
               begin
                    valor := pszName;
                    // valor := umaLinha (valor);
               end;

    if vrole = ROLE_SYSTEM_OUTLINEITEM then
        begin
            piacc.get_accValue(vId, pszInfo);
            valor := 'nível ' + pszInfo + valor;
            piacc.get_accDefaultAction(vId, pszInfo);
            if copy (pszInfo, 1, 4) = 'Expa' then valor := valor + ' fechado';
            if copy (pszInfo, 1, 4) = 'Redu' then valor := valor + ' aberto';
        end;

    piacc.get_accChildCount(numFilhos);

    if pszName <> NIL then
        begin
            SysFreeString(pszName);
            pszName := NIL;
        end;
end;

end.
