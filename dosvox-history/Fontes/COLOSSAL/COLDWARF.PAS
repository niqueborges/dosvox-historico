{--------------------------------------------------------}
{
{    Caverna colossal - jogo de aventura
{
{    Módulo de tratamento dos anões
{
{    Em março/2001
{
{--------------------------------------------------------}

unit coldwarf;
interface
uses dvwin, dvcrt,
     colvars, colglob, colmsg, colfinal;

function dcheck: integer;
procedure dwarves;
procedure dwarfend;

implementation

{--------------------------------------------------------}
{              checa a presença de anões
{--------------------------------------------------------}

function dcheck: integer;
var i: integer;
begin
    for i := 1 to DWARFMAX-2 do
        if dloc[i] = loc then
             begin
                 dcheck := i;
                 exit;
             end;
    dcheck := 0;
end;

{--------------------------------------------------------}
{                 processamento do pirata
{--------------------------------------------------------}

procedure dopirate;
var
    j, k: integer;

label stealit;

begin
	if (newloc = chloc) or (prop[CHEST] >= 0) then
	    exit;

	k := 0;
	for j := 50 to MAXTRS do
            begin
		if (j <> PYRAMID) or
                   (  (newloc <> place[PYRAMID]) and
		      (newloc <> place[EMERALD])  ) then
                        begin
			     if toting(j) then
			          goto stealit;
			     if (here(j)) then inc(k);
                        end;
            end;

	if (tally = tally2+1) and
           (k = 0) and
           (place[CHEST] = 0) and
	   (here(LAMP) and (prop[LAMP] = 1)) then
            begin
		rspeak(186);
		xmove(CHEST, chloc);
		xmove(MESSAGE, chloc2);
		dloc[6] := chloc;
		odloc[6] := chloc;
		dseen[6] := 0;
		exit;
	    end;

	if (odloc[6] <> dloc[6]) and pct(20) then
            begin
		rspeak(127);
		exit;
	    end;

	exit;

stealit:
	rspeak(128);
	if place[MESSAGE] = 0 then
	    xmove(CHEST, chloc);
	xmove(MESSAGE, chloc2);

	for j := 50 to MAXTRS do
            begin
		if (j = PYRAMID) and
                   ((newloc = place[PYRAMID]) or (newloc = place[EMERALD])) then
			continue;
		if at(j) and (fixed[j] = 0) then
		    carry(j, newloc);
		if toting(j) then
		    xdrop(j, chloc);
	    end;

	dloc[6] := chloc;
	odloc[6] := chloc;
	dseen[6] := 0;
end;

{--------------------------------------------------------}
{               processamento dos anões
{--------------------------------------------------------}

procedure dwarves;
var
    i, j, k, tries, attack, stick, dtotal: integer;
label ok;
begin
    { see if dwarves allowed here }

    if  (newloc = 0) or forced(newloc) or
        ((cond[newloc] and NOPIRAT) <> 0) then
	    exit;

    { see if dwarves are active. }

    if dflag = 0 then
        begin
	    if newloc > 15 then dflag := dflag + 1;
	    exit;
        end;

    { if first close encounter (of 3rd kind) kill 0, 1 or 2 }

    if dflag = 1 then
    begin
	    if (newloc < 15) or pct(95) then
		exit;

	    dflag := dflag + 1;
	    for i := 1 to 2 do
                if pct(50) then
		    dloc[random(5)+1] := 0;

	    for i := 1 to DWARFMAX-2 do
                begin
		    if dloc[i] = newloc then
                        dloc[i] := daltloc;
		    odloc[i] := dloc[i];
    	        end;
	    rspeak(3);
	    xdrop(AXE, newloc);
	    exit;
    end;

    dtotal := 0;
    attack := 0;
    stick  := 0;
    for i := 1 to DWARFMAX-1 do
        begin
	    if dloc[i] = 0 then continue;

            { move a dwarf at random. }

	    for tries := 1 to 20 do
                begin
		    j := random(106)+15;  { allowed area }
		    if (j <> odloc[i]) and (j <> dloc[i]) and
		       (i <> DWARFMAX-1) and ((cond[j] and NOPIRAT) <> 0) then
                           goto ok;
	        end;
ok:
	    if j = 0 then j := odloc[i];
	    odloc[i] := dloc[i];
	    dloc[i] := j;
	    if ((dseen[i] <> 0) and (newloc >= 15)) or
		      (dloc[i] = newloc) or
                      (odloc[i] = newloc) then
		dseen[i] := 1
	    else
		dseen[i] := 0;

	    if dseen[i] = 0 then continue;

	    dloc[i] := newloc;
	    if i = 6 then
	        dopirate
	    else
                begin
		    dtotal := dtotal + 1;
		    if odloc[i] = dloc[i] then
                        begin
			    attack := attack + 1;
			    if knfloc >= 0 then
			        knfloc := newloc;
			    if (random(1000) < (95*(dflag-2))) then
			        stick := stick + 1;
		        end;
	        end;
    end;

    if dtotal = 0 then exit;

    if (dtotal > 1) then
        begin
            sintWriteint (dtotal);
            sintWriteln (msgExtra[MSG_DWARF]);
        end
    else
        rspeak(4);

    if attack = 0 then exit;

    if dflag = 2 then
        dflag := dflag + 1;

    if attack > 1 then
        begin
            sintWriteint (attack);
            sintWriteln (msgExtra[MSG_ATTACK]);
	    k := 6;
        end
    else
        begin
	    rspeak(5);
	    k := 52;
        end;

    if stick <= 1 then
        begin
	    rspeak(stick+k);
	    if stick = 0 then exit;
        end
    else
        begin
            sintWriteint (stick);
            sintWriteln (msgExtra[MSG_STUCK]);
        end;

    oldloc2 := newloc;
    death;
end;

{--------------------------------------------------------}
{    trata desistência do usuário acordando os anões
{--------------------------------------------------------}

procedure dwarfend;
begin
    death;
    normend;
end;

end.