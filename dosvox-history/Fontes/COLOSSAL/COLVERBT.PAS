{--------------------------------------------------------}
{
{    Caverna colossal - jogo de aventura
{
{    Processamento de verbos transitivos
{
{    Em março/2001
{
{--------------------------------------------------------}

unit colverbt;
interface
uses
    dvCrt, dvWin, sysutils,
    colvars, colmsg, colglob, colvocab, coldwarf,
    coldescr, colfinal, colmove;

procedure trverb;
procedure needobj;
procedure vtake;
procedure vopen;
procedure vkill;
procedure vfill;
procedure vfeed;
procedure veat;
procedure vdrink;
procedure vread;
procedure vblast;
procedure doobj;

implementation
uses colverbi;

{--------------------------------------------------------}
{      não foi achada objeto razoável para o verbo
{--------------------------------------------------------}

procedure needobj;
var wtype, wval: integer;
begin
    analyze(word1, wtype, wval);
    if wtype = 2 then
        sintWriteln (strPas (word1) + msgExtra[MSG_WHAT])
    else
        sintWriteln (strPas (word2) + msgExtra[MSG_WHAT])
end;

{--------------------------------------------------------}
{      imprime uma palavra correspondente ao objeto
{--------------------------------------------------------}

function probj: pchar;
var wtype, wval: integer;
begin
    analyze(word1, wtype, wval);
    if wtype = 1 then
        probj := word1
    else
        probj := word2;
end;

{--------------------------------------------------------}
{         processa um objeto sendo referenciado
{--------------------------------------------------------}

procedure trobj;
begin
    if verb <> 0 then
        trverb
    else
        sintWriteln (msgExtra[MSG_WHATTODO] + strPas(probj) + '?');
end;

{--------------------------------------------------------}
{                   processa um objeto
{--------------------------------------------------------}

procedure doobj;
var i: integer;
begin

    { is object here?  if so, transitive }

    if (fixed[xobject] = loc) or here(xobject) then
        trobj
    else

    { did he give grate as destination? }

    if xobject = GRATE then
        begin
	    if (loc = 1) or (loc = 4) or (loc = 7) then
                begin
		    motion := DEPRESSION;
		    domove;
                end
	    else
            if (loc>9) and (loc<15) then
                begin
		    motion := ENTRANCE;
		    domove;
                end;
        end
    else


    { is it a dwarf he is after? }

    if (dcheck > 0) and (dflag >= 2) then
        begin
	    xobject := DWARF;
	    trobj;
        end
    else

    { is he trying to get/use a liquid? }

    if ((liq = xobject) and here(BOTTLE)) or
	           (liqloc(loc) = xobject) then
        trobj
    else
    if (xobject = PLANT) and at(PLANT2) and
	    (prop[PLANT2] = 0) then
        begin
	    xobject := PLANT2;
	    trobj;
        end
    else

    { is he trying to grab a knife?  }

    if (xobject = KNIFE) and (knfloc = loc) then
        begin
	    rspeak(116);
	    knfloc := -1;
        end
    else

    { is he trying to get at dynamite? }

    if (xobject = ROD) and here(ROD2) then
        begin
	    xobject := ROD2;
	    trobj;
        end
    else
        sintWriteln (msgExtra[MSG_ISEENO] + strPas (probj) + msgExtra[MSG_HERE]);
end;

{--------------------------------------------------------}
{               CARRY TAKE etc.
{--------------------------------------------------------}

procedure vtake;
var msg, i: integer;
begin
    if toting(xobject) then
        begin
	    actspk(verb);
	    exit;
        end;

    { special case objects and fixed objects }

    msg := 25;
    if (xobject = PLANT) and (prop[PLANT] <= 0) then msg := 115;
    if (xobject = BEAR)  and (prop[BEAR] = 1)   then msg := 169;
    if (xobject = CHAIN) and (prop[BEAR] <> 0)  then msg := 170;
    if fixed[xobject] <> 0 then
        begin
	    rspeak(msg);
	    exit;
        end;

    { special case for liquids }

    if (xobject = WATER) or (xobject = OIL) then
        begin
	    if (not here(BOTTLE)) or (liq <> xobject) then
                begin
		    xobject := BOTTLE;
		    if toting(BOTTLE) and (prop[BOTTLE] = 1) then
                        begin
			    vfill;
			    exit;
		        end;
		    if prop[BOTTLE] <> 1  then msg := 105;
		    if not toting(BOTTLE) then msg := 104;
		    rspeak(msg);
		    exit;
	        end;

	    xobject := BOTTLE;
        end;

    if holding >= 7 then
        begin
	    rspeak(92);
	    exit;
        end;

    { special case for bird. }

    if (xobject = BIRD) and (prop[BIRD] = 0) then
        begin
	    if toting(ROD) then
                begin
		    rspeak(26);
		    exit;
	        end;

	    if not toting(CAGE) then
                begin
                    rspeak(27);
		    exit;
                end;

	    prop[BIRD] := 1;
        end;

    if ( (xobject = BIRD) or (xobject = CAGE) and
         (prop[BIRD] <> 0)  ) then
        carry((BIRD+CAGE)-xobject,loc);

    carry(xobject,loc);

    { handle liquid in bottle }

    i := liq;
    if (xobject = BOTTLE) and (i <> 0) then
        place[i] := -1;

    rspeak(54);
end;

{--------------------------------------------------------}
{                     DROP etc.
{--------------------------------------------------------}

procedure vdrop;
var i: integer;
begin
    { check for dynamite }

    if toting(ROD2) and (xobject = ROD) and (not toting(ROD)) then
        xobject := ROD2;

    if not toting(xobject) then
        begin
	    actspk(verb);
	    exit;
        end;

    { snake and bird }

    if (xobject = BIRD) and here(SNAKE) then
        begin
	    rspeak(30);
	    if closed then
                dwarfend;
	    dstroy(SNAKE);
	    prop[SNAKE] := -1;
        end
    else
            { coins and vending machine }

    if (xobject = COINS) and (here(VEND)) then
        begin
	    dstroy(COINS);
	    xdrop(BATTERIES,loc);
	    pspeak(BATTERIES,0);
	    exit;
        end
    else
            { bird and dragon (ouch!!)  }

    if (xobject = BIRD) and at(DRAGON) and (prop[DRAGON] = 0) then
        begin
	    rspeak(154);
	    dstroy(BIRD);
	    prop[BIRD] := 0;
	    if (place[SNAKE] <> 0) then
                tally2 := tally2 + 1;
	    exit;
        end;


    { Bear and troll }

    if (xobject = BEAR) and at(TROLL) then
        begin
	    rspeak(163);
	    xmove(TROLL,0);
	    xmove((TROLL+MAXOBJ),0);
	    xmove(TROLL2,117);
	    xmove((TROLL2+MAXOBJ),122);
	    juggle(CHASM);
	    prop[TROLL] := 2;
        end
    else

        { vase }

    if xobject = VASE then
        begin
	    if loc = 96 then
                rspeak(54)
	    else
                begin
                    if at(PILLOW) then
                        prop[VASE] := 0
                    else
		        prop[VASE] := 2;
		    pspeak(VASE, prop[VASE]+1);
		    if prop[VASE] <> 0 then
		        fixed[VASE] := -1;
	        end;
        end;

    { handle liquid and bottle }

    i := liq;
    if i = xobject then
        xobject := BOTTLE;
    if (xobject = BOTTLE) and (i <> 0) then
        place[i] := 0;

    { handle bird and cage }

    if (xobject = CAGE) and (prop[BIRD] <> 0) then
        xdrop(BIRD,loc);
    if xobject = BIRD then
        prop[BIRD] := 0;
    xdrop(xobject,loc);
end;

{--------------------------------------------------------}
{               LOCK, UNLOCK, OPEN, CLOSE etc.
{--------------------------------------------------------}

procedure vopen;
var msg,oyclam: integer;
begin
    case xobject of
    CLAM, OYSTER:
        begin
            if xobject = OYSTER then   oyclam := 1
                                else   oyclam := 0;

 	    if verb = LOCK          then  msg := 61
	    else
            if not toting(TRIDENT)  then  msg := 122+oyclam
	    else
            if toting(xobject)      then  msg := 120+oyclam
	    else
                begin
		    msg := 124+oyclam;
		    dstroy(CLAM);
		    xdrop(OYSTER,loc);
		    xdrop(PEARL,105);
	        end;
	end;

    DOOR:   if prop[DOOR] = 1 then   msg := 54
                              else   msg := 111;
    CAGE:   msg := 32;
    KEYS:   msg := 55;

    CHAIN:
        begin
	    if not here(KEYS) then   msg := 31
	    else
            if verb = LOCK then
                begin
		    if prop[CHAIN] <> 0 then msg := 34
		    else
                    if loc <> 130       then msg := 173
		    else
                        begin
			    prop[CHAIN] := 2;
			    if toting(CHAIN) then
			         xdrop(CHAIN,loc);
			    fixed[CHAIN] := -1;
			    msg := 172;
		        end;
	        end
	    else
                begin
		    if prop[BEAR] = 0    then  msg := 41
		    else
                    if prop[CHAIN] = 0   then  msg := 37
		    else
                        begin
			    prop[CHAIN] := 0;
			    fixed[CHAIN] := 0;
			    if prop[BEAR] <> 3 then
			        prop[BEAR] := 2;
			    fixed[BEAR] := 2-prop[BEAR];
			    msg := 171;
		        end;
                end;
        end;

    GRATE:
        begin
	    if not here(KEYS) then     msg := 31
	    else
            if closing then
                begin
	            if not panic then
                        begin
			    clock2 := 15;
			    panic := true;
		        end;
		    msg := 130;
	        end
	    else
                begin
		    msg := 34+prop[GRATE];
                    if verb = LOCK then  prop[GRATE] := 0
                                   else  prop[GRATE] := 1;
		    msg := msg + 2*prop[GRATE];
	        end;
        end;

    else
	msg := 33;
    end;

    rspeak(msg);
end;

{--------------------------------------------------------}
{                        SAY etc.
{--------------------------------------------------------}

procedure vsay;
var wtype, wval: integer;
begin
    analyze(word1, wtype, wval);
    sintWriteln ('Okay.');
    if wval = SAY then
        sintWriteln (strPas(word2))
    else
        sintWriteln (strPas(word1));
end;

{--------------------------------------------------------}
{                      ON etc.
{--------------------------------------------------------}

procedure von;
begin
    if not here(LAMP) then
	actspk(verb)
    else
    if limit < 0 then
	rspeak(184)
    else
        begin
	    prop[LAMP] := 1;
	    rspeak(39);
	    if wzdark then
                begin
		    wzdark := false;
		    { describe; }
		end;
	end;
end;

{--------------------------------------------------------}
{                      OFF etc.
{--------------------------------------------------------}

procedure voff;
begin
    if not here(LAMP) then
       actspk(verb)
    else
        begin
	    prop[LAMP] := 0;
	    rspeak(40);
        end;
end;

{--------------------------------------------------------}
{                      WAVE etc.
{--------------------------------------------------------}

procedure vwave;
begin
	if (not toting(xobject)) and
	   ( (xobject <> ROD) or (not toting(ROD2))) then
	    rspeak(29)
        else
        if (xobject <> ROD) or (not at(FISSURE)) or
		(not toting(xobject)) or closing then
            actspk(verb)
	else
            begin
		prop[FISSURE] := 1-prop[FISSURE];
		pspeak(FISSURE, 2-prop[FISSURE]);
	    end;
end;

{--------------------------------------------------------}
{                   ATTACK, KILL etc.
{--------------------------------------------------------}

procedure vkill;
var msg, i: integer;
begin
    case xobject of
    BIRD:
        begin
	    if closed then
                msg := 137
	    else
                begin
		    dstroy(BIRD);
		    prop[BIRD] := 0;
		    if place[SNAKE] = 19 then
   		        tally2 := tally2 + 1;
		    msg := 45;
	        end;
        end;

    0:        msg := 44;

    CLAM,
    OYSTER:   msg := 150;

    SNAKE:    msg := 46;

    DWARF:
        begin
	    if closed then dwarfend;
	    msg := 49;
	end;

    TROLL:  msg := 157;

    BEAR:   msg := 165+(prop[BEAR]+1) div 2;

    DRAGON:
        begin
	    if prop[DRAGON] <> 0 then
                begin
		    rspeak(167);
                    exit;
   	        end;

	    if not yes(49,0,0) then exit;

	    pspeak(DRAGON,1);
	    prop[DRAGON] := 2;
	    prop[RUG] := 0;
	    xmove((DRAGON+MAXOBJ),-1);
	    xmove((RUG+MAXOBJ),0);
	    xmove(DRAGON,120);
	    xmove(RUG,120);
	    for i := 1 to MAXOBJ-1 do
	        if (place[i] = 119) or (place[i] = 121) then
		    xmove(i,120);
	    newloc := 120;
	    exit;
        end;

    else
	actspk(verb);
	exit;
    end;

    rspeak(msg);
end;

{--------------------------------------------------------}
{                        POUR
{--------------------------------------------------------}

procedure vpour;
begin
	if (xobject = BOTTLE) or (xobject = PLANT) or (xobject = 0) then
	    xobject := liq;      { ???????????? diferente do original }

	if xobject = 0 then
            begin
		needobj;
		exit;
	    end;

	if not toting(xobject) then
            begin
		actspk(verb);
		exit;
	    end;

	if (xobject <> OIL) and (xobject <> WATER) then
            begin
		rspeak(78);
		exit;
            end;

	prop[BOTTLE] := 1;
	place[xobject] := 0;

	if at(PLANT) then
            begin
	        if xobject <> WATER then
	            rspeak(112)
	        else
                    begin
		        pspeak(PLANT,prop[PLANT]+1);
		        prop[PLANT] := (prop[PLANT]+2) mod 6;
		        prop[PLANT2] := prop[PLANT] div 2;
		        describe;
		    end;
            end
	else
        if at(DOOR) then
            begin
                if xobject = OIL then   prop[DOOR] := 1
                                 else   prop[DOOR] := 0;
		rspeak(113+prop[DOOR]);
	    end
	else
	    rspeak(77);
end;

{--------------------------------------------------------}
{                         EAT
{--------------------------------------------------------}

procedure veat;
var msg: integer;
begin
    case xobject of

	FOOD:
                  begin
		      dstroy(FOOD);
		      msg := 72;
	          end;

	BIRD, SNAKE, CLAM, OYSTER,
        DWARF, DRAGON, TROLL, BEAR:    msg := 71;

    else
	actspk(verb);
	exit;
    end;

    rspeak(msg);
end;

{--------------------------------------------------------}
{         	         DRINK
{--------------------------------------------------------}

procedure vdrink;
begin
    if xobject <> WATER then
         rspeak(110)
    else
    if (liq <> WATER) or (not here(BOTTLE)) then
        actspk(verb)
    else
        begin
	    prop[BOTTLE] := 1;
	    place[WATER] := 0;
	    rspeak(74);
        end;
end;

{--------------------------------------------------------}
{                         THROW etc.
{--------------------------------------------------------}

procedure vthrow;
var
    msg, i: integer;
begin
    if toting(ROD2) and (xobject = ROD) and (not toting(ROD)) then
        xobject := ROD2;

    if not toting(xobject) then
        begin
	    actspk(verb);
	    exit;
        end;

    { treasure to troll }

    if at(TROLL) and (xobject >= 50) and (xobject < MAXOBJ) then
        begin
	    rspeak(159);
	    xdrop(xobject,0);
	    xmove(TROLL,0);
	    xmove((TROLL+MAXOBJ),0);
	    xdrop(TROLL2,117);
	    xdrop((TROLL2+MAXOBJ),122);
	    juggle(CHASM);
	    exit;
        end;

    { feed the bears... }

    if (xobject = FOOD) and here(BEAR) then
        begin
	    xobject := BEAR;
	    vfeed;
	    exit;
        end;


    { if not axe, same as drop... }

    if xobject <> AXE then
        begin
	    vdrop;
	    exit;
        end;

    {  AXE is THROWN }

    {  at a dwarf... }

    i := dcheck;
    if i <> 0 then
        begin
	    msg := 48;
	    if pct(33) then
                begin
		    dseen[i] := 0;
                    dloc[i]  := 0;
		    msg := 47;
		    dkill := dkill + 1;
		    if dkill = 1 then
   		        msg := 149;
                end;
        end

    { at a dragon... }

    else
    if at(DRAGON) and (prop[DRAGON] = 0) then msg := 152

    { at the troll... }

    else
    if at(TROLL) then  msg := 158

    { at the bear... }
    else
    if here(BEAR) and (prop[BEAR] = 0) then
        begin
	    rspeak(164);
	    xdrop(AXE,loc);
	    fixed[AXE] := -1;
	    prop[AXE] := 1;
	    juggle(BEAR);
	    exit;
        end

    { otherwise it is an attack }

    else
        begin
	    verb := KILL;
	    xobject := 0;
	    itverb;
	    exit;
        end;

    { handle the left over axe... }

    rspeak(msg);
    xdrop(AXE,loc);
    describe;
end;

{--------------------------------------------------------}
{                  INVENTORY, FIND etc.
{--------------------------------------------------------}

procedure vfind;
var msg: integer;
begin
    if toting(xobject) then
        msg := 24
    else
    if closed then
        msg := 138
    else
    if (dcheck > 0) and (dflag >= 2) and (xobject = DWARF) then
        msg := 94
    else
    if at(xobject) or
       ((liq = xobject) and here(BOTTLE)) or
        (xobject = liqloc(loc)) then
	    msg := 94
    else
        begin
	    actspk(verb);
	    exit;
        end;

    rspeak(msg);
end;

{--------------------------------------------------------}
{                         FILL
{--------------------------------------------------------}

procedure vfill;
var i, msg: integer;
begin
    if xobject = 0 then
        if toting (BOTTLE) then xobject := BOTTLE
        else
        if toting (VASE) then xobject := VASE;

    case xobject of
    BOTTLE:
        begin
	    if liq <> 0        then   msg := 105
	    else
            if liqloc(loc) = 0 then   msg := 106
	    else
                begin
		    prop[BOTTLE] := cond[loc] and WATOIL;
		    i := liq;
		    if toting(BOTTLE) then
                        place[i] := -1;
                    if i = OIL then  msg := 108
                               else  msg := 107;
	        end;
	end;

    VASE:
        begin
	    if liqloc(loc) = 0  then   msg := 144
            else
            if not toting(VASE) then   msg := 29
            else
                begin
	           rspeak(145);
	           vdrop;
	           exit;
                end;
        end
    else
	msg := 29;
    end;

    rspeak(msg);
end;

{--------------------------------------------------------}
{                          FEED
{--------------------------------------------------------}

procedure vfeed;
var msg: integer;
begin
    case xobject of
        BIRD:   msg := 100;

	DWARF:  begin
		    if not here(FOOD) then
                        begin
			    actspk(verb);
			    exit;
                        end;
                    dflag := dflag + 1;
		    msg := 103;
		end;

	BEAR:   begin
		    if not here(FOOD) then
                        begin
			    if prop[BEAR] = 0 then  msg := 102
			    else
                            if prop[BEAR] = 3 then  msg := 110
			    else
                                begin
				    actspk(verb);
				    exit;
                                end;
                        end;

		    dstroy(FOOD);
		    prop[BEAR] := 1;
		    fixed[AXE] := 0;
		    prop[AXE] := 0;
		    msg := 168;
	        end;

	DRAGON: if prop[DRAGON] <> 0 then msg := 110
                                     else msg := 102;

	TROLL:  msg := 182;

	SNAKE:  if closed or (not here(BIRD)) then
  		    msg := 102
                else
                    begin
		        msg := 101;
		        dstroy(BIRD);
		        prop[BIRD] := 0;
		        tally2 := tally2 + 1;
		    end;

	else
		msg := 14;
    end;

    rspeak(msg);
end;

{--------------------------------------------------------}
{                        READ etc.
{--------------------------------------------------------}

procedure vread;
var msg: integer;
label ok;
begin
    msg := 0;
    if dark then
        begin
            sintWriteln (msgExtra[MSG_ISEENO] + strPas (probj) + msgExtra[MSG_HERE]);
            exit;
        end;

    case xobject of
        MAGAZINE:  msg := 190;
        TABLET:    msg := 196;
        MESSAGE:   msg := 191;
        OYSTER:    begin
                       if (not toting(OYSTER)) or (not closed) then
                           goto ok;
                       yes(192,193,54);
	               exit;
                   end;
    else
	;
    end;
ok:
    if msg <> 0 then
        rspeak(msg)
    else
	actspk(verb);
end;

{--------------------------------------------------------}
{                     BLAST etc.
{--------------------------------------------------------}

procedure vblast;
begin
    if (prop[ROD2] < 0) or (not closed) then
        actspk(verb)
    else
        begin
	    bonus := 133;
	    if loc = 115 then    bonus := 134;
	    if here(ROD2) then   bonus := 135;
	    rspeak(bonus);
	    normend;
        end;
end;

{--------------------------------------------------------}
{                     BREAK etc.
{--------------------------------------------------------}

procedure vbreak;
var msg: integer;
begin
    if xobject = MIRROR then
        begin
	    msg := 148;
	    if closed then
                begin
		    rspeak(197);
		    dwarfend;
	        end
        end
    else
    if (xobject = VASE) and (prop[VASE] = 0) then
        begin
	    msg := 198;
	    if toting(VASE) then
	        xdrop(VASE,loc);
	    prop[VASE] := 2;
	    fixed[VASE] := -1;
        end
    else
        begin
	    actspk(verb);
	    exit;
        end;

    rspeak(msg);
end;

{--------------------------------------------------------}
{                    WAKE etc.
{--------------------------------------------------------}

procedure vwake;
begin
    if (xobject <> DWARF) or (not closed) then
        actspk(verb)
    else
        begin
	    rspeak(199);
	    dwarfend;
        end;
end;

{--------------------------------------------------------}
{               processa verbos transistivos
{--------------------------------------------------------}

procedure trverb;
begin
    case verb of
	CALM, WALK, QUIT, SCORE,
	FOO, BRIEF, SUSPEND, HOURS,
        LOG:
		      actspk(verb);
	TAKE:         vtake;
	DROP:         vdrop;
	OPEN, LOCK:   vopen;
	SAY:          vsay;
	NOTHING:      rspeak(54);
	ON:           von;
	OFF:          voff;
	WAVE:         vwave;
	KILL:         vkill;
	POUR:         vpour;
	EAT:          veat;
	DRINK:        vdrink;
	RUB:          if (xobject <> LAMP) then
                          rspeak(76)
	              else
		          actspk(RUB);
	THROW:        vthrow;
	FEED:         vfeed;
	FIND,
	INVENTORY:    vfind;
	FILL:         vfill;
	READ:         vread;
	BLAST:        vblast;
	BREAK:        vbreak;
	WAKE:         vwake;
    else
	   	      sintWriteln (msgExtra[MSG_NOTIMPLEM]);
    end;
end;

end.