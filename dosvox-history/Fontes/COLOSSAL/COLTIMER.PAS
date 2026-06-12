{--------------------------------------------------------}
{
{    Caverna colossal - jogo de aventura
{
{    Módulo de controle do tempo
{
{    Em março/2001
{
{--------------------------------------------------------}

unit coltimer;
interface
uses sysutils, colvars, colmsg, colglob, colfinal;

function stimer: boolean;

implementation

{--------------------------------------------------------}
{               controle do tempo especial
{--------------------------------------------------------}

function stimer: boolean;
var i: integer;
label retFalse;
begin
    if foobar > 0 then
        foobar := -foobar
    else
        foobar := 0;

    if (tally = 0) and (loc >= 15) and (loc <> 33) then
	clock := clock - 1;

    if clock = 0 then
        begin
	    prop[GRATE] := 0;          {	start closing the cave }
	    prop[FISSURE] := 0;
	    for i := 1 to DWARFMAX-1 do
                dseen[i] := 0;
	    xmove(TROLL, 0);
	    xmove((TROLL+MAXOBJ), 0);
	    xmove(TROLL2, 117);
	    xmove((TROLL2+MAXOBJ), 122);
	    juggle(CHASM);
	    if prop[BEAR] <> 3 then
                dstroy(BEAR);
	    prop[CHAIN] := 0;
	    fixed[CHAIN] := 0;
	    prop[AXE] := 0;
	    fixed[AXE] := 0;
	    rspeak(129);
	    clock := -1;
	    closing := true;
	    goto retFalse;
	end;

    if clock < 0 then
        clock2 := clock2 - 1;

    if clock2 = 0 then
        begin
	    { set up storage room...   and close the cave... }
	    prop[BOTTLE]  := put(BOTTLE, 115, 1);
	    prop[PLANT]   := put(PLANT, 115, 0);
	    prop[OYSTER]  := put(OYSTER, 115, 0);
	    prop[LAMP]    := put(LAMP, 115, 0);
	    prop[ROD]     := put(ROD, 115, 0);
	    prop[DWARF]   := put(DWARF, 115, 0);
	    loc := 115;
	    oldloc := 115;
	    newloc := 115;
	    put(GRATE, 116, 0);
	    prop[SNAKE]   := put(SNAKE, 116, 1);
	    prop[BIRD]    := put(BIRD, 116, 1);
	    prop[CAGE]    := put(CAGE, 116, 0);
	    prop[ROD2]    := put(ROD2, 116, 0);
	    prop[PILLOW]  := put(PILLOW, 116, 0);
	    prop[MIRROR]  := put(MIRROR, 115, 0);
	    fixed[MIRROR] := 116;
	    for i := 1 to MAXOBJ do
		if toting(i) then dstroy(i);
	    rspeak(132);
	    closed := true;
	    stimer := true;
            exit;
	end;

    if prop[LAMP] = 1 then
	    limit := limit - 1;

    if (limit <= 30) and
	here(BATTERIES) and (prop[BATTERIES] = 0) and here(LAMP)  then
        begin
	    rspeak(188);
	    prop[BATTERIES] := 1;
	    if toting(BATTERIES) then
		xdrop(BATTERIES, loc);
	    limit := limit + 2500;
	    lmwarn := 0;
	    goto retFalse;
	end;

    if limit = 0 then
        begin
	    limit := limit - 1;
	    prop[LAMP] := 0;
	    if here(LAMP) then
		    rspeak(184);
	    goto retFalse;
        end;

    if (limit < 0) and (loc <= 8) then
        begin
	    rspeak(185);
	    gaveup := true;
	    normend;
	end;

    if (limit <= 30) then
        begin
	    if (lmwarn <> 0) or (not here(LAMP)) then
		  goto retFalse;

	    lmwarn := 1;
	    i := 187;
	    if place[BATTERIES] = 0 then
		    i := 183;
	    if prop[BATTERIES] = 1 then
		    i := 189;
	    rspeak(i);
	    goto retFalse;
	end;

retFalse:
    stimer := false;
end;

end.
