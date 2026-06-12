{--------------------------------------------------------}
{
{    Caverna colossal - jogo de aventura
{
{    Módulo de mensagens e coisas referentes à lingua
{
{    Em março/2001
{
{--------------------------------------------------------}

unit colmsg;
interface
uses dvwin, dvcrt, sysutils, colvars;

function loadMessages: boolean;

procedure rspeak (msg: integer);
procedure pspeak (item, state: integer);
procedure desclg (loc: integer);
procedure descsh (loc: integer);

function yes(msg1, msg2, msg3: integer): boolean;

procedure bug (n: integer);

{--------------------------------------------------------}

type
    pstring = ^string;
var
    msgPlaces1: array [1..600] of pchar;
    msgPlaces2: array [1..600] of pchar;
    msgObjects: array [1..350] of pchar;
    msgSituation: array [1..650] of pchar;
    msgExtra: array [1..50] of string;

{--------------------------------------------------------}

const
    MSG_BADGRAMMAR  = 1;  {'bad grammar...'}
    MSG_NOTIMPLEM   = 2;  {'I don''t know how to do this.'}
    MSG_WHAT        = 3;  {' what?'}
    MSG_WHATTODO    = 4;  {'What do you want to do with the '}
    MSG_DWARF       = 5;  {' threatening little dwarves are now in the room with you!'}
    MSG_ATTACK      = 6;  {' of them throw knives at you!'}
    MSG_STUCK       = 7;  {' of them get you !!!'}
    MSG_ISEENO      = 8;  {'I see no '}
    MSG_HERE        = 9;  {' here.'}

    MSG_TREASURES   = 10; {'Treasures:       '}
    MSG_SURVIVAL    = 11; {'Survival:        '}
    MSG_GETTINGWELL = 12; {'Getting well in: '}
    MSG_MASTERS     = 13; {'Masters section: '}
    MSG_BONUS       = 14; {'Bonus:           '}
    MSG_SCORE       = 15; {'Score:           '}

    MSG_TOACHIEVE   = 16; {'To achieve the next higher rating'}
    MSG_YOUNEED     = 17; {', you need '}
    MSG_MOREPOINT   = 18; {' more point'}
    MSG_NEATTRICK   = 19; {' would be a neat trick!'}
    MSG_CONGRATUL   = 20; {'Congratulations!'}
    MSG_OFFSCALE    = 21; {'You just went off my scale!'}

    MSG_OLDFILENAME = 22; {'In what file is old saved game? '}
    MSG_NOFILE      = 23; {'File not found.'}
    MSG_READERROR   = 24; {'File read error.'}
    MSG_NEWFILENAME = 25; {'Type a file name to save the game? '}
    MSG_NOTCREATED  = 26; {'Coudn''t create the file!'}
    MSG_SAVED       = 27; {'Game saved...'}
    MSG_WRITEERROR  = 28; {'File write error.'}

    MSG_YOUSCORED   = 29; {'You scored '}
    MSG_OUTOF       = 30; {' out of a possible '}
    MSG_USING       = 31; {', using '}
    MSG_TURNS       = 32; {' turns.'}
    MSG_REENTER     = 33; {'Reentering the colossal cave'}
    MSG_VERSION     = 34; {'Version '}

implementation

{--------------------------------------------------------}
{      escreve uma descrição da situação ou lugar
{--------------------------------------------------------}

procedure rspeak (msg: integer);
var
    s: string[10];
    ps: array[0..10] of char;
    p: integer;
begin
    if msg = 54 then
        sintWriteln ('ok.')
    else
        begin
            str (msg, s);
            strPCopy (ps, '#' + s);
            p := 0;
            repeat
                p := p + 1;
            until strcomp (msgSituation[p], ps) = 0;

            repeat
                p := p + 1;
                if msgSituation[p][0] = '*' then
                    writeln (copy (strPas(msgSituation[p]), 2, 999))
                else
                    sintWriteln (strPas(msgSituation[p]));
            until msgSituation[p+1, 0] = '#';
	end;
end;

{--------------------------------------------------------}
{  escreve uma mensagem de item para um estado (msgAdv3)
{--------------------------------------------------------}

procedure pspeak(item, state: integer);
var
    s: string[10];
    ps: array[0..10] of char;
    p, i: integer;
begin
    str (item, s);
    strPCopy (ps, '#' + s);
    p := 0;
    repeat
        p := p + 1;
    until strcomp (msgObjects[p], ps) = 0;

    for i := 0 to state+1 do
        repeat
            p := p + 1;
        until msgObjects[p, 0] = '/';

    repeat
        if strPas(msgObjects[p]) <> '/' then
            sintWriteln (strPas(msgObjects[p]+1));
        p := p + 1;
    until (msgObjects[p, 0] = '/') or (msgObjects[p, 0] = '#');
end;

{--------------------------------------------------------}
{          escreve uma descrição longa (msgAdv1)
{--------------------------------------------------------}

procedure desclg(loc: integer);
var
    s: string[10];
    ps: array[0..10] of char;
    p: integer;
begin
    str (loc, s);
    strPCopy (ps, '#' + s);
    p := 0;
    repeat
        p := p + 1;
    until strcomp (msgPlaces1[p], ps) = 0;
    repeat
        p := p + 1;
        sintWriteln (strPas(msgPlaces1[p]));
    until msgPlaces1[p+1, 0] = '#';
end;

{--------------------------------------------------------}
{          escreve uma descrição longa (msgAdv2)
{--------------------------------------------------------}

procedure descsh (loc: integer);
var
    s: string[10];
    ps: array[0..10] of char;
    p: integer;
begin
    str (loc, s);
    strPCopy (ps, '#' + s);
    p := 0;
    repeat
        p := p + 1;
    until strcomp (msgPlaces2[p], ps) = 0;
    repeat
        p := p + 1;
        sintWriteln (strPas(msgPlaces2[p]));
    until msgPlaces2[p+1, 0] = '#';
end;

{--------------------------------------------------------}
{                pede sim ou não como resposta
{--------------------------------------------------------}

function yes(msg1, msg2, msg3: integer): boolean;
var c, c2: char;
    save: word;
begin
    if msg1 <> 0 then
        rspeak(msg1);
    save := textattr;
    textColor (green);
    write ('>');
    sintLeTecla (c, c2);
    textattr := save;
    writeln;

    if (upcase (c) <> 'Y') and (upcase (c) <> 'S') then
        begin
	    yes := false;
            if msg3 <> 0 then
	        rspeak(msg3);
            exit;
        end;

    if msg2 <> 0 then
        rspeak(msg2);
    yes := true;
end;

{--------------------------------------------------------}
{                        erro fatal
{--------------------------------------------------------}

procedure bug (n: integer);
begin
    sintWriteln ('Fatal error!  Code=');
    sintWriteint (n);
    writeln;

    readln;
    sintFim;
    doneWinCrt;
end;

{--------------------------------------------------------}
{            carrega um arquivo de mensagens
{--------------------------------------------------------}

type
    vetmsg = array [1..10000] of pchar;
    pvetmsg = ^vetmsg;

function loadFile (fileName: string; pmsg: pvetmsg): boolean;
var f: text;
    n: integer;
    s: string;
begin
    assign (f, filename);
    {$I-}  reset (f);  {$I+}
    if ioresult <> 0 then
        begin
            loadFile := false;
            exit;
        end;

    n := 0;
    while not eof (f) do
        begin
            {$I-}  readln (f, s);   {$I+}
            if ioresult <> 0 then
                begin
                    loadFile := false;
                    exit;
                end;

            n := n + 1;
            getmem (pmsg^[n], length(s)+1);
            strPCopy (pmsg^[n], s);
        end;

    n := n + 1;
    getmem (pmsg^[n], 2);
    strPCopy (pmsg^[n], '#');
    close (f);

    loadFile := true;
end;

{--------------------------------------------------------}
{         carrega o arquivo de mensagens extras
{--------------------------------------------------------}

function loadExtraFile (fileName: string): boolean;
var f: text;
    n, p, error: integer;
    s: string;
begin
    assign (f, filename);
    {$I-}  reset (f);  {$I+}
    if ioresult <> 0 then
        begin
            loadExtraFile := false;
            exit;
        end;

    while not eof (f) do
        begin
            {$I-}  readln (f, s);   {$I+}
            if ioresult <> 0 then
                begin
                    loadExtraFile := false;
                    exit;
                end;

            if (s = '') or (s[1] = '#') then continue;

            p := pos (' ', s);
            val (copy (s, 1, p-1), n, error);
            if (error <> 0) or (n = 0) then
                 begin
                     writeln (s);
                     close (f);
                     loadExtraFile := false;
                     exit;
                 end;

            p := pos ('''', s);
            delete (s, 1, p);
            delete (s, length(s), 1);
            msgExtra[n] := s;
        end;

    close (f);

    loadExtraFile := true;
end;

{--------------------------------------------------------}
{              descobre diretório de textos
{--------------------------------------------------------}

function setGlobalDir: boolean;
var
    testFile: text;
label ok;
begin
    globalDir := sintAmbiente ('COLOSSAL', 'DIRTEXTOS');
    if (globalDir <> '') and
       (globalDir [length(globalDir)] <> '\') then
             globalDir := globalDir + '\';

    assign (testFile, globalDir + 'advpor1.txt');
    {$I-} reset (testFile);  {$I+}
    if ioresult = 0 then goto ok;

    globalDir := '\winvox\colossal\';
    assign (testFile, globalDir + 'advpor1.txt');
    {$I-} reset (testFile);  {$I+}
    if ioresult = 0 then goto ok;

    globalDir := '.\';
    assign (testFile, globalDir + 'advpor1.txt');
    {$I-} reset (testFile);  {$I+}
    if ioresult = 0 then goto ok;

    setGlobalDir := false;
    exit;

ok:
    close (testFile);
    setGlobalDir := true;
end;

{--------------------------------------------------------}
{            carrega as mensagens na memória
{--------------------------------------------------------}

function loadMessages: boolean;
var filename: string;
label error;
begin
    filename := '';
    if not setGlobalDir then
        goto error;

    filename := globalDir + LANGFILE + '1.txt';
    if not loadFile (filename, @msgPlaces1)   then goto error;
    filename := globalDir + LANGFILE + '2.txt';
    if not loadFile (filename, @msgPlaces2)   then goto error;
    filename := globalDir + LANGFILE + '3.txt';
    if not loadFile (filename, @msgObjects)   then goto error;
    filename := globalDir + LANGFILE + '4.txt';
    if not loadFile (filename, @msgSituation) then goto error;

    filename := globalDir + LANGFILE + '7.txt';
    if not loadExtraFile (filename) then goto error;
    loadMessages := true;
    exit;

error:
    sintWriteln ('Erro: ' + filename);
    loadMessages := false;
end;

end.
