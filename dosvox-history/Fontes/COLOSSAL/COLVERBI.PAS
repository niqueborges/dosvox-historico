unit colverbi;

interface
uses dvWin, dvCrt,
     colvars, colmsg, colvocab, colglob, coldwarf,
     colfinal, colscore, colsave;

procedure itverb;

implementation
uses colverbt;

{--------------------------------------------------------}
{                 CARRY, TAKE etc.
{--------------------------------------------------------}

procedure ivtake;
var anobj, item: integer;
begin
    anobj := 0;
    for item := 1 to MAXOBJ-1 do
        begin
	    if place[item] = loc then
                begin
		    if anobj <> 0 then
                        begin
			    needobj;
			    exit;
		        end;
		    anobj := item;
                end;
	end;

    if (anobj=0) or ((dcheck>0) and (dflag>=2)) then
        begin
	    needobj;
	    exit;
        end;
    xobject := anobj;
    vtake;
end;

{--------------------------------------------------------}
{                    OPEN, LOCK, UNLOCK
{--------------------------------------------------------}

procedure ivopen;
begin
    if here(CLAM)    then xobject := CLAM;
    if here(OYSTER)  then xobject := OYSTER;
    if at(DOOR)      then xobject := DOOR;
    if at(GRATE)     then xobject := GRATE;

    if here(CHAIN) then
        begin
	    if xobject <> 0 then
                begin
		    needobj;
		    exit;
	        end;
	    xobject := CHAIN;
        end;

    if xobject = 0 then
        begin
	    rspeak(28);
	    exit;
        end;

    vopen;
end;

{--------------------------------------------------------}
{  assegura unicidade de objetos de um verbo intransitivo
{--------------------------------------------------------}

procedure addobj(obj: integer);
begin
    if object1 <> 0 then exit;

    if xobject <> 0 then
        begin
	    object1 := -1;
	    exit;
	end;

    xobject := obj;
end;

{--------------------------------------------------------}
{                    ATTACK, KILL etc
{--------------------------------------------------------}

procedure ivkill;
begin
    object1 := 0;

    if (dcheck > 0) and (dflag >= 2)   then
        xobject := DWARF;

    if here(SNAKE) then
        addobj(SNAKE);

    if at(DRAGON) and (prop[DRAGON] = 0) then
	    addobj(DRAGON);

    if at(TROLL) then
	    addobj(TROLL);

    if here(BEAR) and (prop[BEAR] = 0) then
	    addobj(BEAR);

    if object1 <> 0 then
        begin
	    needobj;
	    exit;
        end;

    if xobject <> 0 then
        begin
	    vkill;
	    exit;
        end;

    if here(BIRD) and (verb <> THROW) then
        xobject := BIRD;

    if here(CLAM) or here(OYSTER) then
        addobj(CLAM);

    if object1 <> 0 then
        begin
	    needobj;
	    exit;
        end;

    vkill;
end;

{--------------------------------------------------------}
{                   	EAT
{--------------------------------------------------------}

procedure iveat;
begin
	if not here(FOOD) then
	    needobj
	else
            begin
		xobject := FOOD;
		veat;
            end;
end;

{--------------------------------------------------------}
{                      DRINK
{--------------------------------------------------------}

procedure ivdrink;
begin
    if (liqloc(loc) <> WATER) and
       ((liq <> WATER) or (not here(BOTTLE))) then
        needobj
    else
        begin
	    xobject := WATER;
	    vdrink;
	end;
end;

{--------------------------------------------------------}
{                        QUIT
{--------------------------------------------------------}

procedure ivquit;
begin
    gaveup := yes(22,54,54);
    if gaveup then
        normend;
end;

{--------------------------------------------------------}
{                          FILL
{--------------------------------------------------------}

procedure ivfill;
begin
    if not here(BOTTLE) then
        needobj
    else
        begin
	    xobject := BOTTLE;
	    vfill;
        end;
end;

{--------------------------------------------------------}
{                 Handle fee fie foe foo...
{--------------------------------------------------------}

procedure ivfoo;
var k, msg: integer;
begin
    k := vocab(word1,3000);
    msg := 42;

    if foobar <> 1-k then
        begin
	    if foobar <> 0 then
		msg := 151;
	    rspeak(msg);
	    exit;
        end;

    foobar := k;
    if k <> 4 then
	exit;

    foobar := 0;
    if (place[EGGS] = 92) or
       (toting(EGGS) and (loc = 92)) then
        begin
   	    rspeak(msg);
	    exit;
        end;

    if (place[EGGS] = 0) and (place[TROLL] = 0) and (prop[TROLL] = 0) then
        prop[TROLL] := 1;

    if here(EGGS) then  k := 1
    else
    if loc = 92 then    k := 0
    else
	                k := 2;
    xmove(EGGS,92);
    pspeak(EGGS,k);
    exit;
end;

{--------------------------------------------------------}
{                      read etc...
{--------------------------------------------------------}

procedure ivread;
begin
    if here(MAGAZINE) then   xobject := MAGAZINE;
    if here(TABLET)   then   xobject := xobject*100 + TABLET;
    if here(MESSAGE)  then   xobject := xobject*100 + MESSAGE;

    if (xobject > 100) or (xobject = 0) or dark then
        begin
	    needobj;
	    exit;
        end;

    vread;
end;

{--------------------------------------------------------}
{                       INVENTORY
{--------------------------------------------------------}

procedure ivinventory;
var i, msg: integer;
begin
    msg := 98;
    for i := 1 to MAXOBJ-1 do
        begin
	    if (i=BEAR) or (not toting(i)) then
	        continue;
	    if msg <> 0 then rspeak(99);
	    msg := 0;
	    pspeak(i,-1);
        end;

    if toting(BEAR) then
        msg := 141;

    if msg <> 0 then
        rspeak(msg);
end;

{--------------------------------------------------------}
{         processamento de verbos intransitivos
{--------------------------------------------------------}

procedure itverb;
begin
    case verb of
	DROP, SAY, WAVE,
        CALM, RUB, THROW,
        FIND, FEED, BREAK,
        WAKE:       needobj;

	TAKE:       ivtake;
	OPEN,
	LOCK:       ivopen;
	NOTHING:    rspeak(54);
	ON, OFF,
        POUR:       trverb;
	WALK:       actspk(verb);
	KILL:       ivkill;
        EAT:        iveat;
	DRINK:      ivdrink;
	QUIT:       ivquit;
        FILL:       ivfill;
	BLAST:      vblast;
	SCORE:      showScore;
	FOO:        ivfoo;
	SUSPEND:    saveadv;
	INVENTORY:  ivinventory;

    else
        sintWriteln (msgExtra[MSG_NOTIMPLEM]);
    end;
end;



end.


