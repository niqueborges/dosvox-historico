{--------------------------------------------------------}
{
{    Comunicação com servidor DDE
{
{    Autor: Jose' Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit dvDDE;

interface
uses dvcrt, windows, messages, sysUtils;

var hwndServer: hwnd;
    linkEstabelecido: boolean;
    DDEStatus: word;

function enviaServidorDDE (servidor, topico, item: string; p: pchar): boolean;
function enviaStringDDE (servidor, topico, item, s: string): boolean;

implementation

{--------------------------------------------------------}

procedure setLink (serverName, serverTopic: pchar);
var
   appAtom, appTopic: TAtom;

begin
    appAtom := globalAddAtom (serverName);
    appTopic := globalAddAtom (serverTopic);
    sendMessage (word(-1), WM_DDE_INITIATE, crtWindow,
                       makeLong (appAtom, appTopic));
    globalDeleteAtom (appAtom);
    globalDeleteAtom (appTopic);
end;

procedure closeLink;
begin
    postMessage (hwndServer, WM_DDE_TERMINATE, crtWindow, 0);
    linkEstabelecido := false;
end;

procedure pokeLink (serverItem, pText: pchar);
var hdata: THandle;
    appTopic: TAtom;
    pPokeData: ^TDDEPoke;

begin
    hdata := globalAlloc (gmem_moveable or gmem_DDEshare, strLen(pText) + 1 + sizeof (TDDEPoke));
    pPokeData := globalLock (hdata);
    with pPokeData^ do
        begin
            flags := dde_Release;
            cfFormat := CF_TEXT;
            strcopy (@value, pText);
        end;
    globalUnlock (hdata);

    appTopic := globalAddAtom (serverItem);
    postMessage (hwndServer, WM_DDE_POKE, crtWindow, makelong (hdata, appTopic));
    globalDeleteAtom (appTopic);
end;

procedure myWinProc (Window: HWnd; Message: UINT; WParam: WPARAM; LParam: LPARAM;
                       var resultx: LRESULT);  far;
var
   appAtom, appTopic: TAtom;
   hmem: THandle;

begin
    resultx := 0;
    case message of
        WM_DDE_ACK:
            begin
                if not linkEstabelecido then
                    begin
                        appAtom  := loWord (lparam);
                        appTopic := hiWord (lparam);
                        if appAtom  <> 0 then globalDeleteAtom (appAtom);
                        if appTopic <> 0 then globalDeleteAtom (appTopic);
                        hwndServer := wparam;
                        linkEstabelecido := true;
                    end
                else
                    begin
                        DDEstatus := loword (lparam);
                        hmem := hiword (lparam);
                        if hmem <> 0 then
                            globalFree (hmem);
                    end;

                resultx := 1;
            end;

        WM_DDE_TERMINATE:
            begin
                linkEstabelecido := false;
                resultx := 1;
            end;
    end;
end;

function enviaServidorDDE (servidor, topico, item: string; p: pchar): boolean;
begin
    alternateWinProc := myWinProc;
    hasAlternateWinProc := true;
    linkEstabelecido := false;

    servidor := servidor + #$0;
    topico := topico + #$0;
    item := item + #$0;

    setLink (@servidor[1], @topico[1]);
    if linkEstabelecido then
        begin
            enviaServidorDDE := true;
            pokeLink (@item[1], p);
            closeLink;
        end
    else
        enviaServidorDDE := false;

    hasAlternateWinProc := false;
end;

function enviaStringDDE (servidor, topico, item, s: string): boolean;
begin
    alternateWinProc := myWinProc;
    hasAlternateWinProc := true;
    linkEstabelecido := false;

    servidor := servidor + #$0;
    topico := topico + #$0;
    item := item + #$0;

    setLink (@servidor[1], @topico[1]);
    if linkEstabelecido then
        begin
            enviaStringDDE := true;
            s := s + #$0;
            pokeLink (@item[1], @s[1]);
            closeLink;
        end
    else
        enviaStringDDE := false;

    hasAlternateWinProc := false;
end;

end.
