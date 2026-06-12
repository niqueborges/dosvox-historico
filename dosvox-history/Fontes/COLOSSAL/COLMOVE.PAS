{--------------------------------------------------------}
{
{    Caverna colossal - jogo de aventura
{
{    Módulo de movimentação
{
{    Em março/2001
{
{--------------------------------------------------------}

unit colmove;
interface
uses dvcrt, sysUtils, colvars, colmsg, colcave, colglob, colfinal;

procedure showMap (loc: integer);
procedure domove;
procedure badmove;
procedure spcmove(rdest: integer);
procedure goback;
procedure dotrav;

implementation

{--------------------------------------------------------}
{       preenche o vetor travel para uma certo lugar
{--------------------------------------------------------}

procedure gettrav(loc: integer);
var
    i: integer;
    t: longint;
    atrav, s: string;
    p: integer;
    erro: integer;
label fim;
begin
    atrav := strPas(cave[loc-1]);

    for i := 0 to MAXTRAV-1 do
        begin
            p := pos (',', atrav);
            if p = 0 then goto fim;

            s := copy (atrav, 1, p-1);
            delete (atrav, 1, p);

            val (s, t, erro);
            if erro <> 0 then bug (33);
	    travel[i].tcond := t mod 1000;
	    t := t div 1000;
	    travel[i].tverb := t mod 1000;
	    t := t div 1000;
	    travel[i].tdest := t mod 1000;
	end;

fim:
    travel[i].tdest := -1;    { end of array	}

    {if dbugflg then showMap (loc);}
end;

{--------------------------------------------------------}
{         se debug mostra o que fazer aqui
{--------------------------------------------------------}

procedure showMap (loc: integer);

var i, p: integer;
    s: string;
    ps: array [0..200] of char;
    saveColor: word;

    function getName (c: char; v: integer): string;
    var i: integer;
        s: string;
    begin
        str (v, s);
        getName := '#'+s;
        if      c = 'O' then v := v + 1000
        else if c = 'V' then v := v + 2000
        else if c = 'S' then v := v + 3000
        else if c = 'I' then v := v + 4000;

        for i := 1 to numWords do
             if wc[i].acode = v then
                     begin
                         getName := strpas (wc[i].aword);
                         exit;
                     end;
    end;

begin
    saveColor := textAttr;
    textColor (blue);

    writeln ('Lugar #', loc);
    gettrav (loc);

    for i := 0 to MAXTRAV-1 do
        with travel[i] do
          begin
             if tdest = -1 then
                 begin
                     textAttr := saveColor;
                     exit;
                 end;

             write ('    verbo ', getname ('M', tverb):12, ' ');

             case tcond div 100 of
                 0:     begin
                            if tcond = 0   then write('desvia para       ')
                            else
                            if tcond = 100 then write ('vai(n dw) para   ')
                                           else write ('probabilidade', tcond:2, '% ');
                        end;
                 1:     write ('se carregando      ', getname ('O', tcond - 100));
                 2:     write ('quando junto com   ', getname ('O', tcond - 200));
                 3..9:  write ('se prop.  ', (tcond mod 100),
                                       ' não ', (tcond div 100)-3, ' ');
             end;

             if (tdest > 300) and (tdest <=500) then
                 writeln ('<caso especial>', tdest-300)
             else
             if tdest > 500 then
                 writeln ('<mesmo lugar>, mensagem  ', tdest-500)
             else
                 begin
                     str (tdest, s);
                     strPCopy (ps, '#' + s);
                     p := 0;
                     repeat
                         p := p + 1;
                     until strcomp (msgPlaces2[p], ps) = 0;
                     repeat
                         p := p + 1;
                     until strPas(msgPlaces2[p]) <> '';
                     writeln (tdest:3, ' ', copy (strPas(msgPlaces2[p]), 1,  30));
                 end;
	end;

    textAttr := saveColor;
end;

{--------------------------------------------------------}
{               retorna para onde veio
{--------------------------------------------------------}

procedure goback;
var
    i, kk, k2, want, temp: integer;
    strav: array [0..MAXTRAV-1] of TTrav;
begin
    if forced(oldloc) then
        want := oldloc2
    else
        want := oldloc;
    oldloc2 := oldloc;
    oldloc := loc;
    k2 := 0;

    if (want = loc) then
        begin
	    rspeak(91);
	    exit;
	end;

    for i := 0 to MAXTRAV-1 do
        strav[i] := travel[i];

    kk := 0;
    while travel[kk].tdest <> -1 do
        begin
	    if (travel[kk].tcond = 0) and (travel[kk].tdest = want) then
               begin
		    motion := travel[kk].tverb;
		    dotrav;
		    exit;
	       end;

	    if travel[kk].tcond = 0 then
                begin
		    k2 := kk;
		    temp := travel[kk].tdest;
		    if temp < 300 then
			begin
			    gettrav(temp);
			    if forced(temp) and (travel[0].tdest = want) then
				k2 := temp;
			    for i := 0 to MAXTRAV-1 do
				travel[i] := strav[i];
			end;
		end;

            kk := kk + 1;
        end;

    if k2 <> 0 then
        begin
	    motion := travel[k2].tverb;
	    dotrav;
        end
    else
        rspeak(140);
end;

{--------------------------------------------------------}
{                 manipula movimentos
{--------------------------------------------------------}

procedure domove;
begin
    gettrav(loc);

    case motion of
        NULLX:  ;

        BACK:   goback;

        LOOK:   begin
	            if detail < 3 then rspeak(15);
                    detail := detail + 1;
	            wzdark := false;
	            visited[loc] := false;
	            newloc := loc;
	            loc := 0;
	        end;

        CAVEX:
	        if loc < 8 then  rspeak(57)
	                   else  rspeak(58);

    else
        oldloc2 := oldloc;
	oldloc := loc;
	dotrav;
    end;
end;

{--------------------------------------------------------}
{   descobre lugar dada o lugar corrente e a "motion"
{--------------------------------------------------------}

procedure dotrav;
var
    mvflag, hitflag: boolean;
    kk: integer;
    rdest, rverb, rcond, robject: integer;
    pctt: integer;
label next;
begin
    newloc := loc;
    mvflag := false;
    hitflag := false;
    pctt := random(100);

    kk := 0;
    while (travel[kk].tdest >=0) and (not mvflag) do
        begin
	    rdest := travel[kk].tdest;
	    rverb := travel[kk].tverb;
	    rcond := travel[kk].tcond;
	    robject := rcond mod 100;

	    if (rverb <> 1) and (rverb <> motion) and (not hitflag) then
		    goto next;

	    hitflag := true;

	    case rcond div 100 of
	    0:  begin
		    if (rcond = 0) or (pctt < rcond) then
		        mvflag := true;
		    if (rcond <> 0) and dbugflg then
			writeln ('-----> Move ', pctt, ' ', mvflag);
		end;

	    1:  begin
		    if robject = 0 then
		        mvflag := true
		    else
                    if (toting(robject)) then
	                mvflag := true;
	        end;

	    2:  if toting(robject) or at(robject) then
	            mvflag := true;

	    3, 4, 5, 7:
                begin
                    if dbugflg then
                        begin
                            writeln ('-----> rcond=',rcond);
                            writeln ('-----> prop =',prop[robject]);
                        end;

	            if prop[robject] <> (rcond div 100) - 3 then
		        mvflag := true;
                end;
	    else
		bug(37);
	    end;
next:
            kk := kk + 1;
        end;

    if not mvflag then
	    badmove
    else
    if rdest > 500 then
	    rspeak(rdest-500)
    else
    if rdest > 300 then
	    spcmove(rdest)
    else
        begin
	    newloc := rdest;
	    if dbugflg then
		 writeln ('-----> Newloc in dotrav = ', newloc);

        end;
end;

{--------------------------------------------------------}
{           o jogador tentou um movimento bobo
{--------------------------------------------------------}

procedure badmove;
var msg: integer;
begin
    msg := 12;
    if (motion >= 43) and  (motion <= 50)     then msg := 9;
    if (motion = 29)  or   (motion = 30)      then msg := 9;
    if (motion = 7)   or   (motion = 36) or
                           (motion = 37)      then msg := 10;
    if (motion = 11)  or   (motion = 19)      then msg := 11;
    if (verb = FIND)  or   (verb = INVENTORY) then msg := 59;
    if (motion = 62)  or   (motion = 65)      then msg := 42;
    if (motion = 17)                          then msg := 80;
    rspeak(msg);
end;

{--------------------------------------------------------}
{              trata movimento muito especial
{--------------------------------------------------------}

procedure spcmove(rdest: integer);
begin
	case (rdest-300) of
	1:  { plover movement via alcove }
		if (holding = 0) or
                    ((holding = 1) and toting(EMERALD)) then
			newloc := (99+100)-loc
		else
			rspeak(117);

	2:  { trying to remove plover, bad route }
		xdrop(EMERALD, loc);

	3:  { troll bridge }
		if prop[TROLL] = 1 then
                    begin
			pspeak(TROLL, 1);
			prop[TROLL] := 0;
			xmove(TROLL2, 0);
			xmove((TROLL2+MAXOBJ), 0);
			xmove(TROLL, 117);
			xmove((TROLL+MAXOBJ), 122);
			juggle(CHASM);
			newloc := loc;
		    end
		else
                    begin
                        if loc = 117 then  newloc := 122
                                     else  newloc := 117;
			if prop[TROLL] = 0 then
			    prop[TROLL] := prop[TROLL] + 1;

			if not toting (BEAR) then exit;

			rspeak(162);
			prop[CHASM] := 1;
			prop[TROLL] := 2;
			xdrop(BEAR, newloc);
			fixed[BEAR] := -1;
			prop[BEAR] := 3;
			if prop[SPICES] < 0 then
			    tally2 := tally2 + 1;
			oldloc2 := newloc;
			death;
		    end;

	else
		bug(38);
	end;
end;

end.
