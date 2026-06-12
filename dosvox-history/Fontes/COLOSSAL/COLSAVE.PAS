unit colsave;
interface
uses dvwin, colvars, colmsg;

function restore: boolean;
function saveadv: boolean;

implementation

{--------------------------------------------------------}
{                 restaura jogo salvo
{--------------------------------------------------------}

function restore: boolean;
var
    oldName: string;
    restfd: file;
    p: integer;
    nrd: integer;
label erro;
begin
    sintWriteln (msgExtra[MSG_REENTER]);
    writeln;

    if savedFileName = '' then
        begin
            sintWrite (msgExtra[MSG_OLDFILENAME]);
            sintReadln (oldName);
        end
    else
        oldName := savedFileName;

    p := pos('.', oldName);
    if p > 0 then
        delete (oldName, p, 99);
    assign (restfd, oldName + '.adv');
    {$I-}  reset (restfd, 1);  {$I+}
    if ioresult <> 0 then
        begin
            sintWriteln (msgExtra[MSG_NOFILE]);
            restore := false;
            exit;
        end;

    {$I-}
    blockread (restfd, cond, sizeof(cond));
    if ioresult <> 0 then goto erro;
    blockread (restfd, place, sizeof(place));
    if ioresult <> 0 then goto erro;
    blockread (restfd, fixed, sizeof(fixed));
    if ioresult <> 0 then goto erro;
    blockread (restfd, actmsg, sizeof(actmsg));
    if ioresult <> 0 then goto erro;
    blockread (restfd, dloc, sizeof(dloc));
    if ioresult <> 0 then goto erro;
    blockread (restfd, firstvar, longint(addr(lastvar)) - longint(addr(firstvar)), nrd);
    if ioresult <> 0 then goto erro;
    {$I+}

    writeln;
    restore := true;
    exit;

erro:
    sintWriteln (msgExtra[MSG_READERROR]);
    close (restfd);
    restore := false;
end;

{--------------------------------------------------------}
{                       salva o jogo
{--------------------------------------------------------}

function saveadv: boolean;
var
    saveName: string;
    savefd: file;
    p: integer;
label erro;

begin
    sintWrite (msgExtra[MSG_NEWFILENAME]);
    sintReadln (saveName);

    p := pos('.', saveName);
    if p > 0 then
        delete (saveName, p, 99);
    assign (savefd, saveName + '.adv');
    {$I-}  rewrite (savefd, 1);  {$I+}
    if ioresult <> 0 then
        begin
            sintWriteln (msgExtra[MSG_NOTCREATED]);
            saveAdv := false;
            exit;
        end;

    {$I-}
    blockwrite (savefd, cond, sizeof(cond));
    if ioresult <> 0 then goto erro;
    blockwrite (savefd, place, sizeof(place));
    if ioresult <> 0 then goto erro;
    blockwrite (savefd, fixed, sizeof(fixed));
    if ioresult <> 0 then goto erro;
    blockwrite (savefd, actmsg, sizeof(actmsg));
    if ioresult <> 0 then goto erro;
    blockwrite (savefd, dloc, sizeof(dloc));
    if ioresult <> 0 then goto erro;
    blockwrite (savefd, firstvar, longint(addr(lastvar)) - longint(addr(firstvar)) );
    if ioresult <> 0 then goto erro;
    {$I+}

    sintWriteln (msgExtra[MSG_SAVED]);
    writeln;
    saveadv := true;
    exit;

erro:
    sintWriteln (msgExtra[MSG_WRITEERROR]);
    close (savefd);
    saveadv := false;
end;

end.